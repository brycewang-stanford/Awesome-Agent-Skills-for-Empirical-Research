***start from M&A sample from SDC
use "K:\M&A and Committee\merger SDC.dta",clear

replace DateAnnounced(DateAnnounced,"DMY",2050)
replace DateEffective=date(DateEffective,"DMY",2050)

***merge with hostile M&A indicator file
joinby DateAnnounced TargetName AcquirorName using "K:\M&A and Committee\hostile indicator.dta",unm(m)
drop _merge
duplicates drop

***obtain statename and statecode for acquirors and targets
replace statename_tar=TargetState if strlen(TargetState)==2
replace statename_acq=AcquirorState if strlen(AcquirorState)==2

ren TargetState statefullname
joinby statefullname using "K:\M&A and Committee\statename-statecode.dta",unm(m)
drop _merge
duplicates drop
replace statename_tar=statename if statename_tar==""
replace statename=statename_tar if statename==""

drop statename statefullname statefullname1
ren statecode statecode_tar

ren AcquirorState statefullname
joinby statefullname using "K:\M&A and Committee\statename-statecode.dta",unm(m)
drop _merge
duplicates drop
replace statename_acq=statename if statename_acq==""
replace statename=statename_tar if statename==""

drop statename statefullname statefullname1
ren statecode statecode_acq

***merge with approval date hand-collection file
joinby DateAnnounced TargetName AcquirorName using "K:\M&A and Committee\real date for approval.dta",unm(m)
drop _merge
duplicates drop

***merge with M&A regulatory outcome manually verified data
joinby DateAnnounced DateEffective TargetName AcquirorName using "K:\M&A and Committee\regulatory outcome.dta",unm(m)
drop _merge
duplicates drop

***cleansing M&A deals
drop if DateAnn==.
gen year=yofd(DateAnn)
drop if (AcquirorNation!="United States"&year<2017)
drop if Status=="Intended"
drop if Status=="Intent W"
gen dateann=DateAnnounced
format dateann %td
gen dateeff=DateEffective
format dateeff %td
gen duration= dateeff-dateann

***standardize CUSIP for acquiror and target firms
replace TargetCUSIP="0"+TargetCUSIP if strlen(TargetCUSIP)==5
replace TargetCUSIP="00"+TargetCUSIP if strlen(TargetCUSIP)==4
replace TargetCUSIP="000"+TargetCUSIP if strlen(TargetCUSIP)==3
replace TargetCUSIP="0000"+TargetCUSIP if strlen(TargetCUSIP)==2

replace AcquirorCUSIP="0"+AcquirorCUSIP if strlen(AcquirorCUSIP)==5
replace AcquirorCUSIP="00"+AcquirorCUSIP if strlen(AcquirorCUSIP)==4
replace AcquirorCUSIP="000"+AcquirorCUSIP if strlen(AcquirorCUSIP)==3
replace AcquirorCUSIP="0000"+AcquirorCUSIP if strlen(AcquirorCUSIP)==2

***drop deals with same acquiror/target pairs
drop if TargetCUSIP==AcquirorCUSIP|TargetName==AcquirorName

***obtain acquiror GVKEY
ren AcquirorCUSIP cusip6
joinby cusip6 using "K:\M&A and Committee\gvkey-cusip-permno.dta",unm(m)
drop _merge
duplicates drop

***obtain company name from Compustat
joinby gvkey using "K:\M&A and Committee\gvkey-conm.dta",unm(m)
drop _merge
duplicates drop

***merge acquiror with state-operation concentration data (Garcia and Norli) 
joinby gvkey year using "K:\M&A and Committee\state_op_num1.dta",unm(m)
drop _merge
duplicates drop
replace state_op_num1=0 if state_op_num1==.&year<2017
ren state_op_num1 state_op_num_acq

***merge with employee data
joinby gvkey year using "K:\M&A and Committee\employee.dta",unm(m)
drop _merge
duplicates drop

