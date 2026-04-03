clear
clear mata
clear matrix
set mem 25000m
set more off 
set maxvar 30000
set matsize 11000
 
cd "D:\TP"
use final  

encode ticker, gen(f)
encode headqctry, gen (headqctry1)
egen firm_year = group(ticker year)
gen y=string(year)
replace nanalyst = log(nanalyst)
replace brsize = log(brsize)
replace nticker = log(nticker)
replace gdpp = gdpp/10000
gen y=string(year)
gen ctrypairyr=headqctry+analyst_loc+y
replace headqctry=headqctry+y
gen analyst_locyr=analyst_loc+y
encode ctrypair, gen(pair)
opt_accu6 = 1 - ratio6
opt_accu3 = 1 - ratio3

* Merge WGI data
sort analyst_loc year
merge m:1 analyst_loc year using wgi_rank.dta, update replace
drop _merge 

merge m:1 analyst_loc year using pc.dta, update replace		/***** Principal components ****/
drop _merge 

sort headqctry year
merge m:1 headqctry year using wgi_headqctry.dta, update replace
drop _merge 

merge m:1 headqctry year using headqctry_traits.dta, update replace
drop _merge 

merge m:1 headqctry year using pc_firm.dta, update replace
drop _merge 

local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12		
local controlAnalyst deltatp2tp return_rev optimism_eps firmex genex nticker brsize acwi12
local dep tp2p tp2p_rank2 opt_accu6 delta6radj 
local ctrytrait legalenf ex_ante_dealing 
local control gdpp commonlaw `controlFirm' `controlAnalyst' i.year 

gen idctry=analyst_loc
sort idctry year

merge m:1 idctry using govern.dta, update replace

drop _merge 
sort headqctry year
merge m:1 headqctry year using PCREV_firm.dta, update replace
drop _merge
 
sort ticker amaskcd anndats 
merge m:1 ticker amaskcd anndats using prc_revdate.dta, update replace 
drop _merge 

save JAR2.dta, replace


*Target Price Optimism and Analyst-Country Traits
clear
clear mata
clear matrix
set mem 25000m
set more off 
set maxvar 30000
set matsize 11000

cd "D:\TP"
use JAR2, clear
*use jarrev, clear

sort ticker
by ticker: keep if _n==1		/**I/B/E/S ticker in the final sample: 17,353 ticker**/
drop if ticker==""
*keep ticker 
*save SampleTicker, replace

sort analyst_loc year
merge m:1 analyst_loc year using PCREV.dta, update replace
drop _merge 

merge m:1 analyst_loc using Jacksonroe.dta, update replace /*****JacksonRoeJFE09 - Public and Private Enforcement of Securities Laws Resource-Based Evidence*********/
drop _merge 

merge m:1 analyst_loc using secreg.dta, update replace /*****LLS (JFE2006): What Works in Securities Laws.xls*********/
drop _merge 
gen staff1=staff/100

local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12		
local controlAnalyst deltatp2tp return_rev optimism_eps firmex genex nticker brsize acwi12
local dep tp2p tp2p_rank2 opt_accu6 delta6radj 
local ctrytrait ctryinfrp1 legsys judicial ruleoflaw corruption 
local control gdpp commonlaw `controlFirm' `controlAnalyst' i.year 

*** Firm fixed effects
xtset f 
***Benchmark reg****
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3'  `control', fe vce(cluster headqctry)		
	}
		
*	Main Tables 5
	foreach trait in `ctrytrait'        {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control', fe vce(cluster headqctry)
		}
	}
	
*	Covered by both local and Foreign analysts;	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control' if localfgn == 2, fe vce(cluster headqctry)
		}
	}
	
*	analyst_loc_freq >=2	
	foreach trait in `ctrytrait'       {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control' if analyst_loc_freq >=2, fe vce(cluster headqctry)
		}
	}
	
*	Non US firms;	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control' if headqctry != "NA", fe vce(cluster headqctry)
		}
	}
	
	esttab using "C:\Users\hptan\Dropbox\JARcheck1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)

	
	*	Foreign analysts;	
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' ctryinfrp1rev ctryinfrp1rev_firm ctryinfrp2rev ctryinfrp2rev_firm 	`control' if local == 0, fe vce(cluster headqctry)
	}
	
*	Full sample: Both analyst counctry and firm country traits	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `trait'_f	`control', 			fe vce(cluster headqctry)
		}
	}	
	
