********************************************************************************
* Sexism, Culture, and Firm Value: Evidence from the Harvey Weinstein Scandal  
*    and the #MeToo Movement												   
* Journal of Accounting Research                                               
*																			   
* Lins, Roth, Servaes, and Tamayo (2024)									   
* April 2024
*
* Code for Data and Sample Creation	
* Stata/MP 18.0 for Windows (64-bit x86-64), Revision 14 Feb 2024														   
********************************************************************************

	cd c:\LRST
	log using "LRST-data-logfile.smcl", replace
	
********************************************************************************
* A1. Create female variables, most recent prior to October 5, 2017 
********************************************************************************

	clear all
	set more off

	// Create fiscal year date data
	use "raw\compustat-2010-2017", clear  // Compustat, downloaded 2018-10-19
	keep gvkey fyear datadate lpermno
	
	gen permno1 = lpermno
	bysort gvkey fyear: gen permno2 = lpermno[_n+1]
	bysort gvkey fyear: gen permno3 = lpermno[_n+2]
	drop lpermno
	
	bysort gvkey fyear: keep if _n==1
	duplicates report gvkey fyear
	
	save "compiled\fyear-datadate", replace

	// Prepare gender variables from 2024 Execucomp data
	use "raw\execucomp-2010-2022", clear  // Execucomp, downloaded 2024-01-17
	
	rename *, lower
	keep execid nameprefix gender
	
	bysort execid gender: keep if _n==1
	duplicates report execid
	
	tab nameprefix gender
	
	rename nameprefix nameprefix_2024
	rename gender gender_2024
	
	save "compiled\gender-execid-2024", replace
	
	// Keep most recent fiscal year prior to Oct 5, 2017   
	use "raw\execucomp", clear  // Execucomp, downloaded 2018-09-15
	
	gen fyear = year 	
	joinby fyear gvkey using "compiled\fyear-datadate", unma(ma)
	drop _merge
	
	drop if mi(datadate)
	keep if datadate<td(1oct2017)

	egen max_datadate = max(datadate), by(gvkey)
	keep if datadate==max_datadate
	drop max_datadate
	keep if year==2016 | year==2017
	
	// Create female variables
	drop if mi(execrankann)
	egen max_execrankann = max(execrankann), by(gvkey)
	drop if max_execrankann<5  
	drop if execrankann>5
		
	gen ceo = (ceoann=="CEO")
	gen cfo = (cfoann=="CFO")

	// Fix Execucomp gender variable classification errors
	tab nameprefix gender 
	
	count
	joinby execid using "compiled\gender-execid-2024", unma(ma)
	count
	tab _m  // 75 unmatched, check manually
	rename _merge check_gender_manually

	replace gender = gender_2024 if gender~=gender_2024 & !mi(gender_2024)
	replace nameprefix = nameprefix_2024 if nameprefix~=nameprefix_2024 & !mi(nameprefix_2024)

	* Manual checks 1
	*browse execid nameprefix gender exec_fullname if check_gender_manually==1
	replace gender = "FEMALE" if execid=="51185"  // Julie O'Neill, MBA

	* Manual checks 2
	tab nameprefix gender // 5 Mr. as Female, check manually
	*browse execid nameprefix gender exec_fullname coname if nameprefix=="Mr." & gender=="FEMALE"
	replace gender = "MALE" if execid=="33636"  // Mark Alan Rossi
	replace gender = "MALE" if execid=="40900"  // Parveen Kakar
	replace gender = "MALE" if execid=="32782"  // Edmund DiSanto
	replace gender = "MALE" if execid=="36423"  // Emory M. Wright
	replace gender = "MALE" if execid=="47634"  // Raphael S. Pascaud

	gen female = (gender=="FEMALE") if !mi(gender)
	gen female_execdir = female * execdir
	gen female_ceo = ceo * female
	gen female_cfo = cfo * female

	egen num_execdir = sum(execdir), by(gvkey)
	egen num_exec = count(execdir), by(gvkey)
	egen num_female_exec = sum(female), by(gvkey)
	egen num_female_execdir = sum(female_execdir), by(gvkey)
	egen has_female_exec = max(female), by(gvkey)
	egen has_female_ceo = max(female_ceo), by(gvkey)
	egen has_female_cfo = max(female_cfo), by(gvkey)
	egen has_female_execdir = max(female_execdir), by(gvkey)

	duplicates drop gvkey, force
	
	gen female_exec_share = num_female_exec / num_exec
	gen female_dir_share = num_female_execdir / num_execdir

	tab num_female_exec
	gen has_female_1 = (num_female_exec==1)
	gen has_female_2 = (num_female_exec==2)
	gen has_female_34 = (num_female_exec==3 | num_female_exec==4)
	gen has_female_234 = (num_female_exec==3 | num_female_exec==4 | num_female_exec==2)
	
	keep gvkey cusip fyear datadate female_exec_share female_dir_share permno* has_female_exec has_female_ceo has_female_cfo has_female_execdir has_female_1 has_female_2 has_female_34 has_female_234
	
	// Manually check firms with multiple PERMNOs
	gen permno = permno1
	replace permno = 86242 if gvkey=="002124"
	replace permno = 61516 if gvkey=="002220"
	replace permno = 29946 if gvkey=="002435"
	replace permno = 69796 if gvkey=="002710"
	replace permno = 59248 if gvkey=="003505"
	replace permno = 83233 if gvkey=="005338"
	replace permno = 41217 if gvkey=="005523"
	replace permno = 86313 if gvkey=="005763"
	replace permno = 32942 if gvkey=="005764"
	replace permno = 47379 if gvkey=="006379"
	replace permno = 52708 if gvkey=="006669"
	replace permno = 52090 if gvkey=="007146"
	replace permno = 61807 if gvkey=="007549"
	replace permno = 82279 if gvkey=="008582"
	replace permno = 82924 if gvkey=="011499"
	replace permno = 90441 if gvkey=="012886"
	replace permno = 76226 if gvkey=="013714"
	replace permno = 13963 if gvkey=="018043"
	replace permno = 91815 if gvkey=="025536"
	replace permno = 88372 if gvkey=="120301"
	replace permno = 14542 if gvkey=="160329"
	replace permno = 90805 if gvkey=="164296"
	replace permno = 15980 if gvkey=="165052"
	replace permno = 91063 if gvkey=="165675"
	
	compress
	save "compiled\firm-female-2017", replace
	
********************************************************************************
* A2. Create firm controls
********************************************************************************
	
	use "raw\compustat-2010-2017", clear  // Compustat, downloaded 2018-10-19
	 
	gen lnat = ln(at)
	gen ppe = ppent / at
	gen lev = (dltt + dlc) / at
	gen cash = che / at
	gen rnd = xrd / at
	replace rnd = 0 if mi(rnd)
	gen rnd_sales = xrd / sale
	replace rnd_sales = 0 if mi(rnd_sales)
	gen q = (csho * prcc_f + at - ceq) / at
	gen mb = csho * prcc_f / ceq
	gen roa = ebit / at
	gen oprofit = oibdp / at
	gen invest = capx / at
	gen adexp = xad / sale
	replace adexp = 0 if mi(adexp)
	
	destring sic, force replace
	gen sic2 = floor(sic/100)
	sicff sic, ind(49) gen(ff49)
	sicff sic, ind(30) gen(ff30)

	gen emp_at = 1000*emp / at
	gen emp_ppe = 1000*emp / ppent
	gen emp_cap = 1000*emp / (csho * prcc_f + dltt + dlc)
	gen sales_emp = sale / (1000*emp)
	foreach x in rnd_sales emp_at emp_ppe emp_cap adexp sales_emp {
		egen `x'_sic = mean(`x'), by(sic fyear) 
		egen `x'_sic2 = mean(`x'), by(sic2 fyear)
	}		
	
	keep gvkey cusip lpermno conm datadate lnat sic2 ppe lev cash rnd rnd_* sales_* q mb roa oprofit invest sic ff30 ff49 emp sale ebit emp_* ggroup gind gsector gsubind adexp* 
	
	duplicates report gvkey datadate, force
	
	// Manuel checkes
	/*sort gvkey datadate lpermno
	duplicates tag gvkey datadate, gen(tag)
	browse if tag>0*/
	count
	joinby lpermno datadate using "raw\gvkey-duplicates-checked", unma(ma)  // manually checked duplciates
	count
	drop _merge
	drop if drop==1
		
	keep if datadate<td(1sep2017)   
	gen diff = td(1oct2017) - datadate
	egen min_diff = min(diff), by(gvkey)
	keep if diff==min_diff
	duplicates report gvkey
	drop min_diff diff
	
	duplicates report gvkey
	duplicates report lpermno
	
	compress	
	save "compiled\firm-controls", replace
	
	
