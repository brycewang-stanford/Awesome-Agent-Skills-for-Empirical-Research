/*******************************************************************************
							Barrios 2021
 Occupational Licensing and Accountant Quality: Evidence from the 150-Hour Rule
 
This code is ment to clean the raw data imported from the online professional 
networking and recruiting site. These profolies are parsed based on the html code
of the site.
*******************************************************************************/


/*******************************************************************************

Clean job experience

*******************************************************************************/

* Import raw csv data 
import delimited "raw/experience_info.csv", varnames(1) clear 

	drop f1-f3 year
	format %30s title
	format %30s firm

* Substract year and month 
	generate splitat = strpos(tenure, "(")
	gen ym = ""
	replace ym = substr(tenure, 1, splitat - 1) if splitat != 0
	split ym, l(5)
	gen Month= strpos(ym1, "April")| strpos(ym1, "August")| strpos(ym1, "December")| strpos(ym1, "February")| strpos(ym1, "January")| strpos(ym1, "July")| strpos(ym1, "June")| strpos(ym1, "March")| strpos(ym1, "May")| strpos(ym1, "November")| strpos(ym1, "October")| strpos(ym1, "September")

* Clean starting month and year
	gen Start_Month = ym1 if Month == 1
	gen Start_Year = ym2 if Month == 1
	replace Start_Year = ym1 if Month == 0

* Clean ending month and year
	gen Month2 = strpos(ym3, "April")| strpos(ym3, "August")| strpos(ym3, "December")| strpos(ym3, "February")| strpos(ym3, "January")| strpos(ym3, "July")| strpos(ym3, "June")| strpos(ym3, "March")| strpos(ym3, "May")| strpos(ym3, "November")| strpos(ym3, "October")| strpos(ym3, "September")
	gen End_Month = ym3 if Month2 == 1
	replace End_Month = subinstr(End_Month, "-", "",.)
	gen End_Year = ym4 if Month2 == 1

	gen Not_date3 = strpos(ym3, "(") | strpos(ym3, "years)")
	replace End_Year = ym3 if Month2 == 0 & Not_date3 == 0
	replace End_Year = subinstr(End_Year, "-", "",.)
	drop Not_date3
	* Obs with starting and ending year only (e.g., 2009-2010)
	gen ey_date2 = strpos(ym2, "-")
	replace End_Year = ym2 if ey_date2 == 1 & End_Year == ""
	replace End_Year = subinstr(End_Year, "-", "",.)

* Obs with starting year, ending year and month only (e.g., 2003 -June 2011)
	gen endm_i = strpos(ym2, "-A")| strpos(ym2, "-J") | strpos(ym2, "-O") | strpos(ym2, "-M") | strpos(ym2, "-D") | strpos(ym2, "-F") | strpos(ym2, "-N") | strpos(ym2, "-S")
	replace End_Month = ym2 if endm_i == 1
	replace End_Month = subinstr(End_Month, "-", "",.)
	drop Month Month2 ey_date2 endm_i

	rename Start_Year start_year
	rename End_Year end_year
	rename Start_Month start_month
	rename End_Month end_month

	destring start_year, replace force
	replace end_year = "2017" if end_year == "Present"
	destring end_year, replace force
	drop ym* splitat

	order id key title firm start_month start_year end_month end_year
	drop if Num_Years == 0 & Num_Months == 0
	drop length
	rename firm comp

* Mannual correction
* Not a work experience (Bachelor of Science (B.S.), Accountancy, 2004 -2008)
	drop if id == 9418 & key == 24146 

* Check expriences before 1970
* Correct the obs if it is not consistent with the website
	drop if key == 15056 & start_year < 1901
	drop if key == 14225 & start_year < 1901
	replace start_year = 1991 if key == 13236 & start_year == 1901 
	replace start_year = 1996 if key == 13236 & start_year == 1906
	replace end_year = "1995" if key == 13236 & end_year == "1905"
	replace end_year = "1999" if key == 13236 & end_year == "1912"
	drop if key == 21695 & start_year < 1902

	drop if lower(title) == "skills"
	drop if lower(title) == "n/a"
	drop if key == 10353 // not accounting
	drop if key == 21435 // misc
	drop if strpos(lower(title),"skil") > 0 & strpos(lower(title),"trainer") == 0

* Clean durations
	replace end_year = "2005" if end_year == "20051"
	replace end_year = "2012" if end_year == "201229"
	replace end_year = "2012" if end_year == "201276"
	replace end_year = "2012" if end_year == "2012800"
	replace end_year = "2012" if end_year == "2012901"
	replace end_year = "2013" if end_year == "20131389"
	replace end_year = "2014" if end_year == "2014145"
	replace end_year = "2015" if end_year == "20155905"
	replace end_year = "2017" if end_year == "20172"
	replace end_year = "2017" if end_year == "2017880"

* Clean ending year contains nonnumerica characters
	egen ey = sieve(end_year), omit(0123456789)
	replace end_year = substr(end_month,1,4) if ey!=""
	replace end_month = "" if ey != ""
	drop ey
	destring end_year, force replace

* Duration measure (unit: month)
	replace duration = round(Tenure_Final*12, 1) if duration== . & Tenure_Final != .
	drop Tenure_Final Num_Years Num_Months id

* Duration measure (unit: annual)
	gen dur_yr = duration/12
	replace dur_yr = end_year - start_year if duration/12 > 59 & end_year != .
	drop if dur_yr == 0
	sort key start_year

* Check outliers
	egen num_job = count(key), by(key)
	* Non-accounting 
	drop if key == 21633 & start_year == 2015 & duration == 1
	drop if key == 10937 
	drop if key == 5551 

* Internship Identifier
	gen Intern = 0
	replace Intern = 1 if strpos(lower(title),"interns")>0 | strpos(lower(title),"summer")>0 |strpos(lower(title),"student as")>0 | strpos(lower(title),"student w")>0 | strpos(lower(title),"winter an")>0 | strpos(lower(title),"intern") >0
	egen Intern_id = max(Intern), by(key)
	drop Intern

/*******************************************************************************

Drop non jobs and miscellaneous data

*******************************************************************************/

* Non jobs and misc
	drop if strpos(lower(title), "at your service") >0 | strpos(lower(comp),"at your service") >0
	drop if strpos(lower(title), "new employer") >0 | strpos(lower(comp),"new employer") >0 | strpos(lower(comp),"exploring opportunities") >0 
	drop if strpos(lower(title), "looking for") >0 | strpos(lower(comp),"looking for") >0
	drop if strpos(lower(title), "pending") >0 | strpos(lower(comp),"pending") >0
	drop if strpos(lower(comp), "new jersey") >0
	drop if strpos(lower(title), "to be determined") >0 | strpos(lower(comp),"to be determined") >0
	drop if lower(comp) == "other"
	drop if lower(comp) == ""
	drop if lower(comp) == "."
	drop if strpos(lower(comp), "various") >0 & strpos(lower(comp), "firm") >0
	drop if strpos(lower(comp), "sole proprietor") >0

* Unemployed
	drop if strpos(lower(title),"unemploy") >0 | strpos(lower(comp),"unemploy") >0
	
* Trainee
	drop if strpos(lower(title),"trainee") >0
	
* Candidate
	drop if strpos(lower(title),"candidate") >0
	
* Youth member
	drop if strpos(lower(title),"youth") >0 & strpos(lower(title),"member") >0
	
* Part time
	drop if strpos(lower(title),"part-time") >0 | strpos(lower(title),"part time") >0 | (strpos(lower(title),"part") >0 & strpos(lower(title),"time") >0)
	drop if strpos(lower(comp),"part-time") >0 | strpos(lower(comp),"part time") >0 | (strpos(lower(comp),"part") >0 & strpos(lower(comp),"time") >0)
	
* Temporary
	drop if strpos(lower(title),"temporary") >0 | lower(title) == "temp"
	
* Internships
	drop if strpos(lower(title),"interns") >0 | strpos(lower(title),"summer")>0 |strpos(lower(title),"student as")>0 |strpos(lower(title),"student w")>0| strpos(lower(title),"winter an")>0 | strpos(lower(title),"intern") >0
	drop if strpos(lower(title),"research assi") >0
	
* VITA
	drop if strpos(lower(comp),"vita") >0 & strpos(lower(comp),"health")==0 & strpos(lower(comp),"corp")==0 & strpos(lower(comp),"llc")==0 & strpos(lower(comp),"med")==0 & strpos(lower(comp),"dolc")==0
	
* Volunteers
	drop if strpos(lower(comp), "volunteer") >0
	
* Personal Trainers
	drop if strpos(lower(title), "traine") >0 & strpos(lower(title), "pers") >0

* Dealers
	drop if strpos(lower(title),"dealer")>0 & (strpos(lower(title),"black") >0 | strpos(lower(title),"poker") >0)
	
* Participants
	drop if strpos(lower(title),"partici") >0
	
* Teaching Assistants
	drop if strpos(lower(title),"intro") & strpos(title,"Core")
	drop if strpos(lower(title),"teaching") & strpos(title,"ass")
	drop if strpos(lower(title),"intro") & strpos(title,"TA")
		
	drop if strpos(lower(comp),"ancient ") > 0
	drop if strpos(lower(title),"cheer") > 0 & strpos(lower(title),"coach") > 0
	drop if strpos(lower(title),"coach") > 0 & strpos(lower(title),"youth") > 0
		
* Leadership programs
	drop if strpos(lower(title),"leader") > 0  & duration == 1
	
* Conference
	drop if strpos(lower(title),"confere") > 0  & duration == 1
	drop if strpos(lower(title),"confere") > 0  & strpos(lower(title),"tra") > 0
	drop if strpos(lower(title),"confere") > 0  & duration < 5

* Research Assistants
	drop if strpos(lower(comp),"univ") & strpos(lower(title),"resear")  & strpos(lower(title),"ass")
	drop if strpos(lower(title),"fellow") > 0
		
* Re-enactors
	drop if strpos(lower(title),"re-enactor") > 0

* List if key == 13722 
	duplicates drop title start_year end_year if key == 13722, force
	duplicates tag key title start_year end_year if num_job > 18 , generate(tag)
	duplicates drop key title start_year end_year if tag > 0 & tag !=., force
	drop tag

* Clean titles
	gen Tit_Length = length(title)
	replace title = lower(trim(title))
	drop if title == "-" | title == "." | title == ".."
	drop if strpos(title, "â") & duration < 2
	drop if strpos(title, "#") & duration < 2
	drop if strpos(title, "doctora") > 0
	drop if strpos(title, "student") > 0

	drop num_job
	egen num_job = count(key), by(key)

* Duplicates
	duplicates tag key title start_year end_year if num_job > 11, generate(tag)
	duplicates drop key title start_year end_year if tag > 0 & tag!=., force
	drop tag num_job
	egen num_job = count(key), by(key)
	drop num_job

* Drop miscellaneous observations
	drop if strpos(title,"extern ") > 0 & duration<4
	drop if strpos(title,"seek") > 0
	drop if strpos(lower(comp),"seeking") > 0
	drop if strpos(lower(comp),"currently") > 0 & strpos(lower(comp),"opportunities") > 0
	drop if strpos(title,"looki") > 0
	duplicates drop key title start_year end_year if strpos(title," ")<4 & duration==1 & start_year<2017 , force
	drop if strpos(lower(comp),"mother") > 0 & strpos(lower(comp),"care") > 0
	drop if strpos(lower(title),"1-d") > 0
	drop if strpos(lower(title),"isbn") > 0
	drop if strpos(title,"peer") > 0 & strpos(title,"speci") == 0
	drop if Tit_Length == 0
	drop if Tit_Length < 3 & strpos(title,"vp") == 0 & strpos(title,"dj") == 0

	egen num_job = count(key), by(key)
	drop if strpos(lower(comp),"e tutor") > 0 & num_job > 11
	drop if strpos(lower(title),"research project") > 0 & num_job > 11
	drop if strpos(lower(title),"filed") > 0 & num_job > 11
	drop if strpos(lower(title),"toast") > 0 & num_job > 11
	drop if strpos(lower(comp),"toast") > 0 & num_job > 11

	list if key == 25946
	drop if key == 25946 & (strpos(title,"1980") > 0 | strpos(title,"1980") > 0 | strpos(title,"1974") > 0)
	drop if key == 25946 & strpos(title,"client") > 0
	replace comp = "Hotel Dieu Hospital" if key == 25946 & comp == "New Orleans"

* Droping one job new entrats in 2017
	drop if num_job == 1 & start_year > 2016
	drop if comp == "" & strpos(title," time off") > 0
	sort key start_year
	by key start_year: gen job_ord = _n

* Examine individuals with long tenures and multiple jobs
	gen long_tenure_check = 0
	replace long_tenure = 1 if duration > 350 & num_job > 1 & job_ord == 1
	egen chk = max(long_tenure_check), by(key)
	* Camera man, marketing, database manager, copywriter, product manager, social media
	drop if key == 1404
	drop if key == 12290
	drop if key == 20706
	drop if key == 100 
	drop if key == 146 
	drop if key == 1114 
	drop if key == 17517 
	drop if key == 52 
	drop if key == 170 
	drop long_tenure_check chk num_job
	egen num_job = count(key), by(key)

* Check errors in the data
	gen check1 = .
	replace check1 = 1 if duration > 1000 & duration !=. 
	replace duration = ( end_year - start_year ) * 12 if check1 == 1
	gen check2 = .
	replace check2 = 1 if key == 25825
	replace check2 = 1 if strpos(lower(title), "graduate assistant")
	replace check2 = 1 if strpos(lower(title), "teaching assistant")

	foreach x in mentor mentee coach{
		replace check2 = 1 if strpos(lower(title),"`x'")
	} 
	replace check2 = 1 if title == "undergraduate member of prof. phil bucksbaum group"
	replace check2 = 1 if title == "bs 1976 criminal justice ~ football & golf"
	replace check2 = 1 if title == "cvsept2009"
	replace check2 = 1 if title == "helper to all"
	replace check2 = 1 if comp == "Eager to add value for Shareholders and Collaborate with Internal and External Customers."
	replace check2 = 1 if comp == "Earlier Professional Experience"
	replace check2 = 1 if comp == "Earlier Experience"
	replace check2 = 1 if comp == "Early Background"
	replace check2 = 1 if comp == "Early Career"
	replace check2 = 1 if comp == "Experience prior to 2009"
	replace check2 = 1 if comp == "Experienced Tax Manager"
	replace check2 = 1 if key == 11124 & comp == "Certified Public Accountant"
	replace check2 = . if title == "area coach" | title == "license operations coach"

save "temp/exp_before_drop", replace

* Save dropped obs in a file to double check 
use "temp/exp_before_drop", clear
	preserve
	keep if check2 == 1
	sort title
	use "temp/exp_before_drop", clear
	merge m:m key using "temp/exp_before_drop"
	keep if _m == 3
	drop _m
	sort key
	order key check2
	label var check2 "review dropped obs"
	note: This file shows the whole career. check2 == 1 are lines of experience with misc
	save "temp/experience_check_dropped_obs", replace
	restore

* Create a clean directory 
use "temp/exp_before_drop", clear

* Remove checked obs 
	drop if check2 == 1
* Drop those without any accounting experience
* E.g., tech, education, designer, data scientist, mkt, laser, coach 
	drop if key == 135
	drop if key == 141
	drop if key == 152
	drop if key == 274
	drop if key == 278
	drop if key == 407
	drop if key == 410 
	drop if key == 449
	drop if key == 456
	drop if key == 475
	drop if key == 485
	drop if key == 630 
	drop if key == 655 
	drop if key == 711
	drop if key == 747
	drop if key == 851
	drop if key == 859
	drop if key == 888 
	drop if key == 983 
	drop if key == 1229 
	drop if key == 1302 
	drop if key == 1661 
	drop if key == 14700
	drop if key == 14706
	drop if key == 14984
	drop if key == 23157 & start_year == 1901

* Measure duration of experience
	bysort key: egen total_exp = total(dur_yr)

* Job order, number of jobs
	drop job_ord num_job
	sort key start_year start_month
	by key: gen job_order = _n
	egen num_job = count(key), by(key)

* Average duration
	egen mean_dur_yr = mean(dur_yr), by(key)

* Label variables 
	label var job_order "job order by the start year"
	label var dur_yr "yearly duration of each job"
	label var mean_dur_yr "avergage duation (year)"
	label var total_exp "for each key, sum the duration of his/her each job"
	label var des "job description"
	label var num_job "total number of jobs"
	label var duration "monthly duration of each job"
	label var title "Linkedin job title"
	label var start_month "clean start month"
	label var start_year "clean start year"
	label var end_month "clean start month"
	label var end_year "clean start year"
	label var title "raw Linkedin job title"
	label var comp "raw Linkedin company"

	order key job_order dur_yr mean_dur_yr total_exp num_job
	drop Intern_id Tit_Length check1 check2

save "output/Experience_Clean", replace

/*******************************************************************************
					 
Classify job titles 

*******************************************************************************/

