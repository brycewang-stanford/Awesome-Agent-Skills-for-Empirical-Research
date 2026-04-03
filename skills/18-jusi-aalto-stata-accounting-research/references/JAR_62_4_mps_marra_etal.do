***************************************************************
******************* Prepare Factors File **********************
***************************************************************

/* We retrieve Fama-French factor data from Kenneth French website. 
 The factors are not at country level but at continent level. They are devided as North America, Europe, Asia-Pacific, Japan. We import the data and convert them into datasets.
*/

* North America
import delimited "/Volumes/Mert's Seagate/Research/Antonio Data Work/M&A Paper (JAR)/CAR2/FF NA.csv", case(preserve) encoding(ISO-8859-1)clear

tostring Date, replace
gen datenew=date(Date, "YMD")
format datenew %td
drop Date
rename datenew Date
order Date
gen Market_ref=1

save factors_america, replace

* Europe

import delimited "/Volumes/Mert's Seagate/Research/Antonio Data Work/M&A Paper (JAR)/CAR2/FF Europe.csv", case(preserve) encoding(ISO-8859-1)clear

tostring Date, replace
gen datenew=date(Date, "YMD")
format datenew %td
drop Date
rename datenew Date
order Date
gen Market_ref=2


save factors_europe, replace

* Asia-Pacific

import delimited "/Volumes/Mert's Seagate/Research/Antonio Data Work/M&A Paper (JAR)/CAR2/FF Asia-Pacific.csv", case(preserve) encoding(ISO-8859-1)clear

tostring Date, replace
gen datenew=date(Date, "YMD")
format datenew %td
drop Date
rename datenew Date
order Date
gen Market_ref=3


save factors_asiapacific, replace

* Japan

import delimited "/Volumes/Mert's Seagate/Research/Antonio Data Work/M&A Paper (JAR)/CAR2/FF Japan.csv", case(preserve) encoding(ISO-8859-1)clear

tostring Date, replace
gen datenew=date(Date, "YMD")
format datenew %td
drop Date
rename datenew Date
order Date
gen Market_ref=4

save factors_japan, replace

* We merge the 4 datasets into one:

use factors_america, clear

append using factors_europe factors_asiapacific factors_japan
label variable MKT "Market returns" 
label variable SMB "Size Factor" 
label variable HML "Book to Market factor" 
label variable WML "Momentum factor"
rename RF risk_free_rate 

replace MKT=MKT/100
replace SMB=SMB/100
replace HML=HML/100
replace WML=WML/100
replace risk_free_rate=risk_free_rate/100
drop RMW CMA

order Date Market_ref MKT SMB HML WML risk_free_rate
drop if year(Date)<2000

save factors, replace

/* We do have market returns data at country level from WRDS and Thomson Refinitiv. We download the daily market returns and recode their reference
numbers. We replace French Kenneth's continent-level market return data with
country-level data. Other factors remain at continent-level.
*/
use "market returns all", clear

merge m:m country using israel_russia_czech
drop _merge

rename date Date
rename country Country
/* We recode US and Canada as one country (North America) due to overlapping 
stock markets */
gen Market_ref=1 if Country=="North America"
replace Market_ref=2 if Country=="AUSTRIA" | Country=="BELGIUM" | Country=="SWITZERLAND" | Country=="GERMANY" | Country=="DENMARK" | Country=="SPAIN" | Country=="FINLAND" | Country=="LUXEMBOURG" | Country=="FRANCE" | Country=="UNITED KINGDOM" | Country=="GREECE" | Country=="IRELAND" | Country=="ITALY" | Country=="NETHERLANDS" | Country=="NORWAY" | Country=="PORTUGAL" | Country=="SWEDEN"  | Country=="POLAND" | Country=="HUNGARY" | Country=="CZECH REPUBLIC" | Country=="ISRAEL"
replace Market_ref=3 if Country=="AUSTRALIA" | Country=="HONG KONG" | Country=="NEW ZEALAND" | Country=="SINGAPORE" | Country=="SOUTH KOREA" | Country=="PHILIPPINES" | Country=="RUSSIA"
replace Market_ref=4 if Country=="JAPAN"

merge m:1 Market_ref Date using factors
drop if _merge==2
drop _merge

rename Market_ref Market_ref1

gen Market_ref2=1 if Country=="North America"
replace Market_ref2=2 if Country=="AUSTRALIA"
replace Market_ref2=3 if Country=="AUSTRIA"
replace Market_ref2=4 if Country=="BELGIUM" 
replace Market_ref2=5 if Country=="BRAZIL"
replace Market_ref2=6 if Country=="CHILE" 
replace Market_ref2=7 if Country=="CHINA" 
replace Market_ref2=8 if Country=="COLOMBIA" 
replace Market_ref2=9 if Country=="DENMARK" 
replace Market_ref2=10 if Country=="EGYPT" 
replace Market_ref2=11 if Country=="FINLAND" 
replace Market_ref2=12 if Country=="FRANCE"
replace Market_ref2=13 if Country=="GERMANY"
replace Market_ref2=14 if Country=="GREECE" 
replace Market_ref2=15 if Country=="HONG KONG"
replace Market_ref2=16 if Country=="HUNGARY" 
replace Market_ref2=17 if Country=="INDIA" 
replace Market_ref2=18 if Country=="INDONESIA" 
replace Market_ref2=19 if Country=="IRELAND"
replace Market_ref2=20 if Country=="ITALY" 
replace Market_ref2=21 if Country=="JAPAN"
replace Market_ref2=22 if Country=="MALAYSIA"
replace Market_ref2=23 if Country=="MEXICO"
replace Market_ref2=24 if Country=="NETHERLANDS" 
replace Market_ref2=25 if Country=="NEW ZEALAND" 
replace Market_ref2=26 if Country=="NORWAY" 
replace Market_ref2=27 if Country=="PHILIPPINES" 
replace Market_ref2=28 if Country=="POLAND" 
replace Market_ref2=29 if Country=="PORTUGAL"
replace Market_ref2=30 if Country=="SINGAPORE"
replace Market_ref2=31 if Country=="SOUTH AFRICA" 
replace Market_ref2=32 if Country=="SOUTH KOREA" 
replace Market_ref2=33 if Country=="SPAIN"
replace Market_ref2=34 if Country=="SWEDEN"
replace Market_ref2=35 if Country=="SWITZERLAND"  
replace Market_ref2=36 if Country=="TAIWAN"  
replace Market_ref2=37 if Country=="THAILAND"  
replace Market_ref2=38 if Country=="TURKEY"  
replace Market_ref2=39 if Country=="UNITED KINGDOM"  
replace Market_ref2=40 if Country=="ISRAEL"  
replace Market_ref2=41 if Country=="RUSSIA" 
replace Market_ref2=42 if Country=="CZECH REPUBLIC"  
 

sort Market_ref2 Date
replace MKT=ret
drop ret Market_ref1
rename Market_ref2 Market_ref
order Date Market_ref

save factors3, replace

***************************************************************
********** Prepare Individual Stock Returns File **************
***************************************************************

****** AMERICA *****
* We retrieve stock returns (from Compustat-CRSP)
use returns_america

* keeping only the primary common securities of each firm
sort gvkey datadate iid
duplicates drop gvkey datadate, force

* calculate returns
sort cusip datadate
by cusip: gen lag_ret=prccd[_n-1]
gen return=(prccd-lag_ret)/lag_ret

* adapt file to eventstudy2 template
drop iid tpci lag_ret gvkey
gen Security_id=substr(cusip,1,6) 
rename datadate Date
rename cshtrd Trading_volume
rename prccd Price
rename return Return
drop cusip
order Date Trading_volume Price Security_id Return
duplicates drop Security_id Date , force
save returns_america2, replace


****** GLOBAL *****
* We retrieve stock returns (from Compustat-CRSP)
use returns_global

* keeping only the primary common securities of each firm
sort gvkey datadate iid
duplicates drop gvkey datadate, force

* calculate returns
sort sedol datadate
by sedol: gen lag_ret=prccd[_n-1]
gen return=(prccd-lag_ret)/lag_ret

* adapt file to eventstudy2 template
drop iid lag_ret gvkey fic
rename sedol Security_id
rename datadate Date
rename cshtrd Trading_volume
rename prccd Price
rename return Return

order Date Trading_volume Price Security_id Return

save returns_global2, replace


***************************************************************
******************* Prepare Events File ***********************
***************************************************************
use "A. Merged DATA Set with CEOs.dta", clear
drop _merge

** Drop First Round observations where Acquirer=Target
drop if ACQUIROR_NAME==TARGET_NAME
* 122 obs deleted - 146 unmatched deals remain

replace master_deal_no=Deal_Number if missing(master_deal_no)
duplicates drop master_deal_no, force
* 4 of them dropped as duplicates, 142 remain.

* Fill some important variables using the old variables and data
replace ACQUIRER_gvkey=gvkey_A if missing(ACQUIRER_gvkey)
replace ACQUIRER_cusip=ACQUIROR_CUSIP if missing(ACQUIRER_cusip)
replace ACQUIRER_sedol=ACQUIROR_SEDOL if missing(ACQUIRER_sedol)

replace TARGET_gvkey=gvkey_T if missing(TARGET_gvkey)
replace TARGET_cusip=TARGET_CUSIP if missing(TARGET_cusip)
replace TARGET_sedol=TARGET_SEDOL if missing(TARGET_sedol)

replace dateann= Date_Announced if missing(dateann)

bys ACQUIRER_COUNTRY_2022: fillmissing ACQUIRER_Country, with(any)
bys TARGET_COUNTRY_2022: fillmissing TARGET_Country, with(any)


replace ACQUIRER_Country = "Ireland-Rep" if ACQUIRER_Country == "Ireland"
replace TARGET_Country = "Ireland-Rep" if TARGET_Country == "Ireland"



