**Replication code for Aghamolla and Thakor (2021), "Do Mandatory Disclosure Requirements for Private Firms Increase the Propensity of Going Public?"
**Journal of Accounting Research

*Code uses data from the 2016 vintage of the Informa BioMedTracker database, which has project-level drug development information. 
*Base data files are: 1) "Company Portfolios.dta", a drug-indication-year level panel that tracks project status over time
*2) "Company Portfolios Firm.dta", a firm-year level panel dataset that tracks firm portfolio status over time;  
*3) "BMT Disclosures Panel.dta", a firm-year level panel dataset that tracks disclosures by firms over time;
*4) "acquisition_year.dta", a firm-year level panel dataset that tracks development actions (acquisitions, initiations, suspensions) by firms over time
 
**Code to generate Figures 1 and 2
*Generate Figure 1, Disclosures by Project Phase:
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
sort company year
rename company bmtnm
merge m:1 bmtnm year using "BMT Disclosures Panel.dta"
drop _merge
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta" /* IPO dates for biopharma firms from Compustat, manually matched to BMT company names*/
drop if _merge==2
drop _merge
sort bmtnm year
gen public = 1 if gvkey~=. & ipodate==.
replace public = 1 if year(ipodate)<=year
replace public = 0 if public==.
gen private = 0 if public==1
replace private = 1 if public==0
rename bmtnm company
gen phase2above_disc = phase2_disc+phaseabove_disc
*Merge with dataset that includes the number of drugs in each firm's portfolio
merge m:1 company year using "Num Drugs Disclosure.dta"
keep if public==0
gen phase2above = phase_2+phase_above
collapse (sum) num_drugs (sum) phase*, by(year)
gen phase1_scaled = phase1_disc/phase_1_numdrugs
gen phaseabove_scaled = (phase2_disc+phaseabove_disc)/phase_above_numdrugs
twoway line phase1_scaled phaseabove_scaled year if year>2003 & year<2010
gen diff = phaseabove_scaled - phase1_scaled
twoway (scatter diff year if year>2003 & year<=2006) (scatter diff year if year>2006 & year<2010) 

*Generate Figure 2, Disclosures by Private and Public Companies
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
sort company year
rename company bmtnm
merge m:1 bmtnm year using "BMT Disclosures Panel.dta"
drop _merge
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta" /* IPO dates for biopharma firms from Compustat, manually matched to BMT company names*/
drop if _merge==2
drop _merge
sort bmtnm year
gen public = 1 if gvkey~=. & ipodate==.
replace public = 1 if year(ipodate)<=year
replace public = 0 if public==.
gen private = 0 if public==1
replace private = 1 if public==0
rename bmtnm company
replace num_disclosure = 0 if num_disclosure ==.
gen phase2above_disc = phase2_disc+phaseabove_disc
merge m:1 company year using "Num Drugs Disclosure.dta"
replace phase2above_disc = phase2above_disc/(phase_2_numdrugs+phase_above_numdrugs)
collapse (sum) num_disclosure (sum) num_drugs, by(public year)
keep if year>=2004
keep if year<=2009
gen disclosure_scaled = num_disclosure/num_drugs
twoway (line disclosure_scaled year if public==1) (line disclosure_scaled year if public==0)
sort year public
gen diff = disclosure_scaled - disclosure_scaled[_n+1] if public==0
twoway (scatter diff year if year>2003 & year<=2006) (scatter diff year if year>2006 & year<2010) 


**Generate Tables 1, 2, 3 (columns 1-2), A1, 5 (columns 2-3), 8, Figure 3
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
sort company year
rename company bmtnm
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta"
drop _merge
gen year_ipo = year(ipodate)
sort bmtnm year
gen ipo = 1 if year_ipo==year & year_ipo~=.
drop if year_ipo<2004
replace ipo=ipo[_n-1] if ipo==. & bmtnm==bmtnm[_n-1]
replace ipo = 0 if ipo==.
rename bmtnm company
gen treat = prop_phase2above if year==2006
bysort company: egen treated = max(treat)
replace treated = 0 if treated==. /* This sets new entrants in the post-period are treated as controls, as noted in paper.*/
gen after = 0
replace after = 1 if year>=2007
gen treatXafter = treated*after
sort company year
egen company_id = group(company)
tsset company_id year

