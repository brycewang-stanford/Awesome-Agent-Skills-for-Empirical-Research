
*************************************************************************************************************
*DOES CORPORATE SOCIAL RESPONSIBILITY (CSR) CREATE SHAREHOLDER VALUE? 
*EVIDENCE FROM THE INDIAN COMPANIES ACT 2013

*HARIOM MANCHIRAJU & SHIVA RAJGOPAL

*PARTS OF STATA CODE AND DESCRIPTION TO REPLICATE MAIN RESULTS - TABLE 3-6

****************************************************************************************************************

************************************************************************************************************
* STEP 1: GENERATE SAMPLE FOR THE RDD ANALYSIS 
*The input dataset "acctdata" contains accountnig data for all firms with non-missing data on total assets, 
*sales, net income, book value of equity, and market capitalization
*************************************************************************************************************

/*use acctdata

gen affected = 0
gen affected1 = 0
replace affected1 = 1 if pat >= 50
gen affected2 = 0
replace affected2 = 1 if bv >= 5000
gen affected3 = 0
replace affected3 = 1 if sale >= 10000
replace affected = 1 if affected1 == 1
replace affected = 1 if affected2 == 1
replace affected = 1 if affected3 == 1



gen bin1  = 0
replace bin1 = 1 if pat >= 25 & pat <= 75
gen bin2 = 0
replace bin2 = 1 if bv >= 2500 & bv <= 7500
gen bin3 = 0
replace bin3 = 1 if sales >= 5000 & sales <= 15000

gen rd_sample = 0
replace rd_sample = 1 if bin1 == 1
replace rd_sample = 1 if bin2 == 1
replace rd_sample = 1 if bin3 == 1


gen pat1 = (pat - 50)/50
gen bv1 = (bv - 5000)/5000
gen sales1 = (sales - 10000)/10000


gen m = 0
replace m = pat1 if affected1 == 1 & affected2 ==0 & affected3 == 0
replace m = bv1 if affected1 == 0 & affected2 ==1 & affected3 == 0
replace m = sales1 if affected1 == 0 & affected2 ==0 & affected3 == 1
replace m = min(pat1, bv1, sales1) if affected1 == 1 & affected2 ==1 & affected3 == 1
replace m = max(pat1, bv1, sales1) if affected1 == 0 & affected2 ==0 & affected3 == 0
replace m = min(pat1, bv1) if affected1 == 1 & affected2 ==1 & affected3 == 0
replace m = min(pat1, sales1) if affected1 == 1 & affected2 ==0 & affected3 ==1
replace m = min(bv1, sales1) if affected1 == 0 & affected2 ==1 & affected3 ==1
replace rd_sample = 0 if m > .5

keep if rd_sample == 1

save acctdata, replace


************************************************************************************************************
* STEP 2: GET STOCK RETURN DATA FOR THE RDD SAMPLE 
*CAR is calculated using the market model around the event dates identified in the paper. The CAR data is then 
*merged with accunting data using the unique key "CMIE COMPANY CODE" to create the final dataset "FINALDATA".
*************************************************************************************************************


**************************************************************************************************************
* STEP 3 - MAIN RESULTS
*The input dataset is "tables_3_6" contains CAR and accountnig data for the RDD sample
**************************************************************************************************************

**********************************************************************************************************
*GRAPHICAL ANALYSIS OF RDD - * FIGURE 3
**********************************************************************************************************
* This set of graphs will have scatter plot of the entire data in the background
*rd file needs to be installed */


cd "H:\Hariom\Research\Projects\8 Mandatory CSR\JAR\tables"

use tables_3_6

tab date, gen(event)

rd car3d m if  event1 == 1, p(1) gr 
rd car3d m if  event2 == 1, p(1) gr 
rd car3d m if  event3 == 1, p(1) gr 
rd car3d m if  event4 == 1, p(1) gr
rd car3d m if  event5 == 1, p(1) gr 
rd car3d m if  event6 == 1, p(1) gr 
rd car3d m if  event7 == 1, p(1) gr 
rd car3d m if  event8 == 1, p(1) gr 
* coefficients and z-stats are tabulated in table 4a

* this set of graphs will have bin averages. The number of bins are also reported
*rdplot file needs to be installed
rdplot car3d m if event1 == 1, h(1) p(3)
rdplot car3d m if event2 == 1, h(1) p(3)
rdplot car3d m if event3 == 1, h(1) p(3)
rdplot car3d m if event4 == 1, h(1) p(3)
rdplot car3d m if event5 == 1, h(1) p(3)
rdplot car3d m if event6 == 1, h(1) p(3)
rdplot car3d m if event7 == 1, h(1) p(3)
rdplot car3d m if event8 == 1, h(1) p(3)


**********************************************************************************************************
* TABLE 3 - UNIVARIATE TESTS
********************************************************************************************************** 

tabstat car3d if affected == 1,  by(date) stat(median)  col(stat)
tabstat car3d if affected == 0, by(date) stat(median)  col(stat)


