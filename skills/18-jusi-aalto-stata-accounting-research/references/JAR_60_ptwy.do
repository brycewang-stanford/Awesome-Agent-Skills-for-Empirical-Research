
* Preperation of Main Face and Demographic variables *

* Face factors - orthog and rescale *
	use raw_traits.dta, clear 
	orthog trust attract dom  , generate(trust_o attract_o dom_o    )
	foreach v of varlist trust attract dom trust_o attract_o dom_o{
		bys female: egen `v'_min = min(`v')
		bys female: egen `v'_max = max(`v')
		replace `v' = (`v' -  `v'_min) / (`v'_max - `v'_min )

	}
	save analyst_face_factors.dta, replace
	
* Gender indicator *
	use baseline.dta, clear 
	split analyst_name, p(" ")
	rename analyst_name1 first_name
	drop analyst_name2
	capt drop _merge 
	/* This name_gender dataset gives first names' probability of female/male */
	/* This dataset is collected from https://www.behindthename.com */
	merge m:1 first_name using name_gender.dta
	/* for not matched sample (_merge == 1) or sample with unisex name probability, manually check using FaceX's face analytics API */
	/* see more about FaceX API at https://facex.io/UserGuide/api/ */
	drop if _merge == 2
	drop _merge
	g female = 0
	replace female = 1 if prop_female > prop_male

* Age *
	merge m:1 amaskcd using linkedInProfile.dta 
	/* match linkedin profile data, the data was collected from LinkedIn together with the photo, including the complete education background of analysts starting from undergraduate degree */
	g edu_year1 = ustrregexs(0) if ustrregexm(edu_time1, "[0-9]+")
	g edu_year2 = ustrregexs(0) if ustrregexm(edu_time2, "[0-9]+")
	g edu_year3 = ustrregexs(0) if ustrregexm(edu_time3, "[0-9]+")
	destring edu_year1 edu_year2 edu_year3, replace force
	replace edu_year1 = edu_year2 if edu_year2 < edu_year1
	replace edu_year1 = edu_year3 if edu_year3 < edu_year1
	drop edu_year2 edu_year3
	rename edu_year1 first_school_year
	/* infer age from first school year*/
	g age = year(anndats) - first_school_year + 19 









****Part 3- Main Analyses***

***Software: Stata MP Ver. 16.1 ***

*******************************
**Table 2 Baseline Regression**
*******************************

*** Generate Accuracy Measures ***
cd "C:\Users\***\Desktop\Face_value\"
use IBES1990-2017.dta

*** Load the IBES detail history file downloaded from WRDS in April, 2018; the dataset contains all forecasts for the entire database with anndats from January 1990 to December 2017 ***

/*keep quarterly EPS forecasts that are made before the earnings announcements*/
keep if measure =="EPS"	 
keep if fpi =="6"| fpi=="7"|fpi=="8"|fpi=="9"    
drop if anndats > anndats_act    

/* drop outdated forecasts */
gen int horizon=fpedats -anndats
drop if horizon>=365   

/* drop if the analyst identification or brokerage identification is missing*/
drop if analys ==0
drop if estimator ==0  
 
/*keep analysts' last forecast for each firm-quarter*/
bys analys cusip fpedats : egen last_date=max(anndats)
keep if anndats ==last_date   

/*generate measure of absolute forecast errors- AFE*/
gen AFE=abs( actual- value)
winsor AFE, gen(AFE_w) p(0.01)  

/*generate mesuare of mean absolute forecast errors - MAFE*/
bys cusip fpedats: egen MAFE=mean(AFE_w)

/*generate the number of analyst following the firm-quarter*/
bys fpedats cusip: egen analyst_following=count(value)  

/*drop if the firm-quarter has only one analsyt following the firm*/
drop if analyst_following ==1   

/*generate measure of proportional mean absoloute forecast errors - PMAFE*/
gen PMAFE=(AFE_w -MAFE)/MAFE
winsor PMAFE, gen(PMAFE_w) p(0.01)   

/*generate the main dependent variable - Accuracy*/
gen Accuracy = -1 * (PMAFE_w) * 100 

/*generate a numerical firm identification*/
egen firm=group(cusip)

save accuracy.dta

*** Generate Control Variables ***

/*This step generate the top10 brokerge indicator variable in a seperate file*/
use accuracy.dta, clear
gen year=year(anndats)

