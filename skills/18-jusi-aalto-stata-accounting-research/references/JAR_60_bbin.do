/*******************************************************************************
							Barrios, Bianchi, Isidro, and Nanda 2022
 Boards of a Feather: Homophily in Foreign Director Appointments Around the World
 

This code is for STATA Parallel 16.1 Edition  


This code is meant to clean the raw data downloaded from BoardEx in csv format (Step 1 trough Step 4) and xlsx format (Step 5)

*******************************************************************************/



/********************************************************************************
********************************************************************************

*STEP 1 - Clean the Employment files (board appointments):
1- Employment_Current.csv
2- Employment_Non Current.csv

Run this code for each of the BoardEx regions separately:
1- Europe (EU)
2- United Kingdom (UK)
3- North America (directors) (NA)
4- North America (senior managers) (SME)
5- Rest of the World (ROW)

********************************************************************************
********************************************************************************/


*Set as directory the folder where you have saved the original data downloaded from BoardEx
cd "original files/region"

*Import Employment_Current.csv
insheet using Employment_Current.csv, delimiter(,) clear
format directorid %14.0g
format companyid %14.0g

*Set the starting date for each position
gen year = regexs(0) if regexm(startdate, "[0-9]*$")

replace year = "20"+regexs(0) if regexm(year, "^[0-1][0-9]$")
replace year = "19"+regexs(0) if regexm(year, "^[2-9][0-9]$")
destring year, replace 

*Set as end date the year when you downloaded the data from BoardEx (in our case it was end of December 2014)
gen enddate=2014
rename year startdate2 
label var startdate2 "Start Date - year"
label var enddate "End Date - year in the current employment sample"

* Generate variable to identify Executive Directors
gen edned2=0
replace edned2=1 if edned=="ED"
label var edned2 "0 if non executive, 1 if executive"

*Generate variable to identify the company type
gen companytype2=0
replace companytype2=1 if companytype=="Private"
replace companytype2=2 if companytype=="Quoted"
label var companytype2 "0 other, 1 Private, 2 Public"
rename enddate enddate2
gen enddate=.
move enddate committeename
tostring enddate, replace
format enddate %9s


*Import Employment_Non_Current.csv
preserve
clear
insheet using Employment_Non_Current.csv, delimiter(,)
format directorid %14.0g
format companyid %14.0g

*Set year of start and end dates 
gen year = regexs(0) if regexm(startdate, "[0-9]*$")

replace year = "20"+regexs(0) if regexm(year, "^[0-1][0-9]$")
replace year = "19"+regexs(0) if regexm(year, "^[2-9][0-9]$")
destring year, replace 
rename year startdate2 
label var startdate2 "Start Date - year"

gen year = regexs(0) if regexm(enddate, "[0-9]*$")

replace year = "20"+regexs(0) if regexm(year, "^[0-1][0-9]$")
replace year = "19"+regexs(0) if regexm(year, "^[2-9][0-9]$")
destring year, replace 
rename year enddate2 
label var enddate2 "End Date - year"

* Generate variable to identify Executive Directors
gen edned2=0
replace edned2=1 if edned=="ED"
label var edned2 "0 if non executive, 1 if executive"

*Generate variable to identify the company type
gen companytype2=0
replace companytype2=1 if companytype=="Private"
replace companytype2=2 if companytype=="Quoted"
label var companytype2 "0 other, 1 Private, 2 Public"
rename countryname country
save "temp/historicemployment", replace
restore


*Append the Employment_Non_Current to the Employment_Current

append using "temp/historicemployment"

*Sort the observations
gsort  directorid startdate2 enddate2 -companytype2


*Clean and label the variables of interest
lab var country "Country of the company"
replace role=lower(role)

*Create CEO dummy
gen prova=strpos(role, "ceo") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova2=strpos(role, "chief executive") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova3=strpos(role, "company leader") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova4=strpos(role, "group leader") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen ceo=0
replace ceo=1 if prova>0 & prova!=. & strpos(role, "assistant")==0
replace ceo=1 if prova2>0 & prova2!=. & strpos(role, "assistant")==0
replace ceo=1 if prova3>0 & prova3!=. & strpos(role, "assistant")==0
replace ceo=1 if prova4>0 & prova4!=. & strpos(role, "assistant")==0
drop prova*
lab var ceo "1 if ceo 0 otherwise"

*Create CFO dummy
gen prova=strpos(role, "cfo") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova2=strpos(role, "chief financial") if strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova3=strpos(role, "chief finance") if strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova4=strpos(role, "principal financial") if strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova5=strpos(role, "principal finance") if strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen cfo=0 
replace cfo=1 if prova>0 & prova!=. & strpos(role, "assistant")==0
replace cfo=1 if prova2>0 & prova2!=. & strpos(role, "assistant")==0
replace cfo=1 if prova3>0 & prova3!=. & strpos(role, "assistant")==0
replace cfo=1 if prova4>0 & prova4!=. & strpos(role, "assistant")==0
replace cfo=1 if prova5>0 & prova5!=. & strpos(role, "assistant")==0
drop prova*
lab var cfo "1 if cfo 0 otherwise"

*Create chairman dummy
gen chairman=strpos(role, "chairman") if strpos(role, "vice")==0 & strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen president=strpos(role, "president") if strpos(role, "vice")==0 & strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen chair=0
replace chair=1 if chairman>0 & chairman!=. & strpos(role, "assistant")==0
replace chair=1 if president>0 & president!=. & strpos(role, "assistant")==0
drop chairman president 
lab var chair "1 if chair 0 otherwise"

*Create audit committee member dummy
replace committeename=lower(committeename)
gen prova=strpos(committeename, "audit")
gen audit=0
replace audit=1 if prova==1 & length(committeename)==5
replace audit=2 if prova>=1 & length(committeename)>5
lab var audit "0 no audit 1 pure audit 2 audit + something"
drop prova

*Create audit compensation member dummy
gen prova=strpos(committeename, "compensation") | strpos(committeename, "remuneration")
gen compensation=0
replace compensation=1 if prova==1 & length(committeename)==12
replace compensation=2 if prova>=1 & length(committeename)!=12
lab var audit "0 no compensation 1 pure compensation 2 compensation + something"
drop prova
lab var compensation "0 no compensation 1 pure compensation 2 compensation + something"

*Create audit governance member dummy
gen prova=strpos(committeename, "governance")
gen governance=0
replace governance=1 if prova>0
lab var governance "0 other 1 governance"
drop prova

*Create nomination committee member dummy
gen prova=strpos(committeename, "nominating") | strpos(committeename, "nomination")
gen nomination=0
replace nomination=1 if prova>0
lab var nomination "0 other 1 nomination"
drop prova

*Create executive committee member dummy
gen executive=0 
replace executive=1 if strpos(committeename, "executive") & compensation==0
lab var executive "0 other 1 executive"

*Create finance committee member dummy
gen finance=0 
replace finance=1 if strpos(committeename, "finance") & audit==0
replace finance=1 if committeename=="investments"
lab var finance "0 other 1 finance"

*Restrict the sample to both private and public companies
keep if companytype2!=0 

*Create an identifier for each observation, where an observation is in wide form and represents an individual work experience for a specific company for the period that starts in startdate and finishes in enddate */
gen id=_n 

*Drop variables that are not of interest
drop companyindex sectorname ///
companytype role roledescription edned startdate enddate committeename committeerole

rename startdate2 yearrole1
rename enddate2 yearrole2

* Delete observations without both beginning and ending date
drop if yearrole1==. & yearrole2==. 

* Set the beginning date equal to the ending date when we have only the ending date available and viceversa
replace yearrole1=yearrole2 if yearrole1==. 
replace yearrole2=yearrole1 if yearrole2==. 

/*Reshape to long form in order to have a panel*/
reshape long year, i(id) j(yearrole, string) 

sort id year


* Eliminate all those observations that are duplicates
duplicates drop id year, force 
tsset id year
tsfill

*Carryforward the relevant variables that were originally reported in wide form 
by id: carryforward directorid companyid companytype2 country edned2 ceo cfo chair audit compensation governance nomination executive finance, replace

drop  id yearrole 

