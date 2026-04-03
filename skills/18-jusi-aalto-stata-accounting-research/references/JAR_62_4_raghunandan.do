** cd to project directory here

log using "analyses_full_run.log", replace nomsg


use "Data/fully_merged_data_firm_state_year_final", clear
	so gvkey year
	qui by gvkey year: egen num_tot_FY_connections = sum(connected_state) // note: connected_state is the subsidy-related connection var
	qui gen connected_outofstate = num_tot_FY_connections - connected_state
		qui replace connected_outofstate = 1 if connected_outofstate  > 1 & connected_outofstate  != .

xtset firmstate year

************ TABLE 5:  ****************************
est clear
qui reghdfe dummy_nonfin_total 	1.connected_state 1.has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal 1.PAC_connected_st  log_firmstate_estabs lassets roa sale_growth mtb lev ppe_scaled, absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
	qui gen mainsample = e(sample)
	foreach v of varlist roa sale_growth mtb lev ppe_scaled {
		winsor `v' if mainsample , p(0.01) gen(`v'_wins) 
	}
	

est clear
qui eststo: reghdfe dummy_nonfin_total 	1.connected_state 1.has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal 1.PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe logpen_total 		1.connected_state 1.has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal 1.PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe dummy_outofstate_total 	1.connected_state 1.has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal 1.PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe logpen_outofstate_total 1.connected_state 1.has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal 1.PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe dummy_nonfin_total 	1.connected_state##1.PAC_connected_st 1.has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe dummy_nonfin_total 	1.connected_state##1.has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal 1.PAC_connected_st   log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe dummy_nonfin_total 	1.connected_state##1.board_connected_state 1.has_PAC_state_CEO board_connected_federal has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal 1.PAC_connected_st   log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)


esttab using "Results/tables_final.tex", replace ///
	title(Subsidies and Enforcement \label{sub_table_main}) label brackets b(3) t(2) star(* 0.10 ** 0.05 *** 0.01) scalars("r2_a Adjusted $R^2$") 

************ TABLE 6 *********************
est clear
qui eststo: reghdfe dummy_nonfin_total 	log_connected_sub_dollar has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe logpen_total 		log_connected_sub_dollar has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe dummy_nonfin_total 	connected_state has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs , absorb(gvkey##state_factor gvkey##year state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe logpen_total 		connected_state has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs , absorb(gvkey##state_factor gvkey##year state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe dummy_nonfin_total  upcoming_connection_4 upcoming_connection_3 upcoming_connection_2 upcoming_connection_1 connected_state_post0 connected_state_post1 connected_state_post2 connected_state_post3 connected_state_post4 connected_state_post5plus has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)

esttab using "Results/tables_final.tex", append ///
	title(Robustness \label{sub_table_robust}) label brackets b(3) t(2) star(* 0.10 ** 0.05 *** 0.01) scalars("r2_a Adjusted $R^2$") 


 ** PLOT COEFFICIENTS ***
coefplot (est5, label("Coefficients by Year") offset (0.2) keep( upcoming_connection_3 upcoming_connection_2 upcoming_connection_1 connected_state_post0 connected_state_post1 connected_state_post2 connected_state_post3 ) ///
	color(black) ), ci(95) vertical ciopts(recast(rcap) color(black)) ytitle(Coefficient) yline(0,lcolor(black)) xline(4, lcolor(black)) omitted graphregion(color(white)) bgcolor(white) ylabel(,tstyle(major_notick)) xlabel(,tstyle(major_notick)) recast(connected) xlabel(1 "t-3" 2 "t-2" 3 "t-1" 4 "t" 5 "t+1" 6 "t+2" 7 "t+3" ) yscale(range(-0.01(0.1)0.04))
 

***************** TABLE 7 *******************************
est clear
qui gen dummy_nonfin_0_1 = dummy_nonfin_total + dummy_nonfin_total_lag1 
	qui replace dummy_nonfin_0_1 = 1 if dummy_nonfin_0_1 == 2
	
qui gen statepen_states = (state=="CA"|state=="IL"|state=="KY"|state=="MA"|state=="NY"|state=="WA") 

* for column 4
qui gen nonconnected = (connected_state == 0)
qui bys gvkey year: egen nviolsp = sum(dummy_nonfin_0_1)
qui gen nviol_OOS_sp = nviolsp - dummy_nonfin_0_1
qui gen dummy_nonfin_0_1_OOS_sp = (nviol_OOS_sp > 0) if (nviol_OOS_sp != .)


qui eststo: reghdfe has_state_penalty   1.dummy_nonfin_0_1 has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins if statepen_states == 1, absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe has_state_penalty   1.connected_state  has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins if statepen_states == 1, absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe has_state_penalty   1.dummy_nonfin_0_1##1.connected_state has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins if statepen_states == 1, absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe has_state_penalty   1.dummy_nonfin_0_1##1.connected_state has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins if statepen_states == 1 & dummy_nonfin_0_1_OOS  == 1, absorb(gvkey##state_factor  state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe has_state_penalty   1.dummy_nonfin_0_1##1.connected_outofstate  has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins if statepen_states == 1, absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)

esttab using "Results/tables_final.tex", append ///
	title(Dual Sovereignty Table \label{dual_sov_table}) label brackets b(3) t(2) star(* 0.10 ** 0.05 *** 0.01) scalars("r2_a Adjusted $R^2$") 



************** TABLE 8 **************
* Two year window
est clear
qui eststo: reghdfe dummy_nonfin_total 	connected_st_inherited has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs   lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins   if merger_twoyear_window == 1 , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe logpen_total 		connected_st_inherited has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs   lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins   if merger_twoyear_window == 1 , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year )

* Three year window
qui eststo: reghdfe dummy_nonfin_total 	connected_st_inherited has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs   lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins   if merger_threeyear_window == 1 , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe logpen_total 		connected_st_inherited has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs   lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins   if merger_threeyear_window == 1 , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year )
esttab using "Results/tables_final.tex", append ///
	title(Mergers ) label brackets b(3) t(2) star(* 0.10 ** 0.05 *** 0.01) scalars("r2_a Adjusted $R^2$") 


