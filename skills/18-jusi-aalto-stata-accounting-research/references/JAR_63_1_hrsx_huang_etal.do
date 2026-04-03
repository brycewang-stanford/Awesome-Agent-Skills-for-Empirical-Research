clear all
set matsize 1000
cd "C:\Users\27273\Desktop\Third Round for JAR\STATA DATA&CODE\"
log using stata_log, replace 

    *firm_year is generated from SAS code in Step 03*
    use firm_year, clear 
 	*fix sich: backfill with the latest ones
	sort gvkey fyear
	by gvkey: gen I=sich if sich[_n-1]==.&sich[_n]~=.
	by gvkey: gen I1=fyear if sich[_n-1]==.&sich[_n]~=.
	by gvkey: egen max=max(sich)
	by gvkey: egen max1=max(I1)
	replace sich=max if fyear<max1&sich==.
	rename sic sic4_string
	destring(sic4_string),gen(sic)
	replace sich=sic if sich==.&sic~=.
	drop I I1 max max1
	tostring(sich),gen (sich_string)
	gen len=length(sich_string)
	replace sich_string="0"+sich_string if len==3
	drop if len==1
	drop len
	gen sich2=substr(sich_string,1,2) 

	keep gvkey datadate sich
	save gvkey_sich, replace 

	*westlaw data
	*westlaw_data is obtained from the Free Law Project that covers the other types of cases handled by judges*
	use westlaw_data, clear
   	local list="Agriculture AntitrustTradeRegulation Appeals Bankruptcy BusinessOrganizations CivilRights CommercialLawandContracts ConstitutionalLaw CreditorDebtor CriminalJustice Education EmploymentLabor Environmental FinanceandBanking Government Health Insurance IntellectualPropertyCopyrigh IntellectualPropertyPatents IntellectualPropertyTrademar LandlordTenant MaritimeLaw MilitaryLaw Other RealProperty Remedies SecuritiesLaw Tax TortsNegligence Transportation Veterans Writs Administrative ArbitrationADR Communications ImmigrationLaw EnergyandUtilities DomesticRelationsFamilyLaw MotorVehicles ProfessionalResponsibility SmallClaims WillsTrustsandEstates Liens Construction IntellectualPropertyGenerally NameChange"
	foreach var of local list{
		replace `var'=0 if `var'==.
	}
	
    egen total_cases=rsum(Agriculture AntitrustTradeRegulation Appeals Bankruptcy BusinessOrganizations CivilRights CommercialLawandContracts ConstitutionalLaw CreditorDebtor CriminalJustice Education EmploymentLabor Environmental FinanceandBanking Government Health Insurance IntellectualPropertyCopyrigh IntellectualPropertyPatents IntellectualPropertyTrademar LandlordTenant MaritimeLaw MilitaryLaw Other RealProperty Remedies SecuritiesLaw Tax TortsNegligence Transportation Veterans Writs Administrative ArbitrationADR Communications ImmigrationLaw EnergyandUtilities DomesticRelationsFamilyLaw MotorVehicles ProfessionalResponsibility SmallClaims WillsTrustsandEstates Liens Construction IntellectualPropertyGenerally NameChange)
  
    egen total_civil_cases=rsum(Agriculture AntitrustTradeRegulation Appeals Bankruptcy BusinessOrganizations CivilRights CommercialLawandContracts CreditorDebtor CriminalJustice Education EmploymentLabor Environmental FinanceandBanking Government Health Insurance IntellectualPropertyCopyrigh IntellectualPropertyPatents IntellectualPropertyTrademar LandlordTenant Other RealProperty Remedies SecuritiesLaw Tax TortsNegligence Transportation Veterans Writs Administrative ArbitrationADR Communications ImmigrationLaw EnergyandUtilities DomesticRelationsFamilyLaw MotorVehicles ProfessionalResponsibility SmallClaims WillsTrustsandEstates Liens Construction IntellectualPropertyGenerally NameChange)
    
	gen security_cases=SecuritiesLaw
	rename Year filing_year
	rename nid final_nid 
 
    keep final_nid filing_year total_cases total_civil_cases security_cases
    duplicates drop final_nid filing_year, force 
 
    save westlaw1, replace 
	
	*outcome2024 is generated from SAS code in Step 07*
    use outcome2024, clear 
	drop sich 
	merge m:1 gvkey datadate using gvkey_sich
	drop if _merge==2
	drop _merge

	gen filing_year=year(filing_date)
	generate dismissed=0 
    replace dismissed=1 if status=="dismissed"  
    generate settled=0 
    replace settled=1 if status=="settled"
  
    generate ongoing=0 
    replace ongoing=1 if status=="ongoing"  
    keep if ongoing==0
    keep if misleading_disc==1 
    keep if final_gvkey~=. 

	
  	*FF48 industry 
                gen ind=.
                replace ind=1 if 99<sich&sich<800|sich==2048
                replace ind=2 if 1999<sich&sich<2047|2049<sich&sich<2064|2069<sich&sich<2080|2089<sich&sich<2096|2097<sich&sich<2100
                replace ind=3 if 2063<sich&sich<2069|2085<sich&sich<2088|2095<sich&sich<2098
                replace ind=4 if 2079<sich&sich<2086
                replace ind=5 if 2099<sich&sich<2200
                replace ind=6 if 899<sich&sich<1000|3649<sich&sich<3653|sich==3732|3929<sich&sich<3950
                replace ind=7 if 7799<sich&sich<7842|7899<sich&sich<8000
    replace ind=8 if 2699<sich&sich<2750|2769<sich&sich<2800
                replace ind=9 if sich==2047|sich==2391|sich==2392|2509<sich&sich<2520|2589<sich&sich<2600|2839<sich&sich<2845|3159<sich&sich<3200|3228<sich&sich<3232|sich==3260|sich==3262|sich==3263|sich==3269|3629<sich&sich<3640|3749<sich&sich<3752|sich==3800|3859<sich&sich<3880|3909<sich&sich<3920|3959<sich&sich<3962|sich==3991|sich==3995
    replace ind=10 if 2299<sich&sich<2391|3019<sich&sich<3022|3099<sich&sich<3112|3129<sich&sich<3160|sich==3965
                replace ind=11 if 7999<sich&sich<8100
                replace ind=12 if sich==3693|3839<sich&sich<3852
                replace ind=13 if 2829<sich&sich<2837
                replace ind=14 if 2799<sich&sich<2830|2849<sich&sich<2900
    replace ind=15 if sich==3000|3049<sich&sich<3100
                replace ind=16 if 2199<sich&sich<2296|2296<sich&sich<2300|2392<sich&sich<2396|2396<sich&sich<2400
    replace ind=17 if 799<sich&sich<900|2399<sich&sich<2440|2449<sich&sich<2460|2489<sich&sich<2500|2949<sich&sich<2953|3199<sich&sich<3220|3239<sich&sich<3260|sich==3261|sich==3264|3269<sich&sich<3300|3419<sich&sich<3443|3445<sich&sich<3453|3489<sich&sich<3500|sich==3996
                replace ind=18 if 1499<sich&sich<1550|1599<sich&sich<1700|1699<sich&sich<1800
                replace ind=19 if 3299<sich&sich<3370|3389<sich&sich<3400
                replace ind=20 if sich==3400|3442<sich&sich<3445|3459<sich&sich<3480
                replace ind=21 if 3509<sich&sich<3537|3539<sich&sich<3570|3579<sich&sich<3600
                replace ind=22 if 3599<sich&sich<3622|3622<sich&sich<3630|3639<sich&sich<3647|3647<sich&sich<3650|sich==3660|3690<sich&sich<3693|sich==3699
    replace ind=23 if sich==3900|sich==3990|sich==3999|9899<sich&sich<10000
                replace ind=24 if sich==2296|sich==2396|3009<sich&sich<3012|sich==3537|sich==3647|sich==3694|3699<sich&sich<3717|3798<sich&sich<3800
                replace ind=25 if 3719<sich&sich<3730
                replace ind=26 if 3729<sich&sich<3732|739<sich&sich<3744
                replace ind=27 if 3479<sich&sich<3490|3759<sich&sich<3770|sich==3795
    replace ind=28 if 1039<sich&sich<1050
    replace ind=29 if 999<sich&sich<1040|1059<sich&sich<1100|1399<sich&sich<1500
                replace ind=30 if 1199<sich&sich<1300
                replace ind=31 if 1309<sich&sich<1390|2899<sich&sich<2912|2989<sich&sich<3000
    replace ind=32 if 4899<sich&sich<5000
                replace ind=33 if 4799<sich&sich<4900
    replace ind=34 if 7019<sich&sich<7022|7029<sich&sich<7040|7199<sich&sich<7213|7214<sich&sich<7300|sich==7395|sich==7500|7519<sich&sich<7550|7599<sich&sich<7700|8099<sich&sich<8500|8599<sich&sich<8700|8799<sich&sich<8900
                replace ind=35 if 2749<sich&sich<2760|sich==3993|7299<sich&sich<7373|7373<sich&sich<7395|sich==7397|sich==7399|7509<sich&sich<7520|8699<sich&sich<8749|8899<sich&sich<9000
                replace ind=36 if 3569<sich&sich<3580|3679<sich&sich<3690|sich==3695|sich==7373
                replace ind=37 if sich==3622|3660<sich&sich<3680|sich==3810|sich==3812
                replace ind=38 if sich==3811|3819<sich&sich<3831
                replace ind=39 if 2519<sich&sich<2550|2599<sich&sich<2640|2669<sich&sich<2700|2759<sich&sich<2762|3949<sich&sich<3956
    replace ind=40 if 2439<sich&sich<2450|2639<sich&sich<2660|3209<sich&sich<3222|3409<sich&sich<3413
                replace ind=41 if 3999<sich&sich<4300|4399<sich&sich<4800
                replace ind=42 if 4999<sich&sich<5200
                replace ind=43 if 5199<sich&sich<5737|5899<sich&sich<6000
                replace ind=44 if 5799<sich&sich<5814|5889<sich&sich<5891|6999<sich&sich<7020|7039<sich&sich<7050|sich==7213
    replace ind=45 if 5999<sich&sich<6200
    replace ind=46 if 6299<sich&sich<6412
    replace ind=47 if 6499<sich&sich<6554
    replace ind=48 if 6199<sich&sich<6300|6699<sich&sich<6800
                replace ind=48 if ind==.
                rename ind ffind48
    
	destring sic, replace
    
	*circuit court
	gen circuit_court=. 
    replace circuit_court=1 if court_state=="ME" | court_state=="MA" | court_state=="NH" | court_state=="RI" | court_state=="PR"
    replace circuit_court=2 if court_state=="CT" | court_state=="NY" | court_state=="VT"
    replace circuit_court=3 if court_state=="DE" | court_state=="NJ" | court_state=="PA" | court_state=="VI"
    replace circuit_court=4 if court_state=="MD" | court_state=="NC" | court_state=="SC" | court_state=="WV" | court_state=="VA"
    replace circuit_court=5 if court_state=="LA" | court_state=="TX" | court_state=="MS" 
    replace circuit_court=6 if court_state=="KY" | court_state=="MI" | court_state=="OH" | court_state=="TN" 
    replace circuit_court=7 if court_state=="IL" | court_state=="IN" | court_state=="WI" 
    replace circuit_court=8 if court_state=="AR" | court_state=="IA" | court_state=="MO" | court_state=="MN" | court_state=="NE" | court_state=="SD" | court_state=="ND"
    replace circuit_court=9 if court_state=="AK" | court_state=="AZ" | court_state=="CA" | court_state=="HI" | court_state=="ID" | court_state=="OR" | court_state=="MT" | court_state=="NV" | court_state=="WA"
    replace circuit_court=10 if court_state=="CO" | court_state=="KS" | court_state=="NM" | court_state=="OK" | court_state=="UT" | court_state=="WY" 
    replace circuit_court=11 if court_state=="AL" | court_state=="FL" | court_state=="GA"
    replace circuit_court=12 if court_state=="DC" 

    gen circuit_court_hq=. 
    replace circuit_court_hq=1 if new_state=="ME" | new_state=="MA" | new_state=="NH" | new_state=="RI" | new_state=="PR"
    replace circuit_court_hq=2 if new_state=="CT" | new_state=="NY" | new_state=="VT"
    replace circuit_court_hq=3 if new_state=="DE" | new_state=="NJ" | new_state=="PA" | new_state=="VI"
    replace circuit_court_hq=4 if new_state=="MD" | new_state=="NC" | new_state=="SC" | new_state=="WV" | new_state=="VA"
    replace circuit_court_hq=5 if new_state=="LA" | new_state=="TX" | new_state=="MS" 
    replace circuit_court_hq=6 if new_state=="KY" | new_state=="MI" | new_state=="OH" | new_state=="TN" 
    replace circuit_court_hq=7 if new_state=="IL" | new_state=="IN" | new_state=="WI" 
    replace circuit_court_hq=8 if new_state=="AR" | new_state=="IA" | new_state=="MO" | new_state=="MN" | new_state=="NE" | new_state=="SD" | new_state=="ND"
    replace circuit_court_hq=9 if new_state=="AK" | new_state=="AZ" | new_state=="CA" | new_state=="HI" | new_state=="ID" | new_state=="OR" | new_state=="MT" | new_state=="NV" | new_state=="WA"
    replace circuit_court_hq=10 if new_state=="CO" | new_state=="KS" | new_state=="NM" | new_state=="OK" | new_state=="UT" | new_state=="WY" 
    replace circuit_court_hq=11 if new_state=="AL" | new_state=="FL" | new_state=="GA"
    replace circuit_court_hq=12 if new_state=="DC" 

   
