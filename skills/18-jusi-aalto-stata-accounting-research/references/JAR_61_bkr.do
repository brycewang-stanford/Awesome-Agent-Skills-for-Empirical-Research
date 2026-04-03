********************************************************
********************************************************
************  							 ***************  
************  Part 1: Data Construction  ***************
************  							 ***************
********************************************************
********************************************************

* Set directory
cd "Data\" 

********************************************************
*********  Process 10K state mentions data  ************
********************************************************

clear all
use "aggregatestate_nodc"

expand 50

sort filename
quietly by filename: gen dup=cond(_N==1,0,_n)

gen state=""
replace state="AK" if s_alaska>0 & dup==1
replace state="AL" if s_alabama>0 & dup==2
replace state="AR" if s_arkansas>0 & dup==3
replace state="AZ" if s_arizona>0 & dup==4
replace state="CA" if s_california>0 & dup==5
replace state="CO" if s_colorado>0 & dup==6
replace state="CT" if s_connecticut>0 & dup==7
replace state="DE" if s_delaware>0 & dup==8
replace state="FL" if s_florida>0 & dup==9
replace state="GA" if s_georgia>0 & dup==10
replace state="HI" if s_hawaii>0 & dup==11
replace state="IA" if s_iowa>0 & dup==12
replace state="ID" if s_idaho>0 & dup==13
replace state="IL" if s_illinois>0 & dup==14
replace state="IN" if s_indiana>0 & dup==15
replace state="KS" if s_kansas>0 & dup==16
replace state="KY" if s_kentucky>0 & dup==17
replace state="LA" if s_louisiana>0 & dup==18
replace state="MA" if s_massachusetts>0 & dup==20
replace state="MD" if s_maryland>0 & dup==21
replace state="ME" if s_maine>0 & dup==22
replace state="MI" if s_michigan>0 & dup==23
replace state="MN" if s_minnesota>0 & dup==24
replace state="MO" if s_missouri>0 & dup==25
replace state="MS" if s_mississippi>0 & dup==26
replace state="MT" if s_montana>0 & dup==27
replace state="NC" if s_northcarolina>0 & dup==28
replace state="ND" if s_northdakota>0 & dup==29
replace state="NE" if s_nebraska>0 & dup==30
replace state="NH" if s_newhampshire>0 & dup==31
replace state="NJ" if s_newjersey>0 & dup==32
replace state="NM" if s_newmexico>0 & dup==33
replace state="NV" if s_nevada>0 & dup==34
replace state="NY" if s_newyork>0 & dup==35
replace state="OH" if s_ohio>0 & dup==36
replace state="OK" if s_oklahoma>0 & dup==37
replace state="OR" if s_oregon>0 & dup==38
replace state="PA" if s_pennsylvania>0 & dup==39
replace state="RI" if s_rhodeisland>0 & dup==40
replace state="SC" if s_southcarolina>0 & dup==41
replace state="SD" if s_southdakota>0 & dup==42
replace state="TN" if s_tennessee>0 & dup==43
replace state="TX" if s_texas>0 & dup==44
replace state="UT" if s_utah>0 & dup==45
replace state="VA" if s_virginia>0 & dup==46
replace state="VT" if s_vermont>0 & dup==48
replace state="WA" if s_washington>0 & dup==49
replace state="WI" if s_wisconsin>0 & dup==50
replace state="WV" if s_westvirginia>0 & dup==19
replace state="WY" if s_wyoming>0 & dup==47

drop if missing(state)

gen mentions=.
replace mentions=s_alaska if state=="AK"
replace mentions=s_alabama if state=="AL"
replace mentions=s_arkansas if state=="AR"
replace mentions=s_arizona if state=="AZ"
replace mentions=s_california if state=="CA"
replace mentions=s_colorado if state=="CO"
replace mentions=s_connecticut if state=="CT"
replace mentions=s_delaware if state=="DE"
replace mentions=s_florida if state=="FL"
replace mentions=s_georgia if state=="GA"
replace mentions=s_hawaii if state=="HI"
replace mentions=s_iowa if state=="IA"
replace mentions=s_idaho if state=="ID"
replace mentions=s_illinois if state=="IL"
replace mentions=s_indiana if state=="IN"
replace mentions=s_kansas if state=="KS"
replace mentions=s_kentucky if state=="KY"
replace mentions=s_louisiana if state=="LA"
replace mentions=s_massachusetts if state=="MA"
replace mentions=s_maryland if state=="MD"
replace mentions=s_maine if state=="ME"
replace mentions=s_michigan if state=="MI"
replace mentions=s_minnesota if state=="MN"
replace mentions=s_missouri if state=="MO"
replace mentions=s_mississippi if state=="MS"
replace mentions=s_montana if state=="MT"
replace mentions=s_northcarolina if state=="NC"
replace mentions=s_northdakota if state=="ND"
replace mentions=s_nebraska if state=="NE"
replace mentions=s_newhampshire if state=="NH"
replace mentions=s_newjersey if state=="NJ"
replace mentions=s_newmexico if state=="NM"
replace mentions=s_nevada if state=="NV"
replace mentions=s_newyork if state=="NY"
replace mentions=s_ohio if state=="OH"
replace mentions=s_oklahoma if state=="OK"
replace mentions=s_oregon if state=="OR"
replace mentions=s_pennsylvania if state=="PA"
replace mentions=s_rhodeisland if state=="RI"
replace mentions=s_southcarolina if state=="SC"
replace mentions=s_southdakota if state=="SD"
replace mentions=s_tennessee if state=="TN"
replace mentions=s_texas if state=="TX"
replace mentions=s_utah if state=="UT"
replace mentions=s_virginia if state=="VA"
replace mentions=s_vermont if state=="VT"
replace mentions=s_washington if state=="WA"
replace mentions=s_wisconsin if state=="WI"
replace mentions=s_westvirginia if state=="WV"
replace mentions=s_wyoming if state=="WY"

* Drop duplicates by filing and state
duplicates drop filename state, force

* Keep mentions for each filing-state-year observation
keep filename state year mentions

* Extract CIK from filing name
gen cik=substr(filename,6,10)
destring(cik),replace

* Rename year variable 
gen fyear=year

* Construct each state's share of mentions for each firm-year observation
bys cik fyear: egen nummentions=sum(mentions)
gen stateexposureVW=mentions/nummentions

* Construct each state's share of mentioned states for each firm-year observation
gen f=1
bys cik fyear: egen numstates=sum(f)
gen stateexposureEW=1/numstates

* Keep necessary variables
keep cik state fyear stateexposureEW stateexposureVW

save "transformedstatementions", replace




********************************************************
*************  Process 10K header file  ****************
********************************************************

clear all
import delimited "LM_EDGAR_10X_Header_1994_2017.csv"