*Table 1 Panel A: Summary Statistics:
su treated ipo L.loa L.num_drugs if year>=2004 & year<=2009, de
*Table 1 Panel B: Number of IPOs by year:
by year: count if year_ipo==year & year_ipo~=. & year>=2004 & year<=2009
*Table 2: IPO Propensity Following Increased Disclosure Requirements After FDAAA Enactment:
reg ipo treatXafter treated after if year>=2004 & year<=2009, r cluster(company)
reg ipo treatXafter treated after L.loa L.num_drugs if year>=2004 & year<=2009, r cluster(company) 
xi: reg ipo treatXafter treated L.loa L.num_drugs i.year if year>=2004 & year<=2009, r cluster(company) 
xi: reg ipo treatXafter treated ind1-ind624 i.year if year>=2004 & year<=2009, r cluster(company)
xi: reg ipo treatXafter treated L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009, r cluster(company)
reghdfe ipo treatXafter L.loa L.num_drugs ind1-ind624 if year>=2004 & year<=2009, absorb(company_id year) vce(cluster company_id) keepsing
*Table 3 columns (1)-(2): Effect based on whether firm had low or high disclosures pre-FDAAA:
rename company bmtnm
merge m:1 bmtnm year using "BMT Disclosures Panel.dta"
drop if _merge==2
drop _merge
replace num_disclosure = 0 if num_disclosure ==.
replace disclosure = 0 if disclosure ==.
gen disclosure_2006 = num_disclosures/num_drugs if year<=2006 & year>=2000
bysort company: egen mean_disclosure_2006 = mean(disclosure_2006)
gen high_disclosure_2006 = 0 if mean_disclosure_2006 <1 & mean_disclosure_2006~=.
replace high_disclosure_2006 = 1 if mean_disclosure_2006>=1 & mean_disclosure_2006~=.
bysort company: egen disclosure_2006_dum = max(high_disclosure_2006)
sort company year
tsset company_id year
reghdfe ipo treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009 & disclosure_2006_dum==0, absorb(company_id year) vce(cluster company_id)
reghdfe ipo treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009 & disclosure_2006_dum==1, absorb(company_id year) vce(cluster company_id)
*Table A1: Logit/Probit Specifications:
logit ipo treatXafter treated after L.loa L.num_drugs i.year if year>=2004 & year<=2009, r cluster(company)
probit ipo treatXafter treated after L.loa L.num_drugs if year>=2004 & year<=2009, r cluster(company)
*Table 5: Columns 2 and 3: 
*Column 2:
reghdfe ipo treatXafter L.loa L.num_drugs ind1-ind624 if year>=2004 & year<=2007, absorb(company_id year) vce(cluster company_id)
*Column 3: Exclude 2008, and keep only IPOs that occured in just first 6 months of 2007 and last 6 months of 2009
gen ipo_month = month(ipodate)
gen ipo_year = year(ipodate)
replace ipo = . if year==2008 
replace ipo = . if ipo_year==2008 
replace ipo = . if ipo_year==2007 & ipo_month>6
replace ipo = . if ipo_year==2009 & ipo_month<=6 
reghdfe ipo treatXafter L.loa L.num_drugs ind1-ind624 if year>=2004 & year<=2007 & year~=2008, absorb(company_id year) vce(cluster company_id)
*Table 8: Robustness, Autocorrelation:
*Newey-West standard errors
newey ipo treatXafter treated after if year>=2004 & year<=2009, lag(2) force
newey ipo treatXafter treated after L.loa L.num_drugs  if year>=2004 & year<=2009, lag(2) force
xi: newey ipo treatXafter treated L.loa L.num_drugs i.year if year>=2004 & year<=2009, lag(2) force
xi: newey ipo treatXafter treated ind1-ind624 i.year if year>=2004 & year<=2009, lag(2) force
reghdfe ipo treatXafter treated L.loa L.num_drugs ind1-ind624 if year>=2004 & year<=2009, absorb(year) vce(robust, bw(2))
reghdfe ipo treatXafter L.loa L.num_drugs ind1-ind624 if year>=2004 & year<=2009, absorb(year company_id) vce(robust, bw(2))
*Figure 3: Parallel Trends
forvalues i=2001(1)2011 {
	gen inter`i' = _Iyear_`i'*treated
}
gen _Iyear_2000=0
replace _Iyear_2000=1 if year==2000
gen inter2000=_Iyear_2000*treated
replace inter2006=0 /*set reference year as 2006 */
reghdfe ipo inter2002 inter2003 inter2004 inter2005 inter2006 inter2007 inter2008 inter2009 L.loa L.num_drugs if year>=2002 & year<=2009, absorb(company_id year ind1-ind624) vce(cluster company_id)
coefplot, keep(inter2002 inter2003 inter2004 inter2005 inter2006 inter2007 inter2008 inter2009) vertical yline(0) levels(90) omitted ciopts(recast(rline) lpattern(dash))


**Table 3 Columns 3-4, Table A3, Effects split by degree of competitiveness and whether firm develops an Orphan Drug
*"Drug Indication Competition.dta" is a dataset of the number of competing drugs per indication category prior to FDAAA:
*Compile data and run regressions:
clear
clear matrix
cd "..."
use "Company Portfolios.dta", clear
gen phase_1 = 1 if eventphase=="Preclinical"
replace phase_1 = 1 if eventphase=="I"
gen phase_2 = 1 if eventphase=="II" 
gen phase_above = 1 if eventphase=="III" | eventphase=="NDA/BLA" 
egen indication_id = group(indication)
tabulate indication_id, gen(ind)
merge m:1 indication year using "Drug Indication Competition.dta" /*Merge indication competition data*/
drop if _merge==2
drop _merge
sort company year
collapse (mean) loa (sum) phase_1 (sum) phase_2 (sum) phase_above (count) num_drugs=loa (max) ind1-ind624 (sum) drug_comp (mean) mean_drug_comp=drug_comp (max) orphan_drug, by(company year)
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
sort company year
rename company bmtnm
append using "Appended Data IPOs BMT.dta"
drop ipodate year_ipo
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta"
drop _merge
sort bmtnm year
gen year_ipo = year(ipodate)
gen ipo = 1 if year_ipo==year & ipodate~=.
drop if year_ipo<2004
replace ipo=ipo[_n-1] if ipo==. & bmtnm==bmtnm[_n-1]
replace ipo = 0 if ipo==.
rename bmtnm company
gen treat = prop_phase2above if year==2006
bysort company: egen treated = max(treat)
replace treated = 0 if treated==. 
gen after = 0
replace after = 1 if year>=2007
gen treatXafter = treated*after
sort company year
egen company_id = group(company)
tsset company_id year
gen comp_06 = drug_comp if year==2006
replace comp_06 = 0 if comp_06==. & year==2006
bysort company: egen comp_2006 = mean(comp_06)
replace comp_2006=0 if comp_2006==.
su comp_06, de
gen orphan_06 = orphan_drug if year==2006
bysort company: egen orphan_2006 = mean(orphan_06)
replace orphan_2006 = 0 if orphan_2006==.
sort company year
tsset company_id year
*Table 3 Columns 3-4 (cut on median number of competing drugs):
xi: reg ipo treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009 & comp_2006>39 & comp_2006~=., r absorb(company) cluster(company)
xi: reg ipo treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009 & comp_2006<39 & comp_2006~=., r absorb(company) cluster(company)
*Table A3:
reg ipo treatXafter treated after i.year if year>=2004 & year<=2009 & orphan_2006==1, r cluster(company)
xi: reg ipo treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009 & orphan_2006==1, r absorb(company) cluster(company)
reg ipo treatXafter treated after i.year if year>=2004 & year<=2009 & orphan_2006==0, r cluster(company)
xi: reg ipo treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009 & orphan_2006==0, r absorb(company) cluster(company)


