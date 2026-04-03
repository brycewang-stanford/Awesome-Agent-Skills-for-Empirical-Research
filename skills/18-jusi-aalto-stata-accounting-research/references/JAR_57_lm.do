*****************************************************************************************************
*****************************************************************************************************
*****      The follwing codes replicate the Main Samples in "Financial Gatekeepers and   	    ***** 
*****        Investor Protection: Evidence from Criminal Background Checks"          	        ***** 
*****        by Kelvin K. F. Law and Lillian F. Mills (2019, Journal of Accounting Research)	***** 
*****                                    Version: March 8, 2019									***** 
*****************************************************************************************************
*****************************************************************************************************
*The following codes construct main advisor sample
*Read raw FINRA employment data 
	use "D:\Dropbox\19-03-08 JAR Replications\advisor\employment_combined.dta", clear
*Construct advisor-year panel
	keep individualid firmid begin end zip5
	gduplicates drop _all, force
	gsort individualid begin firmid 
	drop if begin==.
	gen begyear = year(begin)
	gen endyear = year(end)
	gen length = endyear - begyear + 1
	gen recordid = _n
	expand(length)
	gsort recordid
	by recordid: gen id = _n
	gen year = begyear + id - 1
	rename id tenure
	drop if year(end)<year & end!=. & year!=.
	drop begyear endyear length
	gduplicates drop _all, force
	gsort recordid year begin 
*Years in profession
	by individualid, sort: egen since = min(year)
	gen genexp = year - since + 1 if since>=1946
	gsort recordid year begin 
*Firm size
	preserve
	keep year firmid individualid 
	gduplicates drop year firmid individualid, force
	gen dum = 1
	gcollapse (sum) firmsize = dum, by(firmid year)
	tempfile temp1
	save "`temp1'", replace
	restore
	merge m:1 firmid year using "`temp1'"
	drop if _merge==2
	drop _merge
	gsort recordid year begin 
*Branch size
	preserve
	keep year firmid individualid zip5
	drop if zip5==.
	drop if firmid==.
	gduplicates drop year firmid individualid zip5, force
	gen dum = 1
	gcollapse (sum) branchsize = dum, by(firmid zip5 year)
	tempfile temp2
	save "`temp2'", replace
	restore
	merge m:1 firmid zip5 year using "`temp2'"
	drop if _merge==2
	drop _merge
	gsort recordid year begin 
*One advisor obs per year
	egen groupid = group(individualid year)
	sort groupid firmsize
	by groupid: gen id = _n
	by groupid: egen maxid = max(id)
	keep if maxid==id
	drop groupid maxid id
	gsort recordid year begin 
	gduplicates drop individualid year, force
*Gender
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\Individual ID gender data.dta"
	drop if _merge==2
	drop _merge
	gsort individualid year
*Basic information (e.g., names, exam, bar status)
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\basicinformation.dta"
	drop if _merge==2
	drop _merge
	gsort individualid year
*Criminal records
	gen individual_id = individualid 
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\All criminals.dta" 
	drop if _merge==2
	drop _merge
	replace criminal = 0 if criminal==.
	gsort individualid year
*Exclude financial advisors deregistered between 1971 and 2006
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\List of excluded advisors deregistered between 1971 and 2006.dta"
	drop if _merge==2
	drop _merge
	drop if excluded==1
	gsort individualid year
*Exclude not-in-scope financial advisors
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\Not in scope financial advisors.dta"
	drop if _merge==2
	drop _merge
	drop if notinscope==1
	gsort individualid year
	save "D:\Dropbox\19-03-08 JAR Replications\advisor\Main Advisor Sample.dta"
*****************************************************************************************************
*****************************************************************************************************
*The following codes construct main advisory firm sample
*Read raw FINRA advisory firm data 
	use "D:\Dropbox\19-03-08 JAR Replications\firm\basicInformation.dta", clear
	drop if bcscope==""
	gen firmid = firm_id
	gsort firmid
*Get number of advisors with criminal records per firm
	merge 1:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Num advisor with criminal per firm.dta"
	drop if _merge==2
	drop _merge
	gen lnnumadvisor = ln(numadvisor)
	gen lnnumcriminal = ln(1+numcriminal)
*Small firm
	gen small = 0
	replace small = 1 if numadvisor<=150
	replace small = 1 if firmsize=="Small"
*Formation year
	gen formyear = substr(formeddate,-4,.)
	destring(formyear), replace
*Firm expelled
	gen cancel = 0
	replace cancel = 1 if strpos(sanctions_sanctiondetails_messag,"cancel")
	gen expel = 0
	replace expel = 1 if strpos(sanctions_sanctiondetails_messag,"expel")
	replace expel = 1 if expelleddate!=. & expel==0
	gen expel_or_cancel = 0
	replace expel_or_cancel = 1 if cancel==1
	replace expel_or_cancel = 1 if expel==1
*Corporation status
	gen corp = 0
	replace corp = 1 if firmtype=="Corporation"
*Zip code
	merge 1:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\firmAddressDetails.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Address
	merge 1:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\iaFirmAddressDetails.dta", update
	drop if _merge==2
	drop _merge
	gsort firmid
	duplicates drop _all, force
*Registration
	merge 1:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\registrations.dta"
	drop if _merge==2
	drop _merge
	replace mailingaddress_postalcode = officeaddress_postalcode if mailingaddress_postalcode=="" & officeaddress_postalcode!=""
	gsort firmid
*Branch location
	merge m:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\Find location based on branch office.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Zip code
	gen zip5 = substr(mailingaddress_postalcode,1,5)
	gen zip3 = substr(mailingaddress_postalcode,1,3)
	destring(zip3), replace force
	destring(zip5), replace force
	replace zip5 = branchoffice_zipcode if zip5==. & branchoffice_zipcode!=.
	rename zip5 zip
	rename state stateabbr
*State, County, and MSA FIPS
	merge m:1 zip using "D:\Dropbox\19-03-08 JAR Replications\firm\zipcode.dta", keepusing(x y city state statecode county msa)
	drop if _merge==2
	drop _merge
	gen statecounty = state*1000 + county
	gsort firmid
*City ID
	egen cityid = group(city)
*State ID
	egen formstate_id = group(formedstate)
*Control variables
	gen referral = 0
	replace referral = 1 if referotherbd=="N"
	gen affil = 0
	replace affil=1 if hasaffliation=="Y"
	foreach var in referral affil businesstypecount approvedstateregistrationcount{
		replace `var' = 0 if `var'==.
	}
	gen lnbusinesstypecount = ln(1+businesstypecount)
	gen lnstatereg = ln(1+approvedstateregistrationcount)
*Identify firms that hire advisors with pre-advisor criminal records
	merge 1:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\List of firm which hire advisor with pre-advisor criminal records.dta"
	drop if _merge==2
	drop _merge
	replace firmhire_preadvisor_criminal=0 if firmhire_preadvisor_criminal==.
	gsort firmid
*Identify the fraction of advisors with pre-advisor criminal records
	merge 1:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Fraction of advisors with pre-advisor criminal records.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*SEC ADV form 2017 Data
	merge m:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\2017 Data cleaned.dta" 
	drop if _merge==2
	drop _merge
	gsort firmid
*Retail
	merge m:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Identify retail investment advisers based on 2010-2017 data.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Number of firm regulatory disclosure
	merge m:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\Regulatory event per firm active only.dta"
	drop if _merge==2
	drop _merge
	replace disclosurecount = 0 if disclosurecount==.
	gen lndisclosurecount = ln(1+disclosurecount)
	gsort firmid
*High-risk brokerage
	gen regfirm_90 = 0
	replace regfirm_90 = 1 if disclosurecount>=9 & disclosurecount!=.
*Fee structure
	merge m:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Identify fee structure.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Number of accounts
	gen num_of_accounts = 0
	replace num_of_accounts = _5f_2_f if _5f_2_f!=.
	gen mil_num_of_accounts = num_of_accounts/1000000
*Missing variable indicator
	gen missing_indicator = 0
	replace missing_indicator = 1 if retail==.
	save "D:\Dropbox\19-03-08 JAR Replications\firm\Main Advisory Firm Sample.dta"
*****************************************************************************************************
*****************************************************************************************************
*****      The follwing codes replicate Tables 1-10 in "Financial Gatekeepers and Investor  	***** 
*****        Protection: Evidence from Criminal Background Checks" by Kelvin K. F. Law         	***** 
*****                 and Lillian F. Mills (2019, Journal of Accounting Research) 				***** 
*****                                    Version: March 8, 2019									***** 
*****************************************************************************************************
*****************************************************************************************************
log using "D:\Dropbox\19-03-08 JAR Replications\Tables 1-10"
global path "D:\Dropbox\19-03-08 JAR Replications"
*Table 1A: Overview of Criminal Records: By Year
	use "$path\Data for Table 01A.dta", clear
	levelsof year, local(levelofyear) clean