/*generate the brokersize equals to number of affiliated analysts*/
egen brokersize = nvals(analys), by(year estimator)     
duplicates drop estimator year, force
xtile brokersize_decile=brokersize, nq(10)

/*generate a list of top 10% brokerage-years measured by the number of affiliated analysts*/
keep if brokersize_decile==10
save as top10_list.dta   

/* This step construct control variables*/
gen date=anndats

/*construct analysts' general experience*/
bys analys :egen first_date= min(date)
gen gexp= (anndats- first_date)/365    
bys cusip fpedats: egen mean_gexp=mean( gexp )
gen dgexp= gexp- mean_gexp		

/*construct analysts' firm-specific experience*/
bys analys cusip: egen first_date_firm = min(date)
gen fexp= (anndats- first_date_firm)/365	
bys cusip fpedats: egen mean_fexp=mean( fexp )
gen dfexp = fexp- mean_fexp

/*construct measure of analyst-year portfolio size - number of firms*/
egen port_size = nvals(cusip ), by(year analys)
bys cusip fpedats: egen mean_portsize=mean( port_size  )
gen dportsize=port_size -mean_portsize

/*construct De-meaned HORIZON*/
bys cusip fpedats: egen mean_horizon=mean( horizon )
gen dhorizon=horizon-mean_horizon

/*construct measure of analyst-year number of industry - sic2*/
gen sic2 = substr(sic,1,2)
destring sic2, replace
egen no_sic2 = nvals(sic2), by(year analys)
bys cusip fpedats: egen mean_sic2=mean( no_sic2   )
gen dsic2=no_sic2 -mean_sic2

/*merge with top10_list dataset generated previously and construct De-meaned TOP10 measure*/
merge m:1 estimator year using top10_list.dta
gen top10=_merge==3		
bys cusip fpedats: egen mean_top10=mean( top10   )
gen dtop10=top10- mean_top10		

/*merge with analyst_age.dta construct in Part2 and construct De-meaned Age measure*/
merge m:1 analys year using analyst_age.dta   
keep if _merge ==3
drop _merge
bys cusip fpedats: egen mean_age=mean(age)
gen dage=age- mean_age

/*winsor control variables by 1% on each end*/
winsor dgexp, gen (Dgexp) p(0.01)
winsor dfexp, gen (Dfexp) p(0.01)
winsor dbrokersize, gen (Dbrokersize) p(0.01)
winsor dport_size, gen (Dportsize) p(0.01)
winsor dhorizon, gen (Dhorizon) p(0.01)
winsor dsic2, gen(Dsic2) p(0.01)
winsor dage, gen (Dage) p(0.01)
winsor dtop10, gen (Dtop10) p(0.01)

save, replace

/*This step generates firm fundamental control variables using Compustat and CRSP dataset*/

/*prepare compustat data for merging*/
use Compustat.dta, clear
gen year=year(datadate)
replace cusip=substr(cusip,1,8)
replace ceq=at-lt if ceq==.
save Compustat.dta, replace

/*merge CRSP monthly data with the compustat data of the previous year*/
use CRSP_monthly.dta
gen year=year(date)
replace year=year-1
merge m:1 year cusip using Compustat.dta
keep if _merge==3
drop _merge		

/*calculate market value of equity and book-to-market ratio*/
gen me=prc*shrout
gen bm=ceq*1000/me
gen size=log(me)

/*calculate market adjusted buy and hold abnormal return of the previous 6 months*/
replace year= year+1
sort cusip year month
bys cusip: egen bhar_6m=(1+ret[_n-1])*(1+ret[_n-2])*(1+ret[_n-3])*(1+ret[_n-4])*(1+ret[_n-5])*(1+ret[_n-6])-(1+ewretd[_n-1])*(1+ewretd[_n-2])*(1+ewretd[_n-3])*(1+ewretd[_n-4])*(1+ewretd[_n-5])*(1+ewretd[_n-6])

/*winsor control variables by 1% on each end*/
winsor size, gen(size_w) p(0.01)
winsor bm, gen(bm_w) p(0.01)
winsor bhar_6m, gem(bhar_6m_w) p(0.01)

save fundamental.dta

/*merge the forecast data with fundamental data generated previously*/
use accuracy.dta, clear
merge m:1 cusip year month using fundamental.dta
keep if _merge==3
drop _merge

/*merge with Face Factors and other analystd demographic information data*/
merge m:1 analys using analyst_face_factors.dta
keep if _merge ==3
drop _merge
save baseline.dta

