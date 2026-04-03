

*********************************************************************
**** CODE FOR PAPER "FRAUD ALLEGATIONS AND GOVERNMENT CONTRACTING" 
*****             BY JONAS HEESE AND GERARDO PEREZ CAVAZOS 
*************************************************************************

cap log close
clear 
clear mata
clear matrix
set mem 700m, permanently
set maxvar 32767, permanently
set matsize 11000


global  jarpaper "C:\Users\......."
use "$jarpaper\final_data", replace 

tsset gvkeyn yq_n2

**********************************************************************************************
****  REGRESSIONS 
**********************************************************************************************

**********************************************************************************************
*** generate variables
**********************************************************************************************

gen log_at = log(1+atq)
gen lev= ltq/seq
gen cogs = cogsq/l.saleq

generate sic2 = int(sic/100)
bysort sic2 fyearq: egen total_rev = sum(revtq)
bysort sic2 fyearq: gen mktshare = revtq/total_rev
bysort sic2 fyearq: egen hhi = sum(mktshare^2)
egen comp_med = median(hhi)
gen high_comp =1 if hhi<comp_med
replace high_comp=0 if high_comp==.

label variable log_at "Size"
label variable hhi "HHI"
label variable cogs "COGS"
label variable lev "Leverage"

*******************************
******* TABLE 2 
*****************************************************

sum   dollars_contract_sum    def_total_sum   pct_def_agency    cost_total_sum def_cost_total_sum pct_cost_def_agency  service_total_sum pct_cost_service  product_total_sum pct_cost_product  rd_total_sum pct_cost_rd atq hhi  cogs lev , d

***** REGRESSIONS:

*Treatment variable
gen w8q=1 if post_1==1
replace w8q=1 if post_2==1
replace w8q=1 if post_3==1
replace w8q=1 if post_4==1
replace w8q=1 if post_5==1
replace w8q=1 if post_6==1
replace w8q=1 if post_7==1
replace w8q=1 if post_8==1
replace w8q=0 if  w8q==.


***TABLE 3 
areg  pct_def_agency w8q  log_at hhi cogs lev  i.fyearq  if  (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn) cluster(gvkeyn)  
gen intable3= e(sample)
areg  pct_def_agency w8q  log_at hhi cogs lev   i.def_ag##i.fyearq i.def_ag##i.fqtr  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)    
areg  pct_def_agency w8q  log_at hhi cogs lev   i.def_ag##i.fyearq i.def_ag##i.fqtr i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)    


***TABLE 4 
areg  pct_cost_def_agency w8q  log_at hhi cogs  lev  i.fyearq   if  (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn)  cluster(gvkeyn)  
gen intable4 = e(sample)
areg pct_cost_def_agency w8q  log_at hhi cogs  lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr   if intable4==1 , absorb(gvkeyn) cluster(gvkeyn)  
areg pct_cost_def_agency w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if intable4==1  ,  absorb(gvkeyn) cluster(gvkeyn) 

*****Table 5
***panel A

** Service
areg pct_def_agency_service w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_def_agency_service w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** Product
areg pct_def_agency_product w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_def_agency_product w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** R&D
areg pct_def_agency_rd w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_def_agency_rd w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

***panel B
** Service
areg pct_cost_def_agency_service w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_cost_def_agency_service w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** Product
areg pct_cost_def_agency_product w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_cost_def_agency_product w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** R&D
areg pct_cost_def_agency_rd w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_cost_def_agency_rd w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

*****Table 7 
reghdfe  pct_cost_def_agency pre_3 pre_4 pre_5 pre_6 pre_7 pre_8 post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8  log_at hhi cogs  lev i.fqtr if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | fraudq==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn)  cluster(gvkeyn) 

*****Table 8 
*****Panel A
areg  pct_def_agency c.w8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  

*****Panel B
areg  pct_cost_def_agency c.w8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  

*****Table 9 
*****Panel A

**Alternative Treatment: compare eight quarters prior to the whistleblower allegation to the eight quarters following the DOJ's intervention decision 
gen inter8q=1 if inter_1==1
replace inter8q=1 if inter_2==1
replace inter8q=1 if inter_3==1
replace inter8q=1 if inter_4==1
replace inter8q=1 if inter_5==1
replace inter8q=1 if inter_6==1
replace inter8q=1 if inter_7==1
replace inter8q=1 if inter_8==1
replace inter8q=0 if  inter8q==.

