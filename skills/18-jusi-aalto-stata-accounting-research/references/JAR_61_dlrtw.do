***********************************************************************************************************
*** Journal of Accounting Research                                                                      ***
*** Renewable Governance: Good for the Environment? 													***
*** Dyck, Lins, Roth, Towner, and Wagner (2021)															***
*** November 18, 2021																					***
***********************************************************************************************************


*** Table of Contents (TOC) ***
* Step 1: Merge Worldscope to Header File and Create Balanced Panel
* Step 2: Construct Asset4 Lead Variables and Merge to Worldscope Panel
* Step 3: Merge Factset Ownership Data to Worldscope Panel
* Step 4: Merge Orbis to Worldscope Panel Using Two Data Pulls from Orbis
* Step 5: Construct Asset4 Governance Line Items Panel
* Step 6: Merge Datastream Ownership to Worldscope Panel
* Step 7: Merge Country Time-invariant Variables to Worldscope Panel
* Step 8: Merge BoardEx Panels to Worldscope Panel
* Step 9: Merge ADR Status to Worldscope Panel
* Step 10: Merge Gender Quota Data to Worldscope Panel
* Step 11: Merge GBIF List of Top 100 Family Firms to Worldscope Panel
* Step 12: Merge SASB Sustainability E Scores to Worldscope Panel
* Step 13: Merge and Create Traditional Firm Governance Measures
* Step 14: Merge and Create Alternative E and S Measures
* Step 15: Filter to Ensure Consistent Sample
* Step 16: Generate and Winsorize all Variables
*** End TOC ***


***********************************************************************************************************
* Step 1: Merge Worldscope to Header File and Create Balaned Panel
***********************************************************************************************************

cd "/Users/mitchtowner/Dropbox/DLRTW_Governance"  /// Mitch Laptop

*** Import header file
import delimited "data/header/Header_15feb18.csv", clear 
sort entity_key
save "data/header/header2_new", replace

*** Clean Worldscope to create a semi-balanced panel and identify fiscal year-end from 2000 on
use "data/worldscope/worldscope-1-19-2018", clear
drop if year<2000
drop if ccode == "USA"
gen month = month(fyr)
gen quarter = 1
replace quarter = 2 if month>3 & month<7
replace quarter = 3 if month>6 & month<10
replace quarter = 4 if month>9

*** Assume missing fyr is end of the calendar year
assert quarter>0 & quarter<5
gen yq = yq(year,quarter)
format yq %tq
order entity_name entity_key ccode fyr year yq sic 
drop month quarter
sort entity_key
save "stata/datasets/worldscope_panel", replace

*** Do merge on worldscope identifier
mmerge entity_key using "data/header/header2_new"
keep if _merge == 3
drop _merge
order worldscopepermid - samefirm, after(yq)
sort asset4companyid year
save "stata/datasets/worldscope_merge", replace


***********************************************************************************************************
* Step 2: Construct Asset4 Lead Variables and Merge to Worldscope Panel
***********************************************************************************************************

*** Construct Asset4 Panel
use "data/asset4/ES_scores_18-08-07.dta", clear
drop if ENVSCORE == .
drop ta fyr
rename yq yq_asset4
rename ds_code dscode
rename ASSET4CompanyID asset4companyid

*** Drop UK Version of Royal Dutch
sort asset4companyid year yq_asset4 country 
by asset4companyid year: keep if _n == _N
gen panelid = 0 
bysort asset4companyid: replace panelid = 1 if _n == 1
replace panelid = sum(panelid)
xtset panelid year

*** Construct Annual E Scores
gen overall_e = enviro_score*100/3
gen overall_e_material = enviro_score_material*100/3

*** Convert Contemperaneous E Scores to Lead Variables
bysort panelid: gen e1_lead = F.overall_e
bysort panelid: gen e2_lead = F.ENVSCORE
bysort panelid: gen e3_lead = F.ENER
bysort panelid: gen e4_lead = F.ENPI
bysort panelid: gen e5_lead = F.ENRR
bysort panelid: gen enviro_er_score_lead = F.enviro_er_score*100
bysort panelid: gen enviro_rr_score_lead = F.enviro_rr_score*100
bysort panelid: gen enviro_pi_score_lead = F.enviro_pi_score*100
bysort panelid: gen e_material_lead = F.overall_e_material

