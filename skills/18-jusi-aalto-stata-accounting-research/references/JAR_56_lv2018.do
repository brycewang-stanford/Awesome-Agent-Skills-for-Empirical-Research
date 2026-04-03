global path "C:\LV_JAR"

/*
	This Stata do-file is used to manage the input data and perform the analyses
	in Leung and Veenman (2018), Journal of Accounting Research. Please carefully 
	read the paper as well as the data description sheet, which provide the relevant
	information on the data management steps and input data, respectively.
*/

****************************************************************
****************************************************************
****************************************************************
* STEP 1a: Prepare firm-quarter sample as in Table 1-A
****************************************************************
****************************************************************
****************************************************************

	* Prepare 8-K filings file with item 2.02 
	use "$path\InFiles\items8k.dta", clear
	keep if nitem=="2.02"
	keep cik fdate
	duplicates drop cik fdate, force
	gen filing8k=1
	sort cik fdate
	save "$path\OutFiles\items8k2.dta", replace
	
	* Prepare IBES actuals data files: Street
	use "$path\InFiles\ibes_actu.dta", clear
	drop if cusip==""
	drop if cusip=="00000000"
	drop if value==.
	drop if anndats==.
	keep cusip pends value anndats ticker
	ren pends datadate
	sort cusip datadate
	duplicates drop cusip datadate, force
	save "$path\OutFiles\ibes_actu2.dta", replace

	* Prepare IBES actuals data files: GAAP
	use "$path\InFiles\ibes_actu_gaap.dta", clear
	drop if cusip==""
	drop if cusip=="00000000"
	drop if value==.
	drop if anndats==.
	keep cusip pends value
	ren pends datadate
	ren value actualibes_gaap
	sort cusip datadate
	duplicates drop cusip datadate, force
	save "$path\OutFiles\ibes_actu_gaap2.dta", replace
	
	* Prepare IBES coverage file	
	use "$path\InFiles\ibes_statsumu.dta", clear
	drop if cusip==""
	drop if cusip=="00000000"
	keep if year(statpers)==year(fpedats) & month(statpers)==month(fpedats)
	ren fpedats datadate
	duplicates drop cusip datadate, force
	keep cusip datadate numest
	save "$path\OutFiles\ibes_statsumu2.dta", replace

	* Prepare IBES file	for consensus Street EPS forecasts (needed for ERC tests)
	use "$path\InFiles\ibes_statsumu_eps.dta", clear
	keep if year(statpers)==year(fpedats) & month(statpers)==month(fpedats)
	ren fpedats datadate
	ren medest medest_eps
	keep ticker statpers medest_eps datadate
	sum *
	save "$path\OutFiles\ibes_medest_eps.dta", replace
	
	* Prepare IBES file	for consensus GAAP EPS forecasts (needed for ERC tests)
	use "$path\InFiles\ibes_statsumu_gps.dta", clear
	keep if year(statpers)==year(fpedats) & month(statpers)==month(fpedats)
	ren fpedats datadate
	ren medest medest_gps
	keep ticker statpers medest_gps datadate
	sum *
	save "$path\OutFiles\ibes_medest_gps.dta", replace
	
	* Prepare CRSP pricing data check
	use "$path\InFiles\crspm.dta", clear
	sum date
	joinby date using "$path\InFiles\crspm_vwretd.dta", unmatched(master)
	drop _merge
	sum date vwretd
	gen year=year(date)
	gen month=month(date)
	drop if prc==.
	drop if ret==.
	egen ym=group(year month)
	tsset permno ym
	gen bhr=(ret+1)*(l.ret+1)*(l2.ret+1)-1
	gen bhrm=(vwretd+1)*(l.vwretd+1)*(l2.vwretd+1)-1
	gen bhr12=(ret+1)*(l.ret+1)*(l2.ret+1)*(l3.ret+1)*(l4.ret+1)*(l5.ret+1)*(l6.ret+1)*(l7.ret+1)*(l8.ret+1)*(l9.ret+1)*(l10.ret+1)*(l11.ret+1)-1
	gen mar=bhr-bhrm
	keep permno year month bhr* mar
	gen crspm=1
	duplicates drop permno year month, force
	save "$path\OutFiles\crspm2.dta", replace

	* Prepare firm-quarter sample based on CRSP/Compustat Fundamentals Quarterly
	use "$path\InFiles\fundq.dta", clear
	keep if fic=="USA"
	drop if cik==""
	drop if sic==""

	egen gr=group(gvkey datadate fyearq fqtr)
	egen count=count(gr),by(gr)
	sort count gr liid
	drop if count>1 & liid!="01"
	drop gr count
	egen gr=group(gvkey datadate fyearq fqtr)
	egen count=count(gr),by(gr)
	sum count
	destring gvkey, replace
	drop if atq==.
	drop if atq<=0
	duplicates drop gvkey datadate, force
	duplicates drop gvkey fyearq fqtr, force
	duplicates drop lpermno datadate, force
	duplicates drop lpermno fyearq fqtr, force
	duplicates drop cik fyearq fqtr, force
	egen qid=group(fyearq fqtr)
	tsset gvkey qid
	
	* Create lagged values of relevant variables:
	gen epsfxqm1=l.epsfxq
	gen saleqm4=l4.saleq
	gen lagrdq=l.rdq
	gen lagdatadate=l.datadate
	gen ibqm4=l4.ibq
	gen ibqm3=l3.ibq
	gen ibqm2=l2.ibq
	gen ibqm1=l.ibq
	gen atm1=l.atq
	gen atm2=l2.atq
	gen atm3=l3.atq
	gen atm4=l4.atq

	* Obtain cash flow data from year-to-date data item:
	gen oancf=oancfy if fqtr==1
	replace oancf=d.oancfy if fqtr>1
	replace oancf=oancfy if fqtr>1 & oancf==. & l.oancfy==.
	sum oanc*
	gen oancfm1=l.oancf
	gen oancfm2=l2.oancf
	gen oancfm3=l3.oancf
	gen oancfm4=l4.oancf

	gen ivncf=ivncfy if fqtr==1
	replace ivncf=d.ivncfy if fqtr>1
	replace ivncf=ivncfy if fqtr>1 & ivncf==. & l.ivncfy==.
	sum ivnc*
	
	tsset gvkey qid
	
	gen sample=1
	replace sample=0 if year(datadate)<2006
	replace sample=0 if year(datadate)>2014
	replace sample=0 if fyear<2006
	replace sample=0 if fyear>2014
	sum sample if sample==1
	
	drop if rdq==.
	drop if atq==.
	drop if atq<=0
	drop if niq==.
	drop if ibq==.
	drop if xidoq==.
	drop if epsfxq==.
	drop if ceqq==.
	drop if seqq==.
	drop if prccq==.
	drop if cshoq==.
	drop if cshfdq==.
	keep if sample==1
	sum sample

	*Replace missing and negative stock-based comp expense to zero; some firms have negative because of a "reversal", what explains such reversal is unclear
	replace stkcoq=0 if stkcoq==.
	replace stkcoq=0 if stkcoq<0
	
	*Drop financial firms:
	gen sicnum=sic
	destring sicnum, replace
	gen financial=0
	replace financial=1 if sicnum>5999 & sicnum<7000
	sum financial
	sum sample if financial==0

	* Attach CRSP check
	gen year=year(datadate)
	gen month=month(datadate)
	ren lpermno permno
	joinby permno year month using "$path\OutFiles\crspm2.dta", unmatched(master)
	drop _merge
	sum fyearq crspm
	drop if crspm==.
	sum sample if financial==0 & sample==1

	*Drop observations with extraordinary items and discontinued operations
	replace sample=0 if xidoq!=0
	sum sample if financial==0 & sample==1
	
	*Drop inconsistencies between IBQ and EPSFXQ
	drop if ibq<0 & epsfxq>0
	drop if ibq>0 & epsfxq<0
	drop if ibq==0 & epsfxq>0
	drop if ibq==0 & epsfxq<0
	sum sample if financial==0 & sample==1

	*Drop inconsistencies between basic and diluted EPS
	gen incons=0
	replace incons=1 if epspxq<0 & epsfxq>=0 & epsfxq!=.
	replace incons=1 if epspxq>=0 & epsfxq<0 & epspxq!=.
	sum sample if financial==0 & sample==1 & incons==0
	
	gen loss=0
	replace loss=1 if epsfxq<0
	sum loss
	sum sample if financial==0 & sample==1 & incons==0

	* Attach IBES quarterly forecast data (i.e., require the firm to be followed by an analyst in the month of fiscal quarter end)
	ren cusip cusip9
	gen cusip=substr(cusip9,1,8)
	joinby cusip datadate using "$path\OutFiles\ibes_statsumu2.dta", unmatched(master)
	drop _merge
	sum loss numest
	drop if numest==.
	sum sample if financial==0 & sample==1 & incons==0

	* Attach IBES actual EPS data
	joinby cusip datadate using "$path\OutFiles\ibes_actu2.dta", unmatched(master)
	drop _merge
	sum loss value
	drop if value==.
	drop if anndats==.
	sum sample if financial==0 & sample==1 & incons==0

	sum loss
	joinby cusip datadate using "$path\OutFiles\ibes_actu_gaap2.dta", unmatched(master)
	drop _merge
	sum loss value actualibes_gaap
	drop if actualibes_gaap==.
	sum sample if financial==0 & sample==1 & incons==0
	
	gen ibes_compustat_disagree=0
	replace ibes_compustat_disagree=1 if epsfxq<0 & actualibes_gaap>=0
	replace ibes_compustat_disagree=1 if epsfxq>=0 & actualibes_gaap<0
	sum sample if financial==0 & sample==1 & ibes_compustat_disagree==0 & incons==0
	
	* Lagged IBES anndats
	ren datadate datadate0
	ren anndats anndats0
	ren value value0
	ren lagdatadate datadate
	joinby cusip datadate using "$path\OutFiles\ibes_actu2.dta", unmatched(master)
	drop _merge
	sum loss anndats
	ren anndats laganndats
	ren datadate lagdatadate
	ren datadate0 datadate 
	ren anndats0 anndats 
	drop value
	ren value0 value 

	* Earnings announcement date check:
	gen diff=rdq-anndats
	tabstat diff if abs(diff)<11, by(diff) stats(N)
	drop if abs(diff)>1
	replace rdq=anndats if anndats<rdq
	sum sample if financial==0 & sample==1 & ibes_compustat_disagree==0 & incons==0
	drop diff
	* Lagged EA date check
	replace lagrdq=. if laganndats==.
	replace laganndats=. if lagrdq==.
	gen diff=lagrdq-laganndats
	replace lagrdq=. if abs(diff)>1
	replace laganndats=. if abs(diff)>1
	replace lagrdq=laganndats if laganndats<lagrdq
	drop diff
	sum rdq lagrdq

	* Check for match with 8-K filing
	gen fdate=rdq
	gen check8k=.
	forvalues i=1(1)11{
		qui sort cik fdate
		qui joinby cik fdate using "$path\OutFiles\items8k2.dta", unmatched(master)
		qui drop _merge
		qui sum loss filing8k 
		qui replace check8k=filing8k if check8k==.
		qui replace fdate=fdate+1 if check8k==.
		qui drop filing8k
		sum loss check8k
	}

	ren fdate fdate0
	gen fdate=lagrdq
	gen lagcheck8k=.
	forvalues i=1(1)11{
		qui sort cik fdate
		qui joinby cik fdate using "$path\OutFiles\items8k2.dta", unmatched(master)
		qui drop _merge
		qui sum loss filing8k 
		qui replace lagcheck8k=filing8k if lagcheck8k==.
		qui replace fdate=fdate+1 if lagcheck8k==.
		qui drop filing8k
		sum loss lagcheck8k
	}
	ren fdate lagfdate
	ren fdate0 fdate
	
	drop if check8k==.
	sum sample if financial==0 & sample==1 & ibes_compustat_disagree==0 & incons==0
	sum sample if financial==0 & sample==1 & ibes_compustat_disagree==0 & incons==0 & loss==1
	sum sample if financial==0 & sample==1 & ibes_compustat_disagree==0 & incons==0 & loss==1 & oepsxq<0

	ren value actualibes
	keep gvkey permno cik datadate fyearq fqtr fyr rdq atq niq ibq stkcoq stkcpaq actualibes* fdate epsfxq* sic financial sample loss numest spiq xrdq dpq prccq cshoq ceq saleq saleqm4 intanq gdwlamq gdwliaq gdwlq lagrdq lagcheck8k lagfdate ibqm* atm* xintq bhr* mar cusip ticker oancf* dvpsxq req oiadpq* oepsxq* cshfdq* cshprq piq txtq ivncf* ibes_compustat_disagree epspxq incons
	compress
	save "$path\OutFiles\fundq_sample.dta", replace
	
	* Create sub-files based on sample needed later:
	use "$path\OutFiles\fundq_sample.dta", clear
	keep if sample==1 & financial==0
	keep cik fdate
	gen sample=1
	duplicates drop cik fdate, force
	save "$path\OutFiles\fundq_sample2.dta", replace
	use "$path\OutFiles\fundq_sample.dta", clear
	keep if sample==1 & financial==0
	drop if lagfdate==.
	drop if lagcheck8k==.
	keep cik lagfdate
	ren lagfdate fdate
	gen sample=2
	duplicates drop cik fdate, force
	save "$path\OutFiles\fundq_sample3.dta", replace
	use "$path\OutFiles\fundq_sample2.dta", clear
	append using "$path\OutFiles\fundq_sample3.dta"
	sort cik fdate sample
	duplicates drop cik fdate, force
	save "$path\OutFiles\fundq_sample4.dta", replace
	
	* Create list of 8-Ks to be downloaded with Perl for text search 
	use "$path\InFiles\items8k.dta", clear
	keep if nitem=="2.02"
	joinby cik fdate using "$path\OutFiles\fundq_sample4.dta", unmatched(master)
	drop _merge
	drop if sample==.
	sum sample
	gen downloadId=_n
	gen url=fname
	gen blank=0
	keep downloadId url blank
	sort downloadId
	outsheet using "$path\EDGAR\downloadlist.txt", comma noquote replace

	* Results of basic Perl text-search:
	import delimited "$path\EDGAR\output.csv", clear
	ren file_number downloadId
	sort downloadId
	save "$path\OutFiles\results_textsearch.dta", replace

	* Results of new revised Perl text-search (FEB2016):
	import delimited "$path\EDGAR\output_new.csv", clear
	ren file_number downloadId
	sort downloadId
	save "$path\OutFiles\results_textsearch_new.dta", replace
	
	* Merge 8-K filing data with text search results
	use "$path\InFiles\items8k.dta", clear
	keep if nitem=="2.02"
	joinby cik fdate using "$path\OutFiles\fundq_sample4.dta", unmatched(master)
	drop _merge
	drop if sample==.
	sum sample
	gen downloadId=_n
	sum downloadId

	joinby downloadId using "$path\OutFiles\results_textsearch.dta", unmatched(master)
	drop _merge

	gen nongaap=0
	forvalues i=1(1)15{
		qui replace nongaap=1 if word`i'==1
		sum nongaap
	}

	drop word*
	joinby downloadId using "$path\OutFiles\results_textsearch_new.dta", unmatched(master)
	drop _merge
	gen nongaap_new=0

	forvalues i=1(1)45{
		qui egen max=max(word`i'), by(cik fdate)
		qui replace word`i'=max
		qui drop max
		di `i'
	}
	
	gen sumword=0
	forvalues i=1(1)45{
		qui replace nongaap_new=1 if word`i'==1
		qui replace sumword=sumword+1 if word`i'==1
		sum nongaap_new
	}

	sum sumword
	local q=r(max)
	forvalues i=1(1)`q'{
		gen w_`i'=.
	}
	forvalues i=1(1)`q'{
		forvalues j=1(1)45{
			replace w_`i'=`j' if w_`i'==. & word`j'==1
			replace word`j'=0 if w_`i'==`j'
		}
	}
	
	egen max=max(nongaap), by(cik fdate)
	replace nongaap=max
	drop max
	egen max=max(nongaap_new), by(cik fdate)
	replace nongaap_new=max
	drop max
	
	keep cik fdate nongaap downloadId nongaap_new w_* 
	gen hulp1="file:///C:/LV/EDGAR/"
	gen hulp2=".html"
	egen hulp=concat(hulp1 downloadId hulp2)
	drop downloadId
	ren hulp downloadId
	egen id=group(cik fdate)
	sort id 
	by id: gen j=_n
	reshape wide downloadId, i(id) j(j)
	
	duplicates drop cik fdate, force
	keep cik fdate nongaap downloadId1 downloadId2 downloadId3 nongaap_new w_* 
	
	compress
	sum nongaap nongaap_new 
	save "$path\OutFiles\nongaap.dta", replace
	
	* Create sample with non-GAAP text search results attached
	use "$path\OutFiles\fundq_sample.dta", clear
	joinby cik fdate using "$path\OutFiles\nongaap.dta", unmatched(master)
	drop _merge
		
	keep if sample==1 & financial==0
	drop if ibes_compustat_disagree==1
	drop if incons==1
	
	sum nongaap* 	
	tabstat fyear, by(fyear) stats(N)
	tabstat fyear if loss==1, by(fyear) stats(N)
	tabstat fyear if loss==1 & oepsxq<0, by(fyear) stats(N)
	tabstat nongaap_new, by(fyear)
	tabstat nongaap_new if loss==1 & oepsxq<0, by(fyear)
	egen qid=group(fyearq fqtr)
	tabstat nongaap_new if loss==1 & oepsxq<0, by(qid)
	drop qid	
	save "$path\OutFiles\fundq_sample_nongaap.dta", replace

