set more off

cd "C:\Users\yostb\Dropbox\KVY - work folder"

************************************************************************************************************************
*** Step 9: Filter out deals and time periods during the merger window that will not be included in the final sample ***
************************************************************************************************************************
use "data/kvy_cash.dta", clear

drop if failed_deal == 1
keep if period == 1 | period == 2 | period == 4
drop if deal_value_dollars < 10 | deal_value_dollars == . 
drop if attitude == "Hostile"
drop if num_bidders > 1
drop if date_tender_offer ~= . 
egen sum_ntotal_pr = total(ntotal_pr), by(deal_num)
drop if sum_ntotal_pr <= 5

gen year = year(crspdate)
gen quarter = quarter(crspdate)
gen year_qtr = year*10 + quarter

gen neg = 1 if period == 2
replace neg = 0 if period == 1 | period == 4

gen post = 1 if period == 4
replace post = 0 if period == 1 | period == 2

save bidder_disc_temp1.dta, replace


*************************************************************************************************************************
*** Step 10: Construct Factiva Tone disclosure proxies (Factiva Tone-Sentiment, Factiva Tone-CAR, Factiva Tone-Index) *** 
*************************************************************************************************************************
*** Create Factiva Tone-Sentiment based on positive and negative word counts ***
use bidder_disc_temp1.dta, clear

gen wordcount_day = pr_pos_wordcount_day + pr_neg_wordcount_day
gen pr_pn_wordcount_day = pr_pos_wordcount_day - pr_neg_wordcount_day

egen pr_pos_wordaverage_day = mean(pr_pos_wordcount_day)
egen pr_neg_wordaverage_day = mean(pr_neg_wordcount_day)
egen pr_pn_wordaverage_day = mean(pr_pn_wordcount_day)

gen pr_positive_ind = 1 if pr_pn_wordcount_day > pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_positive_ind = 0 if pr_positive_ind == . 

gen pr_negative_ind = 1 if pr_pn_wordcount_day < pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_negative_ind = 0 if pr_negative_ind == . 

gen pr_pn_ind = 1 if pr_pn_wordcount_day > pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_pn_ind = -1 if pr_pn_wordcount_day < pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_pn_ind = 0 if pr_pn_ind == . 

*** Create Factiva Tone-CAR based on acquirer returns on disclosure days ***
gen ret_positive_ind = 1 if bid_car_3d_vw > 0 & ntotal_pr ~= 0
replace ret_positive_ind = 0 if ret_positive_ind == . 

gen ret_negative_ind = 1 if bid_car_3d_vw < 0 & ntotal_pr ~= 0
replace ret_negative_ind = 0 if ret_negative_ind == . 

gen ret_pn_ind = 1 if bid_car_3d_vw > 0 & ntotal_pr ~= 0
replace ret_pn_ind = -1 if bid_car_3d_vw < 0 & ntotal_pr ~= 0
replace ret_pn_ind = 0 if ret_pn_ind == . 

*** Create Factiva Tone-Index by combining Factiva Tone-Sentiment and Factiva Tone-CAR ***
gen pc1_pn = pr_pn_ind + ret_pn_ind
gen pc1_pos = pr_positive_ind + ret_positive_ind
gen pc1_neg = pr_negative_ind + ret_negative_ind

replace pc1_pn = pc1_pn / 2
replace pc1_pos = pc1_pos / 2
replace pc1_neg = pc1_neg / 2

*** Create Macro Content variable based on the number of "macro" words in Factiva articles ***
egen pr_macro_wordaverage_day = mean(pr_macro_wordcount_day)

gen pr_macro_ind = 1 if pr_macro_wordcount_day > pr_macro_wordaverage_day & pr_macro_wordcount_day ~= . 
replace pr_macro_ind = -1 if pr_macro_wordcount_day < pr_macro_wordaverage_day & pr_macro_wordcount_day ~= . 
replace pr_macro_ind = 0 if pr_macro_ind == . 

save bidder_disc_temp2.dta, replace


*******************************************************************************
*** Step 11: Construct Returns Spillover proxy in ranked form and by groups ***
*******************************************************************************
*** Create ranks ***
use bidder_disc_temp2.dta, clear

winsor2 corr_s, replace cuts(1 99)

egen ret_corr_rank = xtile(corr_s), n(5)
replace ret_corr_rank = (ret_corr_rank - 3) / 4
gen neg_ret_corr_rank = neg * ret_corr_rank
gen post_ret_corr_rank = post * ret_corr_rank