*connection measures*

  keep if  nid_ruling~="" | nid_initial~=""

*connection by ruling judge*
  generate connect01r=0 
  replace connect01r=1 if connection_rule1>0 & connection_rule1~=. 
  replace connect01r=. if connection_rule1==. 
  replace connect01r=. if nid_ruling==""
 
  generate connect02r=0 
  replace connect02r=1 if connection_rule2>0 & connection_rule2~=. 
  replace connect02r=. if connection_rule1==. 
  replace connect02r=. if nid_ruling==""

  generate connect03r=0 
  replace connect03r=1 if connection_rule3>0 & connection_rule3~=. 
  replace connect03r=. if connection_rule1==. 
  replace connect03r=. if nid_ruling==""

  generate connect04r=0 
  replace connect04r=1 if connection_rule4>0 & connection_rule4~=. 
  replace connect04r=. if connection_rule1==. 
  replace connect04r=. if nid_ruling==""

  generate connect04r_law=0 
  replace connect04r_law=1 if connection_rule4_law>0 & connection_rule4_law~=. 
  replace connect04r_law=. if connection_rule1==. 
  replace connect04r_law=. if nid_ruling==""


*connection by initial judge* 
  generate connect01i=0 
  replace connect01i=1 if connection_initial1>0 & connection_initial1~=. 
  replace connect01i=. if connection_initial1==. 

  generate connect02i=0 
  replace connect02i=1 if connection_initial2>0 & connection_initial2~=. 
  replace connect02i=. if connection_initial1==. 

  generate connect03i=0 
  replace connect03i=1 if connection_initial3>0 & connection_initial3~=. 
  replace connect03i=. if connection_initial1==. 

  generate connect04i=0 
  replace connect04i=1 if connection_initial4>0 & connection_initial4~=. 
  replace connect04i=. if connection_initial1==. 

  generate connect04i_law=0 
  replace connect04i_law=1 if connection_initial4_law>0 & connection_initial4_law~=. 
  replace connect04i_law=. if connection_initial1==. 