**************** TABLE 9 *************************
* Attorney general
qui gen ag_gov_opp = 1 - ag_gov_same_party
	label variable ag_gov_opp "AGGovOpp_{jt}"

* Commissioners 
qui gen LC_opp = 1 - labor_gov_same
qui gen AC_opp = 1 - agriculture_gov_same
qui gen NR_opp = 1 - resource_gov_same
qui gen commissioner_opp = ((LC_opp == 1 )|  (AC_opp == 1 ) | (NR_opp == 1) )*1
	label variable commissioner_opp "CommissionerOpp_{jt}"
	
est clear

qui eststo: reghdfe dummy_nonfin_total connected_state##ag_gov_opp  has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe dummy_nonfin_total connected_state##commissioner_opp  has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
esttab using "Results/tables_final.tex", append ///
	title(AG Gov Same Party ) label brackets b(3) t(2) star(* 0.10 ** 0.05 *** 0.01) scalars("r2_a Adjusted $R^2$") 



**************** TABLE 10 *************************
est clear
label variable state_federal_opp_noconnect "StateFederalOpp"
label variable unified_fullgov "UnifiedGovt"

qui eststo: reghdfe dummy_nonfin_total 1.connected_state##1.state_federal_opp_noconnect  has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe dummy_nonfin_total 1.connected_state##1.unified_fullgov  has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe dummy_nonfin_total 1.connected_state##1.unified_fullgov##1.state_federal_opp_noconnect  has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
esttab using "Results/tables_final.tex", append ///
	title(The Federal Government ) label brackets b(3) t(2) star(* 0.10 ** 0.05 *** 0.01) scalars("r2_a Adjusted $R^2$") 