tabstat car3d if affected == 1 , by(date) stat(median)  col(stat)
tabstat car3d if affected == 0 , by(date) stat(median)  col(stat)
 
signrank car3d = 0 if event1 == 1 & affected == 0 
signrank car3d = 0 if event1 == 1 & affected == 1 
ranksum car3d if event1 == 1, by(affected)


signrank car3d = 0 if event2 == 1 & affected == 0 
signrank car3d = 0 if event2 == 1 & affected == 1 
ranksum car3d if event2 == 1 , by(affected)


signrank car3d = 0 if event3 == 1 & affected == 0 
signrank car3d = 0 if event3 == 1 & affected == 1 
ranksum car3d if event3 == 1 , by(affected)


signrank car3d = 0 if event4 == 1 & affected == 0 
signrank car3d = 0 if event4 == 1 & affected == 1 
ranksum car3d if event4 == 1 , by(affected)


signrank car3d = 0 if event5 == 1 & affected == 0 
signrank car3d = 0 if event5 == 1 & affected == 1 
ranksum car3d if event5 == 1 , by(affected)


signrank car3d = 0 if event6 == 1 & affected == 0 
signrank car3d = 0 if event6 == 1 & affected == 1 
ranksum car3d if event6 == 1 , by(affected)


signrank car3d = 0 if event7 == 1 & affected == 0 
signrank car3d = 0 if event7 == 1 & affected == 1 
ranksum car3d if event7 == 1 , by(affected)


signrank car3d = 0 if event8 == 1 & affected == 0 
signrank car3d = 0 if event8 == 1 & affected == 1 
ranksum car3d if event8 == 1 , by(affected)


**********************************************************************************************************
* TABLE 4 - DISCONTINUITY DESIGN - NONPARAMETRIC ESTIMATES
* RDROBUST ROUTINES of STATA NEED TO BE INSTALLED BEFORE RUNNING THIS PART OF THE CODE

**********************************************************************************************************

* Panel A - CAR as a linear function of M

rdrobust car3d m if event1 == 1, p(1) bwselect(ik)
rdrobust car3d m if event2 == 1, p(1) bwselect(ik)
rdrobust car3d m if event3 == 1, p(1) bwselect(ik)
rdrobust car3d m if event4 == 1, p(1) bwselect(ik)
rdrobust car3d m if event5 == 1, p(1) bwselect(ik)
rdrobust car3d m if event6 == 1, p(1) bwselect(ik)
rdrobust car3d m if event7 == 1, p(1) bwselect(ik)
rdrobust car3d m if event8 == 1, p(1) bwselect(ik)


* Panel B - CAR as a polynomial function of M
rdrobust car3d m if event1 == 1, h(1) p(3)
rdrobust car3d m if event2 == 1, h(1) p(3)
rdrobust car3d m if event3 == 1, h(1) p(3)
rdrobust car3d m if event4 == 1, h(1) p(3)
rdrobust car3d m if event5 == 1, h(1) p(3)
rdrobust car3d m if event6 == 1, h(1) p(3)
rdrobust car3d m if event7 == 1, h(1) p(3)
rdrobust car3d m if event8 == 1, h(1) p(3)


**********************************************************************************************************
* TABLE 5 - DISCONTINUITY DESIGN - MULTIPLE RUNNING VARIABLES - PARAMETRIC ESTIMATES WITH CONTROLS
* CLUSTER2 ROUTINE of STATA NEED TO BE INSTALLED BEFORE RUNNING THIS PART OF THE CODE

**********************************************************************************************************

local firm_controls size bm lev roa capex sgrowth cash bind big4 bg govt mnc xad political polluted

tab ffind, gen(ind)

gen affected_event1 = affected*event1
gen affected_event2 = affected*event2
gen affected_event3 = affected*event3
gen affected_event4 = affected*event4
gen affected_event5 = affected*event5
gen affected_event6 = affected*event6
gen affected_event7 = affected*event7
gen affected_event8 = affected*event8

gen affected_m = affected*m
gen m_p2 = m*m
gen m_p3 = m*m*m



cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_m m m_p2 m_p3 pat1 bv1 sales1 event2-event8,  fcluster(coid) tcluster(date)
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = 0
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = -.014
outreg2 using t5.xls,  stats( coef  tstat)  aster paren dec(3) sideway 

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_m m m_p2 m_p3 pat1 bv1 sales1  `firm_controls' ind1-ind38 event2-event8,  fcluster(coid) tcluster(date)
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = 0
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = -.014
outreg2 using t5.xls,  stats( coef  tstat)  aster paren dec(3) sideway

areg car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_m m m_p2 m_p3 pat1 bv1 sales1  `firm_controls' event2-event8,  cluster(coid) absorb(coid)
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = 0
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = -.014
outreg2 using t5.xls,  stats( coef  tstat)  aster paren dec(3) sideway



**********************************************************************************************************
* TABLE 6 - CROSS SECTIONAL ANALYSIS  - RDD WITH PARAMETRIC ESTIMATES WITH CONTROLS
* CLUSTER2 ROUTINE of STATA NEED TO BE INSTALLED BEFORE RUNNING THIS PART OF THE CODE

