***************************************************************************************************************************************************************
**********                                                                    									    								 **********
**********        ARTICLE: Involvement of Component Auditors in Multinational Group Audits: Determinants, Audit Quality and Audit Fees		         **********
**********        AUTHORS: Elizabeth Carson, Roger Simnett, Ulrike Thuerheimer, Ann Vanstraelen													     **********
**********        JOURNAL: Journal of Accounting Research                                                 											 **********
**********                                                                    								             							 **********
**********        DESCRIPTION:                                       										     									 **********
**********        The following STATA do files convert the raw data into our final dataset.   						    			     			 **********
**********        Additional explanations are contained in the accompanying data sheet "CSTV_GroupAudits_DataSheet.pdf".  							 **********
**********        The STATA data file "Identifier_Final Sample.dta" includes the company-years that enter our final samples. We identify companies   **********       
**********        based on their (historic) ASX code.		                   									    								 **********
**********        We share hand-collected data on subsidiaries and audit firm location coverage in the folder "data". All other data can be accessed **********
**********        through databases as identified in the paper.                									    								 **********
**********                                                                    									    								 **********
***************************************************************************************************************************************************************

***************************************************************************************************************************************************************
*Set directory. Replace with correct file path.
global base "\CSTV_GroupAudits"
cd "$base"

***************************************************************************************************************************************************************
*1. Load and clean Aspect Huntley Financial Data
do ".\code\1_Generate_Aspect_Huntley_Financial_Data.do"

***************************************************************************************************************************************************************
*2. Load and Clean SPPR Data and merge with (1.)
do ".\code\2_SPPR_Merge_Aspect_Huntley.do"

***************************************************************************************************************************************************************
*3. Load and Clean UNSW Audit Fee and Reporting Data
do ".\code\3_Generate_UNSW_Audit_Data.do"

***************************************************************************************************************************************************************
*4. Merge (3.) with (2.)
do ".\code\4_SPPR_Merge_AspectHuntley_Merge_UNSWAudit.do"

***************************************************************************************************************************************************************
*5. Extract share price from SPPR database
do ".\code\5_Generate_SPPRprice.do"

***************************************************************************************************************************************************************
*6. Merge (4.) with (5.)
do ".\code\6_Merge_SPPRprice.do"

***************************************************************************************************************************************************************
*7. Calculate Annual Return
do ".\code\7_Generate_Annual_Return_Data.do"

***************************************************************************************************************************************************************
*8. Merge (6.) with (7.)
do ".\code\8_Merge_AnnualReturn.do"

***************************************************************************************************************************************************************
*9. Append annual data from step 8
do ".\code\9_Append_Data Selection.do"

***************************************************************************************************************************************************************
*10. Subsidiary data
do ".\code\Subsidiary_Data.do"

***************************************************************************************************************************************************************
*11. Impute Missing Information
do ".\code\11_Hand-collected Missing Fin Data.do"

***************************************************************************************************************************************************************
*12. Define Variables
do ".\code\12_DefineVariables.do"

***************************************************************************************************************************************************************
*13. Add additional financial variables
do ".\code\13_Merging_PayableData.do"

***************************************************************************************************************************************************************
*14. Add additional financial variables
do ".\code\14_SubsidiaryCountry Variables.do"

***************************************************************************************************************************************************************
*Load data file with company identifiers-years of the final sample
use ".\data\Identifier_Final Sample.dta"

version 14.0
set more off
log cap close

**step 1: import Aspect ASX Financials data and reshape**
clear 
cd "$base"

import delimited ".\data\AspectASXFinancials.csv"
reshape wide value, i(date asxcode prelim) j(itemid)
sort asxcode date
save ".\data\AspectASXFinancials_short-format.dta", replace
*******************************

**step 2: trim data and generate date variable**
clear
cd "$base"
use ".\data\AspectASXFinancials_short-format.dta"
replace asxcode= trim( asxcode )
replace date = trim( date )
replace prelim = trim( prelim )
gen date2= date
replace date2=substr(date2, 1, 10)
gen date3 = date(date2, "DMY")
format date3 %td
drop date2
order date3, after(date)
save ".\data\Aspect_1.dta", replace
****************************************

**step 3: extract data for each year, delete financial reports for periods not equal to 12 months, delete NZ companies**
**FY2000**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
format %10.0g value0
gsort asxcode +date3
count if date3>=td(1,1,2000)& date3<=td(31,12,2000)
duplicates report asxcode if date3>=td(1,1,2000)& date3<=td(31,12,2000)
duplicates list asxcode if date3>=td(1,1,2000)& date3<=td(31,12,2000)
drop if asxcode=="ABC" & value0==20000630
drop if asxcode=="AOE" & value0==20000332
drop if asxcode=="CCP" & value0==20000332
drop if asxcode=="EVZ" & value0==20000532
drop if asxcode=="GCL" & value0==20000630
drop if asxcode=="GWF" & value0==20000332
drop if asxcode=="ICU" & value0==20000532
drop if asxcode=="OOH" & value0==20000430
drop if asxcode=="PLC" & value0==20000630
drop if asxcode=="PLN" & value0==20000930
drop if asxcode=="QBE" & value0==20001232
drop if asxcode=="RBL" & missing(value1)
drop if asxcode=="RCT" & value0==20001232
drop if asxcode=="SLN" & value0==20000332
drop if asxcode=="STA" & value0==20000228
drop if asxcode=="TWD" & value0==20000532
keep if date3>=td(1,1,2000)& date3<=td(31,12,2000)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2000.dta", replace
********************************************************************

**FY2001**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
format %10.0g value0
gsort asxcode +date3
count if date3>=td(1,1,2001)& date3<=td(31,12,2001)
duplicates report asxcode if date3>=td(1,1,2001)& date3<=td(31,12,2001)
duplicates list asxcode if date3>=td(1,1,2001)& date3<=td(31,12,2001)
drop if asxcode=="ALN" & value0==20011232
drop if asxcode=="AXA" & value0==20011232
drop if asxcode=="BLE" & value0==20011232
drop if asxcode=="BWA" & value0==20011232
drop if asxcode=="CBK" & value0==20011232
drop if asxcode=="CHY" & missing(value0)
drop if asxcode=="CHY" & value0==20011232
drop if asxcode=="ERA" & value0==20011232
drop if asxcode=="OTI" & value0==20011232
drop if asxcode=="WJM" & value0==20011232
keep if date3>=td(1,1,2001)& date3<=td(31,12,2001)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2001.dta", replace
********************************************************************

**FY2002**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
format %10.0g value0
//format %12.0g value4000
gsort asxcode +date3
count if date3>=td(1,1,2002)& date3<=td(31,12,2002)
duplicates report asxcode if date3>=td(1,1,2002)& date3<=td(31,12,2002)
duplicates list asxcode if date3>=td(1,1,2002)& date3<=td(31,12,2002)
drop if asxcode=="APL" & value0==20021232
drop if asxcode=="BTA" & missing(value0)
drop if asxcode=="ELC" & value0==20021232
drop if asxcode=="EMM" & value0==20021232
drop if asxcode=="EOS" & value0==20021232
drop if asxcode=="GDO" & value0==20021232
drop if asxcode=="KLR" & value0==20021030
drop if asxcode=="NFM" & value0==20021232
drop if asxcode=="REB" & value0==20020332
drop if asxcode=="TAN" & value0==20021232
drop if asxcode=="TIM" & value0==20020930
keep if date3>=td(1,1,2002)& date3<=td(31,12,2002)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2002.dta", replace
********************************************************************

**FY2003**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
format %10.0g value0
gsort asxcode +date3
count if date3>=td(1,1,2003)& date3<=td(31,12,2003)
duplicates report asxcode if date3>=td(1,1,2003)& date3<=td(31,12,2003)
duplicates list asxcode if date3>=td(1,1,2003)& date3<=td(31,12,2003)
drop if asxcode=="AGJ" & value0==20030328
drop if asxcode=="CRD" & value0==20031232
drop if asxcode=="IDE" & value0==20031232
drop if asxcode=="OPS" & value0==20031230
drop if asxcode=="SAX" & value0==20031232
drop if asxcode=="TAP" & value0==20031232
keep if date3>=td(1,1,2003)& date3<=td(31,12,2003)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2003.dta", replace
********************************************************************

**FY2004**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
format %10.0g value0
gsort asxcode +date3
count if date3>=td(1,1,2004)& date3<=td(31,12,2004)
duplicates report asxcode if date3>=td(1,1,2004)& date3<=td(31,12,2004)
duplicates list asxcode if date3>=td(1,1,2004)& date3<=td(31,12,2004)
drop if asxcode=="AAC" & value0==20041232
drop if asxcode=="ATM" & missing(value0)
drop if asxcode=="AVM" & value0==20041232
drop if asxcode=="AZA" & value0==20041030
drop if asxcode=="BMX" & value0==20041232
drop if asxcode=="BWD" & value0==20040332
drop if asxcode=="CPS" & missing(value0)
drop if asxcode=="IPA" & value0==20040312
drop if asxcode=="MRE" & value0==20041232
drop if asxcode=="MZI" & value0==20040430
drop if asxcode=="PMY" & value0==20040132
drop if asxcode=="SOM" & value0==20040332
drop if asxcode=="WFD" & value0==20041232
keep if date3>=td(1,1,2004)& date3<=td(31,12,2004)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2004.dta", replace
********************************************************************

********************************************************************
**FY2005**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
sort asxcode date
count if date3>=td(1,1,2005)& date3<=td(31,12,2005)
duplicates report asxcode if date3>=td(1,1,2005)& date3<=td(31,12,2005)
duplicates list asxcode if date3>=td(1,1,2005)& date3<=td(31,12,2005)
drop if asxcode=="EPY" & value0==20051232
drop if asxcode=="ETR" & missing(value0)
drop if asxcode=="HDR" & value0==20051232
drop if asxcode=="IFS" & value0==20051232
drop if asxcode=="KGL" & value0==20051232
drop if asxcode=="KOR" & missing(value9060)
drop if asxcode=="MOE" & value0==20051232
drop if asxcode=="PNA" & value0==20051232
drop if asxcode=="VAH" & value0==20050930
keep if date3>=td(1,1,2005)& date3<=td(31,12,2005)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2005.dta", replace
********************************************************************

********************************************************************
**FY2006**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
sort asxcode date
format %10.0g value0
count if date3>=td(1,1,2006)& date3<=td(31,12,2006)
duplicates report asxcode if date3>=td(1,1,2006)& date3<=td(31,12,2006)
duplicates list asxcode if date3>=td(1,1,2006)& date3<=td(31,12,2006)
drop if asxcode=="AJL" & missing(value0)
drop if asxcode=="AKK" & value0==20060630
drop if asxcode=="AZZ" & value0==20061232
drop if asxcode=="BUR" & value0==20060228
drop if asxcode=="CAJ" & value0==20060332
drop if asxcode=="CDT" & value0==20060316
drop if asxcode=="CKP" & value0==20060630
drop if asxcode=="CNQ" & value0==20060332
drop if asxcode=="GGG" & value0==20060428
drop if asxcode=="IPA" & missing(value0)
drop if asxcode=="IPO" & value0==20060132
drop if asxcode=="LHB" & value0==20060600
drop if asxcode=="LLO" & value0==20060132
drop if asxcode=="MIN" & value0==20060630
drop if asxcode=="MTH" & value0==20060816
drop if asxcode=="CZL" & value0==20060410
drop if asxcode=="RHS" & value0==20061230
drop if asxcode=="SIE" & value0==20061232
drop if asxcode=="TMR" & value0==20061232
keep if date3>=td(1,1,2006)& date3<=td(31,12,2006)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2006.dta", replace
*****************************************************************************

********************************************************************
**FY2007**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
sort asxcode date
format %10.0g value0
count if date3>=td(1,1,2007)& date3<=td(31,12,2007)
duplicates report asxcode if date3>=td(1,1,2007)& date3<=td(31,12,2007)
duplicates list asxcode if date3>=td(1,1,2007)& date3<=td(31,12,2007)
drop if asxcode=="AKI" & value0==20070332
drop if asxcode=="API" & value0==20070832
drop if asxcode=="AUQ" & value0==20070332
drop if asxcode=="CIA" & value0==20070132
drop if asxcode=="EMC" & value0==20070630
drop if asxcode=="GTR" & value0==20070430
drop if asxcode=="MAU" & value0==20070332
drop if asxcode=="NFE" & value0==20071032
drop if asxcode=="OKU" & value0==20070328
drop if asxcode=="RLC" & value0==20070332
drop if asxcode=="SFI" & value0==20070228
drop if asxcode=="SAV" & value0==20070631
drop if asxcode=="VMC" & value0==20070320
drop if asxcode=="VSC" & value0==20070630
keep if date3>=td(1,1,2007)& date3<=td(31,12,2007)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2007.dta", replace
*****************************************************************************

********************************************************************
**FY2008**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
sort asxcode date
count if date3>=td(1,1,2008)& date3<=td(31,12,2008)
duplicates report asxcode if date3>=td(1,1,2008)& date3<=td(31,12,2008)
duplicates list asxcode if date3>=td(1,1,2008)& date3<=td(31,12,2008)
drop if asxcode=="AII" & value0==20081232
drop if asxcode=="APH" & value0==20081232
drop if asxcode=="CVR" & value0==20081232
drop if asxcode=="EMG" & value0==20080332
drop if asxcode=="HER" & value0==20081232
drop if asxcode=="ICG" & value0==20080132
drop if asxcode=="ICH" & value0==20081232
drop if asxcode=="IVA" & value0==20080430
drop if asxcode=="NMG" & value0==20080332
keep if date3>=td(1,1,2008)& date3<=td(31,12,2008)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2008.dta", replace
*****************************************************************************

********************************************************************
**FY2009**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
sort asxcode date
count if date3>=td(1,1,2009)& date3<=td(31,12,2009)
duplicates report asxcode if date3>=td(1,1,2009)& date3<=td(31,12,2009)
duplicates list asxcode if date3>=td(1,1,2009)& date3<=td(31,12,2009)
drop if asxcode=="AJJ" & value0==20090630
drop if asxcode=="ELD" & value0==20090630
drop if asxcode=="FND" & value0==20091232
drop if asxcode=="GGG" & value0==20091232
drop if asxcode=="GXY" & value0==20091232
drop if asxcode=="MBN" & value0==20091232
drop if asxcode=="PEM" & value0==20091232
drop if asxcode=="SGL-NZ" & value0==20090630
drop if asxcode=="SUM" & value0==20091232
keep if date3>=td(1,1,2009)& date3<=td(31,12,2009)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2009.dta", replace
*****************************************************************************

********************************************************************
**FY2010**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
sort asxcode date
format %10.0g value0
count if date3>=td(1,1,2010)& date3<=td(31,12,2010)
duplicates report asxcode if date3>=td(1,1,2010)& date3<=td(31,12,2010)
duplicates list asxcode if date3>=td(1,1,2010)& date3<=td(31,12,2010)
drop if asxcode=="AKP" & value0==20101232
drop if asxcode=="AUT" & value0==20101232
drop if asxcode=="BDR" & value0==20101232
drop if asxcode=="CQA" & value0==20100930
drop if asxcode=="DLX" & value0==20100332
drop if asxcode=="EDT" & value0==20101232
drop if asxcode=="EEG" & value0==20101232
drop if asxcode=="EME" & value0==20101232
drop if asxcode=="GRR" & value0==20101232
drop if asxcode=="KGD" & value0==20100630
drop if asxcode=="MDO" & value0==20100630
drop if asxcode=="MNB" & value0==20100532
drop if asxcode=="MNC" & value0==20101232
drop if asxcode=="MOL" & value0==20101232
drop if asxcode=="MSF" & value0==20101232
drop if asxcode=="ONL" & value0==20101232
drop if asxcode=="RAF" & value0==20101232
drop if asxcode=="RMT" & value0==20101232
drop if asxcode=="RVA" & value0==20100930
drop if asxcode=="SCG" & value0==20101232
drop if asxcode=="SFG" & value0==20100630
drop if asxcode=="SOC" & value0==20100916
drop if asxcode=="TGS" & value0==20101232
keep if date3>=td(1,1,2010)& date3<=td(31,12,2010)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
duplicates report asxcode
save ".\data\Financial_Data_2010.dta", replace
****************************************************************************

********************************************************************
**FY2011**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
sort asxcode date
format %10.0g value0
count if date3>=td(1,1,2011)& date3<=td(31,12,2011)
duplicates report asxcode if date3>=td(1,1,2011)& date3<=td(31,12,2011)
duplicates list asxcode if date3>=td(1,1,2011)& date3<=td(31,12,2011)
drop if asxcode=="ALD" & value0==20110630
drop if asxcode=="AMX" & value0==20111232
drop if asxcode=="AOK" & value0==20111232
drop if asxcode=="AZY" & value0==20110130
drop if asxcode=="BRN" & value0==20110630
drop if asxcode=="CIM" & value0==20111232
drop if asxcode=="CQA" & value0==20110332
drop if asxcode=="DMI" & value0==20110316
drop if asxcode=="DTR" & value0==20110228
drop if asxcode=="EVR" & value0==20110630
drop if asxcode=="EXC" & value0==20110228
drop if asxcode=="FCG" & value0==20110832
drop if asxcode=="KPL" & value0==20110532
drop if asxcode=="KRL" & value0==20111232
drop if asxcode=="MDL" & value0==20111232
drop if asxcode=="MSR" & value0==20111232
drop if asxcode=="PGI" & value0==20110630
drop if asxcode=="RFV" & value0==20110228
drop if asxcode=="SHC" & value0==20111232
drop if asxcode=="SLE" & value0==20111232
drop if asxcode=="SPH" & value0==20110630
keep if date3>=td(1,1,2011)& date3<=td(31,12,2011)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
replace asxcode=trim(asxcode)
duplicates report asxcode
save ".\data\Financial_Data_2011.dta", replace
*****************************************************************************

********************************************************************
**FY2012**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
sort asxcode date
format %10.0g value0
count if date3>=td(1,1,2012)& date3<=td(31,12,2012)
duplicates report asxcode if date3>=td(1,1,2012)& date3<=td(31,12,2012)
duplicates list asxcode if date3>=td(1,1,2012)& date3<=td(31,12,2012)
drop if asxcode=="ADX" & value0==20121232
drop if asxcode=="ATU" & value0==20120430
drop if asxcode=="CPL" & value0==20121232
drop if asxcode=="CYY" & value0==20121232
drop if asxcode=="D13" & value0==20120302
drop if asxcode=="LNR" & value0==20121232
drop if asxcode=="LRL" & value0==20121232
drop if asxcode=="MIZ" & value0==20121232
drop if asxcode=="MPO" & value0==20121232
drop if asxcode=="MTA" & value0==20120630
drop if asxcode=="NEN" & value0==20121232
drop if asxcode=="NWF" & value0==20120228
drop if asxcode=="OFW" & value0==20120630
drop if asxcode=="SEA" & value0==20121232
drop if asxcode=="SFI" & value0==20121232
drop if asxcode=="TFL" & value0==20121232
drop if asxcode=="VMT" & value0==20121232
drop if asxcode=="VRT" & value0==20121232
keep if date3>=td(1,1,2012)& date3<=td(31,12,2012)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
replace asxcode=trim(asxcode)
duplicates report asxcode
save ".\data\Financial_Data_2012.dta", replace
*****************************************************************************

********************************************************************
**FY2013**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
sort asxcode date
format %10.0g value0
count if date3>=td(1,1,2013)& date3<=td(31,12,2013)
duplicates report asxcode if date3>=td(1,1,2013)& date3<=td(31,12,2013)
duplicates list asxcode if date3>=td(1,1,2013)& date3<=td(31,12,2013)
drop if asxcode=="AFJ" & value0==20130630
drop if asxcode=="APY" & value0==20131232
drop if asxcode=="AQU" & value0==20130630
drop if asxcode=="BRK" & value0==20131230
drop if asxcode=="BRU" & value0==20131232
drop if asxcode=="CAS" & value0==20131232
drop if asxcode=="CCF" & value0==20130930
drop if asxcode=="DVN" & value0==20131232
drop if asxcode=="FLN" & value0==20130630
drop if asxcode=="FML" & value0==20131230
drop if asxcode=="GNE" & value0==20131232
drop if asxcode=="ISH" & value0==20131232
drop if asxcode=="KPC" & value0==20131232
drop if asxcode=="LOM" & value0==20131232
drop if asxcode=="LRS" & value0==20131232
drop if asxcode=="NWS" & value0==20130332
drop if asxcode=="SBB" & value0==20130532
keep if date3>=td(1,1,2013)& date3<=td(31,12,2013)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
replace asxcode=trim(asxcode)
duplicates report asxcode
save ".\data\Financial_Data_2013.dta", replace
********************************************************************

********************************************************************
**FY2014**
clear
cd "$base"
use ".\data\Aspect_1.dta"
replace asxcode = upper(asxcode)
sort asxcode date
format %10.0g value0
count if date3>=td(1,1,2014)& date3<=td(31,12,2014)
duplicates report asxcode if date3>=td(1,1,2014)& date3<=td(31,12,2014)
duplicates list asxcode if date3>=td(1,1,2014)& date3<=td(31,12,2014)
drop if asxcode=="AB1" & value0==20141232
drop if asxcode=="APO" & value0==20140630
drop if asxcode=="AVB" & value0==20141232
drop if asxcode=="BAL" & value0==20140332
drop if asxcode=="DDR" & value0==20141232
drop if asxcode=="DNK" & value0==20141232
drop if asxcode=="ECG" & value0==20141232
drop if asxcode=="ERX" & value0==20141112
drop if asxcode=="FFG" & value0==20141232
drop if asxcode=="FTH" & value0==20140132
drop if asxcode=="HGO" & value0==20141232
drop if asxcode=="KRS" & value0==20141232
drop if asxcode=="LAA" & value0==20141232
drop if asxcode=="MAD" & value0==20141232
drop if asxcode=="MIG" & value0==20141232
drop if asxcode=="OGX" & value0==20141232
drop if asxcode=="OML" & value0==20140630
drop if asxcode=="OPG" & value0==20141232
drop if asxcode=="RXH" & value0==20140332
drop if asxcode=="SGC" & value0==20141232
drop if asxcode=="TNK" & value0==20140720
drop if asxcode=="TPO" & value0==20140332
drop if asxcode=="WEL" & value0==20140532
drop if asxcode=="XAM" & value0==20141232
drop if asxcode=="YPB" & value0==20141232
keep if date3>=td(1,1,2014)& date3<=td(31,12,2014)
count
*Retain only Australian companies, delete NZ and asxcode more than 3 digits*
gen nz= asxcode
replace nz=substr(nz, 4, .)
replace nz="0" if missing(nz)
count if nz=="0"
drop if nz !="0"
drop nz
count
replace asxcode=trim(asxcode)
duplicates report asxcode
save "C.\data\Financial_Data_2014.dta", replace
********************************************************************