*final connection meansure
  gen connect04=connect04r 
  replace connect04=connect04i if connect04r==. & connect04i~=.
  
  gen connect04_law=connect04r_law 
  replace connect04_law=connect04i_law if connect04r_law==. & connect04i_law~=.
  
  gen connect02=connect02r 
  replace connect02=connect02i if connect02r==. & connect02i~=.
  
  gen connect01=connect01r 
  replace connect01=connect01i if connect01r==. & connect01i~=.
  
  gen connect03=connect03r 
  replace connect03=connect03i if connect03r==. & connect03i~=.
   
***def versus nondef
  generate connect04r_def=0 
  replace connect04r_def=1 if connection_rule4_def>0 & connection_rule4_def~=. 
  replace connect04r_def=. if connection_rule1==.
  replace connect04r_def=. if nid_ruling==""
  generate connect04r_nondef=0 
  replace connect04r_nondef=1 if connection_rule4_nondef>0 & connection_rule4_nondef~=. 
  replace connect04r_nondef=. if connection_rule1==. 
  replace connect04r_nondef=. if nid_ruling==""
  generate connect04i_def=0 
  replace connect04i_def=1 if connection_initial4_def>0 & connect04i==1
  replace connect04i_def=. if connection_initial1==.
  generate connect04i_nondef=0 
  replace connect04i_nondef=1 if connection_initial4_nondef>0 & connect04i==1 
  replace connect04i_nondef=. if connection_initial1==.
  gen connect04_def=connect04r_def 
  replace connect04_def=connect04i_def if connect04r_def==. & connect04i_def~=.
  gen connect04_nondef=connect04r_nondef 
  replace connect04_nondef=connect04i_nondef if connect04r_nondef==. & connect04i_nondef~=.
  gen connect04_defendant=0 
  replace connect04_defendant=1 if num_defendant>0 & connect04_def==1
  gen connect04_nondefendant=0 
  replace connect04_nondefendant=1 if connect04==1 & connect04_defendant==0
  gen dummy_defendant=0 
  replace dummy_defendant=1 if num_defendant>0