*Create an identifier for European countries
gen europe=0
replace europe=1 if country=="Austria" |country=="Belgium" | country=="Bulgaria"	| country=="Croatia" ///
| country=="Cyprus" | country=="Czech Republic" | country=="Denmark" | country=="Estonia" | country=="Finland" ///
| country=="France" | country=="Germany" | country=="Greece" | country=="Italy" | country=="Lithuania" ///
| country=="Luxembourg" | country=="Malta" | country=="Norway" | country=="Poland" | country=="Portugal" ///
| country=="Republic Of Ireland" | country=="Romania" | country=="Slovakia" | country=="Slovenia" | country=="Spain" ///
| country=="Sweden" | country=="Switzerland" 	
replace europe=1 if strpos(country, "United Kingdom") | strpos(country, "British")

sort directorid year companyid
by directorid: egen firstyear=min(year)


save "outcome/region_boardexemployment", replace

/********************************************************************************
*In your "outcome" folder, after your run this code for each of the above 5 regions (EU, UK, NA, NA-SM,and ROW) you should have the following files:
eu_boardexemployment
uk_boardexemployment
na_boardexemployment
sm_boardexemployment
row_boardexemployment
********************************************************************************/

*Aggregate the above files 

cd "outcome"
use eu_boardexemployment, clear
append using uk_boardexemployment
append using row_boardexemployment
append using na_boardexemployment
append using sm_boardexemployment
sort directorid companyid year

*Drop duplicated observations 
duplicates drop directorid companyid year, force 
save "outcome/global_employment", replace /* formerely euukemployment */



/********************************************************************************
********************************************************************************

*STEP 2 - Clean the Non-board appointments files:
1- Non_Board_Current.csv
2- Non_Board_Non_Current.csv

Run this code for each of the BoardEx regions separately:
1- Europe (EU)
2- United Kingdom (UK)
3- North America (directors) (NA)
4- North America (senior managers) (SME)
5- Rest of the World (ROW)

********************************************************************************
********************************************************************************/
*Set as directory the folder where you have saved the original data downloaded from BoardEx
cd "original files/region"

*Import Non_Board_Current.csv
insheet using Non_Board_Current.csv, delimiter(,) clear
destring directorid, replace force
format directorid %14.0g
format companyid %14.0g

gen enddate=.
tostring enddate, replace
format enddate %9s

*Set the starting date for each position
gen year = regexs(0) if regexm(startdate, "[0-9]*$")

replace year = "20"+regexs(0) if regexm(year, "^[0-1][0-9]$")
replace year = "19"+regexs(0) if regexm(year, "^[2-9][0-9]$")
destring year, replace 


rename year startdate2 
label var startdate2 "Start Date - year"

*Set as end date the year when you downloaded the data from BoardEx (in our case it was end of December 2014)
gen enddate2=2014
label var enddate2 "End Date - year in the current employment sample"

* Generate variable to identify Senior Manager
gen ednedsm2=1
replace ednedsm2=0 if ednedsm!="SM"
label var ednedsm2 "0 if non SM, 1 if SM"

*Import Non_Board_Non_Current.csv

preserve
clear
insheet using Non_Board_Non_Current.csv, delimiter(,)
format directorid %14.0g
format companyid %14.0g

*Set the starting date for each position
gen year = regexs(0) if regexm(startdate, "[0-9]*$")

replace year = "20"+regexs(0) if regexm(year, "^[0-1][0-9]$")
replace year = "19"+regexs(0) if regexm(year, "^[2-9][0-9]$")
destring year, replace 


rename year startdate2 
label var startdate2 "Start Date - year"

*Set the end date for each position
gen year = regexs(0) if regexm(enddate, "[0-9]*$")
replace year = "20"+regexs(0) if regexm(year, "^[0-1][0-9]$")
replace year = "19"+regexs(0) if regexm(year, "^[2-9][0-9]$")
destring year, replace 
rename year enddate2 
label var enddate2 "End Date - year in the current employment sample"

* Generate variable to identify Senior Manager
gen ednedsm2=1
replace ednedsm2=0 if ednedsm!="SM"
label var ednedsm2 "0 if non SM, 1 if SM"

save "temp/historicother", replace
restore

*Append Non_Board_Non_Current.csv to Non_Board_Current.csv

append using "temp/historicother"

*Clean and label the variables of interest
lab var country "Country of the company"
replace role=lower(role)

*Generate variable to identify the company type
gen companytype2=0
replace companytype2=1 if companytype=="Private"
replace companytype2=2 if companytype=="Quoted"
label var companytype2 "0 other, 1 Private, 2 Public"
gsort  directorid startdate2 enddate2 -companytype2

*Create CEO dummy
gen prova=strpos(role, "ceo") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova2=strpos(role, "chief executive") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova3=strpos(role, "company leader") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova4=strpos(role, "group leader") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen ceo=0
replace ceo=1 if prova>0 & prova!=. & strpos(role, "assistant")==0
replace ceo=1 if prova2>0 & prova2!=. & strpos(role, "assistant")==0
replace ceo=1 if prova3>0 & prova3!=. & strpos(role, "assistant")==0
replace ceo=1 if prova4>0 & prova4!=. & strpos(role, "assistant")==0
drop prova*
lab var ceo "1 if ceo 0 otherwise"

*Create CFO dummy
gen prova=strpos(role, "cfo") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova2=strpos(role, "chief financial") if strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova3=strpos(role, "chief finance") if strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova4=strpos(role, "principal financial") if strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen prova5=strpos(role, "principal finance") if strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen cfo=0 
replace cfo=1 if prova>0 & prova!=. & strpos(role, "assistant")==0
replace cfo=1 if prova2>0 & prova2!=. & strpos(role, "assistant")==0
replace cfo=1 if prova3>0 & prova3!=. & strpos(role, "assistant")==0
replace cfo=1 if prova4>0 & prova4!=. & strpos(role, "assistant")==0
replace cfo=1 if prova5>0 & prova5!=. & strpos(role, "assistant")==0
drop prova*
lab var cfo "1 if cfo 0 otherwise"

*Create Chairman dummy
gen chairman=strpos(role, "chairman") if strpos(role, "vice")==0 & strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen president=strpos(role, "president") if strpos(role, "vice")==0 & strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen chair=0
replace chair=1 if chairman>0 & chairman!=. & strpos(role, "assistant")==0
replace chair=1 if president>0 & president!=. & strpos(role, "assistant")==0
drop chairman president 
lab var chair "1 if chair or president 0 otherwise"


*Create COO dummy
gen prova=strpos(role, "coo") if strpos(role, "elect")==0 & strpos(role, "regional")==0 & strpos(role, "division")==0 & strpos(role, "designate")==0 & strpos(role, "deputy")==0 & strpos(role, "emeritus")==0 & strpos(role, "global")==0 & strpos(role, "honorary")==0
gen coo=0 
replace coo=1 if prova>0 & prova!=. & strpos(role, "assistant")==0
drop prova
lab var coo "1 if coo 0 otherwise"

*Create Professor dummy
gen prova=strpos(role, "professor")
gen prova2=strpos(role, "lecturer")
gen prova3=strpos(role, "faculty member")
gen professor=0
replace professor=1 if prova>0 | prova2>0 | prova3>0
drop prova*
lab var professor "1 if professor faculty or adjunct 0 otherwise"


*Create Owner dummy
gen prova=strpos(role, "founder")
gen prova2=strpos(role, "founding")
gen prova3=strpos(role, "owner")
gen owner=0
replace owner=1 if prova>0 | prova2>0 |  prova3>0 & strpos(role, "assistant")==0
drop prova*
lab var owner "1 if founder founding or owner 0 otherwise"

*Create Partner dummy
gen prova=strpos(role, "partner")
gen partner=0
replace partner=1 if prova>0 & strpos(role, "assistant")==0
drop prova*
lab var partner "1 if partner 0 otherwise"

*Create Director dummy
gen prova=strpos(role, "director")
gen director=0
replace director=1 if prova>0 & strpos(role, "assistant")==0
drop prova*
lab var director "1 if director 0 otherwise"

*Create VP dummy
gen prova=strpos(role, "senior vp")
gen prova2=strpos(role, "vice president")
gen vp=0
replace vp=1 if prova>0 | prova2>0 & strpos(role, "assistant")==0
drop prova*
lab var vp "1 if senior vp or vp 0 otherwise"

*Create General Manager dummy
gen prova=strpos(role, "general manager") 
gen gm=0
replace gm=1 if prova>0 & strpos(role, "assistant")==0
drop prova
lab var gm "1 if general manager 0 otherwise"

*Create Consultant dummy
gen prova=strpos(role, "consultant") 
gen consultant=0
replace consultant=1 if prova>0
drop prova
lab var consultant "1 if consultant 0 otherwise"