gen abs_ret_corr = abs(corr_s)
egen abs_ret_corr_rank = xtile(abs_ret_corr), n(5)
replace abs_ret_corr_rank = (abs_ret_corr_rank - 3) / 4

save bidder_disc_rank.dta, replace

*** Create std dev for spillover measure distributions ***
use bidder_disc_rank.dta, clear
collapse (sd) corr_s
gen ret_corr_std = corr_s
gen dum = 1
save bidder_disc_ret_std.dta, replace

*** Create positive/negative spillover groups ***
use bidder_disc_rank.dta, clear
gen dum = 1
sort deal_num neg
merge m:1 dum using bidder_disc_ret_std.dta
drop _merge

gen ret_pos = 1 if corr_s >= 0 + (ret_corr_std * 0.5)
replace ret_pos = 0 if ret_pos == . 

gen ret_neg = 1 if corr_s <= 0 - (ret_corr_std * 0.5)
replace ret_neg = 0 if ret_neg == . 

gen neg_ret_pos = neg * ret_pos
gen neg_ret_neg = neg * ret_neg

gen post_ret_pos = post * ret_pos
gen post_ret_neg = post * ret_neg

save bidder_disc_temp3.dta, replace


********************************************************************************************************************************
*** Step 12: Construct winsorized, centered, and interacted control variables for final dataset to be used in Tables 3 and 4 ***
********************************************************************************************************************************
use bidder_disc_temp3.dta, clear

winsor2 target_btm target_roa target_log_firm_age target_ret_1yr acquirer_btm rel_size, replace cuts(1 99)

center target_btm target_roa target_log_firm_age target_ret_1yr acquirer_btm rel_size, replace

gen neg_target_btm = neg * c_target_btm
gen neg_target_roa = neg * c_target_roa
gen neg_target_log_firm_age = neg * c_target_log_firm_age
gen neg_target_ret_1yr = neg * c_target_ret_1yr
gen neg_acquirer_btm = neg * c_acquirer_btm
gen neg_rel_size = neg * c_rel_size
gen neg_horizontal_merger = neg * horizontal_merger
gen neg_vertical_merger = neg * vertical_merger
gen neg_vertical_forward = neg * vertical_forward
gen neg_vertical_backward = neg * vertical_backward

gen post_target_btm = post * c_target_btm
gen post_target_roa = post * c_target_roa
gen post_target_log_firm_age = post * c_target_log_firm_age
gen post_target_ret_1yr = post * c_target_ret_1yr
gen post_acquirer_btm = post * c_acquirer_btm
gen post_rel_size = post * c_rel_size
gen post_horizontal_merger = post * horizontal_merger
gen post_vertical_merger = post * vertical_merger
gen post_vertical_forward = post * vertical_forward
gen post_vertical_backward = post * vertical_backward

keep if period == 1 | period == 2

save bidder_disc.dta, replace



set more off

cd "C:\Users\yostb\Dropbox\KVY - work folder"

************************************************************************************************************************
*** Step 9: Filter out deals and time periods during the merger window that will not be included in the final sample ***
************************************************************************************************************************
use "data/kvy_cash.dta", clear

drop if failed_deal == 1
keep if period == 1 | period == 2 | period == 4
drop if deal_value_dollars < 10 | deal_value_dollars == . 
drop if attitude == "Hostile"
drop if num_bidders > 1
drop if date_tender_offer ~= . 
egen sum_ntotal_pr = total(ntotal_pr), by(deal_num)
drop if sum_ntotal_pr <= 5

gen year = year(crspdate)
gen quarter = quarter(crspdate)
gen year_qtr = year*10 + quarter

gen neg = 1 if period == 2
replace neg = 0 if period == 1 | period == 4

gen post = 1 if period == 4
replace post = 0 if period == 1 | period == 2

save bidder_disc_temp1.dta, replace


*************************************************************************************************************************
*** Step 10: Construct Factiva Tone disclosure proxies (Factiva Tone-Sentiment, Factiva Tone-CAR, Factiva Tone-Index) *** 
*************************************************************************************************************************
*** Create Factiva Tone-Sentiment based on positive and negative word counts ***
use bidder_disc_temp1.dta, clear

gen wordcount_day = pr_pos_wordcount_day + pr_neg_wordcount_day
gen pr_pn_wordcount_day = pr_pos_wordcount_day - pr_neg_wordcount_day

