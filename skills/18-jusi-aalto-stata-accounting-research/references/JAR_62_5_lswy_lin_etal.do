version 16.0
clear all
set more off  

set mat 11000
set maxvar 11000 
capture log close 



use "F:\Dropbox\Julia Yu\data\JAR resubmission\data_ready_resubmit_test.dta", clear

cd "F:\Dropbox\Julia Yu\ESG and ML\JAR submissions\JAR Final 20240801\Results\."

log using JAR_main_tables.log, replace

/* gen randome mandate year sig and voluntary framework 

gen random_yr=round(2001+19*runiform())

gen sig_mandate_date_ro=mdy(month(sig_mandate_date), day(sig_mandate_date), random_yr)

format sig_mandate_date_ro %td

gen sig_mandate_ro=1
replace sig_mandate_ro=0 if year(sig_mandate_date_ro)>2024

gen postsig_ro=0
replace postsig_ro=1 if datadate+365>=sig_mandate_date_ro

gen v_framework_r=round(runiform())

save "F:\Dropbox\Julia Yu\data\JAR resubmission\data_ready_resubmit_test.dta", replace

*/


drop if countryCode!=iso2

drop if GDPgrowth==.
drop if at==.
drop if at==0
drop if total_intensity==.

drop if fyear<2000
drop if fyear>2019

gen roa=ib/at
gen lnana=ln(1+ana_cov)
gen leverage=((dt)/at)
replace leverage=0 if leverage==.

gen size=ln(at)
gen tobin_q=(at+prccf*csho-ceq)/at

gen ag_forest_fish=Agricultureforestryandfishi
gen forest_area_pct=Forestareaoflandarea
gen lntot_ghg=ln(Totalgreenhousegasemissions)
gen renew_energy_pct=Renewableenergyconsumption
gen gdp_percap=GDPpercapita/1000
gen gdp_growth=GDPgrowth
gen unemploy_pct=Unemploymenttotaloftotal
gen life_expectancy=Lifeexpectancyatbirthtotal
gen fertility_rate=Fertilityratetotalbirthspe
gen adj_saving=Adjustednetsavingsincluding
gen resource_rent=Totalnaturalresourcesrents
gen female_labor=FemaleLaborPct
gen tech_pct=TechManuPct
gen ghgper=Totalgreenhousegasemissions*1000/Population

gen lnpop=ln(Population)
gen lnboilerplate_count=ln(1+count_esg_boilerplate)
gen lnspecificity_count=ln(1+esg_specificity_count)
gen lnwords=ln(1+word_count)

gen intensity=esg_word_count*100/word_count
replace esg_boilerplate_percent=esg_boilerplate_percent*100
replace esg_specificity=esg_specificity*100
replace stickiness=stickiness*100
replace visuals=visual_new

sicff sic, ind(5) gen(ffind5)

gen v_framework=0
replace v_framework=1 if cdsb+cdp+gri+iirc+sasb+tcfd>0


replace visuals=visual_new


gen lnesg_word=ln(1+esg_word_count)
gen esg_word_countn=esg_word_count/1000

replace captogdp=captogdp2 if captogdp==.

gen visual_total=pic_count_total+table_count_total

replace boilerplate_percent_total=boilerplate_percent_total*100
replace specificity_total=specificity_total*100
replace stickiness_total=stickiness_total*100

gen specificity_total_count=specificity_total*word_count/1000

winsor2 roa lnana leverage size tobin_q ag_forest_fish forest_area_pct ghgper lntot_ghg renew_energy_pct gdp_percap gdp_growth unemploy_pct life_expectancy fertility_rate adj_saving resource_rent female_labor tech_pct lnpop inst_hold yr_ret ret_vol total_intensity count_esg_boilerplate esg_boilerplate_percent esg_specificity esg_specificity_count stickiness visuals lnboilerplate_count lnspecificity_count lnwords lnesg_word esg_word_countn pve rle rqe gee cce vae captogdp , cut(1 99) replace

winsor2 boilerplate_percent_total specificity_total stickiness_total visual_total specificity_total_count, cut(1 99) replace


gen trend=fyear_t-2000

