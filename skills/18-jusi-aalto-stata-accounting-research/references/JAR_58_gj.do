


/**generate unemployment and house price stuff at the district level**/

 use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\macroeconomic\lf_all3.dta" , clear
 
 merge 1:1 fips year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\macroeconomic\HPI_fips.dta"
 
 cap drop _merge
 
 destring fips, replace
 
 merge n:1 fips using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\macroeconomic\fips_dist.dta"
 
 egen total = sum(Labor_Force) , by(irsdist year)
 egen unempl = sum(Unemployed), by(irsdist year)
 
 gen share_fips = annualchange*Labor_Force
 egen total_for_fips= sum(Labor_Force) if annualchange~=. ,by(irsdist year)
 egen nom_for_fips= sum(share_fips) if annualchange~=. ,by(irsdist year)
 
 gen hpi_change=nom_for_fips/total_for_fips
 
 cap drop share_fips total_for_fips nom_for_fips
 gen share_fips = hpiwith1990base*Labor_Force
 egen total_for_fips= sum(Labor_Force) if annualchange~=. ,by(irsdist year)
 egen nom_for_fips= sum(share_fips) if annualchange~=. ,by(irsdist year)
 
 gen hpi_level=nom_for_fips/total_for_fips
   
 gen unempl_dist = unempl/total
 
 keep irsdist year unempl_dist hpi_change hpi_level
 
 drop if hpi_change==.
 
 duplicates drop 
 egen id = group(irsdist)
 
 xtset id year
 
 gen change_unempl = d.unempl_dist
 
 drop if year == .
 
 drop if id == .
 
 replace  irsdist = "Pacific-Northwest" if  irsdist == "Pacific Northwest"
  
 
  save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta" , replace
 

 
 
/**generate firm-level information using compustat
Step 1: merge HQ data
Step 2: generate district level data
**/

  use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\hq\10-K_Headers.dta" , clear

keep cik ba_zip5 fyear

drop if cik==.

xtset cik fyear


forvalues x = 1(1)20{
replace ba_zip5 = ba_zip5[_n+1] if ba_zip5=="" & cik == f.cik
}

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\hq_10k.dta", replace


/**Second step: Create State/Country Level Averages**/

 use "C:\Users\martin.jacob\Desktop\fb9b4da6455c8e2b.dta" , clear
 
keep if loc == "USA"
keep if fic == "USA"
keep if curcd == "USD"
 
 gen year = year(datadate)
 gen month = month(datadate)

 
 destring cik , replace force
 
drop if sale == .
drop if at == . 

drop if at<0
drop if ceq<0
drop if che<0
drop if sale<0

drop if cik == .

drop if sic == "6020"
drop if sic == "6022"

 egen buffer =count(cik), by(cik fyear)

 keep if buffer == 1 | (buffer == 2 & month == 12)
 
 drop buffer
 
 
merge 1:1 cik fyear using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\hq_10k.dta"
 
 drop if _m == 2
 

egen id = group(gvkey)

xtset id fyear
 
 forvalues x = 1(1)50{
replace ba_zip5 = ba_zip5[_n+1] if ba_zip5=="" & id == f.id
}

 replace ba_zip5 = substr(addzip,1,5) if ba_zip5==""
 
rename ba_zip5 zip 


/******
pecking order
1) use the actual year
2) if (1) not available, use the most recent 10k based HQ location
3) if (2) is not there, then we use use current address
******/
 
 
 cap drop _m
merge n:1 zip using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\irs audit (TRAC)\zip_fips_dist.dta"

keep if _m == 3


cap drop year
rename fyear year

xtset id year

gen inv=capx/ppegt
gen cash_assets=che/at
gen income_assets=(oibdp)/l.at
gen pi_assets=(pi)/l.at
gen ni_assets=(ni)/l.at
gen sg=ln(sale/ll.sale)
gen lvg=(dltt + dlc)/at
gen size=ln(at)
gen q_=(csho*prcc_c)/at
gen gross_margin_at=(sale-cogs)/sale
gen profit_margin_at=(pi)/sale
gen ltdebt_book_equity= (dltt)/ceq
gen intangibles = intan/ at
gen ppe = ppegt/ at
gen tangibility = (ppegt+intan)/at


gen cash_etr_1 = txpd / pi
replace cash_etr_1 = 0 if cash_etr_1<0
replace cash_etr_1 = 1 if cash_etr_1>1 & cash_etr_1<.
replace cash_etr_1 = . if pi<0

keep if year >1989

keep if year < 2006

foreach var of varlist inv cash_assets income_assets sg lvg gross_margin_at profit_margin_at tangibility ///
intangibles ppe ltdebt_book_equity pi_assets ni_assets  { 
winsor `var', p(.01) gen(`var'_w)
}

cap drop _m
merge n:1 zip  using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\zip_state.dta"

drop if _m == 2

egen irs_id = group(irsdist)

gen sic2 = substr(sic,1,2)

egen ind_state_year = group(sic2 state year)

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\Compustat_Sample", replace



use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\Compustat_Sample", clear

cap drop mean_cash_etr_1_w

xtset id year

gen cf_assets = oancf/l.at

winsor cf_assets , gen(cf_assets_w) p(0.01)

gen loss = (ni<0) if ni<.

egen sum_firms = count(ni) if ni ~=. ,by(irsdist year)
egen sum_losses = sum(loss) if ni ~=. ,by(irsdist year)
gen share_losses = sum_losses/sum_firms


drop if inv_w==.
foreach var of varlist inv_w cash_assets_w pi_assets_w ni_assets_w sg_w lvg_w gross_margin_at_w profit_margin_at_w tangibility_w ///
intangibles_w ppe_w ltdebt_book_equity_w cash_etr_1 cf_assets_w { 
egen dist_mean_`var'=mean(`var'), by(irsdist year)
}

egen count=count(year) , by(irsdist year)

foreach var of varlist capx che at dltt sale pi oibdp{ 
egen dist_sum_`var' = sum(`var'), by(irsdist year)
}

keep irsdist dist_mean_* dist_sum_* year count sum_firms sum_losses share_losses

duplicates drop

foreach var of varlist dist_mean_inv_w dist_mean_cash_assets_w dist_mean_pi_assets_w dist_mean_sg_w dist_mean_lvg_w dist_mean_gross_margin_at_w ///
dist_mean_profit_margin_at_w dist_mean_tangibility_w dist_mean_cf_assets_w ///
dist_mean_intangibles_w dist_mean_ppe_w dist_mean_ltdebt_book_equity_w dist_mean_cash_etr_1 share_losses{ 
keep if `var' ~=.
}
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta", replace

replace year = year + 1 
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist_lag.dta", replace


/***input of shares in each district***/



use "C:\Users\martin.jacob\Dropbox\GJ\data\final\district_share.dta", clear

merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\irs_audit_prob.dta"

keep if _m == 3


drop _m 

sort rssd year

cap drop dep_share

gen share_deposits = depdist / depdom

egen max_share = max(share_deposits),by(rssd year)

gen main_location = ( share_deposits== max_share)

egen buff_sum_prob=sum(share_dep), by(rssd year main_location)
gen buf_weighted_perc=(perc_audited*share_dep) / buff_sum_prob

egen weighted_perd = sum(buf_weighted_perc), by(rssd year main_location)

gen buf_perc_audited_main = weighted_perd if main_location == 1
gen buf_perc_audited_other = weighted_perd if main_location == 0

egen perc_audited_main  = mean(buf_perc_audited_main), by(rssd year)
egen perc_audited_other  = mean(buf_perc_audited_other), by(rssd year)

replace perc_audited_other = perc_audited_main if perc_audited_other==.

keep if main_location == 1

keep rssd year perc_audited_main perc_audited_other  share_deposits

duplicates tag rssd year, gen(buffer)
drop if buffer == 1

drop buffer

xtset rssd year

rssdid rssd

save  "C:\Users\martin.jacob\Dropbox\GJ\data\final\input_share_deposits.dta", replace



/******generate audit percentage data******/

clear all

import delimited "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\irs audit (TRAC)\IRS District Audits, FY 1992 - 2000.csv"

rename fy year
rename irsname irsdist

gen perc_audited_other=.

drop if code == 200

 /**this creates the audit percentages by size class**/
egen aud_bel5=sum(aud) if code>200 & code<216, by(irsdist year)
egen buf_ret_bel5=sum(ret) if code>200 & code<216, by(irsdist year)
 
gen buf_perc_audited_bel_5 = aud_bel5/buf_ret_bel5

egen perc_audited_bel_5 = mean(buf_perc_audited_bel_5), by(irsdist year)
egen ret_bel5 = mean(buf_ret_bel5), by(irsdist year)
 
 
forvalues var = 209(2)225{

gen buf_perc_audited_`var' = aud/ret if code == `var'

egen perc_audited_`var' = mean(buf_perc_audited_`var'), by(irsdist year)

 egen buf_ret_`var' = sum(ret) if  code == `var', by(irsdist year)
 egen ret_`var'=mean(buf_ret_`var') , by(irsdist year)

}
 
 keep year irsdist code  perc_audited_* ret_*

 cap drop perc_audited_other 
 cap drop perc_audited_211 
 cap drop ret_211
 cap drop code
 duplicates drop
 
  
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta", replace



/****merging Dealscan information to our dataset - data preparation***/
use  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed.dta" , clear

egen total_loans = sum(loan_total_mixed),by(lenderid year)
gen buffer = loan_total_mixed if ltype=="term"
egen term_loans = sum(buffer),by(lenderid year)

keep lenderid  year total_loans term_loans
duplicates drop

xtset lenderid year

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel.dta" , replace
 
 

 
use  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed.dta" , clear

egen total_loans = sum(loan_total_mixed),by(UltimateParentID year)
gen buffer = loan_total_mixed if ltype=="term"
egen term_loans = sum(buffer),by(UltimateParentID year)

keep UltimateParentID  year total_loans term_loans
duplicates drop

xtset UltimateParentID year

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel_parent.dta" , replace
 

use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\link_lenderid.dta" , clear
egen count=count(year), by(lenderid year)
egen max_best = max(best_match),  by(lenderid year)
drop if count>1 & best_match==0 &max_best==1
drop if year>2000
drop count 
egen count=count(year), by(lenderid year)
*drop if count>1 & best_match==0 

duplicates drop
sort lenderid year
 keep lenderid rssd year

 merge n:1 lenderid year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel.dta" , 

egen all_large_loans = sum(total_loans),by(rssd year)
egen large_term_loans = sum(term_loans),by(rssd year)

keep rssd  year all_large_loans large_term_loans
duplicates drop

xtset rssd year

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid.dta" , replace
 
rename rssd fin_hh_rssd

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid_hold.dta" , replace
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\link_parentid.dta" , clear
egen count=count(year), by(ultimateparentid year)

egen max_best = max(best_match),  by(ultimateparentid year)
drop if count>1 & best_match==0 &max_best==1
drop if year>2000
duplicates drop
sort ultimateparentid year
 keep ultimateparentid rssd year

 rename ultimateparentid UltimateParentID
 
 merge n:1 UltimateParentID year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel_parent.dta" , 


egen all_large_loans_par = sum(total_loans),by(rssd year)
egen large_term_loans_par = sum(term_loans),by(rssd year)

keep rssd  year all_large_loans large_term_loans
duplicates drop

xtset rssd year
save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid.dta" , replace
  

rename rssd fin_hh_rssd
save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid_hold.dta" , replace
  
/****End of Dealscan data preparation***/



/****Let us generate the acutal panel data****/


use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final.dta", clear

format date %td

/**make this panel data**/
gen yq = qofd(date)
format yq %tq

drop if assets <= 0
drop if assets_lag4 <= 0
drop if loans_net_lag4<0
drop if totalcapital < 0



merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_share_deposits.dta"

drop if _m == 2

cap drop state
cap drop _m
rename state_code state

merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta"

drop if _ == 2

cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta"


cap drop _merge
merge n:1 year irsdist using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta"



xtset rssd yq,quarterly

/**data screening**/

drop if country == "PUERTO RICO"
drop if fed_charter == 0 & state_charter == 0
drop if state == ""


count if year > 1991 & year<2001


replace etr = . if pi<0
replace etr2 = . if ebtx<0

replace etr=0 if etr<0
replace etr=1 if etr>1 & etr<.

replace etr2=0 if etr2<0
replace etr2=1 if etr2>1 & etr2<.

gen llp2_q = llp if quarter == 1
replace llp2_q = llp - l.llp if quarter > 1

cap drop loans_scale 
gen loans_scale = l.loans_net + l.llr

cap drop llp_to_loans
gen llp_to_loans = llp2_q/loans_scale

cap drop nonperform_to_loans
gen nonperform_to_loans = nonperform/loans_scale


gen llp_loans_y = llp / (l4.loans_net +l4.llr)
gen npl_loans_y = nonperform / (l4.loans_net +l4.llr)
gen npl_loans_y_lag = l4.npl_loans_y
gen cash_to_assets_lag = l4.cash_to_assets
gen d_npl_loans_y = (nonperform-l4.nonperform) / (l4.loans_net +l4.llr)
gen nco_loans_y = nco / (l4.loans_net +l4.llr)
 
drop deposits* id_cusip name name2 city   country auditclass irsname fips_temp

drop dep_broker_unin_lag4 dep_insured_all_to_assets dep_insured_der_to_assets ///
dep_uninsured_all_to_assets dep_uninsured_der_to_assets dep_uninsured_der_to_liab ///
dep_broker_to_liab dep_broker_unin dep_broker_unin_to_liab dep_broker_growth_yr ///
dep_broker_unin_growth_yr

gen prov = nonperform/llr

gen liab_to_assets_lag1= l1.liab_to_assets
gen liab_to_assets_lag4= l4.liab_to_assets
gen weight_l2= l8.commercial

gen l4_perc_audited_size=l4.perc_audited_size
 gen l_cons_to_loans=l4.consumer_to_loans

egen irs_id = group(irsdist)

/*Drop if firms banks move across districts*/
egen sd_irs_id = sd(irs_id), by(rssd)

keep if sd_irs_id == 0
count if year > 1991 & year<2001

gen  revenue_growth = (interest_revenue-l4.interest_revenue)/l4.interest_revenue

gen l_commercial_to_loans=l4.commercial_to_loans

egen sbl_ind = mean(sbl_ind), by(rssd year)


drop if year>2001

/**The next lines are input for robustness tests mentioned in footnotes**/


gen less_than100k=(l2.comm_lt100_total+f2.comm_lt100_total)/2
gen bet_100_250=(l2.comm_100_250_total+f2.comm_100_250_total)/2

cap drop buffer
gen buffer=commercial-comm_lt100_total
cap drop commercial_ex_100
egen commercial_ex_100=mean(buffer),by(rssd year)


/***merge of dealscan**/

cap drop _m
merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid.dta" 
replace all_large_loans = all_large_loans/1000000
replace large_term_loans = large_term_loans/1000000


cap drop _m
merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid.dta" 
replace all_large_loans_par = all_large_loans_par/1000000
replace large_term_loans_par = large_term_loans_par/1000000


replace all_large_loans=0 if all_large_loans==. & month == 12
replace large_term_loans=0 if large_term_loans==. & month == 12

replace all_large_loans_par=0 if all_large_loans_par==. & month == 12
replace large_term_loans_par=0 if large_term_loans_par==. & month == 12

replace all_large_loans_par=all_large_loans_par+all_large_loans
replace large_term_loans_par=large_term_loans_par+large_term_loans

gen commercial_ex_large_all=commercial-all_large_loans
gen commercial_ex_large_term =commercial-large_term_loans

gen commercial_ex_large_all_p=commercial-all_large_loans_par
gen commercial_ex_large_term_p =commercial-large_term_loans_par


replace commercial_ex_large_all=0 if commercial_ex_large_all<0
replace commercial_ex_large_term=0 if commercial_ex_large_term<0
replace commercial_ex_large_all_p=0 if commercial_ex_large_all_p<0
replace commercial_ex_large_term_p=0 if commercial_ex_large_term_p<0



rename all_large_loans all_large_loans_dir
rename large_term_loans large_term_loans_dir
rename all_large_loans_par all_large_loans_par_dir
rename large_term_loans_par large_term_loans_par_dir



cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid_hold.dta" 
replace all_large_loans = all_large_loans/1000000
replace large_term_loans = large_term_loans/1000000


cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid_hold.dta" 
replace all_large_loans_par = all_large_loans_par/1000000
replace large_term_loans_par = large_term_loans_par/1000000



replace all_large_loans=0 if all_large_loans==. & month == 12
replace large_term_loans=0 if large_term_loans==. & month == 12

replace all_large_loans_par=0 if all_large_loans_par==. & month == 12
replace large_term_loans_par=0 if large_term_loans_par==. & month == 12


replace all_large_loans_par=all_large_loans_par+all_large_loans
replace large_term_loans_par=large_term_loans_par+large_term_loans

gen commercial_ex_large_all2=commercial-all_large_loans
gen commercial_ex_large_term2 =commercial-large_term_loans

gen commercial_ex_large_all_p2=commercial-all_large_loans_par
gen commercial_ex_large_term_p2 =commercial-large_term_loans_par


replace commercial_ex_large_all2=0 if commercial_ex_large_all2<0
replace commercial_ex_large_term2=0 if commercial_ex_large_term2<0
replace commercial_ex_large_all_p2=0 if commercial_ex_large_all_p2<0
replace commercial_ex_large_term_p2=0 if commercial_ex_large_term_p2<0


xtset rssd yq, quarterly
gen l_commercial_ex100_to_loans=l4.commercial_ex_100/l4.loans_scale

/****/

 reg  perc_audited size_lag1 liab_to_assets_lag1    ///
 unemp_nsa ch_unemp_nsa_qtr  hpi_nsa   irs_id irs_id
 
 cap drop in_test
gen in_test = e(sample) == 1


count if year > 1991 & year<2001 & in_test == 1

cap drop code
gen code = .

replace code = 209 if assets<=0.25 
replace code = 213 if assets>0.25 & assets<=1  
replace code = 215 if assets>1 & assets<=5  
replace code = 217  if assets>5 & assets<=10  
replace code = 219 if assets>10 & assets<=50 
replace code = 221 if assets>50 & assets<=100 
replace code = 223 if assets>100 & assets<=250  
replace code = 225 if assets>250 & assets<. 


xtset rssd yq, quarterly
forvalues x = 1(1)12{
replace share_deposits = f.share_deposits if year <1994
}

forvalues x = 1(1)20{
replace share_deposits = f.share_deposits if share_deposits==.
}

count if year > 1991 & year<2001 & abs(share_deposits-1) <0.1 & share_deposits<.

 reg   perc_audited size_lag4 liab_to_assets_lag1    ///
 unemp_nsa ch_unemp_nsa_qtr  hpi_nsa     irs_id irs_id  if in_test == 1 & abs(share_deposits-1) <0.1 & share_deposits<.
 
 cap drop in_test
gen in_test = (e(sample) == 1)

count if year > 1991 & year<2001 & in_test == 1 & abs(share_deposits-1) <0.1 & share_deposits<.

count if year > 1991 & year<2001 & in_test == 1 & commercial_to_loans>0.01 & abs(share_deposits-1) <0.1 & share_deposits<.

count if year > 1991 & year<2001 & in_test == 1 & commercial_to_loans>0.01 & assets >25 & abs(share_deposits-1) <0.1 & share_deposits<.

gen revenue_growth_lag4 = l4.revenue_growth


 gen int_rev_assets= interest_revenue/l4.loans_scale
 gen int_inc_assets= interest_income/l4.loans_scale
 

foreach var of varlist nco_q_to_loans ch_npl  npl_loans_y_lag  ch_loans  ni_q liab_to_assets  commercial_to_loans  d_npl_loans_y ///
  nonperform_to_loans prov llp_q_to_loans llr_to_loans ch_npl_yr revenue_growth_lag4 npl_loans_y revenue_growth int_rev_assets int_inc_assets {
winsor `var',gen(`var'_w) p(0.01)
display `var'
}

cap drop llp_loans_y_w
cap drop nco_loans_y_w

foreach var of varlist llp_loans_y nco_loans_y{
winsor `var',gen(`var'_w) p(0.025)
}


winsor llp_loans_y, gen(llp_loans_y1) p(0.01)
winsor llp_loans_y, gen(llp_loans_y5) p(0.05)
winsor nco_loans_y, gen(nco_loans_y1) p(0.01)
winsor nco_loans_y, gen(nco_loans_y5) p(0.05)

 gen pi_at_dist = dist_sum_pi/dist_sum_at 


winsor dist_mean_cash_etr_1, gen(dist_mean_cash_etr_1_w) p(0.01)

gen inv_at_dist = dist_sum_capx/dist_sum_at  
gen cash_at_dist = dist_sum_che/dist_sum_at 


gen l1_pi_at_dist = l4.pi_at_dist
gen l1_dist_mean_cash_etr_1_w  = l4.dist_mean_cash_etr_1_w 
gen l1_ch_hpi_sa_qtr   = l4.ch_hpi_sa_qtr  
gen l1_change_unempl = l4.change_unempl
gen l1_unempl_dist  = l4.unempl_dist 
gen l1_hpi_sa_qtr   = l4.hpi_sa  
gen l1_cash_at_dist = l4.cash_at_dist
gen l1_inv_at_dist  = l4.inv_at_dist 
gen l1_hpi_change= l4.hpi_change 
gen l1_hpi_level= l4.hpi_level 

gen int_rev_assets_w_lag4= l4.int_rev_assets_w 
gen int_inc_assets_w_lag4= l4.int_inc_assets_w 

gen l4_ret_219=l4.ret_219
gen l4_perc_audited_219=l4.perc_audited_219
gen l4_perc_audited_209=l4.perc_audited_209
gen l4_perc_audited_213=l4.perc_audited_213
gen l4_perc_audited_215=l4.perc_audited_215
gen l4_perc_audited_217=l4.perc_audited_217
gen l4_perc_audited_221=l4.perc_audited_221
gen l4_perc_audited_223=l4.perc_audited_223
gen l4_perc_audited_225=l4.perc_audited_225
gen l4_perc_audited_bel_5=l4.perc_audited_bel_5

*keep if assets>50
drop if month != 12

xtset rssd year


 
keep if abs(share_deposits-1) <0.05 & share_deposits<.

xtset rssd year

*drop if year > 1999

sum l_commercial_to_loans if in_test == 1 & l_commercial_to_loans>0.01, d

replace l1_change_unempl = l1_change_unempl/100
replace l1_hpi_change = l1_hpi_change/100

 reg nco_loans_y_w   l4_perc_audited_219  size_lag4 liab_to_assets_lag4 revenue_growth_lag4_w ///
l1_pi_at_dist  l1_dist_mean_cash_etr_1_w l1_change_unempl l1_unempl_dist   ///
l1_cash_at_dist l1_inv_at_dist l1_hpi_change l1_hpi_level if in_test == 1 & l_commercial_to_loans>0.01  ///
,  cluster(rssd )

cap drop in_sample
gen in_sample = e(sample)

drop _m
merge n:1 state year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\State_Tax_Rates"

drop if _m ==2

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", replace



 
 /**Now, let's generate the Diff-in-Diff Sample*****/
 
 


use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final.dta", clear

 format date %td

/**make this panel data**/
gen yq = qofd(date)
format yq %tq

cap drop _merge
merge n:1 year irsdist using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta"

xtset rssd yq,quarterly

/**data screening**/
drop if assets <= 0
drop if assets_lag4 <= 0
drop if loans_net_lag4<0
drop if country == "PUERTO RICO"
drop if fed_charter == 0 & state_charter == 0
drop if state_code == ""
drop if totalcapital < 0
replace etr = . if pi<0
replace etr2 = . if ebtx<0

replace etr=0 if etr<0
replace etr=1 if etr>1 & etr<.

replace etr2=0 if etr2<0
replace etr2=1 if etr2>1 & etr2<.

gen ni2_q = ni if quarter == 1
replace ni2_q = ni - l.ni if quarter > 1


gen pi2_q = pi if quarter == 1
replace pi2_q = pi - l.pi if quarter > 1


gen llp2_q = llp if quarter == 1
replace llp2_q = llp - l.llp if quarter > 1

cap drop loans_scale 
gen loans_scale = l.loans_net + l.llr

cap drop llp_to_loans
gen llp_to_loans = llp2_q/loans_scale

gen nco_loans_y = nco / (l4.loans_net +l4.llr)



gen int_rev_loans=interest_revenue/loans_net_lag4

 
drop deposits* id_cusip name name2 city   country auditclass irsname fips_temp

drop dep_broker_unin_lag4 dep_insured_all_to_assets dep_insured_der_to_assets ///
dep_uninsured_all_to_assets dep_uninsured_der_to_assets dep_uninsured_der_to_liab ///
dep_broker_to_liab dep_broker_unin dep_broker_unin_to_liab dep_broker_growth_yr ///
dep_broker_unin_growth_yr


gen prov = nonperform/llr

gen liab_to_assets_lag1= l1.liab_to_assets
gen liab_to_assets_lag4= l4.liab_to_assets

cap drop revenue_growth
gen  revenue_growth = (interest_revenue-l4.interest_revenue)/l4.interest_revenue



gen llp_loans_y = llp / (l4.loans_net +l4.llr)
gen npl_loans_y = nonperform / (l4.loans_net +l4.llr)
gen f_npl_loans_y = f4.nonperform / (loans_net +llr)


egen irs_id = group(irsdist)
egen sd_irs_id = sd(irs_id), by(rssd)

keep if sd_irs_id == 0


drop if year<1995
drop if year>2004

drop if scorp == 1


xtset rssd yq
gen revenue_growth_lag4 = l4.revenue_growth