rename f_year fyear
rename f_quarter fqtr
rename f_yq fyq
rename state_of_incorp incstate
rename ba_state bstate
rename ma_state mstate

replace incstate=upper(incstate)
replace bstate=upper(bstate)
replace mstate=upper(mstate)

* Drop observations without state abbreviations
foreach x of varlist incstate bstate mstate {
drop if `x'=="1A"
drop if `x'=="1B"
drop if `x'=="1H"
drop if `x'=="1N"
drop if `x'=="1P"
drop if `x'=="1R"
drop if `x'=="1S"
drop if `x'=="1Q"
drop if `x'=="1T"
drop if `x'=="1Z"
drop if `x'=="2A"
drop if `x'=="2B"
drop if `x'=="2H"
drop if `x'=="2M"
drop if `x'=="2N"
drop if `x'=="2Q"
drop if `x'=="A1"
drop if `x'=="A2"
drop if `x'=="A3"
drop if `x'=="A4"
drop if `x'=="A5"
drop if `x'=="A6"
drop if `x'=="A7"
drop if `x'=="A8"
drop if `x'=="A9"
drop if `x'=="B0"
drop if `x'=="B9"
drop if `x'=="C0"
drop if `x'=="C1"
drop if `x'=="C3"
drop if `x'=="C4"
drop if `x'=="C5"
drop if `x'=="C8"
drop if `x'=="C9"
drop if `x'=="D0"
drop if `x'=="D1"
drop if `x'=="D2"
drop if `x'=="D3"
drop if `x'=="D5"
drop if `x'=="D8"
drop if `x'=="E0"
drop if `x'=="E3"
drop if `x'=="E6"
drop if `x'=="E7"
drop if `x'=="E9"
drop if `x'=="F3"
drop if `x'=="F4"
drop if `x'=="F5"
drop if `x'=="F8"
drop if `x'=="G0"
drop if `x'=="G2"
drop if `x'=="G4"
drop if `x'=="G7"
drop if `x'=="G8"
drop if `x'=="H1"
drop if `x'=="H1"
drop if `x'=="H2"
drop if `x'=="H3"
drop if `x'=="H8"
drop if `x'=="H9"
drop if `x'=="I0"
drop if `x'=="I8"
drop if `x'=="I9"
drop if `x'=="J1"
drop if `x'=="J3"
drop if `x'=="J5"
drop if `x'=="J8"
drop if `x'=="K3"
drop if `x'=="K5"
drop if `x'=="K6"
drop if `x'=="K7"
drop if `x'=="K8"
drop if `x'=="L2"
drop if `x'=="L3"
drop if `x'=="L5"
drop if `x'=="L6"
drop if `x'=="L8"
drop if `x'=="M0"
drop if `x'=="M2"
drop if `x'=="M3"
drop if `x'=="M4"
drop if `x'=="M5"
drop if `x'=="M8"
drop if `x'=="N2"
drop if `x'=="N4"
drop if `x'=="N5"
drop if `x'=="N8"
drop if `x'=="O0"
drop if `x'=="O5"
drop if `x'=="O9"
drop if `x'=="P2"
drop if `x'=="P7"
drop if `x'=="P8"
drop if `x'=="Q1"
drop if `x'=="Q2"
drop if `x'=="Q3"
drop if `x'=="R1"
drop if `x'=="R4"
drop if `x'=="R5"
drop if `x'=="R6"
drop if `x'=="R9"
drop if `x'=="S1"
drop if `x'=="S5"
drop if `x'=="S9"
drop if `x'=="T3"
drop if `x'=="U0"
drop if `x'=="U3"
drop if `x'=="V1"
drop if `x'=="V6"
drop if `x'=="V7"
drop if `x'=="V8"
drop if `x'=="W0"
drop if `x'=="W1"
drop if `x'=="W5"
drop if `x'=="W7"
drop if `x'=="W8"
drop if `x'=="X0"
drop if `x'=="X1"
drop if `x'=="X5"
drop if `x'=="XX"
drop if `x'=="Y0"
drop if `x'=="Y5"
drop if `x'=="Y9"
drop if `x'=="Z2"
drop if `x'=="Z4"
drop if `x'=="A0"
drop if `x'=="L4"
drop if `x'=="Q8"
replace `x'="CO" if `x'=="co"
replace `x'="CT" if `x'=="ct"
replace `x'="NV" if `x'=="nv"
replace `x'="NY" if `x'=="ny"
replace `x'="PA" if `x'=="pa"
replace `x'="UT" if `x'=="ut"
replace `x'="WA" if `x'=="wa"
}

* Construct an indicator to identify firms with overlap in state of incorporation and HQ 
gen samestate=0
replace samestate=1 if incstate==bstate 

* Keep necessary variables
keep cik bstate mstate incstate samestate fqtr fyear fyq

save "HQdata", replace




********************************************************
***  Merge 10-K state mentions with 10-K header data  **
********************************************************

clear all 
use "HQdata"

duplicates drop cik fyear, force
gen year=fyear

joinby cik fyear using "transformedstatementions"

duplicates drop cik state year, force

keep cik year state incstate bstate mstate samestate stateexposureVW stateexposureEW 

* Identify relevant state identifiers within larger CIK-state-year panel 
gen HQstate=0
replace HQstate=1 if bstate==state
gen mailstate=0
replace mailstate=1 if mstate==state
gen INCstate=0
replace INCstate=1 if incstate==state

drop incstate bstate mstate

* Construct an indicator to identify firms with overlap in state of incorporation and HQ 
gen samestate=0
replace samestate=1 if INCstate==1 & HQstate==1
bys cik year: egen s=max(samestate)
drop samestate
rename s samestate

save "state exposure panel", replace




********************************************************
*******  Construct SEC 8-K frequency measures  *********
********************************************************

clear all
use "8kaggregate.dta"

gen ym=ym(year,month(repdate))

replace item103=item1 if missing(item103)
replace item201=item2 if missing(item201)
replace item202=item12 if missing(item202)
replace item401=item4 if missing(item401)
replace item501=item1 if missing(item501)
replace item502=item6 if missing(item502)
replace item503=item8 if missing(item503)
replace item504=item11 if missing(item504)
replace item505=item10 if missing(item505)
replace item701=item9 if missing(item701)
replace item801=item5 if missing(item801)
replace item901=item7 if missing(item901)
gen item902=0
replace item902=item13 if !missing(item13)

foreach var of varlist item101-item901 {
replace `var'=0 if missing(`var')
}

gen num8k=1

sort cik repdate
quietly by cik repdate: gen dup=cond(_N==1,0,_n)

replace dup=1 if dup==0
replace dup=0 if dup>1
bys cik ym: egen numdates=sum(dup)

*Collapse into a CIK-month panel of disclosure content
collapse (sum) numchars numgraphics numxml numexhibits num8k pressrelease numitems item101-item901 (max) numdates, by(cik ym)