**Generate Table 5 column 1: Excluding the Financial Crisis
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
sort company year
rename company bmtnm
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta"
drop _merge
gen year_ipo = year(ipodate)
sort bmtnm year
gen ipo = 1 if year_ipo==year & year_ipo~=.
drop if year_ipo<2003
replace ipo=ipo[_n-1] if ipo==. & bmtnm==bmtnm[_n-1]
replace ipo = 0 if ipo==.
rename bmtnm company
gen treat = prop_phase2above if year==2006
bysort company: egen treated = max(treat)
replace treated = 0 if treated==. 
gen after = 0
replace after = 1 if year>=2007
gen treatXafter = treated*after
sort company year
egen company_id = group(company)
tsset company_id year
*Column 1:
reghdfe ipo treatXafter L.loa L.num_drugs ind1-ind624 if year>=2003 & year<=2010, absorb(company_id year) vce(cluster company_id)


**Generate Table 4: Placebo Test
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
rename company bmtnm
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta"
drop _merge
sort bmtnm year
gen year_ipo = year(ipodate)
gen ipo = 1 if year_ipo==year & ipodate~=.
drop if year_ipo<2000
replace ipo=ipo[_n-1] if ipo==. & bmtnm==bmtnm[_n-1]
replace ipo = 0 if ipo==.
rename bmtnm company
gen treat = prop_phase2above if year==2003
bysort company: egen treated = max(treat)
replace treated = 0 if treated==.
gen after = 0
replace after = 1 if year>=2004
gen treatXafter = treated*after
sort company year
egen company_id = group(company)
tsset company_id year
reg ipo treatXafter treated after if year>=2000 & year<=2006, r cluster(company)
reg ipo treatXafter treated after L.loa L.num_drugs if year>=2000 & year<=2006, r cluster(company)
xi: reg ipo treatXafter treated L.loa L.num_drugs i.year if year>=2000 & year<=2006, r cluster(company) 
xi: reg ipo treatXafter treated ind1-ind624 i.year if year>=2000 & year<=2006, r cluster(company)
xi: reg ipo treatXafter treated L.loa L.num_drugs ind1-ind624 i.year if year>=2000 & year<=2006, r cluster(company)
xi: reg ipo treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2000 & year<=2006, r absorb(company) cluster(company)


**Generate Table 6: Robustness Placebo Test for Portfolio Phase
*Drops Phase 1 firms, uses Phase III and above as treatment. 
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
rename company bmtnm
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta"
drop if _merge==2
drop _merge
sort bmtnm year
gen year_ipo = year(ipodate)
gen ipo = 1 if year_ipo==year & ipodate~=.
sort bmtnm year
drop if year_ipo<2004
sort bmtnm year
replace ipo=ipo[_n-1] if ipo==. & bmtnm==bmtnm[_n-1]
replace ipo = 0 if ipo==.
rename bmtnm company
gen treat = prop_phase2above if year==2006
bysort company: egen treated = max(treat)
replace treated = 0 if treated==.
gen after = 0
replace after = 1 if year>=2007
keep if treated==1
gen prop_phase3 = phase_above/num_drugs
gen treat2 = prop_phase3 if year==2006
bysort company: egen treated2 = max(treat2)
replace treated2 = 0 if treated==.
gen treatXafter = treated2*after
egen company_id = group(company)
tsset company_id year
*Columns 1-6:
reg ipo treatXafter treated2 after if year>=2004 & year<=2009, r cluster(company)
reg ipo treatXafter treated2 after L.loa L.num_drugs if year>=2004 & year<=2009, r cluster(company)
xi: reg ipo treatXafter treated2 after L.loa L.num_drugs i.year if year>=2004 & year<=2009, r cluster(company)
xi: reg ipo treatXafter treated2 ind1-ind624 i.year if year>=2004 & year<=2009, r cluster(company)
xi: reg ipo treatXafter treated2 L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009, r cluster(company)
reghdfe ipo treatXafter L.loa L.num_drugs ind1-ind624 if year>=2004 & year<=2009, absorb(company_id year) vce(cluster company_id)
*Column 7:
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
rename company bmtnm
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta"
drop if _merge==2
drop _merge
sort bmtnm year
gen year_ipo = year(ipodate)
gen ipo = 1 if year_ipo==year & ipodate~=.
sort bmtnm year
drop if year_ipo<2004
sort bmtnm year
replace ipo=ipo[_n-1] if ipo==. & bmtnm==bmtnm[_n-1]
replace ipo = 0 if ipo==.
rename bmtnm company
gen treat = prop_phase2above if year==2006
bysort company: egen treated = max(treat)
replace treated = 0 if treated==.
gen after = 0
replace after = 1 if year>=2007
gen prop_phase3 = phase_above/num_drugs
gen treat2 = prop_phase3 if year==2006
bysort company: egen treated2 = max(treat2)
replace treated2 = 0 if treated2==.
gen treatXafter_placebo = treated2*after
gen treatXafter = treated*after
egen company_id = group(company)
tsset company_id year
reghdfe ipo treatXafter treatXafter_placebo L.loa L.num_drugs ind1-ind624 if year>=2004 & year<=2009, absorb(company_id year) vce(cluster company_id) keepsing