*Column 1: #Financial advisors with criminal records by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if criminal==1 & year==`k'
	}
	distinct individualid if criminal==1
*Column 2: #Financial advisors by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if year==`k'
	}
	distinct individualid
*Column 3: #Criminal records that are felony by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if felony==1 & year==`k'
	}
	distinct individualid if felony==1
	forvalues k = 2007(1)2017 {
		gdistinct individualid if misdemeanor==1 & year==`k'
	}
	distinct individualid if misdemeanor==1
*Column 4: #Male financial advisors by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if male==1 & year==`k'
	}
	gdistinct individualid if male==1
*Column 4: #Male financial advisors with criminal records by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if male==1 & criminal==1 & year==`k'
	}
	gdistinct individualid if male==1 & criminal==1
*****************************************************************************************************
*Table 1B: Overview of Criminal Records: By Charge
	use "$path\Data for Table 01B.dta", clear
*Column 1: # Criminal records
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1
	}
	tab charge_type
*Column 2: % Felony
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & charge_type=="FELONY"
	}
	sum dum if charge_type=="FELONY"
*Column 3: % Misdemeanor
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & charge_type=="MISDEMEANOR"
	}
	sum dum if charge_type=="MISDEMEANOR"
*Column 4: % Dismissed
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & dismissed==1
	}
	sum dismissed
*Column 5: % Male
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & male==1
	}
	sum male
*****************************************************************************************************
*Table 1C: Overview of Criminal Records: By Geography
*Top 5 cities: more than 2,000 advisors
	use "$path\Data for Table 01C.dta", clear
	keep if numadvisor>=2000
	gsort -ratio_criminal 
	gen id = _n
	keep if id<=5
	drop id
	list
*Top 5 cities: less than 2,000 advisors
	use "$path\Data for Table 01C.dta", clear
	keep if criminal>=30 & numadvisor<2000
	gsort -ratio_criminal 
	drop criminal
	gen id = _n
	keep if id<=5
	drop id
	list
*****************************************************************************************************
*Table 3A: Profiling of Financial Advisors with Criminal Records: Pre- and Post-Advisor Criminal Records
	use "$path\Data for Table 03A.dta", clear
	label variable criminal 		"Criminal record"
	label variable male 			"Male"
	label variable minority 		"Minority"
	label variable hb 				"Minority (excluding Asian names)"
	label variable felony 			"Felony"
	label variable misdemeanor 		"Misdemeanor"
*Column 1
	reghdfe criminal male minority, absorb(startingyear cityid)
*Column 2
	reghdfe felony male minority, absorb(startingyear cityid)
*Column 3
	reghdfe misdemeanor male minority, absorb(startingyear cityid)
*Column 4
	reghdfe criminal male hb, absorb(startingyear cityid)
*Column 5
	reghdfe felony male hb, absorb(startingyear cityid)
*Column 6
	reghdfe misdemeanor male hb, absorb(startingyear cityid)
*Summary statistics for Table 2
	tabstat criminal felony misdemeanor male minority hb if e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 3B: Profiling of Financial Advisors with Criminal Records: Pre-Advisor Criminal Records Only
	use "$path\Data for Table 03B.dta", clear
	label variable preadvisor_criminal 		"Pre-advisor criminal record"
	label variable male 					"Male"
	label variable minority 				"Minority"
	label variable hb 						"Minority (excluding Asian names)"
	label variable preadvisor_felony 		"Pre-advisor felony"
	label variable preadvisor_misdemeanor 	"Pre-advisor misdemeanor"
*Column 1
	reghdfe preadvisor_criminal male minority, absorb(startingyear cityid)
*Column 2
	reghdfe preadvisor_felony male minority, absorb(startingyear cityid)
*Column 3
	reghdfe preadvisor_misdemeanor male minority, absorb(startingyear cityid)
*Column 4
	reghdfe preadvisor_criminal male hb, absorb(startingyear cityid)
*Column 5
	reghdfe preadvisor_felony male hb, absorb(startingyear cityid)
*Column 6
	reghdfe preadvisor_misdemeanor male hb, absorb(startingyear cityid)
*Summary statistics for Table 2
	tabstat preadvisor_criminal preadvisor_felony preadvisor_misdemeanor male minority hb if e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 4: Who Hires Financial Advisors with Criminal Records?
*Table 10B: Do Investors Face Higher Exposure to Service Disruption?: Firm Expelled
	use "$path\Data for Table 04 and 10B.dta", clear
	label variable firmhire_preadvisor_criminal 	"Hiring advisor with pre-advisor criminal record"
	label variable pct_firmhire_pre 				"% Pre-advisor criminal record at advisory firm"
	label variable highrisk_brokerage 				"High-risk brokerage"
	label variable expel_or_cancel 					"Firm expelled"
	label variable small 							"Small firm"
	label variable solo 							"Solo firm"
	label variable corp 							"Corporation"
	label variable referral 						"Referral business"
	label variable affil 							"Affiliated"
	label variable num_business_lines 				"Number of business lines (Ln)"
	label variable lnnum_state_reg 					"Number of state registrations (Ln)"
	label variable retail 							"Retail"
	label variable mil_num_of_accounts 				"Number of accounts (in million)"
	label variable prt_aum 							"Percentage of asset"
	label variable hourly 							"Hourly charge"
	label variable fixed 							"Fixed fee"
	label variable commissions 						"Commission"
	label variable performancebased 				"Performance"
	label variable missing_indicator 				"Missing indicator"
*Table 4: Column 1
	reghdfe firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 4: Column 2
	reghdfe firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*Table 4: Column 3
	reghdfe pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 4: Column 4
	reghdfe pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*Summary statistics
	tabstat firmhire_preadvisor_criminal pct_firmhire_pre expel_or_cancel highrisk_brokerage small solo corp referral affil num_business_lines num_state_reg if e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
	tabstat retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased if missing_indicator==0 & e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
*Table 10B: Column 1
	reghdfe expel_or_cancel firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 10B: Column 2
	reghdfe expel_or_cancel firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*Table 10B: Column 3
	reghdfe expel_or_cancel pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 10B: Column 4
	reghdfe expel_or_cancel pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*****************************************************************************************************
*Table 5: Where Do Hiring Firms Cluster?
	use "$path\Data for Table 05.dta", clear
	label variable firmhire_preadvisor_criminal 	"Pre-advisor criminal record at advisory firm"
	label variable pct_firmhire_pre 				"% Pre-advisor criminal record at advisory firm"
	label variable retireperhousehold 				"Retirement income"
	label variable lnretireperhousehold 			"Retirement income (Ln)"
	label variable area_wealthy_retirees 			"Area populated with wealthy retirees"
	label variable pop 								"Population"
	label variable lnpop 							"Population (Ln)"
	label variable income 							"Income"
	label variable lnincome 						"Income (Ln)"
	label variable medianage 						"Age (median)"
	label variable malefemaleratio 					"Male-to-female ratio"
	label variable pct_white 						"% White"
	label variable collegeabove 					"% College and above"
	label variable laborforce 						"% Labor force"
*Column 1
	reghdfe firmhire_preadvisor_criminal lnretireperhousehold lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Column 2
	reghdfe firmhire_preadvisor_criminal area_wealthy_retirees lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Column 3
	reghdfe pct_firmhire_pre lnretireperhousehold lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Column 4
	reghdfe pct_firmhire_pre area_wealthy_retirees lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Summary statistics for Table 2
	tabstat retireperhousehold area_wealthy_retirees pop income medianage malefemaleratio pct_white collegeabove laborforce if e(sample)==1, column(statistics) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 6: Predicting Post-Advisor Criminal Records
*Table 7A: Predicting Customer Complaints and Settlements: Baseline Matched Sample
*Table 10A: Do Investors Face Higher Exposure to Service Disruption?: Advisor Suspended and Advisor Barred
	use "$path\Data for Table 06, 07A, and 10A.dta", clear
	label variable futurecriminal 			"Post-advisor criminal record"
	label variable futurelien 				"Personal lien or judgment"
	label variable futurecivil 				"Civil litigation"
	label variable customer_complaint 		"Customer complaint"
	label variable complaint_with_merit 	"Complaint with merit"
	label variable settled_complaint 		"Settled complaint"
	label variable lareg_settlement 		"Large settlement"
	label variable suspend 					"Advisor suspended"
	label variable bar 						"Advisor barred"
	label variable preadvisor 				"Pre-advisor criminal record"
	label variable firmsize 				"Firm size"
	label variable lnfirmsize 				"Firm size (Ln)"
	label variable avgperjob 				"Tenure per firm"
	label variable lnavgperjob 				"Tenure per firm (Ln)"
	label variable years_in_profession 		"Years in profession"
	label variable lnyears_in_profession 	"Years in profession (Ln)"
	label variable advisor 					"Investment adviser"
	label variable stateexamcount 			"Number of state exams"
	label variable principalexamcount 		"Number of principal exams"
	label variable productexamcount 		"Number of product exams"
	label variable lapse 					"Years since pre-advisor record"
	label variable numfirm 					"Number of advisory firms"
	label variable num_separation 			"Resigned after allegations"
	label variable ownerstopexec 			"Top executive or owner"
	label variable branchid 				"Branch ID"
	label variable since 					"Cohort year"
