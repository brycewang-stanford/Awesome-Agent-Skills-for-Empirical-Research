/*This file computes the number of jinshi around corporate headquarters*/






/*Procedures:

1. Import jinshi from excel (rawdata):
	- Tab2: The coordinates of jinshi
	- Tab3: The coordinates of baqi jinshi 

Obtain the number of jinshi (both types) at the location level.
Convert the data to the wide format, i.e., one row.


2. Import corporate headquarter coordinates (rawdata):
	- Missing headquarter addresses are already dropped from the data.
	- Coordinates are hand-collected.

Compute the distance between headquarter coordinates and jinshi location coordinates. 

*/



global path ""
global rawdata "${path}/Data"
global data "${path}/Data"
global output "${path}/Data"




clear all
set maxvar 10000





**************************************************************************************
**************************************************************************************
**************************************************************************************

/*Step1: Compute the number of jinshi by coordinates*/

**************************************************************************************
**************************************************************************************
**************************************************************************************






* The first part only contains the regular jinshi. Baqi jinshi's coordinates are missing
import excel "${rawdata}/清朝进士原始数据.xlsx", sheet("坐标匹配数据") firstrow clear  
drop if 东经==. 
keep 东经 北纬 totaljinshi 
saveold "${data}/tempnumjinshi.dta", replace version(14) 


* The second part contains the coordinates of baqi jinshi, aggregated at the location level. 
import excel "${rawdata}/清朝进士原始数据.xlsx", sheet("八旗进士居住地") firstrow clear 
sort 东经 北纬
rename 人数 totaljinshi
by 东经 北纬: egen totaljinshi1 = total(totaljinshi)
duplicates drop 东经 北纬, force
keep 东经 北纬 totaljinshi1
rename totaljinshi1 totaljinshi

* Combine the regular jinshi file with the baqi jinshi file.
append using "${data}/tempnumjinshi.dta"
bys 东经 北纬: egen totaljinshi1 = total(totaljinshi)
replace totaljinshi=totaljinshi1

duplicates drop 东经 北纬, force
sort 东经 北纬
keep 东经 北纬 totaljinshi


* Reshape data
count
local num = `r(N)'
forvalues i=1(1)`num'{
	gen dongjing`i' = 东经[_n+`i'-1]*3.1415926/180
	gen beiwei`i' = 北纬[_n+`i'-1]*3.1415926/180
	gen totaljinshi`i' = totaljinshi[_n+`i'-1]
}

keep if _n==1

drop 东经 北纬 totaljinshi
gen id =1
sort id
order totaljinshi*
saveold "${data}/numjinshiwide.dta", replace version(14)




































**************************************************************************************
**************************************************************************************
**************************************************************************************

* Step 2: Compute the distance between corporate headquarters and the location of jinshi;

**************************************************************************************
**************************************************************************************
**************************************************************************************


* Import headquarter data
clear 
set maxvar 32767
use "${rawdata}/2000-2018公司注册地址坐标_20191110.dta", clear
gen id =1
duplicates drop code year, force
keep code year d b id







* Compute the number of jinshi around corporate headquarters

merge m:1 id using "${data}/numjinshiwide.dta", nogen keep(3)