* Coding Countries
replace ACQUIRER_Country_Code=1 if ACQUIRER_Country == "United States"
replace ACQUIRER_Country_Code=2 if ACQUIRER_Country == "United Kingdom"
replace ACQUIRER_Country_Code=3 if ACQUIRER_Country == "Japan"
replace ACQUIRER_Country_Code=4 if ACQUIRER_Country == "France"
replace ACQUIRER_Country_Code=5 if ACQUIRER_Country == "Canada"
replace ACQUIRER_Country_Code=6 if ACQUIRER_Country == "Germany"
replace ACQUIRER_Country_Code=7 if ACQUIRER_Country == "Switzerland"
replace ACQUIRER_Country_Code=8 if ACQUIRER_Country == "Netherlands"
replace ACQUIRER_Country_Code=9 if ACQUIRER_Country == "Sweden"
replace ACQUIRER_Country_Code=10 if ACQUIRER_Country == "Australia"
replace ACQUIRER_Country_Code=11 if ACQUIRER_Country == "China"
replace ACQUIRER_Country_Code=12 if ACQUIRER_Country == "Italy"
replace ACQUIRER_Country_Code=13 if ACQUIRER_Country == "Finland"
replace ACQUIRER_Country_Code=14 if ACQUIRER_Country == "Hong Kong"
replace ACQUIRER_Country_Code=15 if ACQUIRER_Country == "Ireland-Rep" | ACQUIRER_Country == "Ireland"
replace ACQUIRER_Country_Code=16 if ACQUIRER_Country == "India"
replace ACQUIRER_Country_Code=17 if ACQUIRER_Country == "Israel"
replace ACQUIRER_Country_Code=18 if ACQUIRER_Country == "South Korea"
replace ACQUIRER_Country_Code=19 if ACQUIRER_Country == "South Africa"
replace ACQUIRER_Country_Code=20 if ACQUIRER_Country == "Spain"
replace ACQUIRER_Country_Code=21 if ACQUIRER_Country == "Belgium"
replace ACQUIRER_Country_Code=22 if ACQUIRER_Country == "Denmark"
replace ACQUIRER_Country_Code=23 if ACQUIRER_Country == "Norway"
replace ACQUIRER_Country_Code=24 if ACQUIRER_Country == "Singapore"
replace ACQUIRER_Country_Code=25 if ACQUIRER_Country == "Bermuda"
replace ACQUIRER_Country_Code=26 if ACQUIRER_Country == "Brazil"
replace ACQUIRER_Country_Code=27 if ACQUIRER_Country == "Malaysia"
replace ACQUIRER_Country_Code=28 if ACQUIRER_Country == "Mexico"
replace ACQUIRER_Country_Code=29 if ACQUIRER_Country == "Poland"
replace ACQUIRER_Country_Code=30 if ACQUIRER_Country == "Taiwan"
replace ACQUIRER_Country_Code=31 if ACQUIRER_Country == "Austria"
replace ACQUIRER_Country_Code=32 if ACQUIRER_Country == "Luxembourg"
replace ACQUIRER_Country_Code=33 if ACQUIRER_Country == "New Zealand"
replace ACQUIRER_Country_Code=34 if ACQUIRER_Country == "Russian Fed"
replace ACQUIRER_Country_Code=35 if ACQUIRER_Country == "Argentina"
replace ACQUIRER_Country_Code=36 if ACQUIRER_Country == "Isle of Man"
replace ACQUIRER_Country_Code=37 if ACQUIRER_Country == "Papua N Guinea"
replace ACQUIRER_Country_Code=38 if ACQUIRER_Country == "Peru"
replace ACQUIRER_Country_Code=39 if ACQUIRER_Country == "Philippines"
replace ACQUIRER_Country_Code=40 if ACQUIRER_Country == "Thailand"
replace ACQUIRER_Country_Code=41 if ACQUIRER_Country == "Chile"
replace ACQUIRER_Country_Code=42 if ACQUIRER_Country == "Colombia"
replace ACQUIRER_Country_Code=43 if ACQUIRER_Country == "Faroe Islands"
replace ACQUIRER_Country_Code=44 if ACQUIRER_Country == "Gibraltar"
replace ACQUIRER_Country_Code=45 if ACQUIRER_Country == "Greece"
replace ACQUIRER_Country_Code=46 if ACQUIRER_Country == "Guernsey"
replace ACQUIRER_Country_Code=47 if ACQUIRER_Country == "Indonesia"
replace ACQUIRER_Country_Code=48 if ACQUIRER_Country == "Jersey"
replace ACQUIRER_Country_Code=49 if ACQUIRER_Country == "Kuwait"
replace ACQUIRER_Country_Code=50 if ACQUIRER_Country == "Lithuania"
replace ACQUIRER_Country_Code=51 if ACQUIRER_Country == "Nigeria"
replace ACQUIRER_Country_Code=52 if ACQUIRER_Country == "Oman"
replace ACQUIRER_Country_Code=53 if ACQUIRER_Country == "Qatar"
replace ACQUIRER_Country_Code=54 if ACQUIRER_Country == "Saudi Arabia"
replace ACQUIRER_Country_Code=55 if ACQUIRER_Country == "Turkey"
replace ACQUIRER_Country_Code=56 if ACQUIRER_Country == "Utd Arab Em"
replace ACQUIRER_Country_Code=57 if ACQUIRER_Country == "Hungary"
replace ACQUIRER_Country_Code=58 if ACQUIRER_Country == "Morocco"
replace ACQUIRER_Country_Code=59 if ACQUIRER_Country == "Portugal"
replace ACQUIRER_Country_Code=60 if ACQUIRER_Country == "Vietnam"
replace ACQUIRER_Country_Code=61 if ACQUIRER_Country == "Croatia"
replace ACQUIRER_Country_Code=62 if ACQUIRER_Country == "Cyprus"
replace ACQUIRER_Country_Code=63 if ACQUIRER_Country == "Neth Antilles"
replace ACQUIRER_Country_Code=64 if ACQUIRER_Country == "Slovenia"
replace ACQUIRER_Country_Code=65 if ACQUIRER_Country == "Czech Republic"
replace ACQUIRER_Country_Code=66 if ACQUIRER_Country == "Kenya" | ACQUIRER_Country == "Ghana" | ACQUIRER_Country == "Senegal" | ACQUIRER_Country == "Zambia"
replace ACQUIRER_Country_Code=67 if ACQUIRER_Country == "Jordan"
replace ACQUIRER_Country_Code=68 if ACQUIRER_Country == "Romania"
replace ACQUIRER_Country_Code=69 if ACQUIRER_Country == "Ecuador"
replace ACQUIRER_Country_Code=70 if ACQUIRER_Country == "Kazakhstan"
replace ACQUIRER_Country_Code=71 if ACQUIRER_Country == "French Polynesia"
replace ACQUIRER_Country_Code=72 if ACQUIRER_Country == "Tahiti"
replace ACQUIRER_Country_Code=73 if ACQUIRER_Country == "Pakistan"
replace ACQUIRER_Country_Code=74 if ACQUIRER_Country == "Egypt"
replace ACQUIRER_Country_Code=75 if ACQUIRER_Country == "Serbia"
replace ACQUIRER_Country_Code=76 if ACQUIRER_Country == "Cayman Islands"
replace ACQUIRER_Country_Code=77 if ACQUIRER_Country == "Sri Lanka"
replace ACQUIRER_Country_Code=78 if ACQUIRER_Country == "Lebanon"
replace ACQUIRER_Country_Code=79 if ACQUIRER_Country == "Honduras"
replace ACQUIRER_Country_Code=80 if ACQUIRER_Country == "Iran"
replace ACQUIRER_Country_Code=81 if ACQUIRER_Country == "Iceland"
replace ACQUIRER_Country_Code=82 if ACQUIRER_Country == "Malta"



replace TARGET_Country_Code=1 if TARGET_Country == "United States"
replace TARGET_Country_Code=2 if TARGET_Country == "United Kingdom"
replace TARGET_Country_Code=3 if TARGET_Country == "Japan"
replace TARGET_Country_Code=4 if TARGET_Country == "France"
replace TARGET_Country_Code=5 if TARGET_Country == "Canada"
replace TARGET_Country_Code=6 if TARGET_Country == "Germany"
replace TARGET_Country_Code=7 if TARGET_Country == "Switzerland"
replace TARGET_Country_Code=8 if TARGET_Country == "Netherlands"
replace TARGET_Country_Code=9 if TARGET_Country == "Sweden"
replace TARGET_Country_Code=10 if TARGET_Country == "Australia"
replace TARGET_Country_Code=11 if TARGET_Country == "China"
replace TARGET_Country_Code=12 if TARGET_Country == "Italy"
replace TARGET_Country_Code=13 if TARGET_Country == "Finland"
replace TARGET_Country_Code=14 if TARGET_Country == "Hong Kong"
replace TARGET_Country_Code=15 if TARGET_Country == "Ireland-Rep" | TARGET_Country == "Ireland"
replace TARGET_Country_Code=16 if TARGET_Country == "India"
replace TARGET_Country_Code=17 if TARGET_Country == "Israel"
replace TARGET_Country_Code=18 if TARGET_Country == "South Korea"
replace TARGET_Country_Code=19 if TARGET_Country == "South Africa"
replace TARGET_Country_Code=20 if TARGET_Country == "Spain"
replace TARGET_Country_Code=21 if TARGET_Country == "Belgium"
replace TARGET_Country_Code=22 if TARGET_Country == "Denmark"
replace TARGET_Country_Code=23 if TARGET_Country == "Norway"
replace TARGET_Country_Code=24 if TARGET_Country == "Singapore"
replace TARGET_Country_Code=25 if TARGET_Country == "Bermuda"
replace TARGET_Country_Code=26 if TARGET_Country == "Brazil"
replace TARGET_Country_Code=27 if TARGET_Country == "Malaysia"
replace TARGET_Country_Code=28 if TARGET_Country == "Mexico"
replace TARGET_Country_Code=29 if TARGET_Country == "Poland"
replace TARGET_Country_Code=30 if TARGET_Country == "Taiwan"
replace TARGET_Country_Code=31 if TARGET_Country == "Austria"
replace TARGET_Country_Code=32 if TARGET_Country == "Luxembourg"
replace TARGET_Country_Code=33 if TARGET_Country == "New Zealand"
replace TARGET_Country_Code=34 if TARGET_Country == "Russian Fed"
replace TARGET_Country_Code=35 if TARGET_Country == "Argentina"
replace TARGET_Country_Code=36 if TARGET_Country == "Isle of Man"
replace TARGET_Country_Code=37 if TARGET_Country == "Papua N Guinea"
replace TARGET_Country_Code=38 if TARGET_Country == "Peru"
replace TARGET_Country_Code=39 if TARGET_Country == "Philippines"
replace TARGET_Country_Code=40 if TARGET_Country == "Thailand"
replace TARGET_Country_Code=41 if TARGET_Country == "Chile"
replace TARGET_Country_Code=42 if TARGET_Country == "Colombia"
replace TARGET_Country_Code=43 if TARGET_Country == "Faroe Islands"
replace TARGET_Country_Code=44 if TARGET_Country == "Gibraltar"
replace TARGET_Country_Code=45 if TARGET_Country == "Greece"
replace TARGET_Country_Code=46 if TARGET_Country == "Guernsey"
replace TARGET_Country_Code=47 if TARGET_Country == "Indonesia"
replace TARGET_Country_Code=48 if TARGET_Country == "Jersey"
replace TARGET_Country_Code=49 if TARGET_Country == "Kuwait"
replace TARGET_Country_Code=50 if TARGET_Country == "Lithuania"
replace TARGET_Country_Code=51 if TARGET_Country == "Nigeria"
replace TARGET_Country_Code=52 if TARGET_Country == "Oman"
replace TARGET_Country_Code=53 if TARGET_Country == "Qatar"
replace TARGET_Country_Code=54 if TARGET_Country == "Saudi Arabia"
replace TARGET_Country_Code=55 if TARGET_Country == "Turkey"
replace TARGET_Country_Code=56 if TARGET_Country == "Utd Arab Em"
replace TARGET_Country_Code=57 if TARGET_Country == "Hungary"
replace TARGET_Country_Code=58 if TARGET_Country == "Morocco"
replace TARGET_Country_Code=59 if TARGET_Country == "Portugal"
replace TARGET_Country_Code=60 if TARGET_Country == "Vietnam"
replace TARGET_Country_Code=61 if TARGET_Country == "Croatia"
replace TARGET_Country_Code=62 if TARGET_Country == "Cyprus"
replace TARGET_Country_Code=63 if TARGET_Country == "Neth Antilles"
replace TARGET_Country_Code=64 if TARGET_Country == "Slovenia"
replace TARGET_Country_Code=65 if TARGET_Country == "Czech Republic"
replace TARGET_Country_Code=66 if TARGET_Country == "Kenya" | TARGET_Country == "Ghana" | TARGET_Country == "Senegal" | TARGET_Country == "Zambia"
replace TARGET_Country_Code=67 if TARGET_Country == "Jordan"
replace TARGET_Country_Code=68 if TARGET_Country == "Romania"
replace TARGET_Country_Code=69 if TARGET_Country == "Ecuador"
replace TARGET_Country_Code=70 if TARGET_Country == "Kazakhstan"
replace TARGET_Country_Code=71 if TARGET_Country == "French Polynesia"
replace TARGET_Country_Code=72 if TARGET_Country == "Tahiti"
replace TARGET_Country_Code=73 if TARGET_Country == "Pakistan"
replace TARGET_Country_Code=74 if TARGET_Country == "Egypt"
replace TARGET_Country_Code=75 if TARGET_Country == "Serbia"
replace TARGET_Country_Code=76 if TARGET_Country == "Cayman Islands"
replace TARGET_Country_Code=77 if TARGET_Country == "Sri Lanka"
replace TARGET_Country_Code=78 if TARGET_Country == "Lebanon"
replace TARGET_Country_Code=79 if TARGET_Country == "Honduras"
replace TARGET_Country_Code=80 if TARGET_Country == "Iran"
replace TARGET_Country_Code=81 if TARGET_Country == "Iceland"
replace TARGET_Country_Code=82 if TARGET_Country == "Malta"