*Table 6, column 1
	reghdfe futurecriminal preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 6, column 2
	reghdfe futurelien preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 6, column 3
	reghdfe futurecivil preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 1
	reghdfe customer_complaint preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 2
	reghdfe complaint_with_merit preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 3
	reghdfe settled_complaint preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 4
	reghdfe lareg_settlement preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 10, panel A, column 1
	reghdfe suspend preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 10, panel A, column 2
	reghdfe bar preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Summary statistics for Table 2
	tabstat preadvisor futurecriminal futurelien futurecivil customer_complaint complaint_with_merit settle lareg_settlement years_in_profession numfirm avgperjob num_separation ownerstopexec suspend bar firmsize advisor stateexamcount principalexamcount productexamcount lapse if e(sample)==1, column(statistics) statistics(mean sd p25 p50 p75 n)
	tabstat lapse if e(sample)==1 & lapse>0, column(statistics) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 7B: Predicting Customer Complaints and Settlements: Alternative Matched Sample
	use "$path\Data for Table 07B.dta", clear
	label variable customer_complaint 		"Customer complaint"
	label variable complaint_with_merit 	"Complaint with merit"
	label variable settled_complaint 		"Settled complaint"
	label variable lareg_settlement 		"Large settlement"
	label variable preadvisor_criminal 		"Pre-advisor criminal record"
	label variable lnavgperjob 				"Tenure per firm (Ln)"
	label variable lnyears_in_profession 	"Years in profession (Ln)"
	label variable advisor 					"Investment adviser"
	label variable stateexamcount 			"Number of state exams"
	label variable principalexamcount 		"Number of principal exams"
	label variable productexamcount 		"Number of product exams"
	label variable branchid 				"Branch ID"
	label variable year 					"Year"
	label variable since 					"Cohort year"
*Column 1
	reghdfe customer_complaint preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Column 2
	reghdfe complaint_with_merit preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Column 3
	reghdfe settled_complaint preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Column 4
	reghdfe lareg_settlement preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Summary statistics for Table 2
	tabstat customer_complaint complaint_with_merit settled_complaint lareg_settlement if e(sample)==1, statistics(mean sd p25 p50 p75 n) column(statistics)
*****************************************************************************************************
*Table 8: Are Investors Compensated with Higher Returns?
	use "$path\Data for Table 08.dta", clear
	label variable ret_nohire 	"Clean (no advisors with pre-advisor criminal records)"
	label variable ret_highrisk "High (High % of advisors with pre-advisor criminal records)"
	label variable high_no 		"Clean - High"
	label variable mktrf		"Market"
	label variable smb			"Small-minus-big"
	label variable hml			"High-minus-low"
	label variable umd			"Momentum"
	label variable ps_vwf		"Liquidity"
	label variable st_rev		"Short-term reversal"
	label variable lt_rev		"Long-term reversal"
*Fama-French 3-factor model
	foreach var in ret_nohire ret_highrisk high_no {
	newey `var' mktrf smb hml, lag(4)
	}
*Carhart 4-factor model
	foreach var in ret_nohire ret_highrisk high_no {
	newey `var' mktrf smb hml umd, lag(4)
	}
*7-factor model
	foreach var in ret_nohire ret_highrisk high_no {
	newey `var' mktrf smb hml umd ps_vwf st_rev lt_rev, lag(4)
	}
*****************************************************************************************************
*Table 9, column 1: Are Investors Compensated with Lower Fees?: Expense Ratio
	use "$path\Data for Table 09_1.dta", clear
	label variable exp_ratio 	"Expense ratio"
	label variable highrisk 	"Top hiring firm"
	label variable indexfund 	"Index fund"
	label variable nav_latest 	"Assets under management"
	label variable lnnav_latest "Assets under management (Ln)"
	label variable age 			"Fund age"
	label variable lnage 		"Fund age (Ln)"
	label variable turn_ratio 	"Turnover ratio"
	label variable objid 		"Style"
	label variable year 		"Year"
	label variable crsp_fundno 	"CRSP_FUNDNO"
*Column 1
	xi: areg exp_ratio i.year highrisk indexfund lnnav_latest lnage turn_ratio, r absorb(objid) cluster(crsp_fundno)
	tabstat exp_ratio highrisk indexfund nav_latest age turn_ratio if e(sample)==1, statistics(mean sd p25 p50 p75 n) column(statistics)
*****************************************************************************************************
*Table 9, columns 2 and 3: Are Investors Compensated with Lower Fees?: Maximum Initial Purchase Charge and Average Initial Purchase Charge
	use "$path\Data for Table 09_2-3.dta", clear
	label variable maxfront 	"Maximum initial purchase charge"
	label variable meanfront 	"Average initial purchase charge"
	label variable highrisk 	"Top hiring firm"
	label variable indexfund 	"Index fund"
	label variable objid 		"Style"
	label variable vintage		"Vintage"
	label variable crsp_fundno 	"CRSP_FUNDNO"
*Column 2
	xi: areg maxfront i.vintage highrisk indexfund, r absorb(objid) cluster(crsp_fundno)
*Column 3
	xi: areg meanfront i.vintage highrisk indexfund, r absorb(objid) cluster(crsp_fundno)
*Summary statistics for Table 2
	tabstat maxfront meanfront highrisk indexfund if e(sample)==1, statistics(mean sd p25 p50 p75 n) column(statistics)
*****************************************************************************************************
log close
*****************************************************************************************************
*****************************************************************************************************
*****      The follwing codes replicate the Main Samples in "Financial Gatekeepers and   	    ***** 
*****        Investor Protection: Evidence from Criminal Background Checks"          	        ***** 
*****        by Kelvin K. F. Law and Lillian F. Mills (2019, Journal of Accounting Research)	***** 
*****                                    Version: March 8, 2019									***** 
*****************************************************************************************************
*****************************************************************************************************
*The following codes construct main advisor sample
*Read raw FINRA employment data 
	use "D:\Dropbox\19-03-08 JAR Replications\advisor\employment_combined.dta", clear
*Construct advisor-year panel
	keep individualid firmid begin end zip5
	gduplicates drop _all, force
	gsort individualid begin firmid 
	drop if begin==.
	gen begyear = year(begin)
	gen endyear = year(end)
	gen length = endyear - begyear + 1
	gen recordid = _n
	expand(length)
	gsort recordid
	by recordid: gen id = _n
	gen year = begyear + id - 1
	rename id tenure
	drop if year(end)<year & end!=. & year!=.
	drop begyear endyear length
	gduplicates drop _all, force
	gsort recordid year begin 
*Years in profession
	by individualid, sort: egen since = min(year)
	gen genexp = year - since + 1 if since>=1946
	gsort recordid year begin 
*Firm size
	preserve
	keep year firmid individualid 
	gduplicates drop year firmid individualid, force
	gen dum = 1
	gcollapse (sum) firmsize = dum, by(firmid year)
	tempfile temp1
	save "`temp1'", replace
	restore
	merge m:1 firmid year using "`temp1'"
	drop if _merge==2
	drop _merge
	gsort recordid year begin 
*Branch size
	preserve
	keep year firmid individualid zip5
	drop if zip5==.
	drop if firmid==.
	gduplicates drop year firmid individualid zip5, force
	gen dum = 1
	gcollapse (sum) branchsize = dum, by(firmid zip5 year)
	tempfile temp2
	save "`temp2'", replace
	restore
	merge m:1 firmid zip5 year using "`temp2'"
	drop if _merge==2
	drop _merge
	gsort recordid year begin 
*One advisor obs per year
	egen groupid = group(individualid year)
	sort groupid firmsize
	by groupid: gen id = _n
	by groupid: egen maxid = max(id)
	keep if maxid==id
	drop groupid maxid id
	gsort recordid year begin 
	gduplicates drop individualid year, force
*Gender
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\Individual ID gender data.dta"
	drop if _merge==2
	drop _merge
	gsort individualid year
*Basic information (e.g., names, exam, bar status)
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\basicinformation.dta"
	drop if _merge==2
	drop _merge
	gsort individualid year
*Criminal records
	gen individual_id = individualid 
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\All criminals.dta" 
	drop if _merge==2
	drop _merge
	replace criminal = 0 if criminal==.
	gsort individualid year
*Exclude financial advisors deregistered between 1971 and 2006
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\List of excluded advisors deregistered between 1971 and 2006.dta"
	drop if _merge==2
	drop _merge
	drop if excluded==1
	gsort individualid year
*Exclude not-in-scope financial advisors
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\Not in scope financial advisors.dta"
	drop if _merge==2
	drop _merge
	drop if notinscope==1
	gsort individualid year
	save "D:\Dropbox\19-03-08 JAR Replications\advisor\Main Advisor Sample.dta"
*****************************************************************************************************
*****************************************************************************************************
*The following codes construct main advisory firm sample
*Read raw FINRA advisory firm data 
	use "D:\Dropbox\19-03-08 JAR Replications\firm\basicInformation.dta", clear
	drop if bcscope==""
	gen firmid = firm_id
	gsort firmid
*Get number of advisors with criminal records per firm
	merge 1:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Num advisor with criminal per firm.dta"
	drop if _merge==2
	drop _merge
	gen lnnumadvisor = ln(numadvisor)
	gen lnnumcriminal = ln(1+numcriminal)
*Small firm
	gen small = 0
	replace small = 1 if numadvisor<=150
	replace small = 1 if firmsize=="Small"
*Formation year
	gen formyear = substr(formeddate,-4,.)
	destring(formyear), replace
*Firm expelled
	gen cancel = 0
	replace cancel = 1 if strpos(sanctions_sanctiondetails_messag,"cancel")
	gen expel = 0
	replace expel = 1 if strpos(sanctions_sanctiondetails_messag,"expel")
	replace expel = 1 if expelleddate!=. & expel==0
	gen expel_or_cancel = 0
	replace expel_or_cancel = 1 if cancel==1
	replace expel_or_cancel = 1 if expel==1
*Corporation status
	gen corp = 0
	replace corp = 1 if firmtype=="Corporation"
*Zip code
	merge 1:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\firmAddressDetails.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Address
	merge 1:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\iaFirmAddressDetails.dta", update
	drop if _merge==2
	drop _merge
	gsort firmid
	duplicates drop _all, force
*Registration
	merge 1:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\registrations.dta"
	drop if _merge==2
	drop _merge
	replace mailingaddress_postalcode = officeaddress_postalcode if mailingaddress_postalcode=="" & officeaddress_postalcode!=""
	gsort firmid
*Branch location
	merge m:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\Find location based on branch office.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Zip code
	gen zip5 = substr(mailingaddress_postalcode,1,5)
	gen zip3 = substr(mailingaddress_postalcode,1,3)
	destring(zip3), replace force
	destring(zip5), replace force
	replace zip5 = branchoffice_zipcode if zip5==. & branchoffice_zipcode!=.
	rename zip5 zip
	rename state stateabbr
*State, County, and MSA FIPS
	merge m:1 zip using "D:\Dropbox\19-03-08 JAR Replications\firm\zipcode.dta", keepusing(x y city state statecode county msa)
	drop if _merge==2
	drop _merge
	gen statecounty = state*1000 + county
	gsort firmid
*City ID
	egen cityid = group(city)
*State ID
	egen formstate_id = group(formedstate)
*Control variables
	gen referral = 0
	replace referral = 1 if referotherbd=="N"
	gen affil = 0
	replace affil=1 if hasaffliation=="Y"
	foreach var in referral affil businesstypecount approvedstateregistrationcount{
		replace `var' = 0 if `var'==.
	}
	gen lnbusinesstypecount = ln(1+businesstypecount)
	gen lnstatereg = ln(1+approvedstateregistrationcount)
*Identify firms that hire advisors with pre-advisor criminal records
	merge 1:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\List of firm which hire advisor with pre-advisor criminal records.dta"
	drop if _merge==2
	drop _merge
	replace firmhire_preadvisor_criminal=0 if firmhire_preadvisor_criminal==.
	gsort firmid
*Identify the fraction of advisors with pre-advisor criminal records
	merge 1:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Fraction of advisors with pre-advisor criminal records.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*SEC ADV form 2017 Data
	merge m:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\2017 Data cleaned.dta" 
	drop if _merge==2
	drop _merge
	gsort firmid
*Retail
	merge m:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Identify retail investment advisers based on 2010-2017 data.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Number of firm regulatory disclosure
	merge m:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\Regulatory event per firm active only.dta"
	drop if _merge==2
	drop _merge
	replace disclosurecount = 0 if disclosurecount==.
	gen lndisclosurecount = ln(1+disclosurecount)
	gsort firmid
*High-risk brokerage
	gen regfirm_90 = 0
	replace regfirm_90 = 1 if disclosurecount>=9 & disclosurecount!=.
*Fee structure
	merge m:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Identify fee structure.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Number of accounts
	gen num_of_accounts = 0
	replace num_of_accounts = _5f_2_f if _5f_2_f!=.
	gen mil_num_of_accounts = num_of_accounts/1000000
*Missing variable indicator
	gen missing_indicator = 0
	replace missing_indicator = 1 if retail==.
	save "D:\Dropbox\19-03-08 JAR Replications\firm\Main Advisory Firm Sample.dta"
*****************************************************************************************************
*****************************************************************************************************
*****      The follwing codes replicate Tables 1-10 in "Financial Gatekeepers and Investor  	***** 
*****        Protection: Evidence from Criminal Background Checks" by Kelvin K. F. Law         	***** 
*****                 and Lillian F. Mills (2019, Journal of Accounting Research) 				***** 
*****                                    Version: March 8, 2019									***** 
*****************************************************************************************************
*****************************************************************************************************
log using "D:\Dropbox\19-03-08 JAR Replications\Tables 1-10"
global path "D:\Dropbox\19-03-08 JAR Replications"
*Table 1A: Overview of Criminal Records: By Year
	use "$path\Data for Table 01A.dta", clear
	levelsof year, local(levelofyear) clean
*Column 1: #Financial advisors with criminal records by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if criminal==1 & year==`k'
	}
	distinct individualid if criminal==1