**Generate Table 7: Project Composition pre-FDAAA
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
sort company year
rename company bmtnm
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta"
drop if _merge==2
drop _merge
gen year_ipo = year(ipodate)
sort bmtnm year
gen ipo = 1 if year_ipo==year & year_ipo~=.
drop if year_ipo<2000
replace ipo=ipo[_n-1] if ipo==. & bmtnm==bmtnm[_n-1]
replace ipo = 0 if ipo==.
rename bmtnm company
gen treat = prop_phase2above if year==2000
bysort company: egen treated = max(treat)
replace treated = 0 if treated==. 
gen after = 0
replace after = 1 if year>=2007
gen treatXafter = treated*after
sort company year
egen company_id = group(company)
tsset company_id year
*Panel A:
reg ipo treated if year>=2000 & year<=2006, r cluster(company)
reg ipo treated L.loa L.num_drugs if year>=2000 & year<=2006, r cluster(company)
reg ipo treated L.loa L.num_drugs i.year if year>=2000 & year<=2006, r cluster(company)
reg ipo treated L.loa L.num_drugs ind1-ind624 i.year if year>=2000 & year<=2006, r cluster(company)
*Panel B:
reg ipo L.prop_phase2above if year>=2000 & year<=2006, r cluster(company)
reg ipo L.prop_phase2above L.loa L.num_drugs if year>=2000 & year<=2006, r cluster(company)
reg ipo L.prop_phase2above L.loa L.num_drugs i.year if year>=2000 & year<=2006, r cluster(company)
reg ipo L.prop_phase2above L.loa L.num_drugs ind1-ind624 i.year if year>=2000 & year<=2006, r cluster(company)
reghdfe ipo L.prop_phase2above L.loa L.num_drugs ind1-ind624 if year>=2000 & year<=2006, absorb(company_id year) vce(cluster company_id) keepsing

**Generate Table A4: Project Decisions for Firms that Remained Private around FDAAA
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
sort company year
rename company bmtnm
merge m:1 bmtnm year using "acquisition_year.dta" /* Panel of acquisitions of drug projects by firms */
drop if _merge==2
drop _merge
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta"
drop _merge
gen year_ipo = year(ipodate)
sort bmtnm year
gen ipo = 1 if year_ipo==year & year_ipo~=.
drop if year_ipo<2004
replace ipo=ipo[_n-1] if ipo==. & bmtnm==bmtnm[_n-1]
replace ipo = 0 if ipo==.
rename bmtnm company
gen treat = prop_phase2above if year==2006
bysort company: egen treated = max(treat)
replace treated = 0 if treated==. 
gen after = 0
replace after = 1 if year>=2007
gen treatXafter = treated*after
sort company year
egen company_id = group(company)
tsset company_id year
replace pre_initiation_y = 0 if pre_initiation_y==. 
replace risky_initiation = 0 if risky_initiation==. 
replace suspension_y = 0 if suspension_y==. 
replace drug_acq = 0 if drug_acq ==. 
replace late_suspension = 0 if late_suspension==. 
replace early_suspension = 0 if early_suspension==. 
replace late_drugacq = 0 if late_drugacq ==. 
gen non_risky_acq = drug_acq - risk_drug_acq_y
keep if year>=2004 & year<=2009
bysort company: egen private = max(ipo)
sort company year
tsset company_id year
xi: areg num_drugs treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009 & ipo==0, r absorb(company) cluster(company)
xi: areg pre_initiation_y treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009 & ipo==0, r absorb(company) cluster(company)
xi: areg suspension_y treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009 & ipo==0, r absorb(company) cluster(company)
xi: areg drug_acq treatXafter L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2009 & ipo==0, r absorb(company) cluster(company)


