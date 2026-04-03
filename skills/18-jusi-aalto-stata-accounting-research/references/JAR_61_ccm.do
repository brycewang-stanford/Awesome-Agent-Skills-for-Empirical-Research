*********************************************
* 		Externalities of Fraud				*
* 		Carnes, Christensen, Madsen			*
* 		JAR 2023							*	
* 		This code prepared by Madsen		*
*********************************************

clear
clear matrix
set more off

************************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************************
********************* Organization *************************************************************************************************************************************************************
************************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************************

	************************************************************************************************************************************************************************************************
	* AAERs: University of Southern California database ********************************************************************************************************************************************
	************************************************************************************************************************************************************************************************
	
		*Prepare lagged aaer files. 
		foreach name in "jar" "highmedia" "lowmedia" {
			*state-level fraud
				forvalues i = 0(1)5 {
					import sas using "C:\CCM\Data\state_year_frauds_`name'.sas7bdat", clear
						rename *, lower
						rename reveal_year year
						rename count statefraud_`name'
						rename state_historical state
						drop percent
						replace year = year + `i'
						rename statefraud_`name' fraudstate_`name'l`i'
					save "C:\CCM\Data\Macro variables\AAERState`name'Lag`i'.dta", replace
				}
			*county-level fraud
				forvalues i = 0(1)5 {
					import sas using "C:\CCM\Data\county_year_frauds_`name'.sas7bdat", clear
						rename *, lower
						rename reveal_year year
						rename count countyfraud_`name'
						rename fips countyfips
						drop percent
						replace year = year + `i'
						rename countyfraud_`name' fraudcounty_`name'l`i'
					save "C:\CCM\Data\Macro variables\AAERCounty`name'Lag`i'.dta", replace
			}
		}

	************************************************************************************************************************************************************************************************
	* GDP **************************************************************************************************************************************************************************************
	************************************************************************************************************************************************************************************************
		
		* Cleaning: Get state GDP growth file in long form to be merged with HERI. Sources: 
			* https://www.bea.gov/iTable/iTable.cfm?reqid=70&step=10&isuri=1&7003=200&7035=-1&7004=sic&7005=1&7006=xx&7036=-1&7001=1200&7002=1&7090=70&7007=-1&7093=levels#reqid=70&step=10&isuri=1&7003=200&7035=-1&7004=naics&7005=1&7006=xx&7036=-1&7001=1200&7002=1&7090=70&7007=-1&7093=levels
			* https://www.bea.gov/itable/iTable.cfm?ReqID=70&step=1#reqid=70&step=10&isuri=1&7003=200&7035=-1&7004=sic&7005=1&7006=xx&7036=-1&7001=1200&7002=1&7090=70&7007=-1&7093=levels
				* these files are: GDP by state (millions of current dollars) in levels "all industry total" 
				* The format changes in 1997 so code processes early and later years separately

		import delimited "C:\CCM\Data\Macro variables\BEA\BEA_GDPbyStateMillionsCurrentLevelsAllIndTotal_97t17.csv", clear
			rename v3-v23 (y1997 y1998 y1999 y2000 y2001 y2002 y2003 y2004 y2005 y2006 y2007 y2008 y2009 y2010 y2011 y2012 y2013 y2014 y2015 y2016 y2017)
			drop if fips == 0
			drop if fips == 999
			drop if fips > 57000
			rename area state
			keep state y1997-y2017
			reshape long y, i(state) j(year)
			rename y GDP
			egen stateid = group(state)
			tsset stateid year
			gen GDPg = (GDP - l1.GDP)/l1.GDP
			keep state year GDPg
			drop if GDPg == .
		save "C:\CCM\Data\Macro variables\BEA\BEA_GDPbyStateMillionsCurrentLevelsAllIndTotal_97t17.dta", replace

		import delimited "C:\CCM\Data\Macro variables\BEA\BEA_GDPbyStateMillionsCurrentLevelsAllIndTotal_63t97.csv", clear
			rename v3-v37 	(y1963 y1964 y1965 y1966 y1967 y1968 y1969 y1970 y1971 y1972 y1973 y1974 y1975 y1976 y1977 y1978 y1979 ///
							 y1980 y1981 y1982 y1983 y1984 y1985 y1986 y1987 y1988 y1989 y1990 y1991 y1992 y1993 y1994 y1995 y1996 y1997)
			drop if fips == 0
			drop if fips == 999
			drop if fips > 57000
			rename area state
			keep state y1963-y1997
			reshape long y, i(state) j(year)
			rename y GDP
			egen stateid = group(state)
			tsset stateid year
			gen GDPg = (GDP - l1.GDP)/l1.GDP
			keep state year GDPg
			drop if GDPg == .
			append using "C:\CCM\Data\Macro variables\BEA\BEA_GDPbyStateMillionsCurrentLevelsAllIndTotal_97t17.dta"
			sort state year
			gen state2 = state
			drop state
			rename state2 state

			merge m:1 state using "C:\CCM\Data\Macro variables\BEA\StateNamesAbbrev.dta"
			keep if _merge == 3
			drop _merge
			keep state year GDP lowera
			rename state fullstate
			rename lowera state
		save "C:\CCM\Data\Macro variables\BEA\gdpstatereal.dta", replace

		forvalues i = 1(1)5 {
			use "C:\CCM\Data\Macro variables\BEA\gdpstatereal.dta", clear
			replace year = year + `i'
			rename GDPg GDPgl`i'
			save "C:\CCM\Data\Macro variables\BEA\gdpstaterealLag`i'.dta", replace
		}

	************************************************************************************************************************************************************************************************
	*MISC additional data **************************************************************************************************************************************************************************
	************************************************************************************************************************************************************************************************		
		
		* Clean up the zipcode to countyfips crosswalk
		import sas using "C:\CCM\Data\zipcode.sas7bdat", clear
			rename *, lower
			rename fips countyfips
			keep zip countyfips
		save "C:\CCM\Data\Macro variables\BEA\ZipToFips.dta", replace

		* College major labels
		use "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\disagg.dta", clear
			rename *, lower
			egen keeper = tag(major)
			keep if keeper == 1
			keep major
			decode major, gen(majorlab16)
		save "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\majorlabels.dta", replace

		use "C:\CCM\Data\HERI TFS\2020download\OriginalsDTA\disagg.dta", clear
			rename *, lower
			egen keeper = tag(major)
			keep if keeper == 1
			keep major
			decode major, gen(majorlab20)
		save "C:\CCM\Data\HERI TFS\2020download\OriginalsDTA\majorlabels.dta", replace
		clear

	************************************************************************************************************************************************************************************************
	* HERI **************************************************************************************************************************************************************************
	************************************************************************************************************************************************************************************************		

	* We use two version of the HERI Freshman Surveys, each of which is made from several large files from HERI's Data Archive: https://heri.ucla.edu/heri-data-archive/ 
		* We primarily use a version of the Freshman Surveys which we downloaded in 2016. It has data through 2006. 
		* We append additional years of data onto this primary file. These additional years are from a version downloaded in 2020. It has data through 2009.

	* The code below takes all of the input files for each version and organizes them in the same way. 
	* Then, at the end, it appends 2007-2009 onto the original 2016 dataset. 
	* It uses a local variable, called "versionn" to specify which version to organize. 
	* Many of the files are very large, so the code breaks them apart, processes the parts sequentially, then appends them back together. 

		foreach versionn in "16" "20" {	
			if "`versionn'" == "16" {
				forvalues i = 1970(5)2005 {
					use "C:\CCM\Data\HERI TFS\2016download\2016files\demographics.dta" if year > `i' & year < (`i' + 5), clear 
						save "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\demographics`i'.dta", replace
					use "C:\CCM\Data\HERI TFS\2016download\2016files\highschool.dta" if year > `i' & year < (`i' + 5), clear 
						save "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\highschool`i'.dta", replace		
					use "C:\CCM\Data\HERI TFS\2016download\2016files\choice.dta" if year > `i' & year < (`i' + 5), clear 
						save "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\choice`i'.dta", replace		
					use "C:\CCM\Data\HERI TFS\2016download\2016files\plans.dta" if year > `i' & year < (`i' + 5), clear 
						save "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\plans`i'.dta", replace					
					use "C:\CCM\Data\HERI TFS\2016download\2016files\views.dta" if year > `i' & year < (`i' + 5), clear 
						save "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\views`i'.dta", replace
					use "C:\CCM\Data\HERI TFS\2016download\2016files\funds.dta" if year > `i' & year < (`i' + 5), clear 
						save "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\funds`i'.dta", replace
				}	
				use "C:\CCM\Data\HERI TFS\2016download\2016files\disagg.dta", clear 
					save "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\disagg.dta", replace
			}

			if "`versionn'" == "20" {
				forvalues i = 1970(5)2005 {
					import spss if YEAR > `i' & YEAR < (`i' + 5) using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsUnzipped\1 DEMOGRAPHICS.SAV", clear
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\demographics`i'.dta", replace
					import spss if YEAR > `i' & YEAR < (`i' + 5) using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsUnzipped\2 HIGH SCHOOL.SAV", clear
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\highschool`i'.dta", replace
					import spss if YEAR > `i' & YEAR < (`i' + 5) using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsUnzipped\3 CHOICE.SAV", clear
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\choice`i'.dta", replace
					import spss if YEAR > `i' & YEAR < (`i' + 5) using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsUnzipped\4 PLANS.SAV", clear
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\plans`i'.dta", replace
					import spss if YEAR > `i' & YEAR < (`i' + 5) using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsUnzipped\5 VIEWS.SAV", clear
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\views`i'.dta", replace
					import spss if YEAR > `i' & YEAR < (`i' + 5) using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsUnzipped\6 FUNDS.SAV", clear
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\funds`i'.dta", replace
				}

			import spss using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsUnzipped\7 DISAGG.SAV", clear
				save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\disagg.dta", replace
			}
		}

		****************************************************************************************************************************
		****************************************************************************************************************************

		foreach versionn in "16" "20" {	
			*Clean the split HERI files so that they are smaller
				*start with dissagg because it is a single file. Other files will be merged to this one.
					
				use "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\disagg.dta", clear
					rename *, lower
					keep year subjid studwgt ace major scareer* fcareer fcareer74_n mcareer mcareer74_n
					drop if studwgt == .
					egen keeper = tag(year subjid)
					drop if keeper == 0
					drop keeper 
				save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta", replace
				
				forvalues i = 1970(5)2005 {	
					use "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\choice`i'.dta", clear

						rename *, lower
						replace reason05 = reason04_t if reason05 == . & reason04_t != .

					keep year acerecode subjid strat studwgt reason05 reason06 reason08 reason10 reason11 choice disthome
					
					if `i' == 1970 {
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\choicework.dta", replace
					}
					if `i' > 1970 {
						append using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\choicework.dta"
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\choicework.dta", replace
					}
				}
					drop if studwgt == .
					egen keeper = tag(year subjid)
					drop if keeper == 0
					drop keeper studwgt 
					merge 1:1 year subjid using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta"
					drop _merge
				save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta", replace
				
				forvalues i = 1970(5)2005 {
					use "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\plans`i'.dta", clear
					
						rename *, lower
						replace goal08 = goal0809_n if goal08 == . & goal0809_n != .
						replace goal10 = goal0817_n if goal10 == . & goal0817_n != .
						replace goal12 = goal0810_n if goal12 == . & goal0810_n != .

					keep year subjid studwgt scareer goal* compgroup2
					
					if `i' == 1970 {
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\planswork.dta", replace
					}
					if `i' > 1970 {
						append using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\planswork.dta"
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\planswork.dta", replace
					}
				}
					drop if studwgt == .
					egen keeper = tag(year subjid)
					drop if keeper == 0
					drop keeper studwgt 
					merge 1:1 year subjid using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta"
					drop _merge
					*Drop some unnecessary years and variables to reduce file size.
					drop goal01 goal03 goal05-goal07 goal09 goal11 goal13-goal17 goal19-goal24 goal*_*	
				save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta", replace
				
				forvalues i = 1970(5)2005 {
					use "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\funds`i'.dta", clear
					rename *, lower
					
					keep year subjid studwgt fincon aid01
					
					if `i' == 1970 {
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\fundswork.dta", replace
					}
					if `i' > 1970 {
						append using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\fundswork.dta"
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\fundswork.dta", replace
					}
				}
					drop if studwgt == .
					egen keeper = tag(year subjid)
					drop if keeper == 0
					drop keeper studwgt 
					merge 1:1 year subjid using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta"
					drop _merge
				save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta", replace
				
				forvalues i = 1970(5)2005 {
					use "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\demographics`i'.dta", clear
					rename *, lower
					keep 	year studwgt subjid compgroup1 dobmm dobyy ///
							homezip sex age1 racegroup citizen sreligiona income parstat fatheduc motheduc ///
							fcareera mcareera freligiona mreligiona ndeppar fullstat firstgen
					if `i' == 1970 {
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\demographicswork.dta", replace
					}
					if `i' > 1970 {
						append using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\demographicswork.dta"
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\demographicswork.dta", replace
					}
				}
					drop if studwgt == .
					egen keeper = tag(year subjid)
					drop if keeper == 0
					drop keeper studwgt
					merge 1:1 year subjid using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta"
					drop _merge
				save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta", replace

				forvalues i = 1970(5)2005 {
					use "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\highschool`i'.dta", clear
					rename *, lower
					keep 	year studwgt subjid hsgpa satv satm satw actcomp hsrank01 hsrank02 ///
							act10 act11 act23 act24 act20 rate01 rate08 rate10 rate13 rate15 rate16 rate19 rate20 rate17 rate06
					if `i' == 1970 {
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\highschoolwork.dta", replace
					}
					if `i' > 1970 {
						append using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\highschoolwork.dta"
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\highschoolwork.dta", replace
					}
				}
				*
					drop if studwgt == .
					egen keeper = tag(year subjid)
					drop if keeper == 0
					drop keeper studwgt
					merge 1:1 year subjid using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta"
					drop _merge
				save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta", replace

				forvalues i = 1970(5)2005 {
					use "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\views`i'.dta", clear
					rename *, lower
					keep year studwgt subjid poliview views28
					
					if `i' == 1970 {
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\viewswork.dta", replace
					}
					if `i' > 1970 {
						append using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\viewswork.dta"
						save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\viewswork.dta", replace
					}
				}
					drop if studwgt == .
					egen keeper = tag(year subjid)
					drop if keeper == 0
					drop keeper studwgt
					merge 1:1 year subjid using "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta"
					drop _merge

				format %9.0g subjid
				format %6.0g year
				format %9.0g acerecode
				format %9.0g ace
				format %9.0g homezip
				order year subjid ace acerecode studwgt compgroup1 strat
			save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta", replace
			clear 

			erase "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\choicework.dta"
			erase "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\demographicswork.dta"
			erase "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\fundswork.dta"
			erase "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\highschoolwork.dta"
			erase "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\planswork.dta"
			erase "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\viewswork.dta"
		}

		************************************************************************************************************************************************************************************************
		********************* Merge lagged fraud files (prepared at the top of this .do file) together to get all required fraud measures into two files (state level frauds and county level frauds) **
		************************************************************************************************************************************************************************************************
			use "C:\CCM\Data\Macro variables\AAERCountyjarLag0.dta", clear
			foreach loca in "county" {
				foreach name in "jar" "highmedia" "lowmedia" {
					forvalues i = 0(1)5 {
						if "`name'" == "jar" & `i' == 0 {
							drop if year < 1976
							drop if year > 2009			
						}
						else {
							merge m:1 year countyfips using "C:\CCM\Data\Macro variables\AAER`loca'`name'Lag`i'.dta"
							drop _merge
							drop if year < 1976
							drop if year > 2009			
						}
					}
				}
			}
			foreach loca in "county" {
				foreach name in "jar" "highmedia" "lowmedia" {
					forvalues i = 0(1)5 {
						replace fraud`loca'_`name'l`i' = 0 if fraud`loca'_`name'l`i' == .
					}
				}
			}
			save "C:\CCM\Data\Macro variables\AAERCountyKeeper.dta", replace

			use "C:\CCM\Data\Macro variables\AAERStatejarLag0.dta", clear
			foreach loca in "State" {
				foreach name in "jar" "highmedia" "lowmedia" {
					forvalues i = 0(1)5 {
						if "`name'" == "jar" & `i' == 0 {
							drop if year < 1976
							drop if year > 2009			
						}
						else {
							merge m:1 year state using "C:\CCM\Data\Macro variables\AAER`loca'`name'Lag`i'.dta"
							drop _merge
							drop if year < 1976
							drop if year > 2009			
						}
					}
				}
			}
			foreach loca in "state" {
				foreach name in "jar" "highmedia" "lowmedia" {
					forvalues i = 0(1)5 {
						replace fraud`loca'_`name'l`i' = 0 if fraud`loca'_`name'l`i' == .
					}
				}
			}
			replace state = lower(state)
			save "C:\CCM\Data\Macro variables\AAERStateKeeper.dta", replace

		************************************************************************************************************************************************************************************************
		*********************Transform HERI variables and merge on other datasets **********************************************************************************************************************
		************************************************************************************************************************************************************************************************
			foreach versionn in "16" "20" {
				use "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\work.dta", clear

				keep studwgt year homezip acerecode disthome strat hsgpa satv satm satw actcomp sex racegroup major firstgen ///
						act10 act11 act23 act24 act20 rate01 rate08 rate10 rate13 rate15 rate16 rate19 rate20 rate17 rate06 ///
						aid01 goal02 goal04 goal08 goal10 goal12 reason05 reason10 reason06 reason08 reason11 views28 ///
						fcareer fcareer74_n mcareer mcareer74_n hsrank01 hsrank02 goal18 poliview income fincon

				* HERI Freshman Survey databases don't include university locations, but they do include 1) permanent address zip codes and 2) distance of school from home address. 
				* This code uses perm addresses and distances to find likely zipcode location of school, then links the zip to a state 
					replace homezip = . if homezip == 0
					sort acerecode
					by acerecode: egen universityzi = mode(homezip) if disthome == 1, max
					by acerecode: egen universityzi2 = mode(homezip) if disthome == 2, max

				* Only keep the zip if there are at least 5 people saying the same mode zip code is close.
					foreach name in "zi" "zi2" {
						gen zipcount = 0
						replace zipcount = 1 if homezip == university`name' & university`name' != .
						by acerecode: egen zipcountt = sum(zipcount)
						replace university`name' = . if zipcountt < 5
						drop zipcount zipcountt
					}
					by acerecode: egen universityzip = max(universityzi)
					by acerecode: egen universityzip2 = max(universityzi2)
					replace universityzip = universityzip2 if universityzip == .
					sort acerecode homezip

				* As a means of checking our location proceedure, merge on data from the HERI Senior Surveys showing university to state matches. 
					merge m:1 acerecode using "C:\CCM\Data\HERI Senior\HERISeniorStates.dta"
					drop if _merge == 2
					drop _merge

				* Add states matched by zip code
					merge m:1 universityzip using "C:\CCM\Data\Macro variables\USZipCodesStates.dta"
					drop if _merge == 2
					drop _merge

					gen statecheck = 0
					replace statecheck = 1 if state == statesenior
					sum statecheck
					sum statecheck if statesenior != ""

					replace state = statesenior if state == "" & statesenior != ""

				* Add states of permanent residence
					* Change some variable names to use the same zip code to state crosswalk file. Change them back after. 
						rename universityzip universityzipbackup
						rename homezip universityzip
						rename state stateuniv

					merge m:1 universityzip using "C:\CCM\Data\Macro variables\USZipCodesStates.dta"
					drop if _merge == 2
					drop _merge
					
					rename state stateperm

					* Change variable names back.
						rename universityzip homezip
						rename universityzipbackup universityzip
					
					* Compare state measures
						gen samestate = 0
						replace samestate = 1 if stateperm == stateuniv
						replace samestate = . if stateperm == ""
						gen statepermn = 1
						replace statepermn = 0 if stateperm == ""
						gen stateunivn = 1
						replace stateunivn = 0 if stateuniv == ""
						
						display "****************************SAMESTATE COMPARISONS OF LOCATIONS BASED ON PERM VERSUS UNIV****************************************************"
							tabstat samestate statepermn stateunivn, s(sum n)
							tabstat samestate statepermn stateunivn, by(year) s(sum)
						display "****************************SAMESTATE COMPARISONS OF LOCATIONS BASED ON PERM VERSUS UNIV****************************************************"
	
				* Add state aaers merged to state of UNIVERSITY address (stateuniv)
					gen state = stateperm
					replace state = stateuniv
					merge m:1 state year using "C:\CCM\Data\Macro variables\AAERStateKeeper.dta"
						drop if _merge == 2
						drop _merge
						
					foreach loca in "state" {
						foreach name in "jar" "highmedia" "lowmedia" {
							forvalues i = 0(1)5 {
								rename fraud`loca'_`name'l`i' ufraud`loca'_`name'l`i'
								replace ufraud`loca'_`name'l`i' = 0 if ufraud`loca'_`name'l`i' == .
							}
						}
					}

					tabstat ufraudstate_jarl0 ufraudstate_jarl1 ufraudstate_jarl2 ufraudstate_jarl3 ufraudstate_jarl4 ufraudstate_jarl5 if state == "ny", by(year)
				
				* Add state aaers merged to state of permanent address (stateperm)
					replace state = stateperm	
					merge m:1 state year using "C:\CCM\Data\Macro variables\AAERStateKeeper.dta"
						drop if _merge == 2
						drop _merge
						
					foreach loca in "state" {
						foreach name in "jar" "highmedia" "lowmedia" {
							forvalues i = 0(1)5 {
								replace fraud`loca'_`name'l`i' = 0 if fraud`loca'_`name'l`i' == .
							}
						}
					}

					egen stateid = group(state)
					
				* Add state gdp growth
					merge m:1 year state using "C:\CCM\Data\Macro variables\BEA\gdpstatereal.dta"
						sort _merge state year
						drop if _merge == 2
						drop _merge
					forvalues i = 1(1)5 {
						merge m:1 year state using "C:\CCM\Data\Macro variables\BEA\gdpstaterealLag`i'.dta"
						drop if _merge == 2
						drop _merge
					}
					tabstat GDPg GDPgl1 GDPgl2 GDPgl3 GDPgl4 GDPgl5 if state == "ny", by(year)

				* Add state unemployment
					gen fsmatcher = 0
						replace fsmatcher = 1 if fullstate != ""
						replace fsmatcher = 1 if state != ""
					replace fsmatcher = 0
						replace fsmatcher = 1 if state != ""
						replace fsmatcher = 1 if fullstate != ""
						drop fsmatcher
						
					merge m:1 year fullstate using "C:\CCM\Data\Macro variables\UnemploymentStates1980_2019.dta"
						drop if _merge == 2
						drop _merge

				*add county aaers
					*******first use universityzip (zip of university)
					
					* Use the zip to fips crosswalk to get county fips codes (in the using file) matched to permanent address zip codes (in the master file)
						gen zip = universityzip
						merge m:1 zip using "C:\CCM\Data\Macro variables\BEA\ZipToFips.dta"
							drop if _merge == 2
							drop _merge
						
						gen twodig = substr(countyfips,1,2)
						replace twodig = twodig + "000"
						
						gen fipsmatch = (twodig == fips)
						replace fipsmatch = . if countyfips == ""
						sum fipsmatch
					
					* Merge county-level fraud counts onto countyfips
						merge m:1 year countyfips using "C:\CCM\Data\Macro variables\AAERCountyKeeper.dta"
							drop if _merge == 2
							drop _merge
					
						foreach loca in "county" {
							foreach name in "jar" "highmedia" "lowmedia" {
								forvalues i = 0(1)5 {
									rename fraud`loca'_`name'l`i' ufraud`loca'_`name'l`i' 
									replace ufraud`loca'_`name'l`i' = 0 if ufraud`loca'_`name'l`i' == .
								}
							}
						}
						tabstat ufraudcounty_jarl* if countyfips == "36061", by(year)
						rename countyfips ucountyfips
					
					*******now use homezip (zip of permanent address)
					* Use the zip to fips crosswalk to get county fips codes (in the using file) matched to permanent address zip codes (in the master file)
						replace zip = homezip
						merge m:1 zip using "C:\CCM\Data\Macro variables\BEA\ZipToFips.dta"
							drop if _merge == 2
							drop _merge
						
						replace twodig = substr(countyfips,1,2)
						replace twodig = twodig + "000"
						
						replace fipsmatch = (twodig == fips)
						replace fipsmatch = . if countyfips == ""
						sum fipsmatch
					
					* Merge county-level fraud counts onto countyfips
						merge m:1 year countyfips using "C:\CCM\Data\Macro variables\AAERCountyKeeper.dta"
							drop if _merge == 2
							drop _merge
					
						foreach loca in "county" {
							foreach name in "jar" "highmedia" "lowmedia" {
								forvalues i = 0(1)5 {
									replace fraud`loca'_`name'l`i' = 0 if fraud`loca'_`name'l`i' == .
								}
							}
						}
								
				* Rescale GPA to be on a more traditional 4 point scale. 
					gen gpa = . 
					replace gpa = 4 if hsgpa == 8
					replace gpa = 3.67 if hsgpa == 7
					replace gpa = 3.33 if hsgpa == 6
					replace gpa = 3 if hsgpa == 5
					replace gpa = 2.67 if hsgpa == 4
					replace gpa = 2.33 if hsgpa == 3
					replace gpa = 2 if hsgpa == 2
					replace gpa = 1 if hsgpa == 1

				* Test scores
					format satv satm actcomp %5.0g
					tabstat satv satm actcomp, s(n) by(year)
					sort year satv

					egen psatv = xtile(satv), weights(studwgt) by(year) p(.1(.1)99.9) 
					egen psatm = xtile(satm), weights(studwgt) by(year) p(.1(.1)99.9) 
					egen pactcomp = xtile(actcomp), weights(studwgt) by(year) p(.1(.1)99.9) 

					* Rescale
					replace psatv = psatv / 10
					replace psatm = psatm / 10
					replace pactcomp = pactcomp / 10

				* Race and gender
					gen female = (sex==2)
					gen black = (racegroup==3)
					gen hispanic = (racegroup==4)
					gen namerican = (racegroup==1)
					gen minority = 0
					replace minority = 1 if black == 1
					replace minority = 1 if hispanic == 1
					replace minority = 1 if namerican == 1

				* Rename HERI variables to make them more readable
					rename rate20 writing

					rename goal04 authority
					rename goal10 lifephilosophy
					rename goal12 helpothers

					rename reason05 betterjob
					rename reason10 interested
					rename reason06 makemoney
					rename reason08 appreciationideas
					rename reason11 cultured

				* Standard errors cannot be calculated if there is a stratum with only 1 psu. 
				* Reassign psus that are alone in their stratum to a similar neighboring stratum.
					svyset acerecode [pweight=studwgt], strata(strat) singleunit(scaled)
					svydes

					* Pool some HBCUs from small strata
						replace strat = 38 if strat == 39
						replace strat = 38 if strat == 41
						svydes

				* Accounting majors, business majors
					gen accounting = 0
						replace accounting = 1 if major == 34
						replace accounting = . if major == .

					gen business = 0
						replace business = 1 if major == 35
						replace business = 1 if major == 37
						replace business = 1 if major == 40
						replace business = 1 if major == 41
						replace business = 1 if major == 42
						replace business = 1 if major == 46
						replace business = . if major == .

				* First generation college
					gen firstgenn = 0
						replace firstgenn = 1 if firstgen == 2
						replace firstgenn = . if firstgen == .

				save "C:\CCM\Data\HERI TFS\20`versionn'download\OriginalsDTA\analysis.dta", replace
			}
			
		*cleanup 
			forvalues i = 0(1)5 {
				erase "C:\CCM\Data\Macro variables\AAERStatejarLag`i'.dta"
				erase "C:\CCM\Data\Macro variables\AAERCountyjarLag`i'.dta"
				erase "C:\CCM\Data\Macro variables\AAERStatehighmediaLag`i'.dta"
				erase "C:\CCM\Data\Macro variables\AAERStatelowmediaLag`i'.dta"
				erase "C:\CCM\Data\Macro variables\AAERCountyhighmediaLag`i'.dta"
				erase "C:\CCM\Data\Macro variables\AAERCountylowmediaLag`i'.dta"
			}
			forvalues i = 1(1)5 {
			    erase "C:\CCM\Data\Macro variables\BEA\gdpstaterealLag`i'.dta"
			}

		************************************************************************************************************************************************************************************************
		********************* Append the 2016 and 2020 files ********************************************************************************************************************************************
		************************************************************************************************************************************************************************************************
			use "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\analysis.dta", clear
				keep if year < 2007
				keep acerecode major accounting business year strat studwgt state stateid stateperm stateuniv samestate universityzip homezip countyfips ///
					gpa firstgenn fraud* ufraud* ///
					GDPg GDPgl1 GDPgl2 GDPgl3 GDPgl4 GDPgl5 ///
					fcareer fcareer74_n mcareer mcareer74_n ///
					appreciationideas helpothers lifephilosophy interested cultured ///
					makemoney betterjob authority ///
					goal18 poliview ///
					female writing black hispanic namerican minority ///
					psatv psatm pactcomp satv satm actcomp ///
					unemploy fips income fincon
			save "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\analysis2.dta", replace

			use "C:\CCM\Data\HERI TFS\2020download\OriginalsDTA\analysis.dta", clear
				keep if year > 2006
				keep acerecode major accounting business year strat studwgt state stateid stateperm stateuniv samestate universityzip homezip countyfips ///
					gpa firstgenn fraud* ufraud* ///
					GDPg GDPgl1 GDPgl2 GDPgl3 GDPgl4 GDPgl5 ///
					fcareer fcareer74_n mcareer mcareer74_n ///
					appreciationideas helpothers lifephilosophy interested cultured ///
					makemoney betterjob authority ///
					goal18 poliview ///
					female writing black hispanic namerican minority ///
					psatv psatm pactcomp satv satm actcomp ///
					unemploy fips income
			save "C:\CCM\Data\HERI TFS\2020download\OriginalsDTA\analysis2.dta", replace

			append using "C:\CCM\Data\HERI TFS\2016download\OriginalsDTA\analysis.dta"
				sort acerecode year
				save "C:\CCM\Data\HERI TFS\2020download\OriginalsDTA\analysis2.dta", replace

	************************************************************************************************************************************************************************************************
	********************* END OF HERI ORGANIZATION SECTION *******************************************************************************************************************************************
	************************************************************************************************************************************************************************************************

	***********************************************************************************************************************************
	**** Add some local control variables *********************************************************************************************
	***********************************************************************************************************************************
		* In the "analysis2" file
			* countyfips is from home zip code. Format is 5-digit string
			* ucountyfips is from university zip code
			* homezip is home zip code
			* universityzip is university zip code
			
		import sas using "C:\CCM\Data\us_census_1980_2019.sas7bdat", clear
			rename STCOU countyfips
			rename Year year
			rename Area_name county_from_AgeEdMin
			rename Age age
			rename Education education
			rename Minority minority_census
			
			drop if substr(countyfips,3,3) == "000"
			
			destring countyfips, gen(intfips)
			tsset intfips year
				foreach name in age education minority_census {
					gen `name'l0 = `name'
					gen `name'l1 = l.`name'
					gen `name'l2 = l2.`name'
					gen `name'l3 = l3.`name'
					gen `name'l4 = l4.`name'
					gen `name'l5 = l5.`name'
				}
			drop intfips
		save "C:\CCM\Data\Macro variables\DaneCountyAgeEdMinorityJAR.dta", replace

		* State-level
		import sas using "C:\CCM\Data\us_census_1980_2019.sas7bdat", clear
			rename STCOU statefips
			rename Year year
			rename Area_name state_from_AgeEdMin
			rename Age stateage
			rename Education stateeducation
			rename Minority stateminority_census
			
			keep if substr(statefips,3,3) == "000"
			drop if substr(statefips,1,2) == "00"
			
			destring statefips, gen(intfips)
			tsset intfips year
				foreach name in stateage stateeducation stateminority_census {
					gen `name'l0 = `name'
					gen `name'l1 = l.`name'
					gen `name'l2 = l2.`name'
					gen `name'l3 = l3.`name'
					gen `name'l4 = l4.`name'
					gen `name'l5 = l5.`name'
				}
			drop intfips
		save "C:\CCM\Data\Macro variables\DaneStateAgeEdMinorityJAR.dta", replace

		* Import and organize BEA per capita income 
		import delimited "C:\CCM\Data\BEA Per Capita Income\CAINC1__ALL_AREAS_1969_2019.csv", clear 
			foreach v of varlist v9-v59 {
				local x : variable label `v'
				rename `v' y`x'
		}
			replace geofips =  subinstr(geofips,`"""',"",2)
			rename geofips countyfips
			rename geoname county_from_PerCap
			keep if linecode == 3

			replace countyfips = trim(countyfips)
			drop if substr(countyfips,3,3) == "000"
			
			drop region tablename linecode industryclassification description unit
			
			reshape long y, i(countyfips county_from_PerCap) j(year)
			rename y pcinc
			replace pcinc = "" if pcinc == "(NA)"
			destring pcinc, replace
			
			destring countyfips, gen(intfips)
			tsset intfips year
			
			gen pcincl0 = pcinc
			gen pcincl1 = l1.pcinc
			gen pcincl2 = l2.pcinc
			gen pcincl3 = l3.pcinc
			gen pcincl4 = l4.pcinc
			gen pcincl5 = l5.pcinc
			
			gen pcincgl0 = (pcinc - l1.pcinc)/l1.pcinc
			gen pcincgl1 = l1.pcincgl0
			gen pcincgl2 = l2.pcincgl0
			gen pcincgl3 = l3.pcincgl0
			gen pcincgl4 = l4.pcincgl0
			gen pcincgl5 = l5.pcincgl0
			
		save "C:\CCM\Data\Macro variables\DaneCountyPerCapitaIncomeJAR.dta", replace

		* State BEA per capita income
		import delimited "C:\CCM\Data\BEA Per Capita Income\CAINC1__ALL_AREAS_1969_2019.csv", clear 
			foreach v of varlist v9-v59 {
				local x : variable label `v'
				rename `v' y`x'
		}
			replace geofips =  subinstr(geofips,`"""',"",2)
			rename geofips statefips
			rename geoname state_from_PerCap
			keep if linecode == 3

			replace statefips = trim(statefips)
			keep if substr(statefips,3,3) == "000"
			drop if substr(statefips,1,2) == "00"
			
			drop region tablename linecode industryclassification description unit
			
			reshape long y, i(statefips state_from_PerCap) j(year)
			rename y statepcinc
			replace statepcinc = "" if statepcinc == "(NA)"
			destring statepcinc, replace
			
			destring statefips, gen(intfips)
			tsset intfips year
			
			gen statepcincl0 = statepcinc
			gen statepcincl1 = l1.statepcinc
			gen statepcincl2 = l2.statepcinc
			gen statepcincl3 = l3.statepcinc
			gen statepcincl4 = l4.statepcinc
			gen statepcincl5 = l5.statepcinc
			
			gen statepcincgl0 = (statepcinc - l1.statepcinc)/l1.statepcinc
			gen statepcincgl1 = l1.statepcincgl0
			gen statepcincgl2 = l2.statepcincgl0
			gen statepcincgl3 = l3.statepcincgl0
			gen statepcincgl4 = l4.statepcincgl0
			gen statepcincgl5 = l5.statepcincgl0
			
		save "C:\CCM\Data\Macro variables\DaneStatePerCapitaIncomeJAR.dta", replace

		* Merge with analysis file
		use "C:\CCM\Data\HERI TFS\2020download\OriginalsDTA\analysis2.dta", clear
			merge m:1 countyfips year using "C:\CCM\Data\Macro variables\DaneCountyAgeEdMinorityJAR.dta"
				drop if _merge == 2
				drop _merge
			merge m:1 countyfips year using "C:\CCM\Data\Macro variables\DaneCountyPerCapitaIncomeJAR.dta"
				drop if _merge == 2
				drop _merge
			
			rename fips statefips
			merge m:1 statefips year using "C:\CCM\Data\Macro variables\DaneStateAgeEdMinorityJAR.dta"
				drop if _merge == 2
				drop _merge
			merge m:1 statefips year using "C:\CCM\Data\Macro variables\DaneStatePerCapitaIncomeJAR.dta"
				drop if _merge == 2
				drop _merge
			
		save "C:\CCM\Data\HERI TFS\2020download\OriginalsDTA\analysis3.dta", replace
		
	***********************************************************************************************************************************
	**** Additional variable definitions and transformations **************************************************************************
	***********************************************************************************************************************************
		use "C:\CCM\Data\HERI TFS\2020download\OriginalsDTA\analysis3.dta", clear
		*fraud measures
			foreach name in fraudstate_jar fraudcounty_jar {		
				gen `name'4 = `name'l0 + `name'l1 + `name'l2 + `name'l3 
				gen u`name'4 = u`name'l0 + u`name'l1 + u`name'l2 + u`name'l3 
			}	
			rename fraudstate_jar4 fraud4
			rename ufraudstate_jar4 ufraud4
			rename fraudcounty_jar4 cfraud4
			rename ufraudcounty_jar4 cufraud4

		* Fraud4 high media
			foreach name in "lowmedia" "highmedia" {
				gen fraud4_`name' = fraudstate_`name'l0 + fraudstate_`name'l1 + fraudstate_`name'l2 + fraudstate_`name'l3	
				gen cfraud4_`name' = fraudcounty_`name'l0 + fraudcounty_`name'l1 + fraudcounty_`name'l2 + fraudcounty_`name'l3	
			}
			
		*alternative fraud measures
			gen fraud4dum = (fraud4>0)
			gen cfraud4dum = (cfraud4>0)
			gen lfraud4 = ln(1 + fraud4)
			gen lcfraud4 = ln(1 + cfraud4)
			gen fraud4pos = fraud4
				replace fraud4pos = . if fraud4 == 0
			gen cfraud4pos = cfraud4
				replace cfraud4pos = . if fraud4 == 0
		
		*alternative fraud measures again but using only high media frauds
			gen fraud4dum_h = (fraud4_highmedia>0)
			gen cfraud4dum_h = (cfraud4_highmedia>0)
			gen lfraud4_h = ln(1 + fraud4_highmedia)
			gen lcfraud4_h = ln(1 + cfraud4_highmedia)
			gen fraud4pos_h = fraud4_highmedia
				replace fraud4pos_h = . if fraud4_highmedia == 0
			gen cfraud4pos_h = cfraud4_highmedia
				replace cfraud4pos_h = . if fraud4_highmedia == 0

		* Other 4 year average measures
			gen pcincg4 = (pcincgl0 + pcincgl1 + pcincgl2 + pcincgl3) / 4
			gen statepcincg4 = (statepcincgl0 + statepcincgl1 + statepcincgl2 + statepcincgl3) / 4
			gen GDPg4 = (GDPg + GDPgl1 + GDPgl2 + GDPgl3) / 4

		*sub tags observations that are in the main analysis sample
			gen sub = 1
				replace sub = 0 if state == ""
				replace sub = 0 if major == .
				replace sub = 0 if year < 1985
			
		* Test scores
			egen avetest = rowmean(psatv psatm pactcomp)
			replace avetest = avetest / 100
			replace psatv = psatv / 100
			replace psatm = psatm / 100
			replace pactcomp = pactcomp / 100
			
		* Rescale unemployment rate
			replace unemploy = unemploy / 100
		
		* Log transform some demographic/geographic measures
			foreach name in education age minority_census {
				gen l`name' = ln(`name')
				gen lstate`name' = ln(state`name')
			}
				
		* Parents
			gen paccounting = 0
			replace paccounting = 1 if fcareer == 11
			replace paccounting = 1 if mcareer == 11
			replace paccounting = 1 if fcareer74_n == 1
			replace paccounting = 1 if mcareer74_n == 1
			replace paccounting = . if fcareer == . & mcareer == . & fcareer74_n == . & mcareer74_n == .
		
		* Parent income deciles
			gen incomeno = income

			forvalues pi = 10(10)90 {
				gen income`pi'cut = .
				replace income`pi'cut = .
			}
			forvalues i = 1971(1)2009 {
				forvalues pi = 10(10)90 {
					display "i is `i' and pi is `pi'"
					_pctile income [pweight=studwgt] if year == `i' & sub == 1, p(`pi')
						return list
						replace income`pi'cut = r(r1) if year == `i' & sub == 1
				}
			}
			
			gen incomedec = .
			replace incomedec = .
				replace incomedec = 1 if income != 0 & income < income10cut
				replace incomedec = 2 if income >= income10cut & income < income20cut
				replace incomedec = 3 if income >= income20cut & income < income30cut
				replace incomedec = 4 if income >= income30cut & income < income40cut
				replace incomedec = 5 if income >= income40cut & income < income50cut
				replace incomedec = 6 if income >= income50cut & income < income60cut
				replace incomedec = 7 if income >= income60cut & income < income70cut
				replace incomedec = 8 if income >= income70cut & income < income80cut
				replace incomedec = 9 if income >= income80cut & income < income90cut
				replace incomedec = 10 if income >= income90cut & income != .
				
		*get sample of observations with required data
			
			gen hasdata = sub
			foreach name in "stateid" "accounting" "fraud4" "cfraud4" "avetest" "firstgenn" "GDPg" ///
							"pcincg4" "leducation" "lage" "lminority_census" ///
							"statepcincg4" "lstateeducation" "lstateage" "lstateminority_census" ///
							"unemploy" "paccounting" "writing" "female" "minority"  ///
							"appreciationideas" "helpothers" "lifephilosophy" "interested" "cultured" "makemoney" "betterjob" "authority" "incomedec" {
				replace hasdata = 0 if `name' == .
			}
		
			replace sub = 0 if hasdata == 0
		
		* Factors: public service orientation and commercial orientation
			factor  appreciationideas helpothers lifephilosophy interested cultured ///
					makemoney betterjob authority [aweight=studwgt] if sub == 1, ipf
						
			factor  appreciationideas helpothers lifephilosophy interested cultured ///
					makemoney betterjob authority [aweight=studwgt] if sub == 1, ipf  factors(2)
				rotate, oblimin oblique	
			predict pubserv commercial

		* Hard sciences and engineering		
			*Biology (general [17], Biochemistry/Bio [18], Botany [19], Environmental Sc [21], Marine (life) Sc [22], Microbiology or [24], Zoology [26], Agriculture [30], 
			*Other Biological [33], Aeronautical or [54], Civil Engineerin [58], Chemical Enginee [59], Electrical or El [60], Industrial Engin [64], Mechanical Engin [67], 
			*Other Engineerin [68], Health Technolog [71], Medical, Dental, [72], Nursing [73], Pharmacy [74], Therapy (occupat [75], Computer Science [78], 
			*Mathematics [79], Statistics [80], Astronomy [83], Atmospheric Scie [85], Chemistry [86], Earth Science [87], Marine Sciences [89], Physics [90], Other Physical S [91],
			*Building Trades [105], Data Processing [106], Electronics [108], Mechanics [109], Forestry [112].
			gen hardengin = 0
				replace hardengin = 1 if major ==  17
				replace hardengin = 1 if major ==  18
				replace hardengin = 1 if major ==  19
				replace hardengin = 1 if major ==  21
				replace hardengin = 1 if major ==  22
				replace hardengin = 1 if major ==  24
				replace hardengin = 1 if major ==  26
				replace hardengin = 1 if major ==  30
				replace hardengin = 1 if major ==  33
				replace hardengin = 1 if major ==  54
				replace hardengin = 1 if major ==  58
				replace hardengin = 1 if major ==  59
				replace hardengin = 1 if major ==  60
				replace hardengin = 1 if major ==  64
				replace hardengin = 1 if major ==  67
				replace hardengin = 1 if major ==  68
				replace hardengin = 1 if major ==  71
				replace hardengin = 1 if major ==  72
				replace hardengin = 1 if major ==  73
				replace hardengin = 1 if major ==  74
				replace hardengin = 1 if major ==  75
				replace hardengin = 1 if major ==  78
				replace hardengin = 1 if major ==  79
				replace hardengin = 1 if major ==  80
				replace hardengin = 1 if major ==  83
				replace hardengin = 1 if major ==  85
				replace hardengin = 1 if major ==  86
				replace hardengin = 1 if major ==  87
				replace hardengin = 1 if major ==  89
				replace hardengin = 1 if major ==  90
				replace hardengin = 1 if major ==  91
				replace hardengin = 1 if major ==  105
				replace hardengin = 1 if major ==  106
				replace hardengin = 1 if major ==  108
				replace hardengin = 1 if major ==  109
				replace hardengin = 1 if major ==  112
			
		* Other business majors where comparison group is only hardengin
				gen busadmin = 0
					replace busadmin = 1 if major == 35
				gen finance = 0
					replace finance = 1 if major == 37
				gen intbus = 0
					replace intbus = 1 if major == 40
				gen marketing = 0
					replace marketing = 1 if major == 41
				gen management = 0
					replace management = 1 if major == 42
				gen otherbus = 0
					replace otherbus = 1 if major == 46
				gen econ = 0
					replace econ = 1 if major == 93
					
				foreach name in busadmin finance intbus marketing management otherbus econ {
					replace `name' = . if major == .
				}
				
		save "C:\CCM\analysis4.dta", replace
			