**********************************************************************************************************

*  VARIATION BASED ON THE BUSINESS GROUP AFFILIATION
gen affected_event1_political = affected*event1*political
gen affected_event2_political = affected*event2*political
gen affected_event3_political = affected*event3*political
gen affected_event4_political = affected*event4*political
gen affected_event5_political = affected*event5*political
gen affected_event6_political = affected*event6*political
gen affected_event7_political = affected*event7*political
gen affected_event8_political = affected*event8*political

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_event1_political affected_event2_political affected_event3_political affected_event4_political affected_event5_political affected_event6_political affected_event7_political affected_event8_political affected_m m m_p2 m_p3 pat1 bv1 sales1 event1-event8 `firm_controls' ind1-ind38,  fcluster(coid) tcluster(date)
test affected_event1_political + affected_event2_political + affected_event3_political + affected_event4_political + affected_event5_political + affected_event6_political + affected_event7_political + affected_event8_political = 0
outreg2 using t6.xls,  stats( coef  tstat)  aster paren dec(3) sideway


* VARIATION BASED ON HIGH ADVERTISEMENT SPENDERS

gen affected_event1_ad = affected*event1*ad
gen affected_event2_ad = affected*event2*ad
gen affected_event3_ad = affected*event3*ad
gen affected_event4_ad = affected*event4*ad
gen affected_event5_ad = affected*event5*ad
gen affected_event6_ad = affected*event6*ad
gen affected_event7_ad = affected*event7*ad
gen affected_event8_ad = affected*event8*ad

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_event1_ad affected_event2_ad affected_event3_ad affected_event4_ad affected_event5_ad affected_event6_ad affected_event7_ad affected_event8_ad affected_m m m_p2 m_p3 pat1 bv1 sales1  event1-event8 `firm_controls' ind1-ind38,  fcluster(coid) tcluster(date)
test affected_event1_ad + affected_event2_ad + affected_event3_ad + affected_event4_ad + affected_event5_ad + affected_event6_ad + affected_event7_ad + affected_event8_ad = 0
outreg2 using t6.xls,  stats( coef  tstat)  aster paren dec(3) sideway