*Column 2: #Financial advisors by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if year==`k'
	}
	distinct individualid
*Column 3: #Criminal records that are felony by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if felony==1 & year==`k'
	}
	distinct individualid if felony==1
	forvalues k = 2007(1)2017 {
		gdistinct individualid if misdemeanor==1 & year==`k'
	}
	distinct individualid if misdemeanor==1
*Column 4: #Male financial advisors by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if male==1 & year==`k'
	}
	gdistinct individualid if male==1
*Column 4: #Male financial advisors with criminal records by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if male==1 & criminal==1 & year==`k'
	}
	gdistinct individualid if male==1 & criminal==1
*****************************************************************************************************
*Table 1B: Overview of Criminal Records: By Charge
	use "$path\Data for Table 01B.dta", clear
*Column 1: # Criminal records
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1
	}
	tab charge_type
*Column 2: % Felony
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & charge_type=="FELONY"
	}
	sum dum if charge_type=="FELONY"
*Column 3: % Misdemeanor
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & charge_type=="MISDEMEANOR"
	}
	sum dum if charge_type=="MISDEMEANOR"
*Column 4: % Dismissed
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & dismissed==1
	}
	sum dismissed
*Column 5: % Male
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & male==1
	}
	sum male
*****************************************************************************************************
*Table 1C: Overview of Criminal Records: By Geography
*Top 5 cities: more than 2,000 advisors
	use "$path\Data for Table 01C.dta", clear
	keep if numadvisor>=2000
	gsort -ratio_criminal 
	gen id = _n
	keep if id<=5
	drop id
	list
*Top 5 cities: less than 2,000 advisors
	use "$path\Data for Table 01C.dta", clear
	keep if criminal>=30 & numadvisor<2000
	gsort -ratio_criminal 
	drop criminal
	gen id = _n
	keep if id<=5
	drop id
	list
*****************************************************************************************************
*Table 3A: Profiling of Financial Advisors with Criminal Records: Pre- and Post-Advisor Criminal Records
	use "$path\Data for Table 03A.dta", clear
	label variable criminal 		"Criminal record"
	label variable male 			"Male"
	label variable minority 		"Minority"
	label variable hb 				"Minority (excluding Asian names)"
	label variable felony 			"Felony"
	label variable misdemeanor 		"Misdemeanor"
*Column 1
	reghdfe criminal male minority, absorb(startingyear cityid)
*Column 2
	reghdfe felony male minority, absorb(startingyear cityid)
*Column 3
	reghdfe misdemeanor male minority, absorb(startingyear cityid)
*Column 4
	reghdfe criminal male hb, absorb(startingyear cityid)
*Column 5
	reghdfe felony male hb, absorb(startingyear cityid)
*Column 6
	reghdfe misdemeanor male hb, absorb(startingyear cityid)
*Summary statistics for Table 2
	tabstat criminal felony misdemeanor male minority hb if e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 3B: Profiling of Financial Advisors with Criminal Records: Pre-Advisor Criminal Records Only
	use "$path\Data for Table 03B.dta", clear
	label variable preadvisor_criminal 		"Pre-advisor criminal record"
	label variable male 					"Male"
	label variable minority 				"Minority"
	label variable hb 						"Minority (excluding Asian names)"
	label variable preadvisor_felony 		"Pre-advisor felony"
	label variable preadvisor_misdemeanor 	"Pre-advisor misdemeanor"
*Column 1
	reghdfe preadvisor_criminal male minority, absorb(startingyear cityid)
