***********
use mafia_project_full_def_operazioni_rev1,clear

save stats_sample_criminal,replace
use stats_sample_criminal,clear



keep if CRIMINAL==1  // DUMMY VARIABLE EQUALS TO 1 FOR CRIMINAL FIRMS, 0 OTHERWISE
save stats_sample_criminal,replace

use stats_sample_criminal,clear


destring CODATECO_2,g(CODATECO_2_restring) // CODATECO is the identifier for the Industries according to the Italian Classification, CODATECO_2 are the first two digit of the code

g MACRO_INDUSTRY= 1 if CODATECO_2_restring >=1 & CODATECO_2_restring <=3
replace MACRO_INDUSTRY= 2 if CODATECO_2_restring >=10  & CODATECO_2_restring <=33
replace MACRO_INDUSTRY= 3 if CODATECO_2_restring ==35
replace MACRO_INDUSTRY= 4 if CODATECO_2_restring >=36  & CODATECO_2_restring <=39
replace MACRO_INDUSTRY= 5 if CODATECO_2_restring >=41  & CODATECO_2_restring <=43
replace MACRO_INDUSTRY= 6 if CODATECO_2_restring >=45  & CODATECO_2_restring <=47
replace MACRO_INDUSTRY= 7 if CODATECO_2_restring >=49  & CODATECO_2_restring <=53
replace MACRO_INDUSTRY= 8 if CODATECO_2_restring >=55  & CODATECO_2_restring <=56
replace MACRO_INDUSTRY= 9 if CODATECO_2_restring >=58  & CODATECO_2_restring <=63
replace MACRO_INDUSTRY= 10 if CODATECO_2_restring >=64 & CODATECO_2_restring <=66
replace MACRO_INDUSTRY= 11 if CODATECO_2_restring ==68
replace MACRO_INDUSTRY= 12 if CODATECO_2_restring >=69 & CODATECO_2_restring <=75
replace MACRO_INDUSTRY= 13 if CODATECO_2_restring >=77 & CODATECO_2_restring <=82
replace MACRO_INDUSTRY= 14 if CODATECO_2_restring ==85
replace MACRO_INDUSTRY= 15 if CODATECO_2_restring >=86 & CODATECO_2_restring <=88
replace MACRO_INDUSTRY= 16 if CODATECO_2_restring >=90 & CODATECO_2_restring <=93
replace MACRO_INDUSTRY= 17 if CODATECO_2_restring >=94 & CODATECO_2_restring <=96


egen id_operazione=group(ANNO_OP)


bysort CF:egen max_istat= max(COMUNE_Istat)
bysort CF:egen min_istat= min(COMUNE_Istat)

count if max_istat != min_istat
egen unique_CF = tag(CF)
egen uniq=tag(COMUNE_Istat) //The variable COMUNE_Istat uniquely identifies each Municipality

save stats_sample_criminal,replace

use stats_sample_criminal,clear

***// In the following I identify Municipalities hit by police actions only once and apply sample selection criteria

use stats_sample_criminal,clear

keep if ANNO_OP==2005  //ANNO_OP is the year of the Anti-Mafia Action
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2005,replace

use stats_sample_criminal,clear


keep if ANNO_OP==2006
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2006,replace

use stats_sample_criminal,clear

keep if ANNO_OP==2007
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2007,replace

use stats_sample_criminal,clear

keep if ANNO_OP==2008
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2008,replace

use stats_sample_criminal,clear

keep if ANNO_OP==2009
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2009,replace

use stats_sample_criminal,clear

keep if ANNO_OP==2010
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2010,replace

use stats_sample_criminal,clear

keep if ANNO_OP==2011
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2011,replace

use stats_sample_criminal,clear

keep if ANNO_OP==2012
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2012,replace

use stats_sample_criminal,clear

keep if ANNO_OP==2013
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2013,replace

use stats_sample_criminal,clear

keep if ANNO_OP==2014
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2014,replace