* Coding markets with available returns data*
replace ACQUIRER_Market_ref=1 if ACQUIRER_Country=="United States" | ACQUIRER_Country=="Canada"
replace ACQUIRER_Market_ref=2 if ACQUIRER_Country=="Australia"
replace ACQUIRER_Market_ref=3 if ACQUIRER_Country=="Austria"
replace ACQUIRER_Market_ref=4 if ACQUIRER_Country=="Belgium" 
replace ACQUIRER_Market_ref=5 if ACQUIRER_Country=="Brazil" 
replace ACQUIRER_Market_ref=6 if ACQUIRER_Country=="Chile" 
replace ACQUIRER_Market_ref=7 if ACQUIRER_Country=="China" 
replace ACQUIRER_Market_ref=8 if ACQUIRER_Country=="Colombia" 
replace ACQUIRER_Market_ref=9 if ACQUIRER_Country=="Denmark" 
replace ACQUIRER_Market_ref=10 if ACQUIRER_Country=="Egypt" 
replace ACQUIRER_Market_ref=11 if ACQUIRER_Country=="Finland" 
replace ACQUIRER_Market_ref=12 if ACQUIRER_Country=="France"
replace ACQUIRER_Market_ref=13 if ACQUIRER_Country=="Germany"
replace ACQUIRER_Market_ref=14 if ACQUIRER_Country=="Greece" 
replace ACQUIRER_Market_ref=15 if ACQUIRER_Country=="Hong Kong"
replace ACQUIRER_Market_ref=16 if ACQUIRER_Country=="Hungary" 
replace ACQUIRER_Market_ref=17 if ACQUIRER_Country=="India" 
replace ACQUIRER_Market_ref=18 if ACQUIRER_Country=="Indonesia" 
replace ACQUIRER_Market_ref=19 if ACQUIRER_Country=="Ireland-Rep"
replace ACQUIRER_Market_ref=20 if ACQUIRER_Country=="Italy" 
replace ACQUIRER_Market_ref=21 if ACQUIRER_Country=="Japan"
replace ACQUIRER_Market_ref=22 if ACQUIRER_Country=="Malaysia"
replace ACQUIRER_Market_ref=23 if ACQUIRER_Country=="Mexico"
replace ACQUIRER_Market_ref=24 if ACQUIRER_Country=="Netherlands" 
replace ACQUIRER_Market_ref=25 if ACQUIRER_Country=="New Zealand" 
replace ACQUIRER_Market_ref=26 if ACQUIRER_Country=="Norway" 
replace ACQUIRER_Market_ref=27 if ACQUIRER_Country=="Philippines" 
replace ACQUIRER_Market_ref=28 if ACQUIRER_Country=="Poland" 
replace ACQUIRER_Market_ref=29 if ACQUIRER_Country=="Portugal"
replace ACQUIRER_Market_ref=30 if ACQUIRER_Country=="Singapore"
replace ACQUIRER_Market_ref=31 if ACQUIRER_Country=="South Africa" 
replace ACQUIRER_Market_ref=32 if ACQUIRER_Country=="South Korea" 
replace ACQUIRER_Market_ref=33 if ACQUIRER_Country=="Spain"
replace ACQUIRER_Market_ref=34 if ACQUIRER_Country=="Sweden"
replace ACQUIRER_Market_ref=35 if ACQUIRER_Country=="Switzerland"  
replace ACQUIRER_Market_ref=36 if ACQUIRER_Country=="Taiwan"  
replace ACQUIRER_Market_ref=37 if ACQUIRER_Country=="Thailand"  
replace ACQUIRER_Market_ref=38 if ACQUIRER_Country=="Turkey"  
replace ACQUIRER_Market_ref=39 if ACQUIRER_Country=="United Kingdom" 
replace ACQUIRER_Market_ref=40 if ACQUIRER_Country=="Israel" 
replace ACQUIRER_Market_ref=41 if ACQUIRER_Country=="Russian Fed" 
replace ACQUIRER_Market_ref=42 if ACQUIRER_Country=="Czech Republic" 



replace TARGET_Market_ref=1 if TARGET_Country=="United States" | TARGET_Country=="Canada"
replace TARGET_Market_ref=2 if TARGET_Country=="Australia"
replace TARGET_Market_ref=3 if TARGET_Country=="Austria"
replace TARGET_Market_ref=4 if TARGET_Country=="Belgium" 
replace TARGET_Market_ref=5 if TARGET_Country=="Brazil" 
replace TARGET_Market_ref=6 if TARGET_Country=="Chile" 
replace TARGET_Market_ref=7 if TARGET_Country=="China" 
replace TARGET_Market_ref=8 if TARGET_Country=="Colombia" 
replace TARGET_Market_ref=9 if TARGET_Country=="Denmark" 
replace TARGET_Market_ref=10 if TARGET_Country=="Egypt" 
replace TARGET_Market_ref=11 if TARGET_Country=="Finland" 
replace TARGET_Market_ref=12 if TARGET_Country=="France"
replace TARGET_Market_ref=13 if TARGET_Country=="Germany"
replace TARGET_Market_ref=14 if TARGET_Country=="Greece" 
replace TARGET_Market_ref=15 if TARGET_Country=="Hong Kong"
replace TARGET_Market_ref=16 if TARGET_Country=="Hungary" 
replace TARGET_Market_ref=17 if TARGET_Country=="India" 
replace TARGET_Market_ref=18 if TARGET_Country=="Indonesia" 
replace TARGET_Market_ref=19 if TARGET_Country=="Ireland-Rep"
replace TARGET_Market_ref=20 if TARGET_Country=="Italy" 
replace TARGET_Market_ref=21 if TARGET_Country=="Japan"
replace TARGET_Market_ref=22 if TARGET_Country=="Malaysia"
replace TARGET_Market_ref=23 if TARGET_Country=="Mexico"
replace TARGET_Market_ref=24 if TARGET_Country=="Netherlands" 
replace TARGET_Market_ref=25 if TARGET_Country=="New Zealand" 
replace TARGET_Market_ref=26 if TARGET_Country=="Norway" 
replace TARGET_Market_ref=27 if TARGET_Country=="Philippines" 
replace TARGET_Market_ref=28 if TARGET_Country=="Poland" 
replace TARGET_Market_ref=29 if TARGET_Country=="Portugal"
replace TARGET_Market_ref=30 if TARGET_Country=="Singapore"
replace TARGET_Market_ref=31 if TARGET_Country=="South Africa" 
replace TARGET_Market_ref=32 if TARGET_Country=="South Korea" 
replace TARGET_Market_ref=33 if TARGET_Country=="Spain"
replace TARGET_Market_ref=34 if TARGET_Country=="Sweden"
replace TARGET_Market_ref=35 if TARGET_Country=="Switzerland"  
replace TARGET_Market_ref=36 if TARGET_Country=="Taiwan"  
replace TARGET_Market_ref=37 if TARGET_Country=="Thailand"  
replace TARGET_Market_ref=38 if TARGET_Country=="Turkey"  
replace TARGET_Market_ref=39 if TARGET_Country=="United Kingdom" 
replace TARGET_Market_ref=40 if TARGET_Country=="Israel" 
replace TARGET_Market_ref=41 if TARGET_Country=="Russian Fed" 
replace TARGET_Market_ref=42 if TARGET_Country=="Czech Republic" 


replace ACQUIRER_ID=ACQUIRER_cusip if missing(ACQUIRER_ID)
replace TARGET_ID=TARGET_cusip if missing(TARGET_ID)


** Prepare Main Dataset for Premium Calculations **
duplicates drop master_deal_no dateann, force
merge 1:1 master_deal_no dateann using dealval, update
drop if _merge==2
drop _merge
gen PREM3 = dealval-mv
sum pmday pmwk pm4wk PREM3 dealval mv amv pr c1day c1wk c4wk

save "A. Merged DATA Set with CEOs for CAR.dta", replace

keep dateann ACQUIRER_sedol ACQUIRER_ID TARGET_sedol TARGET_ID ACQUIRER_Market_ref TARGET_Market_ref

save CAR_ready, replace

***************************************************************
********************** Calculate CARS *************************
***************************************************************

use CAR_ready, clear

rename dateann Date

* Acquiror - America
rename ACQUIRER_ID Security_id
rename ACQUIRER_Market_ref Market_ref

* Market Adjusted Returns
eventstudy2 Security_id Date using returns_america2, ret(Return) car1LB(-1) car1UB(1) mod(MA) marketfile(factors3) mar(MKT) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(acquirerus_MA_crossfile)replace
* Fama French 3 factor
eventstudy2 Security_id Date using returns_america2, ret(Return) car1LB(-1) car1UB(1) mod(FM) marketfile(factors3) mar(MKT) factor1(SMB) factor2(HML) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(acquirerus_FF_crossfile) replace
* Carhart 4 factor
eventstudy2 Security_id Date using returns_america2, ret(Return) car1LB(-1) car1UB(1) mod(FM) marketfile(factors3) mar(MKT) factor1(SMB) factor2(HML) factor3(WML) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(acquirerus_CA_crossfile) replace

* Target - America
rename Security_id ACQUIRER_ID
rename TARGET_ID Security_id
rename Market_ref ACQUIRER_Market_ref
rename TARGET_Market_ref Market_ref


** Market Adjusted Returns
eventstudy2 Security_id Date using returns_america2, ret(Return) car1LB(-1) car1UB(1) mod(MA) marketfile(factors3) mar(MKT) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(targetus_MA_crossfile) replace
** Fama French 3 factor
eventstudy2 Security_id Date using returns_america2, ret(Return) car1LB(-1) car1UB(1) mod(FM) marketfile(factors3) mar(MKT) factor1(SMB) factor2(HML) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(targetus_FF_crossfile) replace
** Carhart 4 factor
eventstudy2 Security_id Date using returns_america2, ret(Return) car1LB(-1) car1UB(1) mod(FM) marketfile(factors3) mar(MKT) factor1(SMB) factor2(HML) factor3(WML) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(targetus_CA_crossfile) replace

rename Security_id TARGET_ID
rename Market_ref TARGET_Market_ref


* Acquiror - Global
rename ACQUIRER_sedol Security_id
rename ACQUIRER_Market_ref Market_ref

** Market Adjusted Returns
eventstudy2 Security_id Date using returns_global2, ret(Return) car1LB(-1) car1UB(1) mod(MA) marketfile(factors3) mar(MKT) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(acquirerglobal_MA_crossfile) replace
** Fama French 3 factor
eventstudy2 Security_id Date using returns_global2, ret(Return) car1LB(-1) car1UB(1) mod(FM) marketfile(factors3) mar(MKT) factor1(SMB) factor2(HML) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(acquirerglobal_FF_crossfile) replace
** Carhart 4 factor
eventstudy2 Security_id Date using returns_global2, ret(Return) car1LB(-1) car1UB(1) mod(FM) marketfile(factors3) mar(MKT) factor1(SMB) factor2(HML) factor3(WML) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(acquirerglobal_CA_crossfile) replace

* Target - Global
rename Security_id ACQUIRER_sedol
rename TARGET_sedol Security_id
rename Market_ref ACQUIRER_Market_ref
rename TARGET_Market_ref Market_ref