version 14.0
set more off
log cap close

clear
cd "$base"
use ".\data\Subsidiaries.dta"

***Generate Subsidiary Region Dummies (as defined in online appendix Table S1, Panel C***
foreach var of varlist SUBSANTIGUAANDBARBUDA - SUBSZimbabweAfrica {
generate XX_`var'=`var'
}

gen XX_SUBS_UK=XX_SUBSChannelIslandsEurope+XX_SUBSEnglandEurope+XX_SUBSGuernseyEurope+XX_SUBSIrelandEurope+XX_SUBSRepublicofIrelandE+XX_SUBSIsleofManEurope+XX_SUBSJerseyEurope+XX_SUBSNorthernIrelandEuro+XX_SUBSScotlandEurope+XX_SUBSUKEurope

gen XX_SUBS_EuropeOther=XX_SUBSAlbania+XX_SUBSAustriaEurope+XX_SUBSBelgiumEurope+XX_SUBSBosniaHerzegovinaEurope+XX_SUBSBulgariaEurope+XX_SUBSCroatiaEurope+XX_SUBSCyprusEurope+XX_SUBSCzechRepublicEurope+XX_SUBSDenmarkEurope+XX_SUBSEstoniaEurope+XX_SUBSFinlandEurope+XX_SUBSGeorgiaEurope+XX_SUBSGibraltarEurope+XX_SUBSGreeceEurope+XX_SUBSHungaryAsia+XX_SUBSItalyEurope+XX_SUBSLithuaniaEurope+XX_SUBSLuxembourgEurope+XX_SUBSMacedoniaEurope+XX_SUBSMaltaEurope+XX_SUBSMontenegroEurope+XX_SUBSNorwayEurope+XX_SUBSPolandEurope+XX_SUBSPortugalEurope+XX_SUBSRomaniaEurope+XX_SUBSRussiaEurope+XX_SUBSSiberiaEurope+XX_SUBSSlovakiaEurope+XX_SUBSSlovakRepublicEurop+XX_SUBSSloveniaEurope+XX_SUBSSerbia+XX_SUBSSwitzerlandEurope+XX_SUBSTurkeyEurope+XX_SUBSUkraineEurope

gen XX_SUBS_AfricaOther=XX_SUBSAlgeriaAfrica+XX_SUBSAngolaAfrica+XX_SUBSBotswanaAfrica+XX_SUBSBurkinaFasoAfrica+XX_SUBSBurundiAfrica+XX_SUBSCameroonAfrica+XX_SUBSCongoAfrica+XX_SUBSEthiopia+XX_SUBSGaboneseRepublicAfrica+XX_SUBSGambia+XX_SUBSGuineaAfrica+XX_SUBSKenyaAfrica+XX_SUBSIvorycoastAfrica+XX_SUBSLiberia+SUBSLibyaAfrica+SUBSMadagascarAfrica+SUBSMalawiAfrica+SUBSMaliAfrica+SUBSMauritaniaAfrica+SUBSMoroccoAfrica+SUBSMozambiqueAfrica+XX_SUBSNigerAfrica+XX_SUBSNigeriaAfrica+XX_SUBSSenegalAfrica+XX_SUBSSierraLeoneAfrica+XX_SUBSTanzaniaAfrica+XX_SUBSUgandaAfrica+XX_SUBSZambiaAfrica+XX_SUBSZimbabweAfrica

gen XX_SUBS_CentralAmericaOther=XX_SUBSANTIGUAANDBARBUDA+XX_SUBSBahamasSouthAmerica+XX_SUBSBarbadosSouthAmeric+XX_SUBSBermudaSouthAmerica+XX_SUBSBelizeSouthAmerica+XX_SUBSBritishAnguillaSout+XX_SUBSCaymanIslandsSouth+XX_SUBSCostaRicaSouthAmer+XX_SUBSDominicanRepublicSo+XX_SUBSElSalvador+XX_SUBSHondurasSouthAmeric+XX_SUBSJamaicaSouthAmerica+XX_SUBSMexicoNorthAmerica+XX_SUBSNetherlandsAntSout+XX_SUBSPanamaSouthAmerica+XX_SUBSPuertoRicoSouthAme+XX_SUBSTrinidadSouthAmeric+XX_SUBSTurksCaicosIslands

gen XX_SUBS_AsiaOther=XX_SUBSBangladeshAsia+XX_SUBSBruneiAsia+XX_SUBSCambodiaAsia+XX_SUBSTimorLesteAsia+XX_SUBSKoreaAsia+XX_SUBSKyrgyzRepublicAsia+XX_SUBSLaosAsia+XX_SUBSMacauAsia+XX_SUBSMongoliaAsia+XX_SUBSPakistanAsia+XX_SUBSSriLankaAsia+XX_SUBSTaiwanAsia+XX_SUBSVietnamAsia

gen XX_SUBS_CentralAsiaOther=XX_SUBSAfghanistanAsia+XX_SUBSBahrainAsia+XX_SUBSEgyptAsia+XX_SUBSIranAsia+XX_SUBSIraq+XX_SUBSIsraelAsia+XX_SUBSJebelAliFreeZoneA+XX_SUBSKazakhstanAsia+XX_SUBSKuwaitAsia+XX_SUBSOmanAsia+XX_SUBSQatarAsia+XX_SUBSSaudiArabiaAsia+XX_SUBSUAEAsia+XX_SUBSUZBEKISTAN

gen XX_SUBS_SouthAmericaOther=XX_SUBSNAntillesSouthAme+XX_SUBSGuatemalaSouthAmeri+XX_SUBSArgentinaSouthAmeri+XX_SUBSBoliviaSouthAmerica+XX_SUBSColombiaSouthAmeric+XX_SUBSEcuadorSouthAmerica+XX_SUBSGuyanaSouthAmerica+XX_SUBSParaguay+XX_SUBSPeruSouthAmerica+XX_SUBSUruguay+XX_SUBSVenezuelaSouthAmeri

gen XX_SUBS_PacificOtherOther=XX_SUBSAmericanSamoaPacifi+XX_SUBSCookIslandsPacific+XX_SUBSFijiPacific+XX_SUBSNewCaledoniaPacific+XX_SUBSSamoaPacific+XX_SUBSSolomonIsPacific+XX_SUBSTongaPacific+XX_SUBSWesternSamoaPacific+XX_SUBSVanuatuPacific

replace XX_SUBSUSANorthAmerica=XX_SUBSUSANorthAmerica+XX_SUBSAlaska


**Drop constituent countries
*drop Alaska
drop XX_SUBSAlaska

*drop UK components
drop XX_SUBSRepublicofIrelandE
drop XX_SUBSChannelIslandsEurope
drop XX_SUBSEnglandEurope
drop XX_SUBSGuernseyEurope
drop XX_SUBSIrelandEurope
drop XX_SUBSIsleofManEurope
drop XX_SUBSJerseyEurope
drop XX_SUBSNorthernIrelandEuro
drop XX_SUBSScotlandEurope
drop XX_SUBSUKEurope

*drop Europe other components
drop XX_SUBSAlbania
drop XX_SUBSAustriaEurope
drop XX_SUBSBelgiumEurope
drop XX_SUBSBosniaHerzegovinaEurope
drop XX_SUBSBulgariaEurope
drop XX_SUBSCroatiaEurope
drop XX_SUBSCyprusEurope
drop XX_SUBSCzechRepublicEurope
drop XX_SUBSDenmarkEurope
drop XX_SUBSEstoniaEurope
drop XX_SUBSFinlandEurope
drop XX_SUBSGeorgiaEurope
drop XX_SUBSGibraltarEurope
drop XX_SUBSGreeceEurope
drop XX_SUBSHungaryAsia
drop XX_SUBSItalyEurope
drop XX_SUBSLithuaniaEurope
drop XX_SUBSLuxembourgEurope
drop XX_SUBSMacedoniaEurope
drop XX_SUBSMaltaEurope
drop XX_SUBSMontenegroEurope
drop XX_SUBSNorwayEurope
drop XX_SUBSPolandEurope
drop XX_SUBSPortugalEurope
drop XX_SUBSRomaniaEurope
drop XX_SUBSRussiaEurope
drop XX_SUBSSiberiaEurope
drop XX_SUBSSlovakiaEurope
drop XX_SUBSSlovakRepublicEurop
drop XX_SUBSSloveniaEurope
drop XX_SUBSSerbia
drop XX_SUBSSwitzerlandEurope
drop XX_SUBSTurkeyEurope
drop XX_SUBSUkraineEurope

* drop Africa Other components
drop XX_SUBSAlgeriaAfrica
drop XX_SUBSAngolaAfrica
drop XX_SUBSBotswanaAfrica
drop XX_SUBSBurkinaFasoAfrica
drop XX_SUBSBurundiAfrica
drop XX_SUBSCameroonAfrica
drop XX_SUBSCongoAfrica
drop XX_SUBSEthiopia
drop XX_SUBSGaboneseRepublicAfrica
drop XX_SUBSGambia
drop XX_SUBSGuineaAfrica
drop XX_SUBSKenyaAfrica
drop XX_SUBSIvorycoastAfrica
drop XX_SUBSLiberia
drop XX_SUBSLibyaAfrica
drop XX_SUBSMadagascarAfrica
drop XX_SUBSMalawiAfrica
drop XX_SUBSMaliAfrica
drop XX_SUBSMauritaniaAfrica
drop XX_SUBSMoroccoAfrica
drop XX_SUBSMozambiqueAfrica
drop XX_SUBSNigerAfrica
drop XX_SUBSNigeriaAfrica
drop XX_SUBSSenegalAfrica
drop XX_SUBSSierraLeoneAfrica
drop XX_SUBSTanzaniaAfrica
drop XX_SUBSUgandaAfrica
drop XX_SUBSZambiaAfrica
drop XX_SUBSZimbabweAfrica

*drop Central America components 
drop XX_SUBSBelizeSouthAmerica
drop XX_SUBSANTIGUAANDBARBUDA
drop XX_SUBSBahamasSouthAmerica
drop XX_SUBSBarbadosSouthAmeric
drop XX_SUBSBermudaSouthAmerica
drop XX_SUBSBritishAnguillaSout
drop XX_SUBSCaymanIslandsSouth
drop XX_SUBSCostaRicaSouthAmer
drop XX_SUBSDominicanRepublicSo
drop XX_SUBSElSalvador
drop XX_SUBSHondurasSouthAmeric
drop XX_SUBSJamaicaSouthAmerica
drop XX_SUBSMexicoNorthAmerica
drop XX_SUBSNetherlandsAntSout
drop XX_SUBSPanamaSouthAmerica
drop XX_SUBSPuertoRicoSouthAme
drop XX_SUBSTrinidadSouthAmeric
drop XX_SUBSTurksCaicosIslands

*drop Asia Other components
drop XX_SUBSBangladeshAsia
drop XX_SUBSBruneiAsia
drop XX_SUBSCambodiaAsia
drop XX_SUBSTimorLesteAsia
drop XX_SUBSKoreaAsia
drop XX_SUBSKyrgyzRepublicAsia
drop XX_SUBSLaosAsia
drop XX_SUBSMacauAsia
drop XX_SUBSMongoliaAsia
drop XX_SUBSPakistanAsia
drop XX_SUBSSriLankaAsia
drop XX_SUBSTaiwanAsia
drop XX_SUBSVietnamAsia

*drop Central Asia Other components
drop XX_SUBSAfghanistanAsia
drop XX_SUBSBahrainAsia
drop XX_SUBSEgyptAsia
drop XX_SUBSIranAsia
drop XX_SUBSIraq
drop XX_SUBSIsraelAsia
drop XX_SUBSJebelAliFreeZoneA
drop XX_SUBSKazakhstanAsia
drop XX_SUBSKuwaitAsia
drop XX_SUBSOmanAsia
drop XX_SUBSQatarAsia
drop XX_SUBSSaudiArabiaAsia
drop XX_SUBSUAEAsia
drop XX_SUBSUZBEKISTAN

*drop South America components
drop XX_SUBSNAntillesSouthAme
drop XX_SUBSArgentinaSouthAmeri
drop XX_SUBSBoliviaSouthAmerica
drop XX_SUBSColombiaSouthAmeric
drop XX_SUBSEcuadorSouthAmerica
drop XX_SUBSGuyanaSouthAmerica
drop XX_SUBSParaguay
drop XX_SUBSPeruSouthAmerica
drop XX_SUBSUruguay
drop XX_SUBSVenezuelaSouthAmeri
drop XX_SUBSGuatemalaSouthAmeri

*drop Pacific Other components
drop XX_SUBSAmericanSamoaPacifi
drop XX_SUBSCookIslandsPacific
drop XX_SUBSFijiPacific
drop XX_SUBSNewCaledoniaPacific
drop XX_SUBSSamoaPacific
drop XX_SUBSSolomonIsPacific
drop XX_SUBSTongaPacific
drop XX_SUBSWesternSamoaPacific
drop XX_SUBSVanuatuPacific

**Create Dummy variables for each region
order XX_SUBSAustralia XX_SUBSBrazilSouthAmerica XX_SUBSJapanAsia XX_SUBSBritishVirginIslands XX_SUBSCanadaNorthAmerica XX_SUBSChileSouthAmerica XX_SUBSChinaAsia XX_SUBSFranceEurope XX_SUBSGermanyEurope XX_SUBSGhanaAfrica XX_SUBSHKAsia XX_SUBSIndiaAsia XX_SUBSIndonesiaAsia XX_SUBSMalaysiaAsia XX_SUBSMauritiusAfrica XX_SUBSNZPacific XX_SUBSNamibiaAfrica XX_SUBSNetherlandsEurope XX_SUBSPNGPacific XX_SUBSPhilippinesAsia XX_SUBSSingaporeAsia XX_SUBSSpainEurope XX_SUBSSthAfricaAfrica XX_SUBSSwedenEurope XX_SUBSThailandAsia XX_SUBSUSANorthAmerica XX_SUBS_UK XX_SUBS_EuropeOther XX_SUBS_AfricaOther XX_SUBS_CentralAmericaOther XX_SUBS_AsiaOther XX_SUBS_CentralAsiaOther XX_SUBS_SouthAmericaOther XX_SUBS_PacificOtherOther, after(SUBSZimbabweAfrica)

foreach var of varlist XX_SUBSAustralia - XX_SUBS_PacificOtherOther {
gen D`var'=1 
replace D`var'=0 if `var'==. | `var'==0
}
drop XX_SUBS*

**rename DXX_SUBS* into D_SUBS (Include i.D_* as subsidiary region FE in regression analysis)
rename DXX_SUBS_UK D_SUBS_UK
rename DXX_SUBS_SouthAmericaOther D_SUBS_SouthAmericaOther
rename DXX_SUBS_PacificOtherOther D_SUBS_PacificOtherOther
rename DXX_SUBS_EuropeOther D_SUBS_EuropeOther
rename DXX_SUBS_CentralAsiaOther D_SUBS_CentralAsiaOther
rename DXX_SUBS_CentralAmericaOther D_SUBS_CentralAmericaOther
rename DXX_SUBS_AsiaOther D_SUBS_AsiaOther
rename DXX_SUBS_AfricaOther D_SUBS_AfricaOther
rename DXX_SUBSUSANorthAmerica D_SUBSUSANorthAmerica
rename DXX_SUBSThailandAsia D_SUBSThailandAsia
rename DXX_SUBSSwedenEurope D_SUBSSwedenEurope
rename DXX_SUBSSthAfricaAfrica D_SUBSSthAfricaAfrica
rename DXX_SUBSSpainEurope D_SUBSSpainEurope
rename DXX_SUBSSingaporeAsia D_SUBSSingaporeAsia
rename DXX_SUBSPhilippinesAsia D_SUBSPhilippinesAsia
rename DXX_SUBSPNGPacific D_SUBSPNGPacific
rename DXX_SUBSNetherlandsEurope D_SUBSNetherlandsEurope
rename DXX_SUBSNamibiaAfrica D_SUBSNamibiaAfrica
rename DXX_SUBSNZPacific D_SUBSNZPacific
rename DXX_SUBSMauritiusAfrica D_SUBSMauritiusAfrica
rename DXX_SUBSMalaysiaAsia D_SUBSMalaysiaAsia
rename DXX_SUBSJapanAsia D_SUBSJapanAsia
rename DXX_SUBSIndonesiaAsia D_SUBSIndonesiaAsia
rename DXX_SUBSIndiaAsia D_SUBSIndiaAsia
rename DXX_SUBSHKAsia D_SUBSHKAsia
rename DXX_SUBSGhanaAfrica D_SUBSGhanaAfrica
rename DXX_SUBSGermanyEurope D_SUBSGermanyEurope
rename DXX_SUBSFranceEurope D_SUBSFranceEurope
rename DXX_SUBSChinaAsia D_SUBSChinaAsia
rename DXX_SUBSChileSouthAmerica D_SUBSChileSouthAmerica
rename DXX_SUBSCanadaNorthAmerica D_SUBSCanadaNorthAmerica
rename DXX_SUBSBritishVirginIslands D_SUBSBritishVirginIslands
rename DXX_SUBSBrazilSouthAmerica D_SUBSBrazilSouthAmerica

foreach var of varlist D_SUBSBrazilSouthAmerica - D_SUBS_PacificOtherOther {
label var `var' "subsidiary region FE"
}

***Caclulate subsidiary-specific variables***
egen TOTSUB=rowtotal(SUBS*)
gen FXSUB=TOTSUB-SUBSAustralia
gen OZSUB=SUBSAustralia

***Merge with dataset from step 9***
rename ASX_CODE asxcode 
rename YEAR year_SPPR

save ".\data\Subsidiaries_Merge.dta", replace

use ".\data\Final_step4.dta"
merge 1:1 groupcoycode year_SPPR using ".\data\Subsidiaries_Merge.dta"
drop if _merge==2

save ".\data\Final_step5.dta", replace

version 14.0
set more off
log cap close

clear
cd "$base"
use ".\data\Final_step5.dta"

*******************update the 8 observations
replace value8020 = -34840000 if id == "bdr22011"
replace value8020 = 9177000 if id == "gaa12009"
replace value8020 = 215930000 if id == "gra12011"
replace value8020 = -29580000 if id == "gxy12010"
replace value8020 = -8777310 if id == "mnc22011"
replace value8020 = 74180000 if id == "pem12010"
replace value8020 = -46533859 if id == "ssi12009"
replace value8020 = -122258000 if id == "smg12007"
replace value9100 = -5624000 if id == "bdr22011"
replace value9100 = 9767000 if id == "gaa12009"
replace value9100 = 210375000 if id == "gra12011"
replace value9100 = -16674002 if id == "gxy12010"
replace value9100 = -6234490 if id == "mnc22011"
replace value9100 = 53154000 if id == "pem12010"
replace value9100 = -3890979 if id == "ssi12009"
replace value9100 = -25018000 if id == "smg12007"
replace l_value5090 = 78470000 if id == "bdr22011"
replace l_value5090 = 139116000 if id == "gaa12009"
replace l_value5090 = 799908000 if id == "gra12011"
replace l_value5090 = 109049871 if id == "gxy12010"
replace l_value5090 = 137966377 if id == "mnc22011"
replace l_value5090 = 294334000 if id == "pem12010"
replace l_value5090 = 97568704 if id == "ssi12009"
replace l_value5090 = 235486000 if id == "smg12007"
replace value7070 = 0 if id == "bdr22011"
replace value7070 = 106854000 if id == "gaa12009"
replace value7070 = 410432000 if id == "gra12011"
replace value7070 = 0 if id == "gxy12010"
replace value7070 = 0 if id == "mnc22011"
replace value7070 = 239507000 if id == "pem12010"
replace value7070 = 0 if id == "ssi12009"
replace value7070 = 2282000 if id == "smg12007"
replace l_value7070 = 1778000 if id == "bdr22011"
replace l_value7070 = 40383000 if id == "gaa12009"
replace l_value7070 = 193334000 if id == "gra12011"
replace l_value7070 = 0 if id == "gxy12010"
replace l_value7070 = 0 if id == "mnc22011"
replace l_value7070 = 155276000 if id == "pem12010"
replace l_value7070 = 0 if id == "ssi12009"
replace l_value7070 = 1393000 if id == "smg12007"
replace value4995 = 542000 if id == "bdr22011"
replace value4995 = 23303000 if id == "gaa12009"
replace value4995 = 47348000 if id == "gra12011"
replace value4995 = 4212348 if id == "gxy12010"
replace value4995 = 2402416 if id == "mnc22011"
replace value4995 = 35790000 if id == "pem12010"
replace value4995 = 315389 if id == "ssi12009"
replace value4995 = 2957000 if id == "smg12007"
replace l_value4995  = 1294000 if id == "bdr22011"
replace l_value4995  = 21600000 if id == "gaa12009"
replace l_value4995 = 35804000 if id == "gra12011"
replace l_value4995 = 1607979 if id == "gxy12010"
replace l_value4995 = 1999828 if id == "mnc22011"
replace l_value4995 = 17923000 if id == "pem12010"
replace l_value4995 = 551990 if id == "ssi12009"
replace l_value4995 = 1001000 if id == "smg12007"
replace value5030 = 86518000 if id == "bdr22011"
replace value5030 = 3301000 if id == "gaa12009"
replace value5030 = 547898000 if id == "gra12011"
replace value5030 = 148234251 if id == "gxy12010"
replace value5030 = 3589445 if id == "mnc22011"
replace value5030 = 199000000 if id == "pem12010"
replace value5030 = 67003245 if id == "ssi12009"
replace value5030 = 603000 if id == "smg12007"
replace value8012 = -36800000 if id == "bdr22011"
replace value8012 = 11211000 if id == "gaa12009"
replace value8012 = 163290000 if id == "gra12011"
replace value8012 = -25470000 if id == "gxy12010"
replace value8012 = -8568210 if id == "mnc22011"
replace value8012 = 23380000 if id == "pem12010"
replace value8012 = 0 if id == "ssi12009"
replace value8012 = -139202000 if id == "smg12007"
replace value5090 = 138074000 if id == "bdr22011"
replace value5090 = 142071000 if id == "gaa12009"
replace value5090 = 956631000 if id == "gra12011"
replace value5090 = 235532283 if id == "gxy12010"
replace value5090 = 240450211 if id == "mnc22011"
replace value5090 = 611105000 if id == "pem12010"
replace value5090 = 71631850 if id == "ssi12009"
replace value5090 = 101554000 if id == "smg12007"


save ".\data\Final_step6.dta", replace

version 14.0
set more off
log cap close

clear
cd "$base"
use ".\data\Final_step6.dta"

*************************************************************************
***Gen Audit Fee variables***
***Audit Fees***
replace AUDFEE = 0 if missing(AUDFEE)
replace ARFEE = 0 if missing(ARFEE)
rename AUDFEE P_AUDFEE
rename ARFEE P_ARFEE

replace RP_AUDFEE = 0 if missing(RP_AUDFEE)
replace OA_AUDFEE = 0 if missing(OA_AUDFEE)

gen TOTAUDFEE =P_AUDFEE+P_ARFEE+RP_AUDFEE+OA_AUDFEE
label variable TOTAUDFEE "The sum of P_AUDFEE, P_ARFEE, RP_AUDFEE and OA_AUDFEE"

***gen	PRINCIPAL***
gen	PRINCIPAL = 0
replace	PRINCIPAL = 1 if (P_AUDFEE + P_ARFEE)/(P_AUDFEE + P_ARFEE + RP_AUDFEE + OA_AUDFEE) == 1

***gen	PRINCIPAL_pcnt***
gen	PRINCIPAL_pcnt= (P_AUDFEE + P_ARFEE)/(P_AUDFEE + P_ARFEE + RP_AUDFEE + OA_AUDFEE)
drop if PRINCIPAL_pcnt==0

***gen COMPONENT***
gen COMPONENT =0 
replace COMPONENT = 1 if RP_AUDFEE>0 | OA_AUDFEE >0

***gen	UNAFFILIATED***
gen	UNAFFILIATED = 0
replace UNAFFILIATED = 1 if OA_AUDFEE > 0

***gen	UNAFFILIATED_pcnt***
gen	UNAFFILIATED_pcnt = OA_AUDFEE/(P_AUDFEE + P_ARFEE + RP_AUDFEE + OA_AUDFEE)
gen UNAFFILIATED_pcnt_25=0
replace UNAFFILIATED_pcnt_25=1 if UNAFFILIATED_pcnt>0.25

***gen	NETWORK****
gen	NETWORK = 0
replace NETWORK = 1 if RP_AUDFEE > 0

***gen	Network_pcnt***
gen	NETWORK_pcnt = RP_AUDFEE/(P_AUDFEE + P_ARFEE + RP_AUDFEE + OA_AUDFEE)
gen NETWORK_pcnt_25=0
replace NETWORK_pcnt_25=1 if NETWORK_pcnt>0.25

***gen COMPONENT_pcnt***
generate COMPONENT_pcnt=UNAFFILIATED_pcnt+NETWORK_pcnt
gen COMPONENT_pcnt_25 = 0
replace COMPONENT_pcnt_25=1 if COMPONENT_pcnt>0.25
*************************************************************************

*************************************************************************
***Gen subsidiary variables: Define different samples***
gen sample_MNE = 0
replace sample_MNE = 1 if FXSUB>0 & FXSUB!=.
replace sample_MNE = . if missing(FXSUB)
gen sample_OZ=0 
replace sample_OZ=1 if SUBSAustralia>0 & FXSUB==0 & FXSUB!=. & SUBSAustralia!=.
replace sample_MNE = . if missing(FXSUB) | missing(SUBSAustralia)
gen sample_nongroup=0
replace sample_nongroup=1 if SUBSAustralia==0 & FXSUB==0 & FXSUB!=. & SUBSAustralia!=.
replace sample_MNE = . if missing(FXSUB) | missing(SUBSAustralia)

***English speaking SUBS***
gen SUBSEnglish=SUBSAustralia+SUBSAmericanSamoaPacifi+SUBSCookIslandsPacific+SUBSFijiPacific+SUBSNZPacific+SUBSSamoaPacific+SUBSTongaPacific+SUBSVanuatuPacific+SUBSBotswanaAfrica+SUBSBurundiAfrica+SUBSCameroonAfrica+SUBSGhanaAfrica+SUBSKenyaAfrica+SUBSMalawiAfrica+SUBSNamibiaAfrica+SUBSNigeriaAfrica+SUBSSierraLeoneAfrica+SUBSSthAfricaAfrica+SUBSTanzaniaAfrica+SUBSZambiaAfrica+SUBSZimbabweAfrica+SUBSBahamasSouthAmerica+SUBSBarbadosSouthAmeric+SUBSBelizeSouthAmerica+SUBSBermudaSouthAmerica+SUBSBritishVirginIslands+SUBSCaymanIslandsSouth+SUBSGuyanaSouthAmerica+SUBSJamaicaSouthAmerica+SUBSPuertoRicoSouthAme+SUBSCanadaNorthAmerica+SUBSGibraltarEurope+SUBSGuernseyEurope+SUBSIrelandEurope+SUBSJerseyEurope+SUBSMaltaEurope+SUBSBangladeshAsia+SUBSBruneiAsia+SUBSIndiaAsia+SUBSIsraelAsia+SUBSMalaysiaAsia+SUBSPakistanAsia+SUBSPhilippinesAsia+SUBSSingaporeAsia+SUBSANTIGUAANDBARBUDA+SUBSEthiopia+SUBSGambia+SUBSLiberia+SUBSPNGPacific+SUBSSolomonIsPacific+SUBSWesternSamoaPacific+SUBSMauritiusAfrica+SUBSBritishAnguillaSout+SUBSTrinidadSouthAmeric+SUBSTurksCaicosIslands+SUBSUSANorthAmerica+SUBSCyprusEurope+SUBSEnglandEurope+SUBSIsleofManEurope+SUBSNorthernIrelandEuro+SUBSRepublicofIrelandE+SUBSScotlandEurope+SUBSUKEurope+SUBSHKAsia+SUBSUgandaAfrica+SUBSSriLankaAsia+SUBSAlaska
gen SUBSNonEnglish=SUBSLithuaniaEurope+SUBSChannelIslandsEurope+SUBSNAntillesSouthAme+SUBSNewCaledoniaPacific+SUBSAngolaAfrica+SUBSAlgeriaAfrica+SUBSBurkinaFasoAfrica+SUBSCongoAfrica+SUBSGuineaAfrica+SUBSLibyaAfrica+SUBSMadagascarAfrica+SUBSMaliAfrica+SUBSMauritaniaAfrica+SUBSMoroccoAfrica+SUBSMozambiqueAfrica+SUBSNigerAfrica+SUBSSenegalAfrica+SUBSArgentinaSouthAmeri+SUBSBoliviaSouthAmerica+SUBSBrazilSouthAmerica+SUBSChileSouthAmerica+SUBSColombiaSouthAmeric+SUBSCostaRicaSouthAmer+SUBSDominicanRepublicSo+SUBSEcuadorSouthAmerica+SUBSGuatemalaSouthAmeri+SUBSHondurasSouthAmeric+SUBSNetherlandsAntSout+SUBSPanamaSouthAmerica+SUBSPeruSouthAmerica+SUBSVenezuelaSouthAmeri+SUBSMexicoNorthAmerica+SUBSAustriaEurope+SUBSBelgiumEurope+SUBSBulgariaEurope+SUBSCroatiaEurope+SUBSCzechRepublicEurope+SUBSDenmarkEurope+SUBSEstoniaEurope+SUBSFinlandEurope+SUBSFranceEurope+SUBSGermanyEurope+SUBSGeorgiaEurope+SUBSGreeceEurope+SUBSLuxembourgEurope+SUBSItalyEurope+SUBSNetherlandsEurope+SUBSNorwayEurope+SUBSPolandEurope+SUBSPortugalEurope+SUBSRomaniaEurope+SUBSRussiaEurope+SUBSSiberiaEurope+SUBSSlovakiaEurope+SUBSSlovakRepublicEurop+SUBSSloveniaEurope+SUBSSpainEurope+SUBSSwedenEurope+SUBSSwitzerlandEurope+SUBSTurkeyEurope+SUBSUkraineEurope+SUBSBahrainAsia+SUBSCambodiaAsia+SUBSChinaAsia+SUBSEgyptAsia+SUBSHungaryAsia+SUBSIndonesiaAsia+SUBSIranAsia+SUBSJapanAsia+SUBSJebelAliFreeZoneA+SUBSKazakhstanAsia+SUBSKoreaAsia+SUBSKyrgyzRepublicAsia+SUBSKuwaitAsia+SUBSLaosAsia+SUBSMacauAsia+SUBSMongoliaAsia+SUBSMontenegroEurope+SUBSOmanAsia+SUBSQatarAsia+SUBSSaudiArabiaAsia+SUBSTaiwanAsia+SUBSThailandAsia+SUBSTimorLesteAsia+SUBSUAEAsia+SUBSVietnamAsia+SUBSAlbania+SUBSIvorycoastAfrica+SUBSElSalvador+SUBSIraq+SUBSParaguay+SUBSSerbia+SUBSUruguay+SUBSUZBEKISTAN+SUBSMacedoniaEurope+SUBSBosniaHerzegovinaEurope+SUBSGaboneseRepublicAfrica+SUBSAfghanistanAsia
gen PctSUBSEnglish=SUBSEnglish/TOTSUB
gen PctSUBSNonEnglish=SUBSNonEnglish/TOTSUB

gen LowPctSUBSEnglish=0
*Split at 25th Percentile of sample
replace LowPctSUBSEnglish=1 if PctSUBSEnglish<0.8

***% of foreign SUBS***
gen FOREIGN = 1-SUBSAustralia/TOTSUB
label variable FOREIGN "% of foreign subsidiaries"
count if missing(FOREIGN)

gen min25pct_FOREIGN = 0
replace min25pct_FOREIGN = 1 if FOREIGN >=0.25
label variable min25pct_FOREIGN "1 if % of foreign subsidiaries >=25%; 0 otherwise"
count if missing(min25pct_FOREIGN)

***gen LSUB***
gen	LSUB = ln(TOTSUB) if TOTSUB !=0
*************************************************************************

***Gen industry indicators***
***industry fixed effect (70 is not in sample_MNE)
table SIRCAsectorcode, row
gen GICS_sector10 = 0
replace GICS_sector10 = 1 if SIRCAsectorcode==10
gen GICS_sector15 = 0
replace GICS_sector15 = 1 if SIRCAsectorcode==15
gen GICS_sector20 = 0
replace GICS_sector20 = 1 if SIRCAsectorcode==20
gen GICS_sector25 = 0
replace GICS_sector25 = 1 if SIRCAsectorcode==25
gen GICS_sector30 = 0
replace GICS_sector30 = 1 if SIRCAsectorcode==30
gen GICS_sector35 = 0
replace GICS_sector35 = 1 if SIRCAsectorcode==35
gen GICS_sector45 = 0
replace GICS_sector45 = 1 if SIRCAsectorcode==45
gen GICS_sector50 = 0
replace GICS_sector50 = 1 if SIRCAsectorcode==50
gen GICS_sector55 = 0
replace GICS_sector55 = 1 if SIRCAsectorcode==55


***gen INDGROWTH***
gen INDGROWTH=.
forvalues i = 2006/2013 {
forvalues j = 1/10 {
egen TA_all_ind = total(value5090) if indsecgroup == `j' & YEAR == `i'
egen l_TA_all_ind= total(l_value5090) if indsecgroup == `j' & YEAR == `i'
replace INDGROWTH= TA_all_ind/l_TA_all_ind if indsecgroup == `j' & YEAR == `i'
drop TA_all_ind
drop l_TA_all_ind
}
}
*************************************************************************

***Import CPI and gen CPI-adjusted audit fees***
gen y2006 = 0
replace y2006 =1 if YEAR == 2006
gen y2007 = 0
replace y2007 =1 if YEAR == 2007
gen y2008 = 0
replace y2008 =1 if YEAR == 2008
gen y2009 = 0
replace y2009 =1 if YEAR == 2009
gen y2010 = 0
replace y2010 =1 if YEAR == 2010
gen y2011 = 0
replace y2011 =1 if YEAR == 2011
gen y2012 = 0
replace y2012 =1 if YEAR == 2012
gen y2013 = 0
replace y2013 =1 if YEAR == 2013

gen Quarter = 0
replace Quarter =  1 if inrange(month_ye, 1,3) 
replace Quarter =  2 if inrange(month_ye, 4,6)
replace Quarter =  3 if inrange(month_ye, 7,9)
replace Quarter =  4 if inrange(month_ye, 10,12)

gen CPI = .
replace CPI = 84.5 if YEAR == 2006 & Quarter == 1 
replace CPI = 85.9 if YEAR == 2006 & Quarter == 2
replace CPI = 86.7 if YEAR == 2006 & Quarter == 3
replace CPI = 86.6 if YEAR == 2006 & Quarter == 4
replace CPI = 86.6 if YEAR == 2007 & Quarter == 1
replace CPI = 87.7 if YEAR == 2007 & Quarter == 2
replace CPI = 88.3 if YEAR == 2007 & Quarter == 3
replace CPI = 89.1 if YEAR == 2007 & Quarter == 4
replace CPI = 90.3 if YEAR == 2008 & Quarter == 1
replace CPI = 91.6 if YEAR == 2008 & Quarter == 2
replace CPI = 92.7 if YEAR == 2008 & Quarter == 3
replace CPI = 92.4 if YEAR == 2008 & Quarter == 4
replace CPI = 92.5 if YEAR == 2009 & Quarter == 1
replace CPI = 92.9 if YEAR == 2009 & Quarter == 2
replace CPI = 93.8 if YEAR == 2009 & Quarter == 3
replace CPI = 94.3 if YEAR == 2009 & Quarter == 4
replace CPI = 95.2 if YEAR == 2010 & Quarter == 1
replace CPI = 95.8 if YEAR == 2010 & Quarter == 2
replace CPI = 96.5 if YEAR == 2010 & Quarter == 3
replace CPI = 96.9 if YEAR == 2010 & Quarter == 4
replace CPI = 98.3 if YEAR == 2011 & Quarter == 1
replace CPI = 99.2 if YEAR == 2011 & Quarter == 2
replace CPI = 99.8 if YEAR == 2011 & Quarter == 3
replace CPI = 99.8 if YEAR == 2011 & Quarter == 4
replace CPI = 99.9 if YEAR == 2012 & Quarter == 1
replace CPI = 100.4 if YEAR == 2012 & Quarter == 2
replace CPI = 101.8 if YEAR == 2012 & Quarter == 3
replace CPI = 102.0 if YEAR == 2012 & Quarter == 4
replace CPI = 102.4 if YEAR == 2013 & Quarter == 1
replace CPI = 102.8 if YEAR == 2013 & Quarter == 2
replace CPI = 104.0 if YEAR == 2013 & Quarter == 3
replace CPI = 104.8 if YEAR == 2013 & Quarter == 4

***gen LAF**********
count if missing(P_AUDFEE)
count if missing(P_ARFEE)
count if missing(RP_AUDFEE)
count if missing(OA_AUDFEE)
replace P_AUDFEE = 0 if missing(P_AUDFEE)
replace P_ARFEE = 0 if missing(P_ARFEE)
replace RP_AUDFEE = 0 if missing(RP_AUDFEE)
replace OA_AUDFEE = 0 if missing(OA_AUDFEE)

count if (P_AUDFEE + P_ARFEE + RP_AUDFEE + OA_AUDFEE) < 1000
count if (P_AUDFEE + P_ARFEE + RP_AUDFEE + OA_AUDFEE) == 1000
count if (P_AUDFEE + P_ARFEE + RP_AUDFEE + OA_AUDFEE)>1000
gen LAF_CPI_adjusted = .
replace LAF_CPI_adjusted = 0.001 if (P_AUDFEE + P_ARFEE + RP_AUDFEE + OA_AUDFEE)<=1000
replace LAF_CPI_adjusted = ln(((P_AUDFEE + P_ARFEE  + RP_AUDFEE + OA_AUDFEE)/1000)*84.5/CPI) if (P_AUDFEE + P_ARFEE  + RP_AUDFEE + OA_AUDFEE)>1000
**************************************************************************

***Gen Audit specific variables***
***gen	OPINION***
table OPINION, row
count if missing(OPINION)
gen MOPINION = .
replace MOPINION = 0 if !missing(OPINION)
replace MOPINION = 1 if OPINION != "0" & !missing(OPINION)
label variable MOPINION "Modified Opinion current year"

***ADTCHANGE*********
table AUDITOR YEAR
table l_AUDITOR YEAR

replace AUDITOR = "Alcock Davis Danieli" if AUDITOR == "AD Danieli Audit" 
replace AUDITOR = "Alcock Davis Danieli" if AUDITOR == "Alcock Davis Danieli Audit Pty Ltd" 
replace AUDITOR = "Crowe Horwath" if AUDITOR == "CROWE HORWATH" 
replace AUDITOR = "I D Riley" if AUDITOR == "Ian D Riley"
replace AUDITOR = "Leydin Freyer" if AUDITOR == "LeydinFreyer"
replace AUDITOR = "McIntosh Bishop" if AUDITOR == "Mclntosh Bishop"
replace AUDITOR = "R T Kidd" if AUDITOR == "RT Kidd"
replace AUDITOR = "Somes and Cooke" if AUDITOR == "Somes Cooke"
replace AUDITOR = "Stannards" if AUDITOR == "Stannards Accountants and Advisors"
replace AUDITOR = "Stantons" if AUDITOR == "Stantons International"
replace AUDITOR = "Stirling" if AUDITOR == "Stirling International"
replace AUDITOR = "Walker Wayland" if AUDITOR == "Walker Wayland Audit(WA) Pty Ltd"

replace l_AUDITOR = "Duncan Dovico" if l_AUDITOR == "Duncan Dovico Chartered Accountants"
replace l_AUDITOR = "I D Riley" if l_AUDITOR == "Ian D Riley"
replace l_AUDITOR = "Leydin Freyer" if l_AUDITOR == "LeydinFreyer Chartered Accountants"
replace l_AUDITOR = "R T Kidd" if l_AUDITOR == "RT Kidd"
replace l_AUDITOR = "ORD" if l_AUDITOR == "ORD Partners"
replace l_AUDITOR = "Stantons" if l_AUDITOR == "Stantons International"
replace l_AUDITOR = "Stirling" if l_AUDITOR == "Stirling International"

gen ADTCHANGE = .
replace ADTCHANGE = 0 if !missing(AUDITOR) & !missing(l_AUDITOR)
replace ADTCHANGE = 1 if AUDITOR != l_AUDITOR & !missing(AUDITOR) & !missing(l_AUDITOR)

***Partner variables
egen PARTNERFE=group(PARTNER)
gen PTCHANGE=0
replace PTCHANGE=1 if PARTNER!=l_PARTNER
replace PTCHANGE=. if PARTNERFE==.

gen PTonlyCHANGE=0
replace PTonlyCHANGE=1 if PTCHANGE==1 & ADTCHANGE==0
replace PTCHANGE=. if PARTNERFE==.

***gen BIG4: variable BIG4***

***gen	LARGENONBIGN***
gen LARGENONBIGN = .
replace LARGENONBIGN =0 if !missing(AUDITOR)
replace LARGENONBIGN = 1 if (AUDITOR == "BDO" | AUDITOR == "Grant Thornton" | AUDITOR == "William Buck" | AUDITOR == "WHK" | AUDITOR == "Russell Bedford" | AUDITOR == "RSM Bird Cameron" | AUDITOR == "Horwath" | AUDITOR == "Pitcher Partners" | AUDITOR == "PKF" | AUDITOR == "Moore Stephens" | AUDITOR == "Hall Chadwick" | AUDITOR == "HLB Mann Judd" | AUDITOR == "DFK Collins" | AUDITOR == "Crowe Horwath" | AUDITOR == "Bentleys" ) & !missing(AUDITOR)

***SMALLNONBIGN***
gen SMALLNONBIGN = 0
replace SMALLNONBIGN = 1 if !inlist(AUDITOR, "Deloitte Touche", "Ernst and Young", "KPMG","PricewaterhouseCoopers", "BDO", "Grant Thornton") 

***Code Busyseas
gen month=month(YEAREND)
gen day=day(YEAREND)
gen Busyseas=.
replace Busyseas=0 if YEAREND!=.
replace Busyseas=1 if month==6 & day==30

***Code industry specialization: based on client assets (since audit fees are a dependent variable)
* gen total assets for each auditor within each sic and year. Base this on sample_OZ sample_nongroup sample_MNE
bys AUDITOR SIRCAsectorcode year_ye: egen double tot_aud_assets= total(value5090)
label variable tot_aud_assets "total assets per auditor in each industry-year"
format tot_aud_assets %20.0g

bys SIRCAsectorcode year_ye: egen double tot_assets= total(value5090)
label variable tot_assets "total assets in each industry-year"

gen mkt_sh_assets=tot_aud_assets/tot_assets
label variable mkt_sh_assets "market share for each auditor, based on assets for each industry-year"

*Check market share=0 or =1
sum mkt_sh_assets, de
list groupcoycode SIRCAsectorcode AUDITOR P_AUDFEE year_ye value5090 tot_assets tot_aud_assets mkt_sh_assets if mkt_sh_assets==0
***--> these are cases where either audit fees or value5090(client assets) are missing
list groupcoycode SIRCAsectorcode AUDITOR P_AUDFEE year_ye  YEAREND value5090 if mkt_sh_assets==1
***--> cases where year_ye (Year end) is missing
sum mkt_sh_assets if sample_OZ==1|sample_nongroup==1|sample_MNE==1, de

bys SIRCAsectorcode year_ye: egen double MaxMktShare = max(mkt_sh_assets)
gen IndLeader=0
replace IndLeader=1 if MaxMktShare==mkt_sh_assets

***Code MNE specialization
* define MNEs as those companies with at least one foreign sub: FXSUB>0. foreign assets under audit unknown, hence define MNE specialization as FXSUB/TOTSUB
gen FXPerc=FXSUB/TOTSUB
label variable FXPerc "FXSub to TotSub percentage"

bys AUDITOR year_ye: egen double tot_aud_FXPerc= total(FXPerc)
label variable tot_aud_FXPerc "total FXPerc per auditor in each industry-year"

bys year_ye: egen double tot_FXPerc= total(FXPerc)
label variable tot_FXPerc "total FXPerc in each industry-year"

gen FXPerc_share=tot_aud_FXPerc/tot_FXPerc
label variable FXPerc_share "market share for each auditor, based on FXPerc for each year"

sum FXPerc_share if sample_OZ==1|sample_nongroup==1|sample_MNE==1, de
sum FXPerc_share if sample_MNE==1, de

gen MNESpec=cond(FXPerc_share>.1451566,1,0)
label variable MNESpec "=1 if market share>75th percentile (0.14 percent) in each year"

***Define ISA600
gen ISA600=0
gen eventdate = mdy(12, 15, 2009) 
format eventdate %td
replace ISA600=1 if YEAREND>=eventdate
replace ISA600=. if YEAREND==.
drop eventdate

**************************************************************************
***Gen Firm specific variables***
***gen AGE***
gen tem =  year(minlistdate)
replace tem =  1987 if tem<1987
gen AGE = YEAR -tem
drop tem
gen lnAGE=ln(AGE)
*****************

**gen ANNUAL**
gen ANNUAL=Annual
************************

***gen CATA***
gen	CATA = value5020/value5090
*************************

***gen	CHGLEV***
gen	CHGLEV = (value6040/value5090)-(l_value6040/l_value5090)
*************************

***gen CURRENT***
gen CURRENT = value5020/value6010
*******************

***gen GROWTH***
gen GROWTH = value5090/l_value5090
*******************

***gen LAGTOTACC
gen	LAG_TOTACC = (l_value8020 - l_value9100)/l2_value5090
******************

***gen	LEVERAGE***
gen	LEVERAGE = value6040/value5090
*********************

***gen	LOSS***
gen LOSS = .
replace LOSS = 0 if !missing(value8020)
replace LOSS = 1 if value8020<0 & !missing(value8020)

***gen	PERFORM***
gen	PERFORM = value9100/value5090

***gen PPEGROWTH***
gen PPE_current_gross = value5030 - value8010
gen PPE_last_gross= l_value5030 - l_value8010
gen PPEGROWTH = (PPE_current_gross-PPE_last_gross)/PPE_last_gross
replace PPEGROWTH = 1 if PPE_last_gross==0

***gen LTA*********
count if value5090<=1000000
count if value5090==1000000
gen LTA = .
replace LTA = 0.001 if value5090<=1000000 & !missing(value5090)
replace LTA = ln(value5090/1000000) if value5090>1000000 & !missing(value5090)
******************************************************************************

***gen	MB***
gen MVE = totalcapital/100
label variable MVE "Market Value of Equity"

gen BVE = value7010
label variable BVE "Book Value of Equity current year"

gen	MB = MVE/BVE
label variable MB "MVE/BVE"
************************

***gen MINING***
gen MINING = 0
replace MINING = 1 if SIRCAsectorcode == 15
*********************

***gen	NEGEQ*******
gen NEGEQ = .
replace NEGEQ = 0 if !missing(value7010)
replace NEGEQ = 1 if value7010<0 & !missing(value7010)
*******************

***gen OCF_vol***
gen tem = (value9100+l_value9100+l2_value9100)/3
gen OCF_vol = ((((value9100-tem)^2 + (l_value9100-tem)^2 + (l2_value9100-tem)^2)/2)^(1/2))/((value5090 + l_value5090 + l2_value5090)/3)
drop tem
******************

***gen	QUICK***
gen	QUICK = (value5020-value5000)/value6010
*****************

***gen ROI***
gen ROI = value8012/value5090
************************

***gen SALE_vol***
gen tem = (value7070 + l_value7070 + l2_value7070)/3
gen SALE_vol = ((((value7070-tem)^2 + (l_value7070-tem)^2 + (l2_value7070-tem)^2)/2)^(1/2))/((value5090 + l_value5090 + l2_value5090)/3)
drop tem
************************

***gen SALESGROWTH***
gen SALESGROWTH = (value7070 - l_value7070)/l_value7070
replace SALESGROWTH = 0 if l_value7070 == 0
count if !missing(SALESGROWTH)
************************

***gen	WC***
gen	WC = (value5020-value6010)/value5090
*****************

***gen	YE***
gen YE = 0 
replace YE = 1 if month(YEAREND) !=6
*****************

***gen	LaggedTotAcc***
gen l_TotAcc=(l_value8020 - l_value9100)/l2_value5090

***Encode ID***
 encode groupcoycode, gen(IDenc)

***winsorize controls***
winsor2 INDGROWTH CATA QUICK PERFORM LTA LEVERAGE PPEGROWTH SALESGROWTH SALE_vol OCF_vol l_TotAcc MB Annual GROWTH , suffix(w)

***create industry-year indicators***
egen iy=group(indsecgroup YEAR)


*** Discr Accruals (Jones)***
*** Inputs for Disc Accrual estimation 
/*calculate indep vars*/
gen InvAssets=1/l_value5090
gen drevt=value7070-l_value7070
gen drect=value4995-l_value4995
gen RevAR=(drevt-drect)/l_value5090
gen PPEN=value5030/l_value5090
gen l_ROA=l_value8012/l_value5090
gen TotAcc=(value8020 - value9100)/l_value5090
gen absTotAcc=abs(TotAcc)

/*foreach v of var TotAcc InvAssets RevAR PPEG PPEN l_ROA { 
	drop if missing(`v') 
}*/

winsor2 InvAssets RevAR PPEN l_ROA TotAcc, suffix(w)
sum InvAssets* RevAR* PPEN* l_ROA* TotAcc*
gen absTotAccw=abs(TotAccw)

*Check number of observations for each sector year (drop if <=10)
sort indsecgroup YEAR
by indsecgroup YEAR : gen N_secyear=_N
label var N_secyear "number of observations for each industry year"

gen Obs10_SecY= 0
replace Obs10_SecY=1 if N_secyear>10
label var Obs10_SecY "indicator if obs sector year>10"

drop if Obs10_SecY==0

/*Modified Jones by industry and year for full sample winsorized inputs*/
sort groupcoycode YEAR
gen y_hat=. // empty variable for predictions
gen y_res=. // empty variable for residuals --> used as abnormal accruals
tempvar y_hat y_res // temporary variables for each set of predictions
levelsof indsecgroup, local(levels) //define the industry variable 
foreach x of local levels { //define industries
foreach y of numlist 2006/2013 { //define years
capture reg TotAccw InvAssetsw RevARw PPENw l_ROAw  if indsecgroup==`x' & YEAR==`y' //define x, y and z and reg modified Jones
if !_rc {
predict `y_hat' // predictions are now in temporary variable
replace y_hat=`y_hat' if e(sample) // transfer predictions from temp variable
predict `y_res', residuals // residuals are now in temporary variable
replace y_res=`y_res' if e(sample) // transfer residuals from temp variable; thus y_res is abnormal accrual
drop `y_hat' `y_res' // drop temporary variables in preparation for next regression
}
}
}
rename y_res DAPw_IY
label var DAPw_IY "discretionary accruals by industry and year - modified Jones"
winsor2 DAPw_IY, suffix(w)
label var DAPw_IYw "winsorized discretionary accruals by industry and year - modified Jones"
gen absDAPw_IY=abs(DAPw_IY)
label var absDAPw_IY "absolute discretionary accruals by industry and year - modified Jones"
gen absDAPw_IYw=abs(DAPw_IYw)
label var absDAPw_IYw "absolute winsorized discretionary accruals by industry and year - modified Jones"

drop y_hat 


*** Stubben: Discr Revenues - industry year FE ***
gen ScChRec=(value5028-l_value5028)/l_value5090
gen ScChRev=(value7070-l_value7070)/l_value5090

winsor2 ScChRev ScChRec, suffix(w)
sum ScChRev* ScChRec*

sort groupcoycode YEAR
	gen y_hat1=. // empty variable for predictions
	gen y_res1=. // empty variable for residuals --> used as abnormal accruals
	tempvar y_hat1 y_res1 // temporary variables for each set of predictions
	levelsof indsecgroup, local(levels) //define the industry variable 
	foreach x of local levels { //define industries
	foreach y of numlist 2006/2013 { //define years
	capture reg ScChRecw ScChRevw if indsecgroup==`x' & YEAR==`y' //define x, y and z and reg modified Jones
	if !_rc {
	predict `y_hat1' // predictions are now in temporary variable
	replace y_hat1=`y_hat1' if e(sample) // transfer predictions from temp variable
	predict `y_res1', residuals // residuals are now in temporary variable
	replace y_res1=`y_res1' if e(sample) // transfer residuals from temp variable; thus y_res is abnormal accrual
	drop `y_hat1' `y_res1' // drop temporary variables in preparation for next regression
	}
	}
	}

	rename y_res1 DRw_IY
	label var DRw_IY "discretionary revenues by industry and year with country FE"
	winsor2 DRw_IY, suffix(w)
	label var DRw_IYw "winsorized discretionary revenues by industry and year with country FE"
	gen absDRw_IY=abs(DRw_IY) 
	label var absDRw_IY "absolute discretionary revenues by industry and year with country FE"
	gen absDRw_IYw=abs(DRw_IYw)
	label var absDRw_IYw "absolute winsorized discretionary revenues by industry and year with country FE"

gen absScChRec=abs(ScChRec)
gen absScChRecw=abs(ScChRecw)

save ".\data\Final_step7.dta", replace


version 14.2
set more off
log cap close

clear
cd "$base"
***Merge Acc Payable***
use ".\data\AccountsPayable.dta" 
encode groupcoycode, gen(IDenc)
xtset IDenc year_SPPR
gen l_value349=l.value349
gen l_value301=l.value301
gen l2_value301=l2.value301
save ".\data\AccountsPayable_clean.dta", replace

use ".\data\Final_step7.dta", clear
drop _merge
merge 1:1 groupcoycode year_SPPR using ".\data\AccountsPayable_clean.dta", force
drop if _merge==2
drop _merge
*Impute 0s for value2600 (not reported for all firms)
replace value2600=0 if value2600==.
replace l_value2600=0 if l_value2600==.
gen RecTurnover=l_value7090/l_value4995
gen PayTurnover=-l_value2600/l_value301
winsor2 PayTurnover RecTurnover , suffix(w)

gen RecPaySample=.
replace RecPaySample=1 if RecTurnover!=. & PayTurnover!=.   
save ".\data\Final_step8.dta", replace

version 14.2
set more off
log cap close

clear
cd "$base"
***Subsidiary IFRS data***
import excel ".\data\YearIFRSAdoption_SUBS.xlsx", sheet("Year of IFRS adoption by SUBS") firstrow clear

save ".\data\YearIFRSAdoption_SUBS.dta"

use ".\data\Subsidiaries_Merge.dta"
append using ".\data\YearIFRSAdoption_SUBS.dta"

ssc install fillmissing, replace
foreach var of varlist IFRSSUBSANTIGUAANDBARBUDA-IFRSSUBSZimbabweAfrica {
fillmissing `var'
}
drop if year_SPPR==. & asxcode==""

foreach var of varlist IFRSSUBSANTIGUAANDBARBUDA-IFRSSUBSZimbabweAfrica {
destring `var', replace
}

foreach var of varlist SUBSANTIGUAANDBARBUDA-SUBSZimbabweAfrica {
gen IFRSY`var'=`var' if 2006>=IFRS`var'
replace IFRSY`var'=0 if 2006<IFRS`var'
}

*Calculate IFRS variables 
egen IFRSSUB=rowtotal(IFRSY*)
gen FXIFRSSUBS=IFRSSUB-IFRSYSUBSAustralia
gen PercIFRS=IFRSSUB/TOTSUB
gen PercFXIFRS=FXIFRSSUBS/FXSUB

*sum PercFXIFRS if sample_MNE==1 & RecPaySample==1, de
gen LowPercFXIFRS=0
*Split at median within sample, or at upper quartile
replace LowPercFXIFRS=1 if PercFXIFRS<0.2222222
gen HighPercFXIFRS=0
replace HighPercFXIFRS=1 if PercFXIFRS>=0.5348837

drop IFRSSUBS* IFRSY*
rename IFRSSUB IFRSSUBS
save ".\data\SUBS_IFRS.dta", replace

***Subsidiary Distance data***
*Data avaialble from http://www.cepii.fr/PDF_PUB/wp/2011/wp2011-25.pdf
*download dist_cepii.dta, use variable "dist"
use ".\data\dist_cepii.dta", clear
drop if iso_o!="AUS"
drop contig comlang_off comlang_ethno colony comcol curcol col45 smctry distcap distwces distw
reshape wide dist, i(iso_o) j(iso_d) string

*rename distISOCODE consistent with subsidiary data
rename distATG distSUBSANTIGUAANDBARBUDA
rename distAFG distSUBSAfghanistanAsia
rename distUSA distSUBSAlaska
rename distALB distSUBSAlbania
rename distDZA distSUBSAlgeriaAfrica
rename distWSM distSUBSAmericanSamoaPacifi
rename distAGO distSUBSAngolaAfrica
rename distARG distSUBSArgentinaSouthAmeri
rename distAUS distSUBSAustralia
rename distAUT distSUBSAustriaEurope
rename distBHS distSUBSBahamasSouthAmerica
rename distBHR distSUBSBahrainAsia
rename distBGD distSUBSBangladeshAsia
rename distBRB distSUBSBarbadosSouthAmeric
rename distBEL distSUBSBelgiumEurope
rename distBLZ distSUBSBelizeSouthAmerica
rename distBMU distSUBSBermudaSouthAmerica
rename distBOL distSUBSBoliviaSouthAmerica
rename distBIH distSUBSBosniaHerzegovinaEurope
rename distBWA distSUBSBotswanaAfrica
rename distBRA distSUBSBrazilSouthAmerica
rename distAIA distSUBSBritishAnguillaSout
rename distVGB distSUBSBritishVirginIslands
rename distBRN distSUBSBruneiAsia
rename distBGR distSUBSBulgariaEurope
rename distBFA distSUBSBurkinaFasoAfrica
rename distBDI distSUBSBurundiAfrica
rename distKHM distSUBSCambodiaAsia
rename distCMR distSUBSCameroonAfrica
rename distCAN distSUBSCanadaNorthAmerica
rename distCYM distSUBSCaymanIslandsSouth
rename distGBR distSUBSChannelIslandsEurope 
rename distCHL distSUBSChileSouthAmerica
rename distCHN distSUBSChinaAsia
rename distCOL distSUBSColombiaSouthAmeric
rename distCOG distSUBSCongoAfrica
rename distCOK distSUBSCookIslandsPacific
rename distCRI distSUBSCostaRicaSouthAmer
rename distHRV distSUBSCroatiaEurope
rename distCYP distSUBSCyprusEurope
rename distCZE distSUBSCzechRepublicEurope
rename distDNK distSUBSDenmarkEurope
rename distDOM distSUBSDominicanRepublicSo
rename distECU distSUBSEcuadorSouthAmerica
rename distEGY distSUBSEgyptAsia
rename distSLV distSUBSElSalvador
gen distSUBSEnglandEurope=distSUBSChannelIslandsEurope //ISO code Channel Island under GBR
rename distEST distSUBSEstoniaEurope
rename distETH distSUBSEthiopia
rename distFJI distSUBSFijiPacific
rename distFIN distSUBSFinlandEurope
rename distFRA distSUBSFranceEurope
rename distGAB distSUBSGaboneseRepublicAfrica
rename distGMB distSUBSGambia
rename distGEO distSUBSGeorgiaEurope
rename distDEU distSUBSGermanyEurope
rename distGHA distSUBSGhanaAfrica
rename distGIB distSUBSGibraltarEurope
rename distGRC distSUBSGreeceEurope
rename distGTM distSUBSGuatemalaSouthAmeri
gen distSUBSGuernseyEurope=distSUBSChannelIslandsEurope //ISO code Channel Island under GBR
rename distGIN distSUBSGuineaAfrica
rename distGUY distSUBSGuyanaSouthAmerica
rename distHKG distSUBSHKAsia
rename distHND distSUBSHondurasSouthAmeric
rename distHUN distSUBSHungaryAsia
rename distIND distSUBSIndiaAsia
rename distIDN distSUBSIndonesiaAsia
rename distIRN distSUBSIranAsia
rename distIRQ distSUBSIraq
rename distIRL distSUBSIrelandEurope
gen distSUBSIsleofManEurope=distSUBSChannelIslandsEurope //ISO code Jersey under GBR
rename distISR distSUBSIsraelAsia
rename distITA distSUBSItalyEurope
rename distCIV distSUBSIvorycoastAfrica
rename distJAM distSUBSJamaicaSouthAmerica
rename distJPN distSUBSJapanAsia
rename distARE distSUBSJebelAliFreeZoneA
gen distSUBSJerseyEurope=distSUBSChannelIslandsEurope //ISO code Jersey under GBR
rename distKAZ distSUBSKazakhstanAsia
rename distKEN distSUBSKenyaAfrica
rename distKOR distSUBSKoreaAsia
rename distKWT distSUBSKuwaitAsia
rename distKGZ distSUBSKyrgyzRepublicAsia
rename distLAO distSUBSLaosAsia
rename distLBR distSUBSLiberia
rename distLBY distSUBSLibyaAfrica
rename distLTU distSUBSLithuaniaEurope
rename distLUX distSUBSLuxembourgEurope
rename distMAC distSUBSMacauAsia
rename distMKD distSUBSMacedoniaEurope
rename distMDG distSUBSMadagascarAfrica
rename distMWI distSUBSMalawiAfrica
rename distMYS distSUBSMalaysiaAsia
rename distMLI distSUBSMaliAfrica
rename distMLT distSUBSMaltaEurope
rename distMRT distSUBSMauritaniaAfrica
rename distMUS distSUBSMauritiusAfrica
rename distMEX distSUBSMexicoNorthAmerica
rename distMNG distSUBSMongoliaAsia
rename distYUG distSUBSMontenegroEurope
rename distMAR distSUBSMoroccoAfrica
rename distMOZ distSUBSMozambiqueAfrica
rename distANT distSUBSNAntillesSouthAme
rename distNZL distSUBSNZPacific
rename distNAM distSUBSNamibiaAfrica
gen distSUBSNetherlandsAntSout=distSUBSNAntillesSouthAme
rename distNLD distSUBSNetherlandsEurope
rename distNCL distSUBSNewCaledoniaPacific
rename distNER distSUBSNigerAfrica
rename distNGA distSUBSNigeriaAfrica
gen distSUBSNorthernIrelandEuro=distSUBSChannelIslandsEurope //ISO code Northern IRL under GBR
rename distNOR distSUBSNorwayEurope
rename distOMN distSUBSOmanAsia
rename distPNG distSUBSPNGPacific
rename distPAK distSUBSPakistanAsia
rename distPAN distSUBSPanamaSouthAmerica
rename distPRY distSUBSParaguay
rename distPER distSUBSPeruSouthAmerica
rename distPHL distSUBSPhilippinesAsia
rename distPOL distSUBSPolandEurope
rename distPRT distSUBSPortugalEurope
rename distPRI distSUBSPuertoRicoSouthAme
rename distQAT distSUBSQatarAsia
gen distSUBSRepublicofIrelandE=distSUBSIrelandEurope
rename distROM distSUBSRomaniaEurope
rename distRUS distSUBSRussiaEurope
gen distSUBSSamoaPacific=distSUBSAmericanSamoaPacifi
rename distSAU distSUBSSaudiArabiaAsia
gen distSUBSScotlandEurope=distSUBSChannelIslandsEurope //ISO code Scotland under GBR
rename distSEN distSUBSSenegalAfrica
gen distSUBSSerbia=distSUBSMontenegroEurope
gen distSUBSSiberiaEurope=distSUBSRussiaEurope
rename distSLE distSUBSSierraLeoneAfrica
rename distSGP distSUBSSingaporeAsia
rename distSVK distSUBSSlovakRepublicEurop
gen distSUBSSlovakiaEurope=distSUBSSlovakRepublicEurop
rename distSVN distSUBSSloveniaEurope
rename distSLB distSUBSSolomonIsPacific
rename distESP distSUBSSpainEurope
rename distLKA distSUBSSriLankaAsia
rename distZAF distSUBSSthAfricaAfrica
rename distSWE distSUBSSwedenEurope
rename distCHE distSUBSSwitzerlandEurope
rename distTWN distSUBSTaiwanAsia
rename distTZA distSUBSTanzaniaAfrica
rename distTHA distSUBSThailandAsia
rename distTMP distSUBSTimorLesteAsia
rename distTON distSUBSTongaPacific
rename distTTO distSUBSTrinidadSouthAmeric
rename distTUR distSUBSTurkeyEurope
rename distTCA distSUBSTurksCaicosIslands
gen distSUBSUAEAsia=distSUBSJebelAliFreeZoneA //ISO code ARE
gen distSUBSUKEurope=distSUBSChannelIslandsEurope //ISO code UK
gen distSUBSUSANorthAmerica=distSUBSAlaska
rename distUZB distSUBSUZBEKISTAN
rename distUGA distSUBSUgandaAfrica
rename distUKR distSUBSUkraineEurope
rename distURY distSUBSUruguay
rename distVUT distSUBSVanuatuPacific
rename distVEN distSUBSVenezuelaSouthAmeri
rename distVNM distSUBSVietnamAsia
gen distSUBSWesternSamoaPacific=distSUBSAmericanSamoaPacifi
rename distZMB distSUBSZambiaAfrica
rename distZWE distSUBSZimbabweAfrica

drop distABW distAND distARM distAZE distBEN distBLR distBTN distCAF distCCK distCOM distCPV distCUB distCXR distDJI distDMA distERI distESH distFLK distFRO distFSM distGLP distGNB distGNQ distGRD distGRL distGUF distHTI distISL distJOR distKIR distKNA distLBN distLCA distLSO distLVA distMDA distMDV distMHL distMMR distMNP distMSR distMTQ distNFK distNIC distNIU distNPL distNRU distPAL distPCN distPLW distPRK distPYF distREU distSDN distRWA distSHN distSMR distSOM distSPM distSTP distSUR distSWZ distSYR distSYC distTCD distTGO distTJK distTKL distTKM distTUN distTUV distVCT distWLF distYEM distZAR
save ".\data\dist_cepii_clean.dta",replace

use ".\data\SUBS_IFRS.dta"
append using ".\data\dist_cepii_clean.dta"

foreach var of varlist distSUBSAfghanistanAsia - distSUBSWesternSamoaPacific {
fillmissing `var'
}
drop if year_SPPR==. & asxcode==""

foreach var of varlist SUBSANTIGUAANDBARBUDA-SUBSZimbabweAfrica {
gen GD`var'=`var'*dist`var' 
}

egen TotalDistance=rowtotal(GD*)
gen AvgDistance=TotalDistance/TOTSUB
drop GD* dist*
save ".\data\SUBS_IFRS_GeoDist.dta", replace

***Subsidiary RL data***
***Download Excel file at: https://info.worldbank.org/governance/wgi/Home/downLoadFile?fileName=wgidataset.xlsx, use sheet RuleofLaw
***In Excel: use estimates for 2006-2013. Create a long-form dataset with RL estimates from 2006-2013 (RL2006-RL2013)
***Manually match SUBS names to ISO Codes in Excel (use same ISO codes as for Distance data, except New Caledonia matched to FRA). Match between ISO codes and SUBS coding in file "Match SUBS_ISO Country Codes.xlsx"
import excel ".\data\RL_raw.xlsx", sheet("Sheet1") firstrow clear
save ".\data\RL_raw.dta", replace

import excel ".\data\Match SUBS_ISO Country Codes_RL.xlsx", sheet("Sheet1") firstrow clear
save ".\data\Match SUBS_ISO Country Codes_RL.dta", replace

use ".\data\Match SUBS_ISO Country Codes_RL.dta"
merge m:m ISOCountryCode using ".\data\RL_raw.dta"
drop _merge==2
drop _merge

*Impute missing value for Cook Islands; assume RL=0 for missing values Vietnam
replace RL2008=RL2007 if ISOCountryCode=="COK"
replace RL2007=0 if ISOCountryCode=="VNM"
replace RL2008=0 if ISOCountryCode=="VNM"
replace RL2009=0 if ISOCountryCode=="VNM"
replace RL2010=0 if ISOCountryCode=="VNM"
replace RL2011=0 if ISOCountryCode=="VNM"
replace RL2012=0 if ISOCountryCode=="VNM"
replace RL2013=0 if ISOCountryCode=="VNM"

egen AvRL=rowmean(RL2006 RL2007 RL2008 RL2009 RL2010 RL2011 RL2012 RL2013)
drop RL*
sort ISOCountryCode SUBS AvRL
reshape wide AvRL, i(ISOCountryCode) j(SUBS) string 

save ".\data\RL_clean.dta", replace

use ".\data\SUBS_IFRS_GeoDist.dta"
append using ".\data\RL_clean.dta"

foreach var of varlist AvRLSUBSANTIGUAANDBARBUDA - AvRLSUBSZimbabweAfrica {
fillmissing `var'
}
drop if year_SPPR==. & asxcode==""

foreach var of varlist SUBSANTIGUAANDBARBUDA-SUBSZimbabweAfrica {
gen RL`var'=`var'*AvRL`var' 
}

egen RLsum=rowtotal(RL*)
gen AverageRL=RLsum/TOTSUB
drop RL* AvRL*
save ".\data\SUBS_IFRS_GeoDist_RL.dta", replace

***Subsidiary GDP data***
ssc install wbopendata
clear
wbopendata, language(en - English) country() topics() indicator(NY.GDP.PCAP.CD - GDP per capita (current US$))
***Data were downloaded on 11.04.2019 in current US$. The current download will provide slightly different values.
drop countryname region regionname adminregion adminregionname incomelevel incomelevelname lendingtype lendingtypename indicatorname indicatorcode yr1960-yr2005 yr2014-yr2020
rename countrycode ISOCountryCode
save ".\data\GDP_raw.dta", replace

*GDP not available for certain territotries/special administrative regions. Therefore, different matching for GDP vs. Rule of Law.
import excel ".\data\Match SUBS_ISO Country Codes_GDP.xlsx", sheet("Sheet1") firstrow clear
save ".\data\Match SUBS_ISO Country Codes_GDP.dta", replace

use ".\data\Match SUBS_ISO Country Codes_GDP.dta"
merge m:m ISOCountryCode using ".\data\GDP_raw.dta"
drop if _merge==2
drop _merge

egen AvGDP=rowmean(yr2006 yr2007 yr2008 yr2009 yr2010 yr2011 yr2012 yr2013)
drop yr*
sort ISOCountryCode SUBS AvGDP
reshape wide AvGDP, i(ISOCountryCode) j(SUBS) string 
save ".\data\GDP_clean.dta", replace

use ".\data\SUBS_IFRS_GeoDist_RL.dta"
append using ".\data\GDP_clean.dta"

foreach var of varlist AvGDPSUBSANTIGUAANDBARBUDA - AvGDPSUBSZimbabweAfrica {
fillmissing `var'
}
drop if year_SPPR==. & asxcode==""

foreach var of varlist SUBSANTIGUAANDBARBUDA-SUBSZimbabweAfrica {
gen GDP`var'=`var'*AvGDP`var' 
}

egen GDPsum=rowtotal(GDP*)
gen AverageGDP=GDPsum/TOTSUB
drop GDP* AvGDP*
save ".\data\SUBS_IFRS_GeoDist_RL_GDP.dta", replace

***Data Definition***
use ".\data\SUBS_IFRS_GeoDist_RL_GDP.dta"
gen lnSUBGDP=ln( AverageGDP)
gen lnSUBDist=ln( AvgDistance)
gen LowAverageRL=0
*Lowest 25th percentile within sample (if sample_MNE==1 & RecPaySample==1)
replace LowAverageRL=1 if AverageRL<1.120731

*Upper quartile within sample (if sample_MNE==1 & RecPaySample==1)
gen HighSubDist=0
replace HighSubDist=1 if lnSUBDist>9.146697
save ".\data\SUBS_IFRS_GeoDist_RL_GDP.dta", replace

***Merge with Final_step 8.dta
use  ".\data\Final_step8.dta"
merge 1:1 asxcode year_SPPR using ".\data\SUBS_IFRS_GeoDist_RL_GDP.dta"
drop if _merge==2
drop _merge
save  ".\data\Final_step9.dta", replace


***Subsidiary Location Coverage data***
use  ".\data\Final_step9.dta"
keep id groupcoycode YEAR asxcode fullcoyname AUDITOR PARTNER OFFICE sample_MNE sample_OZ sample_nongroup SUBSANTIGUAANDBARBUDA SUBSAfghanistanAsia SUBSAlaska SUBSAlbania SUBSAlgeriaAfrica SUBSAmericanSamoaPacifi SUBSAngolaAfrica SUBSArgentinaSouthAmeri SUBSAustralia SUBSAustriaEurope SUBSBahamasSouthAmerica SUBSBahrainAsia SUBSBangladeshAsia SUBSBarbadosSouthAmeric SUBSBelgiumEurope SUBSBelizeSouthAmerica SUBSBermudaSouthAmerica SUBSBoliviaSouthAmerica SUBSBosniaHerzegovinaEurope SUBSBotswanaAfrica SUBSBrazilSouthAmerica SUBSBritishAnguillaSout SUBSBritishVirginIslands SUBSBruneiAsia SUBSBulgariaEurope SUBSBurkinaFasoAfrica SUBSBurundiAfrica SUBSCambodiaAsia SUBSCameroonAfrica SUBSCanadaNorthAmerica SUBSCaymanIslandsSouth SUBSChannelIslandsEurope SUBSChileSouthAmerica SUBSChinaAsia SUBSColombiaSouthAmeric SUBSCongoAfrica SUBSCookIslandsPacific SUBSCostaRicaSouthAmer SUBSCroatiaEurope SUBSCyprusEurope SUBSCzechRepublicEurope SUBSDenmarkEurope SUBSDominicanRepublicSo SUBSEcuadorSouthAmerica SUBSEgyptAsia SUBSElSalvador SUBSEnglandEurope SUBSEstoniaEurope SUBSEthiopia SUBSFijiPacific SUBSFinlandEurope SUBSFranceEurope SUBSGaboneseRepublicAfrica SUBSGambia SUBSGeorgiaEurope SUBSGermanyEurope SUBSGhanaAfrica SUBSGibraltarEurope SUBSGreeceEurope SUBSGuatemalaSouthAmeri SUBSGuernseyEurope SUBSGuineaAfrica SUBSGuyanaSouthAmerica SUBSHKAsia SUBSHondurasSouthAmeric SUBSHungaryAsia SUBSIndiaAsia SUBSIndonesiaAsia SUBSIranAsia SUBSIraq SUBSIrelandEurope SUBSIsleofManEurope SUBSIsraelAsia SUBSItalyEurope SUBSIvorycoastAfrica SUBSJamaicaSouthAmerica SUBSJapanAsia SUBSJebelAliFreeZoneA SUBSJerseyEurope SUBSKazakhstanAsia SUBSKenyaAfrica SUBSKoreaAsia SUBSKuwaitAsia SUBSKyrgyzRepublicAsia SUBSLaosAsia SUBSLiberia SUBSLibyaAfrica SUBSLithuaniaEurope SUBSLuxembourgEurope SUBSMacauAsia SUBSMacedoniaEurope SUBSMadagascarAfrica SUBSMalawiAfrica SUBSMalaysiaAsia SUBSMaliAfrica SUBSMaltaEurope SUBSMauritaniaAfrica SUBSMauritiusAfrica SUBSMexicoNorthAmerica SUBSMongoliaAsia SUBSMontenegroEurope SUBSMoroccoAfrica SUBSMozambiqueAfrica SUBSNAntillesSouthAme SUBSNZPacific SUBSNamibiaAfrica SUBSNetherlandsAntSout SUBSNetherlandsEurope SUBSNewCaledoniaPacific SUBSNigerAfrica SUBSNigeriaAfrica SUBSNorthernIrelandEuro SUBSNorwayEurope SUBSOmanAsia SUBSPNGPacific SUBSPakistanAsia SUBSPanamaSouthAmerica SUBSParaguay SUBSPeruSouthAmerica SUBSPhilippinesAsia SUBSPolandEurope SUBSPortugalEurope SUBSPuertoRicoSouthAme SUBSQatarAsia SUBSRepublicofIrelandE SUBSRomaniaEurope SUBSRussiaEurope SUBSSamoaPacific SUBSSaudiArabiaAsia SUBSScotlandEurope SUBSSenegalAfrica SUBSSerbia SUBSSiberiaEurope SUBSSierraLeoneAfrica SUBSSingaporeAsia SUBSSlovakRepublicEurop SUBSSlovakiaEurope SUBSSloveniaEurope SUBSSolomonIsPacific SUBSSpainEurope SUBSSriLankaAsia SUBSSthAfricaAfrica SUBSSwedenEurope SUBSSwitzerlandEurope SUBSTaiwanAsia SUBSTanzaniaAfrica SUBSThailandAsia SUBSTimorLesteAsia SUBSTongaPacific SUBSTrinidadSouthAmeric SUBSTurkeyEurope SUBSTurksCaicosIslands SUBSUAEAsia SUBSUKEurope SUBSUSANorthAmerica SUBSUZBEKISTAN SUBSUgandaAfrica SUBSUkraineEurope SUBSUruguay SUBSVanuatuPacific SUBSVenezuelaSouthAmeri SUBSVietnamAsia SUBSWesternSamoaPacific SUBSZambiaAfrica SUBSZimbabweAfrica TOTSUB
order id groupcoycode YEAR asxcode fullcoyname AUDITOR PARTNER OFFICE sample_MNE sample_OZ sample_nongroup SUBSANTIGUAANDBARBUDA SUBSAfghanistanAsia SUBSAlaska SUBSAlbania SUBSAlgeriaAfrica SUBSAmericanSamoaPacifi SUBSAngolaAfrica SUBSArgentinaSouthAmeri SUBSAustralia SUBSAustriaEurope SUBSBahamasSouthAmerica SUBSBahrainAsia SUBSBangladeshAsia SUBSBarbadosSouthAmeric SUBSBelgiumEurope SUBSBelizeSouthAmerica SUBSBermudaSouthAmerica SUBSBoliviaSouthAmerica SUBSBosniaHerzegovinaEurope SUBSBotswanaAfrica SUBSBrazilSouthAmerica SUBSBritishAnguillaSout SUBSBritishVirginIslands SUBSBruneiAsia SUBSBulgariaEurope SUBSBurkinaFasoAfrica SUBSBurundiAfrica SUBSCambodiaAsia SUBSCameroonAfrica SUBSCanadaNorthAmerica SUBSCaymanIslandsSouth SUBSChannelIslandsEurope SUBSChileSouthAmerica SUBSChinaAsia SUBSColombiaSouthAmeric SUBSCongoAfrica SUBSCookIslandsPacific SUBSCostaRicaSouthAmer SUBSCroatiaEurope SUBSCyprusEurope SUBSCzechRepublicEurope SUBSDenmarkEurope SUBSDominicanRepublicSo SUBSEcuadorSouthAmerica SUBSEgyptAsia SUBSElSalvador SUBSEnglandEurope SUBSEstoniaEurope SUBSEthiopia SUBSFijiPacific SUBSFinlandEurope SUBSFranceEurope SUBSGaboneseRepublicAfrica SUBSGambia SUBSGeorgiaEurope SUBSGermanyEurope SUBSGhanaAfrica SUBSGibraltarEurope SUBSGreeceEurope SUBSGuatemalaSouthAmeri SUBSGuernseyEurope SUBSGuineaAfrica SUBSGuyanaSouthAmerica SUBSHKAsia SUBSHondurasSouthAmeric SUBSHungaryAsia SUBSIndiaAsia SUBSIndonesiaAsia SUBSIranAsia SUBSIraq SUBSIrelandEurope SUBSIsleofManEurope SUBSIsraelAsia SUBSItalyEurope SUBSIvorycoastAfrica SUBSJamaicaSouthAmerica SUBSJapanAsia SUBSJebelAliFreeZoneA SUBSJerseyEurope SUBSKazakhstanAsia SUBSKenyaAfrica SUBSKoreaAsia SUBSKuwaitAsia SUBSKyrgyzRepublicAsia SUBSLaosAsia SUBSLiberia SUBSLibyaAfrica SUBSLithuaniaEurope SUBSLuxembourgEurope SUBSMacauAsia SUBSMacedoniaEurope SUBSMadagascarAfrica SUBSMalawiAfrica SUBSMalaysiaAsia SUBSMaliAfrica SUBSMaltaEurope SUBSMauritaniaAfrica SUBSMauritiusAfrica SUBSMexicoNorthAmerica SUBSMongoliaAsia SUBSMontenegroEurope SUBSMoroccoAfrica SUBSMozambiqueAfrica SUBSNAntillesSouthAme SUBSNZPacific SUBSNamibiaAfrica SUBSNetherlandsAntSout SUBSNetherlandsEurope SUBSNewCaledoniaPacific SUBSNigerAfrica SUBSNigeriaAfrica SUBSNorthernIrelandEuro SUBSNorwayEurope SUBSOmanAsia SUBSPNGPacific SUBSPakistanAsia SUBSPanamaSouthAmerica SUBSParaguay SUBSPeruSouthAmerica SUBSPhilippinesAsia SUBSPolandEurope SUBSPortugalEurope SUBSPuertoRicoSouthAme SUBSQatarAsia SUBSRepublicofIrelandE SUBSRomaniaEurope SUBSRussiaEurope SUBSSamoaPacific SUBSSaudiArabiaAsia SUBSScotlandEurope SUBSSenegalAfrica SUBSSerbia SUBSSiberiaEurope SUBSSierraLeoneAfrica SUBSSingaporeAsia SUBSSlovakRepublicEurop SUBSSlovakiaEurope SUBSSloveniaEurope SUBSSolomonIsPacific SUBSSpainEurope SUBSSriLankaAsia SUBSSthAfricaAfrica SUBSSwedenEurope SUBSSwitzerlandEurope SUBSTaiwanAsia SUBSTanzaniaAfrica SUBSThailandAsia SUBSTimorLesteAsia SUBSTongaPacific SUBSTrinidadSouthAmeric SUBSTurkeyEurope SUBSTurksCaicosIslands SUBSUAEAsia SUBSUKEurope SUBSUSANorthAmerica SUBSUZBEKISTAN SUBSUgandaAfrica SUBSUkraineEurope SUBSUruguay SUBSVanuatuPacific SUBSVenezuelaSouthAmeri SUBSVietnamAsia SUBSWesternSamoaPacific SUBSZambiaAfrica SUBSZimbabweAfrica TOTSUB
count if sample_MNE == 1
keep if sample_MNE == 1

replace SUBSAustralia = SUBSAustralia+1 //the purpose of this step is to include parent entity
sum SUBSANTIGUAANDBARBUDA SUBSAfghanistanAsia SUBSAlaska SUBSAlbania SUBSAlgeriaAfrica SUBSAmericanSamoaPacifi SUBSAngolaAfrica SUBSArgentinaSouthAmeri SUBSAustralia SUBSAustriaEurope SUBSBahamasSouthAmerica SUBSBahrainAsia SUBSBangladeshAsia SUBSBarbadosSouthAmeric SUBSBelgiumEurope SUBSBelizeSouthAmerica SUBSBermudaSouthAmerica SUBSBoliviaSouthAmerica SUBSBosniaHerzegovinaEurope SUBSBotswanaAfrica SUBSBrazilSouthAmerica SUBSBritishAnguillaSout SUBSBritishVirginIslands SUBSBruneiAsia SUBSBulgariaEurope SUBSBurkinaFasoAfrica SUBSBurundiAfrica SUBSCambodiaAsia SUBSCameroonAfrica SUBSCanadaNorthAmerica SUBSCaymanIslandsSouth SUBSChannelIslandsEurope SUBSChileSouthAmerica SUBSChinaAsia SUBSColombiaSouthAmeric SUBSCongoAfrica SUBSCookIslandsPacific SUBSCostaRicaSouthAmer SUBSCroatiaEurope SUBSCyprusEurope SUBSCzechRepublicEurope SUBSDenmarkEurope SUBSDominicanRepublicSo SUBSEcuadorSouthAmerica SUBSEgyptAsia SUBSElSalvador SUBSEnglandEurope SUBSEstoniaEurope SUBSEthiopia SUBSFijiPacific SUBSFinlandEurope SUBSFranceEurope SUBSGaboneseRepublicAfrica SUBSGambia SUBSGeorgiaEurope SUBSGermanyEurope SUBSGhanaAfrica SUBSGibraltarEurope SUBSGreeceEurope SUBSGuatemalaSouthAmeri SUBSGuernseyEurope SUBSGuineaAfrica SUBSGuyanaSouthAmerica SUBSHKAsia SUBSHondurasSouthAmeric SUBSHungaryAsia SUBSIndiaAsia SUBSIndonesiaAsia SUBSIranAsia SUBSIraq SUBSIrelandEurope SUBSIsleofManEurope SUBSIsraelAsia SUBSItalyEurope SUBSIvorycoastAfrica SUBSJamaicaSouthAmerica SUBSJapanAsia SUBSJebelAliFreeZoneA SUBSJerseyEurope SUBSKazakhstanAsia SUBSKenyaAfrica SUBSKoreaAsia SUBSKuwaitAsia SUBSKyrgyzRepublicAsia SUBSLaosAsia SUBSLiberia SUBSLibyaAfrica SUBSLithuaniaEurope SUBSLuxembourgEurope SUBSMacauAsia SUBSMacedoniaEurope SUBSMadagascarAfrica SUBSMalawiAfrica SUBSMalaysiaAsia SUBSMaliAfrica SUBSMaltaEurope SUBSMauritaniaAfrica SUBSMauritiusAfrica SUBSMexicoNorthAmerica SUBSMongoliaAsia SUBSMontenegroEurope SUBSMoroccoAfrica SUBSMozambiqueAfrica SUBSNAntillesSouthAme SUBSNZPacific SUBSNamibiaAfrica SUBSNetherlandsAntSout SUBSNetherlandsEurope SUBSNewCaledoniaPacific SUBSNigerAfrica SUBSNigeriaAfrica SUBSNorthernIrelandEuro SUBSNorwayEurope SUBSOmanAsia SUBSPNGPacific SUBSPakistanAsia SUBSPanamaSouthAmerica SUBSParaguay SUBSPeruSouthAmerica SUBSPhilippinesAsia SUBSPolandEurope SUBSPortugalEurope SUBSPuertoRicoSouthAme SUBSQatarAsia SUBSRepublicofIrelandE SUBSRomaniaEurope SUBSRussiaEurope SUBSSamoaPacific SUBSSaudiArabiaAsia SUBSScotlandEurope SUBSSenegalAfrica SUBSSerbia SUBSSiberiaEurope SUBSSierraLeoneAfrica SUBSSingaporeAsia SUBSSlovakRepublicEurop SUBSSlovakiaEurope SUBSSloveniaEurope SUBSSolomonIsPacific SUBSSpainEurope SUBSSriLankaAsia SUBSSthAfricaAfrica SUBSSwedenEurope SUBSSwitzerlandEurope SUBSTaiwanAsia SUBSTanzaniaAfrica SUBSThailandAsia SUBSTimorLesteAsia SUBSTongaPacific SUBSTrinidadSouthAmeric SUBSTurkeyEurope SUBSTurksCaicosIslands SUBSUAEAsia SUBSUKEurope SUBSUSANorthAmerica SUBSUZBEKISTAN SUBSUgandaAfrica SUBSUkraineEurope SUBSUruguay SUBSVanuatuPacific SUBSVenezuelaSouthAmeri SUBSVietnamAsia SUBSWesternSamoaPacific SUBSZambiaAfrica SUBSZimbabweAfrica
rename *Asia * 
rename *Africa * 
rename *Pacific * 
rename *Europe * 
rename *SouthAmerica * 
rename *NorthAmerica * 
rename SUBSANTIGUAANDBARBUDA SUBSAntiguaAndBarbuda
rename SUBSAmericanSamoaPacifi SUBSAmericanSamoa 
rename SUBSArgentinaSouthAmeri SUBSArgentina
rename SUBSBarbadosSouthAmeric SUBSBarbados
rename SUBSBritishAnguillaSout SUBSBritishAnguilla
rename SUBSCaymanIslandsSouth SUBSCaymanIslands
rename SUBSColombiaSouthAmeric SUBSColombia
rename SUBSCostaRicaSouthAmer SUBSCostaRica
rename SUBSDominicanRepublicSo SUBSDominicanRepublic
rename SUBSGuatemalaSouthAmeri SUBSGuatemala
rename SUBSHondurasSouthAmeric SUBSHonduras
rename SUBSJebelAliFreeZoneA SUBSJebelAliFreeZone
rename SUBSNAntillesSouthAme SUBSNAntilles
rename SUBSNetherlandsAntSout SUBSNetherlandsAnt
rename SUBSNorthernIrelandEuro SUBSNorthernIreland
rename SUBSPuertoRicoSouthAme SUBSPuertoRico
rename SUBSRepublicofIrelandE SUBSRepublicofIreland
rename SUBSSlovakRepublicEurop SUBSSlovakRepublic
rename SUBSTrinidadSouthAmeric SUBSTrinidad
rename SUBSVenezuelaSouthAmeri SUBSVenezuela

reshape long SUBS, i(id) j(Country, string)
drop if SUBS == 0

drop PARTNER OFFICE sample_MNE sample_OZ sample_nongroup SUBS TOTSUB
order AUDITOR, after(id)
drop if Country == "ALL"
gen AD_CY = AUDITOR + "_" + Country
count

save ".\data\SUBS_Prep_Cov.dta", replace

import excel ".\data\LocationCoverage_RawData.xlsx", sheet("Sheet1") firstrow clear
drop GU

*Rename countries consistent with SUBS data
rename AntiguaandSaintKittsandNerv AntiguaAndBarbuda
rename BosniaandHerzegovina BosniaHerzegovina
rename CameroonRepublicof Cameroon
rename CongoDemocraticRepublicof Congo
rename GabonRepublicof GaboneseRepublic
rename HongKong HK
rename CotedIvoireIvoryCoast Ivorycoast
rename SouthKorea Korea
rename Kyrgyzstan KyrgyzRepublic
rename NewZealand NZ
rename PapuaNewGuinea PNG
rename SouthAfrica SthAfrica
rename TrinidadTobago Trinidad
rename UnitedArabEmirates UAE
rename UnitedKingdom UK
rename UnitedStates USA
rename Uzbekistan UZBEKISTAN

rename * SUBS*
rename SUBSAUDITOR AUDITOR
reshape long SUBS, i(AUDITOR) j(Country, string)
drop if missing(SUBS)

gen AD_CY = AUDITOR + "_" + Country
keep AD_CY

save ".\data\Cov_Prep.dta", replace

use ".\data\SUBS_Prep_Cov.dta"
merge m:1 AD_CY using ".\data\Cov_Prep.dta"
drop if _merge == 2

gen cover = .
replace cover = 1 if _merge == 3
replace cover = 0 if _merge == 1
count if missing(cover)

by id, sort: egen NoSubLctC = sum(cover)
label variable NoSubLct "Number of (the parent entity + subsidiaries) locations covered by the audit firm network"

by id, sort: egen TotNoSubLct = count(cover)
label variable TotNoSubLct "Total number of (the parent entity + subsidiaries) locations"

gen Location_cov = NoSubLctC/TotNoSubLct
label variable Location_cov "Proportion of subsidiary locations(including parent entity) covered by the main auditor's network (Location_cov = NoSubLctC/TotNoSubLct) "

drop Country AD_CY _merge cover 
duplicates report id
duplicates drop 

tabstat Location_cov, stats(N mean sd min p10 p25 median p75 p90 max) columns(stat) format(%9.2g) 
sort id

save ".\data\Location_Coverage.dta", replace

***Merge with step 9***
use ".\data\Final_step9.dta"
merge 1:1 id using ".\data\Location_Coverage.dta"
rename _merge _merge_GAFN
save ".\data\Final_step10.dta", replace

***Define Sample***
gen Sample=.
replace Sample=1 if year_SPPR>=2006 & year_SPPR<=2013 & sample_MNE==1 & RecPaySample==1 & !missing(COMPONENT) & !missing(COMPONENT_pcnt) & !missing(UNAFFILIATED_pcnt) & !missing(NETWORK_pcnt) & !missing(LTAw) & !missing(CATAw) & !missing(QUICKw) & !missing(LEVERAGEw) & !missing(PERFORMw) & !missing(MOPINION) & !missing(LOSS) & !missing(PPEGROWTHw) & !missing(SALESGROWTHw) & !missing(SALE_vol) & !missing(OCF_volw) & !missing(lnAGE) & !missing(Annualw) & !missing(MBw) & !missing(RecTurnoverw) & !missing(PayTurnoverw) & !missing(MINING) & !missing(ADTCHANGE) & !missing(MNESpec) & !missing(PTonlyCHANGE) & !missing(BIG4) & !missing(LARGENONBIGN) & !missing(IndLeader) & !missing(Busyseas) & !missing(LSUB) & !missing(min25pct_FOREIGN) & !missing(LowPctSUBSEnglish) & !missing(LowPercFXIFRS) & !missing(HighSubDist) & !missing(LowAverageRL) & !missing(absTotAccw) & !missing(InvAssetsw) & !missing(RevARw) & !missing(PPENw) &!missing(l_ROAw) & !missing(iy) & !missing(SIRCAsectorcode) & !missing(D_SUBS_UK) & !missing(LAF_CPI_adjusted) & !missing(LowAverageRL) & !missing(Location_cov) & !missing(IDenc) & !missing(GICS_sector15) & !missing(groupcoycode)

save ".\data\Final_step10.dta", replace

version 14.0
set more off
log cap close


**step1**
clear 
cd "$base"
import excel ".\data\SPPR2015_company.xlsx", sheet("company") firstrow
replace groupcoycode = trim( groupcoycode )
replace companycode = trim( companycode )
replace fullcoyname = trim( fullcoyname )
save ".\data\SPPR2015_company.dta"
****************************************

**step2**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
gsort groupcoycode -listdate
duplicates report groupcoycode listdate
duplicates list groupcoycode listdate
drop if groupcoycode=="cpw1" & companycode=="crs--1"
by groupcoycode: egen maxlistdate = max(listdate)
format %td maxlistdate
gen latest=0
replace latest=1 if maxlistdate==listdate
drop if latest==0
gen tcode  = tcode_3 
keep groupcoycode tcode
save ".\data\tcodemaker.dta", replace
****************************************

**step3**
**2000**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2000)& delistdate>=td(1,1,2000))|(listdate<td(1,1,2000)& missing(delistdate))|(listdate>=td(1,1,2000)& listdate<=td(31,12,2000))
keep if (listdate<td(1,1,2000)& delistdate>=td(1,1,2000))|(listdate<td(1,1,2000)& missing(delistdate))|(listdate>=td(1,1,2000)& listdate<=td(31,12,2000))

gsort groupcoycode +listdate
duplicates report groupcoycode if (listdate<td(1,1,2000)& delistdate>=td(1,1,2000))|(listdate<td(1,1,2000)& missing(delistdate))|(listdate>=td(1,1,2000)& listdate<=td(31,12,2000))
duplicates drop groupcoycode if (listdate<td(1,1,2000)& delistdate>=td(1,1,2000))|(listdate<td(1,1,2000)& missing(delistdate))|(listdate>=td(1,1,2000)& listdate<=td(31,12,2000)), force

count if (listdate<td(1,1,2000)& delistdate>=td(1,1,2000))|(listdate<td(1,1,2000)& missing(delistdate))
count if (listdate>=td(1,1,2000)& listdate<=td(31,12,2000))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

sort asxcode
duplicates report asxcode
duplicates list asxcode

replace asxcode="AEH1" if asxcode=="AEH" & groupcoycode =="apu1" 
replace asxcode="AJR1" if asxcode=="AJR" & groupcoycode =="ajr1" 
replace asxcode="ALQ1" if asxcode=="ALQ" & groupcoycode =="alq2"
replace asxcode="AOG1" if asxcode=="AOG" & groupcoycode =="aog1" 
replace asxcode="CAD1" if asxcode=="CAD" & groupcoycode =="cad1" 
replace asxcode="CBS1" if asxcode=="CBS" & groupcoycode =="cbs1" 
replace asxcode="CLA1" if asxcode=="CLA" & groupcoycode =="cla3"
replace asxcode="MED1" if asxcode=="MED" & groupcoycode =="med1" 
replace asxcode="NTL1" if asxcode=="NTL" & groupcoycode =="ntl1"
replace asxcode="PTL1" if asxcode=="PTL" & groupcoycode =="ptl1" 
replace asxcode="SGO1" if asxcode=="SGO" & groupcoycode =="sgo1" 
replace asxcode="TPS2" if asxcode=="TPS" & groupcoycode =="mmo1" 
drop if asxcode=="X02"

duplicates report asxcode
merge 1:1 asxcode using "Financial_Data_2000.dta"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2000SPPR_Financial.dta", replace
****************************************

**2001**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2001)& delistdate>=td(1,1,2001))|(listdate<td(1,1,2001)& missing(delistdate))|(listdate>=td(1,1,2001)& listdate<=td(31,12,2001))
keep if (listdate<td(1,1,2001)& delistdate>=td(1,1,2001))|(listdate<td(1,1,2001)& missing(delistdate))|(listdate>=td(1,1,2001)& listdate<=td(31,12,2001))

gsort groupcoycode +listdate
duplicates report groupcoycode if (listdate<td(1,1,2001)& delistdate>=td(1,1,2001))|(listdate<td(1,1,2001)& missing(delistdate))|(listdate>=td(1,1,2001)& listdate<=td(31,12,2001))
duplicates drop groupcoycode if (listdate<td(1,1,2001)& delistdate>=td(1,1,2001))|(listdate<td(1,1,2001)& missing(delistdate))|(listdate>=td(1,1,2001)& listdate<=td(31,12,2001)), force

count if (listdate<td(1,1,2001)& delistdate>=td(1,1,2001))|(listdate<td(1,1,2001)& missing(delistdate))
count if (listdate>=td(1,1,2001)& listdate<=td(31,12,2001))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

sort asxcode
duplicates report asxcode
duplicates list asxcode

replace asxcode="AEH1" if asxcode=="AEH" & groupcoycode =="apu1" 
replace asxcode="AJR1" if asxcode=="AJR" & groupcoycode =="ajr1" 
replace asxcode="ALQ1" if asxcode=="ALQ" & groupcoycode =="alq2"
replace asxcode="AOG1" if asxcode=="AOG" & groupcoycode =="aog1" 
replace asxcode="BRS1" if asxcode=="BRS" & groupcoycode =="brs1" 
replace asxcode="CLA1" if asxcode=="CLA" & groupcoycode =="cla3"
replace asxcode="MED1" if asxcode=="MED" & groupcoycode =="med1" 
replace asxcode="NTL1" if asxcode=="NTL" & groupcoycode =="ntl1"
replace asxcode="PTL1" if asxcode=="PTL" & groupcoycode =="ptl1" 
replace asxcode="SGO1" if asxcode=="SGO" & groupcoycode =="sgo1" 
replace asxcode="TPS2" if asxcode=="TPS" & groupcoycode =="mmo1" 
drop if asxcode=="X02"

duplicates report asxcode
merge 1:1 asxcode using "Financial_Data_2001.dta"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2001SPPR_Financial.dta", replace
****************************************

**2002**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2002)& delistdate>=td(1,1,2002))|(listdate<td(1,1,2002)& missing(delistdate))|(listdate>=td(1,1,2002)& listdate<=td(31,12,2002))
keep if (listdate<td(1,1,2002)& delistdate>=td(1,1,2002))|(listdate<td(1,1,2002)& missing(delistdate))|(listdate>=td(1,1,2002)& listdate<=td(31,12,2002))

gsort groupcoycode +listdate
duplicates report groupcoycode if (listdate<td(1,1,2002)& delistdate>=td(1,1,2002))|(listdate<td(1,1,2002)& missing(delistdate))|(listdate>=td(1,1,2002)& listdate<=td(31,12,2002))
duplicates drop groupcoycode if (listdate<td(1,1,2002)& delistdate>=td(1,1,2002))|(listdate<td(1,1,2002)& missing(delistdate))|(listdate>=td(1,1,2002)& listdate<=td(31,12,2002)), force

count if (listdate<td(1,1,2002)& delistdate>=td(1,1,2002))|(listdate<td(1,1,2002)& missing(delistdate))
count if (listdate>=td(1,1,2002)& listdate<=td(31,12,2002))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

sort asxcode
duplicates report asxcode
duplicates list asxcode

replace asxcode="AEH1" if asxcode=="AEH" & groupcoycode =="apu1" 
replace asxcode="AOG1" if asxcode=="AOG" & groupcoycode =="aog1" 
replace asxcode="BRS1" if asxcode=="BRS" & groupcoycode =="brs1" 
replace asxcode="CLA1" if asxcode=="CLA" & groupcoycode =="cla3" 
replace asxcode="PTL1" if asxcode=="PTL" & groupcoycode =="ptl1" 
replace asxcode="SGO1" if asxcode=="SGO" & groupcoycode =="sgo1" 
replace asxcode="TPS2" if asxcode=="TPS" & groupcoycode =="mmo1" 
drop if asxcode=="X02"

duplicates report asxcode
merge 1:1 asxcode using "Financial_Data_2002.dta"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2002SPPR_Financial.dta", replace
****************************************

**2003**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2003)& delistdate>=td(1,1,2003))|(listdate<td(1,1,2003)& missing(delistdate))|(listdate>=td(1,1,2003)& listdate<=td(31,12,2003))
keep if (listdate<td(1,1,2003)& delistdate>=td(1,1,2003))|(listdate<td(1,1,2003)& missing(delistdate))|(listdate>=td(1,1,2003)& listdate<=td(31,12,2003))

gsort groupcoycode +listdate
duplicates report groupcoycode if (listdate<td(1,1,2003)& delistdate>=td(1,1,2003))|(listdate<td(1,1,2003)& missing(delistdate))|(listdate>=td(1,1,2003)& listdate<=td(31,12,2003))
duplicates drop groupcoycode if (listdate<td(1,1,2003)& delistdate>=td(1,1,2003))|(listdate<td(1,1,2003)& missing(delistdate))|(listdate>=td(1,1,2003)& listdate<=td(31,12,2003)), force

count if (listdate<td(1,1,2003)& delistdate>=td(1,1,2003))|(listdate<td(1,1,2003)& missing(delistdate))
count if (listdate>=td(1,1,2003)& listdate<=td(31,12,2003))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

sort asxcode
duplicates report asxcode
duplicates list asxcode

drop if asxcode=="X02"
replace asxcode="AGH1" if asxcode=="AGH" & groupcoycode =="agh1" 
replace asxcode="BRS1" if asxcode=="BRS" & groupcoycode =="brs1" 
 
duplicates report asxcode
merge 1:1 asxcode using "Financial_Data_2003.dta"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2003SPPR_Financial.dta", replace
****************************************

**2004**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2004)& delistdate>=td(1,1,2004))|(listdate<td(1,1,2004)& missing(delistdate))|(listdate>=td(1,1,2004)& listdate<=td(31,12,2004))
keep if (listdate<td(1,1,2004)& delistdate>=td(1,1,2004))|(listdate<td(1,1,2004)& missing(delistdate))|(listdate>=td(1,1,2004)& listdate<=td(31,12,2004))

gsort groupcoycode +listdate
duplicates report groupcoycode if (listdate<td(1,1,2004)& delistdate>=td(1,1,2004))|(listdate<td(1,1,2004)& missing(delistdate))|(listdate>=td(1,1,2004)& listdate<=td(31,12,2004))
duplicates drop groupcoycode if (listdate<td(1,1,2004)& delistdate>=td(1,1,2004))|(listdate<td(1,1,2004)& missing(delistdate))|(listdate>=td(1,1,2004)& listdate<=td(31,12,2004)), force

count if (listdate<td(1,1,2004)& delistdate>=td(1,1,2004))|(listdate<td(1,1,2004)& missing(delistdate))
count if (listdate>=td(1,1,2004)& listdate<=td(31,12,2004))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

sort asxcode
duplicates report asxcode
duplicates list asxcode

drop if asxcode=="X02"
replace asxcode="AGH1" if asxcode=="AGH" & groupcoycode =="agh1" 

replace asxcode="MGO" if asxcode=="MMC" & groupcoycode =="mgo1" 

duplicates report asxcode
merge 1:1 asxcode using "Financial_Data_2004.dta"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2004SPPR_Financial.dta", replace
***************************************

**2005**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2005)& delistdate>=td(1,1,2005))|(listdate<td(1,1,2005)& missing(delistdate))|(listdate>=td(1,1,2005)& listdate<=td(31,12,2005))
keep if (listdate<td(1,1,2005)& delistdate>=td(1,1,2005))|(listdate<td(1,1,2005)& missing(delistdate))|(listdate>=td(1,1,2005)& listdate<=td(31,12,2005))


sort groupcoycode listdate
duplicates report groupcoycode if (listdate<td(1,1,2005)& delistdate>=td(1,1,2005))|(listdate<td(1,1,2005)& missing(delistdate))|(listdate>=td(1,1,2005)& listdate<=td(31,12,2005))
duplicates drop groupcoycode if (listdate<td(1,1,2005)& delistdate>=td(1,1,2005))|(listdate<td(1,1,2005)& missing(delistdate))|(listdate>=td(1,1,2005)& listdate<=td(31,12,2005)), force

count if(listdate<td(1,1,2005)& delistdate>=td(1,1,2005))|(listdate<td(1,1,2005)& missing(delistdate))
count if(listdate>=td(1,1,2005)& listdate<=td(31,12,2005))
count


drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

duplicates report asxcode
duplicates list asxcode
drop if asxcode=="X02"
drop if asxcode=="AEZ" & groupcoycode =="aezc1"
replace asxcode="AHG2" if asxcode=="AHG" & groupcoycode =="inx1" //groupcoycode =="inx1" asxcode=="AHG2"
replace asxcode="BRK1" if asxcode=="BRK" & groupcoycode =="brk2" 

replace asxcode="MGO" if asxcode=="MMC" & groupcoycode =="mgo1" 

merge 1:1 asxcode using "Financial_Data_2005"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2005SPPR_Financial.dta", replace
****************************************

**2006**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2006)& delistdate>=td(1,1,2006))|(listdate<td(1,1,2006)& missing(delistdate))|(listdate>=td(1,1,2006)& listdate<=td(31,12,2006))
keep if (listdate<td(1,1,2006)& delistdate>=td(1,1,2006))|(listdate<td(1,1,2006)& missing(delistdate))|(listdate>=td(1,1,2006)& listdate<=td(31,12,2006))


sort groupcoycode listdate
duplicates report groupcoycode if (listdate<td(1,1,2006)& delistdate>=td(1,1,2006))|(listdate<td(1,1,2006)& missing(delistdate))|(listdate>=td(1,1,2006)& listdate<=td(31,12,2006))
duplicates drop groupcoycode if (listdate<td(1,1,2006)& delistdate>=td(1,1,2006))|(listdate<td(1,1,2006)& missing(delistdate))|(listdate>=td(1,1,2006)& listdate<=td(31,12,2006)), force

count if (listdate<td(1,1,2006)& delistdate>=td(1,1,2006))|(listdate<td(1,1,2006)& missing(delistdate))
count if (listdate>=td(1,1,2006)& listdate<=td(31,12,2006))
count


drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

duplicates report asxcode
duplicates list asxcode
drop if asxcode=="X02"
drop if asxcode=="AEZ" & groupcoycode =="aezc1"
drop if asxcode=="TLS" & groupcoycode =="tlsc1"
replace asxcode="AHG2" if asxcode=="AHG" & groupcoycode =="inx1" //groupcoycode =="inx1" asxcode=="AHG2"
replace asxcode="AGL1" if asxcode=="AGL" & groupcoycode =="agl1"

replace asxcode="MGO" if asxcode=="MMC" & groupcoycode =="mgo1" 

merge 1:1 asxcode using "Financial_Data_2006"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2006SPPR_Financial.dta", replace
****************************************

**2007**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2007)& delistdate>=td(1,1,2007))|(listdate<td(1,1,2007)& missing(delistdate))|(listdate>=td(1,1,2007)& listdate<=td(31,12,2007))
keep if (listdate<td(1,1,2007)& delistdate>=td(1,1,2007))|(listdate<td(1,1,2007)& missing(delistdate))|(listdate>=td(1,1,2007)& listdate<=td(31,12,2007))

sort groupcoycode listdate
duplicates report groupcoycode if (listdate<td(1,1,2007)& delistdate>=td(1,1,2007))|(listdate<td(1,1,2007)& missing(delistdate))|(listdate>=td(1,1,2007)& listdate<=td(31,12,2007))
duplicates drop groupcoycode if (listdate<td(1,1,2007)& delistdate>=td(1,1,2007))|(listdate<td(1,1,2007)& missing(delistdate))|(listdate>=td(1,1,2007)& listdate<=td(31,12,2007)), force

count if (listdate<td(1,1,2007)& delistdate>=td(1,1,2007))|(listdate<td(1,1,2007)& missing(delistdate))
count if (listdate>=td(1,1,2007)& listdate<=td(31,12,2007))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

duplicates report asxcode
duplicates list asxcode
drop if asxcode=="X02"
drop if asxcode=="AEZ" & groupcoycode =="aezc1"
drop if asxcode=="TLS" & groupcoycode =="tlsc1"
drop if asxcode=="CGG" & groupcoycode =="cmdc1"
replace asxcode="AHG2" if asxcode=="AHG" & groupcoycode =="inx1" //groupcoycode =="inx1" asxcode=="AHG2"

replace asxcode="MGO" if asxcode=="MMC" & groupcoycode =="mgo1" 

merge 1:1 asxcode using "Financial_Data_2007"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2007SPPR_Financial.dta", replace
***************************************

**2008*
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2008)& delistdate>=td(1,1,2008))|(listdate<td(1,1,2008)& missing(delistdate))|(listdate>=td(1,1,2008)& listdate<=td(31,12,2008))
keep if (listdate<td(1,1,2008)& delistdate>=td(1,1,2008))|(listdate<td(1,1,2008)& missing(delistdate))|(listdate>=td(1,1,2008)& listdate<=td(31,12,2008))


sort groupcoycode listdate
duplicates report groupcoycode if (listdate<td(1,1,2008)& delistdate>=td(1,1,2008))|(listdate<td(1,1,2008)& missing(delistdate))|(listdate>=td(1,1,2008)& listdate<=td(31,12,2008))
duplicates drop groupcoycode if (listdate<td(1,1,2008)& delistdate>=td(1,1,2008))|(listdate<td(1,1,2008)& missing(delistdate))|(listdate>=td(1,1,2008)& listdate<=td(31,12,2008)), force

count if (listdate<td(1,1,2008)& delistdate>=td(1,1,2008))|(listdate<td(1,1,2008)& missing(delistdate))
count if (listdate>=td(1,1,2008)& listdate<=td(31,12,2008))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

duplicates report asxcode
duplicates list asxcode
drop if asxcode=="X02"
drop if asxcode=="TLS" & groupcoycode =="tlsc1"
drop if asxcode=="CGG" & groupcoycode =="cmdc1"
replace asxcode="AHG2" if asxcode=="AHG" & groupcoycode =="inx1" //groupcoycode =="inx1" asxcode=="AHG2"

replace asxcode="MGO" if asxcode=="MMC" & groupcoycode =="mgo1" 

merge 1:1 asxcode using "Financial_Data_2008"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2008SPPR_Financial.dta", replace
****************************************

**2009**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2009)& delistdate>=td(1,1,2009))|(listdate<td(1,1,2009)& missing(delistdate))|(listdate>=td(1,1,2009)& listdate<=td(31,12,2009))
keep if (listdate<td(1,1,2009)& delistdate>=td(1,1,2009))|(listdate<td(1,1,2009)& missing(delistdate))|(listdate>=td(1,1,2009)& listdate<=td(31,12,2009))

sort groupcoycode listdate
duplicates report groupcoycode if (listdate<td(1,1,2009)& delistdate>=td(1,1,2009))|(listdate<td(1,1,2009)& missing(delistdate))|(listdate>=td(1,1,2009)& listdate<=td(31,12,2009))
duplicates drop groupcoycode if (listdate<td(1,1,2009)& delistdate>=td(1,1,2009))|(listdate<td(1,1,2009)& missing(delistdate))|(listdate>=td(1,1,2009)& listdate<=td(31,12,2009)), force

count if (listdate<td(1,1,2009)& delistdate>=td(1,1,2009))|(listdate<td(1,1,2009)& missing(delistdate))
count if (listdate>=td(1,1,2009)& listdate<=td(31,12,2009))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

sort tcode asxcode
duplicates report asxcode
duplicates list asxcode
drop if asxcode=="X02"
drop if asxcode=="CGG" & groupcoycode =="cmdc1"
replace asxcode="AHG2" if asxcode=="AHG" & groupcoycode =="inx1" //groupcoycode =="inx1" asxcode=="AHG2"

replace asxcode="MGO" if asxcode=="MMC" & groupcoycode =="mgo1" 

merge 1:1 asxcode using "Financial_Data_2009"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2009SPPR_Financial.dta", replace
****************************************

**2010**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2010)& delistdate>=td(1,1,2010))|(listdate<td(1,1,2010)& missing(delistdate))|(listdate>=td(1,1,2010)& listdate<=td(31,12,2010))
keep if (listdate<td(1,1,2010)& delistdate>=td(1,1,2010))|(listdate<td(1,1,2010)& missing(delistdate))|(listdate>=td(1,1,2010)& listdate<=td(31,12,2010))

sort groupcoycode listdate
duplicates report groupcoycode if (listdate<td(1,1,2010)& delistdate>=td(1,1,2010))|(listdate<td(1,1,2010)& missing(delistdate))|(listdate>=td(1,1,2010)& listdate<=td(31,12,2010))
duplicates drop groupcoycode if (listdate<td(1,1,2010)& delistdate>=td(1,1,2010))|(listdate<td(1,1,2010)& missing(delistdate))|(listdate>=td(1,1,2010)& listdate<=td(31,12,2010)), force

count if (listdate<td(1,1,2010)& delistdate>=td(1,1,2010))|(listdate<td(1,1,2010)& missing(delistdate))
count if (listdate>=td(1,1,2010)& listdate<=td(31,12,2010))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

duplicates report asxcode
duplicates list asxcode
drop if asxcode=="X02"
drop if asxcode=="CNL" & groupcoycode =="vgmc1"
drop if asxcode=="GXN" & groupcoycode == "gnic1"
drop if asxcode=="MAU" & groupcoycode =="mauc1"
drop if asxcode=="OXX" & groupcoycode =="oxxc1"

replace asxcode="CRP" if asxcode=="MTL" & groupcoycode =="crp2" 
replace asxcode="MGO" if asxcode=="MMC" & groupcoycode =="mgo1" 

merge 1:1 asxcode using "Financial_Data_2010"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2010SPPR_Financial.dta", replace
****************************************

**2011**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2011)& delistdate>=td(1,1,2011))|(listdate<td(1,1,2011)& missing(delistdate))|(listdate>=td(1,1,2011)& listdate<=td(31,12,2011))
keep if (listdate<td(1,1,2011)& delistdate>=td(1,1,2011))|(listdate<td(1,1,2011)& missing(delistdate))|(listdate>=td(1,1,2011)& listdate<=td(31,12,2011))

sort groupcoycode listdate
duplicates report groupcoycode if (listdate<td(1,1,2011)& delistdate>=td(1,1,2011))|(listdate<td(1,1,2011)& missing(delistdate))|(listdate>=td(1,1,2011)& listdate<=td(31,12,2011))
duplicates drop groupcoycode if (listdate<td(1,1,2011)& delistdate>=td(1,1,2011))|(listdate<td(1,1,2011)& missing(delistdate))|(listdate>=td(1,1,2011)& listdate<=td(31,12,2011)), force

count if (listdate<td(1,1,2011)& delistdate>=td(1,1,2011))|(listdate<td(1,1,2011)& missing(delistdate))
count if (listdate>=td(1,1,2011)& listdate<=td(31,12,2011))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

duplicates report asxcode
duplicates list asxcode
drop if asxcode=="X02"
drop if asxcode=="CNL" & groupcoycode =="vgmc1"
drop if asxcode=="GXN" & groupcoycode == "gnic1"
drop if asxcode=="MAU" & groupcoycode =="mauc1"
drop if asxcode=="OXX" & groupcoycode =="oxxc1"

replace asxcode="MGO" if asxcode=="MMC" & groupcoycode =="mgo1" 

merge 1:1 asxcode using "Financial_Data_2011"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2011SPPR_Financial.dta", replace
****************************************

**2012**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2012)& delistdate>=td(1,1,2012))|(listdate<td(1,1,2012)& missing(delistdate))|(listdate>=td(1,1,2012)& listdate<=td(31,12,2012))
keep if (listdate<td(1,1,2012)& delistdate>=td(1,1,2012))|(listdate<td(1,1,2012)& missing(delistdate))|(listdate>=td(1,1,2012)& listdate<=td(31,12,2012))

sort groupcoycode listdate
duplicates report groupcoycode if (listdate<td(1,1,2012)& delistdate>=td(1,1,2012))|(listdate<td(1,1,2012)& missing(delistdate))|(listdate>=td(1,1,2012)& listdate<=td(31,12,2012))
duplicates drop groupcoycode if (listdate<td(1,1,2012)& delistdate>=td(1,1,2012))|(listdate<td(1,1,2012)& missing(delistdate))|(listdate>=td(1,1,2012)& listdate<=td(31,12,2012)), force

count if (listdate<td(1,1,2012)& delistdate>=td(1,1,2012))|(listdate<td(1,1,2012)& missing(delistdate))
count if (listdate>=td(1,1,2012)& listdate<=td(31,12,2012))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

duplicates report asxcode
duplicates list asxcode
drop if asxcode=="X02"
drop if asxcode=="CNL" & groupcoycode =="vgmc1"
drop if asxcode=="GXN" & groupcoycode == "gnic1"
drop if asxcode=="MAU" & groupcoycode =="mauc1"
drop if asxcode=="OXX" & groupcoycode =="oxxc1"

replace asxcode="MGO" if asxcode=="MMC" & groupcoycode =="mgo1" 

merge 1:1 asxcode using "Financial_Data_2012"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2012SPPR_Financial.dta", replace
****************************************

**2013**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2013)& delistdate>=td(1,1,2013))|(listdate<td(1,1,2013)& missing(delistdate))|(listdate>=td(1,1,2013)& listdate<=td(31,12,2013))
keep if (listdate<td(1,1,2013)& delistdate>=td(1,1,2013))|(listdate<td(1,1,2013)& missing(delistdate))|(listdate>=td(1,1,2013)& listdate<=td(31,12,2013))

gsort groupcoycode +listdate
duplicates report groupcoycode if (listdate<td(1,1,2013)& delistdate>=td(1,1,2013))|(listdate<td(1,1,2013)& missing(delistdate))|(listdate>=td(1,1,2013)& listdate<=td(31,12,2013))
duplicates drop groupcoycode if (listdate<td(1,1,2013)& delistdate>=td(1,1,2013))|(listdate<td(1,1,2013)& missing(delistdate))|(listdate>=td(1,1,2013)& listdate<=td(31,12,2013)), force

count if (listdate<td(1,1,2013)& delistdate>=td(1,1,2013))|(listdate<td(1,1,2013)& missing(delistdate))
count if (listdate>=td(1,1,2013)& listdate<=td(31,12,2013))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

gsort asxcode +listdate
duplicates report asxcode
duplicates list asxcode
drop if asxcode=="BRB" & groupcoycode =="brbc2"
drop if asxcode=="CNL" & groupcoycode =="vgmc1"
drop if asxcode=="GXN" & groupcoycode == "gnic1"
drop if asxcode=="IVO" & groupcoycode == "bmcc2"
drop if asxcode=="MAU" & groupcoycode =="mauc1"
drop if asxcode=="OXX" & groupcoycode =="oxxc1"
drop if asxcode=="X02"

replace asxcode="MGO" if asxcode=="MMC" & groupcoycode =="mgo1" 

merge 1:1 asxcode using "Financial_Data_2013"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2013SPPR_Financial.dta", replace
****************************************

**2014**
clear
cd "$base"
use ".\data\SPPR2015_company.dta"
merge m:1 groupcoycode using ".\data\tcodemaker.dta"

count if (listdate<td(1,1,2014)& delistdate>=td(1,1,2014))|(listdate<td(1,1,2014)& missing(delistdate))|(listdate>=td(1,1,2014)& listdate<=td(31,12,2014))
keep if (listdate<td(1,1,2014)& delistdate>=td(1,1,2014))|(listdate<td(1,1,2014)& missing(delistdate))|(listdate>=td(1,1,2014)& listdate<=td(31,12,2014))

gsort groupcoycode +listdate
duplicates report groupcoycode if (listdate<td(1,1,2014)& delistdate>=td(1,1,2014))|(listdate<td(1,1,2014)& missing(delistdate))|(listdate>=td(1,1,2014)& listdate<=td(31,12,2014))
duplicates drop groupcoycode if (listdate<td(1,1,2014)& delistdate>=td(1,1,2014))|(listdate<td(1,1,2014)& missing(delistdate))|(listdate>=td(1,1,2014)& listdate<=td(31,12,2014)), force

count if (listdate<td(1,1,2014)& delistdate>=td(1,1,2014))|(listdate<td(1,1,2014)& missing(delistdate))
count if (listdate>=td(1,1,2014)& listdate<=td(31,12,2014))
count

drop _merge
rename tcode asxcode
replace asxcode = trim(asxcode)
replace asxcode = upper(asxcode)

gsort asxcode +listdate
duplicates report asxcode
duplicates list asxcode

drop if asxcode=="BRB" & groupcoycode =="brbc2"
drop if asxcode=="CNL" & groupcoycode =="vgmc1"
drop if asxcode=="GXN" & groupcoycode == "gnic1"
drop if asxcode=="LIT" & groupcoycode == "mwnc1"
drop if asxcode=="MAU" & groupcoycode =="mauc1"
drop if asxcode=="OXX" & groupcoycode =="oxxc1"
drop if asxcode=="PWN" & groupcoycode =="pwnc1"
drop if asxcode=="X02"

merge 1:1 asxcode using "Financial_Data_2014"

rename _merge _mergedummy2 
label variable _mergedummy2 "1 from SPPR, 2 from Aspect, 3 matched"

save ".\data\2014SPPR_Financial.dta", replace
****************************************


version 14.0
set more off
log cap close

**step1**
clear 
cd "$base"
import excel ".\data\Audit_Fee.xlsx", sheet("Audit_Fee") firstrow
*Data are provided for the relevant years 2006-2013 only, in folder data ".\data\Audit_Fee_2006-2013.xlsx"
*In the original data generation, we matched on all available years.
replace groupcoycode = trim(groupcoycode)
save ".\data\Audit_Fee.dta",replace
*********************************

**step2**
***2000***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2000
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode

drop if groupcoycode=="nim1" & ASXCODE == "NIM"
drop if groupcoycode=="spw1" & ASXCODE == "ATL"

save ".\data\Audit_Fee2000.dta", replace
*********************************

***2001***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2001
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode

drop if groupcoycode=="nim1" & ASXCODE == "NIM"
drop if groupcoycode=="spw1" & ASXCODE == "ATL"

save ".\data\Audit_Fee2001.dta", replace
*********************************

***2002***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2002
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode

drop if groupcoycode=="nim1" & ASXCODE == "NIM"
drop if groupcoycode=="spw1" & ASXCODE == "ATL"

save ".\data\Audit_Fee2002.dta", replace
*********************************

***2003***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2003
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode

drop if groupcoycode=="nim1" & ASXCODE == "NIM"
drop if groupcoycode=="pmd2" & ASXCODE == "PMD"
drop if groupcoycode=="spw1" & ASXCODE == "ATL"

save ".\data\Audit_Fee2003.dta", replace
*********************************

***2004***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2004
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode
drop if groupcoycode=="nim1" & ASXCODE == "NIM"

replace groupcoycode="mda1" if groupcoycode=="dcl1" 
replace groupcoycode="brn1" if groupcoycode=="avu1" 
drop if ASXCODE =="AVU"
replace ASXCODE ="AVU" if ASXCODE =="AVF"

save ".\data\Audit_Fee2004.dta", replace
*********************************

***2005***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2005
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode
drop if groupcoycode=="nim1" & ASXCODE == "NIM"
drop if groupcoycode=="sig1" & ASXCODE == "SIP"

replace groupcoycode="brn1" if groupcoycode=="avu1" 

save ".\data\Audit_Fee2005.dta", replace
*********************************

***2006***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2006
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode
drop if groupcoycode=="nim1" & ASXCODE == "NIM"
drop if groupcoycode=="zco1" & ASXCODE == "ZCO"

replace groupcoycode="brn1" if groupcoycode=="avu1" 

save ".\data\Audit_Fee2006.dta", replace
*********************************

***2007***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2007
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode
drop if groupcoycode=="nim1" & ASXCODE == "NIM"
drop if groupcoycode=="ogd1" & ASXCODE == "OGD"

replace groupcoycode="sig1" if groupcoycode=="awp2" 
replace groupcoycode="hti2" if groupcoycode=="hti1" 

save ".\data\Audit_Fee2007.dta", replace
*********************************

***2008***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2008
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode
drop if missing(groupcoycode)
drop if groupcoycode=="ahu1" & ASXCODE == "AHU"
drop if groupcoycode=="mbl1" & ASXCODE == "MBL"
drop if groupcoycode=="nim1" & ASXCODE == "NIM"
drop if missing(OPINION)

replace groupcoycode="sig1" if groupcoycode=="awp2" 
replace groupcoycode="cde1" if groupcoycode=="cxc1"
drop if groupcoycode=="esm1" 

save ".\data\Audit_Fee2008.dta", replace
*********************************

***2009***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2009
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode
drop if groupcoycode=="nim1" & ASXCODE == "NIM"
save ".\data\Audit_Fee2009.dta", replace
*********************************

***2010***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2010
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode

replace groupcoycode="ptx1" if groupcoycode=="tsf1"

save ".\data\Audit_Fee2010.dta", replace
*********************************

***2011***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2011
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode
drop if groupcoycode=="ceo1" & ASXCODE == "DRG"
drop if groupcoycode=="ear1" & ASXCODE == "EGP"
drop if groupcoycode=="mda2" & ASXCODE == "MDA"
drop if groupcoycode=="slv1" & ASXCODE == "SLV"
drop if missing(OPINION)

replace groupcoycode="ptx1" if groupcoycode=="tsf1"

save ".\data\Audit_Fee2011.dta", replace
*********************************

***2012***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2012
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode
drop if missing(OPINION)

replace groupcoycode="ptx1" if groupcoycode=="tsf1"
drop if groupcoycode=="gnic1"

save ".\data\Audit_Fee2012.dta", replace
*********************************

***2013***
clear
cd "$base"
use ".\data\Audit_Fee.dta"

keep if YEAR == 2013
drop if missing(OPINION)
count if missing(groupcoycode)
sort groupcoycode
duplicates report groupcoycode
duplicates list groupcoycode

replace groupcoycode="arr1" if ASXCODE=="LRG"
replace ASXCODE="LHB" if ASXCODE=="LRG"
replace groupcoycode="mun1" if ASXCODE=="MUN"
replace CONAME="MINERA GOLD LIMITED" if ASXCODE=="MUN"
drop if groupcoycode=="mrx1" & ASXCODE == "CAD"

replace groupcoycode="ptx1" if groupcoycode=="tsf1"
replace groupcoycode="lpl1" if groupcoycode=="sxs1"
drop if ASXCODE =="SGY"

save ".\data\Audit_Fee2013.dta", replace
*********************************










version 14.0
set more off
log cap close

***2004***
clear
cd "$base"
use ".\data\2004SPPR_Financial.dta"

keep if _mergedummy2 == 1 | _mergedummy2 == 3 
merge 1:1 groupcoycode using ".\data\Audit_Fee2004.dta" 

rename _merge _mergedummy4
label variable _mergedummy4 "1 from SPPR, 2 from UNSW Audit, 3 matched"

save ".\data\2004SPPR_Financial_Audit.dta", replace
******************************************************

***2005***
clear
cd "$base"
use ".\data\2005SPPR_Financial.dta"

keep if _mergedummy2 == 1 | _mergedummy2 == 3 
merge 1:1 groupcoycode using ".\data\Audit_Fee2005.dta" 

rename _merge _mergedummy4
label variable _mergedummy4 "1 from SPPR, 2 from UNSW Audit, 3 matched"

save ".\data\2005SPPR_Financial_Audit.dta", replace
******************************************************

***2006***
clear
cd "$base"
use ".\data\2006SPPR_Financial.dta"

keep if _mergedummy2 == 1 | _mergedummy2 == 3 
merge 1:1 groupcoycode using "Audit_Fee2006.dta" 

rename _merge _mergedummy4
label variable _mergedummy4 "1 from SPPR, 2 from UNSW Audit, 3 matched"

save ".\data\2006SPPR_Financial_Audit.dta", replace
******************************************************

***2007***
clear
cd "$base"
use ".\data\2007SPPR_Financial.dta"

keep if _mergedummy2 == 1 | _mergedummy2 == 3 
merge 1:1 groupcoycode using "Audit_Fee2007.dta" 

rename _merge _mergedummy4
label variable _mergedummy4 "1 from SPPR, 2 from UNSW Audit, 3 matched"

save ".\data\2007SPPR_Financial_Audit.dta", replace
******************************************************

***2008***
clear
cd "$base"
use ".\data\2008SPPR_Financial.dta"

keep if _mergedummy2 == 1 | _mergedummy2 == 3 
merge 1:1 groupcoycode using "Audit_Fee2008.dta" 

rename _merge _mergedummy4
label variable _mergedummy4 "1 from SPPR, 2 from UNSW Audit, 3 matched"

save ".\data\2008SPPR_Financial_Audit.dta", replace
******************************************************

***2009***
clear
cd "$base"
use ".\data\2009SPPR_Financial.dta"

keep if _mergedummy2 == 1 | _mergedummy2 == 3 
merge 1:1 groupcoycode using "Audit_Fee2009.dta" 

rename _merge _mergedummy4
label variable _mergedummy4 "1 from SPPR, 2 from UNSW Audit, 3 matched"

save ".\data\2009SPPR_Financial_Audit.dta", replace
******************************************************

***2010***
clear
cd "$base"
use ".\data\2010SPPR_Financial.dta"

keep if _mergedummy2 == 1 | _mergedummy2 == 3 
merge 1:1 groupcoycode using "Audit_Fee2010.dta" 

rename _merge _mergedummy4
label variable _mergedummy4 "1 from SPPR, 2 from UNSW Audit, 3 matched"

save ".\data\2010SPPR_Financial_Audit.dta", replace
******************************************************

***2011***
clear
cd "$base"
use ".\data\2011SPPR_Financial.dta"

keep if _mergedummy2 == 1 | _mergedummy2 == 3 
merge 1:1 groupcoycode using "Audit_Fee2011.dta" 

rename _merge _mergedummy4
label variable _mergedummy4 "1 from SPPR, 2 from UNSW Audit, 3 matched"

save ".\data\2011SPPR_Financial_Audit.dta", replace
******************************************************

***2012***
clear
cd "$base"
use ".\data\2012SPPR_Financial.dta"

keep if _mergedummy2 == 1 | _mergedummy2 == 3 
merge 1:1 groupcoycode using "Audit_Fee2012.dta" 

rename _merge _mergedummy4
label variable _mergedummy4 "1 from SPPR, 2 from UNSW Audit, 3 matched"

save ".\data\2012SPPR_Financial_Audit.dta", replace
******************************************************

***2013***
clear
cd "$base"
use ".\data\2013SPPR_Financial.dta"

keep if _mergedummy2 == 1 | _mergedummy2 == 3 
merge 1:1 groupcoycode using "Audit_Fee2013.dta" 

rename _merge _mergedummy4
label variable _mergedummy4 "1 from SPPR, 2 from UNSW Audit, 3 matched"

save ".\data\2013SPPR_Financial_Audit.dta", replace
******************************************************

version 14.0
set more off
log cap close

**FY15********************************************************
clear
cd "$base"
import excel ".\data\prices15.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices15.dta", replace
*****************************************************************

**FY14********************************************************
clear
cd "$base"
import excel ".\data\prices14.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices14.dta", replace
*****************************************************************

**FY13********************************************************
clear
cd "$base"
import excel ".\data\prices13.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices13.dta", replace
*****************************************************************

**FY12********************************************************
clear
cd "$base"
import excel ".\data\prices12.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices12.dta", replace
*****************************************************************

**FY11********************************************************
clear
cd "$base"
import excel ".\data\prices11.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices11.dta", replace
*****************************************************************

**FY10********************************************************
clear
cd "$base"
import excel ".\data\prices10.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices10.dta", replace
*****************************************************************

**FY09********************************************************
clear
cd "$base"
import excel ".\data\prices09.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices09.dta", replace
*****************************************************************

**FY08********************************************************
clear
cd "$base"
import excel ".\data\prices08.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices08.dta", replace
*****************************************************************

**FY07********************************************************
clear
cd "$base"
import excel ".\data\prices07.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices07.dta", replace
*****************************************************************

**FY06********************************************************
clear
cd "$base"
import excel ".\data\prices06.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices06.dta", replace
*****************************************************************

**FY05********************************************************
clear
cd "$base"
import excel ".\data\prices05.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices05.dta", replace
*****************************************************************

**FY04********************************************************
clear
cd "$base"
import excel ".\data\prices04.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices04.dta", replace
*****************************************************************

**FY03********************************************************
clear
cd "$base"
import excel ".\data\prices03.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices03.dta", replace
*****************************************************************

**FY02********************************************************
clear
cd "$base"
import excel ".\data\prices02.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices02.dta", replace
*****************************************************************

**FY01********************************************************
clear
cd "$base"
import excel ".\data\prices01.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices01.dta", replace
*****************************************************************

**FY00********************************************************
clear
cd "$base"
import excel ".\data\prices00.xlsx", sheet("prices") firstrow

sort grouptcode ltdmo
duplicates report grouptcode ltdmo
duplicates list grouptcode ltdmo

tostring ltdmo, replace
gen id2 = grouptcode+"_"+ltdmo
duplicates report id2

save ".\data\prices00.dta", replace
*****************************************************************

version 14.0
set more off
log cap close

**2015*****************************************************
clear
cd "$base"
use ".\data\2015SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices15.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2015SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2014*****************************************************
clear
cd "$base"
use ".\data\2014SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices14.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2014SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2013*****************************************************
clear
cd "$base"
use ".\data\2013SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices13.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2013SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2012*****************************************************
clear
cd "$base"
use ".\data\2012SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices12.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2012SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2011*****************************************************
clear
cd "$base"
use ".\data\2011SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices11.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data2011SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2010*****************************************************
clear
cd "$base"
use ".\data\2010SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices10.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2010SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2009*****************************************************
clear
cd "$base"
use ".\data\2009SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices09.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2009SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2008*****************************************************
clear
cd "$base"
use ".\data\2008SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices08.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2008SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2007*****************************************************
clear
cd "$base"
use ".\data\2007SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices07.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2007SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2006*****************************************************
clear
cd "$base"
use ".\data\2006SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices06.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2006SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2005*****************************************************
clear
cd "$base"
use ".\data\2005SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices05.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2005SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2004*****************************************************
clear
cd "$base"
use ".\data\2004SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices04.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2004SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2003*****************************************************
clear
cd "$base"
use ".\data\2003SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices03.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2003SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2002*****************************************************
clear
cd "$base"
use ".\data\2002SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices02.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2002SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2001*****************************************************
clear
cd "$base"
use ".\data\2001SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices01.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2001SPPR_Financial_Audit_Prices.dta", replace
***************************************************************

**2000*****************************************************
clear
cd "$base"
use ".\data\2000SPPR_Financial_Audit.dta"

gen date4 = month(date3)
tostring date4, replace
gen id2 = groupcoycode+"_"+date4

duplicates report id2
merge 1:1 id2 using ".\data\prices00.dta"

keep if _merge ==1 | _merge ==3

rename _merge _mergedummy6
label variable _mergedummy6 "1 from SPPR, 2 from SPPRprices, 3 matched"

count
duplicates report groupcoycode

save ".\data\2000SPPR_Financial_Audit_Prices.dta", replace
***************************************************************






version 14.0
set more off
log cap close

***2000***
clear
cd "$base"
import excel ".\data\Price2000.xlsx", sheet("Price2000") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 1999

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2000.dta", replace
************************************

***2001***
clear
cd "$base"
import excel ".\data\Price2001.xlsx", sheet("Price2001") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2000 

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2001.dta", replace
************************************

***2002***
clear
cd "$base"
import excel ".\data\Price2002.xlsx", sheet("Price2002") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2001 

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2002.dta", replace
************************************

***2003***
clear
cd "$base"
import excel ".\data\Price2003.xlsx", sheet("Price2003") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2002 

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2003.dta", replace
************************************

***2004***
clear
cd "$base"
import excel ".\data\Price2004.xlsx", sheet("Price2004") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2003 

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2004.dta", replace
************************************

***2005***
clear
cd "$base"
import excel ".\data\Price2005.xlsx", sheet("Price2005") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2004 

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2005.dta", replace
************************************

***2006***
clear
cd "$base"
import excel ".\data\Price2006.xlsx", sheet("Price2006") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
 label variable Annual "annual return for the company year"
 
drop if ltdyr == 2005

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2006.dta", replace
************************************

***2007***
clear
cd "$base"
import excel ".\data\Price2007.xlsx", sheet("Price2007") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2006 

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2007.dta", replace
************************************

***2008***
clear
cd "$base"
import excel ".\data\Price2008.xlsx", sheet("Price2008") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2007 

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2008.dta", replace
************************************

***2009***
clear
cd "$base"
import excel ".\data\Price2009.xlsx", sheet("Price2009") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2008

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2009.dta", replace
************************************

***2010***
clear
cd "$base"
import excel ".\data\Price2010.xlsx", sheet("Price2010") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2009
tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2010.dta", replace
************************************

***2011***
clear
cd "$base"
import excel ".\data\Price2011.xlsx", sheet("Price2011") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2010

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2011.dta", replace
************************************

***2012***
clear
cd "$base"
import excel ".\data\Price2012.xlsx", sheet("Price2012") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2011

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2012.dta", replace
************************************

***2013***
clear
cd "$base"
import excel ".\data\Price2013.xlsx", sheet("Price2013") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2012

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2013.dta", replace
************************************

***2014***
clear
cd "$base"
import excel ".\data\Price2014.xlsx", sheet("Price2014") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2013

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2014.dta", replace
************************************

***2015***
clear
cd "$base"
import excel ".\data\Price2015.xlsx", sheet("Price2015") firstrow

encode grouptcode, gen(grouptcode1)
xtset grouptcode1 ltdserial
gen monthly_return=ln(pricerelative)
gen Annual=(exp(monthly_return+L.monthly_return+L2.monthly_return+L3.monthly_return+L4.monthly_return+L5.monthly_return+L6.monthly_return+L7.monthly_return+L8.monthly_return+L9.monthly_return+L10.monthly_return+L11.monthly_return))-1
label variable Annual "annual return for the company year"

drop if ltdyr == 2014

tostring ltdmo, replace
gen id1 = grouptcode+"_"+ltdmo

xtset, clear 
keep id1 Annual

save ".\data\Price2015.dta", replace
************************************



version 14.0
set more off
log cap close

***2000***
clear
cd "$base"
use ".\data\2000SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2000.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2000
order year_SPPR

save ".\data\2000SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2001***
clear
cd "$base"
use ".\data\2001SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2001.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2001
order year_SPPR

save ".\data\2001SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2002***
clear
cd "$base"
use ".\data\2002SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2002.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2002
order year_SPPR

save ".\data\2002SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2003***
clear
cd "$base"
use ".\data\2003SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2003.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2003
order year_SPPR

save ".\data\2003SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2004***
clear
cd "$base"
use ".\data\2004SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2004.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2004
order year_SPPR

save ".\data\2004SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2005***
clear
cd "$base"
use ".\data\2005SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2005.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2005
order year_SPPR

save ".\data\2005SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2006***
clear
cd "$base"
use ".\data\2006SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2006.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2006
order year_SPPR

save ".\data\2006SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2007***
clear
cd "$base"
use ".\data\2007SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2007.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2007
order year_SPPR

save ".\data\2007SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2008***
clear
cd "$base"
use ".\data\2008SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2008.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2008
order year_SPPR

save ".\data\2008SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2009***
clear
cd "$base"
use ".\data\2009SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2009.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2009
order year_SPPR

save ".\data\2009SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2010***
clear
cd "$base"
use ".\data\2010SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2010.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2010
order year_SPPR

save ".\data\2010SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2011***
clear
cd "$base"
use ".\data\2011SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2011.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2011
order year_SPPR

save ".\data\2011SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2012***
clear
cd "$base"
use ".\data\2012SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2012.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2012
order year_SPPR

save ".\data\2012SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2013***
clear
cd "$base"
use ".\data\2013SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2013.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2013
order year_SPPR

save ".\data\2013SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2014***
clear
cd "$base"
use ".\data\2014SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2014.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2014
order year_SPPR

save ".\data\2014SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************

***2015***
clear
cd "$base"
use ".\data\2015SPPR_Financial_Audit_Prices.dta"

gen Aspect_month = month(date3)
tostring Aspect_month, replace
gen id1 = groupcoycode+"_"+Aspect_month
label variable id1 "groupcoycode+month, used for merging with price data"

merge 1:1 id1 using "Price2015.dta" 

drop if _merge==2

rename _merge _mergedummy8
label variable _mergedummy8 "1 from SPPR, 2 from Annual Return, 3 matched"

gen year_SPPR = 2015
order year_SPPR

save ".\data\2015SPPR_Financial_Audit_Prices_AnnualReturn.dta", replace
************************************************************


version 14.0
set more off
log cap close

clear
cd "$base"

**step 1 Append Data from step 8 for years 2000 to 2013**
clear
cd "$base"
use ".\data\2000SPPR_Financial_Audit_Prices_AnnualReturn.dta"
append using ".\data\2001SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2002SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2003SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2004SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2005SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2006SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2007SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2008SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2009SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2010SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2011SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2012SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2013SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2014SPPR_Financial_Audit_Prices_AnnualReturn.dta", force
append using ".\data\2015SPPR_Financial_Audit_Prices_AnnualReturn.dta", force

table year_SPPR, row
table _mergedummy2
table _mergedummy4
table _mergedummy6
table _mergedummy8
drop if _mergedummy4 == 2

save ".\data\Final_step1.dta", replace
***************************************************************

**step 2**
clear
cd "$base"
use ".\data\Final_step1.dta"

keep year_SPPR groupcoycode asxcode fullcoyname YEAR SIRCAsectorcode gicsindustrycode YEAREND  OPINION BIG4 AUDITOR PARTNER OFFICE OPDATE AUDFEE ARFEE RP_AUDFEE OA_AUDFEE NASFEE TOTAUDITFEE TOTAUDITFEE_INC_OA tcode_3 minlistdate maxdelistdate securitytype date value2600 value4990 value4995 value5000 value5010 value5020 value5028 value5029 value5030 value5039 value5040 value5090 value6000 value6010 value6020 value6030 value6040 value7005 value7010 value7070 value7090 value8010 value8012 value8020 value8035 value8036 value9100 value280 value103 OZSUB FXSUB TOTSUB totalcapital _mergedummy2 _mergedummy4 _mergedummy6 _mergedummy8 prelim foreign CURRENCY YEAR OFFICE FINPER securitytype Annual value910 

gen year_ye = year(YEAREND)

gen month_ye = month(YEAREND)

order year_SPPR groupcoycode asxcode fullcoyname YEAR SIRCAsectorcode gicsindustrycode YEAREND year_ye month_ye OPINION BIG4 AUDITOR PARTNER OFFICE OPDATE AUDFEE ARFEE RP_AUDFEE OA_AUDFEE NASFEE TOTAUDITFEE TOTAUDITFEE_INC_OA tcode_3 minlistdate maxdelistdate securitytype date value2600 value4990 value4995 value5000 value5010 value5020 value5028 value5029 value5030 value5039 value5040 value5090 value6000 value6010 value6020 value6030 value6040 value7005 value7010 value7070 value7090 value8010 value8012 value8020 value8035 value8036 value9100 value280 value103 value910 totalcapital _mergedummy2 _mergedummy4 _mergedummy6 _mergedummy8 prelim foreign CURRENCY YEAR OFFICE FINPER securitytype Annual

label variable value4990 "Cash"
label variable value4995 "Debtors"
label variable value5000 "Total Current Inventory"
label variable value5010 "Total Short Term Investment"
label variable value5020 "Total Current Assets"
label variable value5028 "Total Debtors"
label variable value5029 "Total Inventory"
label variable value5030 "Total Fixed Assets"
label variable value5039 "Total Accumulated Depreciation"
label variable value5040 "Total Long Term Investments"
label variable value5090 "Total Assets"
label variable value6000 "Current Debt"
label variable value6010 "Total Current Liabilities"
label variable value6020 "Non Current Debt"
label variable value6030 "Total Non-Current Liabilities"
label variable value6040 "Total Liabilities"
label variable value7005 "Retained Profits/(losses)"
label variable value7010 "Total Shareholders Equity"
label variable value7070 "Trading Revenue"
label variable value7090 "Total Revenue"
label variable value8010 "Depreciation and Amortisation"
label variable value8012 "EBIT"
label variable value8020 "Reported NPAT before abnormals"
label variable value8035 "Tax Expense"
label variable value8036 "Reported NPAT after abnormals"
label variable value9100 "Net Cash Flow from Operations"
label variable value280 "B/S Outside Equity Interests"
label variable value103 "P/L  Outside Equity Interests"
label variable value910 "P/L Dividends Paid"

replace AUDITOR = trim(AUDITOR)

tostring year_SPPR, replace
gen id = groupcoycode + year_SPPR
destring year_SPPR, replace

save ".\data\Final_step2.dta", replace


*************************************************************************
clear
cd "$base"
import excel ".\data\Standardized partner audit firm and office data_2005-2013.xlsx", sheet("Sheet1") firstrow

replace STDAUDITOR = trim(STDAUDITOR)
replace PARTNER = trim(PARTNER)
replace OFFICE = trim(OFFICE)

rename * Y_*
rename Y_YEAR YEAR
rename Y_groupcoycode groupcoycode
tostring YEAR, replace
gen id = groupcoycode + YEAR

duplicates report id
duplicates list id
duplicates drop id, force

drop YEAR groupcoycode


save ".\data\standardized_partnername.dta", replace
*************************************************************************




*************************************************************************
clear
cd "$base"
use ".\data\Final_step2.dta"

merge 1:1 id using ".\data\standardized_partnername.dta"

order Y_STDAUDITOR, after(AUDITOR) 
order Y_BIG4, after(BIG4)   
order Y_PARTNER, after(PARTNER) 
order Y_OFFICE, after(OFFICE)

drop if _merge == 2
drop _merge

table Y_STDAUDITOR
replace Y_STDAUDITOR = "arrack ST Investments Limited" if Y_STDAUDITOR == "Barrack St Investments Limited"
replace Y_STDAUDITOR = "PricewaterhouseCoopers" if Y_STDAUDITOR == "Pricewaterhousecoopers"

table Y_PARTNER

drop BIG4 AUDITOR PARTNER OFFICE
rename Y_BIG4 BIG4 
rename Y_STDAUDITOR AUDITOR
rename Y_PARTNER PARTNER 
rename Y_OFFICE OFFICE

replace BIG4 = . if missing(AUDITOR)

table AUDITOR

table BIG4 if inlist(AUDITOR, "Deloitte Touche", "Ernst and Young", "KPMG", "PricewaterhouseCoopers"), row
table BIG4 if !inlist(AUDITOR, "Deloitte Touche", "Ernst and Young", "KPMG", "PricewaterhouseCoopers"), row

count if BIG4 == 0 & inlist(AUDITOR, "Deloitte Touche", "Ernst and Young", "KPMG", "PricewaterhouseCoopers")
replace BIG4 = 1 if BIG4 == 0 & inlist(AUDITOR, "Deloitte Touche", "Ernst and Young", "KPMG", "PricewaterhouseCoopers")

count if BIG4 == 1 & !inlist(AUDITOR, "Deloitte Touche", "Ernst and Young", "KPMG", "PricewaterhouseCoopers")
count if AUDITOR == "Arthur Andersen"
replace BIG4 = 0 if id == "sky12007"
replace BIG4 = 0 if AUDITOR == "Australian National Audit Office"

save ".\data\Final_step2.2.dta", replace

*************************************************************************




**step 3***********************************************************************************
clear
cd "$base"
use ".\data\Final_step2.2.dta"

drop id
rename * l_*
gen year_SPPR = l_year_SPPR +1
tostring year_SPPR, replace
gen id = l_groupcoycode + year_SPPR
drop year_SPPR

save ".\data\Final_step2_l1.dta", replace
*******


******
clear
cd "$base"
use ".\data\Final_step2.2.dta"

drop id
rename * l2_*
gen year_SPPR = l2_year_SPPR + 2
tostring year_SPPR, replace
gen id = l2_groupcoycode + year_SPPR
drop year_SPPR

save ".\data\Final_step2_l2.dta", replace
*******

******
clear
cd "$base"
use ".\data\Final_step2.2.dta"
table year_SPPR
drop if year_SPPR == 2004 | year_SPPR == 2005 | year_SPPR==2002 | year_SPPR==2003

duplicates report id
merge 1:1 id using ".\data\Final_step2_l1.dta"
keep if _merge ==1 | _merge ==3
rename _merge _mergedummy10_l1
label variable _mergedummy10_l1 "1=cannot merged with last year data, 3=merged"

merge 1:1 id using ".\data\Final_step2_l2.dta"
keep if _merge ==1 | _merge ==3
rename _merge _mergedummy10_l2
label variable _mergedummy10_l2 "1=cannot merged with second last year data, 3=merged"


table year_SPPR, row
count if _mergedummy2 ==3 & _mergedummy4 ==3 & _mergedummy6 ==3 & _mergedummy8 ==3 & _mergedummy10_l1 ==3 & _mergedummy10_l2 ==3 
table year_SPPR if _mergedummy2 ==3 & _mergedummy4 ==3 & _mergedummy6 ==3 & _mergedummy8 ==3 & _mergedummy10_l1 ==3 & _mergedummy10_l2 ==3, row

save ".\data\Final_step3.dta", replace
**************************************************************************************************

**step 4**
clear
cd "$base"
use ".\data\Final_step3.dta"

table year_SPPR, row

***Aspect Financial Data********************
table _mergedummy2, row
count if missing(_mergedummy2)
table year_SPPR if _mergedummy2 == 1, row

table _mergedummy10_l1, row 

table _mergedummy10_l2, row

count if _mergedummy2==3 & _mergedummy10_l1==3 & _mergedummy10_l2==3
table year_SPPR if _mergedummy2==3 & _mergedummy10_l1==3 & _mergedummy10_l2==3, row
keep if _mergedummy2==3 & _mergedummy10_l1==3 & _mergedummy10_l2==3
*****************************

table prelim year_SPPR, row column 
count if missing(prelim)
drop if prelim == "yes"

table foreign year_SPPR, row column
count if missing(foreign)
drop if foreign == "f" | foreign == "x"

table CURRENCY year_SPPR, row column
count if missing(CURRENCY) //48 observations missing, go back to collect!
table CURRENCY year_SPPR if CURRENCY !="AUD", row
drop if CURRENCY =="CAD" | CURRENCY =="EUR" | CURRENCY =="EURO"| CURRENCY =="GBP" | CURRENCY =="HKD" | CURRENCY =="NZL" | CURRENCY =="SGP" | CURRENCY =="SINGDOLLAR" | CURRENCY =="USD"
drop if CURRENCY !="AUD"

replace OFFICE=trim(OFFICE)
table OFFICE, row

drop if inlist(OFFICE, "Auckland", "Auckland, NZL", "Boroko, PNG", "Boston", "Boston, USA", "Cambridge, UK", "Cape Town, South Africa", "Christchurch, NZL") 
drop if inlist(OFFICE, "Douglas(ISLE OF MAN)", "Douglas, IOM", "Edmonton, USA", "Fort Lauderdale, US", "Guildford, UK", "Harare, ZIM", "Harrisburg, US", "Hartford, US")
drop if inlist(OFFICE, "Hong Kong", "Irvine, California", "Isle of Man, UK", "Jakarta, IND", "Johannesburg, SAF", "Kuala Lumpur, MAL", "London", "London, UK", "Minneapolis, Minnesota")
drop if inlist(OFFICE, "Minneapolis,USA", "Montreal, Canada", "New York", "New York, USA", "Not Disclosed", "Ontario, Canada", "Orange County, USA", "Pittsburgh", "Pittsburgh (Pennsylvania)")
drop if inlist(OFFICE, "Pittsburgh, USA", "Port Moresby", "Port Moresby, PNG", "Port Moresby, PNG  and Sydney", "Regina, CAN", "San Diego", "San Diego, California", "San Diego, USA")
drop if inlist(OFFICE, "Singapore", "Toronto", "Toronto, CAN", "Toronto, Canada", "Vancouver Canada", "Vancouver, CAN", "Vancouver, Canada", "Wellington, NZ", "Wellington, NZL")
drop if inlist(OFFICE, "Amsterdam, NLD", "Arizona, USA", "Athens, GRE", "Berkshire, UK", "Brisbane and London", "Denver, USA", "Edinburgh, UK")
drop if inlist(OFFICE, "Glasglow, UK", "Indonesia", "Lae, PNG")
drop if inlist(OFFICE, "London and Brisbane", "London and Melbourne", "Los Angeles, USA", "Michigan, USA", "Ontario,CAN", "Perth & London", "Phoenix, USA")
drop if inlist(OFFICE,"Port Moresby, PNG and Sydney","San Francisco, USA")

table OFFICE, row

table FINPER year_SPPR if FINPER !=12, row col
count if missing(FINPER)
drop if !missing(FINPER) & FINPER !=12

***Exclude financial services
*create gicssectorcode
egen indsecgroup = group(SIRCAsectorcode)
table indsecgroup YEAR
table indsecgroup SIRCAsectorcode
drop if SIRCAsectorcode == 60
drop if SIRCAsectorcode == 40
drop if SIRCAsectorcode == 70

replace securitytype = trim(securitytype)
table securitytype

table YEAR

duplicates report groupcoycode YEAREND
duplicates list groupcoycode YEAREND

duplicates drop groupcoycode YEAREND, force

save ".\data\Final_step4.dta", replace
*******************************************************


***Drop PRINC==0