***merge with firm variables based on Compustat
joinby gvkey year using "K:\M&A and Committee\firm factor.dta",unm(m)
drop _merge
duplicates drop

***merge with firm market share within 3-digit SIC industry
joinby gvkey year using "K:\M&A and Committee\market share sic3.dta",unm(m)
drop _merge
duplicates drop

***merge with politicial connection data from BoardEx
joinby gvkey year using "K:\M&A and Committee\political connection.dta",unm(m)
drop _merge
duplicates drop

***merge with firm lobbying data (Congress and FTC/DOJ)
joinby gvkey year using "K:\M&A and Committee\gvkey lobby.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\gvkey ftcdoj.dta",unm(m)
drop _merge
duplicates drop
replace ftcdoj=0 if ftcdoj==.

***merge with firm political contribution data
joinby gvkey year using "K:\M&A and Committee\FEC firm contribution to congress.dta",unm(m)
drop _merge
duplicates drop

drop cusip permno permco cusip8


********below we repeat the process bove to match target firm with all the variables**********
ren TargetCUSIP cusip6

joinby cusip6 year using "K:\M&A and Committee\gvkey-permno-cusip.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey using "K:\M&A and Committee\gvkey-conm.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\firm factor.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\market share sic3.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\state_op_num1.dta",unm(m)
drop _merge
duplicates drop
replace state_op_num1=0 if state_op_num1==.&year<2017
ren state_op_num1 state_op_num_tar

joinby gvkey year using "K:\M&A and Committee\gvkey lobby.dta",unm(m)
drop _merge
duplicates drop
drop sic*

joinby gvkey year using "K:\M&A and Committee\FEC firm contribution to congress.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\gvkey ftcdoj.dta",unm(m)
drop _merge
duplicates drop
replace ftcdoj=0 if ftcdoj==.

joinby gvkey year using "K:\M&A and Committee\political connection.dta",unm(m)
drop _merge
duplicates drop

drop cusip permno permco cusip8

drop if gvkey_acq==.
drop if year<1998|year>2016
keep if gvkey_tar!=.
drop if value==.




****below we match target with politician by district/state to calculate the committee seniority
joinby gvkey year using "K:\M&A and Committee\house seniority district.dta",unm(m)
drop _merge
duplicates drop

ren statecode_tar statecode
joinby statecode year using "K:\M&A and Committee\senate seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\senate seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\congress seniority other committee.dta",unm(m)
drop _merge
duplicates drop

foreach var of varlist totalcongress-contributiontocongresssub ftcdoj house_totalseniority-house_seniority_all firmage antitakeover {
ren `var' `var'_tar
}

****below we match acquiror with politician by district/state to calculate the committee seniority
ren gvkey gvkey_tar
ren gvkey_acq gvkey
ren statecode statecode_tar
ren statecode_acq statecode

joinby gvkey year using "K:\M&A and Committee\house seniority district.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\senate seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\senate seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\congress seniority other committee.dta",unm(m) update
drop _merge
duplicates drop


foreach var of varlist totalcongress_acq- contributiontocongresssub_acq totalcongress_tar- contributiontocongresssub_tar{
replace `var'=0 if `var'==.
replace `var'=log(1+`var')
}



***merge with time priod data for democratic control
joinby year using "K:\M&A and Committee\year_control_dem.dta",unm(m)
drop _merge
duplicates drop

***cleaning of M&A data
foreach var of varlist ValueofTransactionmil TargetSharePrice4WeeksPriortoAnn NetIncomeLastTwelveMonthsMil TargetTotalAssetsmil AP{
replace `var'="" if `var'=="-"
destring `var',replace
}

replace ValueofTransaction=subinstr(ValueofTransaction,",","",.)
destring ValueofTransaction,replace
replace RatioofOfferPricetoEPS="" if RatioofOfferPricetoEPS=="np"|RatioofOfferPricetoEPS=="nm"
destring RatioofOfferPricetoEPS,replace 
gen targetsize=log(TargetTotalAssetsmil)
gen value=log(1+Value)

foreach var of varlist TargetPrimarySICCode AcquirorPrimarySICCode{
replace `var'="9999" if `var'=="999A"|`var'=="999B"|`var'=="999C"|`var'=="999D"|`var'=="999E"|`var'=="999F"|`var'=="999G"
replace `var'="6191" if `var'=="619A"|`var'=="619B"
replace `var'="4990" if `var'=="499A"
}

