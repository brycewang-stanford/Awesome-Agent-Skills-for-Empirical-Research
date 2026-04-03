clear
cd "G:\My Drive\Research Seller Financing\Data\"
use Transactions_Data_2015.dta, clear
set more off
	
	
***** FIGURES ****

	*** Chart seller financing by year ***
	twoway (line note_paid_avg_yr yr if public_buyer==0) (line note_paid_avg_yr yr if public_buyer==1, lcolor(forest_green) lpattern(dash)), ymtick(, nolabels) ytitle(Transactions using Seller Financing (%)) legend(lab(1 Private Buyer) lab(2 Public Buyer)) legend(cols(1) ring(0) position(2) bmargin(large)) scheme(s1mono) xtitle(Transaction Year) subtitle(, nobox), if yr>1994 & yr<2016
	graph export "G:\My Drive\Research Seller Financing\Results\App_SF_yr.png", replace
	
	*** Chart earnout by year ***
	twoway (line earnout_avg_yr yr if public_buyer==0) (line earnout_avg_yr yr if public_buyer==1, lcolor(forest_green) lpattern(dash)), ymtick(, nolabels) ytitle(Transactions using Earnouts (%)) legend(lab(1 Private Buyer) lab(2 Public Buyer)) legend(cols(1) ring(0) position(10) bmargin(large)) scheme(s1mono) xtitle(Transaction Year) subtitle(, nobox), if yr>1994 & yr<2016
	graph export "G:\My Drive\Research Seller Financing\Results\App_EO_yr.png", replace

	
***** MAIN TABLES ****