******************** TABLE 11 ********************************
label variable connected_federal "ConnectedFederalSub_{ijt}"
est clear
qui eststo: reghdfe dummy_nonfin_total connected_federal  has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe logpen_total connected_federal  has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe dummy_nonfin_total connected_federal connected_state has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
qui eststo: reghdfe logpen_total connected_federal connected_state has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st  log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins , absorb(gvkey##state_factor state_factor##sic2##year) vce(cluster gvkey sic2##year)
esttab using "Results/tables_final.tex", append ///
	title(Federal Subsidies ) label brackets b(3) t(2) star(* 0.10 ** 0.05 *** 0.01) scalars("r2_a Adjusted $R^2$") 

	

	
***************** DESCRIPTIVES ***********************
*** Subsidies
qui gen subs1m = state_subsidy_adjusted/1000000 // for presentation purposes easier to show in millions
	qui gen nonzero_sub_year = subs1m > 0 if subs1m != . // obs that have $$ value available
qui gen industry = " "
qui replace industry = "Agriculture" if sic2 < 10
qui replace industry = "Mining" if sic2 >= 10 & sic2 < 15
qui replace industry = "Construction" if sic2 >= 15 & sic2 < 18
qui replace industry = "Manufacturing" if sic2 >= 20 & sic2 < 40
qui replace industry = "Transportation/Communications" if sic2 >= 40 & sic2 < 50
qui replace industry = "Wholesale Trade" if sic2 >= 50 & sic2 < 52
qui replace industry = "Retail Trade" if sic2 >= 52 & sic2 < 60
qui replace industry = "Finance" if sic2 >= 60 & sic2 < 70
qui replace industry = "Services" if sic2 >= 70 & sic2 < 90
qui replace industry = "Other" if sic2 >= 90

est clear
* By industry
qui estpost tabstat has_state_subsidy_adjusted count_state_subsidy_adjusted nonzero_state_subsidy_adjusted  subs1m if mainsample == 1, by(industry) statistics(sum) columns(statistics)
esttab . using "Results/tables_final.tex", main(sum) unstack append

* By year
est clear
qui estpost tabstat has_state_subsidy_adjusted count_state_subsidy_adjusted nonzero_state_subsidy_adjusted  subs1m if mainsample == 1, by(year) statistics(sum) columns(statistics)
esttab . using "Results/tables_final.tex", main(sum) unstack append

* By state
qui estpost tabstat has_state_subsidy_adjusted count_state_subsidy_adjusted nonzero_state_subsidy_adjusted subs1m if mainsample == 1, by(state) statistics(sum) columns(statistics)
esttab . using "Results/tables_final.tex", main(sum) unstack append



*** Violations 
* By industry
est clear
qui estpost tabstat dummy_nonfin_total if mainsample == 1, by(industry) statistics(sum) columns(statistics)
esttab . using "Results/tables_final.tex", main(sum) unstack append

* By year
est clear
qui estpost tabstat dummy_nonfin_total if mainsample == 1, by(year) statistics(sum) columns(statistics)
esttab . using "Results/tables_final.tex", main(sum) unstack append

* By state
est clear
qui estpost tabstat dummy_nonfin_total if mainsample == 1, by(state) statistics(sum) columns(statistics)
esttab . using "Results/tables_final.tex", main(sum) unstack append

* By type -- need to merge with raw VT data since what we carried through for estimation purposes isn't granular enough
preserve
keep gvkey state year mainsample // unique identifiers
merge 1:m gvkey state year using "Data/violation_data" , keep(3)
	drop _merge
	// collapse to firm-state-year-agency level
	qui gen nviol = 1
	qui gen agency_simp = agency_code 
	qui replace agency_simp = "other" if !((agency_code == "OSHA") | (agency_code == "WHD") | (agency_code == "EPA") | (agency_code == "NLRB") | (agency_code == "MSHA") | (agency_code == "EEOC"))
	collapse (sum) nviol, by(gvkey state year agency_simp mainsample )
	tab agency_simp if mainsample == 1 

restore

** Other variables
est clear
qui estpost tabstat dummy_nonfin_total logpen_total connected_state log_connected_sub_dollar has_PAC_state_CEO has_PAC_federal_CEO has_PAC_federal_firm has_lobbying_federal PAC_connected_st board_connected_state board_connected_federal ag_gov_opp  commissioner_opp state_federal_opp_noconnect unified_fullgov connected_federal log_firmstate_estabs lassets roa_wins sale_growth_wins mtb_wins lev_wins ppe_scaled_wins if mainsample == 1, statistics(N mean median sd p10 p90) columns(statistics) 
esttab . using "Results/tables_final.tex", main(sum) unstack append

log close** cd to project directory here

log using "data_assembly_full_run.log", replace nomsg

** First, some preprocessing of election and violation data
********************************* GUBERNATORIAL ELECTIONS *********************************
import delim Data/Elections/governor_elections_2002_2018_basic_info.csv , clear
rename election_year year
so state year
save Data/Elections/governor_elections_2002_2018_basic, replace




import delim Data/Elections/AttorneyGeneral_Governor_Party.csv, clear // data from Ballotpedia, verified against state govt websites, on who AG and governor were
so state sub_year
save Data/Elections/AG_Gov_Party.dta, replace




import delim "Data/state_violation_data_30jun2020version.csv", clear // only state violation obs from VT, including historical parents
	rename correct_cik cik // hand-checked historical CIK

rename pen_year year

collapse (sum) penalty_adjusted , by(cik state year)
	qui drop if cik == .
	
qui gen has_state_penalty = 1

rename penalty_adjusted statetotalpenalties // need different var name before merging to main data (which also has this var for federal pens)

save Data/state_penalty_data, replace






*************** MAIN BIT OF BODY TO CONSTRUCT FIRM-STATE-YEAR DATA *************************
u Data/refUSA_firm_state_estabs_w_gvkey, clear // # of establishments per firm-state-year derived from ReferenceUSA/Infogroup, with gvkey 
rename year fyear // for Compustat merge
sort gvkey fyear


******** Merge in Compustat once to get CIK and link to databases that rely on CIK. Then we merge in Compustat again later to relevant sample (runs faster) **********
merge m:1 gvkey fyear using Data/Compustat_all_final
	qui drop bkvlps - _merge 

rename fyear year


************ CIK in VT or ST -- GJF coverage universe ********************
* File below derived directly from GJF parent header files which provide full list of CIKs in each dataset, supplemented by my own manual identification of historical parents 
merge m:1 cik using Data/VT_ST_cik_list_final, keep(3) // keep(3) ensures we only keep firms in the GJF coverage universe
	qui drop _merge

qui drop if year < 2002


********* CREATE GRID TO MERGE VIOLATION DATA AND SUBSIDY DATA ************
fillin gvkey state year

 * Create firm-state IDs
encode state, gen(state_factor)
qui gen tempcount = _n
so gvkey state year
qui by gvkey state: egen firmstate = min(tempcount) // since tempcount is unique to each identifier, this gives a common tempcount for each gvkey-state group

qui gen log_firmstate_estabs = log(firm_state_estabs) // estabs in each state-year for firm
qui gen is_HQ_state = (hqstate == state) // for descriptives 



************** FINANCIAL VARIABLES ***************************
rename year fyear
so gvkey fyear
merge m:1 gvkey fyear using Data/Compustat_all_final, keep(1 3) // Compustat raw data, with one add'l variable: roa = ni/l1.at
	qui drop _merge

qui gen lassets = log(at)
qui gen lev = dltt/at
qui gen mtb = prcc_f/bkvlps
qui gen ppe_scaled = ppent/at


	
******************************* Governor and state commissioner data
rename fyear sub_year
sort state sub_year
merge state sub_year using Data/Elections/AG_Gov_Party
qui drop if _merge==2
qui drop _merge

rename sub_year year



****************************************** FEDERAL VIOLATION DATA ********************************************************
merge 1:1 gvkey state year using Data/violations_firm_state_year, keep(1 3) // violations_firm_state_year is raw VT federal violation data aggregated to firm-state-year level
	qui drop _merge

qui replace penalty_total = 0 if penalty_total == .
	qui gen logpen_total = log(1 + penalty_total)

	
so gvkey year
	qui by gvkey year: egen firmyear_pen_total = sum( penalty_total)
		qui gen outofstate_pen_total = firmyear_pen_total  - penalty_total // penalty_total is in-state total
		qui gen logpen_outofstate_total = log(1+outofstate_pen_total)

* Violation indicators
qui gen dummy_nonfin_total = (logpen_total > 0) if logpen_total != .
qui gen dummy_outofstate_total = (outofstate_pen_total > 0) if outofstate_pen_total != .


so gvkey state
by gvkey: egen ever_rec_viol = max(dummy_nonfin_total)

xtset firmstate year

foreach v of varlist dummy_nonfin* logpen_* {
	qui gen `v'_lag1 = l1.`v'
	qui gen `v'_lag2 = l2.`v'
}

****************************************** STATE VIOLATION DATA ********************************************************
merge m:1 cik state year using Data/state_penalty_data, keep(1 3) // some obs have missing CIK -- we drop those later
	qui drop if _merge == 2
	qui drop _merge

qui replace has_state_penalty = 0 if has_state_penalty == .	// for relevant regressions remember that we will limit entire sample to the states with good coverage
	

****** SUBSIDY DATA *************
merge m:1 cik state year using Data/state_sub_connected, keep(1 3)

	qui drop _merge

	
qui gen connected_state = running_subsidy_years > 0 if running_subsidy_years != .
qui replace connected_state = 0 if connected_state == .


	
so gvkey state year
qui by gvkey state: egen ever_connected = sum(connected_state)
qui replace ever_connected = 1 if (ever_connected > 1 & ever_connected != .)


qui gen log_connected_sub_dollar = log(1 + running_subsidy_dollars)
	qui replace log_connected_sub_dollar= 0 if connected_state == 0
	qui replace log_connected_sub_dollar= . if connected_state == 1 & log_connected_sub_dollar == 0 // omit observations with MISSING subsidy $$ value

qui gen log_connected_sub_count = log(1+running_subsidy_count)
	qui replace log_connected_sub_count = 0 if connected_state == 0



***************** INHERITED SUBSIDIES *********************
so cik state year 
merge cik state year using "Data/inherited_subsidies.dta"
	qui drop if _merge == 2
	qui drop _merge
	qui replace connected_st_inherited = 0 if connected_st_inherited == .



	
************** MERGER SUBSAMPLE  -- LIMIT TO MERGERS THEN KEEP SAME FIRM/STATES ****************
so gvkey year
qui gen new_merger_connection = (years_since_inherited == 0)
qui by gvkey year: egen merger_firm_year = sum(new_merger_connection)
	qui replace merger_firm_year = 1 if merger_firm_year > 1 & merger_firm_year != .

xtset firmstate year
qui gen merger_twoyear_window = (merger_firm_year == 1 | l1.merger_firm_year == 1 | l2.merger_firm_year == 1 | f1.merger_firm_year == 1 | f2.merger_firm_year == 1  )
qui gen merger_threeyear_window = (merger_firm_year == 1 | l1.merger_firm_year == 1 | l2.merger_firm_year == 1 | l3.merger_firm_year == 1 | f1.merger_firm_year == 1 | f2.merger_firm_year == 1 | f3.merger_firm_year == 1 )



so state year
	merge state year using Data/Elections/governor_elections_2002_2018_basic
	qui gen electionyear = (_merge == 3)
	qui drop if _merge == 2
	qui drop _merge

foreach v of varlist newgovernor partychange {
	qui replace `v' = 0 if `v' == .
}


save Data/fully_merged_data_firm_state_year_final, replace



*********** BOARD DATA *********************
*** NOTE: Run the current file twice. The first time, stop here, export the board data, then run the corresponding R script to grab board connections data. 
*** Then, merge in the board data 
use Data/fully_merged_data_firm_state_year_final, clear


preserve // having come this far, export CIK for use in grabbing board data
qui keep cik 
	duplicates drop
	qui drop if cik == .
	qui gen cikstring = string(cik,"%08.0f")
	qui keep cikstring
	sort cikstring
export delim Data/cik_for_board_data_upload.txt, replace
restore




******* Political connections - all kinds ******
so gvkey state year
merge 1:1 gvkey state year using "Data/firm_state_year_PAC_sums", keep(1 3)
	qui drop _merge
	qui replace PAC_connected_state = 0 if PAC_connected_state == . // state-level PAC contributions 
	qui replace state_PAC_amount  = 0 if state_PAC_amount == .
		
	qui gen log_state_PAC_contrib = log(1+state_PAC_amount )
	qui gen has_state_PAC_contrib = log_state_PAC_contrib > 0 if log_state_PAC_contrib != .

	
	merge m:1 cik year using "Data/board_connections", keep(1 3)
		qui drop _merge
	merge m:1 gvkey state year using "Data/CEO_state_connections", keep(1 3)
		qui drop _merge
		qui replace PAC_state_CEO = 0 if PAC_state_CEO == .
		qui gen has_PAC_state_CEO = (PAC_state_CEO > 0) if PAC_state_CEO != .
	merge m:1 gvkey year using "Data/CEO_federal_connections", keep(1 3)
		qui drop _merge
		qui replace PAC_federal_CEO = 0 if PAC_federal_CEO == .
		qui gen has_PAC_federal_CEO = (PAC_federal_CEO > 0) if PAC_federal_CEO != .
		qui replace PAC_federal_CEO_dem = 0 if PAC_federal_CEO_dem == .
		qui gen has_PAC_federal_CEO_dem = (PAC_federal_CEO_dem  > 0) if PAC_federal_CEO_dem != .
		qui replace PAC_federal_CEO_rep = 0 if PAC_federal_CEO_rep == .
		qui gen has_PAC_federal_CEO_rep = (PAC_federal_CEO_rep > 0) if PAC_federal_CEO_rep != .
	merge m:1 gvkey year using "Data/corporate_federal_connections", keep(1 3)
		qui drop _merge
		qui replace PAC_federal_firm = 0 if PAC_federal_firm == .
		qui gen has_PAC_federal_firm = (PAC_federal_firm > 0) if PAC_federal_firm != .
		qui replace PAC_federal_firm_dem = 0 if PAC_federal_firm_dem == .
		qui gen has_PAC_federal_firm_dem = (PAC_federal_firm_dem  > 0) if PAC_federal_firm_dem != .
		qui replace PAC_federal_firm_rep = 0 if PAC_federal_firm_rep == .
		qui gen has_PAC_federal_firm_rep = (PAC_federal_firm_rep > 0) if PAC_federal_firm_rep != .
	merge m:1 gvkey year using "Data/corporate_federal_lobbying", keep(1 3)
		qui drop _merge
		qui replace lobbying_federal = 0 if lobbying_federal == .
		qui gen has_lobbying_federal = (lobbying_federal > 0) if lobbying_federal != .
		


* Political variables for Table 10
qui gen state_federal_opp_noconnect = (gov_party == "Democrat") * ((has_PAC_federal_firm_rep + has_PAC_federal_CEO_rep )== 0) * ((year < 2009) | (year >= 2017) ) + (gov_party == "Republican") * ((has_PAC_federal_firm_dem + has_PAC_federal_CEO_dem)== 0) * (year >= 2009 & year < 2017) 
qui gen unified_fullgov = (year >= 2003 & year <= 2006) | (year == 2009) |	(year == 2010)
		

	
	
******* Federal subsidies *************
merge m:1 cik year using Data/federal_subsidies_final, keep(1 3)
	qui drop _merge
	foreach v of varlist federal_subsidy_adjusted count_federal_subsidy_adjusted nonzero_federal_subsidy_adjusted has_federal_subsidy_adjusted {
		qui replace `v' = 0 if `v' == .
	}


*** running federal subsidies
qui gen prez_name = "Bush"
	qui replace prez_name = "Obama" if year >= 2009 & year < 2017
	qui replace prez_name = "Trump" if year >= 2017
	
so firmstate prez_name year
qui by firmstate prez_name: gen running_federal_sub_years = sum(has_federal_subsidy_adjusted)
	qui gen connected_federal = running_federal_sub_years > 0 if running_federal_sub_years != .
	
	
*********** TIME-SPECIFIC INDICATORS ***************
qui gen connected_state_post0 = (running_subsidy_years == 1) // running_subsidy_years equals 1 in the year of subsidy award, i.e., "t=0"
	qui gen connected_state_post1 = (running_subsidy_years == 2)
	qui gen connected_state_post2 = (running_subsidy_years == 3)
	qui gen connected_state_post3 = (running_subsidy_years == 4)
	qui gen connected_state_post4 = (running_subsidy_years == 5)
	qui gen connected_state_post5plus = (running_subsidy_years >= 6) & (running_subsidy_years != .)

qui replace has_state_sub_tplus1 = 0 if has_state_sub_tplus1 == . 
	qui replace has_state_sub_tplus2 = 0 if has_state_sub_tplus2 == .
	qui replace has_state_sub_tplus3 = 0 if has_state_sub_tplus3 == . // 
	qui replace has_state_sub_tplus4 = 0 if has_state_sub_tplus3 == . // 


qui gen upcoming_connection_1 = (has_state_sub_tplus1 == 1) & connected_state == 0 if has_state_sub_tplus1 != .
	qui gen upcoming_connection_2 = (has_state_sub_tplus2 == 1) & (has_state_sub_tplus1 == 0) & connected_state == 0 if (has_state_sub_tplus2 != . & has_state_sub_tplus1 != .)
	qui gen upcoming_connection_3 = (has_state_sub_tplus3 == 1) & (has_state_sub_tplus2 == 0) & (has_state_sub_tplus1 == 0) & connected_state == 0 if (has_state_sub_tplus3 != . & has_state_sub_tplus2 != . & has_state_sub_tplus1 != .)
	qui gen upcoming_connection_4 = (has_state_sub_tplus4 == 1) & (has_state_sub_tplus3 == 0) & (has_state_sub_tplus2 == 0) & (has_state_sub_tplus1 == 0) & connected_state == 0 if (has_state_sub_tplus3 != . & has_state_sub_tplus2 != . & has_state_sub_tplus1 != .)


	
********** Restrict to final sample period 	
qui drop if year < 2004 
qui drop if year > 2016 

********* DROP STATES WITH POOR SUBSIDY COVERAGE *******************
qui drop if (state=="AK"|state=="HI"|state=="PR"|state=="VI"|state=="DC" | state=="ND"|state=="NH"|state=="WY"|state=="DE"|state=="ID"|state=="SD"|state=="PA"|state=="RI"|state=="VT"|state=="MT")


**** Drop if no estabs in firm-state 
qui drop if log_firmstate_estabs == .
	
**** Drop utilities and with missing estabs
rename sic sic4
	qui replace sic4 = sich if sich != . // use historical SIC wherever it exists (vast majority of the time), header when it doesn't

qui gen sic2 = floor(sic4)
	qui drop if sic2 >= 60 & sic2 < 70 // drop financial firms 
	qui drop if sic2 == 49 // drop utilities -- these are already quasi-governmental and "subsidies" are commingled with normal contracts (==> measurement issues). 

	
save Data/fully_merged_data_firm_state_year_final, replace




log close



** cd to project directory here

log using "generate_sub_vars.log", replace nomsg
******** SUBSIDY DATA *************
import excel Data/subsidy_data_updated_withparents.xlsx, first clear


rename cik_at_subsidy_time cik
	drop current_cik 
	qui drop if cik == "Private"
	qui drop if cik == "False match"
	qui drop if cik == ""
	destring cik, replace
	rename sub_year year

keep cik state year subsidy_adjusted subsidy_level 

qui replace subsidy_level = lower(subsidy_level)
qui replace subsidy_level = "state" if subsidy_level == "multiple" // these are all combination state govt + local deals, where the state govt typically provides the lion's share of funding 


qui gen federal_subsidy_adjusted  = subsidy_adjusted  * (subsidy_level == "federal")
	qui gen local_subsidy_adjusted  = subsidy_adjusted  * (subsidy_level == "local")
	qui gen state_subsidy_adjusted  = subsidy_adjusted  * (subsidy_level == "state")


foreach x in "federal" "local" "state" {
    qui gen count_`x'_subsidy_adjusted = (subsidy_level == "`x'")
    qui gen nonzero_`x'_subsidy_adjusted = (subsidy_level == "`x'") * (subsidy_adjusted != 0)
	
}

collapse (sum) federal_sub local_sub state_sub count_* nonzero_* , by(cik state year)

foreach v of varlist federal_sub local_sub state_sub {
	qui gen has_`v' = (count_`v' > 0) if `v' != .
}

preserve
	qui drop if year > 2019
	collapse (sum) federal_sub local_sub state_sub  count_* nonzero_* has*, by(cik year)
		foreach v of varlist has* {
		    qui replace `v' = 1 if `v' > 1 & `v' != .
		}
	save Data/subsidies_firm_year, replace
restore

	qui drop if year < 2003
	qui drop if year > 2019
		

so cik state year	
save Data/subsidies_bytype_firm_state_year, replace

qui keep if has_federal_subsidy_adjusted == 1
keep cik year federal_subsidy_adjusted count_federal_subsidy_adjusted nonzero_federal_subsidy_adjusted has_federal_subsidy_adjusted
save Data/federal_subsidies_final, replace

import delim "Data/Elections/governor_elections_2002_2018_basic_info.csv", clear	
	qui gen year = election_year + 1 // if elected in year t, first year in power is t+1
	rename winner governor_name
	
fillin state year
qui replace pluralityparty = "D" if (pluralityparty == "I" | pluralityparty == "NAF" ) // This is Bill Walker in Alaska and Lincoln Chafee in RI -- both were de jure Independent but de facto Democrat

so state year
	foreach v of varlist governor_name pluralityparty {
		qui by state: replace `v' = `v'[_n-1] if `v' == "" // if incumbent governor remains
		qui by state: replace `v' = `v'[_n-1] if `v' == ""
		qui by state: replace `v' = `v'[_n-1] if `v' == ""
	}
	qui by state: replace governor_name = governor_name[_n - 1] if governor_name == ""


foreach v of varlist newgovernor partychange incumbent* {
	qui replace `v' = 0 if `v' == . & year > 2002
}

so state year
qui drop _fillin
save Data/Elections/governor_state_year, replace

*/

************ GENERATE CONNECTEDNESS VARIABLE -- MAIN SUBSIDY DATA **********
u Data/subsidies_bytype_firm_state_year, clear
	qui drop local_* federal_* has_local* has_federal*
	qui keep if has_state_subsidy_adjusted == 1 // we can merge federal subsidies back in later.

* Use fillin command for unique subsidy-state years
tostring cik, gen(cik_string)
qui gen firmstate = cik_string + state 
	qui drop cik_string
encode firmstate, gen(firmstate_enc)
fillin firmstate_enc year

* Now need to fill in missing values

decode firmstate_enc, gen(firmstate2)
	qui gen cik_string = substr(firmstate2, 1,length(firmstate2)-2)
	destring cik_string, replace
	qui drop cik
	rename cik_string cik
	
	qui gen state_string = substr(firmstate2, length(firmstate2)-1, 2)
	qui replace state = state_string
		qui drop state_string

so state year
merge m:1 state year using Data/Elections/governor_state_year, keep(3)
	qui drop _merge

foreach v of varlist has_* state_* count_* nonzero_* {
	qui replace `v' = 0 if `v' == .
}

	

encode governor_name, gen(governor_enc)
so firmstate_enc governor_name year 
	* NOTE gen, NOT egen in the below! This creates cumulative running connections.
	qui by firmstate_enc governor_name: gen running_subsidy_years = sum(has_state_subsidy_adjusted)
		qui gen connected_state = (running_subsidy_years > 0) if running_subsidy_years != .
	qui by firmstate_enc governor_name: gen running_subsidy_dollars = sum(state_subsidy_adjusted)
	qui by firmstate_enc governor_name: gen running_subsidy_count = sum(count_state_subsidy_adjusted)
	

* Create indicators for years since subsidy

* Future subsidy indicators (t+1, t+2, t+3)
xtset firmstate_enc year
	qui gen has_state_sub_tplus1 = f1.has_state_subsidy_adjusted
	qui gen has_state_sub_tplus2 = f2.has_state_subsidy_adjusted
	qui gen has_state_sub_tplus3 = f3.has_state_subsidy_adjusted
	qui gen has_state_sub_tplus4 = f4.has_state_subsidy_adjusted

keep cik state year running_* has_* state_* count_state_subsidy_adjusted nonzero_state*

so cik state year

save Data/state_sub_connected, replace


************* NOW: INHERITED SUBSIDIES ******************
* Raw subsidy tracker data with additional column that indicates when parent-subsidiary match was valid as of (allowing us to identify inherited subsidies)
import excel "Data/inherited_subsidies_full.xlsx", first clear
rename current_cik cik
qui drop cik_at_subsidy_time
	rename sub_year year
	
qui keep if year < sub_first_year & sub_first_year != . // first year subsidiary was owned by parent -- will always be after year of subsidy for inherited subs


keep cik state year sub_first_year subsidy_adjusted subsidy_level unique_id

	qui gen maindata = 1

so unique_id  // GJF unique identifier for each individual subsidy
append using "Data/Mergers/additional_inherited_from_thomson" // Merger data from SDC Platinum to supplement manually-identified data above
	qui replace maindata = 0 if maindata == . // keep track of what came from Thomson 
	
so unique_id cik sub_first_year
	duplicates drop unique_id cik, force // where there is a tie, keep the earlier merger as this is the first inheritance

so unique_id sub_first_year maindata
	duplicates drop unique_id sub_first_year, force

	
* Need to merge in governor data twice: granting governor and governor at time of subsidy inheritance. Keep when these are the same.
so state year
merge m:1 state year using Data/Elections/governor_state_year, keep(3) // merge once based on governor AT TIME OF SUBSIDY...
	qui drop _merge
	qui drop if governor_name == ""
	rename governor_name granting_governor_name
	

rename year sub_year // year of subsidy
rename sub_first_year year // year of merger 
keep cik state year sub_year subsidy_adjusted  subsidy_level granting_governor_name  


so state year
merge m:1 state year using Data/Elections/governor_state_year, keep(3) // ...and merge a second time based on governor AT TIME OF MERGER
	qui drop if _merge == 2
	qui drop _merge
	qui drop if governor_name == ""
	rename governor_name merger_governor_name

qui keep if granting_governor_name == merger_governor_name

keep cik state year sub_year subsidy_adjusted subsidy_level



qui replace subsidy_level = lower(subsidy_level)
qui replace subsidy_level = "state" if subsidy_level == "multiple"

qui gen inher_loc_subsidy_adjusted  = subsidy_adjusted  * (subsidy_level == "local")
qui gen inher_st_subsidy_adjusted  = subsidy_adjusted  * (subsidy_level == "state")



collapse (sum) inher*, by(cik state year)
foreach v of varlist inher*  {
	qui gen has_`v' = (`v' > 0) if `v' != .
}

so cik state year	

qui keep if has_inher_st_subsidy_adjusted == 1 

tostring cik, gen(cik_string)
qui gen firmstate = cik_string + state 
	qui drop cik_string
encode firmstate, gen(firmstate_enc)
fillin firmstate_enc year

* Now need to fill in missing values
decode firmstate_enc, gen(firmstate2)
	qui gen cik_string = substr(firmstate2, 1,length(firmstate2)-2)
	destring cik_string, replace
	qui drop cik
	rename cik_string cik
	
	qui gen state_string = substr(firmstate2, length(firmstate2)-1, 2)
	qui replace state = state_string
		qui drop state_string

so state year
merge m:1 state year using Data/Elections/governor_state_year, keep(3)

foreach v of varlist has_* inher_* {
	qui replace `v' = 0 if `v' == .
}
	
encode governor_name, gen(governor_enc)
so firmstate_enc governor_enc year 
	* NOTE gen, NOT egen in the below! This creates cumulative running connections.
	qui by firmstate_enc governor_enc: gen running_inher_subsidy_years = sum(has_inher_st_subsidy_adjusted)
		qui by firmstate_enc governor_enc: egen first_inher_year = min(year / (has_inher_st_subsidy_adjusted == 1))
		qui gen years_since_inherited = year - first_inher_year
		qui gen connected_st_inherited = (running_inher_subsidy_years  > 0) if running_inher_subsidy_years  != .
	qui by firmstate_enc governor_enc: gen running_inher_subsidy_dollars = sum(inher_st_subsidy_adjusted)


* Create indicators for years since subsidy

keep cik state year running_* has_* inher_* connected_st_inherited years_since_inherited
 
so cik state year
save Data/inherited_subsidies, replace



log close** cd to project directory here

log using "generate_pcon_vars.log", replace nomsg



******************** LOBBYING/PAC CONTRIBUTIONS **********************

*** CORPORATE STATE-LEVEL OFFICIAL PAC CONTRIBUTIONS ***
u "Data/Lobbying/contributed_amount_state", clear // firm-state-year aggregated contribution data fuzzy matched to include gvkey
	destring gvkey, replace
	rename fyear year
	tostring gvkey, gen(gvkey_string)
	qui gen firmstate = gvkey_string + state 
		qui drop gvkey_string
	encode firmstate, gen(firmstate_enc)
	fillin firmstate_enc year
	rename lobby_amount state_PAC_amount
	qui replace state_PAC_amount = 0 if state_PAC_amount == .


decode firmstate_enc, gen(firmstate2)
	qui gen gvkey_string = substr(firmstate2, 1,length(firmstate2)-2)
	destring gvkey_string, replace
	qui drop gvkey
	rename gvkey_string gvkey
	
	qui gen state_string = substr(firmstate2, length(firmstate2)-1, 2)
	qui replace state = state_string
		qui drop state_string


so state year
merge state year using Data/Elections/governor_state_year 
	qui drop if _merge == 2
	qui drop _merge
	qui drop if governor_name == ""
		
qui gen has_state_PAC_contrib = state_PAC_amount > 0 if state_PAC_amount  != .

foreach v of varlist has_state_PAC_contrib state_PAC_amount  {
	qui replace `v' = 0 if `v' == .
}


encode governor_name, gen(governor_enc)
so firmstate_enc governor_name year 
	* NOTE gen, NOT egen in the below! This creates cumulative running connections.
	qui by firmstate_enc governor_name: gen running_PAC_years = sum(state_PAC_amount)
		qui gen PAC_connected_state = (running_PAC_years > 0) if running_PAC_years != .
	qui by firmstate_enc governor_name: gen running_PAC_dollars = sum(state_PAC_amount)

	
	
xtset firmstate_enc year

qui keep gvkey state year state_PAC* PAC_connected_state running_PAC*

so gvkey state year
save "Data/firm_state_year_PAC_sums", replace

**** OTHER TYPES OF CONNECTIONS ****

* Board data, scraped from 10-K following approach in Goldman/Richoll/So 2009 and Houston et al. 2014 -- see R script
import delim "Data/DEF14A_scraped_connected_firms.csv", clear
	gen fdate_year = floor(fdate/10000)
	gen fdate_month = floor(mod(fdate,10000)/100)

qui gen year = fdate_year
	qui replace year = year - 1 if fdate_month < 8 // account for lag between fyear end and report date, match to fiscal yr
	qui drop fdate* 
** Types of connections -- state and federal 
* Federally connected
qui gen board_connected_federal = 0
foreach v of varlist prezcandidate prezcampaign senator houserep secstate sectreas secdefense attygen secinterior secagri seccommernce seclabor sechhs sechud sectransp secenergy seceducation secva sechomeland econcouncil traderep deputysec undersec asstsec chiefofstaff deputydir regionaldir assocdir mayor whitehouse commissioner ambassador partychair campaignstaff unrep cia epa deptoflabor osha msha whd frb fema cba {
    qui replace board_connected_federal = 1 if `v' == 1
}

qui gen board_connected_state = governorof + governorofthestate
	qui replace board_connected_state = 1 if board_connected_state == 2
	
qui keep cik year board_connected_federal board_connected_state
	duplicates drop cik year, force
save "Data/board_connections", replace

* CEO contributions, state
import delim "Data/CEO_state_compustat_CHECKED.csv", clear // hand-verified fuzzy matches of CEO contributions, with match to gvkey of CEO's employer

qui keep gvkey election_jurisdiction year datadate amount
	qui drop if amount < 0
	rename election_jurisdiction state
	
collapse (sum) amount, by(gvkey state year)
	rename amount PAC_state_CEO
save "Data/CEO_state_connections", replace

* CEO contributions, federal
use "Data/PAC_contributions_CEO_federal", clear // CEO PAC contributions merged to gvkey of CEO's employer
	rename amount PAC_federal_CEO
	rename amount_repub PAC_federal_CEO_repub 
	rename amount_dem PAC_federal_CEO_dem 
	save "Data/CEO_federal_connections", replace

* Corporate contributions, federal
use "Data/PAC_contributions_firm", clear // Corporate PAC contributions merged to gvkey
	rename amount PAC_federal_firm 
	rename amount_repub PAC_federal_firm_repub 
	rename amount_dem PAC_federal_firm_dem 
	save "Data/corporate_federal_connections", replace

* Lobbying, federal
use "Data/lobbying_with_gvkey.dta", clear // Corporate lobbying merged to gvkey
	rename total_lobbying lobbying_federal
	save "Data/corporate_federal_lobbying", replace



log close


** cd to project directory here

log using "process_mergers.log", replace nomsg


u Data/Mergers/US_Mergers_2003_2016, clear // SDC Platinum raw data

*** Public firms only

qui keep if apublic == "Public" 
qui drop if status == "Pending"
qui replace bookvalue = subinstr(bookvalue, ",","",.)
qui replace pe = . if pe == -8888

destring bookvalue, replace
duplicates drop

duplicates drop master_deal_no, force

* Consistent naming with Subsidy Tracker before merging
rename acusip current_cusip
rename amanames parent_name // acquirer
rename tmanames company // target

qui gen parent_clean = parent_name
qui gen company_clean = company
qui replace parent_clean = subinstr(parent_clean , "(","",.)
qui replace parent_clean = subinstr(parent_clean , ")","",.)
qui replace parent_clean = subinstr(parent_clean , " ","",.)
qui replace parent_clean = subinstr(parent_clean , ",","",.)
qui replace parent_clean = subinstr(parent_clean , "'","",.)
qui replace parent_clean = subinstr(parent_clean , ".","",.)
qui replace parent_clean = subinstr(parent_clean , "-","",.)

qui replace company_clean = subinstr(company_clean ,"(","",.)
qui replace company_clean = subinstr(company_clean ,")","",.)
qui replace company_clean = subinstr(company_clean ," ","",.)
qui replace company_clean = subinstr(company_clean ,",","",.)
qui replace company_clean = subinstr(company_clean ,"'","",.)
qui replace company_clean = subinstr(company_clean ,".","",.)
qui replace company_clean = subinstr(company_clean ,"-","",.)

so company_clean parent_clean
	qui drop if company_clean == parent_clean
	qui keep if status == "Completed"
	
sort company_clean parent_clean dateann
	duplicates drop company_clean parent_clean, force // some acquisitions are split into multiple deals, e.g., some equity is acquired then more is. account for each merger just once
save Data/Mergers/US_Mergers_2003_2016_CLEAN, replace

******* NOW FUZZY MATCH GJF to Thomson Reuters **************
u Data/subsidy_mergers_raw_for_thomson, clear // all subsidy recipients whose parent at time of receipt was different from subsequent parent 

qui gen company_clean = company
qui gen parent_clean = parent
	qui replace parent_clean = subinstr(parent_clean , "(","",.)
	qui replace parent_clean = subinstr(parent_clean , ")","",.)
	qui replace parent_clean = subinstr(parent_clean , " ","",.)
	qui replace parent_clean = subinstr(parent_clean , ",","",.)
	qui replace parent_clean = subinstr(parent_clean , "'","",.)
	qui replace parent_clean = subinstr(parent_clean , ".","",.)
	qui replace parent_clean = subinstr(parent_clean , "-","",.)

	qui replace company_clean = subinstr(company_clean ,"(","",.)
	qui replace company_clean = subinstr(company_clean ,")","",.)
	qui replace company_clean = subinstr(company_clean ," ","",.)
	qui replace company_clean = subinstr(company_clean ,",","",.)
	qui replace company_clean = subinstr(company_clean ,"'","",.)
	qui replace company_clean = subinstr(company_clean ,".","",.)
	qui replace company_clean = subinstr(company_clean ,"-","",.)

so company_clean parent_clean
save Data/Mergers/GJF_subsidy_mergers_clean, replace

reclink company_clean parent_clean  using Data/Mergers/US_Mergers_2003_2016_CLEAN, gen(matchscore) idm(unique_for_match) idu(master_deal) wmatch(20 5)
	qui keep if _merge == 3

qui keep company_clean parent_clean Ucompany_clean Uparent_clean matchscore
rename Ucompany_clean thomson_company_clean
rename Uparent_clean thomson_parent_clean
rename company_clean GJFcompany_clean
rename parent_clean GJFparent_clean

export delim Data/Mergers/GJF_SDC_fuzzy_tocheck.csv, replace 

*** NOW HAND CHECK MATCHES ****
************* MAKING IT USABLE ***************
import delim "Data/Mergers/GJF_ThomsonSDC_fuzzy_checked.csv", clear // hand-checked 
	qui keep if truematch == 1
	
rename gjfcompany_clean company_clean
rename gjfparent_clean parent_clean

so company_clean parent_clean
merge company_clean parent_clean using Data/Mergers/GJF_subsidy_mergers_clean
	qui keep if _merge == 3
	drop _merge
	rename company_clean gjfcompany_clean
	rename parent_clean gjfparent_clean

rename thomson_company_clean company_clean
rename thomson_parent_clean parent_clean

so company_clean parent_clean
merge company_clean parent_clean using  "Data/Mergers/US_Mergers_2003_2016_CLEAN"
	qui keep if _merge == 3
	drop _merge
	
qui keep *clean* dateann dateeff aup company parent_name
	duplicates drop
	
rename company_clean thomson_company_clean
rename parent_clean thomson_parent_clean

rename aup cusip6
qui keep cusip6 gjf* dateann dateeff company parent_name thomson_parent_clean // figure out relevant subsidy-state-years by merging to main GJF data, then match cusip to gvkey!
	qui gen year = year(dateeff)
so cusip6 year
save "Data/Mergers/subsidy_acquirers", replace

u "Data/gvkey_cusip_cik_clean.dta", clear
qui gen cusip6 = substr(ncusip,1,6)
qui keep gvkey cik cusip6 fyear
	rename fyear year
	qui drop if cusip6 == ""

duplicates drop

so cusip6 year
merge cusip6 year using "Data/Mergers/subsidy_acquirers"
	qui drop if _merge == 1
	drop _merge

so parent_name company // used for merging w/GJF -- note that parent_name here is GJF PARENT, so we can name merge later
	drop gjf*
save "Data/Mergers/subsidy_acquirers", replace


*** NOW MERGE IN SUBSIDY DATA *****
import excel "Data/inherited_subsidies_full.xlsx", first clear
qui keep parent_name company cik state sub_year subsidy_adjusted subsidy_classification subsidy_level unique_id
qui drop if parent_name == ""

so parent_name company
merge parent_name company using "Data/Mergers/subsidy_acquirers" // recall again that parent_name and company are consistently derived from GJF across sources to enable name matching
	qui keep if _merge == 3
	drop _merge

* Change naming convention to match other files
rename year sub_first_year
rename sub_year year

qui keep if year < sub_first_year // only keep obs where merger happened after subsidy year

qui keep cik state year sub_first_year subsidy_adjusted subsidy_classification subsidy_level unique_id
	qui drop if cik == .

so unique_id 
save "Data/Mergers/additional_inherited_from_thomson", replace

log close