****************************************************************
****************************************************************
****************************************************************
* STEP 1b: Add additional future outcome variables to sample
****************************************************************
****************************************************************
****************************************************************

	* Use most recent data for future CFO/IBQ/EPSFXQ/OEPXQ data 
	use "$path\Infiles\extra_data_2016.dta", clear

	egen gr=group(gvkey datadate fyearq fqtr)
	egen count=count(gr),by(gr)
	sum count
	destring gvkey, replace
	drop if atq==.
	drop if atq<=0
	drop if fyearq<2002
	drop if year(datadate)<2002
	duplicates drop gvkey datadate, force
	duplicates drop gvkey fyearq fqtr, force
	egen qid=group(fyearq fqtr)
	tsset gvkey qid

	forvalues i=1(1)12{
	gen ibqp`i'=f`i'.ibq
	}
	forvalues i=1(1)12{
	gen oepsxqp`i'=f`i'.oepsxq
	}
	forvalues i=1(1)12{	
	gen epsfxqp`i'=f`i'.epsfxq
	}
	forvalues i=1(1)12{	
	gen cshfdqp`i'=f`i'.cshfdq
	}
	gen oancf=oancfy if fqtr==1
	replace oancf=d.oancfy if fqtr>1
	replace oancf=oancfy if fqtr>1 & oancf==. & l.oancfy==.
	sum oanc*
	forvalues i=1(1)12{	
	gen oancfp`i'=f`i'.oancf
	}
	
	gen ivncf=ivncfy if fqtr==1
	replace ivncf=d.ivncfy if fqtr>1
	replace ivncf=ivncfy if fqtr>1 & ivncf==. & l.ivncfy==.
	sum ivnc*
	gen ivncfp1=f.ivncf
	gen ivncfp2=f2.ivncf
	gen ivncfp3=f3.ivncf
	gen ivncfp4=f4.ivncf

	gen rdqp1=f.rdq
	gen rdqp2=f2.rdq
	gen rdqp3=f3.rdq
	gen rdqp4=f4.rdq

	replace xsgaq=0 if xsgaq==.
	replace xrdq=0 if xrdq==.

	gen opprofp0=(revt-cogsq)-(xsgaq-xrdq)
	gen opprofp1=(f.revt-f.cogsq)-(f.xsgaq-f.xrdq)
	gen opprofp2=(f2.revt-f2.cogsq)-(f2.xsgaq-f2.xrdq)
	gen opprofp3=(f3.revt-f3.cogsq)-(f3.xsgaq-f3.xrdq)
	gen opprofp4=(f4.revt-f4.cogsq)-(f4.xsgaq-f4.xrdq)

	gen grossprofp1=(f.revt-f.cogsq)
	gen grossprofp2=(f2.revt-f2.cogsq)
	gen grossprofp3=(f3.revt-f3.cogsq)
	gen grossprofp4=(f4.revt-f4.cogsq)
	
	keep gvkey fyearq fqtr ibqp* oepsxqp* epsfxqp* cshfdqp* oancfp* ivncfp* rdqp* opprof* grossprof*
	sort gvkey fyearq fqtr
	compress
	save "$path\Outfiles\extra_data_2016.dta", replace

	* June 2017: add extra data for 12-quarter ahead CFO 
	use "$path\Infiles\extra_data_2017.dta", clear

	egen gr=group(gvkey datadate fyearq fqtr)
	egen count=count(gr),by(gr)
	sum count
	destring gvkey, replace
	drop if atq==.
	drop if atq<=0
	drop if fyearq<2002
	drop if year(datadate)<2002
	duplicates drop gvkey datadate, force
	duplicates drop gvkey fyearq fqtr, force
	egen qid=group(fyearq fqtr)
	tsset gvkey qid

	gen oancf=oancfy if fqtr==1
	replace oancf=d.oancfy if fqtr>1
	replace oancf=oancfy if fqtr>1 & oancf==. & l.oancfy==.
	sum oanc*
	forvalues i=1(1)12{	
	gen oancfp_extra_`i'=f`i'.oancf
	}
	
	keep gvkey fyearq fqtr oancfp* 
	sort gvkey fyearq fqtr
	compress
	save "$path\Outfiles\extra_data_2017.dta", replace
	
	* Create future earnings announcement returns data: 
	use "$path\Infiles\erdport1.dta", clear
	replace ret=0 if ret==.b
	replace ret=. if ret==.c
	drop if ret==.
	sort permno date
	egen dateid=group(date)
	tsset permno dateid
	gen bhr=(1+l.ret)*(1+ret)*(1+f.ret)-1
	gen bhrlag=(1+l2.ret)
	forvalues i=3(1)21{
		replace bhrlag=bhrlag*(1+l`i'.ret)
		}
	gen bhrlag20=bhrlag-1
	forvalues i=22(1)61{
		replace bhrlag=bhrlag*(1+l`i'.ret)
		}
	replace bhrlag=bhrlag-1
	ren bhrlag bhrlag60
	gen bhrvw=(1+l.decret)*(1+decret)*(1+f.decret)-1
	gen bhar=bhr-bhrvw
	drop bhr bhrvw
	gen bhr=(1+f2.ret)
	gen bhrdec=(1+f2.decret)
	forvalues i=3(1)61{
		replace bhr=bhr*(1+f`i'.ret)
		replace bhrdec=bhrdec*(1+f`i'.decret)
		
	}
	gen bhar60=bhr-bhrdec
	forvalues i=62(1)121{
		replace bhr=bhr*(1+f`i'.ret)
		replace bhrdec=bhrdec*(1+f`i'.decret)
		
	}
	gen bhar120=bhr-bhrdec
	forvalues i=122(1)241{
		replace bhr=bhr*(1+f`i'.ret)
		replace bhrdec=bhrdec*(1+f`i'.decret)
		
	}
	gen bhar240=bhr-bhrdec
	
	keep permno date bhar bhrlag* bhar60 bhar120 bhar240
	drop if bhar==.
	duplicates drop permno date, force
	sort permno date
	save "$path\Outfiles\crspdaily.dta", replace
	
****************************************************************
****************************************************************
****************************************************************
* STEP 2: Add additional variables and future outcomes and clean up the data
****************************************************************
****************************************************************
****************************************************************

	* Firm age (based on Compustat)
	use "$path\Infiles\compustat_age_data.dta", clear
	drop if at==.
	egen firstyear=min(fyear), by(gvkey)
	keep gvkey firstyear
	duplicates drop gvkey, force
	destring gvkey, replace
	compress
	sort gvkey
	save "$path\Outfiles\age.dta", replace
	
	*Calculate historical earnings volatility over previous 2-8 quarters + sales growth variable
	use "$path\InFiles\xtravar.dta", clear
	keep if fic=="USA"
	drop if cik==""
	egen gr=group(gvkey datadate fyearq fqtr)
	egen count=count(gr),by(gr)
	sum count
	destring gvkey, replace
	drop if atq<=0
	drop if fyearq<2002
	drop if year(datadate)<2002
	duplicates drop gvkey datadate, force
	duplicates drop gvkey fyearq fqtr, force
	duplicates drop cik fyearq fqtr, force
	egen qid=group(fyearq fqtr)
	tsset gvkey qid
	keep gvkey qid fyearq fqtr ibq at saleq
	drop if ibq==.
	compress
	sort gvkey qid
	by gvkey: gen id=_n
	gen id2=id-2 if id>2
	egen count=count(id2),by(gvkey)
	egen fid=group(gvkey) if count>0
	gen earn=ibq/atq
	gen dearn=(ibq-l4.ibq)/l4.atq
	gen sdearn=.
	gen sddearn=.
	save "$path\OutFiles\xtravar1.dta", replace
	use "$path\OutFiles\xtravar1.dta", clear
	local y=20
	sum fid
	local t=ceil(r(max)/`y')
	forvalues u=1(1)`t'{
		qui use "$path\OutFiles\xtravar1.dta", clear
		qui keep if fid>`y'*(`u'-1) & fid<=`y'*`u' 
		qui sum fid
		local k=r(min)
		local l=r(max)
		forvalues i=`k'(1)`l'{
			qui sum id2 if fid==`i'
			qui local q=r(max)
			forvalues j=1(1)`q'{
				qui sum earn if fid==`i' & id<`j'+2 & id>=`j'-6
				qui replace sdearn=r(sd) if fid==`i' & id2==`j'
				qui sum dearn if fid==`i' & id<`j'+2 & id>=`j'-6
				qui replace sddearn=r(sd) if fid==`i' & id2==`j'
			}
		}
		di `u' "/" `t'
		qui save "$path\OutFiles\sdroa_`u'.dta", replace
	}
	use "$path\OutFiles\xtravar1.dta", clear
	local y=20
	sum fid
	local t=ceil(r(max)/`y')
	use "$path\OutFiles\sdroa_1.dta", clear
	forvalues i=2(1)`t'{
		append using "$path\OutFiles\sdroa_`i'.dta"
	}
	tsset
	gen lossperc=0 if l.ibq!=.
	forvalues i=1(1)8{
		replace lossperc=lossperc+1 if l`i'.ibq<0
	}
	drop count
	gen count=1 if l.ibq!=.
	forvalues i=2(1)8{
		replace count=count+1 if l`i'.ibq!=.
	}
	replace lossperc=lossperc/count
	sum lossperc,d
	keep gvkey fyearq fqtr lossperc sdearn sddearn
	sum fyear lossperc sdearn
	compress
	save "$path\OutFiles\stdroa.dta", replace
	
	use "$path\OutFiles\xtravar1.dta", clear
	gen saleqm4=l4.saleq
	replace saleq=. if saleq<=0
	replace saleqm4=. if saleqm4<=0
	gen salesgr=saleq/saleqm4-1
	duplicates drop gvkey fyearq fqtr, force
	keep gvkey fyearq fqtr salesgr
	sort gvkey fyearq fqtr
	save "$path\OutFiles\salesgr.dta", replace

	****************************************
	*Merge and calculate other variables
	****************************************
	use "$path\OutFiles\fundq_sample_nongaap.dta", clear
	* Fama/French 12 industries:
	gen ff12=.
	gen sic0=sic
	destring sic, replace
	* 1 NoDur  Consumer NonDurables : Food, Tobacco, Textiles, Apparel, Leather, Toys
	replace ff12=1 if sic>=100 & sic<=999
    replace ff12=1 if sic>=2000 & sic<=2399
    replace ff12=1 if sic>=2700 & sic<=2749
    replace ff12=1 if sic>=2770 & sic<=2799
    replace ff12=1 if sic>=3100 & sic<=3199
    replace ff12=1 if sic>=3940 & sic<=3989
	* 2 Durbl  Consumer Durables : Cars, TV's, Furniture, Household Appliances
    replace ff12=2 if sic>=2500 & sic<=2519
    replace ff12=2 if sic>=2590 & sic<=2599
    replace ff12=2 if sic>=3630 & sic<=3659
    replace ff12=2 if sic>=3710 & sic<=3711
    replace ff12=2 if sic>=3714 & sic<=3714
    replace ff12=2 if sic>=3716 & sic<=3716
    replace ff12=2 if sic>=3750 & sic<=3751
    replace ff12=2 if sic>=3792 & sic<=3792
    replace ff12=2 if sic>=3900 & sic<=3939
    replace ff12=2 if sic>=3990 & sic<=3999
	* 3 Manuf  Manufacturing : Machinery, Trucks, Planes, Off Furn, Paper, Com Printing
    replace ff12=3 if sic>=2520 & sic<=2589
    replace ff12=3 if sic>=2600 & sic<=2699
    replace ff12=3 if sic>=2750 & sic<=2769
    replace ff12=3 if sic>=3000 & sic<=3099
    replace ff12=3 if sic>=3200 & sic<=3569
    replace ff12=3 if sic>=3580 & sic<=3629
    replace ff12=3 if sic>=3700 & sic<=3709
    replace ff12=3 if sic>=3712 & sic<=3713
    replace ff12=3 if sic>=3715 & sic<=3715
    replace ff12=3 if sic>=3717 & sic<=3749
    replace ff12=3 if sic>=3752 & sic<=3791
    replace ff12=3 if sic>=3793 & sic<=3799
    replace ff12=3 if sic>=3830 & sic<=3839
    replace ff12=3 if sic>=3860 & sic<=3899
	* 4 Enrgy  Oil, Gas, and Coal Extraction and Products
    replace ff12=4 if sic>=1200 & sic<=1399
    replace ff12=4 if sic>=2900 & sic<=2999
	* 5 Chems  Chemicals and Allied Products
    replace ff12=5 if sic>=2800 & sic<=2829
    replace ff12=5 if sic>=2840 & sic<=2899
	* 6 BusEq  Business Equipment : Computers, Software, and Electronic Equipment
    replace ff12=6 if sic>=3570 & sic<=3579
    replace ff12=6 if sic>=3660 & sic<=3692
    replace ff12=6 if sic>=3694 & sic<=3699
    replace ff12=6 if sic>=3810 & sic<=3829
    replace ff12=6 if sic>=7370 & sic<=7379
	* 7 Telcm  Telephone and Television Transmission
    replace ff12=7 if sic>=4800 & sic<=4899
	* 8 Utils  Utilities
    replace ff12=8 if sic>=4900 & sic<=4949
	* 9 Shops  Wholesale, Retail, and Some Services (Laundries, Repair Shops)
    replace ff12=9 if sic>=5000 & sic<=5999
    replace ff12=9 if sic>=7200 & sic<=7299
    replace ff12=9 if sic>=7600 & sic<=7699
	*10 Hlth   Healthcare, Medical Equipment, and Drugs
    replace ff12=10 if sic>=2830 & sic<=2839
    replace ff12=10 if sic>=3693 & sic<=3693
    replace ff12=10 if sic>=3840 & sic<=3859
    replace ff12=10 if sic>=8000 & sic<=8099
	*11 Money  Finance
    replace ff12=11 if sic>=6000 & sic<=6999
	*12 Other  Other : Mines, Constr, BldMt, Trans, Hotels, Bus Serv, Entertainment
	replace ff12=12 if ff12==.
	
	tabstat ff12, by(ff12) stats(N)
	
	joinby gvkey fyearq fqtr using "$path\Outfiles\extra_data_2016.dta", unmatched(master)
	drop _merge

	forvalues i=1(1)4{
		gen date=rdqp`i'
		joinby permno date using "$path\Outfiles\crspdaily.dta", unmatched(master)
		drop _merge
		ren bhar bharp`i'
		drop date bhrlag* bhar60 bhar120 bhar240
	}
	sum bhar*
	
	gen date=fdate
	joinby permno date using "$path\Outfiles\crspdaily.dta", unmatched(master)
	drop _merge
	sum fyear bhar
	
	gen sic2=substr(sic0,1,2)
	egen sic2id=group(sic2)
	sum sic2id
	egen count=count(sic2id), by(sic2id)
	sum count,d
	sum sic2id
	local k=r(max)
	forvalues i=1(1)`k'{
		qui gen indusdum_`i'=0
		qui replace indusdum_`i'=1 if sic2id==`i'
		di `i'
	}
	gen year=year(datadate)
	gen quarter=quarter(datadate)
	egen qid=group(year quarter)
	sum qid
	local k=r(max)
	forvalues i=1(1)`k'{
		qui gen timedum_`i'=0
		qui replace timedum_`i'=1 if qid==`i'
		di `i'
	}
	gen mv=prccq*cshoq
	gen lnmv=ln(mv)
	xtile xmv=mv,nq(10)
	replace xmv=(xmv-1)/9
	gen btm=ceq/mv
	xtile xbtm=btm,nq(10)
	replace xbtm=(xbtm-1)/9
	gen lnta=ln(atq)
	xtile xat=atq,nq(10)
	replace xat=(xat-1)/9
	gen lnnumest=ln(numest)
	xtile xnumest=numest,nq(10)
	replace xnumest=(xnumest-1)/9
	xtile xbhr=bhr,nq(10)
	replace xbhr=(xbhr-1)/9
	xtile xbhrlag60=bhrlag60,nq(10)
	replace xbhrlag60=(xbhrlag60-1)/9
	
	gen ratio=stkcoq/abs(ibq)
	xtile xratio=ratio,nq(10)
	replace xratio=(xratio-1)/9
	gen earn=ibq/atq
	xtile xearn=earn,nq(10)
	replace xearn=(xearn-1)/9
	gen dearn=(ibq-ibqm4)/atm4
	xtile xdearn=dearn,nq(10)
	replace xdearn=(xdearn-1)/9
	
	gen earnpos=0
	replace earnpos=ibq/atq if ibq>0 & loss==0
	xtile xearnpos=earnpos if earnpos!=0,nq(9)
	replace xearnpos=0 if xearnpos==.
	replace xearnpos=xearnpos/9
	
	gen earnneg=0
	replace earnneg=ibq/atq if ibq<0 & loss==1
	xtile xearnneg=earnneg if earnneg!=0,nq(9)
	replace xearnneg=xearnneg-10
	replace xearnneg=0 if xearnneg==.
	replace xearnneg=xearnneg/9
	
	replace dpq=0 if dpq==.
	replace dpq=0 if dpq<=0
	replace xrdq=0 if xrdq==.
	replace xrdq=0 if xrdq<=0
	replace xint=0 if xint==.
	replace xint=0 if xint<=0
	gen depr=dpq/atq
	xtile xdepr=depr,nq(10)
	replace xdepr=(xdepr-1)/9
	gen rnd=xrd/atq
	xtile xrnd=rnd if rnd>0,nq(9)
	replace xrnd=0 if xrnd==.
	replace xrnd=xrnd/9
	gen interest=xint/atq
	xtile xinterest=interest if interest>0,nq(9)
	replace xinterest=0 if xinterest==.
	replace xinterest=xinterest/9
		
	gen specialpos=0
	replace specialpos=spiq/atq if spiq>0 & spiq!=.
	xtile xspecialpos=specialpos if specialpos!=0,nq(9)
	replace xspecialpos=0 if xspecialpos==.
	replace xspecialpos=xspecialpos/9

	gen specialneg=0
	replace specialneg=spiq/atq if spiq<0
	xtile xspecialneg=specialneg if specialneg!=0,nq(9)
	replace xspecialneg=xspecialneg-10
	replace xspecialneg=0 if xspecialneg==.
	replace xspecialneg=xspecialneg/9
	
	replace intanq=0 if intanq==.
	gen inta=intanq/atq
	xtile xinta=inta if inta>0,nq(9) 
	replace xinta=0 if xinta==.
	replace xinta=xinta/9
	
	gen expsc=stkcoq/atq
	xtile xexpsc=expsc,nq(10)
	replace xexpsc=(xexpsc-1)/9
	
	gen street=0
	replace street=1 if round(actualibes_gaap,0.01)!=round(actualibes,0.01)
	sum street

	joinby gvkey fyearq fqtr using "$path\OutFiles\stdroa.dta", unmatched(master)
	drop _merge
	sum fyear sd* lossperc
	xtile xsdearn=sdearn,nq(10)
	replace xsdearn=(xsdearn-1)/9
	xtile xsddearn=sddearn,nq(10)
	replace xsddearn=(xsddearn-1)/9

	joinby gvkey fyearq fqtr using "$path\OutFiles\salesgr.dta", unmatched(master)
	drop _merge
	xtile xsalesgr=salesgr,nq(10)
	replace xsalesgr=(xsalesgr-1)/9
	
	gen q2=0
	replace q2=1 if fqtr==2
	gen q3=0
	replace q3=1 if fqtr==3
	gen q4=0
	replace q4=1 if fqtr==4
	
	sort gvkey
	joinby gvkey using "$path\Outfiles\age.dta", unmatched(master)
	drop _merge
	sum fyear firstyear
	gen age=fyear+1-firstyear
	gen lnage=ln(age)
	sum lnage,d
	replace lnage=r(p1) if lnage<r(p1)
	replace lnage=r(p99) if lnage>r(p99) & lnage!=.
	sum age,d
	replace age=r(p1) if age<r(p1)
	replace age=r(p99) if age>r(p99) & age!=.
	xtile xage=age,nq(10)
	replace xage=(xage-1)/9
	
	gen cfo=oancf/atq
	gen acc=(ibq-oancf)/atq
	xtile xcfo=cfo,nq(10)
	replace xcfo=(xcfo-1)/9
	xtile xacc=acc,nq(10)
	replace xacc=(xacc-1)/9

	gen earnp1=(ibqp1+ibqp2+ibqp3+ibqp4)/atq
	gen earnp1_1=(ibqp1)/atq if earnp1!=.
	gen earnp1_2=(ibqp2)/atq if earnp1!=.
	gen earnp1_3=(ibqp3)/atq if earnp1!=.
	gen earnp1_4=(ibqp4)/atq if earnp1!=.
	gen opincp1=(oepsxqp1*cshfdqp1+oepsxqp2*cshfdqp2+oepsxqp3*cshfdqp3+oepsxqp4*cshfdqp4)/(atq)
	gen cfop1=(oancfp1+oancfp2+oancfp3+oancfp4)/atq
	gen fcfp1=(oancfp1+oancfp2+oancfp3+oancfp4+ivncfp1+ivncfp2+ivncfp3+ivncfp4)/atq

	gen opincp1_12q=(oepsxqp1*cshfdqp1+oepsxqp2*cshfdqp2+oepsxqp3*cshfdqp3+oepsxqp4*cshfdqp4+oepsxqp5*cshfdqp5+oepsxqp6*cshfdqp6+oepsxqp7*cshfdqp7+oepsxqp8*cshfdqp8+oepsxqp9*cshfdqp9+oepsxqp10*cshfdqp10+oepsxqp11*cshfdqp11+oepsxqp12*cshfdqp12)/(atq)

	* June 2017 addition:
	joinby gvkey fyearq fqtr using "$path\Outfiles\extra_data_2017.dta", unmatched(master)
	drop _merge
	sum oancfp_extra_*

	forvalues i=5(1)12{
		replace oancfp`i'=oancfp_extra_`i' if oancfp`i'==.
	}
	gen cfop1_12q=(oancfp1+oancfp2+oancfp3+oancfp4+oancfp5+oancfp6+oancfp7+oancfp8+oancfp9+oancfp10+oancfp11+oancfp12)/atq
	drop oancfp_extra_*
	
	forvalues i=1(1)12{
		gen lossp`i'=0 if epsfxqp`i'!=.
	}
	forvalues i=1(1)12{
		replace lossp`i'=1 if epsfxqp`i'<0
	}
	gen freqlossp1=(lossp1+lossp2+lossp3+lossp4)/4
	gen freqlossp1_12q=(lossp1+lossp2+lossp3+lossp4+lossp5+lossp6+lossp7+lossp8+lossp9+lossp10+lossp11+lossp12)/12
	
	gen earn0=earn
	sum earn,d
	replace earn=r(p1) if earn<r(p1)
	replace earn=r(p99) if earn>r(p99) & earn!=.
	sum earnp1,d
	replace earnp1=r(p1) if earnp1<r(p1)
	replace earnp1=r(p99) if earnp1>r(p99) & earnp1!=.
	sum earnp1_1,d
	replace earnp1_1=r(p1) if earnp1_1<r(p1)
	replace earnp1_1=r(p99) if earnp1_1>r(p99) & earnp1_1!=.
	sum earnp1_2,d
	replace earnp1_2=r(p1) if earnp1_2<r(p1)
	replace earnp1_2=r(p99) if earnp1_2>r(p99) & earnp1_2!=.
	sum earnp1_3,d
	replace earnp1_3=r(p1) if earnp1_3<r(p1)
	replace earnp1_3=r(p99) if earnp1_3>r(p99) & earnp1_3!=.
	sum earnp1_4,d
	replace earnp1_4=r(p1) if earnp1_4<r(p1)
	replace earnp1_4=r(p99) if earnp1_4>r(p99) & earnp1_4!=.
	sum opincp1,d
	replace opincp1=r(p1) if opincp1<r(p1)
	replace opincp1=r(p99) if opincp1>r(p99) & opincp1!=.
	sum cfo,d
	replace cfo=r(p1) if cfo<r(p1)
	replace cfo=r(p99) if cfo>r(p99) & cfo!=.
	sum acc,d
	replace acc=r(p1) if acc<r(p1)
	replace acc=r(p99) if acc>r(p99) & acc!=.
	sum cfop1,d
	replace cfop1=r(p1) if cfop1<r(p1)
	replace cfop1=r(p99) if cfop1>r(p99) & cfop1!=.
	sum fcfp1,d
	replace fcfp1=r(p1) if fcfp1<r(p1)
	replace fcfp1=r(p99) if fcfp1>r(p99) & fcfp1!=.

	sum cfop1_12q,d
	replace cfop1_12q=r(p1) if cfop1_12q<r(p1)
	replace cfop1_12q=r(p99) if cfop1_12q>r(p99) & cfop1_12q!=.
	sum opincp1_12q,d
	replace opincp1_12q=r(p1) if opincp1_12q<r(p1)
	replace opincp1_12q=r(p99) if opincp1_12q>r(p99) & opincp1_12q!=.
	
	sum expsc,d
	replace expsc=r(p1) if expsc<r(p1)
	replace expsc=r(p99) if expsc>r(p99) & expsc!=.
	sum salesgr,d
	replace salesgr=r(p1) if salesgr<r(p1)
	replace salesgr=r(p99) if salesgr>r(p99) & salesgr!=.
	sum lnta,d
	replace lnta=r(p1) if lnta<r(p1)
	replace lnta=r(p99) if lnta>r(p99) & lnta!=.
	sum sddearn,d
	replace sddearn=r(p1) if sddearn<r(p1)
	replace sddearn=r(p99) if sddearn>r(p99) & sddearn!=.
	gen lnsddearn=ln(sddearn)
	sum sdearn,d
	replace sdearn=r(p1) if sdearn<r(p1)
	replace sdearn=r(p99) if sdearn>r(p99) & sdearn!=.
	gen lnsdearn=ln(sdearn)
	sum btm,d
	replace btm=r(p1) if btm<r(p1)
	replace btm=r(p99) if btm>r(p99) & btm!=.
	replace spiq=0 if spiq==.
	gen special=spiq/atq
	gen spdum=0
	replace spdum=1 if special!=0
	sum special,d
	replace special=r(p1) if special<r(p1)
	replace special=r(p99) if special>r(p99) & special!=.
	sum depr,d
	replace depr=r(p1) if depr<r(p1)
	replace depr=r(p99) if depr>r(p99) & depr!=.
	sum rnd,d
	replace rnd=r(p1) if rnd<r(p1)
	replace rnd=r(p99) if rnd>r(p99) & rnd!=.
	sum interest,d
	replace interest=r(p1) if interest<r(p1)
	replace interest=r(p99) if interest>r(p99) & interest!=.
	sum epsfxq,d
	replace epsfxq=r(p1) if epsfxq<r(p1)
	replace epsfxq=r(p99) if epsfxq>r(p99) & epsfxq!=.
	
	sum bhr,d
	replace bhr=r(p1) if bhr<r(p1)
	replace bhr=r(p99) if bhr>r(p99) & bhr!=.
	sum mar,d
	replace mar=r(p1) if mar<r(p1)
	replace mar=r(p99) if mar>r(p99) & mar!=.

	sum bhrlag20,d
	replace bhrlag20=r(p1) if bhrlag20<r(p1)
	replace bhrlag20=r(p99) if bhrlag20>r(p99) & bhrlag20!=.
	sum bhrlag60,d
	replace bhrlag60=r(p1) if bhrlag60<r(p1)
	replace bhrlag60=r(p99) if bhrlag60>r(p99) & bhrlag60!=.
	sum bhar60,d
	replace bhar60=r(p1) if bhar60<r(p1)
	replace bhar60=r(p99) if bhar60>r(p99) & bhar60!=.
	sum bhar120,d
	replace bhar120=r(p1) if bhar120<r(p1)
	replace bhar120=r(p99) if bhar120>r(p99) & bhar120!=.
	sum bhar240,d
	replace bhar240=r(p1) if bhar240<r(p1)
	replace bhar240=r(p99) if bhar240>r(p99) & bhar240!=.
	
	sum bhar,d
	replace bhar=r(p1) if bhar<r(p1)
	replace bhar=r(p99) if bhar>r(p99) & bhar!=.
	gen bharsum=bharp1+bharp2+bharp3+bharp4
	sum bharsum,d
	replace bharsum=r(p1) if bharsum<r(p1)
	replace bharsum=r(p99) if bharsum>r(p99) & bharsum!=.
	sum bharp1,d
	replace bharp1=r(p1) if bharp1<r(p1)
	replace bharp1=r(p99) if bharp1>r(p99) & bharp1!=.
	sum bharp2,d
	replace bharp2=r(p1) if bharp2<r(p1)
	replace bharp2=r(p99) if bharp2>r(p99) & bharp2!=.
	sum bharp3,d
	replace bharp3=r(p1) if bharp3<r(p1)
	replace bharp3=r(p99) if bharp3>r(p99) & bharp3!=.
	sum bharp4,d
	replace bharp4=r(p1) if bharp4<r(p1)
	replace bharp4=r(p99) if bharp4>r(p99) & bharp4!=.

	gen assets=atq
	sum assets,d
	replace assets=r(p1) if assets<r(p1)
	replace assets=r(p99) if assets>r(p99) & assets!=.

	forvalues i=1(1)12{
	gen ffdum_`i'=0
		replace ffdum_`i'=1 if ff12==`i'
	}
	
	gen rnddum=0
	replace rnddum=1 if rnd>0 & rnd!=.
	gen divdum=0
	replace divdum=1 if dvpsxq>0 & dvpsxq!=.
	gen div=(dvpsxq*cshfdq)/atq
	xtile xdiv=div if div>0,nq(9)
	replace xdiv=0 if xdiv==.
	replace xdiv=xdiv/9
	sum div,d
	replace div=r(p1) if div<r(p1)
	replace div=r(p99) if div>r(p99) & div!=.

	sum nongaap_new sic2id
	egen sum=sum(nongaap_new), by(qid sic2id)
	egen ngcount=count(nongaap_new), by(qid sic2id)
	sum sum ngcount
	
	gen ng_indus=(sum-1)/(ngcount-1) if ngcount>1
	sum ng_indus
	drop sum ngcount 

	gen sic1=substr(sic0,1,1)
	egen sic1id=group(sic1)
	egen sum=sum(nongaap_new), by(qid sic1id)
	egen ngcount=count(nongaap_new), by(qid sic1id)
	sum sum ngcount
	
	replace ng_indus=(sum-1)/(ngcount-1) if ngcount>1 & ng_indus==.
	sum ng_indus
	drop sum ngcount 
	replace ng_indus=0 if ng_indus==.
	
	logit nongaap_new ng_indus
	
	sum lnnumest,d
	replace lnnumest=r(p1) if lnnumest<r(p1)
	replace lnnumest=r(p99) if lnnumest>r(p99) & lnnumest!=.

	gen opinc=(oepsxq*cshfdq)/(atq)
	sum opinc,d
	replace opinc=r(p1) if opinc<r(p1)
	replace opinc=r(p99) if opinc>r(p99) & opinc!=.

	gen oploss=0
	replace oploss=1 if loss==1 & oepsxq<0
	
	compress
	save "$path\OutFiles\fundq_sample_nongaap2.dta", replace
	
****************************************************************
****************************************************************
****************************************************************
* STEP 3: Descriptives and determinants tests - Figure 1 and Table 1
****************************************************************
****************************************************************
****************************************************************

	****************************************************
	* Figure 1
	****************************************************
	use "$path\OutFiles\fundq_sample_nongaap2.dta", clear
	tabstat fyear, by(fyear) stats(N)
	tabstat loss, by(fyear) 
	tabstat loss if loss==1, by(fyear) stats(N)
	tabstat oploss, by(fyear) 
	tabstat oploss if oploss==1, by(fyear) stats(N)
	tabstat nongaap_new if oploss==1, by(fyear) 

	* (Untabulated) Assess whether loss frequency over time is driven by changes in sample composition
	egen miny=min(fyear), by(cik)
	egen maxy=max(fyear), by(cik)
	tabstat loss if miny==2006 & maxy==2014, by(fyear) stats(N mean)
 	tabstat loss oploss if miny==2006 & maxy==2014, by(fyear) 

	****************************************************
	* Table 1 - Panel B: Industry distribution
	****************************************************
	tabstat ff12, by(ff12) stats(N)
	tabstat oploss, by(ff12) 
	tabstat oploss if oploss==1, by(ff12) stats(N)
	tabstat ff12 if oploss==1 & nongaap_new==1, by(ff12) stats(N)
	tabstat nongaap_new if oploss==1, by(ff12) 

	* (Untabulated) Descriptives for industry NG frequency --- overall and profit firms
	tabstat nongaap_new, by(ff12) 
	drop if loss==1 & oploss==1
	tabstat ff12, by(ff12) stats(N)
	tabstat ff12 if nongaap_new==1, by(ff12) stats(N)
	tabstat nongaap_new, by(ff12) 

	***********************************************************************
	* Table 1 - Panel C: Determinants regressions
	***********************************************************************
	use "$path\OutFiles\fundq_sample_nongaap2.dta", clear
	drop if cfo==.
	drop if cfop1==.
	drop if earnp1==.
	drop if opincp1==.
	drop if salesgr==.
	drop if lnsdearn==.

	* Use "nongaap_new" indicator based on stage 2 text search of 8-K filings
	gen y=nongaap_new
	cluster2 y timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus if loss==1, fcluster(cik) tcluster(qid)
	cluster2 y timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus if loss==0, fcluster(cik) tcluster(qid)
	
	* Differences between coefficients across profit and loss observations
	gen dum=0 if loss==0
	replace dum=1 if loss==1

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_lnta=dum*lnta
	gen inter_btm=dum*btm
	gen inter_lnage=dum*lnage
	gen inter_cfo=dum*cfo
	gen inter_acc=dum*acc
	gen inter_salesgr=dum*salesgr
	gen inter_lnsdearn=dum*lnsdearn
	gen inter_lnsp=dum*spdum	
	gen inter_rnd=dum*rnd
	gen inter_div=dum*div
	gen inter_expsc=dum*expsc
	gen inter_inta=dum*inta
	gen inter_depr=dum*depr
	gen inter_ng_ind=dum*ng_ind
	cluster2 y timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_ind time_* inter_*, fcluster(cik) tcluster(qid)
	
	***********************************************************************
	* (Untabulated) Persistence/informativeness of earnings in loss versus profit firms
	***********************************************************************
	use "$path\OutFiles\fundq_sample_nongaap2.dta", clear
	drop if cfo==.
	drop if cfop1==.
	drop if earnp1==.
	drop if opincp1==.
	drop if salesgr==.
	drop if lnsdearn==.

	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn if loss==1, fcluster(cik) tcluster(qid)
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn if loss==0, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn if loss==1, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn if loss==0, fcluster(cik) tcluster(qid)

	* Differences between coefficients across profit and loss observations
	gen dum=loss
	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen inter=dum*earn
	
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)
	
	
****************************************************************
****************************************************************
****************************************************************
* STEP 4: Merge with hand-collected data
****************************************************************
****************************************************************
****************************************************************

	/*
	As explained in detail in Appendix B the, the hand-collection of data proceeded in two stages.
	In stage 1 we hand-collected data for 3629 firm-quarters, in stage 2 another 2779 firm-quarters.
	The data files created from the handcollection ("data_clean" and "data_clean2") contain the
	following variables:
		cik = CIK identifier
		fdate = SEC 8-K filing date
		eps_dil_ng = diluted non-GAAP EPS 
		ni_ng = non-GAAP earnings in $mln
		ng = indicator variable equal to 1 if non-GAAP earnings measure disclosed, 0 otherwise
		dummy_comp = indicator variable for whether stock-based compensation expense is excluded
		dummy_amort = indicator variable for whether acquired intangible amortization expense is excluded
	*/

	************************************
	* Round 1 handcollected data
	************************************	
	use "$path\EDGAR\data_clean.dta", clear
	sum *
	sum ng
	sum ng if ng==1
	
	************************************
	* Round 2 handcollected data
	************************************	
	use "$path\EDGAR\data_clean2.dta", clear
	sum *
	sum ng
	sum ng if ng==1

	**************************************************************
	*Combine the initial sample with the handcollected data
	**************************************************************
	use "$path\OutFiles\fundq_sample_nongaap2.dta", clear
	destring cik, replace
	joinby cik fdate using "$path\EDGAR\data_clean.dta", unmatched(master)
	drop _merge
	gen round=1 if ng!=.
	
	ren ng n
	ren eps_dil_ng e
	ren ni_ng n2
	ren dummy_comp d1
	ren dummy_amort d2
	
	joinby cik fdate using "$path\EDGAR\data_clean2.dta", unmatched(master)
	drop _merge
	replace n=ng if n==.
	replace e=eps_dil_ng if e==.
	replace n2=ni_ng if n2==.
	replace d1=dummy_comp if d1==.
	replace d2=dummy_amort if d2==.
	drop ng eps_dil_ng ni_ng dummy_comp dummy_amort
	ren n ng
	ren e eps_dil_ng 
	ren n2 ni_ng 
	ren d1 dummy_comp 
	ren d2 dummy_amort 
	replace round=2 if round==. & ng!=.
	
	sum ng dummy_*
	sum dummy_* if round==1
	sum dummy_* if round==2
	
	gen treatnew=0 if loss==1 & oepsxq<0 & ng!=1
	replace treatnew=2 if ng==1 & ni_ng>=0
	replace treatnew=1 if ng==1 & treatnew==.
	tabstat treatnew, by(treatnew) stats(N)
	tabstat treatnew ng, by(treatnew) 
	save "$path\OutFiles\fundq_sample_nongaap3.dta", replace
	
	**********************************
	*Descriptive stats on handcollection and further cleaning:
	**********************************
	use "$path\OutFiles\fundq_sample_nongaap3.dta", clear
	* Firm-quarters with operating loss:
	sum fyearq if loss==1 & oepsxq<0
	* Firm-quarters with non-GAAP earnings:
	sum fyearq if ng==1 & loss==1 & oepsxq<0
	* Firm-quarters with non-GAAP earnings based on text-search:
	sum fyearq if nongaap_new==1 & loss==1 & oepsxq<0
	sum fyearq if nongaap_new==1 & loss==1 & oepsxq<0 & ng==1
	sum fyearq if nongaap_new==0 & loss==1 & oepsxq<0 & ng==1
	sum fyearq if nongaap_new==0 & loss==1 & oepsxq<0 & ng==1 & nongaap==0
	* --> There are 5174-5128=46 firm-quarters for which we found NG in first stage, while second stage text search does not trigger NG
	* --> There are 5428-5128=300 firm-quarters for which the 2nd round text search triggered NG but for which we did not find NG

	drop if cfo==.
	drop if cfop1==.
	drop if earnp1==.
	drop if opincp1==.
	drop if salesgr==.
	drop if lnsdearn==.

	gen ni_ng_sc=ni_ng/atq
	gen ni_ng_sc0=ni_ng_sc
	gen excl=earn0-ni_ng_sc0
	sum excl,d
	replace excl=r(p1) if excl<r(p1)
	replace excl=r(p99) if excl>r(p99) & excl!=.

	sum ni_ng_sc,d
	replace ni_ng_sc=r(p1) if ni_ng_sc<r(p1) & ni_ng_sc!=.
	replace ni_ng_sc=r(p99) if ni_ng_sc>r(p99) & ni_ng_sc!=.

	gen eps_dil_ng0=eps_dil_ng
	sum eps_dil_ng,d
	replace eps_dil_ng=r(p1) if eps_dil_ng<r(p1)
	replace eps_dil_ng=r(p99) if eps_dil_ng>r(p99) & eps_dil_ng!=.
	
	gen actualibes2=actualibes if actualibes!=actualibes_gaap
	sum actualibes2,d
	replace actualibes2=r(p1) if actualibes2<r(p1)
	replace actualibes2=r(p99) if actualibes2>r(p99) & actualibes2!=.
	
	gen d=0 if treatnew==1
	replace d=1 if treatnew==2
	gen ana_agree=0
	replace ana_agree=1 if actualibes2!=.
	tabstat ana_agree, by(d)
	
	cluster2 ana_agree d, fcluster(gvkey) tcluster(qid)
		
	sum loss if loss==1 & oepsxq<0

	ren earn earn_gaap
	drop xearn 
	gen profit=epsfxq*cshfdq
	sum profit
	gen earn=profit/atq
	sum earn,d
	replace earn=r(p1) if earn<r(p1)
	replace earn=r(p99) if earn>r(p99) & earn!=.
	xtile xearn=earn,nq(10)
	replace xearn=(xearn-1)/9
	
	gen acc_gaap=acc
	save "$path\OutFiles\fundq_sample_nongaap4.dta", replace

****************************************************************
****************************************************************
****************************************************************
* STEP 5: Descriptive statistics Table 2
****************************************************************
****************************************************************
****************************************************************

	* Panel A:
	use "$path\OutFiles\fundq_sample_nongaap3.dta", clear
	* Firm-quarters with operating loss:
	sum fyearq if loss==1 & oploss==1
	* Firm-quarters with non-GAAP earnings:
	sum fyearq if ng==1 & loss==1 & oploss==1
	* Types of non-GAAP disclosures:
	tabstat treatnew, by(treatnew) stats(N)
	
	* Restrict sample to observations with available data for tests:
	drop if cfo==.
	drop if cfop1==.
	drop if earnp1==.
	drop if opincp1==.
	drop if salesgr==.
	drop if lnsdearn==.
	* Firm-quarters with operating loss:
	sum fyearq if loss==1 & oploss==1
	* Firm-quarters with non-GAAP earnings:
	sum fyearq if ng==1 & loss==1 & oploss==1
	tabstat treatnew, by(treatnew) stats(N)

	* Panel B:
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	tabstat assets btm age earn cfo acc epsfxq ni_ng_sc eps_dil_ng dummy_* actualibes2 salesgr sdearn spdum rnd div expsc inta depr ng_indus if treatnew==1, columns(statistics) stats(N mean median)
	tabstat assets btm age earn cfo acc epsfxq ni_ng_sc eps_dil_ng dummy_* actualibes2 salesgr sdearn spdum rnd div expsc inta depr ng_indus if treatnew==2, columns(statistics) stats(N mean median)
	tabstat assets btm age earn cfo acc epsfxq ni_ng_sc eps_dil_ng dummy_* actualibes2 salesgr sdearn spdum rnd div expsc inta depr ng_indus if treatnew==0, columns(statistics) stats(N mean median)
	tabstat dummy_* if treatnew==1, columns(statistics) stats(N mean median)
	tabstat dummy_* if treatnew==2, columns(statistics) stats(N mean median)

	* Untabulated :
	drop d
	gen d=0 if treatnew==2
	replace d=1 if treatnew==1
	cluster2 dummy_comp d, fcluster(gvkey) tcluster(qid)
	cluster2 dummy_amort d, fcluster(gvkey) tcluster(qid)	
	drop d
	
	sum actualibes2 if treatnew==2
	sum actualibes2 if treatnew==2 & actualibes2<0
	
	tabstat dummy_* if treatnew==1, columns(statistics) stats(N mean median)
	tabstat dummy_* if treatnew==2, columns(statistics) stats(N mean median)
	gen dummy_both=0
	replace dummy_both=1 if dummy_comp==1 & dummy_amort==1
	tabstat dummy_* if treatnew==1, columns(statistics) stats(N mean median)
	tabstat dummy_* if treatnew==2, columns(statistics) stats(N mean median)

	gen d=0 if treatnew==2
	replace d=1 if treatnew==1
	cluster2 dummy_both d, fcluster(gvkey) tcluster(qid)
	drop d
	
	* Further examine agreement between analysts and managers:
	sum eps_dil_ng actualibes2 if actualibes2!=. & treatnew==2
	gen agree2=0 if actualibes2!=. & treatnew==2
	gen a=round(100*actualibes2)
	gen b=round(100*eps_dil_ng0)
	replace agree2=1 if a==b & treatnew==2
	sum agree2
	sum agree2 if agree2==1
	
****************************************************************
****************************************************************
****************************************************************
* STEP 6: Tables 3-4 predictive ability for future performance
****************************************************************
****************************************************************
****************************************************************
	
	**********************************************************
	* Table 3: Predictive Ability of GAAP versus Non-GAAP Earnings for Future Cash Flows
	* Variable "treatnew" captures:
	*    0 = GAAP-only loss firm-quarters
	*    1 = Non-GAAP loss firm-quarters (GAAP and non-GAAP earnings < 0)
	*    2 = Loss converters (GAAP earnings < 0 and non-GAAP earnings > 0)
	**********************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==0, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==1, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==2, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==2, fcluster(cik) tcluster(qid)
	
	* Compare coefficient on GAAP earnings between GAAP-only loss and non-GAAP loss firm-quarters:	
	gen dum=0 if treatnew==0
	replace dum=1 if treatnew==1

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen inter=dum*earn_gaap
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)
	drop dum ind_inter_* time_inter_* inter_* inter
	
	* Compare coefficient on GAAP earnings between GAAP-only loss and loss converter firm-quarters:	
	gen dum=0 if treatnew==0
	replace dum=1 if treatnew==2

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen inter=dum*earn_gaap
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	* Compare coefficients on GAAP versus non-GAAP earnings for same set of firms using stacked regressions:
	* For non-GAAP loss firms:
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	keep if treatnew==1
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)
	
	* Compare coefficients on GAAP versus non-GAAP earnings for same set of firms using stacked regressions:
	* For loss converterts:
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	keep if treatnew==2
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	**********************************************************
	* Table 4: Differential predictive ability of GAAP versus non-GAAP earnings for future operating earnings
	* Variable "treatnew" captures:
	*    0 = GAAP-only loss firm-quarters
	*    1 = Non-GAAP loss firm-quarters (GAAP and non-GAAP earnings < 0)
	*    2 = Loss converters (GAAP earnings < 0 and non-GAAP earnings > 0)
	**********************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==0, fcluster(cik) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==1, fcluster(cik) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==2, fcluster(cik) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1, fcluster(cik) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==2, fcluster(cik) tcluster(qid)
	
	* Compare coefficient on GAAP earnings between GAAP-only loss and non-GAAP loss firm-quarters:	
	gen dum=0 if treatnew==0
	replace dum=1 if treatnew==1

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen inter=dum*earn_gaap
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)
	drop dum ind_inter_* time_inter_* inter_* inter
	
	* Compare coefficient on GAAP earnings between GAAP-only loss and loss converter firm-quarters:	
	gen dum=0 if treatnew==0
	replace dum=1 if treatnew==2

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen inter=dum*earn_gaap
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	* Compare coefficients on GAAP versus non-GAAP earnings for same set of firms using stacked regressions:
	* For non-GAAP loss firms:
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	keep if treatnew==1
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)
	
	* Compare coefficients on GAAP versus non-GAAP earnings for same set of firms using stacked regressions:
	* For loss converterts:
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	keep if treatnew==2
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	**********************************************************
	* Untabulated: controlling for current cash flow from operations (FOOTNOTE 30)
	**********************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn cfo earn_gaap if treatnew==0, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn cfo earn_gaap if treatnew==1, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn cfo earn_gaap if treatnew==2, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn cfo ni_ng_sc excl if treatnew==1, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn cfo ni_ng_sc excl if treatnew==2, fcluster(gvkey) tcluster(qid)
	
	**********************************************************
	* Untabulated: 3-years (12 quarters) of future cash flows (FOOTNOTE 30)
	**********************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	cluster2 cfop1_12q indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==0, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1_12q indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==1, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1_12q indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==2, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1_12q indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1_12q indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==2, fcluster(gvkey) tcluster(qid)
		
	**********************************************************
	* Untabulated: future bottom-line earnings
	**********************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==0, fcluster(gvkey) tcluster(qid)
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==1, fcluster(gvkey) tcluster(qid)
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==2, fcluster(gvkey) tcluster(qid)
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1, fcluster(gvkey) tcluster(qid)
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==2, fcluster(gvkey) tcluster(qid)

	**********************************************************
	* Untabulated: future free cash flows 
	**********************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==0, fcluster(gvkey) tcluster(qid)
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==1, fcluster(gvkey) tcluster(qid)
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if treatnew==2, fcluster(gvkey) tcluster(qid)
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1, fcluster(gvkey) tcluster(qid)
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==2, fcluster(gvkey) tcluster(qid)
	
	
****************************************************************
****************************************************************
****************************************************************
* STEP 7: Table 5 PSM
****************************************************************
****************************************************************
****************************************************************
	
	**********************************************************
	* Table 5: Differential predictive ability for propensity-score matched samples
	* Variable "treatnew" captures:
	*    0 = GAAP-only loss firm-quarters
	*    1 = Non-GAAP loss firm-quarters (GAAP and non-GAAP earnings < 0)
	*    2 = Loss converters (GAAP earnings < 0 and non-GAAP earnings > 0)
	**********************************************************

	************************************
	* Non-GAAP loss versus GAAP-only: PSM1  
	************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=.
	replace treatment=0 if treatnew==0
	replace treatment=1 if treatnew==1

	* Logit estimation before matching:
	logit2 treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr, fcluster(cik) tcluster(qid)
	
	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr, n(1) common caliper(0.01) logit noreplace
	drop if _weight==.
	replace _weight=0 if treatment==0
	sum _weight
	tabstat _weight, by(_weight) stats(N)
	replace treatment=_weight

	* Logit estimation after matching:
	logit2 treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr, fcluster(cik) tcluster(qid)

	* Covariate balance:
	tabstat lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr if _weight==1, columns(statistics)
	tabstat lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr if _weight==0, columns(statistics)

	gen n=_n
	gen pvalue=.
	gen var1=lnta
	gen var2=btm
	gen var3=lnage
	gen var4=cfo
	gen var5=acc
	gen var6=salesgr
	gen var7=lnsdearn
	gen var8=spdum
	gen var9=rnd
	gen var10=div
	gen var11=expsc
	gen var12=inta
	gen var13=depr

	* Calculate p-values for covariate balance:
	forvalues i=1(1)13{
		cluster2 var`i' _weight, fcluster(cik) tcluster(qid)
		matrix a = vecdiag(e(V))
		matrix b = (e(b)\a)'
		svmat b
		gen se = sqrt(b2)
		gen t = b1/se
		gen p = 2*ttail(e(df_r),abs(t))
		sum p if n==1
		replace pvalue=r(mean) if n==`i'
		drop t se p b1 b2
	}
	tabstat pvalue if n<=13, by(n)
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==1, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==0, fcluster(cik) tcluster(qid)	

	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==1, fcluster(cik) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==0, fcluster(cik) tcluster(qid)	

	* Test for differences in coefficients across estimations:
	gen dum=_weight
	
	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen inter=dum*earn_gaap
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	* Frank test:
	capture noisily {
		konfound inter
	}

	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	* Frank test:
	capture noisily {
		konfound inter
	}


	************************************
	* Non-GAAP loss versus GAAP-only: PSM2  
	************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=.
	replace treatment=0 if treatnew==0
	replace treatment=1 if treatnew==1

	* Logit estimation before matching:
	logit2 treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus, fcluster(cik) tcluster(qid)
	
	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr ng_indus, n(1) common caliper(0.01) logit noreplace
	drop if _weight==.
	replace _weight=0 if treatment==0
	sum _weight
	tabstat _weight, by(_weight) stats(N)
	replace treatment=_weight

	* Logit estimation after matching:
	logit2 treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus, fcluster(cik) tcluster(qid)

	* Covariate balance:
	tabstat lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus if _weight==1, columns(statistics)
	tabstat lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus if _weight==0, columns(statistics)

	gen n=_n
	gen pvalue=.
	gen var1=lnta
	gen var2=btm
	gen var3=lnage
	gen var4=cfo
	gen var5=acc
	gen var6=salesgr
	gen var7=lnsdearn
	gen var8=spdum
	gen var9=rnd
	gen var10=div
	gen var11=expsc
	gen var12=inta
	gen var13=depr
	gen var14=ng_indus

	* Calculate p-values for covariate balance:
	forvalues i=1(1)14{
		cluster2 var`i' _weight, fcluster(cik) tcluster(qid)
		matrix a = vecdiag(e(V))
		matrix b = (e(b)\a)'
		svmat b
		gen se = sqrt(b2)
		gen t = b1/se
		gen p = 2*ttail(e(df_r),abs(t))
		sum p if n==1
		replace pvalue=r(mean) if n==`i'
		drop t se p b1 b2
	}
	tabstat pvalue if n<=14, by(n)
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==1, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==0, fcluster(cik) tcluster(qid)	

	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==1, fcluster(cik) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==0, fcluster(cik) tcluster(qid)	
	
	gen dum=_weight
	
	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen inter=dum*earn_gaap
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	* Frank test:
	capture noisily {
		konfound inter
	}

	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	* Frank test:
	capture noisily {
		konfound inter
	}

	
	************************************
	* Loss converters versus GAAP-only: PSM1  
	************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=.
	replace treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2

	* Logit estimation before matching:
	logit2 treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr, fcluster(cik) tcluster(qid)

	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr, n(1) common caliper(0.01) logit noreplace
	drop if _weight==.
	replace _weight=0 if treatment==0
	sum _weight
	tabstat _weight, by(_weight) stats(N)
	replace treatment=_weight

	* Logit estimation after matching:
	logit2 treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr, fcluster(cik) tcluster(qid)

	* Covariate balance:
	tabstat lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr if _weight==1, columns(statistics)
	tabstat lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr if _weight==0, columns(statistics)

	gen n=_n
	gen pvalue=.
	gen var1=lnta
	gen var2=btm
	gen var3=lnage
	gen var4=cfo
	gen var5=acc
	gen var6=salesgr
	gen var7=lnsdearn
	gen var8=spdum
	gen var9=rnd
	gen var10=div
	gen var11=expsc
	gen var12=inta
	gen var13=depr

	* Calculate p-values for covariate balance:
	forvalues i=1(1)13{
		cluster2 var`i' _weight, fcluster(cik) tcluster(qid)
		matrix a = vecdiag(e(V))
		matrix b = (e(b)\a)'
		svmat b
		gen se = sqrt(b2)
		gen t = b1/se
		gen p = 2*ttail(e(df_r),abs(t))
		sum p if n==1
		replace pvalue=r(mean) if n==`i'
		drop t se p b1 b2
	}
	tabstat pvalue if n<=13, by(n)
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==1, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==0, fcluster(cik) tcluster(qid)	

	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==1, fcluster(cik) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==0, fcluster(cik) tcluster(qid)	

	gen dum=_weight
	
	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen inter=dum*earn_gaap

	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	* Frank test:
	capture noisily {
		konfound inter
	}
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	* Frank test:
	capture noisily {
		konfound inter
	}

	************************************
	* Loss converters versus GAAP-only: PSM2  
	************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=.
	replace treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2

	* Logit estimation before matching:
	logit2 treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus, fcluster(cik) tcluster(qid)

	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr ng_indus, n(1) common caliper(0.01) logit noreplace
	drop if _weight==.
	replace _weight=0 if treatment==0
	sum _weight
	tabstat _weight, by(_weight) stats(N)
	replace treatment=_weight

	* Logit estimation after matching:
	logit2 treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus, fcluster(cik) tcluster(qid)

	* Covariate balance:
	tabstat lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus if _weight==1, columns(statistics)
	tabstat lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus if _weight==0, columns(statistics)

	gen n=_n
	gen pvalue=.
	gen var1=lnta
	gen var2=btm
	gen var3=lnage
	gen var4=cfo
	gen var5=acc
	gen var6=salesgr
	gen var7=lnsdearn
	gen var8=spdum
	gen var9=rnd
	gen var10=div
	gen var11=expsc
	gen var12=inta
	gen var13=depr
	gen var14=ng_indus

	* Calculate p-values for covariate balance:
	forvalues i=1(1)14{
		cluster2 var`i' _weight, fcluster(cik) tcluster(qid)
		matrix a = vecdiag(e(V))
		matrix b = (e(b)\a)'
		svmat b
		gen se = sqrt(b2)
		gen t = b1/se
		gen p = 2*ttail(e(df_r),abs(t))
		sum p if n==1
		replace pvalue=r(mean) if n==`i'
		drop t se p b1 b2
	}
	tabstat pvalue if n<=14, by(n)
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==1, fcluster(cik) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==0, fcluster(cik) tcluster(qid)	

	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==1, fcluster(cik) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if _weight==0, fcluster(cik) tcluster(qid)	
	
	gen dum=_weight
	
	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen inter=dum*earn_gaap

	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	* Frank test:
	capture noisily {
		konfound inter
	}

	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)

	* Frank test:
	capture noisily {
		konfound inter
	}

	
	********************************************
	********************************************
	* Additional (untabulated) tests
	********************************************
	********************************************
	
	**************************************************************************
	* Assess marginal effects of observed covariates on treatment: NG loss
	**************************************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==1
	drop if treatment==.
	sum treatment
	
	* Normalize all continuous variables
	sum lnta 
	replace lnta=(lnta-r(mean))/r(sd)
	sum btm 
	replace btm=(btm-r(mean))/r(sd)
	sum lnage 
	replace lnage=(lnage-r(mean))/r(sd)
	sum salesgr 
	replace salesgr=(salesgr-r(mean))/r(sd)
	sum lnsdearn 
	replace lnsdearn=(lnsdearn-r(mean))/r(sd)
	sum rnd 
	replace rnd=(rnd-r(mean))/r(sd)
	sum div 
	replace div=(div-r(mean))/r(sd)
	sum cfo 
	replace cfo=(cfo-r(mean))/r(sd)
	sum acc 
	replace acc=(acc-r(mean))/r(sd)
	sum expsc 
	replace expsc=(expsc-r(mean))/r(sd)
	sum inta 
	replace inta=(inta-r(mean))/r(sd)
	sum depr 
	replace depr=(depr-r(mean))/r(sd)
	sum ng_indus
	replace ng_indus=(ng_indus-r(mean))/r(sd)
	
	forvalues i=1(1)36{
		qui sum timedum_`i'
		qui replace timedum_`i'=timedum_`i'-r(mean)
		di `i'
	}
	
	logit treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr 
	margins, dydx(lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr) atmeans

	logit treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
	margins, dydx(lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus) atmeans
	
	**************************************************************************
	* Assess marginal effects of observed covariates on treatment: loss converters
	**************************************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2
	drop if treatment==.
	sum treatment
	
	* Normalize all continuous variables
	sum lnta 
	replace lnta=(lnta-r(mean))/r(sd)
	sum btm 
	replace btm=(btm-r(mean))/r(sd)
	sum lnage 
	replace lnage=(lnage-r(mean))/r(sd)
	sum salesgr 
	replace salesgr=(salesgr-r(mean))/r(sd)
	sum lnsdearn 
	replace lnsdearn=(lnsdearn-r(mean))/r(sd)
	sum rnd 
	replace rnd=(rnd-r(mean))/r(sd)
	sum div 
	replace div=(div-r(mean))/r(sd)
	sum cfo 
	replace cfo=(cfo-r(mean))/r(sd)
	sum acc 
	replace acc=(acc-r(mean))/r(sd)
	sum expsc 
	replace expsc=(expsc-r(mean))/r(sd)
	sum inta 
	replace inta=(inta-r(mean))/r(sd)
	sum depr 
	replace depr=(depr-r(mean))/r(sd)
	sum ng_indus
	replace ng_indus=(ng_indus-r(mean))/r(sd)
	
	forvalues i=1(1)36{
		qui sum timedum_`i'
		qui replace timedum_`i'=timedum_`i'-r(mean)
		di `i'
	}
	
	logit treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr 
	margins, dydx(lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr) atmeans

	logit treatment timedum_* lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
	margins, dydx(lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus) atmeans
	
	**************************************************************************
	* Calculate partial correlations to assess impact of observable variables (untabulated statistics discussed in Section 4.2)
	**************************************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	keep if treatnew==1 | treatnew==0
	gen inter=treatnew*earn_gaap
	
	pcorr cfop1 lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
	pcorr inter lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
	pcorr opincp1 lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
	
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	keep if treatnew==2 | treatnew==0
	replace treatnew=1 if treatnew==2
	gen inter=treatnew*earn_gaap
	
	pcorr cfop1 lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
	pcorr inter lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
	pcorr opincp1 lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
		
	
****************************************************************
****************************************************************
****************************************************************
* STEP 8: Table 6 - Loss versus profit firms
****************************************************************
****************************************************************
****************************************************************
	
	**********************************************************
	* Table 6: Differential predictive ability of non-GAAP earnings for loss versus profit firms
	* Panel A: Using our own hand-collected random subsample of non-GAAP earnings in profit firms
	**********************************************************

	*******************************************************
	* Prepare data
	/*
		"data_profit_clean" is a sample of 4000 profit-firm-quarters randomly selected
		Variables included in file:
			cik = CIK identifier
			fdate = SEC 8-K filing date
			eps_dil_ng_p = non-GAAP diluted EPS
			ni_ng_p = non-GAAP earnings in $mln
			ng_p = indicator variable equal to 1 if non-GAAP earnings measure disclosed, 0 otherwise
	*/
	use "$path\EDGAR\data_profit_clean.dta", clear
	sum *

	use "$path\OutFiles\fundq_sample_nongaap3.dta", clear
	drop if cfo==.
	drop if cfop1==.
	drop if earnp1==.
	drop if opincp1==.
	drop if salesgr==.
	drop if lnsdearn==.
		
	ren earn earn_gaap
	drop xearn 
	gen profit=epsfxq*cshfdq
	sum profit
	gen earn=profit/atq
	sum earn,d
	replace earn=r(p1) if earn<r(p1)
	replace earn=r(p99) if earn>r(p99) & earn!=.
	xtile xearn=earn,nq(10)
	replace xearn=(xearn-1)/9
	
	gen acc_gaap=acc
	
	destring cik, replace
	joinby cik fdate using "$path\EDGAR\data_profit_clean.dta", unmatched(master)
	drop _merge

	gen profitng=1 if ng_p==1
	
	replace eps_dil_ng=eps_dil_ng_p if eps_dil_ng==.
	replace ni_ng=ni_ng_p if ni_ng==.
	replace ng=ng_p if ng==.
	
	gen ni_ng_sc=ni_ng/atq 
	gen ni_ng_sc0=ni_ng_sc
	sum ni_ng_sc,d
	replace ni_ng_sc=r(p1) if ni_ng_sc<r(p1)
	replace ni_ng_sc=r(p99) if ni_ng_sc>r(p99) & ni_ng_sc!=.

	gen excl=earn0-ni_ng_sc0
	sum excl,d
	replace excl=r(p1) if excl<r(p1)
	replace excl=r(p99) if excl>r(p99) & excl!=.	

	sum eps_dil_ng,d
	replace eps_dil_ng=r(p1) if eps_dil_ng<r(p1)
	replace eps_dil_ng=r(p99) if eps_dil_ng>r(p99) & eps_dil_ng!=.
	save "$path\OutFiles\fundq_sample_nongaap6.dta", replace

	*******************************************************
	* TESTS	
	*******************************************************
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1 | treatnew==2, fcluster(gvkey) tcluster(qid)

	gen dum=0 if profitng==1
	replace dum=1 if treatnew==1 | treatnew==2

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen interng1=dum*ni_ng_sc
	gen interng2=dum*excl
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl dum ind_inter_* time_inter_* inter_* interng1 interng2, fcluster(gvkey) tcluster(qid)
	drop dum ind_inter_* time_inter_* inter_* inter*

	* Compare coefficients on GAAP versus non-GAAP earnings for same set of firms:
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	keep if profitng==1
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6_sample1.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	keep if treatnew==1 | treatnew==2
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6_sample2.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6_sample1.dta", clear
	gen group=1
	append using "$path\OutFiles\fundq_sample_nongaap6_sample2.dta"
	replace group=2 if group==.
	sort cik fdate dummy
	
	replace group=group-1
	gen i_1=lnta*group
	gen i_2=btm*group
	gen i_3=lnage*group
	gen i_4=salesgr*group
	gen i_5=lnsdearn*group
	gen i_6=earn_gaap*group
	gen i_7=excl*group
	gen i_8=dummy*group
	gen i_9=inter_1*group
	gen i_10=inter_2*group
	gen i_11=inter_3*group
	gen i_12=inter_4*group
	gen i_13=inter_5*group
	forvalues i=1(1)61{
		qui local j=`i'+13
		qui gen i_`j'=group*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui local j=`i'+74
		qui gen i_`j'=group*timedum_`i'
	}
	forvalues i=1(1)61{
		qui local j=`i'+110
		qui gen i_`j'=group*ind_inter_`i'
	}	
	forvalues i=1(1)36{
		qui local j=`i'+171
		qui gen i_`j'=group*time_inter_`i'
	}	
	gen inter2=inter*group
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter i_* inter2, fcluster(gvkey) tcluster(qid)
	
	******************************
	* Do the same for OPINC
	******************************	
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1 | treatnew==2, fcluster(gvkey) tcluster(qid)

	gen dum=0 if profitng==1
	replace dum=1 if treatnew==1 | treatnew==2

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen interng1=dum*ni_ng_sc
	gen interng2=dum*excl
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl dum ind_inter_* time_inter_* inter_* interng1 interng2, fcluster(gvkey) tcluster(qid)
	drop dum ind_inter_* time_inter_* inter_* inter*

	* Compare coefficients on GAAP versus non-GAAP earnings for same set of firms:
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	keep if profitng==1
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6_sample1_opincp1.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	keep if treatnew==1 | treatnew==2
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6_sample2_opincp1.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6_sample1_opincp1.dta", clear
	gen group=1
	append using "$path\OutFiles\fundq_sample_nongaap6_sample2_opincp1.dta"
	replace group=2 if group==.
	sort cik fdate dummy
	
	replace group=group-1
	gen i_1=lnta*group
	gen i_2=btm*group
	gen i_3=lnage*group
	gen i_4=salesgr*group
	gen i_5=lnsdearn*group
	gen i_6=earn_gaap*group
	gen i_7=excl*group
	gen i_8=dummy*group
	gen i_9=inter_1*group
	gen i_10=inter_2*group
	gen i_11=inter_3*group
	gen i_12=inter_4*group
	gen i_13=inter_5*group
	forvalues i=1(1)61{
		qui local j=`i'+13
		qui gen i_`j'=group*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui local j=`i'+74
		qui gen i_`j'=group*timedum_`i'
	}
	forvalues i=1(1)61{
		qui local j=`i'+110
		qui gen i_`j'=group*ind_inter_`i'
	}	
	forvalues i=1(1)36{
		qui local j=`i'+171
		qui gen i_`j'=group*time_inter_`i'
	}	
	gen inter2=inter*group
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter i_* inter2, fcluster(gvkey) tcluster(qid)

	******************************
	* Untabulated: Do the same for EARNP1
	******************************	
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1 | treatnew==2, fcluster(gvkey) tcluster(qid)

	gen dum=0 if profitng==1
	replace dum=1 if treatnew==1 | treatnew==2

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen interng1=dum*ni_ng_sc
	gen interng2=dum*excl
	
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl dum ind_inter_* time_inter_* inter_* interng1 interng2, fcluster(gvkey) tcluster(qid)
	drop dum ind_inter_* time_inter_* inter_* inter*

	* Compare coefficients on GAAP versus non-GAAP earnings for same set of firms:
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	keep if profitng==1
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6_sample1_earnp1.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	keep if treatnew==1 | treatnew==2
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6_sample2_earnp1.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6_sample1_earnp1.dta", clear
	gen group=1
	append using "$path\OutFiles\fundq_sample_nongaap6_sample2_earnp1.dta"
	replace group=2 if group==.
	sort cik fdate dummy
	
	replace group=group-1
	gen i_1=lnta*group
	gen i_2=btm*group
	gen i_3=lnage*group
	gen i_4=salesgr*group
	gen i_5=lnsdearn*group
	gen i_6=earn_gaap*group
	gen i_7=excl*group
	gen i_8=dummy*group
	gen i_9=inter_1*group
	gen i_10=inter_2*group
	gen i_11=inter_3*group
	gen i_12=inter_4*group
	gen i_13=inter_5*group
	forvalues i=1(1)61{
		qui local j=`i'+13
		qui gen i_`j'=group*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui local j=`i'+74
		qui gen i_`j'=group*timedum_`i'
	}
	forvalues i=1(1)61{
		qui local j=`i'+110
		qui gen i_`j'=group*ind_inter_`i'
	}	
	forvalues i=1(1)36{
		qui local j=`i'+171
		qui gen i_`j'=group*time_inter_`i'
	}	
	gen inter2=inter*group
	cluster2 earnp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter i_* inter2, fcluster(gvkey) tcluster(qid)


	******************************
	* Untabulated: Do the same for FCFP1
	******************************	
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1 | treatnew==2, fcluster(gvkey) tcluster(qid)

	gen dum=0 if profitng==1
	replace dum=1 if treatnew==1 | treatnew==2

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen interng1=dum*ni_ng_sc
	gen interng2=dum*excl
	
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl dum ind_inter_* time_inter_* inter_* interng1 interng2, fcluster(gvkey) tcluster(qid)
	drop dum ind_inter_* time_inter_* inter_* inter*

	* Compare coefficients on GAAP versus non-GAAP earnings for same set of firms:
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	keep if profitng==1
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6_sample1_fcfp1.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	keep if treatnew==1 | treatnew==2
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6_sample2_fcfp1.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6_sample1_fcfp1.dta", clear
	gen group=1
	append using "$path\OutFiles\fundq_sample_nongaap6_sample2_fcfp1.dta"
	replace group=2 if group==.
	sort cik fdate dummy
	
	replace group=group-1
	gen i_1=lnta*group
	gen i_2=btm*group
	gen i_3=lnage*group
	gen i_4=salesgr*group
	gen i_5=lnsdearn*group
	gen i_6=earn_gaap*group
	gen i_7=excl*group
	gen i_8=dummy*group
	gen i_9=inter_1*group
	gen i_10=inter_2*group
	gen i_11=inter_3*group
	gen i_12=inter_4*group
	gen i_13=inter_5*group
	forvalues i=1(1)61{
		qui local j=`i'+13
		qui gen i_`j'=group*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui local j=`i'+74
		qui gen i_`j'=group*timedum_`i'
	}
	forvalues i=1(1)61{
		qui local j=`i'+110
		qui gen i_`j'=group*ind_inter_`i'
	}	
	forvalues i=1(1)36{
		qui local j=`i'+171
		qui gen i_`j'=group*time_inter_`i'
	}	
	gen inter2=inter*group
	cluster2 fcfp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter i_* inter2, fcluster(gvkey) tcluster(qid)


	**********************************************************
	**********************************************************
	* Panel B: Using BCGW data
	**********************************************************
	**********************************************************
	
	**************
	* Prepare data
	* First separate the loss firm data used in the Panel A analyses
	use "$path\OutFiles\fundq_sample_nongaap6.dta", clear
	keep if treatnew==1 | treatnew==2
	keep cik fdate ni_ng_sc excl
	ren ni_ng_sc ni_ng_sc_LV
	ren excl excl_LV
	save "$path\OutFiles\fundq_sample_nongaap6_LVdata.dta", replace

	* Prepare the Bentley data
	use "$path\Infiles\bcgw_2018_ng_data_2003to2016.dta", clear
	destring gvkey, replace
	drop url 
	duplicates drop gvkey datadate, force
	save "$path\Outfiles\bcgw.dta", replace

	* Merge and clean	
	use "$path\OutFiles\fundq_sample_nongaap3.dta", clear
	gen lossng_lv=0 if treatnew==0
	replace lossng_lv=1 if treatnew==1 | treatnew==2
	sum lossng_lv
	
	drop if cfo==.
	drop if cfop1==.
	drop if earnp1==.
	drop if opincp1==.
	drop if salesgr==.
	drop if lnsdearn==.
		
	ren earn earn_gaap
	joinby gvkey datadate using "$path\Outfiles\bcgw.dta", unmatched(master)
	drop _merge
	sum fyearq mgr_exclude MGR_NG_EPS
	
	spearman eps_dil_ng MGR_NG_EPS 
	spearman ng mgr_exclude
	
	replace eps_dil_ng=MGR_NG_EPS 
	replace ni_ng=MGR_NG_EPS*cshfdq 
	replace ng=mgr_exclude 

	gen profitng=1 if ng==1 & ibq>=0 & oepsxq>=0 & oepsxq!=.
	replace profitng=0 if ng==1 & ibq<0 & oepsxq<0 & oepsxq!=.
	tabstat profitng, by(profitng) stats(N)
	
	gen ni_ng_sc=ni_ng/atq
	gen ni_ng_sc0=ni_ng_sc
	
	sum ni_ng_sc,d
	replace ni_ng_sc=r(p1) if ni_ng_sc<r(p1)
	replace ni_ng_sc=r(p99) if ni_ng_sc>r(p99) & ni_ng_sc!=.

	gen excl=earn0-ni_ng_sc0
	sum excl,d
	replace excl=r(p1) if excl<r(p1)
	replace excl=r(p99) if excl>r(p99) & excl!=.	

	joinby cik fdate using "$path\OutFiles\fundq_sample_nongaap6_LVdata.dta", unmatched(master)
	drop _merge

	replace ni_ng_sc=ni_ng_sc_LV if treatnew==1 | treatnew==2
	replace excl=excl_LV if treatnew==1 | treatnew==2
	save "$path\OutFiles\fundq_sample_nongaap6B.dta", replace
	
	*******************************************************
	* Tests
	*******************************************************
	use "$path\OutFiles\fundq_sample_nongaap6B.dta", clear
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1 | treatnew==2, fcluster(gvkey) tcluster(qid)

	gen dum=0 if profitng==1
	replace dum=1 if treatnew==1 | treatnew==2

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen interng1=dum*ni_ng_sc
	gen interng2=dum*excl
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl dum ind_inter_* time_inter_* inter_* interng1 interng2, fcluster(gvkey) tcluster(qid)
	drop dum ind_inter_* time_inter_* inter_* inter*

	* Compare coefficients on GAAP versus non-GAAP earnings for same set of firms:
	use "$path\OutFiles\fundq_sample_nongaap6B.dta", clear
	keep if profitng==1
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6B_sample1.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6B.dta", clear
	keep if treatnew==1 | treatnew==2
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6B_sample2.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6B_sample1.dta", clear
	gen group=1
	append using "$path\OutFiles\fundq_sample_nongaap6B_sample2.dta"
	replace group=2 if group==.
	sort cik fdate dummy
	
	replace group=group-1
	gen i_1=lnta*group
	gen i_2=btm*group
	gen i_3=lnage*group
	gen i_4=salesgr*group
	gen i_5=lnsdearn*group
	gen i_6=earn_gaap*group
	gen i_7=excl*group
	gen i_8=dummy*group
	gen i_9=inter_1*group
	gen i_10=inter_2*group
	gen i_11=inter_3*group
	gen i_12=inter_4*group
	gen i_13=inter_5*group
	forvalues i=1(1)61{
		qui local j=`i'+13
		qui gen i_`j'=group*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui local j=`i'+74
		qui gen i_`j'=group*timedum_`i'
	}
	forvalues i=1(1)61{
		qui local j=`i'+110
		qui gen i_`j'=group*ind_inter_`i'
	}	
	forvalues i=1(1)36{
		qui local j=`i'+171
		qui gen i_`j'=group*time_inter_`i'
	}	
	gen inter2=inter*group
	cluster2 cfop1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter i_* inter2, fcluster(gvkey) tcluster(qid)

	
