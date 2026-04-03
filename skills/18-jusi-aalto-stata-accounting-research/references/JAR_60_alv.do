cd "*"
*replace * with your filepath

/* Outline
*this file creates the patent-related variables: tot_claim_ct_mean_log forcites_s_mean_log forcites_s_sd numpat_log breadth_subclass orig_mean gen_mean citesmade_s_mean_log
1) read in and prep Kogan and PatentsView data
2) merge Kogan and tech class data from PatentsView
3) bring in claims data from BigQuery
4) Create variables
5) bring in PatentsView data on citations made (backward citations)
*/

*********************1) read in and prep kogan and PatentsView data****************************

*import Kogan patent data obtained from https://github.com/KPSS2017/Technological-Innovation-Resource-Allocation-and-Growth-Extended-Data
*https://kelley.iu.edu/nstoffma/
*this version has citations through 2019
import delimited "*\KPSS_2019_public.csv", clear

gen issue_date2 = date(issue_date,"MDY")
format issue_date2 %d
drop issue_date
rename issue_date2 issue_date

gen filing_date2 = date(filing_date,"MDY")
format filing_date2 %d
drop filing_date
rename filing_date2 filing_date

rename patent_num patnum

gen fyear_k=year(filing_date)

save "*\kpss_patents.dta", replace


*bring in PatentsView data
*20200827 version downloaded in November 2020 and January 2021. 
*Current versions of the dataset are available at the following web address: https://patentsview.org/download/data-download-tables
*STATA dataset names correspond to PatentsView download filenames

*import PatentsView files
import delimited patent.tsv, varnames(1) bindquote(strict) encoding(utf8) clear
save patent.dta, replace

import delimited cpc_current.tsv, varnames(1) bindquote(strict) encoding(utf8) clear
tostring patent_id, replace
save cpc_current.dta, replace

import delimited application.tsv, varnames(1) bindquote(strict) encoding(utf8) clear
save application.dta, replace

*combine patent and tech class data
use "*\patent.dta", clear
gen patent_id=id
*merge in CPC class
merge 1:m patent_id using "*\cpc_current.dta"
drop if _m==2
drop _m
*retain the first-listed CPC class for each patent (sequence==0)
*takes a while to run
sort patent_id sequence
duplicates drop patent_id, force
drop uuid section_id subsection_id category sequence
rename group_id cpc_group
rename subgroup_id cpc_subgroup
save "*\patent2.dta", replace


*********************2) merge Kogan and tech class data from PatentsView****************************
use "*\kpss_patents.dta", clear
tostring(patnum), gen(patent_id)
*merge in tech class
merge 1:m patent_id using "*\patent2.dta", keepusing(cpc_group cpc_subgroup)
drop if _m==2
drop _m
save "*\kpss_patents2.dta", replace


*********************3) bring in BQ data with claims data****************************
*direct download from BigQuery
*https://console.cloud.google.com/marketplace/partners/patents-public-data?project=nberpatents&folder&organizationId
*see `patents-public-data.uspto_oce_claims.patent_document_stats_2014`
*save as patent_claims.dta dataset

use "*\kpss_patents2.dta", clear
gen pat_no=patent_id
rename fyear_k fyear
merge m:1 pat_no using "*\patent_claims.dta"
drop if _m==2
drop _m
gen tot_claim_ct=pat_clm_ct+pat_dep_clm_ct



*********************4) Create variables ****************************
*bring in forward citations from PatentsView - updated through August 2020
merge m:1 patent_id using "*\citations.dta", keepusing(forcites)
drop if _m==2
drop _m
replace forcites =0 if forcites==.


*scale forward citations by cohort
*use the cohort of citations granted to public firms in the same technology class and grant year
*kpss_patents2.dta dataset only includes patents granted to public firms, so can summarize within a grant_year and cpc_group

gen grant_year=year(issue_date)
bysort grant_year cpc_group: egen forcites_scalar=sum(forcites)