**Generate Tables 9 and 10: Project Decisions and IPOs 
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
sort company year
rename company bmtnm
merge m:1 bmtnm year using "acquisition_year.dta" /* Panel of acquisitions of drug projects by firms */
drop if _merge==2
drop _merge
sort bmtnm year
merge m:1 bmtnm using "IPO Dates JAR Final.dta"
drop _merge
gen year_ipo = year(ipodate)
sort bmtnm year
gen ipo = 1 if year_ipo==year & year_ipo~=.
drop if year_ipo<2004
replace ipo=ipo[_n-1] if ipo==. & bmtnm==bmtnm[_n-1]
replace ipo = 0 if ipo==.
rename bmtnm company
gen treat = prop_phase2above if year==2006
bysort company: egen treated = max(treat)
replace treated = 0 if treated==. 
gen after = 0
replace after = 1 if year>=2007
gen treatXafter = treated*after
sort company year
egen company_id = group(company)
tsset company_id year
replace pre_initiation_y = 0 if pre_initiation_y==. 
replace risky_initiation = 0 if risky_initiation==. 
replace suspension_y = 0 if suspension_y==. 
replace drug_acq = 0 if drug_acq ==. 
replace late_suspension = 0 if late_suspension==. 
replace early_suspension = 0 if early_suspension==. 
replace late_drugacq = 0 if late_drugacq ==. 
gen non_risky_acq = drug_acq - risk_drug_acq_y
*Table 9:
ivregress 2sls num_drugs L.loa L.num_drugs ind1-ind624 i.year (ipo = treatXafter treated) if year>=2004 & year<=2009, r  cluster(company_id)
ivregress 2sls pre_initiation_y L.loa L.num_drugs ind1-ind624 i.year (ipo = treatXafter treated) if year>=2004 & year<=2009, r  cluster(company_id)
ivregress 2sls suspension_y L.loa L.num_drugs ind1-ind624 i.year (ipo = treatXafter treated) if year>=2004 & year<=2009, r  cluster(company_id)
ivregress 2sls drug_acq L.loa L.num_drugs ind1-ind624 i.year (ipo = treatXafter treated) if year>=2004 & year<=2009, r  cluster(company_id)
ivregress 2sls loa L.loa L.num_drugs ind1-ind624 i.year (ipo = treatXafter treated) if year>=2004 & year<=2009, r  cluster(company_id)
*Table 10: 
ivregress 2sls risk_drug_acq L.loa L.num_drugs ind1-ind624 i.year (ipo = treatXafter treated) if year>=2004 & year<=2009, r  cluster(company_id)
ivregress 2sls non_risky_acq L.loa L.num_drugs ind1-ind624 i.year (ipo = treatXafter treated) if year>=2004 & year<=2009, r  cluster(company_id)
ivregress 2sls late_drugacq_y L.loa L.num_drugs ind1-ind624 i.year (ipo = treatXafter treated) if year>=2004 & year<=2009, r  cluster(company_id)
ivregress 2sls early_drug_acq L.loa L.num_drugs ind1-ind624 i.year (ipo = treatXafter treated) if year>=2004 & year<=2009, r  cluster(company_id)


**Table A2: Project Composition and Project Decisions pre-FDAAA
*Project Compostion and Project Decisions pre-FDAAA Table A1
cd "..."
use "Company Portfolios Firm.dta", clear
gen prop_phase1 = phase_1/num_drugs
gen prop_phase2 = phase_2/num_drugs
gen prop_phase2above = (phase_2 + phase_above)/num_drugs
sort company year
rename company bmtnm
merge m:1 bmtnm year using "acquisition_year.dta"
drop if _merge==2
drop _merge
merge m:1 bmtnm using "IPO Dates JAR Final.dta"
drop _merge
gen year_ipo = year(ipodate)
sort bmtnm year
gen ipo = 1 if year_ipo==year & ipodate~=.
drop if year_ipo<2004
replace ipo=ipo[_n-1] if ipo==. & bmtnm==bmtnm[_n-1]
replace ipo = 0 if ipo==.
rename bmtnm company
gen treat = prop_phase2above if year==2006
bysort company: egen treated = max(treat)
replace treated = 0 if treated==. 
gen after = 0
replace after = 1 if year>=2007
gen treatXafter = treated*after
sort company year
egen company_id = group(company)
tsset company_id year
replace pre_initiation_y = 0 if pre_initiation_y==. 
replace risky_initiation = 0 if risky_initiation==. 
replace suspension_y = 0 if suspension_y==. 
replace drug_acq = 0 if drug_acq ==. 
replace late_suspension = 0 if late_suspension==. 
replace early_suspension = 0 if early_suspension==. 
replace late_drugacq = 0 if late_drugacq ==. 
gen non_risky_acq = drug_acq - risk_drug_acq_y
xi: areg num_drugs L.prop_phase2above L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2006, r absorb(company)  cluster(company)
xi: areg pre_initiation_y L.prop_phase2above L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2006, r absorb(company)  cluster(company)
xi: areg suspension_y L.prop_phase2above L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2006, r absorb(company)  cluster(company)
xi: areg drug_acq L.prop_phase2above L.loa L.num_drugs ind1-ind624 i.year if year>=2004 & year<=2006, r absorb(company)  cluster(company)


