
/**construct pac***/


/** principal component analysis ***/
use "C:\Users\yjia\Dropbox\dist\eff_measure_A.dta", clear
/**Table 1 panel B**/
pca wfiling_j pending_j to_time,comp(1)
predict pc2,score
winsor2  wfiling_j pending_j to_time pc2 
 export excel using "C:\Users\yjia\Dropbox\dist\A_effmeasure_final.xlsx", firstrow(variables)


/**Pr(civil action| restatement) Analysis **/

 use "C:\Users\yjia\Dropbox\dist\B_restate_enforcement.dta", clear
 drop if mi(to)
 winsor2 lev  lnat abret log_emp dist2 logage end_file rest_duration  btm ret_sqrt   ws_incomegr ws_unemprate ws_regrate ln_pop vio_rate pro_rate roa count_vio
  gen log_penjing = log( pending_j_w)
  gen log_wfilng = log( wfiling_j_w)
  gen log_dist = log(1+dist2_w)
 
 /**************************************Table 4*********************Table 4***************************************Table 4********************Table 4**************/
 
reghdfe enf   to_time_w  rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue ,a(state office year sic2) vce(cl court)

reghdfe enf   to_time_w  rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue ,a(state office#year sic2) vce(cl court)

reghdfe enf   log_penjing   rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue ,a(state office year sic2) vce(cl court)

reghdfe enf   log_penjing  rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue ,a(state office#year sic2) vce(cl court)

reghdfe enf    log_wfilng rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue ,a(state office year sic2) vce(cl court)

reghdfe enf   log_wfilng rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue ,a(state office#year sic2) vce(cl court)

reghdfe enf    pc2_w rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue ,a(state office year sic2) vce(cl court)

reghdfe enf    pc2_w rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue ,a(state office#year sic2) vce(cl court)

/********************Table 5****************************Table 5**********************************Table 5********************************Table 5********************/
gen low_ret = 1 if  abret_w <-.0132128
replace low_ret = 0 if abret_w >=-.0132128

reghdfe enf    pc2_w rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue if low_ret ==1,a(state office year sic2) vce(cl court)

reghdfe enf    pc2_w rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue if low_ret ==0,a(state office year sic2) vce(cl court)

reghdfe enf    pc2_w rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue if budget_con >= -.0190318 ,a(state office year sic2) vce(cl court)

reghdfe enf    pc2_w rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue if budget_con < -.0190318 ,a(state office year sic2) vce(cl court)


/**f-test***/

tabulate state, generate(state_fe)
tabulate sic2, generate(sic_fe)
tabulate office, generate(off_fe)
tabulate year, generate(yr_fe)

reg enf    pc2_w rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue state_fe* off_fe* yr_fe* sic_fe* if low_ret ==1
est store A
reg enf    pc2_w rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue state_fe* off_fe* yr_fe* sic_fe* if low_ret ~=1
est store B
suest A B,vce(cl court)
test [A_mean]pc2_w =[B_mean]pc2_w



reg enf    pc2_w rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue state_fe* off_fe* yr_fe* sic_fe*  if budget_con >= -.0190318
est store G
reg enf    pc2_w rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue state_fe* off_fe* yr_fe* sic_fe*  if budget_con <-.0190318
est store H
suest G H,vce(cl court)
test [G_mean]pc2_w =[H_mean]pc2_w

/*****************************Table 6***********************************Table 6************************Table 6********************************Table 6******/
replace mean_prop_all2 = 0 if mi(mean_prop_all2 )
gen high_prop = 1 if  mean_prop_all2 >=.0386658
replace high_prop=0 if mean_prop_all2 <.0386658

gen high_prop_vacant = high_prop*vacant_judge

gen low = 1 if number_of_judge  <=7 
replace low = 0 if number_of_judge  >7
gen low_judge= low* vacant_judge


reghdfe enf  vacant_judge rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue,a(state office fyear sic2) vce(cl court)


reghdfe enf  vacant_judge low low_judge rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue ,a(state office fyear sic2) vce(cl court)


reghdfe enf  vacant_judge high_prop high_prop_vacant rest_duration_w rev_reg  count_vio_w abret_w ret_sqrt_w res_adverse end_file_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue if year( file_date)>=2001 ,a(state office fyear sic2) vce(cl court)



/***************************Table 7**********************Table 7**************************************Table 7***********************************Table 7**********************/

use "C:\Users\yjia\Dropbox\dist\D_FRQ_accrual.dta", clear
drop if mi(to)
drop if mi(abnormal_acc)
winsor2  dist2 roa lev lnat  cap_at btm  ws_incomegr ws_unemprate ws_regrate ln_pop vio_rate pro_rate  ppe_at logage abnormal_acc
gen log_dist = log( 1+dist2_w)
drop if fyear==1995
drop if fyear==1994
gen abs_acc = abs(abnormal_acc_w)
new_avg_pc2_w  = new_avg_pc2_w /10

/**column 1**/
reghdfe abs_acc new_avg_pc2_w  lnat_w btm_w  lev_w loss big_four roa_w cap_at_w  logage_w log_dist   ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue, a(sic2 year) vce(cl gvkey)


/**column 3-4**/
reghdfe abs_acc new_avg_pc2_w lnat_w btm_w  lev_w loss big_four roa_w cap_at_w  logage_w log_dist  ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue if (ca_prop <=  .0064935   )  , a(sic2 year) vce(cl gvkey)


reghdfe abs_acc new_avg_pc2_w lnat_w btm_w  lev_w loss big_four roa_w cap_at_w  logage_w log_dist  ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue if (ca_prop >  .0064935   )  , a(sic2 year) vce(cl gvkey)

/**column 5-6**/
reghdfe abs_acc new_avg_pc2_w lnat_w btm_w  lev_w loss big_four roa_w cap_at_w  logage_w log_dist  ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue if (lib_prop <=0.5      )  , a(sic2 year) vce(cl gvkey)


reghdfe abs_acc new_avg_pc2_w lnat_w btm_w  lev_w loss big_four roa_w cap_at_w  logage_w log_dist  ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue if (lib_prop >0.5      )  , a(sic2 year) vce(cl gvkey)


/***F test****/
tabulate sic2, generate(sic_fe)
tabulate year, generate(yr_fe)


reg abs_acc new_avg_pc2_w lnat_w btm_w  lev_w loss big_four roa_w cap_at_w  logage_w log_dist   ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue sic_fe* yr_fe* if ca_prop <=  .0064935  
est store A

reg abs_acc new_avg_pc2_w lnat_w btm_w  lev_w loss big_four roa_w cap_at_w  logage_w log_dist   ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue sic_fe* yr_fe* if ca_prop >  .0064935 
est store B

suest A B,vce(cl gvkey)
test [A_mean]new_avg_pc2_w =[B_mean]new_avg_pc2_w

reg abs_acc new_avg_pc2_w lnat_w btm_w  lev_w loss big_four roa_w cap_at_w  logage_w log_dist  ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue sic_fe* yr_fe* if lib_prop <= .5  
est store C

reg abs_acc new_avg_pc2_w lnat_w btm_w  lev_w loss big_four roa_w cap_at_w  logage_w log_dist   ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue sic_fe* yr_fe* if lib_prop > .5 
est store D

suest C D,vce(cl gvkey)
test [C_mean]new_avg_pc2_w =[D_mean]new_avg_pc2_w

/**************ICW (column 2)*************/
use "C:\Users\yjia\Dropbox\dist\D_FRQ_ICW.dta", clear
drop if year==2002
drop if year==2003
drop if year==2004
drop if mi(to)
drop if mi(abnormal_acc)
winsor2  dist2 roa lev lnat  cap_at btm  ws_incomegr ws_unemprate ws_regrate ln_pop vio_rate pro_rate  ppe_at logage abnormal_acc
gen log_dist = log( 1+dist2_w)
reghdfe icw new_avg_pc2_w lnat_w btm_w  lev_w loss big_four roa_w cap_at_w  logage_w log_dist   ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue , a(sic2 year) vce(cl gvkey)


/***************Table 8***********************Table 8************************************************Table 8************************************************************/
use "C:\Users\yjia\Dropbox\dist\E_latefilng.dta", clear
 drop if mi(to)
 winsor2 lev  lnat abret_m ret_m_sqrt log_emp dist2 logage btm ws_incomegr ws_unemprate ws_regrate ln_pop vio_rate pro_rate roa   
 gen log_dist = log(1+dist2_w)
  
reghdfe enf    pc2_w log_num abret_m_w ret_m_sqrt_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue,a(state office year sic2) vce(cl court)
outreg2 using table4_pur.xls, alpha(0.01, 0.05, 0.1) symbol(***, **, *) dec(3) tstat adj replace
reghdfe enf    pc2_w log_num abret_m_w ret_m_sqrt_w lnat_w logage_w  btm_w small loss log_emp_w  lev_w big_four roa_w log_dist ws_incomegr_w ws_unemprate_w ws_regrate_w ln_pop_w pro_rate_w vio_rate_w blue,a(state office#year sic2) vce(cl court)
outreg2 using table4_pur.xls, alpha(0.01, 0.05, 0.1) symbol(***, **, *) dec(3) tstat adj append