** Market Adjusted Returns
eventstudy2 Security_id Date using returns_global2, ret(Return) car1LB(-1) car1UB(1) mod(MA) marketfile(factors3) mar(MKT) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(targetglobal_MA_crossfile) replace
** Fama French 3 factor
eventstudy2 Security_id Date using returns_global2, ret(Return) car1LB(-1) car1UB(1) mod(FM) marketfile(factors3) mar(MKT) factor1(SMB) factor2(HML) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(targetglobal_FF_crossfile) replace
** Carhart 4 factor
eventstudy2 Security_id Date using returns_global2, ret(Return) car1LB(-1) car1UB(1) mod(FM) marketfile(factors3) mar(MKT) factor1(SMB) factor2(HML) factor3(WML) idmar(Market_ref) evwlb(-1) evwub(+1) eswlb(-100) eswub(-10) arfillevent arfillestimation datelinethreshold(0.2) delweekend crossfile(targetglobal_CA_crossfile) replace

rename Security_id TARGET_sedol
rename Market_ref TARGET_Market_ref


save CAR_ready, replace


***************************************************************
************** Merge CARs with main dataset *******************
***************************************************************

*** Prepare CAR files for merge ***

* North America - Acquirer
use acquirerus_MA_crossfile, clear

rename Security_id ACQUIRER_ID
rename original_event_date dateann
rename CAR1 ACQUIRER_CAR_MA_NEW
keep ACQUIRER_ID dateann ACQUIRER_CAR_MA 

save acquirerus_MA_crossfile, replace

use acquirerus_FF_crossfile, clear

rename Security_id ACQUIRER_ID
rename original_event_date dateann
rename CAR1 ACQUIRER_CAR_FF_NEW
keep ACQUIRER_ID dateann ACQUIRER_CAR_FF 

save acquirerus_FF_crossfile, replace

use acquirerus_CA_crossfile, clear

rename Security_id ACQUIRER_ID
rename original_event_date dateann
rename CAR1 ACQUIRER_CAR_CA_NEW
keep ACQUIRER_ID dateann ACQUIRER_CAR_CA 

save acquirerus_CA_crossfile, replace

* North America - Target

use targetus_MA_crossfile, clear

rename Security_id TARGET_ID
rename original_event_date dateann
rename CAR1 TARGET_CAR_MA_NEW
keep TARGET_ID dateann TARGET_CAR_MA 

save targetus_MA_crossfile, replace

use targetus_FF_crossfile, clear

rename Security_id TARGET_ID
rename original_event_date dateann
rename CAR1 TARGET_CAR_FF_NEW
keep TARGET_ID dateann TARGET_CAR_FF

save targetus_FF_crossfile, replace

use targetus_CA_crossfile, clear

rename Security_id TARGET_ID
rename original_event_date dateann
rename CAR1 TARGET_CAR_CA_NEW
keep TARGET_ID dateann TARGET_CAR_CA 

save targetus_CA_crossfile, replace


* Global - Acquirer

use acquirerglobal_MA_crossfile, clear

rename Security_id ACQUIRER_sedol
rename original_event_date dateann
rename CAR1 ACQUIRER_CAR_MA_NEW
keep ACQUIRER_sedol dateann ACQUIRER_CAR_MA

save acquirerglobal_MA_crossfile, replace

use acquirerglobal_FF_crossfile, clear

rename Security_id ACQUIRER_sedol
rename original_event_date dateann
rename CAR1 ACQUIRER_CAR_FF_NEW
keep ACQUIRER_sedol dateann ACQUIRER_CAR_FF

save acquirerglobal_FF_crossfile, replace

use acquirerglobal_CA_crossfile, clear

rename Security_id ACQUIRER_sedol
rename original_event_date dateann
rename CAR1 ACQUIRER_CAR_CA_NEW
keep ACQUIRER_sedol dateann ACQUIRER_CAR_CA

save acquirerglobal_CA_crossfile, replace

* Global - Target

use targetglobal_MA_crossfile, clear

rename Security_id TARGET_sedol
rename original_event_date dateann
rename CAR1 TARGET_CAR_MA_NEW
keep TARGET_sedol dateann TARGET_CAR_MA

save targetglobal_MA_crossfile, replace

use targetglobal_FF_crossfile, clear

rename Security_id TARGET_sedol
rename original_event_date dateann
rename CAR1 TARGET_CAR_FF_NEW
keep TARGET_sedol dateann TARGET_CAR_FF

save targetglobal_FF_crossfile, replace

use targetglobal_CA_crossfile, clear

rename Security_id TARGET_sedol
rename original_event_date dateann
rename CAR1 TARGET_CAR_CA_NEW
keep TARGET_sedol dateann TARGET_CAR_CA

save targetglobal_CA_crossfile, replace

*** Merge ***

use "A. Merged DATA Set with CEOs for CAR.dta", clear

merge m:m ACQUIRER_ID dateann using acquirerus_MA_crossfile
drop _merge
merge m:m ACQUIRER_ID dateann using acquirerus_FF_crossfile
drop _merge
merge m:m ACQUIRER_ID dateann using acquirerus_CA_crossfile
drop _merge
merge m:m TARGET_ID dateann using targetus_MA_crossfile
drop _merge
merge m:m TARGET_ID dateann using targetus_FF_crossfile
drop _merge
merge m:m TARGET_ID dateann using targetus_CA_crossfile
drop _merge

merge m:m ACQUIRER_sedol dateann using acquirerglobal_MA_crossfile, update
drop if _merge==2
drop _merge
merge m:m ACQUIRER_sedol dateann using acquirerglobal_FF_crossfile, update
drop if _merge==2
drop _merge
merge m:m ACQUIRER_sedol dateann using acquirerglobal_CA_crossfile, update
drop if _merge==2
drop _merge
merge m:m TARGET_sedol dateann using targetglobal_MA_crossfile, update
drop if _merge==2
drop _merge
merge m:m TARGET_sedol dateann using targetglobal_FF_crossfile, update
drop if _merge==2
drop _merge
merge m:m TARGET_sedol dateann using targetglobal_CA_crossfile, update
drop if _merge==2
drop _merge

sum ACQUIRER_CAR_MA* ACQUIRER_CAR_FF* ACQUIRER_CAR_CA* 
sum TARGET_CAR_MA* TARGET_CAR_FF* TARGET_CAR_CA*
sum ACQUIRER_CAR_MA_NEW- TARGET_CAR_CA_NEW

winsor2 ACQUIRER_CAR_MA_NEW- TARGET_CAR_CA_NEW

replace ACQUIRER_CAR_MA_NEW_w=ACQUIRER_CAR_MA_w if missing(ACQUIRER_CAR_MA_NEW_w)
replace ACQUIRER_CAR_MA_NEW_w=CAR_parent if missing(ACQUIRER_CAR_MA_NEW_w)
replace ACQUIRER_CAR_FF_NEW_w=ACQUIRER_CAR_FF if missing(ACQUIRER_CAR_FF_NEW_w)
replace ACQUIRER_CAR_FF_NEW_w=CAR_parent if missing(ACQUIRER_CAR_FF_NEW_w)
replace ACQUIRER_CAR_CA_NEW_w=ACQUIRER_CAR_CA if missing(ACQUIRER_CAR_CA_NEW_w)
replace ACQUIRER_CAR_CA_NEW_w=CAR_parent if missing(ACQUIRER_CAR_CA_NEW_w)

replace TARGET_CAR_MA_NEW_w=TARGET_CAR_MA_w if missing(TARGET_CAR_MA_NEW_w)
replace TARGET_CAR_MA_NEW_w=CAR_target if missing(TARGET_CAR_MA_NEW_w)
replace TARGET_CAR_FF_NEW_w=TARGET_CAR_FF if missing(TARGET_CAR_FF_NEW_w)
replace TARGET_CAR_FF_NEW_w=CAR_target if missing(TARGET_CAR_FF_NEW_w)
replace TARGET_CAR_CA_NEW_w=TARGET_CAR_CA if missing(TARGET_CAR_CA_NEW_w)
replace TARGET_CAR_CA_NEW_w=CAR_target if missing(TARGET_CAR_CA_NEW_w)

label variable ACQUIRER_CAR_MA_NEW "Acquirer's Market Adjusted CAR"
label variable ACQUIRER_CAR_FF_NEW "Acquirer's Fama-French 3F CAR"
label variable ACQUIRER_CAR_CA_NEW "Acquirer's Carhart 4F CAR"
label variable TARGET_CAR_MA_NEW "Target's Market Adjusted CAR"
label variable TARGET_CAR_FF_NEW "Target's Fama-French 3F CAR"
label variable TARGET_CAR_CA_NEW "Target's Carhart 4F CAR"

gen PREM_SDC_1_new=pmday 
gen PREM_SDC_7_new=pmwk 
gen PREM_SDC_28_new=pm4wk 


label variable PREM_SDC_1_new "Target's Premium in % per SDC, based on Target's PPS at Day-1"
label variable PREM_SDC_7_new "Target's Premium in % per SDC, based on Target's PPS at Day-7"
label variable PREM_SDC_28_new "Target's Premium in % per SDC, based on Target's PPS at Day-28"

gen PREM_DEALVAL_NEW=PREM3
label variable PREM_DEALVAL_NEW "Target's Premium in $mil (deal value - target market cap)"

gen SYNERGY_NEW=(ACQUIRER_CAR_MA_NEW_w*amv+TARGET_CAR_MA_NEW_w*mv)/(amv+mv)
label variable SYNERGY_NEW "Acquirer and Target's cumulative CARs weighted by market cap"
winsor2 SYNERGY_NEW

sum ACQUIRER_CAR_MA_NEW_w- TARGET_CAR_CA_NEW_w SYNERGY_NEW_w

save "A. Merged DATA Set with CEOs and CARs.dta", replace


***NOTE: we retrieve data already calculated in previous round. Logic and modeling is identical.****

* Retrieve financial data for first-round deals
use "A. Merged DATA Set with CEOs and CARs.dta", clear
*Acquirer
replace ACQUIRER_fyear=year_P if missing(ACQUIRER_fyear)
merge m:1 ACQUIRER_gvkey ACQUIRER_fyear using Compustat_US_Acquirer, update
drop if _merge==2
drop _merge
merge m:1 ACQUIRER_cusip ACQUIRER_fyear using Compustat_US_Acquirer, update
drop if _merge==2
drop _merge
*Target
replace TARGET_fyear=year_T if missing(TARGET_fyear)
merge m:1 TARGET_gvkey TARGET_fyear using Compustat_US_Target, update
drop if _merge==2
drop _merge
merge m:1 TARGET_cusip TARGET_fyear using Compustat_US_Target, update
drop if _merge==2
drop _merge

save "A. Merged DATA Set with CEOs and CARs.dta", replace







* Merging Fama French factors for North America, Europe, Asia-Pacific, Japan (retrieved from Kenneth French website)

* North America
import delimited "/Volumes/Mert's Seagate/Research/Antonio Data Work/M&A Paper (JAR)/CAR2/FF NA.csv", case(preserve) encoding(ISO-8859-1)clear

tostring Date, replace
gen datenew=date(Date, "YMD")
format datenew %td
drop Date
rename datenew Date
order Date
gen Market_ref=1

save factors_america, replace

* Europe

import delimited "/Volumes/Mert's Seagate/Research/Antonio Data Work/M&A Paper (JAR)/CAR2/FF Europe.csv", case(preserve) encoding(ISO-8859-1)clear

tostring Date, replace
gen datenew=date(Date, "YMD")
format datenew %td
drop Date
rename datenew Date
order Date
gen Market_ref=2


save factors_europe, replace

* Asia-Pacific

import delimited "/Volumes/Mert's Seagate/Research/Antonio Data Work/M&A Paper (JAR)/CAR2/FF Asia-Pacific.csv", case(preserve) encoding(ISO-8859-1)clear

tostring Date, replace
gen datenew=date(Date, "YMD")
format datenew %td
drop Date
rename datenew Date
order Date
gen Market_ref=3


save factors_asiapacific, replace

* Japan

import delimited "/Volumes/Mert's Seagate/Research/Antonio Data Work/M&A Paper (JAR)/CAR2/FF Japan.csv", case(preserve) encoding(ISO-8859-1)clear

