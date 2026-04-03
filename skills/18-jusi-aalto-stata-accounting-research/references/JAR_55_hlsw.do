
****************************************************************************************************
*
* CFO Narcissism and Financial Reporting Quality
*
* Charles Ham, Mark Lang, Nicholas Seybert, Sean Wang
*
****************************************************************************************************


****************************************************************************************************
* Match executives with hand collected signatures to Execucomp
****************************************************************************************************


*create stata file from hand collected master file of executive signatures
insheet using "Signatures_Master_DL.csv", comma names clear
foreach i in "firmname" "title" "filename" "execname" "signedname" {
replace `i'=lower(`i')
}
*drop firm without the files provided
drop if firmnumber==64
save "Signatures_Master_DL.dta", replace

*create permno-gvkey links from crsp compustat merged linking table
use "CCM_Link_DL.dta", clear
keep if linkprim=="P" | linkprim=="C"
keep gvkey lpermno conm conml linkdt linkenddt
rename lpermno permno
destring gvkey, replace
duplicates drop gvkey permno, force
save "CCM_Link1.dta", replace

*create list of executive names from execucomp with gvkey and firm name
use "Execucomp_DL.dta", clear
keep gvkey exec_fullname coname co_per_rol execid
destring gvkey execid, replace
replace coname=lower(coname)
replace exec_fullname=lower(exec_fullname)
duplicates drop gvkey execid, force
sort gvkey exec_fullname
gen execucompid=_n
rename exec_fullname execname
*clean some education information from the names
foreach i in ", be (electrical eng)" ", o.c., ll. d." ", b.sc. (business administration), c" ", b.sc., m.b.a., c.p.a." ", b.a., m.b.a., c.m.a." ", esq., j.d." ", j.d., esq." ", cpa, pfs" ", mba finance" ", cpa" ", cfa" ", cma" ", ph.d." ", j.d." ", esq." ", m.d." ", j.b." {
replace execname=subinstr(execname,"`i'","",.)
}
save "Execucomp_Executive_Names.dta", replace

*create file of all executive-firm-years from execucomp
use "Execucomp_DL.dta", clear
destring gvkey execid co_per_rol, replace
rename year fyear
save "Execucomp_Executive_Firm_Years.dta", replace

*clean some firm names from crsp
use "CRSP_DL.dta", clear
keep permno comnam ticker
rename comnam firmname
replace firmname=lower(firmname)
replace firmname=subinstr(firmname,"international","intl",.)
replace firmname=subinstr(firmname,"incorporated","inc",.)
replace firmname=subinstr(firmname,"corporation","corp",.)
replace firmname=subinstr(firmname,"company","co",.)
replace firmname=subinstr(firmname," limited"," ltd",.)
replace firmname=subinstr(firmname," l p"," lp",.)
replace firmname=subinstr(firmname,"and","&",.)
replace firmname=subinstr(firmname,"u s a ","usa ",.)
replace firmname=subinstr(firmname," u s a"," usa",.)
replace firmname=subinstr(firmname,"u s ","us ",.)
replace firmname=subinstr(firmname," u s"," us",.)
replace firmname=subinstr(firmname," new","",.)
replace firmname=subinstr(firmname,"the ","",.)
replace firmname=subinstr(firmname,"-"," ",.)
replace firmname=subinstr(firmname,"  "," ",.)
duplicates drop firmname permno, force
sort firmname permno
gen crspid=_n
save "CRSP_Firm_Names.dta", replace

*clean some hand collected firm names
insheet using "Signatures_Master_DL.csv", clear
keep firmnumber firmname
replace firmname=lower(firmname)
replace firmname=subinstr(firmname,"'","",.)
replace firmname=subinstr(firmname,"*","",.)
replace firmname=subinstr(firmname,",","",.)
replace firmname=subinstr(firmname,".","",.)
replace firmname=subinstr(firmname,"/","",.)
replace firmname=subinstr(firmname,"international","intl",.)
replace firmname=subinstr(firmname,"incorporated","inc",.)
replace firmname=subinstr(firmname,"corporation","corp",.)
replace firmname=subinstr(firmname,"company","co",.)
replace firmname=subinstr(firmname," l p"," lp",.)
replace firmname=subinstr(firmname," limited"," ltd",.)
replace firmname=subinstr(firmname,"and","&",.)
replace firmname=subinstr(firmname,"u s a ","usa ",.)
replace firmname=subinstr(firmname," u s a"," usa",.)
replace firmname=subinstr(firmname,"u s ","us ",.)
replace firmname=subinstr(firmname," u s"," us",.)
replace firmname=subinstr(firmname," new","",.)
replace firmname=subinstr(firmname,"the ","",.)
replace firmname=subinstr(firmname,"-"," ",.)
replace firmname=subinstr(firmname,"  "," ",.)
duplicates drop firmname, force
save "Signatures_Firm_Names.dta", replace

*fuzzy merge hand collected names with crsp names
use "Signatures_Firm_Names.dta", clear
reclink firmname using "CRSP_Firm_Names.dta", idm(firmnumber) idu(crspid) gen(matchscore) minscore(0.5)
save "Signatures_Firm_Names_Merged1.dta", replace

*create file of poor fuzzy firm matches, then hand check
use "Signatures_Firm_Names_Merged1.dta", clear
keep if matchscore<=0.99
outsheet using "Signatures_Firm_Names_Merged2.csv", comma names replace

*create file of good fuzzy firm matches, then hand check
use "Signatures_Firm_Names_Merged1.dta", clear
keep if matchscore>0.99
outsheet using "Signatures_Firm_Names_Merged3.csv", comma names replace

*create file of correct firm matches from the poor fuzzy firm matches and firms that had a high fuzzy match score but were incorrect matches (done by hand)
insheet using "Signatures_Firm_Names_Merged4.csv", comma names clear
drop if permno=="private"
destring permno, replace
save "Signatures_Firm_Names_Merged4.dta", replace

*create file of all firm matches
*start with good fuzzy match firms
use "Signatures_Firm_Names_Merged1.dta", clear
keep if matchscore>0.99
*drop firms that had a high fuzzy match score but were incorrect matches
foreach i in "81" "111" "276" "354" "446" "689" "929" {
drop if firmnumber==`i'
}
*append the hand collected firm matches that the fuzzy match didn't work for
append using "Signatures_Firm_Names_Merged4.dta"
keep firmnumber firmname permno
save "Signatures_Firm_Names_Merged5.dta", replace

*merge in the gvkeys from the permno-gvkey link created above
use "Signatures_Firm_Names_Merged5.dta", clear
joinby permno using "CCM_Link1.dta", unmatched(master)
drop _merge
*the permno merge picked up an incorrect gvkey for a few firms. updated them here after hand-checking the merge results. these were mostly from old permno-gvkey links.
replace gvkey=4199 if firmnumber==289
replace gvkey=178849 if firmnumber==712
replace gvkey=7086 if firmnumber==546
replace gvkey=120877 if firmnumber==702
replace gvkey=9692 if firmnumber==756
replace gvkey=20993 if firmnumber==882
replace gvkey=4739 if firmnumber==897
replace gvkey=14477 if firmnumber==905
drop if missing(gvkey)
*the permno merge picked up multiple gvkeys for some firms. dropped the incorrect gvkeys here (hand-checked).
drop if firmnumber==364 & gvkey!=5073
drop if firmnumber==116 & gvkey!=11856
drop if firmnumber==158 & gvkey!=12485
drop if firmnumber==193 & gvkey!=3054
drop if firmnumber==196 & gvkey!=3078
drop if firmnumber==277 & gvkey!=3897
drop if firmnumber==280 & gvkey!=4094
drop if firmnumber==340 & gvkey!=4818
drop if firmnumber==370 & gvkey!=12233
drop if firmnumber==372 & gvkey!=5134
drop if firmnumber==394 & gvkey!=12788
drop if firmnumber==403 & gvkey!=29710
drop if firmnumber==411 & gvkey!=179657
drop if firmnumber==424 & gvkey!=27914
drop if firmnumber==440 & gvkey!=6140
drop if firmnumber==447 & gvkey!=14446
drop if firmnumber==499 & gvkey!=6781
drop if firmnumber==514 & gvkey!=7017
drop if firmnumber==523 & gvkey!=141400
drop if firmnumber==535 & gvkey!=7171
drop if firmnumber==550 & gvkey!=24379
drop if firmnumber==597 & gvkey!=24361
drop if firmnumber==656 & gvkey!=179621
drop if firmnumber==665 & gvkey!=28591
drop if firmnumber==667 & gvkey!=8245
drop if firmnumber==672 & gvkey!=2002
drop if firmnumber==697 & gvkey!=8867
drop if firmnumber==728 & gvkey!=5968
drop if firmnumber==756 & gvkey!=9692
drop if firmnumber==781 & gvkey!=9380
drop if firmnumber==798 & gvkey!=28543
drop if firmnumber==846 & gvkey!=10301
drop if firmnumber==887 & gvkey!=165675
drop if firmnumber==888 & gvkey!=160785
drop if firmnumber==901 & gvkey!=3980
drop if firmnumber==907 & gvkey!=4367
drop if firmnumber==76 & gvkey!=25056
drop if firmnumber==778 & gvkey!=10984
drop if firmnumber==779 & gvkey!=5087
duplicates drop firmnumber gvkey, force
sort firmnumber gvkey
save "Signatures_Firm_Names_Merged6.dta", replace

*begin with the firm names. merge in the executive information from the master signature file. then fuzzy match executive names to execucomp
use "Signatures_Firm_Names_Merged6.dta", clear
joinby firmnumber using "Signatures_Master_DL.dta", unmatched(master)
drop _merge
*fuzzy match by gvkey-execname combo to the execucomp file with all gvkey-execname combos
gen newid=_n
reclink gvkey execname using "Execucomp_Executive_Names.dta", idm(newid) idu(execucompid) gen(matchscore) minscore(0.59) required(gvkey)
drop if _merge==1
drop _merge
*hand-check all non-exact matches and drop the incorrect matches
drop if execnum==506 & co_per_rol==22762
drop if execnum==849 & co_per_rol==6076
drop if execnum==472 & co_per_rol==19632
drop if execnum==1861 & co_per_rol==2630
drop if execnum==275 & co_per_rol==38082
drop if execnum==1095 & co_per_rol==17586
drop if execnum==825 & co_per_rol==46614
drop if execnum==1486 & co_per_rol==47903
drop if execnum==1338 & co_per_rol==48451
drop if execnum==71 & co_per_rol==48322
drop if execnum==221 & co_per_rol==15349
drop if execnum==1704 & co_per_rol==3149
drop if execnum==1328 & co_per_rol==2622
drop if execnum==1747 & co_per_rol==39683
drop if execnum==307 & co_per_rol==29853
drop if execnum==1212 & co_per_rol==28967
drop if execnum==1213 & co_per_rol==45067
save "Signatures_Firm_Names_Merged7.dta", replace

*try to manually match the executives that weren't matched by joining all executive names in execucomp for the corresponding firm
use "Signatures_Firm_Names_Merged6.dta", clear
joinby firmnumber using "Signatures_Master_DL.dta", unmatched(master)
drop _merge
merge m:1 execnum using "Signatures_Firm_Names_Merged7.dta", keep(master) nogen
joinby gvkey using "Execucomp_Executive_Names.dta", unmatched(master)
*hand-checked all of the possible matches and no additional matches were identified

*create master file now with gvkey, co_per_rol, & execid
use "Signatures_Firm_Names_Merged7.dta", clear
merge 1:1 execnum using "Signatures_Master_DL.dta", keep(master match) nogen
save "Signatures_Firm_Names_Merged_Final.dta", replace

*expand the file to include the years each executive was in execucomp at the respective firm
use "Signatures_Firm_Names_Merged_Final.dta", clear
joinby co_per_rol using "Execucomp_Executive_Firm_Years.dta", unmatched(master)
foreach i of varlist coname exec_fullname titleann ceoann cfoann {
replace `i'=lower(`i')
}
*drop duplicate year
drop if co_per_rol==27754 & (fyear==2003 | fyear==2004)
*retain only years in office as cfo/ceo
gen iscfo=1 if title=="cfo" & (strpos(cfoann,"cfo")>0 | strpos(titleann,"financial officer")>0 | strpos(titleann,"finance officer")>0 | strpos(titleann,"fnl offr")>0 | strpos(titleann,"chief finance")>0 | strpos(titleann,"finl offr")>0 | strpos(titleann,"exec. fin. offr.")>0 | strpos(titleann,"cfo")>0 | strpos(titleann,"v-p-fin. &")>0 | strpos(titleann,"financ")>0)
gen isceo=1 if title=="ceo" & (strpos(ceoann,"ceo")>0 | strpos(titleann,"chief executive")>0 | strpos(titleann,"executive officer")>0 | strpos(titleann,"ceo")>0)
drop if title=="cfo" & missing(iscfo)
drop if title=="ceo" & missing(isceo)
gen cfo=title=="cfo"
gen ceo=title=="ceo"
save "Signatures_Master_Sample.dta", replace


****************************************************************************************************
* Calculate variables and estimate results
****************************************************************************************************


