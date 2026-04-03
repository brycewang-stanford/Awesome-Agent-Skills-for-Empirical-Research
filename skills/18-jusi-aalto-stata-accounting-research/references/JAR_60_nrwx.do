*sample: 1,966 tranches from 586 ABS deals
*generate deal-level variables
*mtg_deal_name: deal name
*mtg_cmo_class: tranche name
*mdy(sp, fitch)_initial_scale22: the numerical rating of moody's (s&p, fitch) of a tranche, (=1 if rating=AAA(Aaa)...)
*cpn_typ: coupon type
*cpn: coupon rate
*mtg_orig_amt: tranche size 
*mtg_orig_wal: weighted average life of a tranche
*sec_type: security type
*issue_date: the issuance date of a deal
gen     ari=mdy_initial_scale22   if mdy_initial_scale22!=. & sp_initial_scale22==. & fitch_initial_scale22==.
replace ari=sp_initial_scale22    if mdy_initial_scale22==. & sp_initial_scale22!=. & fitch_initial_scale22==.
replace ari=fitch_initial_scale22 if mdy_initial_scale22==. & sp_initial_scale22==. & fitch_initial_scale22!=.
replace ari=(sp_initial_scale22+mdy_initial_scale22)/2    if mdy_initial_scale22!=. & sp_initial_scale22!=. & fitch_initial_scale22==.
replace ari=(fitch_initial_scale22+mdy_initial_scale22)/2 if mdy_initial_scale22!=. & sp_initial_scale22==. & fitch_initial_scale22!=.
replace ari=(sp_initial_scale22+fitch_initial_scale22)/2  if mdy_initial_scale22==. & sp_initial_scale22!=. & fitch_initial_scale22!=.
replace ari=(sp_initial_scale22+fitch_initial_scale22+mdy_initial_scale22)/3  if mdy_initial_scale22!=. & sp_initial_scale22!=. & fitch_initial_scale22!=.
gen     floating=1 if cpn_typ=="FLOATING"
replace floating=0 if cpn_typ!="FLOATING"
gen     spread_orig=cpn-rf         if cpn_typ!="FLOATING"
replace spread_orig=flt_spread/100 if cpn_typ=="FLOATING"
gen tranche_size=ln(mtg_orig_amt)
gen     nrating_tranche=1 if mdy_initial_scale22==. & sp_initial_scale22==. & fitch_initial_scale22!=.
replace nrating_tranche=1 if mdy_initial_scale22!=. & sp_initial_scale22==. & fitch_initial_scale22==.
replace nrating_tranche=1 if mdy_initial_scale22==. & sp_initial_scale22!=. & fitch_initial_scale22==.
replace nrating_tranche=2 if mdy_initial_scale22!=. & sp_initial_scale22!=. & fitch_initial_scale22==.
replace nrating_tranche=2 if mdy_initial_scale22!=. & sp_initial_scale22==. & fitch_initial_scale22!=.
replace nrating_tranche=2 if mdy_initial_scale22==. & sp_initial_scale22!=. & fitch_initial_scale22!=.
replace nrating_tranche=3 if mdy_initial_scale22!=. & sp_initial_scale22!=. & fitch_initial_scale22!=.
gen s1=spread_orig *mtg_orig_amt
gen s2=ari         *mtg_orig_amt
gen s3=mtg_orig_wal*mtg_orig_amt
bys mtg_deal_name: egen sum1=sum(s1)
bys mtg_deal_name: egen sum2=sum(s2)
bys mtg_deal_name: egen sum3=sum(s3)
bys mtg_deal_name: egen dealsize=sum(mtg_orig_amt)
gen spread_vw=sum1/dealsize
gen ari_vw   =sum2/dealsize
gen wal_vw   =sum3/dealsize
drop s1 s2 s3 sum1 sum2 sum3
gen s1=mtg_orig_amt if floating==1
bys mtg_deal_name: egen sum=sum(s1)
gen float_pert=sum/dealsize
drop s1 sum
bys mtg_deal_name: egen s1=sum(mdy_initial_scale22)
bys mtg_deal_name: egen s2=sum(fitch_initial_scale22)
bys mtg_deal_name: egen s3=sum(sp_initial_scale22)
replace s1=1 if s1>=1
replace s2=1 if s2>=1
replace s3=1 if s3>=1
gen nrating=s1+s2+s3
drop s1 s2 s3
bys mtg_deal_name: egen ntranche=count(mtg_cmo_class)
keep mtg_deal_name issue_date sec_type id_issuer spread_vw ari_vw dealsize wal_vw float_pert nrating ntranche 
duplicates drop
gen log_amt=ln(dealsize)
gen y=year(issue_date)
gen q=quarter(issue_date)
gen yq_issue=yq(y,q)
format yq %tq
egen fe_sec_type=group(sec_type)
egen fe_q_type=group(yq_issue sec_type)
gen treat=1     if sec_type=="AUTO"
replace treat=0 if sec_type!="AUTO"
gen post=1 if issue_date>=20781
replace post=0 if issue_date<20781
gen spread_treat     =spread_vw*treat
gen spread_post      =spread_vw*post
gen spread_treat_post=spread_vw*treat*post
gen ari_treat     =ari_vw*treat
gen ari_post      =ari_vw*post
gen ari_treat_post=ari_vw*treat*post
gen treat_post=treat*post
gen post_pseudo=1 if issue_date>20051 & post==0
replace post_pseudo=0 if issue_date<=20051 
gen spread_post_pseudo=spread_vw*post_pseudo
gen spread_treat_post_pseudo=spread_vw*treat*post_pseudo
gen ari_post_pseudo=ari_vw*post_pseudo
gen ari_treat_post_pseudo=ari_vw*treat*post_pseudo
gen treat_post_pseudo=treat*post_pseudo
gen     complex=0 if ntranche<=5 & type=="AUTO"
replace complex=1 if ntranche>5 & type=="AUTO"
*5 is the median of ntranche of auto ABS
save deal,replace

