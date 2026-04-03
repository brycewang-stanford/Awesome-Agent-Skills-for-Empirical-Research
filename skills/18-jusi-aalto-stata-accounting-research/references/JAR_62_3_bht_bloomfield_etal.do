
***set working directories
local rawdata "/Users/mjbloom/Dropbox/SabotageDisclosureJAR/Data/RAW"
local data "/Users/mjbloom/Dropbox/SabotageDisclosureJAR/Data/Processed"



***1. create cik-permno cross-walk, generate returns, industry affiliations and fyrs by cik-date
use "`rawdata'/CompustatMerged.dta", clear
keep if fyear>=2005
gen firm=real(cik)
rename lpermno permno
drop if missing(firm, permno)
gen year=year(datadate)
sort firm permno year datadate revt
by firm permno year: drop if year==year[_n-1]
keep firm permno year
save "`data'/cik-permno.dta", replace



use "`rawdata'/CRSP_daily_FULL.dta", clear
gen year=year(date)
keep if year>=2005
keep permno date ret year prc shrout vol 
merge m:1 permno year using "`data'/cik-permno.dta", keep(match) nogenerate
sort permno date
by permno: gen marketcap=abs(prc[_n-1])*shrout[_n-1]
sort firm date
by firm date: egen firmret=wtmean(ret), weight(marketcap)
replace ret = firmret
sort firm date
sort firm date
by firm date: egen volume=total(vol)
sort firm date permno
by firm date: drop if date==date[_n-1]
gen month=month(date)
gen day=day(date)
keep firm date year month day ret volume marketcap 
save "`data'/returns.dta", replace



use "`rawdata'/CompustatMerged.dta", clear
keep if fyear>=2005
gen firm=real(cik)
drop if missing(firm, fyear, revt, sich)
sort firm fyear revt
by firm fyear: drop if fyear==fyear[_n+1]
gen month=month(datadate)
gen year=year(datadate)
keep gvkey firm fyear year month fyr sich
save "`data'/firmbasics.dta", replace



*create database of fiscal year end months for later convenience
use "`data'/firmbasics.dta", clear
keep firm fyear fyr
save "`data'/fyrs.dta", replace





***2. Construct network of RPE peer relationships, including RPE metrics (accounting vs stock price)
use "`rawdata'/IncentiveLab2019/CompanyFY.dta", clear
merge 1:m cik fiscalyear using "`rawdata'/IncentiveLab2019/GpbaGrant.dta", nogenerate keep(match)
keep if strpos(performancetype, "Rel") 
merge 1:m grantid using "`rawdata'/IncentiveLab2019/GpbaRel.dta", nogenerate keep(match)
merge m:1 cik fiscalyear fiscalmonth participantid using "`rawdata'/IncentiveLab2019/ParticipantFY.dta", nogenerate keep(match)
save "`data'/Rel.dta", replace
gen year=year(fiscalyearend)
gen month=month(fiscalyearend)
gen day=day(fiscalyearend)
replace year=year-1 if month==1 & day<15
replace month=month-1 if day<15
gen firm=real(cik)
keep if currentceo==1
merge m:1 firm year month using "`data'/firmbasics.dta", keep(match) nogenerate
keep if fyear>=2006
drop if fyear==2006 & fyr<12
save "`data'/Rel_firmbasics.dta", replace

use "`data'/Rel_firmbasics.dta", clear
keep if relativebenchmark=="Peer Group"
keep if metrictype=="Stock Price"
sort grantid
by grantid: drop if grantid==grantid[_n-1]
keep firm fyear grantid fyr
merge 1:m grantid using "`rawdata'/IncentiveLab2019/GpbaRelPeer.dta", keep(match) nogenerate
rename peercik peer
keep firm peer fyear fyr
order firm peer fyear fyr
gen pricebased=1
drop if missing(firm, peer, fyear)
sort firm peer fyear
by firm peer fyear: drop if fyear==fyear[_n-1]
save "`data'/rpepeers_pricebased.dta", replace