rename startdate2 yearrole1
rename enddate2 yearrole2

* Delete observations without both beginning and ending date
drop if yearrole1==. & yearrole2==. 

* Set the beginning date equal to the ending date when we have only the ending date available and viceversa
replace yearrole1=yearrole2 if yearrole1==. /* I set the beginning date equal to the ending date when we have the second and viceversa*/
replace yearrole2=yearrole1 if yearrole2==. /* I'll have only an observation in the year where I have the information */

*Drop variables that are not of interest
drop  companyisin companyindex sectorname companytype ednedsm startdate enddate

*Create an identifier for each observation, where an observation is in wide form and represents an individual work experience for a specific company for the period that starts in startdate and finishes in enddate */
gen id=_n

/*Reshape to long form in order to have a panel*/
reshape long year, i(id) j(yearrole, string) 

sort id year

*Drop duplicated observations
duplicates drop id year, force 
tsset id year
tsfill

*Carryforward the relevant variables that were originally reported in wide form 
by id: carryforward directorid country companyid companyname role roledescription ednedsm2 companytype2 ceo cfo chair coo professor ///
owner partner director vp gm consultant , replace

drop  id yearrole 


save "outcome/region_boardexother", replace


/********************************************************************************
*In your "outcome" folder, after your run this code for each of the above 5 regions (EU, UK, NA, NA-SM,and ROW) you should have the following files:
eu_boardexother
uk_boardexother
na_boardexother
sm_boardexother
row_boardexother
********************************************************************************/

*Aggregate the above files 

cd "outcome"
use eu_boardexother, clear
append using uk_boardexother
append using row_boardexother
append using na_boardexother
append using sm_boardexother

sort directorid companyid year 

*Generate a a variable to capture the first year an individual shows up in BoardEx
by directorid: egen firstyear=min(year)
sort directorid companyid year

*Drop duplicated observations
duplicates drop directorid companyid year, force 
save "outcome/global_other", replace /* Formerly euukother */




/********************************************************************************
********************************************************************************

*STEP 3 - Clean Individuals' profiles using Profile.csv

Run this code for each of the BoardEx regions separately:
1- Europe (EU)
2- United Kingdom (UK)
3- North America (directors) (NA)
4- North America (senior managers) (SME)
5- Rest of the World (ROW)

********************************************************************************
********************************************************************************/

*Set as directory the folder where you have saved the original data downloaded from BoardEx
cd "original files/region"


insheet using Profile.csv, delimiter(,) clear
format directorid %14.0g

*Create dat of birth year
gen dobyear = regexs(0) if regexm(dob, "[0-9]*$")

replace dobyear = "20"+regexs(0) if regexm(dobyear, "^[0-1][0-9]$")
replace dobyear = "19"+regexs(0) if regexm(dobyear, "^[2-9][0-9]$")
destring dobyear, replace 


replace age="" if age=="n.a"
destring age, replace 

destring year, replace ignore("Current")
replace year=2014 if year==.
replace dobyear=(year-age) if dobyear==. & age!=.

gen dodyear = regexs(0) if regexm(dod, "[0-9]*$")
replace dodyear = "20"+regexs(0) if regexm(dodyear, "^[0-1][0-9]$")
replace dodyear = "19"+regexs(0) if regexm(dodyear, "^[2-9][0-9]$")
destring dodyear, replace 

*Create gender variable, where 1 identifies females
gen gender2=0
replace gender2=1 if gender=="F"
rename gender2 gender
lab var gender "0 Male 1 Female"

*Clean variables of interst
destring nbdshistoquoted, replace ignore("n.a")
destring nbdshistoprivate, replace ignore("n.a")
destring nbdshistother, replace ignore("n.a")
destring nbdscurrentquoted, replace ignore("n.a")
destring nbdscurrentprivate, replace ignore("n.a")
destring nbdscurrentother, replace ignore("n.a")
destring avgyearsbdsquoted, replace ignore("n.a")

*Generate European nationality dummy
gen eu=0
replace eu=1 if nationality=="Austrian" | nationality=="Belgian" | nationality=="British" | nationality=="Bulgarian" ///
| nationality=="Croatian" | nationality=="Cypriot" | nationality=="Czech" | nationality=="Danish" | nationality=="Dutch" ///
| nationality=="Estonian" | nationality=="Finnish" | nationality=="French" | nationality=="German" | nationality=="Greek" ///
| nationality=="Hungarian" | nationality=="Irish" | nationality=="Italian" | nationality=="Lithuanian" | nationality=="Luxembourger" ///
| nationality=="Maltese" | nationality=="Polish" | nationality=="Portuguese" | nationality=="Romanian" | nationality=="Slovak" ///
| nationality=="Slovene" | nationality=="Spanish" | nationality=="Swedish" 

*Genrate American nationality dummy
gen american=0
replace american=1 if nationality=="American"

*Generate dummies for different nationalities
gen belgian=0
replace belgian=1 if nationality=="Belgian"

gen british=0
replace british=1 if nationality=="British"

gen danish=0
replace danish=1 if nationality=="Danish"

gen dutch=0
replace dutch=1 if nationality=="Dutch"

gen finnish=0
replace finnish=1 if nationality=="Finnish"

gen french=0
replace french=1 if nationality=="French"

gen german=0
replace german=1 if nationality=="German"

gen irish=0
replace irish=1 if nationality=="Irish"

gen italian=0
replace italian=1 if nationality=="Italian"

gen norwegian=0
replace norwegian=1 if nationality=="Norwegian"

gen portuguese=0
replace portuguese=1 if nationality=="Portuguese"

gen swiss=0
replace swiss=1 if nationality=="Swiss"

gen swedish=0
replace swedish=1 if nationality=="Swedish"

gen spanish=0
replace spanish=1 if nationality=="Spanish"

drop age dob dod gender avgyearsbdsquoted

move gender nationality

save "outcome/region_profile", replace


/********************************************************************************
*In your "outcome" folder, after your run this code for each of the above 5 regions (EU, UK, NA, NA-SM,and ROW) you should have the following files:
eu_profile
uk_profile
na_profile
sm_profile
row_profile
********************************************************************************/

*Aggregate the above files 

cd "outcome"

use eu_profile, clear 
append using uk_profile
append using row_profile
append using na_profile
append using sm_profile

*Drop duplicated observations
duplicates drop directorid, force

*Drop non relevant variables
drop  year- nbdscurrentother
save "outcome/global_profile", replace /* Formerly euukprofile */




/********************************************************************************
********************************************************************************

*STEP 4 - Clean Network Files 

Each region has a different number of network files. At the time we received the data we had:
Europe: 31 files
UK: 32 files
NA: 109 files 
NA-SM: 169 files 
ROW: 34 files  

Run this code for each of the BoardEx regions separately:
1- Europe (EU)
2- United Kingdom (UK)
3- North America (directors) (NA)
4- North America (senior managers) (SME)
5- Rest of the World (ROW)

********************************************************************************
********************************************************************************/
*Set as directory the folder where you have saved the original data downloaded from BoardEx
cd "original files/region"


