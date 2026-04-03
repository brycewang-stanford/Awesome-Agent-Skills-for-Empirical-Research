/********************************************************/
/*the following code builds on the following SAS codes 

"LSZZ_1_Data_Assembly_Code_Amadeus_SAS.sas"

"LSZZ_2_Data_Assembly_Code_Oriana_SAS.sas"

and perform the analysis using STATA*/
/********************************************************/



/*Step1:specify local directory*/
cd "local directory"

/*Step2:create the base dataset for further analysis */
use Amadeus_2009disk_combined,clear
*generate HHI index
drop if op_rev==.
gen ind=int(nace/100)
gen private=1 if public=="No"
replace private=0 if public=="Yes"
duplicates drop bvd_id year,force
keep ind op_rev year bvd_id country
bysort country year ind:egen sum_op_rev=sum(op_rev)
gen p_sale=(op_rev/sum_op_rev)^2
bysort country year ind:egen hhi=sum(p_sale)


/*imposing conditions as in Burgstaler et al. (2006) by focusing on firms that meet at least two of the following///
three conditions:
1)the number of employees is not less than 50, 
2)total revenue is not less than €5 million, and 
3)total assets are not less than €2.5 million. 
note: the financial numbers from BvD Amadeus are in thousands
*/
gen d_asset=1 if total_asset>=2500 & total_asset!=.
replace d_asset=0 if total_asset<2500 & total_asset!=.

gen d_sale=1 if op_rev>=5000 & op_rev!=.
replace d_sale=0 if op_rev<5000 & op_rev!=.

gen d_emp=1 if emp>=50 & emp!=.
replace d_emp=0 if emp<50 & emp!=.

gen sum_indicator=d_asset+d_sale+d_emp
keep if sum_indicator>=2 & sum_indicator!=.

*generate non-current asset
gen ncur_asset=total_asset-current_asset

*remove any duplicates
duplicates drop bvd_id year,force

*generate one-year lagged variables
sort bvd_id year
foreach var of varlist op_rev fix_asset total_asset ncur_asset shrf loan lt_debt{
gen lag_`var'=`var'[_n-1] if bvd_id==bvd_id[_n-1] & year==year[_n-1]+1
gen chg_`var'=`var'-lag_`var'
gen `var'_gr=(`var'-lag_`var')/lag_`var'
}

*generate investment variable as change in fixed asset, scaled by lagged total asset
gen inv=chg_fix_asset/lag_total_asset


*generate control variables in the regression analysis
gen roa=pl_after/lag_total_asset
gen lev=(lt_debt+loan)/total_asset
gen ln_at=log(total_asset)
gen cash_s=cash/lag_total_asset
gen tacc=(pl-cash_flow)/lag_total_asset

*winsorize the variables at top and bottom 1 percentile
foreach var of varlist inv roa lev ln_at op_rev_gr cash_s total_asset_gr ncur_asset_gr hhi tacc{
winsor2 `var', replace cuts(1 99) by(year)
}


*generate the pre- versus post-indicator
gen after=1 if year>=2005 & year!=.
replace after=0 if year<2005 & year!=.


*generate public versus private firms indicator
gen private=1 if public=="No"
replace private=0 if public=="Yes" 

*generate industry code
gen ind=int(nace/100)

*following Klapper, Laeven, and Rajan [2006], drop financial firms
drop if ind==65|ind==66

*save the dataset for regression analysis
save amadeus_ready,replace



/**Step3: construct benchmark2 group**/
use amadeus_ready,clear

merge m:1 bvd_id using drop_es_gr
drop if _m==3
drop _m

replace private=1-public_new if public_new!=.
keep if private==1
gen subsample=1 if inv!=. & op_rev_gr!=. & roa!=. & lev!=. & ln_at!=. & cash_s!=. & hhi!=. & nace!=.
egen country_year_ind=group(country ind year)

*we base the construction of benchmark2 group on the year just before IFRS adoption
keep if year==2004
egen country_ind_year=group(country ind year)

*generate size median at country-industry-year level
xtileJ dsize=ln_at if subsample==1,by(country_ind_year) nquantiles(2)
egen country_year_dsize=group(country_ind_year dsize)

*generate leverage tercile at country-industry-year level
xtileJ dlev=lev if subsample==1,by(country_year_dsize) nquantiles(3)
gen large_private=1 if dsize==2 & (dlev==3|dlev==2)
replace large_private=0 if dsize==1 & dlev==1

keep bvd_id large_private 
save private_size_paritition_double_alt,replace


/*exclude certain observations*/
*get the list of firms to be excluded (Spain and Greece private firms that adopt IFRS in 2005)

use amadeus_ready,clear

replace private=1-public_new if public_new!=.

keep if private==1