replace esg_report=0 if esg_report==.		
replace esg_report_broad=0 if esg_report_broad==.

		
tsset code fyear 

gen sig_mandate=1
replace sig_mandate=0 if iso2=="CA" | iso2=="CH" | iso2=="JP" | iso2=="LK" | iso2=="NG" | iso2=="NZ" | iso2=="RU"

gen postsig=0
replace postsig=1 if fenddate>=sig_mandate_date

gen first_mandate=1
replace first_mandate=0 if iso2=="CA" | iso2=="CH" | iso2=="JP" | iso2=="LK" | iso2=="NG" | iso2=="NZ" | iso2=="RU"

gen postfirst=0
replace postfirst=1 if fenddate>=first_mandate_date

summarize intensity esg_word_countn esg_boilerplate_percent esg_specificity stickiness visuals lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q forest_area_pct ghgper resource_rent renew_energy_pct ///
			female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank 

centile intensity esg_word_countn esg_boilerplate_percent esg_specificity stickiness visuals lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q forest_area_pct ghgper resource_rent renew_energy_pct ///
			female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank, centile(25)


/* T4 Panel A */

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank, noabsorb cluster(nation_code)
outreg2 using esg_word_count.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords) addtext(Country FE, No, Firm FE, No, Year FE, No) adj 			
						
reghdfe esg_word_countn lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords, noabsorb cluster(nation_code)
outreg2 using esg_word_count.xls, append ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords) addtext(Country FE, No, Firm FE, No, Year FE, No) adj 

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords, noabsorb cluster(nation_code)
outreg2 using esg_word_count.xls, append ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords) addtext(Country FE, No, Firm FE, No, Year FE, No) adj 
						
reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords, absorb(nation_code fyear) cluster(nation_code)
outreg2 using esg_word_count.xls, append ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords) addtext(Country FE, Yes, Firm FE, No, Year FE, Yes) adj 
						
reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords, absorb(code fyear) cluster(nation_code)
outreg2 using esg_word_count.xls, append ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
						

/* T4 Panel B */

/* boilerplate pct */

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total, absorb(nation_code fyear) cluster(nation_code)
outreg2 using PanelB.xls, replace ctitle(esg_boilerplate_percent) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total) addtext(Country FE, Yes, Firm FE, No, Year FE, Yes) adj 

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total , absorb(code fyear) cluster(nation_code)
outreg2 using PanelB.xls, append ctitle(esg_boilerplate_percent) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
/* specificity pct */
					
reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total , absorb(nation_code fyear) cluster(nation_code)
outreg2 using PanelB.xls, append ctitle(esg_specificity) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total) addtext(Country FE, Yes, Firm FE, No, Year FE, Yes) adj 

reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total , absorb(code fyear) cluster(nation_code)
outreg2 using PanelB.xls, append ctitle(esg_specificity) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						

/* stickiness */
						
reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total , absorb(nation_code fyear) cluster(nation_code)
outreg2 using PanelB.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total) addtext(Country FE, Yes, Firm FE, No, Year FE, Yes) adj 

reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total , absorb(code fyear) cluster(nation_code)
outreg2 using PanelB.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
	

/* visuals */

reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total , absorb(nation_code fyear) cluster(nation_code)
outreg2 using PanelB.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total) addtext(Country FE, Yes, Firm FE, No, Year FE, Yes) adj 

reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total , absorb(code fyear) cluster(nation_code)
outreg2 using PanelB.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 

						
/* T5 Panel A */