*** Merge to Worldscope Panel
sort asset4companyid year 
mmerge asset4companyid year using "stata/datasets/worldscope_merge"
drop if _merge <3
order entity_name - samefirm 
sort factset_entity_id yq
save "stata/datasets/worldscope_merge", replace


***********************************************************************************************************
* Step 3: Merge Factset Ownership Data to Worldscope Panel
***********************************************************************************************************

*** Clean Factset Ownership Panel
use "data/factset/holdings_by_firm_msci_Hannes_13Nov2017", clear
gen year = floor(quarter/100)
gen quarter2 = quarter- year*100
gen yq = yq(year,quarter2)
format yq %tq
drop cusip isin sedol quarter year quarter2
drop if factset_entity_id == ""
sort factset_entity_id yq
keep factset_entity_id io- yq

*** Merge Factset Ownership Data
mmerge factset_entity_id yq using "stata/datasets/worldscope_merge"
drop if _merge == 1
order entity_name - yq_asset4 yq 
sort isin1 year
duplicates drop entity_key year, force // Has 109 duplicate firm-year observations due to duplicate BoardEx IDs 
drop _merge
save "stata/datasets/worldscope_merge", replace   


***********************************************************************************************************
* Step 4: Merge Orbis to Worldscope Panel Using Two Data Pulls from  Orbis
***********************************************************************************************************

/* Note: We had cleaned Orbis data from a publication at RFS that we supllemented with an updated panel of Orbis data. 
We manually matched various ISIN and SEDOLs to company name and country in the master file and sequentially merged across these identifiers.*/

*** Merge Orbis by each ISIN and SEDOL from Master File for 2009 on
use "stata/datasets/worldscope_merge", clear
keep entity_key year isin1 isin2 isin3 isin4 sedol1 sedol2 sedol3 sedol4
save "stata/datasets/worldscope_orbis_merge", replace

*** Merge on isin1
use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if ISINNumber == ""
rename ISINNumber isin1
bysort isin1 year: keep if _n == _N
mmerge isin1 year using "stata/datasets/worldscope_orbis_merge"
keep if _merge ==3
save "stata/datasets/total_merge", replace

use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if ISINNumber == ""
rename ISINNumber isin1
bysort isin1 year: keep if _n == _N
mmerge isin1 year using "stata/datasets/worldscope_orbis_merge"
keep if _merge ==2
sort isin2 year
save "stata/datasets/orbis_remainder", replace

*** Merge on isin2
use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if ISINNumber == ""
rename ISINNumber isin2
bysort isin2 year: keep if _n == _N
mmerge isin2 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if ISINNumber == ""
rename ISINNumber isin2
bysort isin2 year: keep if _n == _N
mmerge isin2 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort sedol1 year
save "stata/datasets/orbis_remainder", replace

*** Merge on sedol1
use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if SEDOLNumber == ""
rename SEDOLNumber sedol1
bysort sedol1 year: keep if _n == _N
mmerge sedol1 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if SEDOLNumber == ""
rename SEDOLNumber sedol1
bysort sedol1 year: keep if _n == _N
mmerge sedol1 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort isin3 year
save "stata/datasets/orbis_remainder", replace

*** Merge on isin3
use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if ISINNumber == ""
rename ISINNumber isin3
bysort isin3 year: keep if _n == _N
mmerge isin3 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if ISINNumber == ""
rename ISINNumber isin3
bysort isin3 year: keep if _n == _N
mmerge isin3 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort sedol2 year
save "stata/datasets/orbis_remainder", replace

*** Merge on sedol2
use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if SEDOLNumber == ""
rename SEDOLNumber sedol2
bysort sedol2 year: keep if _n == _N
mmerge sedol2 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if SEDOLNumber == ""
rename SEDOLNumber sedol2
bysort sedol2 year: keep if _n == _N
mmerge sedol2 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort sedol3 year
save "stata/datasets/orbis_remainder", replace