save "8kmonthly", replace




********************************************************
*******  Construct SEC 8-K returns measures  ***********
********************************************************

clear all
use "8kaggregate"

*Merge CRSP using 8-digit CUSIP with WRDS Event Study Suite announcement returns
joinby cik repdate using "announcementreturns", unmatched(master)
drop if missing(cusip)

gen ym=ym(year(repdate),month(repdate))

gen num8k=1

sort cik repdate
quietly by cik repdate: gen dup=cond(_N==1,0,_n)

replace dup=1 if dup==0
replace dup=0 if dup>1
bys cik ym: egen numdates=sum(dup)

* Construct absolute returns measures from announcement returns file
gen absaret3day=abs(aret3day) if !missing(aret3day)

gen year=year(repdate)
gen yq=yq(year(repdate),quarter(repdate))

collapse (sum) numchars numgraphics numxml numexhibits num8k pressrelease numitems item101-item901 absaret3day (mean) aret3day (max) year yq numdates , by(cik ym)

* Merge with original 8-K monthly panel to avoid losing observations due to merge
joinby cik ym using "8kmonthly", unmatched(both)
drop _merge

destring(cik),replace

save "8kfullmonthlypanel", replace




********************************************************
*************  Process 8K content data  ****************
********************************************************

**Construct CIK-state-month panel**
clear all
use "8kcontent"

* Expand to include one observation per state for each filing
expand 50

sort filename
quietly by filename: gen dup=cond(_N==1,0,_n)

* Count state mentions
gen state=""
replace state="AK" if s_alaska>0 & dup==1
replace state="AL" if s_alabama>0 & dup==2
replace state="AR" if s_arkansas>0 & dup==3
replace state="AZ" if s_arizona>0 & dup==4
replace state="CA" if s_california>0 & dup==5
replace state="CO" if s_colorado>0 & dup==6
replace state="CT" if s_connecticut>0 & dup==7
replace state="DE" if s_delaware>0 & dup==8
replace state="FL" if s_florida>0 & dup==9
replace state="GA" if s_georgia>0 & dup==10
replace state="HI" if s_hawaii>0 & dup==11
replace state="IA" if s_iowa>0 & dup==12
replace state="ID" if s_idaho>0 & dup==13
replace state="IL" if s_illinois>0 & dup==14
replace state="IN" if s_indiana>0 & dup==15
replace state="KS" if s_kansas>0 & dup==16
replace state="KY" if s_kentucky>0 & dup==17
replace state="LA" if s_louisiana>0 & dup==18
replace state="MA" if s_massachusetts>0 & dup==20
replace state="MD" if s_maryland>0 & dup==21
replace state="ME" if s_maine>0 & dup==22
replace state="MI" if s_michigan>0 & dup==23
replace state="MN" if s_minnesota>0 & dup==24
replace state="MO" if s_missouri>0 & dup==25
replace state="MS" if s_mississippi>0 & dup==26
replace state="MT" if s_montana>0 & dup==27
replace state="NC" if s_northcarolina>0 & dup==28
replace state="ND" if s_northdakota>0 & dup==29
replace state="NE" if s_nebraska>0 & dup==30
replace state="NH" if s_newhampshire>0 & dup==31
replace state="NJ" if s_newjersey>0 & dup==32
replace state="NM" if s_newmexico>0 & dup==33
replace state="NV" if s_nevada>0 & dup==34
replace state="NY" if s_newyork>0 & dup==35
replace state="OH" if s_ohio>0 & dup==36
replace state="OK" if s_oklahoma>0 & dup==37
replace state="OR" if s_oregon>0 & dup==38
replace state="PA" if s_pennsylvania>0 & dup==39
replace state="RI" if s_rhodeisland>0 & dup==40
replace state="SC" if s_southcarolina>0 & dup==41
replace state="SD" if s_southdakota>0 & dup==42
replace state="TN" if s_tennessee>0 & dup==43
replace state="TX" if s_texas>0 & dup==44
replace state="UT" if s_utah>0 & dup==45
replace state="VA" if s_virginia>0 & dup==46
replace state="VT" if s_vermont>0 & dup==48
replace state="WA" if s_washington>0 & dup==49
replace state="WI" if s_wisconsin>0 & dup==50
replace state="WV" if s_westvirginia>0 & dup==19
replace state="WY" if s_wyoming>0 & dup==47

drop if missing(state)

gen mentions=.
replace mentions=s_alaska if state=="AK"
replace mentions=s_alabama if state=="AL"
replace mentions=s_arkansas if state=="AR"
replace mentions=s_arizona if state=="AZ"
replace mentions=s_california if state=="CA"
replace mentions=s_colorado if state=="CO"
replace mentions=s_connecticut if state=="CT"
replace mentions=s_delaware if state=="DE"
replace mentions=s_florida if state=="FL"
replace mentions=s_georgia if state=="GA"
replace mentions=s_hawaii if state=="HI"
replace mentions=s_iowa if state=="IA"
replace mentions=s_idaho if state=="ID"
replace mentions=s_illinois if state=="IL"
replace mentions=s_indiana if state=="IN"
replace mentions=s_kansas if state=="KS"
replace mentions=s_kentucky if state=="KY"
replace mentions=s_louisiana if state=="LA"
replace mentions=s_massachusetts if state=="MA"
replace mentions=s_maryland if state=="MD"
replace mentions=s_maine if state=="ME"
replace mentions=s_michigan if state=="MI"
replace mentions=s_minnesota if state=="MN"
replace mentions=s_missouri if state=="MO"
replace mentions=s_mississippi if state=="MS"
replace mentions=s_montana if state=="MT"
replace mentions=s_northcarolina if state=="NC"
replace mentions=s_northdakota if state=="ND"
replace mentions=s_nebraska if state=="NE"
replace mentions=s_newhampshire if state=="NH"
replace mentions=s_newjersey if state=="NJ"
replace mentions=s_newmexico if state=="NM"
replace mentions=s_nevada if state=="NV"
replace mentions=s_newyork if state=="NY"
replace mentions=s_ohio if state=="OH"
replace mentions=s_oklahoma if state=="OK"
replace mentions=s_oregon if state=="OR"
replace mentions=s_pennsylvania if state=="PA"
replace mentions=s_rhodeisland if state=="RI"
replace mentions=s_southcarolina if state=="SC"
replace mentions=s_southdakota if state=="SD"
replace mentions=s_tennessee if state=="TN"
replace mentions=s_texas if state=="TX"
replace mentions=s_utah if state=="UT"
replace mentions=s_virginia if state=="VA"
replace mentions=s_vermont if state=="VT"
replace mentions=s_washington if state=="WA"
replace mentions=s_wisconsin if state=="WI"
replace mentions=s_westvirginia if state=="WV"
replace mentions=s_wyoming if state=="WY"