foreach var of varlist nco_q_to_loans ch_npl   liab_to_assets  commercial_to_loans   ///
  nonperform_to_loans prov llp_q_to_loans llr_to_loans ch_npl_yr revenue_growth_lag4 npl_loans_y revenue_growth {
winsor `var',gen(`var'_w) p(0.01)
display `var'
}



/**create the state-year-quarter fixed effects**/

xtset rssd yq, quarterly

replace irsdist = irsdist[_n-1] if year > 2000 & rssd == l.rssd


xtset rssd yq, quarterly

replace perc_audited_219 = 0.09280 if year ==2001
replace perc_audited_219 = 0.07510 if year ==2002
replace perc_audited_219 = 0.05851 if year ==2003
replace perc_audited_219 = 0.08848 if year ==2004
replace perc_audited_219 = 0.11430 if year ==2005

gen post = (year>2000) 

egen mean_audited_219 = mean(perc_audited_219) if year ~= 2000 & year<2004 & year >1997 , by(rssd post)


replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==1
replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==2
replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==3
replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==4



cap drop diff_219
gen diff_219 = d.mean_audited_219 if year == 2001 &quarter == 1

cap drop change_diff_219
egen change_diff_219 = mean(diff_219) , by(irsdist)

egen count_obs = count(year), by(rssd)



replace irs_id = l.irs_id if year > 2000 & rssd == l.rssd


cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta"

drop if _ == 2


cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta"


drop if _ == 2

 gen pi_at_dist = dist_sum_pi/dist_sum_at 


winsor dist_mean_cash_etr_1, gen(dist_mean_cash_etr_1_w) p(0.01)

gen inv_at_dist = dist_sum_capx/dist_sum_at  
gen cash_at_dist = dist_sum_che/dist_sum_at 


cap drop _m
merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_share_deposits.dta"
drop if _m == 2


drop if month != 12
cap drop _m
 

xtset rssd year


save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\Diff_in_Diff_sample.dta" , replace 

 
 
 /****End of generating panel data****/
 
 
 /***Final Step: Let us generate the cross-sectional split variables***/


 /***Input data for the cross-sectional splits**/
 
 use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch.dta", clear
rename rssdid rssd
rename stcntybr fips
rename depsumbr deposits_branch
keep year rssd namebr fips deposits_branch
drop if year>2000
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer.dta", replace

use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer.dta", clear
keep if year == 1994
replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer93.dta", replace

replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer92.dta", replace

replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer91.dta", replace

replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer90.dta", replace

use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer90.dta", clear
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer91.dta"
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer92.dta"
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer93.dta"
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer.dta"
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta", replace
 
 
 *Step 1: Regional Concentration & Local Competition

use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", clear

keep if month == 12
keep rssd year commercial

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\commercial_banks.dta", replace
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\commercial_banks.dta"
 
 keep if _m == 3
 
 egen sum_deposits = sum(deposits_branch) , by(rssd year)

gen buffer_weight = deposits_branch*commercial/sum_deposits

replace buffer_weight = 0 if buffer_weight==.

egen sum_commercial = sum(buffer_weight), by(fips year) 
 
gen buffer = (buffer_weight/sum_commercial)^2
egen HHI_County_Commercial = sum(buffer), by(fips year)
   
  keep fips year HHI 
  
  duplicates drop
  
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\county_level_information_branch.dta", replace
 
 
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", clear
  
 keep rssd year commercial
  
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_to_branch_data.dta", replace
 
 
use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta" , clear

merge n:1 fips year using  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\county_level_information_branch.dta"

drop if _m == 2
 
 cap drop _m

egen sum_deposits = sum(deposits_branch), by(rssd year)

gen buffer_weight = deposits_branch*HHI_County_Commercial/sum_deposits
egen b_HHI_County_Commercial=sum(buffer_weight),by(rssd year)

gen buffer = (deposits_branch/sum_deposits)^2
egen HHI_Bank_Region = sum(buffer), by(rssd year)

keep rssd year b_HHI_County_Commercial HHI_Bank_Region 

duplicates drop

replace year = year+1

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\bank_cross_section.dta", replace


 *Step 2: New Bank Entries
 
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", clear
 
 *drop if sbl_ind==1
 
 keep rssd year commercial_to_loans
 
 
 rename rssd rssdid
 
  
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\input_for_comm_branch.dta",replace
 
  
 use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch.dta" , clear
 drop if year >2000
  forvalues x=90(1)93{
 append using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_`x'.dta" , 
  }
 drop if asset == 0
 drop if depsumbr == 0
 
 merge n:1 rssdid year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\input_for_comm_branch.dta"
 
 drop if _m == 2
 
 rename stcntybr fips 
  
 gen acq_year = year(SIMS_ACQUIRED_DATE)
 gen est_year = year(SIMS_ESTABLISHED_DATE)
 cap drop age
 gen age = year-est_year
 drop if age <0
 replace age = year-acq_year if acq_year>est_year & acq_year<. 
 drop if age <0
 
 drop if commercial_to_loans<0.01
 
 egen count_branches = count(year) ,by(rssdid fips year)
 keep count_branches rssdid year fips
 
 duplicates drop 
 egen id = group(rssd fips)
  
xtset id year

gen new2 = (count_branches~=. & l.count_branches==. & year >1990)

 egen num_banks_fips=count(count_branches), by(fips year)
 egen num_new = sum(new2), by(fips year)
 
 keep num_banks_fips fips year num_new 
 
 duplicates drop 
 egen id = group(fips)
 
 xtset id year
 gen bank_entry_fips_alt = num_new
 gen bank_growth_fips = num_new/num_banks_fips
 
 drop id
 rename num_banks_fips num_banks_fips_alt  
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\net_entrants_fips91_99.dta", replace

 
 
 
  
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 
cap drop _m
merge n:1 fips year using   "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\net_entrants_fips91_99.dta"
drop if _m == 2


 egen sum_deposits = sum(deposits_branch) , by(rssd year)
 
cap drop buffer_weight
gen buffer_weight = deposits_branch*bank_growth_fips/sum_deposits
egen b_bank_growth_fips=sum(buffer_weight),by(rssd year)


keep rssd year b_*

duplicates drop

replace year = year+1
 
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\entrants_bank_new.dta" , replace
 
 
 
 
 
 /********Data for Table A.1**********/
 
 
 

use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final.dta", clear

format date %td

/**make this panel data**/
gen yq = qofd(date)
format yq %tq

drop if assets <=0
drop if assets_lag4 <= 0
drop if loans_net_lag4<0
drop if totalcapital < 0



merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_share_deposits.dta"

drop if _m == 2

cap drop state
cap drop _m
rename state_code state

merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta"

drop if _ == 2

cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta"


cap drop _merge
merge n:1 year irsdist using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta"



xtset rssd yq,quarterly

/**data screening**/

drop if country == "PUERTO RICO"
drop if fed_charter == 0 & state_charter == 0
drop if state == ""


count if year > 1991 & year<2001


replace etr = . if pi<0
replace etr2 = . if ebtx<0

replace etr=0 if etr<0
replace etr=1 if etr>1 & etr<.

replace etr2=0 if etr2<0
replace etr2=1 if etr2>1 & etr2<.

gen llp2_q = llp if quarter == 1
replace llp2_q = llp - l.llp if quarter > 1

cap drop loans_scale 
gen loans_scale = l.loans_net + l.llr

cap drop llp_to_loans
gen llp_to_loans = llp2_q/loans_scale

cap drop nonperform_to_loans
gen nonperform_to_loans = nonperform/loans_scale

gen etr_lead4=f4.etr2
gen etr_lead8=f8.etr2


gen llp_loans_y = llp / (l4.loans_net +l4.llr)
gen npl_loans_y = nonperform / (l4.loans_net +l4.llr)
gen npl_loans_y_lag = l4.npl_loans_y
gen cash_to_assets_lag = l4.cash_to_assets
gen d_npl_loans_y = (nonperform-l4.nonperform) / (l4.loans_net +l4.llr)
gen nco_loans_y = nco / (l4.loans_net +l4.llr)
gen ni_assets = ni/l4.assets
drop id_cusip name name2 city   country auditclass irsname fips_temp

drop dep_broker_unin_lag4 dep_insured_all_to_assets dep_insured_der_to_assets ///
dep_uninsured_all_to_assets dep_uninsured_der_to_assets dep_uninsured_der_to_liab ///
dep_broker_to_liab dep_broker_unin dep_broker_unin_to_liab dep_broker_growth_yr ///
dep_broker_unin_growth_yr

gen prov = nonperform/llr

gen liab_to_assets_lag1= l1.liab_to_assets
gen liab_to_assets_lag4= l4.liab_to_assets

gen l4_perc_audited_size=l4.perc_audited_size
 gen l_cons_to_loans=l4.consumer_to_loans

egen irs_id = group(irsdist)

/*Drop if firms banks move across districts*/
egen sd_irs_id = sd(irs_id), by(rssd)

keep if sd_irs_id == 0
count if year > 1991 & year<2001

gen  revenue_growth = (interest_revenue-l4.interest_revenue)/l4.interest_revenue

gen l_commercial_to_loans=l4.commercial_to_loans

egen sbl_ind = mean(sbl_ind), by(rssd year)


drop if year>2001




cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid_hold.dta" 
replace all_large_loans = all_large_loans/1000000
replace large_term_loans = large_term_loans/1000000


cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid_hold.dta" 
replace all_large_loans_par = all_large_loans_par/1000000
replace large_term_loans_par = large_term_loans_par/1000000



replace all_large_loans=0 if all_large_loans==. & month == 12
replace large_term_loans=0 if large_term_loans==. & month == 12

replace all_large_loans_par=0 if all_large_loans_par==. & month == 12
replace large_term_loans_par=0 if large_term_loans_par==. & month == 12


replace all_large_loans_par=all_large_loans_par+all_large_loans
replace large_term_loans_par=large_term_loans_par+large_term_loans

gen commercial_ex_large_all2=commercial-all_large_loans
gen commercial_ex_large_term2 =commercial-large_term_loans

gen commercial_ex_large_all_p2=commercial-all_large_loans_par
gen commercial_ex_large_term_p2 =commercial-large_term_loans_par


replace commercial_ex_large_all2=0 if commercial_ex_large_all2<0
replace commercial_ex_large_term2=0 if commercial_ex_large_term2<0
replace commercial_ex_large_all_p2=0 if commercial_ex_large_all_p2<0
replace commercial_ex_large_term_p2=0 if commercial_ex_large_term_p2<0


xtset rssd yq, quarterly
gen l_commercial_ex100_to_loans=l4.commercial_ex_100/l4.loans_scale
gen l_commercial_ex250_to_loans=l4.commercial_ex_250/l4.loans_scale
gen l_commercial_ex_mic_to_loans=l4.commercial_ex_micro/l4.loans_scale

/****/

 reg  perc_audited size_lag1 liab_to_assets_lag1    ///
 unemp_nsa ch_unemp_nsa_qtr  hpi_nsa   irs_id irs_id
 
 cap drop in_test
gen in_test = e(sample) == 1


count if year > 1991 & year<2001 & in_test == 1

cap drop code
gen code = .

replace code = 209 if assets<=0.25 
replace code = 213 if assets>0.25 & assets<=1  
replace code = 215 if assets>1 & assets<=5  
replace code = 217  if assets>5 & assets<=10  
replace code = 219 if assets>10 & assets<=50 
replace code = 221 if assets>50 & assets<=100 
replace code = 223 if assets>100 & assets<=250  
replace code = 225 if assets>250 & assets<. 


xtset rssd yq, quarterly
forvalues x = 1(1)12{
replace share_deposits = f.share_deposits if year <1994
}

forvalues x = 1(1)20{
replace share_deposits = f.share_deposits if share_deposits==.
}

gen revenue_growth_lag4 = l4.revenue_growth


 gen int_rev_assets= interest_revenue/l4.loans_scale
 gen int_inc_assets= interest_income/l4.loans_scale
 

foreach var of varlist nco_q_to_loans ch_npl  npl_loans_y_lag  ch_loans  ni_q liab_to_assets  commercial_to_loans  d_npl_loans_y ni_assets ///
  nonperform_to_loans prov llp_q_to_loans llr_to_loans ch_npl_yr revenue_growth_lag4 npl_loans_y revenue_growth int_rev_assets int_inc_assets {
winsor `var',gen(`var'_w) p(0.01)
display `var'
}

cap drop llp_loans_y_w
cap drop nco_loans_y_w

foreach var of varlist llp_loans_y nco_loans_y{
winsor `var',gen(`var'_w) p(0.025)
}

 gen pi_at_dist = dist_sum_pi/dist_sum_at 

gen inv_at_dist = dist_sum_capx/dist_sum_at  
gen cash_at_dist = dist_sum_che/dist_sum_at 


gen l1_pi_at_dist = l4.pi_at_dist
gen l1_dist_mean_cash_etr_1_w  = l4.dist_mean_cash_etr_1
gen l1_ch_hpi_sa_qtr   = l4.ch_hpi_sa_qtr  
gen l1_change_unempl = l4.change_unempl
gen l1_unempl_dist  = l4.unempl_dist 
gen l1_hpi_sa_qtr   = l4.hpi_sa  
gen l1_cash_at_dist = l4.cash_at_dist
gen l1_inv_at_dist  = l4.inv_at_dist 
gen l1_hpi_change= l4.hpi_change 
gen l1_hpi_level= l4.hpi_level 

gen int_rev_assets_w_lag4= l4.int_rev_assets_w 
gen int_inc_assets_w_lag4= l4.int_inc_assets_w 

gen l4_ret_219=l4.ret_219
gen l4_perc_audited_219=l4.perc_audited_219
gen l4_perc_audited_209=l4.perc_audited_209
gen l4_perc_audited_213=l4.perc_audited_213
gen l4_perc_audited_215=l4.perc_audited_215
gen l4_perc_audited_217=l4.perc_audited_217
gen l4_perc_audited_221=l4.perc_audited_221
gen l4_perc_audited_223=l4.perc_audited_223
gen l4_perc_audited_225=l4.perc_audited_225
gen l4_perc_audited_bel_5=l4.perc_audited_bel_5

*keep if assets>50
drop if month != 12

xtset rssd year

 
gen ln_comm_gr = ln(commercial/l.commercial)
 
winsor ln_comm_gr,gen(ln_comm_gr_w) p(0.01)


drop if assets<250
drop if year > 1999


count if abs(share_deposits-1) <0.05 & share_deposits<.
count if abs(share_deposits-1) >=0.05 & share_deposits<.
 
gen in_test_deposit=1
replace in_test_deposit=0 if abs(share_deposits-1) <0.05 & share_deposits<.


 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\data_for_comparison.dta",replace

 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 drop namebr deposits_branch
 
 duplicates drop
 
 egen count_counties = count(year), by(rssd year)
 
 keep rssd year count_counties 
 
 duplicates drop
 
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\county_data_for_comparison.dta", replace
 
  
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 
 egen count_branches = count(year), by(rssd year)
 
 keep rssd year count_branches 
 
 duplicates drop
 
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\branch_data_for_comparison.dta", replace
 
 
 
 *************
 

use "C:\Users\martin.jacob\Dropbox\GJ\data\final\Compustat_Sample", clear

cap drop mean_cash_etr_1_w

drop if inv_w==.

keep if at>10 & at <50

foreach var of varlist inv_w cash_assets_w pi_assets_w ni_assets_w sg_w lvg_w gross_margin_at_w  tangibility_w ///
intangibles_w ppe_w  cash_etr_1 { 
egen dist_mean_`var'_1050=mean(`var'), by(irsdist year)
}



egen count=count(year) , by(irsdist year)



foreach var of varlist capx che at dltt sale pi oibdp{ 
egen dist_sum_`var'_1050 = sum(`var'), by(irsdist year)
}

keep irsdist dist_mean_* dist_sum_* year count

duplicates drop

foreach var of varlist dist_mean_inv_w dist_mean_cash_assets_w dist_mean_pi_assets_w dist_mean_sg_w dist_mean_lvg_w dist_mean_gross_margin_at_w ///
 dist_mean_tangibility_w ///
dist_mean_intangibles_w dist_mean_ppe_w  dist_mean_cash_etr_1 { 
keep if `var' ~=.
}


replace year = year+1

save "C:\Users\martin.jacob\Dropbox\GJ\data\final\industry_info_dist_1050.dta", replace


use "C:\Users\martin.jacob\Dropbox\GJ\data\final\Compustat_Sample", clear

cap drop mean_cash_etr_1_w

drop if inv_w==.

keep if at>50

foreach var of varlist inv_w cash_assets_w pi_assets_w ni_assets_w sg_w lvg_w gross_margin_at_w  tangibility_w ///
intangibles_w ppe_w  cash_etr_1 { 
egen dist_mean_`var'_ab50=mean(`var'), by(irsdist year)
}



egen count=count(year) , by(irsdist year)



foreach var of varlist capx che at dltt sale pi oibdp{ 
egen dist_sum_`var'_ab50 = sum(`var'), by(irsdist year)
}

keep irsdist dist_mean_* dist_sum_* year count

duplicates drop

foreach var of varlist dist_mean_inv_w dist_mean_cash_assets_w dist_mean_pi_assets_w dist_mean_sg_w dist_mean_lvg_w dist_mean_gross_margin_at_w ///
 dist_mean_tangibility_w ///
