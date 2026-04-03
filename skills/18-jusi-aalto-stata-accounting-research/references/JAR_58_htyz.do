
/* code from raw data to generate the baseline Table 3 */

/********************************************************************************************************/
/********************************* Preparing variables *****************************************/
/********************************************************************************************************/

clear
use compa_all.dta, clear /* raw compustat annual data */
keep gvkey datadate sich sic
sort gvkey datadate
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
tostring sich,gen(sich_string)
replace sich_string=sic if sich==.
replace sich_string="000"+ sich_string
replace sich_string=substr(sich_string,-4,4)
destring sich_string,gen(sich_num)
save compa_sich.dta ,replace
/************************************************************************************/

use compa_all.dta, clear /* raw compustat annual data */
keep gvkey datadate fyear at mkvalt csho prcc_f xrd dvc oibdp ppegt ppent dltt dlc capx txdb ceq pstkrv prstkc ib dp seq dvp che invt ppegt emp aqc aqs rect sale state ibcom oibdp xint txt act lct idit dvpsx_f ajex spi curcd
drop if datadate==.     
replace fyear=year(datadate) if fyear==.     
duplicates tag gvkey  fyear, gen(dupnum)     
tab dupnum
drop if dupnum==1 & at==.
duplicates list gvkey fyear
drop dupnum   

sort gvkey fyear
destring gvkey, generate(num_gvkey)
tsset num_gvkey fyear
replace idit=0 if idit==.
replace xint=0 if xint==.
gen CoreEarn=ib+0.6*xint-0.6*idit
sort num_gvkey fyear
by num_gvkey: gen lag_at=l.at
by num_gvkey: gen lag_earn = l.CoreEarn
gen DPS=dvpsx_f/ajex 
by num_gvkey: gen f_DPS=f.DPS
gen ROA=CoreEarn/lag_at
gen l1ROA=l.ROA
gen l2ROA=l2.ROA
gen l3ROA=l3.ROA
egen n=rownonmiss(ROA l1ROA l2ROA l3ROA)
egen ROAVol=rowsd(ROA l1ROA l2ROA l3ROA) if n==4
gen SI=spi/lag_at
generate LOSS=.
replace LOSS=1 if CoreEarn<0
replace LOSS=0 if CoreEarn>=0
replace LOSS=. if CoreEarn==.
bys num_gvkey: asreg CoreEarn lag_earn, wind(fyear 16) min(4)
rename _b_lag_earn Persist
drop _Nobs _R2 _adjR2 _b_cons n

sort gvkey fyear
gen lnsize_at=ln(at)     
gen ppeta=ppent/at      
gen lev=(dltt+dlc)/at      
gen data74=txdb      
replace data74=0 if txdb==.      
gen q=(csho*prcc_f+at-ceq-data74)/at
gen cashholding=che/at
merge 1:1 gvkey datadate using compa_sich, keepusing(sich_num sich_string) /* compustat industry info, generated above */
drop if _merge==2
drop _merge
gen sic3=substr(sich_string,1,3)
gen flag_fu=1 if 4900<=sich_num & sich_num<=4949      
replace flag_fu=1 if 6000<=sich_num & sich_num<=6999 
replace flag_fu=0 if missing(flag_fu)
keep if flag_fu==0
keep if curcd=="USD"
rename num_gvkey gvkey_n
sort gvkey_n datadate
save compa_from_Huan_final_JAR.dta, replace
/************************************************************************************/


/* 3-step SAS/Stata codes that generate cost stickiness measure (b_dec), written by Huan */

/* Step 1: SAS */
data compa;
set comp.compa_all(keep=gvkey datadate); /* raw compustat annual data */
num_qtr=(year(datadate)-1980)*4+qtr(datadate);
run;

data compq1;
set compq; /* raw compustat quarterly data */
num_qtr=(year(datadate)-1980)*4+qtr(datadate);
run;