* Drop duplicates by filename and state
duplicates drop filename state, force

* Generate reporting date in year-month format
gen ym=ym(year(repdate),month(repdate))

gen numfilings=1

* Collapse into CIK-state-month panel with filing counts by term
collapse (sum) numfilings r_risk r_risks r_uncertainty r_variable r_chance r_possibility r_pending r_uncertainties r_uncertain r_doubt r_prospect r_bet r_variability r_exposed r_likelihood r_threat r_probability r_unknown r_varying r_unclear r_unpredictable r_speculative r_fear r_reservation r_hesitant r_gamble r_risky r_instability r_doubtful r_hazard r_tricky r_sticky r_dangerous r_tentative r_hazardous r_queries r_danger r_fluctuating r_unstable r_vague r_erratic r_query r_jeopardize r_unsettled r_unpredictability r_dilemma r_skepticism r_hesitancy r_riskier r_unresolved r_unsure r_irregular r_jeopardy r_suspicion r_risking r_peril r_hesitating r_risked r_unreliable r_unsafe r_hazy r_apprehension r_unforeseeable r_halting r_wager r_torn r_precarious r_undetermined r_insecurity r_debatable r_undecided r_dicey r_indecision r_wavering r_iffy r_faltering r_endanger r_quandary r_insecure r_changeable r_riskiest r_hairy r_ambivalent r_dubious r_riskiness r_treacherous r_oscillating r_perilous r_tentativeness r_unreliability r_wariness r_vagueness r_dodgy r_equivocation r_indecisive r_chancy r_menace r_qualm r_vacillating r_gnarly r_disquiet r_ambivalence r_imperil r_vacillation r_incalculable r_untrustworthy r_equivocating r_diffident r_fickleness r_misgiving r_changeability r_undependable r_incertitude r_fitful r_parlous r_unconfident r_defenseless r_unsureness r_fluctuant r_niggle r_diffidence r_precariousness r_doubtfulness s_alabama s_alaska s_arizona s_arkansas s_california s_colorado s_connecticut s_delaware s_florida s_georgia s_hawaii s_idaho s_illinois s_indiana s_iowa s_kansas s_kentucky s_louisiana s_maine s_maryland s_massachusetts s_michigan s_minnesota s_mississippi s_missouri s_montana s_nebraska s_nevada s_newhampshire s_newjersey s_newmexico s_newyork s_northcarolina s_northdakota s_ohio s_oklahoma s_oregon s_pennsylvania s_rhodeisland s_southcarolina s_southdakota s_tennessee s_texas s_utah s_vermont s_virginia s_washington s_westvirginia s_wisconsin s_wyoming, by(cik state ym)

* Construct term count measures of risk synonyms 
gen allrisk=r_risk +r_risks +r_uncertainty +r_variable +r_chance +r_possibility +r_pending +r_uncertainties +r_uncertain +r_doubt +r_prospect +r_bet +r_variability +r_exposed +r_likelihood +r_threat +r_probability +r_unknown +r_varying +r_unclear +r_unpredictable +r_speculative+r_fear +r_reservation +r_hesitant +r_gamble +r_risky +r_instability +r_doubtful +r_hazard +r_tricky +r_sticky +r_dangerous +r_tentative +r_hazardous +r_queries +r_danger +r_fluctuating +r_unstable +r_vague +r_erratic +r_query +r_jeopardize +r_unsettled +r_unpredictability +r_dilemma +r_skepticism +r_hesitancy +r_riskier +r_unresolved +r_unsure +r_irregular +r_jeopardy +r_suspicion +r_risking +r_peril +r_hesitating +r_risked +r_unreliable +r_unsafe +r_hazy +r_apprehension +r_unforeseeable +r_halting +r_wager +r_torn +r_precarious +r_undetermined +r_insecurity +r_debatable +r_undecided +r_dicey +r_indecision +r_wavering +r_iffy +r_faltering +r_endanger +r_quandary +r_insecure +r_changeable +r_riskiest +r_hairy +r_ambivalent +r_dubious +r_riskiness +r_treacherous +r_oscillating +r_perilous +r_tentativeness +r_unreliability +r_wariness +r_vagueness +r_dodgy +r_equivocation +r_indecisive +r_chancy +r_menace +r_qualm +r_vacillating +r_gnarly +r_disquiet +r_ambivalence +r_imperil +r_vacillation +r_incalculable +r_untrustworthy +r_equivocating +r_diffident +r_fickleness +r_misgiving +r_changeability +r_undependable +r_incertitude +r_fitful +r_parlous +r_unconfident +r_defenseless +r_unsureness +r_fluctuant +r_niggle +r_diffidence +r_precariousness +r_doubtfulness
gen anyrisk=0
replace anyrisk=1 if allrisk>0
gen top20risk=r_risk +r_risks +r_uncertainty +r_variable +r_chance +r_possibility +r_pending +r_uncertainties +r_uncertain +r_doubt +r_prospect +r_bet +r_variability +r_exposed +r_likelihood +r_threat +r_probability +r_unknown +r_varying +r_unclear 
gen anytop20risk=0
replace anytop20risk=1 if top20risk>0
gen top10risk=r_risk +r_risks +r_uncertainty +r_variable +r_chance +r_possibility +r_pending +r_uncertainties +r_uncertain +r_doubt 
gen anytop10risk=0
replace anytop10risk=1 if top10risk>0

* Keep relevant risk words
keep cik state ym allrisk anyrisk top20risk anytop20risk top10risk anytop10risk numfilings

destring(cik),replace

save "8kcontent_cik_state_ym", replace



**Construct CIK-state-month panel**
clear all
use "8kcontent"

* Expand to include one observation per state for each filing
expand 50

sort filename
quietly by filename: gen dup=cond(_N==1,0,_n)