*connection between defendant/plaintiff lawyer and judge *
  gen connect04r_leaddeflawyer=. 
  replace connect04r_leaddeflawyer=0 if connection_rule4_leaddeflawyer==0 
  replace connect04r_leaddeflawyer=1 if connection_rule4_leaddeflawyer>0 & connection_rule1_leaddeflawyer~=. 

  gen connect04r_leadplalawyer=. 
  replace connect04r_leadplalawyer=0 if connection_rule4_leadplalawyer==0 
  replace connect04r_leadplalawyer=1 if connection_rule4_leadplalawyer>0 & connection_rule1_leadplalawyer~=. 

  gen connect04i_ldeflawyer=. 
  replace connect04i_ldeflawyer=0 if connection_initial4_ldeflawyer==0 
  replace connect04i_ldeflawyer=1 if connection_initial4_ldeflawyer>0 & connection_initial1_ldeflawyer~=. 

  gen connect04i_lplalawyer=. 
  replace connect04i_lplalawyer=0 if connection_initial4_lplalawyer==0 
  replace connect04i_lplalawyer=1 if connection_initial4_lplalawyer>0 & connection_initial1_lplalawyer~=.

  gen connect04_leaddeflawyer=connect04r_leaddeflawyer
  replace connect04_leaddeflawyer=connect04i_ldeflawyer if connect04r==. & connect04i~=.
  gen connect04_leadplalawyer=connect04r_leadplalawyer
  replace connect04_leadplalawyer=connect04i_lplalawyer if connect04r==. & connect04i~=.  
  replace connect04_leaddeflawyer=0 if connect04_leaddeflawyer==.
  replace connect04_leadplalawyer=0 if connect04_leadplalawyer==.
  
  