dist_mean_intangibles_w dist_mean_ppe_w  dist_mean_cash_etr_1 { 
keep if `var' ~=.
}


replace year = year+1

save "C:\Users\martin.jacob\Dropbox\GJ\data\final\industry_info_dist_ab50.dta", replace


 

 /***Input for Table 9 - CRA Data ***/


 cd "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\CRA-Data"
 
 
 
import delimited "00exp_trans.dat", clear delimiter(tab)
gen respondentid = substr(v1, 1, 10)
gen rssd = substr(v1, 133, 10)
keep respondentid rssd
destring  rssd, replace
egen dup = count(rs), by(respon)
drop if dup==2
drop dup
save rssd_respondentid.dta, replace


import delimited "96exp_discl.dat", clear delimiter(tab)
gen table = substr(v1, 1, 4)
keep if table=="D1-1"
gen respondentid = substr(v1, 5, 10)
gen regulatorid = substr(v1, 15, 1)
gen year = substr(v1, 16, 4)
gen loantype = substr(v1, 20, 1)
gen actiontype = substr(v1, 21, 1)
gen state = substr(v1, 22, 2)
gen county = substr(v1, 24, 3)
gen msa = substr(v1, 27,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 44,6)
gen amountloans_lower100k = substr(v1, 50,8)
gen nloans_btwn100k250k = substr(v1, 58,6)
gen amountloans_btwn100k250k = substr(v1, 64,8)
gen nloans_greater250k = substr(v1, 72,6)
gen amountloans_greater250k = substr(v1, 78,8)
gen nloans_lower1M = substr(v1, 86,6)
gen amountloans_lower1M = substr(v1, 92,8)
gen nloans_affiliate = substr(v1, 100,6)
gen amountloans_affiliate = substr(v1, 106,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr reportlevel, replace force
drop if reportlevel==.
keep if reportlevel>399 // Here we have a different situation relative to older CRA reports (The code 400 is only reported when there are more than one 500 and 600 for each county.
duplicates tag respondentid regulatorid stcntybr, generate(dp) // Therefore, here I identify duplicate observations
keep if dp ==0 | reportlevel ==400 & msa=="    " //  and I keep either observations that are not duplicates or the code 400 for duplicate observations

drop table v1 reportlevel dp

egen number_counties=count(nloans_btwn100k250k),by(respondentid)

save sbl996, replace


foreach num of numlist 97/98{

import delimited `num'exp_discl.dat, clear delimiter(tab)
gen table = substr(v1, 1, 5)
keep if table=="D1-1 "
gen respondentid = substr(v1, 6, 10)
gen regulatorid = substr(v1, 16, 1)
gen year = substr(v1, 17, 4)
gen loantype = substr(v1, 21, 1)
gen actiontype = substr(v1, 22, 1)
gen state = substr(v1, 23, 2)
gen county = substr(v1, 25, 3)
gen msa = substr(v1, 28,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 45,6)
gen amountloans_lower100k = substr(v1, 51,8)
gen nloans_btwn100k250k = substr(v1, 59,6)
gen amountloans_btwn100k250k = substr(v1, 65,8)
gen nloans_greater250k = substr(v1, 73,6)
gen amountloans_greater250k = substr(v1, 79,8)
gen nloans_lower1M = substr(v1, 87,6)
gen amountloans_lower1M = substr(v1, 93,8)
gen nloans_affiliate = substr(v1, 101,6)
gen amountloans_affiliate = substr(v1, 107,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr reportlevel, replace force
drop if reportlevel==.
keep if reportlevel>39 // Here we have a different situation relative to older CRA reports (The code 400 is only reported when there are more than one 500 and 600 for each county.
duplicates tag respondentid regulatorid stcntybr, generate(dp) // Therefore, here I identify duplicate observations
keep if dp ==0 | reportlevel ==40 & msa=="    " //  and I keep either observations that are not duplicates or the code 400 for duplicate observations

drop table v1 reportlevel dp


egen number_counties=count(nloans_btwn100k250k),by(respondentid)

save sbl`num', replace
}


//// 1.3 **** Here I am cleaning the data from 1999 to 2003 (CRA started reporting the report level differently after 1998 and then CRA changed the codebook between 2003 and 2004)


import delimited 99exp_discl.dat, clear delimiter(tab)
gen table = substr(v1, 1, 5)
keep if table=="D1-1 "
gen respondentid = substr(v1, 6, 10)
gen regulatorid = substr(v1, 16, 1)
gen year = substr(v1, 17, 4)
gen loantype = substr(v1, 21, 1)
gen actiontype = substr(v1, 22, 1)
gen state = substr(v1, 23, 2)
gen county = substr(v1, 25, 3)
gen msa = substr(v1, 28,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 45,6)
gen amountloans_lower100k = substr(v1, 51,8)
gen nloans_btwn100k250k = substr(v1, 59,6)
gen amountloans_btwn100k250k = substr(v1, 65,8)
gen nloans_greater250k = substr(v1, 73,6)
gen amountloans_greater250k = substr(v1, 79,8)
gen nloans_lower1M = substr(v1, 87,6)
gen amountloans_lower1M = substr(v1, 93,8)
gen nloans_affiliate = substr(v1, 101,6)
gen amountloans_affiliate = substr(v1, 107,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr, replace force
keep if reportlevel =="040"

drop table v1 reportlevel

egen number_counties=count(nloans_btwn100k250k),by(respondentid)


save sbl999.dta, replace


foreach num of numlist 0/3{

import delimited 0`num'exp_discl.dat, clear delimiter(tab)
gen table = substr(v1, 1, 5)
keep if table=="D1-1 "
gen respondentid = substr(v1, 6, 10)
gen regulatorid = substr(v1, 16, 1)
gen year = substr(v1, 17, 4)
gen loantype = substr(v1, 21, 1)
gen actiontype = substr(v1, 22, 1)
gen state = substr(v1, 23, 2)
gen county = substr(v1, 25, 3)
gen msa = substr(v1, 28,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 45,6)
gen amountloans_lower100k = substr(v1, 51,8)
gen nloans_btwn100k250k = substr(v1, 59,6)
gen amountloans_btwn100k250k = substr(v1, 65,8)
gen nloans_greater250k = substr(v1, 73,6)
gen amountloans_greater250k = substr(v1, 79,8)
gen nloans_lower1M = substr(v1, 87,6)
gen amountloans_lower1M = substr(v1, 93,8)
gen nloans_affiliate = substr(v1, 101,6)
gen amountloans_affiliate = substr(v1, 107,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr, replace force
keep if reportlevel =="040"

drop table v1 reportlevel

egen number_counties=count(nloans_btwn100k250k),by(respondentid)

save sbl200`num', replace
}

use sbl996, clear
append using sbl97
append using sbl98
append using sbl999
append using sbl2000
append using sbl2001
append using sbl2002
append using sbl2003

merge n:1 respondentid using rssd_respondentid

keep if _m == 3

save cra_panel_raw.dta, replace




/***Let's generate the numbers within the district**/

use  cra_panel_raw.dta, clear

cap drop number_counties

/***Zoom in only on counties within the HQ district***/
gen fips = state+county
destring fips, replace
cap drop _m 
merge n:1 respondentid using rssd_respondentid

keep if _m == 3
drop _m

merge n:1 rssd using rssd_matched

keep if _m == 3

drop _m
replace irsdist="Pacific Northwest" if irsdist=="Pacific-Northwest"

merge n:1 fips using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\macroeconomic\fips_dist.dta" 

keep if _m == 3


keep if irsdist==irsdist_hq

egen total_loans=rowtotal(amountloans_btwn100k250k amountloans_greater250k)

egen total_loans_100=rowtotal(amountloans_lower100k)

egen total_loans_bank=sum(total_loans),by(rssd  year)
gen buf= total_loans/total_loans_bank
gen buf2 = buf*buf
egen disp_bank = sum(buf2),by(rssd  year)

egen total_loans_bank_100=sum(amountloans_lower100k),by(rssd  year)
cap drop buf buf2
gen buf= total_loans_100/total_loans_bank_100
gen buf2 = buf*buf
egen disp_bank_100 = sum(buf2),by(rssd  year)

keep  year  rssd total_loans_bank disp_bank_100  disp_bank total_loans_bank_100
duplicates drop 
destring year, replace
save cra_information_part_1.dta, replace

/***Let's generate the share of lending / number of counties where bank does not have a branch**/
use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta" , clear
keep if year>1995
drop namebr 
drop deposits_branch
duplicates drop
save raw_branch_for_merge.dta,replace

use  cra_panel_raw.dta, clear

cap drop number_counties

/***Zoom in only on counties within the HQ district***/
gen fips = state+county
destring fips, replace
cap drop _m 
merge n:1 respondentid using rssd_respondentid

keep if _m == 3
drop _m

merge n:1 rssd using rssd_matched

keep if _m == 3

drop _m
replace irsdist="Pacific Northwest" if irsdist=="Pacific-Northwest"

merge n:1 fips using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\macroeconomic\fips_dist.dta" 

keep if _m == 3


drop _m

destring year, replace
merge n:1 rssd year fips using raw_branch_for_merge

drop if _m == 2

keep if irsdist==irsdist_hq

egen total_loans=rowtotal(amountloans_btwn100k250k amountloans_greater250k)

egen total_loans_outside=sum(total_loans) if _m==1, by(rssd year)

cap drop buf 
egen buf = max(total_loans_outside),by(rssd year)
replace total_loans_outside=buf if total_loans_outside==.
replace total_loans_outside=0 if total_loans_outside==.


keep  year  rssd total_loans_outside 
duplicates drop

save cra_information_part_2.dta, replace 


use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta" , clear
keep if year>1995
drop namebr 
drop deposits_branch
duplicates drop
save raw_branch_for_merge.dta,replace

use  cra_panel_raw.dta, clear

cap drop number_counties

/***Zoom in only on counties within the HQ district***/
gen fips = state+county
destring fips, replace
cap drop _m 
merge n:1 respondentid using rssd_respondentid

keep if _m == 3
drop _m

merge n:1 rssd using rssd_matched

keep if _m == 3

drop _m
replace irsdist="Pacific Northwest" if irsdist=="Pacific-Northwest"

merge n:1 fips using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\macroeconomic\fips_dist.dta" 

keep if _m == 3


drop _m

destring year, replace
merge n:1 rssd year fips using raw_branch_for_merge

drop if _m == 2

keep if irsdist==irsdist_hq
egen total_loans=rowtotal(amountloans_lower100k)

egen group = group(rssd year fips)
egen dup = count(fips), by(group)
drop if dup == 2
egen group2 = group(rssd  fips)

xtset group2 year


egen total_loans_bank=sum(total_loans), by(rssd year)
egen total_loans_outside=sum(total_loans) if _m==1, by(rssd year)

drop if total_loans_bank==.
cap drop buf 
egen buf = max(total_loans_bank),by(rssd year)
replace total_loans_bank=buf if total_loans_bank==.

cap drop buf 
egen buf = max(total_loans_outside),by(rssd year)
replace total_loans_outside=buf if total_loans_outside==.

gen share_not_in_branch=total_loans_outside/total_loans_bank
 
keep  year  rssd  share_not_in_branch  
duplicates drop
rename share_not_in_branch share_not_in_branch_100


save cra_information_part_3.dta, replace 




use "C:\Users\martin.jacob\Desktop\fb9b4da6455c8e2b.dta" , clear

keep if loc == "USA"
keep if fic == "USA"
keep if curcd == "USD"

drop indfmt consol popsrc datafmt tic cusip conm acctstd acqmeth compst ///
 final ltcm ogm  costat add1 add2 add3 busdesc city conml county ///
dlrsn ein fax ggroup gind gsector gsubind phone prican prirow priusa ///
spcindcd spcseccd spcsrc ipodate dldte weburl loc fic curcd currtr curuscn curncd ///
acctchg adrr ajex ajp bspr fyr ismod pddur scf src stalt udpl upd apdedate  acchg acco accrt ///
acdo acodo acominc acox acqao acqcshi acqgdwl acqic acqintan acqinvt acqlntal acqniintc acqppe acqsc adpac ///
aedi afudcc afudci aldo am amc amdc amgw ano aocidergl aociother aocipen aocisecgl aodo aol2  aox ///
 apb apc apofs aqa aqc aqd aqeps aqi aqp aqpl1 aqs arb arc arce arced arceeps artfs aul3 autxr balr ///
 banlr bast bastr batr bcef bclr bcltbl bcnlr bcrbl bct bctbl bctr billexce bkvlps bltbl ca capr1 capr2 ///
 capr3 caps capsft capxv cb cbi cdpac ceiexbill ceql ceqt cfbd cfere cfo cfpdo cga cgri cgui cgti chech ///
 cibegni cicurr cidergl cimii ciother cipen cisecgl citotal cld2 cld3 cld4 cld5 clfc clfx clg clis cll ///
 cllc clo clrll clt cmp cnltbl cpcbl cpdoi cpnli cppbl cprei crvnli cshfd cshi cshpri cshr cshrc cshrp ///
 cshrso cshrt cshrw cstk cstkcv cstke dbi dc dclo dcom dcpstk dcs dcvsr dcvsub dcvt dd  dd2 dd3 dd4 ///
 dd5 derac deralt derhedgl derlc derllt dfpac dfs dfxa diladj dilavx dlcch dltis dlto dltp dltr dltsub ///
 dm dn do donr dpacb dpacc dpacli dpacls dpacme dpacnr dpaco dpacre dpact  dpdc dpltb dpret depc ///
  dpsc dpstb dptb dptc dptic dpvieb dpvio dpvir drc drci drlt ds dt dtea dted dteeps dtep dudd dvc ///
 dvdnp dvintf dvp dvpa dvpdp dvpibb dvrpiv dvsco dvrre dvt dxd2 dxd3 dxd4 dxd5 ea ///
  txva txw uaoloch uaox uapt ucaps uccons  ucustad udcopres udd udfcc udmb udolt  ///
 udpco udpfa udvp ufretsd ugi ui uinvt ulcm ulco uniami unl unnp unnpl unopinc unwcc  ///
 uois uopi uopres updvp upmcstk upmpf upmpfs upmsubp upstk upstkc upstksf urect urectr  ///
 urevub uspi ustdnc usubdvp usubpstk utfdoc utfosc utme utxfed uwkcapc uxinst uxintd  ///
 vpac vpo wcap wcapc wcapch wda wdd wdeps wdp ///
  fatp fca fdfr fea fel ffo ffs fiao finaco finao fincf finch findlc findlt finivst  ///
 finlco finlto finnp finrecc finreclt finrev finxint finxopr fopo fopox fopt fsrco  ///
 fsrct fuseo fuset gbbl gdwl gdwlam gdwlia gdwlid gdwlieps gdwlip geqrv gla glcea  ///
 glced glceeps glcep gld gleps gliv glp govgr govtown gp gphbl gplbl gpobl gprbl  ///
 gptbl gwo hedgegl iaeq iaeqci iaeqmi iafici iafxi iafxmi iali ///
  ialoi ialti iamli iaoi iapli transa tsa tsafc tso tstk tstkc tstkme  ///
 tstkn tstkp txtubadjust txtubbegin txtubend txtubmax txtubmin txtubposdec  ///
 txtubposinc txtubpospdec txtubpospinc txtubsettle txtubsoflimit txtubtxtr  ///
 txtubxintbs txtubxintis  iarei iasci iasmi iassi iasti iatci iati iatmi  ///
 iaui  ibadj ibbl ibc ibcom ibki ibmii icapt idiis idilb idilc idis idist  ///
 idit idits iire initb intano intc intpn  invfg invo invofs  ///
 invreh invrei invres invrm  invwip iobd ioi iore ip ipabl ipc iphbl  ///
 iplbl ipobl iptbl ipti ipv irei irent irii irli irnli irsi iseq iseqc  ///
 iseqm isfi isfxc isfxm isgr isgt isgu islg islgc islgm islt isng isngc  ///
 isngm isotc isoth isotm issc issm issu ist istc istm isut itcb itcc itci  ///
 ivaco  ivao ivch ivgod ivi ivncf ivpt ivst ivstch lcabg lcacl lcacr  ///
 lcag lcal lcalt lcam lcao lcast lcat lco lcox lcoxar lcoxdr  lcuacu li  ///
 lif lifr lifrp lloml lloo llot llrci llrcr llwoci llwocr lno lo lol2 loxdr lqpl1  ///
 lrv ls lse lst lt lul3 mib mibn mibt mii mrc1 mrc2 mrc3 mrc4 mrc5 mrct mrcta msa  ///
 msvrv mtl nat nco nfsr niadj nieci niint niintpfc niintpfp niit nim nio nipfc  ///
 nipfp nit nits nopi nopio np npanl npaore nparl npat nrtxt nrtxtd nrtxteps ob  ///
  tf tfva tfvce tfvl tie tii  txdba txdbca txdbcl  txdfed txdfo  txditc txds txeqii  ///
  opeps opili opincar opini opioi opiri opiti oprepsx optca optdr optex optexd optfvgr  ///
 optgr optlife optosby optosey optprcby optprcca optprcex optprcey optprcgr optprcwa  ///
 optrfr optvol palr panlr patr pcl pclr pcnlr pctr pdvc  pll pltbl pnca pncad pncaeps  ///
 pncia pncid pncieps pncip pncwia pncwid pncwieps pncwip pnlbl pnli pnrsho pobl ppcbl  ///
   ppenb ppenc ppenli ppenls ppenme ppennr ppeno  ppevbb ppeveb ppevo ppevr pppabl  ///
 ppphbl pppobl ppptbl prc prca prcad prcaeps prebl pri prodv prsho prstkc prstkcc prstkpc ///
  prvt pstk pstkc pstkl pstkn pstkr pstkrv ptbl ptran pvcl pvo pvon pvpl pvt pwoi radp  ///
 ragr rari rati rca rcd rceps rcl rcp rdip rdipa rdipd rdipeps rdp re rea reajo   ///
 recco recd recta rectr recub ret reuna reunr revt ris rll rlo rlp rlri rlt rmum  ///
 rpag rra rrd rreps rrp rstche rstchelt rvbci rvbpi rvbti rvdo rvdt rveqt rvlrv rvno  ///
 rvnt rvri rvsi rvti rvtxr rvupi rvutx saa sal salepfc salepfp sbdc sc sco scstkc  ///
 secu  seqo seta setd seteps setp siv spce spced spceeps spid spieps spioa spiop  ///
 sppe sppiv spstkc sret srt ssnp sstk stbo stio stkco stkcpa tdc tdscd tdsce tdsg tdslg  ///
 tdsmm tdsng tdso tdss tdst ebit ebitda eiea emol epsfi epsfx epspi epspx esopct esopdlt ///
 esopnr esopr esopt esub esubc excadj fatb fatc fatd exre fate fatl fatn fato xago xagt ///
 xcom xcomi xdepl xdp xeqo  xido  xindb xindc xins xinst  xintd xintopt xivi ///
 xivre xnbi xnf xnins xnitb xobd xoi xopr xoprar xoptd xopteps xore xpp xpr xrdp xrent ///
 xs xt xuw xuwli xuwnli xuwoi xuwrei xuwti exchg prch_c prcl_c adjex_c cshtr_f dvpsp_f ///
 dvpsx_f  prch_f prcl_f adjex_f rank au auop auopic ceoso cfoso add4 ialoi
 
 
 gen year = year(datadate)
 gen month = month(datadate)

 
 destring cik , replace force
 
drop if sale == .
drop if at == . 

drop if at<0
drop if ceq<0
drop if che<0
drop if sale<0

 egen id = group(gvkey)

 cap drop year
 
rename fyear year

xtset id year

 gen tca = -(recch+invch+apalch+txach+aoloch+dpc)/at
 gen cfo = (oancf + xidoc)/at
 gen chg_sales = (sale-l.sale)/at
 gen pped = (ppegt)/at
 
 gen ta = (ib-oancf)/l.at
 gen ppe = (ppegt)/l.at
 gen atinv = 1/at
 gen drevminddrect =( (sale-l.sale) - (rect-l.rect))/l.at
 
 
 gen ln_ta = log(at)
 gen leverage = dltt/l.at
 gen roa=ib/at
 gen ln_mve=ln(prcc_f*csho)
 gen mtb=(abs(prcc_f*csho)+dltt+dlc)/at
 
 cap drop buffer*
 forvalues x=1(1)8{
 gen buffer`x'=l`x'.oancf
 }
 
 egen buf_sd = rowsd(oancf buffer1-buffer8)
 gen sd_cf = buf_sd/at
 
  
 cap drop buffer*
 forvalues x=1(1)8{
 gen buffer`x'=l`x'.sale
 }
 cap drop buf_sd
 egen buf_sd = rowsd(sale buffer1-buffer8)
 drop buffer*
 gen sd_sale = buf_sd/at
 
 gen operating_cycle = ln( 360 / sale / (rect+rect-1)/2 + 360/cogs/(invt+l.invt)/2     )
 
 gen capital_intensity = ppent/l.at
 gen intangibles = (xrd+xad)/sale
 
 replace intangibles = 0 if intangibles == .
 
 gen presence_intan = (intangibles~=0)
 
 gen loss = (ni<0)
 
 drop if year<1989
 keep if year<2002
 foreach var of varlist  tca cfo chg_sales pped ta ppe atinv drevminddrect ///
 ln_ta leverage roa mtb sd_cf sd_sale operating_cycle capital_intensity intangibles {
 winsor `var' , gen(`var'_w) p(0.01)
 }
 
  
 
 destring sic, replace
 
 drop if sic >=4000 & sic<=4999
 drop if sic >=6000 & sic<=6999
 
 ffind sic, newvar(ff48) type(48)
 
 cap  rename fyear year 
xtset id year
 
 reg tca_w l.cfo_w cfo_w f.cfo_w chg_sales_w pped_w
 
 egen count_obs =count(year) if e(sample) == 1, by(ff48 year)
 
 egen reg_id = group(ff48 year) if count_obs>19 & count_obs<.
 
 
 gen b_residual_tca=.
 
 forvalues x = 1(1)602 {
 
 qui cap reg tca_w l.cfo_w cfo_w f.cfo_w chg_sales_w pped_w if reg_id==`x'
  cap drop resi
 qui cap predict resi , residuals
 qui cap replace b_residual_tca=resi if reg_id==`x'
 
 }
 
 
 gen accural_quality = -100 * (abs(b_residual_tca)+abs(l.b_residual_tca))/2
 
 gen b_residual_ta=.

 
 reg ta_w atinv_w drevminddrect_w ppe_w
 
  cap drop count_obs
 egen count_obs =count(year) if e(sample) == 1, by(ff48 year)
 cap drop reg_id
 egen reg_id = group(ff48 year) if count_obs>19 & count_obs<.
 
 
 forvalues x = 1(1)828{
 
 qui cap reg ta_w atinv_w drevminddrect_w ppe_w if reg_id==`x'
  cap drop resi
 qui cap predict resi , residuals
 qui cap replace b_residual_ta=resi if reg_id==`x'
 
 }
 
 
 gen disc_accruals = abs(b_residual_ta)
 
 winsor accural_quality, gen(accural_quality_w) p(0.01)
 winsor disc_accruals, gen(disc_accruals_w) p(0.01)
 
 
gen accruals = (d.act-d.lct-d.ch+d.dd1-dp)/l.at
winsor accruals, gen(accruals_w) p(0.01)

 
 egen buffer =count(cik), by(cik year)

 keep if buffer == 1 | (buffer == 2 & month == 12)
 
 drop buffer
 
 rename year fyear
merge 1:1 cik fyear using "C:\Users\martin.jacob\Dropbox\GJ\data\final\hq_10k.dta"
 
 drop if _m == 2
 

xtset id fyear
 
 forvalues x = 1(1)50{
replace ba_zip5 = ba_zip5[_n+1] if ba_zip5=="" & id == f.id
}

 replace ba_zip5 = substr(addzip,1,5) if ba_zip5==""
 
rename ba_zip5 zip 


/******
pecking order
1) use the actual year
2) if (1) not available, use the most recent 10k based HQ location
3) if (2) is not there, then we use use current address
******/
 
 
 cap drop _m
merge n:1 zip using "C:\Users\martin.jacob\Dropbox\GJ\data\irs audit (TRAC)\zip_fips_dist.dta"

keep if _m == 3

 rename  fyear year

cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\audit_rates_per_class.dta"



cap drop code
gen code = .

replace code = 209 if at<=0.25 
replace code = 213 if at>0.25 & at<=1  
replace code = 215 if at>1 & at<=5  
replace code = 217  if at>5 & at<=10  
replace code = 219 if at>10 & at<=50 
replace code = 221 if at>50 & at<=100 
replace code = 223 if at>100 & at<=250  
replace code = 225 if at>250 & at<. 

cap drop _m
merge n:1 irsdist code year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\irs_audit_prob_size.dta"

drop if _m == 2


gen buffer_rate=perc_audited_size

cap drop _m
merge n:1 code year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\corp_audits_post_2000.dta"

drop if _m == 2


egen irs_id = group(irsdist)

replace perc_audited_size  = perc_audit_size /100 if year>2000

egen ind_year = group(ff48 year)

save "C:\Users\martin.jacob\Dropbox\GJ\data\final\information_environment.dta", replace





 
 clear all
 import excel "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\Data for John 1.13.2020\fly_nb_lrc3.xlsx", sheet("Data Unique FYEAR Change") firstrow
 
 rename fyear_change year
 rename len gvkey 
 rename ta high_avoidance
 
 save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\tax_avoidance_status.dta", replace
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\ggm_nb.dta",clear

rename lender_g gvkey

keep gvkey 

duplicates drop

merge 1:n gvkey using  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\linking.dta"

keep if _m == 3

keep if rssd ~=""



keep rssd gvkey

merge n:n gvkey using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\tax_avoidance_status.dta"

keep if _m == 3

keep rssd year high_avoidance
destring rssd, replace

duplicates drop
gen bank_holding = 1

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\matched_rssds.dta", replace

rename rssd fin_hh_rssd
rename b bank_hold_par
rename high_avoidance high_avoidance_par
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\matched_rssds_parent.dta", replace





/**generate unemployment and house price stuff at the district level**/

 use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\macroeconomic\lf_all3.dta" , clear
 
 merge 1:1 fips year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\macroeconomic\HPI_fips.dta"
 
 cap drop _merge
 
 destring fips, replace
 
 merge n:1 fips using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\macroeconomic\fips_dist.dta"
 
 egen total = sum(Labor_Force) , by(irsdist year)
 egen unempl = sum(Unemployed), by(irsdist year)
 
 gen share_fips = annualchange*Labor_Force
 egen total_for_fips= sum(Labor_Force) if annualchange~=. ,by(irsdist year)
 egen nom_for_fips= sum(share_fips) if annualchange~=. ,by(irsdist year)
 
 gen hpi_change=nom_for_fips/total_for_fips
 
 cap drop share_fips total_for_fips nom_for_fips
 gen share_fips = hpiwith1990base*Labor_Force
 egen total_for_fips= sum(Labor_Force) if annualchange~=. ,by(irsdist year)
 egen nom_for_fips= sum(share_fips) if annualchange~=. ,by(irsdist year)
 
 gen hpi_level=nom_for_fips/total_for_fips
   
 gen unempl_dist = unempl/total
 
 keep irsdist year unempl_dist hpi_change hpi_level
 
 drop if hpi_change==.
 
 duplicates drop 
 egen id = group(irsdist)
 
 xtset id year
 
 gen change_unempl = d.unempl_dist
 
 drop if year == .
 
 drop if id == .
 
 replace  irsdist = "Pacific-Northwest" if  irsdist == "Pacific Northwest"
  
 
  save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta" , replace
 

 
 
/**generate firm-level information using compustat
Step 1: merge HQ data
Step 2: generate district level data
**/

  use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\hq\10-K_Headers.dta" , clear

keep cik ba_zip5 fyear

drop if cik==.

xtset cik fyear


forvalues x = 1(1)20{
replace ba_zip5 = ba_zip5[_n+1] if ba_zip5=="" & cik == f.cik
}

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\hq_10k.dta", replace


/**Second step: Create State/Country Level Averages**/

 use "C:\Users\martin.jacob\Desktop\fb9b4da6455c8e2b.dta" , clear
 
keep if loc == "USA"
keep if fic == "USA"
keep if curcd == "USD"
 
 gen year = year(datadate)
 gen month = month(datadate)

 
 destring cik , replace force
 
drop if sale == .
drop if at == . 

drop if at<0
drop if ceq<0
drop if che<0
drop if sale<0

drop if cik == .

drop if sic == "6020"
drop if sic == "6022"

 egen buffer =count(cik), by(cik fyear)

 keep if buffer == 1 | (buffer == 2 & month == 12)
 
 drop buffer
 
 
merge 1:1 cik fyear using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\hq_10k.dta"
 
 drop if _m == 2
 

egen id = group(gvkey)

xtset id fyear
 
 forvalues x = 1(1)50{
replace ba_zip5 = ba_zip5[_n+1] if ba_zip5=="" & id == f.id
}

 replace ba_zip5 = substr(addzip,1,5) if ba_zip5==""
 
rename ba_zip5 zip 


/******
pecking order
1) use the actual year
2) if (1) not available, use the most recent 10k based HQ location
3) if (2) is not there, then we use use current address
******/
 
 
 cap drop _m
merge n:1 zip using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\irs audit (TRAC)\zip_fips_dist.dta"

keep if _m == 3


cap drop year
rename fyear year

xtset id year

gen inv=capx/ppegt
gen cash_assets=che/at
gen income_assets=(oibdp)/l.at
gen pi_assets=(pi)/l.at
gen ni_assets=(ni)/l.at
gen sg=ln(sale/ll.sale)
gen lvg=(dltt + dlc)/at
gen size=ln(at)
gen q_=(csho*prcc_c)/at
gen gross_margin_at=(sale-cogs)/sale
gen profit_margin_at=(pi)/sale
gen ltdebt_book_equity= (dltt)/ceq
gen intangibles = intan/ at
gen ppe = ppegt/ at
gen tangibility = (ppegt+intan)/at


gen cash_etr_1 = txpd / pi
replace cash_etr_1 = 0 if cash_etr_1<0
replace cash_etr_1 = 1 if cash_etr_1>1 & cash_etr_1<.
replace cash_etr_1 = . if pi<0

keep if year >1989

keep if year < 2006

foreach var of varlist inv cash_assets income_assets sg lvg gross_margin_at profit_margin_at tangibility ///
intangibles ppe ltdebt_book_equity pi_assets ni_assets  { 
winsor `var', p(.01) gen(`var'_w)
}

cap drop _m
merge n:1 zip  using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\zip_state.dta"

drop if _m == 2

egen irs_id = group(irsdist)

gen sic2 = substr(sic,1,2)

egen ind_state_year = group(sic2 state year)

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\Compustat_Sample", replace



use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\Compustat_Sample", clear

cap drop mean_cash_etr_1_w

xtset id year

gen cf_assets = oancf/l.at

winsor cf_assets , gen(cf_assets_w) p(0.01)

gen loss = (ni<0) if ni<.

egen sum_firms = count(ni) if ni ~=. ,by(irsdist year)
egen sum_losses = sum(loss) if ni ~=. ,by(irsdist year)
gen share_losses = sum_losses/sum_firms


drop if inv_w==.
foreach var of varlist inv_w cash_assets_w pi_assets_w ni_assets_w sg_w lvg_w gross_margin_at_w profit_margin_at_w tangibility_w ///
intangibles_w ppe_w ltdebt_book_equity_w cash_etr_1 cf_assets_w { 
egen dist_mean_`var'=mean(`var'), by(irsdist year)
}

egen count=count(year) , by(irsdist year)

foreach var of varlist capx che at dltt sale pi oibdp{ 
egen dist_sum_`var' = sum(`var'), by(irsdist year)
}

keep irsdist dist_mean_* dist_sum_* year count sum_firms sum_losses share_losses

duplicates drop

foreach var of varlist dist_mean_inv_w dist_mean_cash_assets_w dist_mean_pi_assets_w dist_mean_sg_w dist_mean_lvg_w dist_mean_gross_margin_at_w ///
dist_mean_profit_margin_at_w dist_mean_tangibility_w dist_mean_cf_assets_w ///
dist_mean_intangibles_w dist_mean_ppe_w dist_mean_ltdebt_book_equity_w dist_mean_cash_etr_1 share_losses{ 
keep if `var' ~=.
}
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta", replace

replace year = year + 1 
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist_lag.dta", replace


/***input of shares in each district***/



use "C:\Users\martin.jacob\Dropbox\GJ\data\final\district_share.dta", clear

merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\irs_audit_prob.dta"

keep if _m == 3


drop _m 

sort rssd year

cap drop dep_share

gen share_deposits = depdist / depdom

egen max_share = max(share_deposits),by(rssd year)

gen main_location = ( share_deposits== max_share)

egen buff_sum_prob=sum(share_dep), by(rssd year main_location)
gen buf_weighted_perc=(perc_audited*share_dep) / buff_sum_prob

egen weighted_perd = sum(buf_weighted_perc), by(rssd year main_location)

gen buf_perc_audited_main = weighted_perd if main_location == 1
gen buf_perc_audited_other = weighted_perd if main_location == 0

egen perc_audited_main  = mean(buf_perc_audited_main), by(rssd year)
egen perc_audited_other  = mean(buf_perc_audited_other), by(rssd year)

replace perc_audited_other = perc_audited_main if perc_audited_other==.

keep if main_location == 1

keep rssd year perc_audited_main perc_audited_other  share_deposits

duplicates tag rssd year, gen(buffer)
drop if buffer == 1

drop buffer

xtset rssd year

rssdid rssd

save  "C:\Users\martin.jacob\Dropbox\GJ\data\final\input_share_deposits.dta", replace



/******generate audit percentage data******/

clear all

import delimited "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\irs audit (TRAC)\IRS District Audits, FY 1992 - 2000.csv"

rename fy year
rename irsname irsdist

gen perc_audited_other=.

drop if code == 200

 /**this creates the audit percentages by size class**/
egen aud_bel5=sum(aud) if code>200 & code<216, by(irsdist year)
egen buf_ret_bel5=sum(ret) if code>200 & code<216, by(irsdist year)
 
gen buf_perc_audited_bel_5 = aud_bel5/buf_ret_bel5

egen perc_audited_bel_5 = mean(buf_perc_audited_bel_5), by(irsdist year)
egen ret_bel5 = mean(buf_ret_bel5), by(irsdist year)
 
 
forvalues var = 209(2)225{

gen buf_perc_audited_`var' = aud/ret if code == `var'

egen perc_audited_`var' = mean(buf_perc_audited_`var'), by(irsdist year)

 egen buf_ret_`var' = sum(ret) if  code == `var', by(irsdist year)
 egen ret_`var'=mean(buf_ret_`var') , by(irsdist year)

}
 
 keep year irsdist code  perc_audited_* ret_*

 cap drop perc_audited_other 
 cap drop perc_audited_211 
 cap drop ret_211
 cap drop code
 duplicates drop
 
  
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta", replace



/****merging Dealscan information to our dataset - data preparation***/
use  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed.dta" , clear

egen total_loans = sum(loan_total_mixed),by(lenderid year)
gen buffer = loan_total_mixed if ltype=="term"
egen term_loans = sum(buffer),by(lenderid year)

keep lenderid  year total_loans term_loans
duplicates drop

xtset lenderid year

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel.dta" , replace
 
 

 
use  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed.dta" , clear

egen total_loans = sum(loan_total_mixed),by(UltimateParentID year)
gen buffer = loan_total_mixed if ltype=="term"
egen term_loans = sum(buffer),by(UltimateParentID year)

keep UltimateParentID  year total_loans term_loans
duplicates drop

xtset UltimateParentID year

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel_parent.dta" , replace
 

use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\link_lenderid.dta" , clear
egen count=count(year), by(lenderid year)
egen max_best = max(best_match),  by(lenderid year)
drop if count>1 & best_match==0 &max_best==1
drop if year>2000
drop count 
egen count=count(year), by(lenderid year)
*drop if count>1 & best_match==0 

duplicates drop
sort lenderid year
 keep lenderid rssd year

 merge n:1 lenderid year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel.dta" , 

egen all_large_loans = sum(total_loans),by(rssd year)
egen large_term_loans = sum(term_loans),by(rssd year)

keep rssd  year all_large_loans large_term_loans
duplicates drop

xtset rssd year

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid.dta" , replace
 
rename rssd fin_hh_rssd

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid_hold.dta" , replace
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\link_parentid.dta" , clear
egen count=count(year), by(ultimateparentid year)

egen max_best = max(best_match),  by(ultimateparentid year)
drop if count>1 & best_match==0 &max_best==1
drop if year>2000
duplicates drop
sort ultimateparentid year
 keep ultimateparentid rssd year

 rename ultimateparentid UltimateParentID
 
 merge n:1 UltimateParentID year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel_parent.dta" , 


egen all_large_loans_par = sum(total_loans),by(rssd year)
egen large_term_loans_par = sum(term_loans),by(rssd year)

keep rssd  year all_large_loans large_term_loans
duplicates drop

xtset rssd year
save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid.dta" , replace
  

rename rssd fin_hh_rssd
save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid_hold.dta" , replace
  
/****End of Dealscan data preparation***/



/****Let us generate the acutal panel data****/


use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final.dta", clear

format date %td

/**make this panel data**/
gen yq = qofd(date)
format yq %tq

drop if assets <= 0
drop if assets_lag4 <= 0
drop if loans_net_lag4<0
drop if totalcapital < 0



merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_share_deposits.dta"

drop if _m == 2

cap drop state
cap drop _m
rename state_code state

merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta"

drop if _ == 2

cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta"


cap drop _merge
merge n:1 year irsdist using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta"



xtset rssd yq,quarterly

/**data screening**/

drop if country == "PUERTO RICO"
drop if fed_charter == 0 & state_charter == 0
drop if state == ""


count if year > 1991 & year<2001


replace etr = . if pi<0
replace etr2 = . if ebtx<0

replace etr=0 if etr<0
replace etr=1 if etr>1 & etr<.

replace etr2=0 if etr2<0
replace etr2=1 if etr2>1 & etr2<.

gen llp2_q = llp if quarter == 1
replace llp2_q = llp - l.llp if quarter > 1

cap drop loans_scale 
gen loans_scale = l.loans_net + l.llr

cap drop llp_to_loans
gen llp_to_loans = llp2_q/loans_scale

cap drop nonperform_to_loans
gen nonperform_to_loans = nonperform/loans_scale


gen llp_loans_y = llp / (l4.loans_net +l4.llr)
gen npl_loans_y = nonperform / (l4.loans_net +l4.llr)
gen npl_loans_y_lag = l4.npl_loans_y
gen cash_to_assets_lag = l4.cash_to_assets
gen d_npl_loans_y = (nonperform-l4.nonperform) / (l4.loans_net +l4.llr)
gen nco_loans_y = nco / (l4.loans_net +l4.llr)
 
drop deposits* id_cusip name name2 city   country auditclass irsname fips_temp

drop dep_broker_unin_lag4 dep_insured_all_to_assets dep_insured_der_to_assets ///
dep_uninsured_all_to_assets dep_uninsured_der_to_assets dep_uninsured_der_to_liab ///
dep_broker_to_liab dep_broker_unin dep_broker_unin_to_liab dep_broker_growth_yr ///
dep_broker_unin_growth_yr

gen prov = nonperform/llr

gen liab_to_assets_lag1= l1.liab_to_assets
gen liab_to_assets_lag4= l4.liab_to_assets
gen weight_l2= l8.commercial

gen l4_perc_audited_size=l4.perc_audited_size
 gen l_cons_to_loans=l4.consumer_to_loans

egen irs_id = group(irsdist)

/*Drop if firms banks move across districts*/
egen sd_irs_id = sd(irs_id), by(rssd)

keep if sd_irs_id == 0
count if year > 1991 & year<2001

gen  revenue_growth = (interest_revenue-l4.interest_revenue)/l4.interest_revenue

gen l_commercial_to_loans=l4.commercial_to_loans

egen sbl_ind = mean(sbl_ind), by(rssd year)


drop if year>2001

/**The next lines are input for robustness tests mentioned in footnotes**/


gen less_than100k=(l2.comm_lt100_total+f2.comm_lt100_total)/2
gen bet_100_250=(l2.comm_100_250_total+f2.comm_100_250_total)/2

cap drop buffer
gen buffer=commercial-comm_lt100_total
cap drop commercial_ex_100
egen commercial_ex_100=mean(buffer),by(rssd year)


/***merge of dealscan**/

cap drop _m
merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid.dta" 
replace all_large_loans = all_large_loans/1000000
replace large_term_loans = large_term_loans/1000000


cap drop _m
merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid.dta" 
replace all_large_loans_par = all_large_loans_par/1000000
replace large_term_loans_par = large_term_loans_par/1000000


replace all_large_loans=0 if all_large_loans==. & month == 12
replace large_term_loans=0 if large_term_loans==. & month == 12

replace all_large_loans_par=0 if all_large_loans_par==. & month == 12
replace large_term_loans_par=0 if large_term_loans_par==. & month == 12

replace all_large_loans_par=all_large_loans_par+all_large_loans
replace large_term_loans_par=large_term_loans_par+large_term_loans

gen commercial_ex_large_all=commercial-all_large_loans
gen commercial_ex_large_term =commercial-large_term_loans

gen commercial_ex_large_all_p=commercial-all_large_loans_par
gen commercial_ex_large_term_p =commercial-large_term_loans_par


replace commercial_ex_large_all=0 if commercial_ex_large_all<0
replace commercial_ex_large_term=0 if commercial_ex_large_term<0
replace commercial_ex_large_all_p=0 if commercial_ex_large_all_p<0
replace commercial_ex_large_term_p=0 if commercial_ex_large_term_p<0



rename all_large_loans all_large_loans_dir
rename large_term_loans large_term_loans_dir
rename all_large_loans_par all_large_loans_par_dir
rename large_term_loans_par large_term_loans_par_dir



cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid_hold.dta" 
replace all_large_loans = all_large_loans/1000000
replace large_term_loans = large_term_loans/1000000


cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid_hold.dta" 
replace all_large_loans_par = all_large_loans_par/1000000
replace large_term_loans_par = large_term_loans_par/1000000



replace all_large_loans=0 if all_large_loans==. & month == 12
replace large_term_loans=0 if large_term_loans==. & month == 12

replace all_large_loans_par=0 if all_large_loans_par==. & month == 12
replace large_term_loans_par=0 if large_term_loans_par==. & month == 12


replace all_large_loans_par=all_large_loans_par+all_large_loans
replace large_term_loans_par=large_term_loans_par+large_term_loans

gen commercial_ex_large_all2=commercial-all_large_loans
gen commercial_ex_large_term2 =commercial-large_term_loans

gen commercial_ex_large_all_p2=commercial-all_large_loans_par
gen commercial_ex_large_term_p2 =commercial-large_term_loans_par


replace commercial_ex_large_all2=0 if commercial_ex_large_all2<0
replace commercial_ex_large_term2=0 if commercial_ex_large_term2<0
replace commercial_ex_large_all_p2=0 if commercial_ex_large_all_p2<0
replace commercial_ex_large_term_p2=0 if commercial_ex_large_term_p2<0


xtset rssd yq, quarterly
gen l_commercial_ex100_to_loans=l4.commercial_ex_100/l4.loans_scale

/****/

 reg  perc_audited size_lag1 liab_to_assets_lag1    ///
 unemp_nsa ch_unemp_nsa_qtr  hpi_nsa   irs_id irs_id
 
 cap drop in_test
gen in_test = e(sample) == 1


count if year > 1991 & year<2001 & in_test == 1

cap drop code
gen code = .

replace code = 209 if assets<=0.25 
replace code = 213 if assets>0.25 & assets<=1  
replace code = 215 if assets>1 & assets<=5  
replace code = 217  if assets>5 & assets<=10  
replace code = 219 if assets>10 & assets<=50 
replace code = 221 if assets>50 & assets<=100 
replace code = 223 if assets>100 & assets<=250  
replace code = 225 if assets>250 & assets<. 


xtset rssd yq, quarterly
forvalues x = 1(1)12{
replace share_deposits = f.share_deposits if year <1994
}

forvalues x = 1(1)20{
replace share_deposits = f.share_deposits if share_deposits==.
}

count if year > 1991 & year<2001 & abs(share_deposits-1) <0.1 & share_deposits<.

 reg   perc_audited size_lag4 liab_to_assets_lag1    ///
 unemp_nsa ch_unemp_nsa_qtr  hpi_nsa     irs_id irs_id  if in_test == 1 & abs(share_deposits-1) <0.1 & share_deposits<.
 
 cap drop in_test
gen in_test = (e(sample) == 1)

count if year > 1991 & year<2001 & in_test == 1 & abs(share_deposits-1) <0.1 & share_deposits<.

count if year > 1991 & year<2001 & in_test == 1 & commercial_to_loans>0.01 & abs(share_deposits-1) <0.1 & share_deposits<.

count if year > 1991 & year<2001 & in_test == 1 & commercial_to_loans>0.01 & assets >25 & abs(share_deposits-1) <0.1 & share_deposits<.

gen revenue_growth_lag4 = l4.revenue_growth


 gen int_rev_assets= interest_revenue/l4.loans_scale
 gen int_inc_assets= interest_income/l4.loans_scale
 

foreach var of varlist nco_q_to_loans ch_npl  npl_loans_y_lag  ch_loans  ni_q liab_to_assets  commercial_to_loans  d_npl_loans_y ///
  nonperform_to_loans prov llp_q_to_loans llr_to_loans ch_npl_yr revenue_growth_lag4 npl_loans_y revenue_growth int_rev_assets int_inc_assets {
winsor `var',gen(`var'_w) p(0.01)
display `var'
}

cap drop llp_loans_y_w
cap drop nco_loans_y_w

foreach var of varlist llp_loans_y nco_loans_y{
winsor `var',gen(`var'_w) p(0.025)
}


winsor llp_loans_y, gen(llp_loans_y1) p(0.01)
winsor llp_loans_y, gen(llp_loans_y5) p(0.05)
winsor nco_loans_y, gen(nco_loans_y1) p(0.01)
winsor nco_loans_y, gen(nco_loans_y5) p(0.05)

 gen pi_at_dist = dist_sum_pi/dist_sum_at 


winsor dist_mean_cash_etr_1, gen(dist_mean_cash_etr_1_w) p(0.01)

gen inv_at_dist = dist_sum_capx/dist_sum_at  
gen cash_at_dist = dist_sum_che/dist_sum_at 


gen l1_pi_at_dist = l4.pi_at_dist
gen l1_dist_mean_cash_etr_1_w  = l4.dist_mean_cash_etr_1_w 
gen l1_ch_hpi_sa_qtr   = l4.ch_hpi_sa_qtr  
gen l1_change_unempl = l4.change_unempl
gen l1_unempl_dist  = l4.unempl_dist 
gen l1_hpi_sa_qtr   = l4.hpi_sa  
gen l1_cash_at_dist = l4.cash_at_dist
gen l1_inv_at_dist  = l4.inv_at_dist 
gen l1_hpi_change= l4.hpi_change 
gen l1_hpi_level= l4.hpi_level 

gen int_rev_assets_w_lag4= l4.int_rev_assets_w 
gen int_inc_assets_w_lag4= l4.int_inc_assets_w 

gen l4_ret_219=l4.ret_219
gen l4_perc_audited_219=l4.perc_audited_219
gen l4_perc_audited_209=l4.perc_audited_209
gen l4_perc_audited_213=l4.perc_audited_213
gen l4_perc_audited_215=l4.perc_audited_215
gen l4_perc_audited_217=l4.perc_audited_217
gen l4_perc_audited_221=l4.perc_audited_221
gen l4_perc_audited_223=l4.perc_audited_223
gen l4_perc_audited_225=l4.perc_audited_225
gen l4_perc_audited_bel_5=l4.perc_audited_bel_5

*keep if assets>50
drop if month != 12

xtset rssd year


 
keep if abs(share_deposits-1) <0.05 & share_deposits<.

xtset rssd year

*drop if year > 1999

sum l_commercial_to_loans if in_test == 1 & l_commercial_to_loans>0.01, d

replace l1_change_unempl = l1_change_unempl/100
replace l1_hpi_change = l1_hpi_change/100

 reg nco_loans_y_w   l4_perc_audited_219  size_lag4 liab_to_assets_lag4 revenue_growth_lag4_w ///
l1_pi_at_dist  l1_dist_mean_cash_etr_1_w l1_change_unempl l1_unempl_dist   ///
l1_cash_at_dist l1_inv_at_dist l1_hpi_change l1_hpi_level if in_test == 1 & l_commercial_to_loans>0.01  ///
,  cluster(rssd )

cap drop in_sample
gen in_sample = e(sample)

drop _m
merge n:1 state year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\State_Tax_Rates"

drop if _m ==2

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", replace



 
 /**Now, let's generate the Diff-in-Diff Sample*****/
 
 


use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final.dta", clear

 format date %td

/**make this panel data**/
gen yq = qofd(date)
format yq %tq

cap drop _merge
merge n:1 year irsdist using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta"

xtset rssd yq,quarterly

/**data screening**/
drop if assets <= 0
drop if assets_lag4 <= 0
drop if loans_net_lag4<0
drop if country == "PUERTO RICO"
drop if fed_charter == 0 & state_charter == 0
drop if state_code == ""
drop if totalcapital < 0
replace etr = . if pi<0
replace etr2 = . if ebtx<0

replace etr=0 if etr<0
replace etr=1 if etr>1 & etr<.

replace etr2=0 if etr2<0
replace etr2=1 if etr2>1 & etr2<.

gen ni2_q = ni if quarter == 1
replace ni2_q = ni - l.ni if quarter > 1


gen pi2_q = pi if quarter == 1
replace pi2_q = pi - l.pi if quarter > 1


gen llp2_q = llp if quarter == 1
replace llp2_q = llp - l.llp if quarter > 1

cap drop loans_scale 
gen loans_scale = l.loans_net + l.llr

cap drop llp_to_loans
gen llp_to_loans = llp2_q/loans_scale

gen nco_loans_y = nco / (l4.loans_net +l4.llr)



gen int_rev_loans=interest_revenue/loans_net_lag4

 
drop deposits* id_cusip name name2 city   country auditclass irsname fips_temp

drop dep_broker_unin_lag4 dep_insured_all_to_assets dep_insured_der_to_assets ///
dep_uninsured_all_to_assets dep_uninsured_der_to_assets dep_uninsured_der_to_liab ///
dep_broker_to_liab dep_broker_unin dep_broker_unin_to_liab dep_broker_growth_yr ///
dep_broker_unin_growth_yr


gen prov = nonperform/llr

gen liab_to_assets_lag1= l1.liab_to_assets
gen liab_to_assets_lag4= l4.liab_to_assets

cap drop revenue_growth
gen  revenue_growth = (interest_revenue-l4.interest_revenue)/l4.interest_revenue



gen llp_loans_y = llp / (l4.loans_net +l4.llr)
gen npl_loans_y = nonperform / (l4.loans_net +l4.llr)
gen f_npl_loans_y = f4.nonperform / (loans_net +llr)


egen irs_id = group(irsdist)
egen sd_irs_id = sd(irs_id), by(rssd)

keep if sd_irs_id == 0


drop if year<1995
drop if year>2004

drop if scorp == 1


xtset rssd yq
gen revenue_growth_lag4 = l4.revenue_growth

foreach var of varlist nco_q_to_loans ch_npl   liab_to_assets  commercial_to_loans   ///
  nonperform_to_loans prov llp_q_to_loans llr_to_loans ch_npl_yr revenue_growth_lag4 npl_loans_y revenue_growth {
winsor `var',gen(`var'_w) p(0.01)
display `var'
}



/**create the state-year-quarter fixed effects**/

xtset rssd yq, quarterly

replace irsdist = irsdist[_n-1] if year > 2000 & rssd == l.rssd


xtset rssd yq, quarterly

replace perc_audited_219 = 0.09280 if year ==2001
replace perc_audited_219 = 0.07510 if year ==2002
replace perc_audited_219 = 0.05851 if year ==2003
replace perc_audited_219 = 0.08848 if year ==2004
replace perc_audited_219 = 0.11430 if year ==2005

gen post = (year>2000) 

egen mean_audited_219 = mean(perc_audited_219) if year ~= 2000 & year<2004 & year >1997 , by(rssd post)


replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==1
replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==2
replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==3
replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==4



cap drop diff_219
gen diff_219 = d.mean_audited_219 if year == 2001 &quarter == 1

cap drop change_diff_219
egen change_diff_219 = mean(diff_219) , by(irsdist)

egen count_obs = count(year), by(rssd)



replace irs_id = l.irs_id if year > 2000 & rssd == l.rssd


cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta"

drop if _ == 2


cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta"


drop if _ == 2

 gen pi_at_dist = dist_sum_pi/dist_sum_at 


winsor dist_mean_cash_etr_1, gen(dist_mean_cash_etr_1_w) p(0.01)

gen inv_at_dist = dist_sum_capx/dist_sum_at  
gen cash_at_dist = dist_sum_che/dist_sum_at 


cap drop _m
merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_share_deposits.dta"
drop if _m == 2


drop if month != 12
cap drop _m
 

xtset rssd year


save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\Diff_in_Diff_sample.dta" , replace 

 
 
 /****End of generating panel data****/
 
 
 /***Final Step: Let us generate the cross-sectional split variables***/


 /***Input data for the cross-sectional splits**/
 
 use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch.dta", clear
rename rssdid rssd
rename stcntybr fips
rename depsumbr deposits_branch
keep year rssd namebr fips deposits_branch
drop if year>2000
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer.dta", replace

use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer.dta", clear
keep if year == 1994
replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer93.dta", replace

replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer92.dta", replace

replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer91.dta", replace

replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer90.dta", replace

use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer90.dta", clear
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer91.dta"
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer92.dta"
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer93.dta"
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer.dta"
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta", replace
 
 
 *Step 1: Regional Concentration & Local Competition

use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", clear

keep if month == 12
keep rssd year commercial

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\commercial_banks.dta", replace
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\commercial_banks.dta"
 
 keep if _m == 3
 
 egen sum_deposits = sum(deposits_branch) , by(rssd year)

gen buffer_weight = deposits_branch*commercial/sum_deposits

replace buffer_weight = 0 if buffer_weight==.

egen sum_commercial = sum(buffer_weight), by(fips year) 
 
gen buffer = (buffer_weight/sum_commercial)^2
egen HHI_County_Commercial = sum(buffer), by(fips year)
   
  keep fips year HHI 
  
  duplicates drop
  
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\county_level_information_branch.dta", replace
 
 
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", clear
  
 keep rssd year commercial
  
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_to_branch_data.dta", replace
 
 
use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta" , clear

merge n:1 fips year using  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\county_level_information_branch.dta"

drop if _m == 2
 
 cap drop _m

egen sum_deposits = sum(deposits_branch), by(rssd year)

gen buffer_weight = deposits_branch*HHI_County_Commercial/sum_deposits
egen b_HHI_County_Commercial=sum(buffer_weight),by(rssd year)

gen buffer = (deposits_branch/sum_deposits)^2
egen HHI_Bank_Region = sum(buffer), by(rssd year)

keep rssd year b_HHI_County_Commercial HHI_Bank_Region 

duplicates drop

replace year = year+1

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\bank_cross_section.dta", replace


 *Step 2: New Bank Entries
 
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", clear
 
 *drop if sbl_ind==1
 
 keep rssd year commercial_to_loans
 
 
 rename rssd rssdid
 
  
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\input_for_comm_branch.dta",replace
 
  
 use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch.dta" , clear
 drop if year >2000
  forvalues x=90(1)93{
 append using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_`x'.dta" , 
  }
 drop if asset == 0
 drop if depsumbr == 0
 
 merge n:1 rssdid year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\input_for_comm_branch.dta"
 
 drop if _m == 2
 
 rename stcntybr fips 
  
 gen acq_year = year(SIMS_ACQUIRED_DATE)
 gen est_year = year(SIMS_ESTABLISHED_DATE)
 cap drop age
 gen age = year-est_year
 drop if age <0
 replace age = year-acq_year if acq_year>est_year & acq_year<. 
 drop if age <0
 
 drop if commercial_to_loans<0.01
 
 egen count_branches = count(year) ,by(rssdid fips year)
 keep count_branches rssdid year fips
 
 duplicates drop 
 egen id = group(rssd fips)
  
xtset id year

gen new2 = (count_branches~=. & l.count_branches==. & year >1990)

 egen num_banks_fips=count(count_branches), by(fips year)
 egen num_new = sum(new2), by(fips year)
 
 keep num_banks_fips fips year num_new 
 
 duplicates drop 
 egen id = group(fips)
 
 xtset id year
 gen bank_entry_fips_alt = num_new
 gen bank_growth_fips = num_new/num_banks_fips
 
 drop id
 rename num_banks_fips num_banks_fips_alt  
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\net_entrants_fips91_99.dta", replace

 
 
 
  
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 
cap drop _m
merge n:1 fips year using   "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\net_entrants_fips91_99.dta"
drop if _m == 2


 egen sum_deposits = sum(deposits_branch) , by(rssd year)
 
cap drop buffer_weight
gen buffer_weight = deposits_branch*bank_growth_fips/sum_deposits
egen b_bank_growth_fips=sum(buffer_weight),by(rssd year)


keep rssd year b_*

duplicates drop

replace year = year+1
 
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\entrants_bank_new.dta" , replace
 
 
 
 
 
 /********Data for Table A.1**********/
 
 
 

use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final.dta", clear

format date %td

/**make this panel data**/
gen yq = qofd(date)
format yq %tq

drop if assets <=0
drop if assets_lag4 <= 0
drop if loans_net_lag4<0
drop if totalcapital < 0



merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_share_deposits.dta"

drop if _m == 2

cap drop state
cap drop _m
rename state_code state

merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta"

drop if _ == 2

cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta"


cap drop _merge
merge n:1 year irsdist using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta"



xtset rssd yq,quarterly

/**data screening**/

drop if country == "PUERTO RICO"
drop if fed_charter == 0 & state_charter == 0
drop if state == ""


count if year > 1991 & year<2001


replace etr = . if pi<0
replace etr2 = . if ebtx<0

replace etr=0 if etr<0
replace etr=1 if etr>1 & etr<.

replace etr2=0 if etr2<0
replace etr2=1 if etr2>1 & etr2<.

gen llp2_q = llp if quarter == 1
replace llp2_q = llp - l.llp if quarter > 1

cap drop loans_scale 
gen loans_scale = l.loans_net + l.llr

cap drop llp_to_loans
gen llp_to_loans = llp2_q/loans_scale

cap drop nonperform_to_loans
gen nonperform_to_loans = nonperform/loans_scale

gen etr_lead4=f4.etr2
gen etr_lead8=f8.etr2


gen llp_loans_y = llp / (l4.loans_net +l4.llr)
gen npl_loans_y = nonperform / (l4.loans_net +l4.llr)
gen npl_loans_y_lag = l4.npl_loans_y
gen cash_to_assets_lag = l4.cash_to_assets
gen d_npl_loans_y = (nonperform-l4.nonperform) / (l4.loans_net +l4.llr)
gen nco_loans_y = nco / (l4.loans_net +l4.llr)
gen ni_assets = ni/l4.assets
drop id_cusip name name2 city   country auditclass irsname fips_temp

drop dep_broker_unin_lag4 dep_insured_all_to_assets dep_insured_der_to_assets ///
dep_uninsured_all_to_assets dep_uninsured_der_to_assets dep_uninsured_der_to_liab ///
dep_broker_to_liab dep_broker_unin dep_broker_unin_to_liab dep_broker_growth_yr ///
dep_broker_unin_growth_yr

gen prov = nonperform/llr

gen liab_to_assets_lag1= l1.liab_to_assets
gen liab_to_assets_lag4= l4.liab_to_assets

gen l4_perc_audited_size=l4.perc_audited_size
 gen l_cons_to_loans=l4.consumer_to_loans

egen irs_id = group(irsdist)

/*Drop if firms banks move across districts*/
egen sd_irs_id = sd(irs_id), by(rssd)

keep if sd_irs_id == 0
count if year > 1991 & year<2001

gen  revenue_growth = (interest_revenue-l4.interest_revenue)/l4.interest_revenue

gen l_commercial_to_loans=l4.commercial_to_loans

egen sbl_ind = mean(sbl_ind), by(rssd year)


drop if year>2001




cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid_hold.dta" 
replace all_large_loans = all_large_loans/1000000
replace large_term_loans = large_term_loans/1000000


cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid_hold.dta" 
replace all_large_loans_par = all_large_loans_par/1000000
replace large_term_loans_par = large_term_loans_par/1000000



replace all_large_loans=0 if all_large_loans==. & month == 12
replace large_term_loans=0 if large_term_loans==. & month == 12

replace all_large_loans_par=0 if all_large_loans_par==. & month == 12
replace large_term_loans_par=0 if large_term_loans_par==. & month == 12


replace all_large_loans_par=all_large_loans_par+all_large_loans
replace large_term_loans_par=large_term_loans_par+large_term_loans

gen commercial_ex_large_all2=commercial-all_large_loans
gen commercial_ex_large_term2 =commercial-large_term_loans

gen commercial_ex_large_all_p2=commercial-all_large_loans_par
gen commercial_ex_large_term_p2 =commercial-large_term_loans_par


replace commercial_ex_large_all2=0 if commercial_ex_large_all2<0
replace commercial_ex_large_term2=0 if commercial_ex_large_term2<0
replace commercial_ex_large_all_p2=0 if commercial_ex_large_all_p2<0
replace commercial_ex_large_term_p2=0 if commercial_ex_large_term_p2<0


xtset rssd yq, quarterly
gen l_commercial_ex100_to_loans=l4.commercial_ex_100/l4.loans_scale
gen l_commercial_ex250_to_loans=l4.commercial_ex_250/l4.loans_scale
gen l_commercial_ex_mic_to_loans=l4.commercial_ex_micro/l4.loans_scale

/****/

 reg  perc_audited size_lag1 liab_to_assets_lag1    ///
 unemp_nsa ch_unemp_nsa_qtr  hpi_nsa   irs_id irs_id
 
 cap drop in_test
gen in_test = e(sample) == 1


count if year > 1991 & year<2001 & in_test == 1

cap drop code
gen code = .

replace code = 209 if assets<=0.25 
replace code = 213 if assets>0.25 & assets<=1  
replace code = 215 if assets>1 & assets<=5  
replace code = 217  if assets>5 & assets<=10  
replace code = 219 if assets>10 & assets<=50 
replace code = 221 if assets>50 & assets<=100 
replace code = 223 if assets>100 & assets<=250  
replace code = 225 if assets>250 & assets<. 


xtset rssd yq, quarterly
forvalues x = 1(1)12{
replace share_deposits = f.share_deposits if year <1994
}

forvalues x = 1(1)20{
replace share_deposits = f.share_deposits if share_deposits==.
}

gen revenue_growth_lag4 = l4.revenue_growth


 gen int_rev_assets= interest_revenue/l4.loans_scale
 gen int_inc_assets= interest_income/l4.loans_scale
 

foreach var of varlist nco_q_to_loans ch_npl  npl_loans_y_lag  ch_loans  ni_q liab_to_assets  commercial_to_loans  d_npl_loans_y ni_assets ///
  nonperform_to_loans prov llp_q_to_loans llr_to_loans ch_npl_yr revenue_growth_lag4 npl_loans_y revenue_growth int_rev_assets int_inc_assets {
winsor `var',gen(`var'_w) p(0.01)
display `var'
}

cap drop llp_loans_y_w
cap drop nco_loans_y_w

foreach var of varlist llp_loans_y nco_loans_y{
winsor `var',gen(`var'_w) p(0.025)
}

 gen pi_at_dist = dist_sum_pi/dist_sum_at 