gen sic_acq=substr(AcquirorPrimarySICCode,1,2)
gen sic_tar=substr(TargetPrimarySICCode,1,2)

***identify M&A as high risk by 1) competing in the same industry as in Hoberg and Phillips (2010, 2016); 2) whether acquiror and target are vertically linked as in Ahern and Harford (2014)
joinby gvkey year using "K:\M&A and Committee\tnic3.dta",unm(m)
drop _merge
duplicates drop

joinby sic_acq sic_tar using "K:\M&A and Committee\vertical sic list.dta",unm(m)
drop _merge
duplicates drop
replace highrisk=1 if vertical==1&highrisk==0


***generate variable for duration test
replace duration=log(duration)


***merge with state politician ideology data
ren statename_acq statename
joinby statename year using "K:\M&A and Committee\state congress dw.dta",unm(m)
drop _merge
duplicates drop
ren congress_dw congress_dw_acq
ren statename statename_acq

ren statename_tar statename
joinby statename year using "K:\M&A and Committee\state congress dw.dta",unm(m)
drop _merge
duplicates drop
ren congress_dw congress_dw_tar
ren statename statename_tar


***generate friendly deal indicator variable
gen friend=Attitude=="Friendly"


***generate the "Outcome" variable
gen regoutcome=.
replace regoutcome=1 if regulation=="e"
replace regoutcome=2 if regulation=="w"|regulation=="u"
replace regoutcome=3 if regulation=="a"
replace regoutcome=4 if regulation=="c"|regulation=="r"



******Table 3 base model******
xi:oprobit regoutcome congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", replace excel bdec(3) tdec(2) tstat drop(o._I* _I*) addstat(Pseudo R-squared, `e(r2_p)')
xi:oprobit regoutcome congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==1,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) addstat(Pseudo R-squared, `e(r2_p)')
xi:oprobit regoutcome congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==0,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) addstat(Pseudo R-squared, `e(r2_p)')

xi:reg duration congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) adjr2
xi:reg duration congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==1,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) adjr2
xi:reg duration congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==0,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) adjr2

exit,clear STATA
***start from M&A sample from SDC
use "K:\M&A and Committee\merger SDC.dta",clear

replace DateAnnounced(DateAnnounced,"DMY",2050)
replace DateEffective=date(DateEffective,"DMY",2050)

***merge with hostile M&A indicator file
joinby DateAnnounced TargetName AcquirorName using "K:\M&A and Committee\hostile indicator.dta",unm(m)
drop _merge
duplicates drop

***obtain statename and statecode for acquirors and targets
replace statename_tar=TargetState if strlen(TargetState)==2
replace statename_acq=AcquirorState if strlen(AcquirorState)==2

ren TargetState statefullname
joinby statefullname using "K:\M&A and Committee\statename-statecode.dta",unm(m)
drop _merge
duplicates drop
replace statename_tar=statename if statename_tar==""
replace statename=statename_tar if statename==""

drop statename statefullname statefullname1
ren statecode statecode_tar

ren AcquirorState statefullname
joinby statefullname using "K:\M&A and Committee\statename-statecode.dta",unm(m)
drop _merge
duplicates drop
replace statename_acq=statename if statename_acq==""
replace statename=statename_tar if statename==""

drop statename statefullname statefullname1
ren statecode statecode_acq

***merge with approval date hand-collection file
joinby DateAnnounced TargetName AcquirorName using "K:\M&A and Committee\real date for approval.dta",unm(m)
drop _merge
duplicates drop

