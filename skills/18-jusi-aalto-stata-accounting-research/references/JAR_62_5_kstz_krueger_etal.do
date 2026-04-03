*******************************************************************;
*STATA Script
*Paper: "The Effects of Mandatory ESG Disclosure around the World"
*Authors: P. Krueger, Z. Sautner, D. Y. Tang, R. Zhong;
*******************************************************************; 

********************************************************************
* Analysis done in StataMP 18
********************************************************************

clear
cd "C:\Users\zsautn\Dropbox\KruegerSautnerTangZhong\data\Data_File_KSTZ"

use all_data_liquidity_raw_final

********************************************************************
* A. Rename and Encode Some Variables
********************************************************************

egen isin_num=group(isin)

*rename Year year
rename Country_code_nation country_code_nation 
gen country_code = country_code_nation 
encode country_code, gen(country_code_num)

**********************************************************************
* B. Create Sample Period        
**********************************************************************

drop if year< 2002 | year >2021

********************************************************************
* C. Create ESG Disclosure Variables
********************************************************************

*1. Create mandatory ESG disclosure variable

gen esg_disclosure_year = 0
replace esg_disclosure_year = 2008 if country_code == "ARG" 
replace esg_disclosure_year = 2003 if country_code == "AUS" 
replace esg_disclosure_year = 2016 if country_code == "AUT" 
replace esg_disclosure_year = 2009 if country_code == "BEL" 
replace esg_disclosure_year = 2016 if country_code == "BGR"
replace esg_disclosure_year = 2004 if country_code == "CAN" 
replace esg_disclosure_year = 2015 if country_code == "CHL" 
replace esg_disclosure_year = 2008 if country_code == "CHN"
replace esg_disclosure_year = 2016 if country_code == "CYP" 
replace esg_disclosure_year = 2016 if country_code == "DNK" 
replace esg_disclosure_year = 2016 if country_code == "EST" 
replace esg_disclosure_year = 2016 if country_code == "FIN" 
replace esg_disclosure_year = 2001 if country_code == "FRA" 
replace esg_disclosure_year = 2016 if country_code == "DEU" 
replace esg_disclosure_year = 2006 if country_code == "GRC" 
replace esg_disclosure_year = 2015 if country_code == "HKG" 
replace esg_disclosure_year = 2016 if country_code == "HUN" 
replace esg_disclosure_year = 2015 if country_code == "IND"
replace esg_disclosure_year = 2012 if country_code == "IDN"
replace esg_disclosure_year = 2016 if country_code == "IRL" 
replace esg_disclosure_year = 2016 if country_code == "ITA" 
replace esg_disclosure_year = 2016 if country_code == "MLT"
replace esg_disclosure_year = 2007 if country_code == "MYS" 
replace esg_disclosure_year = 2016 if country_code == "NLD" 
replace esg_disclosure_year = 2013 if country_code == "NOR"
replace esg_disclosure_year = 2009 if country_code == "PAK"
replace esg_disclosure_year = 2015 if country_code == "PER" 
replace esg_disclosure_year = 2011 if country_code == "PHL"
replace esg_disclosure_year = 2016 if country_code == "POL" 
replace esg_disclosure_year = 2010 if country_code == "PRT" 
replace esg_disclosure_year = 2016 if country_code == "ROU" 
replace esg_disclosure_year = 2016 if country_code == "SGP" 
replace esg_disclosure_year = 2017 if country_code == "SVN" 
replace esg_disclosure_year = 2010 if country_code == "ZAF" 
replace esg_disclosure_year = 2012 if country_code == "ESP"
replace esg_disclosure_year = 2016 if country_code == "SWE"
replace esg_disclosure_year = 2019 if country_code == "TWN"
replace esg_disclosure_year = 2014 if country_code == "TUR" 
replace esg_disclosure_year = 2013 if country_code == "GBR" 