* Count state mentions
gen state=""
replace state="AK" if s_alaska>0 & dup==1
replace state="AL" if s_alabama>0 & dup==2
replace state="AR" if s_arkansas>0 & dup==3
replace state="AZ" if s_arizona>0 & dup==4
replace state="CA" if s_california>0 & dup==5
replace state="CO" if s_colorado>0 & dup==6
replace state="CT" if s_connecticut>0 & dup==7
replace state="DE" if s_delaware>0 & dup==8
replace state="FL" if s_florida>0 & dup==9
replace state="GA" if s_georgia>0 & dup==10
replace state="HI" if s_hawaii>0 & dup==11
replace state="IA" if s_iowa>0 & dup==12
replace state="ID" if s_idaho>0 & dup==13
replace state="IL" if s_illinois>0 & dup==14
replace state="IN" if s_indiana>0 & dup==15
replace state="KS" if s_kansas>0 & dup==16
replace state="KY" if s_kentucky>0 & dup==17
replace state="LA" if s_louisiana>0 & dup==18
replace state="MA" if s_massachusetts>0 & dup==20
replace state="MD" if s_maryland>0 & dup==21
replace state="ME" if s_maine>0 & dup==22
replace state="MI" if s_michigan>0 & dup==23
replace state="MN" if s_minnesota>0 & dup==24
replace state="MO" if s_missouri>0 & dup==25
replace state="MS" if s_mississippi>0 & dup==26
replace state="MT" if s_montana>0 & dup==27
replace state="NC" if s_northcarolina>0 & dup==28
replace state="ND" if s_northdakota>0 & dup==29
replace state="NE" if s_nebraska>0 & dup==30
replace state="NH" if s_newhampshire>0 & dup==31
replace state="NJ" if s_newjersey>0 & dup==32
replace state="NM" if s_newmexico>0 & dup==33
replace state="NV" if s_nevada>0 & dup==34
replace state="NY" if s_newyork>0 & dup==35
replace state="OH" if s_ohio>0 & dup==36
replace state="OK" if s_oklahoma>0 & dup==37
replace state="OR" if s_oregon>0 & dup==38
replace state="PA" if s_pennsylvania>0 & dup==39
replace state="RI" if s_rhodeisland>0 & dup==40
replace state="SC" if s_southcarolina>0 & dup==41
replace state="SD" if s_southdakota>0 & dup==42
replace state="TN" if s_tennessee>0 & dup==43
replace state="TX" if s_texas>0 & dup==44
replace state="UT" if s_utah>0 & dup==45
replace state="VA" if s_virginia>0 & dup==46
replace state="VT" if s_vermont>0 & dup==48
replace state="WA" if s_washington>0 & dup==49
replace state="WI" if s_wisconsin>0 & dup==50
replace state="WV" if s_westvirginia>0 & dup==19
replace state="WY" if s_wyoming>0 & dup==47

drop if missing(state)

gen mentions=.
replace mentions=s_alaska if state=="AK"
replace mentions=s_alabama if state=="AL"
replace mentions=s_arkansas if state=="AR"
replace mentions=s_arizona if state=="AZ"
replace mentions=s_california if state=="CA"
replace mentions=s_colorado if state=="CO"
replace mentions=s_connecticut if state=="CT"
replace mentions=s_delaware if state=="DE"
replace mentions=s_florida if state=="FL"
replace mentions=s_georgia if state=="GA"
replace mentions=s_hawaii if state=="HI"
replace mentions=s_iowa if state=="IA"
replace mentions=s_idaho if state=="ID"
replace mentions=s_illinois if state=="IL"
replace mentions=s_indiana if state=="IN"
replace mentions=s_kansas if state=="KS"
replace mentions=s_kentucky if state=="KY"
replace mentions=s_louisiana if state=="LA"
replace mentions=s_massachusetts if state=="MA"
replace mentions=s_maryland if state=="MD"
replace mentions=s_maine if state=="ME"
replace mentions=s_michigan if state=="MI"
replace mentions=s_minnesota if state=="MN"
replace mentions=s_missouri if state=="MO"
replace mentions=s_mississippi if state=="MS"
replace mentions=s_montana if state=="MT"
replace mentions=s_northcarolina if state=="NC"
replace mentions=s_northdakota if state=="ND"
replace mentions=s_nebraska if state=="NE"
replace mentions=s_newhampshire if state=="NH"
replace mentions=s_newjersey if state=="NJ"
replace mentions=s_newmexico if state=="NM"
replace mentions=s_nevada if state=="NV"
replace mentions=s_newyork if state=="NY"
replace mentions=s_ohio if state=="OH"
replace mentions=s_oklahoma if state=="OK"
replace mentions=s_oregon if state=="OR"
replace mentions=s_pennsylvania if state=="PA"
replace mentions=s_rhodeisland if state=="RI"
replace mentions=s_southcarolina if state=="SC"
replace mentions=s_southdakota if state=="SD"
replace mentions=s_tennessee if state=="TN"
replace mentions=s_texas if state=="TX"
replace mentions=s_utah if state=="UT"
replace mentions=s_virginia if state=="VA"
replace mentions=s_vermont if state=="VT"
replace mentions=s_washington if state=="WA"
replace mentions=s_wisconsin if state=="WI"
replace mentions=s_westvirginia if state=="WV"
replace mentions=s_wyoming if state=="WY"

* Drop duplicates by filename and state
duplicates drop filename state, force

* Generate reporting date in year-month format
gen ym=ym(year(repdate),month(repdate))

* Sum term count for each state by CIK-state-month
collapse (sum) mentions , by(cik state ym)

* Keep relevant variables
keep cik state ym mentions

destring(cik),replace

save "8kstate_cik_state_ym", replace




********************************************************
**********  Process pre-election poll data  ************
********************************************************

clear all
use "pollpanel"

rename state statestr

gen state=""
replace state="AK" if statestr=="alaska"
replace state="AL" if statestr=="alabama"
replace state="AR" if statestr=="arkansas"
replace state="AZ" if statestr=="arizona"
replace state="CA" if statestr=="california"
replace state="CO" if statestr=="colorado"
replace state="CT" if statestr=="connecticut"
replace state="DE" if statestr=="delaware"
replace state="FL" if statestr=="florida"
replace state="GA" if statestr=="georgia"
replace state="HI" if statestr=="hawaii"
replace state="IA" if statestr=="iowa"
replace state="ID" if statestr=="idaho"
replace state="IL" if statestr=="illinois"
replace state="IN" if statestr=="indiana"
replace state="KS" if statestr=="kansas"
replace state="KY" if statestr=="kentucky"
replace state="LA" if statestr=="louisiana"
replace state="MA" if statestr=="massachusetts"
replace state="MD" if statestr=="maryland"
replace state="ME" if statestr=="maine"
replace state="MI" if statestr=="michigan"
replace state="MN" if statestr=="minnesota"
replace state="MO" if statestr=="missouri"
replace state="MS" if statestr=="mississippi"
replace state="MT" if statestr=="montana"
replace state="NC" if statestr=="northcarolina"
replace state="ND" if statestr=="northdakota"
replace state="NE" if statestr=="nebraska"
replace state="NH" if statestr=="newhampshire"
replace state="NJ" if statestr=="newjersey"
replace state="NM" if statestr=="newmexico"
replace state="NV" if statestr=="nevada"
replace state="NY" if statestr=="newyork"
replace state="OH" if statestr=="ohio"
replace state="OK" if statestr=="oklahoma"
replace state="OR" if statestr=="oregon"
replace state="PA" if statestr=="pennsylvania"
replace state="RI" if statestr=="rhodeisland"
replace state="SC" if statestr=="southcarolina"
replace state="SD" if statestr=="southdakota"
replace state="TN" if statestr=="tennessee"
replace state="TX" if statestr=="texas"
replace state="UT" if statestr=="utah"
replace state="VA" if statestr=="virginia"
replace state="VT" if statestr=="vermont"
replace state="WA" if statestr=="washington"
replace state="WI" if statestr=="wisconsin"
replace state="WV" if statestr=="westvirginia"
replace state="WY" if statestr=="wyoming"