******************************
* Do the same for OPINC
******************************	
	use "$path\OutFiles\fundq_sample_nongaap6B.dta", clear
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if profitng==1, fcluster(gvkey) tcluster(qid)
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl if treatnew==1 | treatnew==2, fcluster(gvkey) tcluster(qid)

	gen dum=0 if profitng==1
	replace dum=1 if treatnew==1 | treatnew==2

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnta
	gen inter_2=dum*btm
	gen inter_3=dum*lnage
	gen inter_4=dum*salesgr
	gen inter_5=dum*lnsdearn
	gen interng1=dum*ni_ng_sc
	gen interng2=dum*excl
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn ni_ng_sc excl dum ind_inter_* time_inter_* inter_* interng1 interng2, fcluster(gvkey) tcluster(qid)
	drop dum ind_inter_* time_inter_* inter_* inter*

	* Compare coefficients on GAAP versus non-GAAP earnings for same set of firms:
	use "$path\OutFiles\fundq_sample_nongaap6B.dta", clear
	keep if profitng==1
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6B_sample1_opincp1.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6B.dta", clear
	keep if treatnew==1 | treatnew==2
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace earn_gaap=ni_ng_sc if dummy==1
	replace excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnta
	gen inter_2=dummy*btm
	gen inter_3=dummy*lnage
	gen inter_4=dummy*salesgr
	gen inter_5=dummy*lnsdearn
	gen inter=dummy*earn_gaap
	
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(gvkey) tcluster(qid)
	save "$path\OutFiles\fundq_sample_nongaap6B_sample2_opincp1.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap6B_sample1_opincp1.dta", clear
	gen group=1
	append using "$path\OutFiles\fundq_sample_nongaap6B_sample2_opincp1.dta"
	replace group=2 if group==.
	sort cik fdate dummy

	replace group=group-1
	gen i_1=lnta*group
	gen i_2=btm*group
	gen i_3=lnage*group
	gen i_4=salesgr*group
	gen i_5=lnsdearn*group
	gen i_6=earn_gaap*group
	gen i_7=excl*group
	gen i_8=dummy*group
	gen i_9=inter_1*group
	gen i_10=inter_2*group
	gen i_11=inter_3*group
	gen i_12=inter_4*group
	gen i_13=inter_5*group
	forvalues i=1(1)61{
		qui local j=`i'+13
		qui gen i_`j'=group*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui local j=`i'+74
		qui gen i_`j'=group*timedum_`i'
	}
	forvalues i=1(1)61{
		qui local j=`i'+110
		qui gen i_`j'=group*ind_inter_`i'
	}	
	forvalues i=1(1)36{
		qui local j=`i'+171
		qui gen i_`j'=group*time_inter_`i'
	}	
	gen inter2=inter*group
	cluster2 opincp1 indusdum* timedum* lnta btm lnage salesgr lnsdearn earn_gaap excl dummy ind_inter_* time_inter_* inter_* inter i_* inter2, fcluster(gvkey) tcluster(qid)
		
	