proc sql;
create table compa_q as select
a.*,b.datadate as datadateq,b.fyearq,b.fqtr,b.fyr,b.datacqtr,b.datafqtr,b.num_qtr as num_qtrq,b.saleq,b.xsgaq,b.atq,b.cogsq,b.oiadpq,b.xrdq
from compa as  a left join compq1 as b
on a.gvkey=b.gvkey and a.num_qtr-b.num_qtr>=0 and a.num_qtr-b.num_qtr<=20;
quit;

proc sort data=compa_q;
by gvkey datadate datadateq;
quit;

/* Step 2: stata codes for generating datasets used in the above SAS code: */

use compa_q.dta, clear
gen order_q_dist= num_qtr - num_qtrq
drop if missing( order_q_dist)
gen datadate_qdate=quarterly( datacqtr ,"YQ")
replace datadate_qdate=qofd(datadateq) if missing(datacqtr)
format datadate_qdate %tq
egen gvkey_datadate=group(gvkey datadate)
duplicates tag gvkey_datadate datadate_qdate, gen(tag)
tab tag
browse if tag==1
browse if tag==2
drop if missing(datacqtr)
drop tag
duplicates tag gvkey_datadate datadate_qdate, gen(tag)
tab tag
browse if tag==1
browse if gvkey_datadate==392684
drop if gvkey_datadate==392684 & tag==1 & fyr==12
drop tag
xtset gvkey_datadate datadate_qdate ,quarterly
gen ch_lg_xsgaq=ln(xsgaq)-ln(l.xsgaq)
gen ch_lg_cogsq=ln(cogsq)-ln(l.cogsq)
gen ch_lg_oc=ln(saleq-oiadpq)-ln(l.saleq-l.oiadpq)
gen ch_lg_cost=ln(cogsq+xsgaq)-ln(l.cogsq+l.xsgaq)
gen ch_lg_saleq=ln(saleq)-ln(l.saleq)
gen dec=1 if saleq-l.saleq<0
replace dec=0 if saleq-l.saleq>=0
gen dec_ch_lg_saleq=dec*ch_lg_saleq
gen dec1=1 if saleq-l.saleq<0
replace dec1=0 if saleq-l.saleq>0
saveold compa_q1.dta ,replace

/* Step 3: SAS */

data compa_q1_16;
set compa_q1;
drop gvkey_datadate;
if order_q_dist>=0 & order_q_dist<=15;
if missing(ch_lg_xsgaq) or missing(ch_lg_saleq) then delete;
run;

proc sort data=compa_q1_16;
by gvkey datadate desending order_q_dist;
quit;

proc reg data=compa_q1_16 noprint outest=b_dec_16 edf;
by gvkey datadate;
model ch_lg_xsgaq=ch_lg_saleq dec_ch_lg_saleq;
quit;

data b_dec_16(drop=_p_ _edf_);
set b_dec_16(keep=gvkey datadate ch_lg_saleq dec_ch_lg_saleq _p_ _edf_ _rsq_);
n=_p_+_edf_;
rename dec_ch_lg_saleq=b_dec;
rename ch_lg_saleq=b;
rename _rsq_=r_square;
run;

/*********************** Table 3: baseline OLS regressions **********************************/
/*******************************************************/

use compa_from_Huan_final_JAR, clear
gen year=year(datadate)
merge 1:1 gvkey datadate using b_dec_16,keepusing(b b_dec n)
drop if _m==2
drop _merge
replace b_dec=b_dec*(-1)
replace b_dec=. if n<16
drop n
drop year
rename fyear year
sort gvkey_n year
xtset gvkey_n year, yearly
egen sic3_year=group(sic3 year)
keep if year>=1978 & year<=2016 
foreach var in f_DPS b_dec lnsize_at lev q cashholding ppeta ROA ROAVol SI Persist {
winsor `var', gen(w`var') p(0.01)
}
gen neg_wSI=-wSI

set more off
unab control: wlnsize_at wlev wq wcashholding wppeta wROA wROAVol LOSS neg_wSI wPersist

reghdfe wf_DPS wb_dec `control', noabsorb cluster(gvkey_n)
keep if e(sample)
reghdfe wf_DPS wb_dec `control', a(sic3_year) cluster(gvkey_n) 

/* generating identifiers */