***merge with M&A regulatory outcome manually verified data
joinby DateAnnounced DateEffective TargetName AcquirorName using "K:\M&A and Committee\regulatory outcome.dta",unm(m)
drop _merge
duplicates drop

***cleansing M&A deals
drop if DateAnn==.
gen year=yofd(DateAnn)
drop if (AcquirorNation!="United States"&year<2017)
drop if Status=="Intended"
drop if Status=="Intent W"
gen dateann=DateAnnounced
format dateann %td
gen dateeff=DateEffective
format dateeff %td
gen duration= dateeff-dateann

***standardize CUSIP for acquiror and target firms
replace TargetCUSIP="0"+TargetCUSIP if strlen(TargetCUSIP)==5
replace TargetCUSIP="00"+TargetCUSIP if strlen(TargetCUSIP)==4
replace TargetCUSIP="000"+TargetCUSIP if strlen(TargetCUSIP)==3
replace TargetCUSIP="0000"+TargetCUSIP if strlen(TargetCUSIP)==2

replace AcquirorCUSIP="0"+AcquirorCUSIP if strlen(AcquirorCUSIP)==5
replace AcquirorCUSIP="00"+AcquirorCUSIP if strlen(AcquirorCUSIP)==4
replace AcquirorCUSIP="000"+AcquirorCUSIP if strlen(AcquirorCUSIP)==3
replace AcquirorCUSIP="0000"+AcquirorCUSIP if strlen(AcquirorCUSIP)==2

***drop deals with same acquiror/target pairs
drop if TargetCUSIP==AcquirorCUSIP|TargetName==AcquirorName

***obtain acquiror GVKEY
ren AcquirorCUSIP cusip6
joinby cusip6 using "K:\M&A and Committee\gvkey-cusip-permno.dta",unm(m)
drop _merge
duplicates drop

***obtain company name from Compustat
joinby gvkey using "K:\M&A and Committee\gvkey-conm.dta",unm(m)
drop _merge
duplicates drop

***merge acquiror with state-operation concentration data (Garcia and Norli) 
joinby gvkey year using "K:\M&A and Committee\state_op_num1.dta",unm(m)
drop _merge
duplicates drop
replace state_op_num1=0 if state_op_num1==.&year<2017
ren state_op_num1 state_op_num_acq

***merge with employee data
joinby gvkey year using "K:\M&A and Committee\employee.dta",unm(m)
drop _merge
duplicates drop

***merge with firm variables based on Compustat
joinby gvkey year using "K:\M&A and Committee\firm factor.dta",unm(m)
drop _merge
duplicates drop

***merge with firm market share within 3-digit SIC industry
joinby gvkey year using "K:\M&A and Committee\market share sic3.dta",unm(m)
drop _merge
duplicates drop

***merge with politicial connection data from BoardEx
joinby gvkey year using "K:\M&A and Committee\political connection.dta",unm(m)
drop _merge
duplicates drop

***merge with firm lobbying data (Congress and FTC/DOJ)
joinby gvkey year using "K:\M&A and Committee\gvkey lobby.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\gvkey ftcdoj.dta",unm(m)
drop _merge
duplicates drop
replace ftcdoj=0 if ftcdoj==.

***merge with firm political contribution data
joinby gvkey year using "K:\M&A and Committee\FEC firm contribution to congress.dta",unm(m)
drop _merge
duplicates drop

drop cusip permno permco cusip8


********below we repeat the process bove to match target firm with all the variables**********
ren TargetCUSIP cusip6

joinby cusip6 year using "K:\M&A and Committee\gvkey-permno-cusip.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey using "K:\M&A and Committee\gvkey-conm.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\firm factor.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\market share sic3.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\state_op_num1.dta",unm(m)
drop _merge
duplicates drop
replace state_op_num1=0 if state_op_num1==.&year<2017
ren state_op_num1 state_op_num_tar

joinby gvkey year using "K:\M&A and Committee\gvkey lobby.dta",unm(m)
drop _merge
duplicates drop
drop sic*