* Compute distance
forvalues i=1(1)1353{
	gen cost`i'=sin(b)*sin(beiwei`i')+cos(b)*cos(beiwei`i')*cos(dongjing`i'-d)
	gen dis`i' =6378.198*(0.5*3.1415926-atan(cost`i'/sqrt(1-cost`i'*cost`i')))
	replace dis`i' = 0 if dis`i' ==. // this happens if the headquarter and jinshi location coincide
	drop cost`i'
}


* Compute jinshi number within a 50 and 100 radius. 
sort code year
foreach i in 50 100{
	
	preserve
	forvalues j=1(1)1353{
		replace totaljinshi`j' = totaljinshi`j'*(dis`j' <= `i') // set the number of jinshi to zero if the distance exceeds the cutoff
	}
	
	egen jsh_`i' = rowtotal( totaljinshi1-totaljinshi1353)
	keep code year jsh_`i'
	sort code year
	
	saveold "${data}/tempjsh_`i'.dta", replace  version(12)
	restore	
	merge 1:1 code year using "${data}/tempjsh_`i'.dta", nogen keep(3)
}
drop totaljinshi* dis* beiwei* dongjing*


keep code year jsh_50 jsh_100 

save "${data}/numjinshi_codeyear.dta", replace










/*This file merges CSMAR with Jinshi */

/*

Procedures:

Import CSMAR data 
Merge CSMAR with Jinshi data, produced by 01_JinshiNum


*/


global path ""
global rawdata "${path}/Data"
global data "${path}/Data"
global output "${path}/Data"


* Step 1: Merge relevant data into Jinshi data, produced by 01_JinshiNum.

* 1.1 Process CSMAR data

/*data download from CSMAR directly*/
import delimited using "${rawdata}/FS_Combas 2000-2018Balance sheet Nov252019.csv", clear
rename stkcd code  
gen year = substr(accper, 1, 4)
destring year, replace
gen month = substr(accper, 6, 7)
keep if month == "12-31" // keep annual reports
keep if typrep == "A" // keep consolidated
gen lev = a002000000/a001000000
rename a002000000 liability
rename a001000000 asset
order year, after(code)
keep code year lev asset 
saveold "${data}/temp_csmar_csv.dta", replace version(14)


* 1.2 Process industry data


/*import data downloaded from CSMAR. */

import excel "${rawdata}/STK_ListedCoInfoAnl_公司基本情况表.xlsx", sheet("Sheet1") firstrow clear
destring 股票代码, g(code)
gen year = substr(年度区间, 1, 4)
destring year, replace
rename 行业代码 ind
keep code year ind
saveold "${data}/temp_ind.dta", replace version(14)
 


* 1.3 Process OREC data

/*import data downloaded from CSMAR.*/
import excel "${rawdata}/RPT_Transfer_关联交易原始数据_20191013下载.xlsx", sheet("Sheet1") firstrow clear
destring 证券代码, g(code)
gen year = substr(统计截止日期,1,4)
destring year,replace
order year, after(code)
destring 资金往来科目分类 , gen(type)
destring 关联关系 , gen(relation)
drop 证券代码 统计截止日期 资金往来科目分类 资金往来科目性质 关联方 备注 关联关系
keep if type == 7
rename 年度余额 annual_balance
/*01=上市公司的母公司
  02=上市公司的子公司
  03=与上市公司受同一母公司控制的其他企业
  04=对上市公司实施共同控制的投资方
  05=对上市公司施加重大影响的投资方
  06=上市公司的合营企业
  07=上市公司的联营企业
  08=上市公司的主要投资者个人及与其关系密切的家庭成员
  09=上市公司或其母公司的关键管理人员及其关系密切的家庭成员
  10=上市公司主要投资者个人、关键管理人员或与其关系密切的家庭成员控制、共同控制或者施加重大影响的企业
  11=上市公司的关联方之间
  12=其他
 */
 
/* type 1,3,4,5,6,7,8,9,10,11,12*/ 
bys code year : egen other_rec1 = total(annual_balance) if (relation ==1 | relation==3 | relation==4 | relation==5 | relation==6 | relation==7 | relation==8 | relation==9 | relation==10 | relation==11 | relation==12 )
label var other_rec1 "relation13456789101112"

duplicates drop code year, force
keep if year >= 2000
keep code year other_rec1
saveold "${data}/temp_other_rec1.dta", replace version(14)





* 1.4 Merge into Jinshi data
use "${data}/numjinshi_codeyear", clear
replace jsh_50 = jsh_50 / 1000
replace jsh_100 = jsh_100 / 1000


merge 1:1 code year using "${data}/temp_other_rec1.dta", keep(1 3) nogen 
replace other_rec1 = 0 if other_rec1 == . 


*merge asset and lev
merge 1:1 code year using "${data}/temp_csmar_csv.dta", keep(1 3)
keep if _merge == 3                                
drop _merge

gen orec1 = other_rec1/asset*100 


*merge industry
merge 1:1 code year using "${data}/temp_ind.dta", keep(1 3)  
keep if _merge == 3
drop _merge













* Step 2: Process data and sample selection

* 2.1 Drop B share. 35 obs dropped
drop if code >= 200000 & code <= 299999
drop if code >= 900000


* 2.2 Require lev >=0 & lev <1. 

keep if lev >=0 & lev < 1

* 2.3 Drop financial firms. 665 obs dropped
drop if (ind == "J66" | ind == "J67" | ind == "J68" | ind == "J69")
saveold "${data}/temp_Jinshi and CSMSR_Merged.dta", replace version(14)


/*This file merges other variables */

/*

Procedures:

1. Merge with registeration city and province of firms


2. Merge with death rate in Taiping Rebellion and geographical features data


3. Bring back location 

4. GDP

*/



global path ""
global rawdata "${path}/Data"
global data "${path}/Data"
global output "${path}/Data"



*Step 1: merge registeration city and province

use "${data}/temp_Jinshi and CSMSR_Merged.dta", clear
merge 1:1 code year using "${rawdata}/2000-2018公司注册省份和城市_修订后.dta", keep(1 3)
keep if _merge == 3                         //new listed and delisted firms, 70 observations are dropped in master file
drop _merge
saveold "${data}/temp_Jinshi_CSMSR_City_Merged.dta", replace version(14)






*Step 2: merge with death rate in Taiping Rebellion and geographical features data

*2.1 merge death rate in Taiping Rebellion
merge m:1 注册城市 using "${rawdata}/Death rate in Taiping Rebellion and City.dta", keep(1 3) nogen
replace 太平天国死亡比例 = 0 if 太平天国死亡比例 == .

*2.2 merge geographical features data
merge m:1 注册地址省 using "${rawdata}/altitude altitude coastal.dta", keep(1 3) nogen
saveold "${data}/temp_Jinshi_CSMSR_City_Taiping_geographical features_Merged.dta", replace version(14)



*Step 3: Bring back location
  
use "${rawdata}/2000-2018公司注册地址坐标_20191110.dta", clear
duplicates drop code year, force
keep code year d b
saveold "${data}/temp_loc.dta", replace version(14)


use "${data}/temp_Jinshi_CSMSR_City_Taiping_geographical features_Merged.dta", clear
winsor2 orec1 jsh_100, cuts(0 99) 
merge 1:1 code year using "${data}/temp_loc.dta", keep(1 3) nogen



* Step 4: Obtain provide level GDP data
sort 注册地址省 year
merge m:1 注册地址省 year using "${rawdata}/注册地址和办公地址GDP及人均GDP.dta", keep(1 3) nogen keepusing(GDP亿元1 人均GDP元1)


saveold "${data}/Regression.dta", replace version(14)
/*This file is to produce regression file with disclosure quality as the dependent variable */

/*

Procedures:

1. Import disclosure qulity data
2. Merge with the data produced by 01_JinshiNum, 02_CSMAR_Jinshi_Mwerge, 03_Registered city, province, Taiping rebellion and geographical data._Merge


*/

global path ""
global rawdata "${path}/Data"
global data "${path}/Data"
global output "${path}/Data"




*Step 1 Import disclosure qulity data
import excel "${rawdata}/disclosure_shenzhen_01-18", sheet("Sheet1") firstrow clear
destring 公司代码, g(code)
rename 考评年度 year
gen evaluation = 0
replace evaluation = 4 if 考评结果 == "A"
replace evaluation = 3 if 考评结果 == "B"
replace evaluation = 2 if 考评结果 == "C"
replace evaluation = 1 if 考评结果 == "D"

keep code year evaluation
duplicates drop
sort code year

saveold "${data}/temp_discl.dta", version(14) replace



*Step 2 Merge with the data produced by 01_JinshiNum, 02_CSMAR_Jinshi_Mwerge, 03_Registered city, province, Taiping rebellion and geographical data._Merge

use "${data}/Regression.dta", clear
merge 1:1 code year using "${data}/temp_discl.dta", keep(1 3) nogen



saveold "${data}/Regression_disclosure quality.dta", replace version(14)
/*This file merges CSMAR with Regression_disclosure qualtiy.dta */
 

/*

Procedures:

1. Import CSMAR data
2. Merge CSMAR data with Regression_disclsure.dta, produced by 04_disclosure qulity




*/



global path ""
global rawdata "${path}/Data"
global data "${path}/Data"
global output "${path}/Data"



* Step 1: import CSMAR data

* 1.1 Process Balance Sheet data


/*data download from CSMAR directly*/
import delimited using "${rawdata}/FS_Combas Balance Sheet1999-2018_16Jan2020.csv", clear
rename stkcd code
gen year = substr(accper, 1, 4)
destring year, replace
gen month = substr(accper, 6, 7)
keep if month == "12-31"
keep if typrep == "A"
rename a001000000 asset
xtset code year
gen Lasset =  L.asset
label var Lasset "previous year asset"
order year, after(code)
order Lasset, after(year)
keep code year Lasset 
drop if year < 2000
saveold "${data}/temp_csmar_Lasset.dta", replace version(14)


* 1.2 Process Income Statement data



/*import data downloaded from CSMAR. */

import delimited using "${rawdata}/FS_Comins_1999-2018_05Jan2020", encoding( "unicode") clear
rename stkcd code
gen year = substr(accper, 1, 4)
destring year, replace
gen month = substr(accper, 6, 7)
keep if month == "12-31"
keep if typrep == "A"
rename b002000000 NI
xtset code year
drop if year < 2000
keep code year NI  
saveold "${data}/temp_csmar_income statement.dta", replace version(14)



* 1.3 Process Equity Nature data

/*import data downloaded from CSMAR. */
import excel "${rawdata}/EN_EquityNatureAll16Jan2018.xlsx", sheet("Sheet1") firstrow clear
destring 证券代码, g(code)
gen year = substr(截止日期, 1, 4)
destring year, replace
gen STATE = 0
replace STATE = 1 if 股权性质编码 == "1"
label var STATE "state-own"
gen Central = 0
replace Central = 1 if (层级判断 == "国家"|层级判断 == "国家,央企"|层级判断 == "国家,市"|层级判断 == "国家,市国企"|层级判断 == "央企")
gen Local = 0 
replace Local = 1 if (层级判断 == "市"|层级判断 == "市,央企"|层级判断 == "市,市国企"|层级判断 == "市国企"|层级判断 == "市国企,央企"|层级判断 == "省"|层级判断 == "省,市"|层级判断 == "省,省国企"|层级判断 == "省国企")
keep code year STATE Central Local   
saveold "${data}/temp_EquityNature.dta", replace version(14)



* Step 2: Merge CSMAR data with Regression_disclsure.dta, produced by 04_disclosure qulity

*merge Balance Sheet data
use "${data}/Regression_disclosure quality.dta", clear
merge 1:1 code year using "${data}/temp_csmar_Lasset.dta", keep(1 3)
drop _merge


*merge income statement data

merge 1:1 code year using "${data}/temp_csmar_income statement.dta", keep(1 3)
drop _merge

*merge equity nature data
merge 1:1 code year using "${data}/temp_EquityNature.dta", keep(1 3)
drop _merge



saveold "${data}/Regression_controls.dta", replace version(14)



global path ""
global rawdata "${path}/Data"
global data "${path}/Data"
global output "${path}/Data"











**************************************************************************************
**************************************************************************************
**************************************************************************************


/*Part 1 improt and process data*/
/*1. Number of scholars in Ming around headquarters*/
/*2. Number of books printed in Printing houses in Ming around headquarters*/
/*3. Dividend*/
/*4. Population in Qing*/

/*Part 2 merge data */


**************************************************************************************
**************************************************************************************
**************************************************************************************











/*Part 1 import and process data*/

/*1. Number of scholars in Ming around headquarters*/
*Import scholars in ming
import excel "${rawdata}/明儒学案数据汇总.xlsx", sheet("理学学派") firstrow clear
drop if 东经 ==. | 北纬 ==.
bys 东经 北纬: gen totalscholar = _N
duplicates drop 东经 北纬, force
sort 东经 北纬
keep 东经 北纬 totalscholar
saveold "${data}/tempnummingscholar1.dta", replace version(14)

import excel "${rawdata}/明儒学案数据汇总.xlsx", sheet("心学学派") firstrow clear
drop if 东经 ==. | 北纬 ==.
bys 东经 北纬: gen totalscholar = _N
duplicates drop 东经 北纬, force
sort 东经 北纬
keep 东经 北纬 totalscholar
saveold "${data}/tempnummingscholar2.dta", replace version(14)

append using "${data}/tempnummingscholar1.dta"
saveold "${data}/tempnummingscholar3.dta", replace version(14)

* Reshape data
count
local num = `r(N)'
forvalues i=1(1)`num'{
	gen dongjing`i' = 东经[_n+`i'-1]*3.1415926/180
	gen beiwei`i' = 北纬[_n+`i'-1]*3.1415926/180
	gen totalscholar`i' = totalscholar[_n+`i'-1]
}