*Column 2
	reghdfe preadvisor_felony male minority, absorb(startingyear cityid)
*Column 3
	reghdfe preadvisor_misdemeanor male minority, absorb(startingyear cityid)
*Column 4
	reghdfe preadvisor_criminal male hb, absorb(startingyear cityid)
*Column 5
	reghdfe preadvisor_felony male hb, absorb(startingyear cityid)
*Column 6
	reghdfe preadvisor_misdemeanor male hb, absorb(startingyear cityid)
*Summary statistics for Table 2
	tabstat preadvisor_criminal preadvisor_felony preadvisor_misdemeanor male minority hb if e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 4: Who Hires Financial Advisors with Criminal Records?
*Table 10B: Do Investors Face Higher Exposure to Service Disruption?: Firm Expelled
	use "$path\Data for Table 04 and 10B.dta", clear
	label variable firmhire_preadvisor_criminal 	"Hiring advisor with pre-advisor criminal record"
	label variable pct_firmhire_pre 				"% Pre-advisor criminal record at advisory firm"
	label variable highrisk_brokerage 				"High-risk brokerage"
	label variable expel_or_cancel 					"Firm expelled"
	label variable small 							"Small firm"
	label variable solo 							"Solo firm"
	label variable corp 							"Corporation"
	label variable referral 						"Referral business"
	label variable affil 							"Affiliated"
	label variable num_business_lines 				"Number of business lines (Ln)"
	label variable lnnum_state_reg 					"Number of state registrations (Ln)"
	label variable retail 							"Retail"
	label variable mil_num_of_accounts 				"Number of accounts (in million)"
	label variable prt_aum 							"Percentage of asset"
	label variable hourly 							"Hourly charge"
	label variable fixed 							"Fixed fee"
	label variable commissions 						"Commission"
	label variable performancebased 				"Performance"
	label variable missing_indicator 				"Missing indicator"
*Table 4: Column 1
	reghdfe firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 4: Column 2
	reghdfe firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*Table 4: Column 3
	reghdfe pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 4: Column 4
	reghdfe pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*Summary statistics
	tabstat firmhire_preadvisor_criminal pct_firmhire_pre expel_or_cancel highrisk_brokerage small solo corp referral affil num_business_lines num_state_reg if e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
	tabstat retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased if missing_indicator==0 & e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
*Table 10B: Column 1
	reghdfe expel_or_cancel firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 10B: Column 2
	reghdfe expel_or_cancel firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*Table 10B: Column 3
	reghdfe expel_or_cancel pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 10B: Column 4
	reghdfe expel_or_cancel pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*****************************************************************************************************
*Table 5: Where Do Hiring Firms Cluster?
	use "$path\Data for Table 05.dta", clear
	label variable firmhire_preadvisor_criminal 	"Pre-advisor criminal record at advisory firm"
	label variable pct_firmhire_pre 				"% Pre-advisor criminal record at advisory firm"
	label variable retireperhousehold 				"Retirement income"
	label variable lnretireperhousehold 			"Retirement income (Ln)"
	label variable area_wealthy_retirees 			"Area populated with wealthy retirees"
	label variable pop 								"Population"
	label variable lnpop 							"Population (Ln)"
	label variable income 							"Income"
	label variable lnincome 						"Income (Ln)"
	label variable medianage 						"Age (median)"
	label variable malefemaleratio 					"Male-to-female ratio"
	label variable pct_white 						"% White"
	label variable collegeabove 					"% College and above"
	label variable laborforce 						"% Labor force"
*Column 1
	reghdfe firmhire_preadvisor_criminal lnretireperhousehold lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Column 2
	reghdfe firmhire_preadvisor_criminal area_wealthy_retirees lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Column 3
	reghdfe pct_firmhire_pre lnretireperhousehold lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Column 4
	reghdfe pct_firmhire_pre area_wealthy_retirees lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Summary statistics for Table 2
	tabstat retireperhousehold area_wealthy_retirees pop income medianage malefemaleratio pct_white collegeabove laborforce if e(sample)==1, column(statistics) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 6: Predicting Post-Advisor Criminal Records
*Table 7A: Predicting Customer Complaints and Settlements: Baseline Matched Sample
*Table 10A: Do Investors Face Higher Exposure to Service Disruption?: Advisor Suspended and Advisor Barred
	use "$path\Data for Table 06, 07A, and 10A.dta", clear
	label variable futurecriminal 			"Post-advisor criminal record"
	label variable futurelien 				"Personal lien or judgment"
	label variable futurecivil 				"Civil litigation"
	label variable customer_complaint 		"Customer complaint"
	label variable complaint_with_merit 	"Complaint with merit"
	label variable settled_complaint 		"Settled complaint"
	label variable lareg_settlement 		"Large settlement"
	label variable suspend 					"Advisor suspended"
	label variable bar 						"Advisor barred"
	label variable preadvisor 				"Pre-advisor criminal record"
	label variable firmsize 				"Firm size"
	label variable lnfirmsize 				"Firm size (Ln)"
	label variable avgperjob 				"Tenure per firm"
	label variable lnavgperjob 				"Tenure per firm (Ln)"
	label variable years_in_profession 		"Years in profession"
	label variable lnyears_in_profession 	"Years in profession (Ln)"
	label variable advisor 					"Investment adviser"
	label variable stateexamcount 			"Number of state exams"
	label variable principalexamcount 		"Number of principal exams"
	label variable productexamcount 		"Number of product exams"
	label variable lapse 					"Years since pre-advisor record"
	label variable numfirm 					"Number of advisory firms"
	label variable num_separation 			"Resigned after allegations"
	label variable ownerstopexec 			"Top executive or owner"
	label variable branchid 				"Branch ID"
	label variable since 					"Cohort year"
*Table 6, column 1
	reghdfe futurecriminal preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 6, column 2
	reghdfe futurelien preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 6, column 3
	reghdfe futurecivil preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 1
	reghdfe customer_complaint preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 2
	reghdfe complaint_with_merit preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 3
	reghdfe settled_complaint preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 4
	reghdfe lareg_settlement preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 10, panel A, column 1
	reghdfe suspend preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 10, panel A, column 2
	reghdfe bar preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Summary statistics for Table 2
	tabstat preadvisor futurecriminal futurelien futurecivil customer_complaint complaint_with_merit settle lareg_settlement years_in_profession numfirm avgperjob num_separation ownerstopexec suspend bar firmsize advisor stateexamcount principalexamcount productexamcount lapse if e(sample)==1, column(statistics) statistics(mean sd p25 p50 p75 n)
	tabstat lapse if e(sample)==1 & lapse>0, column(statistics) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 7B: Predicting Customer Complaints and Settlements: Alternative Matched Sample
	use "$path\Data for Table 07B.dta", clear
	label variable customer_complaint 		"Customer complaint"
	label variable complaint_with_merit 	"Complaint with merit"
	label variable settled_complaint 		"Settled complaint"
	label variable lareg_settlement 		"Large settlement"
	label variable preadvisor_criminal 		"Pre-advisor criminal record"
	label variable lnavgperjob 				"Tenure per firm (Ln)"
	label variable lnyears_in_profession 	"Years in profession (Ln)"
	label variable advisor 					"Investment adviser"
	label variable stateexamcount 			"Number of state exams"
	label variable principalexamcount 		"Number of principal exams"
	label variable productexamcount 		"Number of product exams"
	label variable branchid 				"Branch ID"
	label variable year 					"Year"
	label variable since 					"Cohort year"
*Column 1
	reghdfe customer_complaint preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Column 2
	reghdfe complaint_with_merit preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Column 3
	reghdfe settled_complaint preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Column 4
	reghdfe lareg_settlement preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Summary statistics for Table 2
	tabstat customer_complaint complaint_with_merit settled_complaint lareg_settlement if e(sample)==1, statistics(mean sd p25 p50 p75 n) column(statistics)
*****************************************************************************************************
*Table 8: Are Investors Compensated with Higher Returns?
	use "$path\Data for Table 08.dta", clear
	label variable ret_nohire 	"Clean (no advisors with pre-advisor criminal records)"
	label variable ret_highrisk "High (High % of advisors with pre-advisor criminal records)"
	label variable high_no 		"Clean - High"
	label variable mktrf		"Market"
	label variable smb			"Small-minus-big"
	label variable hml			"High-minus-low"
	label variable umd			"Momentum"
	label variable ps_vwf		"Liquidity"
	label variable st_rev		"Short-term reversal"
	label variable lt_rev		"Long-term reversal"
*Fama-French 3-factor model
	foreach var in ret_nohire ret_highrisk high_no {
	newey `var' mktrf smb hml, lag(4)
	}
*Carhart 4-factor model
	foreach var in ret_nohire ret_highrisk high_no {
	newey `var' mktrf smb hml umd, lag(4)
	}