*Create a loop to open each file separately and clean the information. In this code, we use as a range 1 and 31, given that 31 was the number of files we recevied for Europe  
forvalues i = 1(1)31 {
insheet using region_`i'.csv, delimiter(,) clear

*Clean relevant variables
destring directorid, replace 
format directorid %14.0g

destring linkeddirectorid, replace 
format linkeddirectorid %14.0g

destring connectedcompanyid, replace 
format connectedcompanyid %14.0g

*Drop observations where directorid is missing
drop if directorid==.

drop connectedcompany

*Generate variable to identify the company type
gen companytype=0
replace companytype=1 if connectedcompanytype=="Private"
replace companytype=2 if connectedcompanytype=="Quoted"
label var companytype "0 other, 1 Private, 2 Public"

*We keep only networks of public companies
keep if companytype==2 

*Drop non-relevant variables
drop connectedcompanytype index sector dateofoverlap

*Set the starting date for each director-director connection  
gen year1= regexs(0) if regexm(beginningofoverlap, "[0-9]*$")
replace year1= "20"+regexs(0) if regexm(year1, "^[0-1][0-9]$")
replace year1= "19"+regexs(0) if regexm(year1, "^[2-9][0-9]$")
destring year1, replace 

*Set the ending date for each director-director connection 
gen year2= regexs(0) if regexm(endofoverlap, "[0-9]*$")
replace year2= "20"+regexs(0) if regexm(year2, "^[0-1][0-9]$")
replace year2= "19"+regexs(0) if regexm(year2, "^[2-9][0-9]$")
destring year2, replace 
*We set ending date equal to 2014 for those observations that were current at the time we received the data (December 2014)
replace year2=2014 if endofoverlap=="Current"

drop beginningofoverlap endofoverlap

*Create variable to identify the role of the director 
gen roledirector=0
replace roledirector=1 if n=="NED"
replace roledirector=2 if n=="ED"
label var roledirector "0 if other, 1 if non-executive, 2 if executive"

*Create variable to identify the role of the linked director 
gen rolelinked=0
replace rolelinked=1 if ednedsm=="NED"
replace rolelinked=2 if ednedsm=="ED"
label var rolelinked "0 if other, 1 if non-executive, 2 if executive"

drop overlappingpersonsroletitle ednedsm individualsroletitle n

*Create an identifier for each observation, where an observation is in wide form and represents a company-director-linked director  */
gen id=_n 

/*Reshape to long form in order to have a panel*/
reshape long year, i(id) j(yeartie) /*By reshaping I obtain for each id the beginning date of the connection and the ending date*/

* Drop Duplicated observations 
duplicates drop id year, force 
tsset id year
tsfill

*Carryforward the relevant variables that were originally reported in wide form 
by id: carryforward directorid  linkeddirectorid connectedcompanyid companytype roledirector rolelinked, replace

*Drop non relevant variables
drop  id yeartie
sort  directorid year linkeddirectorid connectedcompanyid

* Drop company-director-linked director duplicated observations 
duplicates drop directorid year linkeddirectorid connectedcompanyid, force
keep if  companytype!=0 
rename connectedcompanyid companyid

save "temp/region_`i'", replace
clear
}

*Append all the network files for each region. In this code 31 represents the number of network files we received for Europe
use "temp/region_1"
forvalues i = 2(1)31 {
append using "temp/region_`i'"
}

sort  directorid year linkeddirectorid companyid
move  roledirector rolelinked
save "outcome/region_network", replace


/********************************************************************************
*In your "outcome" folder, after your run this code for each of the above 5 regions (EU, UK, NA, NA-SM,and ROW) you should have the following files:
eu_network
uk_network
na_network
sm_network
row_network
********************************************************************************/

*Aggregate the above files 

cd "outcome"

use eu_network, clear
append using uk_network
append using row_network
append using na_network
append using sm_network

*Drop duplicated company-year-director-linked director observations
duplicates drop companyid year directorid linkeddirectorid , force 

*Double check that there are no duplicates in the company-year-director-linked director observations
clonevar director1=directorid
clonevar director2=linkeddirectorid 
replace director1=linkeddirectorid if linkeddirectorid<directorid 
replace director2=directorid if linkeddirectorid<directorid
format director1 %14.0g
format director2 %14.0g
sort companyid year director1 director2 
duplicates drop director1 director2 companyid year, force 

drop director1 director2
save "outcome/global_network", replace /* Formerly globalnetwork_2019 */



/********************************************************************************
********************************************************************************

*STEP 5 - Clean Companies' profiles 


********************************************************************************
********************************************************************************/


*Set as directory the folder where you have saved the original data downloaded from BoardEx
*Import European companies
cd "original files"
import excel using Europe-Company-Details.xlsx, firstrow clear

*Import North America companies
preserve
import excel using NA-Company-Details.xlsx, firstrow clear
save "temp/temp_files", replace
restore

append using "temp/temp_files", force

*Import Rest of the World companies 
preserve
import excel using ROW-Company-Details.xlsx, firstrow clear
save "temp/temp_files", replace
restore
append using "temp/temp_files", force

*Import UK companies 
preserve
import excel using UK-Company-Details.xlsx, firstrow clear
save "temp/temp_files", replace
restore
append using "temp/temp_files", force

rename CompanyID companyid
format companyid %14.0g

keep companyid CompanyName  HOCountryName Sector
rename HOCountryName country
rename CompanyName companyname
rename Sector sector

*Drop duplicated observations
duplicates drop companyid, force 
save "outcome/companylist", replace /* Formerly companylist_201907 */


/********************************************************************************

*STEP 6 - Cleaning institutional quality factors received by prof. Karolyi 

********************************************************************************/


*Elaborating institutional quality factor from Karolyi (2016)
insheet using "temp/karoly_oct2018.csv", delimiter(,) names clear
* Reshape to long form in order to have a panel
reshape long year_, i(countrycode1 institutionalquality) j(year)
save "temp/temp_instquality", replace

* Clean the six dimensions of institutional quality
use "temp/temp_instquality", clear
keep if institutionalquality=="Corporate Opacity"
rename year_ corp_opacity
drop institutionalquality
save "temp/temp_instquality1", replace

use "temp/temp_instquality", clear
keep if institutionalquality=="Foreign Accessibility"
rename year_ for_access
drop institutionalquality
save "temp/temp_instquality2", replace

use "temp/temp_instquality", clear
keep if institutionalquality=="Investor Protection"
rename year_ investor_prot
drop institutionalquality
save "temp/temp_instquality3", replace

use "temp/temp_instquality", clear
keep if institutionalquality=="Market Capacity"
rename year_ mkt_capacity
drop institutionalquality
save "temp/temp_instquality4", replace

use "temp/temp_instquality", clear
keep if institutionalquality=="Operational Inefficiency"
rename year_ operat_ineffic
drop institutionalquality
save "temp/temp_instquality5", replace

use "temp/temp_instquality", clear
keep if institutionalquality=="Poltical Instability"
rename year_ political_instab
drop institutionalquality

*Merge back the temporary datasets that contains the each of the dimensions of institutional quality 
merge 1:1 countrycode1 year using "temp/temp_instquality1"
keep if _merge==3
drop _merge

merge 1:1 countrycode1 year using "temp/temp_instquality2"
keep if _merge==3
drop _merge

merge 1:1 countrycode1 year using "temp/temp_instquality3"
keep if _merge==3
drop _merge

merge 1:1 countrycode1 year using "temp/temp_instquality4"
keep if _merge==3
drop _merge

merge 1:1 countrycode1 year using "temp/temp_instquality5"
keep if _merge==3
drop _merge

*Calculate the mean for each of the dimensions of institutional quality
collapse (mean) political_instab-operat_ineffic, by(countrycode1)

factor political_instab-operat_ineffic, factors(1) pcf
rotate
predict instit_qual

egen qrt_inst_qual=xtile(instit_qual), nq(4)

clonevar countrycode2=countrycode1
order countrycode1 countrycode2 

rename qrt_inst_qual qrt_inst_qual1
clonevar qrt_inst_qual2=qrt_inst_qual1

g lowgov1=0
replace lowgov1=1 if qrt_inst_qual1==1 | qrt_inst_qual1==2

g lowgov2=0
replace lowgov2=1 if qrt_inst_qual2==1 | qrt_inst_qual2==2

g highgov1=0
replace highgov1=1 if qrt_inst_qual1==4 | qrt_inst_qual1==3

g highgov2=0
replace highgov2=1 if qrt_inst_qual2==4 | qrt_inst_qual2==3

foreach var of varlist political_instab-operat_ineffic instit_qual {
rename `var' `var'1
clonevar `var'2=`var'1
		}

sort countrycode1
	
save "outcome/instquality", replace


/********************************************************************************

*STEP 7 - Elaborating reporting proximity measure from Francis et al. (2015)

********************************************************************************/


use "temp/gaap_similarity", clear
replace countrycode1="SGP" if countrycode1=="SIN"
replace countrycode2="SGP" if countrycode2=="SIN"
preserve
rename countrycode1 pietro 
rename countrycode2 countrycode1
rename pietro countrycode2
order countrycode1 countrycode2
save "temp/temp_file", replace
restore

order countrycode1 countrycode2
append using "temp/temp_file"
sort countrycode1 countrycode2
duplicates drop countrycode1 countrycode2, force 
drop if countrycode1==countrycode2
save "outcome/francisjune25", replace


/********************************************************************************

*STEP 8 - Clean announcement database for analyses in Table 10

********************************************************************************/

*Cleaning announcement database
*Import European companies
cd "original files"
import excel using Europe-Company-Announcements.xlsx, first all case(lower) clear


preserve
import excel using Europe-SMDE-Announcements.xlsx, first all case(lower) clear
save "temp/temp_file", replace
restore