egen pr_pos_wordaverage_day = mean(pr_pos_wordcount_day)
egen pr_neg_wordaverage_day = mean(pr_neg_wordcount_day)
egen pr_pn_wordaverage_day = mean(pr_pn_wordcount_day)

gen pr_positive_ind = 1 if pr_pn_wordcount_day > pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_positive_ind = 0 if pr_positive_ind == . 

gen pr_negative_ind = 1 if pr_pn_wordcount_day < pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_negative_ind = 0 if pr_negative_ind == . 

gen pr_pn_ind = 1 if pr_pn_wordcount_day > pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_pn_ind = -1 if pr_pn_wordcount_day < pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_pn_ind = 0 if pr_pn_ind == . 

*** Create Factiva Tone-CAR based on acquirer returns on disclosure days ***
gen ret_positive_ind = 1 if bid_car_3d_vw > 0 & ntotal_pr ~= 0
replace ret_positive_ind = 0 if ret_positive_ind == . 

gen ret_negative_ind = 1 if bid_car_3d_vw < 0 & ntotal_pr ~= 0
replace ret_negative_ind = 0 if ret_negative_ind == . 

gen ret_pn_ind = 1 if bid_car_3d_vw > 0 & ntotal_pr ~= 0
replace ret_pn_ind = -1 if bid_car_3d_vw < 0 & ntotal_pr ~= 0
replace ret_pn_ind = 0 if ret_pn_ind == . 

*** Create Factiva Tone-Index by combining Factiva Tone-Sentiment and Factiva Tone-CAR ***
gen pc1_pn = pr_pn_ind + ret_pn_ind
gen pc1_pos = pr_positive_ind + ret_positive_ind
gen pc1_neg = pr_negative_ind + ret_negative_ind

replace pc1_pn = pc1_pn / 2
replace pc1_pos = pc1_pos / 2
replace pc1_neg = pc1_neg / 2

*** Create Macro Content variable based on the number of "macro" words in Factiva articles ***
egen pr_macro_wordaverage_day = mean(pr_macro_wordcount_day)

gen pr_macro_ind = 1 if pr_macro_wordcount_day > pr_macro_wordaverage_day & pr_macro_wordcount_day ~= . 
replace pr_macro_ind = -1 if pr_macro_wordcount_day < pr_macro_wordaverage_day & pr_macro_wordcount_day ~= . 
replace pr_macro_ind = 0 if pr_macro_ind == . 

save bidder_disc_temp2.dta, replace


*******************************************************************************
*** Step 11: Construct Returns Spillover proxy in ranked form and by groups ***
*******************************************************************************
*** Create ranks ***
use bidder_disc_temp2.dta, clear

winsor2 corr_s, replace cuts(1 99)

egen ret_corr_rank = xtile(corr_s), n(5)
replace ret_corr_rank = (ret_corr_rank - 3) / 4
gen neg_ret_corr_rank = neg * ret_corr_rank
gen post_ret_corr_rank = post * ret_corr_rank

gen abs_ret_corr = abs(corr_s)
egen abs_ret_corr_rank = xtile(abs_ret_corr), n(5)
replace abs_ret_corr_rank = (abs_ret_corr_rank - 3) / 4

save bidder_disc_rank.dta, replace

*** Create std dev for spillover measure distributions ***
use bidder_disc_rank.dta, clear
collapse (sd) corr_s
gen ret_corr_std = corr_s
gen dum = 1
save bidder_disc_ret_std.dta, replace

*** Create positive/negative spillover groups ***
use bidder_disc_rank.dta, clear
gen dum = 1
sort deal_num neg
merge m:1 dum using bidder_disc_ret_std.dta
drop _merge

gen ret_pos = 1 if corr_s >= 0 + (ret_corr_std * 0.5)
replace ret_pos = 0 if ret_pos == . 

gen ret_neg = 1 if corr_s <= 0 - (ret_corr_std * 0.5)
replace ret_neg = 0 if ret_neg == . 

gen neg_ret_pos = neg * ret_pos
gen neg_ret_neg = neg * ret_neg

gen post_ret_pos = post * ret_pos
gen post_ret_neg = post * ret_neg

save bidder_disc_temp3.dta, replace


********************************************************************************************************************************
*** Step 12: Construct winsorized, centered, and interacted control variables for final dataset to be used in Tables 3 and 4 ***
********************************************************************************************************************************
use bidder_disc_temp3.dta, clear