gen inv_at_dist = dist_sum_capx/dist_sum_at  
gen cash_at_dist = dist_sum_che/dist_sum_at 


gen l1_pi_at_dist = l4.pi_at_dist
gen l1_dist_mean_cash_etr_1_w  = l4.dist_mean_cash_etr_1
gen l1_ch_hpi_sa_qtr   = l4.ch_hpi_sa_qtr  
gen l1_change_unempl = l4.change_unempl
gen l1_unempl_dist  = l4.unempl_dist 
gen l1_hpi_sa_qtr   = l4.hpi_sa  
gen l1_cash_at_dist = l4.cash_at_dist
gen l1_inv_at_dist  = l4.inv_at_dist 
gen l1_hpi_change= l4.hpi_change 
gen l1_hpi_level= l4.hpi_level 

gen int_rev_assets_w_lag4= l4.int_rev_assets_w 
gen int_inc_assets_w_lag4= l4.int_inc_assets_w 

gen l4_ret_219=l4.ret_219
gen l4_perc_audited_219=l4.perc_audited_219
gen l4_perc_audited_209=l4.perc_audited_209
gen l4_perc_audited_213=l4.perc_audited_213
gen l4_perc_audited_215=l4.perc_audited_215
gen l4_perc_audited_217=l4.perc_audited_217
gen l4_perc_audited_221=l4.perc_audited_221
gen l4_perc_audited_223=l4.perc_audited_223
gen l4_perc_audited_225=l4.perc_audited_225
gen l4_perc_audited_bel_5=l4.perc_audited_bel_5