tostring Date, replace
gen datenew=date(Date, "YMD")
format datenew %td
drop Date
rename datenew Date
order Date
gen Market_ref=4

save factors_japan, replace

* Append 4 datasets

use factors_america, clear

append using factors_europe factors_asiapacific factors_japan
label variable MKT "Market returns" 
label variable SMB "Size Factor" 
label variable HML "Book to Market factor" 
label variable WML "Momentum factor"
rename RF risk_free_rate 

replace MKT=MKT/100
replace SMB=SMB/100
replace HML=HML/100
replace WML=WML/100
replace risk_free_rate=risk_free_rate/100
drop RMW CMA

order Date Market_ref MKT SMB HML WML risk_free_rate
drop if year(Date)<2000

save factors, replace

* Recode markets
use "market returns all", clear

merge m:m country using israel_russia_czech
drop _merge

rename date Date
rename country Country
gen Market_ref=1 if Country=="North America"
replace Market_ref=2 if Country=="AUSTRIA" | Country=="BELGIUM" | Country=="SWITZERLAND" | Country=="GERMANY" | Country=="DENMARK" | Country=="SPAIN" | Country=="FINLAND" | Country=="LUXEMBOURG" | Country=="FRANCE" | Country=="UNITED KINGDOM" | Country=="GREECE" | Country=="IRELAND" | Country=="ITALY" | Country=="NETHERLANDS" | Country=="NORWAY" | Country=="PORTUGAL" | Country=="SWEDEN"  | Country=="POLAND" | Country=="HUNGARY" | Country=="CZECH REPUBLIC" | Country=="ISRAEL"
replace Market_ref=3 if Country=="AUSTRALIA" | Country=="HONG KONG" | Country=="NEW ZEALAND" | Country=="SINGAPORE" | Country=="SOUTH KOREA" | Country=="PHILIPPINES" | Country=="RUSSIA"
replace Market_ref=4 if Country=="JAPAN"

merge m:1 Market_ref Date using factors
drop if _merge==2
drop _merge

rename Market_ref Market_ref1

gen Market_ref2=1 if Country=="North America"
replace Market_ref2=2 if Country=="AUSTRALIA"
replace Market_ref2=3 if Country=="AUSTRIA"
replace Market_ref2=4 if Country=="BELGIUM" 
replace Market_ref2=5 if Country=="BRAZIL"
replace Market_ref2=6 if Country=="CHILE" 
replace Market_ref2=7 if Country=="CHINA" 
replace Market_ref2=8 if Country=="COLOMBIA" 
replace Market_ref2=9 if Country=="DENMARK" 
replace Market_ref2=10 if Country=="EGYPT" 
replace Market_ref2=11 if Country=="FINLAND" 
replace Market_ref2=12 if Country=="FRANCE"
replace Market_ref2=13 if Country=="GERMANY"
replace Market_ref2=14 if Country=="GREECE" 
replace Market_ref2=15 if Country=="HONG KONG"
replace Market_ref2=16 if Country=="HUNGARY" 
replace Market_ref2=17 if Country=="INDIA" 
replace Market_ref2=18 if Country=="INDONESIA" 
replace Market_ref2=19 if Country=="IRELAND"
replace Market_ref2=20 if Country=="ITALY" 
replace Market_ref2=21 if Country=="JAPAN"
replace Market_ref2=22 if Country=="MALAYSIA"
replace Market_ref2=23 if Country=="MEXICO"
replace Market_ref2=24 if Country=="NETHERLANDS" 
replace Market_ref2=25 if Country=="NEW ZEALAND" 
replace Market_ref2=26 if Country=="NORWAY" 
replace Market_ref2=27 if Country=="PHILIPPINES" 
replace Market_ref2=28 if Country=="POLAND" 
replace Market_ref2=29 if Country=="PORTUGAL"
replace Market_ref2=30 if Country=="SINGAPORE"
replace Market_ref2=31 if Country=="SOUTH AFRICA" 
replace Market_ref2=32 if Country=="SOUTH KOREA" 
replace Market_ref2=33 if Country=="SPAIN"
replace Market_ref2=34 if Country=="SWEDEN"
replace Market_ref2=35 if Country=="SWITZERLAND"  
replace Market_ref2=36 if Country=="TAIWAN"  
replace Market_ref2=37 if Country=="THAILAND"  
replace Market_ref2=38 if Country=="TURKEY"  
replace Market_ref2=39 if Country=="UNITED KINGDOM"  
replace Market_ref2=40 if Country=="ISRAEL"  
replace Market_ref2=41 if Country=="RUSSIA" 
replace Market_ref2=42 if Country=="CZECH REPUBLIC"  
 

sort Market_ref2 Date
replace MKT=ret
drop ret Market_ref1
rename Market_ref2 Market_ref
order Date Market_ref


save factors3, replace


********DO FILE ON "Coding Countries"**************


replace anationcode = ACQUIRER_fic if missing(anationcode)
replace anationcode = ACQUIROR_COUNTRY if missing(anationcode)
drop if missing(anationcode)


***A***
gen ACQUIRER_COUNTRY_2022=anationcode

***B***
gen TARGET_COUNTRY_2022=.
replace TARGET_COUNTRY_2022 = ACQUIRER_COUNTRY_2022 if CROSS_BORDER==0

gen CROSS_BORDER_2022=1 if ACQUIRER_COUNTRY_2022 != TARGET_COUNTRY_2022 
replace CROSS_BORDER_2022=0 if CROSS_BORDER_2022==.

*******All this is fixed manually********* 
gen CEO_COUNTRY_2022=.
replace CEO_COUNTRY_2022=1 if CEO_COUNTRY_C=="Algeria"
replace CEO_COUNTRY_2022=2 if CEO_COUNTRY_C=="Australia"
replace CEO_COUNTRY_2022=3 if CEO_COUNTRY_C=="Austria"
replace CEO_COUNTRY_2022=4 if CEO_COUNTRY_C=="Belgium"
replace CEO_COUNTRY_2022=5 if CEO_COUNTRY_C=="Brazil"
replace CEO_COUNTRY_2022=6 if CEO_COUNTRY_C=="Canada"
replace CEO_COUNTRY_2022=7 if CEO_COUNTRY_C=="Chile"
replace CEO_COUNTRY_2022=8 if CEO_COUNTRY_C=="China"
replace CEO_COUNTRY_2022=9 if CEO_COUNTRY_C=="Denmark"
replace CEO_COUNTRY_2022=10 if CEO_COUNTRY_C=="Egypt"
replace CEO_COUNTRY_2022=11 if CEO_COUNTRY_C=="Finland"
replace CEO_COUNTRY_2022=12 if CEO_COUNTRY_C=="France"
replace CEO_COUNTRY_2022=13 if CEO_COUNTRY_C=="Germany"
replace CEO_COUNTRY_2022=14 if CEO_COUNTRY_C=="Hong Kong"
replace CEO_COUNTRY_2022=15 if CEO_COUNTRY_C=="India"
replace CEO_COUNTRY_2022=16 if CEO_COUNTRY_C=="Iran"
replace CEO_COUNTRY_2022=17 if CEO_COUNTRY_C=="Ireland"
replace CEO_COUNTRY_2022=18 if CEO_COUNTRY_C=="Ireland-Rep"
replace CEO_COUNTRY_2022=19 if CEO_COUNTRY_C=="Israel"
replace CEO_COUNTRY_2022=20 if CEO_COUNTRY_C=="Italy"
replace CEO_COUNTRY_2022=21 if CEO_COUNTRY_C=="Japan"
replace CEO_COUNTRY_2022=22 if CEO_COUNTRY_C=="Jordan"
replace CEO_COUNTRY_2022=23 if CEO_COUNTRY_C=="Kazakhstan"
replace CEO_COUNTRY_2022=24 if CEO_COUNTRY_C=="Lebanon"
replace CEO_COUNTRY_2022=25 if CEO_COUNTRY_C=="Mexico"
replace CEO_COUNTRY_2022=26 if CEO_COUNTRY_C=="Morocco"
replace CEO_COUNTRY_2022=27 if CEO_COUNTRY_C=="Netherlands"
replace CEO_COUNTRY_2022=28 if CEO_COUNTRY_C=="New Zealand"
replace CEO_COUNTRY_2022=29 if CEO_COUNTRY_C=="Nigeria"
replace CEO_COUNTRY_2022=30 if CEO_COUNTRY_C=="Norway"
replace CEO_COUNTRY_2022=31 if CEO_COUNTRY_C=="Peru"
replace CEO_COUNTRY_2022=32 if CEO_COUNTRY_C=="Poland"
replace CEO_COUNTRY_2022=33 if CEO_COUNTRY_C=="Russian Fed"
replace CEO_COUNTRY_2022=34 if CEO_COUNTRY_C=="South Africa"
replace CEO_COUNTRY_2022=35 if CEO_COUNTRY_C=="South Korea"
replace CEO_COUNTRY_2022=36 if CEO_COUNTRY_C=="Spain"
replace CEO_COUNTRY_2022=37 if CEO_COUNTRY_C=="Sri Lanka"
replace CEO_COUNTRY_2022=38 if CEO_COUNTRY_C=="Sweden"
replace CEO_COUNTRY_2022=39 if CEO_COUNTRY_C=="Switzerland"
replace CEO_COUNTRY_2022=40 if CEO_COUNTRY_C=="Taiwan"
replace CEO_COUNTRY_2022=41 if CEO_COUNTRY_C=="Turkey"
replace CEO_COUNTRY_2022=42 if CEO_COUNTRY_C=="United Kingdom"
replace CEO_COUNTRY_2022=43 if CEO_COUNTRY_C=="United States"
replace CEO_COUNTRY_2022=44 if CEO_COUNTRY_C=="Zambia"
replace CEO_COUNTRY_2022=45 if CEO_COUNTRY_C=="Zimbabwe"
replace CEO_COUNTRY_2022=47 if CEO_COUNTRY_C=="Argentina"
replace CEO_COUNTRY_2022=48 if CEO_COUNTRY_C=="Armenia"
replace CEO_COUNTRY_2022=49 if CEO_COUNTRY_C=="Azerbaijan"
replace CEO_COUNTRY_2022=50 if CEO_COUNTRY_C=="Lithuania"
replace CEO_COUNTRY_2022=51 if CEO_COUNTRY_C=="Malaysia"
replace CEO_COUNTRY_2022=52 if CEO_COUNTRY_C=="Pakistan"
replace CEO_COUNTRY_2022=53 if CEO_COUNTRY_C=="Panama"
replace CEO_COUNTRY_2022=54 if CEO_COUNTRY_C=="Philippines"
replace CEO_COUNTRY_2022=55 if CEO_COUNTRY_C=="Romania"
replace CEO_COUNTRY_2022=56 if CEO_COUNTRY_C=="Saudi Arabia"
replace CEO_COUNTRY_2022=57 if CEO_COUNTRY_C=="Singapore"
replace CEO_COUNTRY_2022=58 if CEO_COUNTRY_C=="Thailand"
replace CEO_COUNTRY_2022=59 if CEO_COUNTRY_C=="Vietnam"
replace CEO_COUNTRY_2022=60 if CEO_COUNTRY_C=="Africa"
replace CEO_COUNTRY_2022=61 if CEO_COUNTRY_C=="Greece"
replace CEO_COUNTRY_2022=62 if CEO_COUNTRY_C=="Indonesia"
replace CEO_COUNTRY_2022=63 if CEO_COUNTRY_C=="Colombia"
replace CEO_COUNTRY_2022=64 if CEO_COUNTRY_C=="Malta"

********************************************************