*	Foreign analysts: Both analyst counctry and firm country traits	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `trait'_f	`control' if local == 0, fe vce(cluster headqctry)
		}
	}
	esttab using "C:\Users\hptan\Dropbox\JARcheck1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)

	
*	What Works in Securities Laws.xls LA PORTA
*	Robustness: Resource-based enforcement of securities laws   JacksonRoeJFE09 - Public and Private Enforcement of Securities Laws Resource-Based Evidence
	foreach depvar3 in  `dep' {	
		foreach trait in  judimp ex_ante_dealing legalenf pub_enfdjankov staff1 publ_enf  {	
		eststo: xi: xtreg `depvar3' `trait' `control', fe vce(cluster headqctry)
		}
	}
	
*	Control for both firm and analsyt fixed effects
	foreach depvar3 in `dep'  {	
	foreach trait in  `ctrytrait' {
		eststo: xi: reghdfe `depvar3' `trait' `control' i.year, 	absorb(f amaskcd)  cluster(headqctry)
		}
	}
	
	esttab using "C:\Users\hptan\Dropbox\OtherCtryTraits1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)


xtset f 
****Table Country pair-firm-year level	
	collapse `dep' `ctrytrait' gdpp commonlaw `controlFirm' `controlAnalyst', by(f year headqctry analyst_loc )
	
	foreach trait in `ctrytrait'       {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control', fe vce(cluster headqctry)
		}
	}

esttab using "C:\Users\hptan\Dropbox\JARcheck1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)
	

	
**Return predicative power
clear
clear matrix
set mem 25000m
set more off 
cd "D:\TP"
*cd "K:\TP_Alan 2016\P"

*use Jar2
use Jarr1
sum return3 return5 return30 return92 return182	

local traits2 firmex firmex_dum purebroker leadunderwriter research local purelocal expalocal civillaw judicial rule corruption priv_enf publ_enf ///
	it_enf investor_pr expropriat accntstd cifar earnmgmt concent r2 gdpp developed idv media ///
	antidir_new	ex_ante_dealing	anti_dealing disclose ushold usholdgdp ///
	mb def investments cwc internalcf  ///
	bribes comp_fbank enforcement foregnownership integrity judimp judindp legsys privatecredit propprot ///
	def_dum financing_brs_dum earnmgmt_firm earnmgmt_firm1
	
local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12 	
local controlAnalyst return_rev optimism_eps firmex genex nticker brsize acwi12
local ret return3 return5 return30 return92 return182	 		

keep analyst_loc headqctry ctryinfrp1_firm ctryinfrp2_firm ctryinfrp1 ctryinfrp2 headqctry return30 deltatp2tp tpret_sic tpretadj_sic tp2p `ret'  `controlFirm' `controlAnalyst' `traits2'  secabb year mth ticker `pcs'

encode ticker, gen(f)
gen commonlaw = 1 - civillaw
replace nanalyst = log(nanalyst)
replace brsize = log(brsize)
replace nticker = log(nticker)
replace gdpp = gdpp/10000

drop ctryinfrp1 ctryinfrp2 

* Merge WGI data
sort analyst_loc year
merge m:1 analyst_loc year using wgi_rank.dta, update replace
drop _merge 

merge m:1 analyst_loc year using pc.dta, update replace		/***** Principal components ****/
drop _merge 

gen inter_ctry=ctryinfrp1*tp2p	
	
gen y=string(year)
replace headqctry=headqctry+y
gen ctrypair=headqctry + analyst_loc

sum `ret' tp2p tpret_sic deltatp2tp

foreach dep in `ret'  {	
	replace `dep'=`dep'*100
}
	
xtset f 
local ret return3 return30  	
local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12 	
local controlAnalyst  return_rev optimism_eps firmex genex nticker brsize acwi12

foreach dep in `ret'  {	
	foreach traits in tp2p tpret_sic deltatp2tp  {	
	foreach ctrytrait in ctryinfrp1 legsys corruption judicial ruleoflaw       {	
		replace inter_ctry=`ctrytrait'*`traits'	
		eststo:	xi: xtreg `dep' `traits'  inter_ctry `ctrytrait' 		`controlFirm' `controlAnalyst' i.year i.mth, fe vce(cluster headqctry)
		}
	}
}

esttab using MarketRetrev1.csv, b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Markettest)
clear
clear mata
clear matrix
set mem 25000m
set more off 
set maxvar 30000
set matsize 11000
 