reghdfe esg_word_countn trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords, absorb(code ) cluster(nation_code)
outreg2 using trend.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe esg_boilerplate_percent trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total , absorb(code ) cluster(nation_code)
outreg2 using trend.xls, append ctitle(boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe esg_specificity trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total , absorb(code ) cluster(nation_code)
outreg2 using trend.xls, append ctitle(specificity) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe stickiness trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total , absorb(code ) cluster(nation_code)
outreg2 using trend.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe visuals trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total , absorb(code ) cluster(nation_code)
outreg2 using trend.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 



/* T5 Panel B */

reghdfe esg_word_countn i.ffind5#c.trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords, absorb(code ) cluster(nation_code)
outreg2 using indtrend.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(i.ffind5#c.trend trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe esg_boilerplate_percent i.ffind5#c.trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total , absorb(code ) cluster(nation_code)
outreg2 using indtrend.xls, append ctitle(boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(i.ffind5#c.trend trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe esg_specificity i.ffind5#c.trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total , absorb(code ) cluster(nation_code)
outreg2 using indtrend.xls, append ctitle(specificity) stat(coef se ) dec(3) sdec(3) ///
keep(i.ffind5#c.trend trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe stickiness i.ffind5#c.trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total , absorb(code ) cluster(nation_code)
outreg2 using indtrend.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(i.ffind5#c.trend trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe visuals i.ffind5#c.trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total , absorb(code ) cluster(nation_code)
outreg2 using indtrend.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(i.ffind5#c.trend trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
						
/* T6 */

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords cdp cdsb gri iirc sasb tcfd, absorb(code fyear) cluster(nation_code) 
outreg2 using framework.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords v_framework, absorb(code fyear) cluster(nation_code) 
outreg2 using framework.xls, append ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj	
						
						
reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total cdp cdsb gri iirc sasb tcfd , absorb(code fyear) cluster(nation_code)
outreg2 using framework.xls, append ctitle(pct_boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total v_framework , absorb(code fyear) cluster(nation_code)
outreg2 using framework.xls, append ctitle(pct_boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 	
					
								
reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total cdp cdsb gri iirc sasb tcfd , absorb(code fyear) cluster(nation_code)
outreg2 using framework.xls, append ctitle(pct_specificity) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 

reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total v_framework , absorb(code fyear) cluster(nation_code)
outreg2 using framework.xls, append ctitle(pct_specificity) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 		
				
												
reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total cdp cdsb gri iirc sasb tcfd , absorb(code fyear) cluster(nation_code)
outreg2 using framework.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 

reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total v_framework , absorb(code fyear) cluster(nation_code)
outreg2 using framework.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj
 						
reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total cdp cdsb gri iirc sasb tcfd , absorb(code fyear) cluster(nation_code)
outreg2 using framework.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total v_framework , absorb(code fyear) cluster(nation_code)
outreg2 using framework.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
						
/* T7 Panel A */

/* intensity count */

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postfirst#c.first_mandate postfirst first_mandate, absorb(code fyear) cluster(nation_code)
outreg2 using mandatef.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postfirst#c.first_mandate postfirst first_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
		
				
/* boilerplate pct */

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postfirst#c.first_mandate postfirst first_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatef.xls, append ctitle(pct_boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postfirst#c.first_mandate postfirst first_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
						
/* specificity pct */

reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postfirst#c.first_mandate postfirst first_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatef.xls, append ctitle(pct_specificity) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postfirst#c.first_mandate postfirst first_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 

						
/* stickiness */

reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postfirst#c.first_mandate postfirst first_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatef.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postfirst#c.first_mandate postfirst first_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
/* visuals */

reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postfirst#c.first_mandate postfirst first_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatef.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postfirst#c.first_mandate postfirst first_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						

/* T7 Panel B */

/* intensity count */

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postsig#c.sig_mandate postsig sig_mandate, absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postsig#c.sig_mandate c.postsig#c.sig_mandate#c.Integrated_sig postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
				
/* boilerplate pct */

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postsig#c.sig_mandate postsig sig_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig.xls, append ctitle(pct_boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
											
/* specificity pct */

reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postsig#c.sig_mandate postsig sig_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig.xls, append ctitle(pct_specificity) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
/* stickiness */

reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postsig#c.sig_mandate postsig sig_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
					
/* visuals */

reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postsig#c.sig_mandate postsig sig_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj version 16.0
clear all
set more off  

set mat 11000
set maxvar 11000 
capture log close 



use "F:\Dropbox\Julia Yu\data\JAR resubmission\data_ready_resubmit_test.dta", clear

cd "F:\Dropbox\Julia Yu\ESG and ML\JAR submissions\JAR Final 20240801\Results\."

log using JAR_OA_tables.log, replace

/* gen randome mandate year sig and voluntary framework 

gen random_yr=round(2001+19*runiform())

gen sig_mandate_date_ro=mdy(month(sig_mandate_date), day(sig_mandate_date), random_yr)

format sig_mandate_date_ro %td

gen sig_mandate_ro=1
replace sig_mandate_ro=0 if year(sig_mandate_date_ro)>2024

gen postsig_ro=0
replace postsig_ro=1 if datadate+365>=sig_mandate_date_ro

gen v_framework_r=round(runiform())

save "F:\Dropbox\Julia Yu\data\JAR resubmission\data_ready_resubmit_test.dta", replace

*/


drop if countryCode!=iso2

drop if GDPgrowth==.
drop if at==.
drop if at==0
drop if total_intensity==.

drop if fyear<2000
drop if fyear>2019

gen roa=ib/at
gen lnana=ln(1+ana_cov)
gen leverage=((dt)/at)
replace leverage=0 if leverage==.

gen size=ln(at)
gen tobin_q=(at+prccf*csho-ceq)/at

gen ag_forest_fish=Agricultureforestryandfishi
gen forest_area_pct=Forestareaoflandarea
gen lntot_ghg=ln(Totalgreenhousegasemissions)
gen renew_energy_pct=Renewableenergyconsumption
gen gdp_percap=GDPpercapita/1000
gen gdp_growth=GDPgrowth
gen unemploy_pct=Unemploymenttotaloftotal
gen life_expectancy=Lifeexpectancyatbirthtotal
gen fertility_rate=Fertilityratetotalbirthspe
gen adj_saving=Adjustednetsavingsincluding
gen resource_rent=Totalnaturalresourcesrents
gen female_labor=FemaleLaborPct
gen tech_pct=TechManuPct
gen ghgper=Totalgreenhousegasemissions*1000/Population

gen lnpop=ln(Population)
gen lnboilerplate_count=ln(1+count_esg_boilerplate)
gen lnspecificity_count=ln(1+esg_specificity_count)
gen lnwords=ln(1+word_count)

gen intensity=esg_word_count*100/word_count
replace esg_boilerplate_percent=esg_boilerplate_percent*100
replace esg_specificity=esg_specificity*100
replace stickiness=stickiness*100
replace visuals=visual_new

sicff sic, ind(5) gen(ffind5)
gen sic2=int(sic/100)
egen ctyind=group(nation_code ffind5)

gen v_framework=0
replace v_framework=1 if cdsb+cdp+gri+iirc+sasb+tcfd>0


replace visuals=visual_new


gen lnesg_word=ln(1+esg_word_count)
gen esg_word_countn=esg_word_count/1000

replace captogdp=captogdp2 if captogdp==.

gen visual_total=pic_count_total+table_count_total

replace boilerplate_percent_total=boilerplate_percent_total*100
replace specificity_total=specificity_total*100
replace stickiness_total=stickiness_total*100

gen specificity_total_count=specificity_total*word_count/1000

gen esg_word_count_fh=(climate_change_fh+natural_resources_fh+pollution_waste_fh+ecosystem_fh+human_capital_fh+products_and_customers_fh+otherstakeholders_fh+general_fh)/1000
gen visual_fh=pic_count_fh+table_count_fh

replace esg_boilerplate_percent_fh=esg_boilerplate_percent_fh*100
replace esg_specificity_fh=esg_specificity_fh*100
replace stickiness_fh=stickiness_fh*100

winsor2 roa lnana leverage size tobin_q ag_forest_fish forest_area_pct ghgper lntot_ghg renew_energy_pct gdp_percap gdp_growth unemploy_pct life_expectancy fertility_rate adj_saving resource_rent female_labor tech_pct lnpop inst_hold yr_ret ret_vol total_intensity count_esg_boilerplate esg_boilerplate_percent esg_specificity esg_specificity_count stickiness visuals lnboilerplate_count lnspecificity_count lnwords lnesg_word esg_word_countn pve rle rqe gee cce vae captogdp , cut(1 99) replace

winsor2 boilerplate_percent_total specificity_total stickiness_total visual_total esg_boilerplate_percent_fh esg_word_count_fh esg_specificity_fh stickiness_fh visual_fh specificity_total_count, cut(1 99) replace

replace esg_report=0 if esg_report==.		
replace esg_report_broad=0 if esg_report_broad==.

gen trend=fyear_t-2000
		
tsset code fyear 

gen sig_mandate=1
replace sig_mandate=0 if iso2=="CA" | iso2=="CH" | iso2=="JP" | iso2=="LK" | iso2=="NG" | iso2=="NZ" | iso2=="RU"

gen postsig=0
replace postsig=1 if fenddate>=sig_mandate_date

gen first_mandate=1
replace first_mandate=0 if iso2=="CA" | iso2=="CH" | iso2=="JP" | iso2=="LK" | iso2=="NG" | iso2=="NZ" | iso2=="RU"


gen postfirst=0
replace postfirst=1 if fenddate>=first_mandate_date

bysort code: egen num_obs=count(esg_word_count)

/* Table OA.3 */

/* Panel A */

reghdfe esg_word_count_fh trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords, absorb(code ) cluster(nation_code)
outreg2 using trend_fh.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe esg_boilerplate_percent_fh trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total , absorb(code ) cluster(nation_code)
outreg2 using trend_fh.xls, append ctitle(boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe esg_specificity_fh trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total , absorb(code ) cluster(nation_code)
outreg2 using trend_fh.xls, append ctitle(specificity) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe stickiness_fh trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total , absorb(code ) cluster(nation_code)
outreg2 using trend_fh.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe visual_fh trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total , absorb(code ) cluster(nation_code)
outreg2 using trend_fh.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

/* Panel B */

reghdfe esg_word_count_fh forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords v_framework, absorb(code fyear) cluster(nation_code)
outreg2 using framework_fh.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe esg_boilerplate_percent_fh forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total v_framework , absorb(code fyear) cluster(nation_code)
outreg2 using framework_fh.xls, append ctitle(boilerplate) stat(coef se ) dec(3) sdec(3) keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe esg_specificity_fh forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total v_framework , absorb(code fyear) cluster(nation_code)
outreg2 using framework_fh.xls, append ctitle(specificity) stat(coef se ) dec(3) sdec(3) keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe stickiness_fh forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total v_framework , absorb(code fyear) cluster(nation_code)
outreg2 using framework_fh.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe visual_fh forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total v_framework , absorb(code fyear) cluster(nation_code)
outreg2 using framework_fh.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
					
/* Panel C */

reghdfe esg_word_count_fh forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postsig#c.sig_mandate postsig sig_mandate, absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_fh.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe esg_boilerplate_percent_fh forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postsig#c.sig_mandate postsig sig_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_fh.xls, append ctitle(boilerplate) stat(coef se ) dec(3) sdec(3) keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe esg_specificity_fh forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postsig#c.sig_mandate postsig sig_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_fh.xls, append ctitle(specificity) stat(coef se ) dec(3) sdec(3) keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe stickiness_fh forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postsig#c.sig_mandate postsig sig_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_fh.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe visual_fh forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postsig#c.sig_mandate postsig sig_mandate , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_fh.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
	
	
/* Table OA.4 */

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct , noabsorb cluster(nation_code)
outreg2 using OA4.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank ) addtext(Country FE, No, Firm FE, No, Year FE, No) adj 

reghdfe esg_word_countn female_labor life_expectancy lnpop rle unemploy_pct , noabsorb cluster(nation_code)	
outreg2 using OA4.xls, append ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank ) addtext(Country FE, No, Firm FE, No, Year FE, No) adj 

reghdfe esg_word_countn ag_forest_fish gdp_growth gdp_percap captogdp overall_rank, noabsorb cluster(nation_code)	
outreg2 using OA4.xls, append ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank ) addtext(Country FE, No, Firm FE, No, Year FE, No) adj 


/* Table OA.5 */

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total, noabsorb cluster(nation_code)
outreg2 using OA5.xls, replace ctitle(esg_boilerplate_percent) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total) addtext(Country FE, No, Firm FE, No, Year FE, No) adj 
						
reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total , noabsorb cluster(nation_code)
outreg2 using OA5.xls, append ctitle(esg_specificity) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total) addtext(Country FE, No, Firm FE, No, Year FE, No) adj 
		
reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total , noabsorb cluster(nation_code)
outreg2 using OA5.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total) addtext(Country FE, No, Firm FE, No, Year FE, No) adj 

reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total , noabsorb cluster(nation_code)
outreg2 using OA5.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total) addtext(Country FE, No, Firm FE, No, Year FE, No) adj 
				
				
/* Table OA.6 */

/* Panel A */

reghdfe esg_word_countn trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords if num_obs>=10, absorb(code ) cluster(nation_code)
outreg2 using trend_10.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe esg_boilerplate_percent trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total if num_obs>=10, absorb(code ) cluster(nation_code)
outreg2 using trend_10.xls, append ctitle(boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe esg_specificity trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total if num_obs>=10, absorb(code ) cluster(nation_code)
outreg2 using trend_10.xls, append ctitle(specificity) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 
						
reghdfe stickiness trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total if num_obs>=10, absorb(code ) cluster(nation_code)
outreg2 using trend_10.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 

reghdfe visuals trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total if num_obs>=10, absorb(code ) cluster(nation_code)
outreg2 using trend_10.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(trend forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total) addtext(Country FE, No, Firm FE, Yes, Year FE, No) adj 


						
/* Panel B */

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords v_framework if num_obs>=10, absorb(code fyear) cluster(nation_code) 
outreg2 using framework_10.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj	

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total v_framework if num_obs>=10, absorb(code fyear) cluster(nation_code)
outreg2 using framework_10.xls, append ctitle(pct_boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 	

reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total v_framework if num_obs>=10, absorb(code fyear) cluster(nation_code)
outreg2 using framework_10.xls, append ctitle(pct_specificity) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 		

reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total v_framework if num_obs>=10, absorb(code fyear) cluster(nation_code)
outreg2 using framework_10.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj
						
reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total v_framework if num_obs>=10, absorb(code fyear) cluster(nation_code)
outreg2 using framework_10.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total cdp cdsb gri iirc sasb tcfd v_framework) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						

/* Table OA.7 */

/* Panel A */

gen before_f=esg_word_count*(1-postfirst) 

gen after_f=esg_word_count*postfirst

bysort code: egen before_f_obs=sum(1-postfirst)
bysort code: egen after_f_obs=sum(postfirst)

gen exist_f_both=0
replace exist_f_both=1 if first_mandate==0
replace exist_f_both=1 if before_f_obs>0 & after_f_obs>0

/* intensity count */

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postfirst#c.first_mandate postfirst first_mandate if exist_f_both==1, absorb(code fyear) cluster(nation_code)
outreg2 using mandatef_existboth.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postfirst#c.first_mandate postfirst first_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
					
/* boilerplate pct */

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postfirst#c.first_mandate postfirst first_mandate if exist_f_both==1, absorb(code fyear) cluster(nation_code)
outreg2 using mandatef_existboth.xls, append ctitle(pct_boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postfirst#c.first_mandate postfirst first_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
												
/* specificity pct */

reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postfirst#c.first_mandate postfirst first_mandate if exist_f_both==1, absorb(code fyear) cluster(nation_code)
outreg2 using mandatef_existboth.xls, append ctitle(pct_specificity) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postfirst#c.first_mandate postfirst first_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
/* stickiness */

reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postfirst#c.first_mandate postfirst first_mandate if exist_f_both==1, absorb(code fyear) cluster(nation_code)
outreg2 using mandatef_existboth.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postfirst#c.first_mandate postfirst first_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
/* visuals */

reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postfirst#c.first_mandate postfirst first_mandate if exist_f_both==1, absorb(code fyear) cluster(nation_code)
outreg2 using mandatef_existboth.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postfirst#c.first_mandate postfirst first_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						

/* Panel B */

gen before_s=esg_word_count*(1-postsig) 

gen after_s=esg_word_count*postsig

bysort code: egen before_s_obs=sum(1-postsig)
bysort code: egen after_s_obs=sum(postsig)

gen exist_s_both=0
replace exist_s_both=1 if sig_mandate==0
replace exist_s_both=1 if before_s_obs>0 & after_s_obs>0

/* intensity count */

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postsig#c.sig_mandate postsig sig_mandate if exist_s_both==1, absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_existboth.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postsig#c.sig_mandate c.postsig#c.sig_mandate#c.Integrated_sig postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
				
/* boilerplate pct */

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postsig#c.sig_mandate postsig sig_mandate if exist_s_both==1, absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_existboth.xls, append ctitle(pct_boilerplate) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
											
/* specificity pct */

reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postsig#c.sig_mandate postsig sig_mandate if exist_s_both==1, absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_existboth.xls, append ctitle(pct_specificity) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
/* stickiness */

reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postsig#c.sig_mandate postsig sig_mandate if exist_s_both==1, absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_existboth.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
					
/* visuals */

reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postsig#c.sig_mandate postsig sig_mandate if exist_s_both==1, absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_existboth.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) ///
keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank  ///
						lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postsig#c.sig_mandate postsig sig_mandate) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
						
/* Table OA.8 */
						
/* Panel A */

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords v_framework_r, absorb(code fyear) cluster(nation_code) 
outreg2 using framework_fal.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords cdp cdsb gri iirc sasb tcfd v_framework_r) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj	
			

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total v_framework_r , absorb(code fyear) cluster(nation_code)
outreg2 using framework_fal.xls, append ctitle(pct_boilerplate) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total cdp cdsb gri iirc sasb tcfd v_framework_r) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 	
					

reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total v_framework_r , absorb(code fyear) cluster(nation_code)
outreg2 using framework_fal.xls, append ctitle(pct_specificity) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total cdp cdsb gri iirc sasb tcfd v_framework_r) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 						

reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total v_framework_r , absorb(code fyear) cluster(nation_code)
outreg2 using framework_fal.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total cdp cdsb gri iirc sasb tcfd v_framework_r) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj

						
reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total v_framework_r , absorb(code fyear) cluster(nation_code)
outreg2 using framework_fal.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total cdp cdsb gri iirc sasb tcfd v_framework_r) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 