*dependent variables and controls*
  replace settlem=0 if dismissed==1 
  generate ln_payout=ln(1+settlem) 
  generate ln_payout1=ln(settlem)
  generate deal_days=status_date-filing_date
  generate ln_deal_days=ln(deal_days)

  gen provable_loss1=(highest_mkt-first_mkt)/highest_mkt
  gen provable_loss2=highest_mkt-first_mkt
  replace provable_loss2=provable_loss2/1000

  generate diff_days=class_end-class_start
  generate horizon=ln(1+diff_days) 
  replace unemp_rate=unemp_rate/100 
 
  generate liti_ind=0 
  replace liti_ind=1 if sich>=2833 & sich<=2836 | sich>=8731 & sich<=8734 | sich>=3570 & sich<=3577 | sich>=7370 & sich<=7374
  replace liti_ind=1 if sich>=3670 & sich<=3674 | sich>=5200 & sich<=5961
  gen ks_index=-7.883+0.566*liti_ind+0.518*lag_firm_size1+0.982*lag_sale_growth+0.379*lag_adjret12-0.108*lag_ret_skew+25.635*lag_std_ret+0.00007*lag_turnover
	
  replace num_ana=0 if num_ana==. 
  generate analyst=ln(1+num_ana) 
  replace num_aaer1_filing=0 if num_aaer1_filing==. 
  replace num_aaer2_filing=0 if num_aaer2_filing==. 
  gen sec_investigation=0
  replace sec_investigation=1 if num_aaer1_filing>0 | num_aaer2_filing>0 

  replace sum_res_accounting1=0 if sum_res_accounting1==. 
  replace sum_res_fraud1=0 if sum_res_fraud1==. 
  gen restatement=0 
  replace restatement=1 if sum_res_accounting1>0 | sum_res_fraud1>0
  gen security_offering=0 
  replace security_offering=1 if n_security_offering>0 
   