sort country_code year
by country_code: gen d_esg_disclosure=0
replace d_esg_disclosure=1 if year>=esg_disclosure_year
replace d_esg_disclosure=0 if esg_disclosure_year==0   

bysort country_code: egen d_esg_disclosure_cty=max(d_esg_disclosure)

*2. Create separate mandatory E,S, and G disclosure variables

gen e_disclosure_year = 0
replace e_disclosure_year = 2008 if country_code == "ARG" 
replace e_disclosure_year = 2001 if country_code == "AUS" 
replace e_disclosure_year = 2016 if country_code == "AUT" 
replace e_disclosure_year = 1995 if country_code == "BEL"
replace e_disclosure_year = 2016 if country_code == "BGR" 
replace e_disclosure_year = 2012 if country_code == "BRA"
replace e_disclosure_year = 2004 if country_code == "CAN"  
replace e_disclosure_year = 2014 if country_code == "CHL" 
replace e_disclosure_year = 2008 if country_code == "CHN" 
replace e_disclosure_year = 2016 if country_code == "CYP"
replace e_disclosure_year = 2016 if country_code == "DNK" 
replace e_disclosure_year = 2016 if country_code == "EST" 
replace e_disclosure_year = 2016 if country_code == "FIN" 
replace e_disclosure_year = 2001 if country_code == "FRA" 
replace e_disclosure_year = 2016 if country_code == "DEU" 
replace e_disclosure_year = 2006 if country_code == "GRC" 
replace e_disclosure_year = 2015 if country_code == "HKG" 
replace e_disclosure_year = 2016 if country_code == "HUN" 
replace e_disclosure_year = 2015 if country_code == "IND"
replace e_disclosure_year = 2007 if country_code == "IDN"
replace e_disclosure_year = 2016 if country_code == "IRL" 
replace e_disclosure_year = 2016 if country_code == "ITA" 
replace e_disclosure_year = 2005 if country_code == "JPN" 
replace e_disclosure_year = 1974 if country_code == "MYS" 
replace e_disclosure_year = 2012 if country_code == "MEX"
replace e_disclosure_year = 2016 if country_code == "MLT" 
replace e_disclosure_year = 1993 if country_code == "NLD" 
replace e_disclosure_year = 1998 if country_code == "NOR"
replace e_disclosure_year = 2009 if country_code == "PAK"
replace e_disclosure_year = 2015 if country_code == "PER" 
replace e_disclosure_year = 2011 if country_code == "PHL"
replace e_disclosure_year = 2016 if country_code == "POL" 
replace e_disclosure_year = 2010 if country_code == "PRT" 
replace e_disclosure_year = 2016 if country_code == "ROU" 
replace e_disclosure_year = 2012 if country_code == "SGP" 
replace e_disclosure_year = 2017 if country_code == "SVN" 
replace e_disclosure_year = 2010 if country_code == "ZAF"
replace e_disclosure_year = 2012 if country_code == "KOR"  
replace e_disclosure_year = 2002 if country_code == "ESP" 
replace e_disclosure_year = 2016 if country_code == "SWE" 
replace e_disclosure_year = 2019 if country_code == "TWN" 
replace e_disclosure_year = 2006 if country_code == "TUR" 
replace e_disclosure_year = 2008 if country_code == "GBR"  
replace e_disclosure_year = 2016 if country_code == "VNM" 