/*Empirical Analyses*/
qui: reghdfe Accuracy trust female fWHR Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m , absorb(firm year) vce(cluster firm)
est store trust

qui: reghdfe Accuracy attract female fWHR Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m , absorb(firm year) vce(cluster firm)
est store attract

qui: reghdfe Accuracy dom female fWHR Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m , absorb(firm year) vce(cluster firm)
est store dom

qui: reghdfe Accuracy trust_o attract_o dom_o female fWHR Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m , absorb(firm year) vce(cluster firm)
est store full

estout trust attract dom full, cells(b(star fmt(4)) t(par fmt(2))) stats(r2_a N ) starlevels(* 0.1 ** 0.05 *** 0.01) modelwidth(12)


*******************************
**Table 3: In-Person Meetings**
*******************************

***Note: For details on downloading and processing Thomson street event dataset and identify participants, please refer to "Get Speaker.ipynb" Python-3.5 code included in this folder.***

***indentify participants for each event- note TR street Event data is available after 2004***

/*
Variable Mapping List (Check Thomson Reuter StreetEvent for detailed variable definitions)
	v1: EventTitle
	v2: EventDate
	v3: EventType
	v4: companyName
	v5: firstName
	v6: id
	v7: identified
	v8: lastname
	v9: organizer
	v10: phoneticSpelling
	v11: position
	v12: ticker 
*/

clear all 
/*Import the python output file (see: Get Speaking Information from Thomson Reuter.ipynb)*/
import delimited "__STREET_EVENT_FILE__", delimiter("|") clear

/*Keep analyst day and corporate conference events*/
keep if v3 == "Analyst Meetings" | v3 == "Corporate Analyst Meetings"  | v3 == "Conference Presentations"

/*Keep analyst participants*/
keep if v11 == "Analyst" 
drop v6 v7 v9 v10 v11 v13 

/*Replace first name and last name to lowercase*/
replace v5 = lower(v5)
replace v8 = lower(v8)

/*Get date by split by ` / ' (Date / Time, e.g. 04/26/01 / 02:00PM)*/
split v2, p(" / ")
g date = date(v21, "MDY", 2020)
drop v21 v22 

/*Rename variable 12 as tic(ker)*/
rename v12 tic 

/*Keep if both last name and first name is non-missing*/ 
drop if v5 == "" | v8 == ""
drop v1 v2 v3 v4 
g analyst_name = v5 + " " + v8 
drop v5 v8 

duplicates drop analyst_name date tic, force
save meeting.dta, replace 


***meeting-window 1***
use baseline.dta, clear

g meet=0

/*match forecast data with meeting data to identify if a forecast is made within 0,180 day window following a meeting event*/

forval i = 0/180{
	
	quietly merge m:1 tic analyst_name date using "meeting.dta"
	capt replace meet = 1 if _merge == 3
	capt drop if _merge == 2
	capt drop _merge 
	capt replace date = date - 1 
	
}

/*generate interaction terms of face factors with meeting indicator*/

foreach v of varlist trust_o attract_o dom_o{
	capt drop `v'_meet
	g `v'_meet =`v' * meet
}

qui: reghdfe Accuracy trust_o attract_o dom_o trust_o_meet attract_o_meet dom_o_meet meet fWHR female Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m if year>=2004,absorb(firm year) vce(cluster firm )  
est store window1

***meeting window 2***

use baseline.dta, clear
g meet=0

/*match forecast data with meeting data to identify if a forecast is made within 181,360 day window following a meeting event*/

replace date=date-180

forval i = 0/180{
	
	quietly merge m:1 tic analyst_name date using "meeting.dta"
	capt replace meet = 1 if _merge == 3
	capt drop if _merge == 2
	capt drop _merge 
	capt replace date = date - 1 
	
}

/*generate interaction terms of face factors with meeting indicator*/

foreach v of varlist trust_o attract_o dom_o{
	capt drop `v'_meet
	g `v'_meet =`v' * meet
}

qui: reghdfe Accuracy trust_o attract_o dom_o trust_o_meet attract_o_meet dom_o_meet meet fWHR female Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m if year>=2004, absorb(firm year) vce(cluster firm )  
est store window2

estout window1 window2, cells(b(star fmt(4)) t(par fmt(2))) stats(r2_a N ) starlevels(* 0.1 ** 0.05 *** 0.01) modelwidth(12) 