areg  pct_def_agency inter8q  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | inter_1==1 | inter_2==1 | inter_3==1 | inter_4==1 | inter_5==1 | inter_6==1 | inter_7==1 | inter_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn) cluster(gvkeyn)  
gen intable9a = e(sample)
areg  pct_def_agency c.inter8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if   if  intable9a==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.inter8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9a==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.inter8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9a==1, absorb(gvkeyn) cluster(gvkeyn)  

*****Panel B
areg  pct_cost_def_agency c.inter8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | inter_1==1 | inter_2==1 | inter_3==1 | inter_4==1 | inter_5==1 | inter_6==1 | inter_7==1 | inter_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn) cluster(gvkeyn)
gen intable9b = e(sample)
areg  pct_cost_def_agency c.inter8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9b==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.inter8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9b==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.inter8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9b==1, absorb(gvkeyn) cluster(gvkeyn)  

***Table 10
**Panel A
areg  pct_def_agency c.w8q##c.pc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.logsumpc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.largest_100_Max  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.connectedboard  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  

**Panel B
areg  pct_cost_def_agency c.w8q##c.pc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.logsumpc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.largest_100_Max  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.connectedboard  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  













*********************************************************************
**** CODE FOR PAPER "FRAUD ALLEGATIONS AND GOVERNMENT CONTRACTING" 
*****             BY JONAS HEESE AND GERARDO PEREZ CAVAZOS 
*************************************************************************

cap log close
clear 
clear mata
clear matrix
set mem 700m, permanently
set maxvar 32767, permanently
set matsize 11000


global  jarpaper "C:\Users\......."
use "$jarpaper\final_data", replace 

tsset gvkeyn yq_n2

**********************************************************************************************
****  REGRESSIONS 
**********************************************************************************************

**********************************************************************************************
*** generate variables
**********************************************************************************************

gen log_at = log(1+atq)
gen lev= ltq/seq
gen cogs = cogsq/l.saleq

generate sic2 = int(sic/100)
bysort sic2 fyearq: egen total_rev = sum(revtq)
bysort sic2 fyearq: gen mktshare = revtq/total_rev
bysort sic2 fyearq: egen hhi = sum(mktshare^2)
egen comp_med = median(hhi)
gen high_comp =1 if hhi<comp_med
replace high_comp=0 if high_comp==.

label variable log_at "Size"
label variable hhi "HHI"
label variable cogs "COGS"
label variable lev "Leverage"

*******************************
******* TABLE 2 
*****************************************************

sum   dollars_contract_sum    def_total_sum   pct_def_agency    cost_total_sum def_cost_total_sum pct_cost_def_agency  service_total_sum pct_cost_service  product_total_sum pct_cost_product  rd_total_sum pct_cost_rd atq hhi  cogs lev , d

***** REGRESSIONS:

*Treatment variable
gen w8q=1 if post_1==1
replace w8q=1 if post_2==1
replace w8q=1 if post_3==1
replace w8q=1 if post_4==1
replace w8q=1 if post_5==1
replace w8q=1 if post_6==1
replace w8q=1 if post_7==1
replace w8q=1 if post_8==1
replace w8q=0 if  w8q==.


***TABLE 3 
areg  pct_def_agency w8q  log_at hhi cogs lev  i.fyearq  if  (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn) cluster(gvkeyn)  
gen intable3= e(sample)
areg  pct_def_agency w8q  log_at hhi cogs lev   i.def_ag##i.fyearq i.def_ag##i.fqtr  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)    
areg  pct_def_agency w8q  log_at hhi cogs lev   i.def_ag##i.fyearq i.def_ag##i.fqtr i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)    


***TABLE 4 
areg  pct_cost_def_agency w8q  log_at hhi cogs  lev  i.fyearq   if  (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn)  cluster(gvkeyn)  
gen intable4 = e(sample)
areg pct_cost_def_agency w8q  log_at hhi cogs  lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr   if intable4==1 , absorb(gvkeyn) cluster(gvkeyn)  
areg pct_cost_def_agency w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if intable4==1  ,  absorb(gvkeyn) cluster(gvkeyn) 

*****Table 5
***panel A

** Service
areg pct_def_agency_service w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_def_agency_service w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** Product
areg pct_def_agency_product w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_def_agency_product w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** R&D
areg pct_def_agency_rd w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_def_agency_rd w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