*calculate deal-level default rate
*net_loss: net loss in each month
*cum_loss: cumumlative losses over time
*deal_balance: the deal balance in each month
*orig_deal_balance: the deal balance at issuance
*t: each year-month minus origination year-month

*all ABS except for credit card ABS 
egen group=group(mtg_deal_name)
tsset group t
bys group: gen cum_loss2=sum(net_loss)
replace cum_loss=cum_loss2 if cum_loss==.
bys group: gen sum=sum(deal_balance)
bys group: gen no=_n
gen deal_balance_avg=sum/no
replace orig_deal_balance=deal_balance_avg if orig_deal_balance==.
drop cum_loss2 sum no deal_balance_avg
gen cum_loss_pct=cum_loss/orig_deal_balance*100 
gen s1=issue_date+183
*gen s1=issue_date+121
*gen s1=issue_date+244
gen dif=abs(date-s1)
bys mtg: egen min=min(dif)
keep if min==dif
bys mtg: egen max=max(t)
keep if max==t
tsset group
*gen delq_60plus_pct=delq60plus/orig_deal_balance*100
*gen delq_90plus_pct=delq90plus/orig_deal_balance*100
keep mtg_deal_name cum_loss_pct
save temp_1,replace

*credit card ABS
egen group=group(mtg_deal_name)
tsset group t
gen net_loss=charge_off_dollar
bys group: gen cum_loss   =sum(net_loss)
bys group: gen cum_balance=sum(pool_balance_dollar)
gen cum_loss_pct=cum_loss/cum_balance*100
gen s1=issue_date+183
*gen s1=issue_date+121
*gen s1=issue_date+244
gen dif=abs(date-s1)
bys mtg: egen min=min(dif)
keep if min==dif
bys mtg: egen max=max(t)
keep if max==t
tsset group
keep mtg_deal_name cum_loss_pct delq_60plus_pct delq_90plus_pct
append using temp_1
save default,replace

use deal
merge 1:1 mtg_deal_name using default 
drop _merge
save deal,replace