gen s_disclosure_year = 0
replace s_disclosure_year = 2008 if country_code == "ARG" 
replace s_disclosure_year = 2001 if country_code == "AUS" 
replace s_disclosure_year = 2016 if country_code == "AUT"
replace s_disclosure_year = 2008 if country_code == "BEL"
replace s_disclosure_year = 2016 if country_code == "BGR" 
replace s_disclosure_year = 2011 if country_code == "BRA"
replace s_disclosure_year = 2004 if country_code == "CAN"   
replace s_disclosure_year = 2015 if country_code == "CHL" 
replace s_disclosure_year = 2008 if country_code == "CHN" 
replace s_disclosure_year = 2016 if country_code == "CYP"
replace s_disclosure_year = 2016 if country_code == "DNK"
replace s_disclosure_year = 2016 if country_code == "EST"
replace s_disclosure_year = 2016 if country_code == "FIN"
replace s_disclosure_year = 2001 if country_code == "FRA"
replace s_disclosure_year = 2016 if country_code == "DEU"  
replace s_disclosure_year = 2006 if country_code == "GRC" 
replace s_disclosure_year = 2015 if country_code == "HKG"
replace s_disclosure_year = 2016 if country_code == "HUN"  
replace s_disclosure_year = 2015 if country_code == "IND"
replace s_disclosure_year = 2007 if country_code == "IDN"
replace s_disclosure_year = 2016 if country_code == "IRL" 
replace s_disclosure_year = 2016 if country_code == "ITA"
replace s_disclosure_year = 2016 if country_code == "MLT" 
replace s_disclosure_year = 1994 if country_code == "MYS" 
replace s_disclosure_year = 2016 if country_code == "NLD" 
replace s_disclosure_year = 1998 if country_code == "NOR"
replace s_disclosure_year = 2009 if country_code == "PAK"
replace s_disclosure_year = 2015 if country_code == "PER" 
replace s_disclosure_year = 2011 if country_code == "PHL"
replace s_disclosure_year = 2016 if country_code == "POL" 
replace s_disclosure_year = 2004 if country_code == "PRT" 
replace s_disclosure_year = 2016 if country_code == "ROU" 
replace s_disclosure_year = 2016 if country_code == "SGP" 
replace s_disclosure_year = 2017 if country_code == "SVN" 
replace s_disclosure_year = 2010 if country_code == "ZAF" 
replace s_disclosure_year = 2012 if country_code == "ESP" 
replace s_disclosure_year = 2016 if country_code == "SWE" 
replace s_disclosure_year = 2016 if country_code == "CHE"
replace s_disclosure_year = 2019 if country_code == "TWN" 
replace s_disclosure_year = 2003 if country_code == "TUR" 
replace s_disclosure_year = 2016 if country_code == "ARE"
replace s_disclosure_year = 2010 if country_code == "GBR"
replace s_disclosure_year = 2002 if country_code == "USA"
replace s_disclosure_year = 2016 if country_code == "VNM"   