use "`data'/Rel_firmbasics.dta", clear
keep if relativebenchmark=="Peer Group"
keep if metrictype=="Accounting"
sort grantid
by grantid: drop if grantid==grantid[_n-1]
keep firm fyear grantid fyr
merge 1:m grantid using "`rawdata'/IncentiveLab2019/GpbaRelPeer.dta", keep(match) nogenerate
rename peercik peer
keep firm peer fyear fyr
order firm peer fyear fyr
gen pricebased=0
drop if missing(firm, peer, fyear)
sort firm peer fyear
by firm peer fyear: drop if fyear==fyear[_n-1]
save "`data'/rpepeers_accountingbased.dta", replace

*create network of price-peer relationships that exist at any point over 11 years btwn
*2006 and 2016 (last year for which we had necessary data, at the start of our project)
use "`data'/rpepeers_pricebased.dta", clear
sort firm peer
by firm peer: drop if peer==peer[_n-1]
keep firm peer
expand(11)
sort firm peer
by firm peer: gen fyear=2005+_n
merge m:1 firm fyear using "`data'/fyrs.dta", keep(match) nogenerate
save "`data'/firm-peer_pricebased.dta", replace

use "`data'/firm-peer_pricebased.dta", clear
merge 1:1 firm peer fyear using "`data'/rpepeers_pricebased.dta"
*active = 0 indicate that the peer is not a price-peer to the firm in that year-month
*active = 1 indicates that the peer is a price-peer to the firm in that year-month
*obs. with active = 0 correspond to inactive price-peers that active at some point
gen active=_merge==3
replace pricebased=1
drop if _merge==2
drop _merge
expand(12)
gen year=fyear
sort firm peer fyear
by firm peer fyear: gen month=_n
replace year=year+1 if month<=fyr & fyr<=5
replace year=year-1 if month>fyr & fyr>5
expand(31)
sort firm peer year month
by firm peer year month: gen day=_n
save "`data'/firmpairs_pricebased.dta", replace


*create network of profit-peer relationships that exist at any point over 11 years btwn
*2006 and 2016 (last year for which we had necessary data, at the start of our project)
use "`data'/rpepeers_accountingbased.dta", clear
sort firm peer
by firm peer: drop if peer==peer[_n-1]
keep firm peer
expand(11)
sort firm peer
by firm peer: gen fyear=2005+_n
merge m:1 firm fyear using "`data'/fyrs.dta", keep(match) nogenerate
save "`data'/firm-peer_accountingbased.dta", replace

use "`data'/firm-peer_accountingbased.dta", clear
merge 1:1 firm peer fyear using "`data'/rpepeers_accountingbased.dta"
gen active=_merge==3
*active = 0 indicate that the peer is not a profit-peer to the firm in that year-month
*active = 1 indicates that the peer is a profit-peer to the firm in that year-month
*obs. with active = 0 correspond to inactive profit-peers that active at some point
replace pricebased=0
drop if _merge==2
drop _merge
expand(12)
gen year=fyear
sort firm peer fyear
by firm peer fyear: gen month=_n
replace year=year+1 if month<=fyr & fyr<=5
replace year=year-1 if month>fyr & fyr>5
expand(31)
sort firm peer year month
by firm peer year month: gen day=_n
save "`data'/firmpairs_accountingbased.dta", replace





use "`data'/returns.dta", clear
rename firm peer
merge 1:m peer year month day using "`data'/firmpairs_pricebased.dta", keep(match) nogenerate
rename ret ret_peer
rename volume volume_peer
rename marketcap marketcap_peer
keep firm peer fyear date ret_peer pricebased active volume_peer marketcap_peer 
merge m:1 firm date using "`data'/returns.dta", keep(match) nogenerate
rename ret ret_own
keep firm peer fyear date ret_peer ret_own pricebased active volume volume_peer marketcap marketcap_peer 
save "`data'/firmpairreturns_pricebased.dta", replace