*calculate risk layering at the loan level
*based on abs-ee data of 108 auto deals
gen size=reportingperiodactualendbalancea
replace size=reportingperiodendingactualbalan if size==.
gen     fico=obligorcreditscore
replace fico=lesseecreditscore if fico==.
replace fico=900 if fico>900 & fico!=.
replace fico=. if fico==0
gen fico_miss=1 if fico==.
replace fico=. if fico<300
gen s1=fico*size
gen s2=size if s1!=.
bys mtg_deal_name: egen sum1=sum(s1)
bys mtg_deal_name: egen sum2=sum(s2)
gen fico_vw=sum1/sum2
drop s1 s2 sum1 sum2
gen     ltv= originalloanamount/vehiclevalueamount
replace ltv= acquisitioncost   /vehiclevalueamount if ltv==.
replace ltv=2 if ltv>2 & ltv!=.
*set a cap for outliers obs: there are 680 loans with ltv>2, accounting for 0.01% of loans with ltv. 
gen s1=ltv*size
gen s2=size if s1!=.
bys mtg_deal_name: egen sum1=sum(s1)
bys mtg_deal_name: egen sum2=sum(s2)
gen ltv_vw=sum1/sum2
drop s1 s2 sum1 sum2
gen ats=totalactualamountpaid/reportingperiodscheduledpaymenta if totalactualamountpaid>=0
replace ats=10 if ats>10 & ats!=.
*set a cap for outliers obs: there are 16,430 loans with ats>10, accounting for 0.3% of loans with ats
gen actpay_miss=1 if mtg_deal_name=="drive 2018-4" | mtg_deal_name=="drive 2018-5" | mtg_deal_name=="sdart 2018-5"
*ats is 0 for all loans in three deals because actualamountpaid is 0. 
gen s1=ats*size
gen s2=size if s1!=.
bys mtg_deal_name: egen sum1=sum(s1)
bys mtg_deal_name: egen sum2=sum(s2)
gen ats_vw=sum1/sum2
drop s1 s2 sum1 sum2
replace paymenttoincomepercentage=.  if paymenttoincomepercentage==0
gen     p2i=paymenttoincomepercentage
replace p2i=15 if p2i>15 & p2i!=.
*set a cap for outliers obs: there are 32,279 loans with p2i>15, accounting for 0.5% of loans with p2i
gen s1=p2i*size
gen s2=size if s1!=.
bys mtg_deal_name: egen sum1=sum(s1)
bys mtg_deal_name: egen sum2=sum(s2)
gen p2i_vw=sum1/sum2
drop s1 s2 sum1 sum2
gen     low_doc=0 if lesseeincomeverificationlevelcod!=. | lesseeemploymentverificationcode!=. | obligorincomeverificationlevelco!=. | obligoremploymentverificationcod!=. 
replace low_doc=1 if lesseeincomeverificationlevelcod==1
replace low_doc=1 if lesseeemploymentverificationcode==1
replace low_doc=1 if obligorincomeverificationlevelco==1
replace low_doc=1 if obligoremploymentverificationcod==1
replace low_doc=1 if fico_miss==1
sum low_doc if mtg_deal_name=="narot 2017-b"
sum low_doc if mtg_deal_name=="narot 2017-a"
sum low_doc if mtg_deal_name=="narot 2017-c"
sum low_doc if mtg_deal_name=="narot 2018-a"
*"narot 2017-b" is the only deal with the low_doc variable being missing for all loans  
*we check all other deals from the same series and find all of them have "0" value in low_doc for all loans
*so we replace low-doc to be zero for "narot 2017-b"
replace low_doc=0 if mtg_deal_name=="narot 2017-b"
gen s1=size if low_doc==1
gen s2=size if low_doc!=.
bys mtg_deal_name: egen sum1=sum(s1)
bys mtg_deal_name: egen sum2=sum(s2)
gen low_doc_vw=sum1/sum2
drop s1 s2 sum1 sum2
save abs_ee,replace
keep mtg_deal_name fico_vw ltv_vw ats_vw p2i_vw low_doc_vw 
duplicates drop
replace ats_vw=0.829676 if actpay_miss==1
*for the three deals with ats value of 0 for all loans, we replace their average with the average ats_vw of other deals issued by the same issuer in the same year before these deals.
save control,replace