*7-factor model
	foreach var in ret_nohire ret_highrisk high_no {
	newey `var' mktrf smb hml umd ps_vwf st_rev lt_rev, lag(4)
	}
*****************************************************************************************************
*Table 9, column 1: Are Investors Compensated with Lower Fees?: Expense Ratio
	use "$path\Data for Table 09_1.dta", clear
	label variable exp_ratio 	"Expense ratio"
	label variable highrisk 	"Top hiring firm"
	label variable indexfund 	"Index fund"
	label variable nav_latest 	"Assets under management"
	label variable lnnav_latest "Assets under management (Ln)"
	label variable age 			"Fund age"
	label variable lnage 		"Fund age (Ln)"
	label variable turn_ratio 	"Turnover ratio"
	label variable objid 		"Style"
	label variable year 		"Year"
	label variable crsp_fundno 	"CRSP_FUNDNO"
*Column 1
	xi: areg exp_ratio i.year highrisk indexfund lnnav_latest lnage turn_ratio, r absorb(objid) cluster(crsp_fundno)
	tabstat exp_ratio highrisk indexfund nav_latest age turn_ratio if e(sample)==1, statistics(mean sd p25 p50 p75 n) column(statistics)
*****************************************************************************************************
*Table 9, columns 2 and 3: Are Investors Compensated with Lower Fees?: Maximum Initial Purchase Charge and Average Initial Purchase Charge
	use "$path\Data for Table 09_2-3.dta", clear
	label variable maxfront 	"Maximum initial purchase charge"
	label variable meanfront 	"Average initial purchase charge"
	label variable highrisk 	"Top hiring firm"
	label variable indexfund 	"Index fund"
	label variable objid 		"Style"
	label variable vintage		"Vintage"
	label variable crsp_fundno 	"CRSP_FUNDNO"
*Column 2
	xi: areg maxfront i.vintage highrisk indexfund, r absorb(objid) cluster(crsp_fundno)
*Column 3
	xi: areg meanfront i.vintage highrisk indexfund, r absorb(objid) cluster(crsp_fundno)
*Summary statistics for Table 2
	tabstat maxfront meanfront highrisk indexfund if e(sample)==1, statistics(mean sd p25 p50 p75 n) column(statistics)
*****************************************************************************************************
log close
*****************************************************************************************************
*****************************************************************************************************
*****      The follwing codes replicate the Main Samples in "Financial Gatekeepers and   	    ***** 
*****        Investor Protection: Evidence from Criminal Background Checks"          	        ***** 
*****        by Kelvin K. F. Law and Lillian F. Mills (2019, Journal of Accounting Research)	***** 
*****                                    Version: March 8, 2019									***** 
*****************************************************************************************************
*****************************************************************************************************
*The following codes construct main advisor sample
*Read raw FINRA employment data 
	use "D:\Dropbox\19-03-08 JAR Replications\advisor\employment_combined.dta", clear
*Construct advisor-year panel
	keep individualid firmid begin end zip5
	gduplicates drop _all, force
	gsort individualid begin firmid 
	drop if begin==.
	gen begyear = year(begin)
	gen endyear = year(end)
	gen length = endyear - begyear + 1
	gen recordid = _n
	expand(length)
	gsort recordid
	by recordid: gen id = _n
	gen year = begyear + id - 1
	rename id tenure
	drop if year(end)<year & end!=. & year!=.
	drop begyear endyear length
	gduplicates drop _all, force
	gsort recordid year begin 
*Years in profession
	by individualid, sort: egen since = min(year)
	gen genexp = year - since + 1 if since>=1946
	gsort recordid year begin 
*Firm size
	preserve
	keep year firmid individualid 
	gduplicates drop year firmid individualid, force
	gen dum = 1
	gcollapse (sum) firmsize = dum, by(firmid year)
	tempfile temp1
	save "`temp1'", replace
	restore
	merge m:1 firmid year using "`temp1'"
	drop if _merge==2
	drop _merge
	gsort recordid year begin 
*Branch size
	preserve
	keep year firmid individualid zip5
	drop if zip5==.
	drop if firmid==.
	gduplicates drop year firmid individualid zip5, force
	gen dum = 1
	gcollapse (sum) branchsize = dum, by(firmid zip5 year)
	tempfile temp2
	save "`temp2'", replace
	restore
	merge m:1 firmid zip5 year using "`temp2'"
	drop if _merge==2
	drop _merge
	gsort recordid year begin 
*One advisor obs per year
	egen groupid = group(individualid year)
	sort groupid firmsize
	by groupid: gen id = _n
	by groupid: egen maxid = max(id)
	keep if maxid==id
	drop groupid maxid id
	gsort recordid year begin 
	gduplicates drop individualid year, force
*Gender
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\Individual ID gender data.dta"
	drop if _merge==2
	drop _merge
	gsort individualid year
*Basic information (e.g., names, exam, bar status)
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\basicinformation.dta"
	drop if _merge==2
	drop _merge
	gsort individualid year
*Criminal records
	gen individual_id = individualid 
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\All criminals.dta" 
	drop if _merge==2
	drop _merge
	replace criminal = 0 if criminal==.
	gsort individualid year
*Exclude financial advisors deregistered between 1971 and 2006
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\List of excluded advisors deregistered between 1971 and 2006.dta"
	drop if _merge==2
	drop _merge
	drop if excluded==1
	gsort individualid year
*Exclude not-in-scope financial advisors
	merge m:1 individualid using "D:\Dropbox\19-03-08 JAR Replications\advisor\Not in scope financial advisors.dta"
	drop if _merge==2
	drop _merge
	drop if notinscope==1
	gsort individualid year
	save "D:\Dropbox\19-03-08 JAR Replications\advisor\Main Advisor Sample.dta"
*****************************************************************************************************
*****************************************************************************************************
*The following codes construct main advisory firm sample
*Read raw FINRA advisory firm data 
	use "D:\Dropbox\19-03-08 JAR Replications\firm\basicInformation.dta", clear
	drop if bcscope==""
	gen firmid = firm_id
	gsort firmid
*Get number of advisors with criminal records per firm
	merge 1:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Num advisor with criminal per firm.dta"
	drop if _merge==2
	drop _merge
	gen lnnumadvisor = ln(numadvisor)
	gen lnnumcriminal = ln(1+numcriminal)
*Small firm
	gen small = 0
	replace small = 1 if numadvisor<=150
	replace small = 1 if firmsize=="Small"
*Formation year
	gen formyear = substr(formeddate,-4,.)
	destring(formyear), replace
*Firm expelled
	gen cancel = 0
	replace cancel = 1 if strpos(sanctions_sanctiondetails_messag,"cancel")
	gen expel = 0
	replace expel = 1 if strpos(sanctions_sanctiondetails_messag,"expel")
	replace expel = 1 if expelleddate!=. & expel==0
	gen expel_or_cancel = 0
	replace expel_or_cancel = 1 if cancel==1
	replace expel_or_cancel = 1 if expel==1
*Corporation status
	gen corp = 0
	replace corp = 1 if firmtype=="Corporation"
*Zip code
	merge 1:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\firmAddressDetails.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Address
	merge 1:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\iaFirmAddressDetails.dta", update
	drop if _merge==2
	drop _merge
	gsort firmid
	duplicates drop _all, force
*Registration
	merge 1:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\registrations.dta"
	drop if _merge==2
	drop _merge
	replace mailingaddress_postalcode = officeaddress_postalcode if mailingaddress_postalcode=="" & officeaddress_postalcode!=""
	gsort firmid
*Branch location
	merge m:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\Find location based on branch office.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Zip code
	gen zip5 = substr(mailingaddress_postalcode,1,5)
	gen zip3 = substr(mailingaddress_postalcode,1,3)
	destring(zip3), replace force
	destring(zip5), replace force
	replace zip5 = branchoffice_zipcode if zip5==. & branchoffice_zipcode!=.
	rename zip5 zip
	rename state stateabbr
*State, County, and MSA FIPS
	merge m:1 zip using "D:\Dropbox\19-03-08 JAR Replications\firm\zipcode.dta", keepusing(x y city state statecode county msa)
	drop if _merge==2
	drop _merge
	gen statecounty = state*1000 + county
	gsort firmid
*City ID
	egen cityid = group(city)
*State ID
	egen formstate_id = group(formedstate)
*Control variables
	gen referral = 0
	replace referral = 1 if referotherbd=="N"
	gen affil = 0
	replace affil=1 if hasaffliation=="Y"
	foreach var in referral affil businesstypecount approvedstateregistrationcount{
		replace `var' = 0 if `var'==.
	}
	gen lnbusinesstypecount = ln(1+businesstypecount)
	gen lnstatereg = ln(1+approvedstateregistrationcount)
*Identify firms that hire advisors with pre-advisor criminal records
	merge 1:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\List of firm which hire advisor with pre-advisor criminal records.dta"
	drop if _merge==2
	drop _merge
	replace firmhire_preadvisor_criminal=0 if firmhire_preadvisor_criminal==.
	gsort firmid
*Identify the fraction of advisors with pre-advisor criminal records
	merge 1:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Fraction of advisors with pre-advisor criminal records.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*SEC ADV form 2017 Data
	merge m:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\2017 Data cleaned.dta" 
	drop if _merge==2
	drop _merge
	gsort firmid
*Retail
	merge m:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Identify retail investment advisers based on 2010-2017 data.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Number of firm regulatory disclosure
	merge m:1 firm_id using "D:\Dropbox\19-03-08 JAR Replications\firm\Regulatory event per firm active only.dta"
	drop if _merge==2
	drop _merge
	replace disclosurecount = 0 if disclosurecount==.
	gen lndisclosurecount = ln(1+disclosurecount)
	gsort firmid
*High-risk brokerage
	gen regfirm_90 = 0
	replace regfirm_90 = 1 if disclosurecount>=9 & disclosurecount!=.
*Fee structure
	merge m:1 firmid using "D:\Dropbox\19-03-08 JAR Replications\firm\Identify fee structure.dta"
	drop if _merge==2
	drop _merge
	gsort firmid
*Number of accounts
	gen num_of_accounts = 0
	replace num_of_accounts = _5f_2_f if _5f_2_f!=.
	gen mil_num_of_accounts = num_of_accounts/1000000
*Missing variable indicator
	gen missing_indicator = 0
	replace missing_indicator = 1 if retail==.
	save "D:\Dropbox\19-03-08 JAR Replications\firm\Main Advisory Firm Sample.dta"

*****************************************************************************************************
*****************************************************************************************************
*****      The follwing codes replicate Tables 1-10 in "Financial Gatekeepers and Investor  	***** 
*****        Protection: Evidence from Criminal Background Checks" by Kelvin K. F. Law         	***** 
*****                 and Lillian F. Mills (2019, Journal of Accounting Research) 				***** 
*****                                    Version: March 8, 2019									***** 
*****************************************************************************************************
*****************************************************************************************************
log using "D:\Dropbox\19-03-08 JAR Replications\Tables 1-10"
global path "D:\Dropbox\19-03-08 JAR Replications"
*Table 1A: Overview of Criminal Records: By Year
	use "$path\Data for Table 01A.dta", clear
	levelsof year, local(levelofyear) clean
*Column 1: #Financial advisors with criminal records by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if criminal==1 & year==`k'
	}
	distinct individualid if criminal==1