gen g_disclosure_year = 0
replace g_disclosure_year = 2008 if country_code == "ARG" 
replace g_disclosure_year = 2003 if country_code == "AUS" 
replace g_disclosure_year = 2004 if country_code == "AUT" 
replace g_disclosure_year = 2009 if country_code == "BEL"
replace g_disclosure_year = 2016 if country_code == "BGR"
replace g_disclosure_year = 2011 if country_code == "BRA"
replace g_disclosure_year = 2004 if country_code == "CAN"
replace g_disclosure_year = 2015 if country_code == "CHL" 
replace g_disclosure_year = 2008 if country_code == "CHN"
replace g_disclosure_year = 2016 if country_code == "CYP"
replace g_disclosure_year = 2016 if country_code == "DNK"
replace g_disclosure_year = 2016 if country_code == "EST"
replace g_disclosure_year = 2016 if country_code == "FIN" 
replace g_disclosure_year = 2001 if country_code == "FRA"
replace g_disclosure_year = 2016 if country_code == "DEU" 
replace g_disclosure_year = 2006 if country_code == "GRC" 
replace g_disclosure_year = 2015 if country_code == "HKG"
replace g_disclosure_year = 2016 if country_code == "HUN" 
replace g_disclosure_year = 2015 if country_code == "IND"
replace g_disclosure_year = 2012 if country_code == "IDN"
replace g_disclosure_year = 2016 if country_code == "IRL"
replace g_disclosure_year = 2016 if country_code == "ITA"
replace g_disclosure_year = 2014 if country_code == "JPN"
replace g_disclosure_year = 2007 if country_code == "MYS"
replace g_disclosure_year = 2016 if country_code == "MLT" 
replace g_disclosure_year = 2016 if country_code == "NLD"
replace g_disclosure_year = 2011 if country_code == "NGA" 
replace g_disclosure_year = 2013 if country_code == "NOR"
replace g_disclosure_year = 2009 if country_code == "PAK"
replace g_disclosure_year = 2015 if country_code == "PER" 
replace g_disclosure_year = 2011 if country_code == "PHL"
replace g_disclosure_year = 2016 if country_code == "POL"
replace g_disclosure_year = 2004 if country_code == "PRT"
replace g_disclosure_year = 2016 if country_code == "QAT" 
replace g_disclosure_year = 2016 if country_code == "ROU"
replace g_disclosure_year = 2016 if country_code == "SGP"
replace g_disclosure_year = 2017 if country_code == "SVN" 
replace g_disclosure_year = 2010 if country_code == "ZAF"
replace g_disclosure_year = 2013 if country_code == "KOR"  
replace g_disclosure_year = 2012 if country_code == "ESP" 
replace g_disclosure_year = 2016 if country_code == "SWE" 
replace g_disclosure_year = 2016 if country_code == "CHE" 
replace g_disclosure_year = 2019 if country_code == "TWN"
replace g_disclosure_year = 2014 if country_code == "THA" 
replace g_disclosure_year = 2014 if country_code == "TUR" 
replace g_disclosure_year = 2016 if country_code == "ARE"
replace g_disclosure_year = 2013 if country_code == "GBR"
replace g_disclosure_year = 2002 if country_code == "USA" 

*3. Create voluntary ESG disclosure variable

gen esg_vol_disclosure_year = 0

*Countries with voluntary and mandatory disclosure

replace esg_vol_disclosure_year = 2003 if country_code == "AUT" 
replace esg_vol_disclosure_year = 2012 if country_code == "CHL" 
replace esg_vol_disclosure_year = 2009 if country_code == "DNK" 
replace esg_vol_disclosure_year = 2005 if country_code == "FIN" 
replace esg_vol_disclosure_year = 2013 if country_code == "DEU" 
replace esg_vol_disclosure_year = 2002 if country_code == "GRC" 
replace esg_vol_disclosure_year = 2012 if country_code == "HKG" 
replace esg_vol_disclosure_year = 2011 if country_code == "IND" 
replace esg_vol_disclosure_year = 2002 if country_code == "ITA" 
replace esg_vol_disclosure_year = 2006 if country_code == "MYS" 
replace esg_vol_disclosure_year = 2013 if country_code == "PER" 
replace esg_vol_disclosure_year = 2010 if country_code == "PHL" 
replace esg_vol_disclosure_year = 2002 if country_code == "PRT" 
replace esg_vol_disclosure_year = 2009 if country_code == "ROU" 
replace esg_vol_disclosure_year = 2011 if country_code == "SGP" 
replace esg_vol_disclosure_year = 2016 if country_code == "TWN" 

*Countries with voluntary disclosure only