keep gvkey 
duplicates drop
save identifier_gvkey
/* code from raw data to generate the baseline Table 3 */

/********************************************************************************************************/
/********************************* Preparing variables *****************************************/
/********************************************************************************************************/

clear
use compa_all.dta, clear /* raw compustat annual data */
keep gvkey datadate sich sic
sort gvkey datadate
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
tostring sich,gen(sich_string)
replace sich_string=sic if sich==.
replace sich_string="000"+ sich_string
replace sich_string=substr(sich_string,-4,4)
destring sich_string,gen(sich_num)
save compa_sich.dta ,replace
/************************************************************************************/

use compa_all.dta, clear /* raw compustat annual data */
keep gvkey datadate fyear at mkvalt csho prcc_f xrd dvc oibdp ppegt ppent dltt dlc capx txdb ceq pstkrv prstkc ib dp seq dvp che invt ppegt emp aqc aqs rect sale state ibcom oibdp xint txt act lct idit dvpsx_f ajex spi curcd
drop if datadate==.     
replace fyear=year(datadate) if fyear==.     
duplicates tag gvkey  fyear, gen(dupnum)     
tab dupnum
drop if dupnum==1 & at==.
duplicates list gvkey fyear
drop dupnum   

sort gvkey fyear
destring gvkey, generate(num_gvkey)
tsset num_gvkey fyear
replace idit=0 if idit==.
replace xint=0 if xint==.
gen CoreEarn=ib+0.6*xint-0.6*idit
sort num_gvkey fyear
by num_gvkey: gen lag_at=l.at
by num_gvkey: gen lag_earn = l.CoreEarn
gen DPS=dvpsx_f/ajex 
by num_gvkey: gen f_DPS=f.DPS
gen ROA=CoreEarn/lag_at
gen l1ROA=l.ROA
gen l2ROA=l2.ROA
gen l3ROA=l3.ROA
egen n=rownonmiss(ROA l1ROA l2ROA l3ROA)
egen ROAVol=rowsd(ROA l1ROA l2ROA l3ROA) if n==4
gen SI=spi/lag_at
generate LOSS=.
replace LOSS=1 if CoreEarn<0
replace LOSS=0 if CoreEarn>=0
replace LOSS=. if CoreEarn==.
bys num_gvkey: asreg CoreEarn lag_earn, wind(fyear 16) min(4)
rename _b_lag_earn Persist
drop _Nobs _R2 _adjR2 _b_cons n

sort gvkey fyear
gen lnsize_at=ln(at)     
gen ppeta=ppent/at      
gen lev=(dltt+dlc)/at      
gen data74=txdb      
replace data74=0 if txdb==.      
gen q=(csho*prcc_f+at-ceq-data74)/at
gen cashholding=che/at
merge 1:1 gvkey datadate using compa_sich, keepusing(sich_num sich_string) /* compustat industry info, generated above */
drop if _merge==2
drop _merge
gen sic3=substr(sich_string,1,3)
gen flag_fu=1 if 4900<=sich_num & sich_num<=4949      
replace flag_fu=1 if 6000<=sich_num & sich_num<=6999 
replace flag_fu=0 if missing(flag_fu)
keep if flag_fu==0
keep if curcd=="USD"
rename num_gvkey gvkey_n
sort gvkey_n datadate
save compa_from_Huan_final_JAR.dta, replace
/************************************************************************************/


/* 3-step SAS/Stata codes that generate cost stickiness measure (b_dec), written by Huan */

/* Step 1: SAS */
data compa;
set comp.compa_all(keep=gvkey datadate); /* raw compustat annual data */
num_qtr=(year(datadate)-1980)*4+qtr(datadate);
run;

data compq1;
set compq; /* raw compustat quarterly data */
num_qtr=(year(datadate)-1980)*4+qtr(datadate);
run;

proc sql;
create table compa_q as select
a.*,b.datadate as datadateq,b.fyearq,b.fqtr,b.fyr,b.datacqtr,b.datafqtr,b.num_qtr as num_qtrq,b.saleq,b.xsgaq,b.atq,b.cogsq,b.oiadpq,b.xrdq
from compa as  a left join compq1 as b
on a.gvkey=b.gvkey and a.num_qtr-b.num_qtr>=0 and a.num_qtr-b.num_qtr<=20;
quit;