* Import clean experience data 
use "output/Experience_Clean", clear

	egen Title_ID  = group(title)

* Classify titles 
	gen CPA = strpos(title, "CPA") | strpos(title, "Certified Public Accountant") |strpos(title, "cpa") | strpos(title, "certified public accountant") | strpos(title,"CERTIFIED PUBLIC ACCOUNTANT") | strpos(title, "C.P.A.")| strpos(title, "Cpa") | strpos(title, "Certified public accountant") | strpos(title, "C P A TAXATION")
	gen CPA_Check = 1 if CPA > 0

	gen Accountant  = strpos(lower(title), "accountant") | strpos(title, "ACCOUNTANT")
	gen ACC_Check = 1 if Accountant > 0

	gen Auditor = strpos(lower(title), "auditor") | strpos(title, "AUDITOR") | strpos(title, "auditer") | (strpos(title, "audit") & strpos(title, "associate")) | strpos(title, "audit staff") | strpos(title, "auditing staff") | (strpos(title, "audit") & strpos(title, "staff")) | strpos(title, "audit senior") | strpos(title, "external audit") | strpos(title, "audit & assurance") | strpos(title, "audit clerk") | strpos(title, "auditing staff") | strpos(title, "audit team member") | strpos(title, "audit assistant") | strpos(title, "audit professional") | title ==  "audit services" | title ==  "audit services practice" | strpos(title, "audit specialist") | strpos(title, "audit/accounting")  | strpos(title, "auditing / tax") | strpos(title, "auditing and tax")  | title ==  "kpmg audit" | title ==  "audit / assurance" | title ==  "audit advisory services" | title ==  "audit and assurance" | title ==  "audit"

	gen Auditor_Check = 1 if Auditor > 0

	gen CEO  = strpos(title, "CEO") | strpos(title, "ceo") | strpos(lower(title), "chief executive officer")
	gen CEO_Check = 1 if CEO > 0

	gen President = strpos(lower(title), "president") | strpos(title,"PRESIDENT")
	gen Pres_Check = 1 if President > 0

	gen VP  = strpos(lower(title), "vice president") | strpos(title, "VP") | strpos(title, "vp") | strpos(title, "V P") | strpos(title, "V.P.")
	gen VP_Check = 1 if VP  > 0

	gen Owner = strpos(lower(title), "owner")
	gen Owner_Check = 1 if Owner > 0

	gen CFO  = strpos(title, "CFO") | strpos(title, "cfo") | strpos(title, "Cfo") | strpos(title, "CFo") | strpos(title, "Chief Financial Officer") | strpos(title, "CHEIF FINANCIAL OFFICER") | strpos(title, "Cheif Financial Officer") | strpos(title, "Cheif Financial") | strpos(title, "CHIEF FINANCIAL OFFICER") | strpos(title, "Chief Financial & Operating Officer") | (strpos(lower(title),"chief") & strpos(lower(title),"financial") ) | (strpos(lower(title),"chief") & strpos(lower(title),"finance") )
	gen CFO_Check = 1 if CFO > 0

	gen Chief_Accountant = strpos(lower(title), "chief accountant") | strpos(lower(title), "chief accounting officer")
	gen CAO_Check = 1 if Chief_Accountant > 0

	gen Chief_Oper = strpos(lower(title), "chief operating officer") | strpos(title, "COO") | strpos(lower(title), "chief operations officer") | strpos(lower(title), "chief operation officer")
	gen COO_check = 1 if Chief_Oper > 0

	gen Controller = strpos(lower(title), "controller") | strpos(title, "CONTROLLER")| strpos(title, "comptroller") | strpos(title, "Comptroller") | strpos(title, "Contoller")
	gen Controller_Check = 1 if Controller > 0

	gen Consultant = strpos(lower(title), "consultant") | strpos(title, "CONSULTANT")| strpos(title, "consultan")
	gen Consultant_Check = 1 if Consultant > 0

	gen Supervisor = strpos(lower(title), "supervisor")
	gen Supervisor_Check = 1 if Supervisor > 0

	gen Analyst = strpos(lower(title), "analyst")  | strpos(title, "ANALYST")
	gen Analyst_Check = 1 if Analyst > 0

	gen Principle = strpos(lower(title), "principle") | strpos(lower(title),"principal")
	gen Principle_Check = 1 if Principle > 0

	gen Treasurer = strpos(lower(title), "treasurer") |strpos(title, "TREASURER")
	gen Treasurer_Check = 1 if Treasurer > 0

	gen Teller = strpos(lower(title), "teller")

	gen Senior_Partner = strpos(lower(title), "senior partner")
	gen Senior_Partner_Check = 1 if Senior_Partner > 0

	gen Managing_Partner = strpos(lower(title), "managing partner")
	gen Managing_Partner_Check = 1 if Managing_Partner > 0

	gen Partner = strpos(lower(title), "partner") | strpos(title, "PARTNER")
	gen Partner_Check = 1 if Partner > 0

	gen Practice_Leader = strpos(lower(title), "practice leader")
	gen Practice_Leader_Check = 1 if Practice_Leader > 0

	gen Director = strpos(lower(title), "director") | strpos(title, "DIRECTOR") | strpos(title, "Dir of")| strpos(title, "Dir,")
	gen Director_Check = 1 if Director > 0

	gen Manager = strpos(lower(title), "manager")| strpos(title, "MANAGER") | strpos(title, "Manger") | strpos(title, "Mgr") | strpos(title, "mgr ") | strpos(title, "mgr.")  | strpos(title, " mgr")
	gen Manager_Check = 1 if Manager > 0

	gen Senior  = strpos(lower(title), "senior") | strpos(lower(title), "sr ") | strpos(lower(title), "sr. ")
	gen Senior_Check = 1 if Senior > 0

	gen Senior_Manager = strpos(lower(title), "senior manager") | (Senior == 1 & Manager == 1)
	gen Senior_Manager_Check = 1 if Senior_Manager > 0

	gen Senior_Associate = strpos(lower(title),"senior associate")
	gen Senior_Associate_Check = 1 if Senior_Associate > 0

	gen Associate = strpos(lower(title),"associate")
	gen Associate_Check = 1 if Associate > 0

	gen Senior_ACC = strpos(title, "SENIOR ACCOUNTANT") | strpos(title, "Sr Accountant") | strpos(title, "Sr. Accountant")
	gen Sr_ACC_Check = 1 if Senior_ACC > 0

	gen Junior_Accountant = strpos(lower(title), "junior") & strpos(lower(title), "accountant")
	gen JuniorACC_Check = 1 if Junior_Accountant > 0

	gen staff = strpos(lower(title), "staff") | strpos(lower(title), "staff accountant")
	gen staff_Check = 1 if staff > 0

	gen Intern = strpos(lower(title), "intern")
	gen Intern_Check = 1 if Intern > 0

	gen Tax = strpos(lower(title), "tax")
	gen Tax_Check = 1 if Tax > 0

	gen retired = strpos(lower(title), "retired")
	gen retired_Check = 1 if retired > 0

	gen Faculty = strpos(lower(title), "faculty") | strpos(lower(title), "lecturer") | strpos(lower(title), "professor") | strpos(lower(title), "instructor") | strpos(lower(title), "professor") | strpos(lower(title), "lecturer") | strpos(title, "FACULTY MEMBER")
	gen Faculty_Check = 1 if Faculty > 0

	gen Teacher = strpos(lower(title), "teacher")
	gen Teacher_Check = 1 if Teacher > 0

	gen Lawyer = strpos(lower(title), "attorney") |strpos(lower(title), "counselor") | strpos(lower(title), "lawyer") | strpos(lower(title), "counsel")
	gen Lawyer_Check = 1 if Lawyer > 0

	gen Rev_Agent = strpos(lower(title), "revenue agent")
	gen Rev_Agent_check = 1 if Rev_Agent > 0

	gen Sole_Proprietor = strpos(lower(title), "sole proprietor") | strpos(lower(title), "sole proprietor") | strpos(lower(title), "sole-proprietor")
	gen Sole_Prop_check = 1 if Sole_Proprietor > 0

	gen Sales = strpos(lower(title), "sales")
	gen Sales_Check = 1 if Sales > 0

	gen Nurse = strpos(lower(title), "nurse")
	gen Nurse_Check = 1 if Nurse > 0

	gen Realtor = strpos(title, "REALTOR") | strpos(lower(title), "realtor") | strpos(lower(title), "real estate agent") | strpos(lower(title), "real estate broker")
	gen Realtor_Check = 1 if Realtor > 0

	gen Inv_Banker = strpos(lower(title), "investment banker") | strpos(lower(title), "investment advisor") | strpos(lower(title), "investment advisor")
	gen Inv_Banker_Check = 1 if Inv_Banker > 0

	gen IRS_Agent = strpos(title, "IRS Agent") | strpos(lower(title), "irs agent")
	gen IRS_Agent_Check = 1 if Inv_Banker > 0

	gen Financial_Advisor = strpos(lower(title), "financial advisor") | strpos(title, "FINANCIAL ADIVSOR")
	gen Financial_Advisor_Check = 1 if Financial_Advisor > 0

	gen Contractor = strpos(lower(title), "contractor")
	gen Contractor_Check = 1 if Contractor > 0

	gen Bookkeeper = strpos(lower(title), "bookkeeper") | strpos(lower(title), "bookkeeping assistant")
	gen Bookkeeper_Check = 1 if Bookkeeper > 0

	gen Board_Member = strpos(lower(title), "board member") | strpos(lower(title), "board of trustees") | strpos(lower(title), "committee member")
	gen Board_Member_Check = 1 if Board_Member > 0

	gen Assistant = strpos(lower(title), "assistant")
	gen Assistant_Check = 1 if Assistant > 0

	gen Chairman = strpos(lower(title), "chair") | strpos(lower(title), "chairman")
	gen Chairman_Check = 1 if Chairman > 0

	gen ChiefRisk = strpos(lower(title), "chief risk officer") | strpos(lower(title), "chairman")
	gen ChiefRisk_Check = 1 if ChiefRisk > 0

	gen Managing_Member = strpos(lower(title), "managing member") | strpos(lower(title), "managing shareholder")
	gen Managing_Member_Check = 1 if Managing_Member > 0

	gen Founder = strpos(lower(title), "founder") |strpos(lower(title), "co-founder") | strpos(lower(title), "co founder") | strpos(lower(title), "cofounder")
	gen Founder_Check = 1 if Founder > 0

	gen Police = strpos(lower(title), "police") | strpos(lower(title), "police sergeant") | strpos(lower(title), "police officer")
	gen Police_Check = 1 if Police > 0

	gen Volunteer = strpos(lower(title), "volunteer")
	gen Volunteer_Check = 1 if Volunteer > 0

	gen Sole_Pract = strpos(lower(title),"sole practitioner")
	gen Sole_Pract_Check = 1 if Sole_Pract > 0

	gen Self_Employed = strpos(lower(title), "self-employed") | strpos(lower(title), "self employed")
	gen Self_empl_Check = 1 if Self_Employed > 0

	gen Examiner = strpos(lower(title), "examiner")
	gen Examiner_Check = 1 if Examiner > 0

	gen Accounting_Mis = strpos(title, "Accounting") |strpos(title, "accounting") |strpos(title, "ACCOUNTING")
	gen Accounting_Mis_Check = 1 if Accounting_Mis > 0

	gen Acct_Clerk = strpos(lower(title), "accounting clerk") |strpos(lower(title), "accounts receivable clerk") |strpos(lower(title), "ACCOUNTS RECEIVABLE CLERK")
	gen Acct_Clerk_Check = 1 if Acct_Clerk > 0

	gen Clerk = strpos(lower(title), "clerk")
	gen Clerk_Check = 1 if Clerk > 0

	gen Account_Exec = strpos(lower(title), "account executive") | strpos(lower(title), "accounts executive") | strpos(lower(title), "account administrator")| strpos(lower(title), "account technician") | strpos(lower(title), "account officer") | strpos(lower(title), "accounts officer")
	gen Account_Exec_Check = 1 if Account_Exec > 0

	gen Real_Estate = strpos(lower(title), "real estate")
	gen Real_Estate_Check = 1 if Real_Estate > 0

	gen Politician = strpos(lower(title), "candidate") | strpos(lower(title), "congress")
	gen Politician_Check = 1 if Politician > 0

	gen Tutor = strpos(lower(title), "tutor")
	gen Tutor_Check = 1 if Tutor > 0

	gen Credit = strpos(lower(title), "credit")
	gen Credit_Check = 1 if Credit > 0

	gen Team_Member = strpos(lower(title), "team") & strpos(lower(title), "member")
	replace Team_Member = 0 if strpos(lower(title), "manager") > 0

	gen Global_Head = strpos(lower(title), "head") & strpos(lower(title), "global")

	gen Other_Head = strpos(lower(title), "head")


	foreach x of varlist CPA_Check ACC_Check Auditor_Check CEO_Check Pres_Check VP_Check Owner_Check CFO_Check CAO_Check COO_check Controller_Check Consultant_Check Supervisor_Check Analyst_Check Principle_Check Treasurer_Check Senior_Partner_Check Managing_Partner_Check Partner_Check Practice_Leader_Check Director_Check Senior_Manager_Check Manager_Check Senior_Check Senior_Associate_Check Associate_Check Sr_ACC_Check JuniorACC_Check staff_Check Intern_Check Tax_Check retired_Check Faculty_Check Teacher_Check Lawyer_Check Rev_Agent_check Sole_Prop_check Sales_Check Nurse_Check Realtor_Check Inv_Banker_Check IRS_Agent_Check Contractor_Check Financial_Advisor_Check Bookkeeper_Check Board_Member_Check Assistant_Check ChiefRisk_Check Chairman_Check Managing_Member_Check Founder_Check Police_Check Sole_Pract_Check Volunteer_Check Self_empl_Check Examiner_Check Acct_Clerk_Check Clerk_Check Accounting_Mis_Check Account_Exec_Check Real_Estate_Check Politician_Check Tutor_Check Credit_Check{
	  	replace `x' = 0 if `x' == .
	}

	gen Classified = CPA_Check + ACC_Check+Auditor_Check + CEO_Check + Pres_Check + VP_Check +Owner_Check + CFO_Check + CAO_Check + COO_check + Controller_Check + Consultant_Check + Supervisor_Check + Analyst_Check + Principle_Check + Treasurer_Check + Senior_Partner_Check + Managing_Partner_Check + Partner_Check + Practice_Leader_Check + Director_Check  +Senior_Manager_Check + Manager_Check + Senior_Check + Senior_Associate_Check + Associate_Check + Sr_ACC_Check + JuniorACC_Check + staff_Check + Intern_Check + Tax_Check + retired_Check + Faculty_Check + Teacher_Check + Lawyer_Check + Sole_Prop_check + Rev_Agent_check + Sales_Check + Nurse_Check + Realtor_Check + Inv_Banker_Check + IRS_Agent_Check + Contractor_Check + Financial_Advisor_Check+ Bookkeeper_Check+ Board_Member_Check + Assistant_Check+Chairman_Check + ChiefRisk_Check + Managing_Member_Check + Founder_Check + Police_Check + Volunteer_Check + Sole_Pract_Check + Self_empl_Check + Examiner_Check + Acct_Clerk_Check + Clerk_Check + Accounting_Mis_Check + Account_Exec_Check + Real_Estate_Check+ Politician_Check + Tutor_Check + Credit_Check
	by key: egen none_classified = max(Classified)

save "temp/Title_Clean_Part1", replace

/*******************************************************************************
					 
Classify the seniority level for titles 

*******************************************************************************/

use "temp/Title_Clean_Part1", clear

* High seniority 
	gen High = 1 if CEO_Check == 1 | Pres_Check == 1 | VP_Check == 1 | Owner_Check == 1 | CFO_Check == 1 | CAO_Check == 1 | COO_check == 1 | Controller_Check == 1 | Senior_Partner_Check == 1 | Managing_Partner_Check == 1 | Partner_Check == 1 |Practice_Leader_Check == 1 | Chairman_Check == 1 | ChiefRisk_Check == 1 | Managing_Member_Check == 1
	replace High = 0 if High == .

* Mid seniority 
	gen Mid = 1 if Consultant_Check == 1 | Supervisor_Check == 1 | Analyst_Check == 1 | Principle_Check == 1 | Treasurer_Check == 1 | Director_Check == 1 | Senior_Manager_Check == 1 | Manager_Check == 1 | Senior_Check == 1 | Rev_Agent_check == 1 | Inv_Banker_Check == 1 | Account_Exec_Check == 1
	replace Mid = 0 if Mid == .

* Low seniority 
	gen Low = 1 if Senior_Associate_Check == 1 |Associate_Check == 1 |Sr_ACC_Check == 1 | JuniorACC_Check == 1 |staff_Check == 1 |Intern_Check == 1 |IRS_Agent_Check == 1 | Bookkeeper_Check == 1 | Assistant_Check == 1 | Examiner_Check == 1 |Acct_Clerk_Check == 1 |Clerk_Check == 1
	replace Low = 0 if Low == .