replace esg_vol_disclosure_year = 2016 if country_code == "BHR" 
replace esg_vol_disclosure_year = 2012 if country_code == "BRA" 
replace esg_vol_disclosure_year = 2014 if country_code == "COL" 
replace esg_vol_disclosure_year = 2016 if country_code == "EGY" 
replace esg_vol_disclosure_year = 2015 if country_code == "JPN" 
replace esg_vol_disclosure_year = 2009 if country_code == "JOR" 
replace esg_vol_disclosure_year = 2016 if country_code == "KAZ" 
replace esg_vol_disclosure_year = 2015 if country_code == "KEN" 
replace esg_vol_disclosure_year = 2015 if country_code == "KOR" 
replace esg_vol_disclosure_year = 2017 if country_code == "MUS" 
replace esg_vol_disclosure_year = 2011 if country_code == "MEX" 
replace esg_vol_disclosure_year = 2016 if country_code == "MAR" 
replace esg_vol_disclosure_year = 2018 if country_code == "NGA" 
replace esg_vol_disclosure_year = 2016 if country_code == "QAT" 
replace esg_vol_disclosure_year = 2018 if country_code == "RUS" 
replace esg_vol_disclosure_year = 2019 if country_code == "SAU" 
replace esg_vol_disclosure_year = 2018 if country_code == "LKA" 
replace esg_vol_disclosure_year = 2016 if country_code == "CHE" 
replace esg_vol_disclosure_year = 2012 if country_code == "THA" 
replace esg_vol_disclosure_year = 2019 if country_code == "ARE" 
replace esg_vol_disclosure_year = 2013 if country_code == "VNM" 

gen dummy_esg_vol_country = 0
replace dummy_esg_vol_country = 1 if esg_vol_disclosure_year ~= 0

*4. Create ESG disclosure "issued by gov. inst." vs. "stock exchange" 

gen d_esg_issue_se= 0
replace d_esg_issue_se=1 if country_code=="AUS" & d_esg_disclosure==1
replace d_esg_issue_se=1 if country_code=="CAN" & d_esg_disclosure==1
replace d_esg_issue_se=1 if country_code=="CHN" & d_esg_disclosure==1
replace d_esg_issue_se=1 if country_code=="HKG" & d_esg_disclosure==1
replace d_esg_issue_se=1 if country_code=="MYS" & d_esg_disclosure==1
replace d_esg_issue_se=1 if country_code=="SGP" & d_esg_disclosure==1
replace d_esg_issue_se=1 if country_code=="TWN" & d_esg_disclosure==1
replace d_esg_issue_se=1 if country_code=="ZAF" & d_esg_disclosure==1

gen d_esg_issue_gov= d_esg_disclosure
replace d_esg_issue_gov=0 if country_code=="AUS" & d_esg_disclosure==1
replace d_esg_issue_gov=0 if country_code=="CAN" & d_esg_disclosure==1
replace d_esg_issue_gov=0 if country_code=="CHN" & d_esg_disclosure==1
replace d_esg_issue_gov=0 if country_code=="HKG" & d_esg_disclosure==1
replace d_esg_issue_gov=0 if country_code=="MYS" & d_esg_disclosure==1
replace d_esg_issue_gov=0 if country_code=="SGP" & d_esg_disclosure==1 
replace d_esg_issue_gov=0 if country_code=="TWN" & d_esg_disclosure==1
replace d_esg_issue_gov=0 if country_code=="ZAF" & d_esg_disclosure==1

bysort country_code: egen d_esg_issue_se_cty=max(d_esg_issue_se)
bysort country_code: egen d_esg_issue_gov_cty=max(d_esg_issue_gov)

*5. Create ESG disclosure "all at once" vs. "gradually"

gen d_esg_all_once= 0
replace d_esg_all_once=1 if country_code=="ARG" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="CAN" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="CHN" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="DEU" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="DNK" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="EST" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="FIN" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="FRA" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="GRC" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="HKG" & d_esg_disclosure==1 
replace d_esg_all_once=1 if country_code=="HUN" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="IRL" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="ITA" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="IND" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="PAK" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="PER" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="PHL" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="POL" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="ROU" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="SVN" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="SWE" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="TWN" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="ZAF" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="BGR" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="CYP" & d_esg_disclosure==1
replace d_esg_all_once=1 if country_code=="MLT" & d_esg_disclosure==1

gen d_esg_not_all_once= d_esg_disclosure
replace d_esg_not_all_once=0 if country_code=="ARG" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="CAN" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="CHN" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="DEU" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="DNK" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="EST" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="FIN" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="FRA" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="GRC" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="HUN" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="IRL" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="ITA" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="IND" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="PAK" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="PER" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="PHL" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="POL" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="ROU" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="SVN" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="SWE" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="TWN" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="ZAF" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="BGR" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="CYP" & d_esg_disclosure==1
replace d_esg_not_all_once=0 if country_code=="MLT" & d_esg_disclosure==1