********************************************************************************
* A3. Create abnormal returns and CARs for events
********************************************************************************
	
	// Create daily returns
	use "compiled\firm-female-2017", clear
	keep permno
	
	joinby permno using "raw\crsp-jun-2014-jun-2018"  // CRSP, downloaded 2018-09-07
	
	save "compiled\ar-crsp", replace
	
	// Estimate market model abnormal returns
	use "compiled\ar-crsp", clear
	
	drop if date<td(1sep2016)
	gen est = (date>=td(1sep2016) & date<td(1sep2017))
	egen estlen = sum(est), by(permno)
	keep if estlen>250
	
	egen id = group(permno)
	gen aret = .
	
	sum id, det
	local max = `r(max)'
	forvalues x = 1/`r(max)' {

		display "`x'/`max'"
	
		qui regress ret vwretd if id==`x' & est==1
		capture drop aret_tmp
		qui predict aret_tmp if id==`x' & est==0, res
		qui replace aret = aret_tmp if id==`x' & !mi(aret_tmp) & mi(aret)

	}
	
	keep if date>=td(1sep2017)
	keep date permno aret
	
	// Calculate CARs for event windows
	egen car_oct5_6 = sum(aret) if date>=td(5oct2017) & date<=td(6oct2017), by(permno)
	egen car_oct9_13 = sum(aret) if date>=td(9oct2017) & date<=td(13oct2017), by(permno)
	egen car_oct16_27 = sum(aret) if date>=td(16oct2017) & date<=td(27oct2017), by(permno)
	egen car_nov = sum(aret) if date>=td(30oct2017) & date<=td(30nov2017), by(permno)
	
	collapse car_*, by(permno)

	gen car_oct5_6and16_27 = car_oct5_6 + car_oct16_27
	gen car_oct5_27 = car_oct5_6 + car_oct16_27 + car_oct9_13
	
	save "compiled\car-market-model", replace
	
	
********************************************************************************
* A4. Create directors variables
********************************************************************************
	
	// Merge BoardEx with gvkey
	use "raw\boardex-summary-02-07-19", clear  // BoardEx, downloaded 2019-02-07
	joinby CompanyID using "links\CompanyID_gvkey"  // Links BoardEx CompanyID to gvkey 
	
	// Create date variables
	gen monthname = ustrleft(AnnualReportYear, 3)
	gen month = .
	replace month = 1 if monthname=="Jan"
	replace month = 2 if monthname=="Feb"
	replace month = 3 if monthname=="Mar"
	replace month = 4 if monthname=="Apr"
	replace month = 5 if monthname=="May"
	replace month = 6 if monthname=="Jun"
	replace month = 7 if monthname=="Jul"
	replace month = 8 if monthname=="Aug"
	replace month = 9 if monthname=="Sep"
	replace month = 10 if monthname=="Oct"
	replace month = 11 if monthname=="Nov"
	replace month = 12 if monthname=="Dec"
	replace month = 12 if monthname=="Cur"
	
	gen year = ustrright(AnnualReportYear, 4)
	destring year, force replace
	replace year = 2019 if monthname=="Cur"
	
	gen ym = ym(year, month)
	format ym %tm
	drop if mi(ym)
	drop year month monthname
	
	gen date = dofm(ym+1)
	replace date = date - 1
	format date %td
	order AnnualReportYear date ym	
	
	// Keep most recent data prior to Oct 1, 2017
	drop if date>=td(01Oct2017) | date<td(01Oct2016)
	sort gvkey date
	egen maxdate = max(date), by(CompanyID gvkey)
	keep if date==maxdate
	
	// Create female variables
	gen female = (Gender=="F")
	gen female_ED = (DirectorTypeEDorSD=="ED" & female==1)
	gen female_SD = (DirectorTypeEDorSD=="SD" & female==1)
	gen ED = (DirectorTypeEDorSD=="ED")
	gen SD = (DirectorTypeEDorSD=="SD")
	
	egen has_female_director = max(female), by(CompanyID gvkey)
	egen has_female_ED = max(female_ED), by(CompanyID gvkey)
	egen has_female_SD = max(female_SD), by(CompanyID gvkey)
	egen sum_female_directors = sum(female), by(CompanyID gvkey)
	egen sum_female_ED = sum(female_ED), by(CompanyID gvkey)
	egen sum_female_SD = sum(female_SD), by(CompanyID gvkey)
	egen sum_SD = sum(SD), by(CompanyID gvkey)
	egen sum_ED = sum(ED), by(CompanyID gvkey)
	egen sum_directors = count(female), by(CompanyID gvkey)
	gen female_director_share = sum_female_directors / sum_directors
	gen female_ED_share = sum_female_ED / sum_ED
	gen female_SD_share = sum_female_SD / sum_SD
	
	bysort CompanyID gvkey: keep if _n==1
	duplicates tag gvkey, gen(tag)
	drop if tag>0
	drop tag
	
	keep gvkey AnnualReportYear CompanyID has_female_director - female_SD_share
	
	duplicates report gvkey
	joinby gvkey using "links\gvkey-permno-link"  // from Compustat
		
	compress
	save "compiled\directors", replace
	
	
********************************************************************************
* A5. Create female variables, most recent prior to January 1, 2016 
********************************************************************************
	
	// Create fiscal year date data
	use "raw\compustat-2010-2018", clear  // Compustat, downloaded 2019-03-10

	keep gvkey fyear datadate lpermno
	
	gen permno1 = lpermno
	bysort gvkey fyear: gen permno2 = lpermno[_n+1]
	bysort gvkey fyear: gen permno3 = lpermno[_n+2]
	drop lpermno
	
	bysort gvkey fyear: keep if _n==1
	duplicates report gvkey fyear
	
	save "compiled\fyear-datadate-2010-2018", replace

	// Historical CUSIPs	
	use "raw\crsp-2015-2018", clear  // CRSP, downloaded 2019-03-10
	
	keep date permno ncusip
	keep if date>=td(1jan2015) & date<=td(31dec2015)
	
	gen ym = mofd(date)
	format ym %tm
	
	bysort ym permno (date): keep if _n==_N
	drop date
	
	save "compiled\cusip-2015", replace
	
	// Keep most recent fiscal year prior to Jan 1, 2016   
	use "raw\execucomp-2010-2019", clear  // Execucomp, downloaded 2019-03-10

	gen fyear = year 	
	joinby fyear gvkey using "compiled\fyear-datadate-2010-2018", unma(ma)
	drop _merge
	
	drop if mi(datadate)
	keep if datadate<=td(31dec2015) & datadate>=td(1jan2015)

	bysort gvkey (datadate): keep if datadate==datadate[_N]
		
	// Create female variables
	drop if mi(execrankann)
	egen max_execrankann = max(execrankann), by(gvkey)
	drop if max_execrankann<5
	drop if execrankann>=6
	
	gen ceo = (ceoann=="CEO")
	gen cfo = (cfoann=="CFO")

	// Fix Execucomp gender variable classification errors
	tab nameprefix gender 
	
	count
	joinby execid using "compiled\gender-execid-2024", unma(ma)
	count
	tab _m 
	rename _merge check_gender_manually

	replace gender = gender_2024 if gender~=gender_2024 & !mi(gender_2024)
	replace nameprefix = nameprefix_2024 if nameprefix~=nameprefix_2024 & !mi(nameprefix_2024)

	* Manual checks 1
	*browse execid nameprefix gender exec_fullname if check_gender_manually==1   // no errros

	* Manual checks 2
	tab nameprefix gender 
	*browse execid nameprefix gender exec_fullname coname if nameprefix=="Mr." & gender=="FEMALE"
	replace gender = "MALE" if execid=="33636"  // Mark Alan Rossi
	replace gender = "MALE" if execid=="40900"  // Parveen Kakar
	replace gender = "MALE" if execid=="32782"  // Edmund DiSanto
	replace gender = "MALE" if execid=="47634"  // Raphael S. Pascaud

	gen female = (gender=="FEMALE") if !mi(gender)
	gen female_execdir = female * execdir
	gen female_ceo = ceo * female
	gen female_cfo = cfo * female

	egen num_execdir = sum(execdir), by(gvkey)
	egen num_exec = count(execdir), by(gvkey)
	egen num_female_exec = sum(female), by(gvkey)
	egen num_female_execdir = sum(female_execdir), by(gvkey)
	egen has_female_exec = max(female), by(gvkey)
	egen has_female_ceo = max(female_ceo), by(gvkey)
	egen has_female_cfo = max(female_cfo), by(gvkey)
	egen has_female_execdir = max(female_execdir), by(gvkey)

	duplicates drop gvkey, force
	
	gen female_exec_share = num_female_exec / num_exec
	gen female_dir_share = num_female_execdir / num_execdir

	keep gvkey cusip fyear datadate female_exec_share female_dir_share permno* has_female_exec has_female_ceo has_female_cfo has_female_execdir
	
	// Manually check firms with multiple PERMNOs
	gen permno = permno1
	replace permno = 86242 if gvkey=="002124"
	replace permno = 61516 if gvkey=="002220"
	replace permno = 29946 if gvkey=="002435"
	replace permno = 69796 if gvkey=="002710"
	replace permno = 59248 if gvkey=="003505"
	replace permno = 83233 if gvkey=="005338"
	replace permno = 41217 if gvkey=="005523"
	replace permno = 86313 if gvkey=="005763"
	replace permno = 32942 if gvkey=="005764"
	replace permno = 47379 if gvkey=="006379"
	replace permno = 52708 if gvkey=="006669"
	replace permno = 52090 if gvkey=="007146"
	replace permno = 61807 if gvkey=="007549"
	replace permno = 82279 if gvkey=="008582"
	replace permno = 82924 if gvkey=="011499"
	replace permno = 90441 if gvkey=="012886"
	replace permno = 76226 if gvkey=="013714"
	replace permno = 13963 if gvkey=="018043"
	replace permno = 91815 if gvkey=="025536"
	replace permno = 88372 if gvkey=="120301"
	replace permno = 14542 if gvkey=="160329"
	replace permno = 90805 if gvkey=="164296"
	replace permno = 15980 if gvkey=="165052"
	replace permno = 15860 if gvkey=="008210"
	
	// Update CUSIPs
	gen ym = mofd(datadate)
	count
	joinby ym permno using "compiled\cusip-2015", unma(ma)
	count
	tab _m
	drop _m
	
	gen len = strlen(cusip)
	replace cusip = "0" + cusip if len==7
	replace cusip = "00" + cusip if len==6
	replace cusip = "000" + cusip if len==5
		
	gen diff = cusip!=ncusip
	
	drop ym len diff
	
	compress
	save "compiled\firm-female-2015", replace

	
********************************************************************************
* A6. Create institutional ownership variables from Factset 
********************************************************************************

*** Parts of this code follows the SAS code developed by Miguel Ferreira & Pedro Matos (see WRDS, Factset Stock Ownership Tool)

***	Create intermediate datasets, prices & market cap
	
	// Create sample of equity securities
	use "raw\factset\sec_prices", clear  // Factset, downloaded 2022-04-29
	drop if mi(PRICE_DATE)
	bysort FSYM_ID: keep if _n==1
	keep FSYM_ID
	save "compiled\factset\has_sec_prices", replace  

	use "raw\factset\sec_coverage", clear  // Factset, downloaded 2022-04-29

	keep if ISSUE_TYPE=="EQ" | ISSUE_TYPE=="AD" | ISSUE_TYPE=="PF"

	count
	joinby FSYM_ID using "raw\factset\sym_coverage", unma(ma)  // Factset, downloaded 2022-04-29
	count
	tab _m
	drop _m

	keep if ISSUE_TYPE=="EQ" | ISSUE_TYPE=="AD" | (ISSUE_TYPE=="PF" & FREF_SECURITY_TYPE=="PREFEQ")
	keep FSYM_ID ISSUE_TYPE ISO_COUNTRY FREF_SECURITY_TYPE

	joinby FSYM_ID using "compiled\factset\has_sec_prices"

	compress
	save "compiled\factset\eq_secs", replace

	// Securities termination dates
	use "raw\factset\sec_prices", clear  
	bysort FSYM_ID (PRICE_DATE): keep if _n==_N
	rename PRICE_DATE TERMINATION_DATE
	keep FSYM_ID TERMINATION_DATE
	save "compiled\factset\termination", replace

	// Basic equity security information
	use "compiled\factset\eq_secs", clear  
	joinby FSYM_ID using "raw\factset\Security entity"  // Factset, downloaded 2022-04-12
	joinby FSYM_ID using "compiled\factset\termination"
	replace FACTSET_ENTITY_ID = "05K2VT-E" if FACTSET_ENTITY_ID=="000VLZ-E"  // updated dual listings
	replace FACTSET_ENTITY_ID = "0010VG-E" if FACTSET_ENTITY_ID=="05HF13-E"
	replace FACTSET_ENTITY_ID = "05HWCR-E" if FACTSET_ENTITY_ID=="002118-E"
	replace FACTSET_ENTITY_ID = "05DZG8-E" if FACTSET_ENTITY_ID=="002BV8-E"
	replace FACTSET_ENTITY_ID = "05K3JK-E" if FACTSET_ENTITY_ID=="003L8C-E"
	replace FACTSET_ENTITY_ID = "066L2H-E" if FACTSET_ENTITY_ID=="003L8C-E"
	replace FACTSET_ENTITY_ID = "066L2H-E" if FACTSET_ENTITY_ID=="05DZH3-E"
	replace FACTSET_ENTITY_ID = "066L2H-E" if FACTSET_ENTITY_ID=="05DZFJ-E"
	replace FACTSET_ENTITY_ID = "003GTW-E" if FACTSET_ENTITY_ID=="00C390-E"
	save "compiled\factset\own_basic", replace

	// Price 
	use "raw\factset\sec_prices", clear
	gen ym = mofd(PRICE_DATE)
	format ym %tm
	gen yq = qofd(PRICE_DATE)
	format yq %tq
	gen double own_mktcap = ADJ_PRICE * ADJ_SHARES_OUTSTANDING / 1000000
	drop UNADJ_PRICE UNADJ_SHARES_OUTSTANDING
	bysort FSYM_ID ym (PRICE_DATE): keep if _n==_N
	save "compiled\factset\prices_historical", replace

	// Market cap
	use "raw\factset\sec_prices", clear
	joinby FSYM_ID using "compiled\factset\own_basic"
	gen double own_mv_tmp = ADJ_PRICE * ADJ_SHARES_OUTSTANDING
	drop if ISSUE_TYPE=="AD"
	drop TERMINATION_DATE ISO_COUNTRY
	drop if FSYM_ID=="DXVFL5-S" & PRICE_DATE==td(30sep2015)
	egen own_mv = sum(own_mv_tmp), by(FACTSET_ENTITY_ID PRICE_DATE)
	keep FACTSET_ENTITY_ID PRICE_DATE own_mv
	bysort FACTSET_ENTITY_ID PRICE_DATE: keep if _n==1

	gen ym = mofd(PRICE_DATE)
	format ym %tm
	gen yq = qofd(PRICE_DATE)
	format yq %tq
	gen month = month(PRICE_DATE)
	gen eoq = (month==3 | month==6 | month==9 | month==12)
	drop month
	gen double mktcap_usd = own_mv / 1000000
	drop own_mv
	drop if mi(FACTSET_ENTITY_ID)
	keep if mktcap_usd>0
	bysort FACTSET_ENTITY_ID ym: keep if _n==1
	drop PRICE_DATE
	save "compiled\factset\hmktcap", replace

	bysort FACTSET_ENTITY_ID yq (ym): keep if _n==_N
	keep FACTSET_ENTITY_ID yq mktcap_usd 
	save "compiled\factset\hmktcap_yq", replace

	// Entities
	use "raw\factset\factset-entities", clear  // Factset, downloaded 2022-04-12
	keep FACTSET_ENTITY_ID ENTITY_TYPE ENTITY_SUB_TYPE ISO_COUNTRY
	rename FACTSET_ENTITY_ID FACTSET_INST_ID
	save "compiled\factset\inst_type_country", replace

	// Sample securities
	use "links\gvkey-factset-2017-2022-04-27", clear  // Links Factset to gvkey
	rename factset_entity_id FACTSET_ENTITY_ID
	joinby FACTSET_ENTITY_ID using "compiled\factset\own_basic"  
	keep FACTSET_ENTITY_ID FSYM_ID
	save "compiled\factset\sample_secs", replace

*** Calculate investor-level 13F holdings 
	use "raw\factset\factset-13F holdings", clear  // Factset, downloaded 2022-04-27
	rename FACTSET_ENTITY_ID FACTSET_INST_ID
	joinby FSYM_ID using "compiled\factset\sample_secs" 
	keep FSYM_ID FACTSET_INST_ID FACTSET_ENTITY_ID REPORT_DATE ADJ_HOLDING

	gen yq = qofd(REPORT_DATE)
	format yq %tq
	gen ym = mofd(REPORT_DATE)
	format ym %tm

	egen maxdate = max(REPORT_DATE), by(FACTSET_INST_ID yq)
	keep if REPORT_DATE==maxdate
	drop maxdate

	joinby FSYM_ID ym using "compiled\factset\prices_historical"
	joinby FACTSET_ENTITY_ID ym using "compiled\factset\hmktcap"

	gen double io = (ADJ_HOLDING * ADJ_PRICE/1000000) / mktcap_usd

	keep FSYM_ID FACTSET_INST_ID FACTSET_ENTITY_ID yq io own_mktcap mktcap_usd

	collapse (sum) io, by(yq FACTSET_INST_ID FACTSET_ENTITY_ID)
	
	save "compiled\factset\inst_holdings_detail", replace

*** Calculate total firm-level 13F holdings 
	use "compiled\factset\inst_holdings_detail", clear
	
	drop if mi(io)
	gen io_0_25p = io if io>=0.0025
	gen io_0_5p = io if io>=0.005
	gen io_1p = io if io>=0.01
	gen io_2p = io if io>=0.02
	gen io_5p = io if io>=0.05
	foreach x of varlist io_* {
		replace `x' = 0 if mi(`x')
	}

	keep yq FACTSET_ENTITY_ID FACTSET_INST_ID io io_0_25p - io_5p
	
	collapse (sum) io* , by(yq FACTSET_ENTITY_ID) fast

	foreach x of varlist io* {
		replace `x' = 1 if `x'>1
		replace `x' = 0 if `x'<0
	}

	rename io io_13f	
	
	save "compiled\factset\inst_holdings", replace

	