append using "temp/temp_file"

*Import UK companies

preserve
import excel using UK-Company-Announcements.xlsx, first all case(lower) clear
save "temp/temp_file", replace
restore

append using "temp/temp_file"

preserve
import excel using UK-SMDE-CompanyAnnouncements.xlsx, first all case(lower) clear
save "temp/temp_file", replace
restore

append using "temp/temp_file"

*Import North America companies
preserve
import excel using NA-Company-Announcements.xlsx, first all case(lower) clear
save "temp/temp_file", replace
restore
append using "temp/temp_file"

preserve
import excel using NA-SMDE-Announcements.xlsx, first all case(lower) clear
save "temp/temp_file", replace
restore
append using "temp/temp_file"


*Import Rest of the World companies
preserve
import excel using ROW-SMDE-Announcements.xlsx, first all case(lower) clear
save "temp/temp_file", replace
restore
append using "temp/temp_file"


preserve
import excel using ROW-Company-Announcements.xlsx, first all case(lower) clear
save "temp/temp_file", replace
restore
append using "temp/temp_file"

*Format director and company id
destring directorid, replace
format directorid %14.0g
destring companyid, replace
format companyid %14.0g

*Generate variable to identify the year the turnover occured
gen yearchange = regexs(0) if regexm(effectivedate, "[0-9]*$")

replace yearchange = "20"+regexs(0) if regexm(yearchange, "^[0-1][0-9]$")
replace yearchange = "19"+regexs(0) if regexm(yearchange, "^[2-9][0-9]$")
destring yearchange, replace 
rename yearchange year

replace description=lower(description)
replace role=lower(role)

*Generate new appointment and turnover
g newappoint=0
replace newappoint=1 if strpos(description, "join")>0 & strpos(description, "board")>0 

g independent=0
replace independent=1 if strpos(role, "independ")>0 | strpos(description, "ned")>0 

gen turnover=0
replace turnover=1 if strpos(description, "leave")>0 & strpos(description, "board")>0 


sort companyid directorid year companyid
keep if newappoint==1 | turnover==1

preserve
keep companyid directorid year newappoint independent turnover announcementdate
duplicates drop
sort companyid directorid year

save "outcome/announcement", replace
/*******************************************************************************
							Barrios, Bianchi, Isidro, and Nanda 2022
 Boards of a Feather: Homophily in Foreign Director Appointments Around the World
 

This code is for STATA Parallel 16.1 Edition  


This code is ment to build the working dataset for the analysis using the outputs 
from running 01_Clean_Raw_Data_BBIN_2022.do. 

*******************************************************************************/




/********************************************************************************


Merge Global Network file with (1) Employment file (board appointments) and 
(2) Non-board appointments file for both director and linked director
Note: as the Network data are at the company-director-linked director level, 
you need to merge information about board and non-board experience for both director and linked director

********************************************************************************/

use "outcome/global_network", clear
sort directorid companyid year 

*Merge "outcome/global_employment" file relative to director-company
merge m:1 directorid companyid year using "outcome/global_employment", keepusing(ceo cfo chair firstyear) 
drop if _merge==2 
drop _merge

*Merge "outcome/region_boardexother" file relative to director-company
merge m:1 directorid companyid year using "outcome/global_other", keepusing(ceo cfo chair firstyear) update 
drop if _merge==2
drop _merge

*Merge "outcome/global_employment" file relative to linked director-company
rename directorid director1
rename linkeddirector directorid
rename ceo ceo1
rename cfo cfo1
rename chair chair1
rename firstyear firstyear1
sort directorid companyid year
merge m:1 directorid companyid year using "outcome/global_employment", keepusing(country ceo cfo chair firstyear)
drop if _merge==2
drop _merge

*Merge "outcome/region_boardexother" file relative to linked director-company
merge m:1 directorid companyid year using "outcome/global_other", keepusing(country ceo cfo chair firstyear) update
drop if _merge==2
drop _merge
rename ceo ceo2
rename cfo cfo2
rename chair chair2
rename firstyear firstyear2
rename directorid linkeddirectorid
rename director1 directorid


*Drop senior managers who are not CEO, CFO or chair (Email received from from BoardEx representative on March 24, 2015 clarifying this point)
drop if roledirector==0 & (ceo1==0 & cfo1==0 & chair1==0)
*Drop observations where we do not have information about both director and linked director
drop if roledirector==0 & (ceo1==. & cfo1==. & chair1==.) 
drop if rolelinked ==0 & (ceo2==0 & cfo2==0 & chair2==0) 
drop if rolelinked ==0 & (ceo2==. & cfo2==. & chair2==.) 



*Merge with company details to obtain informaiton about country where a company is located

merge m:1 companyid using "outcome/companylist", keepusing(country) update
drop if _merge==2
drop _merge

*Drop observations where country is missing
drop if country=="" 

******************************************************************************

*Merge with director profile data to obtain nationality for both director and linked director

******************************************************************************

*Merge "outcome/global_profile" file relative to director
sort directorid
merge m:1 directorid using "outcome/global_profile", keepusing(gender nationality eu american)
drop if _merge==2
drop _merge


*Merge "outcome/global_profile" file relative to linked director
rename directorid director1
rename linkeddirector directorid
rename gender gender1
rename nationality nationality1
rename eu eu1
rename american american1

sort directorid
merge m:1 directorid using "outcome/global_profile", keepusing(gender nationality eu american)
drop if _merge==2
drop _merge
rename directorid linkeddirectorid
rename director1 directorid
rename gender gender2
rename nationality nationality2
rename eu eu2
rename american american2

*Drop missing observations 
drop if ceo1==. & nationality1=="" 
drop if ceo2==. & nationality2=="" 

*Create board size
preserve
sort companyid year directorid
duplicates drop companyid year directorid, force
by companyid year: gen ndirector=_N /*Board size*/
duplicates drop companyid year, force
save "temp/ndirector", replace
restore

sort companyid year
merge m:1 companyid year using "temp/ndirector", keepusing(ndirector)
drop _merge


*Generate dummy to identify European companies
gen europe=0
replace europe=1 if country=="Austria" |country=="Belgium" | country=="Bulgaria"	| country=="Croatia" ///
| country=="Cyprus" | country=="Czech Republic" | country=="Denmark" | country=="Estonia" | country=="Finland" ///
| country=="France" | country=="Germany" | country=="Greece" | country=="Italy" | country=="Lithuania" ///
| country=="Luxembourg" | country=="Malta" | country=="Norway" | country=="Netherlands" | country=="Poland" | country=="Portugal" ///
| country=="Republic Of Ireland" | country=="Romania" | country=="Slovakia" | country=="Slovenia" | country=="Spain" ///
| country=="Sweden" | country=="Switzerland" | country=="Liechtenstein" | country=="Monaco"

*Generate dummy to identify UK companies
gen uk=0
replace uk=1 if strpos(country, "United Kingdom") | strpos(country, "British")

*Generate dummy to identify US companies
gen us=0
replace us=1 if country=="United States"
save "temp/global_network2", replace

*Start sample from 2000
keep if year>=2000

*Generate variable to capture number of directors per country-year
egen countryobs=group(country year)

preserve
duplicates drop countryobs directorid, force
bysort  countryobs: gen directors=_N
duplicates drop countryobs, force
keep countryobs directors
save "temp/countrydirector", replace
restore

sort countryobs
merge m:1 countryobs using "temp/countrydirector"
drop _merge

*Generate variable to capture number of companies per country-year
preserve
duplicates drop countryobs companyid, force
bysort  countryobs: gen ncompanies=_N
duplicates drop countryobs, force
keep countryobs ncompanies
save "temp/countrycompanies", replace
restore

sort countryobs
merge m:1 countryobs using "temp/countrycompanies"
drop _merge

replace country="United Kingdom" if strpos(country, "United Kingdom")>0

*Merge with "BBIN-2022/countrylevel" (available with this code) to obtain country codes
sort country
merge m:1 country using "BBIN-2022/countrylevel" 
drop if _merge==2
drop _merge

move country  rolelinked
move countrycode rolelinked
bysort country: egen maxcompany=max(ncompanies)

replace countrycode="KOR" if strpos(country, "Korea")>0 /* Note: North Korea is not covered in BoardEx, only South Korea*/

* Restrict the analysis to list of countries from Leuz, Nanda, Wysocki (JFE 2003)

