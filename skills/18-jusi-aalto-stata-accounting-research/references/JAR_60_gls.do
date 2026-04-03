***********************************************************************************************************************************************
// Intangible investments, scaling, and the trend in the accrual-cash flow association
// Jeremiah Green, Henock Louis, and Jalal Sani

// This STATA code generates all tables presented in the paper and the online appendix.          																   ***
***********************************************************************************************************************************************


//Table 3A – Time-series trends and the effect of intangible intensity on the accrual-cash flow association using assets as deflator
clear all
use "..\Data\Annual_ACC_CFO.dta", clear 
cd "..\Tables"
keep time m_intangible_ave_at m_capx_ave_at std_intangible_ave_at std_lev m_intangible_ave_mve

label var m_intangible_ave_at "Intangible Intensity"
label var m_capx_ave_at "Tangible Intensity"
label var std_intangible_ave_at "STD Intangible"
label var std_lev "STD Leverage"
label var m_intangible_ave_mve "Intangible/MV"
label var time "Time"

global filea "T3A.xls"
global keepvar "time"

reg m_intangible_ave_at time, 
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) nonote replace dec(2) label

reg m_capx_ave_at time, 
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) nonote append dec(2) label

reg std_intangible_ave_at time, 
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) nonote append dec(2) label

reg std_lev time, 
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) nonote append dec(2) label


// Table 4A - Time-series trend in intangible investments and the effect of intangible intensity on the accrual-cash flow association using market value of equity as deflator    
global filea "T4A.xls"
global keepvar "time"

reg m_intangible_ave_mve time,  
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) nonote replace dec(2) label


clear all
use "..\Data\ACC_CFO.dta", clear 
cd "..\Tables"