use "`data'/returns.dta", clear
rename firm peer
merge 1:m peer year month day using "`data'/firmpairs_accountingbased.dta", keep(match) nogenerate
rename ret ret_peer
rename volume volume_peer
rename marketcap marketcap_peer
keep firm peer fyear date ret_peer pricebased active volume_peer marketcap_peer 
merge m:1 firm date using "`data'/returns.dta", keep(match) nogenerate
rename ret ret_own
keep firm peer fyear date ret_peer ret_own pricebased active volume volume_peer marketcap marketcap_peer 
save "`data'/firmpairreturns_accountingbased.dta", replace



***3. Merge with IBES guidance data
use "`rawdata'/IBES_CRSP_link.dta", clear
rename *, lower
keep if score==1
drop score
rename ticker ticker_ibes
rename ncusip ncusip_ibes
rename permno lpermno
rangejoin datadate sdate edate using "`rawdata'/CRSP_Compustat_winnowed.dta", by(lpermno)
gen fpedats=datadate
sort ticker_ibes fpedats
by ticker_ibes fpedats: drop if fpedats==fpedats[_n-1]
save "`data'/CRSP_Compustat_winnowed_IBEStickers.dta", replace


use "`rawdata'/IBES_guidance.dta", clear
keep if curr=="USD" & usfirm==1
rename ticker ticker_ibes
drop if missing(ticker_ibes, pdicity, measure, prd_yr, prd_mon)
keep ticker_ibes pdicity measure anndats anntims prd_yr prd_mon val_1 val_2 mean_at_date
save "`data'/IBES_guidance.dta", replace


use "`rawdata'/IBES_estimates_full.dta", clear
keep if measure=="EPS"
keep if curr_act=="USD" & usfirm==1
rename ticker ticker_ibes
gen prd_yr=year(fpedats)
gen prd_mon=month(fpedats)
gen pdicity=fiscalp
drop if missing(ticker_ibes, pdicity, measure, prd_yr, prd_mon)
sort ticker_ibes pdicity measure prd_yr prd_mon statpers
by ticker_ibes pdicity measure prd_yr prd_mon: drop if prd_mon==prd_mon[_n+1]
keep ticker_ibes pdicity measure prd_yr prd_mon fpedats anndats_act anntims_act numest medest meanest stdev highest lowest actual
merge 1:m ticker_ibes pdicity measure prd_yr prd_mon using "`data'/IBES_guidance.dta"
drop if _merge==1
drop _merge
save "`data'/GuidanceAnalystForecastsAndActuals.dta", replace
merge m:1 ticker_ibes fpedats using "`data'/CRSP_Compustat_winnowed_IBEStickers.dta", keep(match) nogenerate
save "`data'/guidancesample.dta", replace
gen year=year(anndats)
gen month=month(anndats)
rename lpermno permno
joinby permno year using "`data'/cik-permno.dta"
save "`data'/guidancesample_cik.dta", replace

*firm disclosure dates
use "`data'/guidancesample_cik.dta", clear
keep if measure=="EPS"
gen date=anndats
keep if year(date)>=2006
gen time=hh(anntims)
gen preclose=time<16
sort firm date time
by firm date: drop if date==date[_n+1]
drop if missing(firm, date, time, preclose)
keep firm date preclose time
gen voldisc=1
merge 1:m firm date using "`data'/firmpairreturns_pricebased.dta"
drop if _merge==1
drop _merge
replace voldisc=0 if voldisc==.
gen discday=0
replace discday=1 if voldisc==1 & preclose==1
sort firm peer date
by firm peer: replace discday=1 if voldisc[_n-1]==1 & preclose[_n-1]==0
save "`data'/disclosure_pricebased.dta", replace