egen country_year=group(country year)

gen subsample=1 if inv!=. & op_rev_gr!=. & roa!=. & lev!=. & ln_at!=. & cash_s!=. & hhi!=. & nace!=.
keep if subsample==1

*we remove certain firms from Greece(GR) and Spain(ES) that allows adoption of IFRS by private firms
keep if (country=="ES" & year==2005 & acc_pract=="IFRS")|(country=="GR" & year==2005 & acc_pract=="IFRS")
keep bvd_id
save drop_es_gr,replace

/**Step4: perform the main analysis in the paper**/

*****************************************
*overall subject versus benchmark 1 group
*****************************************
*Table 3 Panel A
use amadeus_ready,clear
gen subsample=1 if inv!=. & op_rev_gr!=. & roa!=. & lev!=. & ln_at!=. & cash_s!=. & hhi!=. & nace!=.
foreach var of varlist roa lev ln_at cash_s hhi op_rev_gr{
gen `var'_after=`var'*after
}

merge m:1 bvd_id using drop_es_gr
drop if _m==3
drop _m

merge m:1 bvd_id using private_size_paritition_double_alt
keep if _m==3|_m==1
drop _m

*remove firms from Slovakia
drop if country=="SK"

*only keep subject firms(i.e., remove benchmark2 firms)
drop if large_private==0 & private==1

*generate country and industry indicators
tab country,gen(dcountry)
tab ind,gen(dind)

*interact country and industry indicators with sales growth
foreach var of varlist dcountry* dind*{
gen `var'_op_rev_gr=`var'*op_rev_gr
}

*generate country by year indicators
egen country_year=group(country year)

*Table 3 Panel A Columns (1)-(2) full sample
eststo clear
eststo: quietly xi:areg inv private##after op_rev_gr roa lev ln_at cash_s hhi i.ind  if (year>=2002 & year<=2007) & subsample==1,a(country)cluster(bvd_id)
eststo: quietly xi:areg inv private##after op_rev_gr roa lev ln_at cash_s hhi i.ind  if (year>=2002 & year<=2007) & subsample==1,a(country_year)cluster(bvd_id)
esttab using invest.csv, margin constant p b ar2 nogaps b(3) t(2) starlevels(* .1 ** .05 *** .01)  nomtitles replace


*Table 3 Panel B Columns (1)-(2) full sample
eststo clear
eststo: quietly xi:areg inv private##after##c.op_rev_gr after##c.roa after##c.lev after##c.ln_at after##c.cash_s after##c.hhi dind*_op_rev_gr dcountry*_op_rev_gr i.ind if (year>=2002 & year<=2007) & subsample==1,a(country)cluster(bvd_id)
eststo: quietly xi:areg inv private##after##c.op_rev_gr after##c.roa after##c.lev after##c.ln_at after##c.cash_s after##c.hhi dind*_op_rev_gr dcountry*_op_rev_gr i.ind if (year>=2002 & year<=2007) & subsample==1,a(country_year)cluster(bvd_id)
esttab using invest.csv, margin constant p b ar2 nogaps b(3) t(2) starlevels(* .1 ** .05 *** .01)  nomtitles append


*****************************************
*Table 4 overall subject versus benchmark 2 group
****************************************

use amadeus_ready,clear

merge m:1 bvd_id using drop_es_gr
drop if _m==3
drop _m

replace private=1-public_new if public_new!=.

keep if private==1

*generate country by year indicators
egen country_year=group(country year)

gen subsample=1 if inv!=. & op_rev_gr!=. & roa!=. & lev!=. & ln_at!=. & cash_s!=. & hhi!=. & nace!=.

merge m:1 bvd_id using private_size_paritition_double_alt
keep if _m==3|_m==1
drop _m

*generate indicator for subject group (i.e., large_private==1)
replace large_private=1 if (large_private!=0)

*remove firms from Slovakia
drop if country=="SK"

*generate country and industry indicators
tab country,gen(dcountry)
tab ind,gen(dind)

*interact country and industry indicators with sales growth
foreach var of varlist dcountry* dind*{
gen `var'_op_rev_gr=`var'*op_rev_gr
}


eststo clear

eststo: quietly xi:areg inv large_private##after op_rev_gr roa lev ln_at cash_s hhi  i.ind if private==1 & (year>=2002 & year<=2007) &  subsample==1,a(country_year)cluster(bvd_id)

eststo: quietly xi:areg inv large_private##after##c.op_rev_gr after##c.roa after##c.lev after##c.ln_at after##c.cash_s after##c.hhi  dind*_op_rev_gr dcountry*_op_rev_gr  i.ind if private==1 & (year>=2002 & year<=2007) &  subsample==1,a(country_year)cluster(bvd_id)