keep if countrycode=="AUS" | countrycode=="AUT" | countrycode=="BEL" | countrycode=="BRA" | countrycode=="CAN" ///
| countrycode=="CHN" | countrycode=="DNK" | countrycode=="FIN" | countrycode=="FRA" | countrycode=="DEU" ///
| countrycode=="GRC" | countrycode=="HKG" | countrycode=="IND" | countrycode=="ISR" | countrycode=="ITA" ///
| countrycode=="JPN" | countrycode=="KOR" | countrycode=="LUX" | countrycode=="MYS" ///
| countrycode=="MEX" | countrycode=="NLD" | countrycode=="NZL" | countrycode=="NOR" ///
| countrycode=="PHL" | countrycode=="POL" | countrycode=="PRT" | countrycode=="IRL" | countrycode=="RUS" ///
| countrycode=="SGP" | countrycode=="ZAF" | countrycode=="ESP" | countrycode=="SWE" | countrycode=="CHE" ///
| countrycode=="TWN" | countrycode=="THA" | countrycode=="GBR" | countrycode=="USA" | countrycode=="TUR" ///
| countrycode=="IDN" 

*Drop observations for companies for which there is no information in "outcome/global_employment"
drop if companyid==8173180
drop if companyid==19773366
drop if companyid==89436837
drop if companyid==177195804
drop if companyid==188346955
drop if companyid==407705304
drop if companyid==2622212418
drop if companyid==5991629984
drop if companyid==12822325900
drop if companyid==16505529731
drop if companyid==16710289906
drop if companyid==173117410406
drop if companyid==173261810415
drop if companyid==176772010702

drop countryobs
egen countryobs=group(country year)


save "temp/global_network3", replace 

/********************************************************************************

* Identify directors' domicile as described one page 1299 of BBIN (2022)
STEP 1: use nationality in BoardEx

********************************************************************************/

cd "/Users/pietrobianchi/Dropbox/1 Reseach/Foreign Directors - Follow up/Stata Code/october2022"
use "temp/global_network3", clear

*Keep relevant variables for the analysis
keep directorid linkeddirectorid companyid year country countrycode roledirector rolelinked ceo1 cfo1 chair1 ceo2 cfo2 chair2

*Double check there are no duplicates
duplicates drop directorid linkeddirector companyid year, force /* no obs deleted*/

*Generate number of directors between countries  (nlinks)
sort countrycode year
by countrycode year: gen nlinks=_N

/*******************************************************************************

*NOTE: Data are presented in the dyadic form director-linked director at the company-year level. 
Double check that there are no missing linked director-director dyads. To this end you need to append the 
linked director-director dyads to the original director-linked director dyads and drop duplicated observations (if any).
 
*******************************************************************************/

preserve
rename directorid green
rename linkeddirectorid directorid
rename green linkeddirectorid
move directorid linkeddirectorid
rename roledirector alfa
rename ceo1 alfa2
rename cfo1 alfa3
rename chair1 alfa4
rename rolelinked roledirector
rename ceo2 ceo1
rename cfo2 cfo1
rename chair2 chair1

rename alfa rolelinked
rename alfa2 ceo2 
rename alfa3 cfo2 
rename alfa4 chair2 
move ceo1 ceo2
move cfo1 ceo2
move chair1 ceo2
save "temp/globalnetwork3a", replace
restore

append using "temp/globalnetwork3a"

*Drop duplicated observations 
duplicates drop directorid linkeddirector companyid year, force

*Save dataset that contains director-company information
preserve
save "temp/globalnetwork3b", replace 
restore

*Create a dataset that contains information about directors in our final sample 
duplicates drop directorid, force
keep directorid
sort directorid
merge m:1 directorid using "outcome/global_profile", keepusing(dobyear gender nationality) 
keep if _merge==3 
drop _merge
g temp=1
save "temp/temp_file_global", replace

/********************************************************************************

* Identify directors' domicile
* STEP 2 - Use country of first employment in BoardEx as a proxy for director domicile 
when nationality is not reported in BoardEx

********************************************************************************/

* Use "outcome/global_employment" and  merge it with "temp/temp_file_global"
use "outcome/global_employment", clear
merge m:1 directorid using "temp/temp_file_global"
keep if _merge==3
drop _merge
save "temp/temp_empl", replace

* Use "outcome/global_other" and  merge it with "temp/temp_file_global"
use using "outcome/global_other", clear
merge m:1 directorid using "temp/temp_file_global"
keep if _merge==3
drop _merge
save "temp/temp_other", replace

use "temp/temp_empl", clear
append using "temp/temp_other"

*Use information for Public and Private companies.
drop if companytype==0

*Drop non relevant variables
drop companyname companyisin role-consultant

*Drop duplicated observations
duplicates drop directorid companyid year, force 

*Fix some inconsistencies in the name reported by BoardEx for United Kingdom and South Korea (i.e., Korea) 
replace country="United Kingdom" if strpos(country, "United Kingdom")>0
replace country="Korea" if strpos(country, "Korea")>0

*Merge with "BBIN-2022/countrylevel" (available with this code) to obtain country codes
sort country
merge m:1 country using "/Users/pietrobianchi/Dropbox/1 Reseach/02 - Boardex and LinkedIn/01-JAR/countrylevel" 
keep if _merge==3
drop _merge

replace countrycode="KOR" if strpos(country, "Korea")>0

/*******************************************************************************

Drop  variable firstyear that was previously calculated. To identify the country  
where a director was first employed (and reported in BoardEx) we need to generate 
two variables for directors in our sample:
firstyear: the year a director shows up in BoardEx for the first time
firstyearfirm: year a director starts working for a company as reported in BoardEx

*******************************************************************************/
drop firstyear
bysort directorid: egen firstyear=min(year)
bysort directorid companyid: egen firstyearfirm=min(year)

*Create dataset that contains director-company observations 
preserve
duplicates drop directorid companyid, force
keep directorid companyid firstyearfirm firstyear
sort directorid
save "outcome/director_firstyear", replace
restore

*Keep observations for the first year a director is reported in BoardEx 
keep if year==firstyear

*Drop observations where country of the company is missing
drop if country=="Unknown"

*Calculate number of appointments by country 
bysort directorid country: g nappointm=_N
gsort directorid country -companytype2 -ceo -cfo

*Keep one observation per director-country
duplicates drop directorid country, force

*Calculate number of countries a director works in the first year the director is reported in BoardEx
bysort directorid: g ncountries=_N

/*******************************************************************************

For those directors that have appointments in multiple countries in their first year reported in BoardEx, 
drop director-country observations if a director has appointments only in private companies

*******************************************************************************/
drop if (ncountries>1 & companytype<2)
drop nappointm ncountries

*Calculate number of countries a director has appointments in  
bysort directorid: g ncountries=_N

*Code nationality
gen nationality_code=""
replace nationality_code="AUS" if nationality=="Australian"
replace nationality_code="AUT" if nationality=="Austrian"
replace nationality_code="BEL" if nationality=="Belgian"
replace nationality_code="BRA" if nationality=="Brazilian"
replace nationality_code="CAN" if nationality=="Canadian"
replace nationality_code="CHN" if nationality=="Chinese"
replace nationality_code="DNK" if nationality=="Danish"
replace nationality_code="FIN" if nationality=="Finnish"
replace nationality_code="FRA" if nationality=="French"
replace nationality_code="DEU" if nationality=="German"
replace nationality_code="GRC" if nationality=="Greek"
replace nationality_code="IND" if nationality=="Indian"
replace nationality_code="IDN" if nationality=="Indonesian"
replace nationality_code="ISR" if nationality=="Israeli"
replace nationality_code="ITA" if nationality=="Italian"
replace nationality_code="JPN" if nationality=="Japanese"
replace nationality_code="KOR" if nationality=="South Korean"
replace nationality_code="LUX" if nationality=="Luxembourger"
replace nationality_code="MYS" if nationality=="Malaysian"
replace nationality_code="MEX" if nationality=="Mexican"
replace nationality_code="NZL" if nationality=="New Zealander"
replace nationality_code="NLD" if nationality=="Dutch"
replace nationality_code="NOR" if nationality=="Norwegian"
replace nationality_code="PHL" if nationality=="Filipino"
replace nationality_code="POL" if nationality=="Polish"
replace nationality_code="PRT" if nationality=="Portuguese"
replace nationality_code="IRL" if nationality=="Irish"
replace nationality_code="RUS" if nationality=="Russian"
replace nationality_code="SGP" if nationality=="Singaporean"
replace nationality_code="ZAF" if nationality=="South African"
replace nationality_code="ESP" if nationality=="Spanish"
replace nationality_code="SWE" if nationality=="Swedish"
replace nationality_code="CHE" if nationality=="Swiss"
replace nationality_code="TWN" if nationality=="Taiwanese"
replace nationality_code="THA" if nationality=="Thai"
replace nationality_code="TUR" if nationality=="Turkish"
replace nationality_code="GBR" if nationality=="British"
replace nationality_code="USA" if nationality=="American"