gen affected_event1_polluted = affected*event1*polluted
gen affected_event2_polluted = affected*event2*polluted
gen affected_event3_polluted = affected*event3*polluted
gen affected_event4_polluted = affected*event4*polluted
gen affected_event5_polluted = affected*event5*polluted
gen affected_event6_polluted = affected*event6*polluted
gen affected_event7_polluted = affected*event7*polluted
gen affected_event8_polluted = affected*event8*polluted

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_event1_polluted affected_event2_polluted affected_event3_polluted affected_event4_polluted affected_event5_polluted affected_event6_polluted affected_event7_polluted affected_event8_polluted affected_m m m_p2 m_p3 pat1 bv1 sales1 event1-event8 `firm_controls' ind1-ind38,  fcluster(coid) tcluster(date)
test affected_event1_polluted + affected_event2_polluted + affected_event3_polluted + affected_event4_polluted + affected_event5_polluted + affected_event6_polluted + affected_event7_polluted + affected_event8_polluted = 0
outreg2 using t6.xls,  stats( coef  tstat)  aster paren dec(3) sideway


***************************************************************************************************************************************************************

*************************************************************************************************************
*DOES CORPORATE SOCIAL RESPONSIBILITY (CSR) CREATE SHAREHOLDER VALUE? 
*EVIDENCE FROM THE INDIAN COMPANIES ACT 2013

*HARIOM MANCHIRAJU & SHIVA RAJGOPAL

*PARTS OF STATA CODE AND DESCRIPTION TO REPLICATE MAIN RESULTS - TABLE 3-6

****************************************************************************************************************

************************************************************************************************************
* STEP 1: GENERATE SAMPLE FOR THE RDD ANALYSIS 
*The input dataset "acctdata" contains accountnig data for all firms with non-missing data on total assets, 
*sales, net income, book value of equity, and market capitalization
*************************************************************************************************************

/*use acctdata

gen affected = 0
gen affected1 = 0
replace affected1 = 1 if pat >= 50
gen affected2 = 0
replace affected2 = 1 if bv >= 5000
gen affected3 = 0
replace affected3 = 1 if sale >= 10000
replace affected = 1 if affected1 == 1
replace affected = 1 if affected2 == 1
replace affected = 1 if affected3 == 1



gen bin1  = 0
replace bin1 = 1 if pat >= 25 & pat <= 75
gen bin2 = 0
replace bin2 = 1 if bv >= 2500 & bv <= 7500
gen bin3 = 0
replace bin3 = 1 if sales >= 5000 & sales <= 15000

gen rd_sample = 0
replace rd_sample = 1 if bin1 == 1
replace rd_sample = 1 if bin2 == 1
replace rd_sample = 1 if bin3 == 1


gen pat1 = (pat - 50)/50
gen bv1 = (bv - 5000)/5000
gen sales1 = (sales - 10000)/10000


gen m = 0
replace m = pat1 if affected1 == 1 & affected2 ==0 & affected3 == 0
replace m = bv1 if affected1 == 0 & affected2 ==1 & affected3 == 0
replace m = sales1 if affected1 == 0 & affected2 ==0 & affected3 == 1
replace m = min(pat1, bv1, sales1) if affected1 == 1 & affected2 ==1 & affected3 == 1
replace m = max(pat1, bv1, sales1) if affected1 == 0 & affected2 ==0 & affected3 == 0
replace m = min(pat1, bv1) if affected1 == 1 & affected2 ==1 & affected3 == 0
replace m = min(pat1, sales1) if affected1 == 1 & affected2 ==0 & affected3 ==1
replace m = min(bv1, sales1) if affected1 == 0 & affected2 ==1 & affected3 ==1
replace rd_sample = 0 if m > .5

keep if rd_sample == 1

save acctdata, replace


************************************************************************************************************
* STEP 2: GET STOCK RETURN DATA FOR THE RDD SAMPLE 
*CAR is calculated using the market model around the event dates identified in the paper. The CAR data is then 
*merged with accunting data using the unique key "CMIE COMPANY CODE" to create the final dataset "FINALDATA".
*************************************************************************************************************


**************************************************************************************************************
* STEP 3 - MAIN RESULTS
*The input dataset is "tables_3_6" contains CAR and accountnig data for the RDD sample
**************************************************************************************************************

**********************************************************************************************************
*GRAPHICAL ANALYSIS OF RDD - * FIGURE 3
**********************************************************************************************************
* This set of graphs will have scatter plot of the entire data in the background
*rd file needs to be installed */


cd "H:\Hariom\Research\Projects\8 Mandatory CSR\JAR\tables"

use tables_3_6

tab date, gen(event)

rd car3d m if  event1 == 1, p(1) gr 
rd car3d m if  event2 == 1, p(1) gr 
rd car3d m if  event3 == 1, p(1) gr 
rd car3d m if  event4 == 1, p(1) gr
rd car3d m if  event5 == 1, p(1) gr 
rd car3d m if  event6 == 1, p(1) gr 
rd car3d m if  event7 == 1, p(1) gr 
rd car3d m if  event8 == 1, p(1) gr 
* coefficients and z-stats are tabulated in table 4a

* this set of graphs will have bin averages. The number of bins are also reported
*rdplot file needs to be installed
rdplot car3d m if event1 == 1, h(1) p(3)
rdplot car3d m if event2 == 1, h(1) p(3)
rdplot car3d m if event3 == 1, h(1) p(3)
rdplot car3d m if event4 == 1, h(1) p(3)
rdplot car3d m if event5 == 1, h(1) p(3)
rdplot car3d m if event6 == 1, h(1) p(3)
rdplot car3d m if event7 == 1, h(1) p(3)
rdplot car3d m if event8 == 1, h(1) p(3)


**********************************************************************************************************
* TABLE 3 - UNIVARIATE TESTS
********************************************************************************************************** 

tabstat car3d if affected == 1,  by(date) stat(median)  col(stat)
tabstat car3d if affected == 0, by(date) stat(median)  col(stat)


tabstat car3d if affected == 1 , by(date) stat(median)  col(stat)
tabstat car3d if affected == 0 , by(date) stat(median)  col(stat)
 
signrank car3d = 0 if event1 == 1 & affected == 0 
signrank car3d = 0 if event1 == 1 & affected == 1 
ranksum car3d if event1 == 1, by(affected)


signrank car3d = 0 if event2 == 1 & affected == 0 
signrank car3d = 0 if event2 == 1 & affected == 1 
ranksum car3d if event2 == 1 , by(affected)


signrank car3d = 0 if event3 == 1 & affected == 0 
signrank car3d = 0 if event3 == 1 & affected == 1 
ranksum car3d if event3 == 1 , by(affected)


signrank car3d = 0 if event4 == 1 & affected == 0 
signrank car3d = 0 if event4 == 1 & affected == 1 
ranksum car3d if event4 == 1 , by(affected)


signrank car3d = 0 if event5 == 1 & affected == 0 
signrank car3d = 0 if event5 == 1 & affected == 1 
ranksum car3d if event5 == 1 , by(affected)


signrank car3d = 0 if event6 == 1 & affected == 0 
signrank car3d = 0 if event6 == 1 & affected == 1 
ranksum car3d if event6 == 1 , by(affected)


signrank car3d = 0 if event7 == 1 & affected == 0 
signrank car3d = 0 if event7 == 1 & affected == 1 
ranksum car3d if event7 == 1 , by(affected)


signrank car3d = 0 if event8 == 1 & affected == 0 
signrank car3d = 0 if event8 == 1 & affected == 1 
ranksum car3d if event8 == 1 , by(affected)


**********************************************************************************************************
* TABLE 4 - DISCONTINUITY DESIGN - NONPARAMETRIC ESTIMATES
* RDROBUST ROUTINES of STATA NEED TO BE INSTALLED BEFORE RUNNING THIS PART OF THE CODE

**********************************************************************************************************

* Panel A - CAR as a linear function of M

rdrobust car3d m if event1 == 1, p(1) bwselect(ik)
rdrobust car3d m if event2 == 1, p(1) bwselect(ik)
rdrobust car3d m if event3 == 1, p(1) bwselect(ik)
rdrobust car3d m if event4 == 1, p(1) bwselect(ik)
rdrobust car3d m if event5 == 1, p(1) bwselect(ik)
rdrobust car3d m if event6 == 1, p(1) bwselect(ik)
rdrobust car3d m if event7 == 1, p(1) bwselect(ik)
rdrobust car3d m if event8 == 1, p(1) bwselect(ik)


* Panel B - CAR as a polynomial function of M
rdrobust car3d m if event1 == 1, h(1) p(3)
rdrobust car3d m if event2 == 1, h(1) p(3)
rdrobust car3d m if event3 == 1, h(1) p(3)
rdrobust car3d m if event4 == 1, h(1) p(3)
rdrobust car3d m if event5 == 1, h(1) p(3)
rdrobust car3d m if event6 == 1, h(1) p(3)
rdrobust car3d m if event7 == 1, h(1) p(3)
rdrobust car3d m if event8 == 1, h(1) p(3)


**********************************************************************************************************
* TABLE 5 - DISCONTINUITY DESIGN - MULTIPLE RUNNING VARIABLES - PARAMETRIC ESTIMATES WITH CONTROLS
* CLUSTER2 ROUTINE of STATA NEED TO BE INSTALLED BEFORE RUNNING THIS PART OF THE CODE

**********************************************************************************************************

local firm_controls size bm lev roa capex sgrowth cash bind big4 bg govt mnc xad political polluted

tab ffind, gen(ind)

gen affected_event1 = affected*event1
gen affected_event2 = affected*event2
gen affected_event3 = affected*event3
gen affected_event4 = affected*event4
gen affected_event5 = affected*event5
gen affected_event6 = affected*event6
gen affected_event7 = affected*event7
gen affected_event8 = affected*event8

gen affected_m = affected*m
gen m_p2 = m*m
gen m_p3 = m*m*m



cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_m m m_p2 m_p3 pat1 bv1 sales1 event2-event8,  fcluster(coid) tcluster(date)
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = 0
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = -.014
outreg2 using t5.xls,  stats( coef  tstat)  aster paren dec(3) sideway 

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_m m m_p2 m_p3 pat1 bv1 sales1  `firm_controls' ind1-ind38 event2-event8,  fcluster(coid) tcluster(date)
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = 0
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = -.014
outreg2 using t5.xls,  stats( coef  tstat)  aster paren dec(3) sideway