keep if _n==1

drop 东经 北纬 totalscholar
gen id =1
sort id
order totalscholar*
saveold "${data}/numscholarwide.dta", replace version(14)








/*2. Number of books printed in Printing houses in Ming around headquarters*/
import excel "${rawdata}/明朝书坊刻书数量.xlsx", firstrow clear

keep 东经 北纬 明代刻书数量
rename 明代刻书数量 totalbook
saveold "${data}/tempnumbook.dta", replace version(14)

*reshape data

count
local num = `r(N)'
forvalues i=1(1)`num'{
	gen dongjing`i' = 东经[_n+`i'-1]*3.1415926/180
	gen beiwei`i' = 北纬[_n+`i'-1]*3.1415926/180
	gen totalbook`i' = totalbook[_n+`i'-1]
}

keep if _n==1

drop 东经 北纬 totalbook
gen id =1
sort id
order totalbook*
saveold "${data}/numbookwide.dta", replace version(14)






* Import headquarter data
clear 
use "${rawdata}/2000-2018公司注册地址坐标_20191110.dta", clear
gen id =1
duplicates drop code year, force
drop auqing_100 auming_100



merge m:1 id using "${data}/numscholarwide.dta", nogen keep(3)



* Compute distance between scholars and headqurters
forvalues i=1(1)139{
	gen cost`i'=sin(b)*sin(beiwei`i')+cos(b)*cos(beiwei`i')*cos(dongjing`i'-d)
	gen dis`i' =6378.198*(0.5*3.1415926-atan(cost`i'/sqrt(1-cost`i'*cost`i')))
	replace dis`i' = 0 if dis`i' ==. // this happens if the headquarter and scholar location coincide
	drop cost`i'
}


* Compute scholar number within a 50 radius. 
sort code year
foreach i in 50{
	
	preserve
	forvalues j=1(1)139{
		replace totalscholar`j' = totalscholar`j'*(dis`j' <= `i') // set the number of scholar to zero if the distance exceeds the cutoff
	}
	
	egen scholar_`i' = rowtotal( totalscholar1-totalscholar139)
	keep code year scholar_`i'
	sort code year
	
	saveold "${data}/tempscholar_`i'.dta", replace  version(12)
	restore	
	merge 1:1 code year using "${data}/tempscholar_`i'.dta", nogen keep(3)
}
drop totalscholar* dis* beiwei* dongjing*





merge m:1 id using "${data}/numbookwide.dta", nogen keep(3)
* Compute distance between printing houses and headqurters 
forvalues i=1(1)19{
	gen cost`i'=sin(b)*sin(beiwei`i')+cos(b)*cos(beiwei`i')*cos(dongjing`i'-d)
	gen dis`i' =6378.198*(0.5*3.1415926-atan(cost`i'/sqrt(1-cost`i'*cost`i')))
	replace dis`i' = 0 if dis`i' ==. // this happens if the headquarter and scholar location coincide
	drop cost`i'
}


* Compute book number within a 50 radius. 
sort code year
foreach i in 50{
	
	preserve
	forvalues j=1(1)19{
		replace totalbook`j' = totalbook`j'*(dis`j' <= `i') // set the number of jinshi to zero if the distance exceeds the cutoff
	}
	
	egen book_`i' = rowtotal( totalbook1-totalbook19)
	keep code year book_`i'
	sort code year
	
	saveold "${data}/tempbook_`i'.dta", replace  version(12)
	restore	
	merge 1:1 code year using "${data}/tempbook_`i'.dta", nogen keep(3)
}
drop totalbook* dis* beiwei* dongjing*



keep code year scholar_50  book_50 
label var scholar_50 "Num of Ming scholar within 50"
label var book_50 "Num of Ming scholar within 50"

sum scholar_50 book_50,d
saveold "${data}/numscholarbook_codeyear.dta", replace version(14)


















/*3 import dividend data downloaded from CSMAR. */
clear
import delimited "${rawdata}/CD_Dividend_2000-2018_15May2020.csv
rename stkcd code  
rename finyear year
keep if disye == 2
rename numdiv div_total 
keep code year div_total
duplicates tag code year, gen(tag)
drop if (tag != 0 & div_total == .) // some firm-years have more than one copies, only keep non-zero one
sort code year
by code year: gen nvals = _n==1
keep if nvals ==1
drop nvals
drop tag
save "${data}/tempt_div.dta", replace

clear
import delimited using "${rawdata}/FS_Comins_1999-2018_05Jan2020", encoding( "unicode") clear
rename stkcd code
gen year = substr(accper, 1, 4)
destring year, replace
gen month = substr(accper, 6, 7)
keep if month == "12-31"
keep if typrep == "A"
rename b002000000 profit // net income
keep code year profit

merge 1:1 code year using "${data}/tempt_div.dta", nogen keep(3)
replace div_total = 0 if div_total == .
gen cdiv = div_total / profit
label var cdiv "dividend/net income"
keep code year profit div_total cdiv

drop if profit <= 0
drop if profit == .
drop if cdiv > 1
sort code year
winsor2 cdiv, cuts(1 99) replace  


save "${data}/tempt_cdiv.dta", replace












/*4. Population and taxed in Qing*/
clear
import excel "${rawdata}/population and taxes in Qing.xlsx", firstrow clear
rename 省份 注册地址省
rename 人口万人 popQing

saveold "${data}/population and taxes in Qing.dta", replace version(14)










/*Part 2 merge data */


*merge scholar and book in ming data
clear    
use "${data}/Regression_controls.dta", clear
merge 1:1 code year using "${data}/numscholarbook_codeyear.dta", nogen keep(3)



*merge dividend data
merge 1:1 code year using "${data}/tempt_cdiv.dta"
keep if _merge == 1 | _merge  == 3
drop _merge profit 
drop div_total 

*merge pop and tax in Qing data
merge m:1 注册地址省 using "${data}/population and taxes in Qing.dta", nogen keep(3)

saveold "${data}/Regression_more_controls.dta", replace version(14)


global path ""
global rawdata "${path}/Data"
global data "${path}/Data"
global output "${path}/Data"


/*
import holding data


数据来源是wind。Jiang et al.(2010)的数据来源也是wind，CSMAR的数据是所有机构持股的明细。
比如mutual fund holding，需要把每个fund的持股加总。Wind直接给出了mutual fund持股比例。
*/


********************************************************************************
********************************************************************************
**1. import holding data********************************************************
********************************************************************************
********************************************************************************

*1.1 import mutual fund holding data
import excel "${rawdata}/机构投资者基金社保基金持有股份比例.xlsx", sheet("万得") firstrow clear
keep 证券代码 基金持股比例报告期2000年报单位 基金持股比例报告期2001年报单位 ///
基金持股比例报告期2002年报单位 基金持股比例报告期2003年报单位 基金持股比例报告期2004年报单位 ///
基金持股比例报告期2005年报单位 基金持股比例报告期2006年报单位 基金持股比例报告期2007年报单位 ///
基金持股比例报告期2008年报单位 基金持股比例报告期2009年报单位 基金持股比例报告期2010年报单位 ///
基金持股比例报告期2011年报单位 基金持股比例报告期2012年报单位 基金持股比例报告期2013年报单位 ///
基金持股比例报告期2014年报单位 基金持股比例报告期2015年报单位 基金持股比例报告期2016年报单位 ///
基金持股比例报告期2017年报单位 基金持股比例报告期2018年报单位

rename 基金持股比例报告期*年报单位 y*
gather y2000 y2001 y2002 y2003 y2004 y2005 y2006 y2007 y2008 y2009 y2010 y2011 ///
y2012 y2013 y2014 y2015 y2016 y2017 y2018 , variable(year) value(mutualfund)

gen code = substr(证券代码,1,6)
destring code, replace
gen year1 = substr(year,2,5)
destring year1,replace
drop year
rename year1 year
drop 证券代码
order mutualfund, after(year)

saveold "${data}/mutualfund.dta", replace version(14)




*1.2 import social fund holding data
import excel "${rawdata}/机构投资者基金社保基金持有股份比例.xlsx", sheet("万得") firstrow clear
keep 证券代码 社保基金持股比例报告期2000年报单位 社保基金持股比例报告期2001年报单位 ///
社保基金持股比例报告期2002年报单位 社保基金持股比例报告期2003年报单位 社保基金持股比例报告期2004年报单位 ///
社保基金持股比例报告期2005年报单位 社保基金持股比例报告期2006年报单位 社保基金持股比例报告期2007年报单位 ///
社保基金持股比例报告期2008年报单位 社保基金持股比例报告期2009年报单位 社保基金持股比例报告期2010年报单位 ///
社保基金持股比例报告期2011年报单位 社保基金持股比例报告期2012年报单位 社保基金持股比例报告期2013年报单位 ///
社保基金持股比例报告期2014年报单位 社保基金持股比例报告期2015年报单位 社保基金持股比例报告期2016年报单位 ///
社保基金持股比例报告期2017年报单位 社保基金持股比例报告期2018年报单位

rename 社保基金持股比例报告期*年报单位 y*
gather y2000 y2001 y2002 y2003 y2004 y2005 y2006 y2007 y2008 y2009 y2010 y2011 ///
y2012 y2013 y2014 y2015 y2016 y2017 y2018 , variable(year) value(socialfund)

gen code = substr(证券代码,1,6)
destring code, replace
gen year1 = substr(year,2,5)
destring year1,replace
drop year
rename year1 year
drop 证券代码
order socialfund, after(year)

saveold "${data}/socialfund.dta", replace version(14)




global path ""
global rawdata "${path}/Data"
global data "${path}/Data"
global output "${path}/Data"



/*
1. import and data
1.1 return
1.1.1 stock return
1.1.2 market return
1.1.3 stock excess return
1.2 independent director
1.3 seperation


*/

********************************************************************************
********************************************************************************
****************1. import and data**********************************************
********************************************************************************
********************************************************************************





********************************************************************************
*1.1 Return*********************************************************************
********************************************************************************


*1.1 import and calculate stock returns
import excel "${rawdata}/TRD_Mnth_20220919.xlsx", sheet("sheet1") firstrow clear
destring 证券代码, gen(code)
rename 考虑现金红利再投资的月个股回报率 r 
gen year = cond(real(substr(交易月份,6,2))>4,real(substr(交易月份,1,4)),real(substr(交易月份,1,4))-1) 
order year,after(交易月份)
g t = r+1 
gen month = substr(交易月份,6,2)
order month, after(year)
destring month, replace
sort code year month
by code year: replace t = (1+r)*t[_n-1] if _n >= 2  
by code year: g R = t[_N]-1 
order t, after(month)
order R, after(t)
duplicates drop code year R, force
duplicates report code year 
saveold "${data}/stock yearly return.dta", replace version(14)







*1.2 import and calculate market returs 
import excel "${rawdata}/TRD_Cnmont_20220919.xlsx", sheet("sheet1") firstrow clear 
keep if 市场类型 == 21 
rename 考虑现金红利再投资的综合月市场回报率等权平均法 rm 
gen year = cond(real(substr(交易月份,6,2))>4,real(substr(交易月份,1,4)),real(substr(交易月份,1,4))-1) 
order year,after(交易月份)
g tm = rm+1                   
gen month = substr(交易月份,6,2)
order month, after(year)
destring month, replace
sort year month
by year: replace tm = (1+rm)*tm[_n-1] if _n>=2 
by year: gen Rm = tm[_N]-1 
order tm, after(rm)
order Rm, after(tm)
keep year Rm
duplicates drop year Rm, force
duplicates report year 
saveold "${data}/market yearly return.dta", replace version(14)



*1.3 Market return
use "${data}/stock yearly return.dta"
duplicates report code year
keep code year R
merge m:1 year using "${path}/Data/market yearly return.dta"
keep if _merge==3
drop _merge
gen ret = R-Rm /

saveold "${data}/return.dta", replace version(14)




********************************************************************************
*1.2 independent director*******************************************************
********************************************************************************


import excel "${rawdata}/CG_ManagerShareSalary20220620.xlsx", sheet("sheet1") firstrow clear
destring 证券代码, gen(code)
gen year = substr(统计截止日期, 1, 4)
destring year, replace
order code, first
order year, after(code)
keep if 统计口径=="1"
gen IndireRatio1 = 其中独立董事人数/董事人数
label var IndireRatio1 年末在职比率
rename 其中独立董事人数 indirector1
label var indirector1 年末在职人数
keep code year indirector1 IndireRatio1
saveold "${data}/independent director1.dta", replace version(14)


















********************************************************************************
* 1.3 seperation****************************************************************
********************************************************************************
import excel "${rawdata}/EN_EquityNatureAll20220620.xlsx", sheet("sheet1") firstrow clear
destring 证券代码, gen(code)
gen year = substr(截止日期, 1, 4)
destring year, replace
order year, after(code)
keep code year 两权分离率
rename 两权分离率 seperation
saveold "${data}/seperation rate.dta", replace version(14)








global path ""
global rawdata "${path}/Data"
global data "${path}/Data"
global output "${path}/Data"



*************************************************************
* Compute the number of jinshi around CEO birthplace
*************************************************************


* Import CEO birthplace data
clear
set maxvar 6000
use "${rawdata}/CEO出生地2007-2020.dta", clear
gen d = 经度*3.1415926/180
gen b = 纬度*3.1415926/180
gen id =1
duplicates drop code year, force





merge m:1 id using "${data}/numjinshiwide.dta", nogen keep(3)



* Compute distance
forvalues i=1(1)1353{
	gen cost`i'=sin(b)*sin(beiwei`i')+cos(b)*cos(beiwei`i')*cos(dongjing`i'-d)
	gen dis`i' =6378.198*(0.5*3.1415926-atan(cost`i'/sqrt(1-cost`i'*cost`i')))
	replace dis`i' = 0 if dis`i' ==. // this happens if the headquarter and jinshi location coincide
	drop cost`i'
}


* Compute jinshi number within a 50 radius. 
sort code year
foreach i in 50{
	
	preserve
	forvalues j=1(1)1353{
		replace totaljinshi`j' = totaljinshi`j'*(dis`j' <= `i') // set the number of jinshi to zero if the distance exceeds the cutoff
	}
	
	egen jsh_`i' = rowtotal( totaljinshi1-totaljinshi1353)
	keep code year jsh_`i'
	sort code year
	
	saveold "${data}/tempjsh_`i'.dta", replace  version(12)
	restore	
	merge 1:1 code year using "${data}/tempjsh_`i'.dta", nogen keep(3)
}
drop totaljinshi* dis* beiwei* dongjing*


rename jsh_50 jsh_50_CEObirth

rename 经度 CEO出生地经度
rename 纬度 CEO出生地纬度
rename city CEO出生城市
rename prov CEO出生省
rename name CEOname_birth
rename gender CEOgender_birth
rename age CEOage_birth
rename birthplace CEObirthplace


drop  b d id 

saveold "${data}/CEO出生地_jsh.dta", replace version(14)

********************************************************************************
********************************************************************************
***Set paths and load data 

global path ""
global rawdata "${path}/Data"
global data "${path}/Data"
global output "${path}/Data"


use "${data}/Regression_more_controls.dta", clear 

********************************************************************************
********************************************************************************
***Clean and Merge Data 

* Merge in separation
merge 1:1 code year using "${data}/seperation rate.dta", keep(1 3) nogen 

* Merge governance 
merge 1:1 code year using  "${data}/independent director1.dta", keep(1 3) nogen 

* Merge IO
merge 1:1 code year using "${data}/mutualfund.dta", keep(1 3) nogen 
merge 1:1 code year using "${data}/socialfund.dta", keep(1 3) nogen 

* Merge return
merge 1:1 code year using  "${data}/return.dta", keep(1 3) nogen 

* Merge CEO
merge 1:1 code year using "${data}/CEO出生地_jsh.dta", keep(1 3) nogen


** Variable creation
egen city =  group(注册城市) 
egen indus = group(ind)
egen prov = group(注册地址省)

rename 太平天国死亡比例 deathrate
egen highdeath=xtile(deathrate),nq(3)
replace highdeath=0 if highdeath <=2
replace highdeath=1 if highdeath ==3

gen longitude = floor(d*180/3.1415926)
gen latitude = floor(b*180/3.1415926)

gen gdp = GDP亿元1/10000
gen lngdp = log(gdp)

gen id = 1
gen alti=log(海拔)

gen lnpopQing = log(popQing)

gen orec1_w0=orec1_w
replace orec1_w = . if year>=2007

replace book_50 = book_50/1000

rename 是否沿海 sea
gen hanprovince = 注册地址省!="西藏"&注册地址省!="新疆" &注册地址省!= "内蒙古"&注册地址省!= "广西"&注册地址省!= "宁夏"

gen croa = NI/Lasset
winsor2 croa, cuts(1 99) replace

gen logasset=log(Lasset)
winsor2 logasset, cuts(1 99) replace 

gen pre2007 = year<2007

gen north = latitude >30
gen cityprov = 注册地址省 == "北京市" | 注册地址省 == "上海市" | 注册地址省 == "天津市" | 注册地址省 == "重庆市" 

replace Local = 0 if Local ==.
replace Central = 0 if Central ==.
replace cdiv = 0 if cdiv ==.

egen highjsh_50 = xtile(jsh_50) if orec1_w !=., nq(2)
replace highjsh_50 = highjsh_50 - 1


saveold "${data}/data_for_regression.dta", replace version(14)
/*Step 1 Import excel data and process
  Step 2 Append all files
 
  
  
*/


global path ""
global rawdata "${path}"
global data "${path}/Data20230909"
global output "${path}/Output20230909"




*1.1 1957-1972


*********************1957-1972**********************************
****************************************************************



clear
cd "${path}\1956-1981"



local myfiles: dir "${path}\1956-1981" files "19**最终版.xls", respectcase 
dis `"`myfiles'"'

foreach f in `myfiles' {
    import excel "`f'", sheet("Sheet1") firstrow clear   
    
	drop if 省1 == "" 

	bysort 省1:egen weifa_Pr1 = sum(违法出现次数)  
	bysort 省1:egen zhapian_Pr1 = sum(诈骗出现次数)  
	bysort 省1:egen tanwu_Pr1 = sum(贪污出现次数)
	bysort 省1:egen daoqie_Pr1 = sum(盗窃出现次数)

	label var weifa_Pr1 "违法出现次数"
	label var zhapian_Pr1 "诈骗出现次数"
	label var tanwu_Pr1 "贪污出现次数"
	label var daoqie_Pr1 "盗窃出现次数"
	   
	egen Num_article_Pr1 = nvals(文章编号), by(省1)
	label var Num_article_Pr1 "文章数"
		


	duplicates drop 省1, force
	keep 年份 省1 weifa_Pr1 zhapian_Pr1 tanwu_Pr1 daoqie_Pr1  Num_article_Pr1   
	rename 省1 province
	rename 年份 year


	

	save "${path}\1956-1981/`f'fraud.dta", replace  


}







*1.2 1956，1973-1981

*********************1956，1973-1981****************************
****************************************************************




clear
cd "${path}\1956-1981"


local myfiles: dir "${path}\1956-1981" files "19**最终版.xlsx", respectcase
dis `"`myfiles'"'

foreach f in `myfiles' {
    import excel "`f'", sheet("Sheet") firstrow clear
    drop if 省1 == "" 


	bysort 省1:egen weifa_Pr1 = sum(违法出现次数)  
	bysort 省1:egen zhapian_Pr1 = sum(诈骗出现次数)  
	bysort 省1:egen tanwu_Pr1 = sum(贪污出现次数)
	bysort 省1:egen daoqie_Pr1 = sum(盗窃出现次数)

	label var weifa_Pr1 "违法出现次数"
	label var zhapian_Pr1 "诈骗出现次数"
	label var tanwu_Pr1 "贪污出现次数"
	label var daoqie_Pr1 "盗窃出现次数"
	   
	egen Num_article_Pr1 = nvals(文章编号), by(省1)
	label var Num_article_Pr1 "文章数"
		


	duplicates drop 省1, force
	keep 年份 省1 weifa_Pr1 zhapian_Pr1 tanwu_Pr1 daoqie_Pr1   Num_article_Pr1   
	rename 省1 province
	rename 年份 year

	

	save "${path}\1956-1981/`f'fraud.dta", replace


}







*1.3 1983-2003
*********************1983-2003**********************************
****************************************************************






clear
cd "${path}\1983-2003"


local myfiles: dir "${path}\1983-2003" files "人民日报****.xlsx", respectcase
dis `"`myfiles'"'
foreach f in `myfiles' {
    import excel "`f'", sheet("Sheet") firstrow clear
    drop if 省1 == "" 



	bysort 省1:egen weifa_Pr1 = sum(违法出现次数)  
	bysort 省1:egen zhapian_Pr1 = sum(诈骗出现次数)  
	bysort 省1:egen tanwu_Pr1 = sum(贪污出现次数)
	bysort 省1:egen daoqie_Pr1 = sum(盗窃出现次数)

	label var weifa_Pr1 "违法出现次数"
	label var zhapian_Pr1 "诈骗出现次数"
	label var tanwu_Pr1 "贪污出现次数"
	label var daoqie_Pr1 "盗窃出现次数"
	   
	egen Num_article_Pr1 = nvals(文章编号), by(省1)
	label var Num_article_Pr1 "文章数"
		


	duplicates drop 省1, force
	keep 年份 省1 weifa_Pr1 zhapian_Pr1 tanwu_Pr1 daoqie_Pr1   Num_article_Pr1   
	rename 省1 province
	rename 年份 year

	
    destring year, replace   
	save "${path}\1983-2003/`f'fraud.dta", replace


}