*create compustat variables
use "compustat.dta", clear
destring gvkey sic, replace
ffind sic, newvar(ff49) type(49)
bysort gvkey fyear: keep if _n == 1
sort gvkey fyear
xtset gvkey fyear
replace xrd = 0 if xrd == . & xsga != .
replace xad = 0 if xad == . & xsga != .
gen meancfo = (l1.oancf + l2.oancf + l3.oancf + l4.oancf + l5.oancf)/5
gen cfovolatility = (((l1.oancf-meancfo)^2 + (l2.oancf-meancfo)^2 + (l3.oancf-meancfo)^2 + (l4.oancf-meancfo)^2 + (l5.oancf-meancfo)^2)/5)^.5
gen meanrevt = (l1.revt + l2.revt + l3.revt + l4.revt + l5.revt)/5
gen salesvolatility = (((l1.revt-meanrevt)^2 + (l2.revt-meanrevt)^2 + (l3.revt-meanrevt)^2 + (l4.revt-meanrevt)^2 + (l5.revt-meanrevt)^2)/5)^.5
gen percchgcashsales = ((revt-rect)-(l1.revt-l1.rect))/(l1.revt-l1.rect)
gen l4loss = l4.ni < 0
gen l3loss = l3.ni < 0
gen l2loss = l2.ni < 0
gen l1loss = l1.ni < 0
gen percloss = (l4loss + l3loss + l2loss + l1loss)/4
gen earningsprice = ni/(prcc_f*csho)
gen chgroa = (ni/(at+l1.at))-(l1.ni/(l1.at+l2.at))
gen chginv = (invt-l1.invt)/(at+l1.at)
gen chgrec = (rect-l1.rect)/(at+l1.at)
gen l1at=l1.at
gen at_avg=[at+l1at]/2
gen ocf_a1=oancf/l1at
gen prod_a1=[cogs+invt-l1.invt]/l1at
gen disexp_a1=[xrd+xad+xsga]/l1at
gen a_inv=1/l1at
gen s_a1=sale/l1at
gen s_chg=sale-l1.sale
gen s_chg_a1=s_chg/l1at
gen l1s_chg_a1=l1.s_chg/l1at
gen l1s_a1=l1.sale/l1at
gen tacc_a1=[ibc-oancf]/l1at
gen revt_rect_a1=[[revt-l1.revt]-[rect-l1.rect]]/l1at
gen ppegt_a1=ppegt/l1at
gen wc_chg_a1=[[act-l1.act]-[lct-l1.lct]-[che-l1.che]+[dlc-l1.dlc]]/at_avg
gen cffo_a1=[ib-[[act-l1.act]-[lct-l1.lct]-[che-l1.che]+[dlc-l1.dlc]-[dp]]]/l1at
gen l1cffo_a1=l1.cffo_a1
gen f1cffo_a1=f1.cffo_a1
gen roa=ibc/l1at
gen l1roa=l1.roa
gen roa_chg=roa-l1roa
sort sic
save "compustat2.dta", replace

*calculate abnormal operating cash flows
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear ocf_a1 a_inv s_a1 s_chg_a1 ff49
keep if !missing(ocf_a1, a_inv, s_a1, s_chg_a1)
foreach i of varlist ocf_a1 a_inv s_a1 s_chg_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen ocf_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg ocf_a1 a_inv s_a1 s_chg_a1 if newid2==`i'
	capture predict ocf_a1_err_temp, residuals
	capture replace ocf_a1_err=ocf_a1_err_temp if newid2==`i' & missing(ocf_a1_err) & !missing(ocf_a1_err_temp)
	capture drop ocf_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 ocf_a1_err
save "compustatff49_a1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_a1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_a1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear ocf_a1_err
sort gvkey fyear
save "compustatff49_a1_11.dta", replace

*calculate abnormal production costs
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear prod_a1 a_inv s_a1 s_chg_a1 l1s_chg_a1 ff49    
qui keep if !missing(prod_a1, a_inv, s_a1, s_chg_a1, l1s_chg_a1)
foreach i of varlist prod_a1 a_inv s_a1 s_chg_a1 l1s_chg_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen prod_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg prod_a1 a_inv s_a1 s_chg_a1 l1s_chg_a1 if newid2==`i'
	capture predict prod_a1_err_temp, residuals
	capture replace prod_a1_err=prod_a1_err_temp if newid2==`i' & missing(prod_a1_err) & !missing(prod_a1_err_temp)
	capture drop prod_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 prod_a1_err
save "compustatff49_b1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_b1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_b1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear prod_a1_err
sort gvkey fyear
save "compustatff49_b1_11.dta", replace

*calculate abnormal discretionary expenses
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear disexp_a1 a_inv l1s_a1 ff49    
qui keep if !missing(disexp_a1, a_inv, l1s_a1)
foreach i of varlist disexp_a1 a_inv l1s_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen disexp_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg disexp_a1 a_inv l1s_a1 if newid2==`i'
	capture predict disexp_a1_err_temp, residuals
	capture replace disexp_a1_err=disexp_a1_err_temp if newid2==`i' & missing(disexp_a1_err) & !missing(disexp_a1_err_temp)
	capture drop disexp_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 disexp_a1_err
save "compustatff49_c1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_c1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_c1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear disexp_a1_err
sort gvkey fyear
save "compustatff49_c1_11.dta", replace

*calculate discretionary accruals
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear tacc_a1 a_inv revt_rect_a1 l1roa ppegt_a1 ff49    
qui keep if !missing(tacc_a1, a_inv, revt_rect_a1, ppegt_a1, l1roa)
foreach i of varlist tacc_a1 a_inv revt_rect_a1 l1roa ppegt_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen tacc_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg tacc_a1 a_inv revt_rect_a1 ppegt_a1 l1roa if newid2==`i'
	capture predict tacc_a1_err_temp, residuals
	capture replace tacc_a1_err=tacc_a1_err_temp if newid2==`i' & missing(tacc_a1_err) & !missing(tacc_a1_err_temp)
	capture drop tacc_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 tacc_a1_err
save "compustatff49_d1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_d1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_d1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear tacc_a1_err
sort gvkey fyear
save "compustatff49_d1_11.dta", replace

*calculate abnormal working capital accruals
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear wc_chg_a1 l1cffo_a1 cffo_a1 f1cffo_a1 s_chg_a1 ppegt_a1 ff49    
qui keep if !missing(wc_chg_a1, l1cffo_a1, cffo_a1, f1cffo_a1, s_chg_a1, ppegt_a1)
foreach i of varlist wc_chg_a1 l1cffo_a1 cffo_a1 f1cffo_a1 s_chg_a1 ppegt_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49     newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen wc_chg_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg wc_chg_a1 l1cffo_a1 cffo_a1 f1cffo_a1 s_chg_a1 ppegt_a1 if newid2==`i'
	capture predict wc_chg_a1_err_temp, residuals
	capture replace wc_chg_a1_err=wc_chg_a1_err_temp if newid2==`i' & missing(wc_chg_a1_err) & !missing(wc_chg_a1_err_temp)
	capture drop wc_chg_a1_pred_temp
	capture drop wc_chg_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 wc_chg_a1_err
save "compustatff49_e1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_e1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_e1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear wc_chg_a1_err
sort gvkey fyear
save "compustatff49_e1_11.dta", replace

*merge earnings management proxies
use "compustat2.dta", clear
merge 1:1 gvkey fyear using "compustatff49_a1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_b1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_c1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_d1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_e1_11.dta", keep(master match) nogen
sort gvkey fyear
save "compustatEM.dta", replace

*CRSP Merge
use "crsp.dta", clear
sort permno date
save "crsp.dta", replace

use "crsppermnolink.dta", clear
sort permno
by permno: keep if _n==1
save "crsppermnolink.dta", replace

merge 1:m permno using "crsp.dta", keep(master match) nogen
destring gvkey, replace
gen year = year(date)
sort gvkey year
bysort gvkey: keep if _n == 1
gen firstyear = year
drop year date
save "crspfirstyear.dta", replace

use "compustatEM.dta", clear
merge m:1 gvkey using "crspfirstyear.dta", keep(master match) nogen
gen firmage = fyear - firstyear
replace firmage = _n if firmage < 1
destring cik, replace
bysort cik fyear: keep if _n==1
save "compustatEM2.dta", replace

*Audit Analytics Merge
use "internalcontrols.dta", clear
bysort cik fyear: keep if _n == 1
save "internalcontrols.dta", replace

use "auditfees.dta", clear
bysort cik fyear: keep if _n == 1
save "auditfees.dta", replace

use "compustatEM2.dta", clear
merge 1:1 cik fyear using "internalcontrols.dta", keep(master match) nogen
merge 1:1 cik fyear using "auditfees.dta", keep(master match) nogen
save "compustatauditfees.dta", replace

*Restatements and Controls
use "restatements.dta", clear
sort cik
gen yearbegin = year(restatebegin)
gen yearend = year(restateend)
by cik: gen yearbegin1 = year(restatebegin[_n+1]) if !missing(restatebegin[_n+1])
by cik: gen yearend1 = year(restateend[_n+1]) if !missing(restateend[_n+1])
by cik: gen yearbegin2 = year(restatebegin[_n+2]) if !missing(restatebegin[_n+2])
by cik: gen yearend2 = year(restateend[_n+2]) if !missing(restateend[_n+2])
by cik: gen yearbegin3 = year(restatebegin[_n+3]) if !missing(restatebegin[_n+3])
by cik: gen yearend3 = year(restateend[_n+3]) if !missing(restateend[_n+3])
by cik: gen yearbegin4 = year(restatebegin[_n+4]) if !missing(restatebegin[_n+4])
by cik: gen yearend4 = year(restateend[_n+4]) if !missing(restateend[_n+4])
by cik: gen yearbegin5 = year(restatebegin[_n+5]) if !missing(restatebegin[_n+5])
by cik: gen yearend5 = year(restateend[_n+5]) if !missing(restateend[_n+5])
by cik: gen yearbegin6 = year(restatebegin[_n+6]) if !missing(restatebegin[_n+6])
by cik: gen yearend6 = year(restateend[_n+6]) if !missing(restateend[_n+6])
by cik: gen yearbegin7 = year(restatebegin[_n+7]) if !missing(restatebegin[_n+7])
by cik: gen yearend7 = year(restateend[_n+7]) if !missing(restateend[_n+7])
by cik: gen yearbegin8 = year(restatebegin[_n+8]) if !missing(restatebegin[_n+8])
by cik: gen yearend8 = year(restateend[_n+8]) if !missing(restateend[_n+8])
by cik: gen yearbegin9 = year(restatebegin[_n+9]) if !missing(restatebegin[_n+9])
by cik: gen yearend9 = year(restateend[_n+9]) if !missing(restateend[_n+9])
by cik: gen yearbegin10 = year(restatebegin[_n+10]) if !missing(restatebegin[_n+10])
by cik: gen yearend10 = year(restateend[_n+10]) if !missing(restateend[_n+10])
by cik: keep if _n==1
save "restatements2.dta", replace

use "compustatauditfees.dta", clear
merge m:1 cik using "restatements2.dta", keep(master match) nogen
gen restatement = 0
replace restatement = 1 if fyear >= yearbegin & fyear <= yearend
replace restatement = 1 if fyear >= yearbegin1 & fyear <= yearend1
replace restatement = 1 if fyear >= yearbegin2 & fyear <= yearend2
replace restatement = 1 if fyear >= yearbegin3 & fyear <= yearend3
replace restatement = 1 if fyear >= yearbegin4 & fyear <= yearend4
replace restatement = 1 if fyear >= yearbegin5 & fyear <= yearend5
replace restatement = 1 if fyear >= yearbegin6 & fyear <= yearend6
replace restatement = 1 if fyear >= yearbegin7 & fyear <= yearend7
replace restatement = 1 if fyear >= yearbegin8 & fyear <= yearend8
replace restatement = 1 if fyear >= yearbegin9 & fyear <= yearend9
replace restatement = 1 if fyear >= yearbegin10 & fyear <= yearend10
gen effcontrols = 1
replace effcontrols = 0 if controlseffective == "No"
replace effcontrols = . if fyear < 2004
replace effcontrols = . if auditfees == .
replace numweakness = 0 if numweakness == .
replace numweakness = . if fyear < 2004
replace numweakness = . if auditfees == .
gen leverage = (dltt+dlc)/ceq
gen salesgrowth = (revt-revt[_n-3])/revt[_n-3]
gen btm = ceq/(csho*prcc_f)
gen size = ln(at)
drop yearbegin* yearend*
save "compustatrestatements.dta", replace

*Signatures and Characteristics Processing
use "Signatures_Master_Sample.dta", clear
drop firmnumber firmname titleann
drop if ceo != 1 & cfo != 1
gen apl = area/length(signedname)
sort gvkey execid fyear
save "signatures2.dta", replace

use "execucomp.dta", clear
destring gvkey execid, replace
rename year fyear
save "execucomp.dta", replace

use "signatures2.dta", clear
merge 1:1 gvkey execid fyear using "execucomp.dta", keep(master match) nogen
drop if apl == .
sort gvkey execid fyear
by gvkey execid fyear: keep if _n == 1
gen female = gender == "FEMALE"
by gvkey execid: gen tenure = _n
keep if legible > 0
sort gvkey execid fyear
save "signatures3.dta", replace