areg car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_m m m_p2 m_p3 pat1 bv1 sales1  `firm_controls' event2-event8,  cluster(coid) absorb(coid)
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = 0
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = -.014
outreg2 using t5.xls,  stats( coef  tstat)  aster paren dec(3) sideway



**********************************************************************************************************
* TABLE 6 - CROSS SECTIONAL ANALYSIS  - RDD WITH PARAMETRIC ESTIMATES WITH CONTROLS
* CLUSTER2 ROUTINE of STATA NEED TO BE INSTALLED BEFORE RUNNING THIS PART OF THE CODE

**********************************************************************************************************

*  VARIATION BASED ON THE BUSINESS GROUP AFFILIATION
gen affected_event1_political = affected*event1*political
gen affected_event2_political = affected*event2*political
gen affected_event3_political = affected*event3*political
gen affected_event4_political = affected*event4*political
gen affected_event5_political = affected*event5*political
gen affected_event6_political = affected*event6*political
gen affected_event7_political = affected*event7*political
gen affected_event8_political = affected*event8*political

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_event1_political affected_event2_political affected_event3_political affected_event4_political affected_event5_political affected_event6_political affected_event7_political affected_event8_political affected_m m m_p2 m_p3 pat1 bv1 sales1 event1-event8 `firm_controls' ind1-ind38,  fcluster(coid) tcluster(date)
test affected_event1_political + affected_event2_political + affected_event3_political + affected_event4_political + affected_event5_political + affected_event6_political + affected_event7_political + affected_event8_political = 0
outreg2 using t6.xls,  stats( coef  tstat)  aster paren dec(3) sideway


* VARIATION BASED ON HIGH ADVERTISEMENT SPENDERS

