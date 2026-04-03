
use "$inputs\incentive_lab\eca\eca_person.dta", clear 

bysort iss_company_id fiscal_year: egen ceotot=total(ceo_yn)

rename fiscal_year year

merge m:1 iss_company_id year using "$temp\eca_metrics_environment1.dta", keepusing(csr1) keep(match master) nogen

keep if csr1!=.

bysort iss_company_id year: egen ceotot=total(ceo_yn)

replace ceo_yn=1 if ceotot==0 & disclosed_title=="CEO of GN Hearing"

g ceo=.
replace ceo=ceo_yn if ceotot<2
replace ceo=1 if ceotot>1 & iss_title=="CEO Managing Director" & ceo_yn==1
replace ceo=1 if ceotot>1 & iss_title=="CEO" & ceo_yn==1
replace ceo=1 if ceotot>1 & iss_title=="CEO President" & ceo_yn==1
replace ceo=1 if ceotot>1 & iss_title=="Group CEO" & ceo_yn==1
replace ceo=0 if ceotot>1 & iss_title!="" & ceo==.
replace ceo=ceo_yn if ceotot>1 & iss_title==""

bysort iss_company_id year: egen ceotot2=total(ceo)

drop if disclosed_total_comp==.
drop if disclosed_total_comp<0

bysort iss_company_id year: egen maxcomp=max(disclosed_total_comp)

g ceo_comp=0
replace ceo_comp=1 if maxcomp==disclosed_total_comp

g ceo2=.
replace ceo2=ceo if ceotot2<2
replace ceo2=1 if ceotot2>1 & ceo_comp==1 & ceo==1
replace ceo2=0 if ceotot2>1 & ceo2==.

bysort iss_company_id year: egen ceotot3=total(ceo2)

replace ceo2=1 if ceotot3==0 & ceo_comp==1

replace ceo2=0 if ceotot3==2 & ceo2==1 & iss_title=="Chief Financial Officer"
replace ceo2=0 if ceotot3==2 & ceo2==1 & iss_title=="Executive Director"
replace ceo2=0 if ceotot3==2 & ceo2==1 & iss_title=="Marketing"

replace ceo2=0 if iss_title=="" & ceotot3==2 & ceo2==1 & strpos(lower(disclosed_title), "former")

keep if ceo2==1
duplicates drop iss_company_id year, force

rename comp_currency curcd
replace curcd="USD" if curcd=="usd"
merge m:1 curcd year using "$inputs\controls\exchange_rate4.dta", keepusing(exchange_rate) keep(match master) nogen

g lceo_comp=disclosed_total_comp/exchange_rate

g year1=year+1
drop year
rename year1 year
save "$temp\lceo_comp.dta", replace









/*********************************************

Constructs control variables for 2003-2020

Input files:

inputs\trucost_isins_all.dta
inputs\controls\panel_merge_fs.dta
inputs\controls\exchange_rate_2005.dta
temp\datastream_controls_dollars.dta
temp\datastream_curcd.dta
temp\cg_2003_2018_tomerge.dta
temp\cg_2003_2018_tomerge_curcd.dta
temp\cna_2003_2018_tomerge.dta
temp\cna_2003_2018_tomerge_curcd.dta

temp files:

Output files:

temp\controls_extended.dta
*********************************************/

/*Construction of control variables for 2003-2020
in a perfecly balance firm-year panel to ensure construction of proper lags of control variables*/
use "$temp\isin_list_eca.dta", clear 
expand 22, generate(number)
bysort isin: gen count=_n
generate year=count+1998
drop count number 

/*Merging in controls from Datastream*/
merge 1:1 isin year using "$temp\datastream_controls_dollars_eca.dta", keepusing(mv ni ppe st lt eq sales capex cogs assets sic dividend price ret) keep(match master) nogen 

/*Total assets in US dollars*/

g total_size=assets/1000 
g size=ln(total_size)

/*Dividends scaled by Net Income*/
g dividends=dividend/ni
replace dividends=0 if dividends==.

/*Leverage variable construction*/
g lev=(st+lt)/assets 

/*Accounting performance variable*/
g roa=ni/assets 

/*Capex variable construction*/
g capx=capex/assets

/*PPE variable construction*/
g ppe1=ppe/assets 
drop ppe 
rename ppe1 ppe

/*Construction of book-to-market variable*/
g btm=eq/(1000*mv) 

winsor2 btm, cut(2 98)
g log_bm=ln(btm_w)

egen firm_id=group(isin)
tsset firm_id year

/*Construction of Return variable*/
g return=.
replace return=(mv-l.mv)/l.mv if return==. & mv!=.
replace return=(price-l.price)/l.price if return==. & price!=.

g lsize=l.size
g lroa=l.roa
g llev=l.lev
g lppe=l.ppe
g llog_bm=l.log_bm
g ldividends=l.dividends
g lcapx=l.capx
g lreturn=l.return
g lmv=l.mv

save "$temp\controls_eca.dta", replace

/*********************************************


*********************************************/
/*Retriving Datastream variables from Excel*/
clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("PriceVol") firstrow cellrange(A1:W13590) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long vol, i(isin) j(year)

g cort=substr(vol, 1,2)
drop if cort=="In"
replace vol="." if (vol=="NA"|vol==""|cort=="$$")
destring vol, replace

rename vol lvol
g year1=year+1
drop year
rename year1 year

save "$temp\vol_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("ind board") firstrow cellrange(A1:W13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long ind, i(isin) j(year)

g cort=substr(ind, 1,2)
drop if cort=="In"
replace ind="." if (ind=="NA"|ind==""|cort=="$$")
destring ind, replace

g year1=year+1
drop year
rename year1 year

save "$temp\independent_directors_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("diversity") firstrow cellrange(A1:W13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long divers, i(isin) j(year)

g cort=substr(divers, 1,2)
drop if cort=="In"
replace divers="." if (divers=="NA"|divers==""|cort=="$$")
destring divers, replace
g year1=year+1
drop year
rename year1 year
save "$temp\diversity_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("inside") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long ins, i(isin) j(year)

g cort=substr(ins, 1,2)
drop if cort=="In"
replace ins="." if (ins=="NA"|ins==""|cort=="$$")
destring ins, replace

rename ins linsideownership
g year1=year+1
drop year
rename year1 year

save "$temp\inside_datastream_eca.dta", replace


/*Following control variable will be managed/lagged jointly in Prepare Data - Controls ECA.do*/
clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("Dividends") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long di, i(isin) j(year)
rename di dividend
save "$temp\dividend_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("NI") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long ni, i(isin) j(year)
save "$temp\ni_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("CapEx") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long capex, i(isin) j(year)
save "$temp\capex_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("PPE") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long ppe, i(isin) j(year)
save "$temp\ppe_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("COGS") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long cogs, i(isin) j(year)
save "$temp\cogs_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("assets") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long assets, i(isin) j(year)
save "$temp\assets_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("sales") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long sales, i(isin) j(year)
save "$temp\sales_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("MV") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long mv, i(isin) j(year)
save "$temp\mv_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("lt") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long lt, i(isin) j(year)
save "$temp\lt_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("st") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long st, i(isin) j(year)
save "$temp\st_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("eq") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long eq, i(isin) j(year)
save "$temp\eq_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("sic") firstrow cellrange(A1:C13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
replace sic="." if (sic=="NA"|sic=="$$")
save "$temp\sic_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("ret") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long ret, i(isin) j(year)
save "$temp\ret_datastream_eca.dta", replace

clear all
import excel "$inputs\controls\new_controls_datastream_eca.xlsx", sheet("price") firstrow cellrange(A1:X13642) allstring
drop if isin=="0"
drop if isin==""
drop if isin=="null"
reshape long price, i(isin) j(year)
save "$temp\price_datastream_eca.dta", replace

use "$temp\mv_datastream_eca.dta", clear
merge 1:1 isin year using "$temp\ni_datastream_eca.dta", keepusing(ni) keep(match master) nogen 
merge 1:1 isin year using "$temp\ppe_datastream_eca.dta", keepusing(ppe) keep(match master) nogen
merge 1:1 isin year using "$temp\st_datastream_eca.dta", keepusing(st) keep(match master) nogen
merge 1:1 isin year using "$temp\lt_datastream_eca.dta", keepusing(lt) keep(match master) nogen
merge 1:1 isin year using "$temp\eq_datastream_eca.dta", keepusing(eq) keep(match master) nogen
merge 1:1 isin year using "$temp\sales_datastream_eca.dta", keepusing(sales) keep(match master) nogen
merge 1:1 isin year using "$temp\capex_datastream_eca.dta", keepusing(capex) keep(match master) nogen
merge 1:1 isin year using "$temp\cogs_datastream_eca.dta", keepusing(cogs) keep(match master) nogen
merge 1:1 isin year using "$temp\assets_datastream_eca.dta", keepusing(assets) keep(match master) nogen
merge m:1 isin using "$temp\sic_datastream_eca.dta", keepusing(sic) keep(match master) nogen
merge 1:1 isin year using "$temp\dividend_datastream_eca.dta", keepusing(dividend) keep(match master) nogen
merge 1:1 isin year using "$temp\price_datastream_eca.dta", keepusing(price) keep(match master) nogen
merge 1:1 isin year using "$temp\ret_datastream_eca.dta", keepusing(ret) keep(match master) nogen

g cort=substr(mv, 1,2)
drop if cort=="In"
replace mv="." if (mv=="NA"|mv==""|cort=="$$")
destring mv, replace

g cort1=substr(ni, 1,2)
replace ni="." if (ni=="NA"|ni==""|cort1=="$$")
destring ni, replace

g cort2=substr(ppe, 1,2)
replace ppe="." if (ppe=="NA"|ppe==""|cort2=="$$")
destring ppe, replace

g cort3=substr(st, 1,2)
replace st="." if (st=="NA"|st==""|cort3=="$$")
destring st, replace

g cort4=substr(lt, 1,2)
replace lt="." if (lt=="NA"|lt==""|cort4=="$$")
destring lt, replace

g cort6=substr(eq, 1,2)
replace eq="." if (eq=="NA"|eq==""|cort6=="$$")
destring eq, replace