*1.4 2004-2020

*********************2004-2020*****************************************






clear
cd "${path}\2004-2020"


local myfiles: dir "${path}\2004-2020" files "****.xlsx", respectcase
dis `"`myfiles'"'
foreach f in `myfiles' {
    import excel "`f'", sheet("Sheet") firstrow clear
    drop if 省1 == ""


	bysort 省1:egen weifa_Pr1 = sum(违法出现次数)  
	bysort 省1:egen zhapian_Pr1 = sum(诈骗出现次数)  
	bysort 省1:egen tanwu_Pr1 = sum(贪污出现次数)
	bysort 省1:egen daoqie_Pr1 = sum(盗窃出现次数)

	label var weifa_Pr1 "违法出现次数"
	label var zhapian_Pr1 "诈骗出现次数"
	label var tanwu_Pr1 "贪污出现次数"
	label var daoqie_Pr1 "盗窃出现次数"
	   
	egen Num_article_Pr1 = nvals(文章编号), by(省1)
	label var Num_article_Pr1 "文章数"
		


	duplicates drop 省1, force
	keep 年份 省1 weifa_Pr1 zhapian_Pr1 tanwu_Pr1 daoqie_Pr1   Num_article_Pr1   
	rename 省1 province
	rename 年份 year

	
    destring year, replace
	save "${path}\2004-2020/`f'fraud.dta", replace


}