*judge personal characteristics*****
  
  replace Gender=gender1 if nid_ruling=="" & nid_initial~=""
  gen female=0  
  replace female=1 if Gender=="Female"

  replace Birth_Year=birth_year1 if nid_ruling=="" & nid_initial~=""
  destring Birth_Year, replace 
  gen age=filing_year-Birth_Year
  replace age=60 if age==. 
  
  replace Race_or_Ethnicity=Race_or_Ethnicity1 if nid_ruling=="" & nid_initial~=""  
  gen white=0 
  replace white=1 if Race_or_Ethnicity=="White"
 
  replace Party_of_Appointing_President=Party_of_Appointing_President1 if nid_ruling=="" & nid_initial~=""  
  gen democratic=0 
  replace democratic=1 if Party_of_Appointing_President=="Democratic"
  
  replace Birth_State=birth_state1 if nid_ruling=="" & nid_initial~="" 
  gen local_judge=0 
  replace local_judge=1 if Birth_State==new_state 
  
  gen final_nid=nid_ruling 
  replace final_nid=nid_initial if nid_ruling==""
  destring final_nid, replace 
  egen judge_fe=group(final_nid)
 
  merge m:1 final_nid filing_year using westlaw1
  drop if _merge==2
  drop _merge
  
  *judge_number_case is generated from SAS code in Step 09*
  merge m:1 final_nid filing_year using judge_number_case
  drop if _merge==2
  drop _merge

  local list="diff_days horizon ln_deal_days deal_days settlem ln_payout1 ln_payout liti_ind lag_firm_size lag_firm_size1 lag_lev lag_roa lag_sale_growth lag_inst lag_bm analyst lag_std_ret lag_ret_skew lag_adjret12 lag_turnover lag_mret12 unemp_rate gdp_growth provable_loss1 provable_loss2 "
	foreach var of local list{
		centile `var',c(1 99)
		replace `var'=r(c_1) if `var'<r(c_1)&`var'~=.
		replace `var'=r(c_2) if `var'>r(c_2)&`var'~=.
	}
	
  keep if connect04~=. 
  replace ipo_misreporting=0 if ipo_misreporting==. 
  drop if ipo_laddering==1 & ipo_misreporting==0 
  drop if ipo_misreporting==1
	
  local list="horizon car_n1p1_ffvalue ks_index lag_firm_size1 lag_lev lag_roa loss lag_inst analyst lag_mret12 gc exe_law unemp_rate gdp_growth blue holding female age white democratic local_judge provable_loss1 insider_trading_allegation gaap_allegation sec_investigation restatement security_offering connect04_leaddeflawyer connect04_leadplalawyer"
	foreach var of local list{
		drop if `var'==.  
	}
     
  egen firm=group(final_gvkey)
  egen state_in=group(new_state) 
  egen state_court=group(court_state) 
  egen court=group(district_court)
 
  pwcorr provable_loss2 settlem if dismissed==0, sig
  
  replace num4_news=0 if num4_news==. 
  replace n_news2000=0 if n_news2000==.
  replace num4_news=n_news2000 if year(filing_date)<2000
  gen news_coverage=ln(1+num4_news)
  winsor2 news_coverage, cuts(1 99) replace 
 

*==============================================================================*
**TABLE 2 SUMMARY STATISTICS**
*==============================================================================*

***Panel A***
sum fyear 
sum fyear if appeal==1 
sum fyear if appeal==1 & reassigned_indicator==1 
sum fyear if appeal==1 & reassigned_indicator==0 
sum fyear if appeal==0 & reassigned_indicator==1 
sum fyear if appeal==0 & reassigned_indicator==0 

***Panel B***
sum fyear if connect04i==1 
sum fyear if connect04i==0

sum recusal_indicator if connect04i==1 
sum recusal_indicator if connect04i==0 
ttest recusal_indicator, by(connect04i)

sum appeal if connect04i==1 
sum appeal if connect04i==0
ttest appeal, by(connect04i) 

gen dismissed_re=dismissed
replace dismissed_re=1 if district_trial_outcome==1 | district_trial_outcome==4
replace dismissed_re=0 if district_trial_outcome==2 | district_trial_outcome==3

sum appeal if connect04i==1  & dismissed_re==1
sum appeal if connect04i==0  & dismissed_re==1
ttest appeal if dismissed_re==1, by(connect04i)

gen unappeal_dismissed=0 
replace unappeal_dismissed=1 if appeal==0 | (dismissed==1 & appeal==1)
sum unappeal_dismissed if connect04i==1 & dismissed_re==1 
sum unappeal_dismissed if connect04i==0 & dismissed_re==1 
ttest unappeal_dismissed if dismissed_re==1, by(connect04i)

***Panel C***
winsor2 judge_number_case, cuts(1 99) replace 

gen judge_case_per1=judge_number_case/total_cases
gen judge_case_per2=judge_number_case/total_civil_cases
gen judge_case_per3=judge_number_case/security_cases

ttest judge_case_per1, by(connect04)
ttest judge_case_per2, by(connect04)
ttest judge_case_per3, by(connect04)

*==============================================================================*
**TABLE 3 IN THE SAS CODE**
*==============================================================================*
 
*==============================================================================*
**TABLE 4 UNIVARIATE ANALYSES**
*==============================================================================*
 