bysort country_code: egen d_esg_all_once_cty=max(d_esg_all_once)
bysort country_code: egen d_esg_not_all_once_cty=max(d_esg_not_all_once)

*6. Create ESG Disclosure "comply or explain" vs. "not comply or explain"

gen esg_comply_explain = 0
replace esg_comply_explain = 1 if country_code == "BGR" 
replace esg_comply_explain = 1 if country_code == "CHL"
replace esg_comply_explain = 1 if country_code == "CYP"  
replace esg_comply_explain = 1 if country_code == "DNK"  
replace esg_comply_explain = 1 if country_code == "EST" 
replace esg_comply_explain = 1 if country_code == "FIN" 
replace esg_comply_explain = 1 if country_code == "DEU"
replace esg_comply_explain = 1 if country_code == "HKG" 
replace esg_comply_explain = 1 if country_code == "HUN"
replace esg_comply_explain = 1 if country_code == "IRL"  
replace esg_comply_explain = 1 if country_code == "ITA"
replace esg_comply_explain = 1 if country_code == "MLT"  
replace esg_comply_explain = 1 if country_code == "MYS" 
replace esg_comply_explain = 1 if country_code == "NLD"
replace esg_comply_explain = 1 if country_code == "ROU"  
replace esg_comply_explain = 1 if country_code == "SGP" 
replace esg_comply_explain = 1 if country_code == "SVN" 
replace esg_comply_explain = 1 if country_code == "ZAF" 
replace esg_comply_explain = 1 if country_code == "ESP" 
replace esg_comply_explain = 1 if country_code == "SWE" 

gen d_esg_comply_explain=0
replace d_esg_comply_explain=1 if d_esg_disclosure==1 & esg_comply_explain==1

gen d_esg_not_comply_explain=0
replace d_esg_not_comply_explain=1 if d_esg_disclosure==1 & esg_comply_explain==0

bysort country_code: egen d_esg_comply_explain_cty=max(d_esg_comply_explain)
bysort country_code: egen d_esg_not_comply_explain_cty=max(d_esg_not_comply_explain)

********************************************************************
* D. Add PRI Ownership & Voluntary ESG Disclosure Data
********************************************************************

sort isin date
merge 1:m isin date using factset_io.dta
tab _merge
drop if _merge==2
drop _merge 

sort isin year

merge isin year using asset4_csr
tab _merge
drop  if _merge==2
drop _merge

*******************************************************************
* E. Add Equity Index, EPI, WVS & EVS Variables
*******************************************************************

/*merge with equity index info*/
merge m:1 country_code year using index_ret_vol
drop if _merge==2
drop _merge

/*merge with EPI index from Yale*/
merge n:1 country_code year using EPI
drop if _merge==2
drop _merge

/*merge with WVS & EVS data*/
merge n:1 country_code year using ivs_data_esg_refine
drop if _merge==2
drop _merge

*******************************************************************
* F. Create Logs of Illiquidity Variables
*******************************************************************

gen amihud_annual_median2 = amihud_annual_median*1000
gen log_amihud_median = log(amihud_annual_median2)
gen log_bid_ask_median = log(bid_ask_spread_median)

*******************************************************************
* G. Winsorize Variables
*******************************************************************