*1.5 1949-1955, 1982

***********************************************************************






clear
cd "${path}\1949-1956 1982"


local myfiles: dir "${path}\1949-1956 1982" files "人民日报****.xlsx", respectcase
dis `"`myfiles'"'
foreach f in `myfiles' {
    import excel "`f'", sheet("Sheet") firstrow clear
    drop if 省1 == "" 



	bysort 省1:egen weifa_Pr1 = sum(违法出现次数)  
	bysort 省1:egen zhapian_Pr1 = sum(诈骗出现次数)  
	bysort 省1:egen tanwu_Pr1 = sum(贪污出现次数)
	bysort 省1:egen daoqie_Pr1 = sum(盗窃出现次数)

	label var weifa_Pr1 "违法出现次数"
	label var zhapian_Pr1 "诈骗出现次数"
	label var tanwu_Pr1 "贪污出现次数"
	label var daoqie_Pr1 "盗窃出现次数"
	   
	egen Num_article_Pr1 = nvals(文章编号), by(省1)
	label var Num_article_Pr1 "文章数"
		


	duplicates drop 省1, force
	keep 年份 省1 weifa_Pr1 zhapian_Pr1 tanwu_Pr1 daoqie_Pr1   Num_article_Pr1   
	rename 省1 province
	rename 年份 year

	
    destring year, replace
	save "${path}\1949-1956 1982/`f'fraud.dta", replace


}
