use stats_sample_criminal,clear

keep if ANNO_OP==2015
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2015,replace

use stats_sample_criminal,clear

keep if ANNO_OP==2016
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat PROV_id ANNO_OP
save comuni_only_2016,replace


use comuni_only_2005,clear

append using comuni_only_2006 comuni_only_2007 comuni_only_2008 comuni_only_2009 comuni_only_2010 comuni_only_2011 comuni_only_2012 comuni_only_2013 comuni_only_2014 comuni_only_2015 comuni_only_2016
keep COMUNE_Istat PROV_id ANNO_OP
sort COMUNE_Istat ANNO_OP

drop tag
egen tag_comune_doppio= tag(COMUNE_Istat)

keep if tag_comune_doppio==0
egen tag=tag(COMUNE_Istat)
keep if tag==1
save munic_to_drop,replace

use stats_sample_criminal,clear

merge m:1 COMUNE_Istat using munic_to_drop
keep if _merge==1
drop _merge
drop tag

merge m:1 COMUNE_Istat using comuni_only_2005
keep if _merge==1
drop _merge

merge m:1 COMUNE_Istat using comuni_only_2006
keep if _merge==1
drop _merge

merge m:1 COMUNE_Istat using comuni_only_2015
keep if _merge==1
drop _merge

merge m:1 COMUNE_Istat using comuni_only_2016
keep if _merge==1
drop _merge

save stats_sample_criminal_rev1,replace

use stats_sample_criminal_rev1,replace
egen tag=tag(COMUNE_Istat CODATECO_2)
keep if tag==1
keep COMUNE_Istat CODATECO_2 ANNO_OP
save munic_ateco_clean, replace

use stats_sample_criminal_rev1,replace
egen tag=tag(COMUNE_Istat)
keep if tag==1
keep COMUNE_Istat  ANNO_OP
save munic_clean, replace

use stats_sample_criminal_rev1,replace
egen tag=tag(PROV_id) //PROV_id is the identifier for the Province
keep if tag==1
keep PROV_id  ANNO_OP
save province_clean, replace

use stats_sample_criminal_rev1,replace
egen tag=tag( CODATECO_2)
keep if tag==1
keep CODATECO_2 ANNO_OP
save ateco_clean, replace

// now I identify treated  firms (peers) and control firms (non peers)

use mafia_project_full_def_operazioni_rev1, clear


keep if CRIMINAL==0 //now I use non-Mafia firms

merge m:1 COMUNE_Istat using munic_to_drop
keep if _merge==1
drop _merge


merge m:1 COMUNE_Istat using comuni_only_2005
keep if _merge==1
drop _merge

merge m:1 COMUNE_Istat using comuni_only_2006
keep if _merge==1
drop _merge

merge m:1 COMUNE_Istat using comuni_only_2015
keep if _merge==1
drop _merge

merge m:1 COMUNE_Istat using comuni_only_2016
keep if _merge==1
drop _merge

merge m:1 COMUNE_Istat CODATECO_2 using munic_ateco_clean
drop if _merge==2


g treated=0
replace treated = 1 if _merge==3

drop _merge
drop ANNO_OP

merge m:1 COMUNE_Istat  using munic_clean
g COMUNI_RIPULITI=1 if _merge==3
drop if _merge==2
drop _merge

merge m:1 PROV_id  using province_clean
g PROV_RIPULITE=1 if _merge==3
drop if _merge==2
drop _merge

merge m:1 CODATECO_2  using ateco_clean
g ATECO_RIPULITI=1 if _merge==3
drop if _merge==2
drop _merge
save master,replace


use master,clear

keep if COMUNI_RIPULITI==1

save master_rev1,replace

use  master_rev1,clear

g post =0
replace post =1 if ANNO > ANNO_OP
replace post =. if ANNO_OP==.

g post_treated = post*treated  // This is the variable Anti-Mafia Action in the paper

drop if ANNO ==ANNO_OP