proc sort data=compa_q;
by gvkey datadate datadateq;
quit;

/* Step 2: stata codes for generating datasets used in the above SAS code: */

use compa_q.dta, clear
gen order_q_dist= num_qtr - num_qtrq
drop if missing( order_q_dist)
gen datadate_qdate=quarterly( datacqtr ,"YQ")
replace datadate_qdate=qofd(datadateq) if missing(datacqtr)
format datadate_qdate %tq
egen gvkey_datadate=group(gvkey datadate)
duplicates tag gvkey_datadate datadate_qdate, gen(tag)
tab tag
browse if tag==1
browse if tag==2
drop if missing(datacqtr)
drop tag
duplicates tag gvkey_datadate datadate_qdate, gen(tag)
tab tag
browse if tag==1
browse if gvkey_datadate==392684
drop if gvkey_datadate==392684 & tag==1 & fyr==12
drop tag
xtset gvkey_datadate datadate_qdate ,quarterly
gen ch_lg_xsgaq=ln(xsgaq)-ln(l.xsgaq)
gen ch_lg_cogsq=ln(cogsq)-ln(l.cogsq)
gen ch_lg_oc=ln(saleq-oiadpq)-ln(l.saleq-l.oiadpq)
gen ch_lg_cost=ln(cogsq+xsgaq)-ln(l.cogsq+l.xsgaq)
gen ch_lg_saleq=ln(saleq)-ln(l.saleq)
gen dec=1 if saleq-l.saleq<0
replace dec=0 if saleq-l.saleq>=0
gen dec_ch_lg_saleq=dec*ch_lg_saleq
gen dec1=1 if saleq-l.saleq<0
replace dec1=0 if saleq-l.saleq>0
saveold compa_q1.dta ,replace

/* Step 3: SAS */

data compa_q1_16;
set compa_q1;
drop gvkey_datadate;
if order_q_dist>=0 & order_q_dist<=15;
if missing(ch_lg_xsgaq) or missing(ch_lg_saleq) then delete;
run;

proc sort data=compa_q1_16;
by gvkey datadate desending order_q_dist;
quit;

proc reg data=compa_q1_16 noprint outest=b_dec_16 edf;
by gvkey datadate;
model ch_lg_xsgaq=ch_lg_saleq dec_ch_lg_saleq;
quit;

data b_dec_16(drop=_p_ _edf_);
set b_dec_16(keep=gvkey datadate ch_lg_saleq dec_ch_lg_saleq _p_ _edf_ _rsq_);
n=_p_+_edf_;
rename dec_ch_lg_saleq=b_dec;
rename ch_lg_saleq=b;
rename _rsq_=r_square;
run;

/*********************** Table 3: baseline OLS regressions **********************************/
/*******************************************************/

use compa_from_Huan_final_JAR, clear
gen year=year(datadate)
merge 1:1 gvkey datadate using b_dec_16,keepusing(b b_dec n)
drop if _m==2
drop _merge
replace b_dec=b_dec*(-1)
replace b_dec=. if n<16
drop n
drop year
rename fyear year
sort gvkey_n year
xtset gvkey_n year, yearly
egen sic3_year=group(sic3 year)
keep if year>=1978 & year<=2016 
foreach var in f_DPS b_dec lnsize_at lev q cashholding ppeta ROA ROAVol SI Persist {
winsor `var', gen(w`var') p(0.01)
}
gen neg_wSI=-wSI

set more off
unab control: wlnsize_at wlev wq wcashholding wppeta wROA wROAVol LOSS neg_wSI wPersist

reghdfe wf_DPS wb_dec `control', noabsorb cluster(gvkey_n)
keep if e(sample)
reghdfe wf_DPS wb_dec `control', a(sic3_year) cluster(gvkey_n) 

/* generating identifiers */

keep gvkey 
duplicates drop
save identifier_gvkey
/* code from raw data to generate the baseline Table 3 */