set matsize 5000
gen     cfo_ave_at_time  =    cfo_ave_at*time 
gen mod_cfo_ave_at_time  =mod_cfo_ave_at*time 
gen     cfo_ave_ceq_time =    cfo_ave_ceq*time 
gen     cfo_ave_mve_time =    cfo_ave_mve*time 
gen mod_cfo_ave_mve_time =mod_cfo_ave_mve*time 
gen     cfo_ave_ceq_rd_time 	=     cfo_ave_ceq_rd*time
gen     cfo_ave_ceq_es_time 	=     cfo_ave_ceq_es*time
gen mod_cfo_ave_ceq_es_time 	= mod_cfo_ave_ceq_es*time
gen     ocfo_ave_at_time     =     ocfo_ave_at*time 
gen mod_ocfo_ave_at_time     = mod_ocfo_ave_at*time 
gen     ocfo_ave_ceq_time    =     ocfo_ave_ceq*time 
gen     ocfo_ave_mve_time    =     ocfo_ave_mve*time 
gen mod_ocfo_ave_mve_time    = mod_ocfo_ave_mve*time 
gen       es_cfo_ave_at_time=es_cfo_ave_at*time 
gen       es_cfo_ave_mve_time=es_cfo_ave_mve*time 
gen       es_ocfo_ave_mve_time=es_ocfo_ave_mve*time 
gen high_intan_cfo_ave_at=high_intan*cfo_ave_at
gen high_intan_mod_cfo_ave_mve=high_intan*mod_cfo_ave_mve
gen high_intan_time=high_intan*time 
gen high_intan_cfo_ave_at_time=high_intan*cfo_ave_at*time 
gen high_intan_mod_cfo_ave_mve_time=high_intan*mod_cfo_ave_mve*time
gen cfo_beg_mve_time=cfo_beg_mve*time 
gen cfo_end_mve_time=cfo_end_mve*time 
gen HighRisk_mod_cfo_ave_mve_time=HighRisk*mod_cfo_ave_mve*time
gen HighRisk_mod_cfo_ave_mve=HighRisk*mod_cfo_ave_mve
gen HighRisk_time=HighRisk*time 
gen lag_cfo_ave_at_time=lag_cfo_ave_at*time 
gen lag_cfo_ave_ceq_time=lag_cfo_ave_ceq*time 
gen lag_cfo_ave_mve_time=lag_cfo_ave_mve*time 
gen lag_mod_cfo_ave_at_time=lag_mod_cfo_ave_at*time 
gen lag_mod_cfo_ave_mve_time=lag_mod_cfo_ave_mve*time 
gen lead_cfo_ave_at_time=lead_cfo_ave_at*time 
gen lead_cfo_ave_ceq_time=lead_cfo_ave_ceq*time 
gen lead_cfo_ave_mve_time=lead_cfo_ave_mve*time 
gen lead_mod_cfo_ave_at_time=lead_mod_cfo_ave_at*time 
gen lead_mod_cfo_ave_mve_time=lead_mod_cfo_ave_mve*time 
gen loss_cfo_ave_at_time=loss*cfo_ave_at*time 
gen loss_cfo_ave_at=loss*cfo_ave_at
gen loss_mod_cfo_ave_mve_time=loss*mod_cfo_ave_mve*time
gen loss_mod_cfo_ave_mve=loss*mod_cfo_ave_mve
gen loss_time=loss*time 
gen LowRisk_mod_cfo_ave_mve_time=LowRisk*mod_cfo_ave_mve*time
gen LowRisk_mod_cfo_ave_mve=LowRisk*mod_cfo_ave_mve
gen LowRisk_time=LowRisk*time 
gen mod_cfo_beg_mve_time=mod_cfo_beg_mve*time 
gen mod_cfo_end_mve_time=mod_cfo_end_mve*time 
gen over_a3_mod_cfo_ave_mve_time=over_a3*mod_cfo_ave_mve*time
gen over_a3_mod_cfo_ave_mve=over_a3*mod_cfo_ave_mve
gen over_a3_time=over_a3*time 
gen over_a4_mod_cfo_ave_mve_time=over_a4*mod_cfo_ave_mve*time
gen over_a4_mod_cfo_ave_mve=over_a4*mod_cfo_ave_mve
gen over_a4_time=over_a4*time 
gen over_misp_mod_cfo_ave_mve_time=over_misp*mod_cfo_ave_mve*time
gen over_misp_mod_cfo_ave_mve=over_misp*mod_cfo_ave_mve
gen over_misp_time=over_misp*time 
gen high_pti_oi_cfo_ave_at_time=high_pti_oi*cfo_ave_at*time 
gen high_pti_oi_cfo_ave_at=high_pti_oi*cfo_ave_at
gen high_pti_oi_mod_cfo_ave_mve_time=high_pti_oi*mod_cfo_ave_mve*time
gen high_pti_oi_mod_cfo_ave_mve=high_pti_oi*mod_cfo_ave_mve
gen high_pti_oi_time=high_pti_oi*time 
gen under_a3_mod_cfo_ave_mve_time=under_a3*mod_cfo_ave_mve*time
gen under_a3_mod_cfo_ave_mve=under_a3*mod_cfo_ave_mve
gen under_a3_time=under_a3*time 
gen under_a4_mod_cfo_ave_mve_time=under_a4*mod_cfo_ave_mve*time
gen under_a4_mod_cfo_ave_mve=under_a4*mod_cfo_ave_mve
gen under_a4_time=under_a4*time 
gen under_misp_mod_cfo_ave_mve_time=under_misp*mod_cfo_ave_mve*time
gen under_misp_mod_cfo_ave_mve=under_misp*mod_cfo_ave_mve
gen under_misp_time=under_misp*time 

destring gvkey, generate(newgvkey) 
global cluster "fyear newgvkey"
global absorb "fyear newgvkey"