*** Table 1A: Summary Statistics ***
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail
	esttab, cells("mean sd p25 p50 p75 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat.tex"
	esttab, cells("mean sd p25 p50 p75 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat.csv"


	estpost tabstat c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, statistics(n mean sd p1 p25 p50 p75 p99 ) columns(statistics)
	esttab using "G:\My Drive\Research Seller Financing\Results\1_summary_stat.tex", replace cells("mean(fmt(%7.2fc) label(Mean)) sd(fmt(%7.2fc) label(Std Dev)) p25(fmt(%7.2fc)) p50(fmt(%7.2fc)) p75(fmt(%7.2fc)) count(fmt(%9.0fc) label(N Obs))") fragment nofloat booktabs noobs label nonumber ord(`vlst1')
	eststo clear

 	
*** Table 1B: By note for public=0
	* No Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==0 & public_buyer==0
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_0.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_0.csv"
	* With Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==1 & public_buyer==0
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_1.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_1.csv"

	estimates clear
	foreach v of varlist 		c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise{
	quietly reg  `v' note_paid, cluster(ind_code_48),  if public_buyer==0
				estimates store n`v', title("`v'")
	}
	esttab n* using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_ttest.csv" , p stats(N, fmt(%9.0g) labels(R-squared)) legend label mtitle modelwidth(10) collabels(none) star(* 0.1 ** 0.05 *** 0.01)  replace

*** Table 1C: By note for public=1
	* No Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==0 & public_buyer==1
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_0.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_0.csv"
	* With Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==1 & public_buyer==1
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_1.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_1.csv"

	estimates clear
	foreach v of varlist 		c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise{
	quietly reg  `v' note_paid, cluster(ind_code_48),  if public_buyer==1
				estimates store n`v', title("`v'")
	}
	esttab n* using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_ttest.csv" , p stats(N, fmt(%9.0g) labels(R-squared)) legend label mtitle modelwidth(10) collabels(none) star(* 0.1 ** 0.05 *** 0.01)  replace

	
	
*** Seller Financing Indicator ***	
*** TABLE 2A: Information Asymmetry - Firm level characteristics
	quietly eststo r1: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\2A_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** TABLE 2B: Information Asymmetry - Industry, Regulatory, Environment, and Transaction 
	quietly eststo r1: reghdfe note_paid  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\2B_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** TABLE 3A: Earnouts - Firm level characteristics
	quietly eststo r1: reghdfe Earnout  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe Earnout  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\4A_Earnout_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** TABLE 3B: Earnouts - Industry, Regulatory, Environment, and Transaction 
	quietly eststo r1: reghdfe Earnout   public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe Earnout  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe Earnout  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe Earnout           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe Earnout           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\4B_Earnout_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** Table 4: Closing Time & Price (Seller Financing)
	quietly eststo r1: reghdfe l_daystosell 	public_buyer l_age Age_Ind EBTtoS l_revenue note_paid, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r2: reghdfe l_daystosell 	public_buyer l_age Age_Ind EBTtoS l_revenue Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r3: reghdfe l_daystosell 	public_buyer l_age Age_Ind EBTtoS l_revenue note_paid Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r4: reghdfe Discount  		public_buyer l_age Age_Ind EBTtoS l_revenue Ask_to_earn note_paid, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r5: reghdfe Discount  		public_buyer l_age Age_Ind EBTtoS l_revenue Ask_to_earn Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r6: reghdfe Discount  		public_buyer l_age Age_Ind EBTtoS l_revenue Ask_to_earn note_paid Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\5_Price_Time.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
		
	
*** Seller Financing % ***
*** TABLE 5A: Information Asymmetry - Firm level characteristics (intensive margin)
	quietly eststo r1: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\3A_SFperc_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** TABLE 5B: Information Asymmetry - Industry, Regulatory, Environment, and Transaction (intensive margin)
	quietly eststo r1: reghdfe seller_financing  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe seller_financing  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe seller_financing  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe seller_financing           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe seller_financing           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\3B_SFperc_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace	

*** Table 6 Moral Hazard
	quietly eststo r1: reghdfe note_paid 	public_buyer l_age Age_Ind EBTtoS l_revenue noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid 	public_buyer l_age Age_Ind EBTtoS l_revenue noncompete_garmaise nc_g_int noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe Earnout 		public_buyer l_age Age_Ind EBTtoS l_revenue noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r4: reghdfe Earnout 		public_buyer l_age Age_Ind EBTtoS l_revenue noncompete_garmaise nc_g_int noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
		estadd local Sample "All": r1 r2 r3 r4
		estadd local Industry_FE "Yes": r1 r2 r3 r4 
		estadd local Year_FE "Yes": r1 r2 r3 r4
		estadd local Cluster "State & FF-48": r1 r2 r3 r4 
	esttab r1 r2 r3 r4 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 using "G:\My Drive\Research Seller Financing\Results\7A_Moral_Hazard.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** Table 7: Public Buyers	
		quietly eststo r1: reghdfe note_paid 	l_revenue EBTtoS l_age Age_Ind industry_match , cluster(ind_code_48) absorb(ind_code_48 yr)
		quietly eststo r3: reghdfe Earnout 		l_revenue EBTtoS l_age Age_Ind industry_match , cluster(ind_code_48) absorb(ind_code_48 yr)
		quietly eststo r2: reghdfe note_paid 	l_revenue EBTtoS l_age Age_Ind l_TransactionCosts , cluster(ind_code_48) absorb(ind_code_48 yr)
		quietly eststo r4: reghdfe Earnout 		l_revenue EBTtoS l_age Age_Ind l_TransactionCosts , cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "Public Buyer": r1 r2 r3 r4 
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 
			 estadd local Year_FE "Yes": r1 r2 r3 r4 
			 estadd local Cluster "FF-48": r1 r2 r3 r4 
	esttab r1 r2 r3 r4, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 using "G:\My Drive\Research Seller Financing\Results\6_Public_Buyers.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	

*** Appendix ***
*** Appendix B1:State Audit Industry
	eststo r1: reghdfe note_paid  			l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0
	eststo r2: reghdfe seller_financing 	l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0
	eststo r3: reghdfe Earnout 				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0
	eststo r4: reghdfe note_paid  			l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0 & noncompete==0
	eststo r5: reghdfe seller_financing 	l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0 & noncompete==0
	eststo r6: reghdfe Earnout 	l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0 & noncompete==0
			 estadd local Sample "Private Buyer": r1 r2 r3
			 estadd local Sample "Private Buyer & No non-compete": r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "State & Industry": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_3_Ind_audit.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace	

*** Appendix B.2A: Robustness on revenue>$1m (Information Asymmetry - Firm level characteristics )
	preserve
	drop if revenue<1000000
	quietly eststo r1: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_2_1m+_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	restore
	
*** Appendix B.2B: Robustness on revenue>$1m (Information Asymmetry - Industry, Regulatory, Environment, and Transaction)
	preserve
	drop if revenue<1000000
	quietly eststo r1: reghdfe note_paid  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\App_2_1m+_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace	
	restore

*** Appendix B.3: Construction and Restaurant Industry
	quietly eststo r1: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue construction, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t c_corp state_audit disclosure_nomerit construction, cluster(ind_code_48) absorb(yr)
	quietly eststo r3: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue restaurant, cluster(ind_code_48) absorb(yr)
	quietly eststo r4: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t c_corp state_audit disclosure_nomerit restaurant, cluster(ind_code_48) absorb(yr)
		 estadd local Sample "All": r1 r2 r3 r4
		 estadd local Industry_FE "No": r1 r2 r3 r4 
		 estadd local Year_FE "Yes": r1 r2 r3 r4
		 estadd local Cluster "FF-48": r1 r2 r3 r4  
	esttab r1 r2 r3 r4 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 using "G:\My Drive\Research Seller Financing\Results\App_1_Const_Rest.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** Appendix B.4A: Information Asymmetry (firm) with moral hazard robustness
	quietly eststo r1: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_4A_MH_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** Appendix B.4B: Information Asymmetry (Industry, Regulatory, Environment, and Transaction) with moral hazard robustness
	quietly eststo r1: reghdfe note_paid  public_buyer 	noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\App_4B_MH_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

	
*** Appendix B.4C: Information Asymmetry (firm) with moral hazard robustness
	preserve
	keep if noncompete==0
	quietly eststo r1: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_4C_MH_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	restore
	
*** Appendix B.4D: Information Asymmetry (Industry, Regulatory, Environment, and Transaction) with moral hazard robustness
	preserve
	keep if noncompete==0
	quietly eststo r1: reghdfe note_paid  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\App_4D_MH_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	restore
	*

		
	
**************************** END HERE ****************************	


















clear
cd "G:\My Drive\Research Seller Financing\Data\"
use Transactions_Data_2015.dta, clear
set more off
	
	
***** FIGURES ****

	*** Chart seller financing by year ***
	twoway (line note_paid_avg_yr yr if public_buyer==0) (line note_paid_avg_yr yr if public_buyer==1, lcolor(forest_green) lpattern(dash)), ymtick(, nolabels) ytitle(Transactions using Seller Financing (%)) legend(lab(1 Private Buyer) lab(2 Public Buyer)) legend(cols(1) ring(0) position(2) bmargin(large)) scheme(s1mono) xtitle(Transaction Year) subtitle(, nobox), if yr>1994 & yr<2016
	graph export "G:\My Drive\Research Seller Financing\Results\App_SF_yr.png", replace
	
	*** Chart earnout by year ***
	twoway (line earnout_avg_yr yr if public_buyer==0) (line earnout_avg_yr yr if public_buyer==1, lcolor(forest_green) lpattern(dash)), ymtick(, nolabels) ytitle(Transactions using Earnouts (%)) legend(lab(1 Private Buyer) lab(2 Public Buyer)) legend(cols(1) ring(0) position(10) bmargin(large)) scheme(s1mono) xtitle(Transaction Year) subtitle(, nobox), if yr>1994 & yr<2016
	graph export "G:\My Drive\Research Seller Financing\Results\App_EO_yr.png", replace

	
***** MAIN TABLES ****

*** Table 1A: Summary Statistics ***
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail
	esttab, cells("mean sd p25 p50 p75 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat.tex"
	esttab, cells("mean sd p25 p50 p75 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat.csv"


	estpost tabstat c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, statistics(n mean sd p1 p25 p50 p75 p99 ) columns(statistics)
	esttab using "G:\My Drive\Research Seller Financing\Results\1_summary_stat.tex", replace cells("mean(fmt(%7.2fc) label(Mean)) sd(fmt(%7.2fc) label(Std Dev)) p25(fmt(%7.2fc)) p50(fmt(%7.2fc)) p75(fmt(%7.2fc)) count(fmt(%9.0fc) label(N Obs))") fragment nofloat booktabs noobs label nonumber ord(`vlst1')
	eststo clear

 	
*** Table 1B: By note for public=0
	* No Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==0 & public_buyer==0
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_0.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_0.csv"
	* With Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==1 & public_buyer==0
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_1.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_1.csv"

	estimates clear
	foreach v of varlist 		c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise{
	quietly reg  `v' note_paid, cluster(ind_code_48),  if public_buyer==0
				estimates store n`v', title("`v'")
	}
	esttab n* using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_ttest.csv" , p stats(N, fmt(%9.0g) labels(R-squared)) legend label mtitle modelwidth(10) collabels(none) star(* 0.1 ** 0.05 *** 0.01)  replace

*** Table 1C: By note for public=1
	* No Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==0 & public_buyer==1
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_0.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_0.csv"
	* With Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==1 & public_buyer==1
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_1.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_1.csv"

	estimates clear
	foreach v of varlist 		c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise{
	quietly reg  `v' note_paid, cluster(ind_code_48),  if public_buyer==1
				estimates store n`v', title("`v'")
	}
	esttab n* using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_ttest.csv" , p stats(N, fmt(%9.0g) labels(R-squared)) legend label mtitle modelwidth(10) collabels(none) star(* 0.1 ** 0.05 *** 0.01)  replace

	
	
*** Seller Financing Indicator ***	
*** TABLE 2A: Information Asymmetry - Firm level characteristics
	quietly eststo r1: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\2A_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** TABLE 2B: Information Asymmetry - Industry, Regulatory, Environment, and Transaction 
	quietly eststo r1: reghdfe note_paid  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\2B_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** TABLE 3A: Earnouts - Firm level characteristics
	quietly eststo r1: reghdfe Earnout  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe Earnout  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\4A_Earnout_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** TABLE 3B: Earnouts - Industry, Regulatory, Environment, and Transaction 
	quietly eststo r1: reghdfe Earnout   public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe Earnout  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe Earnout  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe Earnout           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe Earnout           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\4B_Earnout_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** Table 4: Closing Time & Price (Seller Financing)
	quietly eststo r1: reghdfe l_daystosell 	public_buyer l_age Age_Ind EBTtoS l_revenue note_paid, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r2: reghdfe l_daystosell 	public_buyer l_age Age_Ind EBTtoS l_revenue Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r3: reghdfe l_daystosell 	public_buyer l_age Age_Ind EBTtoS l_revenue note_paid Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r4: reghdfe Discount  		public_buyer l_age Age_Ind EBTtoS l_revenue Ask_to_earn note_paid, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r5: reghdfe Discount  		public_buyer l_age Age_Ind EBTtoS l_revenue Ask_to_earn Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r6: reghdfe Discount  		public_buyer l_age Age_Ind EBTtoS l_revenue Ask_to_earn note_paid Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\5_Price_Time.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
		
	
*** Seller Financing % ***
*** TABLE 5A: Information Asymmetry - Firm level characteristics (intensive margin)
	quietly eststo r1: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\3A_SFperc_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** TABLE 5B: Information Asymmetry - Industry, Regulatory, Environment, and Transaction (intensive margin)
	quietly eststo r1: reghdfe seller_financing  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe seller_financing  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe seller_financing  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe seller_financing           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe seller_financing           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\3B_SFperc_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace	

*** Table 6 Moral Hazard
	quietly eststo r1: reghdfe note_paid 	public_buyer l_age Age_Ind EBTtoS l_revenue noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid 	public_buyer l_age Age_Ind EBTtoS l_revenue noncompete_garmaise nc_g_int noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe Earnout 		public_buyer l_age Age_Ind EBTtoS l_revenue noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r4: reghdfe Earnout 		public_buyer l_age Age_Ind EBTtoS l_revenue noncompete_garmaise nc_g_int noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
		estadd local Sample "All": r1 r2 r3 r4
		estadd local Industry_FE "Yes": r1 r2 r3 r4 
		estadd local Year_FE "Yes": r1 r2 r3 r4
		estadd local Cluster "State & FF-48": r1 r2 r3 r4 
	esttab r1 r2 r3 r4 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 using "G:\My Drive\Research Seller Financing\Results\7A_Moral_Hazard.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** Table 7: Public Buyers	
		quietly eststo r1: reghdfe note_paid 	l_revenue EBTtoS l_age Age_Ind industry_match , cluster(ind_code_48) absorb(ind_code_48 yr)
		quietly eststo r3: reghdfe Earnout 		l_revenue EBTtoS l_age Age_Ind industry_match , cluster(ind_code_48) absorb(ind_code_48 yr)
		quietly eststo r2: reghdfe note_paid 	l_revenue EBTtoS l_age Age_Ind l_TransactionCosts , cluster(ind_code_48) absorb(ind_code_48 yr)
		quietly eststo r4: reghdfe Earnout 		l_revenue EBTtoS l_age Age_Ind l_TransactionCosts , cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "Public Buyer": r1 r2 r3 r4 
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 
			 estadd local Year_FE "Yes": r1 r2 r3 r4 
			 estadd local Cluster "FF-48": r1 r2 r3 r4 
	esttab r1 r2 r3 r4, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 using "G:\My Drive\Research Seller Financing\Results\6_Public_Buyers.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	

*** Appendix ***
*** Appendix B1:State Audit Industry
	eststo r1: reghdfe note_paid  			l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0
	eststo r2: reghdfe seller_financing 	l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0
	eststo r3: reghdfe Earnout 				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0
	eststo r4: reghdfe note_paid  			l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0 & noncompete==0
	eststo r5: reghdfe seller_financing 	l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0 & noncompete==0
	eststo r6: reghdfe Earnout 	l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0 & noncompete==0
			 estadd local Sample "Private Buyer": r1 r2 r3
			 estadd local Sample "Private Buyer & No non-compete": r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "State & Industry": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_3_Ind_audit.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace	

*** Appendix B.2A: Robustness on revenue>$1m (Information Asymmetry - Firm level characteristics )
	preserve
	drop if revenue<1000000
	quietly eststo r1: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_2_1m+_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	restore
	
*** Appendix B.2B: Robustness on revenue>$1m (Information Asymmetry - Industry, Regulatory, Environment, and Transaction)
	preserve
	drop if revenue<1000000
	quietly eststo r1: reghdfe note_paid  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\App_2_1m+_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace	
	restore

*** Appendix B.3: Construction and Restaurant Industry
	quietly eststo r1: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue construction, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t c_corp state_audit disclosure_nomerit construction, cluster(ind_code_48) absorb(yr)
	quietly eststo r3: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue restaurant, cluster(ind_code_48) absorb(yr)
	quietly eststo r4: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t c_corp state_audit disclosure_nomerit restaurant, cluster(ind_code_48) absorb(yr)
		 estadd local Sample "All": r1 r2 r3 r4
		 estadd local Industry_FE "No": r1 r2 r3 r4 
		 estadd local Year_FE "Yes": r1 r2 r3 r4
		 estadd local Cluster "FF-48": r1 r2 r3 r4  
	esttab r1 r2 r3 r4 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 using "G:\My Drive\Research Seller Financing\Results\App_1_Const_Rest.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** Appendix B.4A: Information Asymmetry (firm) with moral hazard robustness
	quietly eststo r1: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_4A_MH_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** Appendix B.4B: Information Asymmetry (Industry, Regulatory, Environment, and Transaction) with moral hazard robustness
	quietly eststo r1: reghdfe note_paid  public_buyer 	noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\App_4B_MH_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

	
*** Appendix B.4C: Information Asymmetry (firm) with moral hazard robustness
	preserve
	keep if noncompete==0
	quietly eststo r1: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_4C_MH_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	restore
	
*** Appendix B.4D: Information Asymmetry (Industry, Regulatory, Environment, and Transaction) with moral hazard robustness
	preserve
	keep if noncompete==0
	quietly eststo r1: reghdfe note_paid  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\App_4D_MH_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	restore
	*

		
	
**************************** END HERE ****************************	


















clear
cd "G:\My Drive\Research Seller Financing\Data\"
use Transactions_Data_2015.dta, clear
set more off
	
	
***** FIGURES ****

	*** Chart seller financing by year ***
	twoway (line note_paid_avg_yr yr if public_buyer==0) (line note_paid_avg_yr yr if public_buyer==1, lcolor(forest_green) lpattern(dash)), ymtick(, nolabels) ytitle(Transactions using Seller Financing (%)) legend(lab(1 Private Buyer) lab(2 Public Buyer)) legend(cols(1) ring(0) position(2) bmargin(large)) scheme(s1mono) xtitle(Transaction Year) subtitle(, nobox), if yr>1994 & yr<2016
	graph export "G:\My Drive\Research Seller Financing\Results\App_SF_yr.png", replace
	
	*** Chart earnout by year ***
	twoway (line earnout_avg_yr yr if public_buyer==0) (line earnout_avg_yr yr if public_buyer==1, lcolor(forest_green) lpattern(dash)), ymtick(, nolabels) ytitle(Transactions using Earnouts (%)) legend(lab(1 Private Buyer) lab(2 Public Buyer)) legend(cols(1) ring(0) position(10) bmargin(large)) scheme(s1mono) xtitle(Transaction Year) subtitle(, nobox), if yr>1994 & yr<2016
	graph export "G:\My Drive\Research Seller Financing\Results\App_EO_yr.png", replace

	
***** MAIN TABLES ****

*** Table 1A: Summary Statistics ***
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail
	esttab, cells("mean sd p25 p50 p75 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat.tex"
	esttab, cells("mean sd p25 p50 p75 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat.csv"


	estpost tabstat c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, statistics(n mean sd p1 p25 p50 p75 p99 ) columns(statistics)
	esttab using "G:\My Drive\Research Seller Financing\Results\1_summary_stat.tex", replace cells("mean(fmt(%7.2fc) label(Mean)) sd(fmt(%7.2fc) label(Std Dev)) p25(fmt(%7.2fc)) p50(fmt(%7.2fc)) p75(fmt(%7.2fc)) count(fmt(%9.0fc) label(N Obs))") fragment nofloat booktabs noobs label nonumber ord(`vlst1')
	eststo clear

 	
*** Table 1B: By note for public=0
	* No Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==0 & public_buyer==0
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_0.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_0.csv"
	* With Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==1 & public_buyer==0
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_1.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_sf_1.csv"

	estimates clear
	foreach v of varlist 		c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise{
	quietly reg  `v' note_paid, cluster(ind_code_48),  if public_buyer==0
				estimates store n`v', title("`v'")
	}
	esttab n* using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_0_ttest.csv" , p stats(N, fmt(%9.0g) labels(R-squared)) legend label mtitle modelwidth(10) collabels(none) star(* 0.1 ** 0.05 *** 0.01)  replace

*** Table 1C: By note for public=1
	* No Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==0 & public_buyer==1
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_0.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_0.csv"
	* With Seller Financing
	eststo clear
	estpost summarize c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise, detail, if note_paid==1 & public_buyer==1
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_1.tex"
	esttab, cells("mean sd p50 count" b(fmt(%12.3fc))) label replace, using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_sf_1.csv"

	estimates clear
	foreach v of varlist 		c_corp age revenue assets debt_dummy book_eq_neg EBTtoS TAtoS Tobin_QA Franchise hi_IA ///
	price PtoEBT TransactionCosts Discount DaysToSell public_buyer note_paid seller_financing Earnout noncompete employ_agree stock_purchase ///
	state_audit disclosure_nomerit noncompete_garmaise{
	quietly reg  `v' note_paid, cluster(ind_code_48),  if public_buyer==1
				estimates store n`v', title("`v'")
	}
	esttab n* using "G:\My Drive\Research Seller Financing\Results\1_summary_stat_pb_1_ttest.csv" , p stats(N, fmt(%9.0g) labels(R-squared)) legend label mtitle modelwidth(10) collabels(none) star(* 0.1 ** 0.05 *** 0.01)  replace

	
	
*** Seller Financing Indicator ***	
*** TABLE 2A: Information Asymmetry - Firm level characteristics
	quietly eststo r1: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\2A_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** TABLE 2B: Information Asymmetry - Industry, Regulatory, Environment, and Transaction 
	quietly eststo r1: reghdfe note_paid  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\2B_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** TABLE 3A: Earnouts - Firm level characteristics
	quietly eststo r1: reghdfe Earnout  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe Earnout  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe Earnout 	public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\4A_Earnout_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** TABLE 3B: Earnouts - Industry, Regulatory, Environment, and Transaction 
	quietly eststo r1: reghdfe Earnout   public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe Earnout  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe Earnout  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe Earnout           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe Earnout           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\4B_Earnout_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** Table 4: Closing Time & Price (Seller Financing)
	quietly eststo r1: reghdfe l_daystosell 	public_buyer l_age Age_Ind EBTtoS l_revenue note_paid, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r2: reghdfe l_daystosell 	public_buyer l_age Age_Ind EBTtoS l_revenue Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r3: reghdfe l_daystosell 	public_buyer l_age Age_Ind EBTtoS l_revenue note_paid Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r4: reghdfe Discount  		public_buyer l_age Age_Ind EBTtoS l_revenue Ask_to_earn note_paid, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r5: reghdfe Discount  		public_buyer l_age Age_Ind EBTtoS l_revenue Ask_to_earn Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
	quietly eststo r6: reghdfe Discount  		public_buyer l_age Age_Ind EBTtoS l_revenue Ask_to_earn note_paid Earnout, cluster(ind_code_48) absorb (yr ind_code_48)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\5_Price_Time.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
		
	
*** Seller Financing % ***
*** TABLE 5A: Information Asymmetry - Firm level characteristics (intensive margin)
	quietly eststo r1: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe seller_financing  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\3A_SFperc_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** TABLE 5B: Information Asymmetry - Industry, Regulatory, Environment, and Transaction (intensive margin)
	quietly eststo r1: reghdfe seller_financing  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe seller_financing  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe seller_financing  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe seller_financing           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe seller_financing           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\3B_SFperc_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace	

*** Table 6 Moral Hazard
	quietly eststo r1: reghdfe note_paid 	public_buyer l_age Age_Ind EBTtoS l_revenue noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid 	public_buyer l_age Age_Ind EBTtoS l_revenue noncompete_garmaise nc_g_int noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe Earnout 		public_buyer l_age Age_Ind EBTtoS l_revenue noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r4: reghdfe Earnout 		public_buyer l_age Age_Ind EBTtoS l_revenue noncompete_garmaise nc_g_int noncompete employ_agree, cluster(state_id ind_code_48) absorb(ind_code_48 yr)
		estadd local Sample "All": r1 r2 r3 r4
		estadd local Industry_FE "Yes": r1 r2 r3 r4 
		estadd local Year_FE "Yes": r1 r2 r3 r4
		estadd local Cluster "State & FF-48": r1 r2 r3 r4 
	esttab r1 r2 r3 r4 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 using "G:\My Drive\Research Seller Financing\Results\7A_Moral_Hazard.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** Table 7: Public Buyers	
		quietly eststo r1: reghdfe note_paid 	l_revenue EBTtoS l_age Age_Ind industry_match , cluster(ind_code_48) absorb(ind_code_48 yr)
		quietly eststo r3: reghdfe Earnout 		l_revenue EBTtoS l_age Age_Ind industry_match , cluster(ind_code_48) absorb(ind_code_48 yr)
		quietly eststo r2: reghdfe note_paid 	l_revenue EBTtoS l_age Age_Ind l_TransactionCosts , cluster(ind_code_48) absorb(ind_code_48 yr)
		quietly eststo r4: reghdfe Earnout 		l_revenue EBTtoS l_age Age_Ind l_TransactionCosts , cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "Public Buyer": r1 r2 r3 r4 
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 
			 estadd local Year_FE "Yes": r1 r2 r3 r4 
			 estadd local Cluster "FF-48": r1 r2 r3 r4 
	esttab r1 r2 r3 r4, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 using "G:\My Drive\Research Seller Financing\Results\6_Public_Buyers.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	

*** Appendix ***
*** Appendix B1:State Audit Industry
	eststo r1: reghdfe note_paid  			l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0
	eststo r2: reghdfe seller_financing 	l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0
	eststo r3: reghdfe Earnout 				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0
	eststo r4: reghdfe note_paid  			l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0 & noncompete==0
	eststo r5: reghdfe seller_financing 	l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0 & noncompete==0
	eststo r6: reghdfe Earnout 	l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id M_ind) absorb(M_ind yr), if public_buyer==0 & noncompete==0
			 estadd local Sample "Private Buyer": r1 r2 r3
			 estadd local Sample "Private Buyer & No non-compete": r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "State & Industry": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_3_Ind_audit.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace	

*** Appendix B.2A: Robustness on revenue>$1m (Information Asymmetry - Firm level characteristics )
	preserve
	drop if revenue<1000000
	quietly eststo r1: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_2_1m+_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	restore
	
*** Appendix B.2B: Robustness on revenue>$1m (Information Asymmetry - Industry, Regulatory, Environment, and Transaction)
	preserve
	drop if revenue<1000000
	quietly eststo r1: reghdfe note_paid  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\App_2_1m+_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace	
	restore

*** Appendix B.3: Construction and Restaurant Industry
	quietly eststo r1: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue construction, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t c_corp state_audit disclosure_nomerit construction, cluster(ind_code_48) absorb(yr)
	quietly eststo r3: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue restaurant, cluster(ind_code_48) absorb(yr)
	quietly eststo r4: reghdfe note_paid public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t c_corp state_audit disclosure_nomerit restaurant, cluster(ind_code_48) absorb(yr)
		 estadd local Sample "All": r1 r2 r3 r4
		 estadd local Industry_FE "No": r1 r2 r3 r4 
		 estadd local Year_FE "Yes": r1 r2 r3 r4
		 estadd local Cluster "FF-48": r1 r2 r3 r4  
	esttab r1 r2 r3 r4 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 using "G:\My Drive\Research Seller Financing\Results\App_1_Const_Rest.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

*** Appendix B.4A: Information Asymmetry (firm) with moral hazard robustness
	quietly eststo r1: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  noncompete_garmaise nc_g_int noncompete employ_agree public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_4A_MH_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	
*** Appendix B.4B: Information Asymmetry (Industry, Regulatory, Environment, and Transaction) with moral hazard robustness
	quietly eststo r1: reghdfe note_paid  public_buyer 	noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		noncompete_garmaise nc_g_int noncompete employ_agree l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\App_4B_MH_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace

	
*** Appendix B.4C: Information Asymmetry (firm) with moral hazard robustness
	preserve
	keep if noncompete==0
	quietly eststo r1: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r2: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue hi_t, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r3: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue Franchise, cluster(ind_code_48) absorb(ind_code_48 yr)	
	quietly eststo r4: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue c_corp , cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r5: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
	quietly eststo r6: reghdfe note_paid  public_buyer l_age Age_Ind EBTtoS l_revenue TAtoS hi_t Franchise c_corp debt_dummy, cluster(ind_code_48) absorb(ind_code_48 yr)
			 estadd local Sample "All": r1 r2 r3 r4 r5 r6
			 estadd local Industry_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5 r6
			 estadd local Cluster "FF-48": r1 r2 r3 r4 r5 r6
	esttab r1 r2 r3 r4 r5 r6 , ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 r6 using "G:\My Drive\Research Seller Financing\Results\App_4C_MH_Firm.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	restore
	
*** Appendix B.4D: Information Asymmetry (Industry, Regulatory, Environment, and Transaction) with moral hazard robustness
	preserve
	keep if noncompete==0
	quietly eststo r1: reghdfe note_paid  public_buyer 	l_age Age_Ind EBTtoS l_revenue hi_IA, cluster(ind_code_48) absorb(yr)
	quietly eststo r2: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue disclosure_nomerit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r3: reghdfe note_paid  				l_age Age_Ind EBTtoS l_revenue state_audit, cluster(state_id) absorb(ind_code_48 yr), if public_buyer==0
	quietly eststo r4: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue stock_purchase, cluster(ind_code_48) absorb(ind_code_48 yr), if public_buyer==0	
	quietly eststo r5: reghdfe note_paid           		l_age Age_Ind EBTtoS l_revenue hi_IA disclosure_nomerit state_audit stock_purchase, cluster(ind_code_48 state_id) absorb(yr), if public_buyer==0
			 estadd local Sample "All": r1 
			 estadd local Sample "Private Buyer": r2 r3 r4 r5
			 estadd local Industry_FE "Yes": r1 r3 r4 
			 estadd local Industry_FE "No": r2 r5
			 estadd local Year_FE "Yes": r1 r2 r3 r4 r5
			 estadd local Cluster "FF-48": r1 r4  
			 estadd local Cluster "State": r2 r3 
			 estadd local Cluster "State & FF-48": r5 
	esttab r1 r2 r3 r4 r5, ar2 compress label scalars(Sample Industry_FE Year_FE Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01)
	esttab r1 r2 r3 r4 r5 using "G:\My Drive\Research Seller Financing\Results\App_4D_MH_Environment.tex", ar2 compress label scalars(Sample Industry_FE Year_FE  Cluster) cells(b(star fmt(%12.3f)) t(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) nogaps tex replace
	restore
	*

		
	
**************************** END HERE ****************************	



