esttab using invest.csv, margin constant p b ar2 nogaps b(3) t(2) starlevels(* .1 ** .05 *** .01)  nomtitles replace
*end of the code for BvD Amadeus data analysis









/*********************************************************************************************/
*We implement similar procedures in cleaning up Oriana database and obtain the results as reported in the paper
/********************************************************************************************/

/*Step1:specify local directory*/
cd "local directory"

/*Step2:create the base dataset for further analysis */


use Oriana_data_merged,clear
*check the duplicated record
bysort bvd_id year:egen count_bvd_id=count(year)
bysort bvd_id year:egen max_total_assets=max(total_assets)
keep if  total_assets==max_total_assets
duplicates drop bvd_id year,force

sort bvd_id year
rename turnover1 sales
rename fixed_assets1 fix_assets
rename total_assets1 total_assets

*generate one-year lagged variables
foreach var of varlist sales fix_assets total_assets {
gen lag_`var'=`var'[_n-1] if bvd_id==bvd_id[_n-1] & year==year[_n-1]+1
gen chg_`var'=`var'-lag_`var'
gen `var'_gr=(`var'-lag_`var')/lag_`var'
}

foreach var of varlist cash1 longterm_debt1 loans1{
replace `var'=0 if `var'==.
}

*generate dependent, as well as the control variables
gen inv=chg_fix_assets/lag_total_assets
gen roa=p_l_after_tax1/lag_total_assets
gen lev=(longterm_debt1+loans1)/total_assets
gen ln_at=log(total_assets)
gen cash_s=cash1/total_assets

*the following is to calculate HHI
destring nace,replace
gen ind=int(nace/100)

bysort country year ind:egen sum_sales=sum(sales)
gen p_sale=(sales/sum_sales)^2
bysort country year ind:egen hhi=sum(p_sale)
sum hhi

*winsorize variables at top and bottom 1 percentile
foreach var of varlist inv roa lev ln_at sales_gr cash_s total_assets_gr fix_assets_gr hhi {
winsor2 `var', replace cuts(1 99) by(year)
}

gen public=1 if public_quoted=="Listed"
replace public=0 if public_quoted=="Unlisted"
*for firms deilsted, we refine the listing status as follows
split delisted_date,parse(/)
rename  delisted_date3 delist_year
destring delist_year,replace
replace public=1 if public_quoted=="Delisted" & year<=delist_year
replace public=0 if public_quoted=="Delisted" & year>delist_year

gen private=1-public
drop country
gen country=substr(bvd_id,1,2)
gen subsample=1 if inv!=.& sales_gr!=.& roa!=.&  lev!=.&  ln_at!=.&  cash_s!=.&  hhi!=. & ind!=.
keep if subsample==1
tabstat inv sales_gr roa lev ln_at cash_s hhi if subsample==1 & private!=. & (year>=2002 & year<=2007),stat(N min max mean p25 p50 p75) col(s)
tab country year if subsample==1
drop subsample
save Oriana_data_reg,replace





/*assign IFRS adoption year for Oriana countries, and create indicator for pre- versus post-IFRS adoption*/

*2003 adopter (Singapore)
use Oriana_data_reg,clear
keep if country=="SG"
keep if year>=2000 & year<=2005
gen after=1 if year>=2003 & year<=2005
replace after=0 if year>=2000 & year<=2002
save oriana_adopt2003,replace


*2005 adopter (Hong Kong)
use Oriana_data_reg,clear
keep if country=="HK"
keep if year>=2002 & year<=2007
gen after=1 if year>=2005 & year<=2007
replace after=0 if year>=2002 & year<=2004
save oriana_adopt2005,replace



*2006 adopters (Turkey and Australia)
use Oriana_data_reg,clear
keep if country=="TR"|country=="AU"
keep if year>=2003 & year<=2008
gen after=1 if year>=2006 & year<=2008
replace after=0 if year>=2003 & year<=2005
save oriana_adopt2006,replace

*2007 adopter (New Zealand)
use Oriana_data_reg,clear
keep if country=="NZ"
keep if year>=2004 & year<=2009
gen after=1 if year>=2007 & year<=2009
replace after=0 if year>=2004 & year<=2006
save oriana_adopt2007,replace

*2008 adopter (Israel)
use Oriana_data_reg,clear
keep if country=="IL"
keep if year>=2005 & year<=2010
gen after=1 if year>=2008 & year<=2010
replace after=0 if year>=2005 & year<=2007
save oriana_adopt2008,replace


*2011 adopter (South Korea)
use Oriana_data_reg,clear
keep if country=="KR"
keep if year>=2008 & year<=2013
gen after=1 if year>=2011 & year<=2013
replace after=0 if year>=2008 & year<=2010
save oriana_adopt2011,replace

*2012 adopters(Sri Lanka, Malaysia and Russia)
use Oriana_data_reg,clear
keep if country=="LK"|country=="MY"|country=="RU"
keep if year>=2009 & year<=2014
gen after=1 if year>=2012 & year<=2014
replace after=0 if year>=2009 & year<=2011
save oriana_adopt2012,replace


/*merge the data for regression analysis*/
use oriana_adopt2002,clear
append using oriana_adopt2003
append using oriana_adopt2005
append using oriana_adopt2006
append using oriana_adopt2007
append using oriana_adopt2008
append using oriana_adopt2011
append using oriana_adopt2012

keep if status=="Active"
drop if ind==65|ind==66
gen subsample=1 if inv!=.& sales_gr!=.& roa!=.&  lev!=.&  ln_at!=.&  cash_s!=.&  hhi!=. & ind!=.
egen country_ind=group(country ind)

tab country year if subsample==1 & private==1
tab country if subsample==1 & private==1
tab country if subsample==1 & private==0

keep if subsample==1
save oriana_ready,replace

/*create benchmark2 groups*/
use oriana_ready,clear
drop if country=="AU"|country=="KZ"|country=="NZ"
keep if private==1
egen country_year_ind=group(country ind year)

*focus on one year just before IFRS adoption in each jurisdiction
keep if before1==1 & private==1
egen country_ind_year=group(country ind year)

*create the size median at country-industry-year level
xtileJ dsize=ln_at if subsample==1,by(country_ind_year) nquantiles(2)

egen country_year_dsize=group(country_ind_year dsize)
xtileJ dlev=lev if subsample==1,by(country_year_dsize) nquantiles(3)

gen large_private=1 if dsize==2 & (dlev==3|dlev==2)
replace large_private=0 if dsize==1 & dlev==1
keep bvd_id large_private
save large_private_size_lev_oriana,replace



/*Step3:tabulating the results in Panel B of Table 7*/
*benchmark 1
use oriana_ready,clear
*remove firms from Australia, Kazakhstan and New Zealand
drop if country=="AU"|country=="KZ"|country=="NZ"

tab country,gen(dcountry)
tab ind,gen(dind)
foreach var of varlist dcountry* dind*{
gen `var'_sales_gr=`var'*sales_gr
}
*excluding observations from the two industries(agriculture and construction) in Malaysia
drop if (country=="MY" & ((ind>=1 & ind<=3)|ind==41))
merge m:1 bvd_id using large_private_size_lev_oriana
keep if _m==3|_m==1
drop _m