* Construct vote margin among top two finishers
drop margin
gen margin=firstshare-secondshare

* Construct first and final poll margins for each election
bys state electionyear : egen finalpolldate=max(date)
gen finalpoll=0
replace finalpoll=1 if date==finalpolldate
gen finalmargin=margin if date==finalpolldate
bys state electionyear: egen finalpollmargin=max(finalmargin)
drop finalmargin

bys state electionyear : egen firstpolldate=min(date)
gen firstpoll=0
replace firstpoll=1 if date==firstpolldate
gen firstmargin=margin if date==firstpolldate
bys state electionyear: egen firstpollmargin=max(firstmargin)
drop firstmargin

* Construct minimum and maximum poll margins for each election
bys state electionyear: egen minpollmargin=min(margin)
bys state electionyear: egen maxpollmargin=max(margin)

* Construct poll margin trends
gen pollmargintrend=365*(finalpollmargin-firstpollmargin)/(finalpolldate-firstpolldate)
gen annpollmargintrend=365*(finalpollmargin-firstpollmargin)/(finalpolldate-firstpolldate)

* Keep necessary variables
keep state electionyear minpollmargin maxpollmargin firstpollmargin finalpollmargin pollmargintrend annpollmargintrend

duplicates drop state electionyear, force

save "pollsummary", replace

joinby state electionyear using "electiondata", unmatched(both)
drop _merge
duplicates drop state electiondate, force

gen minpollclose=0
replace minpollclose=1 if minpollmargin<.05
gen finalpollclose=0
replace finalpollclose=1 if finalpollmargin<.05
gen firstpollclose=0
replace firstpollclose=1 if firstpollmargin<.05

replace margin=margin/100

sort state electionyear
gen contested=0
replace contested=1 if margin[_n-1]<.10 & margin[_n-2]<.10 & state[_n-1]==state[_n-2]

keep state electiondate electionyear margin minpollclose finalpollclose firstpollclose annpollmargintrend term contested gridlock

save "merged election data", replace




********************************************************
********  Construct BEA input-output measures  *********
********************************************************
clear all
set more off

import delimited "bea_output_table.csv", varnames(1)

drop ind1110-ind8140

gen usetotalgovfrac = (s001+s002+s005+s006+s007+f06c+f06i+f07c+f07i+f08c+f08i+f09c+f09i)/t007
gen usestategovfrac = (s002+s007+f08c+f08i+f09c+f09i)/t007
gen useconsumptionfrac = f010/t007
gen useexport = f040/t007
gen usetrade = (f040-f050)/(t007-f050)

rename v1 naics4
keep naics4 useconsumptionfrac useexport usetrade pctstate

save "GovUse", replace


clear all
use "compustatannual.dta", clear

keep cik fyear naics
duplicates drop cik fyear, force

gen naics4=substr(naics,1,4)
drop if missing(naics)
destring(cik),replace

joinby naics4 using "GovUse.dta"

save "input output NAICS panel.dta", replace




********************************************************
***************  Process macro data  *******************
********************************************************

clear all
use "sp500 return"

joinby ym using "vix", unmatched(both)
drop _merge

joinby ym using "epu monthly", unmatched(both)
drop _merge

gen marketret=vwretd
gen sp500ret=sprtrn
gen epu=GlobalEPUIndexwithCurrentPr

keep marketret sp500ret epu vix ym

save "macro controls", replace




*****************************************************************
*******  Process COMPUSTAT data, merge with pr_risk data  *******
*****************************************************************

clear all
use "compustatquarterly.dta", clear

duplicates drop gvkey yq, force

gen roa=niq/atq
gen size=ln(1+atq)
gen m2b=(prccq*cshoq)/ceqq
gen lev=ltq/atq

winsor roa, gen(wroa) p(0.01)
winsor size, gen(wsize) p(0.01)
winsor m2b, gen(wm2b) p(0.01)
winsor lev, gen(wlev) p(0.01)

gen yq=yq(year(datadate),quarter(datadate))

keep gvkey yq wroa wsize wm2b wlev cusip6 sic cik cusip tic conm datadate rdq fyearq fqtr fyr 

gen gvkstr=gvkey
destring(gvkey),replace

gen cikstr=cik
destring(cik),replace

save "firm quarter level data", replace




*****************************************************************
*******  Construct event study blocks from election data  *******
*****************************************************************

clear all
use "merged election data"

gen ym=ym(year(electiondate),month(electiondate))
drop if missing(ym)

egen s=group(state)
tsset s ym

*Expand election month panel to include 24 months on each side of the election
expand 48

sort s ym
quietly by s ym: gen dup=cond(_N==1,0,_n)

replace dup=dup-25

rename ym electionym
gen ym=electionym+dup

gen electiondistance=ym-electionym
gen month=electiondistance+25

*Generate "post" variable based on month relative to the election
gen post=0
replace post=1 if electiondistance>=0

*Drop duplicates before interim merging
drop dup

save "merged election data blocks", replace




*****************************************************************
******************  Build estimation dataset  *******************
*****************************************************************

clear all
use "8kfullmonthlypanel"

* Merge state exposure data
joinby cik year using "state exposure panel", unmatched(both)
keep if _merge==3
drop _merge

*Merge election event study blocks 
joinby state ym using "merged election data blocks", unmatched(master)
drop _merge

* Merge controls and firm-level political risk measures 
joinby cik yq using "firm quarter level data", unmatched(master)
drop _merge

* Merge macro controls
joinby ym using "macro controls", unmatched(master)
drop _merge

* Merge BEA I/O Account Data
joinby cik year using "input output NAICS panel", unmatched(master)
drop _merge

* Merge 8-K content data at CIK-state-month level
joinby cik state ym using "8kcontent_cik_state_ym", unmatched(both)
drop if _merge==2
drop _merge

* Generate intensity of 8-K risk measures at CIK-state-month level
gen lnallrisk=ln(1+allrisk)
gen lntop10risk=ln(1+top10risk)
gen lntop20risk=ln(1+top20risk)

drop allrisk top20risk top10risk 
rename anyrisk anyriskfsm
rename lnallrisk lnallriskfsm 
rename lntop10risk lntop10riskfsm 
rename lntop20risk lntop20riskfsm 

* Merge 8-K content data at CIK-month level
joinby cik ym using "8kcontent_cik_ym", unmatched(both)
drop if _merge==2
drop _merge

* Generate intensity of 8-K risk measures at CIK-month level
gen lnallrisk=ln(1+allrisk)
gen lntop10risk=ln(1+top10risk)
gen lntop20risk=ln(1+top20risk)