label var acc "ACC (in \$ Mil)"  
label var acc_ave_at       "ACC/Asset" 
label var acc_ave_ceq      "ACC/BE"
label var acc_ave_mve      "ACC/MV" 
label var acc_ave_ceq_rd   "ACC/Modified BE"
label var acc_ave_ceq_es   "ACC/Alt Modified BE"
label var adj_10yr_2yr_acc_ave_mve  "Modified ACC/MV"
label var adj_10yr_5yr_acc_ave_mve  "Modified ACC/MV"
label var adj_5yr_5yr_acc_ave_mve   "Modified ACC/MV"
label var adj_7yr_2yr_acc_ave_mve   "Modified ACC/MV"
label var adj_7yr_5yr_acc_ave_mve   "Modified ACC/MV"
label var intangible_amortization         "Intangible Amor (in \$ Mil)" 
label var intangible_amortization_ave_at  "Intangible Amor/Asset"
label var intangible_amortization_ave_mve "Intangible Amor/MV"
label var ave_at "Asset (in \$ Mil)" 
label var ave_mve "MV (in \$ Mil)" 
label var cfo "CFO (in \$ Mil)" 
label var cfo_ave_at      "CFO/Asset" 
label var cfo_ave_at_time "CFO/Asset * Time" 
label var cfo_ave_ceq              "CFO/BE"
label var cfo_ave_ceq_time         "CFO/BE * Time"
label var cfo_ave_ceq_es           "CFO/Alt Modified BE"
label var cfo_ave_ceq_es_time      "CFO/Alt Modified BE * Time"
label var cfo_ave_ceq_rd           "CFO/Modified BE"
label var cfo_ave_ceq_rd_time      "CFO/Modified BE * Time"
label var cfo_ave_ceq_time "CFO/BE * Time" 
label var cfo_ave_mve      "CFO/MV" 
label var cfo_ave_mve_time "CFO/MV * Time" 
label var es_acc_ave_at  "Alt Modified ACC/Asset" 
label var es_acc_ave_mve "Alt Modified ACC/MV" 
label var es_cfo_ave_at  	 "Alt Modified CFO/Asset" 
label var es_cfo_ave_at_time "Alt Modified CFO/Asset * Time" 
label var es_cfo_ave_ceq_es      "Alt Modified CFO/Alt Modified BE"
label var es_cfo_ave_mve      "Alt Modified CFO/MV" 
label var es_cfo_ave_mve_time "Alt Modified CFO/MV * Time" 
label var es_ocfo_ave_mve      "Alt Modified OCFO/MV" 
label var es_ocfo_ave_mve_time "Alt Modified OCFO/MV * Time" 
label var HighRisk_mod_cfo_ave_mve      "Modified CFO/MV * High Risk"
label var HighRisk_mod_cfo_ave_mve_time "Modified CFO/MV * High Risk * Time"
label var lag_cfo_ave_at      "Lag CFO/Asset" 
label var lag_cfo_ave_at_time "Lag CFO/Asset * Time"
label var lag_cfo_ave_ceq      "Lag CFO/BE" 
label var lag_cfo_ave_ceq_time "Lag CFO/BE * Time"
label var lag_cfo_ave_mve      "Lag CFO/MV" 
label var lag_cfo_ave_mve_time "Lag CFO/MV * Time"
label var lag_mod_cfo_ave_at      "Lag Modified CFO/Asset"
label var lag_mod_cfo_ave_at_time "Lag Modified CFO/Asset * Time"
label var lag_mod_cfo_ave_mve      "Lag Modified CFO/MV" 
label var lag_mod_cfo_ave_mve_time "Lag Modified CFO/MV * Time"
label var lead_cfo_ave_at      "Lead CFO/Asset" 
label var lead_cfo_ave_at_time "Lead CFO/Asset * Time"
label var lead_cfo_ave_ceq      "Lead CFO/BE" 
label var lead_cfo_ave_ceq_time "Lead CFO/BE * Time"
label var lead_cfo_ave_mve      "Lead CFO/MV"
label var lead_cfo_ave_mve_time "Lead CFO/MV * Time"
label var lead_mod_cfo_ave_at      "Lead Modified CFO/Asset"
label var lead_mod_cfo_ave_at_time "Lead Modified CFO/Asset * Time"
label var lead_mod_cfo_ave_mve      "Lead Modified CFO/MV" 
label var lead_mod_cfo_ave_mve_time "Lead Modified CFO/MV * Time  "
label var loss "Loss"
label var loss_cfo_ave_at      "CFO/Asset * Loss"
label var loss_cfo_ave_at_time "CFO/Asset * Loss * Time"
label var loss_mod_cfo_ave_mve      "Modified CFO/MV * Loss"
label var loss_mod_cfo_ave_mve_time "Modified CFO/MV * Loss * Time"
label var loss_time "Loss * Time"
label var LowRisk_mod_cfo_ave_mve      "Modified CFO/MV * Low Risk"
label var LowRisk_mod_cfo_ave_mve_time "Modified CFO/MV * Low Risk * Time"
label var mod_acc         "Modified ACC (in \$ Mil)"
label var mod_acc_ave_at  "Modified ACC/Asset" 
label var mod_acc_ave_ceq_es  "Modified ACC/Alt Modified BE"
label var mod_acc_ave_mve "Modified ACC/MV" 
label var mod_cfo             "Modified CFO (in \$ Mil)"
label var mod_cfo_ave_at      "Modified CFO/Asset" 
label var mod_cfo_ave_at_time "Modified CFO/Asset * Time" 
label var mod_cfo_ave_ceq     "Modified CFO/BE"
label var mod_cfo_ave_ceq_es      "Modified CFO/Alt Modified BE"
label var mod_cfo_ave_ceq_es_time "Modified CFO/Alt Modified BE * Time"
label var mod_cfo_ave_ceq_rd      "Modified CFO/Modified BE"
label var mod_cfo_ave_mve      "Modified CFO/MV" 
label var mod_cfo_ave_mve_time "Modified CFO/MV * Time" 
label var mod_oacc_ave_at  "Modified OACC/Asset" 
label var mod_oacc_ave_mve "Modified OACC/MV" 
label var mod_ocfo_ave_at      "Modified OCFO/Asset" 
label var mod_ocfo_ave_at_time "Modified OCFO/Asset * Time" 
label var mod_ocfo_ave_ceq_es  "Modified OCFO/Alt Modified BE" 
label var mod_ocfo_ave_mve      "Modified OCFO/MV" 
label var mod_ocfo_ave_mve_time "Modified OCFO/MV * Time" 
label var oacc_ave_at  "OACC/Asset" 
label var oacc_ave_ceq "OACC/BE" 
label var oacc_ave_mve "OACC/MV" 
label var ocfo_ave_at      "OCFO/Asset" 
label var ocfo_ave_at_time "OCFO/Asset * Time" 
label var ocfo_ave_ceq      "OCFO/BE" 
label var ocfo_ave_ceq_time "OCFO/BE * Time" 
label var ocfo_ave_mve      "OCFO/MV" 
label var ocfo_ave_mve_time "OCFO/MV * Time" 
label var over_a3_mod_cfo_ave_mve      "Modified CFO/MV * Overpriced_Alpha"
label var over_a3_mod_cfo_ave_mve_time "Modified CFO/MV * Overpriced_Alpha * Time"
label var over_a4_mod_cfo_ave_mve      "Modified CFO/MV * Overpriced_Alpha"
label var over_a4_mod_cfo_ave_mve_time "Modified CFO/MV * Overpriced_Alpha * Time"
label var over_misp_mod_cfo_ave_mve      "Modified CFO/MV * Overpriced_MISP"
label var over_misp_mod_cfo_ave_mve_time "Modified CFO/MV * Overpriced_MISP * Time"
label var high_intan_cfo_ave_at      "CFO/Asset * High Intangible"
label var high_intan_cfo_ave_at_time "CFO/Asset * High Intangible * Time"
label var high_intan_mod_cfo_ave_mve      "Modified CFO/MV * High Intangible"
label var high_intan_mod_cfo_ave_mve_time "Modified CFO/MV * High Intangible * Time"
label var high_pti_oi      "High PTI-OI"
label var high_pti_oi_time "High PTI-OI * Time"
label var high_pti_oi_cfo_ave_at      "CFO/Asset * High PTI-OI"
label var high_pti_oi_cfo_ave_at_time "CFO/Asset * High PTI-OI * Time"
label var high_pti_oi_mod_cfo_ave_mve      "Modified CFO/MV * High PTI-OI"
label var high_pti_oi_mod_cfo_ave_mve_time "Modified CFO/MV * High PTI-OI * Time"
label var high_intan      "High Intangible"
label var high_intan_time "High Intangible * Time"
label var intangible         "Intangible (in \$ Mil)"
label var intangible_ave_at  "Intangible/Asset"
label var intangible_ave_mve "Intangible/MV"
label var under_a3_mod_cfo_ave_mve      "Modified CFO/MV * Underpriced_Alpha"
label var under_a3_mod_cfo_ave_mve_time "Modified CFO/MV * Underpriced_Alpha * Time"
label var under_a4_mod_cfo_ave_mve      "Modified CFO/MV * Underpriced_Alpha"
label var under_a4_mod_cfo_ave_mve_time "Modified CFO/MV * Underpriced_Alpha * Time"
label var under_misp_mod_cfo_ave_mve      "Modified CFO/MV * Underpriced_MISP"
label var under_misp_mod_cfo_ave_mve_time "Modified CFO/MV * Underpriced_MISP * Time"