**Code for Analysis in Section 6 of the paper. Raw data come from Bureau van Dijk Orbis and Amadeus databases, with criteria described in the paper)
*"All Europe.dta": Raw data from Orbis database from 2002 to 2012
**Generate Table 11, Panel A columns 1-2, Panel B column 1:
clear 
clear matrix 
cd "..."
use "All Europe.dta"
rename CLOSDATE_year year
drop if year==2012
drop if IPO_DATE_year<2002
duplicates tag bvdid year, gen(dup)
drop if dup==1 & substr(CONSCODE,1,1)=="U"
drop dup
duplicates drop bvdid year, force
sort bvdid year
gen ipo=1 if year==IPO_DATE_year
replace ipo=ipo[_n-1] if ipo==. & bvdid==bvdid[_n-1]
replace ipo = 0 if ipo==.
order ipo, before(year)
replace ipo=. if ipo==1 & year>IPO_DATE_year
gen after = 0 
replace after = 1 if year>=2006
gen treat = 0
replace treat = 1 if COUNTRY=="Germany"
gen inter = treat*after
egen id = group(bvdid)
sort bvdid year
keep if year<=2009
tsset id year
sort id year
gen size = log(1+TOAS)
gen cash_ta = CASH/TOAS
gen profitability = EBTA/TOAS
*Table 11 Panel A, column 1:
*Coefficient estimates in paper multipled by 100, to ease readability
reghdfe ipo inter size cash_ta profitability if year>=2003 & year<=2008, absorb(id year) vce(cluster id)
*Table 11 Panel B column 1, 2007 treatment year, drop 2006:
gen after2 = 0 
replace after2 = 1 if year>=2007
gen inter2 = treat*after
reghdfe ipo inter2 size cash_ta profitability if year>=2003 & year<=2008 & year~=2006, absorb(id year) vce(cluster id)
*Table 11 Panel A, column 2: Robustness to the financial crisis 
gen ipo_quarter = quarter(IPO_DATE)
drop if ipo_quarter==3 & IPO_DATE_year==2007 & year==2007
drop if ipo_quarter==4 & IPO_DATE_year==2007 & year==2007
reghdfe ipo inter size cash_ta profitability if year>=2003 & year<=2007, absorb(id year) vce(cluster id)

**Figure 4, Parallel Trends:
clear 
clear matrix 
cd "..."
use "All Europe.dta"
rename CLOSDATE_year year
drop if year==2012
drop if IPO_DATE_year<2002
duplicates tag bvdid year, gen(dup)
drop if dup==1 & substr(CONSCODE,1,1)=="U"
drop dup
duplicates drop bvdid year, force
sort bvdid year
gen ipo=1 if year==IPO_DATE_year
replace ipo=ipo[_n-1] if ipo==. & bvdid==bvdid[_n-1]
replace ipo = 0 if ipo==.
order ipo, before(year)
replace ipo=. if ipo==1 & year>IPO_DATE_year
gen after = 0 
replace after = 1 if year>=2006
gen treat = 0
replace treat = 1 if COUNTRY=="Germany"
gen inter = treat*after
egen id = group(bvdid)
sort bvdid year
keep if year<=2009
tsset id year
sort id year
gen size = log(1+TOAS)
gen cash_ta = CASH/TOAS
gen profitability = EBTA/TOAS
forvalues i=2000(1)2012 {
	gen year_`i'=0
	replace year_`i'=1 if year==`i'
	gen inter`i' = year_`i'*treat/100
}
replace inter2005=0
reghdfe ipo inter2002 inter2003 inter2004 inter2005 inter2006 inter2007 inter2008 inter2009 size cash_ta profitability if year>=2002 & year<=2009, absorb(id year) vce(cluster id)
coefplot, keep(inter*) vertical yline(0) levels(90) omitted ciopts(recast(rline) lpattern(dash))

**Generate Table 11, Panel A columns 3-4, Panel B column 2, propensity score matched sample:
clear 
clear matrix 
cd "..."
use "All Europe.dta"
rename CLOSDATE_year year
drop if year==2012
drop if IPO_DATE_year<2002
duplicates tag bvdid year, gen(dup)
drop if dup==1 & substr(CONSCODE,1,1)=="U"
drop dup
duplicates drop bvdid year, force
sort bvdid year
gen ipo=1 if year==IPO_DATE_year
replace ipo=ipo[_n-1] if ipo==. & bvdid==bvdid[_n-1]
replace ipo = 0 if ipo==.
order ipo, before(year)
replace ipo=. if ipo==1 & year>IPO_DATE_year
gen after = 0 
replace after = 1 if year>=2006
gen treat = 0
replace treat = 1 if COUNTRY=="Germany"
gen inter = treat*after
egen id = group(bvdid)
sort bvdid year
keep if year<=2009
tsset id year
sort id year
gen size = log(1+TOAS)
gen cash_ta = CASH/TOAS
gen profitability = EBTA/TOAS
winsor cash_ta, gen(wcash_ta) p(0.01)
preserve
keep if year==2005
collapse (mean) size (mean) wcash_ta (mean) profitability (max) treat, by(id)
psmatch2 treat size wcash_ta profitability, norepl common desc
save "PS Sample Germany.dta", replace
restore
merge m:1 id using "PS sample Germany.dta"
drop _merge
drop if _weight==.
tsset id year
*Table 11 Panel A column 3: 
reghdfe ipo inter size cash_ta profitability if year>=2003 & year<=2008, absorb(id year) vce(cluster id) keepsing
*Table 11 Panel B column 2, 2007 treatment year, drop 2006:
gen after2 = 0 
replace after2 = 1 if year>=2007
gen inter2 = treat*after
reghdfe ipo inter2 size cash_ta profitability if year>=2003 & year<=2008 & year~=2006, absorb(id year) vce(cluster id)
*Table 11 Panel A column 4, excluding financial crisis:
gen ipo_quarter = quarter(IPO_DATE)
drop if ipo_quarter==3 & IPO_DATE_year==2007 & year==2007
drop if ipo_quarter==4 & IPO_DATE_year==2007 & year==2007
reghdfe ipo inter size cash_ta profitability if year>=2003 & year<=2007, absorb(id year) vce(cluster id)

