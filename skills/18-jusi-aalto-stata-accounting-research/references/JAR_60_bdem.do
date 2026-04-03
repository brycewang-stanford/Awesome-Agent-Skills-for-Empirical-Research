********************************************************************************
** BDEM_2_Add_Var_Creation - creation of additional variables for final analyses 												
********************************************************************************

********************************************************************************
** 1. Read in dataset (from SAS) - 3,349 attempted ICOs 
********************************************************************************

use dataset_merged_all_test, clear /*Read in dataset of 3,349 ICOs */

********************************************************************************
** 2. Create / re-label (additional) variables used in main empirical analysis  
********************************************************************************

**** 2A. White paper disclosure variables *****

	*** Create log page count and standardized measure of white paper length
	gen ln_wp_page_count = log(wp_page_count)
	sum wp_page_count, d
	gen wp_norm = (wp_page_count - `r(min)') / (`r(max)'-`r(min)')
	label var wp_norm "Whitepaper Length"
	label var ln_wp_page_count "Whitepaper Length" 

	*** Create combined github/sourcecode indicator variable
	gen github_sourcecode = 1 if sourcecode_ind==1 | github_benchy==1   
	replace github_sourcecode = 0 if github_sourcecode==.
	label var github_sourcecode "Sourcecode Disclosure"

	*** Create technical white paper indicator variable
	gen wp_tech_whitepaper = wp_LaTex
	replace wp_tech_whitepaper = 0 if wp_LaTex==. & wp_page_count!=.
	label var wp_tech_whitepaper "Technical Whitepaper"
		
	*** Create white paper vesting disclosures indicator variable
	gen wp_vesting_ind = 1 if wp_min_Vesting_months>0 & wp_min_Vesting_months!=.
	replace wp_vesting_ind = 0 if wp_min_Vesting_months ==0
	replace wp_vesting_ind = 0 if (wp_min_Vesting_months == . & wp_Div_Dist!=.)
	label var wp_vesting_ind "Token Vesting Disclosure"	

	replace wp_min_Vesting_months=0 if (wp_Div_Dist!=. & wp_min_Vesting_months==.)
	gen wp_vesting_mths = wp_min_Vesting_months
	replace wp_vesting_mths = 0 if (wp_min_Vesting_months ==. & wp_Div_Dist!=.)
	label var wp_vesting_mths "FTAP min vesting (in mths)"
	
	*** Create insider tokens disclosure indicator variable
	gen wp_token_dist_ftap_ind = 1 if( wp_token_dist_FTAP>=0 & wp_Div_Dist!=.)
	replace wp_token_dist_ftap_ind = 0 if (wp_token_dist_FTAP==. & wp_Div_Dist!=.)
	label var wp_token_dist_ftap_ind "Insider Tokens Disclosure"
		
	*** Create use of proceeds disclosure indicator variable 
	replace wp_UOP = 1 if (wp_prod_development_allocation!=. | wp_marketing_allocation!=.)
	replace wp_UOP = 0 if (wp_UOP==. & wp_Div_Dist!=.)
	label var wp_UOP "Use of Proceeds"

	*** Create team identity to indicator (note: team_identity var measure % of ICO team members identified) 
	replace team_identity = 1 if (team_identity>0.25) & team_identity!=.
	replace team_identity = 0 if (team_identity<=0.25) & team_identity!=.
	label var team_identity "ICO Team Identity Disclosures"
		
	*** Create social media presence indicator variable
	gen social_media_presence = 1 if twitter_indicator==1 | telegram_indicator==1
	replace social_media_presence = 0 if social_media_presence == . 
	label var social_media_presence "Social Media Presence"

	** Generate Disclosure Index
	gen tdisc = (wp_UOP + wp_norm + github_sourcecode + wp_tech_whitepaper + wp_product_roadmap_info + team_identity + wp_token_dist_ftap_ind + wp_vesting_ind + video_presentation + social_media_presence) 
	egen tdisc_r = xtile(tdisc), n(10)
	sum tdisc_r, d
	gen tdisc_norm = (tdisc_r - `r(min)') / (`r(max)'-`r(min)')
	label var tdisc_norm "Disclosure Index"


	** Generate Disclosure Index (without vesting & insider tokens disclosure - for cross-sectional tests)
	gen tdisc3 = (wp_UOP + wp_norm + github_sourcecode + wp_tech_whitepaper + wp_product_roadmap_info + team_identity + video_presentation + social_media_presence) 
	egen tdisc3_r = xtile(tdisc3), n(10)
	sum tdisc3_r, d
	gen tdisc3_norm = (tdisc3_r - `r(min)') / (`r(max)'-`r(min)')
	label var tdisc3_norm "Disclosure Index - exc. FTAP & vesting"

	** Prinicpal Components of Disclosure measures
	pca wp_UOP wp_norm github_sourcecode wp_tech_whitepaper wp_product_roadmap_info team_identity wp_token_dist_ftap_ind  wp_vesting_ind video_presentation social_media_presence, mineigen(1) 
	predict pc1 pc2
	sum pc1, d
	label var pc1 "Disclosure PC 1"
	sum pc2, d
	label var pc2 "Disclosure PC 2"
			
			
	**** 2B. Other Controls & Partitioning variables *****
		
	*** Create utility token variable (from WP disclosure / ICO description)
	gen wp_sec_token = 1 if (wp_Div_Dist==1 | wp_Rev_share==1 | wp_BB_and_Burn==1)
	replace wp_sec_token=0 if (wp_sec_token==. & wp_Div_Dist!=.)
	label var wp_sec_token "Security Token"
	gen wp_util_token = 1 if wp_sec_token !=1
	replace wp_util_token = 0 if wp_sec_token==1 
	replace wp_util_token = . if wp_sec_token==.
	label var wp_util_token "Utility Token" 
		
	*** Create log of first day ICO return variables 
	gen ln_ret_1d_open_to_close = ln(ret_1d_open_to_close +1)
	label var ln_ret_1d_open_to_close "First Day ICO return"

			
	*** Create retvol control		
	replace retvol_1w = retvol_1m if retvol_1w==. & retvol_1m!=.
	label var retvol_1w  "volatility 1w"
	gen lretvol_1w = ln(1+retvol_1w)

	*** Create quintile of vesting months for cross-section
	egen vesting_mths_quintile = xtile(wp_min_Vesting_months), n(5)
	replace vesting_mths_quintile = vesting_mths_quintile/5
	label var vesting_mths_quintile "Token Vesting Period"
		

	**** 2C. Rating Variable *****

	** Create normalized variables of ratings (consistent with disclosure index)
	su rating_adj, d
	gen rating_adj_norm = (rating_adj - `r(min)') / (`r(max)'-`r(min)')
	label var rating_adj_norm "Rating (Adjusted)"
			
			
	**** 2D. Long-term outcome measures / controls ***** 

	** Create 6mth returns **
	gen eret_6mp = ret_6mp - eth_ret_6m
	replace eret_6mp = eret_6mp/100
	gen leret_6mp = ln(1+eret_6mp)*100

	** Create failure outcome-variable consistent with Howell et al. (2020)*/
	gen failure = 0 
	replace failure = 1 if Listed==0				
	replace failure = 1 if active_website_ind ==0 	
	replace failure = 1 if (Listed==1 & last_date <= date("01oct2018","DMY")) 


	** Create "Size" control variable (using multiple sources)
	gen mv_raw1 = mv_mm*1000000
	gen mv_raw2 = total_supply_coinmarketcap*close*1000000
	gen mv_raw3 = total_supply_coinmarketcap*close_lag1*1000000
	gen mv_raw4 = total_supply_coinmarketcap*ico_price*1000000
	gen total_sold = tokens_for_sale_icobench*ico_price
	gen total_supply_usd2 = total_supply_usd*1000000
	egen size_temp = rowfirst(mv_raw1 mv_raw2 mv_raw3 mv_raw4 soft_cap_usd_icobench hard_cap_usd_icobench total_sold total_supply_usd2)
	gen size = ln(1+size_temp)

	save dataset_for_analysis, replace
	