g cort7=substr(capex, 1,2)
replace capex="." if (capex=="NA"|capex==""|cort7=="$$")
destring capex, replace

g cort8=substr(sales, 1,2)
replace sales="." if (sales=="NA"|sales==""|cort8=="$$")
destring sales, replace

g cort9=substr(cogs, 1,2)
replace cogs="." if (cogs=="NA"|cogs==""|cort9=="$$")
destring cogs, replace

g cort10=substr(assets, 1,2)
replace assets="." if (assets=="NA"|assets==""|cort10=="$$")
destring assets, replace

g cort17=substr(dividend, 1,2)
replace dividend="." if (dividend=="NA"|dividend==""|cort17=="$$")
destring dividend, replace

g cort18=substr(ret, 1,2)
replace ret="." if (ret=="NA"|ret==""|cort18=="$$")
destring ret, replace

g cort19=substr(price, 1,2)
replace price="." if (price=="NA"|price==""|cort19=="$$")
destring price, replace

replace ppe=. if ppe<0
replace st=. if st<0
replace sales=. if sales<0
replace capex=. if capex<0
replace cogs=. if cogs<0
replace dividend=. if dividend<0

drop cort*

save "$temp\datastream_controls_dollars_eca.dta", replace

/*Converting Roberts's DealScan linking table into STATA format*/

clear all
import excel "$inputs\dealscan\ds_cs_link_April_2018_post.xlsx", sheet("link_data") firstrow cellrange(A1:O177013) allstring

rename bcoid companyid

save "$temp\roberts_companyid_gvkey.dta", replace

/*Converting Old to New DealScan linking table into STATA format*/
clear all
import excel "$inputs\dealscan\LPC_Loanconnector_Company_ID_Mappings.xlsx", sheet("in") firstrow cellrange(A1:C148147) allstring

rename LPC_COMPANY_ID companyid
destring companyid, replace

rename LoanConnectorCompanyID borrowerid
destring borrowerid, replace

save "$temp\link_borrowerid_companyid.dta", replace

/*Converting fuzzymatched DealScan borrowernames table into STATA format*/

clear all
import excel "$inputs\dealscan\Dealscan_fuzzy_matching.xlsx", sheet("Sheet3") firstrow cellrange(A1:F617) allstring

keep if match=="1"

save "$temp\dealscan_fuzzymatch_iss.dta", replace

/*Keeping only green & ESG linked loans*/

use "$inputs\dealscan\dealscan_2010_2015.dta", clear

rename Borrower_Id borrowerid

g green=0
replace green=1 if strpos(lower( Market_Segment ),"green")

g esg_linked=0
replace esg_linked=1 if strpos(lower( Market_Segment ),"environmental")

keep if green==1|esg_linked==1

g year=year(Deal_Active_Date)

bysort borrowerid year: egen m_green=max(green)
bysort borrowerid year: egen m_esg_linked=max(esg_linked)

duplicates drop borrowerid year, force

rename Borrower_Name borrower_name

keep borrowerid year m_green m_esg_linked borrower_name

save "$temp\dealscan1.dta", replace

use "$inputs\dealscan\dealscan_2016_2021.dta", clear

rename Borrower_Id borrowerid

g green=0
replace green=1 if strpos(lower( Market_Segment ),"green")

g esg_linked=0
replace esg_linked=1 if strpos(lower( Market_Segment ),"environmental")

keep if green==1|esg_linked==1

g year=year(Deal_Active_Date)

bysort borrowerid year: egen m_green=max(green)
bysort borrowerid year: egen m_esg_linked=max(esg_linked)

duplicates drop borrowerid year, force

rename Borrower_Name borrower_name

keep borrowerid year m_green m_esg_linked borrower_name

append using "$temp\dealscan1.dta"

destring borrowerid, replace

merge m:1 borrowerid using "$temp\link_borrowerid_companyid.dta", keepusing(companyid) keep(match master) nogen

merge m:1 companyid using "$temp\roberts_companyid_gvkey.dta", keepusing(gvkey) keep(match master) nogen

merge m:1 companyid using "$inputs\dealscan\dealscan_worldscope_linking_table.dta", keepusing(isin) keep(match master) nogen

merge m:1 companyid using "$inputs\dealscan\dealscan_worldscope_linking_table.dta", keepusing(cusip) keep(match master) nogen

save "$temp\dealscan_green_esg.dta", replace

use "$temp\dealscan_green_esg.dta", clear

merge m:1 borrower_name using "$temp\dealscan_fuzzymatch_iss.dta", keepusing(iss_company_id) keep(match master) nogen

rename iss_company_id iss_company_id_new

destring gvkey, replace
merge m:1 gvkey using "$temp\gvkey_list_eca.dta", keepusing(iss_company_id) keep(match master) nogen

replace iss_company_id_new=iss_company_id if iss_company_id_new==. & iss_company_id!=.
drop iss_company_id 

merge m:1 isin using "$temp\isin_list_eca1.dta", keepusing(iss_company_id) keep(match master) nogen

replace iss_company_id_new=iss_company_id if iss_company_id_new==. & iss_company_id!=.
drop iss_company_id 

merge m:1 cusip using "$temp\cusip_list_eca.dta", keepusing(iss_company_id) keep(match master) nogen

replace iss_company_id_new=iss_company_id if iss_company_id_new==. & iss_company_id!=.
drop iss_company_id 

rename iss_company_id_new iss_company_id 

save "$temp\dealscan_green_esg.dta", replace

keep if iss_company_id!=.

bysort iss_company_id year: egen mm_green=max(m_green)
bysort iss_company_id year: egen mm_esg_linked=max(m_esg_linked)

duplicates drop iss_company_id year, force 

g year1=year-1

drop year
rename year1 year
rename mm_green fmm_green
rename mm_esg_linked fmm_esg_linked

save "$temp\dealscan_green_esg_tomerge2.dta", replace








/*Constructing ISS recommendation on firm-year level*/

use "$inputs\iss_voting_analytics\va_us_2009_2021_issrec.dta", clear

rename CompanyID iss_company_id

g year=year(MeetingDate)

g iss_recommendation=0
replace iss_recommendation=1 if ISSrec=="For"

g support=.
replace support=votedFor/(votedFor+votedAgainst) if base=="F+A"
replace support=votedFor/(votedFor+votedAgainst+votedAbstain) if base=="F+A+AB"
replace support=votedFor/(outstandingShare) if base=="Outstanding"

replace support=support*100

keep iss_company_id year support iss_recommendation AgendaGeneralDesc

append using "$temp\va_global_votes.dta"

keep if strpos(lower( AgendaGeneralDesc ),"elect director")

bysort iss_company_id year: egen director_iss=mean(iss_recommendation)

duplicates drop iss_company_id year, force

save "$temp\director_iss.dta", replace


use "$inputs\iss_voting_analytics\va_us_2009_2021_issrec.dta", clear

rename CompanyID iss_company_id

g year=year(MeetingDate)

g iss_recommendation=0
replace iss_recommendation=1 if ISSrec=="For"

g support=.
replace support=votedFor/(votedFor+votedAgainst) if base=="F+A"
replace support=votedFor/(votedFor+votedAgainst+votedAbstain) if base=="F+A+AB"
replace support=votedFor/(outstandingShare) if base=="Outstanding"

replace support=support*100

keep iss_company_id year support iss_recommendation AgendaGeneralDesc

append using "$temp\va_global_votes.dta"

keep if strpos(lower( AgendaGeneralDesc ),"elect director")

bysort iss_company_id year: egen director_support=mean(support)

duplicates drop iss_company_id year, force

save "$temp\director_support.dta", replace




clear all
import excel "$inputs\engagements\SSGA_2019-2020.xlsx", sheet("SSGA Final") firstrow allstring

g environmental_social2=1

rename Year year
destring year, replace

duplicates drop isin year, force

save "$inputs\engagements\statestreet_engagements_2019_2020.dta", replace



clear all
import excel "$inputs\epi\2020-epi.xlsx", sheet("3_EPI_Results") firstrow allstring

keep code iso country EPInew
rename iso iss_country
rename EPInew epi

destring epi, replace

expand 2, generate(number)
bysort iss_country: gen count=_n
generate year=count+2018
drop count number 

save "$temp\epi_2019_2020.dta", replace

clear all
import excel "$inputs\epi\2018-epi.xlsx", sheet("2018EPI_ScoresCurrent") firstrow allstring

keep code iso country EPIcurrent
rename iso iss_country
rename EPIcurrent epi

destring epi, replace

expand 2, generate(number)
bysort iss_country: gen count=_n
generate year=count+2016
drop count number 

save "$temp\epi_2017_2018.dta", replace

clear all
import excel "$inputs\epi\2016-epi.xlsx", sheet("Indicator Scores") firstrow allstring
 
keep ISO3 Country EPIScore
rename ISO3 iss_country
rename EPIScore epi

destring epi, replace

expand 2, generate(number)
bysort iss_country: gen count=_n
generate year=count+2014
drop count number 

save "$temp\epi_2015_2016.dta", replace

clear all
import excel "$inputs\epi\2014-epi.xls", sheet("Indicator Scores") firstrow allstring
  
keep ISO3v10 Country EPIScore
rename ISO3v10 iss_country
rename EPIScore epi

destring epi, replace

expand 2, generate(number)
bysort iss_country: gen count=_n
generate year=count+2012
drop count number 

save "$temp\epi_2013_2014.dta", replace

clear all
import excel "$inputs\epi\2012-epi.xls", sheet("EPI2012") firstrow allstring
  
keep code ISO3V10 EPI
rename ISO3V10 iss_country
rename EPI epi

drop if epi==""

replace epi="." if epi==".."

destring epi, replace

expand 2, generate(number)
bysort iss_country: gen count=_n
generate year=count+2010
drop count number 

save "$temp\epi_2011_2012.dta", replace

clear all
import excel "$inputs\epi\2010-epi.xls", sheet("EPI2010_onlyEPIcountries") firstrow allstring
 
keep code ISO3V10 EPI
rename ISO3V10 iss_country
rename EPI epi

drop if epi==""

replace epi="." if epi==".."

destring epi, replace