* Generate a variable to capture the country where a director had her first appointment (as reported in BoardEx)
g firstcountry_code=""

* For most of the observations, directors have appointments in one country.
replace firstcountry_code=countrycode if ncountries==1

* There are instances of directors with multiple appointments in their first year reported in BoardEx
* If one of these countries corresponds to the country of the director's nationality, then use this as reference
replace firstcountry_code=nationality_code if ncountries>1 & nationality!="Unknown"

duplicates drop directorid, force
keep directorid firstcountry_code 

* Drop observations when the country of first apppointment is not available (i.e., 
* a director has appointments in multiple countries but neither one corresponds to her nationality, nor nationality is available
drop if firstcountry_code=="" 

* Save dataset that contains information about the country of first appointment 
save "outcome/firstcountry", replace 

/********************************************************************************

* Identify directors' domicile
* STEP 3 - Combine STEP 1 and STEP 2

********************************************************************************/

* Use the dataset you created before
use "temp/globalnetwork3b", clear 

duplicates drop directorid, force
keep directorid
sort directorid

*Merge with "outcome/global_profile" to obtain information about nationality
merge m:1 directorid using "outcome/global_profile", keepusing(dobyear gender nationality) /*Merging with profile data*/

*Drop observations for directors whose profiels in BoardEx are missing 
keep if _merge==3 
drop _merge

*Generate a variable for nationality_code
gen nationality_code=""
replace nationality_code="AUS" if nationality=="Australian"
replace nationality_code="AUT" if nationality=="Austrian"
replace nationality_code="BEL" if nationality=="Belgian"
replace nationality_code="BRA" if nationality=="Brazilian"
replace nationality_code="CAN" if nationality=="Canadian"
replace nationality_code="CHN" if nationality=="Chinese"
replace nationality_code="DNK" if nationality=="Danish"
replace nationality_code="FIN" if nationality=="Finnish"
replace nationality_code="FRA" if nationality=="French"
replace nationality_code="DEU" if nationality=="German"
replace nationality_code="GRC" if nationality=="Greek"
replace nationality_code="IND" if nationality=="Indian"
replace nationality_code="IDN" if nationality=="Indonesian"
replace nationality_code="ISR" if nationality=="Israeli"
replace nationality_code="ITA" if nationality=="Italian"
replace nationality_code="JPN" if nationality=="Japanese"
replace nationality_code="KOR" if nationality=="South Korean"
replace nationality_code="LUX" if nationality=="Luxembourger"
replace nationality_code="MYS" if nationality=="Malaysian"
replace nationality_code="MEX" if nationality=="Mexican"
replace nationality_code="NZL" if nationality=="New Zealander"
replace nationality_code="NLD" if nationality=="Dutch"
replace nationality_code="NOR" if nationality=="Norwegian"
replace nationality_code="PHL" if nationality=="Filipino"
replace nationality_code="POL" if nationality=="Polish"
replace nationality_code="PRT" if nationality=="Portuguese"
replace nationality_code="IRL" if nationality=="Irish"
replace nationality_code="RUS" if nationality=="Russian"
replace nationality_code="SGP" if nationality=="Singaporean"
replace nationality_code="ZAF" if nationality=="South African"
replace nationality_code="ESP" if nationality=="Spanish"
replace nationality_code="SWE" if nationality=="Swedish"
replace nationality_code="CHE" if nationality=="Swiss"
replace nationality_code="TWN" if nationality=="Taiwanese"
replace nationality_code="THA" if nationality=="Thai"
replace nationality_code="TUR" if nationality=="Turkish"
replace nationality_code="GBR" if nationality=="British"
replace nationality_code="USA" if nationality=="American"

*Merge with "outcome/firstcountry"
merge 1:1 directorid using "outcome/firstcountry"
drop _merge

*Drop observations if both nationality and country of first appointment are missing
drop if nationality_code=="" & firstcountry_code=="" 

*Save a datset that contains information for each director about nationality and country of first appointment
save "outcome/directorcountry", replace 


/********************************************************************************

**Generate number of foreign directors by country pairs

********************************************************************************/

* Use the dataset you created before
use "temp/globalnetwork3b", clear 

*Move from director-linked director-company year level to director-company year level
duplicates drop companyid directorid year, force
drop linkeddirectorid rolelinked ceo2 cfo2 chair2 nlinks

* Generate variable to identify director's domicile (countrycode2)
preserve
use "outcome/directorcountry", clear
clonevar countrycode2=nationality_code
replace countrycode2=firstcountry_code if nationality_code==""
keep directorid countrycode2 gender /* countrycode2 is the domicile of the director*/
save "temp/temp_file", replace
restore

merge m:1 directorid using "temp/temp_file", keepusing(gender countrycode2)
keep if _merge==3
drop _merge

* Drop original variable created for domicile country of the company
drop country

* Generate variable to identify firm's domicile (countrycode1)
rename countrycode countrycode1

* Generate variable to identify domestic directors
g domestic=0
replace domestic=1 if countrycode1==countrycode2 

* Generate variable to identify foreign directors
g foreign=0 /*generate foreign director*/ 
replace foreign=1 if countrycode1!=countrycode2

* Generate variable to identify foreign independent directors
g foreign_nonex=0 
replace foreign_nonex=1 if countrycode1!=countrycode2 & roledirector==1 

* Generate variable to identify female foreign directors
g fforeign=0 
replace fforeign=1 if (gender==1 & countrycode1!=countrycode2)

* Generate variable to identify female independent foreign directors
g fforeign_nonex=0 
replace fforeign_nonex=1 if (gender==1 & countrycode1!=countrycode2 & roledirector==1) 

* Save dataset at director-firm level that contains information of the domicile of both country of the firm and country of the director
save "outcome/dir_firm_country", replace

* Move the analysis to country-pair level
collapse (sum) domestic foreign foreign_nonex fforeign fforeign_nonex, by(countrycode1 countrycode2 year)

* Save dataset at the country-pair level
save "outcome/countrypairsyear", replace

* Create variables for the number of domestic, foreign, and total directors at the country level and save this informaiton in a new dataset
use countrypairsyear, clear
collapse (sum) domestic foreign, by(countrycode1 year)
rename foreign totalforeign
rename domestic totaldomestic
g totaldirectors=totalforeign+totaldomestic
save "outcome/country_ndirectors", replace 


/********************************************************************************

** Create a matrix country-to-country for the years 2000 - 2013

********************************************************************************/

* Use the csv file that comes with the code
insheet using "BBIN-2022/matrix_countries.csv", delimiter(,) name clear
reshape long var, i(countrycode) j(countrycode2)
drop countrycode2
rename var countrycode2
drop if countrycode1==countrycode2
egen pair=group(countrycode1 countrycode2)
move pair countrycode1

forvalues i = 2000(1)2013{
gen year`i'=`i'
}

reshape long year, i(pair) j(fyear)
drop year
rename fyear year
sort  year countrycode1 countrycode2
save "outcome/matrix_countries", replace 


/********************************************************************************

** Merge data from different sources

********************************************************************************/

* Creating file for main analysis
use "outcome/matrix_countries", clear


merge 1:1 year countrycode1 countrycode2 using "outcome/countrypairsyear"
* Drop all directors who come from countries which are not in our sample
drop if _merge==2 
drop _merge


* Replace missing value to zero for country-pair observations that do not have data in BoardEx
foreach var of varlist foreign foreign_nonex fforeign fforeign_nonex { 
replace `var'=0 if `var'==.
	}

* Merge with file that contains country-pair relevant variables. This file comes with this code 
preserve
use "BBIN-2022/pair_ctr4", clear 
rename  reporteriso countrycode1
rename  partneriso countrycode2
move  countrycode1 boardex_s
move  countrycode2 boardex_s
sort year countrycode1 countrycode2

* Drop variables that are not of interest
drop  boardex_s- nrpair
save "temp/pair_ctr5", replace
restore	
	
* Merge temporary file to obtain relevant country-pair information: geographic distance, import, export, colonial relationship, legal orgin, common religion, and common border. And GDP of both countries
merge 1:1 year  countrycode1 countrycode2 using "temp/pair_ctr5", keepusing(distcap dist reportimport reportexport gdp rworldimport rworldexport colonyp colonizerp continent legal_origin comrelig border) 
keep if _merge==3 
drop _merge

* Create country-pair identifier
drop pair
gen pair= countrycode1+ countrycode2
egen pairid=group(pair)
move  pair year
move  pairid pair
sort pairid year
xtset pairid year

* Create log transformation for relevant variables 
foreach var of varlist foreign foreign_nonex dist distcap { 
gen ln`var'=ln(`var' + 1) 
	}

* Generate a few variables of interest: economic importance, total trade and its log transformation
gen ecoimportance=( reportimport+ reportexport)/ gdp
gen lntottrades=ln( reportimport+ reportexport)
gen tottrades=( reportimport+ reportexport)

* Generate legal origin and continent for directors' domicile (countrycode2) and merge it back to the original dataset
preserve
global white "continent legal_origin"
keep countrycode1 year $white
duplicates drop countrycode1 year, force

foreach x of global white {
rename `x' `x'_c2
}

rename countrycode1 countrycode2
sort countrycode2 year
save "temp/temp_files", replace
restore

sort countrycode2 year
merge m:1 countrycode2 year using "temp/temp_files"
drop _merge

sort countrycode1 countrycode2 year

* Generate common legal orgin between country of domicile of firms and directors 
gen com_leg_orig=0
replace com_leg_orig=1 if legal_origin==legal_origin_c2

gen com_continent=0
replace com_continent=1 if continent==continent_c2


* Merge dataset with variables to calculate cultural distance. This file comes with this code 
merge m:1 countrycode1 using "BBIN-2022/cltest"
drop _merge


* Generate log transformation of GDP of country of firm domicile (lngdp_r)
gen lngdp_r=ln(gdp)

* Generate log transformation of GDP of country of director domicile (lngdp_s)
preserve
keep countrycode1 year lngdp_r
sort countrycode1 year
duplicates drop countrycode1 year, force
rename countrycode1 countrycode2
rename lngdp_r lngdp_s
save "temp/temp_files", replace
restore

merge m:1 countrycode2 year using "temp/temp_files"
drop _merge



* Merge with dataset that contains cultura distance. This dataset comes with the code
preserve
use "BBIN-2022/cultural_distance", clear
rename Inghehart_cd cultural_dist
sort countrycode1 countrycode2 
save "temp/temp_file", replace
restore

merge m:1 countrycode1 countrycode2 using "temp/temp_file"
drop _merge


* Merge with dataset that contains indicator variable for IFRS adopters for country of firm domicile. This dataset comes with the code.
preserve
use "BBIN-2022/ifrs", clear
clonevar countrycode2=countrycode1
replace ifrs=0 if ifrs==.
sort countrycode1 year
save "temp/temp_file", replace
restore

sort countrycode1 year
merge m:1 countrycode1 year using "temp/temp_file", keepusing(ifrs)
drop _merge

* Merge with dataset that contains indicator variable for IFRS adopters for country of director domicile. This dataset comes with the code.
preserve
use "BBIN-2022/ifrs", clear
clonevar countrycode2=countrycode1
replace ifrs=0 if ifrs==.
sort countrycode1 year
rename ifrs ifrs2
save "temp/temp_file", replace
restore

sort countrycode2 year
merge m:1 countrycode2 year using "temp/temp_file", keepusing(ifrs2)
drop _merge

* Create indicator variable that identifies pairs of IFRS adopters 
g both_ifrs=0
replace both_ifrs=1 if ifrs==1 & ifrs2==1
		




g eu=0
replace eu=1 if countrycode1=="AUT" | countrycode1=="BEL" | countrycode1=="DEU" | countrycode1=="DNK" | countrycode1=="ESP" | countrycode1=="FIN" | countrycode1=="FRA" ///
| countrycode1=="GBR" | countrycode1=="GRC" | countrycode1=="IRL" | countrycode1=="ITA" | countrycode1=="LUX" | countrycode1=="NLD" | countrycode1=="POL" | countrycode1=="PRT" ///
| countrycode1=="SWE"

g eu2=0
replace eu2=1 if countrycode2=="AUT" | countrycode2=="BEL" | countrycode2=="DEU" | countrycode2=="DNK" | countrycode2=="ESP" | countrycode2=="FIN" | countrycode2=="FRA" ///
| countrycode2=="GBR" | countrycode2=="GRC" | countrycode2=="IRL" | countrycode2=="ITA" | countrycode2=="LUX" | countrycode2=="NLD" | countrycode2=="POL" | countrycode2=="PRT" ///
| countrycode2=="SWE"


* Merge with dataset that contains informaiton about common language and colonial relationship. This file comes with the code
preserve
use "BBIN-2022/common_variables_old", clear /*This is an older version of STATA */
rename countrycode_dest countrycode1
rename countrycode_orig countrycode2
order countrycode1 countrycode2
drop country_dest country_orig ldist border comcol comctry custrict
save "temp/temp_file", replace
restore

merge m:1 countrycode1 countrycode2 using "temp/temp_file"
replace comlang=0 if _merge==1
replace colony=0 if _merge==1
drop if _merge==2
drop _merge

* Create the inverse of cultural distance
g homophily=-cultural_dist

*Set to zero those observations where there are no data about common language and colonial relationship for Poland and IDN-MYS and IDN-SGP
replace colony=0 if colony==. 
replace comlang=0 if comlang==. 

* Merge data with institutional quality factor. The original data were received by Prof. Karolyi. Generate institutional quality distance
merge m:1 countrycode1 using "outcome/instquality", keepusing(political_instab1 corp_opacity1 for_access1 investor_prot1 mkt_capacity1 operat_ineffic1 instit_qual1 lowgov1 highgov1) 
keep if _merge==3
drop _merge

merge m:1 countrycode2  using "outcome/instquality", keepusing(political_instab2 corp_opacity2 for_access2 investor_prot2 mkt_capacity2 operat_ineffic2 instit_qual2 lowgov2 highgov2)
keep if _merge==3
drop _merge

sort countrycode1 countrycode2 year

 
g prova=[(political_instab1-political_instab2)^2] + [(corp_opacity1-corp_opacity2)^2] + [(for_access1-for_access2)^2] + [(investor_prot1-investor_prot2)^2] + [(mkt_capacity1-mkt_capacity2)^2] + [(operat_ineffic1-operat_ineffic2)^2]
g instqualprox=-[sqrt(prova)] 


* Merge data with reporting quality. This dataset comes with the code. Generate reporting quality distance 
preserve
insheet using "BBIN_2022/reportingquality.csv", delimiter(,) clear
drop countryname
save "temp/temp_file", replace
restore

merge m:1 countrycode1 using "temp/temp_file", keepusing(reportingquality1)
drop _merge

merge m:1 countrycode2 using "temp/temp_file", keepusing(reportingquality2)
drop _merge

g prova2=[(reportingquality1-reportingquality2)^2]

g repqualprox=-[sqrt(prova2)]
drop prova prova2

* Merge data with total number of directors (total, domestic, and foreign)
sort countrycode1 year
merge m:1 countrycode1 year using "outcome/country_ndirectors"
keep if _merge==3
drop _merge

* Craete country and year fixed effects
xi i.countrycode1 , prefix(c1)
xi i.countrycode2 , prefix(c2)
xi i.year


*Merge data with data obtained by Prof. Francis.
merge m:1 countrycode1 countrycode2 using "outcome/francisjune25"
keep if _merge==3
drop _merge

* Run principal components analysis and crate the two factors. 
tsset pairid year

factor homophily repqualprox colony com_leg_orig comrelig comlang instqualprox, factors(3) pcf
rotate
predict factor1 factor2


lab var factor1 "Cultural and institutional proximity"
lab var factor2 "Colonial Ties"
lab var comrelig "Common Religion"
lab var com_leg_orig "Common Legal Origin"
lab var comlang "Common Language"
lab var homophily "Cultural Proximity"
lab var instqualprox "Institutional Proximity"
lab var repqualprox "Reporting Proximity"
lab var instqualprox "Governance Proximity"
lab var colony "Colony"
lab var countrycode1 "Country of destination"
lab var countrycode2 "Country of origin"

* Save final sample for analyses.
save "outcome/final_sample", replace