joinby gvkey year using "K:\M&A and Committee\FEC firm contribution to congress.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\gvkey ftcdoj.dta",unm(m)
drop _merge
duplicates drop
replace ftcdoj=0 if ftcdoj==.

joinby gvkey year using "K:\M&A and Committee\political connection.dta",unm(m)
drop _merge
duplicates drop

drop cusip permno permco cusip8

drop if gvkey_acq==.
drop if year<1998|year>2016
keep if gvkey_tar!=.
drop if value==.




****below we match target with politician by district/state to calculate the committee seniority
joinby gvkey year using "K:\M&A and Committee\house seniority district.dta",unm(m)
drop _merge
duplicates drop

ren statecode_tar statecode
joinby statecode year using "K:\M&A and Committee\senate seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\senate seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\congress seniority other committee.dta",unm(m)
drop _merge
duplicates drop

foreach var of varlist totalcongress-contributiontocongresssub ftcdoj house_totalseniority-house_seniority_all firmage antitakeover {
ren `var' `var'_tar
}

****below we match acquiror with politician by district/state to calculate the committee seniority
ren gvkey gvkey_tar
ren gvkey_acq gvkey
ren statecode statecode_tar
ren statecode_acq statecode

joinby gvkey year using "K:\M&A and Committee\house seniority district.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\senate seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\senate seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\congress seniority other committee.dta",unm(m) update
drop _merge
duplicates drop


foreach var of varlist totalcongress_acq- contributiontocongresssub_acq totalcongress_tar- contributiontocongresssub_tar{
replace `var'=0 if `var'==.
replace `var'=log(1+`var')
}



***merge with time priod data for democratic control
joinby year using "K:\M&A and Committee\year_control_dem.dta",unm(m)
drop _merge
duplicates drop

***cleaning of M&A data
foreach var of varlist ValueofTransactionmil TargetSharePrice4WeeksPriortoAnn NetIncomeLastTwelveMonthsMil TargetTotalAssetsmil AP{
replace `var'="" if `var'=="-"
destring `var',replace
}

replace ValueofTransaction=subinstr(ValueofTransaction,",","",.)
destring ValueofTransaction,replace
replace RatioofOfferPricetoEPS="" if RatioofOfferPricetoEPS=="np"|RatioofOfferPricetoEPS=="nm"
destring RatioofOfferPricetoEPS,replace 
gen targetsize=log(TargetTotalAssetsmil)
gen value=log(1+Value)

foreach var of varlist TargetPrimarySICCode AcquirorPrimarySICCode{
replace `var'="9999" if `var'=="999A"|`var'=="999B"|`var'=="999C"|`var'=="999D"|`var'=="999E"|`var'=="999F"|`var'=="999G"
replace `var'="6191" if `var'=="619A"|`var'=="619B"
replace `var'="4990" if `var'=="499A"
}

gen sic_acq=substr(AcquirorPrimarySICCode,1,2)
gen sic_tar=substr(TargetPrimarySICCode,1,2)

***identify M&A as high risk by 1) competing in the same industry as in Hoberg and Phillips (2010, 2016); 2) whether acquiror and target are vertically linked as in Ahern and Harford (2014)
joinby gvkey year using "K:\M&A and Committee\tnic3.dta",unm(m)
drop _merge
duplicates drop

joinby sic_acq sic_tar using "K:\M&A and Committee\vertical sic list.dta",unm(m)
drop _merge
duplicates drop
replace highrisk=1 if vertical==1&highrisk==0


***generate variable for duration test
replace duration=log(duration)


***merge with state politician ideology data
ren statename_acq statename
joinby statename year using "K:\M&A and Committee\state congress dw.dta",unm(m)
drop _merge
duplicates drop
ren congress_dw congress_dw_acq
ren statename statename_acq

ren statename_tar statename
joinby statename year using "K:\M&A and Committee\state congress dw.dta",unm(m)
drop _merge
duplicates drop
ren congress_dw congress_dw_tar
ren statename statename_tar


