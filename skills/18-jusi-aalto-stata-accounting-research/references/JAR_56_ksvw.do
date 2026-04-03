set memory 4096M
set matsize 5000

set more off
cd "C:\My_Works\Research_1\CDS_Information_Environment\Data\Results"

set seed 123456
gen u=uniform()
sort u

*Main tests
*Table 2: Main Test
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta", clear  

* Panel A
xi:reg d_mf1 cds cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)

xi:reg log_num_mf1_w cds cds_traded log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear, cluster(gvkey)

* Panel B
xi: reg d_mf1 cds cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if fyear > 2001, cluster(gvkey)

xi: reg log_num_mf1_w cds cds_traded log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if  fyear > 2001, cluster(gvkey)


*Table 3: Cross-sectional test: ease of hedging by lenderst & Extent of Lender Monitoring
*Panel A: CDS Liquidity & Credit Derivative Protection
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta", clear  

*(1) CDS Liquidity
xi:reg d_mf1 low_cds_1 high_cds_1  cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_cds_1 = high_cds_1

xi:reg log_num_mf1_w low_cds_1 high_cds_1  cds_traded  log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_cds_1 = high_cds_1

xi:reg d_mf1 low_cds_2 high_cds_2  cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_cds_2 = high_cds_2

*(2) Credit Derivative Protection
xi:reg log_num_mf1_w low_cds_2 high_cds_2  cds_traded  log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_cds_2 = high_cds_2

xi:reg d_mf1 low_rel_cds_protect high_rel_cds_protect cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_rel_cds_protect = high_rel_cds_protect

xi:reg log_num_mf1_w low_rel_cds_protect high_rel_cds_protect cds_traded log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear , cluster(gvkey)
test low_rel_cds_protect = high_rel_cds_protect

*Panel B: Extent of Lender Monitoring (above/below median)
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta", clear  

*(1): Bank Allocation
xi:reg d_mf1 cds cds_h2_bksh h2_bksh cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear, cluster(gvkey)

xi:reg log_num_mf1_w cds cds_h2_bksh h2_bksh cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear, cluster(gvkey)

*(2): financial covenant
xi:reg d_mf1 cds cds_h2_fincov h2_fincov cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear, cluster(gvkey)

xi:reg log_num_mf1_w cds cds_h2_fincov h2_fincov cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w i.fyear, cluster(gvkey)

*(3): distress risk
xi:reg d_mf1 cds cds_h2_lag_leverage h2_lag_leverage cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore i.fyear , cluster(gvkey)

xi:reg log_num_mf1_w cds cds_h2_lag_leverage h2_lag_leverage cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore i.fyear  , cluster(gvkey)


*Table 4: Equityholders' Demand above/below median)
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta", clear  

*(1): strong board: borad independence
xi:reg d_mf1 cds cds_high_bd high_bd cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear , cluster(gvkey)

xi:reg log_num_mf1 cds cds_high_bd high_bd cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear , cluster(gvkey)

*(2)  High Institutions & No blocking holders
xi:reg d_mf1 cds cds_comb_ins_blk_2 comb_ins_blk_2 cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w  i.fyear, cluster(gvkey)

xi:reg log_num_mf1_w cds cds_comb_ins_blk_2 comb_ins_blk_2 cds_traded log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit  mid_zscore lag_leverage_w i.fyear, cluster(gvkey)


*Table 5: Interaction of Lender monitoring intensity and shareholder' information demand
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_1_ver_2017_11.dta", clear  

*(1) high cds liquidity & high institutional ownership (no block) & low lead lenders' share;
xi: reg d_mf1 cds_other_1 cds_low_all_1 cds_high_all_1   cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if high_all_1_miss == 0, cluster(gvkey)
test cds_high_all_1 = cds_low_all_1

xi:reg log_num_mf1_w  cds_other_1 cds_low_all_1 cds_high_all_1   cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if high_all_1_miss == 0, cluster(gvkey)
test cds_high_all_1 = cds_low_all_1

*(2) high cds liquidity & high institutional ownership (no block) & low financial covenants;
xi: reg d_mf1 cds_other_2 cds_low_all_2 cds_high_all_2   cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if high_all_2_miss == 0, cluster(gvkey)
test cds_high_all_2 = cds_low_all_2

xi:reg log_num_mf1_w  cds_other_2 cds_low_all_2 cds_high_all_2   cds_traded   log_at_w lag_mtb_w roa_w inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w i.fyear if high_all_2_miss == 0, cluster(gvkey)
test cds_high_all_2 = cds_low_all_2


*Table 6: Endogeneity - 1: PSM for CDS Initiation using 5year period around CDS initation
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_2_ver_2017_11.dta", clear

set seed 123456
gen u=uniform()
sort u

*first stage (
xi: probit cds_initiation pre_rated pre_inv_grade pre_leverage_w pre_profit_margin_w pre_log_ta_w pre_ret_volatility_w pre_mtb_w , cluster(gvkey)
predict pscore if e(sample), pr

egen year_dind = group(year_cds_match)
gen pscore2=year_dind*100+pscore

drop if cds_traded == 1 & cds_year != first_cds_year

table cds_initiation if cds_traded  == 1
table cds_initiation if cds_traded  == 0

sort u

psmatch2 cds_initiation , pscore(pscore2) neighbor(3) 

#d;
keep u pscore pscore2 _pscore _weight _id _n1 _n2 _n3 _nn _pdif 
       cds_initiation gvkey datadate fyear cds cds_year first_cds_year cds_traded cds_first_date year_cds_match
	   pre_rated pre_inv_grade pre_leverage_w pre_profit_margin_w pre_log_ta_w pre_ret_volatility_w pre_mtb_w;
#d cr;

export sasxport "C:\My_Works\Research_1\CDS_Information_Environment\Data\psm_1st.xpt", rename replace vallabfile(none)

*second stage model;
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_3_ver_2017_11.dta", clear
xi:reg log_num_mf1_w psm_cds post psm_cds_post log_at_w lag_mtb_w roa_w  inst_own_w log_following_w rvol_w eq_iss lit mid_zscore lag_leverage_w post_fd , cluster(gvkey)


*Table 7: Endogeneity - 2: Change analysis for CDS Initiation;
use "C:\My_Works\Research_1\CDS_Information_Environment\Data\data_4_ver_2017_11.dta", clear

*Panel A: change test
xi: reg chg_log_num_mf1_w chg_cds chg_log_at_w chg_lag_mtb_w chg_roa_w chg_inst_own_w chg_log_following_w chg_rvol_w chg_eq_iss lit chg_mid_zscore lagchg_leverage_w log_lag_num_mf1_w  i.fyear, cluster(gvkey)

*Panel B: Reverse Casaulity: OLS for cds initaiton 
xi: reg chg_cds pre_chg_log_num_mf1_w log_lag_num_mf1_w chg_log_at_w chg_lag_mtb_w chg_roa_w chg_inst_own_w chg_log_following_w chg_rvol_w chg_eq_iss lit chg_mid_zscore lagchg_leverage_w i.fyear, cluster(gvkey)