**********************************************************************************
******************************************************************
** BDEM_3_Main_Tables - Main regressions reported in manuscript **												**
******************************************************************

set seed 1339487731
use dataset_for_analysis, clear /*Read in dataset for analysis (check: 3,349 ICOs) */
	
********************************************************************************
** MAIN RESULTS - REGRESSIONS    
********************************************************************************

*** Create fixed effects and clustering variables
encode Industry_FE_desc, gen(industry_f)
encode region, gen(region_f)
gen reg_qtr = region_f*qtr_index
tab region_f, gen(reg_ind)
tab industry_f, gen(ind_fe)

*** Define controls and disclosure variables for regressions 
global CONTROLS1 "wp_util_token log_num_members_benchy Soft_cap preico_indicator bonuses_indicator usa_restricted_ind btc_mom_3m"
global DISCLOSURE "ln_wp_page_count wp_tech_whitepaper wp_product_roadmap_info team_identity wp_token_dist_ftap_ind wp_vesting_ind wp_UOP github_sourcecode video_presentation social_media_presence"
global CONTROLS_sec "size lretvol_1w ln_ret_1d_open_to_close"


********************************************************************************
*****																	   *****
*****   Table 4: RAISED ON DISCLOSURE MEASURES 				               *****
*****																	   *****
********************************************************************************;