winsor2 target_btm target_roa target_log_firm_age target_ret_1yr acquirer_btm rel_size, replace cuts(1 99)

center target_btm target_roa target_log_firm_age target_ret_1yr acquirer_btm rel_size, replace

gen neg_target_btm = neg * c_target_btm
gen neg_target_roa = neg * c_target_roa
gen neg_target_log_firm_age = neg * c_target_log_firm_age
gen neg_target_ret_1yr = neg * c_target_ret_1yr
gen neg_acquirer_btm = neg * c_acquirer_btm
gen neg_rel_size = neg * c_rel_size
gen neg_horizontal_merger = neg * horizontal_merger
gen neg_vertical_merger = neg * vertical_merger
gen neg_vertical_forward = neg * vertical_forward
gen neg_vertical_backward = neg * vertical_backward

gen post_target_btm = post * c_target_btm
gen post_target_roa = post * c_target_roa
gen post_target_log_firm_age = post * c_target_log_firm_age
gen post_target_ret_1yr = post * c_target_ret_1yr
gen post_acquirer_btm = post * c_acquirer_btm
gen post_rel_size = post * c_rel_size
gen post_horizontal_merger = post * horizontal_merger
gen post_vertical_merger = post * vertical_merger
gen post_vertical_forward = post * vertical_forward
gen post_vertical_backward = post * vertical_backward

keep if period == 1 | period == 2

save bidder_disc.dta, replace



set more off

cd "C:\Users\yostb\Dropbox\KVY - work folder"

************************************************************************************************************************
*** Step 9: Filter out deals and time periods during the merger window that will not be included in the final sample ***
************************************************************************************************************************
use "data/kvy_cash.dta", clear

drop if failed_deal == 1
keep if period == 1 | period == 2 | period == 4
drop if deal_value_dollars < 10 | deal_value_dollars == . 
drop if attitude == "Hostile"
drop if num_bidders > 1
drop if date_tender_offer ~= . 
egen sum_ntotal_pr = total(ntotal_pr), by(deal_num)
drop if sum_ntotal_pr <= 5

gen year = year(crspdate)
gen quarter = quarter(crspdate)
gen year_qtr = year*10 + quarter

gen neg = 1 if period == 2
replace neg = 0 if period == 1 | period == 4

gen post = 1 if period == 4
replace post = 0 if period == 1 | period == 2

save bidder_disc_temp1.dta, replace


*************************************************************************************************************************
*** Step 10: Construct Factiva Tone disclosure proxies (Factiva Tone-Sentiment, Factiva Tone-CAR, Factiva Tone-Index) *** 
*************************************************************************************************************************
*** Create Factiva Tone-Sentiment based on positive and negative word counts ***
use bidder_disc_temp1.dta, clear

gen wordcount_day = pr_pos_wordcount_day + pr_neg_wordcount_day
gen pr_pn_wordcount_day = pr_pos_wordcount_day - pr_neg_wordcount_day

egen pr_pos_wordaverage_day = mean(pr_pos_wordcount_day)
egen pr_neg_wordaverage_day = mean(pr_neg_wordcount_day)
egen pr_pn_wordaverage_day = mean(pr_pn_wordcount_day)

gen pr_positive_ind = 1 if pr_pn_wordcount_day > pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_positive_ind = 0 if pr_positive_ind == . 

gen pr_negative_ind = 1 if pr_pn_wordcount_day < pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_negative_ind = 0 if pr_negative_ind == . 

gen pr_pn_ind = 1 if pr_pn_wordcount_day > pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_pn_ind = -1 if pr_pn_wordcount_day < pr_pn_wordaverage_day & pr_pn_wordcount_day ~= . 
replace pr_pn_ind = 0 if pr_pn_ind == . 

*** Create Factiva Tone-CAR based on acquirer returns on disclosure days ***
gen ret_positive_ind = 1 if bid_car_3d_vw > 0 & ntotal_pr ~= 0
replace ret_positive_ind = 0 if ret_positive_ind == . 

gen ret_negative_ind = 1 if bid_car_3d_vw < 0 & ntotal_pr ~= 0
replace ret_negative_ind = 0 if ret_negative_ind == . 

gen ret_pn_ind = 1 if bid_car_3d_vw > 0 & ntotal_pr ~= 0
replace ret_pn_ind = -1 if bid_car_3d_vw < 0 & ntotal_pr ~= 0
replace ret_pn_ind = 0 if ret_pn_ind == . 