replace CEO_COUNTRY_2022=2 if CEO_COUNTRY_BIRTH=="Australia"
replace CEO_COUNTRY_2022=3 if CEO_COUNTRY_BIRTH=="Austria"
replace CEO_COUNTRY_2022=4 if CEO_COUNTRY_BIRTH=="Belgium"
replace CEO_COUNTRY_2022=5 if CEO_COUNTRY_BIRTH=="Brazil"
replace CEO_COUNTRY_2022=6 if CEO_COUNTRY_BIRTH=="Canada"
replace CEO_COUNTRY_2022=7 if CEO_COUNTRY_BIRTH=="Chile"
replace CEO_COUNTRY_2022=8 if CEO_COUNTRY_BIRTH=="China"
replace CEO_COUNTRY_2022=9 if CEO_COUNTRY_BIRTH=="Denmark"
replace CEO_COUNTRY_2022=10 if CEO_COUNTRY_BIRTH=="Egypt"
replace CEO_COUNTRY_2022=11 if CEO_COUNTRY_BIRTH=="Finland"
replace CEO_COUNTRY_2022=12 if CEO_COUNTRY_BIRTH=="France"
replace CEO_COUNTRY_2022=13 if CEO_COUNTRY_BIRTH=="Germany"
replace CEO_COUNTRY_2022=14 if CEO_COUNTRY_BIRTH=="Hong Kong"
replace CEO_COUNTRY_2022=15 if CEO_COUNTRY_BIRTH=="India"
replace CEO_COUNTRY_2022=16 if CEO_COUNTRY_BIRTH=="Iran"
replace CEO_COUNTRY_2022=17 if CEO_COUNTRY_BIRTH=="Ireland"
replace CEO_COUNTRY_2022=18 if CEO_COUNTRY_BIRTH=="Ireland-Rep"
replace CEO_COUNTRY_2022=19 if CEO_COUNTRY_BIRTH=="Israel"
replace CEO_COUNTRY_2022=20 if CEO_COUNTRY_BIRTH=="Italy"
replace CEO_COUNTRY_2022=21 if CEO_COUNTRY_BIRTH=="Japan"
replace CEO_COUNTRY_2022=22 if CEO_COUNTRY_BIRTH=="Jordan"
replace CEO_COUNTRY_2022=23 if CEO_COUNTRY_BIRTH=="Kazakhstan"
replace CEO_COUNTRY_2022=24 if CEO_COUNTRY_BIRTH=="Lebanon"
replace CEO_COUNTRY_2022=25 if CEO_COUNTRY_BIRTH=="Mexico"
replace CEO_COUNTRY_2022=26 if CEO_COUNTRY_BIRTH=="Morocco"
replace CEO_COUNTRY_2022=27 if CEO_COUNTRY_BIRTH=="Netherlands"
replace CEO_COUNTRY_2022=28 if CEO_COUNTRY_BIRTH=="New Zealand"
replace CEO_COUNTRY_2022=29 if CEO_COUNTRY_BIRTH=="Nigeria"
replace CEO_COUNTRY_2022=30 if CEO_COUNTRY_BIRTH=="Norway"
replace CEO_COUNTRY_2022=31 if CEO_COUNTRY_BIRTH=="Peru"
replace CEO_COUNTRY_2022=32 if CEO_COUNTRY_BIRTH=="Poland"
replace CEO_COUNTRY_2022=33 if CEO_COUNTRY_BIRTH=="Russian Fed"
replace CEO_COUNTRY_2022=34 if CEO_COUNTRY_BIRTH=="South Africa"
replace CEO_COUNTRY_2022=35 if CEO_COUNTRY_BIRTH=="South Korea"
replace CEO_COUNTRY_2022=36 if CEO_COUNTRY_BIRTH=="Spain"
replace CEO_COUNTRY_2022=37 if CEO_COUNTRY_BIRTH=="Sri Lanka"
replace CEO_COUNTRY_2022=38 if CEO_COUNTRY_BIRTH=="Sweden"
replace CEO_COUNTRY_2022=39 if CEO_COUNTRY_BIRTH=="Switzerland"
replace CEO_COUNTRY_2022=40 if CEO_COUNTRY_BIRTH=="Taiwan"
replace CEO_COUNTRY_2022=41 if CEO_COUNTRY_BIRTH=="Turkey"
replace CEO_COUNTRY_2022=42 if CEO_COUNTRY_BIRTH=="United Kingdom"
replace CEO_COUNTRY_2022=43 if CEO_COUNTRY_BIRTH=="United States"
replace CEO_COUNTRY_2022=44 if CEO_COUNTRY_BIRTH=="Zambia"
replace CEO_COUNTRY_2022=45 if CEO_COUNTRY_BIRTH=="Zimbabwe"
replace CEO_COUNTRY_2022=47 if CEO_COUNTRY_BIRTH=="Argentina"
replace CEO_COUNTRY_2022=48 if CEO_COUNTRY_BIRTH=="Armenia"
replace CEO_COUNTRY_2022=49 if CEO_COUNTRY_BIRTH=="Azerbaijan"
replace CEO_COUNTRY_2022=50 if CEO_COUNTRY_BIRTH=="Lithuania"
replace CEO_COUNTRY_2022=51 if CEO_COUNTRY_BIRTH=="Malaysia"
replace CEO_COUNTRY_2022=52 if CEO_COUNTRY_BIRTH=="Pakistan"
replace CEO_COUNTRY_2022=53 if CEO_COUNTRY_BIRTH=="Panama"
replace CEO_COUNTRY_2022=54 if CEO_COUNTRY_BIRTH=="Philippines"
replace CEO_COUNTRY_2022=55 if CEO_COUNTRY_BIRTH=="Romania"
replace CEO_COUNTRY_2022=56 if CEO_COUNTRY_BIRTH =="Saudi Arabia"
replace CEO_COUNTRY_2022=57 if CEO_COUNTRY_BIRTH=="Singapore"
replace CEO_COUNTRY_2022=58 if CEO_COUNTRY_BIRTH=="Thailand"
replace CEO_COUNTRY_2022=59 if CEO_COUNTRY_BIRTH=="Vietnam"
replace CEO_COUNTRY_2022=60 if CEO_COUNTRY_BIRTH=="Africa"
replace CEO_COUNTRY_2022=61 if CEO_COUNTRY_BIRTH=="Greece"
replace CEO_COUNTRY_2022=62 if CEO_COUNTRY_BIRTH=="Indonesia"
replace CEO_COUNTRY_2022=63 if CEO_COUNTRY_BIRTH=="Colombia"
replace CEO_COUNTRY_2022=64 if CEO_COUNTRY_BIRTH=="Malta"
 
 ****************************
  
replace CEO_COUNTRY_2022=1 if ceo_country=="Algeria"
replace CEO_COUNTRY_2022=2 if ceo_country=="AT"
replace CEO_COUNTRY_2022=2 if ceo_country=="AU"
replace CEO_COUNTRY_2022=3 if ceo_country=="AS"
replace CEO_COUNTRY_2022=4 if ceo_country=="BE"
replace CEO_COUNTRY_2022=6 if ceo_country=="CA"
replace CEO_COUNTRY_2022=7 if ceo_country=="Chile"
replace CEO_COUNTRY_2022=8 if ceo_country=="China"
replace CEO_COUNTRY_2022=9 if ceo_country=="DK"
replace CEO_COUNTRY_2022=10 if ceo_country=="Egypt"
replace CEO_COUNTRY_2022=11 if ceo_country=="FI"
replace CEO_COUNTRY_2022=12 if ceo_country=="FR"
replace CEO_COUNTRY_2022=13 if ceo_country=="DE"
replace CEO_COUNTRY_2022=14 if ceo_country=="Hong Kong"
replace CEO_COUNTRY_2022=15 if ceo_country=="India"
replace CEO_COUNTRY_2022=16 if ceo_country=="Iran"
replace CEO_COUNTRY_2022=17 if ceo_country=="IR"
replace CEO_COUNTRY_2022=18 if ceo_country=="Ireland-Rep"
replace CEO_COUNTRY_2022=19 if ceo_country=="Israel"
replace CEO_COUNTRY_2022=20 if ceo_country=="IT"
replace CEO_COUNTRY_2022=21 if ceo_country=="Japan"
replace CEO_COUNTRY_2022=22 if ceo_country=="Jordan"
replace CEO_COUNTRY_2022=23 if ceo_country=="KZ"
replace CEO_COUNTRY_2022=24 if ceo_country=="Lebanon"
replace CEO_COUNTRY_2022=25 if ceo_country=="Mexico"
replace CEO_COUNTRY_2022=26 if ceo_country=="Morocco"
replace CEO_COUNTRY_2022=27 if ceo_country=="NL"
replace CEO_COUNTRY_2022=28 if ceo_country=="New Zealand"
replace CEO_COUNTRY_2022=29 if ceo_country=="Nigeria"
replace CEO_COUNTRY_2022=30 if ceo_country=="NO"
replace CEO_COUNTRY_2022=31 if ceo_country=="Peru"
replace CEO_COUNTRY_2022=32 if ceo_country=="PL"
replace CEO_COUNTRY_2022=33 if ceo_country=="RU"
replace CEO_COUNTRY_2022=34 if ceo_country=="ZA"
replace CEO_COUNTRY_2022=35 if ceo_country=="South Korea"
replace CEO_COUNTRY_2022=36 if ceo_country=="ES"
replace CEO_COUNTRY_2022=37 if ceo_country=="Sri Lanka"
replace CEO_COUNTRY_2022=38 if ceo_country=="SW"
replace CEO_COUNTRY_2022=39 if ceo_country=="CH"
replace CEO_COUNTRY_2022=40 if ceo_country=="Taiwan"
replace CEO_COUNTRY_2022=41 if ceo_country=="Turkey"
replace CEO_COUNTRY_2022=42 if ceo_country=="GB"
replace CEO_COUNTRY_2022=43 if ceo_country=="US"
replace CEO_COUNTRY_2022=44 if ceo_country=="Zambia"
replace CEO_COUNTRY_2022=45 if ceo_country=="Zimbabwe"
replace CEO_COUNTRY_2022=46 if ceo_country=="LU"
replace CEO_COUNTRY_2022=47 if ceo_country=="AR"
replace CEO_COUNTRY_2022=48 if ceo_country=="Armenia"
replace CEO_COUNTRY_2022=49 if ceo_country=="Azerbaijan"
replace CEO_COUNTRY_2022=50 if ceo_country=="Lithuania"
replace CEO_COUNTRY_2022=51 if ceo_country=="Malaysia"
replace CEO_COUNTRY_2022=52 if ceo_country=="Pakistan"
replace CEO_COUNTRY_2022=53 if ceo_country=="Panama"
replace CEO_COUNTRY_2022=54 if ceo_country=="Philippines"
replace CEO_COUNTRY_2022=55 if ceo_country=="Romania"
replace CEO_COUNTRY_2022=56 if ceo_country=="Saudi Arabia"
replace CEO_COUNTRY_2022=57 if ceo_country=="Singapore"
replace CEO_COUNTRY_2022=58 if ceo_country=="Thailand"
replace CEO_COUNTRY_2022=59 if ceo_country=="Vietnam"
replace CEO_COUNTRY_2022=60 if ceo_country=="Africa"
replace CEO_COUNTRY_2022=61 if ceo_country=="GR"
replace CEO_COUNTRY_2022=62 if ceo_country=="Indonesia"
replace CEO_COUNTRY_2022=63 if ceo_country=="Colombia"
replace CEO_COUNTRY_2022=64 if ceo_country=="MA" 
**Malta**
replace CEO_COUNTRY_2022=65 if ceo_country=="PG"
replace CEO_COUNTRY_2022=66 if ceo_country=="HU"
replace CEO_COUNTRY_2022=67 if ceo_country=="SL"
replace CEO_COUNTRY_2022=68 if ceo_country=="CZ"



*********Transform letters in Numbers
gen ACQUIRER_COUNTRY_Numb=.