use abs_ee
*risk layers built on fico, ltv, p2i, low_doc, ats
gen     r1=1 if fico<=642 & fico!=.
replace r1=0 if fico!=. & r1==.
*642 is the 25th percentile
gen     r2=1 if ltv>=1.128116 & ltv!=.
replace r2=0 if ltv!=. & r2==.
*1.128116 is the 25th percentile
gen     r3=1 if ats<1 
replace r3=0 if ats!=. & r3==.
gen     r4=1 if p2i>=.1286 & p2i!=.
replace r4=0 if p2i!=. & r4==.
*.1286 is the 25th percentile
gen     sum=r1+r2+r3+r4+low_doc
replace sum=r1+r2+r4+low_doc if actpay_miss==1 
gen     s1=size      if sum>=3 & sum!=.
replace s1=size*0.48 if sum==2 & actpay_miss==1 
*the likelihood of r3=1 is 48% for other deals by the the same issuer of the three deals with actpay_miss=1.  
gen     s2=size      if sum!=.
bys mtg_deal_name: egen t1=sum(s1)
bys mtg_deal_name: egen t2=sum(s2)
gen layer_vw=t1/t2
keep mtg_deal_name layer_vw 
duplicates drop
merge 1:1 mtg_deal_name using control
drop _merge
save layer,replace

use deal
merge 1:1 mtg_deal_name using layer
drop _merge
gen     rl_high=1 if layer_vw>=.0276001 & layer_vw!=.
replace rl_high=0 if layer_vw<=.0276001
*.0276001 is the median of layer_vw
bys series: egen high_avg=mean(rl_high)
replace rl_high=1 if high_avg>=0.67 & high_avg!=. & rl_high==. & treat==1 & post==0
replace rl_high=0 if high_avg< 0.67               & rl_high==. & treat==1 & post==0
*0.67 is the median of high_avg

**figures
*coefficients
forvalues i=2(1)5{
gen     d`i'=1 if period==`i'
replace d`i'=0 if d`i'==.
}
*period=1 for June 2013 – July 2014
*period=2 for August 2014 – September 2015 
*period=3 for October 2015 – November 2016
*period=4 for December 2016 – November 2017 
*period=5 for December 2017 – November 2018
forvalues i=2(1)5{
gen spread_d`i'      =spread_vw*d`i'
gen spread_treat_d`i'=spread_treat*d`i'
}
reg cum_loss_pct spread_vw spread_treat spread_d2-spread_treat_d5 treat_post log_amt wal_vw float_pert ntranche nrating i.fe_sec_type i.period i.id_issuer, cluster(cluster)
gen y1=_b[spread_vw]+_b[spread_treat]
forvalues i=2(1)5{
gen y`i'=_b[spread_vw]+_b[spread_treat]+_b[spread_treat_d`i']
}
gen v1=_b[spread_vw]
forvalues i=2(1)5{
gen v`i'=_b[spread_vw]+_b[spread_d`i']
}
keep y1-y5 v1-v5
duplicates drop
gen n=_n
reshape long y v , i(n) j(m)
ren y Treatment
ren v Control

forvalues i=2(1)5{
gen     d`i'=1 if period==`i'
replace d`i'=0 if d`i'==.
}
forvalues i=2(1)5{
gen ari_d`i'      =ari_vw*d`i'
gen ari_treat_d`i'=ari_treat*d`i'
}
reg cum_loss_pct ari_vw ari_treat ari_d2-ari_treat_d5 treat_post log_amt wal_vw float_pert ntranche nrating i.fe_sec_type i.period i.id_issuer, cluster(mtg_deal_name)
gen x1=_b[ari_vw]+_b[ari_treat]
forvalues i=2(1)5{
gen x`i'=_b[ari_vw]+_b[ari_treat]+_b[ari_treat_d`i']
}
gen u1=_b[ari_vw]
forvalues i=2(1)5{
gen u`i'=_b[ari_vw]+_b[ari_d`i']
}
keep x1-x5 u1-u5
duplicates drop
gen n=_n
reshape long x u, i(n) j(m)
ren x Treatment
ren u Control

