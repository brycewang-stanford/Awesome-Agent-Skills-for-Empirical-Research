// Prior to this step, manually pulled these variables for relevant GVKEYs:
// RCA, RCD, RCEPS, RCP, XRD

use "C:\Users\kverb\Dropbox (University of Michigan)\Gallo Tomy\Data\Final Datasets\Backup\WRDS pull - restructuring and RD expenses - raw.dta", clear

gen restructuring = 0
replace restructuring = 1 if rca > 0 & !missing(rca)
replace restructuring = 1 if rcd > 0 & !missing(rcd)
replace restructuring = 1 if rceps > 0 & !missing(rceps)
replace restructuring = 1 if rcp > 0 & !missing(rcp)

gen year = fyear
gen GVKEY_TS = gvkey
destring GVKEY_TS, replace

sort GVKEY_TS year
egen numnonmiss = rownonmiss( rca rcd rceps rcp xrd)
gsort GVKEY_TS year -numnonmiss
gen keep = 0
by GVKEY_TS year: gen id = _n
replace keep = 1 if id==1
keep if keep==1

save "C:\Users\kverb\Dropbox (University of Michigan)\Gallo Tomy\Data\Final Datasets\Backup\WRDS pull - restructuring and RD expenses - processed.dta", replace

******* Merge restructuring and R&D vars into panel **********;

use "C:\Users\kverb\Dropbox (University of Michigan)\Gallo Tomy\Data\Final Datasets\monitor_violations.dta", clear

merge m:1 GVKEY_TS year using "C:\Users\kverb\Dropbox (University of Michigan)\Gallo Tomy\Data\Final Datasets\Backup\WRDS pull - restructuring and RD expenses - processed.dta", keepusing(at xrd restructuring) generate(rd_restructure_merge)

// Generate average total assets variable to scaled R&D expense
drop if rd_restructure_merge==2
gen at_lag1 = exp(size_lag1)
gen nonmisssizelag = 1
replace nonmisssizelag = 0 if missing(at_lag1)
gen nonmissat = 1
replace nonmissat = 0 if missing(at)
gen ata_denom = nonmisssizelag + nonmissat
gen ata_num = cond(missing(at),0,at) + cond(missing(at_lag1),0,at_lag1)
gen ata = ata_num/ata_denom
gen rd_scaled = xrd/ata
replace rd_scaled = 0 if missing(xrd)
winsor2 rd_scaled, by(year)
label variable rd_scaled_w "Scaled R&D - Winsorized"

************ Run tests with rd_scaled_w and restructuring as outcome **********;