*** Create Factiva Tone-Index by combining Factiva Tone-Sentiment and Factiva Tone-CAR ***
gen pc1_pn = pr_pn_ind + ret_pn_ind
gen pc1_pos = pr_positive_ind + ret_positive_ind
gen pc1_neg = pr_negative_ind + ret_negative_ind

replace pc1_pn = pc1_pn / 2
replace pc1_pos = pc1_pos / 2
replace pc1_neg = pc1_neg / 2

*** Create Macro Content variable based on the number of "macro" words in Factiva articles ***
egen pr_macro_wordaverage_day = mean(pr_macro_wordcount_day)

gen pr_macro_ind = 1 if pr_macro_wordcount_day > pr_macro_wordaverage_day & pr_macro_wordcount_day ~= . 
replace pr_macro_ind = -1 if pr_macro_wordcount_day < pr_macro_wordaverage_day & pr_macro_wordcount_day ~= . 
replace pr_macro_ind = 0 if pr_macro_ind == . 

save bidder_disc_temp2.dta, replace


*******************************************************************************
*** Step 11: Construct Returns Spillover proxy in ranked form and by groups ***
*******************************************************************************
*** Create ranks ***
use bidder_disc_temp2.dta, clear

winsor2 corr_s, replace cuts(1 99)

egen ret_corr_rank = xtile(corr_s), n(5)
replace ret_corr_rank = (ret_corr_rank - 3) / 4
gen neg_ret_corr_rank = neg * ret_corr_rank
gen post_ret_corr_rank = post * ret_corr_rank

gen abs_ret_corr = abs(corr_s)
egen abs_ret_corr_rank = xtile(abs_ret_corr), n(5)
replace abs_ret_corr_rank = (abs_ret_corr_rank - 3) / 4

save bidder_disc_rank.dta, replace

*** Create std dev for spillover measure distributions ***
use bidder_disc_rank.dta, clear
collapse (sd) corr_s
gen ret_corr_std = corr_s
gen dum = 1
save bidder_disc_ret_std.dta, replace

*** Create positive/negative spillover groups ***
use bidder_disc_rank.dta, clear
gen dum = 1
sort deal_num neg
merge m:1 dum using bidder_disc_ret_std.dta
drop _merge

gen ret_pos = 1 if corr_s >= 0 + (ret_corr_std * 0.5)
replace ret_pos = 0 if ret_pos == . 

gen ret_neg = 1 if corr_s <= 0 - (ret_corr_std * 0.5)
replace ret_neg = 0 if ret_neg == . 

gen neg_ret_pos = neg * ret_pos
gen neg_ret_neg = neg * ret_neg

gen post_ret_pos = post * ret_pos
gen post_ret_neg = post * ret_neg

save bidder_disc_temp3.dta, replace


********************************************************************************************************************************
*** Step 12: Construct winsorized, centered, and interacted control variables for final dataset to be used in Tables 3 and 4 ***
********************************************************************************************************************************
use bidder_disc_temp3.dta, clear

winsor2 target_btm target_roa target_log_firm_age target_ret_1yr acquirer_btm rel_size, replace cuts(1 99)

center target_btm target_roa target_log_firm_age target_ret_1yr acquirer_btm rel_size, replace

gen neg_target_btm = neg * c_target_btm
gen neg_target_roa = neg * c_target_roa
gen neg_target_log_firm_age = neg * c_target_log_firm_age
gen neg_target_ret_1yr = neg * c_target_ret_1yr
gen neg_acquirer_btm = neg * c_acquirer_btm
gen neg_rel_size = neg * c_rel_size
gen neg_horizontal_merger = neg * horizontal_merger
gen neg_vertical_merger = neg * vertical_merger
gen neg_vertical_forward = neg * vertical_forward
gen neg_vertical_backward = neg * vertical_backward

gen post_target_btm = post * c_target_btm
gen post_target_roa = post * c_target_roa
gen post_target_log_firm_age = post * c_target_log_firm_age
gen post_target_ret_1yr = post * c_target_ret_1yr
gen post_acquirer_btm = post * c_acquirer_btm
gen post_rel_size = post * c_rel_size
gen post_horizontal_merger = post * horizontal_merger
gen post_vertical_merger = post * vertical_merger
gen post_vertical_forward = post * vertical_forward
gen post_vertical_backward = post * vertical_backward

keep if period == 1 | period == 2

save bidder_disc.dta, replace