*scale forward citations
gen forcites_s= forcites/forcites_scalar

*replace with missing if tech class is missing, otherwise it's filling in average from all those without a tech class
*very small number of observations where this is the case
replace forcites_s=. if cpc_group==""


*aggregate to the firm-year level
foreach var of varlist tot_claim_ct forcites_s{
bysort permno fyear: egen `var'_mean = mean(`var')
replace `var'_mean=0 if `var'_mean==.
}

*take log transformation
foreach var of varlist *_mean{
gen `var'_log=ln(1+`var')
}

*standard deviation of forward citations
bysort permno fyear: egen forcites_s_sd = sd(forcites_s)
replace forcites_s_sd=0 if forcites_s_sd==.


*number of patents filed per year
bysort permno fyear: egen numpat = count(patent_id)
gen numpat_log=ln(1+numpat)

keep permno fyear forcites_s_sd forcites_s_mean_log tot_claim_ct_mean_log numpat_log

*multiply forcites by 100
replace forcites_s_mean_log=forcites_s_mean_log*100

*reduce dataset down to firm-year level
duplicates drop
duplicates report permno fyear
save "*\patentvars1_kpss.dta", replace


**Create breadth measure
*based on the subclass of the patents applied for in a year for a given firm
use "*\kpss_patents2.dta", clear
rename fyear_k fyear
bysort permno fyear: egen npatents = count(patent_id)
bysort permno fyear cpc_subgroup: egen tot_pat_subclass = count(patent_id)
keep permno fyear cpc_subgroup tot_pat_subclass npatents
duplicates drop permno fyear cpc_subgroup, force
bysort permno fyear: egen temp=sum((tot_pat_subclass/npatents)^2)
gen breadth_subclass=1-temp
keep permno fyear breadth_subclass
duplicates drop permno fyear, force
save breadth.dta, replace

*merge breadth measure back into dataset
use "*\patentvars1_kpss.dta", clear
merge m:1 permno fyear using breadth.dta, keepusing(breadth_subclass)
drop _merge
save patentvars1_kpss, replace


*********************5) bring in PatentsView data on citations made****************************
*dataset at the patent level
use "*\kpss_patents2.dta", clear
merge m:1 patent_id using "*\citations.dta"
drop if _m==2
drop _m

rename fyear_k fyear

*aggregate to the firm-year level
bysort permno fyear: egen numpat = count(patent_id)
gen citesmade_s=citesmade/numpat
drop numpat

foreach var in orig citesmade_s gen{
bysort permno fyear: egen `var'_mean=mean(`var')
}

gen citesmade_s_mean_log=ln(1+citesmade_s_mean)

keep permno fyear orig_mean gen_mean citesmade_s_mean_log
duplicates drop
duplicates report permno fyear

save "*\citations_made_firm.dta", replace

use patentvars1_kpss, clear
merge 1:1 permno fyear using "*\citations_made_firm.dta"
drop _m
save patentvars2_kpss, replace
cd "*"
set matsize 11000


*******Format datasets for use in analysis and merge in patent variables****************************************************************************************************************************
use "*\soxdata_temp.dta", clear
destring gvkey, replace
xtset gvkey fyear

merge m:1 permno fyear using "*\patentvars2_kpss.dta"
drop if _m==2
drop _m

