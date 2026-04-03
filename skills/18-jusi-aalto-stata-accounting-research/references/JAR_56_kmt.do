import excel "all_base.xls", sheet("Full") firstrow
save base, replace

clear all
import excel "all_same.xls", sheet("Full") firstrow
save same, replace

clear all
import excel "all_sep.xls", sheet("Full") firstrow
save sep, replace

append using base, force
append using same

save all, replace

use all, clear

drop Auditor4TimesAccurateLag Auditor4TimesHiredLag Auditor4TimesInspectedLag Auditor4TimesPenaltyLag Bid5
drop if Period <6
drop if Period >20

gen cond =0
replace cond=1 if Condition == "Sep"
replace cond =2 if Condition =="Same"

bysort Session: egen ave_aq = mean(VerifierInvestigation)
bysort Session: egen ave_mi = mean(MgrInvestment)

gen c1a=0
replace c1a =-1 if cond==2
replace c1a =1 if cond==0
gen c2a=-1
replace c2a=2 if cond==1

gen MgrID = Session*100 + AssetNumber
gen AuditorID = Session*100 + AuditorHired
gen BuyerID = Session*100 + HighBidder
gen ConsultantID = Session*100 + ConsultantHired

gen base=0
replace base=1 if Condition == "Base"
gen same=0
replace same=1 if Condition =="Same"
gen sep=0
replace sep=1 if Condition =="Sep"

gen AuditorAccuracyPer = .
replace AuditorAccuracyPer = Auditor1TimesAccurateLag / Auditor1TimesHiredLag if AuditorHired == 1
replace AuditorAccuracyPer = Auditor2TimesAccurateLag / Auditor2TimesHiredLag if AuditorHired == 2
replace AuditorAccuracyPer = Auditor3TimesAccurateLag / Auditor3TimesHiredLag if AuditorHired == 3

gen repval =200
replace repval=400 if ReportedValue==1
replace repval=600 if ReportedValue==2
replace repval=800 if ReportedValue==3
replace repval=1000 if ReportedValue==4
replace repval=1200 if ReportedValue==5

gen Confidence = HighBid - repval

gen repval_center_0_800 = repval - 800 
summarize repval, meanonly
gen centered_repval = repval - r(mean)

summarize AuditorAccuracyPer, meanonly
gen centered_AudAccPer = AuditorAccuracyPer - r(mean)

summarize Period, meanonly
gen centered_Period = Period - r(mean)

save all_2, replace

*Table 1
mean VerifierInvestigation MgrInvestment MgrMisreport HighBid HighBidderEarned, over(Session)
mean ConsultantEffort, over(Session)
*Linked session to condition and organized columns by our audit quality measure (VerifierInvestigation) in excel.

*Table 2 - Panel A
duplicates drop Session, force
by cond, sort : summarize ave_aq

use all_2, clear

*Table 2 - Panel C
melogit VerifierInvestigation c1a c2a || Session: || AuditorID:
melogit VerifierInvestigation base same || Session: || AuditorID:
*Table 2 - Panel B
*From above Logit, Chi-2(2) = .88; .88/2 DFs = .44. P-value = .65

*Table 5 - Column 1
melogit MgrInvestment AuditorAccuracyPer || Session: || MgrID:

*Drop observations with maximum value assets as there is no potential to misreport
drop if TrueValue ==5
*Table 5 - Column 2
melogit MgrMisreport AuditorAccuracyPer || Session: || MgrID:

use all_2, clear

*Table 7 - Column 1
mixed Confidence c.centered_AudAccPer##c.repval_center_0_800 centered_Period || Session: || BuyerID: if repval !=200 & AuditorReport != 0
*Table 7 - Column 2
mixed Confidence c.centered_AudAccPer##c.repval_center_0_800 centered_Period sep same || Session: || BuyerID: if repval !=200 & AuditorReport != 0

use all, clear

gen MgrID = Session*100 + AssetNumber
gen AuditorID = Session*100 + AuditorHired
gen BuyerID = Session*100 + HighBidder
gen ConsultantID = Session*100 + ConsultantHired

*Set up Table 3
gen one = 1
sort AuditorID
by AuditorID: gen Count = sum(one)
bysort AuditorID: egen aa = max(Count)
by AuditorID: gen Aud_AQ_Count = sum(VerifierInvestigation)
bysort AuditorID: egen bb = max(Aud_AQ_Count)
gen Aud_AQ = bb / aa
sort ConsultantID Period
by ConsultantID: gen Cons_Count = sum(one)
bysort ConsultantID: egen cc = max(Cons_Count)
by ConsultantID: gen Cons_HE_Count = sum(ConsultantEffort)
bysort ConsultantID: egen dd = max(Cons_HE_Count)
gen Cons_Effort = dd / cc
bysort Session: gen decisions = sum(one)
bysort Session: egen max_hires = max(decisions)
bysort AuditorID: gen mktshr = aa/max_hires
bysort ConsultantID: gen c_mktshr = cc/max_hires
save temp1, replace

use temp1, clear
duplicates drop AuditorID, force
keep Session Condition AuditorID Aud_AQ mktshr
gsort Session -Aud_AQ
by Session: gen rank = _n
gsort Condition Session -aa
br
*Provides data for Table 3.


use temp1, clear
duplicates drop ConsultantID, force
drop if missing(ConsultantID)
keep Session Condition ConsultantID Cons_Effort c_mktshr
gsort Session -Cons_Effort
by Session: gen rank = _n
gsort Condition Session -aa
br

*Provides data for Table 3.
*Combine auditor and consultant information in excel.
*Note - Auditor 1 = Consultant 1, A2 = C2, and A3 = C3 in each session.

use all_2, clear
gen same_pref_hq_aud = 0
replace same_pref_hq_aud = 1 if Session == 9 | Session == 18 | Session == 1 | Session == 17
gen same_pref_lq_aud = 0
replace same_pref_lq_aud = 1 if Session == 5 | Session == 23 | Session == 11 | Session == 6

gen sep_pref_hq_aud = 0
replace sep_pref_hq_aud = 1 if Session == 19 | Session == 20 | Session == 3 | Session == 16
gen sep_pref_lq_aud = 0
replace sep_pref_lq_aud = 1 if Session == 22 | Session == 7 | Session == 14 | Session == 2

gen nas_pref_hq_aud = 0
replace nas_pref_hq_aud = 1 if same_pref_hq_aud == 1 | sep_pref_hq_aud == 1

gen nas_non_hq_aud = 0
replace nas_non_hq_aud = 1 if base == 0 & nas_pref_hq_aud == 0 

gen hq_cond = ""
replace hq_cond = "Base" if base
replace hq_cond = "NAS HQ" if nas_pref_hq_aud
replace hq_cond = "NAS Non-HQ" if nas_non_hq_aud

*Table 4 - Panel B
melogit VerifierInvestigation nas_pref_hq_aud nas_non_hq_aud || Session: || AuditorID:

*Table 6 - Panel B
melogit MgrInvestment nas_pref_hq_aud || Session: || MgrID:

*Table 4 - Panel A
duplicates drop Session, force
by hq_cond, sort : summarize ave_aq

*Table 6 - Panel A
by hq_cond, sort : summarize ave_mi