*keep if assets>50
drop if month != 12

xtset rssd year

 
gen ln_comm_gr = ln(commercial/l.commercial)
 
winsor ln_comm_gr,gen(ln_comm_gr_w) p(0.01)


drop if assets<250
drop if year > 1999


count if abs(share_deposits-1) <0.05 & share_deposits<.
count if abs(share_deposits-1) >=0.05 & share_deposits<.
 
gen in_test_deposit=1
replace in_test_deposit=0 if abs(share_deposits-1) <0.05 & share_deposits<.


 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\data_for_comparison.dta",replace

 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 drop namebr deposits_branch
 
 duplicates drop
 
 egen count_counties = count(year), by(rssd year)
 
 keep rssd year count_counties 
 
 duplicates drop
 
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\county_data_for_comparison.dta", replace
 
  
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 
 egen count_branches = count(year), by(rssd year)
 
 keep rssd year count_branches 
 
 duplicates drop
 
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\branch_data_for_comparison.dta", replace
 
 
 
 *************
 

use "C:\Users\martin.jacob\Dropbox\GJ\data\final\Compustat_Sample", clear

cap drop mean_cash_etr_1_w

drop if inv_w==.

keep if at>10 & at <50

foreach var of varlist inv_w cash_assets_w pi_assets_w ni_assets_w sg_w lvg_w gross_margin_at_w  tangibility_w ///
intangibles_w ppe_w  cash_etr_1 { 
egen dist_mean_`var'_1050=mean(`var'), by(irsdist year)
}



egen count=count(year) , by(irsdist year)



foreach var of varlist capx che at dltt sale pi oibdp{ 
egen dist_sum_`var'_1050 = sum(`var'), by(irsdist year)
}

keep irsdist dist_mean_* dist_sum_* year count

duplicates drop

foreach var of varlist dist_mean_inv_w dist_mean_cash_assets_w dist_mean_pi_assets_w dist_mean_sg_w dist_mean_lvg_w dist_mean_gross_margin_at_w ///
 dist_mean_tangibility_w ///
dist_mean_intangibles_w dist_mean_ppe_w  dist_mean_cash_etr_1 { 
keep if `var' ~=.
}


replace year = year+1

save "C:\Users\martin.jacob\Dropbox\GJ\data\final\industry_info_dist_1050.dta", replace


use "C:\Users\martin.jacob\Dropbox\GJ\data\final\Compustat_Sample", clear

cap drop mean_cash_etr_1_w

drop if inv_w==.

keep if at>50

foreach var of varlist inv_w cash_assets_w pi_assets_w ni_assets_w sg_w lvg_w gross_margin_at_w  tangibility_w ///
intangibles_w ppe_w  cash_etr_1 { 
egen dist_mean_`var'_ab50=mean(`var'), by(irsdist year)
}



egen count=count(year) , by(irsdist year)



foreach var of varlist capx che at dltt sale pi oibdp{ 
egen dist_sum_`var'_ab50 = sum(`var'), by(irsdist year)
}

keep irsdist dist_mean_* dist_sum_* year count

duplicates drop

foreach var of varlist dist_mean_inv_w dist_mean_cash_assets_w dist_mean_pi_assets_w dist_mean_sg_w dist_mean_lvg_w dist_mean_gross_margin_at_w ///
 dist_mean_tangibility_w ///