*Table A5, t-test of treatment and control groups after matching
clear
clear matrix
cd "..."
use "PS sample Germany.dta"
drop if _weight==.
ttest wcash_ta, by(treat)
ttest size, by(treat)
ttest profitability, by(treat)

**Table 12 Panel A: External Validity: Extensions, competitiveness within Germany
*"Germany Sample Competitiveness.dta" is a dataset with data for Germany from BvD Amadeus database, merged by with IPO data from BvD Orbis 
*Table 12 Panel A Column 1:
clear 
clear matrix 
cd "..."
use "Germany Sample Competitiveness.dta"
*Remove firms not affected by reform due to being below threshold
drop if TOAS<4015000 & TURN<8030000 & TOAS~=. & TURN~=.
rename CLOSDATE_year year
drop if year>2008 | year<2003
drop if strpos(SLEGALF,"Foreign companies")
drop if strpos(SLEGALF,"Non profit organisations")
rename NAICS_CORE_CODE naics
drop if substr(naics,1,2)=="52" | substr(naics,1,2)=="92"
drop if substr(USSIC_CORE_CODE,1,1)=="6"
tostring siccode, replace
drop if substr(siccode,1,1)=="6"
*Drop financials and utilities
drop if IPO_DATE_year<2002
duplicates tag bvdid year, gen(dup)
drop if dup==1 & REPBAS=="Unconsolidated data"
drop dup
duplicates drop bvdid year, force
gen naics3=substr(naics,1,3)
bysort naics3 year: egen sum_naics_sales = total(TURN)
gen s_n2 = (TURN/sum_naics_sales)^2
by naics3 year: egen s_2_naics = total(s_n2)
sort bvdid year
gen ipo=1 if year==IPO_DATE_year
replace ipo=ipo[_n-1] if ipo==. & bvdid==bvdid[_n-1]
replace ipo = 0 if ipo==.
order ipo, before(year)
replace ipo=. if ipo==1 & year>IPO_DATE_year
replace s_2_naics=. if year>2005
bysort naics3: egen avg_s2_naics = mean(s_2_naics)
sort bvdid year
gen after = 0 
replace after = 1 if year>=2006 
gen treat = 0 if avg_s2_naics~=.
replace treat = -avg_s2_naics if avg_s2_naics~=.
gen inter = treat*after
egen id = group(bvdid)
sort bvdid year
destring naics, replace
tsset id year
sort id year
gen size = log(1+TOAS)
gen cash_ta = CASH/TOAS
gen profitability = EBTA/TOAS
reghdfe ipo inter size cash_ta if year>=2003 & year<=2008, absorb(id year) vce(cluster id)

*Table 12 Panel A Column 2:
clear 
clear matrix 
cd "..."
use "Germany Sample Competitiveness.dta"
*Remove firms not affected by reform
drop if TOAS<4015000 & TURN<8030000 & TOAS~=. & TURN~=.
rename CLOSDATE_year year
drop if year>2008 | year<2003
drop if strpos(SLEGALF,"Foreign companies")
drop if strpos(SLEGALF,"Non profit organisations")
rename NAICS_CORE_CODE naics
drop if substr(naics,1,2)=="52" | substr(naics,1,2)=="92"
drop if substr(USSIC_CORE_CODE,1,1)=="6"
tostring siccode, replace
drop if substr(siccode,1,1)=="6"
*Drop financials and utilities
drop if IPO_DATE_year<2002
duplicates tag bvdid year, gen(dup)
drop if dup==1 & REPBAS=="Unconsolidated data"
drop dup
duplicates drop bvdid year, force
gen naics3=substr(naics,1,4)
bysort naics3 year: egen sum_naics_sales = total(TURN)
gen s_n2 = (TURN/sum_naics_sales)^2
by naics3 year: egen s_2_naics = total(s_n2)
sort bvdid year
gen ipo=1 if year==IPO_DATE_year
replace ipo=ipo[_n-1] if ipo==. & bvdid==bvdid[_n-1]
replace ipo = 0 if ipo==.
order ipo, before(year)
replace ipo=. if ipo==1 & year>IPO_DATE_year
replace s_2_naics=. if year>2005
bysort naics3: egen avg_s2_naics = mean(s_2_naics)
sort bvdid year
gen after = 0 
replace after = 1 if year>=2006 
gen treat = 0 if avg_s2_naics~=.
replace treat = -avg_s2_naics if avg_s2_naics~=.
gen inter = treat*after
egen id = group(bvdid)
sort bvdid year
destring naics, replace
tsset id year
sort id year
gen size = log(1+TOAS)
gen cash_ta = CASH/TOAS
gen profitability = EBTA/TOAS
reghdfe ipo inter size cash_ta if year>=2003 & year<=2008, absorb(id year) vce(cluster id)