/*Table 1: Summary statistics*/
global keepvar1 "acc_ave_at cfo_ave_at mod_acc_ave_at mod_cfo_ave_at acc_ave_mve cfo_ave_mve mod_acc_ave_mve mod_cfo_ave_mve"
global keepvar2 "intangible_ave_at intangible_amortization_ave_at intangible_ave_mve intangible_amortization_ave_mve acc cfo mod_acc mod_cfo ave_at ave_mve"
global keepvar "$keepvar1 $keepvar2"

outreg2 using T1.xls, replace sum(detail) eqkeep(mean sd p25 p50 p75) title(Summary Statistics) ///
sortvar($keepvar) label dec(2) keep($keepvar)


//Table 2 – Time trend in the accrual-cash flow association with and without adjustments
global keepvar1 "     cfo_ave_at      mod_cfo_ave_at      cfo_ave_ceq      cfo_ave_mve      mod_cfo_ave_mve     "
global keepvar2 "time cfo_ave_at_time mod_cfo_ave_at_time cfo_ave_ceq_time cfo_ave_mve_time mod_cfo_ave_mve_time"
global keepvar "$keepvar1 $keepvar2 "

global filea "T2.xls"

reghdfe acc_ave_at cfo_ave_at cfo_ave_at_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe mod_acc_ave_at mod_cfo_ave_at mod_cfo_ave_at_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe acc_ave_ceq cfo_ave_ceq cfo_ave_ceq_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe acc_ave_mve cfo_ave_mve cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_acc_ave_mve mod_cfo_ave_mve mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label