*** Merge on sedol3
use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if SEDOLNumber == ""
rename SEDOLNumber sedol3
bysort sedol3 year: keep if _n == _N
mmerge sedol3 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if SEDOLNumber == ""
rename SEDOLNumber sedol3
bysort sedol3 year: keep if _n == _N
mmerge sedol3 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort sedol4 year
save "stata/datasets/orbis_remainder", replace

*** Merge on sedol4
use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if SEDOLNumber == ""
rename SEDOLNumber sedol4
bysort sedol4 year: keep if _n == _N
mmerge sedol4 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/orbis_annualpanel", clear
drop if year<2009
drop if SEDOLNumber == ""
rename SEDOLNumber sedol4
bysort sedol4 year: keep if _n == _N
mmerge sedol4 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort isin1 year
save "stata/datasets/orbis_remainder", replace

*** Merge Orbis by each ISIN and SEDOL from Master File for 2005 to 2008
*** Merge on isin1
use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename isin isin1
sort isin1 year
mmerge isin1 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename isin isin1
sort isin1 year
mmerge isin1 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort isin2 year
save "stata/datasets/orbis_remainder", replace

*** Merge on isin2
use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename isin isin2
sort isin2 year
mmerge isin2 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename isin isin2
sort isin2 year
mmerge isin2 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort isin3 year
save "stata/datasets/orbis_remainder", replace

***Merge on isin3
use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename isin isin3
sort isin3 year
mmerge isin3 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename isin isin3
sort isin3 year
mmerge isin3 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort sedol1 year
save "stata/datasets/orbis_remainder", replace

*** Merge on sedol1
use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename sedol sedol1
sort sedol1 year
mmerge sedol1 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename sedol sedol1
sort sedol1 year
mmerge sedol1 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort sedol2 year
save "stata/datasets/orbis_remainder", replace

*** Merge on sedol2
use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename sedol sedol2
sort sedol2 year
mmerge sedol2 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename sedol sedol2
sort sedol2 year
mmerge sedol2 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort sedol3 year
save "stata/datasets/orbis_remainder", replace

*** Merge on sedol3
use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename sedol sedol3
sort sedol3 year
mmerge sedol3 year using "stata/datasets/orbis_remainder"
keep if _merge == 3
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename sedol sedol3
sort sedol3 year
mmerge sedol3 year using "stata/datasets/orbis_remainder"
keep if _merge == 2 | _merge == -2
sort sedol4 year
save "stata/datasets/orbis_remainder", replace

*** Merge on sedol4
use "data/orbis/RFS2013_2005to2009_nonUSfirms", clear
drop if year>2008
drop country
rename sedol sedol4
sort sedol4 year
mmerge sedol4 year using "stata/datasets/orbis_remainder"
drop if _merge == 1
append using "stata/datasets/total_merge"
save "stata/datasets/total_merge", replace

*** Generate Orbis Variables Consistency Across two Pulls of Orbis
use "stata/datasets/total_merge", clear
keep entity_key year BvDIDNumber - uonamenew tFam - tOther
gen widelyheld = 0 if filter <3
gen familycontrol = 0 if filter <3
gen govtcontrol = 0 if filter <3
gen otherblockcontrol = 0 if filter <3
replace widelyheld = 1 if uotypenew == "widely held"
replace familycontrol = 1 if uotypenew == "family"
replace govtcontrol = 1 if uotypenew == "gov"
replace otherblockcontrol = 1 if uotypenew == "nominee" | uotypenew == "mixfin" | uotypenew == "insur" | uotypenew == "indus" | uotypenew == "bank"
replace widelyheld = tWid if tWid !=.
replace familycontrol = tFam if tFam !=.
replace govtcontrol = tGov if tGov !=.
replace otherblockcontrol = tOther if tOther !=.
duplicates report entity_key year
save "stata/datasets/total_merge", replace

*** Merge Consitent Orbis to Worldscope Panel
use "stata/datasets/worldscope_merge", clear
joinby entity_key year using "stata/datasets/total_merge", unma(ma)
drop _merge
duplicates report entity_key year
save "stata/datasets/sampletmp", replace


***********************************************************************************************************
* Step 5: Construct Asset4 Governance Line Items Panel
***********************************************************************************************************