*Column 2: #Financial advisors by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if year==`k'
	}
	distinct individualid
*Column 3: #Criminal records that are felony by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if felony==1 & year==`k'
	}
	distinct individualid if felony==1
	forvalues k = 2007(1)2017 {
		gdistinct individualid if misdemeanor==1 & year==`k'
	}
	distinct individualid if misdemeanor==1
*Column 4: #Male financial advisors by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if male==1 & year==`k'
	}
	gdistinct individualid if male==1
*Column 4: #Male financial advisors with criminal records by year
	forvalues k = 2007(1)2017 {
		gdistinct individualid if male==1 & criminal==1 & year==`k'
	}
	gdistinct individualid if male==1 & criminal==1
*****************************************************************************************************
*Table 1B: Overview of Criminal Records: By Charge
	use "$path\Data for Table 01B.dta", clear
*Column 1: # Criminal records
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1
	}
	tab charge_type
*Column 2: % Felony
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & charge_type=="FELONY"
	}
	sum dum if charge_type=="FELONY"
*Column 3: % Misdemeanor
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & charge_type=="MISDEMEANOR"
	}
	sum dum if charge_type=="MISDEMEANOR"
*Column 4: % Dismissed
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & dismissed==1
	}
	sum dismissed
*Column 5: % Male
	foreach var in theft fraud substance violent traffic public others{
		sum `var' if `var'==1 & male==1
	}
	sum male
*****************************************************************************************************
*Table 1C: Overview of Criminal Records: By Geography
*Top 5 cities: more than 2,000 advisors
	use "$path\Data for Table 01C.dta", clear
	keep if numadvisor>=2000
	gsort -ratio_criminal 
	gen id = _n
	keep if id<=5
	drop id
	list
*Top 5 cities: less than 2,000 advisors
	use "$path\Data for Table 01C.dta", clear
	keep if criminal>=30 & numadvisor<2000
	gsort -ratio_criminal 
	drop criminal
	gen id = _n
	keep if id<=5
	drop id
	list
*****************************************************************************************************
*Table 3A: Profiling of Financial Advisors with Criminal Records: Pre- and Post-Advisor Criminal Records
	use "$path\Data for Table 03A.dta", clear
	label variable criminal 		"Criminal record"
	label variable male 			"Male"
	label variable minority 		"Minority"
	label variable hb 				"Minority (excluding Asian names)"
	label variable felony 			"Felony"
	label variable misdemeanor 		"Misdemeanor"
*Column 1
	reghdfe criminal male minority, absorb(startingyear cityid)
*Column 2
	reghdfe felony male minority, absorb(startingyear cityid)
*Column 3
	reghdfe misdemeanor male minority, absorb(startingyear cityid)
*Column 4
	reghdfe criminal male hb, absorb(startingyear cityid)
*Column 5
	reghdfe felony male hb, absorb(startingyear cityid)
*Column 6
	reghdfe misdemeanor male hb, absorb(startingyear cityid)
*Summary statistics for Table 2
	tabstat criminal felony misdemeanor male minority hb if e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 3B: Profiling of Financial Advisors with Criminal Records: Pre-Advisor Criminal Records Only
	use "$path\Data for Table 03B.dta", clear
	label variable preadvisor_criminal 		"Pre-advisor criminal record"
	label variable male 					"Male"
	label variable minority 				"Minority"
	label variable hb 						"Minority (excluding Asian names)"
	label variable preadvisor_felony 		"Pre-advisor felony"
	label variable preadvisor_misdemeanor 	"Pre-advisor misdemeanor"
*Column 1
	reghdfe preadvisor_criminal male minority, absorb(startingyear cityid)
*Column 2
	reghdfe preadvisor_felony male minority, absorb(startingyear cityid)
*Column 3
	reghdfe preadvisor_misdemeanor male minority, absorb(startingyear cityid)
*Column 4
	reghdfe preadvisor_criminal male hb, absorb(startingyear cityid)
*Column 5
	reghdfe preadvisor_felony male hb, absorb(startingyear cityid)
*Column 6
	reghdfe preadvisor_misdemeanor male hb, absorb(startingyear cityid)
*Summary statistics for Table 2
	tabstat preadvisor_criminal preadvisor_felony preadvisor_misdemeanor male minority hb if e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 4: Who Hires Financial Advisors with Criminal Records?
*Table 10B: Do Investors Face Higher Exposure to Service Disruption?: Firm Expelled
	use "$path\Data for Table 04 and 10B.dta", clear
	label variable firmhire_preadvisor_criminal 	"Hiring advisor with pre-advisor criminal record"
	label variable pct_firmhire_pre 				"% Pre-advisor criminal record at advisory firm"
	label variable highrisk_brokerage 				"High-risk brokerage"
	label variable expel_or_cancel 					"Firm expelled"
	label variable small 							"Small firm"
	label variable solo 							"Solo firm"
	label variable corp 							"Corporation"
	label variable referral 						"Referral business"
	label variable affil 							"Affiliated"
	label variable num_business_lines 				"Number of business lines (Ln)"
	label variable lnnum_state_reg 					"Number of state registrations (Ln)"
	label variable retail 							"Retail"
	label variable mil_num_of_accounts 				"Number of accounts (in million)"
	label variable prt_aum 							"Percentage of asset"
	label variable hourly 							"Hourly charge"
	label variable fixed 							"Fixed fee"
	label variable commissions 						"Commission"
	label variable performancebased 				"Performance"
	label variable missing_indicator 				"Missing indicator"
*Table 4: Column 1
	reghdfe firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 4: Column 2
	reghdfe firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*Table 4: Column 3
	reghdfe pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 4: Column 4
	reghdfe pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*Summary statistics
	tabstat firmhire_preadvisor_criminal pct_firmhire_pre expel_or_cancel highrisk_brokerage small solo corp referral affil num_business_lines num_state_reg if e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
	tabstat retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased if missing_indicator==0 & e(sample)==1, column(statistic) statistics(mean sd p25 p50 p75 n)
*Table 10B: Column 1
	reghdfe expel_or_cancel firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 10B: Column 2
	reghdfe expel_or_cancel firmhire_preadvisor_criminal highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*Table 10B: Column 3
	reghdfe expel_or_cancel pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg, cluster(zip3) absorb(cityid formyear)
*Table 10B: Column 4
	reghdfe expel_or_cancel pct_firmhire_pre highrisk_brokerage small solo corp referral affil lnnum_business_lines lnnum_state_reg retail mil_num_of_accounts prt_aum hourly fixed commissions performancebased missing_indicator, cluster(zip3) absorb(cityid formyear)