//Table 3B – Time-series trends and the effect of intangible intensity on the accrual-cash flow association using assets as deflator    

global keepvar "cfo_ave_at high_intan high_intan_cfo_ave_at"

global filea "T3B.xls"
reghdfe acc_ave_at cfo_ave_at high_intan high_intan_cfo_ave_at, absorb($cluster) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label


// Table 4B - Time-series trend in intangible investments and the effect of intangible intensity on the accrual-cash flow association using market value of equity as deflator    

global keepvar "mod_cfo_ave_mve high_intan high_intan_mod_cfo_ave_mve"
global filea "T4B.xls"

reghdfe mod_acc_ave_mve mod_cfo_ave_mve high_intan high_intan_mod_cfo_ave_mve, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label



// Table 5 – Overall accrual-cash ﬂow association with and without adjustments

global keepvar " cfo_ave_at mod_cfo_ave_at cfo_ave_ceq cfo_ave_mve mod_cfo_ave_mve"
global filea "T5.xls"

reghdfe acc_ave_at cfo_ave_at , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe mod_acc_ave_at mod_cfo_ave_at, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe acc_ave_ceq cfo_ave_ceq, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe acc_ave_mve cfo_ave_mve, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_acc_ave_mve mod_cfo_ave_mve, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label



//  Table 6A – Accrual-cash ﬂow association: Using alternative book value deflators  

global keepvar "cfo_ave_at cfo_ave_ceq cfo_ave_ceq_rd cfo_ave_ceq_es mod_cfo_ave_ceq_es"


global filea "T6A.xls"

reghdfe acc_ave_at cfo_ave_at , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe     acc_ave_ceq          cfo_ave_ceq         , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe     acc_ave_ceq_rd       cfo_ave_ceq_rd  , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe     acc_ave_ceq_es       cfo_ave_ceq_es  , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_acc_ave_ceq_es   mod_cfo_ave_ceq_es  , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,    stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label



//  Table 6B – Accrual-cash ﬂow association: Using alternative book value deflators  