***panel B
** Service
areg pct_cost_def_agency_service w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_cost_def_agency_service w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** Product
areg pct_cost_def_agency_product w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_cost_def_agency_product w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** R&D
areg pct_cost_def_agency_rd w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_cost_def_agency_rd w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

*****Table 7 
reghdfe  pct_cost_def_agency pre_3 pre_4 pre_5 pre_6 pre_7 pre_8 post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8  log_at hhi cogs  lev i.fqtr if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | fraudq==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn)  cluster(gvkeyn) 

*****Table 8 
*****Panel A
areg  pct_def_agency c.w8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  

*****Panel B
areg  pct_cost_def_agency c.w8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  

*****Table 9 
*****Panel A

**Alternative Treatment: compare eight quarters prior to the whistleblower allegation to the eight quarters following the DOJ's intervention decision 
gen inter8q=1 if inter_1==1
replace inter8q=1 if inter_2==1
replace inter8q=1 if inter_3==1
replace inter8q=1 if inter_4==1
replace inter8q=1 if inter_5==1
replace inter8q=1 if inter_6==1
replace inter8q=1 if inter_7==1
replace inter8q=1 if inter_8==1
replace inter8q=0 if  inter8q==.

areg  pct_def_agency inter8q  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | inter_1==1 | inter_2==1 | inter_3==1 | inter_4==1 | inter_5==1 | inter_6==1 | inter_7==1 | inter_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn) cluster(gvkeyn)  
gen intable9a = e(sample)
areg  pct_def_agency c.inter8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if   if  intable9a==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.inter8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9a==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.inter8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9a==1, absorb(gvkeyn) cluster(gvkeyn)  

*****Panel B
areg  pct_cost_def_agency c.inter8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | inter_1==1 | inter_2==1 | inter_3==1 | inter_4==1 | inter_5==1 | inter_6==1 | inter_7==1 | inter_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn) cluster(gvkeyn)
gen intable9b = e(sample)
areg  pct_cost_def_agency c.inter8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9b==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.inter8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9b==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.inter8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9b==1, absorb(gvkeyn) cluster(gvkeyn)  

***Table 10
**Panel A
areg  pct_def_agency c.w8q##c.pc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.logsumpc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.largest_100_Max  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.connectedboard  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  

**Panel B
areg  pct_cost_def_agency c.w8q##c.pc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.logsumpc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.largest_100_Max  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.connectedboard  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  













*********************************************************************
**** CODE FOR PAPER "FRAUD ALLEGATIONS AND GOVERNMENT CONTRACTING" 
*****             BY JONAS HEESE AND GERARDO PEREZ CAVAZOS 
*************************************************************************

cap log close
clear 
clear mata
clear matrix
set mem 700m, permanently
set maxvar 32767, permanently
set matsize 11000


global  jarpaper "C:\Users\......."
use "$jarpaper\final_data", replace 

tsset gvkeyn yq_n2

**********************************************************************************************
****  REGRESSIONS 
**********************************************************************************************

**********************************************************************************************
*** generate variables
**********************************************************************************************

gen log_at = log(1+atq)
gen lev= ltq/seq
gen cogs = cogsq/l.saleq

generate sic2 = int(sic/100)
bysort sic2 fyearq: egen total_rev = sum(revtq)
bysort sic2 fyearq: gen mktshare = revtq/total_rev
bysort sic2 fyearq: egen hhi = sum(mktshare^2)
egen comp_med = median(hhi)
gen high_comp =1 if hhi<comp_med
replace high_comp=0 if high_comp==.

label variable log_at "Size"
label variable hhi "HHI"
label variable cogs "COGS"
label variable lev "Leverage"

*******************************
******* TABLE 2 
*****************************************************

sum   dollars_contract_sum    def_total_sum   pct_def_agency    cost_total_sum def_cost_total_sum pct_cost_def_agency  service_total_sum pct_cost_service  product_total_sum pct_cost_product  rd_total_sum pct_cost_rd atq hhi  cogs lev , d

***** REGRESSIONS:

*Treatment variable
gen w8q=1 if post_1==1
replace w8q=1 if post_2==1
replace w8q=1 if post_3==1
replace w8q=1 if post_4==1
replace w8q=1 if post_5==1
replace w8q=1 if post_6==1
replace w8q=1 if post_7==1
replace w8q=1 if post_8==1
replace w8q=0 if  w8q==.