ttest dismissed, by(connect04)
ttest ln_deal_days, by(connect04)
ttest ln_payout, by(connect04)
ttest horizon, by(connect04)
ttest car_n1p1_ffmvalue, by(connect04) 
ttest provable_loss1, by(connect04)
ttest news_coverage, by(connect04) 
ttest insider_trading_allegation, by(connect04) 
ttest gaap_allegation, by(connect04) 
ttest sec_investigation, by(connect04) 
ttest restatement, by(connect04) 
ttest security_offering, by(connect04) 
ttest connect04_leaddeflawyer, by(connect04)
ttest connect04_leadplalawyer, by(connect04)
ttest gc, by(connect04) 
ttest exe_law, by(connect04) 
ttest ks_index, by(connect04) 
ttest lag_firm_size, by(connect04)    
ttest lag_lev, by(connect04)
ttest lag_roa, by(connect04) 
ttest loss, by(connect04) 
ttest lag_inst, by(connect04) 
ttest analyst, by(connect04) 
ttest lag_mret12, by(connect04) 
ttest holding, by(connect04) 
ttest female, by(connect04) 
ttest age, by(connect04) 
ttest white, by(connect04) 
ttest democratic, by(connect04) 
ttest local_judge, by(connect04)
ttest unemp_rate, by(connect04)
ttest gdp_growth, by(connect04) 
ttest blue, by(connect04) 

*==============================================================================*
**Table 5 BASELINE RESULTS**
*==============================================================================*

	global didcontrol01="horizon car_n1p1_ffmvalue provable_loss1 news_coverage insider_trading_allegation gaap_allegation sec_investigation restatement security_offering connect04_leaddeflawyer connect04_leadplalawyer gc exe_law  ks_index lag_firm_size1 lag_lev lag_roa loss lag_inst analyst lag_mret12 holding female age white democratic local_judge unemp_rate gdp_growth blue" 

  ***Table 5 Panel A***
  xi: logit dismissed connect04 i.ffind48 i.fyear i.state_in i.circuit_court, cluster(firm)
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) replace	 
  xi: logit dismissed connect04 $didcontrol01 i.ffind48 i.fyear i.state_in i.circuit_court, cluster(firm)
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append 
  xi: reghdfe dismissed connect04, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe dismissed connect04 $didcontrol01, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe dismissed connect04 $didcontrol01, abs(ffind48 fyear state_in circuit_court judge_fe) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  
  ***Table 5 Panel B***
  xi: reghdfe ln_deal_days connect04, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) replace	  
  xi: reghdfe ln_deal_days connect04 $didcontrol01, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_deal_days connect04 $didcontrol01, abs(ffind48 fyear state_in circuit_court judge_fe) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_deal_days connect04 dismissed $didcontrol01, abs(ffind48 fyear state_in circuit_court judge_fe) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  
  xi: reghdfe ln_payout connect04,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append  
  xi: reghdfe ln_payout connect04 $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append 
  xi: reghdfe ln_payout connect04 $didcontrol01, abs(ffind48 fyear state_in circuit_court judge_fe) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_payout connect04 dismissed $didcontrol01, abs(ffind48 fyear state_in circuit_court judge_fe) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  
  
*==============================================================================*
**Table 6 CROSS-SECTIONAL ANALYSES: DEFENDANT EXECUTIVE/DIRECTOR**
*==============================================================================*
 
 
  xi: logit dismissed connect04_defendant connect04_nondefendant dummy_defendant $didcontrol01 i.ffind48 i.fyear i.state_in i.circuit_court, cluster(firm)
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) replace	 
  xi: reghdfe dismissed connect04_defendant connect04_nondefendant dummy_defendant $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append	 
  xi: reghdfe ln_deal_days connect04_defendant connect04_nondefendant dummy_defendant $didcontrol01, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_payout connect04_defendant connect04_nondefendant dummy_defendant $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append  

  test connect04_defendant=connect04_nondefendant
 
 
*==============================================================================*
**Table 7 CROSS-SECTIONAL ANALYSES: CASE/FIRM VISIBILITY**
*==============================================================================*

***Panel A***
  sum num4_news if connect04==1, detail 
  gen connect04_morenews=0 
  replace connect04_morenews=1 if connect04==1 & num4_news>=6
  gen connect04_lessnews=0 
  replace connect04_lessnews=1 if connect04==1 & num4_news<6
   
  
  xi: logit dismissed connect04_morenews connect04_lessnews $didcontrol01 i.ffind48 i.fyear i.state_in i.circuit_court, cluster(firm)
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) replace	  
  xi: reghdfe dismissed connect04_morenews connect04_lessnews $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_deal_days connect04_morenews connect04_lessnews $didcontrol01, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_payout connect04_morenews connect04_lessnews $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append  
  
  test connect04_morenews=connect04_lessnews
 
 