* Seniority rank 
	gen Seniority = 1 if Teller == 1 | Senior_Associate_Check == 1 |Associate_Check == 1 |Sr_ACC_Check == 1 | JuniorACC_Check == 1 |staff_Check == 1 |Intern_Check == 1 |IRS_Agent_Check == 1 | Bookkeeper_Check == 1 | Assistant_Check == 1 | Examiner_Check == 1 |Acct_Clerk_Check == 1 |Clerk_Check == 1

	replace Seniority = 2 if Consultant_Check == 1 | Supervisor_Check == 1 | Analyst_Check == 1 | Principle_Check == 1 | Treasurer_Check == 1 | Director_Check == 1 | Senior_Manager_Check == 1 | Manager_Check == 1 | Senior_Check == 1 | Rev_Agent_check == 1 | Inv_Banker_Check == 1 | Account_Exec_Check == 1

	replace Seniority = 3 if CEO_Check == 1 | Pres_Check == 1 | VP_Check == 1 | Owner_Check == 1 | CFO_Check == 1 | CAO_Check == 1 | COO_check == 1 | Controller_Check == 1 | Senior_Partner_Check == 1 | Managing_Partner_Check == 1 | Partner_Check == 1 |Practice_Leader_Check == 1 | Chairman_Check == 1 | ChiefRisk_Check == 1 | Managing_Member_Check == 1

* Classify other cheif xxx
	replace Seniority = 3 if Seniority ==. & strpos(lower(title), "chief") > 0 

* Classify head
	replace Seniority = 3 if Seniority ==. & Global_Head == 1
	replace Seniority = 2 if Seniority ==. & Other_Head == 1

* Classify team member
	gsort key job_ord
	replace Seniority = 1 if Team_Member == 1 & job_ord < 4

* Classify global xxx
	replace Seniority = 2 if strpos(lower(title),"global") > 0 & Seniority ==.

	xtset key job_ord

* Remove individuals who have no job classified into any title
	bysort key: egen chk = max(Seniority)
	drop if chk == . 

* Generate cumulative years worked
	rename dur_yr tenure_years
	bys key (job_ord): gen Cum_Exp = sum(tenure_years)
	gen Cum_Fin = Cum_Exp - tenure_years
	drop Cum_Exp

* Look at individuals with one job not classified and one classified as level one
* Make job level one if stayed at the unclassified job less than 5 years; make two if more than 5 years
	replace Seniority = 2 if ((l.Seniority == .|f.Seniority == .) & (chk < 2 & num_job == 2)) & Seniority == . & tenure_years > 5
	replace Seniority = 1 if ((l.Seniority == .|f.Seniority == .) & (chk < 2 & num_job == 2)) & Seniority == . & tenure_years <= 5

	drop chk
	bysort key: egen chk = max(Seniority)
	drop if chk == 1 
	order key job_order tenure_years mean_dur_yr total_exp num_job High Mid Low Seniority title comp
	drop *check

save "output/Title_Clean", replace


/*******************************************************************************

Flag public accounting company names 

*******************************************************************************/

use "output/Title_Clean", clear

	replace comp = trim(comp)

* Search CPA firms 
	gen EY = 1 if (strpos(comp, "EY ")>0 | strpos(comp, "Ernst")>0 | strpos(comp, "ernst")>0) ///
	 	& (strpos(comp, "CORP")==0 ///
	 	& strpos(comp, "INC")==0 ///
	 	& strpos(comp, "BRA")==0 ///
	 	& strpos(comp, "PC")==0 ///
	 	& strpos(comp, "COMP")==0 ///
	 	& strpos(comp, "Scott")==0 ///
	 	& strpos(comp, "AND")==0 ///
	 	& strpos(comp, "PAI")==0) ///
	 	| strpos(comp, "Ernst & Young")>0 ///
	 	| strpos(comp, "Ernst & Young")>0 ///
		| strpos(comp, "E & Y")>0
	replace EY = 1 if strpos(comp,"EY")>0 & strpos(comp,"EY")<3 & length(comp)<4 
	replace EY = 1 if strpos(comp,"E&Y")>0 & length(comp)<4
	replace EY = 1 if strpos(lower(comp),"ernst")> 0 & strpos(lower(comp),"young")> 0
	replace EY = 1 if strpos(comp,"Ernest & Young")>0
	replace EY = 1 if comp == "E&Y (formerly ISA Consulting)"

	gen Grant = 1 if strpos(comp, "Grant T") > 0 | strpos(lower(comp), "grant thor")>0

	gen KPMG = 1 if strpos(comp, "KPMG") >0 ///
		| strpos(lower(comp), "kpmg")>0 ///
		| strpos(lower(comp), "marwick")>0

	gen Deloitte = 1 if strpos(comp, "Deloi")>0 ///
		| strpos(lower(comp), "deloit")>0 ///
		| strpos(lower(comp), "touch")>0


	gen PWC = 1 if strpos(comp, "PWC")>0 ///
		| strpos(comp, "pwc")>0 ///
		| strpos(comp, "PwC")>0 ///
		| strpos(comp, "price")>0 ///
		| strpos(comp, "Coopers")>0 ///
		| strpos(comp, "waterhouse")>0 ///
		| strpos(comp, "coopers")>0 ///
		| strpos(comp, "lybrand")>0 ///
		| strpos(lower(comp), "price waterhouse")>0

	gen Big4 = 1 if Grant==1 | KPMG==1 | Deloitte==1 | PWC==1

	gen BigN = 0
	replace BigN = 1 if Big4 == 1 | (strpos(lower(comp),"arthur") >0  & strpos(lower(comp),"andersen")  >0 )

	by key: egen Sum_Big4 = max(Big4)
	replace Sum_Big4 = 0 if Sum_Big4 == .

* Indentify by names
	gen In_ACC=1 if (strpos(comp, "&")>0 & strpos(comp, "LLC")>0)|strpos(comp, "CPA")>0 |Grant==1 | KPMG==1 | Deloitte==1 | EY==1 | PWC==1 | strpos(comp, "LLP")>0 | strpos(comp, " PC")>0 | strpos(lower(comp), "accountancy")>0 | strpos(comp, "McGladrey")>0 | strpos(comp, "ACCOUNTANCY")>0 | strpos(comp, "ACOUNTING")>0 | strpos(comp, "ACCOUNTING")>0 | strpos(comp, "P.C.")>0 | strpos(lower(comp), "accounting")>0 |strpos(comp, "Arthur Andersen")>0 |strpos(comp, "P C")>0 | strpos(comp, "PLLC")>0 | strpos(comp,"ACCOUNTANTS")>0| strpos(comp,"P.C")>0| strpos(lower(comp), "altschuler")>0| strpos(lower(comp), "alvey-")>0| strpos(comp, "C.P.A")>0 | strpos(lower(comp), "c.p.a")>0  | strpos(lower(comp), "plante moran")>0 | strpos(lower(comp), "plante & moran")>0 | strpos(comp, "Rachlin Cohen & Holtz")>0 | strpos(comp, "R�dl & Partner")>0 | strpos(comp, "Ryan & Associates P. C. ")>0 |  strpos(lower(comp), "kaufman")>0 | strpos(lower(comp), "accountants")>0| strpos(comp, "MBAF")>0| strpos(comp, "Morrison")>0| strpos(comp, "Montovani")>0| strpos(comp, "Olson,")>0| strpos(comp, "Ostrow")>0| strpos(comp, "Petrovits")>0| strpos(comp, "Powell, Ebert & Smolik")>0| strpos(comp, "Pratt & Whitney")>0| strpos(comp, "Prem Khandelwal")>0| strpos(comp, "Ralph Maya & Company")>0| strpos(comp, "Reznick Group")>0| strpos(comp, "Ronald Blue & Co.")>0| strpos(comp, "Ryan Gunsauls & Odonnell")>0 | strpos(comp, "Saltmarsh, Cleaveland & Gund")>0 | strpos(comp, "Samuel Gary, Jr. & Associates")>0 | strpos(comp, "Samuel S")>0 | strpos(comp, "Silver, Lerner, Schwartz & Fertel")>0 | strpos(comp, "Slade & Company")>0 | strpos(comp, "Steven White")>0 | strpos(comp, "Stephen James Associates")>0 | strpos(comp, "Stinchfield")>0 | strpos(comp, "Stone Trembly")>0 | strpos(comp, "Stone,")>0 | strpos(comp, "Stockman Kast Ryan & CO")>0 | strpos(comp, "Stuart Schmall & Co.")>0 | strpos(comp, "Taylor, Powell, Wilson, & Hartford P.A.")>0 | strpos(comp, "Taylor, Turner & Hartsfield")>0 | strpos(comp, "The Condon Group, Ltd.")>0 | strpos(comp, "The Wenner Group, LLC")>0 | strpos(comp, "Tilson, Lynch & Company")>0 | strpos(comp, "Tone, Walling, & Meador")>0| strpos(comp, "Wall, Smith, Bateman & Associates")>0 | strpos(comp, "Wall, Smith, Bateman & Associates, Inc.")>0 | strpos(comp, "Weinhold, Nickel and Co.")>0 | strpos(comp, "Weinstein Spira & Company")>0 | strpos(comp, "Weiss, Block, Karp, Mandell and Caskey")>0 | strpos(comp, "frohm, kelley, butler and Ryan pc")>0 | strpos(comp, "kaufmann gallucci and grumer llp")>0 | strpos(comp, "meahl mcnamara")>0 | strpos(comp, "mclaren & associates")>0 | strpos(comp, "tweneboah cpa and associate inc")>0 | strpos(comp, "Young, Craig & Co.")>0 | strpos(comp, "Wishnow, Ross Warsavsky  ")>0 | strpos(comp, "Wishnow, Ross, Warsavsky & Co ")>0 | strpos(comp, "WithumSmith+Brown")>0 | strpos(comp, "Squar Milner")>0 | strpos(comp, "McDowell, Dillon & Hunter")>0 | strpos(comp, "accountancy")>0 | strpos(comp, "Rothstein Kass")>0 | strpos(comp, "Brown & Johns, P.A.")>0 | strpos(comp, "Charles Z. Fedak and Associates")>0 | strpos(comp, "Miller and Company")>0 | strpos(comp, "Crawford, Pimentel & Co., Inc.")>0 | strpos(comp, "McFarlane, Cazale & Associates")>0| strpos(comp, "Richard T Dwyer & Co.")>0 | strpos(comp, "Lautze & Lautze")>0 | strpos(comp, "Murdock & Associates")>0 | strpos(comp, "Arthur Young & Co")>0 | strpos(comp, "Gilbert Associates, Inc.")>0 |  strpos(comp, "JPDH & Company")>0 | strpos(comp, "Arthur Young")>0 | strpos(comp, "Jassoy Graff & Douglas")>0 | strpos(comp, "Robert Lipsey & Company")>0 | strpos(comp, "Fitzgerald & Company")>0 | strpos(comp, "Goel Vinay and Associates")>0 | strpos(comp, "D. H. Scott & Company")>0 | strpos(comp, "Ingram Wallis & Company ")>0 | strpos(comp, "Corbin & Wertz")>0 | strpos(comp, "Kellogg & Andelson")>0 | strpos(comp, "John Ullman & Associates, Inc")>0 | strpos(comp, "McCahan, Helfrick, Thiercof & Butera")>0 | strpos(comp, "Yanari Watson McGaughey")>0 | strpos(comp, "Beers & Cutler")>0 | strpos(comp, "Hocking Denton Palmquist")>0 | strpos(comp, "Cobb Stees and Company")>0 | strpos(comp, "Davis Monk & Company")>0 | strpos(comp, "Drexel Burnham Lambert")>0 | strpos(comp, "Bellman-Melcor LLC")>0 | strpos(comp, "Knight and Company")>0 | strpos(comp, "WINDES & MCCLAUGHRY")>0 | strpos(lower(comp), "briscoe & company")>0 | strpos(comp, "CohnReznick")>0 | strpos(comp, "Kessler Orlean Silver")>0 | strpos(comp, "Freemon, Shapard & Story")>0 | strpos(comp, "Warren Averett, LLC ")>0 | strpos(comp, "Gifford Hillegass and Ingwersen, LLC")>0 | strpos(comp, "Les Kraitzick and Associates")>0| strpos(comp, "Diego Buonvino sole practitioner")>0 | strpos(comp, "BlumShapiro")>0 | strpos(comp, "Jennifer L. Wimpey Fletes, LLC")>0 | strpos(comp, "Arty, Cohn, & Feuer")>0 | strpos(comp, "RON MCKAIL & ASSOCIATES")>0 | strpos(comp, "Howard L. Rose and Company, P.A.")>0 | strpos(comp, "Thomas, Zurcher & White, P.A.")>0 | strpos(lower(comp), "arthur andersen")>0 | strpos(lower(comp), "parente randolph")>0 | strpos(comp, "Ehrhardt, Keefe")>0 | strpos(comp, "S. R. Batliboi")>0 | strpos(comp, "Warren Averett")>0 | strpos(lower(comp), "main hurdman")>0 | strpos(lower(comp), "vandenbroucke")>0 | strpos(lower(comp), "tardella")>0  | strpos(lower(comp), "reingold")>0 | strpos(lower(comp), "arthur anderson")>0 | strpos(comp, "1-800Accountant")>0 | strpos(comp, "ADP - Major Accounts")>0  | strpos(lower(comp), "alexander alvarez")>0 | comp == "Morgenstern Waxman Ellershaw" | comp == "Elser and Briggs" | comp == "Arthur Place & Co"

	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "kerry s emrick")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "premier tax & wealth advisors")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "williams & associates")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "seldon")>0  & strpos(lower(comp), "fox")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "hilmas")>0  & strpos(lower(comp), "associates")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "johanson")>0 & strpos(lower(comp), "yau")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "catanese group")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "mytaxlinx")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "beatty")>0 & strpos(lower(comp), "associates")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "erickson demel")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "rashba")>0 & strpos(lower(comp), "pokart")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "kraitzick")>0 & strpos(lower(comp), "associates")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "stinson")>0 & strpos(lower(comp), "associates")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "brostoski")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "doeren")>0 & strpos(lower(comp), "mayhew")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Mackowiak and Johnson")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Barron Yanaros and Caruso")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Rudney Solomon Cohen & Felzer")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Brandon & Tibbs")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Mary G Welch")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Eck Shafer")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Neuman")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "New Light Tax")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Tax Advisor")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Ledok")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Draniczarek")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "UHY Advisors")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Leydon & Gallagher")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Hertzbach")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Conn Geneva & Robinson")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Geisert & Huffman")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Greg Palacek")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "JDS Professional")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Fromson & Scissors")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Sorinsky")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Doyle & McDonnell")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "lawrence ollearis")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Birkholz")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Correll Porvin")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Fenner")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Sisterson &")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Jon Corbell")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Duggar")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Boyes, Wright, Pittman")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Adelson")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "RWK")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Dougherty")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Vejvoda")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Schaffer")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Synder & Jacobs")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "McElreath")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Golub Kessler")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Charneske")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Dupuis")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Sadowski &")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Higham and")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "McKnight")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Abraham")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Burkholder")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Rodriguez")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Seymour Schneidman")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Rogers &")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Heyse &")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Steensma")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Grimsley, White")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "jade")>0
	replace In_ACC = 1 if In_ACC == . & strpos(comp, "Attkisson Hongo")>0

* Self-employed
	replace In_ACC = 1 if In_ACC == . & title == "cpa" & strpos(lower(comp), "self")>0 & strpos(lower(comp), "employ")>0
	replace In_ACC = 1 if In_ACC == . & CPA == 1  & strpos(lower(comp), "self")>0 & strpos(lower(comp), "employ")>0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp), "accoun")>0  & strpos(lower(comp), "self")>0 & strpos(lower(comp), "employ")>0
	foreach x in accounting accountant bookkeep c.p.a quickbooks {
		replace In_ACC = 1 if In_ACC == . & strpos(lower(title),"`x'") & strpos(lower(comp), "self")>0 & strpos(lower(comp), "employ")>0
		replace In_ACC = 1 if In_ACC == . & strpos(lower(comp),"`x'") & strpos(lower(comp), "self")>0 & strpos(lower(comp), "employ")>0
	}
	replace In_ACC = 1 if In_ACC == . & strpos(title, "controll")>0 & strpos(title, "golf")==0 & strpos(title, "club")==0 & strpos(lower(comp), "self")>0 & strpos(lower(comp), "employ")>0

	gen self_check = 1 if In_ACC == . & strpos(lower(comp), "self employ")>0 & strpos(lower(title), "free")==0 ///
		& strpos(lower(title), "env")==0 & strpos(lower(title), "attorney")==0 ///
		& strpos(lower(title), "architectural")==0  & strpos(lower(title), "business development manager")==0 ///
		& strpos(lower(title), "business and technology consultant")==0 ///
		& strpos(lower(title), "caregiver for the severely disabled")==0 ///
		& strpos(lower(title), "trader")==0 & strpos(lower(title), "computer")==0 ///
		& strpos(lower(title), "consultant to medical schools and higher education")==0 ///
		& strpos(lower(title), "consulting/traveling")==0 ///
		& strpos(lower(title), "marketing")==0 ///
		& strpos(lower(title), "human resource")==0 ///
		& strpos(lower(title), "independent business owner")==0 ///
		& strpos(lower(title), "oracle")==0 ///
		& strpos(lower(title), "management consultant")==0 ///
		& strpos(lower(title), "product")==0 ///
		& strpos(lower(title), "videographer")==0 ///
		& strpos(lower(title), "golfer")==0 ///
		& strpos(lower(title), "system")==0 ///
		& strpos(lower(title), "yoga")==0 ///
		& strpos(lower(title), "property manager")==0 ///
		& strpos(lower(title), "project manager")==0 ///
		& strpos(lower(title), "qms")==0 ///