gen affected_event1_ad = affected*event1*ad
gen affected_event2_ad = affected*event2*ad
gen affected_event3_ad = affected*event3*ad
gen affected_event4_ad = affected*event4*ad
gen affected_event5_ad = affected*event5*ad
gen affected_event6_ad = affected*event6*ad
gen affected_event7_ad = affected*event7*ad
gen affected_event8_ad = affected*event8*ad

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_event1_ad affected_event2_ad affected_event3_ad affected_event4_ad affected_event5_ad affected_event6_ad affected_event7_ad affected_event8_ad affected_m m m_p2 m_p3 pat1 bv1 sales1  event1-event8 `firm_controls' ind1-ind38,  fcluster(coid) tcluster(date)
test affected_event1_ad + affected_event2_ad + affected_event3_ad + affected_event4_ad + affected_event5_ad + affected_event6_ad + affected_event7_ad + affected_event8_ad = 0
outreg2 using t6.xls,  stats( coef  tstat)  aster paren dec(3) sideway



gen affected_event1_polluted = affected*event1*polluted
gen affected_event2_polluted = affected*event2*polluted
gen affected_event3_polluted = affected*event3*polluted
gen affected_event4_polluted = affected*event4*polluted
gen affected_event5_polluted = affected*event5*polluted
gen affected_event6_polluted = affected*event6*polluted
gen affected_event7_polluted = affected*event7*polluted
gen affected_event8_polluted = affected*event8*polluted

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_event1_polluted affected_event2_polluted affected_event3_polluted affected_event4_polluted affected_event5_polluted affected_event6_polluted affected_event7_polluted affected_event8_polluted affected_m m m_p2 m_p3 pat1 bv1 sales1 event1-event8 `firm_controls' ind1-ind38,  fcluster(coid) tcluster(date)
test affected_event1_polluted + affected_event2_polluted + affected_event3_polluted + affected_event4_polluted + affected_event5_polluted + affected_event6_polluted + affected_event7_polluted + affected_event8_polluted = 0
outreg2 using t6.xls,  stats( coef  tstat)  aster paren dec(3) sideway


***************************************************************************************************************************************************************

*************************************************************************************************************
*DOES CORPORATE SOCIAL RESPONSIBILITY (CSR) CREATE SHAREHOLDER VALUE? 
*EVIDENCE FROM THE INDIAN COMPANIES ACT 2013

*HARIOM MANCHIRAJU & SHIVA RAJGOPAL

*PARTS OF STATA CODE AND DESCRIPTION TO REPLICATE MAIN RESULTS - TABLE 3-6

****************************************************************************************************************

************************************************************************************************************
* STEP 1: GENERATE SAMPLE FOR THE RDD ANALYSIS 
*The input dataset "acctdata" contains accountnig data for all firms with non-missing data on total assets, 
*sales, net income, book value of equity, and market capitalization
*************************************************************************************************************

/*use acctdata

gen affected = 0
gen affected1 = 0
replace affected1 = 1 if pat >= 50
gen affected2 = 0
replace affected2 = 1 if bv >= 5000
gen affected3 = 0
replace affected3 = 1 if sale >= 10000
replace affected = 1 if affected1 == 1
replace affected = 1 if affected2 == 1
replace affected = 1 if affected3 == 1



gen bin1  = 0
replace bin1 = 1 if pat >= 25 & pat <= 75
gen bin2 = 0
replace bin2 = 1 if bv >= 2500 & bv <= 7500
gen bin3 = 0
replace bin3 = 1 if sales >= 5000 & sales <= 15000

gen rd_sample = 0
replace rd_sample = 1 if bin1 == 1
replace rd_sample = 1 if bin2 == 1
replace rd_sample = 1 if bin3 == 1


gen pat1 = (pat - 50)/50
gen bv1 = (bv - 5000)/5000
gen sales1 = (sales - 10000)/10000


gen m = 0
replace m = pat1 if affected1 == 1 & affected2 ==0 & affected3 == 0
replace m = bv1 if affected1 == 0 & affected2 ==1 & affected3 == 0
replace m = sales1 if affected1 == 0 & affected2 ==0 & affected3 == 1
replace m = min(pat1, bv1, sales1) if affected1 == 1 & affected2 ==1 & affected3 == 1
replace m = max(pat1, bv1, sales1) if affected1 == 0 & affected2 ==0 & affected3 == 0
replace m = min(pat1, bv1) if affected1 == 1 & affected2 ==1 & affected3 == 0
replace m = min(pat1, sales1) if affected1 == 1 & affected2 ==0 & affected3 ==1
replace m = min(bv1, sales1) if affected1 == 0 & affected2 ==1 & affected3 ==1
replace rd_sample = 0 if m > .5

keep if rd_sample == 1

save acctdata, replace


************************************************************************************************************
* STEP 2: GET STOCK RETURN DATA FOR THE RDD SAMPLE 
*CAR is calculated using the market model around the event dates identified in the paper. The CAR data is then 
*merged with accunting data using the unique key "CMIE COMPANY CODE" to create the final dataset "FINALDATA".
*************************************************************************************************************


**************************************************************************************************************
* STEP 3 - MAIN RESULTS
*The input dataset is "tables_3_6" contains CAR and accountnig data for the RDD sample
**************************************************************************************************************

**********************************************************************************************************
*GRAPHICAL ANALYSIS OF RDD - * FIGURE 3
**********************************************************************************************************
* This set of graphs will have scatter plot of the entire data in the background
*rd file needs to be installed */


cd "H:\Hariom\Research\Projects\8 Mandatory CSR\JAR\tables"

use tables_3_6

tab date, gen(event)