*Import Delta/Vega Data From Coles, Daniel, and Naveen (2006)
insheet using "deltavega.csv", clear
rename year fyear
rename coperol co_per_rol
merge 1:1 gvkey co_per_rol fyear using "execucomp.dta", keep(master match) keepusing(tdc1 execid) nogen
replace delta=delta/tdc1
replace vega=vega/tdc1
bysort gvkey execid fyear: keep if _n==1
save "deltavega.dta", replace

use "signatures3.dta", clear
merge 1:1 gvkey execid fyear using "deltavega.dta", keep(master match) nogen
sort gvkey fyear execid
save "signatures4.dta", replace

*Compustat and Signatures Merge
use "compustatrestatements.dta", clear
bysort gvkey fyear: keep if _n==1
save "compustatrestatements.dta", replace

use "signatures4.dta", clear
merge m:1 gvkey fyear using "compustatrestatements.dta", keep(master match) nogen
bysort gvkey execid fyear: keep if _n==1
gen scauditfees = (auditfees/l1at)
gen sic2 = floor(sic/100)
tabulate(sic2), gen(sicdum)
gen abstacc = abs(tacc_a1_err)
sort gvkey execid fyear
gen cfovolat = cfovolatility/at
gen salesvolat = salesvolatility/at
gen inventories = invt/at
foreach i of varlist size btm firmage leverage salesgrowth cfovolat salesvolat percchgcashsales earningsprice chgroa delta vega inventories numweakness chginv chgrec apl tenure scauditfees {
winsor `i', gen(`i'_w) p(0.01)
}
save "compustatsignatures.dta", replace

*Accruals Earnings Management Regressions
areg abstacc apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Absolute Discretionary Accruals) adjr2 excel
areg wc_chg_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Accruals Quality) adjr2 excel

areg abstacc apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Absolute Discretionary Accruals) adjr2 excel
areg wc_chg_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Accruals Quality) adjr2 excel

*Real Earnings Management Regressions
areg disexp_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Abnormal Expenses) adjr2 excel
areg ocf_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Abnormal Cash Flows) adjr2 excel
areg prod_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Abnormal Production) adjr2 excel

areg disexp_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Abnormal Expenses) adjr2 excel
areg ocf_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Abnormal Cash Flows) adjr2 excel
areg prod_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Abnormal Production) adjr2 excel

*Internal Controls Regressions
ologit effcontrols apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if cfo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Effective Controls) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel
ologit numweakness apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if cfo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Number Weaknesses) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

ologit effcontrols apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if ceo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Effective Controls) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel
ologit numweakness apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if ceo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Number Weaknesses) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

*Restatement Regressions
ologit restatement apl_w size_w btm_w firmage_w leverage_w chginv_w chgrec_w percchgcashsales_w earningsprice_w chgroa_w scauditfees_w female tenure_w delta_w vega_w i.sic2 if cfo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Restatements) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

ologit restatement apl_w size_w btm_w firmage_w leverage_w chginv_w chgrec_w percchgcashsales_w earningsprice_w chgroa_w scauditfees_w female tenure_w delta_w vega_w i.sic2 if ceo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Restatements) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

*Conservatism Processing
use "crspreturns.dta", clear
gen newcusip = cusip
gen year = year(date)
gen month = month(date)
sort newcusip year month
by newcusip: gen cumret = ((1+ret[_n-8])*(1+ret[_n-7])*(1+ret[_n-6])*(1+ret[_n-5])*(1+ret[_n-4])*(1+ret[_n-3])*(1+ret[_n-2])*(1+ret[_n-1])*(1+ret)*(1+ret[_n+1])*(1+ret[_n+2])*(1+ret[_n+3]))-1
by newcusip: gen ewmktret = ((1+ewretd[_n-8])*(1+ewretd[_n-7])*(1+ewretd[_n-6])*(1+ewretd[_n-5])*(1+ewretd[_n-4])*(1+ewretd[_n-3])*(1+ewretd[_n-2])*(1+ewretd[_n-1])*(1+ewretd)*(1+ewretd[_n+1])*(1+ewretd[_n+2])*(1+ewretd[_n+3]))-1
gen ewcumret = cumret-ewmktret
save "crspreturns2.dta", replace

*CFO Conservatism 
use "compustatsignatures.dta", clear
keep if cfo == 1
gen newcusip = substr(cusip,1,8)
gen year = year(datadate)
gen month = month(datadate)
bysort newcusip year month: keep if _n==1
merge 1:1 newcusip year month using "crspreturns2.dta", keep(master match) nogen
drop if ff49 == 31 | ff49 >= 45
sort gvkey fyear
xtset gvkey fyear
gen roe=ib/[l1.csho*l1.prcc_f]
gen logmve=ln(csho*prcc_f)
gen lev=(dltt+dlc)/ceq
gen mtb=[csho*prcc_f]/ceq
keep gvkey fyear sic2 apl_w tenure_w female roe logmve lev mtb ewcumret
rename ewcumret ret
drop if missing(roe, ret)
foreach i of varlist roe logmve lev mtb ret {
winsor `i', gen(`i'_w) p(0.01)
}
gen d = ret<0 if !missing(ret)
gen d_ret_w = d*ret_w
qui foreach i of varlist logmve_w mtb_w lev_w apl_w tenure_w female {
gen ret_w_`i'=ret_w*`i'
gen d_`i'=d*`i'
gen d_ret_w_`i'=d*ret_w*`i'
}

*CFO Conservatism Regression
areg roe_w d ret_w d_ret_w apl_w d_apl_w ret_w_apl_w d_ret_w_apl_w logmve_w d_logmve_w ret_w_logmve_w d_ret_w_logmve_w mtb_w d_mtb_w ret_w_mtb_w d_ret_w_mtb_w lev_w d_lev_w ret_w_lev_w d_ret_w_lev_w tenure_w d_tenure_w ret_w_tenure_w d_ret_w_tenure_w female d_female ret_w_female d_ret_w_female, absorb(sic2) cluster(gvkey)
outreg2 using conservatism.xls, se bdec(3) append ctitle(CFO Conservatism) adjr2 excel

*CEO Conservatism 
use "compustatsignatures.dta", clear
keep if ceo == 1
gen newcusip = substr(cusip,1,8)
gen year = year(datadate)
gen month = month(datadate)
bysort newcusip year month: keep if _n==1
merge 1:1 newcusip year month using "crspreturns2.dta", keep(master match) nogen
drop if ff49 == 31 | ff49 >= 45
sort gvkey fyear
bysort gvkey fyear: keep if _n==1
xtset gvkey fyear
gen roe=ib/[l1.csho*l1.prcc_f]
gen logmve=ln(csho*prcc_f)
gen lev=(dltt+dlc)/ceq
gen mtb=[csho*prcc_f]/ceq
keep gvkey fyear sic2 apl_w tenure_w female roe logmve lev mtb ewcumret
rename ewcumret ret
drop if missing(roe, ret)
foreach i of varlist roe logmve lev mtb ret {
winsor `i', gen(`i'_w) p(0.01)
}
gen d = ret<0 if !missing(ret)
gen d_ret_w = d*ret_w
qui foreach i of varlist logmve_w mtb_w lev_w apl_w tenure_w female {
gen ret_w_`i'=ret_w*`i'
gen d_`i'=d*`i'
gen d_ret_w_`i'=d*ret_w*`i'
}

*CEO Conservatism Regression
areg roe_w d ret_w d_ret_w apl_w d_apl_w ret_w_apl_w d_ret_w_apl_w logmve_w d_logmve_w ret_w_logmve_w d_ret_w_logmve_w mtb_w d_mtb_w ret_w_mtb_w d_ret_w_mtb_w lev_w d_lev_w ret_w_lev_w d_ret_w_lev_w tenure_w d_tenure_w ret_w_tenure_w d_ret_w_tenure_w female d_female ret_w_female d_ret_w_female, absorb(sic2) cluster(gvkey)
outreg2 using conservatism.xls, se bdec(3) append ctitle(CEO Conservatism) adjr2 excel


****************************************************************************************************
* Conduct experimental mediation analysis
****************************************************************************************************


*Paste experimental data from Microsoft Excel into Stata data editor, then estimate mediation analysis regressions
reg monetaryallocation signaturesize
reg monetaryallocation narcissism
reg narcissism signaturesize
reg monetaryallocation signaturesize narcissism


****************************************************************************************************
* End
****************************************************************************************************

****************************************************************************************************
*
* CFO Narcissism and Financial Reporting Quality
*
* Charles Ham, Mark Lang, Nicholas Seybert, Sean Wang
*
****************************************************************************************************


****************************************************************************************************
* Match executives with hand collected signatures to Execucomp
****************************************************************************************************


*create stata file from hand collected master file of executive signatures
insheet using "Signatures_Master_DL.csv", comma names clear
foreach i in "firmname" "title" "filename" "execname" "signedname" {
replace `i'=lower(`i')
}
*drop firm without the files provided
drop if firmnumber==64
save "Signatures_Master_DL.dta", replace

*create permno-gvkey links from crsp compustat merged linking table
use "CCM_Link_DL.dta", clear
keep if linkprim=="P" | linkprim=="C"
keep gvkey lpermno conm conml linkdt linkenddt
rename lpermno permno
destring gvkey, replace
duplicates drop gvkey permno, force
save "CCM_Link1.dta", replace

*create list of executive names from execucomp with gvkey and firm name
use "Execucomp_DL.dta", clear
keep gvkey exec_fullname coname co_per_rol execid
destring gvkey execid, replace
replace coname=lower(coname)
replace exec_fullname=lower(exec_fullname)
duplicates drop gvkey execid, force
sort gvkey exec_fullname
gen execucompid=_n
rename exec_fullname execname
*clean some education information from the names
foreach i in ", be (electrical eng)" ", o.c., ll. d." ", b.sc. (business administration), c" ", b.sc., m.b.a., c.p.a." ", b.a., m.b.a., c.m.a." ", esq., j.d." ", j.d., esq." ", cpa, pfs" ", mba finance" ", cpa" ", cfa" ", cma" ", ph.d." ", j.d." ", esq." ", m.d." ", j.b." {
replace execname=subinstr(execname,"`i'","",.)
}
save "Execucomp_Executive_Names.dta", replace

*create file of all executive-firm-years from execucomp
use "Execucomp_DL.dta", clear
destring gvkey execid co_per_rol, replace
rename year fyear
save "Execucomp_Executive_Firm_Years.dta", replace

*clean some firm names from crsp
use "CRSP_DL.dta", clear
keep permno comnam ticker
rename comnam firmname
replace firmname=lower(firmname)
replace firmname=subinstr(firmname,"international","intl",.)
replace firmname=subinstr(firmname,"incorporated","inc",.)
replace firmname=subinstr(firmname,"corporation","corp",.)
replace firmname=subinstr(firmname,"company","co",.)
replace firmname=subinstr(firmname," limited"," ltd",.)
replace firmname=subinstr(firmname," l p"," lp",.)
replace firmname=subinstr(firmname,"and","&",.)
replace firmname=subinstr(firmname,"u s a ","usa ",.)
replace firmname=subinstr(firmname," u s a"," usa",.)
replace firmname=subinstr(firmname,"u s ","us ",.)
replace firmname=subinstr(firmname," u s"," us",.)
replace firmname=subinstr(firmname," new","",.)
replace firmname=subinstr(firmname,"the ","",.)
replace firmname=subinstr(firmname,"-"," ",.)
replace firmname=subinstr(firmname,"  "," ",.)
duplicates drop firmname permno, force
sort firmname permno
gen crspid=_n
save "CRSP_Firm_Names.dta", replace

*clean some hand collected firm names
insheet using "Signatures_Master_DL.csv", clear
keep firmnumber firmname
replace firmname=lower(firmname)
replace firmname=subinstr(firmname,"'","",.)
replace firmname=subinstr(firmname,"*","",.)
replace firmname=subinstr(firmname,",","",.)
replace firmname=subinstr(firmname,".","",.)
replace firmname=subinstr(firmname,"/","",.)
replace firmname=subinstr(firmname,"international","intl",.)
replace firmname=subinstr(firmname,"incorporated","inc",.)
replace firmname=subinstr(firmname,"corporation","corp",.)
replace firmname=subinstr(firmname,"company","co",.)
replace firmname=subinstr(firmname," l p"," lp",.)
replace firmname=subinstr(firmname," limited"," ltd",.)
replace firmname=subinstr(firmname,"and","&",.)
replace firmname=subinstr(firmname,"u s a ","usa ",.)
replace firmname=subinstr(firmname," u s a"," usa",.)
replace firmname=subinstr(firmname,"u s ","us ",.)
replace firmname=subinstr(firmname," u s"," us",.)
replace firmname=subinstr(firmname," new","",.)
replace firmname=subinstr(firmname,"the ","",.)
replace firmname=subinstr(firmname,"-"," ",.)
replace firmname=subinstr(firmname,"  "," ",.)
duplicates drop firmname, force
save "Signatures_Firm_Names.dta", replace

*fuzzy merge hand collected names with crsp names
use "Signatures_Firm_Names.dta", clear
reclink firmname using "CRSP_Firm_Names.dta", idm(firmnumber) idu(crspid) gen(matchscore) minscore(0.5)
save "Signatures_Firm_Names_Merged1.dta", replace