***TABLE 3 
areg  pct_def_agency w8q  log_at hhi cogs lev  i.fyearq  if  (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn) cluster(gvkeyn)  
gen intable3= e(sample)
areg  pct_def_agency w8q  log_at hhi cogs lev   i.def_ag##i.fyearq i.def_ag##i.fqtr  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)    
areg  pct_def_agency w8q  log_at hhi cogs lev   i.def_ag##i.fyearq i.def_ag##i.fqtr i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)    


***TABLE 4 
areg  pct_cost_def_agency w8q  log_at hhi cogs  lev  i.fyearq   if  (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn)  cluster(gvkeyn)  
gen intable4 = e(sample)
areg pct_cost_def_agency w8q  log_at hhi cogs  lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr   if intable4==1 , absorb(gvkeyn) cluster(gvkeyn)  
areg pct_cost_def_agency w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if intable4==1  ,  absorb(gvkeyn) cluster(gvkeyn) 

*****Table 5
***panel A

** Service
areg pct_def_agency_service w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_def_agency_service w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** Product
areg pct_def_agency_product w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_def_agency_product w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** R&D
areg pct_def_agency_rd w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_def_agency_rd w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

***panel B
** Service
areg pct_cost_def_agency_service w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_cost_def_agency_service w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** Product
areg pct_cost_def_agency_product w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_cost_def_agency_product w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

** R&D
areg pct_cost_def_agency_rd w8q log_at hhi cogs   lev  i.fyearq if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 
areg pct_cost_def_agency_rd w8q log_at hhi cogs   lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq   if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013,  absorb(gvkeyn) cluster(gvkeyn) 

*****Table 7 
reghdfe  pct_cost_def_agency pre_3 pre_4 pre_5 pre_6 pre_7 pre_8 post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8  log_at hhi cogs  lev i.fqtr if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | fraudq==1 | post_1==1 | post_2==1 | post_3==1 | post_4==1 | post_5==1 | post_6==1 | post_7==1 | post_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn)  cluster(gvkeyn) 

*****Table 8 
*****Panel A
areg  pct_def_agency c.w8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  

*****Panel B
areg  pct_cost_def_agency c.w8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  

*****Table 9 
*****Panel A

**Alternative Treatment: compare eight quarters prior to the whistleblower allegation to the eight quarters following the DOJ's intervention decision 
gen inter8q=1 if inter_1==1
replace inter8q=1 if inter_2==1
replace inter8q=1 if inter_3==1
replace inter8q=1 if inter_4==1
replace inter8q=1 if inter_5==1
replace inter8q=1 if inter_6==1
replace inter8q=1 if inter_7==1
replace inter8q=1 if inter_8==1
replace inter8q=0 if  inter8q==.

areg  pct_def_agency inter8q  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if   (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | inter_1==1 | inter_2==1 | inter_3==1 | inter_4==1 | inter_5==1 | inter_6==1 | inter_7==1 | inter_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn) cluster(gvkeyn)  
gen intable9a = e(sample)
areg  pct_def_agency c.inter8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if   if  intable9a==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.inter8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9a==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.inter8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9a==1, absorb(gvkeyn) cluster(gvkeyn)  

*****Panel B
areg  pct_cost_def_agency c.inter8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  (pre_1==1 | pre_2==1 |pre_3==1 | pre_4==1 | pre_5==1 | pre_6==1  | pre_7==1 | pre_8==1 | inter_1==1 | inter_2==1 | inter_3==1 | inter_4==1 | inter_5==1 | inter_6==1 | inter_7==1 | inter_8==1) & fyearq > 1999 & fyearq < 2013, absorb(gvkeyn) cluster(gvkeyn)
gen intable9b = e(sample)
areg  pct_cost_def_agency c.inter8q##c.serious_doj  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9b==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.inter8q##c.long_investigation  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9b==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.inter8q##c.serious_settle  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable9b==1, absorb(gvkeyn) cluster(gvkeyn)  

***Table 10
**Panel A
areg  pct_def_agency c.w8q##c.pc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.logsumpc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.largest_100_Max  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_def_agency c.w8q##c.connectedboard  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable3==1, absorb(gvkeyn) cluster(gvkeyn)  

**Panel B
areg  pct_cost_def_agency c.w8q##c.pc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.logsumpc  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.largest_100_Max  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  
areg  pct_cost_def_agency c.w8q##c.connectedboard  log_at hhi cogs lev  i.def_ag##i.fyearq  i.def_ag##i.fqtr  i.ind_code##i.fyearq  if  intable4==1, absorb(gvkeyn) cluster(gvkeyn)  