/********************************************************************************************************/
/********************************* Preparing variables *****************************************/
/********************************************************************************************************/

clear
use compa_all.dta, clear /* raw compustat annual data */
keep gvkey datadate sich sic
sort gvkey datadate
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
by gvkey: replace sich=sich[_n+1] if missing(sich) & !missing(sich[_n+1])
tostring sich,gen(sich_string)
replace sich_string=sic if sich==.
replace sich_string="000"+ sich_string
replace sich_string=substr(sich_string,-4,4)
destring sich_string,gen(sich_num)
save compa_sich.dta ,replace
/************************************************************************************/

use compa_all.dta, clear /* raw compustat annual data */
keep gvkey datadate fyear at mkvalt csho prcc_f xrd dvc oibdp ppegt ppent dltt dlc capx txdb ceq pstkrv prstkc ib dp seq dvp che invt ppegt emp aqc aqs rect sale state ibcom oibdp xint txt act lct idit dvpsx_f ajex spi curcd
drop if datadate==.     
replace fyear=year(datadate) if fyear==.     
duplicates tag gvkey  fyear, gen(dupnum)     
tab dupnum
drop if dupnum==1 & at==.
duplicates list gvkey fyear
drop dupnum   

sort gvkey fyear
destring gvkey, generate(num_gvkey)
tsset num_gvkey fyear
replace idit=0 if idit==.
replace xint=0 if xint==.
gen CoreEarn=ib+0.6*xint-0.6*idit
sort num_gvkey fyear
by num_gvkey: gen lag_at=l.at
by num_gvkey: gen lag_earn = l.CoreEarn
gen DPS=dvpsx_f/ajex 
by num_gvkey: gen f_DPS=f.DPS
gen ROA=CoreEarn/lag_at
gen l1ROA=l.ROA
gen l2ROA=l2.ROA
gen l3ROA=l3.ROA
egen n=rownonmiss(ROA l1ROA l2ROA l3ROA)
egen ROAVol=rowsd(ROA l1ROA l2ROA l3ROA) if n==4
gen SI=spi/lag_at
generate LOSS=.
replace LOSS=1 if CoreEarn<0
replace LOSS=0 if CoreEarn>=0
replace LOSS=. if CoreEarn==.
bys num_gvkey: asreg CoreEarn lag_earn, wind(fyear 16) min(4)
rename _b_lag_earn Persist
drop _Nobs _R2 _adjR2 _b_cons n

sort gvkey fyear
gen lnsize_at=ln(at)     
gen ppeta=ppent/at      
gen lev=(dltt+dlc)/at      
gen data74=txdb      
replace data74=0 if txdb==.      
gen q=(csho*prcc_f+at-ceq-data74)/at
gen cashholding=che/at
merge 1:1 gvkey datadate using compa_sich, keepusing(sich_num sich_string) /* compustat industry info, generated above */
drop if _merge==2
drop _merge
gen sic3=substr(sich_string,1,3)
gen flag_fu=1 if 4900<=sich_num & sich_num<=4949      
replace flag_fu=1 if 6000<=sich_num & sich_num<=6999 
replace flag_fu=0 if missing(flag_fu)
keep if flag_fu==0
keep if curcd=="USD"
rename num_gvkey gvkey_n
sort gvkey_n datadate
save compa_from_Huan_final_JAR.dta, replace
/************************************************************************************/


/* 3-step SAS/Stata codes that generate cost stickiness measure (b_dec), written by Huan */

/* Step 1: SAS */
data compa;
set comp.compa_all(keep=gvkey datadate); /* raw compustat annual data */
num_qtr=(year(datadate)-1980)*4+qtr(datadate);
run;

data compq1;
set compq; /* raw compustat quarterly data */
num_qtr=(year(datadate)-1980)*4+qtr(datadate);
run;

proc sql;
create table compa_q as select
a.*,b.datadate as datadateq,b.fyearq,b.fqtr,b.fyr,b.datacqtr,b.datafqtr,b.num_qtr as num_qtrq,b.saleq,b.xsgaq,b.atq,b.cogsq,b.oiadpq,b.xrdq
from compa as  a left join compq1 as b
on a.gvkey=b.gvkey and a.num_qtr-b.num_qtr>=0 and a.num_qtr-b.num_qtr<=20;
quit;