*create file of poor fuzzy firm matches, then hand check
use "Signatures_Firm_Names_Merged1.dta", clear
keep if matchscore<=0.99
outsheet using "Signatures_Firm_Names_Merged2.csv", comma names replace

*create file of good fuzzy firm matches, then hand check
use "Signatures_Firm_Names_Merged1.dta", clear
keep if matchscore>0.99
outsheet using "Signatures_Firm_Names_Merged3.csv", comma names replace

*create file of correct firm matches from the poor fuzzy firm matches and firms that had a high fuzzy match score but were incorrect matches (done by hand)
insheet using "Signatures_Firm_Names_Merged4.csv", comma names clear
drop if permno=="private"
destring permno, replace
save "Signatures_Firm_Names_Merged4.dta", replace

*create file of all firm matches
*start with good fuzzy match firms
use "Signatures_Firm_Names_Merged1.dta", clear
keep if matchscore>0.99
*drop firms that had a high fuzzy match score but were incorrect matches
foreach i in "81" "111" "276" "354" "446" "689" "929" {
drop if firmnumber==`i'
}
*append the hand collected firm matches that the fuzzy match didn't work for
append using "Signatures_Firm_Names_Merged4.dta"
keep firmnumber firmname permno
save "Signatures_Firm_Names_Merged5.dta", replace

*merge in the gvkeys from the permno-gvkey link created above
use "Signatures_Firm_Names_Merged5.dta", clear
joinby permno using "CCM_Link1.dta", unmatched(master)
drop _merge
*the permno merge picked up an incorrect gvkey for a few firms. updated them here after hand-checking the merge results. these were mostly from old permno-gvkey links.
replace gvkey=4199 if firmnumber==289
replace gvkey=178849 if firmnumber==712
replace gvkey=7086 if firmnumber==546
replace gvkey=120877 if firmnumber==702
replace gvkey=9692 if firmnumber==756
replace gvkey=20993 if firmnumber==882
replace gvkey=4739 if firmnumber==897
replace gvkey=14477 if firmnumber==905
drop if missing(gvkey)
*the permno merge picked up multiple gvkeys for some firms. dropped the incorrect gvkeys here (hand-checked).
drop if firmnumber==364 & gvkey!=5073
drop if firmnumber==116 & gvkey!=11856
drop if firmnumber==158 & gvkey!=12485
drop if firmnumber==193 & gvkey!=3054
drop if firmnumber==196 & gvkey!=3078
drop if firmnumber==277 & gvkey!=3897
drop if firmnumber==280 & gvkey!=4094
drop if firmnumber==340 & gvkey!=4818
drop if firmnumber==370 & gvkey!=12233
drop if firmnumber==372 & gvkey!=5134
drop if firmnumber==394 & gvkey!=12788
drop if firmnumber==403 & gvkey!=29710
drop if firmnumber==411 & gvkey!=179657
drop if firmnumber==424 & gvkey!=27914
drop if firmnumber==440 & gvkey!=6140
drop if firmnumber==447 & gvkey!=14446
drop if firmnumber==499 & gvkey!=6781
drop if firmnumber==514 & gvkey!=7017
drop if firmnumber==523 & gvkey!=141400
drop if firmnumber==535 & gvkey!=7171
drop if firmnumber==550 & gvkey!=24379
drop if firmnumber==597 & gvkey!=24361
drop if firmnumber==656 & gvkey!=179621
drop if firmnumber==665 & gvkey!=28591
drop if firmnumber==667 & gvkey!=8245
drop if firmnumber==672 & gvkey!=2002
drop if firmnumber==697 & gvkey!=8867
drop if firmnumber==728 & gvkey!=5968
drop if firmnumber==756 & gvkey!=9692
drop if firmnumber==781 & gvkey!=9380
drop if firmnumber==798 & gvkey!=28543
drop if firmnumber==846 & gvkey!=10301
drop if firmnumber==887 & gvkey!=165675
drop if firmnumber==888 & gvkey!=160785
drop if firmnumber==901 & gvkey!=3980
drop if firmnumber==907 & gvkey!=4367
drop if firmnumber==76 & gvkey!=25056
drop if firmnumber==778 & gvkey!=10984
drop if firmnumber==779 & gvkey!=5087
duplicates drop firmnumber gvkey, force
sort firmnumber gvkey
save "Signatures_Firm_Names_Merged6.dta", replace

*begin with the firm names. merge in the executive information from the master signature file. then fuzzy match executive names to execucomp
use "Signatures_Firm_Names_Merged6.dta", clear
joinby firmnumber using "Signatures_Master_DL.dta", unmatched(master)
drop _merge
*fuzzy match by gvkey-execname combo to the execucomp file with all gvkey-execname combos
gen newid=_n
reclink gvkey execname using "Execucomp_Executive_Names.dta", idm(newid) idu(execucompid) gen(matchscore) minscore(0.59) required(gvkey)
drop if _merge==1
drop _merge
*hand-check all non-exact matches and drop the incorrect matches
drop if execnum==506 & co_per_rol==22762
drop if execnum==849 & co_per_rol==6076
drop if execnum==472 & co_per_rol==19632
drop if execnum==1861 & co_per_rol==2630
drop if execnum==275 & co_per_rol==38082
drop if execnum==1095 & co_per_rol==17586
drop if execnum==825 & co_per_rol==46614
drop if execnum==1486 & co_per_rol==47903
drop if execnum==1338 & co_per_rol==48451
drop if execnum==71 & co_per_rol==48322
drop if execnum==221 & co_per_rol==15349
drop if execnum==1704 & co_per_rol==3149
drop if execnum==1328 & co_per_rol==2622
drop if execnum==1747 & co_per_rol==39683
drop if execnum==307 & co_per_rol==29853
drop if execnum==1212 & co_per_rol==28967
drop if execnum==1213 & co_per_rol==45067
save "Signatures_Firm_Names_Merged7.dta", replace

*try to manually match the executives that weren't matched by joining all executive names in execucomp for the corresponding firm
use "Signatures_Firm_Names_Merged6.dta", clear
joinby firmnumber using "Signatures_Master_DL.dta", unmatched(master)
drop _merge
merge m:1 execnum using "Signatures_Firm_Names_Merged7.dta", keep(master) nogen
joinby gvkey using "Execucomp_Executive_Names.dta", unmatched(master)
*hand-checked all of the possible matches and no additional matches were identified

*create master file now with gvkey, co_per_rol, & execid
use "Signatures_Firm_Names_Merged7.dta", clear
merge 1:1 execnum using "Signatures_Master_DL.dta", keep(master match) nogen
save "Signatures_Firm_Names_Merged_Final.dta", replace

*expand the file to include the years each executive was in execucomp at the respective firm
use "Signatures_Firm_Names_Merged_Final.dta", clear
joinby co_per_rol using "Execucomp_Executive_Firm_Years.dta", unmatched(master)
foreach i of varlist coname exec_fullname titleann ceoann cfoann {
replace `i'=lower(`i')
}
*drop duplicate year
drop if co_per_rol==27754 & (fyear==2003 | fyear==2004)
*retain only years in office as cfo/ceo
gen iscfo=1 if title=="cfo" & (strpos(cfoann,"cfo")>0 | strpos(titleann,"financial officer")>0 | strpos(titleann,"finance officer")>0 | strpos(titleann,"fnl offr")>0 | strpos(titleann,"chief finance")>0 | strpos(titleann,"finl offr")>0 | strpos(titleann,"exec. fin. offr.")>0 | strpos(titleann,"cfo")>0 | strpos(titleann,"v-p-fin. &")>0 | strpos(titleann,"financ")>0)
gen isceo=1 if title=="ceo" & (strpos(ceoann,"ceo")>0 | strpos(titleann,"chief executive")>0 | strpos(titleann,"executive officer")>0 | strpos(titleann,"ceo")>0)
drop if title=="cfo" & missing(iscfo)
drop if title=="ceo" & missing(isceo)
gen cfo=title=="cfo"
gen ceo=title=="ceo"
save "Signatures_Master_Sample.dta", replace


****************************************************************************************************
* Calculate variables and estimate results
****************************************************************************************************


*create compustat variables
use "compustat.dta", clear
destring gvkey sic, replace
ffind sic, newvar(ff49) type(49)
bysort gvkey fyear: keep if _n == 1
sort gvkey fyear
xtset gvkey fyear
replace xrd = 0 if xrd == . & xsga != .
replace xad = 0 if xad == . & xsga != .
gen meancfo = (l1.oancf + l2.oancf + l3.oancf + l4.oancf + l5.oancf)/5
gen cfovolatility = (((l1.oancf-meancfo)^2 + (l2.oancf-meancfo)^2 + (l3.oancf-meancfo)^2 + (l4.oancf-meancfo)^2 + (l5.oancf-meancfo)^2)/5)^.5
gen meanrevt = (l1.revt + l2.revt + l3.revt + l4.revt + l5.revt)/5
gen salesvolatility = (((l1.revt-meanrevt)^2 + (l2.revt-meanrevt)^2 + (l3.revt-meanrevt)^2 + (l4.revt-meanrevt)^2 + (l5.revt-meanrevt)^2)/5)^.5
gen percchgcashsales = ((revt-rect)-(l1.revt-l1.rect))/(l1.revt-l1.rect)
gen l4loss = l4.ni < 0
gen l3loss = l3.ni < 0
gen l2loss = l2.ni < 0
gen l1loss = l1.ni < 0
gen percloss = (l4loss + l3loss + l2loss + l1loss)/4
gen earningsprice = ni/(prcc_f*csho)
gen chgroa = (ni/(at+l1.at))-(l1.ni/(l1.at+l2.at))
gen chginv = (invt-l1.invt)/(at+l1.at)
gen chgrec = (rect-l1.rect)/(at+l1.at)
gen l1at=l1.at
gen at_avg=[at+l1at]/2
gen ocf_a1=oancf/l1at
gen prod_a1=[cogs+invt-l1.invt]/l1at
gen disexp_a1=[xrd+xad+xsga]/l1at
gen a_inv=1/l1at
gen s_a1=sale/l1at
gen s_chg=sale-l1.sale
gen s_chg_a1=s_chg/l1at
gen l1s_chg_a1=l1.s_chg/l1at
gen l1s_a1=l1.sale/l1at
gen tacc_a1=[ibc-oancf]/l1at
gen revt_rect_a1=[[revt-l1.revt]-[rect-l1.rect]]/l1at
gen ppegt_a1=ppegt/l1at
gen wc_chg_a1=[[act-l1.act]-[lct-l1.lct]-[che-l1.che]+[dlc-l1.dlc]]/at_avg
gen cffo_a1=[ib-[[act-l1.act]-[lct-l1.lct]-[che-l1.che]+[dlc-l1.dlc]-[dp]]]/l1at
gen l1cffo_a1=l1.cffo_a1
gen f1cffo_a1=f1.cffo_a1
gen roa=ibc/l1at
gen l1roa=l1.roa
gen roa_chg=roa-l1roa
sort sic
save "compustat2.dta", replace

*calculate abnormal operating cash flows
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear ocf_a1 a_inv s_a1 s_chg_a1 ff49
keep if !missing(ocf_a1, a_inv, s_a1, s_chg_a1)
foreach i of varlist ocf_a1 a_inv s_a1 s_chg_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen ocf_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg ocf_a1 a_inv s_a1 s_chg_a1 if newid2==`i'
	capture predict ocf_a1_err_temp, residuals
	capture replace ocf_a1_err=ocf_a1_err_temp if newid2==`i' & missing(ocf_a1_err) & !missing(ocf_a1_err_temp)
	capture drop ocf_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 ocf_a1_err
save "compustatff49_a1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_a1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_a1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear ocf_a1_err
sort gvkey fyear
save "compustatff49_a1_11.dta", replace

*calculate abnormal production costs
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear prod_a1 a_inv s_a1 s_chg_a1 l1s_chg_a1 ff49    
qui keep if !missing(prod_a1, a_inv, s_a1, s_chg_a1, l1s_chg_a1)
foreach i of varlist prod_a1 a_inv s_a1 s_chg_a1 l1s_chg_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen prod_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg prod_a1 a_inv s_a1 s_chg_a1 l1s_chg_a1 if newid2==`i'
	capture predict prod_a1_err_temp, residuals
	capture replace prod_a1_err=prod_a1_err_temp if newid2==`i' & missing(prod_a1_err) & !missing(prod_a1_err_temp)
	capture drop prod_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 prod_a1_err
save "compustatff49_b1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_b1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_b1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear prod_a1_err
sort gvkey fyear
save "compustatff49_b1_11.dta", replace

*calculate abnormal discretionary expenses
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear disexp_a1 a_inv l1s_a1 ff49    
qui keep if !missing(disexp_a1, a_inv, l1s_a1)
foreach i of varlist disexp_a1 a_inv l1s_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen disexp_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg disexp_a1 a_inv l1s_a1 if newid2==`i'
	capture predict disexp_a1_err_temp, residuals
	capture replace disexp_a1_err=disexp_a1_err_temp if newid2==`i' & missing(disexp_a1_err) & !missing(disexp_a1_err_temp)
	capture drop disexp_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 disexp_a1_err