g log_assets = ln(TotAttivo)
g ebitda_assets = (RisulOperativo + TotAmmSval + AcctoRischi + AltriAccti)/ TotAttivo
g D_E= TotDebiti/TotPN

winsor D_E,g(D_E_w) p(0.01)
winsor log_assets,g(log_assets_w) p(0.01)
winsor ebitda_assets, g(ebitda_assets_w) p(0.01)


replace AltriRicavi = 0 if AltriRicavi==.

g CASH = DispLiquide/TotAttivo
g COGS = TotCostiProd/TotAttivo
g DEBT = TotDebiti/TotAttivo
g INTEREST = TotOneriFin/TotAttivo
g INVENTORY_PERIOD =  Rimanenze / (  RicaviVend + AltriRicavi) *365   //computed as in aida
replace INVENTORY_PERIOD = 0 if INVENTORY_PERIOD==. & Rimanenze !=.
g ROA = RisAnteImposte/TotAttivo
g SALES = RicaviVend / TotAttivo
g WAGES = (TotPersonale)/ TotAttivo
g log_ppe = log(1+ImmobMat)
g operating_performance= (ebitda + OneriDiversi - AltriRicavi - TotOneriFin)/(TotValProd)
g raw_material= MatPrime/TotCostiProd

foreach var of varlist CASH COGS DEBT  INTEREST INVENTORY_PERIOD  ROA  SALES WAGES log_ppe operating_performance raw_material {
	winsor `var' , generate(`var'_w) p(0.01)
	}
	

egen CF_id = group(CF)
egen COMUNE_id = group(COMUNE_Istat)
egen CODATECO_id = group(CODATECO_2)

tab ANNO,g(ANNO)
tab CODATECO_id,g(CODATECO_id)
tab COMUNE_id,g(COMUNE_id)


g gaap_etr = TotImposte / RisAnteImposte
replace gaap_etr = . if RisAnteImposte <0
winsor gaap_etr, g(gaap_etr_w) p(0.01)

g tax_avoidance_w = -1*gaap_etr_w

sum tax_avoidance_w,d
g tax_avoidance_bounded= tax_avoidance_w
replace tax_avoidance_bounded =- 1 if tax_avoidance_w < -1

drop if tax_avoidance_bounded==. |   log_assets==. |  D_E ==. | ebitda_assets ==.

xtset CF_id ANNO
 
sort CF_id ANNO
 
 g tax_avoidance_bounded_minus1 = l.tax_avoidance_bounded
 g tax_avoidance_bounded_minus2 = l2.tax_avoidance_bounded
 g tax_avoidance_bounded_minus3 = l3.tax_avoidance_bounded
 
egen  tax_avoidance_bounded_3year =rowmean(tax_avoidance_bounded  tax_avoidance_bounded_minus1 tax_avoidance_bounded_minus2)

save master_rev1,replace


use  mafia_project_full_def_operazioni_rev1,clear

keep if ANNO==2005
bysort COMUNE_Istat  CODATECO_2 : egen number_firms=count(CF)
egen unique2= tag(COMUNE_Istat  CODATECO_2)
keep if unique2==1
save comune_number_firms,replace

use  master_rev1,clear

merge m:1 COMUNE_Istat  CODATECO_2 using comune_number_firms, keepusing(number_firms)
drop if _merge==2
drop _merge
sum number_firms,d
g many_firm= 0
replace many_firm =1 if number_firms > r(p50)

g many_firm_inter= many_firm*post_treated
g many_firm_post= many_firm*post
g many_firm_treated= many_firm*treated
g many_assets=log_assets_w*many_firm
g many_DE = many_firm* D_E_w
g many_ebitda= many_firm*ebitda_assets_w


save  master_rev2,replace


use master_rev2,clear
merge m:1 COMUNE_Istat using operazioni_gdf_touse, keepusing(GDF) //the database "operazioni_gdf_touse" classifies Anti-Mafia Police actions according to whether they have been carried out by the Guardia di Finanza or not (variable GDF)