expand 2, generate(number)
bysort iss_country: gen count=_n
generate year=count+2008
drop count number 

append using "$temp\epi_2011_2012.dta"
append using "$temp\epi_2013_2014.dta"
append using "$temp\epi_2015_2016.dta"
append using "$temp\epi_2017_2018.dta"
append using "$temp\epi_2019_2020.dta"
 
save "$temp\epi_2009_2020.dta", replace




use "$inputs\incentive_lab\eca\eca_metrics.dta", clear

rename fiscal_year year 

/*First-tier measure of emission reduction KPIs*/

g exclude=0
replace exclude=1 if strpos( lower(disclosed_metric_name), "lithium carbonate")
replace exclude=1 if strpos( lower(disclosed_metric_name), "hydrocarbon")
replace exclude=1 if strpos( lower(disclosed_metric_name), "carbon disclosure")

g carbon=0
replace carbon=1 if  strpos( lower(disclosed_metric_name), "emission")
replace carbon=1 if  strpos( lower(disclosed_metric_name), "co2")
replace carbon=1 if  strpos( lower(disclosed_metric_name), "carbon")  & exclude==0
replace carbon=1 if  strpos( lower(disclosed_metric_name), "ghg")
replace carbon=1 if  strpos( lower(disclosed_metric_name), "greenhouse")
replace carbon=1 if  strpos( lower(disclosed_metric_name), "green house")
replace carbon=1 if  strpos( lower(disclosed_metric_name), "scope 1")

/*In total 524 events of carbon performance metric in 230 distrinct firms over 400 firm-years*/

/*hydrocarbon growth, carbon disclosure project; carbon disclosure; scope 1; lithium carbonate*/

/*Second-tier measure of emission reduction KPIs*/
g environment=0

replace environment=1 if overall_metric_type=="environment"
replace environment=1 if metric_type_itemized=="climate change and energy use"
replace environment=1 if metric_type_itemized=="environmental protection"
replace environment=1 if strpos( lower(disclosed_metric_name), "emission")
replace environment=1 if strpos( lower(disclosed_metric_name), "carbon disclosure")
replace environment=1 if strpos( lower(disclosed_metric_name), "environment" )
replace environment=1 if strpos( lower(disclosed_metric_name), "enviroment" )
replace environment=1 if strpos( lower(disclosed_metric_name), "envirioment" )
replace environment=1 if strpos( lower(disclosed_metric_name), "ecolog")
replace environment=1 if strpos( lower(disclosed_metric_name), "clean energy")
replace environment=1 if strpos( lower(disclosed_metric_name), "climate")
replace environment=1 if strpos( lower(disclosed_metric_name), "energy efficiency")
replace environment=1 if strpos( lower(disclosed_metric_name), "environment") & strpos( lower(disclosed_metric_name), "safety")
replace environment=1 if disclosed_metric_name=="Environment" 
replace environment=1 if disclosed_metric_name=="Health & environment"
replace environment=1 if strpos( lower(disclosed_metric_name), "co2" )
replace environment=1 if strpos( lower(disclosed_metric_name), "carbon" )
replace environment=1 if strpos( lower(disclosed_metric_name), "environment") & strpos( lower(disclosed_metric_name), "health")
replace environment=1 if strpos( lower(disclosed_metric_name), "environment compliance" )
replace environment=1 if strpos( lower(disclosed_metric_name), "protection of the environment" )
replace environment=1 if strpos( lower(disclosed_metric_name), "environment-human" )
replace environment=1 if strpos( lower(disclosed_metric_name), "planet" )
replace environment=1 if strpos( lower(disclosed_metric_name), "sustainability" )
replace environment=1 if strpos( lower(disclosed_metric_name), "uncharged water" )

replace environment=0 if carbon==1

/*Third-tier measure of emission reduction KPIs*/
g esg=0
replace esg=1 if strpos( lower(disclosed_metric_name), "esg" )

/*Fourth-tier measure of emission reduction KPIs*/
g csr=esg
replace csr=1 if overall_metric_type=="csr"
replace csr=1 if overall_metric_type=="social"
replace csr=1 if metric_type_itemized=="corporate social responsibility"
replace csr=1 if strpos( lower(disclosed_metric_name), "corporate social responsibility" )
replace csr=1 if strpos( lower(disclosed_metric_name), "csr" )

replace csr=0 if environment==1

g safety=0
replace safety=1 if strpos( lower(disclosed_metric_name), "safety")
replace safety=1 if strpos( lower(disclosed_metric_name), "injury")
replace safety=1 if strpos( lower(disclosed_metric_name), "injuries")
replace safety=1 if strpos( lower(disclosed_metric_name), "fatalities")
replace safety=1 if strpos( lower(disclosed_metric_name), "incident")
replace safety=1 if strpos( lower(disclosed_metric_name), "days away")
replace safety=1 if strpos( lower(disclosed_metric_name), "dart")
replace safety=1 if strpos( lower(disclosed_metric_name), "accident")
replace safety=1 if strpos( lower(disclosed_metric_name), "osha")
replace safety=1 if strpos( lower(disclosed_metric_name), "tcir")
replace safety=1 if strpos( lower(disclosed_metric_name), "ltifr")
replace safety=1 if strpos( lower(disclosed_metric_name), "trir")
replace safety=1 if strpos( lower(disclosed_metric_name), "lost time incidence rate")
replace safety=1 if strpos( lower(disclosed_metric_name), "medical incidence rate")
replace safety=1 if strpos( lower(disclosed_metric_name), "trcfr")
replace safety=1 if strpos( lower(disclosed_metric_name), "fatality")
replace safety=1 if strpos( lower(disclosed_metric_name), "critical risk")
replace safety=1 if strpos( lower(disclosed_metric_name), "critical control")
replace safety=1 if strpos( lower(disclosed_metric_name), "damage")
replace safety=1 if strpos( lower(disclosed_metric_name), "emergency response time")
replace safety=1 if strpos( lower(disclosed_metric_name), "lost workday")
replace safety=1 if strpos( lower(disclosed_metric_name), "health")
replace safety=1 if strpos( lower(disclosed_metric_name), "security")
replace safety=1 if strpos( lower(disclosed_metric_name), "lost day")
replace safety=1 if strpos( lower(disclosed_metric_name), "disability")
replace safety=1 if strpos( lower(disclosed_metric_name), "hazard")
replace safety=1 if strpos( lower(disclosed_metric_name), "tphr")
replace safety=1 if strpos( lower(disclosed_metric_name), "nuclear")
replace safety=1 if strpos( lower(disclosed_metric_name), "outage")
replace safety=1 if strpos( lower(disclosed_metric_name), "loss of life")
replace safety=1 if strpos( lower(disclosed_metric_name), "occupational exposure")
replace safety=1 if strpos( lower(disclosed_metric_name), "safe tours completed")
replace safety=1 if strpos( lower(disclosed_metric_name), "safe delivery")
replace safety=1 if strpos( lower(disclosed_metric_name), "dot crash")
replace safety=1 if strpos( lower(disclosed_metric_name), "safe production")
replace safety=1 if strpos( lower(disclosed_metric_name), "sick pay")
replace safety=1 if strpos( lower(disclosed_metric_name), "hsse")
replace safety=1 if strpos( lower(disclosed_metric_name), "recordable case rate")
replace safety=1 if strpos( lower(disclosed_metric_name), "group afr")
replace safety=1 if strpos( lower(disclosed_metric_name), "eh&s")
replace safety=1 if strpos( lower(disclosed_metric_name), "slams")
replace safety=1 if strpos( lower(disclosed_metric_name), "covid")
replace safety=1 if disclosed_metric_name=="RIR"


g diversity=0
replace diversity=1 if strpos( lower(disclosed_metric_name), "diversity")
replace diversity=1 if strpos( lower(disclosed_metric_name), "diverse")
replace diversity=1 if strpos( lower(disclosed_metric_name), "women")
replace diversity=1 if strpos( lower(disclosed_metric_name), "female")
replace diversity=1 if strpos( lower(disclosed_metric_name), "feminization")
replace diversity=1 if strpos( lower(disclosed_metric_name), "feminisation")
replace diversity=1 if strpos( lower(disclosed_metric_name), "inclusion")
replace diversity=1 if strpos( lower(disclosed_metric_name), "gender")
replace diversity=1 if strpos( lower(disclosed_metric_name), "indigenous")
replace diversity=1 if strpos( lower(disclosed_metric_name), "balanced gender")
replace diversity=1 if strpos( lower(disclosed_metric_name), "black")
replace diversity=1 if strpos( lower(disclosed_metric_name), "minority")
replace diversity=1 if strpos( lower(disclosed_metric_name), "minorities")
replace diversity=1 if strpos( lower(disclosed_metric_name), "inclusive")
replace diversity=1 if strpos( lower(disclosed_metric_name), "non-white")
replace diversity=1 if strpos( lower(disclosed_metric_name), "same opportunity")
replace diversity=1 if strpos( lower(disclosed_metric_name), "equal opportunities")
replace diversity=1 if strpos( lower(disclosed_metric_name), "b-bbee")