cd "D:\TP"
use final  

encode ticker, gen(f)
encode headqctry, gen (headqctry1)
egen firm_year = group(ticker year)
gen y=string(year)
replace nanalyst = log(nanalyst)
replace brsize = log(brsize)
replace nticker = log(nticker)
replace gdpp = gdpp/10000
gen y=string(year)
gen ctrypairyr=headqctry+analyst_loc+y
replace headqctry=headqctry+y
gen analyst_locyr=analyst_loc+y
encode ctrypair, gen(pair)
opt_accu6 = 1 - ratio6
opt_accu3 = 1 - ratio3

* Merge WGI data
sort analyst_loc year
merge m:1 analyst_loc year using wgi_rank.dta, update replace
drop _merge 

merge m:1 analyst_loc year using pc.dta, update replace		/***** Principal components ****/
drop _merge 

sort headqctry year
merge m:1 headqctry year using wgi_headqctry.dta, update replace
drop _merge 

merge m:1 headqctry year using headqctry_traits.dta, update replace
drop _merge 

merge m:1 headqctry year using pc_firm.dta, update replace
drop _merge 

local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12		
local controlAnalyst deltatp2tp return_rev optimism_eps firmex genex nticker brsize acwi12
local dep tp2p tp2p_rank2 opt_accu6 delta6radj 
local ctrytrait legalenf ex_ante_dealing 
local control gdpp commonlaw `controlFirm' `controlAnalyst' i.year 

gen idctry=analyst_loc
sort idctry year

merge m:1 idctry using govern.dta, update replace

drop _merge 
sort headqctry year
merge m:1 headqctry year using PCREV_firm.dta, update replace
drop _merge
 
sort ticker amaskcd anndats 
merge m:1 ticker amaskcd anndats using prc_revdate.dta, update replace 
drop _merge 

save JAR2.dta, replace


*Target Price Optimism and Analyst-Country Traits
clear
clear mata
clear matrix
set mem 25000m
set more off 
set maxvar 30000
set matsize 11000

cd "D:\TP"
use JAR2, clear
*use jarrev, clear

sort ticker
by ticker: keep if _n==1		/**I/B/E/S ticker in the final sample: 17,353 ticker**/
drop if ticker==""
*keep ticker 
*save SampleTicker, replace

sort analyst_loc year
merge m:1 analyst_loc year using PCREV.dta, update replace
drop _merge 

merge m:1 analyst_loc using Jacksonroe.dta, update replace /*****JacksonRoeJFE09 - Public and Private Enforcement of Securities Laws Resource-Based Evidence*********/
drop _merge 

merge m:1 analyst_loc using secreg.dta, update replace /*****LLS (JFE2006): What Works in Securities Laws.xls*********/
drop _merge 
gen staff1=staff/100

local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12		
local controlAnalyst deltatp2tp return_rev optimism_eps firmex genex nticker brsize acwi12
local dep tp2p tp2p_rank2 opt_accu6 delta6radj 
local ctrytrait ctryinfrp1 legsys judicial ruleoflaw corruption 
local control gdpp commonlaw `controlFirm' `controlAnalyst' i.year 

*** Firm fixed effects
xtset f 
***Benchmark reg****
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3'  `control', fe vce(cluster headqctry)		
	}
		
*	Main Tables 5
	foreach trait in `ctrytrait'        {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control', fe vce(cluster headqctry)
		}
	}
	
*	Covered by both local and Foreign analysts;	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control' if localfgn == 2, fe vce(cluster headqctry)
		}
	}
	
*	analyst_loc_freq >=2	
	foreach trait in `ctrytrait'       {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control' if analyst_loc_freq >=2, fe vce(cluster headqctry)
		}
	}
	
*	Non US firms;	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control' if headqctry != "NA", fe vce(cluster headqctry)
		}
	}
	
	esttab using "C:\Users\hptan\Dropbox\JARcheck1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)

	
	*	Foreign analysts;	
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' ctryinfrp1rev ctryinfrp1rev_firm ctryinfrp2rev ctryinfrp2rev_firm 	`control' if local == 0, fe vce(cluster headqctry)
	}
	
*	Full sample: Both analyst counctry and firm country traits	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `trait'_f	`control', 			fe vce(cluster headqctry)
		}
	}	
	
*	Foreign analysts: Both analyst counctry and firm country traits	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `trait'_f	`control' if local == 0, fe vce(cluster headqctry)
		}
	}
	esttab using "C:\Users\hptan\Dropbox\JARcheck1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)

	