replace ACQUIRER_COUNTRY_Numb=1 if TARGET_COUNTRY_2022=="Algeria"
replace ACQUIRER_COUNTRY_Numb=2 if ACQUIRER_COUNTRY_2022=="AT" 
*Australia*
replace ACQUIRER_COUNTRY_Numb=2 if ACQUIRER_COUNTRY_2022=="AU" 
*Australia*
replace ACQUIRER_COUNTRY_Numb=3 if ACQUIRER_COUNTRY_2022=="AS" 
**Austria**
replace ACQUIRER_COUNTRY_Numb=4 if ACQUIRER_COUNTRY_2022=="BL"  
**Belgio**
replace ACQUIRER_COUNTRY_Numb=5 if ACQUIRER_COUNTRY_2022=="BR" 
**Brazil**
replace ACQUIRER_COUNTRY_Numb=6 if ACQUIRER_COUNTRY_2022=="CA" 
replace ACQUIRER_COUNTRY_Numb=7 if ACQUIRER_COUNTRY_2022=="CE" 
***Chile**
replace ACQUIRER_COUNTRY_Numb=8 if ACQUIRER_COUNTRY_2022=="CH" 
**China**
replace ACQUIRER_COUNTRY_Numb=9 if ACQUIRER_COUNTRY_2022=="DN" 
**Denmark***
replace ACQUIRER_COUNTRY_Numb=10 if ACQUIRER_COUNTRY_2022=="EG"
**Egypt**
replace ACQUIRER_COUNTRY_Numb=11 if ACQUIRER_COUNTRY_2022=="FIN"
replace ACQUIRER_COUNTRY_Numb=12 if ACQUIRER_COUNTRY_2022=="FRA"
replace ACQUIRER_COUNTRY_Numb=13 if ACQUIRER_COUNTRY_2022=="DEU" 
**also DE***
replace ACQUIRER_COUNTRY_Numb=14 if ACQUIRER_COUNTRY_2022=="HK" 
**Hong Kong**
replace ACQUIRER_COUNTRY_Numb=15 if ACQUIRER_COUNTRY_2022=="IN" 
**India**
replace ACQUIRER_COUNTRY_Numb=16 if ACQUIRER_COUNTRY_2022=="Iran"
replace ACQUIRER_COUNTRY_Numb=17 if ACQUIRER_COUNTRY_2022=="IR"
replace ACQUIRER_COUNTRY_Numb=18 if ACQUIRER_COUNTRY_2022=="IRL" 
**Ireland-Rep**
replace ACQUIRER_COUNTRY_Numb=19 if ACQUIRER_COUNTRY_2022=="ISR" 
**Israel**
replace ACQUIRER_COUNTRY_Numb=20 if ACQUIRER_COUNTRY_2022=="ITA"
replace ACQUIRER_COUNTRY_Numb=21 if ACQUIRER_COUNTRY_2022=="JP"
replace ACQUIRER_COUNTRY_Numb=22 if ACQUIRER_COUNTRY_2022=="Jordan"
replace ACQUIRER_COUNTRY_Numb=23 if ACQUIRER_COUNTRY_2022=="KZ" 
**Kazakistan**
replace ACQUIRER_COUNTRY_Numb=24 if ACQUIRER_COUNTRY_2022=="Lebanon"
replace ACQUIRER_COUNTRY_Numb=25 if ACQUIRER_COUNTRY_2022=="MEX" 
**Mexico**
replace ACQUIRER_COUNTRY_Numb=26 if ACQUIRER_COUNTRY_2022=="Morocco"
replace ACQUIRER_COUNTRY_Numb=27 if ACQUIRER_COUNTRY_2022=="NLD" 
**Netherlands
replace ACQUIRER_COUNTRY_Numb=28 if ACQUIRER_COUNTRY_2022=="NZL" 
**New Zealand**
replace ACQUIRER_COUNTRY_Numb=29 if ACQUIRER_COUNTRY_2022=="NGA" 
**Nigeria**
replace ACQUIRER_COUNTRY_Numb=30 if ACQUIRER_COUNTRY_2022=="NOR" 
**Norway**
replace ACQUIRER_COUNTRY_Numb=31 if ACQUIRER_COUNTRY_2022=="Peru"
replace ACQUIRER_COUNTRY_Numb=32 if ACQUIRER_COUNTRY_2022=="POL" 
**Poland also PL**
replace ACQUIRER_COUNTRY_Numb=33 if ACQUIRER_COUNTRY_2022=="RU" 
**Russian Fed**
replace ACQUIRER_COUNTRY_Numb=34 if ACQUIRER_COUNTRY_2022=="ZAF" 
*South Africa
replace ACQUIRER_COUNTRY_Numb=35 if ACQUIRER_COUNTRY_2022=="KOR" 
**South Korea**
replace ACQUIRER_COUNTRY_Numb=36 if ACQUIRER_COUNTRY_2022=="ESP"
**also ES**
replace ACQUIRER_COUNTRY_Numb=37 if ACQUIRER_COUNTRY_2022=="LKA" 
**Sri Lanka**
replace ACQUIRER_COUNTRY_Numb=38 if ACQUIRER_COUNTRY_2022=="SWE" 
**Sweden also SW**
replace ACQUIRER_COUNTRY_Numb=39 if ACQUIRER_COUNTRY_2022=="SZ"
**Switzerland..note that in ceo_country is coded CH"
replace ACQUIRER_COUNTRY_Numb=40 if ACQUIRER_COUNTRY_2022=="TW" 
**Taiwan**
replace ACQUIRER_COUNTRY_Numb=41 if ACQUIRER_COUNTRY_2022=="TK" 
**Turkey**
replace ACQUIRER_COUNTRY_Numb=42 if ACQUIRER_COUNTRY_2022=="GBR"
replace ACQUIRER_COUNTRY_Numb=43 if ACQUIRER_COUNTRY_2022=="USA"
replace ACQUIRER_COUNTRY_Numb=44 if ACQUIRER_COUNTRY_2022=="ZA"
**Zambia"
replace ACQUIRER_COUNTRY_Numb=45 if ACQUIRER_COUNTRY_2022=="Zimbabwe"
replace ACQUIRER_COUNTRY_Numb=46 if ACQUIRER_COUNTRY_2022=="LUX" 
**Luxemburg also LU**
replace ACQUIRER_COUNTRY_Numb=47 if ACQUIRER_COUNTRY_2022=="AR" 
**Argentina**
replace ACQUIRER_COUNTRY_Numb=48 if ACQUIRER_COUNTRY_2022=="Armenia"
replace ACQUIRER_COUNTRY_Numb=49 if ACQUIRER_COUNTRY_2022=="Azerbaijan"
replace ACQUIRER_COUNTRY_Numb=50 if ACQUIRER_COUNTRY_2022=="LT" 
**Lithuania
replace ACQUIRER_COUNTRY_Numb=51 if ACQUIRER_COUNTRY_2022=="MA" 
**Malaysia"
replace ACQUIRER_COUNTRY_Numb=52 if ACQUIRER_COUNTRY_2022=="PAK" 
**Pakistan**
replace ACQUIRER_COUNTRY_Numb=53 if ACQUIRER_COUNTRY_2022=="Panama"
replace ACQUIRER_COUNTRY_Numb=54 if ACQUIRER_COUNTRY_2022=="PHL" 
**Philippines**
replace ACQUIRER_COUNTRY_Numb=55 if ACQUIRER_COUNTRY_2022=="RO" 
**Romania**
replace ACQUIRER_COUNTRY_Numb=56 if ACQUIRER_COUNTRY_2022=="SAU"
**Saudi Arabia**
replace ACQUIRER_COUNTRY_Numb=57 if ACQUIRER_COUNTRY_2022=="SGP"
***Singapore**
replace ACQUIRER_COUNTRY_Numb=58 if ACQUIRER_COUNTRY_2022=="TH"
**Thailand**
replace ACQUIRER_COUNTRY_Numb=59 if ACQUIRER_COUNTRY_2022=="VNM"
**Vietnam**
replace ACQUIRER_COUNTRY_Numb=60 if ACQUIRER_COUNTRY_2022=="Africa"
replace ACQUIRER_COUNTRY_Numb=61 if ACQUIRER_COUNTRY_2022=="GRC" 
**Greece also GR***
replace ACQUIRER_COUNTRY_Numb=62 if ACQUIRER_COUNTRY_2022=="IDN" 
**Indonesia**
replace ACQUIRER_COUNTRY_Numb=63 if ACQUIRER_COUNTRY_2022=="CO" 
**Colombia**
replace ACQUIRER_COUNTRY_Numb=64 if ACQUIRER_COUNTRY_2022=="MT" 
*Malta**
replace ACQUIRER_COUNTRY_Numb=65 if ACQUIRER_COUNTRY_2022=="PG"
replace ACQUIRER_COUNTRY_Numb=66 if ACQUIRER_COUNTRY_2022=="HUN" 
**Hungary**
replace ACQUIRER_COUNTRY_Numb=67 if ACQUIRER_COUNTRY_2022=="SVN" 
**Slovenia also SL**
replace ACQUIRER_COUNTRY_Numb=68 if ACQUIRER_COUNTRY_2022=="CZE" 
**Czech Republic - also CZ**
replace ACQUIRER_COUNTRY_Numb=69 if ACQUIRER_COUNTRY_2022=="BE" 
replace ACQUIRER_COUNTRY_Numb=70 if ACQUIRER_COUNTRY_2022=="CT" 
***Croatia*** 
replace ACQUIRER_COUNTRY_Numb=71 if ACQUIRER_COUNTRY_2022=="CUW" 
***Curacao***
replace ACQUIRER_COUNTRY_Numb=72 if ACQUIRER_COUNTRY_2022=="CYP" 
***CYP***
replace ACQUIRER_COUNTRY_Numb=73 if ACQUIRER_COUNTRY_2022=="MA" 
***Malta***
replace ACQUIRER_COUNTRY_Numb=74 if ACQUIRER_COUNTRY_2022=="PNG" 
***Papa Guinea***

replace ACQUIRER_COUNTRY_Numb=75 if ACQUIRER_COUNTRY_2022=="PRT" 
***Portugal to check as only one obs..***





*********Transform letters in Numbers
gen TARGET_COUNTRY_Numb=.