g people=0
replace people=1 if strpos( lower(disclosed_metric_name), "management development")
replace people=1 if strpos( lower(disclosed_metric_name), "talent")
replace people=1 if strpos( lower(disclosed_metric_name), "retention")
replace people=1 if strpos( lower(disclosed_metric_name), "people development")
replace people=1 if strpos( lower(disclosed_metric_name), "development of people")
replace people=1 if strpos( lower(disclosed_metric_name), "personnel")
replace people=1 if strpos( lower(disclosed_metric_name), "workplace development")
replace people=1 if strpos( lower(disclosed_metric_name), "human capital")
replace people=1 if strpos( lower(disclosed_metric_name), "leadership development")
replace people=1 if strpos( lower(disclosed_metric_name), "employee engagement")
replace people=1 if strpos( lower(disclosed_metric_name), "employee turnover")
replace people=1 if strpos( lower(disclosed_metric_name), "turnover rate")
replace people=1 if strpos( lower(disclosed_metric_name), "leadership")
replace people=1 if strpos( lower(disclosed_metric_name), "filled internally")
replace people=1 if strpos( lower(disclosed_metric_name), "employee survey")
replace people=1 if strpos( lower(disclosed_metric_name), "engagement survey")
replace people=1 if strpos( lower(disclosed_metric_name), "employee satisfaction")
replace people=1 if strpos( lower(disclosed_metric_name), "workforce")
replace people=1 if strpos( lower(disclosed_metric_name), "member engagement")
replace people=1 if strpos( lower(disclosed_metric_name), "great place to work")
replace people=1 if strpos( lower(disclosed_metric_name), "best place to work")
replace people=1 if strpos( lower(disclosed_metric_name), "better place to work")
replace people=1 if strpos( lower(disclosed_metric_name), "place people are proud to work")
replace people=1 if strpos( lower(disclosed_metric_name), "human resources")
replace people=1 if strpos( lower(disclosed_metric_name), "hr and organization")
replace people=1 if strpos( lower(disclosed_metric_name), "people empowerment")
replace people=1 if strpos( lower(disclosed_metric_name), "people leadership")
replace people=1 if strpos( lower(disclosed_metric_name), "people engagement")
replace people=1 if strpos( lower(disclosed_metric_name), "positive workplace")
replace people=1 if strpos( lower(disclosed_metric_name), "training")
replace people=1 if strpos( lower(disclosed_metric_name), "trained")
replace people=1 if strpos( lower(disclosed_metric_name), "teamwork")
replace people=1 if strpos( lower(disclosed_metric_name), "leadership quality")
replace people=1 if strpos( lower(disclosed_metric_name), "capability")
replace people=1 if strpos( lower(disclosed_metric_name), "skill")
replace people=1 if strpos( lower(disclosed_metric_name), "workplace health")
replace people=1 if strpos( lower(disclosed_metric_name), "recruitment")
replace people=1 if strpos( lower(disclosed_metric_name), "colleague")
replace people=1 if strpos( lower(disclosed_metric_name), "staff")
replace people=1 if strpos( lower(disclosed_metric_name), "stuff")
replace people=1 if strpos( lower(disclosed_metric_name), "succession")
replace people=1 if strpos( lower(disclosed_metric_name), "organizational health")
replace people=1 if strpos( lower(disclosed_metric_name), "motivation")
replace people=1 if strpos( lower(disclosed_metric_name), "employee")
replace people=1 if strpos( lower(disclosed_metric_name), "people")
replace people=1 if strpos( lower(disclosed_metric_name), "engagement")
replace people=1 if strpos( lower(disclosed_metric_name), "engage")
replace people=1 if strpos( lower(disclosed_metric_name), "simplify work")
replace people=1 if strpos( lower(disclosed_metric_name), "team")
replace people=1 if strpos( lower(disclosed_metric_name), "turnover")
replace people=1 if strpos( lower(disclosed_metric_name), "hiring")
replace people=1 if strpos( lower(disclosed_metric_name), "job security")
replace people=1 if strpos( lower(disclosed_metric_name), "wellness")
replace people=1 if strpos( lower(disclosed_metric_name), "employment")
replace people=1 if strpos( lower(disclosed_metric_name), "quality of life")
replace people=1 if strpos( lower(disclosed_metric_name), "candidate experience")
replace people=1 if strpos( lower(disclosed_metric_name), "promotion")
replace people=1 if strpos( lower(disclosed_metric_name), "labor")
replace people=1 if strpos( lower(disclosed_metric_name), "hr and csr")
replace people=1 if strpos( lower(disclosed_metric_name), "resignation")
replace people=1 if strpos( lower(disclosed_metric_name), "member satisfaction")
replace people=1 if strpos( lower(disclosed_metric_name), "professionals")
replace people=1 if strpos( lower(disclosed_metric_name), "employer of choice")
replace people=1 if strpos( lower(disclosed_metric_name), "disciplinary factor")
replace people=1 if strpos( lower(disclosed_metric_name), "loyalty")
replace people=1 if strpos( lower(disclosed_metric_name), "human resource")
replace people=1 if strpos( lower(disclosed_metric_name), "workers compensation")
replace people=1 if strpos( lower(disclosed_metric_name), "bullying")
replace people=1 if strpos( lower(disclosed_metric_name), "harassment")
replace people=1 if strpos( lower(disclosed_metric_name), "employment equity")
replace people=1 if strpos( lower(disclosed_metric_name), "future of work")
replace people=1 if strpos( lower(disclosed_metric_name), "connect with work")
replace people=1 if strpos( lower(disclosed_metric_name), "top employer")
replace people=1 if strpos( lower(disclosed_metric_name), "workplace satisfaction")
replace people=1 if strpos( lower(disclosed_metric_name), "formation")
replace people=1 if strpos( lower(disclosed_metric_name), "star rating")
replace people=1 if strpos( lower(disclosed_metric_name), "workplace walfare")
replace people=1 if strpos( lower(disclosed_metric_name), "size of life-licensed sales force")

g corporate_culture=0
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "cultural development")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "employee culture")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "culture and values")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "conduct and culture")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "organizational culture")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "code of conduct")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "ethics")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "ethical")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "community")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "culture")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "cultur")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "communities")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "integrity")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "value")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "societ")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "social")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "stakeholder")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "commun criteria")
replace corporate_culture=1 if strpos( lower(disclosed_metric_name), "persimmon way")


g compliance=0
replace compliance=1 if strpos( lower(disclosed_metric_name), "slavery")
replace compliance=1 if strpos( lower(disclosed_metric_name), "compliance")
replace compliance=1 if strpos( lower(disclosed_metric_name), "bribery")
replace compliance=1 if strpos( lower(disclosed_metric_name), "corruption")
replace compliance=1 if strpos( lower(disclosed_metric_name), "reputation")
replace compliance=1 if strpos( lower(disclosed_metric_name), "human rights")
replace compliance=1 if strpos( lower(disclosed_metric_name), "perception")
replace compliance=1 if strpos( lower(disclosed_metric_name), "corporate image")
replace compliance=1 if strpos( lower(disclosed_metric_name), "regulator")
replace compliance=1 if strpos( lower(disclosed_metric_name), "animal welfare")
replace compliance=1 if strpos( lower(disclosed_metric_name), "migrant labor")
replace compliance=1 if strpos( lower(disclosed_metric_name), "dot complaint")
replace compliance=1 if strpos( lower(disclosed_metric_name), "build quality")
replace compliance=1 if strpos( lower(disclosed_metric_name), "mccsr ratio")


g governance=0
replace governance=1 if strpos( lower(disclosed_metric_name), "corporate governance")
replace governance=1 if strpos( lower(disclosed_metric_name), "governance")
replace governance=1 if strpos( lower(disclosed_metric_name), "corporate stewardship")
replace governance=1 if strpos( lower(disclosed_metric_name), "shareholder")

g customer=0
replace customer=1 if strpos( lower(disclosed_metric_name), "customer")
replace customer=1 if strpos( lower(disclosed_metric_name), "saifi")
replace customer=1 if strpos( lower(disclosed_metric_name), "saidi")
replace customer=1 if strpos( lower(disclosed_metric_name), "client")
replace customer=1 if strpos( lower(disclosed_metric_name), "consumer")
replace customer=1 if strpos( lower(disclosed_metric_name), "costumer")
replace customer=1 if strpos( lower(disclosed_metric_name), "guest satisfaction")
replace customer=1 if strpos( lower(disclosed_metric_name), "response time")
replace customer=1 if strpos( lower(disclosed_metric_name), "service level")
replace customer=1 if strpos( lower(disclosed_metric_name), "likelihood to recommend")
replace customer=1 if strpos( lower(disclosed_metric_name), "reliability")
replace customer=1 if strpos( lower(disclosed_metric_name), "net promoter score")
replace customer=1 if strpos( lower(disclosed_metric_name), "nps")
replace customer=1 if strpos( lower(disclosed_metric_name), "call center")
replace customer=1 if strpos( lower(disclosed_metric_name), "quality of service")
replace customer=1 if strpos( lower(disclosed_metric_name), "on time action")
replace customer=1 if strpos( lower(disclosed_metric_name), "reclamation")
replace customer=1 if strpos( lower(disclosed_metric_name), "user satisfaction")
replace customer=1 if strpos( lower(disclosed_metric_name), "rate of satisfaction")

g other=0
replace other=1 if csr==1 & safety==0 & customer==0 & corporate_culture==0 & compliance==0 & governance==0 & people==0 & diversity==0

bysort iss_company_id year: egen carbon2=max(carbon)
bysort iss_company_id year: egen environment2=max(environment)
bysort iss_company_id year: egen csr2=max(csr)
bysort iss_company_id year: egen safety2=max(safety)
bysort iss_company_id year: egen customer2=max(customer)
bysort iss_company_id year: egen governance2=max(governance)
bysort iss_company_id year: egen compliance2=max(compliance)
bysort iss_company_id year: egen culture2=max(corporate_culture)
bysort iss_company_id year: egen people2=max(people)
bysort iss_company_id year: egen diversity2=max(diversity)
bysort iss_company_id year: egen other2=max(other)

keep iss_company_id year carbon2 environment2 csr2 safety2 customer2 governance2 compliance2 culture2 people2 diversity2 other2
duplicates drop iss_company_id year, force

save "$temp\eca_metrics_environment6.dta", replace


use "$inputs\incentive_lab\eca\eca_metrics.dta", clear

/*There are 330,266 performance metrics spanning 2011-2021*/

rename fiscal_year year 

/*First-tier measure of emission reduction KPIs*/

g exclude=0
replace exclude=1 if strpos( lower(disclosed_metric_name), "lithium carbonate")
replace exclude=1 if strpos( lower(disclosed_metric_name), "hydrocarbon")
replace exclude=1 if strpos( lower(disclosed_metric_name), "carbon disclosure")

g carbon=0
replace carbon=1 if  strpos( lower(disclosed_metric_name), "emission")
replace carbon=1 if  strpos( lower(disclosed_metric_name), "co2")
replace carbon=1 if  strpos( lower(disclosed_metric_name), "carbon")  & exclude==0
replace carbon=1 if  strpos( lower(disclosed_metric_name), "ghg")
replace carbon=1 if  strpos( lower(disclosed_metric_name), "greenhouse")
replace carbon=1 if  strpos( lower(disclosed_metric_name), "green house")
replace carbon=1 if  strpos( lower(disclosed_metric_name), "scope 1")