*	What Works in Securities Laws.xls LA PORTA
*	Robustness: Resource-based enforcement of securities laws   JacksonRoeJFE09 - Public and Private Enforcement of Securities Laws Resource-Based Evidence
	foreach depvar3 in  `dep' {	
		foreach trait in  judimp ex_ante_dealing legalenf pub_enfdjankov staff1 publ_enf  {	
		eststo: xi: xtreg `depvar3' `trait' `control', fe vce(cluster headqctry)
		}
	}
	
*	Control for both firm and analsyt fixed effects
	foreach depvar3 in `dep'  {	
	foreach trait in  `ctrytrait' {
		eststo: xi: reghdfe `depvar3' `trait' `control' i.year, 	absorb(f amaskcd)  cluster(headqctry)
		}
	}
	
	esttab using "C:\Users\hptan\Dropbox\OtherCtryTraits1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)


xtset f 
****Table Country pair-firm-year level	
	collapse `dep' `ctrytrait' gdpp commonlaw `controlFirm' `controlAnalyst', by(f year headqctry analyst_loc )
	
	foreach trait in `ctrytrait'       {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control', fe vce(cluster headqctry)
		}
	}

esttab using "C:\Users\hptan\Dropbox\JARcheck1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)
	

	
**Return predicative power
clear
clear matrix
set mem 25000m
set more off 
cd "D:\TP"
*cd "K:\TP_Alan 2016\P"

*use Jar2
use Jarr1
sum return3 return5 return30 return92 return182	

local traits2 firmex firmex_dum purebroker leadunderwriter research local purelocal expalocal civillaw judicial rule corruption priv_enf publ_enf ///
	it_enf investor_pr expropriat accntstd cifar earnmgmt concent r2 gdpp developed idv media ///
	antidir_new	ex_ante_dealing	anti_dealing disclose ushold usholdgdp ///
	mb def investments cwc internalcf  ///
	bribes comp_fbank enforcement foregnownership integrity judimp judindp legsys privatecredit propprot ///
	def_dum financing_brs_dum earnmgmt_firm earnmgmt_firm1
	
local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12 	
local controlAnalyst return_rev optimism_eps firmex genex nticker brsize acwi12
local ret return3 return5 return30 return92 return182	 		

keep analyst_loc headqctry ctryinfrp1_firm ctryinfrp2_firm ctryinfrp1 ctryinfrp2 headqctry return30 deltatp2tp tpret_sic tpretadj_sic tp2p `ret'  `controlFirm' `controlAnalyst' `traits2'  secabb year mth ticker `pcs'

encode ticker, gen(f)
gen commonlaw = 1 - civillaw
replace nanalyst = log(nanalyst)
replace brsize = log(brsize)
replace nticker = log(nticker)
replace gdpp = gdpp/10000

drop ctryinfrp1 ctryinfrp2 

* Merge WGI data
sort analyst_loc year
merge m:1 analyst_loc year using wgi_rank.dta, update replace
drop _merge 

merge m:1 analyst_loc year using pc.dta, update replace		/***** Principal components ****/
drop _merge 

gen inter_ctry=ctryinfrp1*tp2p	
	
gen y=string(year)
replace headqctry=headqctry+y
gen ctrypair=headqctry + analyst_loc

sum `ret' tp2p tpret_sic deltatp2tp

foreach dep in `ret'  {	
	replace `dep'=`dep'*100
}
	
xtset f 
local ret return3 return30  	
local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12 	
local controlAnalyst  return_rev optimism_eps firmex genex nticker brsize acwi12

foreach dep in `ret'  {	
	foreach traits in tp2p tpret_sic deltatp2tp  {	
	foreach ctrytrait in ctryinfrp1 legsys corruption judicial ruleoflaw       {	
		replace inter_ctry=`ctrytrait'*`traits'	
		eststo:	xi: xtreg `dep' `traits'  inter_ctry `ctrytrait' 		`controlFirm' `controlAnalyst' i.year i.mth, fe vce(cluster headqctry)
		}
	}
}

esttab using MarketRetrev1.csv, b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Markettest)
clear
clear mata
clear matrix
set mem 25000m
set more off 
set maxvar 30000
set matsize 11000
 
cd "D:\TP"
use final  