foreach var in tot_claim_ct_mean_log forcites_s_mean_log forcites_s_sd numpat_log breadth_subclass orig_mean gen_mean citesmade_s_mean_log{
replace `var'=0 if `var'==.
replace `var'=0 if permno==.
}

winsor2 tot_claim_ct_mean_log forcites_s_mean_log forcites_s_sd numpat_log breadth_subclass orig_mean gen_mean citesmade_s_mean_log, by(fyear) replace 

save "*\soxdata.dta", replace


*******pseudo event dataset
use "*\pseudosoxdata_temp.dta", clear
destring gvkey, replace
xtset gvkey fyear

merge m:1 permno fyear using "*\patentvars2_kpss.dta"
drop if _m==2
drop _m

foreach var in tot_claim_ct_mean_log forcites_s_mean_log forcites_s_sd numpat_log breadth_subclass orig_mean gen_mean citesmade_s_mean_log{
replace `var'=0 if `var'==.
replace `var'=0 if permno==.
}

winsor2 tot_claim_ct_mean_log forcites_s_mean_log forcites_s_sd numpat_log breadth_subclass orig_mean gen_mean citesmade_s_mean_log, by(fyear) replace 

save "*\pseudosoxdata.dta", replace




*******TABLE 1 SAMPLE SELECTION****************************************************************************************************************************
use soxdata, clear

tab af intro


***********************************************************************************************************************************************************
*descriptive stats - Table 2 Panel A - intro to mature firms
use soxdata, clear
keep if af==1

global dvs	"rd numpat_log forcites_s_mean_log tot_claim_ct_mean_log restate ddf_resid fsd signed_accruals"
global controls "size hp_index litrisk instit_own roa"
global rdcontrols "rd"

eststo clear
bysort intro post: eststo: quietly estpost summarize $dvs $controls, d 
esttab, cells("mean") label nodepvar
*ttest pre vs. post for both samples
eststo: quietly estpost ttest $dvs $controls if intro==1, by(post) unequal 
esttab ., wide p label star(* .10 ** .05 *** .01)
eststo: quietly estpost ttest $dvs $controls if intro==0, by(post) unequal 
esttab ., wide p label star(* .10 ** .05 *** .01)
*difference in difference univariate test
reg rd postsox_intro post intro, robust
outreg2 using DID_descr, replace word adjr2 tstat label dec(2)
foreach var of varlist $dvs $controls{
reg `var' postsox_intro post intro, robust
outreg2 using DID_descr, append word adjr2 tstat label dec(2)
}

*descriptive stats - Table 2 Panel B - intro AF to intro NAF firms

use soxdata, clear
keep if intro==1
gen postsox_af=post*af