***generate friendly deal indicator variable
gen friend=Attitude=="Friendly"


***generate the "Outcome" variable
gen regoutcome=.
replace regoutcome=1 if regulation=="e"
replace regoutcome=2 if regulation=="w"|regulation=="u"
replace regoutcome=3 if regulation=="a"
replace regoutcome=4 if regulation=="c"|regulation=="r"



******Table 3 base model******
xi:oprobit regoutcome congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", replace excel bdec(3) tdec(2) tstat drop(o._I* _I*) addstat(Pseudo R-squared, `e(r2_p)')
xi:oprobit regoutcome congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==1,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) addstat(Pseudo R-squared, `e(r2_p)')
xi:oprobit regoutcome congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==0,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) addstat(Pseudo R-squared, `e(r2_p)')

xi:reg duration congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) adjr2
xi:reg duration congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==1,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) adjr2
xi:reg duration congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==0,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) adjr2

exit,clear STATA
***start from M&A sample from SDC
use "K:\M&A and Committee\merger SDC.dta",clear

replace DateAnnounced(DateAnnounced,"DMY",2050)
replace DateEffective=date(DateEffective,"DMY",2050)

***merge with hostile M&A indicator file
joinby DateAnnounced TargetName AcquirorName using "K:\M&A and Committee\hostile indicator.dta",unm(m)
drop _merge
duplicates drop

***obtain statename and statecode for acquirors and targets
replace statename_tar=TargetState if strlen(TargetState)==2
replace statename_acq=AcquirorState if strlen(AcquirorState)==2

ren TargetState statefullname
joinby statefullname using "K:\M&A and Committee\statename-statecode.dta",unm(m)
drop _merge
duplicates drop
replace statename_tar=statename if statename_tar==""
replace statename=statename_tar if statename==""

drop statename statefullname statefullname1
ren statecode statecode_tar

ren AcquirorState statefullname
joinby statefullname using "K:\M&A and Committee\statename-statecode.dta",unm(m)
drop _merge
duplicates drop
replace statename_acq=statename if statename_acq==""
replace statename=statename_tar if statename==""

drop statename statefullname statefullname1
ren statecode statecode_acq

***merge with approval date hand-collection file
joinby DateAnnounced TargetName AcquirorName using "K:\M&A and Committee\real date for approval.dta",unm(m)
drop _merge
duplicates drop

***merge with M&A regulatory outcome manually verified data
joinby DateAnnounced DateEffective TargetName AcquirorName using "K:\M&A and Committee\regulatory outcome.dta",unm(m)
drop _merge
duplicates drop

***cleansing M&A deals
drop if DateAnn==.
gen year=yofd(DateAnn)
drop if (AcquirorNation!="United States"&year<2017)
drop if Status=="Intended"
drop if Status=="Intent W"
gen dateann=DateAnnounced
format dateann %td
gen dateeff=DateEffective
format dateeff %td
gen duration= dateeff-dateann

***standardize CUSIP for acquiror and target firms
replace TargetCUSIP="0"+TargetCUSIP if strlen(TargetCUSIP)==5
replace TargetCUSIP="00"+TargetCUSIP if strlen(TargetCUSIP)==4
replace TargetCUSIP="000"+TargetCUSIP if strlen(TargetCUSIP)==3
replace TargetCUSIP="0000"+TargetCUSIP if strlen(TargetCUSIP)==2

replace AcquirorCUSIP="0"+AcquirorCUSIP if strlen(AcquirorCUSIP)==5
replace AcquirorCUSIP="00"+AcquirorCUSIP if strlen(AcquirorCUSIP)==4
replace AcquirorCUSIP="000"+AcquirorCUSIP if strlen(AcquirorCUSIP)==3
replace AcquirorCUSIP="0000"+AcquirorCUSIP if strlen(AcquirorCUSIP)==2

***drop deals with same acquiror/target pairs
drop if TargetCUSIP==AcquirorCUSIP|TargetName==AcquirorName