/*In total 524 events of carbon performance metric in 230 distrinct firms over 400 firm-years*/

/*hydrocarbon growth, carbon disclosure project; carbon disclosure; scope 1; lithium carbonate*/

/*Second-tier measure of emission reduction KPIs*/
g environment=carbon

replace environment=1 if overall_metric_type=="environment"
replace environment=1 if metric_type_itemized=="climate change and energy use"
replace environment=1 if metric_type_itemized=="environmental protection"
replace environment=1 if strpos( lower(disclosed_metric_name), "emission")
replace environment=1 if strpos( lower(disclosed_metric_name), "carbon disclosure")
replace environment=1 if strpos( lower(disclosed_metric_name), "environment" )
replace environment=1 if strpos( lower(disclosed_metric_name), "enviroment" )
replace environment=1 if strpos( lower(disclosed_metric_name), "envirioment" )
replace environment=1 if strpos( lower(disclosed_metric_name), "ecolog")
replace environment=1 if strpos( lower(disclosed_metric_name), "clean energy")
replace environment=1 if strpos( lower(disclosed_metric_name), "climate")
replace environment=1 if strpos( lower(disclosed_metric_name), "energy efficiency")
replace environment=1 if strpos( lower(disclosed_metric_name), "environment") & strpos( lower(disclosed_metric_name), "safety")
replace environment=1 if disclosed_metric_name=="Environment" 
replace environment=1 if disclosed_metric_name=="Health & environment"
replace environment=1 if strpos( lower(disclosed_metric_name), "co2" )
replace environment=1 if strpos( lower(disclosed_metric_name), "carbon" )
replace environment=1 if strpos( lower(disclosed_metric_name), "environment") & strpos( lower(disclosed_metric_name), "health")
replace environment=1 if strpos( lower(disclosed_metric_name), "environment compliance" )
replace environment=1 if strpos( lower(disclosed_metric_name), "protection of the environment" )
replace environment=1 if strpos( lower(disclosed_metric_name), "environment-human" )
replace environment=1 if strpos( lower(disclosed_metric_name), "planet" )
replace environment=1 if strpos( lower(disclosed_metric_name), "sustainability" )

/*Third-tier measure of emission reduction KPIs*/
g esg=environment
replace esg=1 if strpos( lower(disclosed_metric_name), "esg" )

/*Fourth-tier measure of emission reduction KPIs*/
g csr=esg
replace csr=1 if overall_metric_type=="csr"
replace csr=1 if overall_metric_type=="social"
replace csr=1 if metric_type_itemized=="corporate social responsibility"
replace csr=1 if strpos( lower(disclosed_metric_name), "corporate social responsibility" )
replace csr=1 if strpos( lower(disclosed_metric_name), "csr" )

bysort iss_company_id year: egen carbon1=max(carbon)
bysort iss_company_id year: egen environment1=max(environment)
bysort iss_company_id year: egen esg1=max(esg)
bysort iss_company_id year: egen csr1=max(csr)

keep iss_company_id year carbon1 environment1  esg1 csr1 nonfinancial1
duplicates drop iss_company_id year, force

save "$temp\eca_metrics_environment1.dta", replace



use "$inputs\esg\esg_company_summary_data.dta", clear 

rename FisYear year
rename Isin isin

drop if isin==""

duplicates drop isin year, force

save "$temp\esgt.dta", replace

g year1=year+1

drop year
rename year1 year
rename overall_score loverall_score
rename econ_score lecon_score
rename envrn_score lenvrn_score
rename corpgov_score lcorpgov_score
rename social_score lsocial_score

save "$temp\esg.dta", replace



/*Forwarding all the voting variables by 1 year*/
use "$temp\pay_support.dta", clear
g year1=year-1
drop year
rename year1 year
save "$temp\fpay_support.dta", replace

use "$temp\director_support.dta", clear
g year1=year-1
drop year
rename year1 year
save "$temp\fdirector_support.dta", replace

use "$temp\pay_iss.dta", clear
g year1=year-1
drop year
rename year1 year
save "$temp\fpay_iss.dta", replace

use "$temp\director_iss.dta", clear
g year1=year-1
drop year
rename year1 year
save "$temp\fdirector_iss.dta", replace


/*Retreaving the date of fiscal year end corresponding to Proxy statement*/
use "$inputs\incentive_lab\eca\eca_metrics.dta", clear

/*There are 330,266 performance metrics spanning 2011-2021*/

rename fiscal_year year 

g date=substr(eca_company_year_id, 17,8)

g month=substr(date, 5,2)
g day=substr(date, 7,2)

g data=date(date, "YMD")

rename data date_fye

keep iss_company_id year date_fye
duplicates drop iss_company_id year, force

save "$temp\date_fye.dta", replace

/*Retreaving the date of actual voting*/
use "$inputs\iss_voting_analytics\va_global_issrec.dta", clear

rename CompanyID iss_company_id

g year=year(MeetingDate)

keep iss_company_id year MeetingDate

save "$temp\va_global_meetingdate.dta", replace

use "$inputs\iss_voting_analytics\va_us_2009_2021_issrec.dta", clear

rename CompanyID iss_company_id

g year=year(MeetingDate)

keep iss_company_id year MeetingDate

append using "$temp\va_global_meetingdate.dta"

bysort iss_company_id year: egen min_date=min(MeetingDate)

keep if min_date==MeetingDate
duplicates drop iss_company_id year, force

g year1=year-1
drop year
rename year1 year

save "$temp\voting_date.dta", replace


clear all
import excel "$temp\slb_iss_code.xlsx", sheet("Sheet6") firstrow cellrange(A1:D775) allstring

keep if match=="1"
keep IssuerName iss_company_id
destring iss_company_id, replace

save "$temp\green_bond_iss_company_id.dta", replace

clear all
import excel "$inputs\green_bonds\Bloomberg Green Corporate Bonds.xlsx", sheet("Hardcopy_1") firstrow cellrange(A1:O4154) allstring

merge m:1 IssuerName using "$temp\green_bond_iss_company_id.dta", keepusing(iss_company_id) keep(match master) nogen

keep if iss_company_id!=.

split IssueDate, p(/)

rename IssueDate3 year

duplicates drop iss_company_id year, force
keep iss_company_id year

g green_bond=1
destring year, replace

g year1=year-1

drop year
rename year1 year
rename green_bond fgreen_bond
save "$temp\fgreen_bond.dta", replace


use "$inputs\factset\FactSet_ownership_summary_2000_2019.dta", clear

g year=year(rquarter)

// Keep last observation for the year
sort factset_entity_id rquarter
bysort factset_entity_id year: gen numer=_n
bysort factset_entity_id year: gen total=_N
keep if total==numer

drop if isin==""
egen firm_id=group(isin)

tsset firm_id year
g lio=l.io

save "$inputs\IO_total_2000_2019_tomerge1.dta", replace


use "$inputs\esg\msci lkd esg.dta", clear 

g score_str=ENV_str_num+EMP_str_num+COM_str_num+DIV_str_num+PRO_str_num+CGOV_str_num+HUM_str_num
g score_con=ENV_con_num+COM_con_num+HUM_con_num+EMP_con_num+DIV_con_num+PRO_con_num+CGOV_con_num 
g score_kld5=ENV_str_num-ENV_con_num+EMP_str_num-EMP_con_num+COM_str_num-COM_con_num+DIV_str_num-DIV_con_num+PRO_str_num-PRO_con_num
g score_kld_env=ENV_str_num-ENV_con_num

keep ENV_str_num CompanyName year CUSIP Ticker score_str score_con score_kld5 score_kld_env
rename CUSIP cusip
drop if cusip==""
drop if cusip=="NA"
drop if cusip=="0"

/*Remaining duplicates are due to using of portions of isins instead of genune cusip*/
duplicates drop cusip year, force

rename cusip cusip8

save "$temp\kld.dta", replace

g year1=year+1
drop year
rename year1 year

rename ENV_str_num lenv_str_num
rename score_str lscore_str
rename score_con lscore_con
rename score_kld5 lscore_kld5
rename score_kld_env lscore_kld_env

save "$temp\lkld.dta", replace



/*Constructing ISS recommendation on firm-year level*/

use "$inputs\iss_voting_analytics\va_us_2009_2021_issrec.dta", clear

rename CompanyID iss_company_id

g year=year(MeetingDate)

g iss_recommendation=0
replace iss_recommendation=1 if ISSrec=="For"

g support=.
replace support=votedFor/(votedFor+votedAgainst) if base=="F+A"
replace support=votedFor/(votedFor+votedAgainst+votedAbstain) if base=="F+A+AB"
replace support=votedFor/(outstandingShare) if base=="Outstanding"

replace support=support*100

keep iss_company_id year support iss_recommendation AgendaGeneralDesc

append using "$temp\va_global_votes.dta"

g pay=0
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"advisory vote to ratify named executi")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"advisory vote on executive compensati")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"amend equity compensation plan")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve adjustment to  aggregate comp")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve adjustment to aggregate compe")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve adjustment to aggregate compe")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve bundled compensation plans")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve compensation of ceo")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve equity compensation plan")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve equity-based compensation")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve fixed-variable compensation")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve increase in aggregate compens")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend bundled compensation")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend deferred compensation")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"bundle compensation")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve annual bonus")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve executive incentive bonus")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve or amend executive incentive")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend bonus matching")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend deferred share bonus")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend executive incentive")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend stock-for-salary/bonus")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"pay for superior performance")

keep if pay==1

bysort iss_company_id year: egen pay_iss=mean(iss_recommendation)

duplicates drop iss_company_id year, force

save "$temp\pay_iss.dta", replace


use "$inputs\iss_voting_analytics\va_us_2009_2021_issrec.dta", clear

rename CompanyID iss_company_id

g year=year(MeetingDate)

g iss_recommendation=0
replace iss_recommendation=1 if ISSrec=="For"

g support=.
replace support=votedFor/(votedFor+votedAgainst) if base=="F+A"
replace support=votedFor/(votedFor+votedAgainst+votedAbstain) if base=="F+A+AB"
replace support=votedFor/(outstandingShare) if base=="Outstanding"