encode ticker, gen(f)
encode headqctry, gen (headqctry1)
egen firm_year = group(ticker year)
gen y=string(year)
replace nanalyst = log(nanalyst)
replace brsize = log(brsize)
replace nticker = log(nticker)
replace gdpp = gdpp/10000
gen y=string(year)
gen ctrypairyr=headqctry+analyst_loc+y
replace headqctry=headqctry+y
gen analyst_locyr=analyst_loc+y
encode ctrypair, gen(pair)
opt_accu6 = 1 - ratio6
opt_accu3 = 1 - ratio3

* Merge WGI data
sort analyst_loc year
merge m:1 analyst_loc year using wgi_rank.dta, update replace
drop _merge 

merge m:1 analyst_loc year using pc.dta, update replace		/***** Principal components ****/
drop _merge 

sort headqctry year
merge m:1 headqctry year using wgi_headqctry.dta, update replace
drop _merge 

merge m:1 headqctry year using headqctry_traits.dta, update replace
drop _merge 

merge m:1 headqctry year using pc_firm.dta, update replace
drop _merge 

local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12		
local controlAnalyst deltatp2tp return_rev optimism_eps firmex genex nticker brsize acwi12
local dep tp2p tp2p_rank2 opt_accu6 delta6radj 
local ctrytrait legalenf ex_ante_dealing 
local control gdpp commonlaw `controlFirm' `controlAnalyst' i.year 

gen idctry=analyst_loc
sort idctry year

merge m:1 idctry using govern.dta, update replace

drop _merge 
sort headqctry year
merge m:1 headqctry year using PCREV_firm.dta, update replace
drop _merge
 
sort ticker amaskcd anndats 
merge m:1 ticker amaskcd anndats using prc_revdate.dta, update replace 
drop _merge 

save JAR2.dta, replace


*Target Price Optimism and Analyst-Country Traits
clear
clear mata
clear matrix
set mem 25000m
set more off 
set maxvar 30000
set matsize 11000

cd "D:\TP"
use JAR2, clear
*use jarrev, clear

sort ticker
by ticker: keep if _n==1		/**I/B/E/S ticker in the final sample: 17,353 ticker**/
drop if ticker==""
*keep ticker 
*save SampleTicker, replace

sort analyst_loc year
merge m:1 analyst_loc year using PCREV.dta, update replace
drop _merge 

merge m:1 analyst_loc using Jacksonroe.dta, update replace /*****JacksonRoeJFE09 - Public and Private Enforcement of Securities Laws Resource-Based Evidence*********/
drop _merge 

merge m:1 analyst_loc using secreg.dta, update replace /*****LLS (JFE2006): What Works in Securities Laws.xls*********/
drop _merge 
gen staff1=staff/100

local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12		
local controlAnalyst deltatp2tp return_rev optimism_eps firmex genex nticker brsize acwi12
local dep tp2p tp2p_rank2 opt_accu6 delta6radj 
local ctrytrait ctryinfrp1 legsys judicial ruleoflaw corruption 
local control gdpp commonlaw `controlFirm' `controlAnalyst' i.year 

*** Firm fixed effects
xtset f 
***Benchmark reg****
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3'  `control', fe vce(cluster headqctry)		
	}
		
*	Main Tables 5
	foreach trait in `ctrytrait'        {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control', fe vce(cluster headqctry)
		}
	}
	
*	Covered by both local and Foreign analysts;	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control' if localfgn == 2, fe vce(cluster headqctry)
		}
	}
	
*	analyst_loc_freq >=2	
	foreach trait in `ctrytrait'       {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control' if analyst_loc_freq >=2, fe vce(cluster headqctry)
		}
	}
	
*	Non US firms;	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control' if headqctry != "NA", fe vce(cluster headqctry)
		}
	}
	
	esttab using "C:\Users\hptan\Dropbox\JARcheck1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)

	
	*	Foreign analysts;	
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' ctryinfrp1rev ctryinfrp1rev_firm ctryinfrp2rev ctryinfrp2rev_firm 	`control' if local == 0, fe vce(cluster headqctry)
	}
	
*	Full sample: Both analyst counctry and firm country traits	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `trait'_f	`control', 			fe vce(cluster headqctry)
		}
	}	
	
*	Foreign analysts: Both analyst counctry and firm country traits	
	foreach trait in  `ctrytrait' {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `trait'_f	`control' if local == 0, fe vce(cluster headqctry)
		}
	}
	esttab using "C:\Users\hptan\Dropbox\JARcheck1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)

	