save "compustatff49_c1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_c1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_c1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear disexp_a1_err
sort gvkey fyear
save "compustatff49_c1_11.dta", replace

*calculate discretionary accruals
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear tacc_a1 a_inv revt_rect_a1 l1roa ppegt_a1 ff49    
qui keep if !missing(tacc_a1, a_inv, revt_rect_a1, ppegt_a1, l1roa)
foreach i of varlist tacc_a1 a_inv revt_rect_a1 l1roa ppegt_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen tacc_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg tacc_a1 a_inv revt_rect_a1 ppegt_a1 l1roa if newid2==`i'
	capture predict tacc_a1_err_temp, residuals
	capture replace tacc_a1_err=tacc_a1_err_temp if newid2==`i' & missing(tacc_a1_err) & !missing(tacc_a1_err_temp)
	capture drop tacc_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 tacc_a1_err
save "compustatff49_d1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_d1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_d1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear tacc_a1_err
sort gvkey fyear
save "compustatff49_d1_11.dta", replace

*calculate abnormal working capital accruals
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear wc_chg_a1 l1cffo_a1 cffo_a1 f1cffo_a1 s_chg_a1 ppegt_a1 ff49    
qui keep if !missing(wc_chg_a1, l1cffo_a1, cffo_a1, f1cffo_a1, s_chg_a1, ppegt_a1)
foreach i of varlist wc_chg_a1 l1cffo_a1 cffo_a1 f1cffo_a1 s_chg_a1 ppegt_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49     newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen wc_chg_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg wc_chg_a1 l1cffo_a1 cffo_a1 f1cffo_a1 s_chg_a1 ppegt_a1 if newid2==`i'
	capture predict wc_chg_a1_err_temp, residuals
	capture replace wc_chg_a1_err=wc_chg_a1_err_temp if newid2==`i' & missing(wc_chg_a1_err) & !missing(wc_chg_a1_err_temp)
	capture drop wc_chg_a1_pred_temp
	capture drop wc_chg_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 wc_chg_a1_err
save "compustatff49_e1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_e1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_e1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear wc_chg_a1_err
sort gvkey fyear
save "compustatff49_e1_11.dta", replace

*merge earnings management proxies
use "compustat2.dta", clear
merge 1:1 gvkey fyear using "compustatff49_a1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_b1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_c1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_d1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_e1_11.dta", keep(master match) nogen
sort gvkey fyear
save "compustatEM.dta", replace

*CRSP Merge
use "crsp.dta", clear
sort permno date
save "crsp.dta", replace

use "crsppermnolink.dta", clear
sort permno
by permno: keep if _n==1
save "crsppermnolink.dta", replace

merge 1:m permno using "crsp.dta", keep(master match) nogen
destring gvkey, replace
gen year = year(date)
sort gvkey year
bysort gvkey: keep if _n == 1
gen firstyear = year
drop year date
save "crspfirstyear.dta", replace

use "compustatEM.dta", clear
merge m:1 gvkey using "crspfirstyear.dta", keep(master match) nogen
gen firmage = fyear - firstyear
replace firmage = _n if firmage < 1
destring cik, replace
bysort cik fyear: keep if _n==1
save "compustatEM2.dta", replace

*Audit Analytics Merge
use "internalcontrols.dta", clear
bysort cik fyear: keep if _n == 1
save "internalcontrols.dta", replace

use "auditfees.dta", clear
bysort cik fyear: keep if _n == 1
save "auditfees.dta", replace

use "compustatEM2.dta", clear
merge 1:1 cik fyear using "internalcontrols.dta", keep(master match) nogen
merge 1:1 cik fyear using "auditfees.dta", keep(master match) nogen
save "compustatauditfees.dta", replace

*Restatements and Controls
use "restatements.dta", clear
sort cik
gen yearbegin = year(restatebegin)
gen yearend = year(restateend)
by cik: gen yearbegin1 = year(restatebegin[_n+1]) if !missing(restatebegin[_n+1])
by cik: gen yearend1 = year(restateend[_n+1]) if !missing(restateend[_n+1])
by cik: gen yearbegin2 = year(restatebegin[_n+2]) if !missing(restatebegin[_n+2])
by cik: gen yearend2 = year(restateend[_n+2]) if !missing(restateend[_n+2])
by cik: gen yearbegin3 = year(restatebegin[_n+3]) if !missing(restatebegin[_n+3])
by cik: gen yearend3 = year(restateend[_n+3]) if !missing(restateend[_n+3])
by cik: gen yearbegin4 = year(restatebegin[_n+4]) if !missing(restatebegin[_n+4])
by cik: gen yearend4 = year(restateend[_n+4]) if !missing(restateend[_n+4])
by cik: gen yearbegin5 = year(restatebegin[_n+5]) if !missing(restatebegin[_n+5])
by cik: gen yearend5 = year(restateend[_n+5]) if !missing(restateend[_n+5])
by cik: gen yearbegin6 = year(restatebegin[_n+6]) if !missing(restatebegin[_n+6])
by cik: gen yearend6 = year(restateend[_n+6]) if !missing(restateend[_n+6])
by cik: gen yearbegin7 = year(restatebegin[_n+7]) if !missing(restatebegin[_n+7])
by cik: gen yearend7 = year(restateend[_n+7]) if !missing(restateend[_n+7])
by cik: gen yearbegin8 = year(restatebegin[_n+8]) if !missing(restatebegin[_n+8])
by cik: gen yearend8 = year(restateend[_n+8]) if !missing(restateend[_n+8])
by cik: gen yearbegin9 = year(restatebegin[_n+9]) if !missing(restatebegin[_n+9])
by cik: gen yearend9 = year(restateend[_n+9]) if !missing(restateend[_n+9])
by cik: gen yearbegin10 = year(restatebegin[_n+10]) if !missing(restatebegin[_n+10])
by cik: gen yearend10 = year(restateend[_n+10]) if !missing(restateend[_n+10])
by cik: keep if _n==1
save "restatements2.dta", replace

use "compustatauditfees.dta", clear
merge m:1 cik using "restatements2.dta", keep(master match) nogen
gen restatement = 0
replace restatement = 1 if fyear >= yearbegin & fyear <= yearend
replace restatement = 1 if fyear >= yearbegin1 & fyear <= yearend1
replace restatement = 1 if fyear >= yearbegin2 & fyear <= yearend2
replace restatement = 1 if fyear >= yearbegin3 & fyear <= yearend3
replace restatement = 1 if fyear >= yearbegin4 & fyear <= yearend4
replace restatement = 1 if fyear >= yearbegin5 & fyear <= yearend5
replace restatement = 1 if fyear >= yearbegin6 & fyear <= yearend6
replace restatement = 1 if fyear >= yearbegin7 & fyear <= yearend7
replace restatement = 1 if fyear >= yearbegin8 & fyear <= yearend8
replace restatement = 1 if fyear >= yearbegin9 & fyear <= yearend9
replace restatement = 1 if fyear >= yearbegin10 & fyear <= yearend10
gen effcontrols = 1
replace effcontrols = 0 if controlseffective == "No"
replace effcontrols = . if fyear < 2004
replace effcontrols = . if auditfees == .
replace numweakness = 0 if numweakness == .
replace numweakness = . if fyear < 2004
replace numweakness = . if auditfees == .
gen leverage = (dltt+dlc)/ceq
gen salesgrowth = (revt-revt[_n-3])/revt[_n-3]
gen btm = ceq/(csho*prcc_f)
gen size = ln(at)
drop yearbegin* yearend*
save "compustatrestatements.dta", replace

*Signatures and Characteristics Processing
use "Signatures_Master_Sample.dta", clear
drop firmnumber firmname titleann
drop if ceo != 1 & cfo != 1
gen apl = area/length(signedname)
sort gvkey execid fyear
save "signatures2.dta", replace

use "execucomp.dta", clear
destring gvkey execid, replace
rename year fyear
save "execucomp.dta", replace

use "signatures2.dta", clear
merge 1:1 gvkey execid fyear using "execucomp.dta", keep(master match) nogen
drop if apl == .
sort gvkey execid fyear
by gvkey execid fyear: keep if _n == 1
gen female = gender == "FEMALE"
by gvkey execid: gen tenure = _n
keep if legible > 0
sort gvkey execid fyear
save "signatures3.dta", replace

*Import Delta/Vega Data From Coles, Daniel, and Naveen (2006)
insheet using "deltavega.csv", clear
rename year fyear
rename coperol co_per_rol
merge 1:1 gvkey co_per_rol fyear using "execucomp.dta", keep(master match) keepusing(tdc1 execid) nogen
replace delta=delta/tdc1
replace vega=vega/tdc1
bysort gvkey execid fyear: keep if _n==1
save "deltavega.dta", replace

use "signatures3.dta", clear
merge 1:1 gvkey execid fyear using "deltavega.dta", keep(master match) nogen
sort gvkey fyear execid
save "signatures4.dta", replace

*Compustat and Signatures Merge
use "compustatrestatements.dta", clear
bysort gvkey fyear: keep if _n==1
save "compustatrestatements.dta", replace

use "signatures4.dta", clear
merge m:1 gvkey fyear using "compustatrestatements.dta", keep(master match) nogen
bysort gvkey execid fyear: keep if _n==1
gen scauditfees = (auditfees/l1at)
gen sic2 = floor(sic/100)
tabulate(sic2), gen(sicdum)
gen abstacc = abs(tacc_a1_err)
sort gvkey execid fyear
gen cfovolat = cfovolatility/at
gen salesvolat = salesvolatility/at
gen inventories = invt/at
foreach i of varlist size btm firmage leverage salesgrowth cfovolat salesvolat percchgcashsales earningsprice chgroa delta vega inventories numweakness chginv chgrec apl tenure scauditfees {
winsor `i', gen(`i'_w) p(0.01)
}
save "compustatsignatures.dta", replace

*Accruals Earnings Management Regressions
areg abstacc apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Absolute Discretionary Accruals) adjr2 excel
areg wc_chg_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Accruals Quality) adjr2 excel

areg abstacc apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Absolute Discretionary Accruals) adjr2 excel
areg wc_chg_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Accruals Quality) adjr2 excel

*Real Earnings Management Regressions
areg disexp_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Abnormal Expenses) adjr2 excel
areg ocf_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Abnormal Cash Flows) adjr2 excel
areg prod_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Abnormal Production) adjr2 excel

areg disexp_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Abnormal Expenses) adjr2 excel
areg ocf_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Abnormal Cash Flows) adjr2 excel
areg prod_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Abnormal Production) adjr2 excel

*Internal Controls Regressions
ologit effcontrols apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if cfo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Effective Controls) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel
ologit numweakness apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if cfo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Number Weaknesses) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

ologit effcontrols apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if ceo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Effective Controls) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel
ologit numweakness apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if ceo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Number Weaknesses) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

*Restatement Regressions
ologit restatement apl_w size_w btm_w firmage_w leverage_w chginv_w chgrec_w percchgcashsales_w earningsprice_w chgroa_w scauditfees_w female tenure_w delta_w vega_w i.sic2 if cfo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Restatements) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

ologit restatement apl_w size_w btm_w firmage_w leverage_w chginv_w chgrec_w percchgcashsales_w earningsprice_w chgroa_w scauditfees_w female tenure_w delta_w vega_w i.sic2 if ceo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Restatements) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

*Conservatism Processing
use "crspreturns.dta", clear
gen newcusip = cusip
gen year = year(date)
gen month = month(date)
sort newcusip year month
by newcusip: gen cumret = ((1+ret[_n-8])*(1+ret[_n-7])*(1+ret[_n-6])*(1+ret[_n-5])*(1+ret[_n-4])*(1+ret[_n-3])*(1+ret[_n-2])*(1+ret[_n-1])*(1+ret)*(1+ret[_n+1])*(1+ret[_n+2])*(1+ret[_n+3]))-1
by newcusip: gen ewmktret = ((1+ewretd[_n-8])*(1+ewretd[_n-7])*(1+ewretd[_n-6])*(1+ewretd[_n-5])*(1+ewretd[_n-4])*(1+ewretd[_n-3])*(1+ewretd[_n-2])*(1+ewretd[_n-1])*(1+ewretd)*(1+ewretd[_n+1])*(1+ewretd[_n+2])*(1+ewretd[_n+3]))-1
gen ewcumret = cumret-ewmktret
save "crspreturns2.dta", replace

*CFO Conservatism 
use "compustatsignatures.dta", clear
keep if cfo == 1
gen newcusip = substr(cusip,1,8)
gen year = year(datadate)
gen month = month(datadate)
bysort newcusip year month: keep if _n==1
merge 1:1 newcusip year month using "crspreturns2.dta", keep(master match) nogen
drop if ff49 == 31 | ff49 >= 45
sort gvkey fyear
xtset gvkey fyear
gen roe=ib/[l1.csho*l1.prcc_f]
gen logmve=ln(csho*prcc_f)
gen lev=(dltt+dlc)/ceq
gen mtb=[csho*prcc_f]/ceq
keep gvkey fyear sic2 apl_w tenure_w female roe logmve lev mtb ewcumret
rename ewcumret ret
drop if missing(roe, ret)
foreach i of varlist roe logmve lev mtb ret {
winsor `i', gen(`i'_w) p(0.01)
}
gen d = ret<0 if !missing(ret)
gen d_ret_w = d*ret_w
qui foreach i of varlist logmve_w mtb_w lev_w apl_w tenure_w female {
gen ret_w_`i'=ret_w*`i'
gen d_`i'=d*`i'
gen d_ret_w_`i'=d*ret_w*`i'
}