keep if _merge==3
drop _merge


g post_treated_GDF= post_treated*GDF
g post_GDF= post* GDF 
g treated_GDF= treated * GDF

save master_rev3,replace


use data_gdf_full,clear //This database is a subsample of the AIDA database to be used in the test involving police action by Guardia di Finanza only

g log_assets = ln(TotAttivo)
winsor log_assets,g(log_assets_w) p(0.01)
g ebitda_assets = (RisulOperativo + TotAmmSval + AcctoRischi + AltriAccti)/ TotAttivo
winsor ebitda_assets,g(ebitda_assets_w) p(0.01)
g D_E = TotDebiti/TotPN
winsor D_E, g(D_E_w) p(0.01)

g RisAnteImposte = UtileEserc + TotImposte
g gaap_etr = TotImposte / RisAnteImposte
replace gaap_etr = . if RisAnteImposte <0
winsor gaap_etr, g(gaap_etr_w) p(0.01)

g tax_avoidance_w = -1*gaap_etr_w

sum tax_avoidance_w,d
g tax_avoidance_bounded= tax_avoidance_w
replace tax_avoidance_bounded =- 1 if tax_avoidance_w < -1


merge m:1 COMUNE_Istat using comuni_gdf_yes_mafia_touse,keepusing(anno_operazione) //the database "comuni_gdf_yes_mafia_touse" includes the municipalities hit by a GDF Action against Mafia firms
drop if _merge==2
drop _merge

drop if anno_operazione==.

g ateco_two = substr(CODATECO,1,2)
g treated= 0
merge m:1 ateco_two COMUNE_Istat using treated_gdf_yesmafia,keepusing(nome_dell_operazione) // the database "treated_gdf_yesmafia" ibcludes Municipalities-Industries pairs involved by a GDF Action against Mafia firms
replace treated=1 if _merge==3
drop if _merge==2
drop _merge

g post = 0
replace post = 1 if ANNO > anno_operazione
g post_treated = post*treated

egen CF_id=group(CF)
egen COMUNE_id=group(COMUNE_Istat)


save database_gdf_related,replace


use data_gdf_full,clear 

g log_assets = ln(TotAttivo)
winsor log_assets,g(log_assets_w) p(0.01)
g ebitda_assets = (RisulOperativo + TotAmmSval + AcctoRischi + AltriAccti)/ TotAttivo
winsor ebitda_assets,g(ebitda_assets_w) p(0.01)
g D_E = TotDebiti/TotPN
winsor D_E, g(D_E_w) p(0.01)

g RisAnteImposte = UtileEserc + TotImposte
g gaap_etr = TotImposte / RisAnteImposte
replace gaap_etr = . if RisAnteImposte <0
winsor gaap_etr, g(gaap_etr_w) p(0.01)

g tax_avoidance_w = -1*gaap_etr_w

sum tax_avoidance_w,d
g tax_avoidance_bounded= tax_avoidance_w
replace tax_avoidance_bounded =- 1 if tax_avoidance_w < -1


merge m:1 COMUNE_Istat using comuni_gdf_no_mafia_touse,keepusing(anno_operazione) //the database "comuni_gdf_no_mafia_touse" includes the municipalities hit by a GDF Action against non-Mafia firms
drop if _merge==2
drop _merge

drop if anno_operazione==.

g ateco_two = substr(CODATECO,1,2)
g treated= 0
merge m:1 ateco_two COMUNE_Istat using treated_gdf_nomafia,keepusing(nome_dell_operazione) // the database "treated_gdf_nomafia" includes Municipalities-Industries pairs involved by a GDF Action against non-Mafia firms
replace treated=1 if _merge==3
drop if _merge==2
drop _merge

g post = 0
replace post = 1 if ANNO > anno_operazione
g post_treated = post*treated

egen CF_id=group(CF)
egen COMUNE_id=group(COMUNE_Istat)


save database_gdf_unrelated,replace