replace support=support*100

keep iss_company_id year support iss_recommendation AgendaGeneralDesc

append using "$temp\va_global_votes.dta"

g pay=0
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"advisory vote to ratify named executi")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"advisory vote on executive compensati")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"amend equity compensation plan")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve adjustment to  aggregate comp")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve adjustment to aggregate compe")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve adjustment to aggregate compe")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve bundled compensation plans")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve compensation of ceo")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve equity compensation plan")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve equity-based compensation")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve fixed-variable compensation")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve increase in aggregate compens")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend bundled compensation")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend deferred compensation")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"bundle compensation")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve annual bonus")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve executive incentive bonus")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve or amend executive incentive")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend bonus matching")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend deferred share bonus")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend executive incentive")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"approve/amend stock-for-salary/bonus")
replace pay=1 if strpos(lower( AgendaGeneralDesc ),"pay for superior performance")

keep if pay==1

bysort iss_company_id year: egen pay_support=mean(support)

duplicates drop iss_company_id year, force

save "$temp\pay_support.dta", replace


/*Creating balanced panel of firms covered by ISS ECA*/
use "$temp\isin_list_eca.dta", clear 
expand 13, generate(number)
bysort isin: gen count=_n
generate year=count+2007
drop count number 
g cusip8=substr(cusip,1,8)

/*Merging in control variables*/
merge 1:1 iss_company_id year using "$temp\controls_eca.dta", keepusing(lsize lroa llev lppe llog_bm ldividends lcapx lreturn sic return ch_roa) keep(match master) nogen
merge 1:1 isin year using "$temp\vol_datastream_eca.dta", keepusing(lvol) keep(match master) nogen
merge 1:1 isin year using "$temp\inside_datastream_eca.dta", keepusing(linsideownership) keep(match master) nogen
merge 1:1 isin year using "$temp\diversity_datastream_eca.dta", keepusing(divers) keep(match master) nogen
merge 1:1 isin year using "$temp\independent_directors_datastream_eca.dta", keepusing(ind) keep(match master) nogen
merge m:1 isin year using "$inputs\IO_total_2000_2019_tomerge1.dta", keepusing(lio) keep(match master) nogen

/*Depending on specification controls would be measured either at the end of year t-1 or at the end of year t*/
merge 1:1 iss_company_id year using "$temp\controls_eca.dta", keepusing(size roa lev ppe log_bm dividends return) keep(match master) nogen

/*Identifier for companies closely held by insiders*/
g ch=0
replace ch=1 if linsideownership>50 & linsideownership!=.

/*Merging in compensation variables*/
merge 1:1 iss_company_id year using "$temp\lceo_comp.dta", keepusing(lceo_comp) keep(match master) nogen

/*Constructing industry indicators*/
destring sic, replace
ffind sic, newvar(ff48) type(48)
ffind sic, newvar(ff17) type(17)
replace ff48=48 if ff48==.

winsor2 lsize lroa llev lppe llog_bm ldividends lio lreturn size roa lev ppe log_bm dividends return, cut(1 99)

/*Constructing abnormal compensation relative to industry-size peers*/
xtile size_quintile = lsize_w, nq(5)
bysort ff48 year size_quintile: egen median_comp3=median(lceo_comp)
g lceo_comp7=lceo_comp-median_comp3

/*Merging in SBTi initiative constituents*/
merge m:1 isin using "$temp\sbti.dta", keepusing(year_joined) keep(match master) nogen

g lsbti=0 
replace lsbti=1 if year>2015 & year_joined<year

/*Merging in emissions variable in levels and changes*/
merge m:1 isin year using "$temp\ltrucost_2021.dta", keepusing(llog_s1) keep(match master) nogen

merge 1:1 isin year using "$temp\f_carbon.dta", keepusing(f* ch* sch* scope*) keep(match master) nogen
drop firm_id
replace ch_s1=ch_s1/1000000

merge 1:1 isin year using "$temp\f_carbon_2022.dta", keepusing(ch_s1_new) keep(match master) nogen
replace ch_s1_new=ch_s1_new/1000000
replace ch_s1_new=ch_s1 if ch_s1_new==. & ch_s1!=.

/*Merging in ESG indexes*/
merge m:1 isin year using "$temp\esg.dta", keepusing(loverall_score) keep(match master) nogen 
merge m:1 isin year using "$temp\esgt.dta", keepusing(overall_score) keep(match master) nogen 
merge m:1 isin year using "$temp\sustainalitics_score.dta", keepusing(total_esg_score) keep(match master) nogen 
merge m:1 isin year using "$temp\sustainalitics_score_t.dta", keepusing(total_esg_score_t) keep(match master) nogen 
merge m:1 cusip8 year using "$temp\kld.dta", keepusing(score_kld5 ) keep(match master) nogen
merge m:1 cusip8 year using "$temp\lkld.dta", keepusing(lscore_kld5) keep(match master) nogen
merge m:1 isin year using "$temp\ch_sustain_new.dta", keepusing(ch_sustain_new) keep(match master) nogen 
merge m:1 isin year using "$temp\sustainalitics_score_new.dta", keepusing(total_esg_score_new) keep(match master) nogen 

g ch_score=overall_score-loverall_score
g ch_score_kld5=score_kld5-lscore_kld5

/*Building sustainalitics scores*/
g ch_sustain=total_esg_score_t-total_esg_score
g ch_sustain2=ch_sustain
replace ch_sustain2=ch_sustain_new if ch_sustain2==. & ch_sustain_new!=.

winsor2 lceo_comp7 loverall_score llog_s1, cut(1 99)

/*Merging in data on engagements by Big Three institutional investors*/
merge 1:1 isin year using "$inputs\engagements\blackrock_engagements_2018_2020.dta", keepusing(blk_engagement) keep(match master) nogen 
merge 1:1 isin year using "$inputs\engagements\statestreet_engagements_2014_2018_adj.dta", keepusing(environmental_social) keep(match master) nogen 
merge 1:1 isin year using "$inputs\engagements\statestreet_engagements_2019_2020.dta", keepusing(environmental_social2) keep(match master) nogen 
merge 1:1 isin year using "$inputs\engagements\vanguard_engagements_2019_2020_adj.dta", keepusing(oversight_strategy_risk) keep(match master) nogen 

replace blk_engagement=0 if blk_engagement!=1 & year>2017
replace environmental_social=0 if environmental_social!=1 & year>2013 & year<2019
replace environmental_social=environmental_social2 if environmental_social2==1 & year>2018
replace environmental_social=0 if environmental_social!=1 & year>2018
replace oversight_strategy_risk=0 if oversight_strategy_risk!=1 & year>2018

g engagement=0 if year>2013
replace engagement=1 if blk_engagement==1|environmental_social==1|oversight_strategy_risk==1

/*Indicator for companies from high emitting industries*/
g dirty4=0
replace dirty4=1 if ff17==14
replace dirty4=1 if ff17==3
replace dirty4=1 if ff17==9
replace dirty4=1 if ff17==12

/*Filling in missing values for headquarters countries*/
replace iss_country="AUS" if company_name=="Aquarius Platinum Ltd."
replace iss_country="GBR" if company_name=="Exillon Energy Plc"
replace iss_country="GBR" if company_name=="Atrium European Real Estate Ltd."
replace iss_country="GBR" if company_name=="Genel Energy Plc"
replace iss_country="GBR" if company_name=="boohoo group Plc"
replace iss_country="FRA" if company_name=="Solutions 30 SE"
replace iss_country="FRA" if company_name=="Sword Group SE"
replace iss_country="DEU" if company_name=="ADLER Group SA"
replace iss_country="FRA" if company_name=="Aperam SA"
replace iss_country="DEU" if company_name=="Aroundtown SA"
replace iss_country="DEU" if company_name=="Gagfah SA"
replace iss_country="DEU" if company_name=="Grand City Properties SA"
replace iss_country="DEU" if company_name=="RTL Group SA"
replace iss_country="DEU" if company_name=="Stabilus S.A."
replace iss_country="GBR" if company_name=="Subsea 7 SA"
replace iss_country="NLD" if company_name=="Core Laboratories NV"

/*Indicator for countreis with ESG disclosure regulations*/
g lreg=0
replace lreg=1 if iss_country=="ARG" & year>=2009
replace lreg=1 if iss_country=="AUS" & year>=2004
replace lreg=1 if iss_country=="AUT" & year>=2017
replace lreg=1 if iss_country=="CHL" & year>=2016
replace lreg=1 if iss_country=="CHN" & year>=2009
replace lreg=1 if iss_country=="FRA" & year>=2004
replace lreg=1 if iss_country=="GRC" & year>=2007
replace lreg=1 if iss_country=="HKG" & year>=2017
replace lreg=1 if iss_country=="IND" & year>=2016
replace lreg=1 if iss_country=="IDN" & year>=2013
replace lreg=1 if iss_country=="ITA" & year>=2017
replace lreg=1 if iss_country=="MYS" & year>=2008
replace lreg=1 if iss_country=="NLD" & year>=2017
replace lreg=1 if iss_country=="NOR" & year>=2014
replace lreg=1 if iss_country=="PAK" & year>=2010
replace lreg=1 if iss_country=="PER" & year>=2017
replace lreg=1 if iss_country=="PHL" & year>=2012
replace lreg=1 if iss_country=="PRT" & year>=2011
replace lreg=1 if iss_country=="SGP" & year>=2017
replace lreg=1 if iss_country=="ZAF" & year>=2011
replace lreg=1 if iss_country=="ESP" & year>=2013
replace lreg=1 if iss_country=="CHE" & year>=2017
replace lreg=1 if iss_country=="THA" & year>=2015
replace lreg=1 if iss_country=="TUR" & year>=2015
replace lreg=1 if iss_country=="GBR" & year>=2014

g control=0
replace control=1 if llog_s1_w!=. & lvol!=. & lsize_w!=. & lio_w!=. & llog_bm_w!=. & lroa_w!=. & llev_w!=. & lppe_w!=. & ldividends_w!=. & lreturn_w!=. & iss_country!="LUX" & iss_country!="HUN" & iss_country!="CZE" & iss_country!="CHN" & iss_country!="HKG"                 