dist_mean_intangibles_w dist_mean_ppe_w  dist_mean_cash_etr_1 { 
keep if `var' ~=.
}


replace year = year+1

save "C:\Users\martin.jacob\Dropbox\GJ\data\final\industry_info_dist_ab50.dta", replace


 

 /***Input for Table 9 - CRA Data ***/


 cd "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\CRA-Data"
 
 
 
import delimited "00exp_trans.dat", clear delimiter(tab)
gen respondentid = substr(v1, 1, 10)
gen rssd = substr(v1, 133, 10)
keep respondentid rssd
destring  rssd, replace
egen dup = count(rs), by(respon)
drop if dup==2
drop dup
save rssd_respondentid.dta, replace


import delimited "96exp_discl.dat", clear delimiter(tab)
gen table = substr(v1, 1, 4)
keep if table=="D1-1"
gen respondentid = substr(v1, 5, 10)
gen regulatorid = substr(v1, 15, 1)
gen year = substr(v1, 16, 4)
gen loantype = substr(v1, 20, 1)
gen actiontype = substr(v1, 21, 1)
gen state = substr(v1, 22, 2)
gen county = substr(v1, 24, 3)
gen msa = substr(v1, 27,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 44,6)
gen amountloans_lower100k = substr(v1, 50,8)
gen nloans_btwn100k250k = substr(v1, 58,6)
gen amountloans_btwn100k250k = substr(v1, 64,8)
gen nloans_greater250k = substr(v1, 72,6)
gen amountloans_greater250k = substr(v1, 78,8)
gen nloans_lower1M = substr(v1, 86,6)
gen amountloans_lower1M = substr(v1, 92,8)
gen nloans_affiliate = substr(v1, 100,6)
gen amountloans_affiliate = substr(v1, 106,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr reportlevel, replace force
drop if reportlevel==.
keep if reportlevel>399 // Here we have a different situation relative to older CRA reports (The code 400 is only reported when there are more than one 500 and 600 for each county.
duplicates tag respondentid regulatorid stcntybr, generate(dp) // Therefore, here I identify duplicate observations
keep if dp ==0 | reportlevel ==400 & msa=="    " //  and I keep either observations that are not duplicates or the code 400 for duplicate observations

drop table v1 reportlevel dp

egen number_counties=count(nloans_btwn100k250k),by(respondentid)

save sbl996, replace


foreach num of numlist 97/98{

import delimited `num'exp_discl.dat, clear delimiter(tab)
gen table = substr(v1, 1, 5)
keep if table=="D1-1 "
gen respondentid = substr(v1, 6, 10)
gen regulatorid = substr(v1, 16, 1)
gen year = substr(v1, 17, 4)
gen loantype = substr(v1, 21, 1)
gen actiontype = substr(v1, 22, 1)
gen state = substr(v1, 23, 2)
gen county = substr(v1, 25, 3)
gen msa = substr(v1, 28,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 45,6)
gen amountloans_lower100k = substr(v1, 51,8)
gen nloans_btwn100k250k = substr(v1, 59,6)
gen amountloans_btwn100k250k = substr(v1, 65,8)
gen nloans_greater250k = substr(v1, 73,6)
gen amountloans_greater250k = substr(v1, 79,8)
gen nloans_lower1M = substr(v1, 87,6)
gen amountloans_lower1M = substr(v1, 93,8)
gen nloans_affiliate = substr(v1, 101,6)
gen amountloans_affiliate = substr(v1, 107,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr reportlevel, replace force
drop if reportlevel==.
keep if reportlevel>39 // Here we have a different situation relative to older CRA reports (The code 400 is only reported when there are more than one 500 and 600 for each county.
duplicates tag respondentid regulatorid stcntybr, generate(dp) // Therefore, here I identify duplicate observations
keep if dp ==0 | reportlevel ==40 & msa=="    " //  and I keep either observations that are not duplicates or the code 400 for duplicate observations

drop table v1 reportlevel dp


egen number_counties=count(nloans_btwn100k250k),by(respondentid)

save sbl`num', replace
}


//// 1.3 **** Here I am cleaning the data from 1999 to 2003 (CRA started reporting the report level differently after 1998 and then CRA changed the codebook between 2003 and 2004)


import delimited 99exp_discl.dat, clear delimiter(tab)
gen table = substr(v1, 1, 5)
keep if table=="D1-1 "
gen respondentid = substr(v1, 6, 10)
gen regulatorid = substr(v1, 16, 1)
gen year = substr(v1, 17, 4)
gen loantype = substr(v1, 21, 1)
gen actiontype = substr(v1, 22, 1)
gen state = substr(v1, 23, 2)
gen county = substr(v1, 25, 3)
gen msa = substr(v1, 28,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 45,6)
gen amountloans_lower100k = substr(v1, 51,8)
gen nloans_btwn100k250k = substr(v1, 59,6)
gen amountloans_btwn100k250k = substr(v1, 65,8)
gen nloans_greater250k = substr(v1, 73,6)
gen amountloans_greater250k = substr(v1, 79,8)
gen nloans_lower1M = substr(v1, 87,6)
gen amountloans_lower1M = substr(v1, 93,8)
gen nloans_affiliate = substr(v1, 101,6)
gen amountloans_affiliate = substr(v1, 107,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr, replace force
keep if reportlevel =="040"

drop table v1 reportlevel

egen number_counties=count(nloans_btwn100k250k),by(respondentid)


save sbl999.dta, replace


foreach num of numlist 0/3{

import delimited 0`num'exp_discl.dat, clear delimiter(tab)
gen table = substr(v1, 1, 5)
keep if table=="D1-1 "
gen respondentid = substr(v1, 6, 10)
gen regulatorid = substr(v1, 16, 1)
gen year = substr(v1, 17, 4)
gen loantype = substr(v1, 21, 1)
gen actiontype = substr(v1, 22, 1)
gen state = substr(v1, 23, 2)
gen county = substr(v1, 25, 3)
gen msa = substr(v1, 28,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 45,6)
gen amountloans_lower100k = substr(v1, 51,8)
gen nloans_btwn100k250k = substr(v1, 59,6)
gen amountloans_btwn100k250k = substr(v1, 65,8)
gen nloans_greater250k = substr(v1, 73,6)
gen amountloans_greater250k = substr(v1, 79,8)
gen nloans_lower1M = substr(v1, 87,6)
gen amountloans_lower1M = substr(v1, 93,8)
gen nloans_affiliate = substr(v1, 101,6)
gen amountloans_affiliate = substr(v1, 107,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr, replace force
keep if reportlevel =="040"

drop table v1 reportlevel

egen number_counties=count(nloans_btwn100k250k),by(respondentid)

save sbl200`num', replace
}

use sbl996, clear
append using sbl97
append using sbl98
append using sbl999
append using sbl2000
append using sbl2001
append using sbl2002
append using sbl2003

merge n:1 respondentid using rssd_respondentid

keep if _m == 3

save cra_panel_raw.dta, replace




/***Let's generate the numbers within the district**/

use  cra_panel_raw.dta, clear

cap drop number_counties

/***Zoom in only on counties within the HQ district***/
gen fips = state+county
destring fips, replace
cap drop _m 
merge n:1 respondentid using rssd_respondentid

keep if _m == 3
drop _m

merge n:1 rssd using rssd_matched

keep if _m == 3

drop _m
replace irsdist="Pacific Northwest" if irsdist=="Pacific-Northwest"

merge n:1 fips using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\macroeconomic\fips_dist.dta" 

keep if _m == 3


keep if irsdist==irsdist_hq

egen total_loans=rowtotal(amountloans_btwn100k250k amountloans_greater250k)

egen total_loans_100=rowtotal(amountloans_lower100k)

egen total_loans_bank=sum(total_loans),by(rssd  year)
gen buf= total_loans/total_loans_bank
gen buf2 = buf*buf
egen disp_bank = sum(buf2),by(rssd  year)

egen total_loans_bank_100=sum(amountloans_lower100k),by(rssd  year)
cap drop buf buf2
gen buf= total_loans_100/total_loans_bank_100
gen buf2 = buf*buf
egen disp_bank_100 = sum(buf2),by(rssd  year)

keep  year  rssd total_loans_bank disp_bank_100  disp_bank total_loans_bank_100
duplicates drop 
destring year, replace
save cra_information_part_1.dta, replace

/***Let's generate the share of lending / number of counties where bank does not have a branch**/
use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta" , clear
keep if year>1995
drop namebr 
drop deposits_branch
duplicates drop
save raw_branch_for_merge.dta,replace

use  cra_panel_raw.dta, clear

cap drop number_counties

/***Zoom in only on counties within the HQ district***/
gen fips = state+county
destring fips, replace
cap drop _m 
merge n:1 respondentid using rssd_respondentid

keep if _m == 3
drop _m

merge n:1 rssd using rssd_matched

keep if _m == 3

drop _m
replace irsdist="Pacific Northwest" if irsdist=="Pacific-Northwest"

merge n:1 fips using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\macroeconomic\fips_dist.dta" 

keep if _m == 3


drop _m

destring year, replace
merge n:1 rssd year fips using raw_branch_for_merge

drop if _m == 2

keep if irsdist==irsdist_hq

egen total_loans=rowtotal(amountloans_btwn100k250k amountloans_greater250k)

egen total_loans_outside=sum(total_loans) if _m==1, by(rssd year)

cap drop buf 
egen buf = max(total_loans_outside),by(rssd year)
replace total_loans_outside=buf if total_loans_outside==.
replace total_loans_outside=0 if total_loans_outside==.


keep  year  rssd total_loans_outside 
duplicates drop

save cra_information_part_2.dta, replace 


use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta" , clear
keep if year>1995
drop namebr 
drop deposits_branch
duplicates drop
save raw_branch_for_merge.dta,replace

use  cra_panel_raw.dta, clear

cap drop number_counties

/***Zoom in only on counties within the HQ district***/
gen fips = state+county
destring fips, replace
cap drop _m 
merge n:1 respondentid using rssd_respondentid

keep if _m == 3
drop _m

merge n:1 rssd using rssd_matched

keep if _m == 3

drop _m
replace irsdist="Pacific Northwest" if irsdist=="Pacific-Northwest"

merge n:1 fips using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\macroeconomic\fips_dist.dta" 

keep if _m == 3


drop _m

destring year, replace
merge n:1 rssd year fips using raw_branch_for_merge

drop if _m == 2

keep if irsdist==irsdist_hq
egen total_loans=rowtotal(amountloans_lower100k)

egen group = group(rssd year fips)
egen dup = count(fips), by(group)
drop if dup == 2
egen group2 = group(rssd  fips)

xtset group2 year


egen total_loans_bank=sum(total_loans), by(rssd year)
egen total_loans_outside=sum(total_loans) if _m==1, by(rssd year)

drop if total_loans_bank==.
cap drop buf 
egen buf = max(total_loans_bank),by(rssd year)
replace total_loans_bank=buf if total_loans_bank==.

cap drop buf 
egen buf = max(total_loans_outside),by(rssd year)
replace total_loans_outside=buf if total_loans_outside==.

gen share_not_in_branch=total_loans_outside/total_loans_bank
 
keep  year  rssd  share_not_in_branch  
duplicates drop
rename share_not_in_branch share_not_in_branch_100


save cra_information_part_3.dta, replace 




use "C:\Users\martin.jacob\Desktop\fb9b4da6455c8e2b.dta" , clear

keep if loc == "USA"
keep if fic == "USA"
keep if curcd == "USD"

drop indfmt consol popsrc datafmt tic cusip conm acctstd acqmeth compst ///
 final ltcm ogm  costat add1 add2 add3 busdesc city conml county ///
dlrsn ein fax ggroup gind gsector gsubind phone prican prirow priusa ///
spcindcd spcseccd spcsrc ipodate dldte weburl loc fic curcd currtr curuscn curncd ///
acctchg adrr ajex ajp bspr fyr ismod pddur scf src stalt udpl upd apdedate  acchg acco accrt ///
acdo acodo acominc acox acqao acqcshi acqgdwl acqic acqintan acqinvt acqlntal acqniintc acqppe acqsc adpac ///
aedi afudcc afudci aldo am amc amdc amgw ano aocidergl aociother aocipen aocisecgl aodo aol2  aox ///
 apb apc apofs aqa aqc aqd aqeps aqi aqp aqpl1 aqs arb arc arce arced arceeps artfs aul3 autxr balr ///
 banlr bast bastr batr bcef bclr bcltbl bcnlr bcrbl bct bctbl bctr billexce bkvlps bltbl ca capr1 capr2 ///
 capr3 caps capsft capxv cb cbi cdpac ceiexbill ceql ceqt cfbd cfere cfo cfpdo cga cgri cgui cgti chech ///
 cibegni cicurr cidergl cimii ciother cipen cisecgl citotal cld2 cld3 cld4 cld5 clfc clfx clg clis cll ///
 cllc clo clrll clt cmp cnltbl cpcbl cpdoi cpnli cppbl cprei crvnli cshfd cshi cshpri cshr cshrc cshrp ///
 cshrso cshrt cshrw cstk cstkcv cstke dbi dc dclo dcom dcpstk dcs dcvsr dcvsub dcvt dd  dd2 dd3 dd4 ///
 dd5 derac deralt derhedgl derlc derllt dfpac dfs dfxa diladj dilavx dlcch dltis dlto dltp dltr dltsub ///
 dm dn do donr dpacb dpacc dpacli dpacls dpacme dpacnr dpaco dpacre dpact  dpdc dpltb dpret depc ///
  dpsc dpstb dptb dptc dptic dpvieb dpvio dpvir drc drci drlt ds dt dtea dted dteeps dtep dudd dvc ///
 dvdnp dvintf dvp dvpa dvpdp dvpibb dvrpiv dvsco dvrre dvt dxd2 dxd3 dxd4 dxd5 ea ///
  txva txw uaoloch uaox uapt ucaps uccons  ucustad udcopres udd udfcc udmb udolt  ///
 udpco udpfa udvp ufretsd ugi ui uinvt ulcm ulco uniami unl unnp unnpl unopinc unwcc  ///
 uois uopi uopres updvp upmcstk upmpf upmpfs upmsubp upstk upstkc upstksf urect urectr  ///
 urevub uspi ustdnc usubdvp usubpstk utfdoc utfosc utme utxfed uwkcapc uxinst uxintd  ///
 vpac vpo wcap wcapc wcapch wda wdd wdeps wdp ///
  fatp fca fdfr fea fel ffo ffs fiao finaco finao fincf finch findlc findlt finivst  ///
 finlco finlto finnp finrecc finreclt finrev finxint finxopr fopo fopox fopt fsrco  ///
 fsrct fuseo fuset gbbl gdwl gdwlam gdwlia gdwlid gdwlieps gdwlip geqrv gla glcea  ///
 glced glceeps glcep gld gleps gliv glp govgr govtown gp gphbl gplbl gpobl gprbl  ///
 gptbl gwo hedgegl iaeq iaeqci iaeqmi iafici iafxi iafxmi iali ///
  ialoi ialti iamli iaoi iapli transa tsa tsafc tso tstk tstkc tstkme  ///
 tstkn tstkp txtubadjust txtubbegin txtubend txtubmax txtubmin txtubposdec  ///
 txtubposinc txtubpospdec txtubpospinc txtubsettle txtubsoflimit txtubtxtr  ///
 txtubxintbs txtubxintis  iarei iasci iasmi iassi iasti iatci iati iatmi  ///
 iaui  ibadj ibbl ibc ibcom ibki ibmii icapt idiis idilb idilc idis idist  ///
 idit idits iire initb intano intc intpn  invfg invo invofs  ///
 invreh invrei invres invrm  invwip iobd ioi iore ip ipabl ipc iphbl  ///
 iplbl ipobl iptbl ipti ipv irei irent irii irli irnli irsi iseq iseqc  ///
 iseqm isfi isfxc isfxm isgr isgt isgu islg islgc islgm islt isng isngc  ///
 isngm isotc isoth isotm issc issm issu ist istc istm isut itcb itcc itci  ///
 ivaco  ivao ivch ivgod ivi ivncf ivpt ivst ivstch lcabg lcacl lcacr  ///
 lcag lcal lcalt lcam lcao lcast lcat lco lcox lcoxar lcoxdr  lcuacu li  ///
 lif lifr lifrp lloml lloo llot llrci llrcr llwoci llwocr lno lo lol2 loxdr lqpl1  ///
 lrv ls lse lst lt lul3 mib mibn mibt mii mrc1 mrc2 mrc3 mrc4 mrc5 mrct mrcta msa  ///
 msvrv mtl nat nco nfsr niadj nieci niint niintpfc niintpfp niit nim nio nipfc  ///
 nipfp nit nits nopi nopio np npanl npaore nparl npat nrtxt nrtxtd nrtxteps ob  ///
  tf tfva tfvce tfvl tie tii  txdba txdbca txdbcl  txdfed txdfo  txditc txds txeqii  ///
  opeps opili opincar opini opioi opiri opiti oprepsx optca optdr optex optexd optfvgr  ///
 optgr optlife optosby optosey optprcby optprcca optprcex optprcey optprcgr optprcwa  ///
 optrfr optvol palr panlr patr pcl pclr pcnlr pctr pdvc  pll pltbl pnca pncad pncaeps  ///
 pncia pncid pncieps pncip pncwia pncwid pncwieps pncwip pnlbl pnli pnrsho pobl ppcbl  ///
   ppenb ppenc ppenli ppenls ppenme ppennr ppeno  ppevbb ppeveb ppevo ppevr pppabl  ///
 ppphbl pppobl ppptbl prc prca prcad prcaeps prebl pri prodv prsho prstkc prstkcc prstkpc ///
  prvt pstk pstkc pstkl pstkn pstkr pstkrv ptbl ptran pvcl pvo pvon pvpl pvt pwoi radp  ///
 ragr rari rati rca rcd rceps rcl rcp rdip rdipa rdipd rdipeps rdp re rea reajo   ///
 recco recd recta rectr recub ret reuna reunr revt ris rll rlo rlp rlri rlt rmum  ///
 rpag rra rrd rreps rrp rstche rstchelt rvbci rvbpi rvbti rvdo rvdt rveqt rvlrv rvno  ///
 rvnt rvri rvsi rvti rvtxr rvupi rvutx saa sal salepfc salepfp sbdc sc sco scstkc  ///
 secu  seqo seta setd seteps setp siv spce spced spceeps spid spieps spioa spiop  ///
 sppe sppiv spstkc sret srt ssnp sstk stbo stio stkco stkcpa tdc tdscd tdsce tdsg tdslg  ///
 tdsmm tdsng tdso tdss tdst ebit ebitda eiea emol epsfi epsfx epspi epspx esopct esopdlt ///
 esopnr esopr esopt esub esubc excadj fatb fatc fatd exre fate fatl fatn fato xago xagt ///
 xcom xcomi xdepl xdp xeqo  xido  xindb xindc xins xinst  xintd xintopt xivi ///
 xivre xnbi xnf xnins xnitb xobd xoi xopr xoprar xoptd xopteps xore xpp xpr xrdp xrent ///
 xs xt xuw xuwli xuwnli xuwoi xuwrei xuwti exchg prch_c prcl_c adjex_c cshtr_f dvpsp_f ///
 dvpsx_f  prch_f prcl_f adjex_f rank au auop auopic ceoso cfoso add4 ialoi
 
 
 gen year = year(datadate)
 gen month = month(datadate)

 
 destring cik , replace force
 
drop if sale == .
drop if at == . 

drop if at<0
drop if ceq<0
drop if che<0
drop if sale<0

 egen id = group(gvkey)

 cap drop year
 
rename fyear year

xtset id year

 gen tca = -(recch+invch+apalch+txach+aoloch+dpc)/at
 gen cfo = (oancf + xidoc)/at
 gen chg_sales = (sale-l.sale)/at
 gen pped = (ppegt)/at
 
 gen ta = (ib-oancf)/l.at
 gen ppe = (ppegt)/l.at
 gen atinv = 1/at
 gen drevminddrect =( (sale-l.sale) - (rect-l.rect))/l.at
 
 
 gen ln_ta = log(at)
 gen leverage = dltt/l.at
 gen roa=ib/at
 gen ln_mve=ln(prcc_f*csho)
 gen mtb=(abs(prcc_f*csho)+dltt+dlc)/at
 
 cap drop buffer*
 forvalues x=1(1)8{
 gen buffer`x'=l`x'.oancf
 }
 
 egen buf_sd = rowsd(oancf buffer1-buffer8)
 gen sd_cf = buf_sd/at
 
  
 cap drop buffer*
 forvalues x=1(1)8{
 gen buffer`x'=l`x'.sale
 }
 cap drop buf_sd
 egen buf_sd = rowsd(sale buffer1-buffer8)
 drop buffer*
 gen sd_sale = buf_sd/at
 
 gen operating_cycle = ln( 360 / sale / (rect+rect-1)/2 + 360/cogs/(invt+l.invt)/2     )
 
 gen capital_intensity = ppent/l.at
 gen intangibles = (xrd+xad)/sale
 
 replace intangibles = 0 if intangibles == .
 
 gen presence_intan = (intangibles~=0)
 
 gen loss = (ni<0)
 
 drop if year<1989
 keep if year<2002
 foreach var of varlist  tca cfo chg_sales pped ta ppe atinv drevminddrect ///
 ln_ta leverage roa mtb sd_cf sd_sale operating_cycle capital_intensity intangibles {
 winsor `var' , gen(`var'_w) p(0.01)
 }
 
  
 
 destring sic, replace
 
 drop if sic >=4000 & sic<=4999
 drop if sic >=6000 & sic<=6999
 
 ffind sic, newvar(ff48) type(48)
 
 cap  rename fyear year 
xtset id year
 
 reg tca_w l.cfo_w cfo_w f.cfo_w chg_sales_w pped_w
 
 egen count_obs =count(year) if e(sample) == 1, by(ff48 year)
 
 egen reg_id = group(ff48 year) if count_obs>19 & count_obs<.
 
 
 gen b_residual_tca=.
 
 forvalues x = 1(1)602 {
 
 qui cap reg tca_w l.cfo_w cfo_w f.cfo_w chg_sales_w pped_w if reg_id==`x'
  cap drop resi
 qui cap predict resi , residuals
 qui cap replace b_residual_tca=resi if reg_id==`x'
 
 }
 
 
 gen accural_quality = -100 * (abs(b_residual_tca)+abs(l.b_residual_tca))/2
 
 gen b_residual_ta=.

 
 reg ta_w atinv_w drevminddrect_w ppe_w
 
  cap drop count_obs
 egen count_obs =count(year) if e(sample) == 1, by(ff48 year)
 cap drop reg_id
 egen reg_id = group(ff48 year) if count_obs>19 & count_obs<.
 
 
 forvalues x = 1(1)828{
 
 qui cap reg ta_w atinv_w drevminddrect_w ppe_w if reg_id==`x'
  cap drop resi
 qui cap predict resi , residuals
 qui cap replace b_residual_ta=resi if reg_id==`x'
 
 }
 
 
 gen disc_accruals = abs(b_residual_ta)
 
 winsor accural_quality, gen(accural_quality_w) p(0.01)
 winsor disc_accruals, gen(disc_accruals_w) p(0.01)
 
 
gen accruals = (d.act-d.lct-d.ch+d.dd1-dp)/l.at
winsor accruals, gen(accruals_w) p(0.01)

 
 egen buffer =count(cik), by(cik year)

 keep if buffer == 1 | (buffer == 2 & month == 12)
 
 drop buffer
 
 rename year fyear
merge 1:1 cik fyear using "C:\Users\martin.jacob\Dropbox\GJ\data\final\hq_10k.dta"
 
 drop if _m == 2
 

xtset id fyear
 
 forvalues x = 1(1)50{
replace ba_zip5 = ba_zip5[_n+1] if ba_zip5=="" & id == f.id
}

 replace ba_zip5 = substr(addzip,1,5) if ba_zip5==""
 
rename ba_zip5 zip 


/******
pecking order
1) use the actual year
2) if (1) not available, use the most recent 10k based HQ location
3) if (2) is not there, then we use use current address
******/
 
 
 cap drop _m
merge n:1 zip using "C:\Users\martin.jacob\Dropbox\GJ\data\irs audit (TRAC)\zip_fips_dist.dta"

keep if _m == 3

 rename  fyear year

cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\audit_rates_per_class.dta"



cap drop code
gen code = .

replace code = 209 if at<=0.25 
replace code = 213 if at>0.25 & at<=1  
replace code = 215 if at>1 & at<=5  
replace code = 217  if at>5 & at<=10  
replace code = 219 if at>10 & at<=50 
replace code = 221 if at>50 & at<=100 
replace code = 223 if at>100 & at<=250  
replace code = 225 if at>250 & at<. 

cap drop _m
merge n:1 irsdist code year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\irs_audit_prob_size.dta"

drop if _m == 2


gen buffer_rate=perc_audited_size

cap drop _m
merge n:1 code year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\corp_audits_post_2000.dta"

drop if _m == 2


egen irs_id = group(irsdist)

replace perc_audited_size  = perc_audit_size /100 if year>2000

egen ind_year = group(ff48 year)

save "C:\Users\martin.jacob\Dropbox\GJ\data\final\information_environment.dta", replace





 
 clear all
 import excel "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\Data for John 1.13.2020\fly_nb_lrc3.xlsx", sheet("Data Unique FYEAR Change") firstrow
 
 rename fyear_change year
 rename len gvkey 
 rename ta high_avoidance
 
 save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\tax_avoidance_status.dta", replace
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\ggm_nb.dta",clear

rename lender_g gvkey

keep gvkey 

duplicates drop

merge 1:n gvkey using  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\linking.dta"

keep if _m == 3

keep if rssd ~=""



keep rssd gvkey

merge n:n gvkey using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\tax_avoidance_status.dta"

keep if _m == 3

keep rssd year high_avoidance
destring rssd, replace

duplicates drop
gen bank_holding = 1

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\matched_rssds.dta", replace

rename rssd fin_hh_rssd
rename b bank_hold_par
rename high_avoidance high_avoidance_par
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\matched_rssds_parent.dta", replace





/**generate unemployment and house price stuff at the district level**/

 use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\macroeconomic\lf_all3.dta" , clear
 
 merge 1:1 fips year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\macroeconomic\HPI_fips.dta"
 
 cap drop _merge
 
 destring fips, replace
 
 merge n:1 fips using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\macroeconomic\fips_dist.dta"
 
 egen total = sum(Labor_Force) , by(irsdist year)
 egen unempl = sum(Unemployed), by(irsdist year)
 
 gen share_fips = annualchange*Labor_Force
 egen total_for_fips= sum(Labor_Force) if annualchange~=. ,by(irsdist year)
 egen nom_for_fips= sum(share_fips) if annualchange~=. ,by(irsdist year)
 
 gen hpi_change=nom_for_fips/total_for_fips
 
 cap drop share_fips total_for_fips nom_for_fips
 gen share_fips = hpiwith1990base*Labor_Force
 egen total_for_fips= sum(Labor_Force) if annualchange~=. ,by(irsdist year)
 egen nom_for_fips= sum(share_fips) if annualchange~=. ,by(irsdist year)
 
 gen hpi_level=nom_for_fips/total_for_fips
   
 gen unempl_dist = unempl/total
 
 keep irsdist year unempl_dist hpi_change hpi_level
 
 drop if hpi_change==.
 
 duplicates drop 
 egen id = group(irsdist)
 
 xtset id year
 
 gen change_unempl = d.unempl_dist
 
 drop if year == .
 
 drop if id == .
 
 replace  irsdist = "Pacific-Northwest" if  irsdist == "Pacific Northwest"
  
 
  save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta" , replace
 

 
 
/**generate firm-level information using compustat
Step 1: merge HQ data
Step 2: generate district level data
**/

  use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\hq\10-K_Headers.dta" , clear

keep cik ba_zip5 fyear

drop if cik==.

xtset cik fyear


forvalues x = 1(1)20{
replace ba_zip5 = ba_zip5[_n+1] if ba_zip5=="" & cik == f.cik
}

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\hq_10k.dta", replace


/**Second step: Create State/Country Level Averages**/

 use "C:\Users\martin.jacob\Desktop\fb9b4da6455c8e2b.dta" , clear
 
keep if loc == "USA"
keep if fic == "USA"
keep if curcd == "USD"
 
 gen year = year(datadate)
 gen month = month(datadate)

 
 destring cik , replace force
 
drop if sale == .
drop if at == . 

drop if at<0
drop if ceq<0
drop if che<0
drop if sale<0

drop if cik == .

drop if sic == "6020"
drop if sic == "6022"

 egen buffer =count(cik), by(cik fyear)

 keep if buffer == 1 | (buffer == 2 & month == 12)
 
 drop buffer
 
 
merge 1:1 cik fyear using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\hq_10k.dta"
 
 drop if _m == 2
 

egen id = group(gvkey)

xtset id fyear
 
 forvalues x = 1(1)50{
replace ba_zip5 = ba_zip5[_n+1] if ba_zip5=="" & id == f.id
}

 replace ba_zip5 = substr(addzip,1,5) if ba_zip5==""
 
rename ba_zip5 zip 


/******
pecking order
1) use the actual year
2) if (1) not available, use the most recent 10k based HQ location
3) if (2) is not there, then we use use current address
******/
 
 
 cap drop _m
merge n:1 zip using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\irs audit (TRAC)\zip_fips_dist.dta"

keep if _m == 3


cap drop year
rename fyear year

xtset id year

gen inv=capx/ppegt
gen cash_assets=che/at
gen income_assets=(oibdp)/l.at
gen pi_assets=(pi)/l.at
gen ni_assets=(ni)/l.at
gen sg=ln(sale/ll.sale)
gen lvg=(dltt + dlc)/at
gen size=ln(at)
gen q_=(csho*prcc_c)/at
gen gross_margin_at=(sale-cogs)/sale
gen profit_margin_at=(pi)/sale
gen ltdebt_book_equity= (dltt)/ceq
gen intangibles = intan/ at
gen ppe = ppegt/ at
gen tangibility = (ppegt+intan)/at


gen cash_etr_1 = txpd / pi
replace cash_etr_1 = 0 if cash_etr_1<0
replace cash_etr_1 = 1 if cash_etr_1>1 & cash_etr_1<.
replace cash_etr_1 = . if pi<0

keep if year >1989

keep if year < 2006

foreach var of varlist inv cash_assets income_assets sg lvg gross_margin_at profit_margin_at tangibility ///
intangibles ppe ltdebt_book_equity pi_assets ni_assets  { 
winsor `var', p(.01) gen(`var'_w)
}

cap drop _m
merge n:1 zip  using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\zip_state.dta"

drop if _m == 2

egen irs_id = group(irsdist)

gen sic2 = substr(sic,1,2)

egen ind_state_year = group(sic2 state year)

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\Compustat_Sample", replace



use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\Compustat_Sample", clear

cap drop mean_cash_etr_1_w

xtset id year

gen cf_assets = oancf/l.at

winsor cf_assets , gen(cf_assets_w) p(0.01)

gen loss = (ni<0) if ni<.

egen sum_firms = count(ni) if ni ~=. ,by(irsdist year)
egen sum_losses = sum(loss) if ni ~=. ,by(irsdist year)
gen share_losses = sum_losses/sum_firms


drop if inv_w==.
foreach var of varlist inv_w cash_assets_w pi_assets_w ni_assets_w sg_w lvg_w gross_margin_at_w profit_margin_at_w tangibility_w ///
intangibles_w ppe_w ltdebt_book_equity_w cash_etr_1 cf_assets_w { 
egen dist_mean_`var'=mean(`var'), by(irsdist year)
}

egen count=count(year) , by(irsdist year)

foreach var of varlist capx che at dltt sale pi oibdp{ 
egen dist_sum_`var' = sum(`var'), by(irsdist year)
}

keep irsdist dist_mean_* dist_sum_* year count sum_firms sum_losses share_losses

duplicates drop

foreach var of varlist dist_mean_inv_w dist_mean_cash_assets_w dist_mean_pi_assets_w dist_mean_sg_w dist_mean_lvg_w dist_mean_gross_margin_at_w ///
dist_mean_profit_margin_at_w dist_mean_tangibility_w dist_mean_cf_assets_w ///
dist_mean_intangibles_w dist_mean_ppe_w dist_mean_ltdebt_book_equity_w dist_mean_cash_etr_1 share_losses{ 
keep if `var' ~=.
}
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta", replace

replace year = year + 1 
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist_lag.dta", replace


/***input of shares in each district***/



use "C:\Users\martin.jacob\Dropbox\GJ\data\final\district_share.dta", clear

merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\irs_audit_prob.dta"

keep if _m == 3


drop _m 

sort rssd year

cap drop dep_share

gen share_deposits = depdist / depdom

egen max_share = max(share_deposits),by(rssd year)

gen main_location = ( share_deposits== max_share)

egen buff_sum_prob=sum(share_dep), by(rssd year main_location)
gen buf_weighted_perc=(perc_audited*share_dep) / buff_sum_prob

egen weighted_perd = sum(buf_weighted_perc), by(rssd year main_location)

gen buf_perc_audited_main = weighted_perd if main_location == 1
gen buf_perc_audited_other = weighted_perd if main_location == 0

egen perc_audited_main  = mean(buf_perc_audited_main), by(rssd year)
egen perc_audited_other  = mean(buf_perc_audited_other), by(rssd year)

replace perc_audited_other = perc_audited_main if perc_audited_other==.

keep if main_location == 1

keep rssd year perc_audited_main perc_audited_other  share_deposits

duplicates tag rssd year, gen(buffer)
drop if buffer == 1

drop buffer

xtset rssd year

rssdid rssd

save  "C:\Users\martin.jacob\Dropbox\GJ\data\final\input_share_deposits.dta", replace



/******generate audit percentage data******/

clear all

import delimited "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\irs audit (TRAC)\IRS District Audits, FY 1992 - 2000.csv"

rename fy year
rename irsname irsdist

gen perc_audited_other=.

drop if code == 200

 /**this creates the audit percentages by size class**/
egen aud_bel5=sum(aud) if code>200 & code<216, by(irsdist year)
egen buf_ret_bel5=sum(ret) if code>200 & code<216, by(irsdist year)
 
gen buf_perc_audited_bel_5 = aud_bel5/buf_ret_bel5

egen perc_audited_bel_5 = mean(buf_perc_audited_bel_5), by(irsdist year)
egen ret_bel5 = mean(buf_ret_bel5), by(irsdist year)
 
 
forvalues var = 209(2)225{

gen buf_perc_audited_`var' = aud/ret if code == `var'

egen perc_audited_`var' = mean(buf_perc_audited_`var'), by(irsdist year)

 egen buf_ret_`var' = sum(ret) if  code == `var', by(irsdist year)
 egen ret_`var'=mean(buf_ret_`var') , by(irsdist year)

}
 
 keep year irsdist code  perc_audited_* ret_*

 cap drop perc_audited_other 
 cap drop perc_audited_211 
 cap drop ret_211
 cap drop code
 duplicates drop
 
  
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta", replace



/****merging Dealscan information to our dataset - data preparation***/
use  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed.dta" , clear

egen total_loans = sum(loan_total_mixed),by(lenderid year)
gen buffer = loan_total_mixed if ltype=="term"
egen term_loans = sum(buffer),by(lenderid year)

keep lenderid  year total_loans term_loans
duplicates drop

xtset lenderid year

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel.dta" , replace
 
 

 
use  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed.dta" , clear

egen total_loans = sum(loan_total_mixed),by(UltimateParentID year)
gen buffer = loan_total_mixed if ltype=="term"
egen term_loans = sum(buffer),by(UltimateParentID year)

keep UltimateParentID  year total_loans term_loans
duplicates drop

xtset UltimateParentID year

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel_parent.dta" , replace
 

use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\link_lenderid.dta" , clear
egen count=count(year), by(lenderid year)
egen max_best = max(best_match),  by(lenderid year)
drop if count>1 & best_match==0 &max_best==1
drop if year>2000
drop count 
egen count=count(year), by(lenderid year)
*drop if count>1 & best_match==0 

duplicates drop
sort lenderid year
 keep lenderid rssd year

 merge n:1 lenderid year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel.dta" , 

egen all_large_loans = sum(total_loans),by(rssd year)
egen large_term_loans = sum(term_loans),by(rssd year)

keep rssd  year all_large_loans large_term_loans
duplicates drop

xtset rssd year

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid.dta" , replace
 
rename rssd fin_hh_rssd

save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid_hold.dta" , replace
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\link_parentid.dta" , clear
egen count=count(year), by(ultimateparentid year)

egen max_best = max(best_match),  by(ultimateparentid year)
drop if count>1 & best_match==0 &max_best==1
drop if year>2000
duplicates drop
sort ultimateparentid year
 keep ultimateparentid rssd year

 rename ultimateparentid UltimateParentID
 
 merge n:1 UltimateParentID year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\dealscan_mixed_panel_parent.dta" , 


egen all_large_loans_par = sum(total_loans),by(rssd year)
egen large_term_loans_par = sum(term_loans),by(rssd year)

keep rssd  year all_large_loans large_term_loans
duplicates drop

xtset rssd year
save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid.dta" , replace
  

rename rssd fin_hh_rssd
save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid_hold.dta" , replace
  
/****End of Dealscan data preparation***/



/****Let us generate the acutal panel data****/


use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final.dta", clear

format date %td

/**make this panel data**/
gen yq = qofd(date)
format yq %tq

drop if assets <= 0
drop if assets_lag4 <= 0
drop if loans_net_lag4<0
drop if totalcapital < 0



merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_share_deposits.dta"

drop if _m == 2

cap drop state
cap drop _m
rename state_code state

merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta"

drop if _ == 2

cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta"


cap drop _merge
merge n:1 year irsdist using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta"



xtset rssd yq,quarterly

/**data screening**/

drop if country == "PUERTO RICO"
drop if fed_charter == 0 & state_charter == 0
drop if state == ""


count if year > 1991 & year<2001


replace etr = . if pi<0
replace etr2 = . if ebtx<0

replace etr=0 if etr<0
replace etr=1 if etr>1 & etr<.

replace etr2=0 if etr2<0
replace etr2=1 if etr2>1 & etr2<.

gen llp2_q = llp if quarter == 1
replace llp2_q = llp - l.llp if quarter > 1

cap drop loans_scale 
gen loans_scale = l.loans_net + l.llr

cap drop llp_to_loans
gen llp_to_loans = llp2_q/loans_scale

cap drop nonperform_to_loans
gen nonperform_to_loans = nonperform/loans_scale


gen llp_loans_y = llp / (l4.loans_net +l4.llr)
gen npl_loans_y = nonperform / (l4.loans_net +l4.llr)
gen npl_loans_y_lag = l4.npl_loans_y
gen cash_to_assets_lag = l4.cash_to_assets
gen d_npl_loans_y = (nonperform-l4.nonperform) / (l4.loans_net +l4.llr)
gen nco_loans_y = nco / (l4.loans_net +l4.llr)
 
drop deposits* id_cusip name name2 city   country auditclass irsname fips_temp

drop dep_broker_unin_lag4 dep_insured_all_to_assets dep_insured_der_to_assets ///
dep_uninsured_all_to_assets dep_uninsured_der_to_assets dep_uninsured_der_to_liab ///
dep_broker_to_liab dep_broker_unin dep_broker_unin_to_liab dep_broker_growth_yr ///
dep_broker_unin_growth_yr

gen prov = nonperform/llr

gen liab_to_assets_lag1= l1.liab_to_assets
gen liab_to_assets_lag4= l4.liab_to_assets
gen weight_l2= l8.commercial

gen l4_perc_audited_size=l4.perc_audited_size
 gen l_cons_to_loans=l4.consumer_to_loans

egen irs_id = group(irsdist)

/*Drop if firms banks move across districts*/
egen sd_irs_id = sd(irs_id), by(rssd)

keep if sd_irs_id == 0
count if year > 1991 & year<2001

gen  revenue_growth = (interest_revenue-l4.interest_revenue)/l4.interest_revenue

gen l_commercial_to_loans=l4.commercial_to_loans

egen sbl_ind = mean(sbl_ind), by(rssd year)


drop if year>2001

/**The next lines are input for robustness tests mentioned in footnotes**/


gen less_than100k=(l2.comm_lt100_total+f2.comm_lt100_total)/2
gen bet_100_250=(l2.comm_100_250_total+f2.comm_100_250_total)/2

cap drop buffer
gen buffer=commercial-comm_lt100_total
cap drop commercial_ex_100
egen commercial_ex_100=mean(buffer),by(rssd year)


/***merge of dealscan**/

cap drop _m
merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid.dta" 
replace all_large_loans = all_large_loans/1000000
replace large_term_loans = large_term_loans/1000000


cap drop _m
merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid.dta" 
replace all_large_loans_par = all_large_loans_par/1000000
replace large_term_loans_par = large_term_loans_par/1000000


replace all_large_loans=0 if all_large_loans==. & month == 12
replace large_term_loans=0 if large_term_loans==. & month == 12

replace all_large_loans_par=0 if all_large_loans_par==. & month == 12
replace large_term_loans_par=0 if large_term_loans_par==. & month == 12

replace all_large_loans_par=all_large_loans_par+all_large_loans
replace large_term_loans_par=large_term_loans_par+large_term_loans

gen commercial_ex_large_all=commercial-all_large_loans
gen commercial_ex_large_term =commercial-large_term_loans

gen commercial_ex_large_all_p=commercial-all_large_loans_par
gen commercial_ex_large_term_p =commercial-large_term_loans_par


replace commercial_ex_large_all=0 if commercial_ex_large_all<0
replace commercial_ex_large_term=0 if commercial_ex_large_term<0
replace commercial_ex_large_all_p=0 if commercial_ex_large_all_p<0
replace commercial_ex_large_term_p=0 if commercial_ex_large_term_p<0



rename all_large_loans all_large_loans_dir
rename large_term_loans large_term_loans_dir
rename all_large_loans_par all_large_loans_par_dir
rename large_term_loans_par large_term_loans_par_dir



cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid_hold.dta" 
replace all_large_loans = all_large_loans/1000000
replace large_term_loans = large_term_loans/1000000


cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid_hold.dta" 
replace all_large_loans_par = all_large_loans_par/1000000
replace large_term_loans_par = large_term_loans_par/1000000



replace all_large_loans=0 if all_large_loans==. & month == 12
replace large_term_loans=0 if large_term_loans==. & month == 12

replace all_large_loans_par=0 if all_large_loans_par==. & month == 12
replace large_term_loans_par=0 if large_term_loans_par==. & month == 12


replace all_large_loans_par=all_large_loans_par+all_large_loans
replace large_term_loans_par=large_term_loans_par+large_term_loans

gen commercial_ex_large_all2=commercial-all_large_loans
gen commercial_ex_large_term2 =commercial-large_term_loans

gen commercial_ex_large_all_p2=commercial-all_large_loans_par
gen commercial_ex_large_term_p2 =commercial-large_term_loans_par


replace commercial_ex_large_all2=0 if commercial_ex_large_all2<0
replace commercial_ex_large_term2=0 if commercial_ex_large_term2<0
replace commercial_ex_large_all_p2=0 if commercial_ex_large_all_p2<0
replace commercial_ex_large_term_p2=0 if commercial_ex_large_term_p2<0


xtset rssd yq, quarterly
gen l_commercial_ex100_to_loans=l4.commercial_ex_100/l4.loans_scale

/****/

 reg  perc_audited size_lag1 liab_to_assets_lag1    ///
 unemp_nsa ch_unemp_nsa_qtr  hpi_nsa   irs_id irs_id
 
 cap drop in_test
gen in_test = e(sample) == 1


count if year > 1991 & year<2001 & in_test == 1

cap drop code
gen code = .

replace code = 209 if assets<=0.25 
replace code = 213 if assets>0.25 & assets<=1  
replace code = 215 if assets>1 & assets<=5  
replace code = 217  if assets>5 & assets<=10  
replace code = 219 if assets>10 & assets<=50 
replace code = 221 if assets>50 & assets<=100 
replace code = 223 if assets>100 & assets<=250  
replace code = 225 if assets>250 & assets<. 


xtset rssd yq, quarterly
forvalues x = 1(1)12{
replace share_deposits = f.share_deposits if year <1994
}

forvalues x = 1(1)20{
replace share_deposits = f.share_deposits if share_deposits==.
}

count if year > 1991 & year<2001 & abs(share_deposits-1) <0.1 & share_deposits<.

 reg   perc_audited size_lag4 liab_to_assets_lag1    ///
 unemp_nsa ch_unemp_nsa_qtr  hpi_nsa     irs_id irs_id  if in_test == 1 & abs(share_deposits-1) <0.1 & share_deposits<.
 
 cap drop in_test
gen in_test = (e(sample) == 1)

count if year > 1991 & year<2001 & in_test == 1 & abs(share_deposits-1) <0.1 & share_deposits<.

count if year > 1991 & year<2001 & in_test == 1 & commercial_to_loans>0.01 & abs(share_deposits-1) <0.1 & share_deposits<.

count if year > 1991 & year<2001 & in_test == 1 & commercial_to_loans>0.01 & assets >25 & abs(share_deposits-1) <0.1 & share_deposits<.

gen revenue_growth_lag4 = l4.revenue_growth


 gen int_rev_assets= interest_revenue/l4.loans_scale
 gen int_inc_assets= interest_income/l4.loans_scale
 

foreach var of varlist nco_q_to_loans ch_npl  npl_loans_y_lag  ch_loans  ni_q liab_to_assets  commercial_to_loans  d_npl_loans_y ///
  nonperform_to_loans prov llp_q_to_loans llr_to_loans ch_npl_yr revenue_growth_lag4 npl_loans_y revenue_growth int_rev_assets int_inc_assets {
winsor `var',gen(`var'_w) p(0.01)
display `var'
}

cap drop llp_loans_y_w
cap drop nco_loans_y_w

foreach var of varlist llp_loans_y nco_loans_y{
winsor `var',gen(`var'_w) p(0.025)
}


winsor llp_loans_y, gen(llp_loans_y1) p(0.01)
winsor llp_loans_y, gen(llp_loans_y5) p(0.05)
winsor nco_loans_y, gen(nco_loans_y1) p(0.01)
winsor nco_loans_y, gen(nco_loans_y5) p(0.05)

 gen pi_at_dist = dist_sum_pi/dist_sum_at 


winsor dist_mean_cash_etr_1, gen(dist_mean_cash_etr_1_w) p(0.01)

gen inv_at_dist = dist_sum_capx/dist_sum_at  
gen cash_at_dist = dist_sum_che/dist_sum_at 


gen l1_pi_at_dist = l4.pi_at_dist
gen l1_dist_mean_cash_etr_1_w  = l4.dist_mean_cash_etr_1_w 
gen l1_ch_hpi_sa_qtr   = l4.ch_hpi_sa_qtr  
gen l1_change_unempl = l4.change_unempl
gen l1_unempl_dist  = l4.unempl_dist 
gen l1_hpi_sa_qtr   = l4.hpi_sa  
gen l1_cash_at_dist = l4.cash_at_dist
gen l1_inv_at_dist  = l4.inv_at_dist 
gen l1_hpi_change= l4.hpi_change 
gen l1_hpi_level= l4.hpi_level 

gen int_rev_assets_w_lag4= l4.int_rev_assets_w 
gen int_inc_assets_w_lag4= l4.int_inc_assets_w 

gen l4_ret_219=l4.ret_219
gen l4_perc_audited_219=l4.perc_audited_219
gen l4_perc_audited_209=l4.perc_audited_209
gen l4_perc_audited_213=l4.perc_audited_213
gen l4_perc_audited_215=l4.perc_audited_215
gen l4_perc_audited_217=l4.perc_audited_217
gen l4_perc_audited_221=l4.perc_audited_221
gen l4_perc_audited_223=l4.perc_audited_223
gen l4_perc_audited_225=l4.perc_audited_225
gen l4_perc_audited_bel_5=l4.perc_audited_bel_5

*keep if assets>50
drop if month != 12

xtset rssd year


 
keep if abs(share_deposits-1) <0.05 & share_deposits<.

xtset rssd year

*drop if year > 1999

sum l_commercial_to_loans if in_test == 1 & l_commercial_to_loans>0.01, d

replace l1_change_unempl = l1_change_unempl/100
replace l1_hpi_change = l1_hpi_change/100

 reg nco_loans_y_w   l4_perc_audited_219  size_lag4 liab_to_assets_lag4 revenue_growth_lag4_w ///
l1_pi_at_dist  l1_dist_mean_cash_etr_1_w l1_change_unempl l1_unempl_dist   ///
l1_cash_at_dist l1_inv_at_dist l1_hpi_change l1_hpi_level if in_test == 1 & l_commercial_to_loans>0.01  ///
,  cluster(rssd )

cap drop in_sample
gen in_sample = e(sample)

drop _m
merge n:1 state year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\State_Tax_Rates"

drop if _m ==2

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", replace



 
 /**Now, let's generate the Diff-in-Diff Sample*****/
 
 


use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final.dta", clear

 format date %td

/**make this panel data**/
gen yq = qofd(date)
format yq %tq

cap drop _merge
merge n:1 year irsdist using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta"

xtset rssd yq,quarterly

/**data screening**/
drop if assets <= 0
drop if assets_lag4 <= 0
drop if loans_net_lag4<0
drop if country == "PUERTO RICO"
drop if fed_charter == 0 & state_charter == 0
drop if state_code == ""
drop if totalcapital < 0
replace etr = . if pi<0
replace etr2 = . if ebtx<0

replace etr=0 if etr<0
replace etr=1 if etr>1 & etr<.

replace etr2=0 if etr2<0
replace etr2=1 if etr2>1 & etr2<.

gen ni2_q = ni if quarter == 1
replace ni2_q = ni - l.ni if quarter > 1


gen pi2_q = pi if quarter == 1
replace pi2_q = pi - l.pi if quarter > 1


gen llp2_q = llp if quarter == 1
replace llp2_q = llp - l.llp if quarter > 1

cap drop loans_scale 
gen loans_scale = l.loans_net + l.llr

cap drop llp_to_loans
gen llp_to_loans = llp2_q/loans_scale

gen nco_loans_y = nco / (l4.loans_net +l4.llr)



gen int_rev_loans=interest_revenue/loans_net_lag4

 
drop deposits* id_cusip name name2 city   country auditclass irsname fips_temp

drop dep_broker_unin_lag4 dep_insured_all_to_assets dep_insured_der_to_assets ///
dep_uninsured_all_to_assets dep_uninsured_der_to_assets dep_uninsured_der_to_liab ///
dep_broker_to_liab dep_broker_unin dep_broker_unin_to_liab dep_broker_growth_yr ///
dep_broker_unin_growth_yr


gen prov = nonperform/llr

gen liab_to_assets_lag1= l1.liab_to_assets
gen liab_to_assets_lag4= l4.liab_to_assets

cap drop revenue_growth
gen  revenue_growth = (interest_revenue-l4.interest_revenue)/l4.interest_revenue



gen llp_loans_y = llp / (l4.loans_net +l4.llr)
gen npl_loans_y = nonperform / (l4.loans_net +l4.llr)
gen f_npl_loans_y = f4.nonperform / (loans_net +llr)


egen irs_id = group(irsdist)
egen sd_irs_id = sd(irs_id), by(rssd)

keep if sd_irs_id == 0


drop if year<1995
drop if year>2004

drop if scorp == 1


xtset rssd yq
gen revenue_growth_lag4 = l4.revenue_growth

foreach var of varlist nco_q_to_loans ch_npl   liab_to_assets  commercial_to_loans   ///
  nonperform_to_loans prov llp_q_to_loans llr_to_loans ch_npl_yr revenue_growth_lag4 npl_loans_y revenue_growth {
winsor `var',gen(`var'_w) p(0.01)
display `var'
}



/**create the state-year-quarter fixed effects**/

xtset rssd yq, quarterly

replace irsdist = irsdist[_n-1] if year > 2000 & rssd == l.rssd


xtset rssd yq, quarterly

replace perc_audited_219 = 0.09280 if year ==2001
replace perc_audited_219 = 0.07510 if year ==2002
replace perc_audited_219 = 0.05851 if year ==2003
replace perc_audited_219 = 0.08848 if year ==2004
replace perc_audited_219 = 0.11430 if year ==2005

gen post = (year>2000) 

egen mean_audited_219 = mean(perc_audited_219) if year ~= 2000 & year<2004 & year >1997 , by(rssd post)


replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==1
replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==2
replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==3
replace mean_audited_219 = l.mean_audited_219 if year == 2000 & quarter ==4



cap drop diff_219
gen diff_219 = d.mean_audited_219 if year == 2001 &quarter == 1

cap drop change_diff_219
egen change_diff_219 = mean(diff_219) , by(irsdist)

egen count_obs = count(year), by(rssd)



replace irs_id = l.irs_id if year > 2000 & rssd == l.rssd


cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta"

drop if _ == 2


cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta"


drop if _ == 2

 gen pi_at_dist = dist_sum_pi/dist_sum_at 


winsor dist_mean_cash_etr_1, gen(dist_mean_cash_etr_1_w) p(0.01)

gen inv_at_dist = dist_sum_capx/dist_sum_at  
gen cash_at_dist = dist_sum_che/dist_sum_at 


cap drop _m
merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_share_deposits.dta"
drop if _m == 2


drop if month != 12
cap drop _m
 

xtset rssd year


save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\Diff_in_Diff_sample.dta" , replace 

 
 
 /****End of generating panel data****/
 
 
 /***Final Step: Let us generate the cross-sectional split variables***/


 /***Input data for the cross-sectional splits**/
 
 use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch.dta", clear
rename rssdid rssd
rename stcntybr fips
rename depsumbr deposits_branch
keep year rssd namebr fips deposits_branch
drop if year>2000
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer.dta", replace

use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer.dta", clear
keep if year == 1994
replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer93.dta", replace

replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer92.dta", replace

replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer91.dta", replace

replace year = year-1
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer90.dta", replace

use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer90.dta", clear
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer91.dta"
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer92.dta"
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer93.dta"
append using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_buffer.dta"
save "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta", replace
 
 
 *Step 1: Regional Concentration & Local Competition

use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", clear

keep if month == 12
keep rssd year commercial

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\commercial_banks.dta", replace
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\commercial_banks.dta"
 
 keep if _m == 3
 
 egen sum_deposits = sum(deposits_branch) , by(rssd year)

gen buffer_weight = deposits_branch*commercial/sum_deposits

replace buffer_weight = 0 if buffer_weight==.

egen sum_commercial = sum(buffer_weight), by(fips year) 
 
gen buffer = (buffer_weight/sum_commercial)^2
egen HHI_County_Commercial = sum(buffer), by(fips year)
   
  keep fips year HHI 
  
  duplicates drop
  
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\county_level_information_branch.dta", replace
 
 
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", clear
  
 keep rssd year commercial
  
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_to_branch_data.dta", replace
 
 
use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta" , clear

merge n:1 fips year using  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\county_level_information_branch.dta"

drop if _m == 2
 
 cap drop _m

egen sum_deposits = sum(deposits_branch), by(rssd year)

gen buffer_weight = deposits_branch*HHI_County_Commercial/sum_deposits
egen b_HHI_County_Commercial=sum(buffer_weight),by(rssd year)

gen buffer = (deposits_branch/sum_deposits)^2
egen HHI_Bank_Region = sum(buffer), by(rssd year)

keep rssd year b_HHI_County_Commercial HHI_Bank_Region 

duplicates drop

replace year = year+1

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\bank_cross_section.dta", replace


 *Step 2: New Bank Entries
 
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\final_for_regression.dta", clear
 
 *drop if sbl_ind==1
 
 keep rssd year commercial_to_loans
 
 
 rename rssd rssdid
 
  
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\input_for_comm_branch.dta",replace
 
  
 use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch.dta" , clear
 drop if year >2000
  forvalues x=90(1)93{
 append using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_`x'.dta" , 
  }
 drop if asset == 0
 drop if depsumbr == 0
 
 merge n:1 rssdid year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\input_for_comm_branch.dta"
 
 drop if _m == 2
 
 rename stcntybr fips 
  
 gen acq_year = year(SIMS_ACQUIRED_DATE)
 gen est_year = year(SIMS_ESTABLISHED_DATE)
 cap drop age
 gen age = year-est_year
 drop if age <0
 replace age = year-acq_year if acq_year>est_year & acq_year<. 
 drop if age <0
 
 drop if commercial_to_loans<0.01
 
 egen count_branches = count(year) ,by(rssdid fips year)
 keep count_branches rssdid year fips
 
 duplicates drop 
 egen id = group(rssd fips)
  
xtset id year

gen new2 = (count_branches~=. & l.count_branches==. & year >1990)

 egen num_banks_fips=count(count_branches), by(fips year)
 egen num_new = sum(new2), by(fips year)
 
 keep num_banks_fips fips year num_new 
 
 duplicates drop 
 egen id = group(fips)
 
 xtset id year
 gen bank_entry_fips_alt = num_new
 gen bank_growth_fips = num_new/num_banks_fips
 
 drop id
 rename num_banks_fips num_banks_fips_alt  
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\net_entrants_fips91_99.dta", replace

 
 
 
  
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 
cap drop _m
merge n:1 fips year using   "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\net_entrants_fips91_99.dta"
drop if _m == 2


 egen sum_deposits = sum(deposits_branch) , by(rssd year)
 
cap drop buffer_weight
gen buffer_weight = deposits_branch*bank_growth_fips/sum_deposits
egen b_bank_growth_fips=sum(buffer_weight),by(rssd year)


keep rssd year b_*

duplicates drop

replace year = year+1
 
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\entrants_bank_new.dta" , replace
 
 
 
 
 
 /********Data for Table A.1**********/
 
 
 

use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final.dta", clear

format date %td

/**make this panel data**/
gen yq = qofd(date)
format yq %tq

drop if assets <=0
drop if assets_lag4 <= 0
drop if loans_net_lag4<0
drop if totalcapital < 0



merge n:1 rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\input_share_deposits.dta"

drop if _m == 2

cap drop state
cap drop _m
rename state_code state

merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\industry_info_dist.dta"

drop if _ == 2

cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\unemployment_dist.dta"


cap drop _merge
merge n:1 year irsdist using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\audit_rates_per_class.dta"



xtset rssd yq,quarterly

/**data screening**/

drop if country == "PUERTO RICO"
drop if fed_charter == 0 & state_charter == 0
drop if state == ""


count if year > 1991 & year<2001


replace etr = . if pi<0
replace etr2 = . if ebtx<0

replace etr=0 if etr<0
replace etr=1 if etr>1 & etr<.

replace etr2=0 if etr2<0
replace etr2=1 if etr2>1 & etr2<.

gen llp2_q = llp if quarter == 1
replace llp2_q = llp - l.llp if quarter > 1

cap drop loans_scale 
gen loans_scale = l.loans_net + l.llr

cap drop llp_to_loans
gen llp_to_loans = llp2_q/loans_scale

cap drop nonperform_to_loans
gen nonperform_to_loans = nonperform/loans_scale

gen etr_lead4=f4.etr2
gen etr_lead8=f8.etr2


gen llp_loans_y = llp / (l4.loans_net +l4.llr)
gen npl_loans_y = nonperform / (l4.loans_net +l4.llr)
gen npl_loans_y_lag = l4.npl_loans_y
gen cash_to_assets_lag = l4.cash_to_assets
gen d_npl_loans_y = (nonperform-l4.nonperform) / (l4.loans_net +l4.llr)
gen nco_loans_y = nco / (l4.loans_net +l4.llr)
gen ni_assets = ni/l4.assets
drop id_cusip name name2 city   country auditclass irsname fips_temp

drop dep_broker_unin_lag4 dep_insured_all_to_assets dep_insured_der_to_assets ///
dep_uninsured_all_to_assets dep_uninsured_der_to_assets dep_uninsured_der_to_liab ///
dep_broker_to_liab dep_broker_unin dep_broker_unin_to_liab dep_broker_growth_yr ///
dep_broker_unin_growth_yr

gen prov = nonperform/llr

gen liab_to_assets_lag1= l1.liab_to_assets
gen liab_to_assets_lag4= l4.liab_to_assets

gen l4_perc_audited_size=l4.perc_audited_size
 gen l_cons_to_loans=l4.consumer_to_loans

egen irs_id = group(irsdist)

/*Drop if firms banks move across districts*/
egen sd_irs_id = sd(irs_id), by(rssd)

keep if sd_irs_id == 0
count if year > 1991 & year<2001

gen  revenue_growth = (interest_revenue-l4.interest_revenue)/l4.interest_revenue

gen l_commercial_to_loans=l4.commercial_to_loans

egen sbl_ind = mean(sbl_ind), by(rssd year)


drop if year>2001




cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_lenderid_hold.dta" 
replace all_large_loans = all_large_loans/1000000
replace large_term_loans = large_term_loans/1000000


cap drop _m
merge n:1 fin_hh_rssd year using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\dealscan\large_loans_parentid_hold.dta" 
replace all_large_loans_par = all_large_loans_par/1000000
replace large_term_loans_par = large_term_loans_par/1000000



replace all_large_loans=0 if all_large_loans==. & month == 12
replace large_term_loans=0 if large_term_loans==. & month == 12

replace all_large_loans_par=0 if all_large_loans_par==. & month == 12
replace large_term_loans_par=0 if large_term_loans_par==. & month == 12


replace all_large_loans_par=all_large_loans_par+all_large_loans
replace large_term_loans_par=large_term_loans_par+large_term_loans

gen commercial_ex_large_all2=commercial-all_large_loans
gen commercial_ex_large_term2 =commercial-large_term_loans

gen commercial_ex_large_all_p2=commercial-all_large_loans_par
gen commercial_ex_large_term_p2 =commercial-large_term_loans_par


replace commercial_ex_large_all2=0 if commercial_ex_large_all2<0
replace commercial_ex_large_term2=0 if commercial_ex_large_term2<0
replace commercial_ex_large_all_p2=0 if commercial_ex_large_all_p2<0
replace commercial_ex_large_term_p2=0 if commercial_ex_large_term_p2<0


xtset rssd yq, quarterly
gen l_commercial_ex100_to_loans=l4.commercial_ex_100/l4.loans_scale
gen l_commercial_ex250_to_loans=l4.commercial_ex_250/l4.loans_scale
gen l_commercial_ex_mic_to_loans=l4.commercial_ex_micro/l4.loans_scale

/****/

 reg  perc_audited size_lag1 liab_to_assets_lag1    ///
 unemp_nsa ch_unemp_nsa_qtr  hpi_nsa   irs_id irs_id
 
 cap drop in_test
gen in_test = e(sample) == 1


count if year > 1991 & year<2001 & in_test == 1

cap drop code
gen code = .

replace code = 209 if assets<=0.25 
replace code = 213 if assets>0.25 & assets<=1  
replace code = 215 if assets>1 & assets<=5  
replace code = 217  if assets>5 & assets<=10  
replace code = 219 if assets>10 & assets<=50 
replace code = 221 if assets>50 & assets<=100 
replace code = 223 if assets>100 & assets<=250  
replace code = 225 if assets>250 & assets<. 


xtset rssd yq, quarterly
forvalues x = 1(1)12{
replace share_deposits = f.share_deposits if year <1994
}

forvalues x = 1(1)20{
replace share_deposits = f.share_deposits if share_deposits==.
}

gen revenue_growth_lag4 = l4.revenue_growth


 gen int_rev_assets= interest_revenue/l4.loans_scale
 gen int_inc_assets= interest_income/l4.loans_scale
 

foreach var of varlist nco_q_to_loans ch_npl  npl_loans_y_lag  ch_loans  ni_q liab_to_assets  commercial_to_loans  d_npl_loans_y ni_assets ///
  nonperform_to_loans prov llp_q_to_loans llr_to_loans ch_npl_yr revenue_growth_lag4 npl_loans_y revenue_growth int_rev_assets int_inc_assets {
winsor `var',gen(`var'_w) p(0.01)
display `var'
}

cap drop llp_loans_y_w
cap drop nco_loans_y_w

foreach var of varlist llp_loans_y nco_loans_y{
winsor `var',gen(`var'_w) p(0.025)
}

 gen pi_at_dist = dist_sum_pi/dist_sum_at 