* Horwarth
	replace In_ACC = 1 if In_ACC ==. & strpos(lower(comp), "crowe")>0 & strpos(lower(comp), "horwath")>0
	replace In_ACC = 1 if In_ACC ==. & strpos(lower(comp), "laventhol")>0 & strpos(lower(comp), "horwath")>0
	replace In_ACC = 1 if In_ACC ==. & strpos(lower(comp), "laventhal")>0 & strpos(lower(comp), "horwath")>0 //wrong spelling
	replace In_ACC = 1 if In_ACC ==. & strpos(lower(comp), "lavethol")>0 & strpos(lower(comp), "horwath")>0 //wrong spelling
	replace In_ACC = 1 if In_ACC ==. & strpos(lower(comp), "leventhol")>0 & strpos(lower(comp), "horwath")>0 //wrong spelling
	replace In_ACC = 1 if In_ACC ==. & strpos(lower(comp), "horwath India")>0

* BDO
	replace In_ACC = 1 if In_ACC==. & ( ///
		strpos(comp,"BDO China") >0  | strpos(comp,"BDO Seidman") >0 ///
		| strpos(comp,"BDO USA") >0 | comp == "BDO" | strpos(comp,"BDO International") >0 ///
		| strpos(comp,"BDO Canada") >0 | strpos(comp,"Piccerelli Gilstein and Co") | strpos(comp,"BDO Trevisan") >0 ///
		| strpos(comp,"BDO Puerto Rico") >0 | strpos(comp,"BDO Spencer Steward") >0 | strpos(comp,"BDO South Africa") >0 ///
		| strpos(comp,"BDO Bulgaria") >0 | strpos(comp,"BDO AWT") >0 | strpos(comp,"BDO Sanyu") >0 ///
		| strpos(comp,"BDO Israel") >0 | strpos(comp,"BDO SEIDMAN") >0 | strpos(comp,"acquired by BDO") >0 ///
		| strpos(comp,"BDO Ziv Haft Israel") >0 | strpos(comp,"BDO Ireland)") >0 	///
		)

	replace In_ACC = 1 if In_ACC==. ///
		& (strpos(comp, "PA")>0 ///
		| strpos(comp, "P.")>0) ///
		&(strpos(comp, "J.")==0) ///
		& strpos(comp, "Law ")==0 ///
		& strpos(comp, "Ins")==0 ///
		& strpos(comp, "JAPA")==0 ///
		& strpos(comp, "Build")==0

	replace In_ACC=1 if In_ACC==. ///
		& strpos(title, "CPA")>0 ///
		& strpos(comp, "&")>0 ///
		& strpos(comp, "CAPITAL")==0 ///
		& strpos(comp, "Financial")==0

	replace In_ACC=1 if In_ACC==. & strpos(title, "CPA")>0  & strpos(comp, "PL")>0

* Independent accoutant 
	replace In_ACC = 1 if strpos(lower(title),"independent") >0  & strpos(lower(title),"accounting") >0 & In_ACC == .
	replace In_ACC = 1 if strpos(lower(title),"independent") >0  & strpos(lower(title),"accountant") >0 & In_ACC == .
	replace In_ACC = 1 if strpos(lower(title),"independent") >0  & strpos(lower(title),"bookkeeper") >0 & In_ACC == .
	replace In_ACC = 1 if strpos(lower(title),"independent") >0  & strpos(lower(title),"cpa") >0 & In_ACC == .
	replace In_ACC = 1 if strpos(lower(title),"independent") >0  & strpos(lower(title),"auditor") >0 & In_ACC == .
	replace In_ACC = 1 if lower(title) == "cpa"  & strpos(lower(comp),"independent") >0 & In_ACC == .
	replace In_ACC = 1 if lower(title) == "cpa" & strpos(lower(comp),"contract")>0 & In_ACC == .
	replace In_ACC = 1 if lower(comp) == "certified public accountant" & In_ACC == .
	replace In_ACC = 1 if lower(comp) == "cpa" & In_ACC == .
	replace In_ACC = 1 if strpos(lower(comp),"independent") > 0 & strpos(lower(comp),"accountant") > 0 & In_ACC == .

* Owner
	replace In_ACC = 1 if In_ACC == . & strpos(lower(title),"mary hitt") >0 //owner & principal, mary hitt, cpa
	replace In_ACC = 1 if In_ACC == . & strpos(lower(title),"owner") >0 & strpos(lower(comp),"certified public accountant") >0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(title),"founder") >0 & strpos(lower(comp),"certified public accountant") >0

* Bookkeeper
	replace In_ACC = 1 if In_ACC == . & (strpos(lower(comp),"bookkeep") >0 | strpos(lower(comp),"bookeep") >0 )

* Public accounting
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp),"public accounting") >0
	replace In_ACC = 1 if In_ACC == . & strpos(lower(comp),"accounting firm") >0

* Other
	replace In_ACC = 1 if In_ACC ==. & strpos(lower(comp),"bizcpas") >0 | strpos(lower(comp),"bakke") >0 | strpos(lower(comp),"brenda w smith") >0 | strpos(lower(comp),"phillips & associates") >0 | strpos(lower(comp),"phillips & associates") >0

/*******************************************************************************

Flag industries other than public accounting 

*******************************************************************************/

* Millitary, court, government
	gen millitary = strpos(lower(comp),"army")>0 | strpos(lower(comp),"navy")>0 | strpos(lower(comp),"air force")>0
	gen court =  strpos(lower(comp)," court ")>0  & strpos(lower(comp),"hotel")==0 //design
	gen government =  strpos(lower(comp),"government") >0 | strpos(lower(comp),"department of") >0 | strpos(lower(comp),"city of") >0 | strpos(lower(comp),"state auditor") >0 | strpos(lower(comp),"state of") >0 | strpos(lower(comp),"internal revenue service") >0
	gen university = strpos(lower(comp),"university") >0
	gen school = strpos(lower(comp),"school") >0 | strpos(comp,"College ") >0 | strpos(comp," College") >0
	gen finance = strpos(lower(comp),"bank") >0 | strpos(lower(comp),"hedge fund") >0 | strpos(lower(comp),"financial") >0 | strpos(lower(comp),"investment") >0 | strpos(lower(comp),"finance") >0 | strpos(comp,"Financial")>0 | strpos(comp,"FInancial")>0 | strpos(lower(comp),"finanical") >0 | strpos(lower(comp),"finaical") >0 | strpos(lower(comp),"brokerage") >0  | strpos(lower(comp),"american express") >0
	gen health = strpos(lower(comp),"health") >0 |  strpos(lower(comp),"healthcare") >0
	gen realestate = strpos(lower(comp),"realestate") >0 | strpos(lower(comp),"real estate") >0
	gen hospital = strpos(lower(comp),"hospital") >0
	gen food =  strpos(lower(comp),"food") >0 | strpos(lower(comp),"catering") >0
	gen ernergy = strpos(lower(comp),"ernergy") >0 | strpos(lower(comp),"resource") >0
	gen transportation = strpos(lower(comp),"airline") >0
	gen tech = strpos(lower(comp),"technology") >0 | strpos(lower(comp),"tech ") >0
	gen other = strpos(lower(comp),"coach") >0 | strpos(lower(comp),"national pupulation vote") >0 | strpos(lower(comp),"product") >0 | strpos(lower(comp),"glass") >0

	gen corp = 0
	foreach x in corp inc llc company plc {
		replace corp = 1 if strpos(lower(comp),"`x'")
	}
	gen comp_raw = comp 

/*******************************************************************************

Correct misclassifications

*******************************************************************************/

	replace In_ACC =. if comp == "CAPA International Education"
	replace In_ACC = . if strpos(lower(comp),"shop.com") >0
	replace In_ACC = . if strpos(lower(title),"faculty") >0
	replace In_ACC = . if strpos(lower(title)," PC") >0 & ///
		( strpos(comp,"EPCPA PLLC") >0 | strpos(comp,"SPCA") >0 ///
		| strpos(comp,"Sprint") >0 ) //correct " PC"
	replace In_ACC = . if In_ACC == 1 & (millitary == 1 | court == 1 | government == 1 | university == 1 |  school == 1 ///
		| health == 1 | hospital == 1 | food == 1 ///
		| transportation == 1 | other == 1 )
	replace In_ACC = 1 if strpos(lower(title),"arthur") >0 & government == 1

	replace In_ACC = 0 if In_ACC==.

save "temp/Public_Acc_Temp", replace

/*******************************************************************************

String match using AuditAnalytics and Compustat

*******************************************************************************/

* Import using files from Auditanalytics list 
use "raw/public_acc_audit_0731", clear

	foreach x in inc , . llp llc ltd &co pllp & co plc {
		replace auditor_name = subinstr(lower(auditor_name),"`x'","",.)
	}
	replace auditor_name = subinstr(lower(auditor_name),"  "," ",.)
	replace auditor_name = subinstr(lower(auditor_name),"   "," ",.)
	replace auditor_name = subinstr(lower(auditor_name),"    "," ",.)
	replace auditor_name = trim(auditor_name)
	duplicates list auditor_name
	duplicates drop auditor_name,force

save "temp/public_acc_auditanalytics_raw", replace


use "raw/public_acc_audit_0731", clear
	keep if strpos(lower(auditor_name),"&") >0
	duplicates drop auditor_name,force
save "temp/public_acc_auditanalytics_sub&", replace

use "raw/public_acc_audit_0731", clear
	keep if strpos(lower(auditor_name),"&") ==0
	duplicates drop auditor_name,force
save "temp/public_acc_auditanalytics_sub&2", replace

* Compustat list
use "raw/public_acc_compustat_0731", clear

	keep if fyear == 2018
	duplicates drop gvkey conm, force
	duplicates list conm
	duplicates drop conm, force
	destring gvkey, replace
	foreach x in , . & {
		replace conm = subinstr(lower(conm),"`x'","",.)
	}
	foreach x in inc lp llc ltd &co pllp co plc{
		replace conm = subinstr(lower(conm)," `x'","",.)
	}
	replace conm = subinstr(lower(conm),"  "," ",.)
	replace conm = subinstr(lower(conm),"   "," ",.)
	replace conm = subinstr(lower(conm),"    "," ",.)
	replace conm = trim(conm)
	duplicates list conm
	duplicates drop conm, force

save "temp/public_acc_compustat_raw", replace

* Combine 
use "raw/public_acc_compustat_0731", clear
	duplicates drop gvkey conm, force
	duplicates list conm
	duplicates drop conm,force
	destring gvkey, replace
	replace conm = proper(conm)
	gen ID = _n
save "temp/public_acc_compustat_all", replace

* Create 40 files
forvalue i = 0(1000) 40000{
	use "temp/public_acc_compustat_all", clear
	local j = `i'
	local k = `i' + 1000
	keep if ID >= `j' & ID < `k'
	save "temp/ccm_`i'", replace
}

* CRSP list 
use "raw/crsp_0803", clear
	duplicates drop permno,force
	duplicates drop comnam,force
	replace comnam = lower(comnam)
save "temp/crsp", replace

* Create an unique master file for matching 
use "temp/Public_Acc_Temp", clear
	keep key title comp_raw comp Big4 In_ACC
	duplicates drop comp,force
	foreach x in , . & {
		replace comp = subinstr(lower(comp),"`x'","",.)
	}
	foreach x in inc lp llc ltd &co pllp co plc{
		replace comp = subinstr(lower(comp)," `x'","",.)
	}
	replace comp = subinstr(lower(comp),"  "," ",.)
	replace comp = subinstr(lower(comp),"   "," ",.)
	replace comp = subinstr(lower(comp),"    "," ",.)
	replace comp = trim(comp)
	duplicates drop comp,force
	gen comp_id = _n
save "temp/Public_Acc_Part2_Master", replace

* Exact match 
use "temp/Public_Acc_Part2_Master", clear
	gen auditor_name = comp
	gen conm = comp
	merge m:1 auditor_name using "temp/public_acc_auditanalytics_raw", keepusing(auditor_key)
	drop if _m == 2
	drop _m auditor_name
	merge m:1 conm using "temp/public_acc_compustat_raw", keepusing(gvkey conm) update
	drop if _m == 2
	drop _m
	duplicates drop comp_raw, force
save "temp/Public_Acc_Match_R1", replace

* Merge results 
use "temp/Public_Acc_Temp", clear
	merge m:1 comp_raw using "temp/Public_Acc_Match_R1.dta", keepusing(gvkey auditor_key) update
	drop if _m == 2
	drop _m
	replace In_ACC = 1 if auditor_key !=. 
	gen Public_Listed = 1 if gvkey !=. 
save "temp/Public_Acc_Match_Results1", replace

* Repeat matching 
use "temp/Public_Acc_Match_R1", clear
	keep if gvkey == . & auditor_key ==.
save "temp/Public_Acc_Match_M1", replace

use "temp/Public_Acc_Match_M1", clear 
	matchit comp_id comp_raw using "temp/public_acc_auditanalytics_raw.dta", txtu(auditor_name) idusing(auditor_key) similmethod(token_soundex) threshold(0.8)
	egen max_sim = max(similscore), by (comp_id)
	gsort comp_id -similscore
	by comp_id: gen count = _n
	bys comp: gen bestmatch = _n==1
save "temp/Public_Acc_Match_AuditAnalytics_Token_Soundex", replace

use "temp/Public_Acc_Match_AuditAnalytics_Token_Soundex", clear
	gen left = ustrleft(comp, 8)
	gen right = ustrleft(auditor_name, 8)
	keep if left == right & similscore >. 85
	merge m:m comp using "temp/Public_Acc_Part2_Master", keepusing(comp_raw) update 
	drop if _m == 2
	drop _m
	duplicates drop comp_raw, force
save "temp/Public_Acc_Match_R2.dta", replace 

use "temp/Public_Acc_Match_M1", clear
	matchit comp_id comp using "temp/public_acc_compustat_raw.dta", txtu(conm) idusing(gvkey) similmethod(token_soundex) threshold(0.8)
	egen max_sim = max(similscore), by(comp_id)
	gsort comp_id -similscore
	by comp_id: gen count = _n
	bys comp: gen bestmatch = _n == 1
save "temp/Public_Acc_Match_Compustata_Token_Soundex", replace

use "temp/Public_Acc_Match_Compustata_Token_Soundex", clear
	gen left = ustrleft(comp,8)
	gen right = ustrleft(conm,8)
	keep if left == right & similscore >.85
	merge m:m comp using "temp/Public_Acc_Part2_Master", keepusing(comp_raw) update
	drop if _m == 2
	drop _m
	duplicates drop comp_raw, force
save "temp/Public_Acc_Match_R3.dta", replace

* Merge results
use "temp/Public_Acc_Temp", clear
	merge m:1 comp_raw using "temp/Public_Acc_Match_R1.dta", keepusing(gvkey auditor_key) update
	drop if _m == 2
	drop _m
	merge m:1 comp_raw using "temp/Public_Acc_Match_R2.dta", keepusing(auditor_key) update
	drop if _m == 2
	drop _m 
	merge m:1 comp_raw using "temp/Public_Acc_Match_R3.dta", keepusing(gvkey) update
	drop if _m == 2
	drop _m 

	replace In_ACC = 1 if auditor_key !=. 
	gen Listed = 0
	replace Listed = 1 if gvkey !=. 

* Mannual correction
	replace Listed = 1 if Listed == 0 & (comp == "Uber" | comp == "3M" | comp == "GE" | comp == "Dell" )
	replace Listed = 1 if Listed == 0 & (strpos(lower(comp),"citigroup") >0 | strpos(lower(comp),"general electric") >0)
	replace Listed = 1 if Listed == 0 & (strpos(lower(comp),"nyse :") >0 | (strpos(lower(comp),"nasdaq") >0 & comp != "Nasdaq" & comp!= "NASDAQ OMX"))
	replace Listed = 1 if Listed == 0 & comp == "Toyota" | strpos(lower(comp),"toyota north america") >0 | (strpos(comp,"GE ") >0 & strpos(comp,"GE ") <3)

	gsort key job_ord