merge m:1 iss_country year using "$temp\epi_2009_2020.dta", keepusing(epi) keep(match master) nogen

egen country_id=group(iss_country)
egen firm_id=group(isin)
egen country_industry=group(ff48 country_id)
egen country_year=group(country_id year)
egen industry_year=group(ff48 year)

/*Shareholder voting results and ISS recommendations variables*/
merge 1:1 iss_company_id year using "$temp\fpay_support.dta", keepusing(pay_support) keep(match master) nogen
merge 1:1 iss_company_id year using "$temp\fdirector_support.dta", keepusing(director_support) keep(match master) nogen
merge 1:1 iss_company_id year using "$temp\fpay_iss.dta", keepusing(pay_iss) keep(match master) nogen
merge 1:1 iss_company_id year using "$temp\fdirector_iss.dta", keepusing(director_iss) keep(match master) nogen

merge 1:1 iss_company_id year using "$temp\date_fye.dta", keepusing(date_fye) keep(match master) nogen
merge 1:1 iss_company_id year using "$temp\voting_date.dta", keepusing(MeetingDate) keep(match master) nogen

g time_lag=MeetingDate-date_fye

rename pay_support fpay_support
rename director_support fdirector_support
rename pay_iss fpay_iss
rename director_iss fdirector_iss

merge 1:1 iss_company_id year using "$temp\pay_support.dta", keepusing(pay_support) keep(match master) nogen
merge 1:1 iss_company_id year using "$temp\director_support.dta", keepusing(director_support) keep(match master) nogen
merge 1:1 iss_company_id year using "$temp\pay_iss.dta", keepusing(pay_iss) keep(match master) nogen
merge 1:1 iss_company_id year using "$temp\director_iss.dta", keepusing(director_iss) keep(match master) nogen

/*Keeping the shareholder voting results from the closest annual meeting after the fiscal year end*/
g pay_support1=.
replace pay_support1=fpay_support if time_lag<366 & time_lag!=. & time_lag>0
replace pay_support1=pay_support if time_lag>365 & time_lag!=. & time_lag>0

g director_support1=.
replace director_support1=fdirector_support if time_lag<366 & time_lag!=. & time_lag>0
replace director_support1=director_support if time_lag>365 & time_lag!=. & time_lag>0

g pay_iss1=.
replace pay_iss1=fpay_iss if time_lag<366 & time_lag!=. & time_lag>0
replace pay_iss1=pay_iss if time_lag>365 & time_lag!=. & time_lag>0

g director_iss1=.
replace director_iss1=fdirector_iss if time_lag<366 & time_lag!=. & time_lag>0
replace director_iss1=director_iss if time_lag>365 & time_lag!=. & time_lag>0

/*Merging in proxies for ESG Pay*/
merge 1:1 iss_company_id year using "$temp\eca_metrics_environment1.dta", keepusing(csr1) keep(match master) nogen
merge 1:1 iss_company_id year using "$temp\eca_metrics_environment6.dta", keepusing(carbon2 environment2 csr2 safety2 customer2 governance2 compliance2 culture2 people2 diversity2 other2) keep(match master) nogen 

g carbon3=0 if csr1!=.
replace carbon3=1 if carbon2==1 & csr1==1

g environment3=0 if csr1!=.
replace environment3=1 if environment2==1 & csr1==1

g safety3=0 if csr1!=.
replace safety3=1 if safety2==1 & csr1==1

g diversity3=0 if csr1!=.
replace diversity3=1 if diversity2==1 & csr1==1

g people3=0 if csr1!=.
replace people3=1 if people2==1 & csr1==1

g governance3=0 if csr1!=.
replace governance3=1 if governance2==1 & csr1==1

g culture3=0 if csr1!=.
replace culture3=1 if culture2==1 & csr1==1

g compliance3=0 if csr1!=.
replace compliance3=1 if compliance2==1 & csr1==1

g other3=0 if csr1!=.
replace other3=1 if csr1==1 & compliance3==0 & culture3==0 & governance3==0 & people3==0 & diversity3==0 & safety3==0 & environment3==0 & carbon3==0

/*Percentage of industry peers that use ESG Pay*/
bysort ff48 year: gen firm_num=_N
bysort ff48 year: egen env_kpi_num=total(csr1)
g peer=(env_kpi_num*100)/firm_num

/*Green and ESG-linked debt instruments*/
merge 1:1 iss_company_id year using "$temp\dealscan_green_esg_tomerge2.dta", keepusing(fmm_green fmm_esg_linked) keep(match master) nogen
replace fmm_green=0 if fmm_green==.
replace fmm_esg_linked=0 if fmm_esg_linked==.

merge 1:1 iss_company_id year using "$temp\fslb.dta", keepusing(fslb) keep(match master) nogen
replace fslb=0 if fslb==.

merge 1:1 iss_company_id year using "$temp\fgreen_bond.dta", keepusing(fgreen_bond) keep(match master) nogen
replace fgreen_bond=0 if fgreen_bond==.

label variable dirty4 "Non Green Industry"
label variable engagement "Engagement by Big3 t"
label variable blk_engagement "Engagement by BlackRock t"
label variable environmental_social "Engagement by StateStreet t"
label variable oversight_strategy_risk "Engagement by Vanguard t"
label variable ch "Indicator inside>50% t-1"
label variable lio_w "Institutional Ownership t-1"
label variable divers "%Female Board t-1"
label variable ind "%Independent directors t-1"
label variable lsize_w "Log(Total Assets) t-1"
label variable lroa_w "Profitability t-1"
label variable llev_w "Leverage t-1"
label variable lppe_w "Tangibility t-1"
label variable llog_bm_w "Log(Book-to-Market) t-1"
label variable ldividends_w "Dividends t-1" 
label variable lreturn_w "Return t-1" 
label variable llog_s1_w "Log(CO2) t-1"
label variable loverall_score "Overall Score t-1"
label variable total_esg_score "Sustainalitics Total Score t-1"
label variable csr1 "ESG&CSR KPI t"
label variable lvol "Stock Volatility t-1"
label variable lreg "ESG Disclosure Mandate t-1"
label variable epi "Country ESG sensitivity EPI t-1"
label variable linsideownership "%Closely-held shares t-1"
label variable lceo_comp "CEO pay t-1"
label variable lsbti "SBTi t-1"
       
label variable size_w "Log(Total Assets) t"
label variable roa_w "Profitability t"
label variable lev_w "Leverage t"
label variable ppe_w "Tangibility t"
label variable log_bm_w "Log(Book-to-Market) t"
label variable dividends_w "Dividends t" 
label variable return_w "Return t" 

save "$temp\regressions.dta", replace


/*Construction of fund-firm-year sample for regression in Table 7*/
use fund_holdings_detail_2002_2020.dta, clear

rename FACTSET_FUND_ID factset_fund_id
rename REPORT_DATE report_date
rename FSYM_ID fsym_id
rename REPORTED_HOLDING holding
rename ADJ_HOLDING adj_holding

merge m:1 fsym_id using sample_iss_eca.dta, keepusing(iss_company_id) keep(match master) nogen 
keep if iss_company_id!=.
gen year = year(report_date)

// Keep last observation for the year
bysort factset_fund_id fsym_id year: egen last_date = max(report_date)
keep if report_date==last_date

egen fund_firm=group(factset_fund_id fsym_id)

tsset fund_firm year

g lholding=l.holding
g fholding=f.holding

replace lholding=0 if lholding==. & year!=2009

expand 2 if fholding==. & year!=2022, gen(id)
replace year=year+1 if id==1
replace holding=0 if id==1
replace adj_holding=0 if id==1

drop lholding
tsset fund_firm year
g lholding=l.holding
g lholdinga=l.adj_holding

g sc_holding=(holding-lholding)/lholding
g sc_holdinga=(adj_holding-lholdinga)/lholdinga

replace sc_holding=1 if lholding==. & year!=2009
replace sc_holdinga=1 if lholdinga==. & year!=2009 
drop if year==2009

replace sc_holding=1 if lholding==0 & year!=2009
replace sc_holdinga=1 if lholdinga==0 & year!=2009

ssc install winsor2
winsor2 sc_holding sc_holdinga, cut(1 99)

merge m:1 iss_company_id year using regressions_eca4.dta, keepusing(csr1 carbon3 environment3 safety3 governance3 compliance3 culture3 people3 diversity3 other3 lsize_w llog_bm_w lroa_w llev_w lppe_w ldividends_w lreturn_w control firm_id isin) keep(match master) nogen 

merge m:1 isin year using regressions4.dta, keepusing(disclosure1) keep(match master) nogen

egen fund_year_id=group(factset_fund_id year)

save fund_firm_year10.dta, replace


clear all
import excel "$inputs\esg\companies-taking-action.xlsx", sheet("Worksheet") firstrow cellrange(A1:T2140) allstring

replace Date=BA15Date if Date==""

g year=substr(Date,7,4)

g year1=substr(BA15Date,7,4)

destring year, replace

keep CompanyName ISIN year Country OrganizationType

rename ISIN isin
rename year year_joined

drop if year_joined==2021

merge 1:1 CompanyName using "$inputs\isin\sbti_isin.dta", keepusing(isin1) keep(match master) nogen

replace isin=isin1 if isin=="" & isin1!=""

drop if isin==""
save "$temp\sbti.dta", replace


clear all
import excel "$temp\slb_iss_code.xlsx", sheet("Sheet3") firstrow cellrange(A1:E113) allstring

keep if match=="1"
keep IssuerName iss_company_id
destring iss_company_id, replace

save "$temp\slb_iss_company_id.dta", replace

/*Reading from raw file the actual sustainability linked bonds data*/

clear all
import excel "$inputs\green_bonds\Bloomberg SLB Screening.xlsx", sheet("Hardcopy_1") firstrow cellrange(A1:T449) allstring

merge m:1 IssuerName using "$temp\slb_iss_company_id.dta", keepusing(iss_company_id) keep(match master) nogen

keep if iss_company_id!=.

split IssueDate, p(/)