***obtain acquiror GVKEY
ren AcquirorCUSIP cusip6
joinby cusip6 using "K:\M&A and Committee\gvkey-cusip-permno.dta",unm(m)
drop _merge
duplicates drop

***obtain company name from Compustat
joinby gvkey using "K:\M&A and Committee\gvkey-conm.dta",unm(m)
drop _merge
duplicates drop

***merge acquiror with state-operation concentration data (Garcia and Norli) 
joinby gvkey year using "K:\M&A and Committee\state_op_num1.dta",unm(m)
drop _merge
duplicates drop
replace state_op_num1=0 if state_op_num1==.&year<2017
ren state_op_num1 state_op_num_acq

***merge with employee data
joinby gvkey year using "K:\M&A and Committee\employee.dta",unm(m)
drop _merge
duplicates drop

***merge with firm variables based on Compustat
joinby gvkey year using "K:\M&A and Committee\firm factor.dta",unm(m)
drop _merge
duplicates drop

***merge with firm market share within 3-digit SIC industry
joinby gvkey year using "K:\M&A and Committee\market share sic3.dta",unm(m)
drop _merge
duplicates drop

***merge with politicial connection data from BoardEx
joinby gvkey year using "K:\M&A and Committee\political connection.dta",unm(m)
drop _merge
duplicates drop

***merge with firm lobbying data (Congress and FTC/DOJ)
joinby gvkey year using "K:\M&A and Committee\gvkey lobby.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\gvkey ftcdoj.dta",unm(m)
drop _merge
duplicates drop
replace ftcdoj=0 if ftcdoj==.

***merge with firm political contribution data
joinby gvkey year using "K:\M&A and Committee\FEC firm contribution to congress.dta",unm(m)
drop _merge
duplicates drop

drop cusip permno permco cusip8


********below we repeat the process bove to match target firm with all the variables**********
ren TargetCUSIP cusip6

joinby cusip6 year using "K:\M&A and Committee\gvkey-permno-cusip.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey using "K:\M&A and Committee\gvkey-conm.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\firm factor.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\market share sic3.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\state_op_num1.dta",unm(m)
drop _merge
duplicates drop
replace state_op_num1=0 if state_op_num1==.&year<2017
ren state_op_num1 state_op_num_tar

joinby gvkey year using "K:\M&A and Committee\gvkey lobby.dta",unm(m)
drop _merge
duplicates drop
drop sic*

joinby gvkey year using "K:\M&A and Committee\FEC firm contribution to congress.dta",unm(m)
drop _merge
duplicates drop

joinby gvkey year using "K:\M&A and Committee\gvkey ftcdoj.dta",unm(m)
drop _merge
duplicates drop
replace ftcdoj=0 if ftcdoj==.

joinby gvkey year using "K:\M&A and Committee\political connection.dta",unm(m)
drop _merge
duplicates drop

drop cusip permno permco cusip8

drop if gvkey_acq==.
drop if year<1998|year>2016
keep if gvkey_tar!=.
drop if value==.




****below we match target with politician by district/state to calculate the committee seniority
joinby gvkey year using "K:\M&A and Committee\house seniority district.dta",unm(m)
drop _merge
duplicates drop

ren statecode_tar statecode
joinby statecode year using "K:\M&A and Committee\senate seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\senate seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\congress seniority other committee.dta",unm(m)
drop _merge
duplicates drop

foreach var of varlist totalcongress-contributiontocongresssub ftcdoj house_totalseniority-house_seniority_all firmage antitakeover {
ren `var' `var'_tar
}

****below we match acquiror with politician by district/state to calculate the committee seniority
ren gvkey gvkey_tar
ren gvkey_acq gvkey
ren statecode statecode_tar
ren statecode_acq statecode

joinby gvkey year using "K:\M&A and Committee\house seniority district.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\senate seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\house seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\senate seniority sub.dta",unm(m)
drop _merge
duplicates drop

joinby statecode year using "K:\M&A and Committee\congress seniority other committee.dta",unm(m) update
drop _merge
duplicates drop


