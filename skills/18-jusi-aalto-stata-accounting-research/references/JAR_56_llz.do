***********************************************************************************************************************************************************************************
*********** This program is use to conduct further data cleaning and the estimations of models in Table 2. The input data (all data5.dta)is the output based on CODE1 and CODE2. **
***********************************************************************************************************************************************************************************
clear all
set memory 1g
use "C:\Users\Dropbox\IDD and disclosure\regression data\all data5.dta", clear

*****generate year, state, and industry  indicator*******

drop if  gdpgr==.
tabulate year, generate(dumt)
tabulate ba_state, generate(dums)

destring sic, generate(sic2)

gen sic_2digi=int(sic2/100)
tabulate sic_2digi, generate(ndumi)
egen state_year=group(ba_state fyear)
egen industry_year=group(sic_2digi fyear)


****normalize and winsorize the variables***
replace hide_ratio_sale=1 if hide_ratio_sale==.
gen lnhide_ratio=ln(hide_ratio+1)
gen lnhide_ratio_sale=ln(hide_ratio_sale+1)
replace  nanalysts=0 if  nanalysts==.

local control "rd_to_sales intangible_to_at advertise_to_sale lnat abroa_persistence "
		foreach v of varlist `control'{

	    winsor `v', gen (`v'_2) p(0.01)
		}

*****Drop financial firms and firms without principle customers (10%<=csales%)*******

drop if   6000<=sic2&sic2<=6999
drop if lnat==. 
replace  manextyear=0 if  manextyear==.
replace seonextyear=0 if seonextyear==.
egen id=group(sic_2digi fyear)
egen id2=group(id ba_state)

*********deleting firm without principle customers********
drop if salecs_dum==0


********************** summary statistics***************************
estpost tabstat   post ,by(ba_state) statistics(n mean median sd) columns(statistics) 

estpost tabstat hide_ratio hide_ratio_sale  post  intangible_to_at_2 advertise_to_sale_2 lnat_2 abroa_persistence_2 bign hhi mis_rd rd_to_sales_2   nanalysts ratio2 manextyear seonextyear gdpgr unemployment   ///
, statistics(n mean median sd) columns(statistics) listwise

*****************************Main Table******************************
est clear

areg  lnhide_ratio post mis_rd rd_to_sales_2 intangible_to_at_2 advertise_to_sale_2 lnat_2    bign  hhi manextyear seonextyear gdpgr unemployment dumt* dums* , a(sic_2digi) cluster(ba_state) robust
est store idd1

areg  lnhide_ratio_sale post mis_rd rd_to_sales_2 intangible_to_at_2 advertise_to_sale_2 lnat_2   bign hhi manextyear seonextyear gdpgr unemployment dumt* dums*, a(sic_2digi) cluster(ba_state) robust
est store idd2


areg  lnhide_ratio post mis_rd rd_to_sales_2 intangible_to_at_2 advertise_to_sale_2 lnat_2  bign  hhi manextyear seonextyear gdpgr unemployment dumt* dums*, a(gvkey) cluster(ba_state) robust
est store idd3

areg  lnhide_ratio_sale post mis_rd  rd_to_sales_2 intangible_to_at_2 advertise_to_sale_2 lnat_2   bign hhi manextyear seonextyear gdpgr unemployment dumt* dums*, a(gvkey) cluster(ba_state) robust
est store idd4


esttab idd* using IDD_TABLE2.csv, replace scalar(r2_p r2_a N F) compress star(* 0.1 ** 0.05 *** 0.01) b(%6.3f) se(%6.3f)  nogap