*	What Works in Securities Laws.xls LA PORTA
*	Robustness: Resource-based enforcement of securities laws   JacksonRoeJFE09 - Public and Private Enforcement of Securities Laws Resource-Based Evidence
	foreach depvar3 in  `dep' {	
		foreach trait in  judimp ex_ante_dealing legalenf pub_enfdjankov staff1 publ_enf  {	
		eststo: xi: xtreg `depvar3' `trait' `control', fe vce(cluster headqctry)
		}
	}
	
*	Control for both firm and analsyt fixed effects
	foreach depvar3 in `dep'  {	
	foreach trait in  `ctrytrait' {
		eststo: xi: reghdfe `depvar3' `trait' `control' i.year, 	absorb(f amaskcd)  cluster(headqctry)
		}
	}
	
	esttab using "C:\Users\hptan\Dropbox\OtherCtryTraits1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)


xtset f 
****Table Country pair-firm-year level	
	collapse `dep' `ctrytrait' gdpp commonlaw `controlFirm' `controlAnalyst', by(f year headqctry analyst_loc )
	
	foreach trait in `ctrytrait'       {
	foreach depvar3 in  `dep' {	
		eststo: xi: xtreg `depvar3' `trait' `control', fe vce(cluster headqctry)
		}
	}

esttab using "C:\Users\hptan\Dropbox\JARcheck1.csv", b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Fixed effect)
	

	
**Return predicative power
clear
clear matrix
set mem 25000m
set more off 
cd "D:\TP"
*cd "K:\TP_Alan 2016\P"

*use Jar2
use Jarr1
sum return3 return5 return30 return92 return182	

local traits2 firmex firmex_dum purebroker leadunderwriter research local purelocal expalocal civillaw judicial rule corruption priv_enf publ_enf ///
	it_enf investor_pr expropriat accntstd cifar earnmgmt concent r2 gdpp developed idv media ///
	antidir_new	ex_ante_dealing	anti_dealing disclose ushold usholdgdp ///
	mb def investments cwc internalcf  ///
	bribes comp_fbank enforcement foregnownership integrity judimp judindp legsys privatecredit propprot ///
	def_dum financing_brs_dum earnmgmt_firm earnmgmt_firm1
	
local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12 	
local controlAnalyst return_rev optimism_eps firmex genex nticker brsize acwi12
local ret return3 return5 return30 return92 return182	 		

keep analyst_loc headqctry ctryinfrp1_firm ctryinfrp2_firm ctryinfrp1 ctryinfrp2 headqctry return30 deltatp2tp tpret_sic tpretadj_sic tp2p `ret'  `controlFirm' `controlAnalyst' `traits2'  secabb year mth ticker `pcs'

encode ticker, gen(f)
gen commonlaw = 1 - civillaw
replace nanalyst = log(nanalyst)
replace brsize = log(brsize)
replace nticker = log(nticker)
replace gdpp = gdpp/10000

drop ctryinfrp1 ctryinfrp2 

* Merge WGI data
sort analyst_loc year
merge m:1 analyst_loc year using wgi_rank.dta, update replace
drop _merge 

merge m:1 analyst_loc year using pc.dta, update replace		/***** Principal components ****/
drop _merge 

gen inter_ctry=ctryinfrp1*tp2p	
	
gen y=string(year)
replace headqctry=headqctry+y
gen ctrypair=headqctry + analyst_loc

sum `ret' tp2p tpret_sic deltatp2tp

foreach dep in `ret'  {	
	replace `dep'=`dep'*100
}
	
xtset f 
local ret return3 return30  	
local controlFirm logmv mb revt_growth intangible nanalyst turnoverpre12 retstd12 	
local controlAnalyst  return_rev optimism_eps firmex genex nticker brsize acwi12

foreach dep in `ret'  {	
	foreach traits in tp2p tpret_sic deltatp2tp  {	
	foreach ctrytrait in ctryinfrp1 legsys corruption judicial ruleoflaw       {	
		replace inter_ctry=`ctrytrait'*`traits'	
		eststo:	xi: xtreg `dep' `traits'  inter_ctry `ctrytrait' 		`controlFirm' `controlAnalyst' i.year i.mth, fe vce(cluster headqctry)
		}
	}
}

esttab using MarketRetrev1.csv, b(3) ar2 nogaps star(* 0.10 ** 0.05 *** 0.01)   replace title ( Markettest)