gen inv_at_dist = dist_sum_capx/dist_sum_at  
gen cash_at_dist = dist_sum_che/dist_sum_at 


gen l1_pi_at_dist = l4.pi_at_dist
gen l1_dist_mean_cash_etr_1_w  = l4.dist_mean_cash_etr_1
gen l1_ch_hpi_sa_qtr   = l4.ch_hpi_sa_qtr  
gen l1_change_unempl = l4.change_unempl
gen l1_unempl_dist  = l4.unempl_dist 
gen l1_hpi_sa_qtr   = l4.hpi_sa  
gen l1_cash_at_dist = l4.cash_at_dist
gen l1_inv_at_dist  = l4.inv_at_dist 
gen l1_hpi_change= l4.hpi_change 
gen l1_hpi_level= l4.hpi_level 

gen int_rev_assets_w_lag4= l4.int_rev_assets_w 
gen int_inc_assets_w_lag4= l4.int_inc_assets_w 

gen l4_ret_219=l4.ret_219
gen l4_perc_audited_219=l4.perc_audited_219
gen l4_perc_audited_209=l4.perc_audited_209
gen l4_perc_audited_213=l4.perc_audited_213
gen l4_perc_audited_215=l4.perc_audited_215
gen l4_perc_audited_217=l4.perc_audited_217
gen l4_perc_audited_221=l4.perc_audited_221
gen l4_perc_audited_223=l4.perc_audited_223
gen l4_perc_audited_225=l4.perc_audited_225
gen l4_perc_audited_bel_5=l4.perc_audited_bel_5

*keep if assets>50
drop if month != 12

xtset rssd year

 
gen ln_comm_gr = ln(commercial/l.commercial)
 
winsor ln_comm_gr,gen(ln_comm_gr_w) p(0.01)


drop if assets<250
drop if year > 1999


count if abs(share_deposits-1) <0.05 & share_deposits<.
count if abs(share_deposits-1) >=0.05 & share_deposits<.
 
gen in_test_deposit=1
replace in_test_deposit=0 if abs(share_deposits-1) <0.05 & share_deposits<.


 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\data_for_comparison.dta",replace

 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 drop namebr deposits_branch
 
 duplicates drop
 
 egen count_counties = count(year), by(rssd year)
 
 keep rssd year count_counties 
 
 duplicates drop
 
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\county_data_for_comparison.dta", replace
 
  
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\branch\branch_raw_90_00.dta" , clear
 
 
 egen count_branches = count(year), by(rssd year)
 
 keep rssd year count_branches 
 
 duplicates drop
 
 save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\final\branch_data_for_comparison.dta", replace
 
 
 
 *************
 

use "C:\Users\martin.jacob\Dropbox\GJ\data\final\Compustat_Sample", clear

cap drop mean_cash_etr_1_w

drop if inv_w==.

keep if at>10 & at <50

foreach var of varlist inv_w cash_assets_w pi_assets_w ni_assets_w sg_w lvg_w gross_margin_at_w  tangibility_w ///
intangibles_w ppe_w  cash_etr_1 { 
egen dist_mean_`var'_1050=mean(`var'), by(irsdist year)
}



egen count=count(year) , by(irsdist year)



foreach var of varlist capx che at dltt sale pi oibdp{ 
egen dist_sum_`var'_1050 = sum(`var'), by(irsdist year)
}

keep irsdist dist_mean_* dist_sum_* year count

duplicates drop

foreach var of varlist dist_mean_inv_w dist_mean_cash_assets_w dist_mean_pi_assets_w dist_mean_sg_w dist_mean_lvg_w dist_mean_gross_margin_at_w ///
 dist_mean_tangibility_w ///
dist_mean_intangibles_w dist_mean_ppe_w  dist_mean_cash_etr_1 { 
keep if `var' ~=.
}


replace year = year+1

save "C:\Users\martin.jacob\Dropbox\GJ\data\final\industry_info_dist_1050.dta", replace


use "C:\Users\martin.jacob\Dropbox\GJ\data\final\Compustat_Sample", clear

cap drop mean_cash_etr_1_w

drop if inv_w==.

keep if at>50

foreach var of varlist inv_w cash_assets_w pi_assets_w ni_assets_w sg_w lvg_w gross_margin_at_w  tangibility_w ///
intangibles_w ppe_w  cash_etr_1 { 
egen dist_mean_`var'_ab50=mean(`var'), by(irsdist year)
}



egen count=count(year) , by(irsdist year)



foreach var of varlist capx che at dltt sale pi oibdp{ 
egen dist_sum_`var'_ab50 = sum(`var'), by(irsdist year)
}

keep irsdist dist_mean_* dist_sum_* year count

duplicates drop

foreach var of varlist dist_mean_inv_w dist_mean_cash_assets_w dist_mean_pi_assets_w dist_mean_sg_w dist_mean_lvg_w dist_mean_gross_margin_at_w ///
 dist_mean_tangibility_w ///