*CFO Conservatism Regression
areg roe_w d ret_w d_ret_w apl_w d_apl_w ret_w_apl_w d_ret_w_apl_w logmve_w d_logmve_w ret_w_logmve_w d_ret_w_logmve_w mtb_w d_mtb_w ret_w_mtb_w d_ret_w_mtb_w lev_w d_lev_w ret_w_lev_w d_ret_w_lev_w tenure_w d_tenure_w ret_w_tenure_w d_ret_w_tenure_w female d_female ret_w_female d_ret_w_female, absorb(sic2) cluster(gvkey)
outreg2 using conservatism.xls, se bdec(3) append ctitle(CFO Conservatism) adjr2 excel

*CEO Conservatism 
use "compustatsignatures.dta", clear
keep if ceo == 1
gen newcusip = substr(cusip,1,8)
gen year = year(datadate)
gen month = month(datadate)
bysort newcusip year month: keep if _n==1
merge 1:1 newcusip year month using "crspreturns2.dta", keep(master match) nogen
drop if ff49 == 31 | ff49 >= 45
sort gvkey fyear
bysort gvkey fyear: keep if _n==1
xtset gvkey fyear
gen roe=ib/[l1.csho*l1.prcc_f]
gen logmve=ln(csho*prcc_f)
gen lev=(dltt+dlc)/ceq
gen mtb=[csho*prcc_f]/ceq
keep gvkey fyear sic2 apl_w tenure_w female roe logmve lev mtb ewcumret
rename ewcumret ret
drop if missing(roe, ret)
foreach i of varlist roe logmve lev mtb ret {
winsor `i', gen(`i'_w) p(0.01)
}
gen d = ret<0 if !missing(ret)
gen d_ret_w = d*ret_w
qui foreach i of varlist logmve_w mtb_w lev_w apl_w tenure_w female {
gen ret_w_`i'=ret_w*`i'
gen d_`i'=d*`i'
gen d_ret_w_`i'=d*ret_w*`i'
}

*CEO Conservatism Regression
areg roe_w d ret_w d_ret_w apl_w d_apl_w ret_w_apl_w d_ret_w_apl_w logmve_w d_logmve_w ret_w_logmve_w d_ret_w_logmve_w mtb_w d_mtb_w ret_w_mtb_w d_ret_w_mtb_w lev_w d_lev_w ret_w_lev_w d_ret_w_lev_w tenure_w d_tenure_w ret_w_tenure_w d_ret_w_tenure_w female d_female ret_w_female d_ret_w_female, absorb(sic2) cluster(gvkey)
outreg2 using conservatism.xls, se bdec(3) append ctitle(CEO Conservatism) adjr2 excel


****************************************************************************************************
* Conduct experimental mediation analysis
****************************************************************************************************


*Paste experimental data from Microsoft Excel into Stata data editor, then estimate mediation analysis regressions
reg monetaryallocation signaturesize
reg monetaryallocation narcissism
reg narcissism signaturesize
reg monetaryallocation signaturesize narcissism


****************************************************************************************************
* End
****************************************************************************************************

****************************************************************************************************
*
* CFO Narcissism and Financial Reporting Quality
*
* Charles Ham, Mark Lang, Nicholas Seybert, Sean Wang
*
****************************************************************************************************


****************************************************************************************************
* Match executives with hand collected signatures to Execucomp
****************************************************************************************************


*create stata file from hand collected master file of executive signatures
insheet using "Signatures_Master_DL.csv", comma names clear
foreach i in "firmname" "title" "filename" "execname" "signedname" {
replace `i'=lower(`i')
}
*drop firm without the files provided
drop if firmnumber==64
save "Signatures_Master_DL.dta", replace

*create permno-gvkey links from crsp compustat merged linking table
use "CCM_Link_DL.dta", clear
keep if linkprim=="P" | linkprim=="C"
keep gvkey lpermno conm conml linkdt linkenddt
rename lpermno permno
destring gvkey, replace
duplicates drop gvkey permno, force
save "CCM_Link1.dta", replace

*create list of executive names from execucomp with gvkey and firm name
use "Execucomp_DL.dta", clear
keep gvkey exec_fullname coname co_per_rol execid
destring gvkey execid, replace
replace coname=lower(coname)
replace exec_fullname=lower(exec_fullname)
duplicates drop gvkey execid, force
sort gvkey exec_fullname
gen execucompid=_n
rename exec_fullname execname
*clean some education information from the names
foreach i in ", be (electrical eng)" ", o.c., ll. d." ", b.sc. (business administration), c" ", b.sc., m.b.a., c.p.a." ", b.a., m.b.a., c.m.a." ", esq., j.d." ", j.d., esq." ", cpa, pfs" ", mba finance" ", cpa" ", cfa" ", cma" ", ph.d." ", j.d." ", esq." ", m.d." ", j.b." {
replace execname=subinstr(execname,"`i'","",.)
}
save "Execucomp_Executive_Names.dta", replace

*create file of all executive-firm-years from execucomp
use "Execucomp_DL.dta", clear
destring gvkey execid co_per_rol, replace
rename year fyear
save "Execucomp_Executive_Firm_Years.dta", replace

*clean some firm names from crsp
use "CRSP_DL.dta", clear
keep permno comnam ticker
rename comnam firmname
replace firmname=lower(firmname)
replace firmname=subinstr(firmname,"international","intl",.)
replace firmname=subinstr(firmname,"incorporated","inc",.)
replace firmname=subinstr(firmname,"corporation","corp",.)
replace firmname=subinstr(firmname,"company","co",.)
replace firmname=subinstr(firmname," limited"," ltd",.)
replace firmname=subinstr(firmname," l p"," lp",.)
replace firmname=subinstr(firmname,"and","&",.)
replace firmname=subinstr(firmname,"u s a ","usa ",.)
replace firmname=subinstr(firmname," u s a"," usa",.)
replace firmname=subinstr(firmname,"u s ","us ",.)
replace firmname=subinstr(firmname," u s"," us",.)
replace firmname=subinstr(firmname," new","",.)
replace firmname=subinstr(firmname,"the ","",.)
replace firmname=subinstr(firmname,"-"," ",.)
replace firmname=subinstr(firmname,"  "," ",.)
duplicates drop firmname permno, force
sort firmname permno
gen crspid=_n
save "CRSP_Firm_Names.dta", replace

*clean some hand collected firm names
insheet using "Signatures_Master_DL.csv", clear
keep firmnumber firmname
replace firmname=lower(firmname)
replace firmname=subinstr(firmname,"'","",.)
replace firmname=subinstr(firmname,"*","",.)
replace firmname=subinstr(firmname,",","",.)
replace firmname=subinstr(firmname,".","",.)
replace firmname=subinstr(firmname,"/","",.)
replace firmname=subinstr(firmname,"international","intl",.)
replace firmname=subinstr(firmname,"incorporated","inc",.)
replace firmname=subinstr(firmname,"corporation","corp",.)
replace firmname=subinstr(firmname,"company","co",.)
replace firmname=subinstr(firmname," l p"," lp",.)
replace firmname=subinstr(firmname," limited"," ltd",.)
replace firmname=subinstr(firmname,"and","&",.)
replace firmname=subinstr(firmname,"u s a ","usa ",.)
replace firmname=subinstr(firmname," u s a"," usa",.)
replace firmname=subinstr(firmname,"u s ","us ",.)
replace firmname=subinstr(firmname," u s"," us",.)
replace firmname=subinstr(firmname," new","",.)
replace firmname=subinstr(firmname,"the ","",.)
replace firmname=subinstr(firmname,"-"," ",.)
replace firmname=subinstr(firmname,"  "," ",.)
duplicates drop firmname, force
save "Signatures_Firm_Names.dta", replace

*fuzzy merge hand collected names with crsp names
use "Signatures_Firm_Names.dta", clear
reclink firmname using "CRSP_Firm_Names.dta", idm(firmnumber) idu(crspid) gen(matchscore) minscore(0.5)
save "Signatures_Firm_Names_Merged1.dta", replace

*create file of poor fuzzy firm matches, then hand check
use "Signatures_Firm_Names_Merged1.dta", clear
keep if matchscore<=0.99
outsheet using "Signatures_Firm_Names_Merged2.csv", comma names replace

*create file of good fuzzy firm matches, then hand check
use "Signatures_Firm_Names_Merged1.dta", clear
keep if matchscore>0.99
outsheet using "Signatures_Firm_Names_Merged3.csv", comma names replace

*create file of correct firm matches from the poor fuzzy firm matches and firms that had a high fuzzy match score but were incorrect matches (done by hand)
insheet using "Signatures_Firm_Names_Merged4.csv", comma names clear
drop if permno=="private"
destring permno, replace
save "Signatures_Firm_Names_Merged4.dta", replace

*create file of all firm matches
*start with good fuzzy match firms
use "Signatures_Firm_Names_Merged1.dta", clear
keep if matchscore>0.99
*drop firms that had a high fuzzy match score but were incorrect matches
foreach i in "81" "111" "276" "354" "446" "689" "929" {
drop if firmnumber==`i'
}
*append the hand collected firm matches that the fuzzy match didn't work for
append using "Signatures_Firm_Names_Merged4.dta"
keep firmnumber firmname permno
save "Signatures_Firm_Names_Merged5.dta", replace

*merge in the gvkeys from the permno-gvkey link created above
use "Signatures_Firm_Names_Merged5.dta", clear
joinby permno using "CCM_Link1.dta", unmatched(master)
drop _merge
*the permno merge picked up an incorrect gvkey for a few firms. updated them here after hand-checking the merge results. these were mostly from old permno-gvkey links.
replace gvkey=4199 if firmnumber==289
replace gvkey=178849 if firmnumber==712
replace gvkey=7086 if firmnumber==546
replace gvkey=120877 if firmnumber==702
replace gvkey=9692 if firmnumber==756
replace gvkey=20993 if firmnumber==882
replace gvkey=4739 if firmnumber==897
replace gvkey=14477 if firmnumber==905
drop if missing(gvkey)
*the permno merge picked up multiple gvkeys for some firms. dropped the incorrect gvkeys here (hand-checked).
drop if firmnumber==364 & gvkey!=5073
drop if firmnumber==116 & gvkey!=11856
drop if firmnumber==158 & gvkey!=12485
drop if firmnumber==193 & gvkey!=3054
drop if firmnumber==196 & gvkey!=3078
drop if firmnumber==277 & gvkey!=3897
drop if firmnumber==280 & gvkey!=4094
drop if firmnumber==340 & gvkey!=4818
drop if firmnumber==370 & gvkey!=12233
drop if firmnumber==372 & gvkey!=5134
drop if firmnumber==394 & gvkey!=12788
drop if firmnumber==403 & gvkey!=29710
drop if firmnumber==411 & gvkey!=179657
drop if firmnumber==424 & gvkey!=27914
drop if firmnumber==440 & gvkey!=6140
drop if firmnumber==447 & gvkey!=14446
drop if firmnumber==499 & gvkey!=6781
drop if firmnumber==514 & gvkey!=7017
drop if firmnumber==523 & gvkey!=141400
drop if firmnumber==535 & gvkey!=7171
drop if firmnumber==550 & gvkey!=24379
drop if firmnumber==597 & gvkey!=24361
drop if firmnumber==656 & gvkey!=179621
drop if firmnumber==665 & gvkey!=28591
drop if firmnumber==667 & gvkey!=8245
drop if firmnumber==672 & gvkey!=2002
drop if firmnumber==697 & gvkey!=8867
drop if firmnumber==728 & gvkey!=5968
drop if firmnumber==756 & gvkey!=9692
drop if firmnumber==781 & gvkey!=9380
drop if firmnumber==798 & gvkey!=28543
drop if firmnumber==846 & gvkey!=10301
drop if firmnumber==887 & gvkey!=165675
drop if firmnumber==888 & gvkey!=160785
drop if firmnumber==901 & gvkey!=3980
drop if firmnumber==907 & gvkey!=4367
drop if firmnumber==76 & gvkey!=25056
drop if firmnumber==778 & gvkey!=10984
drop if firmnumber==779 & gvkey!=5087
duplicates drop firmnumber gvkey, force
sort firmnumber gvkey
save "Signatures_Firm_Names_Merged6.dta", replace

*begin with the firm names. merge in the executive information from the master signature file. then fuzzy match executive names to execucomp
use "Signatures_Firm_Names_Merged6.dta", clear
joinby firmnumber using "Signatures_Master_DL.dta", unmatched(master)
drop _merge
*fuzzy match by gvkey-execname combo to the execucomp file with all gvkey-execname combos
gen newid=_n
reclink gvkey execname using "Execucomp_Executive_Names.dta", idm(newid) idu(execucompid) gen(matchscore) minscore(0.59) required(gvkey)
drop if _merge==1
drop _merge
*hand-check all non-exact matches and drop the incorrect matches
drop if execnum==506 & co_per_rol==22762
drop if execnum==849 & co_per_rol==6076
drop if execnum==472 & co_per_rol==19632
drop if execnum==1861 & co_per_rol==2630
drop if execnum==275 & co_per_rol==38082
drop if execnum==1095 & co_per_rol==17586
drop if execnum==825 & co_per_rol==46614
drop if execnum==1486 & co_per_rol==47903
drop if execnum==1338 & co_per_rol==48451
drop if execnum==71 & co_per_rol==48322
drop if execnum==221 & co_per_rol==15349
drop if execnum==1704 & co_per_rol==3149
drop if execnum==1328 & co_per_rol==2622
drop if execnum==1747 & co_per_rol==39683
drop if execnum==307 & co_per_rol==29853
drop if execnum==1212 & co_per_rol==28967
drop if execnum==1213 & co_per_rol==45067
save "Signatures_Firm_Names_Merged7.dta", replace

*try to manually match the executives that weren't matched by joining all executive names in execucomp for the corresponding firm
use "Signatures_Firm_Names_Merged6.dta", clear
joinby firmnumber using "Signatures_Master_DL.dta", unmatched(master)
drop _merge
merge m:1 execnum using "Signatures_Firm_Names_Merged7.dta", keep(master) nogen
joinby gvkey using "Execucomp_Executive_Names.dta", unmatched(master)
*hand-checked all of the possible matches and no additional matches were identified

*create master file now with gvkey, co_per_rol, & execid
use "Signatures_Firm_Names_Merged7.dta", clear
merge 1:1 execnum using "Signatures_Master_DL.dta", keep(master match) nogen
save "Signatures_Firm_Names_Merged_Final.dta", replace

*expand the file to include the years each executive was in execucomp at the respective firm
use "Signatures_Firm_Names_Merged_Final.dta", clear
joinby co_per_rol using "Execucomp_Executive_Firm_Years.dta", unmatched(master)
foreach i of varlist coname exec_fullname titleann ceoann cfoann {
replace `i'=lower(`i')
}
*drop duplicate year
drop if co_per_rol==27754 & (fyear==2003 | fyear==2004)
*retain only years in office as cfo/ceo
gen iscfo=1 if title=="cfo" & (strpos(cfoann,"cfo")>0 | strpos(titleann,"financial officer")>0 | strpos(titleann,"finance officer")>0 | strpos(titleann,"fnl offr")>0 | strpos(titleann,"chief finance")>0 | strpos(titleann,"finl offr")>0 | strpos(titleann,"exec. fin. offr.")>0 | strpos(titleann,"cfo")>0 | strpos(titleann,"v-p-fin. &")>0 | strpos(titleann,"financ")>0)
gen isceo=1 if title=="ceo" & (strpos(ceoann,"ceo")>0 | strpos(titleann,"chief executive")>0 | strpos(titleann,"executive officer")>0 | strpos(titleann,"ceo")>0)
drop if title=="cfo" & missing(iscfo)
drop if title=="ceo" & missing(isceo)
gen cfo=title=="cfo"
gen ceo=title=="ceo"
save "Signatures_Master_Sample.dta", replace