replace TARGET_COUNTRY_Numb=1 if TARGET_COUNTRY_2022=="Algeria"
replace TARGET_COUNTRY_Numb=2 if TARGET_COUNTRY_2022=="AT" 
*Australia*
replace TARGET_COUNTRY_Numb=2 if TARGET_COUNTRY_2022=="AU" 
*Australia*
replace TARGET_COUNTRY_Numb=3 if TARGET_COUNTRY_2022=="AS" 
**Austria**
replace TARGET_COUNTRY_Numb=4 if TARGET_COUNTRY_2022=="BL"  
**Belgio**
replace TARGET_COUNTRY_Numb=5 if TARGET_COUNTRY_2022=="BR" 
**Brazil**
replace TARGET_COUNTRY_Numb=6 if TARGET_COUNTRY_2022=="CA" 
replace TARGET_COUNTRY_Numb=7 if TARGET_COUNTRY_2022=="CE" 
***Chile**
replace TARGET_COUNTRY_Numb=8 if TARGET_COUNTRY_2022=="CH" 
**China**
replace TARGET_COUNTRY_Numb=9 if TARGET_COUNTRY_2022=="DN" 
**Denmark***
replace TARGET_COUNTRY_Numb=10 if TARGET_COUNTRY_2022=="EG"
**Egypt**
replace TARGET_COUNTRY_Numb=11 if TARGET_COUNTRY_2022=="FIN"
replace TARGET_COUNTRY_Numb=12 if TARGET_COUNTRY_2022=="FRA"
replace TARGET_COUNTRY_Numb=13 if TARGET_COUNTRY_2022=="DEU" 
**also DE***
replace TARGET_COUNTRY_Numb=14 if TARGET_COUNTRY_2022=="HK" 
**Hong Kong**
replace TARGET_COUNTRY_Numb=15 if TARGET_COUNTRY_2022=="IN" 
**India**
replace TARGET_COUNTRY_Numb=16 if TARGET_COUNTRY_2022=="Iran"
replace TARGET_COUNTRY_Numb=17 if TARGET_COUNTRY_2022=="IR"
replace TARGET_COUNTRY_Numb=18 if TARGET_COUNTRY_2022=="IRL" 
**Ireland-Rep**
replace TARGET_COUNTRY_Numb=19 if TARGET_COUNTRY_2022=="IS" 
**Israel**
replace TARGET_COUNTRY_Numb=20 if TARGET_COUNTRY_2022=="ITA"
replace TARGET_COUNTRY_Numb=21 if TARGET_COUNTRY_2022=="JP"
replace TARGET_COUNTRY_Numb=22 if TARGET_COUNTRY_2022=="Jordan"
replace TARGET_COUNTRY_Numb=23 if TARGET_COUNTRY_2022=="KZ" 
**Kazakistan**
replace TARGET_COUNTRY_Numb=24 if TARGET_COUNTRY_2022=="Lebanon"
replace TARGET_COUNTRY_Numb=25 if TARGET_COUNTRY_2022=="MEX" 
**Mexico**
replace TARGET_COUNTRY_Numb=26 if TARGET_COUNTRY_2022=="MR"
**Morocco**
replace TARGET_COUNTRY_Numb=27 if TARGET_COUNTRY_2022=="NLD" 
**Netherlands
replace TARGET_COUNTRY_Numb=28 if TARGET_COUNTRY_2022=="NZL" 
**New Zealand**
replace TARGET_COUNTRY_Numb=29 if TARGET_COUNTRY_2022=="NGA" 
**Nigeria**
replace TARGET_COUNTRY_Numb=30 if TARGET_COUNTRY_2022=="NOR" 
**Norway**
replace TARGET_COUNTRY_Numb=31 if TARGET_COUNTRY_2022=="PE" 
**Peru**
replace TARGET_COUNTRY_Numb=32 if TARGET_COUNTRY_2022=="POL" 
**Poland also PL**
replace TARGET_COUNTRY_Numb=33 if TARGET_COUNTRY_2022=="RU" 
**Russian Fed**
replace TARGET_COUNTRY_Numb=34 if TARGET_COUNTRY_2022=="ZAF" 
*South Africa
replace TARGET_COUNTRY_Numb=35 if TARGET_COUNTRY_2022=="KOR" 
**South Korea**
replace TARGET_COUNTRY_Numb=36 if TARGET_COUNTRY_2022=="ESP"
**also ES**
replace TARGET_COUNTRY_Numb=37 if TARGET_COUNTRY_2022=="LKA" 
**Sri Lanka**
replace TARGET_COUNTRY_Numb=38 if TARGET_COUNTRY_2022=="SWE" 
**Sweden also SW**
replace TARGET_COUNTRY_Numb=39 if TARGET_COUNTRY_2022=="SZ"
**Switzerland..note that in ceo_country is coded CH"
replace TARGET_COUNTRY_Numb=40 if TARGET_COUNTRY_2022=="TW" 
**Taiwan**
replace TARGET_COUNTRY_Numb=41 if TARGET_COUNTRY_2022=="TK" 
**Turkey**
replace TARGET_COUNTRY_Numb=42 if TARGET_COUNTRY_2022=="GBR"
replace TARGET_COUNTRY_Numb=43 if TARGET_COUNTRY_2022=="USA"
replace TARGET_COUNTRY_Numb=44 if TARGET_COUNTRY_2022=="ZA"
**Zambia"
replace TARGET_COUNTRY_Numb=45 if TARGET_COUNTRY_2022=="Zimbabwe"
replace TARGET_COUNTRY_Numb=46 if TARGET_COUNTRY_2022=="LUX" 
**Luxemburg also LU**
replace TARGET_COUNTRY_Numb=47 if TARGET_COUNTRY_2022=="AR" 
**Argentina**
replace TARGET_COUNTRY_Numb=48 if TARGET_COUNTRY_2022=="Armenia"
replace TARGET_COUNTRY_Numb=49 if TARGET_COUNTRY_2022=="Azerbaijan"
replace TARGET_COUNTRY_Numb=50 if TARGET_COUNTRY_2022=="LT" 
**Lithuania
replace TARGET_COUNTRY_Numb=51 if TARGET_COUNTRY_2022=="MA" 
**Malaysia"
replace TARGET_COUNTRY_Numb=52 if TARGET_COUNTRY_2022=="PAK" 
**Pakistan**
replace TARGET_COUNTRY_Numb=53 if TARGET_COUNTRY_2022=="Panama"
replace TARGET_COUNTRY_Numb=54 if TARGET_COUNTRY_2022=="PHL" 
**Philippines**
replace TARGET_COUNTRY_Numb=55 if TARGET_COUNTRY_2022=="RO" 
**Romania**
replace TARGET_COUNTRY_Numb=56 if TARGET_COUNTRY_2022=="SAU"
**Saudi Arabia**
replace TARGET_COUNTRY_Numb=57 if TARGET_COUNTRY_2022=="SGP"
***Singapore**
replace TARGET_COUNTRY_Numb=58 if TARGET_COUNTRY_2022=="TH"
**Thailand**
replace TARGET_COUNTRY_Numb=59 if TARGET_COUNTRY_2022=="VNM"
**Vietnam**
replace TARGET_COUNTRY_Numb=60 if TARGET_COUNTRY_2022=="Africa"
replace TARGET_COUNTRY_Numb=61 if TARGET_COUNTRY_2022=="GRC" 
**Greece also GR***
replace TARGET_COUNTRY_Numb=62 if TARGET_COUNTRY_2022=="IDN" 
**Indonesia**
replace TARGET_COUNTRY_Numb=63 if TARGET_COUNTRY_2022=="CO" 
**Colombia**
replace TARGET_COUNTRY_Numb=64 if TARGET_COUNTRY_2022=="MT" 
*Malta**
replace TARGET_COUNTRY_Numb=65 if TARGET_COUNTRY_2022=="PG"
replace TARGET_COUNTRY_Numb=66 if TARGET_COUNTRY_2022=="HUN" 
**Hungary**
replace TARGET_COUNTRY_Numb=67 if TARGET_COUNTRY_2022=="SVN" 
**Slovenia also SL**
replace TARGET_COUNTRY_Numb=68 if TARGET_COUNTRY_2022=="CZ" 
replace TARGET_COUNTRY_Numb=68 if TARGET_COUNTRY_2022=="CC" 
**Czech Republic - also CZE and CC****
replace TARGET_COUNTRY_Numb=69 if TARGET_COUNTRY_2022=="BE" 
replace TARGET_COUNTRY_Numb=70 if TARGET_COUNTRY_2022=="CT" 
***Croatia*** 
replace TARGET_COUNTRY_Numb=71 if TARGET_COUNTRY_2022=="CUW" 
***Curacao***
replace TARGET_COUNTRY_Numb=72 if TARGET_COUNTRY_2022=="CYP" 
***CYP***
replace TARGET_COUNTRY_Numb=73 if TARGET_COUNTRY_2022=="MA" 
***Malta***
replace TARGET_COUNTRY_Numb=74 if TARGET_COUNTRY_2022=="PNG" 
***Papa Guinea***

replace TARGET_COUNTRY_Numb=75 if TARGET_COUNTRY_2022=="PRT" 
***Pportugal to check as only one obs..***

*****for having only data with countries identifications*********
drop if CEO_COUNTRY_2022==.




*******************gen CEO_NON_DOMESTIC_2022=0************

gen CEO_NON_DOMESTIC_2022=0
replace CEO_NON_DOMESTIC_2022=1 if ACQUIRER_COUNTRY_Numb!=CEO_COUNTRY_2022



************* We complement the Dataset with information from the following two Databases:
** World Values Survey: from which we obtatin CHARITY-related information by countries
** Gravity: we obtain data related to sanction imposition and sanction threat among Countries from 2000 to 2013. The original Dataset is composed of a binary relation among 2 countries (origin and destination) for each year. We have transformed those data to obtain Country-Year observations for easiness of use (see Variables Description for additional information)
** We merge these datasets with the orignial one using Country_Code as variable **
******************************************
******** FAMA FRENCH 12 Industries********
******************************************

use "2. All Data for Analysis - Round 3.dta", clear

drop ACQUIRER_ind TARGET_ind

* fill missing data for first DB SICs *
replace ACQUIRER_sic=ACQUIROR_SIC if missing(ACQUIRER_sic)
replace TARGET_sic=TARGET_SIC if missing(TARGET_sic)

* Acquirers
destring ACQUIRER_sic, replace
replace ACQUIRER_sic=ACQUIRER_sich if missing(ACQUIRER_sic)
sicff ACQUIRER_sic, ind(12) gen(ACQUIRER_ind)

* Targets
destring TARGET_sic, replace
replace TARGET_sic=TARGET_sich if missing(TARGET_sic)
sicff TARGET_sic, ind(12) gen(TARGET_ind)

*******************************************
******** Country Pair Fixed Effects********
*******************************************
drop Country_pair_FE Country_pair_FIXEFF

egen Country_Pair_FE=group(ACQUIRER_Country TARGET_Country)

save "2. All Data for Analysis with Added Vars- Round 3.dta", replace

********************************
******** EXPAND DATASET ********
********************************


**** Expand Dataset for NON-Domestic CEOs, by number of possible Target Countries ****

use "2. All Data for Analysis with Added Vars- Round 3.dta", clear

* Keep only Cross Border deals
keep if CROSS_BORDER_DEALS==1
tab TARGET_Country_Code

* TARGET_Country_Code 1 to 66 except 25, 28, 32, 35, 36, 37, 39, 43, 44, 49, 50, 51, 52, 53, 54, 56, 57, 59, 60, 61, 62, 63, 64: 43 target countries appear in the main dataset
* We consider each of these countries as potential target options (regardless of whether they were picked by a Non-Domestic CEO)
tab NONDOMESTIC_CEO
* which are 190 CEOs in total

* Each deal will have 66 potential target countries (the non-existing options will be dropped later)
expand 66
sort master_deal_no dateann
* There 66 exactly same rows of each deal

* We enumerate each option (which NOW makes each line per deal an alternative: i.e. each line is the same deal with a different TARGET_Country)
bys master_deal_no dateann: gen TARGET_Option=_n
*Flagging the country option that was actually picked by the CEO
gen TARGET_COUNTRY=1 if TARGET_Country_Code==TARGET_Option
replace TARGET_COUNTRY=0 if missing(TARGET_COUNTRY)
*dropping the options that did not appear in the actual Target Countries list above
drop if TARGET_Option==25 | TARGET_Option==28 | TARGET_Option==32 | TARGET_Option==35 | TARGET_Option==36 | TARGET_Option==37 | TARGET_Option==39 | TARGET_Option==43 | TARGET_Option==44 | TARGET_Option==49 | TARGET_Option==50 | TARGET_Option==51 | TARGET_Option==52 | TARGET_Option==53 | TARGET_Option==54 | TARGET_Option==56 | TARGET_Option==57 | TARGET_Option==59 | TARGET_Option==60 | TARGET_Option==61 | TARGET_Option==62 | TARGET_Option==63  | TARGET_Option==64
tab TARGET_Option
* needs to be same list as "tab TARGET_Country_Code", except there should be 542 obs of each
* we drop the Domestic CEOs and keep the Non-Domestic CEOs only (190 CEOs)
keep if NONDOMESTIC_CEO==1
* same country list, but now there should be 406obs for each target country option
tab TARGET_Option

* we adjust the CEO_COUNTRY. Now it should be coded 1 if the birth country is the same as the target option (not necessarily the actual target country) 
gen CEO_TARGET_MATCH_EXPAND=1 if CEO_COUNTRY_CODE==TARGET_Option
replace CEO_TARGET_MATCH_EXPAND=0 if missing(CEO_TARGET_MATCH_EXPAND)

save "2. All Data for Analysis EXPANDED- Round 3.dta", replace