********************************************************************************
* A7. Create investor holdings-based ESG preference measueres
********************************************************************************
	
*** Refinitiv ESG measures

	// Prepare Factset CUSIP, ISIN, Sedol headers
	use "raw\factset\H_SECURITY_CUSIP", clear  // Factset, downloaded 2022-05-11
	drop if mi(CUSIP) | mi(FACTSET_ENTITY_ID)
	bysort CUSIP FACTSET_ENTITY_ID: keep if _n==1
	duplicates report CUSIP
	keep CUSIP PROPER_NAME FACTSET_ENTITY_ID
	save "compiled\factset\CUSIP-ESG", replace

	use "raw\factset\H_SECURITY_ISIN", clear  // Factset, downloaded 2022-05-11
	drop if mi(ISIN) | mi(FACTSET_ENTITY_ID)
	bysort ISIN FACTSET_ENTITY_ID: keep if _n==1
	duplicates report ISIN
	keep ISIN PROPER_NAME FACTSET_ENTITY_ID
	save "compiled\factset\ISIN-ESG", replace

	use "raw\factset\H_SECURITY_SEDOL", clear  // Factset, downloaded 2022-05-11
	drop if mi(SEDOL) | mi(FACTSET_ENTITY_ID)
	bysort SEDOL FACTSET_ENTITY_ID: keep if _n==1
	duplicates report SEDOL
	keep SEDOL PROPER_NAME FACTSET_ENTITY_ID
	save "compiled\factset\SEDOL-ESG", replace

	// CUSIP
	use "links\refinitiv-ESG-header-2021-10-08", clear  // Refinitiv ESG header
	keep dscode cusip company_name
	drop if mi(cusip)
	rename cusip CUSIP
	count
	joinby CUSIP using "compiled\factset\CUSIP-ESG", unma(ma)
	count
	tab _m
	drop _m
	drop if mi(FACTSET_ENTITY_ID)
	keep dscode FACTSET_ENTITY_ID
	rename FACTSET_ENTITY_ID FACTSET_ENTITY_ID_CUSIP
	save "compiled\factset\CUSIP-ESG-matched", replace

	// ISIN
	use "links\refinitiv-ESG-header-2021-10-08", clear
	keep dscode isin company_name
	drop if mi(isin)
	rename isin ISIN
	count
	joinby ISIN using "compiled\factset\ISIN-ESG", unma(ma)
	count
	tab _m
	drop _m
	drop if mi(FACTSET_ENTITY_ID)
	keep dscode FACTSET_ENTITY_ID
	rename FACTSET_ENTITY_ID FACTSET_ENTITY_ID_ISIN
	save "compiled\factset\ISIN-ESG-matched", replace

	// Sedol
	use "links\refinitiv-ESG-header-2021-10-08", clear
	keep dscode sedol company_name
	drop if mi(sedol)
	rename sedol SEDOL
	count
	joinby SEDOL using "compiled\factset\SEDOL-ESG", unma(ma)
	count
	tab _m
	drop _m
	drop if mi(FACTSET_ENTITY_ID)
	keep dscode FACTSET_ENTITY_ID
	rename FACTSET_ENTITY_ID FACTSET_ENTITY_ID_SEDOL
	save "compiled\factset\SEDOL-ESG-matched", replace

	// Names
	use "raw\factset\Entities", clear  // Factset, downloaded 2022-04-12
	keep FACTSET_ENTITY_ID ENTITY_NAME
	bysort FACTSET_ENTITY_ID ENTITY_NAME: keep if _n==1
	rename ENTITY_NAME company_name
	rename FACTSET_ENTITY_ID FACTSET_ENTITY_ID_NAME
	bysort company_name: drop if _N>1
	save "compiled\factset\Name-ESG-matched", replace

	// Combine data
	use "links\refinitiv-ESG-header-2021-10-08", clear
	drop s t

	foreach x in ISIN SEDOL CUSIP {
		count
		joinby dscode using "compiled\factset\\`x'-ESG-matched", unma(ma)
		count
		tab _m
		drop _m
	}

	count
	joinby company_name using "compiled\factset\\Name-ESG-matched", unma(ma)
	count
	tab _m
	drop _m

	gen FACTSET_ENTITY_ID = FACTSET_ENTITY_ID_ISIN
	replace FACTSET_ENTITY_ID = FACTSET_ENTITY_ID_SEDOL if mi(FACTSET_ENTITY_ID)
	replace FACTSET_ENTITY_ID = FACTSET_ENTITY_ID_CUSIP if mi(FACTSET_ENTITY_ID)
	replace FACTSET_ENTITY_ID = FACTSET_ENTITY_ID_NAME if mi(FACTSET_ENTITY_ID)

	drop if mi(FACTSET_ENTITY_ID)
	keep dscode FACTSET_ENTITY_ID
	save "links\Refinitiv-header-FactsetID", replace

	// Refinitiv ESG measures, quarterly
	use "raw\Refinitiv ESG, 2021-10-09", clear  // Refinitiv, downloaded 2021-10-09
	count
	joinby dscode using "links\Refinitiv-header-FactsetID"
	count

	keep dscode FACTSET_ENTITY_ID fyr_month year esg_fyr_latest ENSCORE - TRESGSOWOS TRDIRDS SODODP0081  

	replace SODODP0081 = "1" if trim(SODODP0081)=="Y"
	replace SODODP0081 = "0" if trim(SODODP0081)=="N"
	destring ENSCORE - SODODP0081, replace force

	gen q = quarter(date(esg_fyr_latest, "MDY"))
	destring year, force replace
	gen yq = yq(year, q)
	format yq %tq

	expand 4
	sort dscode yq
	bysort dscode yq: replace yq = yq[_n-1] + 1 if _n>1
	bysort dscode yq: drop if _N>1
	bysort FACTSET_ENTITY_ID yq: drop if _N>1
	drop q fyr_month esg_fyr_latest year dscode

	keep FACTSET_ENTITY_ID yq TRESGS SOSCORE TRESGSOWOS
	
	save "compiled\factset\ESG_measures_entities", replace
	
	// Refinitiv ESG measures, constant (average over 2016q4 to 2017q3)
	keep if yq>=tq(2016q4) & yq<=tq(2017q3)
	collapse TRESGS SOSCORE TRESGSOWOS, by(FACTSET_ENTITY_ID)
	save "compiled\factset\ESG_measures_entities_2016q4to2017q3", replace
	