* Identify highly regulated industries with 2-digit SICs
gen sic2=substr(sic,1,2)
destring(sic2),replace
gen highregulated=0
replace highregulated=1 if (sic2>59 & sic2<70) | (sic2>9 & sic2<15) | sic2==49

* Create and declare the firm-state-month panel
egen firmstateid=group(cik state)
egen id=group(cik state)
duplicates drop firmstateid ym, force
tsset firmstateid ym

* Generate indicator for top state exposure 
bys cik ym: egen topstateexposureVW=max(stateexposureVW)
gen topstate=0
replace topstate=1 if stateexposureVW==topstateexposureVW

* Generate election year and election cycle indicators
gen electionyr=floor((electionym/12)+1960)
gen electioncycle=1
replace electioncycle=2 if year>1996 & year<2001
replace electioncycle=3 if year>2000 & year<2005
replace electioncycle=4 if year>2004 & year<2009
replace electioncycle=5 if year>2008 & year<2013
replace electioncycle=6 if year>2012 & year<2017

* Construct measures of 8-K frequencies and intensities
gen lnchars=ln(1+numchar)
gen lnpress=ln(1+pressrelease)
gen lngraphics=ln(1+numgraphics)
gen lnexhibits=ln(1+numexhibits)

gen ln101=ln(1+item101)
gen ln102=ln(1+item102)
gen ln103=ln(1+item103)
gen ln104=ln(1+item104)
gen ln201=ln(1+item201)
gen ln202=ln(1+item202)
gen ln203=ln(1+item203)
gen ln204=ln(1+item204)
gen ln205=ln(1+item205)
gen ln206=ln(1+item206)
gen ln301=ln(1+item301)
gen ln302=ln(1+item302)
gen ln303=ln(1+item303)
gen ln401=ln(1+item401)
gen ln402=ln(1+item402)
gen ln501=ln(1+item501)
gen ln502=ln(1+item502)
gen ln503=ln(1+item503)
gen ln504=ln(1+item504)
gen ln505=ln(1+item505)
gen ln506=ln(1+item506)
gen ln507=ln(1+item507)
gen ln508=ln(1+item508)
gen ln601=ln(1+item601)
gen ln602=ln(1+item602)
gen ln603=ln(1+item603)
gen ln604=ln(1+item604)
gen ln605=ln(1+item605)
gen ln701=ln(1+item701)
gen ln801=ln(1+item801)
gen ln901=ln(1+item901)

*Generate measure of voluntary disclosure frequency
gen voluntary=item701+item801
replace voluntary=0 if missing(voluntary)
gen lnvoluntary=ln(1+voluntary)

*Generate measure of mandatory disclosure frequency
gen mandatory=numitems-item701-item801-item901-item202
replace mandatory=0 if mandatory<0
gen lnmandatory=ln(1+mandatory)

*Generate measure of proportion of voluntary disclosure 
gen volpct=(voluntary)/(voluntary+mandatory)

save "estimationdata.dta", replace
********************************************************
********************************************************
************  							 ***************  
************  Part 2: Estimation Output  ***************
************  							 ***************
********************************************************
********************************************************

* Install commands
ssc install reghdfe
ssc install maptile 
ssc install spmap
maptile_install using "http://files.michaelstepner.com/geo_state.zip"

* Set directory
cd "Data\" 

********************************************************
**********************  Figures  ***********************
********************************************************

*** Figure 1
** Panel A
use "estimationdata.dta"
bys state electionym: gen n=_n
replace margin = margin/100
twoway (kdensity firstpollmargin)||(kdensity finalpollmargin)||(kdensity margin) if n==1




** Panel B
clear all
use "estimationdata.dta"
bys state electionym: gen n=_n
hist annpollmargintrend if abs(annpollmargintrend)<0.5 & n==1, frac bin(15)




*** Figure 2
clear all
use "state exposure panel.dta"
keep if year==2014
collapse (sum) stateexposureVW, by(state)
maptile stateexposureVW, geo(state)




*** Figure 3
** Panel A
clear all
use "state exposure panel.dta"
keep if year==2014
hist stateexposureVW if stateexposureVW>0, bin(100) frac

** Panel B
clear all
use "state exposure panel.dta"
keep if year==2014
duplicates tag cik, gen(num)
duplicates drop cik, force 
replace num=num+1
hist num, bin(50) frac

** Panel C
clear all
use "state exposure panel.dta"
keep if year==2014
twoway (kdensity stateexposureVW if INCstate==1)||(kdensity stateexposureVW if HQstate==1)




********************************************************
**********************  Tables  ************************
********************************************************

***TABLE 1***
clear all
use "estimationdata.dta"

* 8-K Filings
summ numitems if post==0 & abs(electiondistance)<25,det
summ mandatory if post==0 & abs(electiondistance)<25,det
summ voluntary if post==0 & abs(electiondistance)<25,det
summ numchars if post==0 & abs(electiondistance)<25,det
summ numgraphics if post==0 & abs(electiondistance)<25,det
summ numexhibits if post==0 & abs(electiondistance)<25,det
summ pressrelease if post==0 & abs(electiondistance)<25,det
* Firms
summ assets if !missing(wm2b) & wm2b>0 & !missing(wlev) & !missing(wroa) & !missing(wsize) & post==0 & abs(electiondistance)<25,det
summ wroa if !missing(wm2b) & wm2b>0 & !missing(wlev) & !missing(wroa) & !missing(wsize) & post==0 & abs(electiondistance)<25,det
summ wlev if !missing(wm2b) & wm2b>0 & !missing(wlev) & !missing(wroa) & !missing(wsize) & post==0 & abs(electiondistance)<25,det
summ wm2b if !missing(wm2b) & wm2b>0 & !missing(wlev) & !missing(wroa) & !missing(wsize) & post==0 & abs(electiondistance)<25,det
* Elections
clear all
use "merged election data"
summ minpollclose, det
summ firstpollmargin,det
summ finalpollmargin,det
summ margin,det
summ term,det
summ contested,det
summ gridlock,det