use "`data'/guidancesample_cik.dta", clear
keep if measure=="EPS"
gen date=anndats
keep if year(date)>=2006
gen time=hh(anntims)
gen preclose=time<16
sort firm date time
by firm date: drop if date==date[_n+1]
drop if missing(firm, date, time, preclose)
keep firm date preclose time
gen voldisc=1
merge 1:m firm date using "`data'/firmpairreturns_accountingbased.dta"
drop if _merge==1
drop _merge
replace voldisc=0 if voldisc==.
gen discday=0
replace discday=1 if voldisc==1 & preclose==1
sort firm peer date
by firm peer: replace discday=1 if voldisc[_n-1]==1 & preclose[_n-1]==0
save "`data'/disclosure_accountingbased.dta", replace




*4. clean up
use "`data'/disclosure_pricebased.dta", clear
append using "`data'/disclosure_accountingbased.dta"
keep if active==1
drop if firm==peer
drop active

drop if missing(pricebased, discday, ret_peer, ret_own, firm, peer, date)

sort firm peer date pricebased
by firm peer date: egen rpetype=mean(pricebased)
by firm peer date: drop if date==date[_n+1]

merge m:1 firm fyear using "`data'/fyrs.dta", keep(match) nogenerate
keep if fyear>=2006
drop if fyear==2006 & fyr<12
gen month=month(date)
gen year=year(date)
replace ret_peer=100*ret_peer
replace ret_own=100*ret_own
winsor2 ret_peer ret_own, replace cuts(1 99)
gen ret_dif=ret_own-ret_peer
save "`data'/returns-disclosures-rpetype.dta", replace


use "`data'/firmbasics.dta", clear
*sample window to occur post-CD&A, and 
*end with the latest incentive data 
*available as beginning the project
*sample upper bound not binding here
*given the network construction code.
keep if fyear>=2006 | fyear<=2016
drop if fyear==2006 & fyr<12
keep firm fyear sich
merge 1:m firm fyear using "`data'/returns-disclosures-rpetype.dta", keep(match) nogenerate
gen fmonth=12-(fyr-month)
replace fmonth=fmonth-12 if fmonth>12
replace fmonth=fmonth+12 if fmonth<0
save "`data'/analysisfile_baseline.dta", replace




********************************************************
**Flipped specification based on peer disclosure dates**
********************************************************


*peer disclosure dates
use "`data'/guidancesample_cik.dta", clear
keep if measure=="EPS"
gen date=anndats
keep if year(date)>=2006
gen time=hh(anntims)
gen preclose=time<16
rename firm peer
sort peer date time
by peer date: drop if date==date[_n+1]
drop if missing(peer, date, time, preclose)
keep peer date preclose time
gen voldisc=1
merge 1:m peer date using "`data'/firmpairreturns_pricebased.dta"
drop if _merge==1
drop _merge
replace voldisc=0 if voldisc==.
gen discday=0
replace discday=1 if voldisc==1 & preclose==1
sort peer firm date
by peer firm: replace discday=1 if voldisc[_n-1]==1 & preclose[_n-1]==0
rename discday discday_peer
collapse discday_peer, by(peer date)
save "`data'/peerdisclosure_pricebased.dta", replace


use "`data'/guidancesample_cik.dta", clear
keep if measure=="EPS"
gen date=anndats
keep if year(date)>=2006
gen time=hh(anntims)
gen preclose=time<16
rename firm peer
sort peer date time
by peer date: drop if date==date[_n+1]
drop if missing(peer, date, time, preclose)
keep peer date preclose time
gen voldisc=1
merge 1:m peer date using "`data'/firmpairreturns_accountingbased.dta"
drop if _merge==1
drop _merge
replace voldisc=0 if voldisc==.
gen discday=0
replace discday=1 if voldisc==1 & preclose==1
sort peer firm date
by peer firm: replace discday=1 if voldisc[_n-1]==1 & preclose[_n-1]==0
rename discday discday_peer
collapse discday_peer, by(peer date)
save "`data'/peerdisclosure_accountingbased.dta", replace

use "`data'/peerdisclosure_accountingbased.dta", clear
append using "`data'/peerdisclosure_pricebased.dta"
collapse discday_peer, by(peer date)
save "`data'/peerdisclosuredates.dta", replace