****************************************************************
****************************************************************
****************************************************************
* STEP 9: Table 7 ERC tests
****************************************************************
****************************************************************
****************************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	sort ticker datadate
	joinby ticker datadate using "$path\OutFiles\ibes_medest_eps.dta", unmatched(master)
	drop _merge
	sum fyear medest*
	sort ticker datadate
	joinby ticker datadate using "$path\OutFiles\ibes_medest_gps.dta", unmatched(master)
	drop _merge
	sum fyear medest*
	drop if medest_gps==.
	drop eps_dil_ng
	ren eps_dil_ng0 eps_dil_ng

	gen surprise_gaap=(actualibes_gaap-medest_gps)/prccq
	gen surprise_nongaap=(eps_dil_ng-medest_eps)/prccq
	* Exclusion surprise = difference between the actual exclusions and that forecasted based on gaap vs nongaap forecasts
	gen surprise_excl=((actualibes_gaap-eps_dil_ng)-(medest_gps-medest_eps))/prccq
	gen surprise_street=(actualibes-medest_eps)/prccq

	sum surprise_gaap,d
	replace surprise_gaap=r(p1) if surprise_gaap<r(p1)
	replace surprise_gaap=r(p99) if surprise_gaap>r(p99) & surprise_gaap!=.
	sum surprise_nongaap,d
	replace surprise_nongaap=r(p1) if surprise_nongaap<r(p1)
	replace surprise_nongaap=r(p99) if surprise_nongaap>r(p99) & surprise_nongaap!=.
	sum surprise_excl,d
	replace surprise_excl=r(p1) if surprise_excl<r(p1)
	replace surprise_excl=r(p99) if surprise_excl>r(p99) & surprise_excl!=.
	sum surprise_street,d
	replace surprise_street=r(p1) if surprise_street<r(p1)
	replace surprise_street=r(p99) if surprise_street>r(p99) & surprise_street!=.
	save "$path\OutFiles\fundq_sample_nongaap4_surprise.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap4_surprise.dta", clear
	* Main regressions
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_gaap if treatnew==0, fcluster(cik) tcluster(qid)
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_gaap if treatnew==1, fcluster(cik) tcluster(qid)
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_gaap if treatnew==2, fcluster(cik) tcluster(qid)
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_nongaap surprise_excl if treatnew==1, fcluster(cik) tcluster(qid)
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_nongaap surprise_excl if treatnew==2, fcluster(cik) tcluster(qid)
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_nongaap surprise_excl if treatnew==2 & dummy_comp==1, fcluster(cik) tcluster(qid)
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_nongaap surprise_excl if treatnew==2 & dummy_comp!=1, fcluster(cik) tcluster(qid)
	
	* (Untabulated) Differences in informativeness of GAAP earnings across samples - non-GAAP loss versus GAAP-only loss:
	gen dum=0 if treatnew==0
	replace dum=1 if treatnew==1

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnmv
	gen inter_2=dum*btm
	gen inter_3=dum*bhrlag60
	gen inter=dum*surprise_gaap
	
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)
	drop dum ind_inter_* time_inter_* inter_* inter

	* (Untabulated) Differences in informativeness of GAAP earnings across samples - loss converters versus GAAP-only loss:
	gen dum=0 if treatnew==0
	replace dum=1 if treatnew==2
	
	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dum*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dum*timedum_`i'
	}
	gen inter_1=dum*lnmv
	gen inter_2=dum*btm
	gen inter_3=dum*bhrlag60
	gen inter=dum*surprise_gaap
	
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_gaap dum ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)
	drop dum ind_inter_* time_inter_* inter_* inter

	* (Untabulated) Compare coefficients on GAAP versus non-GAAP earnings for same set of firms - non-GAAP loss firms:
	use "$path\OutFiles\fundq_sample_nongaap4_surprise.dta", clear
	keep if treatnew==1
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace surprise_gaap=surprise_nongaap if dummy==1
	replace surprise_excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnmv
	gen inter_2=dummy*btm
	gen inter_3=dummy*bhrlag60
	gen inter=dummy*surprise_gaap
	
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_gaap surprise_excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)
	
	* (Untabulated) Compare coefficients on GAAP versus non-GAAP earnings for same set of firms - loss converters:
	use "$path\OutFiles\fundq_sample_nongaap4_surprise.dta", clear
	keep if treatnew==2
	sum lnta
	gen hulp_1=1
	gen hulp_2=2
	gen id=_n
	reshape long hulp_, i(id) j(n)
	
	gen dummy=hulp_-1
	sort cik fdate dummy
	
	replace surprise_gaap=surprise_nongaap if dummy==1
	replace surprise_excl=0 if dummy==0

	forvalues i=1(1)61{
		qui gen ind_inter_`i'=dummy*indusdum_`i'
	}
	forvalues i=1(1)36{
		qui gen time_inter_`i'=dummy*timedum_`i'
	}
	gen inter_1=dummy*lnmv
	gen inter_2=dummy*btm
	gen inter_3=dummy*bhrlag60
	gen inter=dummy*surprise_gaap
	
	cluster2 bhar indusdum* timedum* lnmv btm bhrlag60 surprise_gaap surprise_excl dummy ind_inter_* time_inter_* inter_* inter, fcluster(cik) tcluster(qid)
	
	