*********************************
******* PANEL A: RAISED *********
*********************************

**** Column (1): Raised on raw Disclosure Measures 
reghdfe Raised $DISCLOSURE $CONTROLS1, keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr)

**** Column (2): Raised on aggregated disclosure measure (decile) 
reghdfe Raised tdisc_norm $CONTROLS1, keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr)

**** Column (3): Raised on the first Two Principal Components of Disclosure Index
reghdfe Raised pc1 pc2 $CONTROLS1, keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr)


*********************************
******* PANEL B: USD Raised  ****
*********************************
	
**** Column (1): Log USD Raised on raw Disclosure Measures 
reghdfe log_usdraise $DISCLOSURE $CONTROLS1 if log_usdraise!=0, keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr) 

**** Column (2): Log USD Raised on aggregated disclosure measure (decile) 
reghdfe log_usdraise tdisc_norm $CONTROLS1 if log_usdraise!=0,  keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr) 

**** Column (3): Log USD Raised on the first Two Principal Components of Disclosure Index
reghdfe log_usdraise pc1 pc2 $CONTROLS1 if log_usdraise!=0, keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr)



********************************************************************************
*****																	   *****
*****   Table 5: Cross-Sectional results: Internal Governance              *****
*****																	   *****
********************************************************************************

**** Column (1): Interaction with vesting indicator
reghdfe Raised c.tdisc3_norm##c.wp_vesting_ind $CONTROLS1,  keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr) 

**** Column (2): Interaction with vesting months 
reghdfe Raised c.tdisc3_norm##c.vesting_mths_quintile $CONTROLS1,  keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr) 



********************************************************************************
*****																	   *****
*****   Table 6: Cross-Sectional results: Information Intermediaries       *****
*****																	   *****
********************************************************************************
			
*** Column (1): Determinants of being rated
reghdfe rating_ind tdisc_norm $CONTROLS1, keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr)
		
*** Column (2): Rating (continuous) on disclosure index
reghdfe rating_adj_norm tdisc_norm $CONTROLS1, keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr)

*** Column (3): Continuous rating on predicting Failure (note - run on sample with tdisc_norm not missing)
reghdfe failure rating_adj_norm $CONTROLS1 if tdisc_norm!=., keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr)

*** Column (4): Continuous rating on 6mth returns
winsor2 leret_6mp, replace cuts(0 99) 	/* NOTE: winsorize extreme returns. This does not impact inferences */ 
reghdfe leret_6mp rating_adj_norm $CONTROLS1 $CONTROLS_sec if (tdisc_norm!=. & Listed==1), keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr)

**** Column (5): Raised on tdisc_norm interact with Rating Indicator 
reghdfe Raised c.tdisc_norm##c.rating_ind $CONTROLS1,  keepsingletons a(region_f industry_f qtr_index) cl(reg_qtr) 

********************************************************************************
************************        END			************************************
********************************************************************************





