proc sort data=compa_q;
by gvkey datadate datadateq;
quit;

/* Step 2: stata codes for generating datasets used in the above SAS code: */

use compa_q.dta, clear
gen order_q_dist= num_qtr - num_qtrq
drop if missing( order_q_dist)
gen datadate_qdate=quarterly( datacqtr ,"YQ")
replace datadate_qdate=qofd(datadateq) if missing(datacqtr)
format datadate_qdate %tq
egen gvkey_datadate=group(gvkey datadate)
duplicates tag gvkey_datadate datadate_qdate, gen(tag)
tab tag
browse if tag==1
browse if tag==2
drop if missing(datacqtr)
drop tag
duplicates tag gvkey_datadate datadate_qdate, gen(tag)
tab tag
browse if tag==1
browse if gvkey_datadate==392684
drop if gvkey_datadate==392684 & tag==1 & fyr==12
drop tag
xtset gvkey_datadate datadate_qdate ,quarterly
gen ch_lg_xsgaq=ln(xsgaq)-ln(l.xsgaq)
gen ch_lg_cogsq=ln(cogsq)-ln(l.cogsq)
gen ch_lg_oc=ln(saleq-oiadpq)-ln(l.saleq-l.oiadpq)
gen ch_lg_cost=ln(cogsq+xsgaq)-ln(l.cogsq+l.xsgaq)
gen ch_lg_saleq=ln(saleq)-ln(l.saleq)
gen dec=1 if saleq-l.saleq<0
replace dec=0 if saleq-l.saleq>=0
gen dec_ch_lg_saleq=dec*ch_lg_saleq
gen dec1=1 if saleq-l.saleq<0
replace dec1=0 if saleq-l.saleq>0
saveold compa_q1.dta ,replace

/* Step 3: SAS */

data compa_q1_16;
set compa_q1;
drop gvkey_datadate;
if order_q_dist>=0 & order_q_dist<=15;
if missing(ch_lg_xsgaq) or missing(ch_lg_saleq) then delete;
run;

proc sort data=compa_q1_16;
by gvkey datadate desending order_q_dist;
quit;

proc reg data=compa_q1_16 noprint outest=b_dec_16 edf;
by gvkey datadate;
model ch_lg_xsgaq=ch_lg_saleq dec_ch_lg_saleq;
quit;

data b_dec_16(drop=_p_ _edf_);
set b_dec_16(keep=gvkey datadate ch_lg_saleq dec_ch_lg_saleq _p_ _edf_ _rsq_);
n=_p_+_edf_;
rename dec_ch_lg_saleq=b_dec;
rename ch_lg_saleq=b;
rename _rsq_=r_square;
run;

/*********************** Table 3: baseline OLS regressions **********************************/
/*******************************************************/

use compa_from_Huan_final_JAR, clear
gen year=year(datadate)
merge 1:1 gvkey datadate using b_dec_16,keepusing(b b_dec n)
drop if _m==2
drop _merge
replace b_dec=b_dec*(-1)
replace b_dec=. if n<16
drop n
drop year
rename fyear year
sort gvkey_n year
xtset gvkey_n year, yearly
egen sic3_year=group(sic3 year)
keep if year>=1978 & year<=2016 
foreach var in f_DPS b_dec lnsize_at lev q cashholding ppeta ROA ROAVol SI Persist {
winsor `var', gen(w`var') p(0.01)
}
gen neg_wSI=-wSI

set more off
unab control: wlnsize_at wlev wq wcashholding wppeta wROA wROAVol LOSS neg_wSI wPersist

reghdfe wf_DPS wb_dec `control', noabsorb cluster(gvkey_n)
keep if e(sample)
reghdfe wf_DPS wb_dec `control', a(sic3_year) cluster(gvkey_n) 

/* generating identifiers */

keep gvkey 
duplicates drop
save identifier_gvkey