global keepvar1 "cfo_ave_at        cfo_ave_ceq      cfo_ave_ceq_rd      cfo_ave_ceq_es      mod_cfo_ave_ceq_es      "
global keepvar2 "cfo_ave_at_time   cfo_ave_ceq_time cfo_ave_ceq_rd_time cfo_ave_ceq_es_time mod_cfo_ave_ceq_es_time "
global keepvar "$keepvar1 $keepvar2"


global filea "T6B.xls"
reghdfe acc_ave_at cfo_ave_at cfo_ave_at_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe     acc_ave_ceq          cfo_ave_ceq         cfo_ave_ceq_time   , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe     acc_ave_ceq_rd       cfo_ave_ceq_rd      cfo_ave_ceq_rd_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe     acc_ave_ceq_es       cfo_ave_ceq_es      cfo_ave_ceq_es_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_acc_ave_ceq_es   mod_cfo_ave_ceq_es  mod_cfo_ave_ceq_es_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,    stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label




//Online Appendix

// Table A1 – Using the same accruals and cash flows measures over time

global keepvar1 "     ocfo_ave_at      mod_ocfo_ave_at      ocfo_ave_ceq      ocfo_ave_mve      mod_ocfo_ave_mve     "
global keepvar2 "time ocfo_ave_at_time mod_ocfo_ave_at_time ocfo_ave_ceq_time ocfo_ave_mve_time mod_ocfo_ave_mve_time"
global keepvar "$keepvar1 $keepvar2"

global filea "TA1.xls"

reghdfe oacc_ave_at ocfo_ave_at ocfo_ave_at_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe mod_oacc_ave_at mod_ocfo_ave_at mod_ocfo_ave_at_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe oacc_ave_ceq ocfo_ave_ceq ocfo_ave_ceq_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe oacc_ave_mve ocfo_ave_mve ocfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_oacc_ave_mve mod_ocfo_ave_mve mod_ocfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label




// Table A2A - Cash flow statement approach to measuring accruals and cash flows

global keepvar "cfo_ave_at mod_cfo_ave_at cfo_ave_ceq cfo_ave_mve mod_cfo_ave_mve"
global filea "TA2A.xls"

reghdfe acc_ave_at cfo_ave_at if fyear>1987, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe mod_acc_ave_at mod_cfo_ave_at if fyear>1987, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe acc_ave_ceq cfo_ave_ceq if fyear>1987, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe acc_ave_mve cfo_ave_mve if fyear>1987, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_acc_ave_mve mod_cfo_ave_mve if fyear>1987, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label


// Table A2B - Cash flow statement approach to measuring accruals and cash flows

global keepvar1 "     cfo_ave_at      mod_cfo_ave_at      cfo_ave_ceq      cfo_ave_mve      mod_cfo_ave_mve     "
global keepvar2 "time cfo_ave_at_time mod_cfo_ave_at_time cfo_ave_ceq_time cfo_ave_mve_time mod_cfo_ave_mve_time"
global keepvar "$keepvar1 $keepvar2 "

global filea "TA2B.xls"

reghdfe acc_ave_at cfo_ave_at cfo_ave_at_time if fyear>1987, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe mod_acc_ave_at mod_cfo_ave_at mod_cfo_ave_at_time if fyear>1987, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe acc_ave_ceq cfo_ave_ceq cfo_ave_ceq_time if fyear>1987, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe acc_ave_mve cfo_ave_mve cfo_ave_mve_time if fyear>1987, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_acc_ave_mve mod_cfo_ave_mve mod_cfo_ave_mve_time if fyear>1987, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,   stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label




// Table A3 - Alternative useful lives

global keepvar "mod_cfo_ave_mve mod_cfo_ave_mve_time"
global filea "TA3.xls"

// 10_5
reghdfe adj_10yr_5yr_acc_ave_mve mod_cfo_ave_mve mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

// 10_2
reghdfe adj_10yr_2yr_acc_ave_mve mod_cfo_ave_mve mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

// 7_5
reghdfe adj_7yr_5yr_acc_ave_mve mod_cfo_ave_mve mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

// 7_2
reghdfe adj_7yr_2yr_acc_ave_mve mod_cfo_ave_mve mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

// 5_5
reghdfe adj_5yr_5yr_acc_ave_mve mod_cfo_ave_mve mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label



// Table A4 – Alternative numerator adjustment