dist_mean_intangibles_w dist_mean_ppe_w  dist_mean_cash_etr_1 { 
keep if `var' ~=.
}


replace year = year+1

save "C:\Users\martin.jacob\Dropbox\GJ\data\final\industry_info_dist_ab50.dta", replace


 

 /***Input for Table 9 - CRA Data ***/


 cd "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\CRA-Data"
 
 
 
import delimited "00exp_trans.dat", clear delimiter(tab)
gen respondentid = substr(v1, 1, 10)
gen rssd = substr(v1, 133, 10)
keep respondentid rssd
destring  rssd, replace
egen dup = count(rs), by(respon)
drop if dup==2
drop dup
save rssd_respondentid.dta, replace


import delimited "96exp_discl.dat", clear delimiter(tab)
gen table = substr(v1, 1, 4)
keep if table=="D1-1"
gen respondentid = substr(v1, 5, 10)
gen regulatorid = substr(v1, 15, 1)
gen year = substr(v1, 16, 4)
gen loantype = substr(v1, 20, 1)
gen actiontype = substr(v1, 21, 1)
gen state = substr(v1, 22, 2)
gen county = substr(v1, 24, 3)
gen msa = substr(v1, 27,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 44,6)
gen amountloans_lower100k = substr(v1, 50,8)
gen nloans_btwn100k250k = substr(v1, 58,6)
gen amountloans_btwn100k250k = substr(v1, 64,8)
gen nloans_greater250k = substr(v1, 72,6)
gen amountloans_greater250k = substr(v1, 78,8)
gen nloans_lower1M = substr(v1, 86,6)
gen amountloans_lower1M = substr(v1, 92,8)
gen nloans_affiliate = substr(v1, 100,6)
gen amountloans_affiliate = substr(v1, 106,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr reportlevel, replace force
drop if reportlevel==.
keep if reportlevel>399 // Here we have a different situation relative to older CRA reports (The code 400 is only reported when there are more than one 500 and 600 for each county.
duplicates tag respondentid regulatorid stcntybr, generate(dp) // Therefore, here I identify duplicate observations
keep if dp ==0 | reportlevel ==400 & msa=="    " //  and I keep either observations that are not duplicates or the code 400 for duplicate observations

drop table v1 reportlevel dp

egen number_counties=count(nloans_btwn100k250k),by(respondentid)

save sbl996, replace


foreach num of numlist 97/98{

import delimited `num'exp_discl.dat, clear delimiter(tab)
gen table = substr(v1, 1, 5)
keep if table=="D1-1 "
gen respondentid = substr(v1, 6, 10)
gen regulatorid = substr(v1, 16, 1)
gen year = substr(v1, 17, 4)
gen loantype = substr(v1, 21, 1)
gen actiontype = substr(v1, 22, 1)
gen state = substr(v1, 23, 2)
gen county = substr(v1, 25, 3)
gen msa = substr(v1, 28,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 45,6)
gen amountloans_lower100k = substr(v1, 51,8)
gen nloans_btwn100k250k = substr(v1, 59,6)
gen amountloans_btwn100k250k = substr(v1, 65,8)
gen nloans_greater250k = substr(v1, 73,6)
gen amountloans_greater250k = substr(v1, 79,8)
gen nloans_lower1M = substr(v1, 87,6)
gen amountloans_lower1M = substr(v1, 93,8)
gen nloans_affiliate = substr(v1, 101,6)
gen amountloans_affiliate = substr(v1, 107,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr reportlevel, replace force
drop if reportlevel==.
keep if reportlevel>39 // Here we have a different situation relative to older CRA reports (The code 400 is only reported when there are more than one 500 and 600 for each county.
duplicates tag respondentid regulatorid stcntybr, generate(dp) // Therefore, here I identify duplicate observations
keep if dp ==0 | reportlevel ==40 & msa=="    " //  and I keep either observations that are not duplicates or the code 400 for duplicate observations

drop table v1 reportlevel dp


egen number_counties=count(nloans_btwn100k250k),by(respondentid)

save sbl`num', replace
}


//// 1.3 **** Here I am cleaning the data from 1999 to 2003 (CRA started reporting the report level differently after 1998 and then CRA changed the codebook between 2003 and 2004)


import delimited 99exp_discl.dat, clear delimiter(tab)
gen table = substr(v1, 1, 5)
keep if table=="D1-1 "
gen respondentid = substr(v1, 6, 10)
gen regulatorid = substr(v1, 16, 1)
gen year = substr(v1, 17, 4)
gen loantype = substr(v1, 21, 1)
gen actiontype = substr(v1, 22, 1)
gen state = substr(v1, 23, 2)
gen county = substr(v1, 25, 3)
gen msa = substr(v1, 28,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 45,6)
gen amountloans_lower100k = substr(v1, 51,8)
gen nloans_btwn100k250k = substr(v1, 59,6)
gen amountloans_btwn100k250k = substr(v1, 65,8)
gen nloans_greater250k = substr(v1, 73,6)
gen amountloans_greater250k = substr(v1, 79,8)
gen nloans_lower1M = substr(v1, 87,6)
gen amountloans_lower1M = substr(v1, 93,8)
gen nloans_affiliate = substr(v1, 101,6)
gen amountloans_affiliate = substr(v1, 107,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr, replace force
keep if reportlevel =="040"

drop table v1 reportlevel

egen number_counties=count(nloans_btwn100k250k),by(respondentid)


save sbl999.dta, replace


foreach num of numlist 0/3{

import delimited 0`num'exp_discl.dat, clear delimiter(tab)
gen table = substr(v1, 1, 5)
keep if table=="D1-1 "
gen respondentid = substr(v1, 6, 10)
gen regulatorid = substr(v1, 16, 1)
gen year = substr(v1, 17, 4)
gen loantype = substr(v1, 21, 1)
gen actiontype = substr(v1, 22, 1)
gen state = substr(v1, 23, 2)
gen county = substr(v1, 25, 3)
gen msa = substr(v1, 28,4)
gen reportlevel = substr(v1, 42,3)
gen nloans_lower100k = substr(v1, 45,6)
gen amountloans_lower100k = substr(v1, 51,8)
gen nloans_btwn100k250k = substr(v1, 59,6)
gen amountloans_btwn100k250k = substr(v1, 65,8)
gen nloans_greater250k = substr(v1, 73,6)
gen amountloans_greater250k = substr(v1, 79,8)
gen nloans_lower1M = substr(v1, 87,6)
gen amountloans_lower1M = substr(v1, 93,8)
gen nloans_affiliate = substr(v1, 101,6)
gen amountloans_affiliate = substr(v1, 107,8)
gen stcntybr = state + county

*****
destring nloans_lower100k-amountloans_affiliate stcntybr, replace force
keep if reportlevel =="040"

drop table v1 reportlevel

egen number_counties=count(nloans_btwn100k250k),by(respondentid)

save sbl200`num', replace
}

use sbl996, clear
append using sbl97
append using sbl98
append using sbl999
append using sbl2000
append using sbl2001
append using sbl2002
append using sbl2003

merge n:1 respondentid using rssd_respondentid

keep if _m == 3

save cra_panel_raw.dta, replace




/***Let's generate the numbers within the district**/

use  cra_panel_raw.dta, clear

cap drop number_counties

/***Zoom in only on counties within the HQ district***/
gen fips = state+county
destring fips, replace
cap drop _m 
merge n:1 respondentid using rssd_respondentid

keep if _m == 3
drop _m

merge n:1 rssd using rssd_matched

keep if _m == 3

drop _m
replace irsdist="Pacific Northwest" if irsdist=="Pacific-Northwest"

merge n:1 fips using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\macroeconomic\fips_dist.dta" 

keep if _m == 3


keep if irsdist==irsdist_hq

egen total_loans=rowtotal(amountloans_btwn100k250k amountloans_greater250k)

egen total_loans_100=rowtotal(amountloans_lower100k)

egen total_loans_bank=sum(total_loans),by(rssd  year)
gen buf= total_loans/total_loans_bank
gen buf2 = buf*buf
egen disp_bank = sum(buf2),by(rssd  year)

egen total_loans_bank_100=sum(amountloans_lower100k),by(rssd  year)
cap drop buf buf2
gen buf= total_loans_100/total_loans_bank_100
gen buf2 = buf*buf
egen disp_bank_100 = sum(buf2),by(rssd  year)

keep  year  rssd total_loans_bank disp_bank_100  disp_bank total_loans_bank_100
duplicates drop 
destring year, replace
save cra_information_part_1.dta, replace

/***Let's generate the share of lending / number of counties where bank does not have a branch**/
use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta" , clear
keep if year>1995
drop namebr 
drop deposits_branch
duplicates drop
save raw_branch_for_merge.dta,replace

use  cra_panel_raw.dta, clear

cap drop number_counties

/***Zoom in only on counties within the HQ district***/
gen fips = state+county
destring fips, replace
cap drop _m 
merge n:1 respondentid using rssd_respondentid

keep if _m == 3
drop _m

merge n:1 rssd using rssd_matched

keep if _m == 3

drop _m
replace irsdist="Pacific Northwest" if irsdist=="Pacific-Northwest"

merge n:1 fips using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\macroeconomic\fips_dist.dta" 

keep if _m == 3


drop _m

destring year, replace
merge n:1 rssd year fips using raw_branch_for_merge

drop if _m == 2

keep if irsdist==irsdist_hq

egen total_loans=rowtotal(amountloans_btwn100k250k amountloans_greater250k)

egen total_loans_outside=sum(total_loans) if _m==1, by(rssd year)

cap drop buf 
egen buf = max(total_loans_outside),by(rssd year)
replace total_loans_outside=buf if total_loans_outside==.
replace total_loans_outside=0 if total_loans_outside==.


keep  year  rssd total_loans_outside 
duplicates drop

save cra_information_part_2.dta, replace 


use "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\branch\branch_raw_90_00.dta" , clear
keep if year>1995
drop namebr 
drop deposits_branch
duplicates drop
save raw_branch_for_merge.dta,replace

use  cra_panel_raw.dta, clear

cap drop number_counties

/***Zoom in only on counties within the HQ district***/
gen fips = state+county
destring fips, replace
cap drop _m 
merge n:1 respondentid using rssd_respondentid

keep if _m == 3
drop _m

merge n:1 rssd using rssd_matched

keep if _m == 3

drop _m
replace irsdist="Pacific Northwest" if irsdist=="Pacific-Northwest"

merge n:1 fips using  "C:\Users\martin.jacob\Dropbox\current projects\GJ\data\macroeconomic\fips_dist.dta" 

keep if _m == 3


drop _m

destring year, replace
merge n:1 rssd year fips using raw_branch_for_merge

drop if _m == 2

keep if irsdist==irsdist_hq
egen total_loans=rowtotal(amountloans_lower100k)

egen group = group(rssd year fips)
egen dup = count(fips), by(group)
drop if dup == 2
egen group2 = group(rssd  fips)

xtset group2 year


egen total_loans_bank=sum(total_loans), by(rssd year)
egen total_loans_outside=sum(total_loans) if _m==1, by(rssd year)

drop if total_loans_bank==.
cap drop buf 
egen buf = max(total_loans_bank),by(rssd year)
replace total_loans_bank=buf if total_loans_bank==.

cap drop buf 
egen buf = max(total_loans_outside),by(rssd year)
replace total_loans_outside=buf if total_loans_outside==.

gen share_not_in_branch=total_loans_outside/total_loans_bank
 
keep  year  rssd  share_not_in_branch  
duplicates drop
rename share_not_in_branch share_not_in_branch_100


save cra_information_part_3.dta, replace 




use "C:\Users\martin.jacob\Desktop\fb9b4da6455c8e2b.dta" , clear

keep if loc == "USA"
keep if fic == "USA"
keep if curcd == "USD"

drop indfmt consol popsrc datafmt tic cusip conm acctstd acqmeth compst ///
 final ltcm ogm  costat add1 add2 add3 busdesc city conml county ///
dlrsn ein fax ggroup gind gsector gsubind phone prican prirow priusa ///
spcindcd spcseccd spcsrc ipodate dldte weburl loc fic curcd currtr curuscn curncd ///
acctchg adrr ajex ajp bspr fyr ismod pddur scf src stalt udpl upd apdedate  acchg acco accrt ///
acdo acodo acominc acox acqao acqcshi acqgdwl acqic acqintan acqinvt acqlntal acqniintc acqppe acqsc adpac ///
aedi afudcc afudci aldo am amc amdc amgw ano aocidergl aociother aocipen aocisecgl aodo aol2  aox ///
 apb apc apofs aqa aqc aqd aqeps aqi aqp aqpl1 aqs arb arc arce arced arceeps artfs aul3 autxr balr ///
 banlr bast bastr batr bcef bclr bcltbl bcnlr bcrbl bct bctbl bctr billexce bkvlps bltbl ca capr1 capr2 ///
 capr3 caps capsft capxv cb cbi cdpac ceiexbill ceql ceqt cfbd cfere cfo cfpdo cga cgri cgui cgti chech ///
 cibegni cicurr cidergl cimii ciother cipen cisecgl citotal cld2 cld3 cld4 cld5 clfc clfx clg clis cll ///
 cllc clo clrll clt cmp cnltbl cpcbl cpdoi cpnli cppbl cprei crvnli cshfd cshi cshpri cshr cshrc cshrp ///
 cshrso cshrt cshrw cstk cstkcv cstke dbi dc dclo dcom dcpstk dcs dcvsr dcvsub dcvt dd  dd2 dd3 dd4 ///
 dd5 derac deralt derhedgl derlc derllt dfpac dfs dfxa diladj dilavx dlcch dltis dlto dltp dltr dltsub ///
 dm dn do donr dpacb dpacc dpacli dpacls dpacme dpacnr dpaco dpacre dpact  dpdc dpltb dpret depc ///
  dpsc dpstb dptb dptc dptic dpvieb dpvio dpvir drc drci drlt ds dt dtea dted dteeps dtep dudd dvc ///
 dvdnp dvintf dvp dvpa dvpdp dvpibb dvrpiv dvsco dvrre dvt dxd2 dxd3 dxd4 dxd5 ea ///
  txva txw uaoloch uaox uapt ucaps uccons  ucustad udcopres udd udfcc udmb udolt  ///
 udpco udpfa udvp ufretsd ugi ui uinvt ulcm ulco uniami unl unnp unnpl unopinc unwcc  ///
 uois uopi uopres updvp upmcstk upmpf upmpfs upmsubp upstk upstkc upstksf urect urectr  ///
 urevub uspi ustdnc usubdvp usubpstk utfdoc utfosc utme utxfed uwkcapc uxinst uxintd  ///
 vpac vpo wcap wcapc wcapch wda wdd wdeps wdp ///
  fatp fca fdfr fea fel ffo ffs fiao finaco finao fincf finch findlc findlt finivst  ///
 finlco finlto finnp finrecc finreclt finrev finxint finxopr fopo fopox fopt fsrco  ///
 fsrct fuseo fuset gbbl gdwl gdwlam gdwlia gdwlid gdwlieps gdwlip geqrv gla glcea  ///
 glced glceeps glcep gld gleps gliv glp govgr govtown gp gphbl gplbl gpobl gprbl  ///
 gptbl gwo hedgegl iaeq iaeqci iaeqmi iafici iafxi iafxmi iali ///
  ialoi ialti iamli iaoi iapli transa tsa tsafc tso tstk tstkc tstkme  ///
 tstkn tstkp txtubadjust txtubbegin txtubend txtubmax txtubmin txtubposdec  ///
 txtubposinc txtubpospdec txtubpospinc txtubsettle txtubsoflimit txtubtxtr  ///
 txtubxintbs txtubxintis  iarei iasci iasmi iassi iasti iatci iati iatmi  ///
 iaui  ibadj ibbl ibc ibcom ibki ibmii icapt idiis idilb idilc idis idist  ///
 idit idits iire initb intano intc intpn  invfg invo invofs  ///
 invreh invrei invres invrm  invwip iobd ioi iore ip ipabl ipc iphbl  ///
 iplbl ipobl iptbl ipti ipv irei irent irii irli irnli irsi iseq iseqc  ///
 iseqm isfi isfxc isfxm isgr isgt isgu islg islgc islgm islt isng isngc  ///
 isngm isotc isoth isotm issc issm issu ist istc istm isut itcb itcc itci  ///
 ivaco  ivao ivch ivgod ivi ivncf ivpt ivst ivstch lcabg lcacl lcacr  ///
 lcag lcal lcalt lcam lcao lcast lcat lco lcox lcoxar lcoxdr  lcuacu li  ///
 lif lifr lifrp lloml lloo llot llrci llrcr llwoci llwocr lno lo lol2 loxdr lqpl1  ///
 lrv ls lse lst lt lul3 mib mibn mibt mii mrc1 mrc2 mrc3 mrc4 mrc5 mrct mrcta msa  ///
 msvrv mtl nat nco nfsr niadj nieci niint niintpfc niintpfp niit nim nio nipfc  ///
 nipfp nit nits nopi nopio np npanl npaore nparl npat nrtxt nrtxtd nrtxteps ob  ///
  tf tfva tfvce tfvl tie tii  txdba txdbca txdbcl  txdfed txdfo  txditc txds txeqii  ///
  opeps opili opincar opini opioi opiri opiti oprepsx optca optdr optex optexd optfvgr  ///
 optgr optlife optosby optosey optprcby optprcca optprcex optprcey optprcgr optprcwa  ///
 optrfr optvol palr panlr patr pcl pclr pcnlr pctr pdvc  pll pltbl pnca pncad pncaeps  ///
 pncia pncid pncieps pncip pncwia pncwid pncwieps pncwip pnlbl pnli pnrsho pobl ppcbl  ///
   ppenb ppenc ppenli ppenls ppenme ppennr ppeno  ppevbb ppeveb ppevo ppevr pppabl  ///
 ppphbl pppobl ppptbl prc prca prcad prcaeps prebl pri prodv prsho prstkc prstkcc prstkpc ///
  prvt pstk pstkc pstkl pstkn pstkr pstkrv ptbl ptran pvcl pvo pvon pvpl pvt pwoi radp  ///
 ragr rari rati rca rcd rceps rcl rcp rdip rdipa rdipd rdipeps rdp re rea reajo   ///
 recco recd recta rectr recub ret reuna reunr revt ris rll rlo rlp rlri rlt rmum  ///
 rpag rra rrd rreps rrp rstche rstchelt rvbci rvbpi rvbti rvdo rvdt rveqt rvlrv rvno  ///
 rvnt rvri rvsi rvti rvtxr rvupi rvutx saa sal salepfc salepfp sbdc sc sco scstkc  ///
 secu  seqo seta setd seteps setp siv spce spced spceeps spid spieps spioa spiop  ///
 sppe sppiv spstkc sret srt ssnp sstk stbo stio stkco stkcpa tdc tdscd tdsce tdsg tdslg  ///
 tdsmm tdsng tdso tdss tdst ebit ebitda eiea emol epsfi epsfx epspi epspx esopct esopdlt ///
 esopnr esopr esopt esub esubc excadj fatb fatc fatd exre fate fatl fatn fato xago xagt ///
 xcom xcomi xdepl xdp xeqo  xido  xindb xindc xins xinst  xintd xintopt xivi ///
 xivre xnbi xnf xnins xnitb xobd xoi xopr xoprar xoptd xopteps xore xpp xpr xrdp xrent ///
 xs xt xuw xuwli xuwnli xuwoi xuwrei xuwti exchg prch_c prcl_c adjex_c cshtr_f dvpsp_f ///
 dvpsx_f  prch_f prcl_f adjex_f rank au auop auopic ceoso cfoso add4 ialoi
 
 
 gen year = year(datadate)
 gen month = month(datadate)

 
 destring cik , replace force
 
drop if sale == .
drop if at == . 

drop if at<0
drop if ceq<0
drop if che<0
drop if sale<0

 egen id = group(gvkey)

 cap drop year
 
rename fyear year

xtset id year

 gen tca = -(recch+invch+apalch+txach+aoloch+dpc)/at
 gen cfo = (oancf + xidoc)/at
 gen chg_sales = (sale-l.sale)/at
 gen pped = (ppegt)/at
 
 gen ta = (ib-oancf)/l.at
 gen ppe = (ppegt)/l.at
 gen atinv = 1/at
 gen drevminddrect =( (sale-l.sale) - (rect-l.rect))/l.at
 
 
 gen ln_ta = log(at)
 gen leverage = dltt/l.at
 gen roa=ib/at
 gen ln_mve=ln(prcc_f*csho)
 gen mtb=(abs(prcc_f*csho)+dltt+dlc)/at
 
 cap drop buffer*
 forvalues x=1(1)8{
 gen buffer`x'=l`x'.oancf
 }
 
 egen buf_sd = rowsd(oancf buffer1-buffer8)
 gen sd_cf = buf_sd/at
 
  
 cap drop buffer*
 forvalues x=1(1)8{
 gen buffer`x'=l`x'.sale
 }
 cap drop buf_sd
 egen buf_sd = rowsd(sale buffer1-buffer8)
 drop buffer*
 gen sd_sale = buf_sd/at
 
 gen operating_cycle = ln( 360 / sale / (rect+rect-1)/2 + 360/cogs/(invt+l.invt)/2     )
 
 gen capital_intensity = ppent/l.at
 gen intangibles = (xrd+xad)/sale
 
 replace intangibles = 0 if intangibles == .
 
 gen presence_intan = (intangibles~=0)
 
 gen loss = (ni<0)
 
 drop if year<1989
 keep if year<2002
 foreach var of varlist  tca cfo chg_sales pped ta ppe atinv drevminddrect ///
 ln_ta leverage roa mtb sd_cf sd_sale operating_cycle capital_intensity intangibles {
 winsor `var' , gen(`var'_w) p(0.01)
 }
 
  
 
 destring sic, replace
 
 drop if sic >=4000 & sic<=4999
 drop if sic >=6000 & sic<=6999
 
 ffind sic, newvar(ff48) type(48)
 
 cap  rename fyear year 
xtset id year
 
 reg tca_w l.cfo_w cfo_w f.cfo_w chg_sales_w pped_w
 
 egen count_obs =count(year) if e(sample) == 1, by(ff48 year)
 
 egen reg_id = group(ff48 year) if count_obs>19 & count_obs<.
 
 
 gen b_residual_tca=.
 
 forvalues x = 1(1)602 {
 
 qui cap reg tca_w l.cfo_w cfo_w f.cfo_w chg_sales_w pped_w if reg_id==`x'
  cap drop resi
 qui cap predict resi , residuals
 qui cap replace b_residual_tca=resi if reg_id==`x'
 
 }
 
 
 gen accural_quality = -100 * (abs(b_residual_tca)+abs(l.b_residual_tca))/2
 
 gen b_residual_ta=.

 
 reg ta_w atinv_w drevminddrect_w ppe_w
 
  cap drop count_obs
 egen count_obs =count(year) if e(sample) == 1, by(ff48 year)
 cap drop reg_id
 egen reg_id = group(ff48 year) if count_obs>19 & count_obs<.
 
 
 forvalues x = 1(1)828{
 
 qui cap reg ta_w atinv_w drevminddrect_w ppe_w if reg_id==`x'
  cap drop resi
 qui cap predict resi , residuals
 qui cap replace b_residual_ta=resi if reg_id==`x'
 
 }
 
 
 gen disc_accruals = abs(b_residual_ta)
 
 winsor accural_quality, gen(accural_quality_w) p(0.01)
 winsor disc_accruals, gen(disc_accruals_w) p(0.01)
 
 
gen accruals = (d.act-d.lct-d.ch+d.dd1-dp)/l.at
winsor accruals, gen(accruals_w) p(0.01)

 
 egen buffer =count(cik), by(cik year)

 keep if buffer == 1 | (buffer == 2 & month == 12)
 
 drop buffer
 
 rename year fyear
merge 1:1 cik fyear using "C:\Users\martin.jacob\Dropbox\GJ\data\final\hq_10k.dta"
 
 drop if _m == 2
 

xtset id fyear
 
 forvalues x = 1(1)50{
replace ba_zip5 = ba_zip5[_n+1] if ba_zip5=="" & id == f.id
}

 replace ba_zip5 = substr(addzip,1,5) if ba_zip5==""
 
rename ba_zip5 zip 


/******
pecking order
1) use the actual year
2) if (1) not available, use the most recent 10k based HQ location
3) if (2) is not there, then we use use current address
******/
 
 
 cap drop _m
merge n:1 zip using "C:\Users\martin.jacob\Dropbox\GJ\data\irs audit (TRAC)\zip_fips_dist.dta"

keep if _m == 3

 rename  fyear year

cap drop _m
merge n:1 irsdist year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\audit_rates_per_class.dta"



cap drop code
gen code = .

replace code = 209 if at<=0.25 
replace code = 213 if at>0.25 & at<=1  
replace code = 215 if at>1 & at<=5  
replace code = 217  if at>5 & at<=10  
replace code = 219 if at>10 & at<=50 
replace code = 221 if at>50 & at<=100 
replace code = 223 if at>100 & at<=250  
replace code = 225 if at>250 & at<. 

cap drop _m
merge n:1 irsdist code year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\irs_audit_prob_size.dta"

drop if _m == 2


gen buffer_rate=perc_audited_size

cap drop _m
merge n:1 code year using "C:\Users\martin.jacob\Dropbox\GJ\data\final\corp_audits_post_2000.dta"

drop if _m == 2


egen irs_id = group(irsdist)

replace perc_audited_size  = perc_audit_size /100 if year>2000

egen ind_year = group(ff48 year)

save "C:\Users\martin.jacob\Dropbox\GJ\data\final\information_environment.dta", replace





 
 clear all
 import excel "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\Data for John 1.13.2020\fly_nb_lrc3.xlsx", sheet("Data Unique FYEAR Change") firstrow
 
 rename fyear_change year
 rename len gvkey 
 rename ta high_avoidance
 
 save  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\tax_avoidance_status.dta", replace
 
 
use "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\ggm_nb.dta",clear

rename lender_g gvkey

keep gvkey 

duplicates drop

merge 1:n gvkey using  "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\linking.dta"

keep if _m == 3

keep if rssd ~=""



keep rssd gvkey

merge n:n gvkey using "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\tax_avoidance_status.dta"

keep if _m == 3

keep rssd year high_avoidance
destring rssd, replace

duplicates drop
gen bank_holding = 1

save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\matched_rssds.dta", replace

rename rssd fin_hh_rssd
rename b bank_hold_par
rename high_avoidance high_avoidance_par
save "C:\Users\martin.jacob\Dropbox\Current Projects\GJ\data\GGM\matched_rssds_parent.dta", replace