*** Load First Set of Governance Items
use "data/asset4/gov-line-items", clear
bysort asset4companyid yq: keep if _n == _N
save "stata/datasets/gov-line-items_merge", replace

*** Load Second set of Governance Items
use "data/asset4/gov-line-items-2", clear
bysort asset4companyid yq: keep if _n == _N
save "stata/datasets/gov-line-items-2_merge", replace

*** Combine Governance Items
use "stata/datasets/sampletmp", clear
joinby asset4companyid yq using "stata/datasets/gov-line-items_merge", unma(ma)
drop _merge
joinby asset4companyid yq using "stata/datasets/gov-line-items-2_merge", unma(ma)
drop _merge

*** Rename Variables by Definition
rename QCGSRDP022 dualclass
rename QCGSRDP023 novoteshares
rename QCGSRDP024 doublevoteshares
rename QCGSRDP025 priorityshares
rename QCGSRDP026 votingcap
rename QCGSRDP033 majorityelections
rename QCGSRDP059 nocumulativevoting
rename QCGSRO01V allcommonstock
rename QCGSRO02V equalvoting
rename QCGSRO05V vetopower

***Construct Governance Variables
gen controlrights_nocf = 0
replace controlrights_nocf = 1 if dualclass == 1 | novoteshares == 1 | doublevoteshares == 1
regress CGVSCORE priorityshares votingcap majorityelections vetopower controlrights_nocf
predict cgv_resid, residuals
rename QCGBSDP060 a4_boardmembers
gen a4_pctwomen = QCGBSO03V/100
rename QCGBSO05V a4_avgboardtenure
gen a4_pctnonexecutive  = QCGBSO06V/100
gen a4_pctindependent = QCGBSO07V/100
gen a4_pctstrictindependent = QCGBSO08V/100
rename QCGBSO09V a4_dualceochair
gen a4_pctbiggestowner = QCGSRDP045/100
gen a4_pctvotebiggestowner = QCGSRDP046/100
rename QCGSRDP048 a4_vetopower
rename QCGSRDP049 a4_soe 
gen a4_pctblockholder = QCGSRO03V/100
duplicates report entity_key year


***********************************************************************************************************
* Step 6: Merge Datastream Ownership to Worldscope Panel
***********************************************************************************************************

joinby asset4companyid yq using "data/datastream/free-float-items-9-22-18", unma(ma)
drop _merge
duplicates report entity_key year


***********************************************************************************************************
* Step 7: Merge Country Time-invariant Variables to Worldscope Panel
***********************************************************************************************************

*** Mergen Static Country Variables
joinby ccode using "data/country data/country-level-data-static", unma(ma)
drop _merge
duplicates report entity_key year
save "stata/datasets/sampletmp", replace

*** Merge Secreg 
use "data/country data/secreg", clear
drop wb_country_name
save "stata/datasets/secreg_merge", replace
use "stata/datasets/sampletmp", clear
joinby ccode using "stata/datasets/secreg_merge", unma(ma)
drop _merge

*** Merge Country Governance Variables
joinby ccode using "data/country data/govern", unma(ma)
drop _merge
joinby ccode using "data/country data/esg-disclosure-rules-new", unma(ma)
drop _merge
gen mandatory_disc = 0
replace mandatory_disc = 1 if year>=mandatoryesgdisclosureyear
gen stewardship = 0
replace stewardship = 1 if year>=stewardshipcodeyear
save "stata/datasets/sampletmp", replace


***********************************************************************************************************
* Step 8: Merge BoardEx Panels to Worldscope Panel
***********************************************************************************************************

*** Merge Overall BoardEx Traits
joinby boardex_companyid year using "stata/datasets/boardex_panel27august_all", unma(ma)
drop _merge
duplicates report entity_key year


***********************************************************************************************************
* Step 9: Merge Cross-listing Status to Worldscope Panel
***********************************************************************************************************

*** Merge US cross-listing data										
joinby entity_key using "data/cross-listing/US-exchange-traded", unma(ma)
drop _merge