***Panel B*** 
  sort ffind48 connect04
  by ffind48 connect04: egen p50_analyst=pctile(analyst), p(50)
  by ffind48 connect04: egen p50_io=pctile(lag_inst), p(50)
  by ffind48 connect04: egen p50_size=pctile(lag_firm_size1), p(50)
  
  gen connect_morevisi=0 
  replace connect_morevisi=1 if connect04==1 & analyst>=p50_analyst & lag_inst>=p50_io & lag_firm_size1>=p50_size 
  gen connect_lessvisi=0 
  replace connect_lessvisi=1 if connect04==1 & connect_morevisi==0
  
  xi: logit dismissed connect_morevisi connect_lessvisi $didcontrol01 i.ffind48 i.fyear i.state_in i.circuit_court, cluster(firm)
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) replace	 
  xi: reghdfe dismissed connect_morevisi connect_lessvisi $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_deal_days connect_morevisi connect_lessvisi $didcontrol01, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_payout connect_morevisi connect_lessvisi $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append  

  test connect_morevisi=connect_lessvisi
  
 
*==============================================================================*
**Table 8 LIKELIHOOD OF DIRECT SOCIAL CONNECTIONS**
*==============================================================================*
***Panel A***
gen school_size=u_ft 
replace school_size=tot_num if tot_num~=.

sum school_size if connect04==1, detail 
gen connect_small=0 
replace connect_small=1 if connect04==1 & school_size<=2020
gen connect_large=0 
replace connect_large=1 if connect04==1 & school_size>2020

  xi: logit dismissed connect_small connect_large $didcontrol01 i.ffind48 i.fyear i.state_in i.circuit_court, cluster(firm)
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) replace	 
  xi: reghdfe dismissed connect_small connect_large $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_deal_days connect_small connect_large $didcontrol01, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_payout connect_small connect_large $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append  

  test connect_small=connect_large
  
***Panel B law school and overlapping period***
  xi: logit dismissed connect04_law $didcontrol01 i.ffind48 i.fyear i.state_in i.circuit_court, cluster(firm)
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) replace	 
  xi: reghdfe dismissed connect04_law $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_deal_days connect04_law $didcontrol01, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_payout connect04_law $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append  
  
***Panel C university and overlapping period***
  xi: logit dismissed connect02 $didcontrol01 i.ffind48 i.fyear i.state_in i.circuit_court, cluster(firm)
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) replace	 
  xi: reghdfe dismissed connect02 $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_deal_days connect02 $didcontrol01, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_payout connect02 $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append  

***Panel D school but no overlapping period*
  xi: logit dismissed connect03 $didcontrol01 i.ffind48 i.fyear i.state_in i.circuit_court, cluster(firm)
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) replace	 
  xi: reghdfe dismissed connect03 $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_deal_days connect03 $didcontrol01, abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append
  xi: reghdfe ln_payout connect03 $didcontrol01 ,abs(ffind48 fyear state_in circuit_court) cluster(firm) keepsingleton 
  outreg2 using table3.xls,excel drop (_I*) tstat aster(tstat)  bdec(3) tdec(2) append  
 
 
*==============================================================================*
**Table 1 Summary Statistics**
*==============================================================================*
gen size_origial=exp(lag_firm_size)  
keep dismissed deal_days settlem connect04 diff_days car_n1p1_ffmvalue provable_loss2 news_coverage insider_trading_allegation gaap_allegation sec_investigation restatement security_offering connect04_leaddeflawyer connect04_leadplalawyer gc exe_law ks_index size_origial lag_lev lag_roa loss lag_inst num_ana lag_mret12 holding female age white democratic local_judge unemp_rate gdp_growth blue
 
outreg2 using table1, label excel ///
replace sum(detail) keep (dismissed deal_days settlem connect04 diff_days car_n1p1_ffmvalue provable_loss2 news_coverage insider_trading_allegation gaap_allegation sec_investigation restatement security_offering connect04_leaddeflawyer connect04_leadplalawyer gc exe_law ks_index size_origial lag_lev lag_roa loss lag_inst num_ana lag_mret12 holding female age white democratic local_judge unemp_rate gdp_growth blue) eqkeep (N mean sd p50 p25  p75)


 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
   
   
   