/* Panel B  */			

reghdfe esg_word_countn forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postsig_ro#c.sig_mandate_ro postsig_ro sig_mandate_ro, absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_fal.xls, replace ctitle(esg_word_count) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords c.postsig_ro#c.sig_mandate_ro postsig_ro sig_mandate_ro) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
/* boilerplate pct */

reghdfe esg_boilerplate_percent forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postsig_ro#c.sig_mandate_ro postsig_ro sig_mandate_ro , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_fal.xls, append ctitle(pct_boilerplate) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords boilerplate_percent_total c.postsig_ro#c.sig_mandate_ro postsig_ro sig_mandate_ro) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
												
/* specificity pct */

reghdfe esg_specificity forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postsig_ro#c.sig_mandate_ro postsig_ro sig_mandate_ro , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_fal.xls, append ctitle(pct_specificity) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords specificity_total c.postsig_ro#c.sig_mandate_ro postsig_ro sig_mandate_ro) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 

/* stickiness */

reghdfe stickiness forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postsig_ro#c.sig_mandate_ro postsig_ro sig_mandate_ro , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_fal.xls, append ctitle(stickiness) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords stickiness_total c.postsig_ro#c.sig_mandate_ro postsig_ro sig_mandate_ro) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 
						
/* visuals */

reghdfe visuals forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postsig_ro#c.sig_mandate_ro postsig_ro sig_mandate_ro , absorb(code fyear) cluster(nation_code)
outreg2 using mandatesig_fal.xls, append ctitle(visuals) stat(coef se ) dec(3) sdec(3) keep(forest_area_pct ghgper resource_rent renew_energy_pct female_labor life_expectancy lnpop rle unemploy_pct ag_forest_fish gdp_growth gdp_percap captogdp overall_rank lnana esg_rating esg_report yr_ret ret_vol inst_hold leverage roa size tobin_q lnwords visual_total c.postsig_ro#c.sig_mandate_ro postsig_ro sig_mandate_ro) addtext(Country FE, No, Firm FE, Yes, Year FE, Yes) adj 