*Step 2 Append all files



clear
cd "${path}\1956-1981"
use 1956最终版.xlsxfraud.dta

*append 1957-1972
forvalues s = 1957/1972{
    append using `s'最终版.xlsfraud.dta
}

*append 1973-1981
forvalues s = 1973/1981{
    append using `s'最终版.xlsxfraud.dta
}

*append 1983-2003
cd "${path}\1983-2003"
forvalues s = 1983/2003{
    append using 人民日报`s'.xlsxfraud.dta
}


*append 2004-2020
cd "${path}\2004-2020"
forvalues s = 2004/2020{
    append using `s'.xlsxfraud.dta
}

*append 1949-1955
cd "${path}\1949-1956 1982"
forvalues s = 1949/1955{
    append using 人民日报`s'.xlsxfraud.dta
}

*append 1982
cd "${path}\1949-1956 1982"
append using 人民日报1982.xlsxfraud.dta

encode province, gen(prov) 
xtset prov year

save "${data}\1949-2020fraud.dta", replace

/*

The raw data is a set of excel files based on data from the People's Daily. 

To generate the raw data, for each article, we first determine the location (i.e., province and city)
and then count the number of keywords in each article. The keyword list can be found in the paper. 

* 

Step 1 Import excel data and process
Step 2 Append all files
 
*/


global path ""
global rawdata "${path}"
global data "${path}/Data20230906"
global output "${path}/Output20230906"




*Step 1 Import and process 



*1.1 1957-1972


*********************1957-1972**********************************
****************************************************************



clear
cd "${path}\1956-1981"


local myfiles: dir "${path}\1956-1981" files "19**最终版.xls", respectcase 
dis `"`myfiles'"'

foreach f in `myfiles' {
    import excel "`f'", sheet("Sheet1") firstrow clear   
    
	drop if 省1 == ""  	

	egen Co_To2_noneg = rowtotal(仁慈出现次数 仁爱出现次数 道义出现次数 公义出现次数 ///          
	正义出现次数 礼貌出现次数 礼仪出现次数 礼节出现次数 智谋出现次数 才智出现次数 ///
	信赖出现次数 诚信出现次数 诚实出现次数 忠诚出现次数 孝顺出现次数 孝道出现次数 /// 
	和平出现次数  和气出现次数 廉洁出现次数 清廉出现次数 廉政出现次数 ///
	廉正出现次数)

	bysort 省1:egen Co2_Pr_noneg1 = sum(Co_To2_noneg)
				
	egen Num_article_Pr1 = nvals(文章编号), by(省1)
	label var Num_article_Pr1 "文章数"
		
	duplicates drop 省1, force 
    keep 年份 省1 Co2_Pr_noneg1 Num_article_Pr1
	rename 省1 province 
	rename 年份 year

	save "${path}\1956-1981/`f'.dta", replace


}