***TABLE 2***
clear all
use "estimationdata.dta"
label variable minpollclose "Close"
qui: reghdfe lnmandatory c.minpollclose [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m1
qui: reghdfe lnmandatory wlev wsize wroa wm2b c.minpollclose [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m2
qui: reghdfe lnvoluntary c.minpollclose [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m3
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.minpollclose [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m4

estout m*, title("Table 2") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(minpollclose) varlabels(minpollclose "Close")
estimates clear



***TABLE 3***
clear all
use "estimationdata.dta"
label variable term "Term"
label variable contested "PastClose"
label variable gridlock "Gridlock"
qui: reghdfe lnmandatory wlev wsize wroa wm2b c.term [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m1
qui: reghdfe lnmandatory wlev wsize wroa wm2b c.contested [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m2
qui: reghdfe lnmandatory wlev wsize wroa wm2b c.gridlock [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m3
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.term [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m4
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.contested [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m5
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.gridlock [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m6

estout m*, title("Table 3") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(term contested gridlock) varlabels(term "Term" contested "PastClose" gridlock "Gridlock")
estimates clear




***TABLE 4***
clear all
use "estimationdata.dta"
label variable minpollclose "Close"
qui: reghdfe lnmandatory wlev wsize wroa wm2b c.minpollclose##c.highregulated [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid stateelection) cl(cik s)
estimates store m1
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.minpollclose##c.highregulated [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid stateelection) cl(cik s)
estimates store m2

estout m*, title("Table 4, Row 1") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(c.minpollclose#c.highregulated) varlabels(minpollclose#highregulated "Close $\times$ Regulated")
estimates clear

qui: reghdfe lnmandatory wlev wsize wroa wm2b c.minpollclose##c.pctstate [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid stateelection) cl(cik s)
estimates store m1
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.minpollclose##c.pctstate [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid stateelection) cl(cik s)
estimates store m2

estout m*, title("Table 4, Row 2") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(c.minpollclose#c.pctstate) varlabels(minpollclose#pctstate "Close $\times$ State Gov't")
estimates clear

qui: reghdfe lnmandatory wlev wsize wroa wm2b c.minpollclose##c.useconsumptionfrac [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid stateelection) cl(cik s)
estimates store m1
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.minpollclose##c.useconsumptionfrac [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid stateelection) cl(cik s)
estimates store m2

estout m*, title("Table 4, Row 3") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(c.minpollclose#c.useconsumptionfrac) varlabels(minpollclose#useconsumptionfrac "Close $\times$ Consumer")
estimates clear

qui: reghdfe lnmandatory wlev wsize wroa wm2b c.minpollclose##c.useexport [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid stateelection) cl(cik s)
estimates store m1
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.minpollclose##c.useexport [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid stateelection) cl(cik s)
estimates store m2

estout m*, title("Table 4, Row 4") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(c.minpollclose#c.useexport) varlabels(minpollclose#useexport "Close $\times$ Export")
estimates clear

qui: reghdfe lnmandatory wlev wsize wroa wm2b c.minpollclose##c.usetrade [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid stateelection) cl(cik s)
estimates store m1
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.minpollclose##c.usetrade [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid stateelection) cl(cik s)
estimates store m2

estout m*, title("Table 4, Row 5") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(c.minpollclose#c.usetrade) varlabels(minpollclose#usetrade "Close $\times$ Trade")
estimates clear


***TABLE 5***
clear all
use "estimationdata.dta"
label variable minpollclose "Close"
qui: reghdfe lnchars wlev wsize wroa wm2b c.minpollclose [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m1
qui: reghdfe lngraphics wlev wsize wroa wm2b c.minpollclose [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m2
qui: reghdfe lnpress wlev wsize wroa wm2b c.minpollclose [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m3
qui: reghdfe lnexhibits wlev wsize wroa wm2b c.minpollclose [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m4
qui: reghdfe aret3day wlev wsize wroa wm2b c.minpollclose [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m5
qui: reghdfe absaret3day wlev wsize wroa wm2b c.minpollclose [aw=stateexposureVW] if !missing(aret3day) & post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m6

estout m*, title("Table 5") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(minpollclose) varlabels(minpollclose "Close")
estimates clear



***TABLE 6***
clear all
use "estimationdata.dta"
label variable minpollclose "Close"
qui: reghdfe lnallrisk c.minpollclose wlev wsize wroa wm2b  [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m1
qui: reghdfe lntop10risk c.minpollclose wlev wsize wroa wm2b  [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m2
qui: reghdfe lntop20risk c.minpollclose wlev wsize wroa wm2b  [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m3
qui: reghdfe lnallriskfsm c.minpollclose wlev wsize wroa wm2b  [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m4
qui: reghdfe lntop10riskfsm c.minpollclose wlev wsize wroa wm2b  [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m5
qui: reghdfe lntop20riskfsm c.minpollclose wlev wsize wroa wm2b  [aw=stateexposureVW] if post==0 & abs(electiondistance)<25, abs(month firmstateid) cl(s cik)
estimates store m6

estout m*, title("Table 6") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(minpollclose) varlabels(minpollclose "Close")
estimates clear



***TABLE 7***
clear all
use "estimationdata.dta"
label variable minpollclose "Close"
label variable uncertaintrend "Pre-Election Trend"
qui: reghdfe lnmandatory wlev wsize wroa wm2b c.uncertaintrend [aw=stateexposureVW] if abs(electiondistance)<25 & post==0, abs(month firmstateid) cl(cik s)
estimates store m1
qui: reghdfe lnmandatory wlev wsize wroa wm2b c.minpollclose c.uncertaintrend [aw=stateexposureVW] if abs(electiondistance)<25 & post==0, abs(month firmstateid) cl(cik s)
estimates store m2
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.uncertaintrend [aw=stateexposureVW] if abs(electiondistance)<25 & post==0, abs(month firmstateid) cl(cik s)
estimates store m3
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.minpollclose c.uncertaintrend [aw=stateexposureVW] if abs(electiondistance)<25 & post==0, abs(month firmstateid) cl(cik s)
estimates store m4

estout m*, title("Table 7") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(minpollclose uncertaintrend) varlabels(minpollclose "Close" uncertaintrend "Pre-Election Trend")
estimates clear



***TABLE 8***
clear all
use "estimationdata.dta"
label variable minpollclose "Close"
label variable post "Post"
qui: reghdfe lnmandatory c.minpollclose##c.post [aw=stateexposureVW] if abs(electiondistance)<25, abs(firmstateid month) cl(cik##post s)
estimates store m1
qui: reghdfe lnmandatory wlev wsize wroa wm2b c.minpollclose##c.post [aw=stateexposureVW] if abs(electiondistance)<25, abs(firmstateid stateelection month) cl(cik##post s)
estimates store m2
qui: reghdfe lnvoluntary c.minpollclose##c.post [aw=stateexposureVW] if abs(electiondistance)<25, abs(firmstateid month) cl(cik##post s)
estimates store m3
qui: reghdfe lnvoluntary wlev wsize wroa wm2b c.minpollclose##c.post [aw=stateexposureVW] if abs(electiondistance)<25, abs(firmstateid stateelection month) cl(cik##post s)
estimates store m4

estout m*, title("Table 8") cells(b(star fmt(%9.4fc)) se(par)) label stats(r2 N, fmt(%9.3f %9.0fc) label("Adj. $ R^2$" "Obs.")) numbers mlabels(,none) collabels(,none) style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) varwidth(30) keep(minpollclose post c.minpollclose#c.post) varlabels(minpollclose "Close" post "Post" minpollclose#post "Close $\times$ Post")
estimates clear