*R2
reg cum_loss_pct treat_post log_amt wal_vw float_pert ntranche nrating i.fe_sec_type i.period i.id_issuer, cluster(cluster)
predict res,res
gen r2_treat=.
gen r2_control=.
forvalues i=1(1)5{
reg res spread_vw        if period==`i' & sec_type=="AUTO"
replace r2_treat  =e(r2) if period==`i' & sec_type=="AUTO"
reg res spread_vw        if period==`i' & sec_type!="AUTO"
replace r2_control=e(r2) if period==`i' & sec_type!="AUTO"
}
keep r2_treat r2_control period
duplicates drop
save temp_1,replace
keep r2_treat period
drop if r2_treat==.
save temp_2,replace
use temp_1
keep r2_control period
drop if r2_control==.
merge 1:1 period using temp_2
drop _merge
ren r2_treat Treatment
ren r2_control Control

reg cum_loss_pct treat_post log_amt wal_vw float_pert ntranche nrating i.fe_sec_type i.period i.id_issuer, cluster(cluster)
predict res,res
gen r2_treat=.
gen r2_control=.
forvalues i=1(1)5{
reg res ari_vw           if period==`i' & sec_type=="AUTO"
replace r2_treat  =e(r2) if period==`i' & sec_type=="AUTO"
reg res ari_vw           if period==`i' & sec_type!="AUTO"
replace r2_control=e(r2) if period==`i' & sec_type!="AUTO"
}
keep r2_treat r2_control period
duplicates drop
save temp_1,replace
keep r2_treat period
drop if r2_treat==.
save temp_2,replace
use temp_1
keep r2_control period
drop if r2_control==.
merge 1:1 period using temp_2
drop _merge
ren r2_treat Treatment
ren r2_control Control

*the number of unique IP addresses that download preliminary prospectus and/or absee.
*dataset All_abs_2017 comes from sas code 'ABS EDGAR download code'
use All_abs_2017
drop issuer time datetime p1 abs
duplicates drop
gen t= date- p1filedate
save temp_1,replace

use temp_1
keep if formtype=="424H"
save temp_2, replace
forvalues i=0(1)12{
use temp_2
keep if t<=`i'
keep mtg_deal ip
duplicates drop
gen s=1
bys mtg_deal: egen count=sum(s)
keep mtg_deal count
gen t=`i'
duplicates drop
save `i',replace
}
use 0
forvalues i=1(1)12{
append using `i'
}
bys t: egen avg_prospectus=mean(count)
keep t avg_prospectus
duplicates drop
save prospectus,replace

use temp_1
keep if formtype=="ABS-EE"
save temp_2, replace
forvalues i=0(1)12{
use temp_2
keep if t<=`i'
keep mtg_deal ip
duplicates drop
gen s=1
bys mtg_deal: egen count=sum(s)
keep mtg_deal count
gen t=`i'
duplicates drop
save `i',replace
}
use 0
forvalues i=1(1)12{
append using `i'
}
bys t: egen avg_absee=mean(count)
keep t avg_absee
duplicates drop
save absee,replace

forvalues i=0(1)12{
use temp_1
keep if t<=`i'
keep mtg_deal formtype ip
duplicates drop
bys mtg_deal ip: egen count=count(formtype)
drop if count==1
drop count formtype
duplicates drop
gen s=1
bys mtg_deal: egen count=sum(s)
keep mtg_deal count
gen t=`i'
duplicates drop
save `i',replace
}
use 0
forvalues i=1(1)12{
append using `i'
}
bys t: egen avg_common=mean(count)
keep t avg_common
duplicates drop
save common,replace

use prospectus
merge 1:1 t using absee
drop _merge
merge 1:1 t using common
drop _merge