rd car3d m if  event1 == 1, p(1) gr 
rd car3d m if  event2 == 1, p(1) gr 
rd car3d m if  event3 == 1, p(1) gr 
rd car3d m if  event4 == 1, p(1) gr
rd car3d m if  event5 == 1, p(1) gr 
rd car3d m if  event6 == 1, p(1) gr 
rd car3d m if  event7 == 1, p(1) gr 
rd car3d m if  event8 == 1, p(1) gr 
* coefficients and z-stats are tabulated in table 4a

* this set of graphs will have bin averages. The number of bins are also reported
*rdplot file needs to be installed
rdplot car3d m if event1 == 1, h(1) p(3)
rdplot car3d m if event2 == 1, h(1) p(3)
rdplot car3d m if event3 == 1, h(1) p(3)
rdplot car3d m if event4 == 1, h(1) p(3)
rdplot car3d m if event5 == 1, h(1) p(3)
rdplot car3d m if event6 == 1, h(1) p(3)
rdplot car3d m if event7 == 1, h(1) p(3)
rdplot car3d m if event8 == 1, h(1) p(3)


**********************************************************************************************************
* TABLE 3 - UNIVARIATE TESTS
********************************************************************************************************** 

tabstat car3d if affected == 1,  by(date) stat(median)  col(stat)
tabstat car3d if affected == 0, by(date) stat(median)  col(stat)


tabstat car3d if affected == 1 , by(date) stat(median)  col(stat)
tabstat car3d if affected == 0 , by(date) stat(median)  col(stat)
 
signrank car3d = 0 if event1 == 1 & affected == 0 
signrank car3d = 0 if event1 == 1 & affected == 1 
ranksum car3d if event1 == 1, by(affected)


signrank car3d = 0 if event2 == 1 & affected == 0 
signrank car3d = 0 if event2 == 1 & affected == 1 
ranksum car3d if event2 == 1 , by(affected)


signrank car3d = 0 if event3 == 1 & affected == 0 
signrank car3d = 0 if event3 == 1 & affected == 1 
ranksum car3d if event3 == 1 , by(affected)


signrank car3d = 0 if event4 == 1 & affected == 0 
signrank car3d = 0 if event4 == 1 & affected == 1 
ranksum car3d if event4 == 1 , by(affected)


signrank car3d = 0 if event5 == 1 & affected == 0 
signrank car3d = 0 if event5 == 1 & affected == 1 
ranksum car3d if event5 == 1 , by(affected)


signrank car3d = 0 if event6 == 1 & affected == 0 
signrank car3d = 0 if event6 == 1 & affected == 1 
ranksum car3d if event6 == 1 , by(affected)


signrank car3d = 0 if event7 == 1 & affected == 0 
signrank car3d = 0 if event7 == 1 & affected == 1 
ranksum car3d if event7 == 1 , by(affected)


signrank car3d = 0 if event8 == 1 & affected == 0 
signrank car3d = 0 if event8 == 1 & affected == 1 
ranksum car3d if event8 == 1 , by(affected)


**********************************************************************************************************
* TABLE 4 - DISCONTINUITY DESIGN - NONPARAMETRIC ESTIMATES
* RDROBUST ROUTINES of STATA NEED TO BE INSTALLED BEFORE RUNNING THIS PART OF THE CODE

**********************************************************************************************************

* Panel A - CAR as a linear function of M

rdrobust car3d m if event1 == 1, p(1) bwselect(ik)
rdrobust car3d m if event2 == 1, p(1) bwselect(ik)
rdrobust car3d m if event3 == 1, p(1) bwselect(ik)
rdrobust car3d m if event4 == 1, p(1) bwselect(ik)
rdrobust car3d m if event5 == 1, p(1) bwselect(ik)
rdrobust car3d m if event6 == 1, p(1) bwselect(ik)
rdrobust car3d m if event7 == 1, p(1) bwselect(ik)
rdrobust car3d m if event8 == 1, p(1) bwselect(ik)


* Panel B - CAR as a polynomial function of M
rdrobust car3d m if event1 == 1, h(1) p(3)
rdrobust car3d m if event2 == 1, h(1) p(3)
rdrobust car3d m if event3 == 1, h(1) p(3)
rdrobust car3d m if event4 == 1, h(1) p(3)
rdrobust car3d m if event5 == 1, h(1) p(3)
rdrobust car3d m if event6 == 1, h(1) p(3)
rdrobust car3d m if event7 == 1, h(1) p(3)
rdrobust car3d m if event8 == 1, h(1) p(3)


**********************************************************************************************************
* TABLE 5 - DISCONTINUITY DESIGN - MULTIPLE RUNNING VARIABLES - PARAMETRIC ESTIMATES WITH CONTROLS
* CLUSTER2 ROUTINE of STATA NEED TO BE INSTALLED BEFORE RUNNING THIS PART OF THE CODE

**********************************************************************************************************

local firm_controls size bm lev roa capex sgrowth cash bind big4 bg govt mnc xad political polluted

tab ffind, gen(ind)