use "`data'/analysisfile_baseline.dta", clear
merge m:1 peer date using "`data'/peerdisclosuredates.dta"
save "`data'/analysisfile_flipped.dta", replace


***********************************
**Disclosure-Day Return Reversals**
***********************************

use "`data'/analysisfile_baseline.dta", clear


gen logret_peer=log(1+ret_peer/100)

local windows 3 30

foreach window in `windows'{

	gen logret_peer_runsum`window'=0 if discday==1

	foreach i of numlist 1/`window'{

		sort firm peer date
		by firm peer: replace logret_peer_runsum`window'=logret_peer_runsum`window'+logret_peer[_n+`i'] if discday==1

	}
	gen ret_peer_`window'=(exp(logret_peer_runsum`window')-1)*100

}

save "`data'/analysisfile_reversals.dta", replace


*******************************************
**Targeting based on tournament standings**
*******************************************

use "`data'/analysisfile_baseline.dta", clear
keep if pricebased==1

gen logret_own=log(1+ret_own/100)
gen logret_peer=log(1+ret_peer/100)

sort fyear peer firm date
by fyear peer firm: gen logret_own_runsum=sum(logret_own)

sort fyear firm peer date
by fyear firm peer: gen logret_peer_runsum=sum(logret_peer)

gen ret_own_ytd=(exp(logret_own_runsum)-1)*100
gen ret_peer_ytd=(exp(logret_peer_runsum)-1)*100

sort fyear firm peer date
by fyear firm peer: gen ret_peer_ytd_lag=ret_peer_ytd[_n-1]
by fyear firm peer: gen ret_own_ytd_lag=ret_own_ytd[_n-1]

sort fyear firm peer date
by fyear firm peer: gen ytd_dif=ret_own_ytd[_n-1]-ret_peer_ytd[_n-1]
gen absytd_dif=abs(ytd_dif)

sort fyear firm peer date
by fyear firm peer: gen ytdpeer=ret_peer_ytd[_n-1]


sort firm date ret_peer_ytd
by firm date: egen groupsize=count(ret_peer_ytd)
by firm date: egen rank_peer_ytd=rank(-ret_peer_ytd)
sort firm date ret_peer_ytd
gen worse=ytd_dif<0
sort firm date
by firm date: egen rank_own_ytd=total(worse)
replace rank_own_ytd=rank_own_ytd+1
replace rank_peer_ytd=rank_peer_ytd+1-worse
replace groupsize=groupsize+1
gen pct_peer_ytd=1-rank_peer_ytd/groupsize
gen pct_own_ytd=1-rank_own_ytd/groupsize

sort fyear pricebased peer firm date
by fyear pricebased peer firm: gen rankdif=rank_own_ytd[_n-1]-rank_peer_ytd[_n-1]

sort fyear pricebased peer firm date
by fyear pricebased peer firm: gen pct_dif=pct_own_ytd[_n-1]-pct_peer_ytd[_n-1]
gen abs_pct_dif=abs(pct_dif)

gen proximity=1-abs_pct_dif
gen peerabove=pct_dif<0

*drop if discday==0
drop if missing(proximity, peerabove)

gen within1=absytd_dif<=1
gen within2=absytd_dif<=2
gen within3=absytd_dif<=3

local bandwidths 1 2 3

foreach bandwidth in `bandwidths'{

	sort firm date
	by firm date: egen propwithin`bandwidth'=mean(within`bandwidth')
	by firm date: egen numwithin`bandwidth'=total(within`bandwidth')
	by firm date: egen countwithin`bandwidth'=count(within`bandwidth')
	gen propwithinother_`bandwidth'=(numwithin`bandwidth'-within`bandwidth')/(countwithin`bandwidth'-1)
	gen density_`bandwidth'=sqrt(propwithinother_`bandwidth')

}


save "`data'/analysisfile_targeting.dta", replace