eststo clear
bysort af post: eststo: quietly estpost summarize $dvs $controls, d 
esttab, cells("mean") label nodepvar
*ttest pre vs. post for both samples
eststo: quietly estpost ttest $dvs $controls if af==1, by(post) unequal 
esttab ., wide p label star(* .10 ** .05 *** .01)
eststo: quietly estpost ttest $dvs $controls if af==0, by(post) unequal 
esttab ., wide p label star(* .10 ** .05 *** .01)
*difference in difference univariate test
reg rd postsox_af post af, robust
outreg2 using DID_descr, replace word adjr2 tstat label dec(2)
foreach var of varlist $dvs $controls{
reg `var' postsox_af post af, robust
outreg2 using DID_descr, append word adjr2 tstat label dec(2)
}



use soxdata, clear
global dvs	"rd numpat_log forcites_s_mean_log tot_claim_ct_mean_log restate ddf_resid fsd signed_accruals"
global controls "size hp_index litrisk instit_own roa"

*Panel C
univar $dvs $controls if af==1 & intro==0, dec(3)
*Panel D
univar $dvs $controls if af==0 & intro==0, dec(3)
*Panel E
univar $dvs $controls if af==1 & intro==1, dec(3)
*Panel F
univar $dvs $controls if af==0 & intro==1, dec(3)


***********************************************************************************************************************************************************
*Table 3 - Innovation and Poor Financial Reporting Quality, Young vs. More Mature Life-Cycle Firms

global controls "size hp_index litrisk instit_own roa"
global rdcontrols "rd"

use soxdata, clear
keep if af==1

xtreg rd postsox_intro $controls i.fyear, fe cluster(gvkey)
outreg2 using Table3.xls, replace adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg numpat_log postsox_intro $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table3.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg forcites_s_mean_log postsox_intro $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table3.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg tot_claim_ct_mean_log postsox_intro $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table3.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg restate postsox_intro $controls i.fyear, fe cluster(gvkey)
outreg2 using Table3.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg ddf_resid postsox_intro $controls i.fyear, fe cluster(gvkey)
outreg2 using Table3.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg fsd postsox_intro $controls i.fyear, fe cluster(gvkey)
outreg2 using Table3.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg signed_accruals postsox_intro $controls i.fyear, fe cluster(gvkey)
outreg2 using Table3.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)



***********************************************************************************************************************************************************
*Table 4 - Innovation and Poor Financial Reporting Quality, Accelerated Filer Young Life-Cycle vs. Non-accelerated Filer Young Life-Cycle Firms

use soxdata, clear
keep if intro==1

xtreg rd af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table4.xls, replace adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg numpat_log af_postsox $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table4.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg forcites_s_mean_log af_postsox $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table4.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg tot_claim_ct_mean_log af_postsox $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table4.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg restate af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table4.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg ddf_resid af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table4.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg fsd af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table4.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg signed_accruals af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table4.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)


**************************************************************************************************************************************************************
*Table 5 - Innovation and Poor Financial Reporting Quality, Mature Non-Accelerated Filer vs. Mature Accelerated Filer vs. Young Life-Cycle Accelerated Filer vs. Young Life-Cycle Non-Accelerated Filer 
*Panel A
use soxdata, clear

xtreg rd intro_af_post intro_af intro_post af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, replace adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg numpat_log intro_af_post intro_af intro_post af_postsox $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append word adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg forcites_s_mean_log intro_af_post intro_af intro_post af_postsox $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append word adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg tot_claim_ct_mean_log intro_af_post intro_af intro_post af_postsox $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append word adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg restate intro_af_post intro_af intro_post af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg ddf_resid intro_af_post intro_af intro_post af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg fsd intro_af_post intro_af intro_post af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg signed_accruals intro_af_post intro_af intro_post af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)


***Table 5 Panel B 
use soxdata, clear

global controls "size size_post hp_index hp_index_post litrisk litrisk_post instit_own instit_own_post roa roa_post"
global rdcontrols "rd rd_post"

xtreg rd intro_af_post intro_af intro_post af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, replace adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg numpat_log intro_af_post intro_af intro_post af_postsox $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append word adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg forcites_s_mean_log intro_af_post intro_af intro_post af_postsox $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append word adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg tot_claim_ct_mean_log intro_af_post intro_af intro_post af_postsox $rdcontrols $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append word adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg restate intro_af_post intro_af intro_post af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg ddf_resid intro_af_post intro_af intro_post af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg fsd intro_af_post intro_af intro_post af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg signed_accruals intro_af_post intro_af intro_post af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table5.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)




***********************************************************************************************************************************************************
*Table 6 - Event Study for Political Events Increasing the Likelihood of SOX Passage
use eventus, clear
drop if shakeout ==1 | decline==1
keep if fic =="USA" & curcd=="USD"

bootstrap, reps(1000) seed(1): reg ehwcarmar_sox intro laglogmv lagbm lagleverage lagfcf lagroa lagmturnover lagstdret, robust
outreg2 using eventus, replace word adjr2 tstat label addtext(Robust SE, YES, Bootstrap SE, YES) dec(3)
bootstrap, reps(1000) seed(1): reg carmar_sign intro laglogmv lagbm lagleverage lagfcf lagroa lagmturnover lagstdret, robust
outreg2 using eventus, append word adjr2 tstat label addtext(Robust SE, YES, Bootstrap SE, YES) dec(3)

***********************************************************************************************************************************************************


***********************************************************************************************************************************************************
*Table 7 - Future Market Performance
use soxdata, clear
keep if af==1
xtreg dgtw_bhar postsox_intro $controls i.fyear, fe cluster(gvkey)
outreg2 using Table8.xls, replace adjr2 tstat label addtext(Controls, YES, Year FE, YES, Firm FE, YES) dec(3)

use soxdata, clear
keep if intro==1
xtreg dgtw_bhar af_postsox $controls i.fyear, fe cluster(gvkey)
outreg2 using Table8.xls, append adjr2 tstat label addtext(Controls, YES, Year FE, YES, Firm FE, YES) dec(3)


***********************************************************************************************************************************************************
*Table 8 - Innovation Strategy


*Panel A
use soxdata, clear
keep if af==1

global controls "size hp_index litrisk instit_own roa"
global rdcontrols "rd"

xtreg orig_mean postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table9a.xls, replace adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg gen_mean postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table9a.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg forcites_s_sd postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table9a.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg breadth_subclass postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table9a.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg citesmade_s_mean_log postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table9a.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)



*Panel B
use soxdata, clear
keep if intro==1

global controls "size hp_index litrisk instit_own roa"
global rdcontrols "rd"

xtreg orig_mean af_postsox $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table9b.xls, replace adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg gen_mean af_postsox $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table9b.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg forcites_s_sd af_postsox $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table9b.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg breadth_subclass af_postsox $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table9b.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg citesmade_s_mean_log af_postsox $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table9b.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)




***********************************************************************************************************************************************************
********Table 9 extra years - build dataset

global dvs	"rd numpat_log forcites_s_mean_log tot_claim_ct_mean_log restate ddf_resid fsd signed_accruals"
global controls "size hp_index litrisk instit_own roa"
global rdcontrols "rd"

*create list of gvkeys in sample
use soxdata_temp, clear
keep gvkey
duplicates drop
gen sample=1
save sample_gvkeys, replace
*keep only extra years for firms in our sample
use soxdata_xtrayrs, clear
merge m:1 gvkey using sample_gvkeys
drop _m 
*t+5 means we keep through 2010 (2005 is latest implementation, 2006-2010 is t+5)
keep if sample==1 & fyear >=2007 & fyear <=2010
drop sample
duplicates drop
destring gvkey, gen(gvkey2)
save xtrayrs_sample_t5, replace


*build the expanded dataset
use soxdata_temp, clear
destring gvkey, gen(gvkey2)
xtset gvkey2 fyear
*append extra years for sample firms
append using xtrayrs_sample_t5
merge m:1 permno fyear using "*\patentvars2_kpss.dta"
drop if _m==2
drop _m


foreach var in tot_claim_ct_mean_log forcites_s_mean_log forcites_s_sd numpat_log breadth_subclass orig_mean gen_mean citesmade_s_mean_log{
replace `var'=0 if `var'==.
replace `var'=0 if permno==.
}

winsor2 tot_claim_ct_mean_log forcites_s_mean_log forcites_s_sd numpat_log breadth_subclass orig_mean gen_mean citesmade_s_mean_log, by(fyear) replace 


keep $dvs $controls $rdcontrols gvkey gvkey2 fyear intro af post intro_af_post intro_af intro_post af_postsox postsox_intro implem
duplicates drop
duplicates report gvkey fyear
duplicates tag gvkey fyear, gen(dup)
sort gvkey fyear af
duplicates drop gvkey fyear, force
drop dup

*mipolate af status
bysort gvkey2: mipolate af gvkey2, generate(af2) groupwise
replace af=af2 if af==.
drop af2

*create firm-level variable to identify year of implementation so we keep the right number of post years
gen implem_year=.
replace implem_year=fyear if implem==1
*mipolate implementation year
bysort gvkey2: mipolate implem_year gvkey2, generate(implem_year2) groupwise
replace implem_year=implem_year2 if implem_year==.
drop implem_year2

******************************************************
*drop the extra year if implemented in 2004 - created duplicate entry when we merged
*need to change for each window
drop if implem_year==2004 & fyear==2010
******************************************************

*fill in post interactions
replace af_postsox=af*post if af_postsox==.
replace intro_af_post=intro*af*post if intro_af_post==.
replace intro_af=intro*af if intro_af==.

*create tminus/tplus variables
sort gvkey fyear
by gvkey: generate count=_n

gen tminus3=0
replace tminus3=1 if count==1
gen tminus2=0
replace tminus2=1 if count==2
gen tminus1=0
replace tminus1=1 if count==3
gen tzero=0
replace tzero=1 if count==4
gen tplus1=0
replace tplus1=1 if count==5
gen tplus2=0
replace tplus2=1 if count==6
gen tplus3=0
replace tplus3=1 if count==7
gen tplus4=0
replace tplus4=1 if count==8
gen tplus5=0
replace tplus5=1 if count==9


gen zero=0
gen intro_tminus3=intro*tminus3
gen intro_tminus2=intro*tminus2
gen intro_tminus1=intro*tminus1
gen intro_tzero=intro*tzero
gen intro_tplus1=intro*tplus1
gen intro_tplus2=intro*tplus2
gen intro_tplus3=intro*tplus3
gen intro_tplus4=intro*tplus4
gen intro_tplus5=intro*tplus5

gen af_tminus3=af*tminus3
gen af_tminus2=af*tminus2
gen af_tminus1=af*tminus1
gen af_tzero=af*tzero
gen af_tplus1=af*tplus1
gen af_tplus2=af*tplus2
gen af_tplus3=af*tplus3
gen af_tplus4=af*tplus4
gen af_tplus5=af*tplus5

save xtrayrs_sample_forregs_t5, replace

***********************************************************************************************************************************************************
*********Table 9 - Time Trend Analysis

global controls "size hp_index litrisk instit_own roa"
global rdcontrols "rd"

*Panel A
use xtrayrs_sample_forregs_t5, clear
keep if af==1

global timevars "intro_tminus2 intro_tminus1 intro_tzero intro_tplus1 intro_tplus2 intro_tplus3 intro_tplus4 intro_tplus5"


xtreg rd zero $timevars $controls i.fyear, fe cluster(gvkey)
outreg2 using Table10a.xls, replace adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)
xtreg numpat_log zero $timevars  $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table10a.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)
xtreg forcites_s_mean_log zero $timevars  $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table10a.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)
xtreg tot_claim_ct_mean_log zero $timevars $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table10a.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)


*Panel B
use xtrayrs_sample_forregs_t5, clear
keep if intro==1

global timevars "af_tminus2 af_tminus1 af_tzero af_tplus1 af_tplus2 af_tplus3 af_tplus4 af_tplus5"

xtreg rd zero $timevars $controls i.fyear, fe cluster(gvkey)
outreg2 using Table10b.xls, replace adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)
xtreg numpat_log zero $timevars $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table10b.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)
xtreg forcites_s_mean_log zero $timevars $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table10b.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)
xtreg tot_claim_ct_mean_log zero $timevars $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table10b.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

***********************************************************************************************************************************************************
*Table 10 - Falsification Tests
***Panel A
use soxdata, clear
keep if af==0

global controls "size hp_index litrisk instit_own roa"
global rdcontrols "rd"

xtreg rd postsox_intro $controls i.fyear, fe cluster(gvkey)
outreg2 using Table11a.xls, replace adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg numpat_log postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table11a.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg forcites_s_mean_log postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table11a.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg tot_claim_ct_mean_log postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table11a.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)


***Panel B - 1993-1999 sample period
use pseudosoxdata, clear
xtset gvkey fyear
*don't need to keep if af==1 since only af vars were saved in dataset
global controls "size hp_index litrisk instit_own roa"
global rdcontrols "rd"

xtreg rd postsox_intro $controls i.fyear, fe cluster(gvkey)
outreg2 using Table11b.xls, replace adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg numpat_log postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table11b.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg forcites_s_mean_log postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table11b.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

xtreg tot_claim_ct_mean_log postsox_intro $controls $rdcontrols i.fyear, fe cluster(gvkey)
outreg2 using Table11b.xls, append adjr2 tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)










***********************************************************************************************************************************************************
***********************************************************************************************************************************************************
***********************************************************************************************************************************************************
/*
Per the editor/referee's suggestion, we moved the entropy-balanced results to an untabulated footnote. The code below reproduces just that footnote.
Here is the related discussion on entropy balancing (formerly Table 6):

Entropy Balanced Results 
A concern with comparing young to mature life-cycle firms or with comparing accelerated to non-accelerated firms is that the treatment and control firms vary in terms of firm characteristics that impact 
innovation and FRQ (see Table 2), which may limit our ability to attribute any documented difference to SOX. To reduce this concern, we use entropy balancing to create two covariate-balanced control samples 
(one with accelerated filer, mature control firms and the other with non-accelerated filer, young life-cycle firms).*  After entropy balancing, the control samples are indistinguishable from the treatment firms 
with respect to the mean of the control variables used in our models over the entire sample period.**  We present the results from this analysis in Table 6. The results confirm our full sample findings that 
innovation declines for young life-cycle firms required to comply with SOX relative to similar mature life-cycle firms (Panel A) and relative to similar young life-cycle firms exempt from compliance with SOX (Panel B). 
We find no evidence to suggest that these innovation declines were offset by improvements in FRQ. 

*Entropy balancing is a statistical method that balances covariates between treatment and control firms when the treatment is binary (life-cycle stage in our setting). See Hainmueller (2012). This is accomplished by 
adding regression weights to a regression analysis. We implement entropy balancing using the STATA command “ebalance” to achieve covariate balance. Hainmueller and Xu (2013) provide a useful discussion and examples 
for implementing “ebalance”.
**By construction, our sample of young life-cycle, accelerated filers and young life-cycle, non-accelerated filers compares firms of disparate size. As such, we do not include size in our entropy balancing procedure in 
Table 6 panel B, due to lack of common support. We do include size as a control in Table 6 panel A.

*/

*Entropy Balanced Sample   
*Panel A

global controls "size hp_index litrisk instit_own roa"
global rdcontrols "rd"

use soxdata, clear
keep if af==1
ebalance intro $controls, target(1)
reghdfe rd postsox_intro $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6a.xls, replace addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

use soxdata, clear
keep if af==1
ebalance intro $rdcontrols $controls, target(1)

reghdfe numpat_log postsox_intro $rdcontrols $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6a.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe forcites_s_mean_log postsox_intro $rdcontrols $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6a.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe tot_claim_ct_mean_log postsox_intro $rdcontrols $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6a.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

use soxdata, clear
keep if af==1

ebalance intro $controls, target(1)

reghdfe restate postsox_intro $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6a.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe ddf_resid postsox_intro $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6a.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe fsd postsox_intro $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6a.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe signed_accruals postsox_intro $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6a.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)



*Panel B

use soxdata, clear
keep if intro==1
ebalance af hp_index litrisk instit_own roa, target(1)
reghdfe rd af_postsox $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6b.xls, replace addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

use soxdata, clear
keep if intro==1

ebalance af $rdcontrols hp_index litrisk instit_own roa, target(1)
reghdfe numpat_log af_postsox $rdcontrols $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6b.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe forcites_s_mean_log af_postsox $rdcontrols $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6b.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe tot_claim_ct_mean_log af_postsox $rdcontrols $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6b.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)


use soxdata, clear
keep if intro==1


ebalance af hp_index litrisk instit_own roa, target(1)

reghdfe restate af_postsox $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6b.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe ddf_resid af_postsox $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6b.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe fsd af_postsox $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6b.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)

reghdfe signed_accruals af_postsox $controls [weight=_webal], absorb(i.fyear gvkey) vce(cluster gvkey) keepsingletons
outreg2 using table6b.xls, append addstat(R-squared within,e(r2_within)) tstat label addtext(Year FE, YES, Firm FE, YES) dec(3)