*****************************************************************************************************
*Table 5: Where Do Hiring Firms Cluster?
	use "$path\Data for Table 05.dta", clear
	label variable firmhire_preadvisor_criminal 	"Pre-advisor criminal record at advisory firm"
	label variable pct_firmhire_pre 				"% Pre-advisor criminal record at advisory firm"
	label variable retireperhousehold 				"Retirement income"
	label variable lnretireperhousehold 			"Retirement income (Ln)"
	label variable area_wealthy_retirees 			"Area populated with wealthy retirees"
	label variable pop 								"Population"
	label variable lnpop 							"Population (Ln)"
	label variable income 							"Income"
	label variable lnincome 						"Income (Ln)"
	label variable medianage 						"Age (median)"
	label variable malefemaleratio 					"Male-to-female ratio"
	label variable pct_white 						"% White"
	label variable collegeabove 					"% College and above"
	label variable laborforce 						"% Labor force"
*Column 1
	reghdfe firmhire_preadvisor_criminal lnretireperhousehold lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Column 2
	reghdfe firmhire_preadvisor_criminal area_wealthy_retirees lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Column 3
	reghdfe pct_firmhire_pre lnretireperhousehold lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Column 4
	reghdfe pct_firmhire_pre area_wealthy_retirees lnpop lnincome medianage malefemaleratio pct_white collegeabove laborforce, cluster(county_fips) absorb(state_fips formyear)
*Summary statistics for Table 2
	tabstat retireperhousehold area_wealthy_retirees pop income medianage malefemaleratio pct_white collegeabove laborforce if e(sample)==1, column(statistics) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 6: Predicting Post-Advisor Criminal Records
*Table 7A: Predicting Customer Complaints and Settlements: Baseline Matched Sample
*Table 10A: Do Investors Face Higher Exposure to Service Disruption?: Advisor Suspended and Advisor Barred
	use "$path\Data for Table 06, 07A, and 10A.dta", clear
	label variable futurecriminal 			"Post-advisor criminal record"
	label variable futurelien 				"Personal lien or judgment"
	label variable futurecivil 				"Civil litigation"
	label variable customer_complaint 		"Customer complaint"
	label variable complaint_with_merit 	"Complaint with merit"
	label variable settled_complaint 		"Settled complaint"
	label variable lareg_settlement 		"Large settlement"
	label variable suspend 					"Advisor suspended"
	label variable bar 						"Advisor barred"
	label variable preadvisor 				"Pre-advisor criminal record"
	label variable firmsize 				"Firm size"
	label variable lnfirmsize 				"Firm size (Ln)"
	label variable avgperjob 				"Tenure per firm"
	label variable lnavgperjob 				"Tenure per firm (Ln)"
	label variable years_in_profession 		"Years in profession"
	label variable lnyears_in_profession 	"Years in profession (Ln)"
	label variable advisor 					"Investment adviser"
	label variable stateexamcount 			"Number of state exams"
	label variable principalexamcount 		"Number of principal exams"
	label variable productexamcount 		"Number of product exams"
	label variable lapse 					"Years since pre-advisor record"
	label variable numfirm 					"Number of advisory firms"
	label variable num_separation 			"Resigned after allegations"
	label variable ownerstopexec 			"Top executive or owner"
	label variable branchid 				"Branch ID"
	label variable since 					"Cohort year"
*Table 6, column 1
	reghdfe futurecriminal preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 6, column 2
	reghdfe futurelien preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 6, column 3
	reghdfe futurecivil preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 1
	reghdfe customer_complaint preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 2
	reghdfe complaint_with_merit preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 3
	reghdfe settled_complaint preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 7, panel A, column 4
	reghdfe lareg_settlement preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 10, panel A, column 1
	reghdfe suspend preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Table 10, panel A, column 2
	reghdfe bar preadvisor lnfirmsize lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(branchid since) vce(robust)
*Summary statistics for Table 2
	tabstat preadvisor futurecriminal futurelien futurecivil customer_complaint complaint_with_merit settle lareg_settlement years_in_profession numfirm avgperjob num_separation ownerstopexec suspend bar firmsize advisor stateexamcount principalexamcount productexamcount lapse if e(sample)==1, column(statistics) statistics(mean sd p25 p50 p75 n)
	tabstat lapse if e(sample)==1 & lapse>0, column(statistics) statistics(mean sd p25 p50 p75 n)
*****************************************************************************************************
*Table 7B: Predicting Customer Complaints and Settlements: Alternative Matched Sample
	use "$path\Data for Table 07B.dta", clear
	label variable customer_complaint 		"Customer complaint"
	label variable complaint_with_merit 	"Complaint with merit"
	label variable settled_complaint 		"Settled complaint"
	label variable lareg_settlement 		"Large settlement"
	label variable preadvisor_criminal 		"Pre-advisor criminal record"
	label variable lnavgperjob 				"Tenure per firm (Ln)"
	label variable lnyears_in_profession 	"Years in profession (Ln)"
	label variable advisor 					"Investment adviser"
	label variable stateexamcount 			"Number of state exams"
	label variable principalexamcount 		"Number of principal exams"
	label variable productexamcount 		"Number of product exams"
	label variable branchid 				"Branch ID"
	label variable year 					"Year"
	label variable since 					"Cohort year"
*Column 1
	reghdfe customer_complaint preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Column 2
	reghdfe complaint_with_merit preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Column 3
	reghdfe settled_complaint preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Column 4
	reghdfe lareg_settlement preadvisor_criminal lnavgperjob lnyears_in_profession advisor stateexamcount principalexamcount productexamcount, absorb(year#branchid since) vce(robust)
*Summary statistics for Table 2
	tabstat customer_complaint complaint_with_merit settled_complaint lareg_settlement if e(sample)==1, statistics(mean sd p25 p50 p75 n) column(statistics)
*****************************************************************************************************
*Table 8: Are Investors Compensated with Higher Returns?
	use "$path\Data for Table 08.dta", clear
	label variable ret_nohire 	"Clean (no advisors with pre-advisor criminal records)"
	label variable ret_highrisk "High (High % of advisors with pre-advisor criminal records)"
	label variable high_no 		"Clean - High"
	label variable mktrf		"Market"
	label variable smb			"Small-minus-big"
	label variable hml			"High-minus-low"
	label variable umd			"Momentum"
	label variable ps_vwf		"Liquidity"
	label variable st_rev		"Short-term reversal"
	label variable lt_rev		"Long-term reversal"
*Fama-French 3-factor model
	foreach var in ret_nohire ret_highrisk high_no {
	newey `var' mktrf smb hml, lag(4)
	}
*Carhart 4-factor model
	foreach var in ret_nohire ret_highrisk high_no {
	newey `var' mktrf smb hml umd, lag(4)
	}
*7-factor model
	foreach var in ret_nohire ret_highrisk high_no {
	newey `var' mktrf smb hml umd ps_vwf st_rev lt_rev, lag(4)
	}
*****************************************************************************************************
*Table 9, column 1: Are Investors Compensated with Lower Fees?: Expense Ratio
	use "$path\Data for Table 09_1.dta", clear
	label variable exp_ratio 	"Expense ratio"
	label variable highrisk 	"Top hiring firm"
	label variable indexfund 	"Index fund"
	label variable nav_latest 	"Assets under management"
	label variable lnnav_latest "Assets under management (Ln)"
	label variable age 			"Fund age"
	label variable lnage 		"Fund age (Ln)"
	label variable turn_ratio 	"Turnover ratio"
	label variable objid 		"Style"
	label variable year 		"Year"
	label variable crsp_fundno 	"CRSP_FUNDNO"
*Column 1
	xi: areg exp_ratio i.year highrisk indexfund lnnav_latest lnage turn_ratio, r absorb(objid) cluster(crsp_fundno)
	tabstat exp_ratio highrisk indexfund nav_latest age turn_ratio if e(sample)==1, statistics(mean sd p25 p50 p75 n) column(statistics)
*****************************************************************************************************
*Table 9, columns 2 and 3: Are Investors Compensated with Lower Fees?: Maximum Initial Purchase Charge and Average Initial Purchase Charge
	use "$path\Data for Table 09_2-3.dta", clear
	label variable maxfront 	"Maximum initial purchase charge"
	label variable meanfront 	"Average initial purchase charge"
	label variable highrisk 	"Top hiring firm"
	label variable indexfund 	"Index fund"
	label variable objid 		"Style"
	label variable vintage		"Vintage"
	label variable crsp_fundno 	"CRSP_FUNDNO"
*Column 2
	xi: areg maxfront i.vintage highrisk indexfund, r absorb(objid) cluster(crsp_fundno)
*Column 3
	xi: areg meanfront i.vintage highrisk indexfund, r absorb(objid) cluster(crsp_fundno)
*Summary statistics for Table 2
	tabstat maxfront meanfront highrisk indexfund if e(sample)==1, statistics(mean sd p25 p50 p75 n) column(statistics)
*****************************************************************************************************
log close