global keepvar_ "cfo_ave_at es_cfo_ave_at cfo_ave_mve es_cfo_ave_mve cfo_ave_at_time  es_cfo_ave_at_time cfo_ave_mve_time es_cfo_ave_mve_time"
global filea "TA4.xls"

reghdfe        acc_ave_at               cfo_ave_at            cfo_ave_at_time if es_cfo_ave_mve~=., absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar_) keep($keepvar_) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe es_acc_ave_at        es_cfo_ave_at         es_cfo_ave_at_time   , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar_) keep($keepvar_) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe        acc_ave_mve        cfo_ave_mve     cfo_ave_mve_time if es_cfo_ave_mve~=., absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar_) keep($keepvar_) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe es_acc_ave_mve es_cfo_ave_mve es_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar_) keep($keepvar_) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label




// Table A5 - Accrual-cash flow association: Mechanical association due to numerator adjustments
global keepvar1 "mod_cfo_ave_at      mod_cfo_ave_mve           es_cfo_ave_mve      mod_ocfo_ave_at      mod_ocfo_ave_mve        es_ocfo_ave_mve     "
global keepvar2 "mod_cfo_ave_at_time mod_cfo_ave_mve_time      es_cfo_ave_mve_time mod_ocfo_ave_at_time mod_ocfo_ave_mve_time   es_ocfo_ave_mve_time"

global keepvar "$keepvar1 $keepvar2"

global filea "TA5.xls"
reghdfe     acc_ave_at mod_cfo_ave_at mod_cfo_ave_at_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe     acc_ave_mve mod_cfo_ave_mve mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe    acc_ave_mve es_cfo_ave_mve es_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe    oacc_ave_at mod_ocfo_ave_at mod_ocfo_ave_at_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe    oacc_ave_mve mod_ocfo_ave_mve mod_ocfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe    oacc_ave_mve es_ocfo_ave_mve es_ocfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label



// Table A6 – Potential alternative explanations

global keepvar "cfo_ave_at mod_cfo_ave_mve loss_cfo_ave_at high_pti_oi_cfo_ave_at high_intan_cfo_ave_at loss_mod_cfo_ave_mve high_pti_oi_mod_cfo_ave_mve high_intan_mod_cfo_ave_mve cfo_ave_at_time loss_cfo_ave_at_time high_pti_oi_cfo_ave_at_time high_intan_cfo_ave_at_time mod_cfo_ave_mve_time loss_mod_cfo_ave_mve_time high_pti_oi_mod_cfo_ave_mve_time high_intan_mod_cfo_ave_mve_time"

global filea "TA6.xls"

reghdfe     acc_ave_at      cfo_ave_at  loss          loss_time          loss_cfo_ave_at            cfo_ave_at_time   loss_cfo_ave_at_time          , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe     acc_ave_at      cfo_ave_at  high_pti_oi   high_pti_oi_time   high_pti_oi_cfo_ave_at      cfo_ave_at_time   high_pti_oi_cfo_ave_at_time    , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe     acc_ave_at      cfo_ave_at  high_intan    high_intan_time    high_intan_cfo_ave_at       cfo_ave_at_time   high_intan_cfo_ave_at_time     , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_acc_ave_mve mod_cfo_ave_mve loss          loss_time         loss_mod_cfo_ave_mve        mod_cfo_ave_mve_time  loss_mod_cfo_ave_mve_time      , absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_acc_ave_mve mod_cfo_ave_mve high_pti_oi   high_pti_oi_time  high_pti_oi_mod_cfo_ave_mve mod_cfo_ave_mve_time  high_pti_oi_mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_acc_ave_mve mod_cfo_ave_mve high_intan    high_intan_time   high_intan_mod_cfo_ave_mve  mod_cfo_ave_mve_time  high_intan_mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label





// Table A7 – The effect of mispricing and risk on the time trend in the accrual-cash flow association

global filea "TA7.xls"

global keepvar "mod_cfo_ave_mve mod_cfo_ave_mve_time over_misp_mod_cfo_ave_mve under_misp_mod_cfo_ave_mve over_misp_mod_cfo_ave_mve_time under_misp_mod_cfo_ave_mve_time"