****************************************************************
****************************************************************
****************************************************************
* STEP 10: Table 8 tests
****************************************************************
****************************************************************
****************************************************************
	
****************************************************************************
****************************************************************************
* Table 8: Future performance of loss converters versus GAAP-only loss firms
****************************************************************************
****************************************************************************

	* (Untabulated) First verify results based on pooled (unmatched) sample:
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen _weight=0 if treatnew==0
	replace _weight=1 if treatnew==2
	
	cluster2 cfop1 timedum_* indusdum_* _weight cfo acc_gaap lnta btm lnage salesgr lnsdearn spdum rnd div expsc inta depr, fcluster(cik) tcluster(qid)
	cluster2 opincp1 timedum_* indusdum_* _weight cfo acc_gaap lnta btm lnage salesgr lnsdearn spdum rnd div expsc inta depr, fcluster(cik) tcluster(qid)
	cluster2 freqlossp1 timedum_* indusdum_* _weight cfo acc_gaap lnta btm lnage salesgr lnsdearn spdum rnd div expsc inta depr, fcluster(cik) tcluster(qid)
	
	* PSM1: excluding industry variable 
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2
	
	logit treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr, cluster(cik)

	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr, n(1) common caliper(0.01) logit noreplace
	drop if _weight==.
	replace _weight=0 if treatment==0
	sum _weight
	tabstat _pscore, by(_weight) stats(mean N)
		
	cluster2 cfop1 _weight, fcluster(cik) tcluster(qid)
	cluster2 opincp1 _weight, fcluster(cik) tcluster(qid)
	cluster2 freqlossp1 _weight, fcluster(cik) tcluster(qid)

	cluster2 cfop1 timedum_* indusdum_* _weight cfo acc_gaap lnta btm lnage salesgr lnsdearn spdum rnd div expsc inta depr ng_indus, fcluster(cik) tcluster(qid)
	capture noisily {
		konfound _weight
	}
	cluster2 opincp1 timedum_* indusdum_* _weight cfo acc_gaap lnta btm lnage salesgr lnsdearn spdum rnd div expsc inta depr ng_indus, fcluster(cik) tcluster(qid)
	capture noisily {
		konfound _weight
	}
	cluster2 freqlossp1 timedum_* indusdum_* _weight cfo acc_gaap lnta btm lnage salesgr lnsdearn spdum rnd div expsc inta depr ng_indus, fcluster(cik) tcluster(qid)
	capture noisily {
		konfound _weight
	}
	
	* PSM2: including industry variable
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2

	logit treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr ng_indus, cluster(cik)

	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr ng_indus, n(1) common caliper(0.01) logit noreplace
	drop if _weight==.
	replace _weight=0 if treatment==0
	sum _weight
	tabstat _pscore, by(_weight) stats(mean N)

	cluster2 cfop1 _weight, fcluster(cik) tcluster(qid)
	cluster2 opincp1 _weight, fcluster(cik) tcluster(qid)
	cluster2 freqlossp1 _weight, fcluster(cik) tcluster(qid)
	
	cluster2 cfop1 timedum_* indusdum_* _weight cfo acc_gaap lnta btm lnage salesgr lnsdearn spdum rnd div expsc inta depr ng_indus, fcluster(cik) tcluster(qid)
	* Frank test:
	capture noisily {
		konfound _weight
	}
	cluster2 opincp1 timedum_* indusdum_* _weight cfo acc_gaap lnta btm lnage salesgr lnsdearn spdum rnd div expsc inta depr ng_indus, fcluster(cik) tcluster(qid)
	capture noisily {
		konfound _weight
	}
	cluster2 freqlossp1 timedum_* indusdum_* _weight cfo acc_gaap lnta btm lnage salesgr lnsdearn spdum rnd div expsc inta depr ng_indus, fcluster(cik) tcluster(qid)
	capture noisily {
		konfound _weight
	}

	* Rosenbaum bounds
	*1	
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2
	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr, n(1) common caliper(0.01) logit noreplace outc(cfop1)
	gen delta = cfop1 - _cfop1 if _treat==1 & _support==1
	rbounds delta, gamma(1.5 (.05) 2.5)
	rbounds delta, gamma(1.6 (.01) 1.8)

	drop if _weight==.
	replace _weight=0 if treatment==0
	sum _weight
	gen invw=1-_weight
	tabstat cfop1 opincp1 freqlossp1, by(invw)
	
	*2	
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2
	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr ng_indus, n(1) common caliper(0.01) logit noreplace outc(cfop1)
	gen delta = cfop1 - _cfop1 if _treat==1 & _support==1
	rbounds delta, gamma(1.5 (.05) 2.5)
	rbounds delta, gamma(1.7 (.01) 1.9)

	drop if _weight==.
	replace _weight=0 if treatment==0
	sum _weight
	gen invw=1-_weight
	tabstat cfop1 opincp1 freqlossp1, by(invw)
	
	*3	
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2
	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr, n(1) common caliper(0.01) logit noreplace outc(opincp1)
	gen delta = opincp1 - _opincp1 if _treat==1 & _support==1
	rbounds delta, gamma(1.3 (.05) 2.0)
	rbounds delta, gamma(1.3 (.01) 1.5)

	*4	
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2
	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr ng_indus, n(1) common caliper(0.01) logit noreplace outc(opincp1)
	gen delta = opincp1 - _opincp1 if _treat==1 & _support==1
	rbounds delta, gamma(1.3 (.05) 2.0)
	rbounds delta, gamma(1.3 (.01) 1.5)
	
	*5	
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2
	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr, n(1) common caliper(0.01) logit noreplace outc(freqlossp1)
	gen delta = freqlossp1 - _freqlossp1 if _treat==1 & _support==1
	rbounds delta, gamma(1.0 (.05) 2.0)
	rbounds delta, gamma(1.5 (.01) 1.7)

	*6	
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2
	psmatch2 treatment timedum_* lnta btm lnage salesgr lnsdearn spdum rnd div cfo acc expsc inta depr ng_indus, n(1) common caliper(0.01) logit noreplace outc(freqlossp1)
	gen delta = freqlossp1 - _freqlossp1 if _treat==1 & _support==1
	rbounds delta, gamma(1.0 (.05) 2.0)
	rbounds delta, gamma(1.6 (.01) 1.8)
	

	**********************
	* (Untabulated) Calculate partial correlations to assess impact of observable variables (discussed in Section 5.2)
	**********************	
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	keep if treatnew==2 | treatnew==0
	replace treatnew=1 if treatnew==2
	
	pcorr treatnew lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
	pcorr cfop1 lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
	pcorr opincp1 lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus
	pcorr freqlossp1 lnta btm lnage cfo acc salesgr lnsdearn spdum rnd div expsc inta depr ng_indus

	