*1.2 1956，1973-1981

*********************1956，1973-1981****************************
*************格式为.xlsx，excel中sheet 名称为"sheet"************
****************************************************************




clear



local myfiles: dir "${path}\1956-1981" files "19**最终版.xlsx", respectcase
dis `"`myfiles'"'

foreach f in `myfiles' {
    import excel "`f'", sheet("Sheet") firstrow clear
    drop if 省1 == "" 

	
   	egen Co_To2_noneg = rowtotal(仁慈出现次数 仁爱出现次数 道义出现次数 公义出现次数 ///          
	正义出现次数 礼貌出现次数 礼仪出现次数 礼节出现次数 智谋出现次数 才智出现次数 ///
	信赖出现次数 诚信出现次数 诚实出现次数 忠诚出现次数 孝顺出现次数 孝道出现次数 /// 
	和平出现次数  和气出现次数 廉洁出现次数 清廉出现次数 廉政出现次数 ///
	廉正出现次数)

	
	bysort 省1:egen Co2_Pr_noneg1 = sum(Co_To2_noneg)  
		
	egen Num_article_Pr1 = nvals(文章编号), by(省1)
	label var Num_article_Pr1 "文章数"
			
	duplicates drop 省1, force
	keep 年份 省1  Co2_Pr_noneg1 Num_article_Pr1  
	rename 省1 province
	rename 年份 year
	

	save "${path}\1956-1981/`f'.dta", replace


}