**Table A6: External Validity, Disclosure Requirements Across Europe
*Data from BvD Orbis database
*"All Europe v2.dta" is a dataset from BvD Orbis that has the sample of European firms indicated in the paper from 2002 to 2019
*"USD EUR Exch.dta" is a dataset of yearly exchange rates between USD and EUR, obtained from the St. Louis FRED data repository
clear 
clear matrix 
cd "..."
use "All Europe v2.dta"
rename CLOSDATE_year year
*Drop financials and utilities
drop if IPO_DATE_year<2002
duplicates tag bvdid year, gen(dup)
drop if dup==1 & substr(CONSCODE,1,1)=="U"
drop dup
duplicates drop bvdid year, force
sort bvdid year
gen ipo=1 if year==IPO_DATE_year
replace ipo=ipo[_n-1] if ipo==. & bvdid==bvdid[_n-1]
replace ipo = 0 if ipo==.
order ipo, before(year)
replace ipo=. if ipo==1 & year>IPO_DATE_year
merge m:1 year using "USD EUR Exch.dta"
drop _merge
*Convert to common currencies using exchange rate info
foreach x of varlist CASH TOAS TURN EBTA {
	replace `x'=`x'*EXCHRATE if ORIG_CURRENCY~="EUR"
	replace `x'=`x'*usd_eur
}
*Treatment definitions based on disclosure thresholds as in Bernard et al (2018)
gen treat = 0
replace treat=1 if year>=2003 & year<=2005 & TOAS>=3125000 & TURN>=6250000 & EMPL>=50 & COUNTRY=="Austria" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2006 & year<=2008 & TOAS>=3650000 & TURN>=7300000 & EMPL>=50 & COUNTRY=="Austria" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2009 & TOAS>=4840000 & TURN>=9680000 & EMPL>=50 & COUNTRY=="Austria" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2003 & year<=2004 & TOAS>=3125000 & TURN>=6250000 & EMPL>=50 & COUNTRY=="Belgium" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2005 & TOAS>=3650000 & TURN>=7300000 & EMPL>=50 & COUNTRY=="Belgium" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2003 & year<=2004 & TOAS>=2689560 & TURN>=5379120 & EMPL>=50 & COUNTRY=="Denmark" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2005 & year<=2008 & TOAS>=3890495 & TURN>=7780990 & EMPL>=50 & COUNTRY=="Denmark" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2009 & TOAS>=4833504 & TURN>=9667008 & EMPL>=50 & COUNTRY=="Denmark" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2003 & year<=2005 & TOAS>=3125000 & TURN>=6250000 & EMPL>=50 & COUNTRY=="Finland" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2006 & TOAS>=3650000 & TURN>=7300000 & EMPL>=50 & COUNTRY=="Finland" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2003 & year<=2010 & TOAS>=267000 & TURN>=534000 & EMPL>=10 & COUNTRY=="France" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2011 & TOAS>=1000000 & TURN>=2000000 & EMPL>=20 & COUNTRY=="France" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2003 & year<=2004 & TOAS>=3438000 & TURN>=6875000 & EMPL>=50 & COUNTRY=="Germany" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2005 & year<=2009 & TOAS>=4015000 & TURN>=8030000 & EMPL>=50 & COUNTRY=="Germany" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2010 & TOAS>=4840000 & TURN>=9680000 & EMPL>=50 & COUNTRY=="Germany" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2003 & TOAS>=1904607 & TURN>=3809214 & EMPL>=50 & COUNTRY=="Ireland" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2003 & year<=2006 & TOAS>=3125000 & TURN>=6250000 & EMPL>=50 & COUNTRY=="Italy" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2007 & year<=2009 & TOAS>=3650000 & TURN>=7300000 & EMPL>=50 & COUNTRY=="Italy" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2010 & TOAS>=4400000 & TURN>=8800000 & EMPL>=50 & COUNTRY=="Italy" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2003 & year<=2004 & TOAS>=3500000 & TURN>=7000000 & EMPL>=50 & COUNTRY=="Netherlands" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2005 & year<=2006 & TOAS>=3650000 & TURN>=7300000 & EMPL>=50 & COUNTRY=="Netherlands" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2006 & TOAS>=4400000 & TURN>=8800000 & EMPL>=50 & COUNTRY=="Netherlands" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2003 & year<=2008 & TOAS>=2373998 & TURN>=4747996 & EMPL>=50 & COUNTRY=="Spain" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2009 & TOAS>=2850000 & TURN>=5700000 & EMPL>=50 & COUNTRY=="Spain" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2008 & year<=2011 & TOAS>=2582500 & TURN>=5165000 & EMPL>=50 & COUNTRY=="Sweden" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2012 & TOAS>=4408000 & TURN>=8816000 & EMPL>=50 & COUNTRY=="Sweden" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year==2003 & TOAS>=2024120 & TURN>=4048240 & EMPL>=50 & COUNTRY=="United Kingdom" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2004 & year<=2008 & TOAS>=3944080 & TURN>=7888160 & EMPL>=50 & COUNTRY=="United Kingdom" & TOAS~=. & TURN~=. & EMPL~=.
replace treat=1 if year>=2009 & TOAS>=3755520 & TURN>=7488000 & EMPL>=50 & COUNTRY=="United Kingdom" & TOAS~=. & TURN~=. & EMPL~=.
egen id = group(bvdid)
tsset id year
*Firm is treated if it stays past disclosure threshold for two consecutive years
replace treat=1 if L.treat==1 & L2.treat==1
sort bvdid year
by bvdid: gen counter = sum(treat)
replace treat=1 if counter>2
drop counter
tostring year, gen(year2)
gen countryyear = CTRYISO+year2
tab countryyear, gen(countryXyear)
tsset id year
sort id year
gen size = log(1+TOAS)
gen cash_ta = CASH/TOAS
gen profitability = EBTA/TOAS
*Coefficients multiplied by 100 in paper to ease readability
reghdfe ipo L.treat size cash_ta profitability, absorb(id year) vce(cluster id)
reghdfe ipo L.treat size cash_ta profitability, absorb(id countryXyear*) vce(cluster id)