rename IssueDate3 year

duplicates drop iss_company_id year, force
keep iss_company_id year

g slb=1
destring year, replace
save "$temp\slb.dta", replace

g year1=year-1

drop year
rename year1 year
rename slb fslb
save "$temp\fslb.dta", replace


use "$inputs\esg\sustainlitics_weighted_score.dta", clear

drop if isin==""
duplicates drop company, force
keep company isin
rename isin isin1
save "$temp\company_isin.dta", replace

use "$inputs\esg\sustainlitics_weighted_score.dta", clear

merge m:1 company using "$temp\company_isin.dta", keepusing(isin1) keep(match master) nogen 

replace isin=isin1 if isin=="" & isin1!=""

g year=year(date)
drop if isin==""
drop if isin=="NA"
drop if isin=="No data"

// Keep last observation for the year
bysort isin year: egen last_date = max(date)
keep if date==last_date

g month=month(date)

duplicates tag isin year, g(dup)

drop if dup==1 & ticker=="" & country=="South Korea"
drop if dup==1 & ticker=="" & country=="Mexico"

keep isin total_esg_score governance_score social_score environment_score g_2_7_1 g_2_8_1 g_2_9_1 year

rename total_esg_score total_esg_score_t

save "$temp\sustainalitics_score_t.dta", replace

g year1=year+1

drop year
rename year1 year
rename total_esg_score_t total_esg_score 
save "$temp\sustainalitics_score.dta", replace












clear all
set excelxlsxlargefile on
import excel "$inputs\esg\sustainalytics\HD_ESG Ratings_20220202_P1.xlsx", sheet(Data) firstrow cellrange(A1:AG339989) allstring

rename TotalESGScore total_esg_score
destring total_esg_score, replace 

rename ISIN isin

save "$temp\sustainalytics_p1.dta", replace

clear all
set excelxlsxlargefile on
import excel "$inputs\esg\sustainalytics\HD_ESG Ratings_20220202_P2.xlsx", sheet(Data) firstrow cellrange(A1:AG346226) allstring

rename TotalESGScore total_esg_score
destring total_esg_score, replace 

rename ISIN isin

save "$temp\sustainalytics_p2.dta", replace

clear all
set excelxlsxlargefile on
import excel "$inputs\esg\sustainalytics\HD_ESG Ratings_20220202_P3.xlsx", sheet(Data) firstrow cellrange(A1:AG173511) allstring

rename TotalESGScore total_esg_score
destring total_esg_score, replace 

rename ISIN isin

append using "$temp\sustainalytics_p2.dta" 
append using "$temp\sustainalytics_p1.dta"

save "$temp\sustainalytics_all.dta", replace

use "$temp\sustainalytics_all.dta", clear

drop if isin==""
duplicates drop EntityId, force
keep EntityId isin
rename isin isin1
save "$temp\company_isin1.dta", replace

clear all
set excelxlsxlargefile on
import excel "$inputs\esg\sustainalytics\Sustainalytics_additonal_isins.xlsx", sheet(Sheet3) firstrow cellrange(A1:E3156) allstring

keep if match=="1"
keep EntityId isin
rename isin isin2
save "$temp\company_isin2.dta", replace

use "$temp\sustainalytics_all.dta", clear

merge m:1 EntityId using "$temp\company_isin1.dta", keepusing(isin1) keep(match master) nogen 
replace isin=isin1 if isin=="" & isin1!=""
replace isin=isin1 if isin=="NA" & isin1!=""
/*(15,406 real changes made) - very little, still 250K missing isin observations*/

merge m:1 EntityId using "$temp\company_isin2.dta", keepusing(isin2) keep(match master) nogen 
replace isin=isin2 if isin=="" & isin2!=""
replace isin=isin2 if isin=="NA" & isin2!=""
/*(224,480 real changes made) - very good, only 34K observations remain without isin*/

split ExtractionDate, g(date) p(/) l(3)

rename date1 month
rename date3 year
destring month, replace
destring year, replace

drop if isin==""
drop if isin=="NA"
drop if total_esg_score==.

// Keep last observation for the year
bysort isin year: egen max_m=max(month)
keep if max_m==month
duplicates drop isin year, force

egen firm_id=group(isin)
tsset firm_id year

g ch_sustain_new=total_esg_score-l.total_esg_score

save "$temp\ch_sustain_new.dta", replace

g year1=year+1

drop year
rename year1 year
rename total_esg_score total_esg_score_new

save "$temp\sustainalitics_score_new.dta", replace



clear all
set excelxlsxlargefile on
import delimited "$inputs\trucost\IESE_Env_CPUCU_AllYr_20220827.csv"

keep tcuid company isin financialyear country carbonscope1tonnesco2e carbonscope2tonnesco2e carbonscope3tonnesco2e carbondisclosure accountingyearend figurerestate effectivedate

rename financialyear year
rename carbonscope1tonnesco2e scope1
rename carbonscope2tonnesco2e scope2
rename carbonscope3tonnesco2e scope3

rename company name

merge m:1 name using "$temp\trucost_isins_add.dta", keepusing(isin2) keep(match master) nogen 
replace isin=isin2 if isin=="null" & isin2!=""

merge m:1 name using "$temp\trucost_isins_add1.dta", keepusing(isin3) keep(match master) nogen 
replace isin=isin3 if isin=="null" & isin3!=""

drop if isin=="null"

g log_s1=log(scope1)

duplicates drop isin year, force

save "$temp\trucost_2022_new.dta", replace

use "$temp\trucost_list.dta", clear 
expand 16, generate(number)
bysort isin: gen count=_n
generate year=count+2004
drop count number 

merge 1:1 isin year using "$temp\trucost_2022_new.dta", keepusing(scope*) keep(match master) nogen

g log_s1=log(scope1)
g log_s2=log(scope2)
g log_s3=log(scope3)
g log_s1s3=log(scope1+scope2+scope3)

egen firm_id=group(isin)
tsset firm_id year

g ch_s1_new=scope1-l.scope1

save "$temp\f_carbon_2022.dta", replace


use "$temp\trucost_2021.dta", clear

duplicates drop isin, force

keep isin

save "$temp\trucost_list.dta", replace

use "$temp\trucost_list.dta", clear 
expand 16, generate(number)
bysort isin: gen count=_n
generate year=count+2004
drop count number 

merge 1:1 isin year using "$temp\trucost_2021.dta", keepusing(scope*) keep(match master) nogen

g log_s1=log(scope1)
g log_s2=log(scope2)
g log_s3=log(scope3)
g log_s1s3=log(scope1+scope2+scope3)

egen firm_id=group(isin)
tsset firm_id year

g f_s1=f.log_s1
g f_s2=f.log_s2
g f_s3=f.log_s3
g f_s1s3=f.log_s1s3

g f2_s1=f2.log_s1
g f2_s2=f2.log_s2
g f2_s3=f2.log_s3
g f2_s1s3=f2.log_s1s3

g f3_s1=f3.log_s1
g f3_s2=f3.log_s2
g f3_s3=f3.log_s3
g f3_s1s3=f3.log_s1s3

g f4_s1=f4.log_s1
g f4_s2=f4.log_s2
g f4_s3=f4.log_s3
g f4_s1s3=f4.log_s1s3

g ch_s1=scope1-l.scope1
g ch2_s1=f2.scope1-l.scope1
g ch3_s1=f3.scope1-l.scope1
g ch4_s1=f4.scope1-l.scope1

g sch_s1=(scope1-l.scope1)/l.scope1
g sch2_s1=(f2.scope1-l.scope1)/l.scope1
g sch3_s1=(f3.scope1-l.scope1)/l.scope1
g sch4_s1=(f4.scope1-l.scope1)/l.scope1

save "$temp\f_carbon.dta", replace













clear all
set excelxlsxlargefile on
import delimited "$inputs\trucost\IESE_Env_CPUCU_AllYr_20211024.csv"

keep tcuid company isin financialyear country carbonscope1tonnesco2e carbonscope2tonnesco2e carbonscope3tonnesco2e carbondisclosure accountingyearend figurerestate effectivedate

rename financialyear year
rename carbonscope1tonnesco2e scope1
rename carbonscope2tonnesco2e scope2
rename carbonscope3tonnesco2e scope3

drop if isin=="null"

g log_s1=log(scope1)

g year1=year+1
drop year
rename year1 year
rename log_s1 llog_s1

save "$temp\ltrucost_2021.dta", replace

**********************************
* Master code
**********************************

capture cd "C:\Users\ikadach\Dropbox (IESE)\Incentive Lab Data\Production"

global inputs "inputs"
global temp "temp"
global code "code"
global output "output"

// Do files here

do "$code/Prepare Data - ESG Pay - csr1.do"

do "$code/Prepare Data - ESG Pay - components.do"

do "$code/Prepare Data - Datastream ECA.do"

do "$code/Prepare Data - Controls ECA.do"

do "$code/Prepare Data - CEO compensation.do"

do "$code/Prepare Data - Engagements StateStreet 2019-2020.do"

do "$code/Prepare Data - EPI.do"

do "$code/Prepare Data - ESG Scores Refinitiv.do"

do "$code/Prepare Data - KLD.do"

do "$code/Prepare Data - Institutional ownership.do"

do "$code/Prepare Data - Trucost future co2.do"

do "$code/Prepare Data - Trucost lagged co2.do"

do "$code/Prepare Data - Trucost future co2 update.do"

do "$code/Prepare Data - Sustainalitics scores new.do"

do "$code/Prepare Data - Sustainalitics score.do"

do "$code/Prepare Data - SBTi.do"

do "$code/Prepare Data - SLB.do"

do "$code/Prepare Data - Green bonds.do"

do "$code/Prepare Data - Dealscan.do"

do "$code/Prepare Data - pay support.do"

do "$code/Prepare Data - Pay ISS recommendation.do"

do "$code/Prepare Data - Director support.do"

do "$code/Prepare Data - Director ISS recommendation.do"

do "$code/Prepare Data - Forwarding voting data.do"

do "$code/Prepare Data - FYE and MeetingDate.do"

do "$code/Prepare Data - Regressions File firm-year.do"


do "$code/Prepare Data - Regressions File fund-firm-year"