*1.3 1983-2003
*********************1983-2003**********************************
*************格式为.xlsx sheet 名称为"sheet"********************
****************************************************************






clear
cd "${path}\1983-2003"


local myfiles: dir "${path}\1983-2003" files "人民日报****.xlsx", respectcase
dis `"`myfiles'"'
foreach f in `myfiles' {
    import excel "`f'", sheet("Sheet") firstrow clear
    drop if 省1 == ""

	
   
   	egen Co_To2_noneg = rowtotal(仁慈出现次数 仁爱出现次数 道义出现次数 公义出现次数 ///          
	正义出现次数 礼貌出现次数 礼仪出现次数 礼节出现次数 智谋出现次数 才智出现次数 ///
	信赖出现次数 诚信出现次数 诚实出现次数 忠诚出现次数 孝顺出现次数 孝道出现次数 /// 
	和平出现次数  和气出现次数 廉洁出现次数 清廉出现次数 廉政出现次数 ///
	廉正出现次数)
   
	
	   
	bysort 省1:egen Co2_Pr_noneg1 = sum(Co_To2_noneg)  
		
		
	egen Num_article_Pr1 = nvals(文章编号), by(省1)
	label var Num_article_Pr1 "文章数"
		
		
	duplicates drop 省1, force
    keep 年份 省1 Co2_Pr_noneg1 Num_article_Pr1 
	rename 省1 province
	rename 年份 year
	
		
	

    destring year, replace   
	save "${path}\1983-2003/`f'.dta", replace


}





*1.4 2004-2020

*********************2004-2020*****************************************
*************格式为.xlsx sheet 名称为"sheet"***************************
*************2004和2005词频处理有问题，提前进行了修改，可能需要重新做**






clear
cd "${path}\2004-2020"


local myfiles: dir "${path}\2004-2020" files "****.xlsx", respectcase
dis `"`myfiles'"'
foreach f in `myfiles' {
    import excel "`f'", sheet("Sheet") firstrow clear
    drop if 省1 == "" 

	
   	egen Co_To2_noneg = rowtotal(仁慈出现次数 仁爱出现次数 道义出现次数 公义出现次数 ///         
	正义出现次数 礼貌出现次数 礼仪出现次数 礼节出现次数 智谋出现次数 才智出现次数 ///
	信赖出现次数 诚信出现次数 诚实出现次数 忠诚出现次数 孝顺出现次数 孝道出现次数 /// 
	和平出现次数  和气出现次数 廉洁出现次数 清廉出现次数 廉政出现次数 ///
	廉正出现次数)
   
	
	   
	bysort 省1:egen Co2_Pr_noneg1 = sum(Co_To2_noneg)  
		
		
	egen Num_article_Pr1 = nvals(文章编号), by(省1)
	label var Num_article_Pr1 "文章数"
		

	duplicates drop 省1, force
    keep 年份 省1 Co2_Pr_noneg1 Num_article_Pr1 
	rename 省1 province
	rename 年份 year

	
    destring year, replace
	save "${path}\2004-2020/`f'.dta", replace


}








*1.5 1949-1955, 1982

*********************2049-1955,1982************************************
*************格式为.xlsx sheet 名称为"sheet"***************************
***********************************************************************






clear
cd "${path}\1949-1956 1982"


local myfiles: dir "${path}\1949-1956 1982" files "人民日报****.xlsx", respectcase
dis `"`myfiles'"'
foreach f in `myfiles' {
    import excel "`f'", sheet("Sheet") firstrow clear
    drop if 省1 == "" 

   
   	egen Co_To2_noneg = rowtotal(仁慈出现次数 仁爱出现次数 道义出现次数 公义出现次数 ///          
	正义出现次数 礼貌出现次数 礼仪出现次数 礼节出现次数 智谋出现次数 才智出现次数 ///
	信赖出现次数 诚信出现次数 诚实出现次数 忠诚出现次数 孝顺出现次数 孝道出现次数 /// 
	和平出现次数  和气出现次数 廉洁出现次数 清廉出现次数 廉政出现次数 ///
	廉正出现次数)
   

	   
	bysort 省1:egen Co2_Pr_noneg1 = sum(Co_To2_noneg)  
	
		
	egen Num_article_Pr1 = nvals(文章编号), by(省1)
	label var Num_article_Pr1 "文章数"
		
		
		
	duplicates drop 省1, force
	keep 年份 省1  Co2_Pr_noneg1 Num_article_Pr1  
	rename 省1 province
	rename 年份 year



	
    destring year, replace
	save "${path}\1949-1956 1982/`f'.dta", replace


}
















*Step 2 Append all files




clear
cd "${path}\1956-1981"
use 1956最终版.xlsx.dta

*append 1957-1972
forvalues s = 1957/1972{
    append using `s'最终版.xls.dta
}

*append 1973-1981
forvalues s = 1973/1981{
    append using `s'最终版.xlsx.dta
}

*append 1983-2003
cd "${path}\1983-2003"
forvalues s = 1983/2003{
    append using 人民日报`s'.xlsx.dta
}


*append 2004-2020
cd "${path}\2004-2020"
forvalues s = 2004/2020{
    append using `s'.xlsx.dta
}

*append 1949-1955
cd "${path}\1949-1956 1982"
forvalues s = 1949/1955{
    append using 人民日报`s'.xlsx.dta
}

*append 1982
cd "${path}\1949-1956 1982"
append using 人民日报1982.xlsx.dta

save "${data}\1949-2020_addnoneg.dta", replace