**Construct Cross-list Variable
gen adrstartyear = year(date_eff)
gen adrendyear =  year(date_inactive)
gen ADR = 0
replace ADR = 1 if year>=adrstartyear & year<=adrendyear & adrendyear != .
replace ADR = 1 if date_inactive == td(31dec2015) & year == 2016 
drop adrstartyear adrendyear

**Merge ADR Data
joinby entity_key using "data/cross-listing/ADR-exchange-traded", unma(ma)
drop _merge

**Construct ADR for non-US
gen adrstartyear = year(date_eff_ADR)
gen adrendyear =  year(date_inactive_ADR)
replace ADR = 1 if year>=adrstartyear & year<=adrendyear & adrendyear != .
replace ADR = 1 if date_inactive == td(1dec2015) & year == 2016 
drop adrstartyear adrendyear

drop date_eff date_inactive date_eff_ADR date_inactive_ADR
duplicates report entity_key year
save "stata/datasets/sampletmp", replace


***********************************************************************************************************
* Step 10: Merge Gender Quota Data to Worldscope Panel
***********************************************************************************************************

*** Merge Gender Quota Data
import excel "data/country data/genderquota.xlsx", sheet("Sheet1") firstrow clear
drop if ccode == ""
drop europe
save "stata/datasets/genderquota", replace

use "stata/datasets/sampletmp", clear
joinby ccode using "stata/datasets/genderquota", unma(ma)
drop _merge
duplicates report entity_key year
save "stata/datasets/sampletmp", replace


***********************************************************************************************************
* Step 11: Merge GBIF List of Top 100 Family Firms to Worldscope Panel
***********************************************************************************************************

*** Merge manual family firm checks
import delimited "data/family firms/FamilyCheck4June.csv", clear 
keep entity_key familygbiftop00
keep if familygbiftop00 == 1
bysort entity_key: keep if _n == _N
save "stata/datasets/familycheck", replace

use "stata/datasets/sampletmp", clear
joinby entity_key using "stata/datasets/familycheck", unma(ma)
drop _merge
duplicates report entity_key year
save "stata/datasets/sampletmp", replace


***********************************************************************************************************
* Step 12: Merge SASB Sustainability E Scores to Worldscope Panel
***********************************************************************************************************

*** Merge SASB materiality scores
use "data/SASB Materiality/SASB-Materiality-E-Scores-3-13-18", clear
rename yq yq_asset4
rename ASSET4CompanyID asset4companyid
save "stata/datasets/sasbmat", replace

use "stata/datasets/sampletmp", clear
joinby asset4companyid yq_asset4 using "stata/datasets/sasbmat", unma(ma)
drop _merge
duplicates report entity_key year
save "stata/datasets/sampletmp", replace


***********************************************************************************************************
* Step 13: Merge and Create Traditional Firm Governance Measures
***********************************************************************************************************

*** Merge Governance Variables
joinby dscode yq using "Data/ASSET4/gov-measures-8-30-19", unma(ma)
drop _merge
joinby dscode yq using "Data/ASSET4/G-score-2013", unma(ma)
drop _merge
joinby dscode yq using "Data/ASSET4/G-score-2017", unma(ma)
drop _merge
joinby dscode yq using "Data/ASSET4/sustainability-gov-items-2021-07-17", unma(ma)
drop _merge
duplicates report yq asset4companyid

*** Generate Additional Governance Variables
gen per_indep_directors = pctindependent
replace per_indep_directors = perc_indep_board_strict if mi(per_indep_directors)
replace per_indep_directors = per_indep_board if mi(per_indep_directors)
egen med_per_indep_directors = median(per_indep_directors), by(ccode)
gen d_indep_board = (per_indep_directors>med_per_indep_directors) if !mi(per_indep_directors)
gen duality = ceochairdual
replace duality = CEO_chairman_dual if mi(duality)
gen not_duality = 1 - duality
gen gov3 = d_indep_board + not_duality + one_share_one_vote
gen anywomen = 0 if pctwomen == 0
replace anywomen = 1 if pctwomen>0 & pctwomen<.
gen has_woman_director =  anywomen
replace has_woman_director = has_female_dir if mi(has_woman_director)
replace gov_score_exVS_V2 = .54 if gov_score_exVS_V2 == .
gen indep50 = (per_indep_directors>0.5) if !mi(per_indep_directors)
replace boardsize = a4_boardmembers if mi(boardsize)
replace boardsize = totdirectors if mi(boardsize)
replace boardsize_stulz = (boardsize>5 & boardsize<16) if !mi(boardsize)
replace dir_ann_ind_elected = dir_ind_elected if mi(dir_ann_ind_elected) & !mi(dir_ind_elected)
gen gov_aesw = indep50 + boardsize_stulz + not_duality + dir_ann_ind_elected + indep_audit_comm + one_share_one_vote