*******************
**Table 4: Reg FD**
*******************

use baseline.dta, clear

/*define indicator variable Pre-FD =1 if the forecast was annouced before October 23, 2000*/
g FD = (anndats < 14906)

foreach v of varlist trust_o attract_o dom_o{
	capt drop `v'_FD
	g `v'_FD =`v' * FD 
}

/*empirical analyses*/

qui: reghdfe Accuracy trust_o attract_o dom_o fWHR female Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m if FD==1, absorb(firm) vce(cluster firm)
est store pre-fd

qui: reghdfe Accuracy trust_o attract_o dom_o fWHR female Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m if FD==0, absorb(firm) vce(cluster firm)
est store post-fd

qui: reghdfe Accuracy trust_o attract_o dom_o trust_o_FD attract_o_FD dom_o_FD fWHR female FD Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m, absorb(firm) vce(cluster firm)
est store fd_interaction

estout pre-fd post-fd fd_interaction, cells(b(star fmt(4)) t(par fmt(2))) stats(r2 N ) starlevels(* 0.1 ** 0.05 *** 0.01) modelwidth(12)

******************************
**Table 5: New Relationships**
******************************

***Use annual executive-comp file to identify the turnover of new CEO or CFO， the anncomp.dta dataset was downloaded from WRDS in November 2019***

/*identify the first year an executive is CEO*/
use anncomp.dta, clear 
rename TITLEANN titleann
rename YEAR year
rename GVKEY gvkey
rename CO_PER_ROL co_per_rol
replace titleann = lower(titleann)
keep if ceoann == "CEO"
duplicates drop gvkey co_per_rol year, force
bys gvkey co_per_rol: egen min_year = min(year) 
g turnover = (year == min_year)
format titleann %30s 
sort gvkey year 
keep if turnover == 1 
keep gvkey year
save ceo_turnover.dta, replace

/*identify the first year an executive is CFO*/
use anncomp.dta, clear 
rename TITLEANN titleann
rename YEAR year
rename GVKEY gvkey
rename CO_PER_ROL co_per_rol
replace titleann = lower(titleann)
keep if regexm(titleann, "cfo|chief financial officer|chief finance officer")
duplicates drop gvkey co_per_rol year, force
bys gvkey co_per_rol: egen min_year = min(year) 
g turnover = (year == min_year)
format titleann %30s 
sort gvkey year 
keep if turnover == 1 
keep gvkey year
save cfo_turnover.dta, replace

/*combine the two dataset*/
use ceo_turnover.dta, clear 
append using cfo_turnover.dta
duplicates drop gvkey year, force
save ceo_cfo_turnover.dta, replace

/*New Analyst*/
use baseline.dta, clear

/*identify the first year an analyst is following an industry*/
bys analys sic2: egen first_year = min(year)	
capt drop junior 
g junior = 0
replace junior = 1 if year - first_year <= 2

/*generate interaction terms*/
foreach v in trust_o attract_o dom_o{
	capt drop junior_`v'
	g junior_`v' = junior*`v'
}

/*empirical analyses*/
qui: reghdfe Accuracy trust_o attract_o dom_o junior_trust_o junior_attract_o junior_dom_o junior fWHR female Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m , absorb(firm year) vce(cluster firm )  
est store new_analyst
	
/*New CEO-CFO*/ 
use baseline.dta, clear

/*merge with CEO-CFO turnvoer data to identify forecasts made within two years following ceo/cfo turnover*/
g I = 0			
forval i = 1/2{
	replace year = year - 1 
	merge m:1 gvkey year using ceo_cfo_turnover.dta
	replace I = 1 if _merge == 3
	drop if _merge == 2
	drop _merge
}

replace year = year(anndats)

/*generate interaction terms*/
foreach v of varlist trust_o attract_o dom_o{
	capt drop `v'_I 
	g `v'_I = `v' * I 
}

/*empirical analyses*/
qui: reghdfe Accuracy trust_o attract_o dom_o trust_o_I attract_o_I dom_o_I I fWHR female Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m , absorb(firm year) vce(cluster firm )
est store new_ceo_cfo

estout new_analyst new_ceo_cfo , cells(b(star fmt(4)) t(par fmt(2))) stats(r2 r2_a N ) starlevels(* 0.1 ** 0.05 *** 0.01) modelwidth(12)


************************
**Table 6: Uncertainty**
************************
/*Column 1: High Analyst Dispersion*/

/*Identify High Analyst Dispersion Firms*/