****************************************************************
****************************************************************
****************************************************************
* STEP 11: Table 9 mispricing tests
****************************************************************
****************************************************************
****************************************************************

	****************************************
	* Panel A: Asset pricing portfolio tests
	****************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=0 if treatnew==0
	replace treatment=1 if treatnew==2
	drop if treatment==.
	sum treatment
	drop year
	gen year=year(fdate)
	gen month=month(fdate)
	keep permno year month treatment ni_ng_sc fdate
	forvalues i=1(1)12{
		qui gen m_`i'=`i'
	}
	gen id=_n
	reshape long m_, i(id) j(n)
	replace month=month+m_
	replace year=year+1 if month>12
	replace month=month-12 if month>12
	replace year=year+1 if month>12
	replace month=month-12 if month>12
	drop m_ id n
	sort permno year month
	egen gr=group(permno year month)
	egen count=count(gr), by(gr)
	egen max=max(treatment), by(gr)
	replace treatment=max
	duplicates drop permno year month, force
	keep permno year month treatment
	save "$path\OutFiles\fundq_sample_nongaap4_assetpricing0.dta", replace

	use "$path\Infiles\crspm.dta", clear
	append using "$path\Infiles\crspm_2015_2017.dta"
	duplicates drop permno date, force
	gen year=year(date)
	gen month=month(date)
	keep permno year month ret
	compress
	save "$path\Outfiles\crspm_complete.dta", replace

	use "$path\OutFiles\fundq_sample_nongaap4_assetpricing0.dta", clear
	joinby permno year month using "$path\Outfiles\crspm_complete.dta", unmatched(master)
	drop _merge
	drop if ret==.
	egen ym=group(year month)
	tabstat ym, by(ym) stats(N)
	tabstat ym year month, by(ym) 
	tabstat ym if treatment==1, by(ym) stats(N)
	* Drop months with insufficient obs:
	drop if ym<4
	* With 12 months
	drop if ym>120
	drop ym 
	egen ym=group(year month)
	
	gen ret0=ret if treatment==0
	gen ret1=ret if treatment==1
	
	egen meanret0=mean(ret0), by(ym)
	egen meanret1=mean(ret1), by(ym)
	sum meanret* ym
	duplicates drop ym, force
	sum meanret* ym
	gen hedge=meanret1-meanret0
	
	reg meanret1
	reg meanret0
	reg hedge

	joinby year month using "$path\InFiles\ff_factors_4.dta", unmatched(master)
	drop _merge
	sum hedge mktrf
	
	tsset ym
	newey meanret1 mktrf smb hml umd, lag(12)
	newey meanret0 mktrf smb hml umd, lag(12)
	newey hedge mktrf smb hml umd, lag(12)
	
	********************************************************************************************************
	* Panel B+C: Relation between current non-GAAP earnings surprises and future earnings announcement returns
	********************************************************************************************************
	use "$path\OutFiles\fundq_sample_nongaap4.dta", clear
	gen treatment=1 if treatnew==2
	keep if treatment==1
	
	sort ticker datadate
	joinby ticker datadate using "$path\OutFiles\ibes_medest_eps.dta", unmatched(master)
	drop _merge
	sum fyear medest*
	sort ticker datadate
	joinby ticker datadate using "$path\OutFiles\ibes_medest_gps.dta", unmatched(master)
	drop _merge
	sum fyear medest*
	drop if medest_gps==.
		
	drop eps_dil_ng
	ren eps_dil_ng0 eps_dil_ng

	gen surprise_gaap=(actualibes_gaap-medest_gps)/prccq
	gen surprise_nongaap_unscaled=(eps_dil_ng-medest_eps)
	gen surprise_nongaap=(eps_dil_ng-medest_eps)/prccq
	gen surprise_excl=((actualibes_gaap-eps_dil_ng)-(medest_gps-medest_eps))/prccq
	gen surprise_street=(actualibes-medest_eps)/prccq

	sum surprise_gaap,d
	replace surprise_gaap=r(p1) if surprise_gaap<r(p1)
	replace surprise_gaap=r(p99) if surprise_gaap>r(p99) & surprise_gaap!=.
	sum surprise_nongaap_unscaled,d
	replace surprise_nongaap_unscaled=r(p1) if surprise_nongaap_unscaled<r(p1)
	replace surprise_nongaap_unscaled=r(p99) if surprise_nongaap_unscaled>r(p99) & surprise_nongaap_unscaled!=.
	sum surprise_nongaap,d
	replace surprise_nongaap=r(p1) if surprise_nongaap<r(p1)
	replace surprise_nongaap=r(p99) if surprise_nongaap>r(p99) & surprise_nongaap!=.
	sum surprise_excl,d
	replace surprise_excl=r(p1) if surprise_excl<r(p1)
	replace surprise_excl=r(p99) if surprise_excl>r(p99) & surprise_excl!=.
	sum surprise_street,d
	replace surprise_street=r(p1) if surprise_street<r(p1)
	replace surprise_street=r(p99) if surprise_street>r(p99) & surprise_street!=.
	save "$path\OutFiles\fundq_sample_nongaap4_surprise_4mispricing.dta", replace
	
	use "$path\OutFiles\fundq_sample_nongaap4_surprise_4mispricing.dta", clear
	xtile xsurprise_nongaap=surprise_nongaap if treatment==1,nq(5)
	
	drop if bharp1==.
	drop if bharp2==.
	drop if bharp3==.
	drop if bharp4==.
	drop if bharsum==.
	
	* Panel B regressions:	
	cluster2 bharp1 indusdum* timedum* lnmv btm bhrlag60 surprise_nongaap surprise_excl if treatment==1, fcluster(cik) tcluster(qid)
	cluster2 bharp2 indusdum* timedum* lnmv btm bhrlag60 surprise_nongaap surprise_excl if treatment==1, fcluster(cik) tcluster(qid)
	cluster2 bharp3 indusdum* timedum* lnmv btm bhrlag60 surprise_nongaap surprise_excl if treatment==1, fcluster(cik) tcluster(qid)
	cluster2 bharp4 indusdum* timedum* lnmv btm bhrlag60 surprise_nongaap surprise_excl if treatment==1, fcluster(cik) tcluster(qid)
	cluster2 bharsum indusdum* timedum* lnmv btm bhrlag60 surprise_nongaap surprise_excl if treatment==1, fcluster(cik) tcluster(qid)
	
	* Panel C average returns per portfolio:	
	tabstat bharp* bharsum, by(xsurprise_nongaap)

	* Assess statistical significance:	
	cluster2 bharp1 if treatment==1 & xsurprise_nongaap==1, fcluster(cik) tcluster(qid)
	cluster2 bharp2 if treatment==1 & xsurprise_nongaap==1, fcluster(cik) tcluster(qid)
	cluster2 bharp3 if treatment==1 & xsurprise_nongaap==1, fcluster(cik) tcluster(qid)
	cluster2 bharp4 if treatment==1 & xsurprise_nongaap==1, fcluster(cik) tcluster(qid)
	cluster2 bharsum if treatment==1 & xsurprise_nongaap==1, fcluster(cik) tcluster(qid)

	cluster2 bharp1 if treatment==1 & xsurprise_nongaap==2, fcluster(cik) tcluster(qid)
	cluster2 bharp2 if treatment==1 & xsurprise_nongaap==2, fcluster(cik) tcluster(qid)
	cluster2 bharp3 if treatment==1 & xsurprise_nongaap==2, fcluster(cik) tcluster(qid)
	cluster2 bharp4 if treatment==1 & xsurprise_nongaap==2, fcluster(cik) tcluster(qid)
	cluster2 bharsum if treatment==1 & xsurprise_nongaap==2, fcluster(cik) tcluster(qid)

	cluster2 bharp1 if treatment==1 & xsurprise_nongaap==3, fcluster(cik) tcluster(qid)
	cluster2 bharp2 if treatment==1 & xsurprise_nongaap==3, fcluster(cik) tcluster(qid)
	cluster2 bharp3 if treatment==1 & xsurprise_nongaap==3, fcluster(cik) tcluster(qid)
	cluster2 bharp4 if treatment==1 & xsurprise_nongaap==3, fcluster(cik) tcluster(qid)
	cluster2 bharsum if treatment==1 & xsurprise_nongaap==3, fcluster(cik) tcluster(qid)

	cluster2 bharp1 if treatment==1 & xsurprise_nongaap==4, fcluster(cik) tcluster(qid)
	cluster2 bharp2 if treatment==1 & xsurprise_nongaap==4, fcluster(cik) tcluster(qid)
	cluster2 bharp3 if treatment==1 & xsurprise_nongaap==4, fcluster(cik) tcluster(qid)
	cluster2 bharp4 if treatment==1 & xsurprise_nongaap==4, fcluster(cik) tcluster(qid)
	cluster2 bharsum if treatment==1 & xsurprise_nongaap==4, fcluster(cik) tcluster(qid)

	cluster2 bharp1 if treatment==1 & xsurprise_nongaap==5, fcluster(cik) tcluster(qid)
	cluster2 bharp2 if treatment==1 & xsurprise_nongaap==5, fcluster(cik) tcluster(qid)
	cluster2 bharp3 if treatment==1 & xsurprise_nongaap==5, fcluster(cik) tcluster(qid)
	cluster2 bharp4 if treatment==1 & xsurprise_nongaap==5, fcluster(cik) tcluster(qid)
	cluster2 bharsum if treatment==1 & xsurprise_nongaap==5, fcluster(cik) tcluster(qid)
	

****************************************************************
****************************************************************
****************************************************************
* STEP 12: Create file with identifiers for sharing on JAR website
****************************************************************
****************************************************************
****************************************************************
	use "$path\OutFiles\fundq_sample_nongaap3.dta", clear
	keep cik fdate nongaap_new ng eps_dil_ng ni_ng dummy_*
	sum *
	destring cik, replace
	joinby cik fdate using "$path\EDGAR\data_profit_clean.dta", unmatched(master)
	drop _merge
	ren nongaap_new textsearch_stage2
	ren dummy_comp exclude_comp
	ren dummy_amort exclude_amort
	ren comp_excl_p exclude_comp_p
	ren depram_excl_p exclude_amort_p
	sum *
	sort cik fdate
	save "$path\lv_jar_dataset.dta", replace

*end of do-file