foreach var of varlist totalcongress_acq- contributiontocongresssub_acq totalcongress_tar- contributiontocongresssub_tar{
replace `var'=0 if `var'==.
replace `var'=log(1+`var')
}



***merge with time priod data for democratic control
joinby year using "K:\M&A and Committee\year_control_dem.dta",unm(m)
drop _merge
duplicates drop

***cleaning of M&A data
foreach var of varlist ValueofTransactionmil TargetSharePrice4WeeksPriortoAnn NetIncomeLastTwelveMonthsMil TargetTotalAssetsmil AP{
replace `var'="" if `var'=="-"
destring `var',replace
}

replace ValueofTransaction=subinstr(ValueofTransaction,",","",.)
destring ValueofTransaction,replace
replace RatioofOfferPricetoEPS="" if RatioofOfferPricetoEPS=="np"|RatioofOfferPricetoEPS=="nm"
destring RatioofOfferPricetoEPS,replace 
gen targetsize=log(TargetTotalAssetsmil)
gen value=log(1+Value)

foreach var of varlist TargetPrimarySICCode AcquirorPrimarySICCode{
replace `var'="9999" if `var'=="999A"|`var'=="999B"|`var'=="999C"|`var'=="999D"|`var'=="999E"|`var'=="999F"|`var'=="999G"
replace `var'="6191" if `var'=="619A"|`var'=="619B"
replace `var'="4990" if `var'=="499A"
}

gen sic_acq=substr(AcquirorPrimarySICCode,1,2)
gen sic_tar=substr(TargetPrimarySICCode,1,2)

***identify M&A as high risk by 1) competing in the same industry as in Hoberg and Phillips (2010, 2016); 2) whether acquiror and target are vertically linked as in Ahern and Harford (2014)
joinby gvkey year using "K:\M&A and Committee\tnic3.dta",unm(m)
drop _merge
duplicates drop

joinby sic_acq sic_tar using "K:\M&A and Committee\vertical sic list.dta",unm(m)
drop _merge
duplicates drop
replace highrisk=1 if vertical==1&highrisk==0


***generate variable for duration test
replace duration=log(duration)


***merge with state politician ideology data
ren statename_acq statename
joinby statename year using "K:\M&A and Committee\state congress dw.dta",unm(m)
drop _merge
duplicates drop
ren congress_dw congress_dw_acq
ren statename statename_acq

ren statename_tar statename
joinby statename year using "K:\M&A and Committee\state congress dw.dta",unm(m)
drop _merge
duplicates drop
ren congress_dw congress_dw_tar
ren statename statename_tar


***generate friendly deal indicator variable
gen friend=Attitude=="Friendly"


***generate the "Outcome" variable
gen regoutcome=.
replace regoutcome=1 if regulation=="e"
replace regoutcome=2 if regulation=="w"|regulation=="u"
replace regoutcome=3 if regulation=="a"
replace regoutcome=4 if regulation=="c"|regulation=="r"



******Table 3 base model******
xi:oprobit regoutcome congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", replace excel bdec(3) tdec(2) tstat drop(o._I* _I*) addstat(Pseudo R-squared, `e(r2_p)')
xi:oprobit regoutcome congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==1,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) addstat(Pseudo R-squared, `e(r2_p)')
xi:oprobit regoutcome congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==0,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) addstat(Pseudo R-squared, `e(r2_p)')

xi:reg duration congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) adjr2
xi:reg duration congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==1,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) adjr2
xi:reg duration congress_acq congress_tar lobby_acq lobby_tar polit_conn_acq polit_conn_tar value herfindahl_acq relativesize totalshare i.sic2_acq i.sic2_tar i.state_acq i.state_tar i.year if highrisk==0,cluster(state_acq)
outreg2 using "K:\M&A and Committee\outcome result.txt", excel bdec(3) tdec(2) tstat drop(o._I* _I*) adjr2

exit,clear STATA