/*calculate the standard deviation of analyst EPS forecast for a given firm-quarter*/
use baseline.dta, clear
bys cusip fpedats : egen value_sd=sd(value)
duplicates drop cusip fpedats, force
rename value_sd dispersion 
replace dispersion = dispersion/prc 

/*calculate the firm-level mean dispersion in the past 2 years*/
rangestat (mean) dispersion , interval(year, -2, -1) by(cusip) 
rename dispersion_mean dispersion 
winsor2 dispersion, cuts(1 99) replace by(year)
bys year quarter: egen dispersion_h = pctile(dispersion), p(50)
g I = (dispersion>=dispersion_h) if dispersion != . 

save high_disperson.dta

/*Merge basline sample with high_dispersion dataset*/
use baseline.dta, clear 
gen quarter=quarter(date)
merge m:1 cusip year quarter using high_dispersion.dta
keep if _merge==3
drop _merge

/*generate ineraction terms*/
foreach v of varlist trust_o attract_o dom_o{
	capt drop `v'_I
	g `v'_I =`v' * I
}

/*empirical analyses*/
qui: reghdfe Accuracy trust_o attract_o dom_o trust_o_I attract_o_I dom_o_I I fWHR female Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m , absorb(firm year) vce(cluster firm )
est store high_dispersion

estout high_dispersion, cells(b(star fmt(4)) t(par fmt(2))) stats(r2 r2_a N ) starlevels(* 0.1 ** 0.05 *** 0.01) modelwidth(12) 

/*Column 2: High Earnings Volatility*/

/*Calculate earnings volatility as the seasonal earning changes estimated over the two-year period ending on the fiscal end date*/

/*use COMPUSTAT quarterly file*/
use compustat_q.dta,clear
sort fyearq fqtr

/*generate time variable for panel*/
egen tv = group(fyearq fqtr)
duplicates drop tv cusip, force
egen cusip_id = group(cusip) 
xtset cusip_id tv 

/*calculate eps change as the seasonal quarterly EPS change*/
g eps_change = epspiq - L4.epspiq

/*calculate the standard deviation of the seaonsl quarterly EPS change in the past eight quarters*/
rangestat (sd) eps_change, by(cusip) interval(tv, -7, 0) 
rename eps_change_sd ev 
keep ev cusip fqtr fyearq
duplicates drop fqtr fyearq cusip, force 
gen year=year(datadate)
gen quarter=quarter(datadate)
replace cusip = substr(cusip, 1, 8) 
save firm_ev.dta, replace 

/*calcualate sample-median EV*/
use accuracy.dta, clear
merge m:1 cusip year quarter using firm_ev.dta
drop if _merge != 3
drop _merge 
duplicates drop year quarter cusip , force 

/*generate the median EV for sample*/
bys year quarter: egen ev_median = median(ev) 
keep year quarter cusip ev ev_median
save sample_ev.dta, replace 

/*High EV-regressions*/
use baseline.dta, clear

/*to merge EV of the last quarter*/
replace anndats = anndats - 90 
replace year = year(anndats)
replace quarter = quarter(anndats)

/*merge to get firm quarter EV estimated in firm_ev.dta*/
merge m:1 cusip year quarter using firm_ev.dta
drop if _merge!=3
drop _merge

/*merge to get sample EV estimated in sample_ev.dta*/
merge m:1 cusip year quarter using sample_ev.dta
drop if _merge!=3
drop _merge

/*generate indicator var for high_EV*/
g high_ev = (ev>ev_median)
replace anndats = anndats + 90 
replace year = year(actdats)
replace quarter = quarter(actdats)

/*generate interaction terms*/
foreach v in trust_o attract_o dom_o{
	capt drop high_ev_`v'
	g high_ev_`v' = high_ev*`v'
}

/*Empirical Analyses*/
qui: reghdfe Accuracy trust_o attract_o dom_o high_ev_trust_o high_ev_attract_o high_ev_dom_o high_ev fWHR female Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m, absorb(firm year) vce(cluster firm )
est high_ev

estout high_ev, cells(b(star fmt(4)) t(par fmt(2))) stats(r2 r2_a N ) starlevels(* 0.1 ** 0.05 *** 0.01) modelwidth(12) 

****************************
**Table 7: Market Reaction**
****************************

/*Calculate Abnormal Return*/