save "temp/Company_Clean1", replace

* String match using CRSP
use "temp/Company_Clean1", clear
	keep if In_ACC ==0 & government ==0 & Listed ==0 & court ==0 & millitary == 0 & university== 0 & comp!="" & school ==0 & finance == 0 & realestate == 0 & hospital == 0 & corp == 0 & food == 0 & transportation ==0 & ernergy ==0
	duplicates drop comp,force
	sort comp
	gen comp_id = _n
	tempfile left
save `left', replace

matchit comp_id comp using "temp/crsp.dta", txtu(comnam) idusing(permno) threshold(0.8)
drop if comp == "Deposco"
save "temp/left_matches_1", replace

use "temp/Company_Clean1", clear
	merge m:1 comp using "temp/left_matches_1", keepusing(permno) update
	drop if _m == 2
	drop _m
	replace Listed = 1 if Listed == 0 & permno !=.

save "temp/Company_Clean2", replace

* Match using audit analytics sub sample 1 "&"
use "temp/Company_Clean2", clear
	gen check = 0
	replace check = 1 if In_ACC ==0 & government ==0 & Listed ==0 & court ==0 & millitary == 0 & university== 0 & comp!="" & school ==0 & finance == 0 & realestate == 0 & hospital == 0 & corp == 0 & food == 0 & transportation ==0 & ernergy ==0 & health== 0
	keep if check == 1
	duplicates drop comp,force
	sort comp
	keep key comp comp_raw
	keep if strpos(lower(comp), "&") > 0
	gen comp_id = _n
	tempfile left2
save `left2', replace

use "temp/public_acc_auditanalytics_sub&.dta", clear
	matchit auditor_key auditor_name using `left2' , txtu(comp) idusing(comp_id) threshold(0.7)
	egen max_sim = max(similscore), by (comp_id)
	gsort comp_id -similscore
	by comp_id: gen count = _n
	bys comp: gen bestmatch = _n==1
save "temp/left_matches_2_raw", replace

* Clean matches
use "temp/left_matches_2_raw", clear
	keep if similscore >0.85
	drop if auditor_name == "Varma & Associates" & comp == "Jarman & Associates"
	drop if auditor_name == "Bujan & Associates Ltd" & comp == "Logan & Associates Ltd"
	drop if auditor_name == "Fine & Associates" & comp == "LaBine & Associates"
	drop if auditor_name == "Bailey & Associates"
	drop if auditor_name == "Nilson & Associates"
	drop if auditor_name == "HDSG & Associates"
	drop if auditor_name == "Boler & Associates"
	drop if auditor_name == "Erickson & Associates SC"
	drop if auditor_name == "Haran & Associates Ltd"
	drop if auditor_name == "Henson & Associates"
	drop if auditor_name == "Huber & Associates"
	drop if auditor_name == "Hudson Anderson & Associates PC"
	drop if auditor_name == "Evanson & Associates"
	drop if auditor_name == "JW Anderson & Associates PC"
	drop if auditor_name == "Stotley & Associates"
	drop if comp == "Anderson & Associates"  //law firm
	drop if auditor_name == "Brewster & Associates"
	drop if auditor_name == "Doran & Associates"
	drop if auditor_name == "Marmann & Associates PC"
	drop if comp == "Morris & Associates" //construction
	drop if auditor_name == "AKG & Associates"
	drop if comp == "Weisman & Associates" //law
	drop if auditor_name == "GSA & Associates"
	drop if auditor_name == "ABP & Associates"
	drop if auditor_name == "PA & Associates"
	drop if auditor_name == "Harrison & Associates"
	drop if auditor_name == "A & G Associates"
	duplicates list comp
	duplicates drop comp, force
save "temp/left_matches_2", replace

* Match using audit analytics sub sample 2
use "temp/Company_Clean2", clear
	gen check = 0
	replace check = 1 if In_ACC ==0 & government ==0 & Listed ==0 & court ==0 & millitary == 0 & university== 0 & comp!="" & school ==0 & finance == 0 & realestate == 0 & hospital == 0 & corp == 0 & food == 0 & transportation ==0 & ernergy ==0 & health== 0
	duplicates drop comp,force
	sort comp
	keep key comp comp_raw
	keep if strpos(lower(comp),"&")==0
	duplicates drop comp,force
	gen comp_id = _n
	tempfile left3
save `left3', replace

	matchit comp_id comp using "temp/public_acc_auditanalytics_sub&2.dta", txtu(auditor_name) idusing(auditor_key) threshold(0.8)
	egen max_sim = max(similscore), by (comp_id)
	gsort comp_id -similscore
	by comp_id: gen count = _n
	bys comp: gen bestmatch = _n==1
save "temp/left_matches_3_raw", replace

use "temp/left_matches_3_raw", clear
	keep if similscore >0.9
save "temp/left_matches_3", replace

* Merge results 
use "temp/Company_Clean2", clear
	merge m:1 comp using "temp/left_matches_3", keepusing(auditor_key) update
	drop if _m == 2
	drop _m
	merge m:1 comp using "temp/left_matches_2", keepusing(auditor_key) update
	drop if _m == 2
	drop _m
	replace In_ACC = 1 if auditor_key !=. & In_ACC == 0 
	replace Listed = 1 if gvkey !=. & Listed == 0

* Mannual correction
	gen check = 0
	replace check = 1 if In_ACC ==0 & government ==0 & Listed ==0 & court ==0 & millitary == 0 & university== 0 & comp!="" & school ==0 & finance == 0 & realestate == 0 & hospital == 0 & corp == 0 & food == 0 & transportation ==0 & ernergy ==0 & health== 0 & tech == 0

save "temp/Company_Clean3", replace

* Match using 40 files
use "temp/Company_Clean3", clear
	keep if Listed == 0
	drop if In_ACC == 1 | government == 1 | court == 1 | millitary == 1 | university == 1 | school == 1
	duplicates drop comp,force
	gen comp_id = _n
	keep comp_id comp
	tempfile clean3_raw
save `clean3_raw', replace

forvalue i = 28000(1000) 40000{
	use `clean3_raw', clear
	matchit comp_id comp using "temp/ccm_`i'.dta", txtu(conm) idusing(gvkey) threshold(0.88)
	egen max_sim = max(similscore), by (comp_id)
	gsort comp_id -similscore
	by comp_id: gen count = _n
	bys comp: gen bestmatch = _n==1
	save "temp/ccm_match_`i'", replace
}

forvalue i = 28000(1000) 40000{
	use "temp/ccm_match_`i'", clear
	keep if similscore > 0.89
	duplicates drop comp,force
	tempfile ccm_match_clean_`i'
	save `ccm_match_clean_`i'', replace
}

use "temp/Company_Clean3", clear
	forvalue i = 0(1000) 40000{
		merge m:1 comp using `ccm_match_clean_`i'', keepusing(gvkey) update
		drop if _m == 2
		drop _m
	}

	replace In_ACC = 1 if auditor_key !=. & In_ACC == 0 
	replace Listed = 1 if gvkey !=. & Listed == 0

* Measure In_ACC2 
	gen In_ACC2 = 1 if In_ACC == 1
	replace In_ACC2 = 1 if ( title == "cpa" & check == 1 & In_ACC == 0 ) | (strpos(lower(comp), "accoun")>0 & check == 1 & In_ACC == 0 ) | ( strpos(lower(comp), "& associate")>0 & check == 1 & In_ACC == 0 ) //734 changes
	label var In_ACC2 "include more potential/small pub acc firms"

save "output/Company_Clean", replace

/*******************************************************************************

Classify job positions
E.g., Accounting/Finance/Marketing/Law/Management/Banking/Big4/Big4_First/Tax

*******************************************************************************/

use "output/Company_Clean", clear

	keep key title comp Tax job_ord

* Classify Positions in Accounting //? what about senior consultant, cpa?
	gen Accounting=0
	replace Accounting=1 if strpos(title, "reporting") | strpos(title, "tax")| strpos(title, "audit")| strpos(title, "reporti")| strpos(title, "accounting")| strpos(title, "certified public accountant")| strpos(title, "cpa") | strpos(title, "accountant")
	replace Accounting=1 if strpos(title,"statem") & Accounting==0
	replace Accounting=1 if strpos(title,"accounta")& Accounting==0
	replace Accounting =1 if Accounting==0 & strpos(title,"assura")>0

* Classify Positions in Finance
	gen Finance=0
	replace Finance=1 if Accounting==0 & (strpos(title,"financ") | strpos(title,"investm"))
	replace Finance=1 if Accounting==0 & (strpos(title,"corporate") & strpos(title,"manager"))
	replace Accounting=1 if Accounting==0 & strpos(title,"book") & strpos(title,"text")==0

* Classify Positions in Marketing
	gen Marketing=0
	replace Marketing=1 if Accounting==0 & Finance==0 & (strpos(title,"market")>0 | strpos(title,"media")>0 )| strpos(title,"marketing")>0

* Classify Positions in Law
	gen Law=0
	replace Law=1 if Accounting==0 & Marketing==0 & Finance==0 & (strpos(title,"legal")>0| strpos(title,"law ")>0)

* Classify Positions in Management
	gen Management=0
	replace Management=1 if Accounting==0 & Finance==0 & Marketing==0 & Law==0 & (strpos(title,"operations")>0 )
	replace Management=1 if strpos(title,"busines") & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0
	replace Management=1 if strpos(title,"invent")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

* Classify controllors as Accounting
	replace Accounting=1 if strpos(title, "controll")>0 & strpos(title, "golf")==0 & strpos(title, "club")==0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Accounting=1 if strpos(title,"paya")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Accounting=1 if strpos(title,"recei")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Accounting=1 if strpos(title,"internal")>0 & strpos(title,"contro")>0  & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Accounting=1 if strpos(title,"internal")>0 & strpos(title,"agen")>0  & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Management=1 if strpos(title,"reve")>0 & strpos(title,"intern")==0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Management=1 if strpos(title,"cost")>0  & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Management=1 if strpos(title,"payroll")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Finance=1 if strpos(title,"insurance")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Finance=1 if  strpos(title,"account")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Management=1 if strpos(title,"consulta")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

* M&A as management
	replace Management=1 if strpos(title,"m&a")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

* Consulting as management
	replace Management=1 if strpos(title,"consulting")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Finance=1 if strpos(title,"manager")>0 & strpos(title,"asset")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Management=1 if strpos(title,"manager")>0 & strpos(title,"ass")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Management=1 if strpos(title,"manager")>0 & strpos(title,"gen")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

* Classify Positions in Banking
	gen Banking=0
	replace Banking=1 if strpos(title,"manager")>0 & strpos(title,"branch")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0

	replace Management=1 if strpos(title,"manager")>0 & strpos(title,"office")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0 & Banking==0

	replace Management=1 if strpos(title,"manager")>0 & strpos(title,"produ")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0 & Banking==0

	replace Marketing=1 if strpos(title,"manager")>0 & strpos(title,"brand")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0 & Banking==0

	replace Management=1 if strpos(title,"manager")>0 & strpos(title,"hr ")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0 & Banking==0

	replace Accounting=1 if strpos(title, "treasur")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0 & Banking==0

	replace Banking=1 if strpos(title, "bank")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0 & Banking==0

	replace Finance=1 if strpos(title, "asset")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Management==0 & Banking==0

	replace Accounting=1 if strpos(title,"accout")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0

	replace Management=1 if strpos(title,"account")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0

	replace Finance=1 if (strpos(title,"hedge f")>0 | strpos(title,"mutual f")>0 )& Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0

	replace Finance=1 if (strpos(title,"hedge f")>0 | strpos(title,"fund m")>0 )& Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0

	replace Finance=1 if (strpos(title,"hedge f")>0 | strpos(title,"hedge")>0 )& Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0

	replace Finance=1 if strpos(title,"stockb")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0

	replace Accounting=1 if strpos(title,"acounta")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0

	replace Banking=1 if strpos(title,"loan")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0

	replace Banking=1 if strpos(title,"teller")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0

	replace Banking=1 if strpos(title,"lend")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0

* Mannually check classifications
	gen Temp_Job = 0
	replace Temp_Job = 1 if strpos(title,"temp")>0 & Accounting==0 & Finance==0 & Marketing==0 & Law==0 & Banking==0
	egen MTemp = max(Temp_Job),by(key)
	drop Temp_Job
	rename MTemp Temp_Job

* Create an identifier if Big4 is the first job 
	gen Big4_First = 0
	replace Big4_First = 1 if Big4==1 & job_ord==1

	gen BigN=0
	replace BigN=1 if strpos(lower(comp),"deloi")>0 | strpos(lower(comp),"touch")>0 | strpos(lower(comp),"pwc")>0| strpos(lower(comp),"pricew")>0| strpos(lower(comp)," ey ")>0 | strpos(lower(comp),"ernst ")>0| strpos(lower(comp),"& young ")>0 | strpos(lower(comp),"kpmg")>0 | strpos(lower(comp),"peat ma")>0| (strpos(lower(comp),"arthur ")>0 & strpos(lower(comp),"anderson")>0)
	replace BigN=1 if strpos(comp,"EY") > 0 & BigN == 0 & length(comp) < 3
	replace BigN=1 if strpos(lower(comp),"price water") > 0 & BigN == 0
	replace BigN=1 if strpos(lower(comp),"coopers") > 0 & BigN == 0
	replace BigN=1 if (strpos(lower(comp),"arthur") > 0  & strpos(lower(comp),"andersen")  >0 ) & BigN == 0
	replace BigN=1 if  BigN == 0 & strpos(lower(comp),"grant t") > 0
	replace BigN=1 if BigN == 0 & strpos(lower(comp),"arthur an") > 0

	gen BigN_First = 0
	replace BigN_First = 1 if BigN == 1 & job_ord == 1
	tab BigN_First

* Tax Focus
	replace Tax = 1 if strpos(title,"tax") > 0 | strpos(lower(comp),"tax") > 0

* Has CPA or not 
* Bring in raw names to identify cpas
	merge m:1 key using "output/Comb_Directory_Cleaned_Noduplicates", keepus(raw_name clean_name firstname middlepreferredname lastname)
	drop if _m == 2
	drop _m

	gen has_cpa = 0
	replace has_cpa= strpos(title, "CPA") | strpos(title, "Certified Public Accountant") |strpos(title, "cpa") | strpos(title, "certified public accountant") | strpos(title,"CERTIFIED PUBLIC ACCOUNTANT") | strpos(title, "C.P.A.")| strpos(title, "Cpa") | strpos(title, "Certified public accountant") | strpos(title, "C P A TAXATION")
	replace has_cpa = 1 if has_cpa == 0 & strpos(lower(raw_name),"cpa")>0
	replace has_cpa = 1 if strpos(lower(raw_name),"cpa")>0 | strpos(lower(raw_name),"c.p.")>0| strpos(lower(raw_name),"acco")>0
	replace has_cpa = 1 if has_cpa == 0 & Big4 == 1
	replace has_cpa = 1 if has_cpa == 0 & Tax == 1
	replace has_cpa = 1 if has_cpa == 0 & Accounting == 1
	replace has_cpa = 1 if has_cpa == 0 & Big4 == 1

* Individual measures
	foreach x of varlis Accounting Finance Marketing Law Management Banking Big4 Big4_First BigN BigN_First Tax has_cpa{
		egen M`x'=max(`x'),by(key)
		drop `x'
		rename M`x' `x'
	}

* Data with one observation for each individual 
	duplicates drop key, force

	gen position_classified = Accounting + Finance+ Law + Management  + Banking + Marketing + Tax + Big4

	drop job_order
	order key title comp Accounting Finance Marketing Law Management Banking Big4 Big4_First Tax has_cpa position_classified

save "output/Ind_Emp_Sum", replace


/*******************************************************************************

Clean education data and classify degrees

*******************************************************************************/