*keep the subject group only (i.e., large_private==1)
drop if large_private==0 & private==1
egen country_year=group(country year)
tab country private

*restrict the countries to the following 
keep if country=="HK"|country=="IL"|country=="KR"|country=="LK"|country=="RU"|country=="SG"|country=="TR"|country=="MY"
*Column (1) in Panel B Table 7
eststo clear
eststo: quietly xi:areg inv after##private sales_gr roa lev ln_at cash_s hhi  i.ind  if subsample==1,a(country_year)cluster(bvd_id)
esttab using invest.csv, margin constant p b ar2 nogaps b(3) t(2) starlevels(* .1 ** .05 *** .01)  nomtitles replace


*Results against Benchmark2
use oriana_ready,clear
*remove firms from Australia, Kazakhstan and New Zealand
drop if country=="AU"|country=="KZ"|country=="NZ"

*generate country and industry indicators
tab country,gen(dcountry)
tab ind,gen(dind)

*interact country and industry indicators with sales growth
foreach var of varlist dcountry* dind*{
gen `var'_sales_gr=`var'*sales_gr
}

*excluding observations from the two industries (agriculture and construction) in Malaysia
drop if (country=="MY" & ((ind>=1 & ind<=3)|ind==41))
merge m:1 bvd_id using large_private_size_lev_oriana
keep if _m==3|_m==1
drop _m

*focus on private firms and generate indicator for subject group (i.e., large_private==1)
drop if private==0
replace large_private=1 if (large_private!=0)
egen country_year=group(country year)

tab country large_private
*restrict the countries to the following 
keep if country=="HK"|country=="IL"|country=="KR"|country=="LK"|country=="RU"|country=="SG"|country=="TR"|country=="MY"
*Column (2) in Panel B Table 7
eststo clear
eststo: quietly xi:areg inv after##large_private sales_gr roa lev ln_at cash_s hhi  i.ind  if subsample==1,a(country_year)cluster(bvd_id)
esttab using invest.csv, margin constant p b ar2 nogaps b(3) t(2) starlevels(* .1 ** .05 *** .01)  nomtitles replace
*end of the code for BvD Oriana data analysis