/*Use full CRSP daily file, the file was downloaded through WRDS in July 2018*/
use CRSP_daily.dta, clear 
sort permno date
replace prc = abs(prc)

/*Calculate the daily CAR as the difference between the individual stock return and the CRSP value-weighted index return*/
g CAR0 = (prc/prc[_n-1]-1) - vwretd if permno == permno[_n-1]		
winsor CAR0, p(0.001) g(CAR0_w)
replace CAR0 = CAR0_w
drop CAR0_w

/*Calculate CAR(-1,+1)*/
g car1 = 0
sort permno date
replace car1 = (1+car1) * (1+CAR0[_n-1]) -1 if permno == permno[_n-1] & CAR0[_n-1] != .
replace car1 = (1+car1) * (1+CAR0) -1 
replace car1 = (1+car1) * (1+CAR0[_n+1]) -1 if permno == permno[_n+1] & CAR0[_n+1] != . 

/*Calculate the price of -2 day to deflate foreacst revisions*/
g l2prc = prc[_n-2] if permno == permno[_n-2] & prc[_n-2] != .
duplicates drop cusip date, force 
keep cusip date car1 l2prc 
save ret.dta, replace 

/*Calculate the earnings revision measures*/
use IBES1990-2017.dta, clear   
keep if measure =="EPS"	
keep if fpi =="6"| fpi=="7"|fpi=="8"|fpi=="9"   
drop if anndats > anndats_act 
gen int horizon=fpedats -anndats
drop if horizon>=365    
drop if analys == 0
drop if estimator == 0  
g date=anndats

/*merge with return data calculated previously*/
merge m:1 cusip date using ret.dta
keep if _merge ==3
drop _merge 

/*generate revision equal to the difference between the analyst's current and preceding earnings forecast for a firm-quarter, scaled by the stock price two trading days prior to the current forecast date*/
sort analys cusip fpedats date   
bys analys cusip fpedats: g lastvalue = value[_n-1]
g revision = (value-lastvalue)/l2prc
keep if revision != . 

/*delete revisions with same-day revisions*/
bys cusip date: egen num_count = count(date)		
sum num_count, d 
drop if num_count > 1
keep analys cusip anndats fpedats car1 revision

/*merge with baseline data */
merge 1:1 analys cusip anndats fpedats using baseline.dta
keep if _merge == 3
drop _merge 

/*generate measure of an analys's lagged accuracy as control variable*/
rangestat (mean) Accuracy, interval(date -730 -1) by(analys)
rename Accuracy_mean precision
winsor2 revision precision car1, cuts(1 99) replace 

/*Column 1 and Column 2*/
g precision_revision = precision * revision 
foreach v of varlist trust_o attract_o dom_o{
	g revision_`v'= revision * `v'
}

/*generate interaction of revision and control variables*/
global additonal_interactions = ""
foreach v of varlist gexp fexp age portfolio_size broker_size female no_following roa leverage_ratio size_w bm_w bhar_6m horizon {
	capt drop revision_`v'
	g revision_`v' = revision * `v'
	global additonal_interactions = "$additonal_interactions revision_`v'"
}
quietly do ff17.do   /* add ff-17 industry classifications*/
capt drop quarter 
g quarter = quarter(date)
egen year_quarter = group(year quarter)