import delimited "raw/education_info.csv", varnames(1) clear 

	foreach x in school spec descr {
		format %50s `x'
	}

* Clean dates 
	replace start = yrstart if key > 22100
	replace end = yrend if key > 22100
	drop yrstart yrend indivID
	egen sy = sieve(start), keep(n)
	egen ey = sieve(end), keep(n)
	rename start start_raw
	rename end end_raw
	rename sy start
	rename ey end

	foreach x in start end {
		gen length_`x' = length(`x') 
		destring `x',force replace
		gen `x'_temp = `x' 
		replace `x' = 2000 + `x'_temp if `x' <= 20 // years >= 2000
		replace `x' = 1900 + `x'_temp if `x' > 20 & `x' < 100 & length_`x' == 2 // years < 2000
			drop `x'_temp
	}

	tabstat start end,  stats(mean median sd N min p5 p95 max) columns(statistics)

* Clean descriptions
	replace spec = trim(spec)
	replace description = trim(description)
	replace spec = description if spec == "" & description != ""
	drop description
	replace descr = spec if descr == "" & spec !=""
	format %15s spec
	format %15s descr
	order key school descr

* Duplicates drop 
	duplicates drop key school descr start end, force

* Drop High Schools and primaries
	drop if school=="" & descr==""
	drop if strpos(lower(school),"high")>0 | strpos(lower(school),"middle school")>0 | strpos(school," HS")>0
	drop if strpos(lower(spec),"high ")>0 | strpos(lower(descr),"high ")>0 | strpos(lower(descr),"hs diploma")>0
	drop if strpos(lower(spec),"college prep")>0
	drop if strpos(lower(spec),"a-level")>0	| strpos(lower(spec),"a level")>0
	drop if strpos(lower(spec),"o-level")>0	| strpos(lower(spec),"o level")>0
	drop if strpos(lower(school),"talent")>0 | strpos(lower(school),"train")>0 | strpos(lower(descr),"training course")>0
	drop if strpos(lower(school),"prim")>0
	drop if strpos(lower(school),"coursera")>0
	drop if strpos(lower(spec),"coursera")>0 | strpos(lower(descr),"coursera")>0
	drop if strpos(lower(school),"second")>0
	drop if strpos(lower(school),"self education")>0
	drop if strpos(lower(school),"prep")>0
	drop if strpos(lower(school),"regist")>0
	drop if strpos(lower(school),"elementary")>0
	drop if strpos(lower(descr),"study ab")>0 | strpos(lower(descr),"boardi")>0
	drop if strpos(lower(descr), "abroad") > 0 | strpos(lower(descr), "exchange") > 0
	drop if strpos(lower(school),"president p")>0 | strpos(lower(descr),"president ")>0
	drop if strpos(lower(school),"attend")>0 | strpos(lower(descr),"attend")>0
	drop if strpos(lower(school),"summer")>0 | strpos(lower(descr),"summer")>0
	drop if strpos(lower(school),"continuing")>0 | strpos(lower(descr),"continuing")>0 | strpos(lower(descr),"continued education")>0
	drop if strpos(lower(school),"secondary")>0
	drop if strpos(lower(descr),"credentia")>0
	drop if strpos(lower(descr),"none")>0
	drop if strpos(lower(descr),"n/a,")>0
	drop if strpos(lower(descr),"wine")>0 & strpos(lower(descr),"level")>0
	drop if strpos(lower(descr),"leadership program")>0

* Drop incomplete degrees
	drop if strpos(lower(descr),"not complete") > 0
	drop if strpos(lower(descr),"no degree") > 0
	drop if strpos(lower(descr),"incomplete") > 0

* Drop data error, key == 13235
	drop if key == 13236 & school == "Maire School"
	drop if key == 13236 & school == "St. Mark's School"
	drop if key == 17643 & school != "Farmingdale State University of New York"

* Check outliers. High schools, companies, leadership programs
	drop if strpos(lower(descr),"4 month") > 0
	drop if school == "University of San Francisco Law Review"
	drop if strpos(lower(school), "state bar") > 0
	drop if strpos(lower(school), "hangzhou foreign languages school") > 0
	drop if strpos(lower(school), "crescent girls' school") > 0
	drop if strpos(lower(descr), "gce") > 0
	drop if school == "Bank of America Securities"
	drop if school == "First National Bank of Chicago"
	drop if school == "Technical and System Skills"
	drop if school == "Driven For Life"
	drop if school == "Quantum Resources"
	drop if school == "Landmark Education"
	drop if school == "Toastmasters International - Ingram Microphones"
	drop if school == "The Founder Institute"
	drop if school == "Cantonal Bank of Bern"
	drop if school == "(ISC)2"
	drop if school == "Udemy" | school == "xx" | school == "Allidina Visram" | school == "Habib public school"
	drop if school == "Microsoft certification"
	drop if school == "Hein and Associates"
	drop if school == "Watkins Glen Central School"
	drop if school == "Ida Crown"
	drop if school == "Leadership Pueblo"
	drop if school == "Chapman College Afloat"
	drop if descr == "general education classes - tennis team"
	drop if key == 5345 & descr == "Geography"
	drop if school == "Robinson School" | school == "Immaculate Conception Academy HS"
	drop if school == "Loomis-Chafee"
	drop if school == "Cisco Networking Academy" | school == "Spartan Village Global Leadership Academy"
	drop if school == "Ecole Al Jabr"
	drop if school == "Groupe Scolaire D'Anfa."
	drop if school == "St Pete CHAMBER Entrepreneurial Academy"
	drop if school == "American Society of Military Comptrollers"
	drop if strpos(lower(school), "notary public") > 0
	drop if school == "Consulting" | school == "Defense Language Institute Foreign Language Center"
	drop if school == "Vastergard Gymnasiet" | school == "School name:" | school == "Modern School" | school == "School of Life"
	drop if strpos(lower(school), "educacion juridica") > 0
	drop if descr == "Disruptive Strategy with Clayton Chistensen, Business strategy"
	drop if school == "John Maxwell Intentional Living" |  school == "International House Xi'an, China" | school == "chess school"
	drop if school ==	"Society of Human Resources" | school == "Master" | school == "Meetup" | lower(school) == "other" | school == "P.S. 200"
	drop if school == "HCI" | school == "Confidential" | school == "Computer Systems Skills"
	drop if school == "Thornwood H.S." | school == "Shaw Academy" | school == "Miriam College" | school == "BB & N" | school == "Principia Upper School"
	drop if strpos(lower(school), "new oriental") > 0 |  school == "Wine & Spirit Education Trust"
	drop if school == "Corona" | school == "NIA Chicago" | school == "Advisory Board"
	drop if descr == "Women's Executive Leadership:  Business Strategies for Success [October 2017]"
	drop if school == "Sandler / Acuity Systems, Inc." | school == "Aledo"
	drop if school == "Technical Certification, Control Data Institute" | school == "ACS" | school == "Hillcrest"
	drop if descr == "Assoc. Dean, International Tax & Financial Services" | school == "Strategic Sales & Marketing Management Program, 2002"
	drop if school == "oracle university" | school == "starehe boys center" | school == "Boys' Latin School" | school == "La Pietra- Hawaii School for Girls" | school == "Raffles Girls' School" | school == "Stella Maris Convent Girls School"
	drop if school == "2017 Level I Candidate in the CFA Program"

* Flag Tax, Accounting, AICPA, CPA, CMA, Cerficates 
* Identifier for Tax
	gen Tax_F = 0
	replace Tax_F = 1 if strpos(lower(descr), "tax") | strpos(lower(school), "tax") | strpos(lower(spec), "tax")

* Identifier for Accounting
	gen ACC_F = 0
	replace ACC_F = 1 if strpos(lower(spec),"acc") > 0 | strpos(lower(descr),"acc") > 0

* Identifier for the AICPA membership
	gen AICPA = 0
	replace AICPA = 1 if strpos(lower(school),"american ins") > 0
	replace AICPA = 1 if AICPA == 0 & strpos(lower(school),"aicpa") > 0
	replace AICPA = 1 if AICPA == 0 & strpos(lower(school),"ficpa") > 0
* Identifier for for CPA and CMA
	gen CPA= 0
	replace CPA = 1 if CPA == 0 & AICPA == 0 & strpos(lower(school),"cpa") > 0
	replace CPA = 1 if CPA == 0	& AICPA == 0 & strpos(lower(school),"certified p") > 0
	replace CPA = 1 if CPA == 0 & AICPA == 0 & strpos(lower(school),"charter") > 0 & strpos(lower(school),"mana") == 0 & strpos(lower(school),"colle") == 0
	replace CPA = 1 if CPA == 0 & AICPA == 0 & strpos(lower(school),"c.p.a") > 0

	gen CMA = 0
	replace CMA = 1 if CPA == 0 & AICPA == 0 & strpos(lower(school),"mana")>0 & strpos(lower(school),"colle") == 0 & strpos(lower(school),"acc")>0 & strpos(lower(descr),"bach") == 0
		
* Identifier for certificates
	gen Certificate=0
	replace Certificate=1 if strpos(lower(descr),"certi") > 0
	replace Certificate=1 if Certificate == 0 & (CMA==1|CPA==1|AICPA==1)
	replace Certificate=1 if Certificate == 0 & strpos(lower(descr),"cfa") > 0
	replace Certificate=1 if Certificate == 0 & strpos(lower(descr),"cer") > 0

* Individual indentifiers
	foreach x of varlist AICPA CPA CMA Certificate Tax_F {
		egen M`x' = max(`x'), by(key)
		drop `x'
		rename M`x' `x'
	}

* Drop non degrees 
	egen Num_Deg=count(key), by(key)

	drop if Num_Deg > 1 & (strpos(lower(school),"american ins") > 0	///
		| strpos(lower(school),"aicpa") > 0 ///
		| AICPA == 0 & strpos(lower(school),"ficpa") > 0)
	drop if strpos(lower(school),"certified") > 0 | strpos(lower(school),"accounting education") > 0
	drop if strpos(lower(school),"board ")>0 & strpos(lower(school), "professional education") > 0
	drop if strpos(lower(school), "association") > 0 | strpos(lower(school), "adult education") > 0
	drop if strpos(lower(school), "quickbooks") > 0
	drop if strpos(lower(descr), "cpa class") > 0

	drop Num_Deg

* Identifier for a Bachelor Degree 
	gen Bachelor = strpos(descr, "Bachelor") | strpos(descr, "bachelor") | strpos(descr, "B.A.") ///
		| strpos(descr, "B A") | strpos(descr, "B. S.") | strpos(descr, "B.S.") ///
		| strpos(descr, "BA") | strpos(descr, "BS") | strpos(descr, "B.") ///
		| strpos(descr, "B.B.A.") |strpos(descr, "B.B.A") | strpos(descr, "BBA") ///
		| strpos(descr, "B/S") | strpos(descr,"SB") |strpos(descr, "BGS") ///
		| strpos(descr, "BSBA") | strpos(descr, "BSC") | strpos(descr, "Ba") ///
		| strpos(descr, "BASc") | strpos(descr, "bs,") | strpos(descr, "bsa,") ///
		| strpos(descr, "bs in") | strpos(descr, "Baccalaureate") ///
		| strpos(descr, "B B A")|strpos(descr, "B Com") | strpos(descr, "B S,") ///
		| strpos(descr, "B-S") | strpos(descr, "Double Major")|strpos(descr, "Bsc") ///
		| strpos(descr, "Bcompt") | strpos(lower(school), "bsc")>0 ///
		| strpos(lower(school), "bache")>0 | strpos(descr,"bba") ///
		| strpos(descr,"B of S") | strpos(descr,"BFA") | strpos(descr,"bfa") ///
		| strpos(descr,"BCom") | strpos(descr,"BCOM") | strpos(descr,"Bcom") ///
		| strpos(lower(descr),"bsba") | strpos(lower(descr),"bpa") | strpos(lower(descr),"b.p.a.") ///
		| strpos(lower(descr), "bechelor")

* Identifier for an Associates Degree
	gen Associate = strpos(descr, "Associate") | strpos(descr, "AS") | strpos(descr, "A.S.") ///
		| strpos(descr, "AA") | strpos(descr, "A.A.S.") | strpos(descr, "A.A.") ///
		| strpos(descr, "AAS")| strpos(descr, "A.A,")| strpos(descr, "AB,") ///
		| strpos(descr, "AB") | strpos(descr, "A.S,")

* Identifier for a Masters Degree
	gen Masters = strpos(descr, "Macc")| strpos(descr, "Master") | strpos(descr, "master") ///
		| strpos(descr, "MST") | strpos(descr, "MBA") | strpos(descr, "MaCC") | strpos(descr, "MST") ///
		| strpos(descr, "MT") | strpos(descr, "MSPA") | strpos(descr, "MSM") |strpos(descr, "MSAT") ///
		| strpos(descr, "MSA") | strpos(descr, "MS") | strpos(descr, "MBT") | strpos(descr, "MAcc") ///
		| strpos(descr, "MACC") | strpos(descr, "MAA") | strpos(descr, "MA,")| strpos(descr, "M.S.T.") ///
		| strpos(descr, "M.T.") | strpos(descr, "M.S.A.")| strpos(descr, "M.S.") ///
		| strpos(descr, "M.P.A") | strpos(descr, "M.A.") | strpos(descr, "M.A") ///
		| strpos(descr, "M.B.A.") | strpos(descr, "M. S.") | strpos(descr, "M. Acc") ///
		| strpos(descr, "M.Acc.")| strpos(descr, "M.Div")| strpos(descr, "M.S,") ///
		| strpos(descr, "MDiv")| strpos(descr, "MPA")| strpos(descr, "MPS") ///
		| strpos(descr, "mba") | strpos(descr, "msa")
	replace Masters = 0 if 	strpos(lower(descr), "cma") > 0 & strpos(lower(descr), "master") == 0 & strpos(lower(descr), "mba") == 0

* Identifier for a Law Degree
	gen JD = strpos(descr, "J.D") | strpos(descr, "JD") | strpos(descr, "Juris Doctor") | strpos(descr, "Juris Doctorate") | strpos(descr, "Law School") | strpos(descr, "Doctorate, Laws") | strpos(descr, "Doctor of Jurisprudence")| strpos(descr, "JURIS DOCTOR")| strpos(lower(descr),"jd,")>0
	gen LLM = strpos(descr, "LLM") | strpos(descr, "llm") | strpos(descr, "LL.M")

* Identifier for a Ph.D.
	gen PhD = strpos(descr, "Phd") | strpos(descr, "PhD") |strpos(descr, "Ph.D")| strpos(descr, "Doctor of Business Administration, Accounting & Taxation") |strpos(descr, "Doctorate, Geology")

* Other
	gen Post = strpos(descr, "Post") | strpos(descr, "post") | strpos(descr, "additional")| strpos(descr, "5 year")

* Check duration 0
	gen dur = end - start
		order dur
	drop if dur == 0 & start < 2016 & descr != "" & Masters == 0 & Bachelor == 0 & JD == 0 & LLM == 0 & PhD == 0 & Post == 0
	drop if strpos(lower(descr),"transfer") > 0 & dur == 1
	drop if descr == "Additional Accounting courses for CPA Exam"

* Flag accounting masters 
	gen ACC_Mast = 0
	replace ACC_Mast = 1 if Masters == 1 & ACC_F == 1

* Drop miscellaneous data
	drop if dur == 1 & strpos(lower(school),"community") > 0 & Bach == 0 & Ass == 0 & strpos(lower(descr),"certificate")
	drop if school == "cpa" | school == "CPA"

* Measure for individuals
	foreach x of varlist Bachelor Associate Masters JD LLM PhD Post AICPA CPA CMA Tax_F ACC_Mast {
		egen M`x' = max(`x'), by(key)
		drop `x'
		rename M`x' `x'
	}

* Individuals with Masters must have Bachelor degrees
	replace Bachelor = 1 if Masters == 1 

* Clean certificates 
* Identify each row's degree
	gen Ass = strpos(descr, "Associate") | strpos(descr, "AS") | strpos(descr, "A.S.") ///
		| strpos(descr, "AA") | strpos(descr, "A.A.S.") | strpos(descr, "A.A.") ///
		| strpos(descr, "AAS")| strpos(descr, "A.A,")| strpos(descr, "AB,") ///
		| strpos(descr, "AB") | strpos(descr, "A.S,")

	gen Bach = strpos(descr, "Bachelor") | strpos(descr, "bachelor") | strpos(descr, "B.A.") ///
		| strpos(descr, "B. S.") | strpos(descr, "B.S.") | strpos(descr, "BA") ///
		| strpos(descr, "BS") | strpos(descr, "B.") |strpos(descr, "B.B.A.") ///
		| strpos(descr, "B.B.A") | strpos(descr, "BBA") |strpos(descr, "B/S") ///
		| strpos(descr, "BGS") | strpos(descr, "BSBA") | strpos(descr, "BSC") ///
		| strpos(descr, "Ba") |strpos(descr, "BASc") | strpos(descr, "bs,") ///
		| strpos(descr, "bsa,") | strpos(descr, "bs in") | strpos(descr, "Baccalaureate") ///
		| strpos(descr, "B B A")|strpos(descr, "B Com") |strpos(lower(descr), "bcom") |strpos(descr, "B S,") ///
		| strpos(descr, "B-S") | strpos(descr, "Double Major") |strpos(descr, "Bsc") ///
		| strpos(descr, "Bcompt") | strpos(lower(descr), "bechelor")

	gen Mast=strpos(descr, "Macc")| strpos(descr, "Master") | strpos(descr, "master") ///
		| strpos(descr, "MST") | strpos(descr, "MBA") | strpos(descr, "MaCC") ///
		| strpos(descr, "MST") | strpos(descr, "MT") | strpos(descr, "MSPA") ///
		| strpos(descr, "MSM") |strpos(descr, "MSAT")| strpos(descr, "MSA") ///
		| strpos(descr, "MS") | strpos(descr, "MBT") | strpos(descr, "MAcc") ///
		| strpos(descr, "MACC") | strpos(descr, "MAA") | strpos(descr, "MA,") ///
		| strpos(descr, "M.S.T.") | strpos(descr, "M.T.") | strpos(descr, "M.S.A.") ///
		| strpos(descr, "M.S.") | strpos(descr, "M.P.A") | strpos(descr, "M.A.") ///
		| strpos(descr, "M.B.A.") |strpos(lower(descr),"mba") | strpos(descr, "M. S.") ///
		| strpos(descr, "M. Acc")| strpos(descr, "M.Acc.")| strpos(descr, "M.Div") ///
		| strpos(descr, "M.S,")| strpos(descr, "MDiv")| strpos(descr, "MPA") ///
		| strpos(descr, "MPS")| strpos(descr, "mba") | strpos(descr, "msa") ///
		| strpos(descr,"MAC")

	gen Jd= strpos(descr, "J.D") | strpos(descr, "JD") | strpos(descr, "Juris Doctor") ///
		| strpos(descr, "Juris Doctorate") | strpos(descr, "Law School") ///
		| strpos(descr, "Doctorate, Laws") | strpos(descr, "Doctor of Jurisprudence") ///
		| strpos(descr, "JURIS DOCTOR")| strpos(lower(descr),"jd,")>0
	
	gen Cert = 0
	replace Cert = 1 if strpos(lower(descr),"certi") > 0
	replace Cert = 1 if Cert == 0 & (CMA == 1 |CPA == 1 |AICPA == 1) & Bach == 0 & Mast == 0 & Jd == 0
	replace Cert = 1 if Cert == 0 & strpos(lower(descr),"cfa") > 0
	replace Cert = 1 if Cert == 0 & strpos(lower(descr),"cer") > 0

	gen Cert_only = 1 if Cert== 1 & Bach == 0 & Mast == 0 & Jd == 0
	drop if Cert_only == 1
	drop if Ass == 1
	drop if dur == 0 & start < 2016 & descr != "" 