*** Create holdings-based investor ESG preference measures	
	
	// Create list of firms
	use "raw\factset\factset-13F holdings", clear
	rename FACTSET_ENTITY_ID FACTSET_INST_ID

	count
	joinby FSYM_ID using "compiled\factset\own_basic" // keep equity securities only
	count

	keep FSYM_ID FACTSET_INST_ID FACTSET_ENTITY_ID REPORT_DATE ADJ_HOLDING ISO_COUNTRY
	drop if mi(FACTSET_ENTITY_ID)

	gen yq = qofd(REPORT_DATE)
	format yq %tq
	gen ym = mofd(REPORT_DATE)
	format ym %tm

	egen maxdate = max(REPORT_DATE), by(FACTSET_INST_ID yq)
	keep if REPORT_DATE==maxdate
	drop maxdate

	// Add prices, calculate $ holdings
	joinby FSYM_ID ym using "compiled\factset\prices_historical"

	drop if mi(ADJ_HOLDING)
	gen double inv = ADJ_HOLDING * ADJ_PRICE/1000000

	drop FSYM_ID REPORT_DATE ADJ_HOLDING ISO_COUNTRY ym PRICE_DATE ADJ_PRICE ADJ_SHARES_OUTSTANDING own_mktcap

	save "compiled\factset\tmp-1", replace
	
	// Add ESG scores, quarterly
	count
	joinby FACTSET_ENTITY_ID yq using "compiled\factset\ESG_measures_entities", unma(ma)
	count
	tab _m
	drop _m

	save "compiled\factset\tmp-2, quarterly", replace

	// Add ESG scores, constant
	use "compiled\factset\tmp-1", clear
	count
	joinby FACTSET_ENTITY_ID using "compiled\factset\ESG_measures_entities_2016q4to2017q3", unma(ma)
	count
	tab _m
	drop _m

	save "compiled\factset\tmp-2, constant", replace

	// Calculate holdings-value-weighted ESG scores using quarterly ESG scores
	foreach x in TRESGS SOSCORE TRESGSOWOS {    

		use "compiled\factset\tmp-2, quarterly", clear

		replace `x' = . if `x'==0  // set 0 values to missing; has no impact
			
		egen double inv_total = sum(inv), by(FACTSET_INST_ID yq)

		gen double inv_weight_woESG = inv / inv_total if mi(`x')
		egen double inv_total_woESG = sum(inv_weight_woESG), by(FACTSET_INST_ID yq)
		gen missingESG50plus = (inv_total_woESG>0.5)

		drop inv_total inv_weight_woESG inv_total_woESG
		egen double inv_total = sum(inv) if !mi(`x'), by(FACTSET_INST_ID yq)
		gen double inv_weight = inv / inv_total

		gen double `x'_hweighted = `x' * inv_weight

		collapse (sum) `x'_hweighted (mean) missingESG50plus, by(FACTSET_INST_ID yq)
		replace `x'_hweighted = 0 if missingESG50plus==1

		save "compiled\factset\\`x'_hweighted_setzero", replace  

	}
	
	// Calculate holdings-value-weighted ESG scores using constant ESG scores
	foreach x in TRESGS SOSCORE TRESGSOWOS {    

		use "compiled\factset\tmp-2, constant", clear

		replace `x' = . if `x'==0  // set 0 values to missing; has no impact
			
		egen double inv_total = sum(inv), by(FACTSET_INST_ID yq)

		gen double inv_weight_woESG = inv / inv_total if mi(`x')
		egen double inv_total_woESG = sum(inv_weight_woESG), by(FACTSET_INST_ID yq)
		gen missingESG50plus = (inv_total_woESG>0.5)

		drop inv_total inv_weight_woESG inv_total_woESG
		egen double inv_total = sum(inv) if !mi(`x'), by(FACTSET_INST_ID yq)
		gen double inv_weight = inv / inv_total

		gen double `x'_hweighted = `x' * inv_weight

		collapse (sum) `x'_hweighted (mean) missingESG50plus, by(FACTSET_INST_ID yq)
		replace `x'_hweighted = 0 if missingESG50plus==1

		save "compiled\factset\\`x'_hweighted_setzero_constant", replace  

	}
	
	// Combining holdings-value-weighted ESG scores using quarterly ESG scores
	use "compiled\factset\tmp-2, quarterly", clear
	
	local first = 1
	foreach x of varlist TRESGS SOSCORE TRESGSOWOS {    
		if `first'==1 use "compiled\factset\\`x'_hweighted_setzero", clear
		if `first'==0 joinby FACTSET_INST_ID yq using "compiled\factset\\`x'_hweighted_setzero", unma(ma)
		if `first'==0 drop _m
		local first = 0
	}

	save "compiled\factset\ESG_holdings_score", replace
	
	// Combining holdings-value-weighted ESG scores using constant ESG scores
	use "compiled\factset\tmp-2, constant", clear
	
	local first = 1
	foreach x of varlist TRESGS SOSCORE TRESGSOWOS {    
		if `first'==1 use "compiled\factset\\`x'_hweighted_setzero_constant", clear
		if `first'==0 joinby FACTSET_INST_ID yq using "compiled\factset\\`x'_hweighted_setzero_constant", unma(ma)
		if `first'==0 drop _m
		local first = 0
	}

	save "compiled\factset\ESG_holdings_score_constant", replace

	// Calculate investor ESG preference measures
	use "compiled\factset\ESG_holdings_score", clear
	keep if yq<=tq(2017q2) & yq>tq(2016q2)  // keep 1 year before Weinstein/MeToo
	collapse TRESGS_hweighted SOSCORE_hweighted TRESGSOWOS_hweighted, by(FACTSET_INST_ID)  // average ESG scores by institution
	save "compiled\factset\\13F_investor_ESG_performance", replace

	
********************************************************************************
* A8. Measure long-term and transient investors
********************************************************************************
	
	use "raw\factset\13F holdings, all", clear  // Factset, downloaded 2023-07-04
	rename factset_entity_id FACTSET_INST_ID
	joinby FSYM_ID using "compiled\factset\own_basic"   
	keep FSYM_ID FACTSET_INST_ID FACTSET_ENTITY_ID REPORT_DATE ADJ_HOLDING

	gen yq = qofd(REPORT_DATE)
	format yq %tq
	gen ym = mofd(REPORT_DATE)
	format ym %tm

	egen maxdate = max(REPORT_DATE), by(FACTSET_INST_ID yq)
	keep if REPORT_DATE==maxdate
	drop maxdate
	
	keep if yq<=tq(2017q3)

	bysort yq FACTSET_ENTITY_ID FACTSET_INST_ID: keep if _n==1

	bysort FACTSET_ENTITY_ID FACTSET_INST_ID: gen held_n = _N

	bysort FACTSET_ENTITY_ID FACTSET_INST_ID: keep if _n==1

	keep FACTSET_ENTITY_ID FACTSET_INST_ID held_n 

	save "compiled\factset\longterm_transient", replace

	
********************************************************************************
* B1. Create sample for Table 2
********************************************************************************

	// Panel A
	use "compiled\firm-female-2017", clear

	joinby permno using "raw\crsp-aug-2017-jan-2018"  // CRSP daily return, downloaded 2019-03-08
	duplicates drop permno date ret, force
	duplicates report permno date
	keep if date>=td(1sep2017) & date<=td(30nov2017)
	
	gen event_oct5_6 = (date>=td(5oct2017) & date<=td(6oct2017))
	gen event_oct15_27 = (date>=td(15oct2017) & date<=td(27oct2017))
	gen event_oct7_14 = (date>=td(7oct2017) & date<=td(14oct2017))
	gen event_nov = (date>=td(28oct2017) & date<=td(30nov2017))
	gen event_oct5_27 = (date>=td(5oct2017) & date<=td(27oct2017))
	
	tsset permno date
	
	replace ret = ret * 100
	replace vwretd = vwretd * 100
	
	egen N = count(ret), by(permno)
	keep if N==63

	save "compiled\sample-table2-panelA", replace
	
	// Panel B
	use "compiled\sample-table2-panelA", replace // use same sample firms as in Table 2, Panel A
	bysort permno: keep if _n==1  

	joinby permno using "compiled\car-market-model"  

	foreach x of varlist car_* {
		replace `x' = `x' * 100
	}
	
	save "compiled\sample-table2-panelB", replace


********************************************************************************
* B3. Create sample for Table 3
********************************************************************************

	use "compiled\directors", clear
	
	joinby gvkey using "compiled\firm-female-2017"
	joinby permno using "raw\crsp-aug-2017-jan-2018"  // CRSP daily return, downloaded 2019-03-08
	
	duplicates drop permno date ret, force
	duplicates report permno date
	keep if date>=td(1sep2017) & date<=td(30nov2017)
	
	gen event_oct5_6 = (date>=td(5oct2017) & date<=td(6oct2017))
	gen event_oct15_27 = (date>=td(15oct2017) & date<=td(27oct2017))
	gen event_oct7_14 = (date>=td(7oct2017) & date<=td(14oct2017))
	gen event_nov = (date>=td(28oct2017) & date<=td(30nov2017))
	gen event_oct5_27 = (date>=td(5oct2017) & date<=td(27oct2017))
	
	tsset permno date
	
	replace ret = ret * 100
	replace vwretd = vwretd * 100
	
	egen N = count(ret), by(permno)
	keep if N==63

	save "compiled\sample-table3", replace

	
********************************************************************************
* B3. Create sample for Table 1 
********************************************************************************
	
	// Female executive variables and firm controls
	use "compiled\sample-table2-panelA", clear  
		
	qui reghdfe ret 1.event_oct5_6#c.female_exec_share, absorb(permno date) vce(cluster permno) // keep sample firms
	keep if e(sample)
	bysort gvkey: keep if _n==1
	
	count
	joinby gvkey using "compiled\firm-controls", unma(ma)
	count
	tab _merge
	drop _merge

	save "compiled\sample-table1a", replace

	keep gvkey
	save LRST-gvkey, replace

	
	// Female board variables
	use "compiled\sample-table3", clear  

	qui reghdfe ret 1.event_oct5_6#c.female_exec_share, absorb(permno date) vce(cluster permno)
	keep if e(sample)
	bysort gvkey: keep if _n==1
	
	save "compiled\sample-table1b", replace
	

********************************************************************************
* B4. Create sample for Table 4
********************************************************************************

	use "compiled\firm-female-2017", clear
	
	count
	joinby gvkey using  "links\gvkey-factset-2017-2022-04-27", unma(ma)  // Links Factset to gvkey
	count
	tab _m
	drop _m
	
	joinby factset_entity_id using  "raw\factset\holdings_by_firm_msci", unma(ma)  // WRDS Factset Ownership Summary, downloaded 2021-06-16 
	tab _m
	drop _m
	gen lnmk = ln(mktcap)
	
	duplicates report gvkey rquarter
	
	format rquarter %td
	gen month = month(rquarter)
	gen year = year(rquarter)
	rename quarter quarter_factset
	gen quarter = quarter(rquarter)
	gen yq = yq(year, quarter)
	format yq %tq
	
	keep if rquarter>=td(1jan2016) & rquarter<=td(31dec2019) 
	gen post = (rquarter>=td(31dec2017))
	
	rename factset_entity_id FACTSET_ENTITY_ID
	count
	joinby FACTSET_ENTITY_ID yq using  "compiled\factset\inst_holdings", unma(ma)
	count
	tab _m
	drop _m
	
	foreach x of varlist io_13f - io_5p {
			gen `x'_prc = `x' * 100
	} 

	save "compiled\sample-table4", replace

	
********************************************************************************
* B5. Create sample for Tables 5 & 6
********************************************************************************
	
	use "compiled\sample-table4", clear 
	keep permno yq FACTSET_ENTITY_ID has_female_exec female_exec_share lnmk post rquarter
	
	count
	joinby FACTSET_ENTITY_ID yq using "compiled\factset\inst_holdings_detail", unma(ma)
	count
	tab _m
	drop _m
	
	count
	joinby FACTSET_INST_ID using "compiled\factset\13F_investor_ESG_performance", unma(ma)
	count
	tab _m
	drop _m
	
	gen io_prc = io * 100
	
	foreach x in 25 {
		gen p`x' = (io>=0.00`x')
		egen p`x'_max = max(p`x'), by(FACTSET_INST_ID permno)
		sum p`x'_max
		gen io_0_`x'p_prcadj = io_prc if p`x'_max==1
		drop p`x' p`x'_max
		rename io_0_`x'p_prcadj io_0_`x'p_prc
	}

	foreach x in 1 5 {
		gen p`x' = (io>=0.0`x')
		egen p`x'_max = max(p`x'), by(FACTSET_INST_ID permno)
		sum p`x'_max
		gen io_`x'p_prcadj = io_prc if p`x'_max==1
		drop p`x' p`x'_max
		rename io_`x'p_prcadj io_`x'p_prc
	}

	egen indstid = group(FACTSET_INST_ID)
	
	drop if rquarter==td(31dec2017)
	
	save "compiled\sample-table5-6", replace

	
********************************************************************************
* B6. Create sample for Tables 7
********************************************************************************
	
	// Columns 1, 3, 5 (time-varying)
	use "compiled\factset\13F_investor_ESG_performance", clear
	foreach x in TRESGS SOSCORE TRESGSOWOS {
		egen `x'_t3 = cut(`x'_hweighted), group(3)
	}	
	keep FACTSET_INST_ID *_t3
	save "compiled\factset\13F_investor_ESG_performance_terciles", replace
		
	use "compiled\factset\ESG_holdings_score", clear 
	count
	joinby FACTSET_INST_ID using "compiled\factset\13F_investor_ESG_performance_terciles"
	count

	gen post = (yq>tq(2017q3))
	keep if yq>=tq(2016q1) & yq<=tq(2019q4)

	foreach x in TRESGS SOSCORE TRESGSOWOS {
		gen low`x' = (`x'_t3==0)
		replace low`x' = . if `x'_t3==1
	}

	drop if yq==tq(2017q4)
	
	save "compiled\sample-table7a", replace
	
	// Columns 2, 4, 6 (constant)
	use "compiled\factset\ESG_holdings_score_constant", clear 
	count
	joinby FACTSET_INST_ID using "compiled\factset\13F_investor_ESG_performance_terciles"
	count

	gen post = (yq>tq(2017q3))
	keep if yq>=tq(2016q1) & yq<=tq(2019q4)

	foreach x in TRESGS SOSCORE TRESGSOWOS {
		gen low`x' = (`x'_t3==0)
		replace low`x' = . if `x'_t3==1
	}

	drop if yq==tq(2017q4)
	
	save "compiled\sample-table7b", replace

	
********************************************************************************
* B7. Create sample for Table 8
********************************************************************************

*** Panel A

	// Calculate CRSP excess returns	
	use "raw\crsp-monthly-2015-2022", clear  // CRSP, downloaded 2023-09-06
	gen yq = qofd(date)
	format yq %tq
	
	gen logret = ln(1+RET)
	gen logmk = ln(1+vwretd)
	
	collapse logret logmk, by(PERMNO yq)
	
	gen ret = exp(logret) - 1
	gen mk = exp(logmk) - 1
	
	gen excess_ret = ret - mk
	gen log_excess_ret = logret - logmk
	
	rename PERMNO permno
	
	duplicates report permno yq
	save "compiled\returns-yq", replace

	// Merge institutional ownership data with returns
	use "compiled\sample-table5-6", clear 

	count
	joinby permno yq using "compiled\returns-yq", unma(ma)
	count
	tab _m
	drop _m

	replace excess_ret = 0 if mi(excess_ret)
	
	drop if yq==tq(2017q4)
	
	save "compiled\sample-table8-panelA", replace

*** Panel B
	use "compiled\sample-table5-6", clear 

	count
	joinby FACTSET_INST_ID FACTSET_ENTITY_ID using "compiled\factset\longterm_transient", unma(ma)
	count
	tab _m
	drop _m
	
	gen held15 = (held_n==15)

	drop if yq==tq(2017q4)

	save "compiled\sample-table8-panelB", replace

	
********************************************************************************
* B8. Create sample for Table 9
********************************************************************************
	
	// Panel A	
	use "compiled\firm-female-2017", clear
	
	joinby cusip using "raw\ESG items, Refinitiv, 2021-07-12"

	count
	joinby gvkey using "compiled\firm-controls"
	count

	gen post = (year>=2017)
	tsset year permno

	keep if year>=2013
	drop if year==2017

	gen const=1
	
	save "compiled\sample-table9-panelAC", replace

	// Panel B
	use "compiled\firm-female-2017", clear
	
	joinby cusip using "raw\ESG items, Refinitiv, 2021-07-12"

	tsset year permno

	keep if year>=2013

	gen tm4 = (year==2013)
	gen tm3 = (year==2014)
	gen tm2 = (year==2015)
	gen tm1 = (year==2016)
	gen t0 = (year==2017)
	gen tp1 = (year==2018)
	gen tp2 = (year==2019)
	gen tp3 = (year==2020)

	save "compiled\sample-table9-panelB", replace

		
********************************************************************************
* B9. Create sample for Table 10
********************************************************************************
	
	use "compiled\firm-female-2017", clear // OLD
	rename permno permno_female
	
	count
	joinby gvkey using  "raw\data_for_analysis_pre_esg"  // Data are from Amiraslani, Lins, Servaes, and Tamayo (2023)
	count

	gen companyid_tmp1 = companyid if mon_yr==tm(2019m6)
	egen companyid_tmp2 = max(companyid_tmp1), by(cusip_id)
	replace companyid = companyid_tmp2 if mi(month12) & mon_yr==tm(2019m7)
	replace companyid = companyid_tmp2 if mi(month12) & mon_yr==tm(2019m8)
	replace companyid = companyid_tmp2 if mi(month12) & mon_yr==tm(2019m9)
	
	count
	joinby companyid mon_yr using "raw\pd", unma(ma)  // Data are from the Credit Research Initiative, National University of Singapore, downloaded 2022-08-04
	count
	tab _m
	drop _m
	
	drop if mi(spread)
	drop if mi(mon_yr)
	
	egen min = min(mon_yr), by(cusip_id)
	egen max = max(mon_yr), by(cusip_id)
	format min max %tm
	
	gen post1 = (mon_yr==tm(2017m10))
	gen post2 = (mon_yr>tm(2017m10))
	
	gen post = (mon_yr>=tm(2017m10))
	keep if mon_yr>=tm(2016m10) & mon_yr<=tm(2018m9)  // [-12;+12]

	bysort cusip_id mon_yr: keep if _N==1
	duplicates report cusip_id mon_yr

	keep if min<=tm(2016m10) & max>=tm(2018m9)  // [-12;+12]

	egen min_rating = max(rating), by(cusip_id)
	egen max_rating = min(rating), by(cusip_id)
	gen rating_diff = min_rating - max_rating
	drop if rating==22
	
	gen lnmve = ln(mve)
	gen lnamt = ln(offering_amt)
	gen lnvol = ln(retvol_d)
	gen lnduration = ln(duration)
	
	gen ic1 = (int1>0)
	gen ic2 = (int2>0)
	gen ic3 = (int3>0)
	gen ic4 = (int4>0)
	
	replace month12 = month12*100
	
	drop if mon_yr==tm(2017m10)
	
	save "compiled\sample-table10", replace

	
********************************************************************************
* B10. Create sample for Table 11
********************************************************************************
	
	// Employees from annual Compustat data
	use "raw\compustatY-2021-08-02", clear  // Compustat, downloaded 2021-08-02
	keep gvkey fyear emp datadate
	bysort gvkey fyear (datadate): keep if _n==_N
	drop datadate
	save "compiled\employeesY-2021-08-02", replace

	// Quarterly Compustat data
	use "compiled\firm-female-2015", clear
	rename datadate datadate_execucomp
	rename fyear year_execucomp
	
	joinby gvkey using "raw\compustatQ-2021-08-02"  // Compustat, downloaded 2021-08-02
	duplicates tag gvkey datadate, gen(tag)
	keep if tag==0
	drop tag
	
	gen fyear = fyearq
	count
	joinby gvkey fyear using "compiled\employeesY-2021-08-02", unma(ma)
	count
	drop _m

	gen yq = qofd(datadate)
	format yq %tq
	gen quarter = quarter(datadate)
	
	egen firmid = group(gvkey)
	bysort firmid yq (datadate): keep if _n==_N
	tsset firmid yq
	
	gen op_income_sales =  oibdpq / saleq if saleq>0
	gen gross_margin = (saleq - cogsq) / saleq if saleq>0
	gen sales_growth = saleq / L4.saleq if saleq>0 & L4.saleq>0
	gen sales_emp = saleq / (emp * 1000) if saleq>0
	gen lnat = ln(atq)
	
	// Industry
	destring sic, replace force
	gen sic2 = floor(sic/100)

	// Time
	gen post = .
	replace post = 0 if datadate<=td(30sep2017) & datadate>=td(1jan2016)
	replace post = 1 if datadate>=td(1jan2018) & datadate<=td(31dec2020)
	drop if mi(post)
	
	winsor2 op_income_sales gross_margin sales_growth sales_emp, replace cut(1 99) 
	
	save "compiled\sample-table11", replace

	
********************************************************************************
* B11. Create sample for Table 12
********************************************************************************

***	CARs around earnings announcements
	
	// Earnings announcement dates to calculate CARs
	use "raw\IBES summary, adj, 2021-08-02", clear  // IBES, downloaded 2021-08-02
	rename *, lower

	rename ticker IBES_ticker
	drop if mi(IBES_ticker)

	count
	joinby IBES_ticker using "links\firm-female-ibes" // Links IBES to gvkey
	count

	drop if mi(anndats_act)

	bysort IBES_ticker anndats_act: keep if _n==1

	keep permno anndats_act anntims_act

	gen nextday = 0
	gen hour = hh(anntims_act)
	replace nextday = 1 if hour>=16

	gen anndats_act_adj = anndats_act
	replace anndats_act_adj = anndats_act + 1 if nextday==1
	format anndats_act_adj %td
	gen dow = dow(anndats_act_adj)
	replace anndats_act_adj = anndats_act_adj + 2 if dow==6
	replace anndats_act_adj = anndats_act_adj + 1 if dow==0

	gen double date = year(anndats_act_adj) * 10000 + month(anndats_act_adj) * 100 + day(anndats_act_adj)
	tostring date, replace force

	keep permno date // => use in WRDS Event Study tool to calculate market-model adjusted ARs and CARs (parameters: 120 80 20 -1 1)

	// CARs 
	use "raw\WRDS-car-m1p1-mm", clear  // WRDS Event Study tool, calculated and downloaded 2021-08-02
	sum nrets, det
	keep if nrets==r(max)
	rename evtdate anndats_act_adj
	keep permno anndats_act car
	save "compiled\car-m1p1", replace
	
	local year = 2015

*** Create sample
	
	// Stock prices
	use "raw\IBES price, adj, 2021-08-02", clear  // IBES, downloaded 2021-08-02
	rename *, lower

	rename ticker IBES_ticker
	drop if mi(IBES_ticker)

	keep IBES_ticker statpers price prdays
	duplicates drop IBES_ticker statpers, force

	save "compiled\IBES-prices", replace
	
   // Combine
	use "raw\IBES summary, adj, 2021-08-02", clear  // IBES, downloaded 2021-08-02
	rename *, lower

	rename ticker IBES_ticker
	drop if mi(IBES_ticker)

	drop if statpers > anndats_act

	count
	joinby IBES_ticker using "links\firm-female-ibes"  // Links IBES to gvkey and permno
	count

	gen nextday = 0
	gen hour = hh(anntims_act)
	replace nextday = 1 if hour>=16

	gen anndats_act_adj = anndats_act
	replace anndats_act_adj = anndats_act + 1 if nextday==1
	format anndats_act_adj %td
	gen dow = dow(anndats_act_adj)
	replace anndats_act_adj = anndats_act_adj + 2 if dow==6
	replace anndats_act_adj = anndats_act_adj + 1 if dow==0

	keep if fpi=="1"  // annual EPS
	drop if mi(anndats_act_adj)

	bysort IBES_ticker fpedats (statpers): keep if _n==_N

	count
	joinby IBES_ticker statpers using "compiled\IBES-prices", unma(ma)  
	count
	tab _m
	drop _m

	drop if mi(price)
	drop if price<=0
	drop if mi(actual)
	drop if mi(meanest)

	gen ux = (actual - meanest)
	gen ux_x = ux / price

	count
	joinby permno anndats_act_adj using "compiled\car-m1p1", unma(ma)
	tab _m
	drop _m
	count
	
	count
	joinby permno using "links\sic-permno", unma(ma)  // Links permno to SIC (CRSP)
	count
	tab _m
	drop _m

	keep if anndats_act>=td(1jan2016) & fpedats<=td(31dec2020)
	drop if anndats_act>=td(1oct2017) & anndats_act<=td(31oct2017)
	gen post = (anndats_act>=td(1nov2017))

	gen yq = qofd(anndats_act)
	format yq %tq
	gen ym = mofd(anndats_act)
	format ym %tm

	gen year = year(fpedats)

	egen firmid = group(permno)

	winsor2 ux_x, cut(1 99) replace 
	winsor2 car, cut(1 99) replace

	count
	joinby gvkey using "compiled\firm-female-2015"
	count

	save "compiled\sample-table12", replace

	log close










********************************************************************************
* Sexism, Culture, and Firm Value: Evidence from the Harvey Weinstein Scandal  
*    and the #MeToo Movement												   
* Journal of Accounting Research                                               
*																			   
* Lins, Roth, Servaes, and Tamayo (2024)									   
* April 2024															   
*
* Code for Empirical Analyses
* Stata/MP 18.0 for Windows (64-bit x86-64), Revision 14 Feb 2024
********************************************************************************

	cd  c:\lrst
	log using "LRST-results-logfile.smcl", replace

********************************************************************************
* Table 1
********************************************************************************

	clear all
	set more off
	
	use "compiled\sample-table1a", clear  
		
	tabstat female_exec_share has_female_exec has_female_ceo has_female_cfo lnat cash lev q invest oprofit ///
		, stats(mean p50 sd N) columns(stats)

	tabstat female_exec_share has_female_exec has_female_ceo has_female_cfo lnat cash lev q invest oprofit ///
		if has_female_exec==1, stats(mean p50 sd N) columns(stats)

	tabstat female_exec_share has_female_exec has_female_ceo has_female_cfo lnat cash lev q invest oprofit ///
		if has_female_exec==0, stats(mean p50 sd N) columns(stats)
	
	foreach x in lnat cash lev q invest oprofit {
		regress `x' has_female_exec, robust
	}
	
	foreach x in lnat cash lev q invest oprofit {
		ranksum `x', by(has_female_exec)
	}

	use "compiled\sample-table1b", clear  
	
	tabstat female_director_share, stats(mean p50 sd N) columns(stats)

	tabstat female_director_share if has_female_exec==1, stats(mean p50 sd N) columns(stats)
	tabstat female_director_share if has_female_exec==0, stats(mean p50 sd N) columns(stats)
	
	regress female_director_share has_female_exec, robust
	ranksum female_director_share, by(has_female_exec)
	
	
********************************************************************************
* Table 2
********************************************************************************

	// Panel A
	use "compiled\sample-table2-panelA", replace

	est clear
	
	reghdfe ret 1.event_oct5_6#c.female_exec_share 1.event_oct15_27#c.female_exec_share, absorb(permno date) vce(cluster permno date)
	est store A1

	reghdfe ret 1.event_oct5_6#1.has_female_exec 1.event_oct15_27#1.has_female_exec, absorb(permno date) vce(cluster permno date)
	est store A2

	reghdfe ret 1.event_oct5_6#c.female_exec_share 1.event_oct7_14#c.female_exec_share 1.event_oct15_27#c.female_exec_share 1.event_nov#c.female_exec_share, absorb(permno date) vce(cluster permno date)
	est store A3

	reghdfe ret 1.event_oct5_6#1.has_female_exec 1.event_oct7_14#1.has_female_exec 1.event_oct15_27#1.has_female_exec 1.event_nov#1.has_female_exec, absorb(permno date) vce(cluster permno date)
	est store A4

	esttab * using "output\table2-panelA.csv", replace compress nogaps b(3) p(2) ///
	stats(N r2_a, fmt(%9.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes starlevels(* 0.10 ** 0.05 *** 0.01) ///
	order(1.event_oct5_6#c.female_exec_share 1.event_oct7_14#c.female_exec_share 1.event_oct15_27#c.female_exec_share 1.event_nov#c.female_exec_share 1.event_oct5_6#1.has_female_exec 1.event_oct7_14#1.has_female_exec)

	// Panel B
	use "compiled\sample-table2-panelB", replace

	est clear
	local i = 1
	
	foreach x in car_oct5_6 car_oct16_27 car_oct5_6and16_27 {
		reg `x' if has_female_exec==1
		est store A`i' 
		local ++i
	}
	
	foreach x in car_oct5_6 car_oct16_27 car_oct5_6and16_27 {
		reg `x' if has_female_exec==0
		est store A`i' 
		local ++i
	}

	foreach x in car_oct5_6 car_oct16_27 car_oct5_6and16_27 {
		reg `x' has_female_exec
		est store A`i' 
		local ++i
	}

	esttab * using "output\table2-panelB.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%9.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes star(* 0.10 ** 0.05 *** 0.01)  

	
	
********************************************************************************
* Table 3
********************************************************************************

	use "compiled\sample-table3", clear
	
	est clear
		
	reghdfe ret 1.event_oct5_6#c.female_director_share 1.event_oct15_27#c.female_director_share ///	
		1.event_oct5_6#c.female_exec_share  1.event_oct15_27#c.female_exec_share, absorb(permno date) vce(cluster permno date)
	est store A3
	
	reghdfe ret 1.event_oct5_6#c.female_director_share 1.event_oct15_27#c.female_director_share ///	
		1.event_oct5_6#1.has_female_exec 1.event_oct15_27#1.has_female_exec, absorb(permno date) vce(cluster permno date)
	est store A4
	
	reghdfe ret 1.event_oct5_6#c.female_director_share 1.event_oct7_14#c.female_director_share 1.event_oct15_27#c.female_director_share 1.event_nov#c.female_director_share ///	
		1.event_oct5_6#c.female_exec_share 1.event_oct7_14#c.female_exec_share 1.event_oct15_27#c.female_exec_share 1.event_nov#c.female_exec_share, absorb(permno date) vce(cluster permno date)
	est store A5
	
	reghdfe ret 1.event_oct5_6#c.female_director_share 1.event_oct7_14#c.female_director_share 1.event_oct15_27#c.female_director_share 1.event_nov#c.female_director_share ///	
		1.event_oct5_6#1.has_female_exec 1.event_oct7_14#1.has_female_exec 1.event_oct15_27#1.has_female_exec 1.event_nov#1.has_female_exec, absorb(permno date) vce(cluster permno date)
	est store A6

	esttab * using "output\table3.csv", replace compress nogaps b(3) p(2) label ///
		stats(N r2_a, fmt(%9.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes star(* 0.10 ** 0.05 *** 0.01)  ///
		order(1.event_oct5_6#c.female_director_share 1.event_oct7_14#c.female_director_share 1.event_oct15_27#c.female_director_share 1.event_nov#c.female_director_share ///
		1.event_oct5_6#c.female_exec_share 1.event_oct7_14#c.female_exec_share 1.event_oct15_27#c.female_exec_share 1.event_nov#c.female_exec_share 1.event_oct5_6#1.has_female_exec 1.event_oct7_14#1.has_female_exec)
	
	
	
********************************************************************************
* Table 4
********************************************************************************

	// Panel A
	use "compiled\sample-table4", clear
	drop if rquarter==td(31dec2017)

	est clear
	local i = 1
	
	foreach x of varlist io_13f_prc io_0_25p_prc io_1p_prc io_5p_prc {  
	
		reghdfe `x' 1.post##c.female_exec_share lnmk, absorb(permno rquarter) vce(cluster permno rquarter)
		est store A`i', title("`x'")
		local ++i

		reghdfe `x' 1.post##c.has_female_exec lnmk, absorb(permno rquarter) vce(cluster permno rquarter)
		est store A`i', title("`x'")
		local ++i
		
	}
	
	esttab * using "output\table4-panelA.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%9.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes starlevels(* 0.10 ** 0.05 *** 0.01) ///
		drop(1.post female_exec_share has_female_exec) order(1.post*)

	// Panel B
	use "compiled\sample-table4", clear
	tab rquarter 

	gen tm7 = (rquarter==td(31mar2016))
	gen tm6 = (rquarter==td(30jun2016))
	gen tm5 = (rquarter==td(30sep2016))
	gen tm4 = (rquarter<=td(31dec2016))
	gen tm3 = (rquarter==td(31mar2017))
	gen tm2 = (rquarter==td(30jun2017))
	gen tm1 = (rquarter==td(30sep2017))
	gen t0 = (rquarter==td(31dec2017))
	gen tp1 = (rquarter==td(31mar2018))
	gen tp2 = (rquarter==td(30jun2018))
	gen tp3 = (rquarter==td(30sep2018))
	gen tp4 = (rquarter>=td(31dec2018))
	gen tp5 = (rquarter==td(31mar2019))
	gen tp6 = (rquarter==td(30jun2019))
	gen tp7 = (rquarter==td(30sep2019))
	gen tp8 = (rquarter==td(31dec2019))		
	
	est clear
	
	reghdfe io_13f_prc  1.tm4#c.female_exec_share 1.tm3#c.female_exec_share 1.tm2#c.female_exec_share  ///
		1.t0#c.female_exec_share 1.tp1#c.female_exec_share 1.tp2#c.female_exec_share 1.tp3#c.female_exec_share 1.tp4#c.female_exec_share lnmk if !mi(post), absorb(permno rquarter) vce(cluster permno rquarter)
		est store A1

	reghdfe io_13f_prc  1.tm4#c.has_female_exec 1.tm3#c.has_female_exec 1.tm2#c.has_female_exec  ///
		1.t0#c.has_female_exec 1.tp1#c.has_female_exec 1.tp2#c.has_female_exec 1.tp3#c.has_female_exec 1.tp4#c.has_female_exec lnmk if !mi(post), absorb(permno rquarter) vce(cluster permno rquarter)
		est store A2
	
	esttab * using "output\table4-panelB.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%9.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes starlevels(* 0.10 ** 0.05 *** 0.01) ///
		order(*#c.female_exec_share *#c.has_female_exec)
		

********************************************************************************
* Table 5
********************************************************************************

	use "compiled\sample-table5-6", clear

	est clear
	local i = 1
	
	foreach x of varlist io_prc io_0_25p_prc io_1p_prc io_5p_prc {     
	
		reghdfe `x' 1.post##c.female_exec_share lnmk, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)
		est store A`i', title("`x'")
		local ++i

		reghdfe `x' 1.post##c.has_female_exec lnmk, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)
		est store A`i', title("`x'")
		local ++i
		
	}
	
	esttab * using "output\table5.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%12.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes starlevels(* 0.10 ** 0.05 *** 0.01) ///
		drop(1.post female_exec_share has_female_exec) order(1.post*) 

	
********************************************************************************
* Table 6
********************************************************************************

	use "compiled\sample-table5-6", clear

	est clear
	local i = 1
	
	foreach x of varlist TRESGS_hweighted SOSCORE_hweighted TRESGSOWOS_hweighted {  
	
		capture drop ESG_tercile
		egen ESG_tercile = cut(`x'), group(3)
	
		reghdfe io_prc 1.post##c.female_exec_share lnmk if ESG_tercile==0, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)
		est store A`i', title("`x'")
		local ++i

		reghdfe io_prc 1.post##c.female_exec_share lnmk if ESG_tercile==2, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)
		est store A`i', title("`x'")
		local ++i

		reghdfe io_prc 1.post##c.female_exec_share##ESG_tercile lnmk if ESG_tercile~=1, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)
		est store A`i', title("`x'")
		local ++i

		*
		
		reghdfe io_prc 1.post##1.has_female_exec lnmk if ESG_tercile==0, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)
		est store A`i', title("`x'")
		local ++i

		reghdfe io_prc 1.post##1.has_female_exec lnmk if ESG_tercile==2, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)
		est store A`i', title("`x'")
		local ++i
	
		reghdfe io_prc 1.post##1.has_female_exec##ESG_tercile lnmk if ESG_tercile~=1, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)
		est store A`i', title("`x'")
		local ++i
	
	}
	
	esttab * using "output\table6.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%12.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes starlevels(* 0.10 ** 0.05 *** 0.01) ///
		drop(1.post female_exec_share 1.has_female_exec) order(1.post*) mtitles


********************************************************************************
* Table 7
********************************************************************************
	
	// Columns 1, 3, 5 (time-varying)
	use "compiled\sample-table7a", clear
	
	est clear
	local i = 1
	
	foreach x in TRESGS SOSCORE TRESGSOWOS {  
	
		reghdfe `x'_hweighted 1.post##1.low`x', absorb(FACTSET_INST_ID yq) vce(cluster FACTSET_INST_ID yq)
		est store A`i'
		local ++i

	}
		
	esttab * using "output\table7a.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%12.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes starlevels(* 0.10 ** 0.05 *** 0.01) ///
		drop(1.post 1.low*)
	
	
	// Columns 2, 4, 6 (constant)
	use "compiled\sample-table7b", clear
	
	est clear
	local i = 1
	
	foreach x in TRESGS SOSCORE TRESGSOWOS {  
	
		reghdfe `x'_hweighted 1.post##1.low`x', absorb(FACTSET_INST_ID yq) vce(cluster FACTSET_INST_ID yq)
		est store A`i'
		local ++i

	}
		
	esttab * using "output\table7b.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%12.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes starlevels(* 0.10 ** 0.05 *** 0.01) ///
		drop(1.post 1.low*)

	
********************************************************************************
* Table 8
********************************************************************************

	// Panel A
	use "compiled\sample-table8-panelA", clear

	est clear

	reghdfe io_prc 1.post##c.female_exec_share excess_ret lnmk, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)
	est store A1

	reghdfe io_prc 1.post##1.has_female_exec excess_ret lnmk, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)
	est store A4

	esttab * using "output\table8-panelA.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%12.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes star(* 0.10 ** 0.05 *** 0.01)  ///
		drop(1.post 1.has_female_exec) order(1.post*)

	// Panel B
	use "compiled\sample-table8-panelB", clear

	est clear

	reghdfe io_prc 1.post##c.female_exec_share lnmk if held15==1, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)	
	est store A1

	reghdfe io_prc 1.post##c.female_exec_share lnmk if held15==0, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)	
	est store A2

	reghdfe io_prc 1.post##c.female_exec_share##held15 lnmk, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)	
	est store A3
	
	*
	
	reghdfe io_prc 1.post##1.has_female_exec lnmk if held15==1, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)	
	est store A4

	reghdfe io_prc 1.post##1.has_female_exec lnmk if held15==0 , absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)	
	est store A5

	reghdfe io_prc 1.post##1.has_female_exec##1.held15 lnmk, absorb(permno rquarter##indstid) vce(cluster permno FACTSET_INST_ID rquarter)	
	est store A6

	esttab * using "output\table8-panelB.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%12.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes star(* 0.10 ** 0.05 *** 0.01)  ///
		order(1.post*)

	
********************************************************************************
* Table 9
********************************************************************************
	
	// Panel A
	use "compiled\sample-table9-panelAC", clear

	est clear
	local i = 1

	foreach x of varlist TRDIRDS CGBSO19 SODODP0081 {
		reghdfe `x' post##c.female_exec_share, absorb(permno year) vce(cluster permno year)
		est store A`i', title("`x'")
		local ++i
	}

	local i = 1
	foreach x of varlist TRDIRDS CGBSO19 SODODP0081 {
		reghdfe `x' post##has_female_exec, absorb(permno year) vce(cluster permno year)
		est store B`i', title("`x'")
		local ++i
	}
		
	esttab A1 B1 A2 B2 A3 B3 using "output\table9-panelA.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%12.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes star(* 0.10 ** 0.05 *** 0.01)  ///
		order(1.post*)

	// Panel B
	use "compiled\sample-table9-panelB", clear

	est clear
  
	reghdfe CGBSO19 1.tm4#1.has_female_exec 1.tm3#1.has_female_exec 1.tm2#1.has_female_exec 1.t0#1.has_female_exec 1.tp1#1.has_female_exec 1.tp2#1.has_female_exec 1.tp3#1.has_female_exec, absorb(permno year) vce(cluster permno)
	est store A1

	reghdfe CGBSO19 1.tm4#c.female_exec_share 1.tm3#c.female_exec_share 1.tm2#c.female_exec_share 1.t0#c.female_exec_share 1.tp1#c.female_exec_share 1.tp2#c.female_exec_share 1.tp3#c.female_exec_share, absorb(permno year) vce(cluster permno)
	est store A2

	reghdfe SODODP0081 1.tm4#1.has_female_exec 1.tm3#1.has_female_exec 1.tm2#1.has_female_exec 1.t0#1.has_female_exec 1.tp1#1.has_female_exec 1.tp2#1.has_female_exec 1.tp3#1.has_female_exec, absorb(permno year) vce(cluster permno)
	est store A3

	reghdfe SODODP0081 1.tm4#c.female_exec_share 1.tm3#c.female_exec_share 1.tm2#c.female_exec_share 1.t0#c.female_exec_share 1.tp1#c.female_exec_share 1.tp2#c.female_exec_share 1.tp3#c.female_exec_share, absorb(permno year) vce(cluster permno)
	est store A4
	
	esttab A2 A1 A4 A3 using "output\table9-panelB.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%12.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes star(* 0.10 ** 0.05 *** 0.01)  

	// Panel C
	use "compiled\sample-table9-panelAC", clear

	est clear
	local i = 1
	
	foreach x of varlist TRDIRDS CGBSO19 SODODP0081 {  
	
		reghdfe `x' 1.post#1.has_female_exec 1.post#0.has_female_exec has_female_exec, absorb(const) vce(cluster permno year) 
		test 1.post#1.has_female_exec 1.post#0.has_female_exe
		estadd scalar p_val = r(p)
		est	store A`i'
		local ++i

	}
	
	esttab * using "output\table9-panelC.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a p_val, fmt(%9.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes star(* 0.10 ** 0.05 *** 0.01) 

	
********************************************************************************
* Table 10
********************************************************************************

	use "compiled\sample-table10", clear	
	
	est clear
	
	global bond_controls "amihud duration month12 rating lnamt life coupon"
	global firm_controls "lnmve profit inv_lev ic1-ic4 lnvol"
	
	reghdfe spread 1.post#c.female_exec_share $bond_controls, absorb(gvkey mon_yr) vce(cluster gvkey mon_yr)
	est store A1A
	
	reghdfe spread 1.post#c.female_exec_share $bond_controls $firm_controls, absorb(gvkey mon_yr) vce(cluster gvkey mon_yr)
	est store A1B

	reghdfe spread 1.post#1.has_female_exec $bond_controls, absorb(gvkey mon_yr) vce(cluster gvkey mon_yr)
	est store A2A

	reghdfe spread 1.post#1.has_female_exec $bond_controls $firm_controls, absorb(gvkey mon_yr) vce(cluster gvkey mon_yr)
	est store A2B
	
	esttab * using "output\table10.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%9.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes star(* 0.10 ** 0.05 *** 0.01)  ///
		order(1.post#c.female_exec_share 1.post#1.has_female_exec)
	
	
********************************************************************************
* Table 11
********************************************************************************
	
	use "compiled\sample-table11", clear	

	est clear
		
	local i = 1
		
	foreach x in op_income_sales gross_margin sales_growth sales_emp {

		reghdfe `x' 1.post#c.female_exec_share lnat , absorb(firmid yq##sic2) vce(cluster firmid yq)
	 	est store A`i', title("`x'")
		local ++i

	}

	foreach x in op_income_sales gross_margin sales_growth sales_emp {
	
		reghdfe `x' 1.post#1.has_female_exec lnat , absorb(firmid yq##sic2) vce(cluster firmid yq)
	 	est store B`i', title("`x'")
		local ++i

	}
	
	esttab * using "output\table11.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%9.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes star(* 0.10 ** 0.05 *** 0.01)  ///
		order(1.post#c.female_exec_share 1.post#1.has_female_exec)

	
	
********************************************************************************
* Table 12
********************************************************************************
	
	use "compiled\sample-table12", clear	
	
	est clear
	
	reghdfe car c.ux_x##1.post##c.female_exec_share, absorb(yq##sic2 firmid) cluster(firmid yq)
	est store A1

	reghdfe car c.ux_x##1.post##1.has_female_exec, absorb(yq##sic2 firmid) cluster(firmid yq)
	est store A2

	esttab * using "output\table12.csv", replace compress nogaps b(3) p(2) ///
		stats(N r2_a, fmt(%9.0g %9.3fc) labels(Obs "Adjusted R2")) nonotes star(* 0.10 ** 0.05 *** 0.01) ///
		drop(1.post female_exec_share 1.has_female_exec)

	log close