****************************************************************************************************
* Calculate variables and estimate results
****************************************************************************************************


*create compustat variables
use "compustat.dta", clear
destring gvkey sic, replace
ffind sic, newvar(ff49) type(49)
bysort gvkey fyear: keep if _n == 1
sort gvkey fyear
xtset gvkey fyear
replace xrd = 0 if xrd == . & xsga != .
replace xad = 0 if xad == . & xsga != .
gen meancfo = (l1.oancf + l2.oancf + l3.oancf + l4.oancf + l5.oancf)/5
gen cfovolatility = (((l1.oancf-meancfo)^2 + (l2.oancf-meancfo)^2 + (l3.oancf-meancfo)^2 + (l4.oancf-meancfo)^2 + (l5.oancf-meancfo)^2)/5)^.5
gen meanrevt = (l1.revt + l2.revt + l3.revt + l4.revt + l5.revt)/5
gen salesvolatility = (((l1.revt-meanrevt)^2 + (l2.revt-meanrevt)^2 + (l3.revt-meanrevt)^2 + (l4.revt-meanrevt)^2 + (l5.revt-meanrevt)^2)/5)^.5
gen percchgcashsales = ((revt-rect)-(l1.revt-l1.rect))/(l1.revt-l1.rect)
gen l4loss = l4.ni < 0
gen l3loss = l3.ni < 0
gen l2loss = l2.ni < 0
gen l1loss = l1.ni < 0
gen percloss = (l4loss + l3loss + l2loss + l1loss)/4
gen earningsprice = ni/(prcc_f*csho)
gen chgroa = (ni/(at+l1.at))-(l1.ni/(l1.at+l2.at))
gen chginv = (invt-l1.invt)/(at+l1.at)
gen chgrec = (rect-l1.rect)/(at+l1.at)
gen l1at=l1.at
gen at_avg=[at+l1at]/2
gen ocf_a1=oancf/l1at
gen prod_a1=[cogs+invt-l1.invt]/l1at
gen disexp_a1=[xrd+xad+xsga]/l1at
gen a_inv=1/l1at
gen s_a1=sale/l1at
gen s_chg=sale-l1.sale
gen s_chg_a1=s_chg/l1at
gen l1s_chg_a1=l1.s_chg/l1at
gen l1s_a1=l1.sale/l1at
gen tacc_a1=[ibc-oancf]/l1at
gen revt_rect_a1=[[revt-l1.revt]-[rect-l1.rect]]/l1at
gen ppegt_a1=ppegt/l1at
gen wc_chg_a1=[[act-l1.act]-[lct-l1.lct]-[che-l1.che]+[dlc-l1.dlc]]/at_avg
gen cffo_a1=[ib-[[act-l1.act]-[lct-l1.lct]-[che-l1.che]+[dlc-l1.dlc]-[dp]]]/l1at
gen l1cffo_a1=l1.cffo_a1
gen f1cffo_a1=f1.cffo_a1
gen roa=ibc/l1at
gen l1roa=l1.roa
gen roa_chg=roa-l1roa
sort sic
save "compustat2.dta", replace

*calculate abnormal operating cash flows
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear ocf_a1 a_inv s_a1 s_chg_a1 ff49
keep if !missing(ocf_a1, a_inv, s_a1, s_chg_a1)
foreach i of varlist ocf_a1 a_inv s_a1 s_chg_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen ocf_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg ocf_a1 a_inv s_a1 s_chg_a1 if newid2==`i'
	capture predict ocf_a1_err_temp, residuals
	capture replace ocf_a1_err=ocf_a1_err_temp if newid2==`i' & missing(ocf_a1_err) & !missing(ocf_a1_err_temp)
	capture drop ocf_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 ocf_a1_err
save "compustatff49_a1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_a1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_a1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear ocf_a1_err
sort gvkey fyear
save "compustatff49_a1_11.dta", replace

*calculate abnormal production costs
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear prod_a1 a_inv s_a1 s_chg_a1 l1s_chg_a1 ff49    
qui keep if !missing(prod_a1, a_inv, s_a1, s_chg_a1, l1s_chg_a1)
foreach i of varlist prod_a1 a_inv s_a1 s_chg_a1 l1s_chg_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen prod_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg prod_a1 a_inv s_a1 s_chg_a1 l1s_chg_a1 if newid2==`i'
	capture predict prod_a1_err_temp, residuals
	capture replace prod_a1_err=prod_a1_err_temp if newid2==`i' & missing(prod_a1_err) & !missing(prod_a1_err_temp)
	capture drop prod_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 prod_a1_err
save "compustatff49_b1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_b1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_b1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear prod_a1_err
sort gvkey fyear
save "compustatff49_b1_11.dta", replace

*calculate abnormal discretionary expenses
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear disexp_a1 a_inv l1s_a1 ff49    
qui keep if !missing(disexp_a1, a_inv, l1s_a1)
foreach i of varlist disexp_a1 a_inv l1s_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen disexp_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg disexp_a1 a_inv l1s_a1 if newid2==`i'
	capture predict disexp_a1_err_temp, residuals
	capture replace disexp_a1_err=disexp_a1_err_temp if newid2==`i' & missing(disexp_a1_err) & !missing(disexp_a1_err_temp)
	capture drop disexp_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 disexp_a1_err
save "compustatff49_c1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_c1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_c1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear disexp_a1_err
sort gvkey fyear
save "compustatff49_c1_11.dta", replace

*calculate discretionary accruals
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear tacc_a1 a_inv revt_rect_a1 l1roa ppegt_a1 ff49    
qui keep if !missing(tacc_a1, a_inv, revt_rect_a1, ppegt_a1, l1roa)
foreach i of varlist tacc_a1 a_inv revt_rect_a1 l1roa ppegt_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49 newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen tacc_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg tacc_a1 a_inv revt_rect_a1 ppegt_a1 l1roa if newid2==`i'
	capture predict tacc_a1_err_temp, residuals
	capture replace tacc_a1_err=tacc_a1_err_temp if newid2==`i' & missing(tacc_a1_err) & !missing(tacc_a1_err_temp)
	capture drop tacc_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 tacc_a1_err
save "compustatff49_d1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_d1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_d1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear tacc_a1_err
sort gvkey fyear
save "compustatff49_d1_11.dta", replace