qui: reghdfe car1 gexp fexp age portfolio_size broker_size  revision_fWHR fWHR female revision_trust_o revision_attract_o revision_dom_o trust_o attract_o dom_o precision_revision precision revision no_following roa leverage_ratio size_w bm_w bhar_6m horizon $additonal_interactions , absorb(year_quarter ff17) cluster(firm)
est store reg1
qui: reghdfe car1 gexp fexp age portfolio_size broker_size  revision_fWHR fWHR female revision_trust_o revision_attract_o revision_dom_o trust_o attract_o dom_o precision_revision precision revision no_following roa leverage_ratio size_w bm_w bhar_6m horizon $additonal_interactions , absorb(i.year_quarter##c.revision i.ff17##c.revision ) cluster(firm)
est store reg2

estout reg1 reg2, cells(b(star fmt(4)) t(par fmt(2))) stats(r2_a N ) starlevels(* 0.1 ** 0.05 *** 0.01) modelwidth(12) 

/*Column 3*/

/*merge forecast data with institutional_ownership data of the previous year*/
replace year=year-1
merge m:1 cusip year using insitutional_ownership.dta		
/*Institutional_ownership dataset was downloaded from WRDS Thomson Reuters Institutional (13f) Holdings - Stock Ownership Summary in February 2021*/

keep if _merge==3
drop _merge

bys year ff17: egen insti_own_p = pctile(InstOwn_Perc) if InstOwn_Perc!=. , p(75)
g h = (InstOwn_Perc >= insti_own_p) 
replace year=year+1

/*generate interaction terms*/ 
foreach v of varlist trust_o attract_o dom_o {
	capt drop `v'_h revision_`v'_h
	g `v'_h = `v' * h 
	g revision_`v'_h = revision_`v' * h 
}
g revision_h = revision * h 
global interactions3way = "revision_trust_o_h revision_attract_o_h revision_dom_o_h"
global interactions2way = "trust_o_h attract_o_h dom_o_h revision_trust_o  revision_attract_o  revision_dom_o revision_h"
global interactions1way = "trust_o attract_o dom_o  h "

/*empirical analyses*/
qui: reghdfe car1 gexp fexp age portfolio_size broker_size  revision_fWHR fWHR female $interactions3way $interactions2way $interactions1way precision_revision precision no_following roa leverage_ratio size_w bm_w bhar_6m horizon $additonal_interactions , absorb(i.year_quarter##c.revision i.ff17##c.revision ) cluster(firm)
est store reg3

estout reg3, cells(b(star fmt(3)) t(par fmt(2))) stats(r2_a N ) starlevels(* 0.1 ** 0.05 *** 0.01) modelwidth(12) 
 
**************************
**Table 8: Female Sample**
**************************

use baseline.dta, clear

qui: reghdfe Accuracy trust_o attract_o dom_o fWHR Dgexp Dfexp Dhorizon Dportsize Dsic2 Dtop10 Dage analyst_following size_w bm_w bhar_6m if female==1, absorb(sic2 year) vce(cluster firm)
est store female

estout female, cells(b(star fmt(4)) t(par fmt(2))) stats(r2_a N ) starlevels(* 0.1 ** 0.05 *** 0.01) modelwidth(12)

*******************************
**Table 9: All-Star Selection**
*******************************

use baseline.dta, clear

/*generate control variables of analyst annual measure of forecast accuracy*/
bys year analys: egen mean_accuracy = mean(accuracy)

/*calculate portfolio cap, for each firm year, count into portfolio only once*/ 
bys year analys cusip: gen u = _n 
bys year analys: egen portfolio_cap = sum(size_w) if u == 1 

/*apply the calculated number to the rest of sample*/
bys year analys: egen portfolio_cap_m = mean(portfolio_cap) 
replace portfolio_cap = portfolio_cap_m 
drop u portfolio_cap_m 
duplicates drop analys year, force

/*merge with all_star.dta, collected from Institutional Investor magazine’s All-Star Analyst list from 1991 to 2017*/
merge 1:1 year analys using all_star.dta
g all_star_dummy = (_merge == 3)
drop if _merge == 2
drop _merge

/*generate indicator variable if the analyst is elected all-star the next year*/
tsset analys year
g become_star_dummy = (f.all_star_dummy==1)

/*logit regression for female and male sample*/
qui: logit become_star_dummy fWHR trust_o attract_o dom_o portfolio_size no_sic2 broker_size mean_accuracy portfolio_cap age all_star_dummy i.year if female == 1 , r      
est store female
qui: logit become_star_dummy fWHR trust_o attract_o dom_o portfolio_size no_sic2 broker_size mean_accuracy portfolio_cap age all_star_dummy i.year if female == 0 , r      
est store male

estout female male , cells(b(star fmt(4)) z(par fmt(2))) stats(r2_p N chi2) starlevels(* 0.1 ** 0.05 *** 0.01) modelwidth(9) 

/*test of coefficient equality*/ 
qui: logit become_star_dummy fWHR trust_o attract_o dom_o portfolio_size no_sic2 broker_size mean_accuracy portfolio_cap age all_star_dummy i.year if female == 1   
est store female
qui: logit become_star_dummy fWHR trust_o attract_o dom_o portfolio_size no_sic2 broker_size mean_accuracy portfolio_cap age all_star_dummy i.year if female == 0   
est store male
qui: suest female male, robust 
test [ALL1_`v']trust_o = [ALL2_`v']trust_o
test [ALL1_`v']attract_o = [ALL2_`v']attract_o
test [ALL1_`v']dom_o = [ALL2_`v']dom_o

/*end of code*/