* Year of exiting schools 
	sort key start
	by key: gen deg_ord = _n

	gen Sch_Year = end if deg_ord == 1
	replace Sch_Year = start if Sch_Year ==. & start != . & start < 2018

* Check outliers 
	drop if key == 5252 & start > 1995
	drop if key == 21015 & start > 1996
	drop if key == 5802 & start == .

	foreach x of varlist Sch_Year {
		egen M`x'=max(`x'), by(key)
		drop `x'
		rename M`x' `x'
	}

* Duplicates drop after mannually checking obs 
	duplicates drop key school start end, force

* Number of degrees 
	egen Num_Deg = count(key), by(key)
	gen yrend = end

* Create Year_Graduate variable
	order id key deg_ord deg_ord school spec descr start end Bachelor Masters Bach Mast
	format %15s spec
	format %15s descr

	gen Year_2 = substr(descr, length(descr) - 4, length(descr)) if yrend == . & strpos(descr, "1") > 0
	replace Year_2 = "1990" if id == 5874
	replace Year_2 = "1972" if id == 7392

	tostring yrend, replace
	replace yrend = Year_2 if yrend == "" & strpos(descr, "1") > 0
	drop Year_2
	destring yrend, force gen(Year_end)
	rename Year_end year_end

	sort  key year_end
	by key: gen Degree_order = _n
	order Degree_order

* Use bachelor graduation year if went to work
	gen Year_Graduated = year_end if Bachelor == 1 & Degree_order < 2 

* Use master graduation year if Year_Graduated==. & Masters==1 & Bachelor==0
	replace Year_Graduated = year_end if Year_Graduated ==. & Masters == 1 & Bachelor == 0
	order Year_Graduated

* Use master graduation year if no work exp btw bachelor & masters
* Check: compare the bachelor graduation year & ma start year
	by key: gen end_ba_temp = end if Bach == 1 | deg_ord == 1 // bachelor or the first degree
	by key: gen start_ma_temp = start if Mast== 1
	order end_ba* start_ma*
	by key: egen end_ba = max(end_ba_temp)
	by key: egen start_ma = max(start_ma_temp)
	order end_ba* start_ma*
	gen ba_then_ma = 1 if end_ba == start_ma & end_ba !=. & start_ma!=.
	tab ba_then_ma
	order ba_then_ma

* Save a temp dataset for mannual check
	preserve  
		keep if ba_then_ma == 1
		note: obs went to Masters after Bachelor education, without working exp in btw
		save "check/Education_BA_Then_MA", replace
	restore
	drop end_ba* start_ma*

* Use the end of masters year after checking 
	by key: gen end_ma_temp = end if ba_then_ma == 1
	by key: egen end_ma = max(end_ma_temp) if ba_then_ma == 1
	drop end_ma_temp
	
* Update the Year_Graduated var
	replace Year_Graduated = end_ma if ba_then_ma == 1

	by key: gen Num = _N
	sort key Year_Graduated
	by key: gen Num_ord = _n
	tabstat Year_Graduated , stats(mean median sd N min p5 p95 max) columns(statistics)

	order Num Num_ord
	gsort key Num_ord
	keep if Num_ord == 1
	drop Num Num_ord

	format %15s spec
	format %15s descr
	order id key deg_ord deg_ord school spec descr start end year_end Bachelor Masters
	drop start end deg_ord Degree_order end_ma

	gen Non_ACC_Mast = 0
	replace Non_ACC_Mast = 1 if Masters == 1 & ACC_Mast == 0
	tab Non_ACC_Mast

* Check the distribution
	tabstat ba_then_ma Year_Graduated Masters ACC_Mast Non_ACC_Mast, stats(mean median sd N min p5 p95 max) columns(statistics)

save "output/Education_Clean", replace






























/*******************************************************************************
							Barrios 2021
 Occupational Licensing and Accountant Quality: Evidence from the 150-Hour Rule
 
This code is ment to build the working dataset for the analysis using the outputs 
from running 1_Clean_Raw_Data.do. 

*******************************************************************************/


/*******************************************************************************
Setup
*******************************************************************************/

	set more off, perm
	set type double, perm

/*******************************************************************************

Create a job panel

*******************************************************************************/

* Import the clean experience data
use "output/Company_Clean", clear

* Clean those are not actual in pub acc
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "marketing") >0
		replace In_ACC = 0 if In_ACC == 1 & lower(title) == "information technology" //
			| lower(title) == "technical communications assistant" //
			| lower(title) == "communications manager" | lower(title) == "media planner"
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "writer") >0 & strpos(lower(des), "media") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "art") >0 & strpos(lower(des), "magazine") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "recruit") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "human resource") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "hr") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "placement") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "talent") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "editor") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "engineer") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "online producer") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(des), "cpa") >0 & strpos(lower(comp), "association") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "adminis") >0 //
			& strpos(lower(title), "acc") == 0 & strpos(lower(title), "tax") == 0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(title), "campus") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(comp), "cpa prosperity") >0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(comp), "society") >0 //
			& strpos(lower(comp), "Accounting Aid Society") == 0
		replace In_ACC = 0 if In_ACC == 1 & strpos(lower(comp), "association") >0 & comp != "Utah Association of CPAs"
		replace In_ACC = 0 if key == 23387

* Bring in individual summary variables. e.g., has_cpa
		drop Tax BigN
		merge m:1 key using "output/Ind_Emp_Sum", update
		drop if _m == 2
		drop _m

* Drop individuals with Sum_In_ACC == 0
		bysort key: egen Sum_In_ACC = total(In_ACC)
		distinct key if Sum_In_ACC == 0
		replace Sum_In_ACC = 1 if CPA == 1
		replace Sum_In_ACC = 1 if has_cpa == 1
		drop if Sum_In_ACC == 0

* Gen first job start year; Exclude the first job as an intern, tutor, etc
		sort key start_year
		gen Job1_Start_Year_Temp = start_year if job_order == 1 & Intern_Check == 0 //
		 & retired_Check == 0 & Tutor_Check == 0 & Volunteer_Check == 0 
		by key: egen Job1_Start_Year = max(Job1_Start_Year_Temp) 
		drop Job1_Start_Year_Temp

* Merge year graduate var from the education file
		merge m:1 key using "output/Education_Clean", keepusing(Year_Graduated Masters ACC_Mast Non_ACC_Mast Num_Deg) update
		drop if _m == 2
		drop _m

* Modify Masters identifier, Num Deg
		replace Masters = 0 if Masters ==. 
		replace ACC_Mast = 0 if ACC_Mast == .
		replace Non_ACC_Mast = 0 if Non_ACC_Mast  ==.
		replace Num_Deg = 0 if Num_Deg == .

* Calculate year_eval, limit the sample to people graduate in 2016
		gen Year_Eval = Year_Graduated 
		replace Year_Eval = Job1_Start_Year if Year_Eval== . & Job1_Start_Year !=. 
		drop if Year_Eval > 2016
		order key Year_Graduated Job1_Start_Year start_year

* Drop duplicates bring in other vars from the directory, location, gender
		merge m:1 key using "output/Comb_Directory_Cleaned_Noduplicates", update
		keep if _m == 3 
		drop _m

* Gender identifier
		gen Male = 1 if  gender == "Male"
		replace Male = 0 if Male ==.

* Create the Post-150 Rule Indicator
		merge m:1 state using "output/State_Adoptions", update nogen 
		gen Post_150 = 1 if Year_Eval >= EffectiveYear
		replace Post_150 = 0 if Post_150 ==.
		gen Pre_150=1 if Post_150==0
		replace Pre_150=0  if Post_150==1

* Gen Job_Num, Job Ord 
		rename tenure_years Tenure_Years
		rename start_year Start_Year
		rename end_year End_Year
		sort key Start_Year
		by key: gen Job_Num = _n
		drop if key ==.
		drop job_order
		gsort key Start_Year start_month
		by key: gen job_order = _n

* Gen mean_dur_yr & years per job
		drop mean_dur_yr num_job
		egen mean_dur_yr = mean(Tenure_Years), by(key)
		gsort key Start_Year start_month
		egen num_job = count(key), by(key)
		order num_job

* Sum_In_ACC, Ratio_InACC
		rename num_job Total_Job
		rename total_exp Total_Expereince
		gen Ratio_InACC = (Sum_In_ACC / Total_Job)*100

* FACC_Tenure: the cumulative years the individual has worked in pub acc
		egen ACC_Tenure = sum(Tenure_Years) if In_ACC == 1, by(key)
		egen FACC_Tenure = max(ACC_Tenure), by(key)
			replace FACC_Tenure = 0 if FACC_Tenure ==.
		order key In_ACC Sum_In_ACC Tenure_Years ACC_Tenure FACC_Tenure

* Percentage
		gen PerY_ACC = (FACC_Tenure / Total_Expereince)*100

* Check the distribution
		tabstat Year_Eval Year_Graduated Total_Job, stats(mean median sd N min p5 p95 max) columns(statistics)

save "temp/working_panel_full", replace

/*******************************************************************************

Create an individual directory

*******************************************************************************/

use "temp/working_panel_full",clear

* Keep unique individuals
	dups key, terse drop

	keep key Non_ACC_Mast ACC_Mast Masters year_enter_job_market clean_name //
	State Post_150 Pre_150 Male state Year_Eval Total_Job mean_dur_yr BigN //
	Tax Year_Eval Num_Deg BigN_First Big4_First FACC_Tenure EffectiveYear

* Check the distribution
	tabstat Masters, stats(mean p1 p5 p10 p25   p50   p75  p90 p95 p99) columns(statistics)

save "temp/working_ind_full", replace

/*******************************************************************************

Create data: Exit Pub ACC  

*******************************************************************************/

use "temp/working_panel_full", clear
						
* Order variables
	order key In_ACC Sum_In_ACC Tenure_Years ACC_Tenure FACC_Tenure

* The total number of jobs
	drop Total_Job
	sort key Start_Year
	egen Total_Job = count(key), by(key)
	order key job_order Total_Job Seniority
	gsort key job_order

* Filter the last job before exiting, and the job right after exiting
	by key: gen order_before = job_order if In_ACC[_n] == 1 & In_ACC[_n+1] == 0
	by key: gen order_after = job_order + 1
	replace order_after = . if order_before ==.
	* Gen an identifier if this individual has ever left pub acc
	gen everleft_temp = 1 if order_after !=. 
	by key: egen everleft = max(everleft_temp)
	order order_before order_after
	order key everleft

* Keep only individuals who have ever left pub acc
	keep if everleft == 1
	order key job_order Total_Job Seniority In_ACC Sum_In_ACC title comp start_month end_month End_Year

save "temp/Left_Pub_ACC_Data_All", replace

* The last job before exiting
use "temp/Left_Pub_ACC_Data_All", clear

	keep key order_before
	drop if order_before == .
	rename order_before job_order

save "temp/before", replace

* The job right after exiting
use "temp/Left_Pub_ACC_Data_All", clear

	keep key order_after
	drop if order_after == .
	rename order_after job_order

save "temp/after", replace

* Remove other jobs
use "temp/Left_Pub_ACC_Data_All", clear

	merge m:1 key job_order using "temp/before"
	rename _m m1
	merge m:1 key job_order using "temp/after", update
	rename _m m2
	keep if m1 == 3 | m2 == 3

* The number of changes experience
	sort key
	by key: gen total_change_order = sum(In_ACC)
	by key: egen total_change = max(total_change_order)
	order total_change*
	** check the distribution of total changes
	sum total_change

* Flag individuals who left and came back
	gen left_back = 1 if total_change > 1

	label var total_change "total change and individual experience (In_ACC from 1 to 0)"
	label var total_change_order "count the order of change (In_ACC from 1 to 0), 1st, 2nd, etc."
	label var left_back "mark individuals who left and came back"

	order key total_change total_change_order job_order Total_Job Seniority //
	In_ACC title comp start_month Start_Year end_month End_Year duration
	gsort key job_order
	drop order_before order_after

save "temp/Left_Pub_ACC_Data_Partial",replace

* Create a dataset: one row per individual, 
* and pre and new variables for the first time they left public accounting.

use "temp/Left_Pub_ACC_Data_Partial",clear

* Keep the first changes
	keep if total_change_order == 1

* Reshape
	by key: gen change_order = _n
	keep key change_order job_order duration title comp Job1_Start_Year Start_Year End_Year Tenure_Years In_ACC Seniority
	reshape wide title comp job_order duration Tenure_Years Start_Year End_Year In_ACC Seniority, i(key) j(change_order)

* Merge variables 
	merge 1:1 key using "temp/working_ind_full", keepusing(Post_150 Male state Year_Eval )
	drop if _m == 2
	drop _m

* Gen pre_150
	gen Pre_150 = 1 if Post_150 == 0
	replace Pre_150 = 0 if Post_150 == 1

* Rename variables
foreach x in 1 {
	rename Seniority`x' prev_seniority
	rename In_ACC`x' prev_In_ACC
	rename title`x' prev_title
	rename comp`x' prev_comp
	rename Start_Year`x' prev_start_year
	rename End_Year`x' prev_end_year
	rename Tenure_Years`x' prev_tenure_years
	rename job_order`x' prev_job_order
	rename duration`x' prev_duration
}
foreach x in 2 {
	rename Seniority`x' new_seniority
	rename In_ACC`x' new_In_ACC
	rename title`x' new_title
	rename comp`x' new_comp
	rename Start_Year`x' new_start_year
	rename End_Year`x' new_end_year
	rename Tenure_Years`x' new_tenure_years
	rename job_order`x' new_job_order
	rename duration`x' new_duration
}

* Gen outcome variables
	gen greater_seniority = 1 if new_seniority > prev_seniority & new_seniority != . & prev_seniority !=.
	replace greater_seniority = 0 if new_seniority <= prev_seniority  & new_seniority != . & prev_seniority !=.
	drop Job1_Start_Year

save "temp/Left_Pub_ACC_Once_Data",replace

/*******************************************************************************

Create variable: Ever Left Pub Acc

*******************************************************************************/

* Import everyone who ever left public accounting 
use "temp/Left_Pub_ACC_Data_All",clear

		order key job_order Total_Job title comp Start_Year End_Year everleft Tenure_Years ACC_Tenure FACC_Tenure In_ACC
		rename FACC_Tenure time_exit_pub
		label var time_exit_pub "time from enter till exiting pub acc"
		label var everleft "1 if ever left pub acc"
		duplicates drop key,force

save "temp/unique_ever_left", replace

/*******************************************************************************

Create variable: Time Till Promotion Level 1

*******************************************************************************/

use "temp/working_panel_full", clear

* From the exp panel, create the dependent variable
		drop Cum_Fin 
		bys key (job_order): gen Cum_Exp = sum( Tenure_Years)
		order Cum_Exp Tenure_Years
		gen Cum_Fin = Cum_Exp - Tenure_Years
		order Cum_Fin
		drop Cum_Exp

* Keep observations which only have 1 in them
		gen id1 = 1 if Seniority == 1
		egen id11 = max(id1), by(key)
		drop if id11 == .
		drop if Seniority == 2
		sort key job_order Seniority
		drop chk id1 id11

		keep if Seniority == 1 & Cum_Fin!=0
		egen minjob = min(job_order) , by(key)
		order minjob job_order
		keep if job_order == minjob
		rename Cum_Fin time_till_promotion1
		