*** Label Governance Variables
label var gov3 "Traditional Governance Index"
label var has_woman_director "Has Female Director"
label var gov_score_exVS_V2 "ASSET4 Governance Score (ex Sustainability)"
label var gov_aesw "AESW Index"


duplicates report entity_key year
save "stata/datasets/sampletmp-7-17-21", replace

********************************************************************************
* Step 14: Add alternative E and S Scores
********************************************************************************

use "stata/datasets/sampletmp-7-17-21", clear
joinby year entity_key using "stata/datasets/SP-ES-2020-11-27", unma(ma)
drop _merge
gen lnE_SPGlobal = ln(E_SPGlobal)
gen lnS_SPGlobal = ln(S_SPGlobal)
duplicates report entity_key year
save "stata/datasets/sampletmp-7-17-21", replace


********************************************************************************
* Step 15: Filter to Ensure Consistent Sample
********************************************************************************

use "stata/datasets/sampletmp-7-17-21", clear
keep if year>=2004

*** Require 10 Observations per Country
sort ccode entity_key
by ccode entity_key: gen countryfirms = 1 if _n == 1
by ccode: egen countryfirms_total = sum(countryfirms)
drop if countryfirms_total<10
drop if ccode == "BMU" | ccode == "ARE" | ccode == "KWT" | ccode == "SAU" | ccode =="QAT"

*** Ensure Non-missing Key Variables
drop if mi(ta)
drop if mi(e1_lead)
drop if mi(e2_lead)
drop if has_woman_director == .
drop if gov3 == .
drop if majorityelections == .
drop if gov_aesw == .


********************************************************************************
* Step 16: Generate and Winsorize all Variables
********************************************************************************

*** Country dummy Variables and Industry Codes
egen countrycode = group(ccode)
gen sic2 = floor(sic/100)

gen industry_name = ""
replace industry_name = "Agriculture, Forestry, Fishing" if sic2<10
replace industry_name = "Mining" if sic2>=10 & sic2<=14
replace industry_name = "Construction" if sic2>=15 & sic2<=17
replace industry_name = "Manufacturing" if sic2>=20 & sic2<=39
replace industry_name = "Transportation & Public Utilities" if sic2>=40 & sic2<=49
replace industry_name = "Wholesale Trade" if sic2>=50 & sic2<=51
replace industry_name = "Retail Trade" if sic2>=52 & sic2<=59
replace industry_name = "Finance, Insurance, Real Estate" if sic2>=60 & sic2<=67
replace industry_name = "Services" if sic2>=70 & sic2<=89
replace industry_name = "Public Administration" if sic2>=91 & sic2<=99

***Generate E Variables
gen lne1 = log(e1_lead)
gen lne2 = log(e2_lead)
gen lne3 = log(e3_lead)
gen lne4 = log(e4_lead)
gen lne5 = log(e5_lead)
gen lnematerial = log(1+e_material_lead)

*** Generate Firm controls
egen entity_id = group(entity_key)
gen lnta = ln(ta)
gen lnmc = ln(mc)
gen rnd_ta = r_and_d/ta
replace rnd_ta = 0 if mi(rnd_ta)
gen ppe = ppe_net/ta
gen q = (ta - she + mc) / ta
replace roa = roa/100
replace chs = chs/100
replace dtoa = dtoa/100
drop cash
gen cash = cashequivalents/ta