reghdfe mod_acc_ave_mve mod_cfo_ave_mve over_misp under_misp mod_cfo_ave_mve_time  over_misp_time under_misp_time over_misp_mod_cfo_ave_mve under_misp_mod_cfo_ave_mve over_misp_mod_cfo_ave_mve_time under_misp_mod_cfo_ave_mve_time if fyear<=2016, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar)  addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

global keepvar "mod_cfo_ave_mve mod_cfo_ave_mve_time over_a3_mod_cfo_ave_mve   under_a3_mod_cfo_ave_mve   over_a3_mod_cfo_ave_mve_time under_a3_mod_cfo_ave_mve_time "

reghdfe mod_acc_ave_mve mod_cfo_ave_mve over_a3   under_a3   mod_cfo_ave_mve_time  over_a3_time   under_a3_time   over_a3_mod_cfo_ave_mve   under_a3_mod_cfo_ave_mve    over_a3_mod_cfo_ave_mve_time  under_a3_mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

global keepvar "mod_cfo_ave_mve mod_cfo_ave_mve_time HighRisk_mod_cfo_ave_mve LowRisk_mod_cfo_ave_mve HighRisk_mod_cfo_ave_mve_time LowRisk_mod_cfo_ave_mve_time"

reghdfe mod_acc_ave_mve mod_cfo_ave_mve HighRisk LowRisk  mod_cfo_ave_mve_time  HighRisk_time LowRisk_time HighRisk_mod_cfo_ave_mve LowRisk_mod_cfo_ave_mve HighRisk_mod_cfo_ave_mve_time LowRisk_mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label





// Table A8 - Time trend in the accrual-cash flow association using the Dechow and Dichev model
global keepvar1 "lag_cfo_ave_at cfo_ave_at lead_cfo_ave_at lag_mod_cfo_ave_at mod_cfo_ave_at lead_mod_cfo_ave_at lag_cfo_ave_ceq cfo_ave_ceq lead_cfo_ave_ceq lag_cfo_ave_mve cfo_ave_mve lead_cfo_ave_mve lag_mod_cfo_ave_mve mod_cfo_ave_mve lead_mod_cfo_ave_mve"
global keepvar2 "lag_cfo_ave_at_time cfo_ave_at_time lead_cfo_ave_at_time lag_mod_cfo_ave_at_time mod_cfo_ave_at_time lead_mod_cfo_ave_at_time lag_cfo_ave_ceq_time cfo_ave_ceq_time lead_cfo_ave_ceq_time lag_cfo_ave_mve_time cfo_ave_mve_time lead_cfo_ave_mve_time lag_mod_cfo_ave_mve_time mod_cfo_ave_mve_time lead_mod_cfo_ave_mve_time"
global keepvar "$keepvar1 $keepvar2"

global filea "TA8.xls"
reghdfe acc_ave_at lag_cfo_ave_at cfo_ave_at lead_cfo_ave_at lag_cfo_ave_at_time cfo_ave_at_time lead_cfo_ave_at_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote replace dec(2) label

reghdfe mod_acc_ave_at lag_mod_cfo_ave_at mod_cfo_ave_at lead_mod_cfo_ave_at lag_mod_cfo_ave_at_time mod_cfo_ave_at_time lead_mod_cfo_ave_at_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe acc_ave_ceq lag_cfo_ave_ceq cfo_ave_ceq lead_cfo_ave_ceq lag_cfo_ave_ceq_time cfo_ave_ceq_time lead_cfo_ave_ceq_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe acc_ave_mve lag_cfo_ave_mve cfo_ave_mve lead_cfo_ave_mve lag_cfo_ave_mve_time cfo_ave_mve_time lead_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label

reghdfe mod_acc_ave_mve lag_mod_cfo_ave_mve mod_cfo_ave_mve lead_mod_cfo_ave_mve lag_mod_cfo_ave_mve_time mod_cfo_ave_mve_time lead_mod_cfo_ave_mve_time, absorb($absorb) vce(cluster $cluster) keepsin
outreg2 using $filea,  stats(coef tstat) sortvar($keepvar) keep($keepvar) ///
addtext(Firm & Year FEs, Yes, Firm & Year Cluster, Yes) nocons nonote append dec(2) label