save "temp/promotion1", replace 		

/*******************************************************************************

Create variable: Time Till Promotion Level 2 

*******************************************************************************/

use "temp/working_panel_full", clear

* From the exp panel, create the dependent variable
		drop Cum_Fin 
		bys key (job_order): gen Cum_Exp = sum( Tenure_Years)
		order Cum_Exp Tenure_Years
		gen Cum_Fin = Cum_Exp - Tenure_Years
		order Cum_Fin
		drop Cum_Exp

* Keep observations which only have 2 in them
		gen id2 = 1 if Seniority == 2
		egen id22 = max(id2), by(key)
		drop if id22 == .
		drop if Seniority == 3
		sort key job_order Seniority
		drop chk id2 id22

* Generate cumulative years worked 
* If the 1st job is level 2, it is dropped 
* If there are multiple level 2 jobs, keep the earliest one 
		keep if Seniority == 2 & (l.Seniority==1 | l.Seniority==.) & Cum_Fin!=0
		egen minjob = min(job_order) , by(key)
		order minjob job_order
		keep if job_order == minjob
		rename Cum_Fin time_till_promotion2

save "temp/promotion2",replace

/*******************************************************************************

Create variable: Time Till Promotion Level 3

*******************************************************************************/

use "temp/working_panel_full", clear

* Generate cumulative years worked
		drop Cum_Fin  
		bys key (job_order): gen Cum_Exp = sum(Tenure_Years)
		order Cum_Exp Tenure_Years
		gen Cum_Fin = Cum_Exp - Tenure_Years
		order Cum_Fin
		drop Cum_Exp

* Keep observations which only have 3 in them
		gen id3 = 1 if Seniority==3
		egen id33 = max(id3), by(key)
		drop if id33 == .
		sort key job_order Seniority
		drop if Seniority == 1
		drop chk id3 id33

* If the 1st job is level 3, it is dropped 
* If there are multiple level 3 jobs, keep the earliest one (smallest job order)
		keep if Seniority == 3 & (l.Seniority == 2|l.Seniority == .) & Cum_Fin != 0
		egen minjob = min( job_order) , by(key)
		keep if job_order == minjob

		rename Cum_Fin time_till_promotion3

save "temp/promotion3",replace

/*******************************************************************************

Create variable: Time till Partner 

*******************************************************************************/

use "temp/working_panel_full", clear

		sort key
		egen tot_years_worked = total(Tenure_Years), by(key)
		by key: egen Avg_years_perjob = mean(Tenure_Years)

* Generate cumulative years worked
		drop Cum_Fin  
		bys  key (job_order): gen Cum_Exp = sum( Tenure_Years)
		order Cum_Exp Tenure_Years
		gen Cum_Fin = Cum_Exp - Tenure_Years
		order Cum_Fin

* Keep if the individual is ever a partner
		gen partner = 0
		replace partner = 1 if strpos(title, "Partner")>0 | strpos(title, "partner")>0 //
		 | strpos(comp, "Partner ")>0 | strpos(title, "Shareholder")>0 | strpos(title, "shareholder")>0
		tabstat partner, stats(N mean median sd) columns(statistics)
		egen M_partner = max(partner), by(key)
		keep if M_partner == 1

* Drop unusual ones (the first job is a partner)
		gen unusual = 0
		replace unusual = 1 if partner == 1 & job_order==1
		egen Max_unusual = max(unusual), by(key)
		* drop if Max_unusual == 1

* Keep if the row is a partner job
		order partner
		keep if partner == 1

* Gen job order, keep the row of the first time partner
		drop job_order
		sort key Start_Year
		by key: gen job_order = _n
		keep if job_order == 1

* Flag Big N
		gen BigN2 = 0
		replace BigN2 = 1 if strpos(lower(comp),"deloi") >0 | strpos(lower(comp),"touch") >0 //
		 | strpos(lower(comp),"pwc") >0 | strpos(lower(comp),"pricew") >0 //
		 | strpos(lower(comp)," ey ") >0 | strpos(lower(comp),"ernst ")>0 //
		 | strpos(lower(comp),"& young ")>0 | strpos(lower(comp),"kpmg")>0 //
		 | strpos(lower(comp),"peat ma")>0| (strpos(lower(comp),"arthur")>0 & strpos(lower(comp),"anderson")>0)
		replace BigN2 = 1 if strpos(comp,"EY") > 0 & BigN2 == 0 & length(comp) < 3
		replace BigN2 = 1 if strpos(lower(comp),"price water") > 0 & BigN2 == 0
		replace BigN2 = 1 if strpos(lower(comp),"coopers") > 0 & BigN2 == 0
		replace BigN2 = 1 if BigN2 == 0 & strpos(lower(comp),"grant t") > 0
		replace BigN2 = 1 if BigN2 == 0 & strpos(lower(comp),"arthur a") > 0

		rename Cum_Fin time_till_partner
		rename BigN partner_BigN
		rename BigN2 partner_BigN2

		order key partner time_till_partner Cum_Exp Tenure_Years title comp Start_Year End_Year partner_BigN
	
save "temp/partner", replace
 
/*******************************************************************************

Create variable: Firm Tenure 

*******************************************************************************/

use "temp/working_panel_full", clear

		drop if Year_Eval <= 1970 | Year_Eval >= 2017

* Number of firms
		by key : egen Num_Firms = nvals(comp)
		order Num_Firms

* Average Tenure
		rename Tenure_Years dur_yr
		by key : egen Total_Tenure = total(dur_yr)
		gen Avg_Tenure = Total_Tenure / Num_Firms

* Tenure in first job
		by key : gen temp_tenure_1 = dur_yr*(job_order == 1)
		by key : egen tenure_1 = max(temp_tenure_1)
		drop temp_tenure_1

* Tenure in big n 
		gen Job_Bign = 0
		replace Job_Bign = 1 if strpos(lower(comp),"deloi") >0 | strpos(lower(comp),"touch") >0 //
		 | strpos(lower(comp),"pwc") >0 | strpos(lower(comp),"pricew") >0 //
		 | strpos(lower(comp)," ey ") >0 | strpos(lower(comp),"ernst ")>0 //
		 | strpos(lower(comp),"& young ")>0 | strpos(lower(comp),"kpmg")>0 //
		 | strpos(lower(comp),"peat ma")>0| (strpos(lower(comp),"arthur")>0 & strpos(lower(comp),"anderson")>0)
		replace Job_Bign = 1 if strpos(comp,"EY") >0 & Job_Bign == 0 & length(comp) < 3
		replace Job_Bign = 1 if strpos(lower(comp),"price water") > 0 & Job_Bign == 0
		replace Job_Bign = 1 if strpos(lower(comp),"coopers") > 0 & Job_Bign == 0
		replace Job_Bign = 1 if Job_Bign == 0 & strpos(lower(comp),"grant t") > 0
		replace Job_Bign = 1 if Job_Bign == 0 & strpos(lower(comp),"arthur a") > 0
		label var Job_Bign "Job is at Big N"
		order Job_Bign

		by key : gen tenure_bign_temp = sum(dur_yr) if Job_Bign == 1 
		by key : egen Tenure_Bign = max(tenure_bign_temp)
	
		order key Num_Firms Avg_Tenure Total_Tenure Tenure_Bign Job_Bign dur_yr title comp Start_Year End_Year
		duplicates drop key, force

save "temp/firmtenure",replace

/*******************************************************************************

Merge all the variables to the full sample 

*******************************************************************************/

use "temp/working_ind_full", clear

* Merge variable ever left public accounting 
	merge m:1 key using "temp/unique_ever_left", keepusing(everleft time_exit_pub)
		drop if _m == 2
		drop _m

	replace everleft = 0 if everleft == .
	label var everleft "Exit Pub ACC"
	label var time_exit_pub "Time to Exit Pub ACC"

* Merge variable greater Seniority 
	merge 1:1 key using  "temp/Left_Pub_ACC_Once_Data", keepusing(greater_seniority prev_seniority new_In_ACC)
		drop if _m == 2 
		drop _m
	label var prev_seniority 
	label var Post_150 "Rule"

* left & higher place (unconditional)
	replace greater_seniority = 0 if greater_seniority == . 
	label var greater_seniority "Higher Seniority Post ACC"

* Merge time till promotion  Level 1
	merge m:1 key using "temp/promotion1", keepusing(time_till_promotion1)
		drop if _m == 2
		drop _m
	label var time_till_promotion1 "years till promoted to level 1"

* Merge time till promotion  Level 2 
	merge m:1 key using "temp/promotion2", keepusing(time_till_promotion2)
		drop if _m == 2
		drop _m
	label var time_till_promotion2 "years till promoted to level 2"

* Merge time till promotion Level 3
	merge m:1 key using "temp/promotion3", keepusing(time_till_promotion3)
		drop if _m == 2
		drop _m		
	label var time_till_promotion3 "years till promoted to level 3"


* Merge time till partner 
	merge m:1 key using "temp/partner", keepusing(time_till_partner partner_BigN partner_BigN2 In_ACC)
		drop if _m == 2
		drop _m		
	label var time_till_partner "years till promoted to partner"
	label var partner_BigN "1 if partner at Big N"
	label var partner_BigN2 "1 if partner at Big N2"
	label var In_ACC "1 if the job's company is an accounting firm"

* Merge firm tenure 
	merge m:1 key using  "temp/firmtenure", keepusing(Num_Firms Avg_Tenure Tenure_Bign)
		drop if _m == 2
		drop _m		
	label var Num_Firms "Number of Firms"
	label var Avg_Tenure "Average Tenure per Firm"
	label var Tenure_Bign "Total Years spent at Big N"

* Sample filter 
	distinct key if Avg_Tenure < 1 
	distinct key if time_till_promotion2 > 40 &  time_till_promotion2 !=.

* Winsorize
 	winsor2 Num_Firms  time_exit_pub Tenure_Bign, replace 
	winsor2 Total_Job mean_dur_yr Num_Deg, replace 

* Gen dependent vars after I winsorize 
	gen log_Num_Firms = log(Num_Firms)
	gen log_Avg_Tenure = log(Avg_Tenure)
	gen log_time_exit_pub = log(time_exit_pub)

	label var Total_Job "Nubmer of Positions"
	label var mean_dur_yr "Average Years per Job"
	label var Num_Deg "Number of Degress"
	label var BigN "Big N"
	label var Year_Eval "Year Graduated"
	label var Masters "Master's Degree"
	label var ACC_Mast "Accounting Master's"
	label var Non_ACC_Mast "Non-Accounting Master's"

	order key Num_Firms Avg_Tenure time_exit_pub Total_Job mean_dur_yr Num_Deg
	rename State State_Full
	rename *, proper

save "output/working_individual_data",replace 	

/*******************************************************************************

Create matched sample - CEM 

*******************************************************************************/

use "temp/working_individual_data", clear

	sum Avg_Tenure, d
	ttest Year_Eval , by(Post_150)
	tabstat Year_Eval, stats(mean p1 p5 p10 p25   p50   p75  p90 p95 p99)  columns(statistics)

* Set up cut points
	foreach i in Year_Eval {
		* set the percentile
		_pctile `i', p(1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95)

		local `i'1 = `r(r1)'
		local `i'5 = `r(r2)'
		local `i'10 = `r(r3)'
		local `i'15 = `r(r4)'
		local `i'20 = `r(r5)'
		local `i'25 = `r(r6)'
		local `i'30 = `r(r7)'
		local `i'35 = `r(r8)'
		local `i'40 = `r(r9)'
		local `i'45 = `r(r10)'
		local `i'50 = `r(r11)'
		local `i'55 = `r(r12)'
		local `i'60 = `r(r13)'
		local `i'65 = `r(r14)'
		local `i'70 = `r(r15)'
		local `i'75 = `r(r16)'
		local `i'80 = `r(r17)'
		local `i'85 = `r(r18)'
		local `i'90 = `r(r19)'
		local `i'95 = `r(r20)'

		* save the percentile as cut_`x'
		local cut_`i' "``i'1' ``i'5' ``i'10' ``i'15' ``i'20' ``i'25' ``i'30' ``i'35' ``i'40' ``i'45' ``i'50' ``i'55' ``i'60' ``i'65' ``i'70' ``i'75' ``i'80' ``i'85' ``i'90' ``i'95' "
	}

* Run CEM matching algorithm; without k2k
		cem Male(#0)	Year_Eval (`cut_Year_Eval'), treatment(Post_150) // #0 exact match; otherwise, match according to the cut point;

* Save the matched sample
		keep if cem_matched == 1

* Remove average tenure smaller than 1 year  
	drop if Avg_Tenure < 1 

* Reomve time till promotion to level longer than 40 years 
	drop if Time_Till_Promotion2 >= 40  & Time_Till_Promotion2 !=.

save "output/working_individual_data_cem", replace
/*******************************************************************************
					
							Barrios 2021
 Occupational Licensing and Accountant Quality: Evidence from the 150-Hour Rule
 				 
This code is ment to build the working data for the analysis on writing quantity
and quality using the profiles for the sample of CPAs from the networking 
website.

*******************************************************************************/

* Import the raw data
use "2_Data/raw/Desc_Complex.dta", clear

* Set Up variables - Jobs
	gen Num_Jobs = Num_Job
	* In at least one position or in majority of positions
	gen d = 0
	replace d = 1 if des != ""
	egen Has_Desc = max(d), by(key) // a zero one if has at least one description or not
	* In at least one position or in majority of positions
	egen Num_Job_Desc = sum(d), by(key)
	drop d
	gen Perc_JobDesc = Num_Job_Desc/Num_Jobs

* Create lingustic measures
	gen Fog = fog_index
	gen Flesch = flesch_score
	replace Flesch = 0 if Flesch < 0
	gen Num_Words = num_words
	gen Num_Sent = num_sentences
	gen Wrd_Per_Sent = num_words/num_sentences
	gen Log_Words = log(num_words)
	gen Log_Sent = log(num_sentences)

* Get rid of duplicate keys, using the final clean directory
	merge m:1 key using "2_Data/input/Comb_Directory_Cleaned_Noduplicates", keepusing(key) update
	drop if _m == 1 
	drop if _m == 2 
	drop _m

* Merge state adoption variables
	merge m:1 key using "2_Data/input/Adoption_Linking_File", keepusing(state_id EffectiveYear) update
	drop if _m == 2
	drop _m

* Merge the year enter the job mkt
	drop Total_Job
	merge m:1 key using "2_Data/temp/working_ind_full", keepusing(Year_Eval Total_Job) update
	drop if _m == 2
	drop _m

* Merge individual summary variables
	merge m:1 key using "2_Data/input/ind_emp_sum", update
	drop if _m == 2
	drop _m

save "2_Data/output/Desc_clean", replace
/*******************************************************************************
									Barrios 2021
 Occupational Licensing and Accountant Quality: Evidence from the 150-Hour Rule
 
This code is ment to build the working data for the CPA supply analysis.

*******************************************************************************/

* Import data for universities - this is data parsed from the raw pdf provided by NASBA
* Can be obtained by contacting NASBA
	use "raw/FULL_NASBA_Universities_Work_June2016", clear

* Generate good and bad candidates
	gen good =(ALL/100) * NUMBEROFCANDIDATES
	gen bad = (NONE/100) * NUMBEROFCANDIDATES

	gen G =log(1+good)
	gen B =log(1+bad)

* Look percentages
	gen Perc_All = good / NUMBEROFCANDIDATES
	gen Perc_None = bad / NUMBEROFCANDIDATES

* Label variables
	label variable AUDITING "Auditing Section"
	label variable LAW "Law Section"
	label variable PRACTICE "Practice Section"
	label variable THEORY "Theory Section"
	label variable ALL "Passed All"
	label variable SOME "Passed Some Sections"
	label variable NONE "Passed No"
	label variable Perc_All "Perc All"
	label variable Perc_None " Perc None"
	label variable NUMBEROFCANDIDATES "Number of Candidates"
	label variable log_Cand "Log Cand"
	label variable bad "Passed None"
	label variable good "Passed All"
	label variable GRAD "Graduate Degree"
	label variable Rule_150 "Rule"

* Generate the Rule variable
	gen Rule_1 = 1 if Year >= EffectiveYear
	replace Rule_1 = 0 if Rule_1 == .
	gen log_cand = log(NUMBEROFCANDIDATES)
	egen State_ID = group(State_cl)
	label variable Rule_1 "Rule"

* Set up descriptive samples
	gen desc_sample = 1
	replace desc_sample = 0 if EffectiveYear < 1984
	replace desc_sample = 0 if EffectiveYear > 2003
	gen May_Sitting = 0
	replace May_Sitting = 1 if May_Nov == "May"

	label variable Int_150 "GradXRule"
	label variable yearb1 "Year Before"
	drop Int_150
	gen Int_150 = GRAD * Rule_1
	replace Int_150 = 0 if Int_150 == .

save "output/workingdata.dta", replace