*calculate abnormal working capital accruals
clear
local j=1
while `j'<=10 {
use "compustat2.dta", clear
keep gvkey fyear wc_chg_a1 l1cffo_a1 cffo_a1 f1cffo_a1 s_chg_a1 ppegt_a1 ff49    
qui keep if !missing(wc_chg_a1, l1cffo_a1, cffo_a1, f1cffo_a1, s_chg_a1, ppegt_a1)
foreach i of varlist wc_chg_a1 l1cffo_a1 cffo_a1 f1cffo_a1 s_chg_a1 ppegt_a1 {
winsor `i', gen(`i'_w) p(0.01)
drop `i'
rename `i'_w `i'
}
sort ff49 fyear
qui egen newid2=group(ff49 fyear)
xtile newid2_nq=newid2, nq(10)
qui keep if newid2_nq==`j'
drop ff49     newid2_nq
egen newid2_min=min(newid2)
egen newid2_max=max(newid2)
qui gen wc_chg_a1_err=.
local i= newid2_min
while `i'<=newid2_max {
	capture ereturn clear
	capture reg wc_chg_a1 l1cffo_a1 cffo_a1 f1cffo_a1 s_chg_a1 ppegt_a1 if newid2==`i'
	capture predict wc_chg_a1_err_temp, residuals
	capture replace wc_chg_a1_err=wc_chg_a1_err_temp if newid2==`i' & missing(wc_chg_a1_err) & !missing(wc_chg_a1_err_temp)
	capture drop wc_chg_a1_pred_temp
	capture drop wc_chg_a1_err_temp
	local i=`i'+1
}
keep gvkey fyear newid2 wc_chg_a1_err
save "compustatff49_e1_`j'.dta", replace
local j=`j'+1
}
use "compustatff49_e1_1.dta", clear
local j=2
while `j'<=10 {
append using "compustatff49_e1_`j'.dta"
local j=`j'+1
}
bysort newid2: egen newid2_num=count(newid2)
keep if newid2_num>=15
keep gvkey fyear wc_chg_a1_err
sort gvkey fyear
save "compustatff49_e1_11.dta", replace

*merge earnings management proxies
use "compustat2.dta", clear
merge 1:1 gvkey fyear using "compustatff49_a1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_b1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_c1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_d1_11.dta", keep(master match) nogen
merge 1:1 gvkey fyear using "compustatff49_e1_11.dta", keep(master match) nogen
sort gvkey fyear
save "compustatEM.dta", replace

*CRSP Merge
use "crsp.dta", clear
sort permno date
save "crsp.dta", replace

use "crsppermnolink.dta", clear
sort permno
by permno: keep if _n==1
save "crsppermnolink.dta", replace

merge 1:m permno using "crsp.dta", keep(master match) nogen
destring gvkey, replace
gen year = year(date)
sort gvkey year
bysort gvkey: keep if _n == 1
gen firstyear = year
drop year date
save "crspfirstyear.dta", replace

use "compustatEM.dta", clear
merge m:1 gvkey using "crspfirstyear.dta", keep(master match) nogen
gen firmage = fyear - firstyear
replace firmage = _n if firmage < 1
destring cik, replace
bysort cik fyear: keep if _n==1
save "compustatEM2.dta", replace

*Audit Analytics Merge
use "internalcontrols.dta", clear
bysort cik fyear: keep if _n == 1
save "internalcontrols.dta", replace

use "auditfees.dta", clear
bysort cik fyear: keep if _n == 1
save "auditfees.dta", replace

use "compustatEM2.dta", clear
merge 1:1 cik fyear using "internalcontrols.dta", keep(master match) nogen
merge 1:1 cik fyear using "auditfees.dta", keep(master match) nogen
save "compustatauditfees.dta", replace

*Restatements and Controls
use "restatements.dta", clear
sort cik
gen yearbegin = year(restatebegin)
gen yearend = year(restateend)
by cik: gen yearbegin1 = year(restatebegin[_n+1]) if !missing(restatebegin[_n+1])
by cik: gen yearend1 = year(restateend[_n+1]) if !missing(restateend[_n+1])
by cik: gen yearbegin2 = year(restatebegin[_n+2]) if !missing(restatebegin[_n+2])
by cik: gen yearend2 = year(restateend[_n+2]) if !missing(restateend[_n+2])
by cik: gen yearbegin3 = year(restatebegin[_n+3]) if !missing(restatebegin[_n+3])
by cik: gen yearend3 = year(restateend[_n+3]) if !missing(restateend[_n+3])
by cik: gen yearbegin4 = year(restatebegin[_n+4]) if !missing(restatebegin[_n+4])
by cik: gen yearend4 = year(restateend[_n+4]) if !missing(restateend[_n+4])
by cik: gen yearbegin5 = year(restatebegin[_n+5]) if !missing(restatebegin[_n+5])
by cik: gen yearend5 = year(restateend[_n+5]) if !missing(restateend[_n+5])
by cik: gen yearbegin6 = year(restatebegin[_n+6]) if !missing(restatebegin[_n+6])
by cik: gen yearend6 = year(restateend[_n+6]) if !missing(restateend[_n+6])
by cik: gen yearbegin7 = year(restatebegin[_n+7]) if !missing(restatebegin[_n+7])
by cik: gen yearend7 = year(restateend[_n+7]) if !missing(restateend[_n+7])
by cik: gen yearbegin8 = year(restatebegin[_n+8]) if !missing(restatebegin[_n+8])
by cik: gen yearend8 = year(restateend[_n+8]) if !missing(restateend[_n+8])
by cik: gen yearbegin9 = year(restatebegin[_n+9]) if !missing(restatebegin[_n+9])
by cik: gen yearend9 = year(restateend[_n+9]) if !missing(restateend[_n+9])
by cik: gen yearbegin10 = year(restatebegin[_n+10]) if !missing(restatebegin[_n+10])
by cik: gen yearend10 = year(restateend[_n+10]) if !missing(restateend[_n+10])
by cik: keep if _n==1
save "restatements2.dta", replace

use "compustatauditfees.dta", clear
merge m:1 cik using "restatements2.dta", keep(master match) nogen
gen restatement = 0
replace restatement = 1 if fyear >= yearbegin & fyear <= yearend
replace restatement = 1 if fyear >= yearbegin1 & fyear <= yearend1
replace restatement = 1 if fyear >= yearbegin2 & fyear <= yearend2
replace restatement = 1 if fyear >= yearbegin3 & fyear <= yearend3
replace restatement = 1 if fyear >= yearbegin4 & fyear <= yearend4
replace restatement = 1 if fyear >= yearbegin5 & fyear <= yearend5
replace restatement = 1 if fyear >= yearbegin6 & fyear <= yearend6
replace restatement = 1 if fyear >= yearbegin7 & fyear <= yearend7
replace restatement = 1 if fyear >= yearbegin8 & fyear <= yearend8
replace restatement = 1 if fyear >= yearbegin9 & fyear <= yearend9
replace restatement = 1 if fyear >= yearbegin10 & fyear <= yearend10
gen effcontrols = 1
replace effcontrols = 0 if controlseffective == "No"
replace effcontrols = . if fyear < 2004
replace effcontrols = . if auditfees == .
replace numweakness = 0 if numweakness == .
replace numweakness = . if fyear < 2004
replace numweakness = . if auditfees == .
gen leverage = (dltt+dlc)/ceq
gen salesgrowth = (revt-revt[_n-3])/revt[_n-3]
gen btm = ceq/(csho*prcc_f)
gen size = ln(at)
drop yearbegin* yearend*
save "compustatrestatements.dta", replace

*Signatures and Characteristics Processing
use "Signatures_Master_Sample.dta", clear
drop firmnumber firmname titleann
drop if ceo != 1 & cfo != 1
gen apl = area/length(signedname)
sort gvkey execid fyear
save "signatures2.dta", replace

use "execucomp.dta", clear
destring gvkey execid, replace
rename year fyear
save "execucomp.dta", replace

use "signatures2.dta", clear
merge 1:1 gvkey execid fyear using "execucomp.dta", keep(master match) nogen
drop if apl == .
sort gvkey execid fyear
by gvkey execid fyear: keep if _n == 1
gen female = gender == "FEMALE"
by gvkey execid: gen tenure = _n
keep if legible > 0
sort gvkey execid fyear
save "signatures3.dta", replace

*Import Delta/Vega Data From Coles, Daniel, and Naveen (2006)
insheet using "deltavega.csv", clear
rename year fyear
rename coperol co_per_rol
merge 1:1 gvkey co_per_rol fyear using "execucomp.dta", keep(master match) keepusing(tdc1 execid) nogen
replace delta=delta/tdc1
replace vega=vega/tdc1
bysort gvkey execid fyear: keep if _n==1
save "deltavega.dta", replace

use "signatures3.dta", clear
merge 1:1 gvkey execid fyear using "deltavega.dta", keep(master match) nogen
sort gvkey fyear execid
save "signatures4.dta", replace

*Compustat and Signatures Merge
use "compustatrestatements.dta", clear
bysort gvkey fyear: keep if _n==1
save "compustatrestatements.dta", replace

use "signatures4.dta", clear
merge m:1 gvkey fyear using "compustatrestatements.dta", keep(master match) nogen
bysort gvkey execid fyear: keep if _n==1
gen scauditfees = (auditfees/l1at)
gen sic2 = floor(sic/100)
tabulate(sic2), gen(sicdum)
gen abstacc = abs(tacc_a1_err)
sort gvkey execid fyear
gen cfovolat = cfovolatility/at
gen salesvolat = salesvolatility/at
gen inventories = invt/at
foreach i of varlist size btm firmage leverage salesgrowth cfovolat salesvolat percchgcashsales earningsprice chgroa delta vega inventories numweakness chginv chgrec apl tenure scauditfees {
winsor `i', gen(`i'_w) p(0.01)
}
save "compustatsignatures.dta", replace

*Accruals Earnings Management Regressions
areg abstacc apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Absolute Discretionary Accruals) adjr2 excel
areg wc_chg_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Accruals Quality) adjr2 excel

areg abstacc apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Absolute Discretionary Accruals) adjr2 excel
areg wc_chg_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w chgroa_w earningsprice_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Accruals Quality) adjr2 excel

*Real Earnings Management Regressions
areg disexp_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Abnormal Expenses) adjr2 excel
areg ocf_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Abnormal Cash Flows) adjr2 excel
areg prod_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if cfo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Abnormal Production) adjr2 excel

areg disexp_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Abnormal Expenses) adjr2 excel
areg ocf_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Abnormal Cash Flows) adjr2 excel
areg prod_a1_err apl_w size_w btm_w firmage_w leverage_w l1loss cfovolat_w salesvolat_w percchgcashsales_w earningsprice_w chgroa_w female tenure_w delta_w vega_w if ceo == 1, absorb(sic2) cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Abnormal Production) adjr2 excel

*Internal Controls Regressions
ologit effcontrols apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if cfo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Effective Controls) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel
ologit numweakness apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if cfo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Number Weaknesses) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

ologit effcontrols apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if ceo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Effective Controls) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel
ologit numweakness apl_w size_w btm_w firmage_w leverage_w percloss salesgrowth_w inventories_w scauditfees_w female tenure_w i.sic2 if ceo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Number Weaknesses) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

*Restatement Regressions
ologit restatement apl_w size_w btm_w firmage_w leverage_w chginv_w chgrec_w percchgcashsales_w earningsprice_w chgroa_w scauditfees_w female tenure_w delta_w vega_w i.sic2 if cfo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CFO Restatements) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

ologit restatement apl_w size_w btm_w firmage_w leverage_w chginv_w chgrec_w percchgcashsales_w earningsprice_w chgroa_w scauditfees_w female tenure_w delta_w vega_w i.sic2 if ceo == 1, cluster(gvkey)
outreg2 using finaltables.xls, se bdec(3) append ctitle(CEO Restatements) addstat("Pseudo R-squared", 1-e(ll)/e(ll_0)) excel

*Conservatism Processing
use "crspreturns.dta", clear
gen newcusip = cusip
gen year = year(date)
gen month = month(date)
sort newcusip year month
by newcusip: gen cumret = ((1+ret[_n-8])*(1+ret[_n-7])*(1+ret[_n-6])*(1+ret[_n-5])*(1+ret[_n-4])*(1+ret[_n-3])*(1+ret[_n-2])*(1+ret[_n-1])*(1+ret)*(1+ret[_n+1])*(1+ret[_n+2])*(1+ret[_n+3]))-1
by newcusip: gen ewmktret = ((1+ewretd[_n-8])*(1+ewretd[_n-7])*(1+ewretd[_n-6])*(1+ewretd[_n-5])*(1+ewretd[_n-4])*(1+ewretd[_n-3])*(1+ewretd[_n-2])*(1+ewretd[_n-1])*(1+ewretd)*(1+ewretd[_n+1])*(1+ewretd[_n+2])*(1+ewretd[_n+3]))-1
gen ewcumret = cumret-ewmktret
save "crspreturns2.dta", replace

*CFO Conservatism 
use "compustatsignatures.dta", clear
keep if cfo == 1
gen newcusip = substr(cusip,1,8)
gen year = year(datadate)
gen month = month(datadate)
bysort newcusip year month: keep if _n==1
merge 1:1 newcusip year month using "crspreturns2.dta", keep(master match) nogen
drop if ff49 == 31 | ff49 >= 45
sort gvkey fyear
xtset gvkey fyear
gen roe=ib/[l1.csho*l1.prcc_f]
gen logmve=ln(csho*prcc_f)
gen lev=(dltt+dlc)/ceq
gen mtb=[csho*prcc_f]/ceq
keep gvkey fyear sic2 apl_w tenure_w female roe logmve lev mtb ewcumret
rename ewcumret ret
drop if missing(roe, ret)
foreach i of varlist roe logmve lev mtb ret {
winsor `i', gen(`i'_w) p(0.01)
}
gen d = ret<0 if !missing(ret)
gen d_ret_w = d*ret_w
qui foreach i of varlist logmve_w mtb_w lev_w apl_w tenure_w female {
gen ret_w_`i'=ret_w*`i'
gen d_`i'=d*`i'
gen d_ret_w_`i'=d*ret_w*`i'
}

*CFO Conservatism Regression
areg roe_w d ret_w d_ret_w apl_w d_apl_w ret_w_apl_w d_ret_w_apl_w logmve_w d_logmve_w ret_w_logmve_w d_ret_w_logmve_w mtb_w d_mtb_w ret_w_mtb_w d_ret_w_mtb_w lev_w d_lev_w ret_w_lev_w d_ret_w_lev_w tenure_w d_tenure_w ret_w_tenure_w d_ret_w_tenure_w female d_female ret_w_female d_ret_w_female, absorb(sic2) cluster(gvkey)
outreg2 using conservatism.xls, se bdec(3) append ctitle(CFO Conservatism) adjr2 excel

*CEO Conservatism 
use "compustatsignatures.dta", clear
keep if ceo == 1
gen newcusip = substr(cusip,1,8)
gen year = year(datadate)
gen month = month(datadate)
bysort newcusip year month: keep if _n==1
merge 1:1 newcusip year month using "crspreturns2.dta", keep(master match) nogen
drop if ff49 == 31 | ff49 >= 45
sort gvkey fyear
bysort gvkey fyear: keep if _n==1
xtset gvkey fyear
gen roe=ib/[l1.csho*l1.prcc_f]
gen logmve=ln(csho*prcc_f)
gen lev=(dltt+dlc)/ceq
gen mtb=[csho*prcc_f]/ceq
keep gvkey fyear sic2 apl_w tenure_w female roe logmve lev mtb ewcumret
rename ewcumret ret
drop if missing(roe, ret)
foreach i of varlist roe logmve lev mtb ret {
winsor `i', gen(`i'_w) p(0.01)
}
gen d = ret<0 if !missing(ret)
gen d_ret_w = d*ret_w
qui foreach i of varlist logmve_w mtb_w lev_w apl_w tenure_w female {
gen ret_w_`i'=ret_w*`i'
gen d_`i'=d*`i'
gen d_ret_w_`i'=d*ret_w*`i'
}

*CEO Conservatism Regression
areg roe_w d ret_w d_ret_w apl_w d_apl_w ret_w_apl_w d_ret_w_apl_w logmve_w d_logmve_w ret_w_logmve_w d_ret_w_logmve_w mtb_w d_mtb_w ret_w_mtb_w d_ret_w_mtb_w lev_w d_lev_w ret_w_lev_w d_ret_w_lev_w tenure_w d_tenure_w ret_w_tenure_w d_ret_w_tenure_w female d_female ret_w_female d_ret_w_female, absorb(sic2) cluster(gvkey)
outreg2 using conservatism.xls, se bdec(3) append ctitle(CEO Conservatism) adjr2 excel


****************************************************************************************************
* Conduct experimental mediation analysis
****************************************************************************************************


*Paste experimental data from Microsoft Excel into Stata data editor, then estimate mediation analysis regressions
reg monetaryallocation signaturesize
reg monetaryallocation narcissism
reg narcissism signaturesize
reg monetaryallocation signaturesize narcissism


****************************************************************************************************
* End
****************************************************************************************************