gen affected_event1 = affected*event1
gen affected_event2 = affected*event2
gen affected_event3 = affected*event3
gen affected_event4 = affected*event4
gen affected_event5 = affected*event5
gen affected_event6 = affected*event6
gen affected_event7 = affected*event7
gen affected_event8 = affected*event8

gen affected_m = affected*m
gen m_p2 = m*m
gen m_p3 = m*m*m



cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_m m m_p2 m_p3 pat1 bv1 sales1 event2-event8,  fcluster(coid) tcluster(date)
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = 0
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = -.014
outreg2 using t5.xls,  stats( coef  tstat)  aster paren dec(3) sideway 

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_m m m_p2 m_p3 pat1 bv1 sales1  `firm_controls' ind1-ind38 event2-event8,  fcluster(coid) tcluster(date)
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = 0
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = -.014
outreg2 using t5.xls,  stats( coef  tstat)  aster paren dec(3) sideway

areg car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_m m m_p2 m_p3 pat1 bv1 sales1  `firm_controls' event2-event8,  cluster(coid) absorb(coid)
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = 0
test  affected_event1 + affected_event2 + affected_event3 + affected_event4 + affected_event5 + affected_event6 + affected_event7 + affected_event8 = -.014
outreg2 using t5.xls,  stats( coef  tstat)  aster paren dec(3) sideway



**********************************************************************************************************
* TABLE 6 - CROSS SECTIONAL ANALYSIS  - RDD WITH PARAMETRIC ESTIMATES WITH CONTROLS
* CLUSTER2 ROUTINE of STATA NEED TO BE INSTALLED BEFORE RUNNING THIS PART OF THE CODE

**********************************************************************************************************

*  VARIATION BASED ON THE BUSINESS GROUP AFFILIATION
gen affected_event1_political = affected*event1*political
gen affected_event2_political = affected*event2*political
gen affected_event3_political = affected*event3*political
gen affected_event4_political = affected*event4*political
gen affected_event5_political = affected*event5*political
gen affected_event6_political = affected*event6*political
gen affected_event7_political = affected*event7*political
gen affected_event8_political = affected*event8*political

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_event1_political affected_event2_political affected_event3_political affected_event4_political affected_event5_political affected_event6_political affected_event7_political affected_event8_political affected_m m m_p2 m_p3 pat1 bv1 sales1 event1-event8 `firm_controls' ind1-ind38,  fcluster(coid) tcluster(date)
test affected_event1_political + affected_event2_political + affected_event3_political + affected_event4_political + affected_event5_political + affected_event6_political + affected_event7_political + affected_event8_political = 0
outreg2 using t6.xls,  stats( coef  tstat)  aster paren dec(3) sideway


* VARIATION BASED ON HIGH ADVERTISEMENT SPENDERS

gen affected_event1_ad = affected*event1*ad
gen affected_event2_ad = affected*event2*ad
gen affected_event3_ad = affected*event3*ad
gen affected_event4_ad = affected*event4*ad
gen affected_event5_ad = affected*event5*ad
gen affected_event6_ad = affected*event6*ad
gen affected_event7_ad = affected*event7*ad
gen affected_event8_ad = affected*event8*ad

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_event1_ad affected_event2_ad affected_event3_ad affected_event4_ad affected_event5_ad affected_event6_ad affected_event7_ad affected_event8_ad affected_m m m_p2 m_p3 pat1 bv1 sales1  event1-event8 `firm_controls' ind1-ind38,  fcluster(coid) tcluster(date)
test affected_event1_ad + affected_event2_ad + affected_event3_ad + affected_event4_ad + affected_event5_ad + affected_event6_ad + affected_event7_ad + affected_event8_ad = 0
outreg2 using t6.xls,  stats( coef  tstat)  aster paren dec(3) sideway



gen affected_event1_polluted = affected*event1*polluted
gen affected_event2_polluted = affected*event2*polluted
gen affected_event3_polluted = affected*event3*polluted
gen affected_event4_polluted = affected*event4*polluted
gen affected_event5_polluted = affected*event5*polluted
gen affected_event6_polluted = affected*event6*polluted
gen affected_event7_polluted = affected*event7*polluted
gen affected_event8_polluted = affected*event8*polluted

cluster2 car3d  affected_event1 affected_event2 affected_event3 affected_event4 affected_event5 affected_event6 affected_event7 affected_event8 affected_event1_polluted affected_event2_polluted affected_event3_polluted affected_event4_polluted affected_event5_polluted affected_event6_polluted affected_event7_polluted affected_event8_polluted affected_m m m_p2 m_p3 pat1 bv1 sales1 event1-event8 `firm_controls' ind1-ind38,  fcluster(coid) tcluster(date)
test affected_event1_polluted + affected_event2_polluted + affected_event3_polluted + affected_event4_polluted + affected_event5_polluted + affected_event6_polluted + affected_event7_polluted + affected_event8_polluted = 0
outreg2 using t6.xls,  stats( coef  tstat)  aster paren dec(3) sideway


***************************************************************************************************************************************************************