foreach x in lnta cash ppe dtoa roa io {
	drop if mi(`x')
}

*** Define Family and Blockholder Classifications
gen family_alg1 = 0
replace family_alg1 =1 if (uotypenew=="family")|(uotypenew=="nominee"&dualclass==1)| familygbiftop00==1 
sort entity_key family_alg1 year
by entity_key: gen lastfamilyyear = year[_N] if family_alg1[_N] == 1
gsort entity_key family_alg1 -year
by entity_key: gen firstfamilyyear = year[_N] if family_alg1[_N] == 1

gen lastfamilyvote = a4_pctvotebiggestowner if lastfamilyyear == year
gen firstfamilyvote = a4_pctvotebiggestowner if firstfamilyyear == year
sort entity_key firstfamilyvote
by entity_key: replace firstfamilyvote = firstfamilyvote[1]
sort entity_key lastfamilyvote
by entity_key: replace lastfamilyvote = lastfamilyvote[1]

gen family_alg_sum = 0 
replace family_alg_sum = 1 if family_alg1 == 1

sort entity_key family_alg_sum year
by entity_key: gen lastfamilyyear2 = year[_N] if family_alg_sum[_N] == 1
gsort entity_key family_alg_sum -year
by entity_key: gen firstfamilyyear2 = year[_N] if family_alg_sum[_N] == 1

gen Family = 0
replace Family = 1 if year>=firstfamilyyear2 & year<=lastfamilyyear2
gen InclusiveWide = 0  // Original widely-held coding
replace InclusiveWide = 1 if a4_pctvotebiggestowner<.5 & Family == 0
replace InclusiveWide = 1 if a4_pctvotebiggestowner== . & Family == 0
replace InclusiveWide = 1 if a4_pctvotebiggestowner>=.5 & Family == 0 & uotypenew == "widely held"
sort entity_key InclusiveWide
by entity_key: gen everwide = InclusiveWide[_N]
replace InclusiveWide = 1 if everwide == 1 & Family == 0

*** Generate Governance and Board Variables
gen majorityindependent = 0
replace majorityindependent = 1 if pctindependent>=.5 & pctindependent <.

*** Winsorize Variables
winsor chs, gen(closelyheldshares) p(.01)    
winsor dtoa, gen(Leverage) p(.01)
winsor roa, gen(Profitability) p(.01)
winsor q, gen(tobinsq) p(.01)
winsor ppe, gen(Tangibility) p(.01)
winsor lnta, gen(logassets) p(.01)
winsor rnd_ta, gen(RandD) p(.01)
winsor io, gen(IO) p(.01)
winsor lnmc, gen(logmktcap) p(.01)
winsor cash, gen(cashtoassets) p(.01)

*** Label Variables
label var e1_lead "Overall E"
label var e2_lead "ASSET4 E"
label var e3_lead "ASSET4 ENER"
label var e4_lead "ASSET4 ENPI"
label var e5_lead "ASSET4 ENRR"

label var lne1 "Log Overall E"
label var lne2 "Log ASSET4 E"
label var lne3 "Log ASSET4 ENER"
label var lne4 "Log ASSET4 ENPI"
label var lne5 "Log ASSET4 ENRR"

label var Family "Family"
label var InclusiveWide "Other"
label var logassets "Log (Total Assets)"
label var cashtoassets "Cash"
label var Tangibility "Tangibility"
label var Leverage "Leverage"
label var Profitability "Profitability"
label var io "IO"
label var ADR "Cross-list"
label var majorityelections "Majority Elections"
label var pctindependent "Board Independence"
label var msci_entrenched "MSCI Entrenched"
label var ceochairdual "CEO-Chair Duality"
label var avgceotenure "CEO Tenure"
label var LeadExecPayCSR "Executive Pay is Tied to Sustainability"
label var LeadCSRCommittee "Sustainability Committee"
label var LeadStakeholderEngage "Engage Stakeholder" 
label var LeadSustainabilityReport "Sustainability Report"

egen yearsic = group(year sic2)
egen yearcountry = group(year countrycode)
bysort yearsic: gen tot_yearsic = _N
bysort yearcountry: gen tot_yearcountry = _N
drop if tot_yearsic == 1
drop if tot_yearcountry == 1
drop tot_yearsic tot_yearcountry
*** Save
duplicates report entity_key year
compress
save "stata/datasets/sample-7-17-21", replace