foreach var of varlist bid_ask_spread_median amihud_annual_median2 log_bid_ask_median log_amihud_median numest_median log_size roa lev_ratio mtob index_vol_annual index_ret_annual io_pri {
winsor(`var'), p(.01) gen(W_`var')
}

*******************************************************************
* H. Create Log Illiquidity Measures & Illiquidity Factor
*******************************************************************

gen log_W_bid_ask_median=log(W_bid_ask_spread_median)
gen log_W_amihud_median=log(W_amihud_annual_median2)

factor log_W_bid_ask_median log_W_amihud_median zero_ret, pcf
rotate,  promax
predict spl_factor 

*******************************************************************
* I. Create Timing Variables
*******************************************************************

*t=0 is year in which disclosure mandate is introduced

gen t= year - esg_disclosure_year
gen pre_3m = (t<=-3 & t>=-17  & esg_disclosure_year >0)
gen pre_2 = (t==-2 & esg_disclosure_year >0)
gen pre_1 = (t==-1 & esg_disclosure_year >0)
gen post_0 = (t==0 & esg_disclosure_year >0)
gen post_1 = (t==1 & esg_disclosure_year >0)
gen post_2 = (t==2 & esg_disclosure_year >0)
gen post_3p = (t>=3 & t<=19 & esg_disclosure_year >0)

*******************************************************************
* J. Create Voluntary Disclosure Variables
*******************************************************************

*1. Voluntary earnings guidance
 
gen d_managerial_guidance=0
replace d_managerial_guidance=1 if no_guide!=.

*2. Voluntary ESG reports

sort isin_num year
tsset isin_num year
gen csr_1=l.dummy_csr_asset4 
gen csr_2=l2.dummy_csr_asset4 
tab csr_1 csr_2

gen group = 1 + csr_1 + 2*csr_2

* = 1 When csr_1=0 and csr_2=0, group = 1 + 0 + 0 = 1 (treated, mandatory adopters, no report in t-1 and t-2, baseline)
* = 2 When csr_1=1 and csr_2=0, group = 1 + 1 + 0 = 2 (early mandatory, late voluntary, report in t-1)
* = 3 When csr_1=0 and csr_2=1, group = 1 + 0 + 2 = 3 (likely error category, report in t-2 but not in t-1, treat below as group =4) 
* = 4 When csr_1=1 and csr_2=1, group = 1 + 1 + 2 = 4 (early voluntary, report in t-2 and t-1)

gen group_1= group
replace group_1 = 4 if group==3

*******************************************************************
* K. Create Lagged Variables
*******************************************************************

sort isin_num year
foreach var of varlist W_numest_median W_log_size W_roa W_lev_ratio W_mtob W_index_vol_annual W_index_ret_annual d_managerial_guidance {
by isin_num: gen `var'_lag=`var'[_n-1]
}

*******************************************************************
* L. Create Country-Level Residual Variables
*******************************************************************

encode legal_origin, gen(legal_origin_num)

reg index_rule_of_law GDP_per_capita index_globalization legal_origin_num
predict index_rule_of_law_res, residuals

reg index_govt_effectiveness GDP_per_capita index_globalization legal_origin_num
predict index_govt_effectiveness_res, residuals

reg ivs_environment GDP_per_capita index_globalization legal_origin_num
predict ivs_environment_res, residuals

reg ivs_social GDP_per_capita index_globalization legal_origin_num
predict ivs_social_res, residuals

reg EPI GDP_per_capita index_globalization legal_origin_num
predict EPI_res, residuals

* Create temporary dataset 
*save temp_t8.dta,replace

*******************************************************************
* M. Drop Year 2021 as Only Partial Data for Some Controls					
*******************************************************************

drop if year==2021

*******************************************************************
* N. Add Data on Google Search and ESG Incidents        
*******************************************************************

merge m:1 country_code year using gs_data

drop if year==2021
drop if year==2022
drop _merge

sort country_code year

merge m:1 country_code year using esg_incidents_reprisk

foreach var of varlist  ESG CSR CSR2  num_incidents_ctr {
winsor(`var'), p(.01) gen(W_`var')
}

gen W_ESG_10000=W_ESG/10000
gen W_num_incidents_ctr_100000=W_num_incidents_ctr/100000
gen GDP_per_capita_100000=GDP_per_capita/100000

drop if missing(isin_num)


