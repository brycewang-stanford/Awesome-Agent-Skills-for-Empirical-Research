********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
****																		****
**** Module:	Importing Amadeus Data (STATA Version)						****
**** Author: 	Matthias Breuer												****
**** Date: 	 	12/13/2016													****
********************************************************************************

*** Initiations ***
clear all
set more off
unicode encoding set UTF8 // STATA Version 14

********************************************************************************
**** (0) Choices/Options													****
********************************************************************************

/* Directory/Folder Path */
local directory = ".../IGM-BVD_Amadeus" // insert directory path for raw data (downloads from BvD discs)
local output = ".../IGM-BVD_Amadeus/STATA_Data" // insert directory for converted data

/* Section */
local section = "Company" // insert section (Financials, Company, Ownership, Subsidiaries)

/* Year */
local year = 2008 // insert year (of BvD disc)

********************************************************************************
**** (1) Importing: Financials												****
********************************************************************************

/* Section: Financials */
if "`section'" == "Financials" {

	/* Folder List */
	local folders: dir "`directory'/`year'/`section'" dirs "*"

	/* Folder Loop */
	foreach country of local folders {

		/* File List */
		local files: dir "`directory'/`year'/`section'/`country'" files "*"
		
		/* File Loop */
		foreach file of local files {
		
			/* Vintage Condition: Old Vintage */
			if `year' == 2005 | `year' == 2008 {
			
				/* Import */
				insheet using "`directory'/`year'/`section'/`country'/`file'", name tab clear double
			
				/* Check Import */
				if c(k) < 50 {
					insheet using "`directory'/`year'/`section'/`country'/`file'", name delimiter(".") clear double
				}
				
				if c(k) < 50 {
					insheet using "`directory'/`year'/`section'/`country'/`file'", name delimiter(";") clear double
				}
				
				/* Rename Header */
				
					/* Obtain Variable List */
					ds
					local varlist = r(varlist)
					
					/* Variable Loop */
					foreach var of local varlist {
						forvalues i = 0(1)9 {
							if strpos("`var'", "`i'") != 0 {
								local new_name = substr("`var'", 1, strpos("`var'", "`i'")-1)
								rename `var' `new_name'`i'
								local num_list: list num_list | new_name
							}
						}
					/* Close: Variable List */
					}

				/* Reshape */
				drop if (accnr == "" & idnr == "") | (accnr == "n.a." & idnr == "n.a.") | (accnr == "Credit needed" & idnr == "Credit needed")
				reshape long `num_list', i(company idnr accnr consol) j(rel_year) string
				
				/* Drop missing */
				drop if statda == "" | statda == "n.a."
				
				/* Save Intermediate Data */
				cd "`output'/`section'"
				save intermediate_`year', replace
		
			/* Close: Old Vintage */
			}
			
			/* Vintage Condition: New Vintage */
			if `year' == 2012 {
			
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(tab) varnames(1) clear
			
				/* Check Import */
				if c(k) < 50 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(".") varnames(1) clear
				}
				
				if c(k) < 50 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(";") varnames(1) clear
				}
				
				/* Rename Header */
				
					/* Manual Adjustment */
					cap rename v1 company
					cap rename ï company
					rename statdate statda
					drop v3-v11 v13-v21 v33-v41
					
					/* Obtain Variable List */
					ds, has(varlabel)
					local varlist = r(varlist)
					local static_list = "company idnr accnr consol"
					local num_list: list varlist - static_list
					ds
					local varlist = r(varlist)
					local long_list: list varlist - static_list

					/* Variable Loop */
					foreach var of local num_list {
						foreach v of local long_list {
							if "`var'" == "`v'" {
								local new_name = "`var'"
								local i = 0
							}

							if `i' < 10 {
								rename `v' `new_name'`i'
								local i = `i' +1
							}
						}
					/* Close: Variable List */
					}

				/* Reshape */
				drop if (accnr == "" & idnr == "") | (accnr == "n.a." & idnr == "n.a.") | (accnr == "Credit needed" & idnr == "Credit needed")
				reshape long `num_list', i(company idnr accnr consol) j(rel_year) string
				
				/* Drop missing */
				drop if statda == "" | statda == "n.a."
				
				/* Save Intermediate Data */
				cd "`output'/`section'"
				save intermediate_`year', replace
			
			/* Close: New Vintage */
			}
			
			/* Append Data */
			capture append using data_`year', force 
			
			/* Save Appended Data */
			save data_`year', replace
			
		/* Close: File Loop */
		}
		
		/* Reformat Variables */
		
			/* Obtain Variable List */
			ds
			local varlist = r(varlist)
			local char_list = "company idnr accnr consol statda"
			local num_list: list varlist - char_list
			
			/* Variable Loop */
			foreach var of local num_list {
				destring `var', replace ignore(",") force
			}	
		
		/* Save (by Country) */
		save "`country'_`section'_`year'", replace

		/* Deleting Intermediate Data */
		rm data_`year'.dta
		rm intermediate_`year'.dta
		
		/* Deleting Numlist Local */
		local num_list
		
	/* Close: Folder Loop */
	}

/* Close: Financials Section */
}	

********************************************************************************
**** (2) Importing: Company Sections										****
********************************************************************************

/* Section: Company */
if "`section'" == "Company" {

	/* Folder List */
	local folders: dir "`directory'/`year'/`section'" dirs "*"

	/* Folder Loop */
	foreach country of local folders {

		/* File List */
		local files: dir "`directory'/`year'/`section'/`country'" files "*"
	
		/* Vintage Condition: Old Vintage (2005-2007) */
		if `year' <= 2007 {
		
			/* File Loop */
			foreach file of local files {
			
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
			
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
				
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}
				
				/* Destring */
				destring ///
					months0* ///
					exchra0* ///
					unit0* ///
					opre0* ///
					pl0* ///
					empl0* ///
					hdr_mar ///
					onbr ///
					snbr ///
					, replace ignore(",")
					
				/* Rename */
				rename months* months
				rename exchra* exchrate
				rename unit* unit
				rename opre* opre_c
				rename pl* pl_c
				rename empl* empl_c
				
				/* Compress */
				compress
				
				/* Save Intermediate Data */
				cd "`output'/`section'"
				save intermediate_`year', replace
			
				/* Append Data */
				capture append using data_`year', force 
				
				/* Save Appended Data */
				save data_`year', replace
			
			/* Close: File Loop */
			}	
		
		/* Save (by Country) */
		save "`country'_`section'_`year'", replace

		/* Deleting Intermediate Data */
		rm data_`year'.dta
		rm intermediate_`year'.dta
		
		/* Close: Old Vintage (2005-2007) */
		}		
		
		/* Vintage Condition: Old Vintage (2008) */
		if `year' == 2008 {
		
			/* File Loop */
			foreach file of local files {
					
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
				
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
					
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}
 
				/* Destring */
				destring ///
					empl* ///
					opre* ///
					pl* ///
					onbr ///
					snbr ///
					hdr_mar ///
					months* ///
					exch* ///
					, replace ignore(",")
							
				/* Rename */
				rename months* months
				rename exchra* exchrate
				rename unit* unit_string
				rename opre* opre_c
				rename pl* pl_c
				rename empl* empl_c
				rename company company_name
				rename ad_name auditor_name
				rename idnr bvd_id_number
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Shareholders */
					preserve

						/* Keep shareholder information */
						keep accnr ult* d* is* shhtext oname oid oticker ocountry otype onace onaics odirect ototal osource odate ocldate ooprev ototas oempl
						
						/* Duplicates drop */
						duplicates drop accnr accnr ult* d* is* shhtext oname oid oticker ocountry otype onace onaics odirect ototal osource odate ocldate ooprev ototas oempl, force
						
						/* Save Intermediate Data */
						cd "`output'/Ownership"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Ownership_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Ownership_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore

					/* Subsidiaries */
					preserve

						/* Keep shareholder information */
						keep accnr subtext sname sid sticker scountry stype snace snaics sdirect stotal slevel sstatus ssource sdate scldate soprev subtast subempl
						
						/* Duplicates drop */
						duplicates drop accnr subtext sname sid sticker scountry stype snace snaics sdirect stotal slevel sstatus ssource sdate scldate soprev subtast subempl, force
						
						/* Save Intermediate Data */
						cd "`output'/Subsidiaries"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Subsidiaries_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Subsidiaries_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep mangers */
						keep accnr mg_*
						
						/* Duplicates drop */
						duplicates drop accnr mg_*, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop other */
						drop is* ult* d* mg_* shhtext oname oid oticker ocountry otype onace onaics odirect ototal osource odate ocldate ooprev ototas oempl subtext sname sid sticker scountry stype snace snaics sdirect stotal slevel sstatus ssource sdate scldate soprev subtast subempl
 
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2008) */
		}	
			
		/* Vintage Condition: Old Vintage (2009) */
		if `year' == 2009 {
		
			/* File Loop */
			foreach file of local files {
					
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
				
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
					
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}

				/* Destring */
				destring ///
					employees* ///
					operatingrevenueturnover* ///
					plforperiod** ///
					marketcapitalisation* ///
					noofrecordedshareholders ///
					noofrecsubsidiaries ///
					numberofmonthslast* ///
					exchangerate* ///
					, replace ignore(",")
							
				/* Rename */
				rename numberofmonthslast* months
				rename exchangerate* exchrate
				rename unit* unit_string
				rename operatingrevenueturnover* opre_c
				rename plforperiod* pl_c
				rename employees* empl_c
				rename marketcapital* hdr_mar
				rename noofrecordedshareholders onbr
				rename noofrecsubsidiaries snbr
				rename bvdepaccountnumber accnr
				rename companyname company_name
				rename auditorname auditor_name
				rename bvdepidnumber bvd_id_number
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Shareholders */
					preserve

						/* Keep shareholder information */
						keep accnr shareholder* domestic* immediate* global* v99 v114
						
						/* Duplicates drop */
						duplicates drop accnr shareholder* domestic* immediate* global* v99 v114, force
						
						/* Save Intermediate Data */
						cd "`output'/Ownership"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Ownership_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Ownership_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore

					/* Subsidiaries */
					preserve

						/* Keep shareholder information */
						keep accnr subsidiar*
						
						/* Duplicates drop */
						duplicates drop accnr subsidiar*, force
						
						/* Save Intermediate Data */
						cd "`output'/Subsidiaries"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Subsidiaries_`year'", force // note: drops information in using if string-numeric mismatch occurs
						
						/* Save Appended Data */
						save "`country'_Subsidiaries_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep bankers */
						keep accnr firstname middlename lastname fullname title salutation dateofbirth dateofbirth nationality homeaddress homecountry titlesince biography
						
						/* Duplicates drop */
						duplicates drop accnr firstname middlename lastname fullname title salutation dateofbirth dateofbirth nationality homeaddress homecountry titlesince biography, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop other */
						drop shareholder* domestic* immediate* global* v99 v114 subsidiar* firstname middlename lastname fullname title salutation dateofbirth dateofbirth nationality homeaddress homecountry titlesince biography
 
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2009) */
		}			
	
		/* Vintage Condition: Old Vintage (2010) */
		if `year' == 2010 {
		
			/* File Loop */
			foreach file of local files {

				/* Version 1 */
				capture {
					
					/* Error */
					local error = 1
					
					/* Import */
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(4) rowrange(5:) clear asdouble stringcols(_all) 
				
					/* Check Import */
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(4) rowrange(5:) clear asdouble stringcols(_all)
					}

					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(4) rowrange(5:) clear asdouble stringcols(_all)
					}
					
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(4) rowrange(5:) clear asdouble stringcols(_all)
					}
				
					/* Alternative variable names */
					
						/* Drop */
						drop v1
						
						/* Destring */
						destring ///
							oprevenuemileurlast* ///
							plforperiodmileurlast* ///
							marketcapitalisation* ///
							noofrecshareholders ///
							noofrecsubsidiaries ///
							peergroupsize ///
							numberofmonthslast* ///
							exchangeratefromlocalcurrencyeur ///
							, replace ignore(",")
							
						/* Rename */
						rename numberofmonthslast* months
						rename exchangeratefromlocalcurrencyeur exchrate
						rename accountunitlast* unit_string
						rename oprevenuemileurlast* opre_c
						rename plforperiodmileurlast* pl_c
						rename numberofemployeeslast* empl_c
						rename marketcapital* hdr_mar
						rename noofrecshareholders onbr
						rename noofrecsubsidiaries snbr
						rename bvdaccountnumber accnr
						rename companyname company_name
						rename auditorname auditor_name
						rename bvdidnumber bvd_id_number
						
						/* Error */
						local error = 0
				}
					
				/* Version 2: different datarows  */
				if `error' == 1  {
					
					/* Import */
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(16) rowrange(17:) clear asdouble stringcols(_all) 
				
					/* Check Import */
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(16) rowrange(17:) clear asdouble stringcols(_all)
					}

					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(16) rowrange(17:) clear asdouble stringcols(_all)
					}
					
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(16) rowrange(17:) clear asdouble stringcols(_all)
					}
				
					/* Alternative variable names */
					
						/* Drop */
						drop v1
						
						/* Destring */
						destring ///
							oprevenuemileurlast* ///
							plforperiodmileurlast* ///
							marketcapitalisation* ///
							noofrecshareholders ///
							noofrecsubsidiaries ///
							peergroupsize ///
							numberofmonthslast* ///
							exchangeratefromlocalcurrencyeur ///
							, replace ignore(",")
							
						/* Rename */
						rename numberofmonthslast* months
						rename exchangeratefromlocalcurrencyeur exchrate
						rename accountunitlast* unit_string
						rename oprevenuemileurlast* opre_c
						rename plforperiodmileurlast* pl_c
						rename numberofemployeeslast* empl_c
						rename marketcapital* hdr_mar
						rename noofrecshareholders onbr
						rename noofrecsubsidiaries snbr
						rename bvdaccountnumber accnr
						rename companyname company_name
						rename auditorname auditor_name
						rename bvdidnumber bvd_id_number
				}					
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Bankers */
					preserve

						/* Keep bankers */
						keep accnr banker*
						
						/* Duplicates drop */
						duplicates drop accnr banker*, force
						
						/* Save Intermediate Data */
						cd "`output'/Bankers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Bankers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Bankers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep bankers */
						keep accnr bm*
						
						/* Duplicates drop */
						duplicates drop accnr bm*, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop bankers & managers */
						drop banker* bm* 
						
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2010) */
		}			
	
		/* Vintage Condition: Old Vintage (2011) */
		if `year' == 2011 {
		
			/* File Loop */
			foreach file of local files {
			
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
			
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
				
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}
				
				/* Alternative variable names */
				
					/* Version 1 */
					capture {
						
						/* Drop */
						drop mark
						
						/* Destring */
						destring ///
							op_revenue_mil_eur_last* ///
							p_l_for_period_mil_eur_last* ///
							total_assets_mil_eur_last* ///
							current_market_capitalisation* ///
							no_of_recorded_shareholders ///
							no_of_recorded_subsidiaries ///
							peer_group_size ///
							number_of_months_last* ///
							var98 ///
							, replace ignore(",")
							
						/* Rename */
						rename number_of_months_last* months
						rename var98 exchrate
						rename account_unit_last* unit_string
						rename op_revenue_mil_eur_last* opre_c
						rename p_l_for_period_mil_eur_last* pl_c
						rename total_assets_mil_eur_last* at_c
						rename number_of_employees_last* empl_c
						rename current_market_capitalisation hdr_mar
						rename no_of_recorded_shareholders onbr
						rename no_of_recorded_subsidiaries snbr
						rename bvd_account_number accnr

					}
					
					/* Version 2 */
					capture {
					
						/* Drop */
						drop *mark
						
						/* Destring */
						destring ///
							oprevenuemileurlast* ///
							plforperiodmileurlast* ///
							totalassetsmileurlast* ///
							currentmarketcapitalisation* ///
							noofrecordedshareholders ///
							noofrecordedsubsidiaries ///
							peergroupsize ///
							numberofmonthslast* ///
							exchangeratefromlocalcurrencyeur ///
							, replace ignore(",")
							
						/* Rename */
						rename numberofmonthslast* months
						rename exchangeratefromlocalcurrencyeur exchrate
						rename accountunitlast* unit_string
						rename oprevenuemileurlast* opre_c
						rename plforperiodmileurlast* pl_c
						rename totalassetsmileurlast* at_c
						rename numberofemployeeslast* empl_c
						rename currentmarketcapitalisation hdr_mar
						rename noofrecordedshareholders onbr
						rename noofrecordedsubsidiaries snbr
						rename bvdaccountnumber accnr
						rename companyname company_name
						rename auditorname auditor_name
						rename bvdidnumber bvd_id_number
					}
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Bankers */
					preserve

						/* Keep bankers */
						keep accnr banker*
						
						/* Duplicates drop */
						duplicates drop accnr banker*, force
						
						/* Save Intermediate Data */
						cd "`output'/Bankers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Bankers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Bankers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep bankers */
						keep accnr dm*
						
						/* Duplicates drop */
						duplicates drop accnr dm*, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop bankers & managers */
						drop banker* dm* 
						
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2011) */
		}		
		
		/* Vintage Condition: New Vintage (2012) */
		if `year' >= 2012 {
			
			/* File Loop */
			foreach file of local files {
			
				/* Category */
				if regexm("`file'", "[0-9]+\.") == 1 {
					local category = "main"
				}
				
				if regexm("`file'", "[a-zA-Z]+\.") == 1 {
				
					qui di regexm("`file'", "[a-zA-Z]+\.")
					if substr(regexs(0), 1, 2) == "nr" {
						local category = substr(regexs(0), 3, length(regexs(0))-3)
					}

					if substr(regexs(0), 1, 4) == "nrof" {
						local category = substr(regexs(0), 5, length(regexs(0))-5)
					}
					
					if substr(regexs(0), 1, 2) != "nr" {
						local category = substr(regexs(0), 1, length(regexs(0))-1)
					}
				}

				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(tab) varnames(1) clear stringcols(_all)
			
				/* Check Import */
				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(".") varnames(1) clear stringcols(_all)
				}

				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(";") varnames(1) clear stringcols(_all)
				}

				/* Compress */
				compress
				
				/* Rename */
				capture rename ïrecord_id record_id
				
				/* Company data */
				if 	///
					regexm("`category'", "auditor") == 0 & ///
					regexm("`category'", "code") == 0 & ///
					regexm("`category'", "additional") == 0 & ///
					regexm("`category'", "banker") == 0 & ///
					regexm("`category'", "contacts") == 0 & ///
					regexm("`category'", "shareholder") == 0 & ///
					regexm("`category'", "subsidiar") == 0 & ///
					regexm("`category'", "acronym") == 0 & ///
					regexm("`category'", "nace") == 0 & ///
					regexm("`category'", "naics") == 0 & ///
					regexm("`category'", "national") == 0 & ///
					regexm("`category'", "email") == 0 & ///
					regexm("`category'", "faxes") == 0 & ///
					regexm("`category'", "identifiers") == 0 & ///
					regexm("`category'", "years") == 0 & ///
					regexm("`category'", "phones") == 0 & ///
					regexm("`category'", "website") == 0 & ///
					regexm("`category'", "previous") == 0 & ///
					regexm("`category'", "sic") == 0 {
				
					/* Save Intermediate Data */
					cd "`output'/`section'"
					if "`category'" != "main" {
						save intermediate_`year'_`category', replace
						local categories: list categories | category 
					}
					
					/* Merge, Append, & Save */
					if "`category'" == "main" { 
						/* Merge */
						foreach c of local categories {
							merge m:m record_id using intermediate_`year'_`c'
							drop _merge
							rm intermediate_`year'_`c'.dta
						}
					
						/* Append Data*/
						capture append using "`country'_`section'_`year'", force
						
						/* Save */
						save "`country'_`section'_`year'", replace
						
						/* Reset local */
						local categories
					}
				}

				/* Auditor data */
				if regexm("`category'", "auditor") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Auditors"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Auditors_`year'", force
					save "`country'_Auditors_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}				
				
				
				/* Banker data */
				if regexm("`category'", "banker") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Bankers"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Bankers_`year'", force
					save "`country'_Bankers_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Manager data */
				if regexm("`category'", "contacts") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Managers"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Managers_`year'", force
					save "`country'_Managers_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Ownership data */
				if regexm("`category'", "shareholder") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Ownership"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Ownership_`year'_`category'", force
					save "`country'_Ownership_`year'_`category'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Subsidiary data */
				if regexm("`category'", "subsidiar") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Subsidiaries"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Subsidiaries_`year'_`category'", force
					save "`country'_Subsidiaries_`year'_`category'", replace
				
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				}
	
				/* Subsidiary data */
				if ///
					regexm("`category'", "acronym") == 1 | ///
					regexm("`category'", "nace") == 1 | ///
					regexm("`category'", "naics") == 1 | ///
					regexm("`category'", "national") == 1 | ///
					regexm("`category'", "email") == 1 | ///
					regexm("`category'", "faxes") == 1 | ///
					regexm("`category'", "identifiers") == 1 | ///
					regexm("`category'", "years") == 1 | ///
					regexm("`category'", "phones") == 1 | ///
					regexm("`category'", "website") == 1 | ///
					regexm("`category'", "previous") == 1 | ///
					regexm("`category'", "code") == 1 | ///
					regexm("`category'", "additional") == 1 | ///
					regexm("`category'", "sic") == 1 {

					/* Save Intermediate Data */
					cd "`output'/Other"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Other_`year'_`category'", force
					save "`country'_Other_`year'_`category'", replace
				
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				}
				
			/* Close: File Loop */
			}
	
		/* Deleting Intermediate Data */
		cd "`output'/`section'"
		cap rm intermediate_`year'.dta
					
		/* Close: New Vintage */
		}
		
	/* Close: Folder Loop */
	}

/* Close: Company Section */
}	

********************************************************************************
**** (3) Importing: Ownership and Subsidiaries Sections						****
********************************************************************************

/* Section: Ownership */
if "`section'" == "Ownership" | "`section'" == "Subsidiaries" {

	/* Folder List */
	local folders: dir "`directory'/`year'/`section'" dirs "*"
	
	/* Folder Loop */
	foreach country of local folders {

		/* File List */
		local files: dir "`directory'/`year'/`section'/`country'" files "*"

		/* Vintage Condition: New Vintage (2012) */
		if `year' >= 2012 {
			
			/* File Loop */
			foreach file of local files {
		
				/* Category */
				if regexm("`file'", "[0-9]+\.") == 1 {
					local category = "main"
				}
				
				if regexm("`file'", "[a-zA-Z]+\.") == 1 {
				
					qui di regexm("`file'", "[a-zA-Z]+\.")
					if substr(regexs(0), 1, 2) == "nr" {
						local category = substr(regexs(0), 3, length(regexs(0))-3)
					}

					if substr(regexs(0), 1, 4) == "nrof" {
						local category = substr(regexs(0), 5, length(regexs(0))-5)
					}
					
					if substr(regexs(0), 1, 2) != "nr" {
						local category = substr(regexs(0), 1, length(regexs(0))-1)
					}
				}

				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(tab) varnames(1) clear stringcols(_all)
			
				/* Check Import */
				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(".") varnames(1) clear stringcols(_all)
				}

				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(";") varnames(1) clear stringcols(_all)
				}

				/* Compress */
				compress
				
				/* Rename */
				capture rename ïrecord_id record_id

				/* Main ownership data */
				if regexm("`category'", "main") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/`section'"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_`section'_`year'", force
					save "`country'_`section'_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				
				}				
				
				/* Ownership data */
				if regexm("`category'", "shareholder") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Ownership"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Ownership_`year'_`category'", force
					save "`country'_Ownership_`year'_`category'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Subsidiary data */
				if regexm("`category'", "subsidiar") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Subsidiaries"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Subsidiaries_`year'_`category'", force
					save "`country'_Subsidiaries_`year'_`category'", replace
				
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				}
				
			/* Close: File Loop */
			}
					
		/* Close: New Vintage */
		}
		
	/* Close: Folder Loop */
	}

/* Close: Ownership Section */
}	
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		12/07/2020													****
**** Program:	Analyses													****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Data.dta")		

********************************************************************************
**** (1) Sample selection and variable truncation							****
********************************************************************************

/* Data */
use Data, clear

/* Duplicates drop */
duplicates drop ci year, force

/* Sample period */
keep if year >= 2001 & year <= 2015

/* Panel */
xtset ci year

/* Variable list

Manuscript labels (Table 2):
	mc_scope		= Standardized Reporting Scope
	mc_audit		= Standardized Auditing Scope
	scope			= Actual Reporting Scope
	audit_scope		= Actual Auditing Scope
	m_audit			= Audit (Average)
	m_listed		= Publicly Listed (Average)
	w_listed		= Public Listed (Aggregate)
	m_shareholder	= Shareholders (Average)
	w_shareholder	= Shareholders (Aggregate)
	m_indep			= Independence (Average)
	w_indep			= Independence (Aggregate)
	m_entry			= Entry (Average)
	w_entry			= Entry (Aggregate)
	m_exit			= Exit (Average)
	w_exit			= Exit (Aggregate)
	hhi				= HHI
	cv_markup		= Dispersion (Gross Margin)
	sr_markup		= Distance (Gross Margin)
	cv_margin		= Dispersion (EBITDA/Sales)
	sr_margin		= Distance (EBITDA/Sales)
	cv_tfp_e		= Dispersion (TFP (Employees))
	sr_tfp_e		= Distance (TFP (Employees))
	p20_tfp_e		= Lower Tail (TFP (Employees))
	p80_tfp_e		= Upper Tail (TFP (Employees))
	cv_tfp_w		= Dispersion (TFP (Wage))
	sr_tfp_w		= Distance (TFP (Wage))
	p20_tfp_w		= Lower Tail (TFP (Wage))
	p80_tfp_w		= Upper Tail (TFP (Wage))
	cov_lp_e		= Covariance Y/L and Y (Employees)
	cov_tfp_e		= Covariance TFP and Y (Employees)
	cov_lp_w		= Covariance Y/L and Y (Wage)
	cov_tfp_w		= Covariance TFP and Y (Wage)
	m_lp_e			= Y/L (Employees) (Average)
	m_lp_w			= Y/L (Wage) (Average)
	m_tfp_e			= TFP (Employees) (Average)
	m_tfp_w			= TFP (Wage) (Average)
	w_lp_e			= Y/L (Employees) (Aggregate)
	w_lp_w			= Y/L (Wage) (Aggregate)
	w_tfp_e			= TFP (Employees) (Aggregate)
	w_tfp_w			= TFP (Wage) (Aggregate)
	dm_lp_e			= delta Y/L (Employees) (Average)
	dm_lp_w			= delta Y/L (Wage) (Average)
	dm_tfp_e		= delta TFP (Employees) (Average)
	dm_tfp_w		= delta TFP (Wage) (Average)
	dw_lp_e			= delta Y/L (Employees) (Aggregate)
	dw_lp_w			= delta Y/L (Wage) (Aggregate)
	dw_tfp_e		= delta TFP (Employees) (Aggregate)
	dw_tfp_w		= delta TFP (Wage) (Aggregate)

Notes:
	mc_ 		= prefix denoting simulated/standardized scopes (i.e., Monte Carlo simulation based scopes)
	m_ 			= prefix for equally-weighted mean
	w_			= prefix for sales-share-weighted total
	sr_			= prefix for standardized distance or range ((p80-p20)/mean)
	cv_			= prefix for coefficient of variation (standard deviation/mean)
	p20_		= prefix for 20th percentile
	p80_		= prefix for 80th percentile
	dm_			= prefix for mean growth (delta of mean)
	dw_ 		= prefix for aggregate growth (delta of sales-weighted total)
	_e			= suffix for employees-based measure (e.g., TFP calculated with number of employees as input)
	_w			= suffix for wage-based measure (e.g., TFP calculated with wage expense as input)
*/

	/* All outcomes */
	local All = "scope audit_scope m_audit m_listed w_listed m_shareholder w_shareholder m_indep w_indep m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w m_lp_e m_lp_w m_tfp_e m_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

	/* All second stage outcomes (excludes: scope and audit_scope) */
	local All_2SLS = "m_audit m_listed w_listed m_shareholder w_shareholder m_indep w_indep m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w m_lp_e m_lp_w m_tfp_e m_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

/* Panel: country-industry year */
xtset ci year

********************************************************************************
**** Table 1: Descriptive Statistics										****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_1.smcl, replace smcl name(Table_1) 

/* Descriptives */

	/* Financial reporting */
	local descriptives = "mc_scope mc_audit scope audit_scope m_audit"
	tabstat `descriptives' if mc_scope != . & mc_audit != . ///
		, col(stats) stat(N mean sd p10 p25 p50 p75 p90)
	
	/* Type of resource allocation */
	local descriptives = "m_listed w_listed m_shareholder w_shareholder m_indep w_indep m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin"
	tabstat `descriptives' if mc_scope != . & mc_audit != . ///
		, col(stats) stat(N mean sd p10 p25 p50 p75 p90)
		
	/* Efficiency of resource allocation */
	local descriptives = "cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w m_lp_e m_lp_w m_tfp_e m_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"
	tabstat `descriptives' if mc_scope != . & mc_audit != . ///
		, col(stats) stat(N mean sd p10 p25 p50 p75 p90)

/* Log file: close */
log close Table_1

********************************************************************************
**** Table 2: Standardized Scope and Actual Scope							****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_2.smcl, replace smcl name(Table_2) 		
	
/* Regression inputs */
local DepVar = "scope audit_scope m_audit"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_2	
	
********************************************************************************
**** Table 3: Standardized Scope and Ownership Concentration				****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_3.smcl, replace smcl name(Table_3) 		
		
/* Regression inputs */
local DepVar = "m_listed w_listed m_shareholder w_shareholder m_indep w_indep"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_3		
	
********************************************************************************
**** Table 4: Standardized Scope and Product-Market Competition				****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_4.smcl, replace smcl name(Table_4) 		
		
/* Regression inputs */
local DepVar = "m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_4	
	
********************************************************************************
**** Table 5: Standardized Scope, Revenue-Productivity Dispersion, and		****
****          Size-Productivity Covariance,  and Product-Market Competition	****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_5.smcl, replace smcl name(Table_5) 		
		
/* Regression inputs */
local DepVar = "cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cov_lp_e cov_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_w cov_tfp_w"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_5		
	
********************************************************************************
**** Table 6: Standardized Scope and Revenue Productivity					****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_6.smcl, replace smcl name(Table_6) 		
		
/* Regression inputs */
local DepVar = "m_lp_e m_lp_w m_tfp_e m_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_6	
		
********************************************************************************
**** Table 7: Correlated Factors											****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_7.smcl, replace smcl name(Table_7) 

/* Regression inputs */
local DepVar = "scope"
local CIY = "firms m_sales m_empl m_fias hhi"

/* Loop */
foreach y of varlist `DepVar' {

	/* Estimation */
	qui reghdfe mc_`y' `CIY' if `y'!=., a(cy iy) cluster(ci_cluster cy)
		est store M1
			
	qui reghdfe `y' `CIY' if mc_`y'!=., a(cy iy) cluster(ci_cluster cy)
		est store M2

				
	/* Output */
	estout M1 M2, cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
		legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE") ///
		mlabels(, depvars) varwidth(40) modelwidth(20) unstack ///
		stats(N N_clust1 N_clust2 r2_within, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "R-Squared (Within)"))			
			
}

/* Log file: close */
log close Table_7	
	
********************************************************************************
**** Table A2: Standardized Reporting and Auditing Scopes by Country + Year	****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A2.smcl, replace smcl name(Table_A2) 	
	
	
/* Scope by year */
forvalue y = 2001(1)2015 {
	di "Year: " `y'
	tabstat mc_scope mc_audit if year == `y', by(country) format(%9.2f)
}

/* Log file: close */
log close Table_A2

********************************************************************************
**** Table A5: Second Stage Estimates (IV)							 		****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A5.smcl, replace smcl name(Table_A5) 

/* Regression inputs */
local DepVar = "`All_2SLS'"

/* Regression: country-year + industry-year fixed effects (scope + audit) [IV] */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui ivreghdfe `y' (scope audit_scope = mc_scope mc_audit), a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(scope audit_scope) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [IV]") ///
				varlabels(scope "Instrumented Reporting Scope" audit_scope "Instrumented Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}

/* Log file: close */
log close Table_A5

********************************************************************************
**** Table A6: Firm Density and Resource Allocation					 		****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A6.smcl, replace smcl name(Table_A6) 

/* Regression inputs */
local DepVar = "`All'"

/* Regression: country-year + industry-year fixed effects (firms + firms^2) */
foreach y of varlist `DepVar' {
			
	/* Preserve */
	preserve
			
		/* Firms (squared) */
		gen firms_2 = firms^2
		label var firms_2 "Number of Firms (squared)"
			
		/* Capture */
		capture noisily {
				
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=. & firms!=., a(cy iy) residual(r_`y')
			qui reghdfe firms if `y'!=. & mc_audit!=. & firms!=., a(cy iy) residual(r_firms)
			qui reghdfe firms_2 if `y'!=. & mc_scope!=. & firms!=., a(cy iy) residual(r_firms_2)
					
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
					
			qui sum r_firms, d
			qui replace firms = . if r_firms < r(p1) | r_firms > r(p99)		
		
			qui sum r_firms_2, d
			qui replace firms_2 = . if r_firms_2 < r(p1) | r_firms_2 > r(p99)
				
			/* Estimation */
			qui reghdfe `y' firms firms_2, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(firms firms_2) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Aggregate Growth Validation]") ///
				mlabels(, depvar) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
					
		}
			
	/* Restore */
	restore
}

/* Log file: close */
log close Table_A6

********************************************************************************
**** Table A7: Interaction of Reporting and Auditing Mandates				****
********************************************************************************

/* Interactions */
qui gen mc_scope_unc = 0 if mc_scope != .
qui replace mc_scope_unc = mc_scope if mc_scope > mc_audit
label var mc_scope_unc "Reporting (w/o Auditing)"

qui gen mc_scope_con = 0 if mc_scope != .
qui replace mc_scope_con = mc_scope if mc_scope <= mc_audit
label var mc_scope_con "Reporting (w/ Auditing)"

qui gen mc_audit_unc = 0 if mc_audit != .
qui replace mc_audit_unc = mc_audit if mc_scope < mc_audit
label var mc_audit_unc "Auditing (w/o Reporting)"

qui gen mc_audit_con = 0 if mc_audit != .
qui replace mc_audit_con = mc_audit if mc_scope >= mc_audit
label var mc_audit_con "Auditing (w/ Reporting)"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A7.smcl, replace smcl name(Table_A7) 

/* Regression inputs */
local DepVar = "`All'"
	
/* Regression: country-year + industry-year fixed effects (scope + audit) [jointly] */
foreach y of varlist `DepVar' {
					
	/* Preserve */
	preserve

		/* Capture */
		capture noisily {
				
			/* Truncation */
			qui reghdfe `y' if mc_scope_unc!=. & mc_scope_con!=. & mc_audit_unc!=. & mc_audit_con!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope_unc if `y'!=. & mc_scope_con!=. & mc_audit_unc!=. & mc_audit_con!=., a(cy iy) residual(r_mc_scope_unc)
			qui reghdfe mc_scope_con if `y'!=. & mc_scope_unc!=. & mc_audit_unc!=. & mc_audit_con!=., a(cy iy) residual(r_mc_scope_con)
			qui reghdfe mc_audit_unc if `y'!=. & mc_scope_unc!=. & mc_scope_con!=. & mc_audit_con!=., a(cy iy) residual(r_mc_audit_unc)
			qui reghdfe mc_audit_con if `y'!=. & mc_scope_unc!=. & mc_scope_con!=. & mc_audit_unc!=., a(cy iy) residual(r_mc_audit_con)
			
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
					
			qui sum r_mc_scope_unc, d
			qui replace mc_scope_unc = . if r_mc_scope_unc < r(p1) | r_mc_scope_unc > r(p99)		

			qui sum r_mc_scope_con, d
			qui replace mc_scope_con = . if r_mc_scope_con < r(p1) | r_mc_scope_con > r(p99)
					
			qui sum r_mc_audit_unc, d
			qui replace mc_audit_unc = . if r_mc_audit_unc < r(p1) | r_mc_audit_unc > r(p99)		

			qui sum r_mc_audit_con, d
			qui replace mc_audit_con = . if r_mc_audit_con < r(p1) | r_mc_audit_con > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope_unc mc_scope_con mc_audit_unc mc_audit_con, a(cy iy) cluster(ci_cluster cy)
						
			/* Output */
			estout, keep(mc_scope_unc mc_scope_con mc_audit_unc mc_audit_con) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
	
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_A7

********************************************************************************
**** Supplemental information: Instrument F-stat, number of firms, and		****
****						   conditional standard deviations		 		****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Supplement.smcl, replace smcl name(Supplement) 

/* First stage F-staticts (instrument) */

	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe firms if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_firms)
			qui reghdfe mc_scope if firms!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if firms!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_firms, d
			qui replace firms = . if r_firms < r(p1) | r_firms > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			ivreghdfe firms (scope audit_scope = mc_scope mc_audit), a(cy iy) cluster(ci_cluster cy) ffirst
						
		}
		
	/* Restore */
	restore

/* Total number of firm-years */

	/* Preserve */
	preserve
	
		/* Exponentiate */
		qui gen number = exp(firms)
		
		/* Total */
		qui egen double total = total(number)
		
		/* Sum */
		qui sum total
		local sum = r(mean)
		
		/* Display */
		di "Total number of firm-year observations: " `sum'
		
	/* Restore */
	restore
	

/* Conditional standard deviation (covariance and growth) */
local DepVar = "cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace r_`y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Sum */
			sum r_`y' if mc_scope != . & mc_audit != . & ci_cluster != . & cy != . & iy != .
						
		}
		
	/* Restore */
	restore
}	

/* Log file: close */	
log close Supplement
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Panel of Amadeus ID and other static items 					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // insert directory for raw data

**** Project ****
project, original("`directory'\Amadeus\Amadeus_ID.txt")
project, original("`directory'\Amadeus\correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format.dta")

********************************************************************************
**** (1) Creating BvD ID and industry correspondence tables					****
********************************************************************************

/* BvD ID changes */

	/* Correspondence table */
	cd "`directory'\Amadeus"
	import delimited using Amadeus_ID.txt, delimiter(tab) varnames(1) clear

	/* Rename */
	rename oldid bvd_id
	
	/* Save */
	save Amadeus_ID, replace
		
	/* Project */
	project, creates("`directory'\Amadeus\Amadeus_ID.dta")

/* Industry (NACE) correspondence (Sebnem et al. (2015)) */

	/* Correspondence table */
	cd "`directory'\Amadeus"
	use correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format, clear

	/* Keep relevant variables */
	keep nacerev11 nacerev2
	
	/* Destring code */
	destring nacerev11 nacerev2, ignore(".") replace force
	
	/* Keep if non-missing */
	keep if nacerev11 != . & nacerev2 != .
	
	/* Rename */
	rename nacerev11 nace_ind
	rename nacerev2 nace2_ind_corr
	
	/* Save */
	save NACE_correspondence, replace
	
	/* Project */
	project, creates("`directory'\Amadeus\NACE_correspondence.dta")
	
********************************************************************************
**** (1) Constructing panel data by country									****
********************************************************************************

/* Sample countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop (loading data, keeping relevant variables, saving in local folder) */
foreach country of local countries {

	/* Delete existing data */
	cd "`directory'\Amadeus"
	cap rm Company_`country'.dta	
		
	forvalues year = 2005(1)2016 {	
		
		/* Delete */
		cap rm Auditors.dta
		cap rm Owners.dta
		
		/* Capture */
		capture noisily {
		
			/* Project */
			project, original("`data'\Company/`country'_Company_`year'.dta")

			/* Data */
			cd "`data'\Company"
			use `country'_Company_`year', clear
			
			/* Vintage */
			gen vintage = `year'
			label var vintage "Vintage (BvD Disc)"			
			
			/* Renaming, keeping relevant variables, merging missing variables */
			if `year' == 2005 {
			
				/* Rename */
				rename idnr bvd_id
				rename nacpri nace_ind
				
				/* Keep (only keep empl_c; no unit issues) */
				keep bvd_id company lstatus type quoted repbas typacc dateinc empl_c onbr indepind ad_name nace_ind consol vintage
				
				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol ad_name, replace force
				destring nace_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				cap rm Company_`country'.dta
				save Company_`country', replace

			}
			if `year' == 2006 {
			
				/* Rename */
				rename idnr bvd_id
				rename nacpri nace_ind
				
				/* Keep */
				keep bvd_id company lstatus type quoted repbas typacc dateinc empl_c onbr indepind ad_name nace_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol ad_name, replace force
				destring nace_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}			
			if `year' == 2007 {
			
				/* Rename */
				rename idnr bvd_id
				rename accpra* accpra
				rename nacpri nace_ind
				
				/* Keep */
				keep bvd_id company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol ad_name, replace force
				destring nace_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2008 {
			
				/* Rename */
				rename bvd_id_number bvd_id
				rename company_name company
				rename auditor_name ad_name
				rename accpra* accpra
				rename nac2pri nace2_ind

				/* Keep (w/o dateinc) */
				keep bvd_id company lstatus type quoted repbas accpra typacc empl_c onbr indepind ad_name nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas accpra typacc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2009 {
			
				/* Rename */
				rename bvd_id_number bvd_id
				rename legalstatus lstatus
				rename legalform type
				rename publiclyquoted quoted
				rename reportingbasis repbas
				rename typeofaccount* typacc
				rename accountingpractice* accpra
				rename dateofincorporation dateinc
				rename bvdepindependenceindicator indepind
				rename auditor_name ad_name
				rename nacerev2primarycode nace2_ind
				rename consol* consol
				
				/* Keep */
				keep bvd_id company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas accpra typacc dateinc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2010 {
				
				/* Rename */
				rename bvd_id_number bvd_id
				rename company_name company
				rename legalstatus lstatus
				rename legalform type
				rename publiclyquoted quoted
				rename dateofincorporation dateinc
				rename reportingbasis repbas
				rename typeofaccountavailable typacc
				rename accountingpractice* accpra
				rename bvdindependenceindicator indepind
				rename auditor_name ad_name
				rename nacerev2primarycode nace2_ind
				rename conscode consol
				
				/* Keep */
				keep bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace2_ind consol vintage
				
				/* Format */
				tostring bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Add further variables from separate files */
				
					/* Number of banks */
					capture {
					
						/* Data */
						cd "`data'\Bankers"
						use `country'_Bankers_`year', clear
						
						/* Keep */
						keep accnr b*
						
						/* Convert to string */
						cap tostring b*, replace force
						
						/* Drop missing */
						drop if b == ""
						
						/* Count banks */
						egen banks = count(accnr), by(accnr)
						
						/* Keep */
						keep accnr banks
						
						/* Duplicates */
						sort accnr banks
						duplicates drop accnr, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Bankers, replace
					}
					
					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					capture {	
						merge m:1 accnr using Bankers
						drop if _merge == 2
						drop _merge
					}
					
					/* Drop */
					drop accnr
					
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace	
				
			}
			if `year' == 2011 {
			
				/* Rename */
				rename bvd_id_number bvd_id
				rename company_name company
				cap rename legalstatus lstatus
				cap rename legal_status lstatus
				cap rename nationallegalform type
				cap rename national_legal_form type
				cap rename dateofincorporation dateinc
				cap rename date_of_incorporation dateinc
				cap rename publiclyquoted quoted
				cap rename publicly_quoted quoted
				cap rename reportingbasis repbas
				cap rename reporting_basis repbas
				cap rename typesofaccountsavailable typacc
				cap rename type_s__of_accounts* typacc
				rename accounting* accpra
				cap rename bvdindependenceindicator indepind
				cap rename bvd_indep* indepind
				rename auditor_name ad_name
				cap rename nacerev2primarycode nace2_ind
				cap rename nace_rev__2_primary_code nace2_ind
				cap rename cons* consol

				/* Keep */
				keep bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace2_ind consol vintage

				/* Format */
				tostring bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge

				/* Drop */
				drop accnr
					
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
			
			}
			if `year' == 2012 {

				/* Rename */
				rename idnr bvd_id
				rename name company
				rename quoted_str quoted
				rename nac2pri nace2_ind
				rename v30 indepind
				rename v31 onbr
				
				/* Keep */
				keep bvd_id record_id company lstatus type quoted repbas typacc dateinc indepind onbr nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring onbr nace2_ind, replace force ignore(",")

				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Add further variables from separate files */
				
					/* Auditor name */
						
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep record_id ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort record_id ad_name
						duplicates drop record_id, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace

					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					merge m:1 record_id using Auditors
					drop if _merge == 2
					drop _merge
					
					/* Drop */
					drop record_id
					
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace				
			}
			if `year' == 2013 {

				/* Rename */
				rename idnr bvd_id
				rename name company
				rename quoted_str quoted
				rename header_empl empl_c
				rename nac2pri nace2_ind
				rename v73 indepind
				rename v74 onbr
				
				/* Keep */
				keep record_id bvd_id company lstatus type quoted repbas typacc dateinc indepind onbr empl_c nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring onbr nace2_ind empl_c, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Add further variables from separate files */
				
					/* Auditor name */
						
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep record_id ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort record_id ad_name
						duplicates drop record_id, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace

					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					merge m:1 record_id using Auditors
					drop if _merge == 2
					drop _merge
					
					/* Drop */
					drop record_id
				
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2014 | `year' == 2015 {

				/* Rename */
				rename idnr bvd_id
				rename name company
				rename quoted_str quoted
				rename header_empl empl_c
				rename historic_status_str_lastyear lstatus
				rename v33 indepind
				rename v35 onbr
				rename nac2pri nace2_ind
				
				/* Keep */
				keep bvd_id record_id company lstatus type quoted repbas typacc dateinc empl_c indepind onbr nace2_ind consol vintage 

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring onbr nace2_ind empl_c, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
	
				/* Add further variables from separate files */
				
					/* Auditor name */
						
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep record_id ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort record_id ad_name
						duplicates drop record_id, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace
					
					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					merge m:1 record_id using Auditors
					drop if _merge == 2
					drop _merge

					/* Drop */
					drop record_id					
					
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace		
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
			}			
			if `year' == 2016 {
			
				/* Rename */
				rename name company
				rename repbas_header repbas
				drop dateinc
				rename dateinc_char dateinc
				rename nace_prim_code nace2_ind
				
				/* Keep */
				keep idnr company lstatus type quoted repbas typacc dateinc indepind nace2_ind consol vintage

				/* Format */
				tostring company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring nace2_ind, replace force ignore(",")
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace

			/* Add further variables from separate files */
				
					/* Auditor name */
					capture {
					
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep idnr ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort idnr ad_name
						duplicates drop idnr, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace
					}
					
					/* Ownership */
					
						/* Data */
						cd "`data'\Ownership"
						use `country'_Ownership_`year', clear
						
						/* Keep */
						keep idnr sh_name
						tostring sh_name, replace force
						drop if sh_name == ""
						
						/* Duplicates */
						sort idnr sh_name
						duplicates drop idnr sh_name, force
						
						/* Number of recorded shareholders */
						egen onbr = count(sh_name), by(idnr)
						
						/* Duplicates */
						duplicates drop idnr, force
						
						/* Drop */
						drop sh_name
						
						/* Save */
						cd "`directory'\Amadeus"
						save Owners, replace
					
					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					capture {
						merge m:1 idnr using Auditors
						drop if _merge == 2
						drop _merge
					}
					
					merge m:1 idnr using Owners
					drop if _merge == 2
					drop _merge	
					
					/* Rename */
					rename idnr bvd_id					
						
					/* Merge: prior ID */
					cd "`directory'\Amadeus"				
					merge m:1 bvd_id using Amadeus_ID
					drop if _merge == 2
					drop _merge
				
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace		
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
			}
						
		/* End: Capture */
		}
		
	/* End: Vintage/year loop */
	}
				
	/* Country */
	gen country = "`country'"
	replace country = "Czech Republic" if country == "Czech_Republic"
	replace country = "United Kingdom" if country == "United_Kingdom"
	label var country "Country"
		
	/* BvD ID definition */
	
		/* Latest ID */
		
			/* Update */
			rename bvd_id bvd_id_h
			gen bvd_id = bvd_id_h
			replace bvd_id = newid if newid != ""
			drop newid

			/* Mode */
			egen mode = mode(bvd_id), by(bvd_id_h)
			replace bvd_id = mode if bvd_id == ""
			drop mode
			
			/* Rename */
			rename bvd_id bvd_id_new
			rename bvd_id_h bvd_id	
			
	/* Sample restriction & ID */
	drop if bvd_id == "" & bvd_id_new == ""
	egen double id = group(bvd_id_new)

	/* Duplicates (tag) */
	duplicates tag id vintage, gen(dup)

	/* Drop: missing location or industry if duplicate */
	drop if dup > 0 & (nace_ind == . & nace2_ind == .)
	
	/* Consolidation: avoid duplication (drop duplicates associated with C2 (or C for 2016)) */
	gen con = (consol == "C2" | consol == "C")
	egen c2 = max(con), by(id)
	drop if dup != 0 & (consol != "C2" | consol != "C") & c2 == 1
	sort id vintage dup
	duplicates drop id vintage if dup != 0, force
	drop dup con c2

	/* Duplicates (drop) */
	sort id vintage
	duplicates drop id vintage, force
	
	/* Panel definition */
	xtset id vintage
	
	/* Industry definition */
	
		/* Merge: Industry correspondence */
		merge m:1 nace_ind using NACE_correspondence
		drop if _merge ==2
		drop _merge

		/* Generate converged industry */
		gen industry = nace2_ind
		label var industry "Industry (NACE rev 2)"
		
		/* Backfilling (using panel information) */
		xtset id vintage
		forvalues y = 1(1)11 {
			replace industry = f.industry if industry == . & f.industry != . & vintage == 2016 - `y'
		}

		/* Filling in missing values (using correspondence table) */
		replace industry = nace2_ind_corr if industry == .
		drop nace*

		/* Mode: Filling in missing values (using mode of industry code per firm) */
		egen industry_mode = mode(industry), by(id)
		replace industry = industry_mode if industry == .
		drop industry_mode
		
		/* Drop missing industry */
		drop if industry == .
		
	/* Clean auditor name */
	replace ad_name = "" if ad_name == "."
	
	/* Replace missing incorporation date (esp. 2008) */
	egen mode = mode(dateinc), by(id)
	replace dateinc = mode
	drop mode
	
	/* Drop */
	drop id
	
	/* Save */
	save Company_`country', replace	

	/* Project	*/
	project, creates("`directory'\Amadeus\Company_`country'.dta")

/* End: Country loop */
}

/* Delete intermediate data */
cd "`directory'\Amadeus"
cap rm Intermediate.dta
cap rm Auditors.dta
cap rm Owners.dta
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation 	****
**** Author:	M. Breuer													****
**** Date:		02/13/2017													****
**** Program:	Data for analyses											****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Outcomes.dta")	
project, uses("`directory'\Data\Scope.dta")	

********************************************************************************
**** (1) Combining data														****
********************************************************************************

/* Data */
use Outcomes, clear

/* Merge: Scope (Treatment) */
merge 1:1 country industry year using Scope
keep if _merge == 3
drop _merge

/* Merge: Regulation */
merge m:1 country year using Regulation
drop if _merge == 2
drop _merge

********************************************************************************
**** (2) Remaining variables												****
********************************************************************************

/* Other regulations */

	/* EU */
	gen EU = (year >= eu_date)
	label var EU "EU Member"
	
	/* EURO */
	gen EURO = (year >= euro_date)
	label var EURO "EURO Member"
	
	/* IFRS */
	gen ifrs_year = substr(ifrsdate, -4, 4)
	destring ifrs_year, force replace
	gen IFRS = (year >= ifrs_year)
	label var IFRS "IFRS Directive"
	drop ifrs_year
	
	/* TPD */
	gen TPD = (year >= tpdyear)
	label var TPD "TPD Directive"
	
	/* MAD */
	gen MAD = (year >= madyear)
	label var MAD "MAD Directive"

/* Exemptions */

	/* Preparation */
	egen preparation = rowtotal(bs_preparation_abridged is_preparation_abridged notes_preparation_abridged), missing
	label var preparation "Preparation exemptions (Small)"

	/* Publication */
	egen publication = rowtotal(bs_publication is_publication notes_publication), missing
	replace publication = 3 - publication
	label var publication "Publication exemptions (Small)"

	/* Combined exemptions */
	gen exemptions = (preparation + publication)/6
	label var exemptions "Exemptions (Small)"

********************************************************************************
**** (3) Country, industry, year indicator									****
********************************************************************************

/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Year */
egen y = group(year)
label var y "Year ID"

/* Country-industry */
egen ci = group(c i)
label var ci "Country-industry ID"

/* Country-year */
egen cy = group(c y)
label var cy "Country-year ID"

/* Industry-year */
egen iy = group(i y)
label var iy "Industry-year ID"

/* Cluster */
gen i_1 = floor(industry/1000)
egen ci_cluster = group(c i_1)
label var ci_cluster "Country-industry cluster (1-Digit)"
drop i_1

********************************************************************************
**** (4) Cleaning and saving												****
********************************************************************************

/* Save */
save Data, replace

/* Project */
project, creates("`directory'\Data\Data.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Installs external (user-written) programs					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

********************************************************************************
**** (1) Install external programs											****
********************************************************************************

**** Estout ****
ssc install estout, replace

**** Coefplot ****
ssc install coefplot, replace

**** Outreg2 ****
ssc install outreg2, replace

**** Reghdfe ****
ssc install reghdfe, replace

**** Ivreghdfe ***
ssc install ivreghdfe, replace // replaces former reghdfe IV command
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/13/2017													****
**** Program:	Graphs														****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Data.dta")		

********************************************************************************
**** (1) Sample selection and variable truncation							****
********************************************************************************

/* Data */
use Data, clear

/* Duplicates drop */
duplicates drop ci year, force

/* Sample period */
keep if year >= 2001 & year <= 2015

/* Panel: country-industry year */
xtset ci year

/* Directory */
cd "`directory'\Output\Figures"

********************************************************************************
**** Figure 2: Distribution & Time Trend of Reporting + Auditing Scopes		****
********************************************************************************

/* Scope variation within year and over time */

	/* Preserve */
	preserve	
	
		/* Graph */
		graph box mc_scope mc_audit ///
			, over(year, label(labsize(*.9) alternate)) nooutsides bar(1, color(black)) bar(2, color(gs10)) ///
			ylabel(0(0.1)1, angle(0) format(%9.2f)) ///
			legend(label(1 "Reporting Scope") label(2 "Audit Scope") rows(2) ring(0) position(2) bmargin(medium)) ///
			ytitle("Scope") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			name(Box, replace)
		
	/* Restore */
	restore
	
/* Average scope trend */

	/* Preserve */
	preserve
	
		/* Country level */
		duplicates drop c y, force
		
		/* Cross-country aggregation */
		foreach var of varlist mc_scope mc_audit {
			egen mean_`var' = mean(`var'), by(year)
		}
		
		/* Year level */
		duplicates drop year, force
		sort year
		
		/* Graph */
		graph twoway ///
			(connected mean_mc_scope year, lwidth(medium) color(black) msymbol(+)) ///
			(connected mean_mc_audit year, lwidth(medium) lpattern(dash) color(black) msymbol(x)) ///
				, ylabel(0(0.1)1, angle(0) format(%9.2f)) xlabel(2001(2)2015) ///
				legend(label(1 "Reporting Scope") label(2 "Audit Scope") rows(2) ring(0) position(2) bmargin(medium)) ///
				xtitle("Year") ///
				ytitle("Scope (Mean)") ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Time, replace)
		
	/* Restore */
	restore

/* Combine graphs */
graph combine Box Time ///
	, altshrink	title("DISTRIBUTION & TIME TREND" "OF REPORTING AND AUDITING SCOPES", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	ysize(5) xsize(10) ///
	saving(Figure_2, replace)
	
********************************************************************************
**** Figure 3: Reporting versus Auditing Scope								****
********************************************************************************

	
/* Raw scopes */

	/* Preserve */
	preserve
		
		/* Consolidate */
		gen auditing = round(mc_audit, 0.05)
		gen reporting = round(mc_scope, 0.05)
		duplicates tag auditing reporting, gen(dup)		
		
		/* Drop duplicates */
		duplicates drop auditing reporting, force
		
		/* Auditing vs. Reporting */
		graph twoway ///
			(scatter reporting auditing [w = dup], msymbol(circle_hollow) mcolor(black)) ///
				, ylabel(, angle(0) format(%9.1f)) xlabel(, format(%9.1f)) ///
				legend(off) ///
				xtitle("Standardized Auditing Scope") ///
				ytitle("Standardized Reporting Scope") ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Auditing_Raw, replace)
			
	/* Restore */
	restore		
	
/* Residualized scopes */

	/* Preserve */
	preserve
	
		/* Residual */
		qui reghdfe mc_scope if scope!=., a(cy iy) residuals(r_reporting)	
	
		qui reghdfe mc_audit if audit_scope!=., a(cy iy) residuals(r_auditing)
		
		/* Consolidate */
		gen auditing = round(r_auditing, 0.05)
		gen reporting = round(r_reporting, 0.05)
		duplicates tag auditing reporting, gen(dup)		
		
		/* Drop duplicates */
		duplicates drop auditing reporting, force
		
		/* Auditing vs. Reporting */
		graph twoway ///
			(scatter reporting auditing [w = dup], msymbol(circle_hollow) mcolor(black)) ///
				, ylabel(, angle(0) format(%9.1f)) xlabel(, format(%9.1f)) ///
				legend(off) ///
				xtitle("Res. Standardized Auditing Scope") ///
				ytitle("Res. Standardized Reporting Scope") ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Auditing_Res, replace)
			
	/* Restore */
	restore	
	
/* Combine graphs */
graph combine Auditing_Raw Auditing_Res ///
	, altshrink	title("REPORTING VERSUS AUDITING SCOPE", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	ysize(5) xsize(10) ///
	saving(Figure_3, replace)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		12/09/2020													****
**** Program:	Identifiers for publication [JAR Data & Code policy]		****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

********************************************************************************
**** (1) Sample firms														****
********************************************************************************

/* Delete existing outcomes data */
cd "`directory'\Data"
cap rm Identifiers.dta

/* Countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop */
foreach country of local countries {

	/* Project */
	project, uses("`directory'\Amadeus\Data_`country'.dta")

	/* Data */
	cd "`directory'\Amadeus"
	use Data_`country', clear

	/* Sample period (after EUR) */
	keep if year >= 1999 & year <= 2015	
	
	/* Non-missing industry */
	drop if industry == .

	/* BvD ID */
	label var bvd_id "BvD ID (original)"

	/* Panel */
	duplicates drop bvd_id, force
	
	/* Append */
	cd "`directory'\Data"
	cap append using Identifiers

	/* Save */
	save Identifiers, replace
			
/* End: Country loop */
}

/* Project	*/
project, creates("`directory'\Data\Identifiers.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/08/2017													****
**** Program:	Outcomes													****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // specify path of (raw) STATA files

/* Project */
project, original("`directory'\Data\WB_nominal_exchange_rate.txt")		
project, original("`directory'\Data\WB_GDP_deflator.txt")		

********************************************************************************
**** (1) Currency and inflation adjustments (World Bank)					****
********************************************************************************

/* Note on adjustment logic:
- Refer to Sebnem et al. (2015, p.32)

Step-by-step:
- convert account currency to official currency of the country (as used by GDP deflator; check for currency breaks for late EUR adopters: e.g., Slovenia)
- deflate the series by the national GDP deflator with 2015 base from the World Bank
- divide by exchange rate of official currency to U.S. dollar in 2015
*/

/* World Bank nominal exchange data */

	/* Data */
	import delimited using WB_nominal_exchange_rate.txt, delimiter(tab) varnames(1) clear
	
	/* Rename */
	rename countryname country
	label var country "Country"
	rename time year
	label var year "Year"
	rename value exch
	label var exch "Nominal exchange rate (local per USD)"
	
	/* Keep */
	keep country year exch
	
	/* Country name */
	replace country = "Slovakia" if country == "Slovak Republic"
	
	/* Keep non-missing */
	drop if year == . & exch == . & country == ""
	
	/* Currency codes */
	gen currency = "EUR" if country == "Euro area" & exch != .
	replace currency = "ATS" if country == "Austria" & exch != .
	replace currency = "BEF" if country == "Belgium" & exch != .
	replace currency = "BGN" if country == "Bulgaria" & exch != .
	replace currency = "CZK" if country == "Czech Republic" & exch != .
	replace currency = "DKK" if country == "Denmark" & exch != .
	replace currency = "EEK" if country == "Estonia" & exch != .
	replace currency = "FIM" if country == "Finland" & exch != .
	replace currency = "FRF" if country == "France" & exch != .
	replace currency = "DEM" if country == "Germany" & exch != .
	replace currency = "GRD" if country == "Greece" & exch != .
	replace currency = "IEP" if country == "Ireland" & exch != .
	replace currency = "ITL" if country == "Italy" & exch != .
	replace currency = "LTL" if country == "Lithuania" & exch != .
	replace currency = "LUF" if country == "Luxembourg" & exch != .
	replace currency = "ANG" if country == "Netherlands" & exch != .
	replace currency = "PTE" if country == "Portugal" & exch != .
	replace currency = "SKK" if country == "Slovakia" & exch != .
	replace currency = "SIT" if country == "Slovenia" & exch != .
	replace currency = "GBP" if country == "United Kingdom" & exch != .
	replace currency = "HRK" if country == "Croatia" & exch != .
	replace currency = "HUF" if country == "Hungary" & exch != .
	replace currency = "NOK" if country == "Norway" & exch != .
	replace currency = "PLN" if country == "Poland" & exch != .
	replace currency = "RON" if country == "Romania" & exch != .
	replace currency = "SEK" if country == "Sweden" & exch != .
	replace currency = "ESP" if country == "Spain" & exch != .
	label var currency "Currency"
	
	/* Euro */
	gen eu = exch if country == "Euro area"
	egen exch_eu = max(eu), by(year)
	replace currency = "EUR" if exch == . & currency == "" 
	replace exch = exch_eu if exch == . & currency == "EUR"
	label var exch_eu "Nominal exchange rate (local per EUR)"
	drop eu
		
	/* Drop missing */
	drop if exch == .
	
	/* Conversion: 2015 */
	gen ex = exch if year == 2015
	egen exch_2015 = max(ex), by(country)
	label var exch_2015 "Nominal exchange rate (local per USD in 2015)"
	drop ex	
	
	/* Save */
	save WB_nominal_exchange_rate, replace
	
	/* Project */
	project, creates("`directory'\Data\WB_nominal_exchange_rate.dta")		
	
/* World Bank GDP deflator data */	
	
	/* Data */
	import delimited using WB_GDP_deflator.txt, delimiter(tab) varnames(1) clear
	
	/* Rename */
	rename countryname country
	label var country "Country"
	rename time year
	label var year "Year"
	rename value deflator
	label var deflator "GDP deflator (USD)"
	
	/* Keep */
	keep country year deflator
	
	/* Country name */
	replace country = "Slovakia" if country == "Slovak Republic"
	
	/* Rebase (to 2015) */
	gen deflator_2015 = deflator if year == 2015
	egen base = max(deflator_2015), by(country)
	replace deflator = deflator/base
	drop deflator_2015 base	
	
	/* Drop missing */
	drop if deflator == .
	
	/* Save */
	save WB_GDP_deflator, replace
	
	/* Project */
	project, creates("`directory'\Data\WB_GDP_deflator.dta")

********************************************************************************
**** (2) Sample restriction	& variable definition							****
********************************************************************************

/* Delete existing outcomes data */
cd "`directory'\Data"
cap rm Outcomes.dta

/* Countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop */
foreach country of local countries {

	/* Project */
	project, uses("`directory'\Amadeus\Data_`country'.dta")

	/* Data */
	cd "`directory'\Amadeus"
	use Data_`country', clear

	/* Sample period (after EUR) */
	keep if year >= 1999 & year <= 2015	
	
	/* Non-missing industry */
	drop if industry == .

	/* BvD ID */
	drop bvd_id
	rename bvd_id_new bvd_id
	egen double id = group(bvd_id)
	
	/* Panel */
	duplicates drop id year, force
	xtset id year
	
	/* Limited liability (cf. BvD legal type document: focus on corporations; most directly affected by thresholds) */
	
		/* Other */
		gen other = 0
		replace other = 1 if ///
			regexm(lower(type), "unlimited") == 1 | ///
			regexm(lower(type), "unltd") == 1 | ///
			regexm(lower(type), "association") == 1 | ///
			regexm(lower(type), "partnership") == 1 | ///
			regexm(lower(type), "proprietorship") == 1 | ///
			regexm(lower(type), "cooperative") == 1
			
		/* Generic */
		gen limited = 1 if ///
			regexm(lower(type), "limited liability company") == 1 | ///
			regexm(lower(type), "limited company") == 1 | ///
			regexm(lower(type), "joint stock") == 1 | ///
			regexm(lower(type), "joint-stock") == 1 | ///
			regexm(lower(type), "share company") == 1 | ///
			regexm(lower(type), "one-person company with limited liability") == 1 | ///
			regexm(lower(type), "company limited by shares") == 1
		replace limited = 0 if limited == . | other == 1
		label var limited "Limited corporations"
		
		/* Country specific (legal forms) */
		replace limited = 1 if ///
			(lower(type) == "gmbh" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "AG" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "(E)BVBA / SPRL(U)" & (country == "Belgium" | country == "Luxembourg")) | ///
			(type == "AS" & country == "Czech Republic") | ///
			(type == "OY" & country == "Finland") | ///			
			(type == "OYJ" & country == "Finland") | ///			
			(type == "EURL" & country == "France") | ///			
			(type == "SARL" & country == "France") | ///			
			(type == "Société en action simple" & country == "France") | ///			
			(type == "SA" & (country == "France" | country == "Greece")) | ///			
			(regexm(type, "GmbH & Co KG") == 1 & country == "Germany") | ///			
			(regexm(type, "Limited liability company & partnership") ==1 & country == "Germany") | ///			
			(regexm(type, "AG & C0 KG") ==1 & country == "Germany") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(regexm(type, "Private") ==1 & country == "Ireland") | ///			
			(regexm(type, "Public") ==1 & country == "Ireland") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(type == "SRL" & country == "Italy") | ///			
			(type == "SPA" & country == "Italy") | ///			
			(regexm(type, "SCARL") == 1 & country == "Italy") | ///			
			(regexm(type, "SCRL") == 1 & country == "Italy") | ///			
			(type == "SA" & country == "Italy") | ///			
			(type == "NV / SA" & country == "Luxembourg") | ///			
			(type == "NV" & country == "Netherlands") | ///			
			(type == "BV" & country == "Netherlands") | ///			
			(type == "AS" & country == "Norway") | ///			
			(type == "ASA" & country == "Norway") | ///			
			(type == "SP. Z O.O." & country == "Poland") | ///			
			(type == "S.A." & country == "Poland") | ///			
			(type == "SA" & country == "Poland") | ///			
			(type == "Sp. z.o.o." & country == "Poland") | ///			
			(type == "S.R.L." & country == "Portugal") | ///			
			(type == "S.R.O." & country == "Slovakia") | ///			
			(type == "d.d." & country == "Slovenia") | ///			
			(type == "d.o.o." & country == "Slovenia") | ///			
			(regexm(type, "Sociedad anonima") == 1 & country == "Spain") | ///			
			(regexm(type, "Sociedad limitada") == 1 & country == "Spain") | ///			
			(regexm(type, "AB") == 1 & country == "Sweden") | ///
			(type == "Private" & country == "United Kingdom") | ///
			(type == "Private Limited" & country == "United Kingdom") | ///
			(regexm(type, "Public") == 1 & country == "United Kingdom")
		
		/* Backfill */
		egen mode = mode(limited), by(id)
		replace limited = mode
		label var limited "Limited liability"
		drop mode type
		keep if limited == 1
		
	/* Entry */
	egen mode = mode(dateinc), by(id)
	gen inc_year = substr(mode, -4, 4)
	destring inc_year, replace force
	gen entry = (inc_year + 2 >= year) if year >= inc_year
	label var entry "Entry (past 2 years)"
	drop mode inc_year dateinc
	
	/* Exit (broad definition: failing, consolidating/merging, stopping production) */
	bys year id (lstatus): replace lstatus = lstatus[_N] if missing(lstatus)
	gen exit = 1 if ///
		regexm(lower(lstatus), "insolvency") == 1 | ///
		regexm(lower(lstatus), "receivership") == 1 | ///
		regexm(lower(lstatus), "liquidation") == 1 | ///
		regexm(lower(lstatus), "dissolved") == 1 | ///
		regexm(lower(lstatus), "inactive") == 1 | ///
		regexm(lower(lstatus), "dormant") == 1 | ///
		regexm(lower(lstatus), "bankruptcy") == 1
	replace exit = 0 if exit == . & lstatus != ""
	label var exit "Exit"
	drop lstatus
	
	/* Quoted/listed */
	bys year id (quoted): replace quoted = quoted[_N] if missing(quoted)
	gen listed = (quoted == "Yes") if quoted != ""
	label var listed "Listed/quoted"
	drop quoted
	
	/* Auditor */
	gen audit = (ad_name != "")
	label var audit "Audit"
	drop ad_name
	
	/* Independence */
	gen indep = 1 if indepind == "A+"
	replace indep = 2 if indepind == "A"
	replace indep = 3 if indepind == "A-"
	replace indep = 4 if indepind == "B+"
	replace indep = 5 if indepind == "B"
	replace indep = 6 if indepind == "B-"
	replace indep = 7 if indepind == "C+"
	replace indep = 8 if indepind == "C"
	replace indep = 9 if indepind == "D"
	replace indep = (9 - indep)/(9 - 1)
	label var indep "Independence (Ownership)"
	drop indepind
	
	/* Shareholders */
	gen shareholders = ln(1+onbr)
	label var shareholders "Shareholders (Log)"
	drop onbr
	
	/* Peer group size */
	gen peers = ln(1+pgsize)
	label var peers "Number of peers (Log; acc. BvD)"
	drop pgsize
	
	/* Exchange rate and inflation adjustment (exchange rate and GDP deflator) */

		/* Currency translation (from account to local currency) */
		
			/* Filling missing */	
			egen firm_mode = mode(currency), by(id)
			egen country_mode = mode(currency), by(country year)
			replace currency = firm_mode if currency == "" | length(currency) > 3
			replace currency = country_mode if currency == "" | length(currency) > 3
			drop firm_mode country_mode
			
			/* Merge: account currency exchange rate */
			cd "`directory'\Data"
			merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch)
			drop if _merge == 2
			drop _merge
			rename currency currency_account
			rename exch exch_account
			replace exch_account = 1 if currency_account == "USD"
			
			/* Merge: local currency exchange rate */
			merge m:1 country year using WB_nominal_exchange_rate
			drop if _merge == 2
			drop _merge

			/* Conversion */
			local variables = "toas opre turn fias ifas ltdb cost mate staf inte av ebta"
			foreach var of varlist `variables' {
			
				/* Convert account currency to USD + USD to local currency */
				replace `var' = `var'/exch_account*exch if currency_account != currency
			}

		/* Deflating (price level as of 2015) */
		
			/* Merge: GDP deflator */
			merge m:1 country year using WB_GDP_deflator
			drop if _merge == 2
			drop _merge
			
			/* Deflating */
			foreach var of varlist `variables' {
			
				/* Deflate nominal variables (in local currency) with country-year specific GDP deflator */
				replace `var' = `var'/deflator
			}		
			
		/* Currency translation (to USD as of 2015) */
		
			/* Translation */
			foreach var of varlist `variables' {
			
				/* Translate real variables (in local currency) to USD */
				replace `var' = `var'/exch_2015
			}	
	
		/* Drop */
		drop exch* deflator currency*
	
	/* Panel (reset) */
	xtset id year
	
	/* Employees */
	replace empl = empl_c if empl == .
	drop empl_c
	
	/* Material costs */
	replace mate = cost if mate == .
	drop cost
	
	/* Total variable cost */
	egen vc = rowtotal(mate staf)
	label var vc "Variable cost"

	/* Output */
	gen sales = turn
	replace sales = opre if turn == .
	label var sales "Sales"
	
	/* Markup */
	gen markup = (sales - vc)/sales
	replace markup = . if markup > 1 | markup < 0
	label var markup "(Y-c)/Y (Markup)"
	
	/* Operating margin */
	gen margin = ebta/sales
	replace margin = . if margin > 1 | margin < 0	
	label var margin "(Y-c)/Y (Operating Margin)"
	
	/* Capital-labor ratio */
	gen cl_e = ln(fias/empl)
	label var cl_e "K/L (Employees)"
	
	gen cl_w = ln(fias/staf)
	label var cl_w "K/L (Wage)"
	
	/* Capital-output ratio */
	gen cy = ln(fias/sales)
	label var cy "K/Y"
		
	/* Productivity */
	
		/* Labor productivity */
		gen lp_e = ln(sales/empl)
		label var lp_e "Y/L (Employees)"
		
		gen lp_w = ln(sales/staf)
		label var lp_w "Y/L (Wage)"
		
		/* Total factor productivity (excl. materials) */
		gen tfp_e = ln(sales) - 0.3*ln(fias) - 0.7*ln(empl)
		label var tfp_e "TFP (Employees)"
		
		gen tfp_w = ln(sales) - 0.3*ln(fias) - 0.7*ln(staf)
		label var tfp_w "TFP (Wage)"
	
********************************************************************************
**** (3) Outcomes (aggregation)												****
********************************************************************************

/* Information environment */
	
	/* Number of firms (control in later specifications) */
	egen firms = count(id), by(industry year)
	replace firms = ln(firms)
	label var firms "Number of firms"
	
	/* Other information environment variables */
	local information = "audit listed"
	foreach var of varlist `information' {
	
		/* Mean */
		egen m_`var' = mean(`var'), by(industry year)
		
		/* Weighted */
		egen double total = total(sales) if `var' ! = ., by(industry year) missing
		egen w_`var' = total(`var'*sales/total), by(industry year) missing
		drop total `var'	
	}

/* Concentration measures */

	/* HHI */
	egen total = total(sales), by(industry year) missing
	egen hhi = total((sales/total)^2), by(industry year) missing
	label var hhi "Concentration (HHI)"
	drop total

/* Productivity and output */

	/* Input and output */
	local measures = "sales empl fias"
	foreach var of varlist `measures' {	
	
		/* Mean */
		gen ln_`var' = ln(`var')
		egen m_`var' = mean(ln_`var'), by(industry year)

	}
	
	/* Productivity, profitability, and markup measures  */
	local measures = "lp_* tfp_* markup margin"
	foreach var of varlist `measures' {
		
		/* Mean */
		egen m_`var' = mean(`var'), by(industry year)
		
		/* Mean (growth) */
		gen d_`var' = d.`var'
		egen dm_`var' = mean(d_`var'), by(industry year)				
		
		/* Weighted */
		egen double total = total(sales) if `var' ! = ., by(industry year) missing
		egen w_`var' = total(`var'*sales/total), by(industry year) missing
				
		/* Weighted (growth) */
		gen dw_`var' = d.w_`var'

		/* Upper and lower tails */
		egen  p20_`var' = pctile(`var'*sales/total), p(20) by(industry year)
		replace p20_`var' = . if p20_`var' == 0
		egen  p80_`var' = pctile(`var'*sales/total), p(80) by(industry year)
		replace p80_`var' = . if p80_`var' == 0
		
		/* Distance between 20-80 percentile */
		gen di_`var' = p80_`var' - p20_`var'
		replace di_`var' = . if di_`var' == 0
			
		/* Standardized range */
		gen sr_`var' = di_`var'/m_`var'
		
		/* Dispersion */
		egen sd_`var' = sd(`var'*sales/total), by(industry year)
		replace sd_`var' = . if sd_`var' == 0
		drop total
		
		/* Coefficient of variation */
		gen cv_`var' = sd_`var'/m_`var'
		
		/* Covariance */
		egen mean = mean(`var') if sales != . & `var' != ., by(industry year)
		egen double total = total(sales) if sales != . & `var' ! = ., by(industry year)
		gen cov = w_`var' - mean
		egen cov_`var' = mode(cov), by(industry year)
		replace cov_`var' = . if cov_`var' == 0
		drop total mean cov `var'
		
	}

/* Other */

	/* Other firm characteristics, entry, exit */
	local characteristics = "entry exit indep shareholders"
	foreach var of varlist `characteristics' {
		/* Mean */
		egen m_`var' = mean(`var'), by(industry year)
		
		/* Weighted */
		egen double total = total(sales) if `var' ! = ., by(industry year) missing
		egen w_`var' = total(`var'*sales/total), by(industry year) missing
		drop total `var'	
	}
	
********************************************************************************
**** (4) Outcome data														****
********************************************************************************

/* Keeping relevant variables */
keep country industry year firms hhi m_* dm_* w_* dw_* p20_* p80_* di_* sr_* sd_* cv_* cov_*

/* Duplicates drop */
duplicates drop industry year, force

/* Labeling */

	/* Information environment */
	label var m_audit "Audit (Mean)"
	label var w_audit "Audit (Weighted)"
	label var m_listed "Listed (Mean)"
	label var w_listed "Listed (Weighted)"	
	
	/* Output */
	label var m_sales "Mean Y (Log)"

	/* Employees */
	label var m_empl "Mean L (Log)"	
	
	/* Fixed assets */
	label var m_fias "Mean K (Log)"	
	
	/* Productivity */
	label var m_lp_e "Y/L (Employees; Mean)"
	label var dm_lp_e "Y/L (Employees; Growth; Mean)"		
	label var w_lp_e "Y/L (Employees; Weighted)"
	label var dw_lp_e "Y/L (Employees; Growth; Weighted)"	
	label var p20_lp_e "Y/L (Employees; p20)"
	label var p80_lp_e "Y/L (Employees; p80)"
	label var di_lp_e "Y/L (Employees; p80-p20)"
	label var sr_lp_e "Y/L (Employees; p80-p20; scaled)"
	label var sd_lp_e "Y/L (Employees; SD)"
	label var cv_lp_e "Y/L (Employees; SD; scaled)"
	label var cov_lp_e "Y/L (Employees; Cov)"	
	
	label var m_lp_w "Y/L (Wage; Mean)"
	label var dm_lp_w "Y/L (Wage; Growth; Mean)"		
	label var w_lp_w "Y/L (Wage; Weighted)"
	label var dw_lp_w "Y/L (Wage; Growth; Weighted)"	
	label var p20_lp_w "Y/L (Wage; p20)"
	label var p80_lp_w "Y/L (Wage; p80)"
	label var di_lp_w "Y/L (Wage; p80-p20)"	
	label var sr_lp_w "Y/L (Wage; p80-p20; scaled)"
	label var sd_lp_w "Y/L (Wage; SD)"
	label var cv_lp_w "Y/L (Wage; SD; scaled)"
	label var cov_lp_w "Y/L (Wage; Cov)"
	
	label var m_tfp_e "TFP (Employees; Mean)"
	label var dm_tfp_e "TFP (Employees; Growth; Mean)"		
	label var w_tfp_e "TFP (Employees; Weighted)"
	label var dw_tfp_e "TFP (Employees; Growth; Weighted)"	
	label var p20_tfp_e "TFP (Employees; p20)"
	label var p80_tfp_e "TFP (Employees; p80)"
	label var di_tfp_e "TFP (Employees; p80-p20)"
	label var sr_tfp_e "TFP (Employees; p80-p20; scaled)"
	label var sd_tfp_e "TFP (Employees; SD)"
	label var cv_tfp_e "TFP (Employees; SD; scaled)"
	label var cov_tfp_e "TFP (Employees; Cov)"	
	
	label var m_tfp_w "TFP (Wage; Mean)"
	label var dm_tfp_w "TFP (Wage; Growth; Mean)"		
	label var w_tfp_w "TFP (Wage; Weighted)"
	label var dw_tfp_w "TFP (Wage; Growth; Weighted)"	
	label var p20_tfp_w "TFP (Wage; p20)"
	label var p80_tfp_w "TFP (Wage; p80)"
	label var di_tfp_w "TFP (Wage; p80-p20)"
	label var sr_tfp_w "TFP (Wage; p80-p20; scaled)"
	label var sd_tfp_w "TFP (Wage; SD)"
	label var cv_tfp_w "TFP (Wage; SD; scaled)"
	label var cov_tfp_w "TFP (Wage; Cov)"	
	
	/* Markup and margin */
	label var m_markup "(Y-c)/Y (Markup; Mean)"
	label var dm_markup "(Y-c)/Y (Markup; Growth; Mean)"		
	label var w_markup "(Y-c)/Y (Markup; Weighted)"
	label var dw_markup "(Y-c)/Y (Markup; Growth; Weighted)"	
	label var p20_markup "(Y-c)/Y (Markup; p20)"
	label var p80_markup "(Y-c)/Y (Markup; p80)"
	label var di_markup "(Y-c)/Y (Markup; p80-p20)"
	label var sr_markup "(Y-c)/Y (Markup; p80-p20; scaled)"
	label var sd_markup "(Y-c)/Y (Markup; SD)"
	label var cv_markup "(Y-c)/Y (Markup; SD; scaled)"
	label var cov_markup "(Y-c)/Y (Markup; Cov)"	
	
	label var m_margin "(Y-c)/Y (Margin; Mean)"
	label var dm_margin "(Y-c)/Y (Margin; Growth; Mean)"		
	label var w_margin "(Y-c)/Y (Margin; Weighted)"
	label var dw_margin "(Y-c)/Y (Margin; Growth; Weighted)"	
	label var p20_margin "(Y-c)/Y (Margin; p20)"
	label var p80_margin "(Y-c)/Y (Margin; p80)"
	label var di_margin "(Y-c)/Y (Margin; p80-p20)"
	label var sr_margin "(Y-c)/Y (Margin; p80-p20; scaled)"
	label var sd_margin "(Y-c)/Y (Margin; SD)"
	label var cv_margin "(Y-c)/Y (Margin; SD; scaled)"
	label var cov_margin "(Y-c)/Y (Margin; Cov)"	
		
	/* Other firm characteristics, entry, exit */
	label var m_indep "Independence (Mean)"
	label var w_indep "Independence (Weighted)"	
	label var m_shareholders "Shareholders (Mean)"
	label var w_shareholders "Shareholders (Weighted)"
	label var m_entry "Entry (Mean)"
	label var w_entry "Entry (Weighted)"
	label var m_exit "Exit (Mean)"
	label var w_exit "Exit (Weighted)"		

/* Append */
cd "`directory'\Data"
cap append using Outcomes

/* Save */
save Outcomes, replace
		
/* End: Country loop */
}

/* Project	*/
project, creates("`directory'\Data\Outcomes.dta")
	
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Construct panel (financial, company, ownership information)	****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // specify location of (raw) STATA files

********************************************************************************
**** (1) Constructing panel data by country	and vintage						****
********************************************************************************

/* Sample countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Year/Vintage loop */
local years = "2005 2008 2012 2016"
	
/* Country loop */
foreach country of local countries {
	
	/* Vintage loop */
	foreach year of local years {
		
		/* Financials */
		
			/* Project */
			cap project, original("`data'\Financials\`country'_Financials_`year'.dta")		
		
			/* Vintages: 2005 and 2008 */
			if "`year'" == "2005" | "`year'" == "2008" {
			
				/* Data */
				cd "`data'\Financials"
				use `country'_Financials_`year', clear

				/* Relevant variables */
				keep accnr idnr consol statda toas empl opre turn fias ifas ltdb cost mate staf av inte ebta
				
				/* Generate year */
				split statda, p(/)
				destring statda*, replace
				replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
				replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
				rename statda3 year
				replace year = year - 1 if statda1 <=6
				label var year "Year"
				drop statda*
				
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Financials_`year', replace
			
			/* End: Vintages 2005 and 2008 */
			}

			/* Vintages: 2012 */
			if "`year'" == "2012" {
			
				/* Data */
				cd "`data'\Financials"
				use `country'_Financials_`year', clear

				/* Relevant variables (including R&D from 2012 on) */
				keep accnr idnr consol statda toas empl opre turn fias ifas ltdb cost mate staf av inte ebta				
				
				/* Generate year */
				split statda, p(/)
				destring statda*, replace
				replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
				replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
				rename statda3 year
				replace year = year - 1 if statda1 <=6
				label var year "Year"
				drop statda*
				
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Financials_`year', replace
			
			/* End: Vintages 2012 */
			}
			
			/* Vintage: 2016 */
			if "`year'" == "2016" {
	
				/* Data */
				cd "`data'\Financials"
				use `country'_Financials_`year', clear

				/* Relevant variables */
				keep idnr unit closdate closdate_year toas empl opre turn fias ifas ltdb cost mate staf inte av ebta
				
				/* Generate year */
				gen closdate_month = month(closdate)
				gen year = closdate_year
				replace year = year - 1 if closdate_month <= 6
				label var year "Year"
				drop closdate*	
	
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Financials_2016, replace
			
			/* End: Vintage 2016 */
			}
			
		/* Company (type, unit, currency) */

			/* Vintages: 2005 and 2008 */
			if "`year'" == "2005" | "`year'" == "2008" {
	
				/* Data */
				cd "`data'\Company"
				use `country'_Company_`year', clear
			
				/* Relevant variables */
				keep accnr type unit currency
				
				/* Destring unit */
				capture {
					destring unit, replace
					rename unit_string unit
				}

				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Company_`year', replace
			
			/* End: Vintages 2005 and 2008 */
			}
			
			/* Vintage: 2012 */
			if "`year'" == "2012" {			
	
				/* Data */
				cd "`data'\Company"
				use `country'_Company_`year', clear
			
				/* Relevant variables */
				keep accnr type currency
				
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"				
				save `country'_Company_`year', replace	
			
			/* End: Vintage 2012 */
			}
			
			/* Vintage: 2016 */
			if "`year'" == "2016" {
			
				/* Data */
				cd "`data'\Company"
				use `country'_Company_`year', clear
			
				/* Relevant variables */
				keep accnr consol idnr type currency

				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"				
				save `country'_Company_`year', replace
		
			/* End: Vintage 2016 */
			}		
		
		/* Combination */

			/* Vintages: 2005 (units: units) */
			if "`year'" == "2005" {
			
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
	
				/* Merge company data */
				merge m:m accnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge
		
				/* Unit conversion */
				local num_list = "toas opre turn fias ifas ltdb cost mate staf av inte ebta"
				foreach var of varlist `num_list' {
					replace `var' = `var'*10^unit
				}
				
				/* Consolidation: avoid duplication (drop duplicates associated with C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				duplicates drop idnr year if dup != 0, force
				drop dup con c2	
					
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge
				
				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
				
				/* Save */
				save `country'_Combined_`year', replace
		
			/* End: Vintages 2005 */
			}
			
			/* Vintage: 2008 (unit: thousands) */
			if "`year'" == "2008" {
			
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
	
				/* Merge company data */
				merge m:m accnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge
		
				/* Unit conversion */
				local num_list = "toas opre turn fias ifas ltdb cost mate staf av inte ebta"
				foreach var of varlist `num_list' {
					replace `var' = `var'*10^3
				}
				
				/* Consolidation: avoid duplication (drop duplicates associated with C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				cap duplicates drop idnr year if dup != 0, force
				drop dup con c2	
					
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge				
				
				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
				
				/* Save */
				save `country'_Combined_`year', replace
		
			/* End: Vintages 2008 */
			}
			
			/* Vintage: 2012 */
			if "`year'" == "2012" {
			
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
			
				/* Merge company data */
				merge m:m accnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge
	
				/* Consolidation: avoid duplication (drop duplicates associated with C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				cap duplicates drop idnr year if dup != 0, force
				drop dup con c2	
					
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge				

				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
				
				/* Save */
				save `country'_Combined_`year', replace
				
			/* End: Vintage 2012 */
			}
			
			/* Vintage: 2016 */
			if "`year'" == "2016" {
	
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
			
				/* Merge company data */
				merge m:m idnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge 

				/* Consolidation: avoid duplication (drop duplicates associated with C1 & C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				cap duplicates drop idnr year if dup != 0, force
				drop dup con c2	
		
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge
				
				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
		
				/* Save */
				save `country'_Combined_`year', replace
		
				/* Delete intermediate */
				rm `country'_Financials_`year'.dta
				rm `country'_Company_`year'.dta
				
			/* End: Vintage 2016 */
			}
	
	/* End: Vintage loop */
	}
			
/* End: Country loop */		
}

********************************************************************************
**** (2) Merging panel data by country										****
********************************************************************************

/* Years (start with latest vintage; after 2016) */
local years = "2012 2008 2005"

/* Country loop */
foreach country of local countries {
	
	/* Data: Vintage 2016 */
	cd "`directory'\Amadeus"				
	use `country'_Combined_2016, clear	
	
	/* Vintage loop */
	foreach year of local years {
			
		/* Merge: update */
		merge 1:1 bvd_id_new year using `country'_Combined_`year', update
		drop _merge
		
		/* Duplicates */
		egen id = group(bvd_id_new)
		duplicates drop id year, force
		drop id	
		
		/* Delete intermediate */
		rm `country'_Combined_`year'.dta
		
	/* End: Vintage loop */
	}
	
	/* Add company panel information */
	rename vintage vintage_disc
	gen vintage = year + 1
	merge m:1 bvd_id_new vintage using Company_`country'
	drop if _merge == 2
	drop _merge vintage
	rename vintage_disc vintage	
	
	/* Compress */
	compress
	
	/* Save */
	save Data_`country', replace
	
	/* Project	*/
	project, creates("`directory'\Amadeus\Data_`country'.dta")
	
/* End: Country loop */		
}
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/11/2017													****
**** Program:	Regulations													****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // insert path to (raw) STATA files

/* Project */
project, original("`directory'\Data\Regulation.csv")
project, original("`directory'\Data\MAD.csv")
project, original("`directory'\Data\IFRS.csv")				
project, uses("`directory'\Data\WB_nominal_exchange_rate.dta")		

********************************************************************************
**** (1) Regulatory thresholds												****
********************************************************************************

/* Data */
import delimited using Regulation.csv, delimiter(",") varnames(1) clear

/* Mode currency */
egen mode = mode(currency_reporting), by(country)
replace currency_reporting = mode if currency_reporting == ""
drop mode

egen mode = mode(currency_audit), by(country)
replace currency_audit = mode if currency_audit == ""
drop mode

/* Cleaning */
keep if year != . & year < 2016

/* Exchange rates */

	/* Reporting threshold currency */
	cd "`directory'\Data"
	rename currency_reporting currency
	merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch_eu)
	drop if _merge==2
	drop _merge
	rename exch_eu exch_reporting
	rename currency currency_reporting

	/* Audit threshold currency */
	rename currency_audit currency
	merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch_eu)
	drop if _merge==2
	drop _merge	
	rename exch_eu exch_audit
	rename currency currency_audit

/* Missing rates (Wikipedia: conversion rates to EUR at official conversion date) */

	/* Italian Lira */
	replace exch_reporting = 1936.27 if currency_reporting == "ITL"
	replace exch_audit = 1936.27 if currency_audit == "ITL"

	/* French Franc */
	replace exch_reporting = 6.55957 if currency_reporting == "FRF"
	replace exch_audit = 6.55957 if currency_audit == "FRF"
	
	/* German mark */
	replace exch_reporting = 1.95583 if currency_reporting == "DEM"
	replace exch_audit = 1.95583 if currency_audit == "DEM"	
	
	/* Finish marka */
	replace exch_reporting = 5.94 if currency_reporting == "FIM"
	replace exch_audit = 5.94 if currency_audit == "FIM"	
	
	/* Greek drachma */
	replace exch_reporting = 340.750 if currency_reporting == "GRD"
	replace exch_audit = 340.750 if currency_audit == "GRD"	
	
	/* Irish pound */
	replace exch_reporting = 0.787564 if currency_reporting == "IEP"
	replace exch_audit = 0.787564 if currency_audit == "IEP"		

	/* Dutch guilder */
	replace exch_reporting = 2.20371 if currency_reporting == "NLG"
	replace exch_audit = 2.20371 if currency_audit == "NLG"	

	/* Portuguese escudo */
	replace exch_reporting = 200.482 if currency_reporting == "PTE"
	replace exch_audit = 200.482 if currency_audit == "PTE"		
	
	/* Spanish peseta */
	replace exch_reporting = 166.386 if currency_reporting == "ESP"
	replace exch_audit = 166.386 if currency_audit == "ESP"		

/* Filling in missing exchange rates (forward) */
egen c = group(country)
duplicates drop c year, force
xtset c year
foreach var of varlist exch_reporting exch_audit {
	forvalues i = 1(1)15 {
		replace `var' = l.`var' if `var' == . & l.`var' != . & year == 1999 + `i'
	}
}

/* Keep relevant variables */
keep ///
	country ///
	year ///
	eu_date ///
	euro_date ///
	directive_4 ///
	directive_7 ///
	at_reporting ///
	sales_reporting ///
	empl_reporting ///
	bs_preparation_abridged ///
	is_preparation_abridged ///
	notes_preparation_abridged ///
	bs_publication ///
	is_publication ///
	notes_publication ///
	at_audit ///
	sales_audit ///
	empl_audit ///
	exch_* ///
	currency_reporting ///
	currency_audit
	
/* Labeling */
label var country "Country"
label var year "Year"
label var eu_date "EU Accession Year"
label var euro_date "EURO Accession Year"
label var directive_4 "4th Directive Implementation Year" 
label var directive_7 "7th Directive Implementation Year"
label var at_reporting "Total Assets Threshold (Reporting Requirements)"
label var sales_reporting "Sales Threshold (Reporting Requirements)"
label var empl_reporting "Employees Threshold (Reporting Requirements)"
label var bs_preparation_abridged "Balance Sheet Preparation (Abridged)"
label var is_preparation_abridged "Income Statement Preparation (Abridged)"
label var notes_preparation_abridged "Notes Preparation (Abridged)"
label var bs_publication "Balance Sheet Publication"
label var is_publication "Income Statement Publication"
label var notes_publication "Notes Publication"
label var at_audit "Total Assets Threshold (Audit Requirements)"
label var sales_audit "Sales Threshold (Audit Requirements)"
label var empl_audit "Employees Threshold (Audit Requirements)"
label var currency_reporting "Currency (Reporting Requirements)"
label var currency_audit "Currency (Audit Requirements)"

/* Save */
save Regulation, replace

********************************************************************************
**** (2) Adding concurrent regulations										****
********************************************************************************

/* MAD */

	/* Data */
	import delimited using MAD.csv, delimiter(",") varnames(1) clear

	/* Save */
	save MAD, replace
	
/* IFRS */

	/* Data */
	import delimited using IFRS.csv, delimiter(",") varnames(1) clear

	/* Save */
	save IFRS, replace

/* Data */
use Regulation, clear
merge m:1 country using MAD
drop if _merge == 2
drop _merge

merge m:1 country using IFRS
drop if _merge == 2
drop _merge

/* Sort */
sort country year

/* Save */
save Regulation, replace

********************************************************************************
**** (3) Thresholds (only)													****
********************************************************************************

/* Keep threshold variables */
keep ///
	country ///
	year ///
	at_reporting ///
	sales_reporting ///
	empl_reporting ///
	bs_preparation_abridged ///
	is_preparation_abridged ///
	notes_preparation_abridged ///
	bs_publication ///
	is_publication ///
	notes_publication ///
	at_audit ///
	sales_audit ///
	empl_audit ///
	exch_reporting ///
	exch_audit ///
	currency_reporting ///
	currency_audit

/* Save */
save Thresholds, replace

/* Project */
project, creates("`directory'\Data\Regulation.dta")	
project, creates("`directory'\Data\Thresholds.dta")	
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/11/2017													****
**** Program:	Scope [Excerpt]												****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // specify path to (raw) STATA files

/* Project */
project, uses("`directory'\Data\WB_nominal_exchange_rate.dta")	
project, uses("`directory'\Data\Regulation.dta")		

********************************************************************************
**** (1) Cross-country data													****
********************************************************************************

/* Delete existing outcomes data */
cd "`directory'\Data"
cap rm Scope_data.dta

/* Countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop */
foreach country of local countries {

	/* Project */
	project, uses("`directory'\Amadeus\Data_`country'.dta")		

	/* Data */
	cd "`directory'\Amadeus"
	use Data_`country', clear

	/* Keep relevant variables & observations */
	keep bvd_id_new toas empl empl_c opre turn year currency type industry country 
	drop if toas == . & empl == . & opre == . & turn == .
	
	/* Total assets */
	rename toas at
	
	/* Sales */
	gen sales = turn
	replace sales = opre if turn == .
	label var sales "Sales"
	drop opre turn
	
	/* Employees */
	replace empl = empl_c if empl == .
	drop empl_c
	
	/* Sample period (after EUR) */
	keep if year >= 1999 & year <= 2015	
	
	/* Non-missing industry */
	drop if industry == .

	/* BvD ID */
	rename bvd_id_new bvd_id
	egen double id = group(bvd_id)
	
	/* Panel */
	duplicates drop id year, force
	xtset id year
	
	/* Limited liability (cf. BvD legal type document: focus on corporations; most directly affected by thresholds) */
	
		/* Other */
		gen other = 0
		replace other = 1 if ///
			regexm(lower(type), "unlimited") == 1 | ///
			regexm(lower(type), "unltd") == 1 | ///
			regexm(lower(type), "association") == 1 | ///
			regexm(lower(type), "partnership") == 1 | ///
			regexm(lower(type), "proprietorship") == 1 | ///
			regexm(lower(type), "cooperative") == 1
			
		/* Generic */
		gen limited = 1 if ///
			regexm(lower(type), "limited liability company") == 1 | ///
			regexm(lower(type), "limited company") == 1 | ///
			regexm(lower(type), "joint stock") == 1 | ///
			regexm(lower(type), "joint-stock") == 1 | ///
			regexm(lower(type), "share company") == 1 | ///
			regexm(lower(type), "one-person company with limited liability") == 1 | ///
			regexm(lower(type), "company limited by shares") == 1
		replace limited = 0 if limited == . | other == 1
		label var limited "Limited corporations"
		
		/* Country specific (legal forms) */
		replace limited = 1 if ///
			(lower(type) == "gmbh" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "AG" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "(E)BVBA / SPRL(U)" & (country == "Belgium" | country == "Luxembourg")) | ///
			(type == "AS" & country == "Czech Republic") | ///
			(type == "OY" & country == "Finland") | ///			
			(type == "OYJ" & country == "Finland") | ///			
			(type == "EURL" & country == "France") | ///			
			(type == "SARL" & country == "France") | ///			
			(type == "Société en action simple" & country == "France") | ///			
			(type == "SA" & (country == "France" | country == "Greece")) | ///			
			(regexm(type, "GmbH & Co KG") == 1 & country == "Germany") | ///			
			(regexm(type, "Limited liability company & partnership") ==1 & country == "Germany") | ///			
			(regexm(type, "AG & C0 KG") ==1 & country == "Germany") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(regexm(type, "Private") ==1 & country == "Ireland") | ///			
			(regexm(type, "Public") ==1 & country == "Ireland") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(type == "SRL" & country == "Italy") | ///			
			(type == "SPA" & country == "Italy") | ///			
			(regexm(type, "SCARL") == 1 & country == "Italy") | ///			
			(regexm(type, "SCRL") == 1 & country == "Italy") | ///			
			(type == "SA" & country == "Italy") | ///			
			(type == "NV / SA" & country == "Luxembourg") | ///			
			(type == "NV" & country == "Netherlands") | ///			
			(type == "BV" & country == "Netherlands") | ///			
			(type == "AS" & country == "Norway") | ///			
			(type == "ASA" & country == "Norway") | ///			
			(type == "SP. Z O.O." & country == "Poland") | ///			
			(type == "S.A." & country == "Poland") | ///			
			(type == "SA" & country == "Poland") | ///			
			(type == "Sp. z.o.o." & country == "Poland") | ///			
			(type == "S.R.L." & country == "Portugal") | ///			
			(type == "S.R.O." & country == "Slovakia") | ///			
			(type == "d.d." & country == "Slovenia") | ///			
			(type == "d.o.o." & country == "Slovenia") | ///			
			(regexm(type, "Sociedad anonima") == 1 & country == "Spain") | ///			
			(regexm(type, "Sociedad limitada") == 1 & country == "Spain") | ///			
			(regexm(type, "AB") == 1 & country == "Sweden") | ///
			(type == "Private" & country == "United Kingdom") | ///
			(type == "Private Limited" & country == "United Kingdom") | ///
			(regexm(type, "Public") == 1 & country == "United Kingdom")
		
		/* Backfill */
		egen mode = mode(limited), by(id)
		replace limited = mode
		label var limited "Limited liability"
		drop mode type
		keep if limited == 1 
	
	/* Currency translation (to EURO; Lira conversion in "Regulation" also to EURO; scope is free of monetary unit) */
		
		/* Filling missing */	
		egen firm_mode = mode(currency), by(id)
		egen country_mode = mode(currency), by(country year)
		replace currency = firm_mode if currency == "" | length(currency) > 3
		replace currency = country_mode if currency == "" | length(currency) > 3
		drop firm_mode country_mode
			
		/* Merge: account currency exchange rate */
		cd "`directory'\Data"
		merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch_eu)
		drop if _merge == 2
		drop _merge
		rename currency currency_account
		rename exch_eu exch_account
			
		/* Merge: local currency exchange rate */
		merge m:1 country year using WB_nominal_exchange_rate
		drop if _merge == 2
		drop _merge

		/* Conversion */
		local sizes = "at sales"
		foreach var of varlist `sizes' {
			
			/* Convert account currency to EUR + EUR to local currency */
			replace `var' = `var'/exch_account*exch_eu if currency_account != currency
		}
	
	/* Keep relevant variables */
	keep bvd_id country industry year at sales empl 
	
	/* Append */
	cd "`directory'\Data"
	cap append using Scope_data
	 
	/*Save */
	save Scope_data, replace
}

/* Project */
project, creates("`directory'\Data\Scope_data.dta")		

********************************************************************************
**** (2) Thresholds															****
********************************************************************************

/* Data */
use Scope_data, clear

/* Merge: Thresholds */
merge m:1 country year using Thresholds
keep if _merge==3
drop _merge

/* Threshold currency translation */
foreach var of varlist at_reporting sales_reporting {
	replace `var'=`var'/exch_reporting if currency_reporting!="EUR" & currency_reporting!=""
}

foreach var of varlist at_audit sales_audit {
	replace `var'=`var'/exch_audit if currency_audit!="EUR" & currency_audit!=""
}

drop exch_* currency_*

** Reporting Requirements **
egen preparation=rowtotal(bs_preparation_abridged is_preparation_abridged notes_preparation_abridged), missing
replace preparation=3-preparation
label var preparation "Preparation Requirement Strength (Small)"

egen publication=rowtotal(bs_publication is_publication notes_publication), missing
label var publication "Publication Requirement Strength (Small)"

********************************************************************************
**** (3) Measured scope														****
********************************************************************************

/* Reporting scope indicator */
gen regulation = .
label var regulation "Reporting Regulation (Indicator)"

	/* Three thresholds */
	replace regulation = ((at>at_reporting & at!=. & sales>sales_reporting & sales!=.) | (at>at_reporting & at!=. & empl>empl_reporting & empl!=.) | (sales>sales_reporting & sales!=. & empl>empl_reporting & empl!=.)) ///
		if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.)
		
		/* Missing size values */
		replace regulation = (at>at_reporting & at!=.) ///
			if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.) & regulation == . & empl== . & sales== .
			
		replace regulation = (sales>sales_reporting & sales!=.) ///
			if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.) & regulation == . & at== . & empl== .
			
		replace regulation = (empl>empl_reporting & empl!=.) ///
			if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.) & regulation == . & at==. & sales==.		
		
	/* Two thresholds */	
	replace regulation = (at>at_reporting & at!=. & sales>sales_reporting & sales!=.) ///
		if at_reporting != . & sales_reporting != . & empl_reporting == .

		/* Missing size values */
		replace regulation = (at>at_reporting & at!=.) ///
			if (at_reporting != . & sales_reporting != . & empl_reporting == .) & regulation == . & sales== .
			
		replace regulation = (sales>sales_reporting & sales!=.) ///
			if (at_reporting != . & sales_reporting != . & empl_reporting == .) & regulation == . & at== .
			
	replace regulation = (at>at_reporting & at!=. & empl>empl_reporting & empl!=.) ///
		if at_reporting != . & sales_reporting == . & empl_reporting != .					

		/* Missing size values */
		replace regulation = (at>at_reporting & at!=.) ///
			if (at_reporting != . & sales_reporting == . & empl_reporting != .) & regulation == . & empl== .
			
		replace regulation = (empl>empl_reporting & empl!=.) ///
			if (at_reporting != . & sales_reporting == . & empl_reporting != .) & regulation == . & at== .
			
	replace regulation = (sales>sales_reporting & sales!=. & empl>empl_reporting & empl!=.) ///
		if at_reporting == . & sales_reporting != . & empl_reporting != .
		
		/* Missing size values */
		replace regulation = (sales>sales_reporting & sales!=.) ///
			if (at_reporting == . & sales_reporting != . & empl_reporting != .) & regulation == . & empl== .
			
		replace regulation = (empl>empl_reporting & empl!=.) ///
			if (at_reporting == . & sales_reporting != . & empl_reporting != .) & regulation == . & sales== .			
	
	/* One threshold  */
	replace regulation = (at>at_reporting & at!=.) ///
		if (at_reporting != . & sales_reporting == . & empl_reporting == .)	& regulation == .
		
	replace regulation = (sales>sales_reporting & sales!=.) ///
		if (at_reporting == . & sales_reporting != . & empl_reporting == .)	& regulation == .		

	replace regulation = (empl>empl_reporting & empl!=.) ///
		if (at_reporting == . & sales_reporting == . & empl_reporting != .)	& regulation == .

/* Audit scope indicator */
gen audit = .
label var audit "Audit Regulation (Indicator)"

	/* Three thresholds */
	replace audit = ((at>at_audit & at!=. & sales>sales_audit & sales!=.) | (at>at_audit & at!=. & empl>empl_audit & empl!=.) | (sales>sales_audit & sales!=. & empl>empl_audit & empl!=.)) ///
		if (at_audit!=. & sales_audit!=. & empl_audit!=.)
		
		/* Missing size values */
		replace audit = (at>at_audit & at!=.) ///
			if (at_audit!=. & sales_audit!=. & empl_audit!=.) & audit == . & empl== . & sales== .
			
		replace audit = (sales>sales_audit & sales!=.) ///
			if (at_audit!=. & sales_audit!=. & empl_audit!=.) & audit == . & at== . & empl== .
			
		replace audit = (empl>empl_audit & empl!=.) ///
			if (at_audit!=. & sales_audit!=. & empl_audit!=.) & audit == . & at==. & sales==.		
		
	/* Two thresholds */	
	replace audit = (at>at_audit & at!=. & sales>sales_audit & sales!=.) ///
		if at_audit != . & sales_audit != . & empl_audit == .

		/* Missing size values */
		replace audit = (at>at_audit & at!=.) ///
			if (at_audit != . & sales_audit != . & empl_audit == .) & audit == . & sales== .
			
		replace audit = (sales>sales_audit & sales!=.) ///
			if (at_audit != . & sales_audit != . & empl_audit == .) & audit == . & at== .
			
	replace audit = (at>at_audit & at!=. & empl>empl_audit & empl!=.) ///
		if at_audit != . & sales_audit == . & empl_audit != .					

		/* Missing size values */
		replace audit = (at>at_audit & at!=.) ///
			if (at_audit != . & sales_audit == . & empl_audit != .) & audit == . & empl== .
			
		replace audit = (empl>empl_audit & empl!=.) ///
			if (at_audit != . & sales_audit == . & empl_audit != .) & audit == . & at== .
			
	replace audit = (sales>sales_audit & sales!=. & empl>empl_audit & empl!=.) ///
		if at_audit == . & sales_audit != . & empl_audit != .
		
		/* Missing size values */
		replace audit = (sales>sales_audit & sales!=.) ///
			if (at_audit == . & sales_audit != . & empl_audit != .) & audit == . & empl== .
			
		replace audit = (empl>empl_audit & empl!=.) ///
			if (at_audit == . & sales_audit != . & empl_audit != .) & audit == . & sales== .			
	
	/* One threshold  */
	replace audit = (at>at_audit & at!=.) ///
		if (at_audit != . & sales_audit == . & empl_audit == .)	& audit == .
		
	replace audit = (sales>sales_audit & sales!=.) ///
		if (at_audit == . & sales_audit != . & empl_audit == .)	& audit == .		

	replace audit = (empl>empl_audit & empl!=.) ///
		if (at_audit == . & sales_audit == . & empl_audit != .)	& audit == .

/* Country-industry-level scope */
			
	/* Reporting */
	egen scope = mean(regulation), by(country industry year)
	label var scope "Scope (Country-Industry-Year)"
	 
	/* Audit */
	egen audit_scope = mean(audit), by(country industry year)
	label var audit_scope "Audit Scope (Country-Industry-Year)"
		
/* Preserve */
preserve

	/* Duplicates */
	duplicates drop country industry year, force
		
	/* Keep */
	keep country industry year scope audit_scope at_reporting at_* sales_* empl_*
	
	/* Save */
	save Scope, replace
	
/* Restore */
restore

********************************************************************************
**** (4) Simulated scope													****
********************************************************************************

/* Keep full disclosure countries */
keep if bs_publication == 1 & is_publication == 1 
drop bs_* is_* notes_*

/* Drop irrelevant data */
keep industry at empl sales

/* Delete prior Monte Carlo simulation */
capture {
	cd "`directory'\Data\Simulation"
	local datafiles: dir "`directory'\Data\Simulation" files "MC*.dta"
	foreach datafile of local datafiles {
			rm `datafile'
	}
}
	
/* Monte Carlo/Multivariate distribution */

	/* Logarithm (wse +1 adjustment in regulatory thresholds) */
	gen ln_at=ln(at)
	gen ln_sales=ln(sales+1)
	gen ln_empl=ln(empl+1)
 
	/* Draws (multivariate log-normal following Gibrat's Law) [growth rate independent of absolute size; see JEL article in IO] */
	gen n_at = (at != .)
	gen n_sa = (sales != .)
	gen n_em = (empl != .)
	egen count = total(n_at*n_sa*n_em), by(industry) missing
	egen group = group(industry) if count >= 200
	
	/* Loop through industries */
	sum group
	forvalues i=1/`r(max)' {
		
		/* Moments */
		foreach var of varlist at sales empl {
			sum ln_`var' if group==`i'
			local `var'_mean=`r(mean)'
			local `var'_sd=`r(sd)'
				
			foreach var2 of varlist at sales empl {
				corr ln_`var' ln_`var2' if group==`i'
				local `var'_`var2'=`r(rho)'
			}
		}
			
		/* Monte Carlo (use correlations: scale free; alleviates upward bias from missing variables in lower tail) */
		preserve
		
			/* Matrices */
			matrix mean_vector=(`at_mean' \ `sales_mean' \ `empl_mean')
			matrix sd_vector=(`at_sd' \ `sales_sd' \ `empl_sd')
			matrix corr_matrix=(1, `at_sales', `at_empl' \ `sales_at', 1, `sales_empl' \ `empl_at', `empl_sales', 1)
		
			/* MV-normal draw */
			set seed 1234
			drawnorm at sales empl, n(100000) means(mean_vector) sds(sd_vector) corr(corr_matrix) clear
			
			/* Log variables */
			gen y = sales
			gen k = at // approximation of fias
			gen l = empl
			
			/* Exponentiate (including adjustments -1) */
			replace at = exp(at)
			replace sales = exp(sales)-1
			replace empl = exp(empl)-1								
				
			/* Group ID */
			gen group=`i'
			
			/* Saving */
			cd "`directory'\Data\Simulation"
			save MC_industry_`i', replace
			
		restore
	}
	
	/* Save group-industry-correspondence */
	keep if group!=.
	duplicates drop group, force
	keep industry group
	save Correspondence, replace
	
/* Data */	
cd "`directory'\Data"
use Scope, clear

/* Monte Carlo simulation */
				
	/* MC consolidation */
	preserve
		clear all
		cd "`directory'\Data\Simulation"
		! dir MC_industry_*.dta /a-d /b >"`directory'\Data\Simulation\filelist.txt", replace

		file open myfile using "`directory'\Data\Simulation\filelist.txt", read

		file read myfile line
		use `line'
		save MC, replace

		file read myfile line
		while r(eof)==0 { /* while you're not at the end of the file */
			append using `line'
			file read myfile line
		}
		file close myfile
		
		/* Merge Correspondence */
		merge m:1 group using Correspondence
		keep if _merge==3
		drop _merge group
		
		/* Saving */
		save MC, replace
		
	restore

/* Country-industry looping: Monte Carlo */
egen cy_id = group(country year) if at_reporting != . | sales_reporting != . | empl_reporting != . | at_audit != . | sales_audit != . | empl_audit != .
sum cy_id
forvalues i=1/`r(max)' {
	
	/* Reporting */
	sum at_reporting if cy_id==`i'
	cap global at_rep=`r(mean)'
	
	sum sales_reporting if cy_id==`i'
	cap global sa_rep=`r(mean)'
	
	sum empl_reporting if cy_id==`i'
	cap global em_rep=`r(mean)'
	
	/* Audit */
	sum at_audit if cy_id==`i'
	cap global at_au=`r(mean)'
	
	sum sales_audit if cy_id==`i'
	cap global sa_au=`r(mean)'
	
	sum empl_audit if cy_id==`i'
	cap global em_au=`r(mean)'
	
	preserve

		/* MC Sample */
		cd "`directory'\Data\Simulation"
		use MC, clear
			
		/* Thresholds */

			/* Actual */	
				
				/* Reporting */
				gen rep = .
				
					/* Three thresholds */
					cap replace rep = ((at>${at_rep} & sales>${sa_rep}) | (at>${at_rep} & empl>${em_rep}) | (sales>${sa_rep} & empl>${em_rep})) ///
						if ${at_rep} != . & ${sa_rep} != . & ${em_rep} != .

					/* Two thresholds */
					cap replace rep = (at>${at_rep} & sales>${sa_rep}) ///
						if ${at_rep} != . & ${sa_rep} != . & ${em_rep} == .

					cap replace rep = (at>${at_rep} & empl>${em_rep}) ///
						if ${at_rep} != . & ${sa_rep} == . & ${em_rep} != .						

					cap replace rep = (sales>${sa_rep} & empl>${em_rep}) ///
						if ${at_rep} == . & ${sa_rep} != . & ${em_rep} != .	
						
					/* One threshold */
					cap replace rep = (at>${at_rep}) ///
						if ${at_rep} != . & ${sa_rep} == . & ${em_rep} == .					
					
					cap replace rep = (sales>${sa_rep}) ///
						if ${at_rep} == . & ${sa_rep} != . & ${em_rep} == .	

					cap replace rep = (empl>${em_rep}) ///
						if ${at_rep} == . & ${sa_rep} == . & ${em_rep} != .	
						
				/* Auditing */
				gen aud = .
				
					/* Three thresholds */
					cap replace aud = ((at>${at_au} & sales>${sa_au}) | (at>${at_au} & empl>${em_au}) | (sales>${sa_au} & empl>${em_au})) ///
						if ${at_au} != . & ${sa_au} != . & ${em_au} != .

					/* Two thresholds */
					cap replace aud = (at>${at_au} & sales>${sa_au}) ///
						if ${at_au} != . & ${sa_au} != . & ${em_au} == .

					cap replace aud = (at>${at_au} & empl>${em_au}) ///
						if ${at_au} != . & ${sa_au} == . & ${em_au} != .						

					cap replace aud = (sales>${sa_au} & empl>${em_au}) ///
						if ${at_au} == . & ${sa_au} != . & ${em_au} != .	
						
					/* One threshold */
					cap replace aud = (at>${at_au}) ///
						if ${at_au} != . & ${sa_au} == . & ${em_au} == .					
					
					cap replace aud = (sales>${sa_au}) ///
						if ${at_au} == . & ${sa_au} != . & ${em_au} == .	

					cap replace aud = (empl>${em_au}) ///
						if ${at_au} == . & ${sa_au} == . & ${em_au} != .	
			
		/* Aggregation */
				
			/* Reporting */	
			egen mc_scope = mean(rep), by(industry)
			
			/* Audit */
			egen mc_audit = mean(aud), by(industry)

		/* Relevant Observations */
		keep industry mc_*
		duplicates drop industry, force

		/* Identifier */
		gen cy_id = `i'			
			
		/* Saving */
		save MC_final_`i', replace
	
	restore
}

/* Merging */

	/* Monte Carlo (Industry) */
	sum cy_id, d
	forvalues i=1/`r(max)' {
		cd "`directory'\Data\Simulation\"
		merge m:m cy_id industry using MC_final_`i', update
		drop if _merge==2
		drop _merge
	}

********************************************************************************
**** (5) Cleaning, timing, and saving										****
********************************************************************************

/* Duplicates */
keep country industry year scope* audit_scope* joint_scope* mc_*
duplicates drop country industry year, force

/* Time (shifting back 1 year) */
replace year = year + 1

/* Labeling */
label var country "Country"
label var industry "NACE Industry (4-Digit)"
label var year "Year" 
label var mc_scope "Scope (MC)"
label var mc_audit "Audit Scope (MC)"

/* Save */
cd "`directory'\Data"
save Scope, replace

/* Project */
project, creates("`directory'\Data\Scope.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Database construction												****
********************************************************************************

/* Constructing company data */
project, do(Dofiles/Companies.do)

/* Constructing panel data (financials + company) */
project, do(Dofiles/Panel.do)

/* Constructing outcomes */
project, do(Dofiles/Outcomes.do)

/* Constructing regulatory threshold data */
project, do(Dofiles/Regulation.do)

/* Constructing scope measure */
project, do(Dofiles/Scope.do)


********************************************************************************
**** (3) Analyses															****
********************************************************************************

/* Constructing sample */
project, do(Dofiles/Data.do)

/* Running analyses */
project, do(Dofiles/Analyses.do)

/* Generating graphs */
project, do(Dofiles/Graphs.do)


********************************************************************************
**** (4) Identifiers [JAR Code & Data Policy]								****
********************************************************************************

/* Generating graphs */
project, do(Dofiles/Identifiers.do)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Setup of "project" program									****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Master directory ****
local master = "...\Project_Europe\Programs" // please insert/adjust directory path

********************************************************************************
**** (0) Install external program ("project")								****
********************************************************************************

**** Install ****
ssc install project

********************************************************************************
**** (1) Setup and building project: Local									****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Europe.do")

**** Build ****
cap noisily project Master_Europe, build
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Coverage (outcome) part calculated based on AMA	[Excerpt]	****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Amadeus"

**** Project ****
project, uses("`directory'\Amadeus\AMA_data.dta")

********************************************************************************
**** (1) Number of firms													****
********************************************************************************

/* Data */
use AMA_data, clear

/* Specify: level of industry (2-digit) */
rename industry industry_4
gen industry = floor(industry_4/100)
label var industry "Industry (2-Digit NACE/WZ)"

/* Restrict: limited liability firms */
keep if limited == 1
				
/* Balance sheet disclosure */
gen disclosure = (at != .)
label var disclosure "Disclosure (TA available from limited firms)"
				
/* Number of firms */
egen double no_firms = total(disclosure), by(county industry year)
label var no_firms "Number of disclosing (limited) firms"

********************************************************************************
**** (2) Cleaning, labeling, and saving										****
********************************************************************************

/* Keep relevant variables */
keep industry county year no_firms

/* Lag coverage/scope variables (t-2) */
replace year = year+2

/* Save */
cd "`directory'\Data"
save AMA_coverage, replace

/* Prior Stata Version for Destatis */
saveold AMA_coverage_2013, replace

/* Project */
project, creates("`directory'\Amadeus\AMA_coverage.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Amadeus dataset creation [Excerpt]							****
********************************************************************************
**** Note:		Executed on local computer to create AMA dataset to be 		****
****			transferred to and used by Statistisches Bundesamt (on-site)****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Amadeus"

**** Project ****
project, original("`directory'\Amadeus\germany_Financials_2005.dta")
project, original("`directory'\Amadeus\germany_Financials_2008.dta")
project, original("`directory'\Amadeus\germany_Financials_2012.dta")
project, original("`directory'\Amadeus\germany_Financials_2016.dta")
project, original("`directory'\Amadeus\germany_Company_2005.dta")
project, original("`directory'\Amadeus\germany_Company_2008.dta")
project, original("`directory'\Amadeus\germany_Company_2012.dta")
project, original("`directory'\Amadeus\germany_Company_2016.dta")
project, uses("`directory'\Amadeus\AMA_panel.dta")
project, uses("`directory'\Amadeus\AMA_panel_unique.dta")

********************************************************************************
**** (1) Creating unified datasets by vintage								****
********************************************************************************

/* Financials */

	/* Vintage: 2005 */
	
		/* Data */
		use germany_Financials_2005, clear
		
		/* Relevant variables */
		keep accnr idnr consol statda toas empl opre turn
		
		/* Generate year */
		split statda, p(/)
		destring statda*, replace
		replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
		replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
		rename statda3 year
		replace year = year - 1 if statda1 <=6
		drop statda*
		
		/* Save */
		save Financials_2005, replace

	/* Vintage: 2008 */
	
		/* Data */
		use germany_Financials_2008, clear
		
		/* Relevant variables */
		keep accnr idnr consol statda toas empl opre turn
		
		/* Generate year */
		split statda, p(/)
		destring statda*, replace
		replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
		replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
		rename statda3 year
		replace year = year - 1 if statda1 <=6
		drop statda*
		
		/* Save */
		save Financials_2008, replace	
	
	/* Vintage: 2012 */
	
		/* Data */
		use germany_Financials_2012, clear
		
		/* Relevant variables */
		keep accnr idnr consol statda toas empl opre turn
		
		/* Generate year */
		split statda, p(/)
		destring statda*, replace
		replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
		replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
		rename statda3 year
		replace year = year - 1 if statda1 <=6
		drop statda*
		
		/* Save */
		save Financials_2012, replace		
	
	/* Vintage: 2016 */

		/* Data */
		use germany_Financials_2016, clear
		
		/* Relevant variables */
		keep idnr unit closdate closdate_year toas empl opre turn
		
		/* Generate year */
		gen closdate_month = month(closdate)
		gen year = closdate_year
		replace year = year - 1 if closdate_month <= 6
		drop closdate*	
		
		/* Save */
		save Financials_2016, replace
	
/* Company (Type, unit, sales, and employees data) */

	/* Vintage: 2005 */
	
		/* Data */
		use germany_Company_2005, clear
	
		/* Relevant variables */
		keep accnr type unit 
		
		/* Save */
		save Company_2005, replace
		
	/* Vintage: 2008 */
	
		/* Data */
		use germany_Company_2008, clear
	
		/* Relevant variables */
		keep accnr type unit 
		
		/* Destring unit */
		destring unit_string, gen(unit)
		drop unit_string
		
		/* Save */
		save Company_2008, replace
	
	/* Vintage: 2012 */
	
		/* Data */
		use germany_Company_2012, clear
	
		/* Relevant variables */ /* missing: unit! */
		keep accnr type
		
		/* Save */
		save Company_2012, replace	
	
	/* Vintage: 2016 */

		/* Data */
		use germany_Company_2016, clear
	
		/* Relevant variables */
		keep accnr idnr type consol
		
		/* Save */
		save Company_2016, replace
		
/* Combination */

	/* Vintage: 2005 */
	
		/* Data */
		use Financials_2005, clear
	
		/* Merge company data */
		merge m:m accnr using Company_2005
		drop if _merge == 2
		drop _merge
		
		/* Unit conversion */
		local num_list = "toas"
		foreach var of varlist `num_list' {
			replace `var' = `var'*10^unit
		}

		/* Save */
		save Combined_2005, replace
		
	/* Vintage: 2008 (units: thousands) */
	
		/* Data */
		use Financials_2008, clear
	
		/* Merge company data */
		merge m:m accnr using Company_2008
		drop if _merge == 2
		drop _merge
		
		/* Unit conversion */
		local num_list = "toas"
		foreach var of varlist `num_list' {
			replace `var' = `var'*10^3 // in thousands
		}

		/* Save */
		save Combined_2008, replace
		
	/* Vintage: 2012 */
	
		/* Data */
		use Financials_2012, clear
	
		/* Merge company data */
		merge m:m accnr using Company_2012
		drop if _merge == 2
		drop _merge
		
		/* Save */
		save Combined_2012, replace

	/* Vintage: 2016 */
	
		/* Data */
		use Financials_2016, clear
	
		/* Merge company data */
		merge m:m idnr using Company_2016
		drop if _merge == 2
		drop _merge

		/* Save */
		save Combined_2016, replace
		
	/* Combined vintages (2005, 2008, 2012, and 2016) */
	
		/* Data */
		use Combined_2005, clear
		
		/* Update until 2008 */
		merge m:m accnr year using Combined_2008, update
		drop _merge
		
		/* Update until 2012 */
		merge m:m accnr year using Combined_2012, update
		drop _merge
		
		/* Update until 2016 */
		merge m:m accnr year using Combined_2016, update
		drop _merge

		/* Duplicates */
		egen double id = group(accnr)
		duplicates drop id year, force
		xtset id year
	
		/* Consolidation: avoid duplication (drop duplicates associated with C2) */
		rename idnr bvd_id	
		duplicates tag bvd_id year, gen(dup)
		gen con = (consol == "C2")
		egen c2 = max(con), by(bvd_id)
		drop if dup != 0 & (consol != "C2") & c2 == 1
		sort bvd_id year dup
		duplicates drop bvd_id year if dup != 0, force
		drop dup
		
		/* Sample period */
		keep if year >= 2000 & year <= 2014
		
		/* County & industry definitions */
			
			/* Define time dimension: vintage */
			gen vintage = year
			
			/* Merge company panel (bvd_id vintage: 2005-2014)*/
			merge 1:1 bvd_id vintage using AMA_panel, keepusing(industry ags)
			drop if _merge == 2
			drop _merge
			
			/* Apply earliest vintage to previous years (2000-2004) */
			drop id
			egen double id = group(bvd_id)
			xtset id year
			forvalues y = 1(1)6 {
				foreach var of varlist industry ags {
					replace `var' = f.`var' if `var' == . & f.`var' != . & vintage == 2008-`y'
				}
			}
			
			/* Merge company panel (bvd_id; update) */
			merge m:1 bvd_id using AMA_panel_unique, keepusing(industry ags) update
			drop if _merge == 2
			drop _merge
			
			/* Drop missing observations */
			drop if industry == . | ags ==.
			
			/* County identifier */
			tostring ags, gen(ags_string)
			gen county = substr(ags_string, -6, 3)
			egen county_id = group(county)
			drop ags_string

********************************************************************************
**** (2) (Re)Defining variables												****
********************************************************************************

/* Limited liability indicator */
gen limited = 0
replace limited = 1 if ///
	regexm(type, "AG") == 1 | ///
	regexm(type, "limited liability") == 1 | ///
	regexm(type, "European company") == 1 | ///
	regexm(type, "GmbH") == 1 | ///
	regexm(type, "Public limited") == 1

/* Total assets */
rename toas at

********************************************************************************
**** (3) Cleaning, labeling, and saving										****
********************************************************************************

/* Duplicates drop */
sort id year
duplicates drop id year, force

/* Keep relevant variables */
keep bvd_id year industry ags county county_id at sales empl limited
 
/* Labels */
label var bvd_id "BvD ID"
label var year "Fiscal Year"
label var industry "NACE 2 (WZ 2008)"
label var ags "AGS (BBSR, Destatis; manual)"
label var county "County (String)"
label var county_id "County ID (Numeric)"
label var at "Total Assets"
label var limited "Limited liability"

/* Save (final AMA data) */
save AMA_data, replace

/* Delete individual datasets */
forvalues y = 2005(1)2016 {
	capture {
		rm Company_`y'.dta
		rm Financials_`y'.dta
		rm Combined_`y'.dta
	}
}

/* Project */
project, creates("`directory'\Amadeus\AMA_data.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/23/2017													****
**** Program:	Amadeus ID and city panel [Excerpt]							****
********************************************************************************
**** Note:		Executed on local computer to create AMA dataset to be 		****
****			transferred to and used by Statistisches Bundesamt (on-site)****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Amadeus"

**** Project ****
forvalues year = 2005(1)2016 {
	project, original("`directory'\Amadeus\germany_Company_`year'.dta")
}
project, original("`directory'\Amadeus\correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format.dta")
project, original("`directory'\Amadeus\Counties.csv")

********************************************************************************
**** (1) Creating unified datasets by vintage								****
********************************************************************************

forvalues year = 2005(1)2016 {

	/* Data */
	use germany_Company_`year', clear
	
	/* Rename */
	cap rename company company_name
	cap rename name company_name
	cap rename zip zipcode
	cap rename bvd_id_number bvd_id
	cap rename idnr bvd_id
	cap rename nacpri nace_ind
	cap rename nac2pri nace2_ind
	cap rename nacerev2primarycode nace2_ind
	cap rename nace_prim_code nace2_ind
	
	/* Keep relevant data */
	cap keep bvd_id company_name city zipcode nace_ind
	cap keep bvd_id company_name city zipcode nace2_ind
	
	/* Industry */
	cap destring nace_ind, replace
	cap destring nace2_ind, replace
	
	/* Vintage */
	gen vintage = `year'
	
	/* Append */
	if `year' == 2005 {
		
		/* Save panel */
		cap rm AMA_panel.dta
		save AMA_panel, replace
	}
	
	if `year' > 2005 {
		
		/* Append */
		append using AMA_panel
		
		/* Save panel */
		save AMA_panel, replace	
	}
}

/* ID */
drop if bvd_id == "" | substr(bvd_id, 1, 2) != "DE"
egen double id = group(bvd_id)

/* Duplicates (tag) */
duplicates tag id vintage, gen(dup)

/* Drop: missing location or industry if duplicate */
drop if dup > 0 & (city == "" | (nace_ind == . & nace2_ind == .))
drop dup

/* Duplicates (drop) */
sort id vintage
duplicates drop id vintage, force

/* Panel */
xtset id vintage

/* Save */
save AMA_panel, replace

********************************************************************************
**** (2) Creating industry and location correspondence tables				****
********************************************************************************

/* Industry (NACE) correspondence (Sebnem et al. (2015)) */

	/* Correspondence table */
	use correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format, clear

	/* Keep relevant variables */
	keep nacerev11 nacerev2 descriptionrev2
	
	/* Destring code */
	destring nacerev11 nacerev2, ignore(".") replace force
	
	/* Keep if non-missing */
	keep if nacerev11 != . & nacerev2 != .
	
	/* Rename */
	rename nacerev11 nace_ind
	rename nacerev2 nace2_ind_corr
	
	/* Save */
	save NACE_correspondence, replace
	
	/* Project */
	project, creates("`directory'\Amadeus\NACE_correspondence.dta")

/* AGS correspondence (BBSR; Destatis; manual) */

	/* Import (.csv data from Excel match) */
	import delimited using Counties.csv, delimiter(",") varnames(1) clear
	
	/* Keep relevant variables */
	keep city zipcode match_name agsall
	
	/* Rename */
	rename agsall ags
	rename match_name city_1
	
	/* Save */
	save AGS_correspondence, replace
	
	/* Duplicates */
	sort city_1
	duplicates drop city_1, force
	
	/* Save */
	save AGS_correspondence_1, replace

	/* Project */
	project, creates("`directory'\Amadeus\AGS_correspondence.dta")
	project, creates("`directory'\Amadeus\AGS_correspondence_1.dta")
	
********************************************************************************
**** (3) Converging industry and location definitions						****
********************************************************************************

/* Data */
use AMA_panel, clear

/* Merge: Industry correspondence */
merge m:1 nace_ind using NACE_correspondence
drop if _merge ==2
drop _merge

/* Drop NACE description */
drop description*

/* Generate converged industry */
gen industry = nace2_ind

/* Backfilling (using panel information) */
xtset id vintage
forvalues y = 1(1)11 {
	replace industry = f.industry if industry == . & f.industry != . & vintage == 2016 - `y'
}

/* Filling in missing values (using correspondence table) */
replace industry = nace2_ind_corr if industry == .
drop nace*

/* Mode: Filling in missing values (using mode of industry code per firm) */
egen industry_mode = mode(industry), by(id)
replace industry = industry_mode if industry == .
drop industry_mode

/* Destring zipcode */
destring zipcode, replace force

/* Merge (1): Location correspondence (exact match) */
merge m:1 city zipcode using AGS_correspondence, keepusing(ags)
drop if _merge == 2
drop _merge

/* Merge (2): Location correspondence (name (city) match) */
merge m:1 city using AGS_correspondence, keepusing(ags) update
drop if _merge == 2
drop _merge

/* Merge (3): Location correspondence (name (city_1) match) */
rename city city_1
merge m:1 city_1 using AGS_correspondence_1, keepusing(ags) update
drop if _merge == 2
drop _merge
rename city_1 city

/* Destring AGS */
destring ags, replace force

/* Backfilling (using panel information: backward and forward) */
sort id vintage
duplicates drop id vintage, force
xtset id vintage
forvalues y = 1(1)11 {
	replace ags = f.ags if ags == . & f.ags != . & vintage == 2016 - `y'
}

forvalues y = 1(1)11 {
	replace ags = l.ags if ags == . & l.ags != . & vintage == 2005 + `y'
}

/* Mode: Filling in missing (using AGS by city and vintage) */
egen ags_mode = mode(ags), by(city vintage)
replace ags = ags_mode if ags_mode != .
drop ags_mode

********************************************************************************
**** (4) Cleaning, labeling, and saving										****
********************************************************************************

/* Keep relevant variables */
keep id bvd_id vintage industry ags

/* Keep observations with non-missing industry and location information */
drop if industry == . | ags == .

/* Label variables */
label var id "ID (Numeric)"
label var bvd_id "BvD ID (String)"
label var vintage "Vintage (Year of BvD disc)"
label var industry "NACE 2 (WZ 2008)"
label var ags "AGS (Location identifier)"

/* Save */
save AMA_panel, replace

********************************************************************************
**** (5) Unique																****
********************************************************************************

/* Duplicates drop */
sort bvd_id vintage
duplicates drop bvd_id, force

/* Save */
save AMA_panel_unique, replace

/* Project */
project, creates("`directory'\Amadeus\AMA_panel.dta")
project, creates("`directory'\Amadeus\AMA_panel_unique.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Analysis on county, industry, year level (AMA, URS, GWS)	****
****			[Excerpt]													****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: Data.dta
	Variables:
		- county			County (Kreis)
		- state				State (Bundesland)
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- sales 			Sales (Estimated taxable sales)
		- empl				Employees (1+Employees)
		- hhi				Herfindahl-Hirschman Index (Concentration)
		- entry_main		Entry (Log count; Main business)
		- entry_sub			Entry (Log count; Subsidiary)
		- exit_main			Exit (Log count; Main business)
		- exit_close 		Exit (Log count; Insolvency) 
		- coverage 			Coverage (Actual) (ratio of number of firms in AMA over number of firms in URS in same county-industry-year)
		- limited_share 	Share of limited firms among all firms (limited + unlimited; pre-period)
		- s_firms			Median split (number of firms, pre-period)
		- county_id 		County ID (numeric)
		- ci 				County-Industry ID (numeric)
		- cy 				County-Year ID (numeric)	
		- state_id 			State ID (numeric)
		- si 				State-Industry ID (numeric)
		- sy 				State-Year ID (numeric)
		- iy 				Industry-Year ID (numeric)	
		- post				Post (indicator taking value of 1 for years after 2007)
		- y_2003			Year 2003
		- y_2004			Year 2004
		- y_2005			Year 2005
		- y_2006			Year 2006
		- y_2007			Year 2007
		- y_2008			Year 2008
		- y_2009			Year 2009
		- y_2010			Year 2010
		- y_2011			Year 2011
		- y_2012			Year 2012		
		- trend				Linear time trend
	
Comment:
This program runs multivariate analyses using county-industry-year observations.
*/

**** Preliminaries ****
version 15.1
clear all
set more off
set varabbrev off

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Data.dta")

********************************************************************************
**** (1) Preparing data														****
********************************************************************************

/* Data (URS) */ 
use Data, clear

/* Duplicates drop */
duplicates drop county industry year, force

/* Sample period */
keep if year >= 2003 & year <= 2012

/* Panel */
xtset ci year
	
********************************************************************************
**** (2) Regressions: County-industry-year analyses							****
********************************************************************************

/* Panel: county-industry year */
xtset ci year

/* Log file: open */
cd "`directory'\Output\Logs"
log using Enforcement.smcl, replace smcl name(Enforcement) 

/* Regression inputs (treatment: lagged by two years (see AMA_coverage.do)) */
local DepVar = "coverage entry_main exit_main hhi"
local IndVar = "limited_share"

/* OLS Regression: county-industry + county-year + industry-year fixed effects with instrument */
foreach x of varlist `IndVar' {
	foreach y of varlist `DepVar' {

		/* Preserve */
		preserve
					
			/* Capture */
			capture noisily {
			
				/* Truncation */
				
					/* Outcome */
					qui reghdfe `y' if `x' != ., a(ci cy iy) residuals(res_`y')

					/* Treatment */
					qui reghdfe `x' if `y' != ., a(ci cy iy) residuals(res_`x')
					
					/* Replace */
					qui sum res_`y', d
					qui replace `y' = . if res_`y' > r(p99) | res_`y' < r(p1)
					
					qui sum res_`x', d
					qui replace `x' = . if res_`x' > r(p99) | res_`x' < r(p1)					
						
				/* Estimation */
				qui reghdfe `y' `x' c.`x'#1.y_2003 c.`x'#1.y_2004 c.`x'#1.y_2005 c.`x'#1.y_2007 c.`x'#1.y_2008 c.`x'#1.y_2009 c.`x'#1.y_2010 c.`x'#1.y_2011 c.`x'#1.y_2012, a(ci cy iy) cluster(county_id)
				
				/* Output */
				estout, keep(1.y_2003#c.`x' 1.y_2004#c.`x' 1.y_2005#c.`x' 1.y_2007#c.`x' 1.y_2008#c.`x' 1.y_2009#c.`x' 1.y_2010#c.`x' 1.y_2011#c.`x' 1.y_2012#c.`x') cells(b(star fmt(3)) t(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
					legend label title("SPECIFICATION: COUNTY-INDUSTRY, COUNTY-YEAR, INDUSTRY-YEAR FE WITH INSTRUMENT (Base: 2006; OLS)") ///
					mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
					stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "# Clusters" "Adjusted R-Squared"))
					
				/* Joint test */
				qui test (1.y_2003#c.`x'+1.y_2004#c.`x'+1.y_2005#c.`x')=(1.y_2007#c.`x'+1.y_2008#c.`x'+1.y_2009#c.`x'+1.y_2010#c.`x'+1.y_2011#c.`x'+1.y_2012#c.`x')
				di "Joint F-test (pre- vs. post-period): F " round(`r(F)', 0.01) ", p " round(`r(p)', 0.001)	
			}
						
		/* Restore */
		restore	
	}
}

********************************************************************************
**** (3) Cross-Section: County-industry-year analyses						****
********************************************************************************

/* Regression inputs */
local DepVar = "entry_sub exit_close hhi"
local IndVar = "limited_share"
local SplVar = "s_firms"

/* Split */
foreach s of varlist `SplVar' { 

	/* Generate split variable */
	egen median = median(`s')	
				
	/* Regression: county-industry + county-year + industry-year fixed effects */
	foreach x of varlist `IndVar' {
		foreach y of varlist `DepVar' {
			
			/* Preserve */
			preserve

				/* Capture */
				capture noisily {
				
					/* Truncation */
					
						/* Outcome */
						qui reghdfe `y' if `x' != ., a(ci cy iy) residuals(res_`y')

						/* Treatment */
						qui reghdfe `x' if `y' != ., a(ci cy iy) residuals(res_`x')
						
						/* Replace */
						qui sum res_`y', d
						qui replace `y' = . if res_`y' > r(p99) | res_`y' < r(p1)
						
						qui sum res_`x', d
						qui replace `x' = . if res_`x' > r(p99) | res_`x' < r(p1)					
							
					/* Estimation */
					qui reghdfe `y' `x' c.`x'#1.y_2003 c.`x'#1.y_2004 c.`x'#1.y_2005 c.`x'#1.y_2007 c.`x'#1.y_2008 c.`x'#1.y_2009 c.`x'#1.y_2010 c.`x'#1.y_2011 c.`x'#1.y_2012 if `s' >= median & `s' != ., a(ci cy iy) cluster(county_id)
						est store M1
						
					qui reghdfe `y' `x' c.`x'#1.y_2003 c.`x'#1.y_2004 c.`x'#1.y_2005 c.`x'#1.y_2007 c.`x'#1.y_2008 c.`x'#1.y_2009 c.`x'#1.y_2010 c.`x'#1.y_2011 c.`x'#1.y_2012 if `s' < median & `s' != ., a(ci cy iy) cluster(county_id)
						est store M2
						
					/* Output */
					estout M1 M2, keep(1.y_2003#c.`x' 1.y_2004#c.`x' 1.y_2005#c.`x' 1.y_2007#c.`x' 1.y_2008#c.`x' 1.y_2009#c.`x' 1.y_2010#c.`x' 1.y_2011#c.`x' 1.y_2012#c.`x') cells(b(star fmt(3)) t(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label title("SPECIFICATION: COUNTY-INDUSTRY, COUNTY-YEAR, INDUSTRY-YEAR FE WITH INSTRUMENT (Base: 2006)" "SPLIT: `s'") ///
						mgroups("High" "Low", pattern(0 1)) mlabels(, depvars) varwidth(40) modelwidth(22) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "# Clusters" "Adjusted R-Squared"))						
			}
						
			/* Restore */
			restore				
		}
	}
	
	/* Drop */
	drop median
	
}

/* Log file: close */
log close Enforcement
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Combining outcome (URS, GWS) and coverage (AMA) data 		****
****			[Excerpt]													****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: URS_outcome.dta
	Variables:
		- county			County (Kreis)
		- state				State (Bundesland)
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- sales 			Sales (Estimated taxable sales)
		- empl				Employees (1+Employees)
		- limited_fraction 	Fraction of limited firms in all firms
		- no_firms_URS 		Number of firms (URS)
		- hhi				Herfindahl-Hirschman Index (Concentration)
		
	Data file: GWS_outcome.dta
	Variables:
		- county			County (Kreis)
		- state				State (Bundesland)
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- entry_main 		Entry (Log count; Main business)
		- entry_sub			Entry (Log count; Subsidiary)
		- exit_main			Exit (Log count; Main business)
		- exit_close 		Exit (Log count; Insolvency) 
		
	Data file: AMA_coverage.dta
	Variables:
		- county			County (Kreis)
		- industry			Industry (2-Digit NACE/WZ 2008)
		- year				Fiscal Year
		- no_firms			Number of firms with non-missing total assets in Bureau van Dijk's Amadeus (AMA) database 
		
Newly created variables (kept):
		- coverage 			Coverage (Actual) (ratio of number of firms in AMA over number of firms in URS in same county-industry-year)
		- limited_share 	Share of limited firms among all firms (limited + unlimited; pre-period)
		- county_id 		County ID (numeric)
		- ci 				County-Industry ID (numeric)
		- cy 				County-Year ID (numeric)	
		- state_id 			State ID (numeric)
		- si 				State-Industry ID (numeric)
		- sy 				State-Year ID (numeric)
		- iy 				Industry-Year ID (numeric)	
		- post				Post (indicator taking value of 1 for years after 2007)	
		- y_2003			Year 2003
		- y_2004			Year 2004
		- y_2005			Year 2005
		- y_2006			Year 2006
		- y_2007			Year 2007
		- y_2008			Year 2008
		- y_2009			Year 2009
		- y_2010			Year 2010
		- y_2011			Year 2011
		- y_2012			Year 2012

Note:
		- suffix: lim		Uses limited liability firms only
		- suffix: unl		Uses unlimited liability firms only	
	
Comment:
This program merges the county-industry-year level outcomes (from URS and GWS) with the corresponding first-stage outcome (from AMA).
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, uses("`directory'\Data\URS_outcomes.dta")
project, uses("`directory'\Data\GWS_outcomes.dta")
project, original("`directory'\Data\AMA_coverage.dta") // not recreated at Destatis

********************************************************************************
**** (1) Combining datasets (AMA, URS, GWS)									****
********************************************************************************

/* Data (URS) */
use URS_outcomes, clear

/* Merge: GWS outcomes */
merge 1:1 county industry year using GWS_outcomes
drop _merge

/* Merge: AMA coverage */
merge 1:1 county industry year using AMA_coverage, keepusing(no_firms)
keep if _merge == 3
drop _merge

********************************************************************************
**** (2) Generating relevant variables										****
********************************************************************************
		
/* Coverage measures */

	/* Actual coverage */
	gen coverage = min(no_firms/no_firms_URS, 1) if no_firms != . & no_firms_URS != .
	replace coverage = 0 if no_firms == . & no_firms_URS != .
	label var coverage "Coverage (Actual)"

/* Treatment (limited share) */

	/* Limited vs. unlimited firms */
	gen pre = limited_fraction if year == 2006
	egen limited_share = mean(pre), by(county industry)
	label var limited_share "Share of limited firms among all firms (limited + unlimited; pre-period)"
	drop pre
		
/* Identifiers */

	/* Drop missing county, industry, year */
	drop if county == "" | industry == . | year == .
	
	/* County */
	egen county_id = group(county)
	label var county_id "County ID"

	/* Country-industry */
	egen ci = group(county industry)
	label var ci "County-Industry ID"
	
	/* County-year */
	egen cy = group(county year)
	label var cy "County-Year ID"	

	/* State */
	egen state_id = group(state)
	label var state_id "State ID"
	
	/* State-industry */
	egen si = group(state industry)
	label var si "State-Industry ID"
	
	/* State-year */
	egen sy = group(state year)
	label var sy "State-Year ID"
	
	/* Industry-year */
	egen iy = group(industry year)
	label var iy "Industry-Year ID"	
	
	/* Individual years */
	forvalues y = 2003(1)2012 {
		gen y_`y' = (year == `y')
		label var y_`y' "`y'"
	}

	/* Trend */
	gen trend = (year - 2003)
	label var trend "Trend"

********************************************************************************
**** (3) Saving combined dataset											****
********************************************************************************

/* Save */
save Data, replace

/* Project */
project, creates("`directory'\Data\Data.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Installs external (user-written) programs					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

********************************************************************************
**** (1) Install external programs											****
********************************************************************************

**** Estout ****
ssc install estout, replace

**** Coefplot ****
ssc install coefplot, replace

**** Outreg2 ****
ssc install outreg2, replace

**** Reghdfe ****
ssc install reghdfe, replace
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Graphs [hard-coded; created based on FDZ regression output]	****													
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set varabbrev off

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Output\Figures"

/* Observations */
set obs 10

/* Years */
gen year = 2002 + _n

********************************************************************************
**** Figure 4 Panel A: PUBLIC DISCLOSURE ENFORCEMENT AND ENTRY				****
********************************************************************************

/* Reduced Form: Limited share on entry */

	/* Results */

		/* Coefficients */
		
			/* Aggregate */
			gen b_entry = 0.005 if _n == 1
			replace b_entry = -0.080 if _n == 2
			replace b_entry = -0.053 if _n == 3
			replace b_entry = 0 if _n == 4
			replace b_entry = -0.029 if _n == 5
			replace b_entry = 0.067 if _n == 6
			replace b_entry = 0.160 if _n == 7
			replace b_entry = 0.153 if _n == 8
			replace b_entry = 0.167 if _n == 9
			replace b_entry = 0.150 if _n == 10	
		
		/* Standard errors */
		
			/* Aggregate */
			gen t_entry = 0.11 if _n == 1
			replace t_entry = -1.80 if _n == 2	
			replace t_entry = -1.18 if _n == 3
			replace t_entry = 0 if _n == 4
			replace t_entry = -0.64 if _n == 5
			replace t_entry = 1.54 if _n == 6
			replace t_entry = 3.45 if _n == 7
			replace t_entry = 3.37 if _n == 8
			replace t_entry = 3.70 if _n == 9
			replace t_entry = 3.16 if _n == 10
			gen se_entry = 1/(t_entry/b_entry)
			replace se_entry = 0 if _n == 4

		/* Confidence interval */
		gen ci_entry_low = b_entry - 1.96*se_entry
		gen ci_entry_high = b_entry + 1.96*se_entry
		
	/* Graph: Limited share on entry */
	graph twoway ///
		(rarea ci_entry_high ci_entry_low year, color(gs13)) ///
		(scatter b_entry year, msymbol(o) color(black)) ///		
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Entry") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" "AND ENTRY", color(black)) ///
			saving(Figure_4_Panel_A, replace)

********************************************************************************
**** Figure 4 Panel B: PUBLIC DISCLOSURE ENFORCEMENT AND EXIT				****
********************************************************************************

/* Reduced Form: Limited share on exit */

	/* Results */

		/* Coefficients */
		
			/* Aggregate */
			gen b_exit = -0.012 if _n == 1
			replace b_exit = 0.003 if _n == 2
			replace b_exit = -0.039 if _n == 3
			replace b_exit = 0 if _n == 4
			replace b_exit = -0.072 if _n == 5
			replace b_exit = 0.081 if _n == 6
			replace b_exit = 0.065 if _n == 7
			replace b_exit = 0.099 if _n == 8
			replace b_exit = 0.049 if _n == 9
			replace b_exit = 0.094 if _n == 10	
		
		/* Standard errors */
		
			/* Aggregate */
			gen t_exit = -0.28 if _n == 1
			replace t_exit = 0.07 if _n == 2	
			replace t_exit = -0.88 if _n == 3
			replace t_exit = 0 if _n == 4
			replace t_exit = -1.51 if _n == 5
			replace t_exit = 1.84 if _n == 6
			replace t_exit = 1.44 if _n == 7
			replace t_exit = 2.18 if _n == 8
			replace t_exit = 1.08 if _n == 9
			replace t_exit = 2.09 if _n == 10
			gen se_exit = 1/(t_exit/b_exit)
			replace se_exit = 0 if _n == 4

		/* Confidence interval */
		gen ci_exit_low = b_exit - 1.96*se_exit
		gen ci_exit_high = b_exit + 1.96*se_exit
		
	/* Graph: Limited share on exit */
	graph twoway ///
		(rarea ci_exit_high ci_exit_low year, color(gs13)) ///
		(scatter b_exit year, msymbol(o) color(black)) ///		
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Exit") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" "AND EXIT", color(black)) ///
			saving(Figure_4_Panel_B, replace)

********************************************************************************
**** Figure 4 Panel C: PUBLIC DISCLOSURE ENFORCEMENT AND CONCENTRATION		****
********************************************************************************

/* Reduced Form: Limited share on concentration */

	/* Results */

		/* Coefficients */
		
			/* Aggregate */
			gen b_hhi = -0.003 if _n == 1
			replace b_hhi = 0.006 if _n == 2
			replace b_hhi = 0.003 if _n == 3
			replace b_hhi = 0 if _n == 4
			replace b_hhi = -0.009 if _n == 5
			replace b_hhi = -0.015 if _n == 6
			replace b_hhi = -0.013 if _n == 7
			replace b_hhi = -0.016 if _n == 8
			replace b_hhi = -0.019 if _n == 9
			replace b_hhi = -0.017 if _n == 10	
		
		/* Standard errors */
		
			/* Aggregate */
			gen t_hhi = -0.37 if _n == 1
			replace t_hhi = 0.79 if _n == 2	
			replace t_hhi = 0.50 if _n == 3
			replace t_hhi = 0 if _n == 4
			replace t_hhi = -1.59 if _n == 5
			replace t_hhi = -2.00 if _n == 6
			replace t_hhi = -1.38 if _n == 7
			replace t_hhi = -1.74 if _n == 8
			replace t_hhi = -2.05 if _n == 9
			replace t_hhi = -1.98 if _n == 10
			gen se_hhi = 1/(t_hhi/b_hhi)
			replace se_hhi = 0 if _n == 4

		/* Confidence interval */
		gen ci_hhi_low = b_hhi - 1.96*se_hhi
		gen ci_hhi_high = b_hhi + 1.96*se_hhi
		
	/* Graph: Limited share on concentration */
	graph twoway ///
		(rarea ci_hhi_high ci_hhi_low year, color(gs13)) ///
		(scatter b_hhi year, msymbol(o) color(black)) ///		
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.06(0.02)0.06, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("HHI") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" "AND PRODUCT MARKET CONCENTRATION", color(black)) ///
			saving(Figure_4_Panel_C, replace)

********************************************************************************
**** Figure A1: PUBLIC DISCLOSURE ENFORCEMENT AND DISCLOSURE RATE			****
********************************************************************************

/* First Stage: Limited share on disclosure rate */

	/* Results */

		/* Coefficients */
		gen b_lshare = -0.071 if _n == 1
		replace b_lshare = -0.064 if _n == 2
		replace b_lshare = -0.026 if _n == 3
		replace b_lshare = 0 if _n == 4
		replace b_lshare = 0.26 if _n == 5
		replace b_lshare = 0.293 if _n == 6
		replace b_lshare = 0.275 if _n == 7
		replace b_lshare = 0.260 if _n == 8
		replace b_lshare = 0.250 if _n == 9
		replace b_lshare = 0.235 if _n == 10
		
		/* Standard errors */
		gen t_lshare = -9.04 if _n == 1
		replace t_lshare = -8.35 if _n == 2	
		replace t_lshare = -4.53 if _n == 3
		replace t_lshare = 0 if _n == 4
		replace t_lshare = 21.69 if _n == 5
		replace t_lshare = 27.32 if _n == 6
		replace t_lshare = 24.55 if _n == 7
		replace t_lshare = 21.91 if _n == 8
		replace t_lshare = 22.96 if _n == 9
		replace t_lshare = 22.40 if _n == 10
		gen se_lshare = 1/(t_lshare/b_lshare)
		replace se_lshare = 0 if _n == 4
				
		/* Confidence interval */
		gen ci_lshare_low = b_lshare - 1.96*se_lshare
		gen ci_lshare_high = b_lshare + 1.96*se_lshare
		
	/* Graph: Limited share on disclosure rate */
	graph twoway ///
		(rarea ci_lshare_high ci_lshare_low year, color(gs13)) ///
		(scatter b_lshare year, msymbol(o) color(black)) ///
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.1(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///
			xtitle("Year") ///
			ytitle("Disclosure rate") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" " AND DISCLOSURE RATE", color(black)) ///
			name(Figure_A1, replace)

********************************************************************************
**** Figure A2: PUBLIC DISCLOSURE ENFORCEMENT AND ENTRY OF SUBSIDIARIES		****
********************************************************************************

/* Reduced Form: Limited share on entry */

	/* Results */

		/* Coefficients */
		
			/* High */
			gen b_entry_h = -0.115 if _n == 1
			replace b_entry_h = -0.221 if _n == 2
			replace b_entry_h = -0.139 if _n == 3
			replace b_entry_h = 0 if _n == 4
			replace b_entry_h = 0.085 if _n == 5
			replace b_entry_h = -0.014 if _n == 6
			replace b_entry_h = 0.059 if _n == 7
			replace b_entry_h = -0.017 if _n == 8
			replace b_entry_h = -0.178 if _n == 9
			replace b_entry_h = -0.096 if _n == 10	
	
			/* Low */
			gen b_entry_l = 0.039 if _n == 1
			replace b_entry_l = 0.042 if _n == 2
			replace b_entry_l = -0.060 if _n == 3
			replace b_entry_l = 0 if _n == 4
			replace b_entry_l = 0.096 if _n == 5
			replace b_entry_l = 0.152 if _n == 6
			replace b_entry_l = 0.089 if _n == 7
			replace b_entry_l = 0.179 if _n == 8
			replace b_entry_l = 0.122 if _n == 9
			replace b_entry_l = 0.142 if _n == 10	
			
		/* Standard errors */
		
			/* High */
			gen t_entry_h = -1.15 if _n == 1
			replace t_entry_h = -2.24 if _n == 2	
			replace t_entry_h = -1.31 if _n == 3
			replace t_entry_h = 0 if _n == 4
			replace t_entry_h = 0.86 if _n == 5
			replace t_entry_h = -0.15 if _n == 6
			replace t_entry_h = 0.61 if _n == 7
			replace t_entry_h = -0.18 if _n == 8
			replace t_entry_h = -1.91 if _n == 9
			replace t_entry_h = -0.98 if _n == 10
			gen se_entry_h = 1/(t_entry_h/b_entry_h)
			replace se_entry_h = 0 if _n == 4

			/* Low */
			gen t_entry_l = 0.79 if _n == 1
			replace t_entry_l = 0.82 if _n == 2	
			replace t_entry_l = -1.22 if _n == 3
			replace t_entry_l = 0 if _n == 4
			replace t_entry_l = 1.92 if _n == 5
			replace t_entry_l = 3.29 if _n == 6
			replace t_entry_l = 1.89 if _n == 7
			replace t_entry_l = 3.68 if _n == 8
			replace t_entry_l = 2.48 if _n == 9
			replace t_entry_l = 2.88 if _n == 10
			gen se_entry_l = 1/(t_entry_l/b_entry_l)
			replace se_entry_l = 0 if _n == 4
			
		/* Confidence interval */
		gen ci_entry_h_low = b_entry_h - 1.96*se_entry_h
		gen ci_entry_h_high = b_entry_h + 1.96*se_entry_h

		gen ci_entry_l_low = b_entry_l - 1.96*se_entry_l
		gen ci_entry_l_high = b_entry_l + 1.96*se_entry_l
		
	/* Graph: Limited share on entry */
	graph twoway ///
		(rarea ci_entry_h_high ci_entry_h_low year, color(gs13)) ///
		(scatter b_entry_h year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Entry of subsidiaries") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("HIGH" "(NUMBER OF FIRMS)", color(black)) ///
			name(Entry_h, replace)	
	
	graph twoway ///
		(rarea ci_entry_l_high ci_entry_l_low year, color(gs13)) ///
		(scatter b_entry_l year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Entry of subsidiaries") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("LOW" "(NUMBER OF FIRMS)", color(black)) ///
			name(Entry_l, replace)		
			
	graph combine Entry_h Entry_l, ///
		altshrink cols(2) ysize(4) xsize(10) ///
		title("PUBLIC DISCLOSURE ENFORCEMENT" "AND ENTRY OF SUBSIDIARIES", color(black)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		saving(Figure_A2, replace)		

********************************************************************************
**** Figure A3: PUBLIC DISCLOSURE ENFORCEMENT AND EXIT DUE TO 				****
**** 			UNPROFITABILITY												****
********************************************************************************
		
/* Reduced Form: Limited share on exit */

	/* Results */

		/* Coefficients */
		
			/* High */
			gen b_exit_h = -0.049 if _n == 1
			replace b_exit_h = -0.052 if _n == 2
			replace b_exit_h = -0.098 if _n == 3
			replace b_exit_h = 0 if _n == 4
			replace b_exit_h = -0.127 if _n == 5
			replace b_exit_h = -0.009 if _n == 6
			replace b_exit_h = -0.029 if _n == 7
			replace b_exit_h = 0.074 if _n == 8
			replace b_exit_h = -0.188 if _n == 9
			replace b_exit_h = -0.131 if _n == 10	
	
			/* Low */
			gen b_exit_l = 0.002 if _n == 1
			replace b_exit_l = -0.002 if _n == 2
			replace b_exit_l = -0.016 if _n == 3
			replace b_exit_l = 0 if _n == 4
			replace b_exit_l = -0.074 if _n == 5
			replace b_exit_l = 0.084 if _n == 6
			replace b_exit_l = 0.086 if _n == 7
			replace b_exit_l = 0.108 if _n == 8
			replace b_exit_l = 0.049 if _n == 9
			replace b_exit_l = 0.087 if _n == 10	
			
		/* Standard errors */
		
			/* High */
			gen t_exit_h = -0.53 if _n == 1
			replace t_exit_h = -0.55 if _n == 2	
			replace t_exit_h = -1.07 if _n == 3
			replace t_exit_h = 0 if _n == 4
			replace t_exit_h = -1.31 if _n == 5
			replace t_exit_h = -0.10 if _n == 6
			replace t_exit_h = -0.36 if _n == 7
			replace t_exit_h = 0.86 if _n == 8
			replace t_exit_h = -2.04 if _n == 9
			replace t_exit_h = -1.45 if _n == 10
			gen se_exit_h = 1/(t_exit_h/b_exit_h)
			replace se_exit_h = 0 if _n == 4

			/* Low */
			gen t_exit_l = 0.04 if _n == 1
			replace t_exit_l = -0.04 if _n == 2	
			replace t_exit_l = -0.37 if _n == 3
			replace t_exit_l = 0 if _n == 4
			replace t_exit_l = -1.92 if _n == 5
			replace t_exit_l = 2.07 if _n == 6
			replace t_exit_l = 2.17 if _n == 7
			replace t_exit_l = 2.57 if _n == 8
			replace t_exit_l = 1.27 if _n == 9
			replace t_exit_l = 2.21 if _n == 10
			gen se_exit_l = 1/(t_exit_l/b_exit_l)
			replace se_exit_l = 0 if _n == 4
			
		/* Confidence interval */
		gen ci_exit_h_low = b_exit_h - 1.96*se_exit_h
		gen ci_exit_h_high = b_exit_h + 1.96*se_exit_h

		gen ci_exit_l_low = b_exit_l - 1.96*se_exit_l
		gen ci_exit_l_high = b_exit_l + 1.96*se_exit_l
		
	/* Graph: Limited share on exit */
	graph twoway ///
		(rarea ci_exit_h_high ci_exit_h_low year, color(gs13)) ///
		(scatter b_exit_h year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Exit due to unprofitability") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("HIGH" "(NUMBER OF FIRMS)", color(black)) ///
			name(Exit_h, replace)	
	
	graph twoway ///
		(rarea ci_exit_l_high ci_exit_l_low year, color(gs13)) ///
		(scatter b_exit_l year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Exit due to unprofitability") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("LOW" "(NUMBER OF FIRMS)", color(black)) ///
			name(Exit_l, replace)		
			
	graph combine Exit_h Exit_l, ///
		altshrink cols(2) ysize(4) xsize(10) ///
		title("PUBLIC DISCLOSURE ENFORCEMENT" "AND EXIT DUE TO UNPROFITABILITY", color(black)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		saving(Figure_A3, replace)	

********************************************************************************
**** Figure A4: PUBLIC DISCLOSURE ENFORCEMENT AND CONCENTRATION				****
********************************************************************************
		
/* Reduced Form: Limited share on concentration */

	/* Results */

		/* Coefficients */
		
			/* High */
			gen b_hhi_h = -0.008 if _n == 1
			replace b_hhi_h = -0.018 if _n == 2
			replace b_hhi_h = -0.007 if _n == 3
			replace b_hhi_h = 0 if _n == 4
			replace b_hhi_h = -0.001 if _n == 5
			replace b_hhi_h = -0.009 if _n == 6
			replace b_hhi_h = -0.005 if _n == 7
			replace b_hhi_h = 0.002 if _n == 8
			replace b_hhi_h = -0.002 if _n == 9
			replace b_hhi_h = 0.005 if _n == 10	
	
			/* Low */
			gen b_hhi_l = 0.002 if _n == 1
			replace b_hhi_l = 0.011 if _n == 2
			replace b_hhi_l = 0.005 if _n == 3
			replace b_hhi_l = 0 if _n == 4
			replace b_hhi_l = -0.012 if _n == 5
			replace b_hhi_l = -0.018 if _n == 6
			replace b_hhi_l = -0.015 if _n == 7
			replace b_hhi_l = -0.019 if _n == 8
			replace b_hhi_l = -0.020 if _n == 9
			replace b_hhi_l = -0.019 if _n == 10	
			
		/* Standard errors */
		
			/* High */
			gen t_hhi_h = -0.60 if _n == 1
			replace t_hhi_h = -1.44 if _n == 2	
			replace t_hhi_h = -0.73 if _n == 3
			replace t_hhi_h = 0 if _n == 4
			replace t_hhi_h = -0.08 if _n == 5
			replace t_hhi_h = -0.69 if _n == 6
			replace t_hhi_h = -0.33 if _n == 7
			replace t_hhi_h = 0.13 if _n == 8
			replace t_hhi_h = -0.13 if _n == 9
			replace t_hhi_h = 0.35 if _n == 10
			gen se_hhi_h = 1/(t_hhi_h/b_hhi_h)
			replace se_hhi_h = 0 if _n == 4

			/* Low */
			gen t_hhi_l = 0.18 if _n == 1
			replace t_hhi_l = 1.31 if _n == 2	
			replace t_hhi_l = 0.76 if _n == 3
			replace t_hhi_l = 0 if _n == 4
			replace t_hhi_l = -1.70 if _n == 5
			replace t_hhi_l = -1.99 if _n == 6
			replace t_hhi_l = -1.38 if _n == 7
			replace t_hhi_l = -1.72 if _n == 8
			replace t_hhi_l = -1.87 if _n == 9
			replace t_hhi_l = -1.87 if _n == 10
			gen se_hhi_l = 1/(t_hhi_l/b_hhi_l)
			replace se_hhi_l = 0 if _n == 4
			
		/* Confidence interval */
		gen ci_hhi_h_low = b_hhi_h - 1.96*se_hhi_h
		gen ci_hhi_h_high = b_hhi_h + 1.96*se_hhi_h

		gen ci_hhi_l_low = b_hhi_l - 1.96*se_hhi_l
		gen ci_hhi_l_high = b_hhi_l + 1.96*se_hhi_l
		
	/* Graph: Limited share on concentration */
	graph twoway ///
		(rarea ci_hhi_h_high ci_hhi_h_low year, color(gs13)) ///
		(scatter b_hhi_h year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.06(0.02)0.06, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("HHI") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("HIGH" "(NUMBER OF FIRMS)", color(black)) ///
			name(HHI_h, replace)	
	
	graph twoway ///
		(rarea ci_hhi_l_high ci_hhi_l_low year, color(gs13)) ///
		(scatter b_hhi_l year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.06(0.02)0.06, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("HHI") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("LOW" "(NUMBER OF FIRMS)", color(black)) ///
			name(HHI_l, replace)		
			
	graph combine HHI_h HHI_l, ///
		altshrink cols(2) ysize(4) xsize(10) ///
		title("PUBLIC DISCLOSURE ENFORCEMENT" "AND PRODUCT MARKET CONCENTRATION", color(black)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		saving(Figure_A4, replace)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Cleaning GWS data [Excerpt]									****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: GWS_panel.dta
	Variables:
		- gwa_jahr			gwa_jahr	
		- of2_2014			Amtlicher Gemeindeschluessel (AGS) der Betriebsstaette (Sitz) zum 31.12.2014
		- ef14				Schluessel der Rechtsform
		- ef81				Taetigkeit (Schwerpunktsangabe)
		- ef85 				Taetigkeit im Nebenerwerb?
		- ef86				Taetigkeit (Schwerpunktsangabe)
		- ef94				Anzahl der Vollzeitbeschaeftigten
		- ef95				Anzahl der Teilzeitbeschaeftigten
		- ef96				Keine Beschaeftigten
		- ef97				Erstattung fuer 1 = Hauptniederlassung; 2 = Zweigniederlassung; 3 = unselbstständige Zweigstelle
		- of1				Art der Meldung
		- ef99u1			Grund der Anmeldung: Neugruendung
		- ef99u2			Grund der Anmeldung: Wiedereroeffnung nach Verlegung aus einem anderen Meldebezirk
		- ef99u3			Grund der Anmeldung: Gruendung nach Umwandlungsgesetz
		- ef99u4			Grund der Anmeldung: Wechsel der Rechtsform
		- ef99u5			Grund der Anmeldung: Gesellschaftereintritt
		- ef99u6			Grund der Anmeldung: Erbfolge/Kauf/Pacht
		- ef100u1			Grund der Abmeldung: Vollstaendige Aufgabe
		- ef100u2			Grund der Abmeldung: Verlegung in einen anderen Meldebezirk
		- ef100u3			Grund der Abmeldung: Aufgabe infolge Umwandlungsgesetz
		- ef100u4			Grund der Abmeldung: Wechsel der Rechtsform
		- ef100u5			Grund der Abmeldung: Gesellschafteraustritt
		- ef100u6			Grund der Abmeldung: Erbfolge/Verkauf/Verpachtung
		- ef102				Ursache der Abmeldung
		- ef124				Grund der Ummeldung

Newly created variables (kept):
		- county 			County (Kreis)
		- state 			State (Bundesland)
		- industry 			Industry (2-Digit; WZ2008 (rev))
		- year 				Year (gwa_jahr)
		- limited 			Limited liability
		- empl 				Employees (incl. founder/owner)
		- main 				Main site
		- register 			Registration (Anmeldung)
		- change 			Change (Umwandlung)
		- deregister 		Deregistration (Abmeldung)
		- register_entry 	Entry (Registration)
		- register_move 	Move (Registration)
		- register_law		Legal split (Registration)
		- register_form		Legal form switch (Registration)
		- register_owner 	Entry of owner (Registration)
		- register_acquisition Acquisition (Registration)
		- deregister_exit 	Exit (Deregistration)
		- deregister_move 	Move (Deregistration)
		- deregister_law 	Legal combination (Deregistration)
		- deregister_form 	Legal form change (Deregistration)
		- deregister_owner 	Exit of owner (Deregistration)
		- deregister_sale 	Sale (Deregistration)
		- exit_close 		Exit (Unprofitable; Insolvency)
		- exit_sale 		Exit (Sale)
		- change_industry 	Industry change

Comment:
This program cleans the GWS panel creating selected variables required in subsequent analyses.
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, original("`directory'\Data\GWS_panel.dta")
project, uses("`directory'\Data\WZ_correspondence.dta")

********************************************************************************
**** (1) Industry correspondence (detailed WZ 2003 to WZ 2008)				****
********************************************************************************

/* Data */
use WZ_correspondence, clear

/* Two-digit industries */
foreach var of varlist wz* {
	replace `var' = floor(`var'/1000)
}

/* Approximation */
egen mode = mode(wz2008), by(wz2003)

gen approx = (mode != wz2008)
egen max = max(approx), by(wz2003)

replace approx = max
drop max mode

/* Duplicates */
duplicates drop wz2003, force

/* Save */
save WZ_correspondence_2, replace

/* Project */
project, creates("`directory'\Data\WZ_correspondence_2.dta")
	
********************************************************************************
**** (2) Variable definition												****
********************************************************************************

/* Data */
use GWS_panel, clear

/* Keep relevant obsevrations & variables */
drop if ef98 == "1" | ef98 == "2" // exclude: Automatenaufsteller und Reisegewerbe
keep gwa_jahr of2_2014 ef14 ef81 ef86 ef85 ef94 ef95 ef96 ef97 of1 ef99u* ef100u* ef102 ef124
	
/* Year */
rename gwa_jahr year

/* County */
gen county = substr(of2_2014, -6, 3)

/* State */
gen state = substr(of2_2014, -8, 2)
drop of2_2014

/* Limited company (incl. GmbH & Co. KG; incl. juristische Personen auslaendischer Rechtsformen (da gebuendelt in 991; verhindert Strukturbruch); excluding special forms (340)) */
gen limited = 0
replace limited = 1 if ///
	ef14 == "230" | ///
	ef14 == "232" | ///
	ef14 == "310" | ///
	ef14 == "320" | ///
	ef14 == "321" | ///
	ef14 == "322" | ///
	ef14 == "330" | ///
	ef14 == "350" | ///
	ef14 == "360" | ///
	(ef14 == "351" & year >= 2007) | ///
	(ef14 == "355" & year >= 2007) | ///
	(ef14 == "356" & year >= 2007) | ///	
	(ef14 == "910" & year < 2007) | ///
	(ef14 == "911" & year >= 2007)| ///
	(ef14 == "993" & year < 2007 & year >= 2005) | ///
	(ef14 == "991" & year < 2005) | ///
	(ef14 == "912" & year >= 2007) | ///
	(ef14 == "994" & year < 2007 & year >= 2005) | ///
	(ef14 == "992" & year >= 2007) | ///
	(ef14 == "996" & year < 2007 & year >= 2005)
drop ef14

/* Industry (WZ2003 or WZ2008) */
destring ef81 ef86, force replace /* FDZ comment: force-Option im FDZ hinzugefuegt, da irrelevante alphanumerische Zeichen vorkommen (vereinzelt)*/
replace ef81 = ef86 if ef81 == .
rename ef81 industry
drop ef86

/* Reclassification to WZ2008 */
gen wz2003 = industry if year < 2008
merge m:1 wz2003 using WZ_correspondence_2
drop if _merge == 2
drop _merge

replace industry = wz2008 if year < 2008
egen max = max(approx), by(industry)
replace approx = max
drop max wz2003 wz2008

drop if industry == 98 // only defined in WZ2008

/* Employees (Part-time employees: 1/2 FTE; Founder/Owner/Manager: 1 FTE; PT Founder/Owner/Manager: 1/2 FTE) */
destring ef85 ef96, replace /* FDZ comment: ef94 und ef95 liegen schon im Zahlenformat vor, daher im FDZ aus dieser Liste entfernt */
gen empl = 1 if ef96 == 1
replace empl = 0.5 if ef96 == 0 & ef85 == 1
replace empl = 1 + ef94 + ef95 if empl == . & ef94 != . & ef95 != .
replace empl = 1 + ef94 if empl == . & ef94 != . & ef95 == .
replace empl = 1 + ef95 if empl == . & ef94 == . & ef95 != .
drop ef85 ef94 ef95 ef96

/* Main site */
destring ef97, replace
gen main = (ef97 == 1) if ef97 != .
drop ef97

/* Register, change, deregister */
destring of1, replace
gen register = (of1 == 1) if of1 != .
gen change = (of1 == 2) if of1 != .
gen deregister = (of1 == 3) if of1 != .
drop of1

/* Registration: type */ 
destring ef99u*, replace
gen register_entry = (ef99u1 == 1) if ef99u1 != .
gen register_move = (ef99u2 == 1) if ef99u2 != .
gen register_law = (ef99u3 == 1) if ef99u3 != .
gen register_form = (ef99u4 == 1) if ef99u4 != .
gen register_owner = (ef99u5 == 1) if ef99u5 != .
gen register_sale = (ef99u6 == 1) if ef99u6 != .
drop ef99u*

/* Deregistration: type */
destring ef100u*, replace
gen deregister_exit = (ef100u1 == 1) if ef100u1 != .
gen deregister_move = (ef100u2 == 1) if ef100u2 != .
gen deregister_law = (ef100u3 == 1) if ef100u3 != .
gen deregister_form = (ef100u4 == 1) if ef100u4 != .
gen deregister_owner = (ef100u5 == 1) if ef100u5 != .
gen deregister_sale = (ef100u6 == 1) if ef100u6 != .
drop ef100u*

/* Deregistration: reason */
destring ef102, replace
gen exit_close = (ef102 == 11 | ef102 == 12)
gen exit_sale = (ef102 == 17)
drop ef102

********************************************************************************
**** (3) Labeling and saving												****
********************************************************************************

/* Labeling */
label var county "County"
label var state "State"
label var industry "Industry (2-Digit; WZ2008)"
label var year "Year"
label var limited "Limited liability"
label var empl "Employees (incl. founder/owner)"
label var main "Main site"
label var register "Registration"
label var change "Change"
label var deregister "Deregistration"
label var register_entry "Entry (Registration)"
label var register_move "Move (Registration)"
label var register_law "Legal split (Registration)"
label var register_form "Legal form switch (Registration)"
label var register_owner "Entry of owner (Registration)"
label var register_sale "Acquisition (Registration)"
label var deregister_exit "Exit (Deregistration)"
label var deregister_move "Move (Deregistration)"
label var deregister_law "Legal combination (Deregistration)"
label var deregister_form "Legal form change (Deregistration)"
label var deregister_owner "Exit of owner (Deregistration)"
label var deregister_sale "Sale (Deregistration)"
label var exit_close "Exit (Unprofitable; Insolvency)"
label var exit_sale "Exit (Sale)"

/* Save */
save GWS_data, replace

/* Project */
project, creates("`directory'\Data\GWS_data.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Aggregate outcomes from GWS	[Excerpt]						****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: GWS_data.dta
	Variables:
		- county 			County (Kreis)
		- state 			State (Bundesland)
		- industry 			Industry (2-Digit; WZ2008 (rev))
		- year 				Year (gwa_jahr)
		- limited 			Limited liability
		- empl 				Employees (incl. founder/owner)
		- register_entry 	Entry (Registration)
		- register_form		Entry (Legal form change)
		- register_owner 	Entry (Owner entry)
		- register_sale 	Entry (Acquisition)		
		- deregister_exit 	Exit (Deregistration)
		- deregister_form	Exit (Legal form change)
		- deregister_sale	Exit (Sale)
		- exit_close 		Exit (Unprofitable; Insolvency)
		
Newly created variables (kept):
		- entry_main		Entry (Log count; Main business)
		- entry_sub			Entry (Log count; Subsidiary)
		- exit_main			Exit (Log count; Main business)
		- exit_close 		Exit (Log count; Insolvency) 
		
Comment:
This program calculates county-industry-year level aggregates of firm entry and exit.
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, uses("`directory'\Data\GWS_data.dta")

********************************************************************************
**** (1) Aggregate outcomes													****
********************************************************************************

/* Data */
use GWS_data, clear

/* Aggregate outcomes */
  
	/* Count */
	local variables = "register_entry deregister_exit exit_close"
	foreach var of varlist `variables' {
		
		/* County-industry level */
		egen t_`var' = total(`var'), by(county industry year) missing
		
		/* County-industry level: Main vs. subsidiary */
		egen t_`var'_main = total(`var'*main), by(county industry year) missing
		gen t_`var'_sub = t_`var' - t_`var'_main	

		/* Drop */
		drop `var'
	}

********************************************************************************
**** (2) Entry and exit measures											****
********************************************************************************

/* Keep */
keep county state industry year t_*

/* Duplicates */
duplicates drop county industry year, force	
	
	/* Entry */
	
		/* Main */
		gen entry_main = ln(1+t_register_entry_main)
		label var entry_main "Entry (Log; Main)"

		/* Subsidiary */
		gen entry_sub = ln(1+t_register_entry_sub)
		label var entry_sub "Entry (Log; Subsidiary)"			
			
	/* Exit */
	
		/* True exit */			
		gen exit_close = ln(1+t_exit_close)
		label var exit_close "Exit (Insolvency; Log)"
		
		/* Main */
		gen exit_main = ln(1+t_deregister_exit_main)
		label var exit_main "Exit (Log; Main)"

********************************************************************************
**** (3) Cleaning, labeling, saving											****
********************************************************************************		

/* Keep relevant variables */
keep county industry year entry* exit*		

/* Save */
save GWS_outcomes, replace

/* Project */
project, creates("`directory'\Data\GWS_outcomes.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Converging industry	definitions (WZ 2003, 2008) in URS		****
****			[Excerpt]													****
********************************************************************************
/*
Original variables (used/kept): 	

	Data file: Klassifikationenwz2008_umsteiger.csv
	Variables:
		- wz2003			WZ 2003 code
		- wz2008			WZ 2008 code
		
	Data file: URS_panel.dta
	Variables:
		- UNR				systemfreie Unternehmensnummer
		- urs_jahr			Auswertungsjahr des Unternehmensregisters
		- aktiv				Aktive URS-Einheiten (=1) vs. inaktive URS-Einheiten (=0)
		- untern			Unternehmen=1, 0=sonst
		- urs_1ef6			Sitz der Einheit: Amtlicher Gemeindeschluessel
		- urs_1ef16			Zugangsmonat
		- urs_1ef17			Zugangsjahr
		- urs_1ef19			Art der Einheit
		- urs_1ef20			Wirtschaftszweig WZ2003 (fuer 2004-2007) bzw. WZ2008 (fuer 2008 und folgende Jahre)
		- urs_1ef26			Rechtsform
		- urs_5ef16u1		Steuerbarer Umsatz in 1000 EUR
		- urs_5ef16u2		Bezugszeit steuerbarer Umsatz (jjjj)
		- urs_5ef18u1		Sozialversicherungspflichtig Beschaeftigte: Anzahl
		- urs_5ef18u2		Sozialversicherungspflichtig Beschaeftigte: Bezugszeit (jjjj)
		- urs_5ef20u1		Beginn der Steuerpflicht (ttmmjjjj)
		- urs_5ef20u2		Zeitpunkt der Aufnahme der wirtschaftlichen Taetigkeit
		- urs_5ef21u1		Ende der Steuerpflicht (ttmmjjjj)
		- urs_5ef21u2		Zeitpunkt der engueltigen Aufgabe der betrieblichen Taetigkeit 
		- urs_5ef30u1		Schaetzumsatz nach Organschaftschaetzung in 1000 EUR
		- urs_5ef30u2		Bezugszeit Schaetzumsatz (jjjj)
		- GTAG				Gemeindeteilausgliederung gemaess BBSR-AGS-Umsteigern 2014
		- agsunsicher		agsunsicher: 1=gewisse Restunsicherheit in der (manuellen) Umkodierung des AGS
		- urs_1ef6_14		Amtlicher Gemeindeschluessel zum Gebietsstand 31.12.2014

Newly created variables (kept):
		- industry_5 		5-digit industry identifier (WZ 2003 before 2008 and WZ 2008 in and after 2008)
		- county			County identifier (Kreis)
		- state				State identifier (Bundesland)
		- legal_form		Legal form (limited vs. unlimited liability)
		- wz2008_rev		Updated/converged WZ 2008 for entire panel

Comment:
This program generates a firm-year panel with a common legal form definition, county identifiers as of 2014, and industry identifiers using WZ2008 (rev).
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, original("`directory'\Data\Klassifikationenwz2008_umsteiger.csv")
project, original("`directory'\Data\URS_panel.dta")

********************************************************************************
**** (1) Industry correspondence (detailed WZ 2003 to WZ 2008)				****
********************************************************************************

/* Data (WZ Umsteiger) */
import delimited Klassifikationenwz2008_umsteiger.csv, delimiter(",") varnames(nonames) rowrange(3:) clear

	/* Keep relevant variables */
	keep v2 v5

	/* Rename variables */
	rename v2 wz2003
	rename v5 wz2008
	
	/* Destring industry codes */
	destring wz*, replace ignore(".")
	
	/* Duplicates (ambiguous categories) */
	duplicates drop wz2003, force
	
	/* Save */
	save WZ_correspondence, replace
	
	/* Project */
	project, creates("`directory'\Data\WZ_correspondence.dta")
	
********************************************************************************
**** (2) Industry redefinition (URS) 										****
********************************************************************************

/* Data (URS) (Sample restriction: only corporations) */
use URS_panel if untern == 1 & aktiv == 1, clear

/* Make industry 5-digits */
replace urs_1ef20 = urs_1ef20 + "000" if length(urs_1ef20) == 2
replace urs_1ef20 = urs_1ef20 + "00" if length(urs_1ef20) == 3
replace urs_1ef20 = urs_1ef20 + "0" if length(urs_1ef20) == 4

/* Industry match variable */
destring urs_1ef20, gen(industry_5)
gen wz2003 = industry_5 if urs_jahr <= 2007

/* Merge: WZ correspondence */
merge m:1 wz2003 using WZ_correspondence
drop if _merge == 2
drop _merge

/* Panel */
duplicates drop UNR urs_jahr, force
xtset UNR urs_jahr

/* Backfilling legal form (no adjustment for legal form issues before 2005; proportions look fine in sample file) */
destring urs_1ef26, replace force
gen legal_form = urs_1ef26
forvalues y = 1(1)13 {
	replace legal_form = f.urs_1ef26 if (urs_1ef26 == . | urs_1ef26 == 9)  & f.urs_1ef26 != . & urs_jahr == 2014-`y' 
}

/* WZ 2008 (new) */
gen wz2008_rev = industry_5 if urs_jahr >= 2008

/* Backfilling */
forvalues y = 1(1)7 {
	replace wz2008_rev = f.wz2008_rev if wz2008_rev == . & f.wz2008_rev != . & urs_jahr == 2008-`y' 
}

/* WZ correspondence */
replace wz2008_rev = wz2008 if wz2008_rev == .

/* Drop */
drop untern aktiv

/* Save */
save URS_data, replace

********************************************************************************
**** (3) Panel information for industry redefinition (URS) 					****
********************************************************************************
	
/* Relevant variables */
keep wz2003 wz2008_rev
	
/* Mode */
egen wz2008_corr = mode(wz2008_rev), by(wz2003)
	
/* Keep correspondence */
keep wz2003 wz2008_corr
	
/* Duplicates */
duplicates drop wz2003, force
	
/* WZ panel correspondence */
save WZ_panel_correspondence, replace 

/* Project */
project, creates("`directory'\Data\WZ_panel_correspondence.dta")
project, uses("`directory'\Data\WZ_panel_correspondence.dta")

********************************************************************************
**** (4) Converged data (URS) 												****
********************************************************************************

/* Data */
use URS_data, clear

/* Merge: WZ panel correspondence */
merge m:1 wz2003 using WZ_panel_correspondence
drop if _merge == 2
drop _merge

/* Adjust correspondence (assumption: most frequent match) */
replace wz2008_rev = wz2008_corr if wz2008_rev == .

/* County identifier */
gen county = substr(urs_1ef6_14, -6, 3)
		
/* State identifier */
gen state = substr(urs_1ef6_14, -8, 2)

/* Keep relevant data */
keep ///
	UNR ///
	urs_jahr ///
	urs_1ef6 ///
	urs_1ef16 ///
	urs_1ef17 ///
	urs_1ef19 ///
	industry_5 ///
	urs_1ef26 ///
	urs_5ef16u1 ///
	urs_5ef16u2 ///
	urs_5ef18u1 ///
	urs_5ef18u2 ///
	urs_5ef20u1 ///
	urs_5ef20u2 ///
	urs_5ef21u1 ///
	urs_5ef21u2 ///
	urs_5ef30u1 ///
	urs_5ef30u2 ///
	GTAG ///
	agsunsicher ///
	urs_1ef6_14 ///
	county ///
	state ///
	wz2003 ///
	wz2008_rev ///
	legal_form
	
/* Labeling */
label var wz2003 "WZ 2003"
label var wz2008_rev "WZ 2008 (Revised)"
label var county "County (AGS)"
label var state "State (AGS)"
label var legal_form "Legal form (Revised)"

/* Save */
save URS_data, replace

/* Project */
project, creates("`directory'\Data\URS_data.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/21/2017													****
**** Program:	Aggregate outcomes from URS [Excerpt]						****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: URS_data.dta
	Variables:
		- UNR				systemfreie Unternehmensnummer
		- urs_jahr			Auswertungsjahr des Unternehmensregisters
		- urs_1ef26			Rechtsform
		- urs_5ef16u1		Steuerbarer Umsatz in 1000 EUR
		- urs_5ef16u2		Bezugszeit steuerbarer Umsatz (jjjj)
		- urs_5ef18u1		Sozialversicherungspflichtig Beschaeftigte: Anzahl
		- urs_5ef18u2		Sozialversicherungspflichtig Beschaeftigte: Bezugszeit (jjjj)
		- urs_5ef30u1		Schaetzumsatz nach Organschaftschaetzung in 1000 EUR
		- urs_5ef30u2		Bezugszeit Schaetzumsatz (jjjj)
		- urs_1ef6_14		Amtlicher Gemeindeschluessel zum Gebietsstand 31.12.2014
		- county			County identifier (Kreis)
		- state				State identifier (Bundesland)
		- legal_form		Legal form (limited vs. unlimited liability)
		- wz2008_rev		Updated/converged WZ 2008 for entire panel

Newly created variables (kept):
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- sales 			Sales (Estimated taxable sales)
		- empl				Employees (1+Employees)
		- limited_fraction 	Fraction of limited firms in all firms
		- no_firms_URS 		Number of firms (URS)
		- hhi				Herfindahl-Hirschman Index (Concentration)

Note:
		- suffix: lim		Uses limited liability firms only
		- suffix: unl		Uses unlimited liability firms only
		
Comment:
This program calculates county-industry-year level aggregates (e.g., product-market concentration).
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, uses("`directory'\Data\URS_data.dta")

********************************************************************************
**** (1) Number of limited liability firms in URS							****
********************************************************************************

/* Data */
use URS_data, clear

/* Keep relevant variables */
keep ///
	UNR ///
	urs_jahr ///
	county ///
	state ///
	urs_1ef17 ///
	urs_1ef26 ///
	urs_5ef16u2 ///
	urs_5ef18u2 ///
	urs_5ef30u2 ///
	urs_5ef16u1 ///
	urs_5ef30u1 ///
	urs_5ef18u1	///
	wz2008_rev ///
	legal_form	

/* Specify: level of industry (2-digit) */
gen industry = floor(wz2008_rev/1000)
label var industry "Industry (2-Digit NACE/WZ)"

/* Duplicates */
sort UNR urs_jahr
duplicates drop UNR urs_jahr, force

/* Sample restriction */
keep if legal_form >= 1 & legal_form <= 8
 
/* Number of all firms */
egen no_firms_URS = count(UNR), by(county industry urs_jahr)

/* Number of limited liability firms */
gen limited = (legal_form == 5 | legal_form == 6 | legal_form == 7)
label var limited "Limited firm"

egen no_firms_URS_lim = total(limited), by(county industry urs_jahr) missing

/* Number of unlimited liability firms */
gen unlimited = (legal_form == 1 | legal_form == 2 | legal_form == 3 | legal_form == 4 | legal_form == 8)
label var unlimited "Unlimited firm"

egen no_firms_URS_unl = total(unlimited), by(county industry urs_jahr) missing

********************************************************************************
**** (2) Weights and outcomes in URS										****
********************************************************************************

/* Year */
destring urs_5ef16u2 urs_5ef18u2 urs_5ef30u2, replace
gen year = urs_jahr - 2
label var year "Fiscal Year"

/* Panel entry year */
destring urs_1ef17, replace
rename urs_1ef17 entry_year
label var entry_year "Entry Year (URS)"

/* Sales */
gen sales = urs_5ef30u1 
replace sales = urs_5ef16u1 if sales == . & urs_jahr == 2008
replace sales = urs_5ef16u1 if urs_5ef30u2 != year & urs_5ef16u2 == year
replace sales = . if urs_5ef30u2 != year & urs_5ef16u2 != year
label var sales "Sales (Estimated taxable sales)"

/* Employees (replace for missing values with year + nonmissing value with wrong year) */
gen empl = urs_5ef18u1+1
replace empl = 1 if (empl == . & urs_5ef18u1 == . & urs_5ef18u2 != .) | (urs_5ef18u2 != year)
label var empl "Employees (1+Employees)"

/* Panel */
sort UNR year
duplicates drop UNR year, force
xtset UNR year

/* Sample restriction: period 2003 to 2012 */
keep if year >= 2003 & year <= 2012

/* Drop missing */
drop if sales == . & empl == .

/* Save firm sample */
save Firm, replace

/* Concentration measure (HHI) */

	/* All */
	egen total = total(sales), by(county industry year) missing
	egen hhi = total((sales/total)^2), by(county industry year) missing
	label var hhi "Concentration (HHI)"
	drop total
	
********************************************************************************
**** (5) Cleaning and labeling												****
********************************************************************************

/* Keep relevant variables */ 
keep ///
	county ///
	state ///
	industry ///
	year ///
	no_* ///
	hhi
	
/* Duplicates */
sort county industry year
duplicates drop county industry year, force

/* Labeling */
label var no_firms_URS "Number of firms (URS)"
label var no_firms_URS_lim "Number of (limited) firms (URS)"
label var no_firms_URS_unl "Number of (unlimited) firms (URS)"

********************************************************************************
**** (6) Additional variables												****
********************************************************************************

/* Duplicates */
duplicates drop county industry year, force
	
/* Fraction of firms */
gen limited_fraction = no_firms_URS_lim/no_firms_URS
label var limited_fraction "Fraction of limited firms in all firms"
	
/* Cross-sectional split variables */

	/* Number of firms */
	egen pre = mean(no_firms_URS) if year == 2006, by(county industry)
	egen s_firms = mean(pre), by(county industry)
	label var s_firms "Firms (pre)"
	drop pre
			
********************************************************************************
**** (7) Saving																****
********************************************************************************
			
/* Save */
cd "`directory'\Data"
save URS_outcomes, replace	

/* Project */	
project, creates("`directory'\Data\URS_outcomes.dta")
project, creates("`directory'\Data\Firm.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (0) Execute project programs 											****
****	 (Data source abbreviations:										****
****		- URS: Unternehmensregister										****
****		- GWS: Gewerbeanzeigenstatistik									****
****		- AMA: Amadeus (Bureau van Dijk) [separate do-file: AMA_data]	****
********************************************************************************

********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Unifying county & industry definitions 							****
********************************************************************************

/* Cleaning URS panel & converging industry (WZ) definitions */
project, do(Dofiles/URS_data.do)

/* Cleaning GWS panel */
project, do(Dofiles/GWS_data.do)


********************************************************************************
**** (3) Aggregate outcomes 												****
********************************************************************************

/* Obtaining aggregate outcomes from URS */
project, do(Dofiles/URS_outcomes.do)

/* Obtaining aggregate outcomes from GWS */
project, do(Dofiles/GWS_outcomes.do)


********************************************************************************
**** (4) Empirical analyses 												****
********************************************************************************

/* Merging outcome and treatment variables */
project, do(Dofiles/Data.do)

/* Regression analyses */
project, do(Dofiles/Analyses.do)

/* Graphs */
project, do(Dofiles/Graphs.do)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (0) Execute project programs 											****
****	 (Data source abbreviations:										****
****		- URS: Unternehmensregister										****
****		- GWS: Gewerbeanzeigenstatistik									****
****		- AMA: Amadeus (Bureau van Dijk) [separate do-file: AMA_data]	****
********************************************************************************

********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Coverage (treatment) [to be prepared for Destatis]					****
********************************************************************************

/* AMA panel data with converged industry (WZ) and location (AGS) definitions */
project, do(Dofiles/AMA_panel.do)

/* AMA data for coverage calculation */
project, do(Dofiles/AMA_data.do)

/* Obtaining coverage (treatment) from AMA (for Germany) */
project, do(Dofiles/AMA_coverage.do)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Setup of "project" program (German enforcement setting)		****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Master directory ****
local master = "...\Project_Germany\Programs" // specify directory path

********************************************************************************
**** (0) Install external program ("project")								****
********************************************************************************

**** Install ****
ssc install project


********************************************************************************
**** (1) Setup and building project: Local									****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Local.do")

**** Build ****
cap noisily project Master_Local, build


********************************************************************************
**** (2) Setup and building project: Destatis [to be run at FDZ]			****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Destatis.do")

**** Build ****
cap noisily project Master_Destatis, build
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Installs external (user-written) programs					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

********************************************************************************
**** (1) Install external programs											****
********************************************************************************

**** Estout ****
ssc install estout, replace

**** Reghdfe ****
ssc install reghdfe, replace
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		08/03/2020													****
**** Program:	EU KLEMS productivity data									****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, original("`directory'\Data\Statistical_National-Accounts.dta")	
project, original("`directory'\Data\Statistical_Growth-Accounts.dta")	
project, original("`directory'\Data\Statistical_Capital.dta")	

********************************************************************************
**** (1) Generate KLEMS data												****
********************************************************************************

/* Delete */
cap rm KLEMS.dta

/* Data */
use Statistical_National-Accounts, clear

/* Keep relevant data */
keep if var == "VA" | var == "COMP"

/* Reshape: Variable into columns */

	/* Obtain variable names */
	levelsof var, clean local(varlist) 

	/* Loop over variables */
	foreach var of local varlist {

		/* Preserve */
		preserve
			
			/* Variable */
			keep if var == "`var'"
			drop db var indnr Sort_ID
			
			/* Variable name */
			local name = lower("`var'")
			
			/* Rename */
			rename value `name'
			label var `name' "`var'"

			/* Merge */
			//cd "`directory'\Data"
			cap merge 1:1 country code year using KLEMS
			cap drop _merge
			
			/* Save */
			save KLEMS, replace
			
		/* Restore */
		restore
			
	}
	
/* Data: Growth Accounts */
use Statistical_Growth-Accounts, clear

/* Keep relevant data */
keep if var == "VA_G"

/* Reshape: Variable into columns */

	/* Obtain variable names */
	levelsof var, clean local(varlist) 

	/* Loop over variables */
	foreach var of local varlist {

		/* Preserve */
		preserve
			
			/* Variable */
			keep if var == "`var'"
			drop db var indnr Sort_ID
			
			/* Variable name */
			local name = lower("`var'")
			
			/* Rename */
			rename value `name'
			label var `name' "`var'"

			/* Merge */
			//cd "`directory'\Data"
			cap merge 1:1 country code year using KLEMS
			cap drop _merge
			
			/* Save */
			save KLEMS, replace
			
		/* Restore */
		restore
			
	}

/* Data: Capital Accounts */
use Statistical_Capital, clear

/* Keep relevant data */
keep if var == "K_GFCF"

/* Reshape: Variable into columns */

	/* Obtain variable names */
	levelsof var, clean local(varlist) 

	/* Loop over variables */
	foreach var of local varlist {

		/* Preserve */
		preserve
			
			/* Variable */
			keep if var == "`var'"
			drop db var indnr Sort_ID
			
			/* Variable name */
			local name = lower("`var'")
			
			/* Rename */
			rename value `name'
			label var `name' "`var'"

			/* Merge */
			//cd "`directory'\Data"
			cap merge 1:1 country code year using KLEMS
			cap drop _merge
			
			/* Save */
			save KLEMS, replace
			
		/* Restore */
		restore
			
	}

/* Data */
use KLEMS, clear
	
/* Cleaning */

	/* Country */
	replace country = "Austria" if country == "AT"
	replace country = "Belgium" if country == "BE"
	replace country = "Bulgaria" if country == "BG"
	replace country = "Cyprus" if country == "CY"
	replace country = "Czech Republic" if country == "CZ"
	replace country = "Germany" if country == "DE"
	replace country = "Denmark" if country == "DK"
	replace country = "Estonia" if country == "EE"
	replace country = "Greece" if country == "EL"
	replace country = "Spain" if country == "ES"
	replace country = "Finland" if country == "FI"
	replace country = "France" if country == "FR"
	replace country = "Croatia" if country == "HR"
	replace country = "Hungary" if country == "HU"
	replace country = "Ireland" if country == "IE"
	replace country = "Italy" if country == "IT"
	replace country = "Japan" if country == "JP"
	replace country = "Lithuania" if country == "LT"
	replace country = "Luxembourg" if country == "LU"
	replace country = "Latvia" if country == "LV"
	replace country = "Malta" if country == "MT"
	replace country = "Netherlands" if country == "NL"
	replace country = "Poland" if country == "PL"
	replace country = "Portugal" if country == "PT"
	replace country = "Romania" if country == "RO"
	replace country = "Sweden" if country == "SE"
	replace country = "Slovenia" if country == "SI"
	replace country = "Slovakia" if country == "SK"
	replace country = "United Kingdom" if country == "UK"
	replace country = "United States" if country == "US"
	drop if country == "EA19" | regexm(country, "EU") == 1

	/* Industry */
	rename code industry
	drop if industry == "MARKT" | regexm(industry, "TOT") == 1

/* Sort */
sort country industry year
		
/* Labels */  
label var country "Country"
label var industry "Industry"
label var year "Year"
label var va "GVA, current prices, NAC mn"
label var comp "Compensation of employees, current prices, NAC mn"
label var va_g "Growth rate of value added volume, %, log"
label var k_gfcf "Capital stock, net, current replacement (all assets)"

/* Save */
save KLEMS, replace

/* Project */
project, creates("`directory'\Data\KLEMS.dta")

********************************************************************************
**** (2) Industry link to Scopes											****
********************************************************************************

/* Data */
use Scope_2, clear // Scope calculated using Scope.do from Project_Europe (but for two-digit instead of four-digit NACE industries)

/* Rename industry */
rename industry industry_nace
	
/* Generate broad ISIC 4 */
gen industry = ""
replace industry = "A" if industry_nace >= 1 & industry_nace <= 3
replace industry = "B" if industry_nace >= 5 & industry_nace <= 9
replace industry = "C10-C12" if industry_nace >= 10 & industry_nace <= 12
replace industry = "C13-C15" if industry_nace >= 13 & industry_nace <= 15
replace industry = "C16-C18" if industry_nace >= 16 & industry_nace <= 18
replace industry = "C19" if industry_nace == 19
replace industry = "C20" if industry_nace == 20
replace industry = "C21" if industry_nace == 21
replace industry = "C22_C23" if industry_nace >= 22 & industry_nace <= 23
replace industry = "C24_C25" if industry_nace >= 24 & industry_nace <= 25
replace industry = "C26" if industry_nace == 26
replace industry = "C27" if industry_nace == 27
replace industry = "C28" if industry_nace == 28
replace industry = "C29_C30" if industry_nace >= 29 & industry_nace <= 30
replace industry = "C31_C33" if industry_nace >= 30 & industry_nace <= 33
replace industry = "D" if industry_nace == 35
replace industry = "E" if industry_nace >= 36 & industry_nace <= 39
replace industry = "F" if industry_nace >= 41 & industry_nace <= 43
replace industry = "G45" if industry_nace == 45
replace industry = "G46" if industry_nace == 46
replace industry = "G47" if industry_nace == 47
replace industry = "H49" if industry_nace == 49
replace industry = "H50" if industry_nace == 50
replace industry = "H51" if industry_nace == 51
replace industry = "H52" if industry_nace == 52
replace industry = "H53" if industry_nace == 53
replace industry = "I" if industry_nace >= 55 & industry_nace <= 56
replace industry = "J58-J60" if industry_nace >= 58 & industry_nace <= 60
replace industry = "J61" if industry_nace == 61
replace industry = "J62_J63" if industry_nace >= 62 & industry_nace <= 63
replace industry = "K" if industry_nace >= 64 & industry_nace <= 66
replace industry = "L" if industry_nace == 68
replace industry = "M_N" if industry_nace >= 69 & industry_nace <= 82
replace industry = "O" if industry_nace == 84
replace industry = "P" if industry_nace == 85
replace industry = "Q" if industry_nace >= 86 & industry_nace <= 88
replace industry = "R_S" if industry_nace >= 90 & industry_nace <= 96
replace industry = "T" if industry_nace >= 97 & industry_nace <= 98
replace industry = "U" if industry_nace == 99
label var industry "Industry (KLEMS)"

/* Aggregate scopes to broad KLEMS industries */
collapse (mean) mc_scope mc_audit, by(country industry year)

/* Save */
save Scope_KLEMS, replace

/* Project */
project, creates("`directory'\Data\Scope_KLEMS.dta")

********************************************************************************
**** (3) Combine KLEMS and Scopes											****
********************************************************************************

/* Data */
use KLEMS, clear

/* Scope */
		
	/* Merge: own scope */
	merge m:1 country industry year using Scope_KLEMS
	drop if _merge == 2
	drop _merge
	
/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Cluster */
egen cluster = group(c i)
label var cluster "Cluster (country-industry)"

********************************************************************************
**** (4) Generate relevant variables										****
********************************************************************************

/* Panel */
xtset cluster year

/* Combined scope */
egen min = rowmin(mc_scope mc_audit)
label var min "Reporting and Auditing"

/* Productivity */

	/* log */
	gen value = ln(va)
	gen lp = ln(va) - ln(comp)
	gen tfp = ln(va) - 0.7*ln(comp) - 0.3*ln(k_gfcf)
	gen growth = va_g/100 // already logarithmic
	
********************************************************************************
**** (5) Regression analysis												****
********************************************************************************

/* Keep relevant period */
keep if year >= 2001 & year <= 2015

/* Variable list */

	/* Parameters*/
	local FE = "c##year i##year"	
	local Cluster = "cluster"
	
	/* All outcomes */
	local Outcomes = "value lp tfp growth"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_8_Panel_A.smcl, replace smcl name(Table_8_Panel_A) 

/* Industry Level */
foreach y of varlist `Outcomes' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if mc_scope!=., a(`FE') residual(r_`y')
			qui reghdfe mc_scope if `y'!=., a(`FE') residual(r_mc_scope)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		

			/* Estimation */			
			qui reghdfe `y' mc_scope, a(`FE') cluster(`Cluster')    
				est store M1	
				
		}
		
	/* Restore */
	restore
	
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if min!=., a(`FE') residual(r_`y')
			qui reghdfe min if `y'!=., a(`FE') residual(r_min)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)

			qui sum r_min, d
			qui replace min = . if r_min < r(p1) | r_min > r(p99)
			
			/* Estimation */
			qui reghdfe `y' min, a(`FE') cluster(`Cluster')    
				est store M2
				
			/* Output */
			estout M1 M2, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("COUNTRY-INDUSTRY LEVEL: `y_label'") ///
				varlabels(mc_scope "Standardized Reporting Scope" min "Standardized Reporting and Auditing Scope") ///				
				mlabels(, depvars) varwidth(45) modelwidth(15) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "Clusters (Country-Industry)" "Adjusted R-Squared"))  	
				
		}
		
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_8_Panel_A
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		08/03/2020													****
**** Program:	OECD productivity data										****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, original("`directory'\Data\DATA.txt")

/******************************************************************************/
/* (1) Import OECD Industry Data										 	  */
/******************************************************************************/

/* Delete */
cap rm OECD.dta

/* Import */
import delimited using DATA.txt, delimiter("|") varnames(1) case(lower) clear

/* Keep relevant variables */
drop flag
keep if var == "VALU" | var == "LABR" | var == "GFCF"

/* Loop over variables */
local variables = "VALU LABR GFCF"
foreach var of local variables {

	/* Preserve */
	preserve 

		/* Keep relevant observations */
		keep if var == "`var'"
		
		/* Name */
		local name = lower("`var'")
		
		/* Rename */
		rename value `name'
		
		/* Drop */
		drop var
		
		/* Merge */
		//cd "`directory'\Data"
		cap merge 1:1 cou ind year using OECD
		cap drop _merge
		
		/* Save */
		save OECD, replace
	
	/* Restore */
	restore
	
}

/* Data */
use OECD, clear

/* Rename */
rename ind industry

/* Industry */
drop if ///
	industry == "ENERGYP" | ///
	industry == "ICTMS" | ///
	regexm(industry, "DT") == 1 | ///
	regexm(industry, "X") == 1
replace industry = substr(industry, 2,.)

/* Country */
gen country = "Australia" if cou == "AUS"
replace country = "Austria" if cou == "AUT"
replace country = "Belgium" if cou == "BEL"
replace country = "Canada" if cou == "CAN"
replace country = "Switzerland" if cou == "CHE"
replace country = "Chile" if cou == "CHL"
replace country = "Costa Rica" if cou == "CRI"
replace country = "Czech Republic" if cou == "CZE"
replace country = "Germany" if cou == "DEU"
replace country = "Denmark" if cou == "DNK"
replace country = "Spain" if cou == "ESP"
replace country = "Estonia" if cou == "EST"
replace country = "Finland" if cou == "FIN"
replace country = "France" if cou == "FRA"
replace country = "United Kingdom" if cou == "GBR"
replace country = "Greece" if cou == "GRC"
replace country = "Hungary" if cou == "HUN"
replace country = "Ireland" if cou == "IRL"
replace country = "Iceland" if cou == "ISL"
replace country = "Israel" if cou == "ISR"
replace country = "Italy" if cou == "ITA"
replace country = "Japan" if cou == "JPN"
replace country = "South Korea" if cou == "KOR"
replace country = "Lithuania" if cou == "LTU"
replace country = "Luxembourg" if cou == "LUX"
replace country = "Latvia" if cou == "LVA"
replace country = "Mexico" if cou == "MEX"
replace country = "Netherlands" if cou == "NLD"
replace country = "Norway" if cou == "NOR"
replace country = "New Zealand" if cou == "NZL"
replace country = "Poland" if cou == "POL"
replace country = "Portugal" if cou == "PRT"
replace country = "Slovakia" if cou == "SVK"
replace country = "Slovenia" if cou == "SVN"
replace country = "Sweden" if cou == "SWE"
replace country = "Turkey" if cou == "TUR"
replace country = "United States" if cou == "USA"
drop cou

/* Label */
label var country "Country"
label var industry "Industry"
label var year "Year"
label var valu "Value added, current prices (m national currency)"
label var labr "Labour costs (compensation of employees) (m national currency)"
label var gfcf "Gross fixed capital formation, current price (m national currency)"

/* Sample */
keep if year >= 2000 & year <= 2015

/* Order */
order country industry year

/* Sort */
sort country industry year

/* Save */
save OECD, replace

/* Project */
project, creates("`directory'\Data\OECD.dta")

/******************************************************************************/
/* (2) OECD Industries (broad ISIC 4)										  */
/******************************************************************************/

/* Data */
use Scope_2, clear

/* Rename */
rename industry industry_nace

/* Generate broad ISIC 4 */
gen industry = ""
replace industry = "01T03" if industry_nace >= 1 & industry_nace <= 3
replace industry = "05T06" if industry_nace >= 5 & industry_nace <= 6
replace industry = "07T08" if industry_nace >= 7 & industry_nace <= 8
replace industry = "09" if industry_nace == 9
replace industry = "10T12" if industry_nace >= 10 & industry_nace <= 12
replace industry = "13T15" if industry_nace >= 13 & industry_nace <= 15
replace industry = "16" if industry_nace == 16
replace industry = "17T18" if industry_nace >= 17 & industry_nace <= 18
replace industry = "19" if industry_nace == 19
replace industry = "20T21" if industry_nace >= 20 & industry_nace <= 21
replace industry = "22" if industry_nace == 22
replace industry = "23" if industry_nace == 23
replace industry = "24" if industry_nace == 24
replace industry = "25" if industry_nace == 25
replace industry = "26" if industry_nace == 26
replace industry = "27" if industry_nace == 27
replace industry = "28" if industry_nace == 28
replace industry = "29" if industry_nace == 29
replace industry = "30" if industry_nace == 30
replace industry = "31T33" if industry_nace >= 31 & industry_nace <= 33
replace industry = "35T39" if industry_nace >= 35 & industry_nace <= 39
replace industry = "41T43" if industry_nace >= 41 & industry_nace <= 43
replace industry = "45T47" if industry_nace >= 45 & industry_nace <= 47
replace industry = "49T53" if industry_nace >= 49 & industry_nace <= 53
replace industry = "55T56" if industry_nace >= 55 & industry_nace <= 56
replace industry = "58T60" if industry_nace >= 58 & industry_nace <= 60
replace industry = "61" if industry_nace == 61
replace industry = "62T63" if industry_nace >= 62 & industry_nace <= 63
replace industry = "64T66" if industry_nace >= 64 & industry_nace <= 66
replace industry = "68" if industry_nace == 68
replace industry = "69T82" if industry_nace >= 69 & industry_nace <= 82
replace industry = "84" if industry_nace == 84
replace industry = "84" if industry_nace == 85
replace industry = "86T88" if industry_nace >= 86 & industry_nace <= 88
replace industry = "90T96" if industry_nace >= 90 & industry_nace <= 96
replace industry = "97T98" if industry_nace >= 97 & industry_nace <= 98
label var industry "Industry (OECD)"

/* Aggregate scopes to broad ISIC 4 */
collapse (mean) mc_scope mc_audit, by(country industry year)

/* Save */
save Scope_OECD, replace

/* Project */
project, creates("`directory'\Data\Scope_OECD.dta")

********************************************************************************
**** (3) Combine OECD and Scopes											****
********************************************************************************

/* Data */
use OECD, clear

/* Scope */
		
	/* Merge: own scope */
	merge m:1 country industry year using Scope_OECD
	drop if _merge == 2
	drop _merge
	
/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Cluster */
egen cluster = group(c i)
label var cluster "Cluster (country-industry)"

********************************************************************************
**** (4) Generate relevant variables										****
********************************************************************************

/* Panel */
xtset cluster year

/* Combined scope */
egen min = rowmin(mc_scope mc_audit)
label var min "Reporting and Auditing"

/* Productivity */

	/* log */
	gen value = ln(valu)
	gen lp = ln(valu) - ln(labr)
	gen tfp = ln(valu) - 0.7*ln(labr) - 0.3*ln(gfcf)
	gen growth = ln(valu) - ln(l.valu)
	
********************************************************************************
**** (5) Regression analysis												****
********************************************************************************

/* Keep relevant period */
keep if year >= 2001 & year <= 2015

/* Variable list */

	/* Parameters*/
	local FE = "c##year i##year"	
	local Cluster = "cluster"
	
	/* All outcomes */
	local Outcomes = "value lp tfp growth"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_8_Panel_B.smcl, replace smcl name(Table_8_Panel_B) 

/* Industry Level */
foreach y of varlist `Outcomes' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if mc_scope!=., a(`FE') residual(r_`y')
			qui reghdfe mc_scope if `y'!=., a(`FE') residual(r_mc_scope)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		

			/* Estimation */			
			qui reghdfe `y' mc_scope, a(`FE') cluster(`Cluster')    
				est store M1	
				
		}
		
	/* Restore */
	restore
	
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if min!=., a(`FE') residual(r_`y')
			qui reghdfe min if `y'!=., a(`FE') residual(r_min)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)

			qui sum r_min, d
			qui replace min = . if r_min < r(p1) | r_min > r(p99)
			
			/* Estimation */
			qui reghdfe `y' min, a(`FE') cluster(`Cluster')    
				est store M2
				
			/* Output */
			estout M1 M2, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("COUNTRY-INDUSTRY LEVEL: `y_label'") ///
				varlabels(mc_scope "Standardized Reporting Scope" min "Standardized Reporting and Auditing Scope") ///				
				mlabels(, depvars) varwidth(45) modelwidth(15) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "Clusters (Country-Industry)" "Adjusted R-Squared"))  	
				
		}
		
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_8_Panel_B
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		08/03/2020													****
**** Program:	OECD productivity data										****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, original("`directory'\Data\WIOD_SEA_Nov16.xlsx")

/******************************************************************************/
/* (1) Import WIOD Socio Economic Data									 	  */
/******************************************************************************/

/* Delete */
cap rm WIOD.dta

/* Import */
import excel using WIOD_SEA_Nov16.xlsx, sheet("DATA") firstrow case(lower) clear

/* Rename variables */
local year = 2000
foreach var of varlist e-s {
	
	/* Rename */
	rename `var' v`year'
	
	/* Year */
	local year = `year' + 1

}

/* Id */
egen i = group(country variable code)

/* Reshape */
reshape long v, i(i) j(year)

/* Drop */
drop i

/* Destring */
destring v, force replace

/* Loop over variables */
local variables = "CAP LAB VA"
foreach var of local variables {

	/* Preserve */
	preserve 

		/* Keep relevant observations */
		keep if variable == "`var'"
		
		/* Name */
		local name = lower("`var'")
		
		/* Rename */
		rename v `name'
		
		/* Drop */
		drop variable
		
		/* Merge */
		//cd "`directory'\Data"
		cap merge 1:1 country code year using WIOD
		cap drop _merge
		
		/* Save */
		save WIOD, replace
	
	/* Restore */
	restore
	
}

/* Data */
use WIOD, clear

/* Country */
replace country = "Australia" if country == "AUS"
replace country = "Austria" if country == "AUT"
replace country = "Belgium" if country == "BEL"
replace country = "Bulgaria" if country == "BGR"
replace country = "Brazil" if country == "BRA"
replace country = "Canada" if country == "CAN"
replace country = "Switzerland" if country == "CHE"
replace country = "China" if country == "CHN"
replace country = "Cyprus" if country == "CYP"
replace country = "Czech Republic" if country == "CZE"
replace country = "Germany" if country == "DEU"
replace country = "Denmark" if country == "DNK"
replace country = "Spain" if country == "ESP"
replace country = "Estonia" if country == "EST"
replace country = "Finland" if country == "FIN"
replace country = "France" if country == "FRA"
replace country = "United Kingdom" if country == "GBR"
replace country = "Greece" if country == "GRC"
replace country = "Croatia" if country == "HRV"
replace country = "Hungary" if country == "HUN"
replace country = "Indonesia" if country == "IDN"
replace country = "India" if country == "IND"
replace country = "Ireland" if country == "IRL"
replace country = "Italy" if country == "ITA"
replace country = "Japan" if country == "JPN"
replace country = "South Korea" if country == "KOR"
replace country = "Lithuania" if country == "LTU"
replace country = "Luxembourg" if country == "LUX"
replace country = "Latvia" if country == "LVA"
replace country = "Mexico" if country == "MEX"
replace country = "Malta" if country == "MLT"
replace country = "Netherlands" if country == "NLD"
replace country = "Norway" if country == "NOR"
replace country = "Poland" if country == "POL"
replace country = "Portugal" if country == "PRT"
replace country = "Romania" if country == "ROU"
replace country = "Russia" if country == "RUS"
replace country = "Slovakia" if country == "SVK"
replace country = "Slovenia" if country == "SVN"
replace country = "Sweden" if country == "SWE"
replace country = "Turkey" if country == "TUR"
replace country = "Taiwan" if country == "TWN"
replace country = "United States" if country == "USA"

/* Industry */
rename code industry

/* Labels */
label var year "Year"
label var va "Gross value added at current basic prices (in m of national currency)"
label var lab "Labour compensation (in m of national currency)"	
label var cap "Capital compensation (in m of national currency)"		

/* Order */
order country industry year

/* Sort */
sort country industry year

/* Save */
save WIOD, replace

/* Project */
project, creates("`directory'\Data\WIOD.dta")

/******************************************************************************/
/* (2) WIOD Industries (broad ISIC 4)										  */
/******************************************************************************/

/* Data */
use Scope_2, clear

/* Rename */
rename industry industry_nace

/* Generate broad ISIC 4 */
gen industry = ""
replace industry = "A01" if industry_nace == 1
replace industry = "A02" if industry_nace == 2
replace industry = "A03" if industry_nace == 3
replace industry = "B" if industry_nace >= 5 & industry_nace <= 9
replace industry = "C10-C12" if industry_nace >= 10 & industry_nace <= 12
replace industry = "C13-C15" if industry_nace >= 13 & industry_nace <= 15
replace industry = "C16" if industry_nace == 16
replace industry = "C17" if industry_nace == 17
replace industry = "C18" if industry_nace == 18
replace industry = "C19" if industry_nace == 19
replace industry = "C20" if industry_nace == 20
replace industry = "C21" if industry_nace == 21
replace industry = "C22" if industry_nace == 22
replace industry = "C23" if industry_nace == 23
replace industry = "C24" if industry_nace == 24
replace industry = "C25" if industry_nace == 25
replace industry = "C26" if industry_nace == 26
replace industry = "C27" if industry_nace == 27
replace industry = "C28" if industry_nace == 28
replace industry = "C29" if industry_nace == 29
replace industry = "C30" if industry_nace == 30
replace industry = "C31_C32" if industry_nace >= 31 & industry_nace <= 32
replace industry = "C33" if industry_nace == 33
replace industry = "D35" if industry_nace == 35
replace industry = "E36" if industry_nace == 36
replace industry = "E37-E39" if industry_nace >= 37 & industry_nace <= 39
replace industry = "F" if industry_nace >= 41 & industry_nace <= 43
replace industry = "G45" if industry_nace == 45
replace industry = "G46" if industry_nace == 46
replace industry = "G47" if industry_nace == 47
replace industry = "H49" if industry_nace == 49
replace industry = "H50" if industry_nace == 50
replace industry = "H51" if industry_nace == 51
replace industry = "H52" if industry_nace == 52
replace industry = "H53" if industry_nace == 53
replace industry = "I" if industry_nace >= 55 & industry_nace <= 56
replace industry = "J58" if industry_nace == 58
replace industry = "J59_J60" if industry_nace >= 59 & industry_nace <= 60
replace industry = "J61" if industry_nace == 61
replace industry = "J62_J63" if industry_nace >= 62 & industry_nace <= 63
replace industry = "K64" if industry_nace == 64
replace industry = "K65" if industry_nace == 65
replace industry = "K66" if industry_nace == 66
replace industry = "L68" if industry_nace == 68
replace industry = "M69_M70" if industry_nace >= 69 & industry_nace <= 70
replace industry = "M71" if industry_nace == 71
replace industry = "M72" if industry_nace == 72
replace industry = "M73" if industry_nace == 73
replace industry = "M74_M75" if industry_nace >= 74 & industry_nace <= 75
replace industry = "N" if industry_nace >= 77 & industry_nace <= 82
replace industry = "O84" if industry_nace == 84
replace industry = "P85" if industry_nace == 85
replace industry = "Q" if industry_nace >= 86 & industry_nace <= 88
replace industry = "R_S" if industry_nace >= 90 & industry_nace <= 96
replace industry = "T" if industry_nace >= 97 & industry_nace <= 98
replace industry = "U" if industry_nace == 99
label var industry "Industry (WIOD)"

/* Aggregate scopes to broad ISIC 4 */
collapse (mean) mc_scope mc_audit, by(country industry year)

/* Save */
save Scope_WIOD, replace

/* Project */
project, creates("`directory'\Data\Scope_WIOD.dta")

********************************************************************************
**** (3) Combine WIOD and Scopes											****
********************************************************************************

/* Data */
use WIOD, clear

/* Scope */
		
	/* Merge: own scope */
	merge m:1 country industry year using Scope_WIOD
	drop if _merge == 2
	drop _merge
	
/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Cluster */
egen cluster = group(c i)
label var cluster "Cluster (country-industry)"

********************************************************************************
**** (4) Generate relevant variables										****
********************************************************************************

/* Panel */
xtset cluster year

/* Combined scope */
egen min = rowmin(mc_scope mc_audit)
label var min "Reporting and Auditing"

/* Productivity */

	/* log */
	gen value = ln(va)
	gen lp = ln(va) - ln(lab)
	gen tfp = ln(va) - 0.7*ln(lab) - 0.3*ln(cap)
	gen growth = ln(valu) - ln(l.valu)
	
********************************************************************************
**** (5) Regression analysis												****
********************************************************************************

/* Keep relevant period */
keep if year >= 2001 & year <= 2015

/* Variable list */

	/* Parameters*/
	local FE = "c##year i##year"	
	local Cluster = "cluster"
	
	/* All outcomes */
	local Outcomes = "value lp tfp growth"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_8_Panel_C.smcl, replace smcl name(Table_8_Panel_C) 

/* Industry Level */
foreach y of varlist `Outcomes' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if mc_scope!=., a(`FE') residual(r_`y')
			qui reghdfe mc_scope if `y'!=., a(`FE') residual(r_mc_scope)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		

			/* Estimation */			
			qui reghdfe `y' mc_scope, a(`FE') cluster(`Cluster')    
				est store M1	
				
		}
		
	/* Restore */
	restore
	
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if min!=., a(`FE') residual(r_`y')
			qui reghdfe min if `y'!=., a(`FE') residual(r_min)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)

			qui sum r_min, d
			qui replace min = . if r_min < r(p1) | r_min > r(p99)
			
			/* Estimation */
			qui reghdfe `y' min, a(`FE') cluster(`Cluster')    
				est store M2
				
			/* Output */
			estout M1 M2, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("COUNTRY-INDUSTRY LEVEL: `y_label'") ///
				varlabels(mc_scope "Standardized Reporting Scope" min "Standardized Reporting and Auditing Scope") ///				
				mlabels(, depvars) varwidth(45) modelwidth(15) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "Clusters (Country-Industry)" "Adjusted R-Squared"))  	
				
		}
		
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_8_Panel_C
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Construct Data & Run Analyses										****
********************************************************************************

/* EU KLEMS sample */
project, do(Dofiles/KLEMS.do)

/* OECD sample */
project, do(Dofiles/OECD.do)

/* WIOD sample */
project, do(Dofiles/WIOD.do)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Setup of "project" program	(National Statistics)			****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Master directory ****
local master = "...\Project_Statistics\Programs" // please insert/adjust directory path

********************************************************************************
**** (0) Install external program ("project")								****
********************************************************************************

**** Install ****
ssc install project

********************************************************************************
**** (1) Setup and building project: Local									****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Statistics.do")

**** Build ****
cap noisily project Master_Statistics, build
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
****																		****
**** Module:	Importing Amadeus Data (STATA Version)						****
**** Author: 	Matthias Breuer												****
**** Date: 	 	12/13/2016													****
********************************************************************************

*** Initiations ***
clear all
set more off
unicode encoding set UTF8 // STATA Version 14

********************************************************************************
**** (0) Choices/Options													****
********************************************************************************

/* Directory/Folder Path */
local directory = ".../IGM-BVD_Amadeus" // insert directory path for raw data (downloads from BvD discs)
local output = ".../IGM-BVD_Amadeus/STATA_Data" // insert directory for converted data

/* Section */
local section = "Company" // insert section (Financials, Company, Ownership, Subsidiaries)

/* Year */
local year = 2008 // insert year (of BvD disc)

********************************************************************************
**** (1) Importing: Financials												****
********************************************************************************

/* Section: Financials */
if "`section'" == "Financials" {

	/* Folder List */
	local folders: dir "`directory'/`year'/`section'" dirs "*"

	/* Folder Loop */
	foreach country of local folders {

		/* File List */
		local files: dir "`directory'/`year'/`section'/`country'" files "*"
		
		/* File Loop */
		foreach file of local files {
		
			/* Vintage Condition: Old Vintage */
			if `year' == 2005 | `year' == 2008 {
			
				/* Import */
				insheet using "`directory'/`year'/`section'/`country'/`file'", name tab clear double
			
				/* Check Import */
				if c(k) < 50 {
					insheet using "`directory'/`year'/`section'/`country'/`file'", name delimiter(".") clear double
				}
				
				if c(k) < 50 {
					insheet using "`directory'/`year'/`section'/`country'/`file'", name delimiter(";") clear double
				}
				
				/* Rename Header */
				
					/* Obtain Variable List */
					ds
					local varlist = r(varlist)
					
					/* Variable Loop */
					foreach var of local varlist {
						forvalues i = 0(1)9 {
							if strpos("`var'", "`i'") != 0 {
								local new_name = substr("`var'", 1, strpos("`var'", "`i'")-1)
								rename `var' `new_name'`i'
								local num_list: list num_list | new_name
							}
						}
					/* Close: Variable List */
					}

				/* Reshape */
				drop if (accnr == "" & idnr == "") | (accnr == "n.a." & idnr == "n.a.") | (accnr == "Credit needed" & idnr == "Credit needed")
				reshape long `num_list', i(company idnr accnr consol) j(rel_year) string
				
				/* Drop missing */
				drop if statda == "" | statda == "n.a."
				
				/* Save Intermediate Data */
				cd "`output'/`section'"
				save intermediate_`year', replace
		
			/* Close: Old Vintage */
			}
			
			/* Vintage Condition: New Vintage */
			if `year' == 2012 {
			
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(tab) varnames(1) clear
			
				/* Check Import */
				if c(k) < 50 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(".") varnames(1) clear
				}
				
				if c(k) < 50 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(";") varnames(1) clear
				}
				
				/* Rename Header */
				
					/* Manual Adjustment */
					cap rename v1 company
					cap rename ï company
					rename statdate statda
					drop v3-v11 v13-v21 v33-v41
					
					/* Obtain Variable List */
					ds, has(varlabel)
					local varlist = r(varlist)
					local static_list = "company idnr accnr consol"
					local num_list: list varlist - static_list
					ds
					local varlist = r(varlist)
					local long_list: list varlist - static_list

					/* Variable Loop */
					foreach var of local num_list {
						foreach v of local long_list {
							if "`var'" == "`v'" {
								local new_name = "`var'"
								local i = 0
							}

							if `i' < 10 {
								rename `v' `new_name'`i'
								local i = `i' +1
							}
						}
					/* Close: Variable List */
					}

				/* Reshape */
				drop if (accnr == "" & idnr == "") | (accnr == "n.a." & idnr == "n.a.") | (accnr == "Credit needed" & idnr == "Credit needed")
				reshape long `num_list', i(company idnr accnr consol) j(rel_year) string
				
				/* Drop missing */
				drop if statda == "" | statda == "n.a."
				
				/* Save Intermediate Data */
				cd "`output'/`section'"
				save intermediate_`year', replace
			
			/* Close: New Vintage */
			}
			
			/* Append Data */
			capture append using data_`year', force 
			
			/* Save Appended Data */
			save data_`year', replace
			
		/* Close: File Loop */
		}
		
		/* Reformat Variables */
		
			/* Obtain Variable List */
			ds
			local varlist = r(varlist)
			local char_list = "company idnr accnr consol statda"
			local num_list: list varlist - char_list
			
			/* Variable Loop */
			foreach var of local num_list {
				destring `var', replace ignore(",") force
			}	
		
		/* Save (by Country) */
		save "`country'_`section'_`year'", replace

		/* Deleting Intermediate Data */
		rm data_`year'.dta
		rm intermediate_`year'.dta
		
		/* Deleting Numlist Local */
		local num_list
		
	/* Close: Folder Loop */
	}

/* Close: Financials Section */
}	

********************************************************************************
**** (2) Importing: Company Sections										****
********************************************************************************

/* Section: Company */
if "`section'" == "Company" {

	/* Folder List */
	local folders: dir "`directory'/`year'/`section'" dirs "*"

	/* Folder Loop */
	foreach country of local folders {

		/* File List */
		local files: dir "`directory'/`year'/`section'/`country'" files "*"
	
		/* Vintage Condition: Old Vintage (2005-2007) */
		if `year' <= 2007 {
		
			/* File Loop */
			foreach file of local files {
			
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
			
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
				
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}
				
				/* Destring */
				destring ///
					months0* ///
					exchra0* ///
					unit0* ///
					opre0* ///
					pl0* ///
					empl0* ///
					hdr_mar ///
					onbr ///
					snbr ///
					, replace ignore(",")
					
				/* Rename */
				rename months* months
				rename exchra* exchrate
				rename unit* unit
				rename opre* opre_c
				rename pl* pl_c
				rename empl* empl_c
				
				/* Compress */
				compress
				
				/* Save Intermediate Data */
				cd "`output'/`section'"
				save intermediate_`year', replace
			
				/* Append Data */
				capture append using data_`year', force 
				
				/* Save Appended Data */
				save data_`year', replace
			
			/* Close: File Loop */
			}	
		
		/* Save (by Country) */
		save "`country'_`section'_`year'", replace

		/* Deleting Intermediate Data */
		rm data_`year'.dta
		rm intermediate_`year'.dta
		
		/* Close: Old Vintage (2005-2007) */
		}		
		
		/* Vintage Condition: Old Vintage (2008) */
		if `year' == 2008 {
		
			/* File Loop */
			foreach file of local files {
					
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
				
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
					
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}
 
				/* Destring */
				destring ///
					empl* ///
					opre* ///
					pl* ///
					onbr ///
					snbr ///
					hdr_mar ///
					months* ///
					exch* ///
					, replace ignore(",")
							
				/* Rename */
				rename months* months
				rename exchra* exchrate
				rename unit* unit_string
				rename opre* opre_c
				rename pl* pl_c
				rename empl* empl_c
				rename company company_name
				rename ad_name auditor_name
				rename idnr bvd_id_number
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Shareholders */
					preserve

						/* Keep shareholder information */
						keep accnr ult* d* is* shhtext oname oid oticker ocountry otype onace onaics odirect ototal osource odate ocldate ooprev ototas oempl
						
						/* Duplicates drop */
						duplicates drop accnr accnr ult* d* is* shhtext oname oid oticker ocountry otype onace onaics odirect ototal osource odate ocldate ooprev ototas oempl, force
						
						/* Save Intermediate Data */
						cd "`output'/Ownership"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Ownership_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Ownership_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore

					/* Subsidiaries */
					preserve

						/* Keep shareholder information */
						keep accnr subtext sname sid sticker scountry stype snace snaics sdirect stotal slevel sstatus ssource sdate scldate soprev subtast subempl
						
						/* Duplicates drop */
						duplicates drop accnr subtext sname sid sticker scountry stype snace snaics sdirect stotal slevel sstatus ssource sdate scldate soprev subtast subempl, force
						
						/* Save Intermediate Data */
						cd "`output'/Subsidiaries"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Subsidiaries_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Subsidiaries_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep mangers */
						keep accnr mg_*
						
						/* Duplicates drop */
						duplicates drop accnr mg_*, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop other */
						drop is* ult* d* mg_* shhtext oname oid oticker ocountry otype onace onaics odirect ototal osource odate ocldate ooprev ototas oempl subtext sname sid sticker scountry stype snace snaics sdirect stotal slevel sstatus ssource sdate scldate soprev subtast subempl
 
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2008) */
		}	
			
		/* Vintage Condition: Old Vintage (2009) */
		if `year' == 2009 {
		
			/* File Loop */
			foreach file of local files {
					
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
				
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
					
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}

				/* Destring */
				destring ///
					employees* ///
					operatingrevenueturnover* ///
					plforperiod** ///
					marketcapitalisation* ///
					noofrecordedshareholders ///
					noofrecsubsidiaries ///
					numberofmonthslast* ///
					exchangerate* ///
					, replace ignore(",")
							
				/* Rename */
				rename numberofmonthslast* months
				rename exchangerate* exchrate
				rename unit* unit_string
				rename operatingrevenueturnover* opre_c
				rename plforperiod* pl_c
				rename employees* empl_c
				rename marketcapital* hdr_mar
				rename noofrecordedshareholders onbr
				rename noofrecsubsidiaries snbr
				rename bvdepaccountnumber accnr
				rename companyname company_name
				rename auditorname auditor_name
				rename bvdepidnumber bvd_id_number
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Shareholders */
					preserve

						/* Keep shareholder information */
						keep accnr shareholder* domestic* immediate* global* v99 v114
						
						/* Duplicates drop */
						duplicates drop accnr shareholder* domestic* immediate* global* v99 v114, force
						
						/* Save Intermediate Data */
						cd "`output'/Ownership"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Ownership_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Ownership_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore

					/* Subsidiaries */
					preserve

						/* Keep shareholder information */
						keep accnr subsidiar*
						
						/* Duplicates drop */
						duplicates drop accnr subsidiar*, force
						
						/* Save Intermediate Data */
						cd "`output'/Subsidiaries"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Subsidiaries_`year'", force // note: drops information in using if string-numeric mismatch occurs
						
						/* Save Appended Data */
						save "`country'_Subsidiaries_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep bankers */
						keep accnr firstname middlename lastname fullname title salutation dateofbirth dateofbirth nationality homeaddress homecountry titlesince biography
						
						/* Duplicates drop */
						duplicates drop accnr firstname middlename lastname fullname title salutation dateofbirth dateofbirth nationality homeaddress homecountry titlesince biography, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop other */
						drop shareholder* domestic* immediate* global* v99 v114 subsidiar* firstname middlename lastname fullname title salutation dateofbirth dateofbirth nationality homeaddress homecountry titlesince biography
 
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2009) */
		}			
	
		/* Vintage Condition: Old Vintage (2010) */
		if `year' == 2010 {
		
			/* File Loop */
			foreach file of local files {

				/* Version 1 */
				capture {
					
					/* Error */
					local error = 1
					
					/* Import */
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(4) rowrange(5:) clear asdouble stringcols(_all) 
				
					/* Check Import */
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(4) rowrange(5:) clear asdouble stringcols(_all)
					}

					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(4) rowrange(5:) clear asdouble stringcols(_all)
					}
					
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(4) rowrange(5:) clear asdouble stringcols(_all)
					}
				
					/* Alternative variable names */
					
						/* Drop */
						drop v1
						
						/* Destring */
						destring ///
							oprevenuemileurlast* ///
							plforperiodmileurlast* ///
							marketcapitalisation* ///
							noofrecshareholders ///
							noofrecsubsidiaries ///
							peergroupsize ///
							numberofmonthslast* ///
							exchangeratefromlocalcurrencyeur ///
							, replace ignore(",")
							
						/* Rename */
						rename numberofmonthslast* months
						rename exchangeratefromlocalcurrencyeur exchrate
						rename accountunitlast* unit_string
						rename oprevenuemileurlast* opre_c
						rename plforperiodmileurlast* pl_c
						rename numberofemployeeslast* empl_c
						rename marketcapital* hdr_mar
						rename noofrecshareholders onbr
						rename noofrecsubsidiaries snbr
						rename bvdaccountnumber accnr
						rename companyname company_name
						rename auditorname auditor_name
						rename bvdidnumber bvd_id_number
						
						/* Error */
						local error = 0
				}
					
				/* Version 2: different datarows  */
				if `error' == 1  {
					
					/* Import */
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(16) rowrange(17:) clear asdouble stringcols(_all) 
				
					/* Check Import */
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(16) rowrange(17:) clear asdouble stringcols(_all)
					}

					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(16) rowrange(17:) clear asdouble stringcols(_all)
					}
					
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(16) rowrange(17:) clear asdouble stringcols(_all)
					}
				
					/* Alternative variable names */
					
						/* Drop */
						drop v1
						
						/* Destring */
						destring ///
							oprevenuemileurlast* ///
							plforperiodmileurlast* ///
							marketcapitalisation* ///
							noofrecshareholders ///
							noofrecsubsidiaries ///
							peergroupsize ///
							numberofmonthslast* ///
							exchangeratefromlocalcurrencyeur ///
							, replace ignore(",")
							
						/* Rename */
						rename numberofmonthslast* months
						rename exchangeratefromlocalcurrencyeur exchrate
						rename accountunitlast* unit_string
						rename oprevenuemileurlast* opre_c
						rename plforperiodmileurlast* pl_c
						rename numberofemployeeslast* empl_c
						rename marketcapital* hdr_mar
						rename noofrecshareholders onbr
						rename noofrecsubsidiaries snbr
						rename bvdaccountnumber accnr
						rename companyname company_name
						rename auditorname auditor_name
						rename bvdidnumber bvd_id_number
				}					
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Bankers */
					preserve

						/* Keep bankers */
						keep accnr banker*
						
						/* Duplicates drop */
						duplicates drop accnr banker*, force
						
						/* Save Intermediate Data */
						cd "`output'/Bankers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Bankers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Bankers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep bankers */
						keep accnr bm*
						
						/* Duplicates drop */
						duplicates drop accnr bm*, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop bankers & managers */
						drop banker* bm* 
						
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2010) */
		}			
	
		/* Vintage Condition: Old Vintage (2011) */
		if `year' == 2011 {
		
			/* File Loop */
			foreach file of local files {
			
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
			
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
				
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}
				
				/* Alternative variable names */
				
					/* Version 1 */
					capture {
						
						/* Drop */
						drop mark
						
						/* Destring */
						destring ///
							op_revenue_mil_eur_last* ///
							p_l_for_period_mil_eur_last* ///
							total_assets_mil_eur_last* ///
							current_market_capitalisation* ///
							no_of_recorded_shareholders ///
							no_of_recorded_subsidiaries ///
							peer_group_size ///
							number_of_months_last* ///
							var98 ///
							, replace ignore(",")
							
						/* Rename */
						rename number_of_months_last* months
						rename var98 exchrate
						rename account_unit_last* unit_string
						rename op_revenue_mil_eur_last* opre_c
						rename p_l_for_period_mil_eur_last* pl_c
						rename total_assets_mil_eur_last* at_c
						rename number_of_employees_last* empl_c
						rename current_market_capitalisation hdr_mar
						rename no_of_recorded_shareholders onbr
						rename no_of_recorded_subsidiaries snbr
						rename bvd_account_number accnr

					}
					
					/* Version 2 */
					capture {
					
						/* Drop */
						drop *mark
						
						/* Destring */
						destring ///
							oprevenuemileurlast* ///
							plforperiodmileurlast* ///
							totalassetsmileurlast* ///
							currentmarketcapitalisation* ///
							noofrecordedshareholders ///
							noofrecordedsubsidiaries ///
							peergroupsize ///
							numberofmonthslast* ///
							exchangeratefromlocalcurrencyeur ///
							, replace ignore(",")
							
						/* Rename */
						rename numberofmonthslast* months
						rename exchangeratefromlocalcurrencyeur exchrate
						rename accountunitlast* unit_string
						rename oprevenuemileurlast* opre_c
						rename plforperiodmileurlast* pl_c
						rename totalassetsmileurlast* at_c
						rename numberofemployeeslast* empl_c
						rename currentmarketcapitalisation hdr_mar
						rename noofrecordedshareholders onbr
						rename noofrecordedsubsidiaries snbr
						rename bvdaccountnumber accnr
						rename companyname company_name
						rename auditorname auditor_name
						rename bvdidnumber bvd_id_number
					}
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Bankers */
					preserve

						/* Keep bankers */
						keep accnr banker*
						
						/* Duplicates drop */
						duplicates drop accnr banker*, force
						
						/* Save Intermediate Data */
						cd "`output'/Bankers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Bankers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Bankers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep bankers */
						keep accnr dm*
						
						/* Duplicates drop */
						duplicates drop accnr dm*, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop bankers & managers */
						drop banker* dm* 
						
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2011) */
		}		
		
		/* Vintage Condition: New Vintage (2012) */
		if `year' >= 2012 {
			
			/* File Loop */
			foreach file of local files {
			
				/* Category */
				if regexm("`file'", "[0-9]+\.") == 1 {
					local category = "main"
				}
				
				if regexm("`file'", "[a-zA-Z]+\.") == 1 {
				
					qui di regexm("`file'", "[a-zA-Z]+\.")
					if substr(regexs(0), 1, 2) == "nr" {
						local category = substr(regexs(0), 3, length(regexs(0))-3)
					}

					if substr(regexs(0), 1, 4) == "nrof" {
						local category = substr(regexs(0), 5, length(regexs(0))-5)
					}
					
					if substr(regexs(0), 1, 2) != "nr" {
						local category = substr(regexs(0), 1, length(regexs(0))-1)
					}
				}

				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(tab) varnames(1) clear stringcols(_all)
			
				/* Check Import */
				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(".") varnames(1) clear stringcols(_all)
				}

				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(";") varnames(1) clear stringcols(_all)
				}

				/* Compress */
				compress
				
				/* Rename */
				capture rename ïrecord_id record_id
				
				/* Company data */
				if 	///
					regexm("`category'", "auditor") == 0 & ///
					regexm("`category'", "code") == 0 & ///
					regexm("`category'", "additional") == 0 & ///
					regexm("`category'", "banker") == 0 & ///
					regexm("`category'", "contacts") == 0 & ///
					regexm("`category'", "shareholder") == 0 & ///
					regexm("`category'", "subsidiar") == 0 & ///
					regexm("`category'", "acronym") == 0 & ///
					regexm("`category'", "nace") == 0 & ///
					regexm("`category'", "naics") == 0 & ///
					regexm("`category'", "national") == 0 & ///
					regexm("`category'", "email") == 0 & ///
					regexm("`category'", "faxes") == 0 & ///
					regexm("`category'", "identifiers") == 0 & ///
					regexm("`category'", "years") == 0 & ///
					regexm("`category'", "phones") == 0 & ///
					regexm("`category'", "website") == 0 & ///
					regexm("`category'", "previous") == 0 & ///
					regexm("`category'", "sic") == 0 {
				
					/* Save Intermediate Data */
					cd "`output'/`section'"
					if "`category'" != "main" {
						save intermediate_`year'_`category', replace
						local categories: list categories | category 
					}
					
					/* Merge, Append, & Save */
					if "`category'" == "main" { 
						/* Merge */
						foreach c of local categories {
							merge m:m record_id using intermediate_`year'_`c'
							drop _merge
							rm intermediate_`year'_`c'.dta
						}
					
						/* Append Data*/
						capture append using "`country'_`section'_`year'", force
						
						/* Save */
						save "`country'_`section'_`year'", replace
						
						/* Reset local */
						local categories
					}
				}

				/* Auditor data */
				if regexm("`category'", "auditor") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Auditors"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Auditors_`year'", force
					save "`country'_Auditors_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}				
				
				
				/* Banker data */
				if regexm("`category'", "banker") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Bankers"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Bankers_`year'", force
					save "`country'_Bankers_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Manager data */
				if regexm("`category'", "contacts") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Managers"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Managers_`year'", force
					save "`country'_Managers_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Ownership data */
				if regexm("`category'", "shareholder") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Ownership"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Ownership_`year'_`category'", force
					save "`country'_Ownership_`year'_`category'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Subsidiary data */
				if regexm("`category'", "subsidiar") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Subsidiaries"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Subsidiaries_`year'_`category'", force
					save "`country'_Subsidiaries_`year'_`category'", replace
				
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				}
	
				/* Subsidiary data */
				if ///
					regexm("`category'", "acronym") == 1 | ///
					regexm("`category'", "nace") == 1 | ///
					regexm("`category'", "naics") == 1 | ///
					regexm("`category'", "national") == 1 | ///
					regexm("`category'", "email") == 1 | ///
					regexm("`category'", "faxes") == 1 | ///
					regexm("`category'", "identifiers") == 1 | ///
					regexm("`category'", "years") == 1 | ///
					regexm("`category'", "phones") == 1 | ///
					regexm("`category'", "website") == 1 | ///
					regexm("`category'", "previous") == 1 | ///
					regexm("`category'", "code") == 1 | ///
					regexm("`category'", "additional") == 1 | ///
					regexm("`category'", "sic") == 1 {

					/* Save Intermediate Data */
					cd "`output'/Other"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Other_`year'_`category'", force
					save "`country'_Other_`year'_`category'", replace
				
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				}
				
			/* Close: File Loop */
			}
	
		/* Deleting Intermediate Data */
		cd "`output'/`section'"
		cap rm intermediate_`year'.dta
					
		/* Close: New Vintage */
		}
		
	/* Close: Folder Loop */
	}

/* Close: Company Section */
}	

********************************************************************************
**** (3) Importing: Ownership and Subsidiaries Sections						****
********************************************************************************

/* Section: Ownership */
if "`section'" == "Ownership" | "`section'" == "Subsidiaries" {

	/* Folder List */
	local folders: dir "`directory'/`year'/`section'" dirs "*"
	
	/* Folder Loop */
	foreach country of local folders {

		/* File List */
		local files: dir "`directory'/`year'/`section'/`country'" files "*"

		/* Vintage Condition: New Vintage (2012) */
		if `year' >= 2012 {
			
			/* File Loop */
			foreach file of local files {
		
				/* Category */
				if regexm("`file'", "[0-9]+\.") == 1 {
					local category = "main"
				}
				
				if regexm("`file'", "[a-zA-Z]+\.") == 1 {
				
					qui di regexm("`file'", "[a-zA-Z]+\.")
					if substr(regexs(0), 1, 2) == "nr" {
						local category = substr(regexs(0), 3, length(regexs(0))-3)
					}

					if substr(regexs(0), 1, 4) == "nrof" {
						local category = substr(regexs(0), 5, length(regexs(0))-5)
					}
					
					if substr(regexs(0), 1, 2) != "nr" {
						local category = substr(regexs(0), 1, length(regexs(0))-1)
					}
				}

				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(tab) varnames(1) clear stringcols(_all)
			
				/* Check Import */
				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(".") varnames(1) clear stringcols(_all)
				}

				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(";") varnames(1) clear stringcols(_all)
				}

				/* Compress */
				compress
				
				/* Rename */
				capture rename ïrecord_id record_id

				/* Main ownership data */
				if regexm("`category'", "main") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/`section'"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_`section'_`year'", force
					save "`country'_`section'_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				
				}				
				
				/* Ownership data */
				if regexm("`category'", "shareholder") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Ownership"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Ownership_`year'_`category'", force
					save "`country'_Ownership_`year'_`category'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Subsidiary data */
				if regexm("`category'", "subsidiar") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Subsidiaries"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Subsidiaries_`year'_`category'", force
					save "`country'_Subsidiaries_`year'_`category'", replace
				
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				}
				
			/* Close: File Loop */
			}
					
		/* Close: New Vintage */
		}
		
	/* Close: Folder Loop */
	}

/* Close: Ownership Section */
}	
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		12/07/2020													****
**** Program:	Analyses													****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Data.dta")		

********************************************************************************
**** (1) Sample selection and variable truncation							****
********************************************************************************

/* Data */
use Data, clear

/* Duplicates drop */
duplicates drop ci year, force

/* Sample period */
keep if year >= 2001 & year <= 2015

/* Panel */
xtset ci year

/* Variable list

Manuscript labels (Table 2):
	mc_scope		= Standardized Reporting Scope
	mc_audit		= Standardized Auditing Scope
	scope			= Actual Reporting Scope
	audit_scope		= Actual Auditing Scope
	m_audit			= Audit (Average)
	m_listed		= Publicly Listed (Average)
	w_listed		= Public Listed (Aggregate)
	m_shareholder	= Shareholders (Average)
	w_shareholder	= Shareholders (Aggregate)
	m_indep			= Independence (Average)
	w_indep			= Independence (Aggregate)
	m_entry			= Entry (Average)
	w_entry			= Entry (Aggregate)
	m_exit			= Exit (Average)
	w_exit			= Exit (Aggregate)
	hhi				= HHI
	cv_markup		= Dispersion (Gross Margin)
	sr_markup		= Distance (Gross Margin)
	cv_margin		= Dispersion (EBITDA/Sales)
	sr_margin		= Distance (EBITDA/Sales)
	cv_tfp_e		= Dispersion (TFP (Employees))
	sr_tfp_e		= Distance (TFP (Employees))
	p20_tfp_e		= Lower Tail (TFP (Employees))
	p80_tfp_e		= Upper Tail (TFP (Employees))
	cv_tfp_w		= Dispersion (TFP (Wage))
	sr_tfp_w		= Distance (TFP (Wage))
	p20_tfp_w		= Lower Tail (TFP (Wage))
	p80_tfp_w		= Upper Tail (TFP (Wage))
	cov_lp_e		= Covariance Y/L and Y (Employees)
	cov_tfp_e		= Covariance TFP and Y (Employees)
	cov_lp_w		= Covariance Y/L and Y (Wage)
	cov_tfp_w		= Covariance TFP and Y (Wage)
	m_lp_e			= Y/L (Employees) (Average)
	m_lp_w			= Y/L (Wage) (Average)
	m_tfp_e			= TFP (Employees) (Average)
	m_tfp_w			= TFP (Wage) (Average)
	w_lp_e			= Y/L (Employees) (Aggregate)
	w_lp_w			= Y/L (Wage) (Aggregate)
	w_tfp_e			= TFP (Employees) (Aggregate)
	w_tfp_w			= TFP (Wage) (Aggregate)
	dm_lp_e			= delta Y/L (Employees) (Average)
	dm_lp_w			= delta Y/L (Wage) (Average)
	dm_tfp_e		= delta TFP (Employees) (Average)
	dm_tfp_w		= delta TFP (Wage) (Average)
	dw_lp_e			= delta Y/L (Employees) (Aggregate)
	dw_lp_w			= delta Y/L (Wage) (Aggregate)
	dw_tfp_e		= delta TFP (Employees) (Aggregate)
	dw_tfp_w		= delta TFP (Wage) (Aggregate)

Notes:
	mc_ 		= prefix denoting simulated/standardized scopes (i.e., Monte Carlo simulation based scopes)
	m_ 			= prefix for equally-weighted mean
	w_			= prefix for sales-share-weighted total
	sr_			= prefix for standardized distance or range ((p80-p20)/mean)
	cv_			= prefix for coefficient of variation (standard deviation/mean)
	p20_		= prefix for 20th percentile
	p80_		= prefix for 80th percentile
	dm_			= prefix for mean growth (delta of mean)
	dw_ 		= prefix for aggregate growth (delta of sales-weighted total)
	_e			= suffix for employees-based measure (e.g., TFP calculated with number of employees as input)
	_w			= suffix for wage-based measure (e.g., TFP calculated with wage expense as input)
*/

	/* All outcomes */
	local All = "scope audit_scope m_audit m_listed w_listed m_shareholder w_shareholder m_indep w_indep m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w m_lp_e m_lp_w m_tfp_e m_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

	/* All second stage outcomes (excludes: scope and audit_scope) */
	local All_2SLS = "m_audit m_listed w_listed m_shareholder w_shareholder m_indep w_indep m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w m_lp_e m_lp_w m_tfp_e m_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

/* Panel: country-industry year */
xtset ci year

********************************************************************************
**** Table 1: Descriptive Statistics										****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_1.smcl, replace smcl name(Table_1) 

/* Descriptives */

	/* Financial reporting */
	local descriptives = "mc_scope mc_audit scope audit_scope m_audit"
	tabstat `descriptives' if mc_scope != . & mc_audit != . ///
		, col(stats) stat(N mean sd p10 p25 p50 p75 p90)
	
	/* Type of resource allocation */
	local descriptives = "m_listed w_listed m_shareholder w_shareholder m_indep w_indep m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin"
	tabstat `descriptives' if mc_scope != . & mc_audit != . ///
		, col(stats) stat(N mean sd p10 p25 p50 p75 p90)
		
	/* Efficiency of resource allocation */
	local descriptives = "cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w m_lp_e m_lp_w m_tfp_e m_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"
	tabstat `descriptives' if mc_scope != . & mc_audit != . ///
		, col(stats) stat(N mean sd p10 p25 p50 p75 p90)

/* Log file: close */
log close Table_1

********************************************************************************
**** Table 2: Standardized Scope and Actual Scope							****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_2.smcl, replace smcl name(Table_2) 		
	
/* Regression inputs */
local DepVar = "scope audit_scope m_audit"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_2	
	
********************************************************************************
**** Table 3: Standardized Scope and Ownership Concentration				****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_3.smcl, replace smcl name(Table_3) 		
		
/* Regression inputs */
local DepVar = "m_listed w_listed m_shareholder w_shareholder m_indep w_indep"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_3		
	
********************************************************************************
**** Table 4: Standardized Scope and Product-Market Competition				****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_4.smcl, replace smcl name(Table_4) 		
		
/* Regression inputs */
local DepVar = "m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_4	
	
********************************************************************************
**** Table 5: Standardized Scope, Revenue-Productivity Dispersion, and		****
****          Size-Productivity Covariance,  and Product-Market Competition	****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_5.smcl, replace smcl name(Table_5) 		
		
/* Regression inputs */
local DepVar = "cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cov_lp_e cov_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_w cov_tfp_w"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_5		
	
********************************************************************************
**** Table 6: Standardized Scope and Revenue Productivity					****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_6.smcl, replace smcl name(Table_6) 		
		
/* Regression inputs */
local DepVar = "m_lp_e m_lp_w m_tfp_e m_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_6	
		
********************************************************************************
**** Table 7: Correlated Factors											****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_7.smcl, replace smcl name(Table_7) 

/* Regression inputs */
local DepVar = "scope"
local CIY = "firms m_sales m_empl m_fias hhi"

/* Loop */
foreach y of varlist `DepVar' {

	/* Estimation */
	qui reghdfe mc_`y' `CIY' if `y'!=., a(cy iy) cluster(ci_cluster cy)
		est store M1
			
	qui reghdfe `y' `CIY' if mc_`y'!=., a(cy iy) cluster(ci_cluster cy)
		est store M2

				
	/* Output */
	estout M1 M2, cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
		legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE") ///
		mlabels(, depvars) varwidth(40) modelwidth(20) unstack ///
		stats(N N_clust1 N_clust2 r2_within, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "R-Squared (Within)"))			
			
}

/* Log file: close */
log close Table_7	
	
********************************************************************************
**** Table A2: Standardized Reporting and Auditing Scopes by Country + Year	****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A2.smcl, replace smcl name(Table_A2) 	
	
	
/* Scope by year */
forvalue y = 2001(1)2015 {
	di "Year: " `y'
	tabstat mc_scope mc_audit if year == `y', by(country) format(%9.2f)
}

/* Log file: close */
log close Table_A2

********************************************************************************
**** Table A5: Second Stage Estimates (IV)							 		****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A5.smcl, replace smcl name(Table_A5) 

/* Regression inputs */
local DepVar = "`All_2SLS'"

/* Regression: country-year + industry-year fixed effects (scope + audit) [IV] */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui ivreghdfe `y' (scope audit_scope = mc_scope mc_audit), a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(scope audit_scope) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [IV]") ///
				varlabels(scope "Instrumented Reporting Scope" audit_scope "Instrumented Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}

/* Log file: close */
log close Table_A5

********************************************************************************
**** Table A6: Firm Density and Resource Allocation					 		****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A6.smcl, replace smcl name(Table_A6) 

/* Regression inputs */
local DepVar = "`All'"

/* Regression: country-year + industry-year fixed effects (firms + firms^2) */
foreach y of varlist `DepVar' {
			
	/* Preserve */
	preserve
			
		/* Firms (squared) */
		gen firms_2 = firms^2
		label var firms_2 "Number of Firms (squared)"
			
		/* Capture */
		capture noisily {
				
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=. & firms!=., a(cy iy) residual(r_`y')
			qui reghdfe firms if `y'!=. & mc_audit!=. & firms!=., a(cy iy) residual(r_firms)
			qui reghdfe firms_2 if `y'!=. & mc_scope!=. & firms!=., a(cy iy) residual(r_firms_2)
					
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
					
			qui sum r_firms, d
			qui replace firms = . if r_firms < r(p1) | r_firms > r(p99)		
		
			qui sum r_firms_2, d
			qui replace firms_2 = . if r_firms_2 < r(p1) | r_firms_2 > r(p99)
				
			/* Estimation */
			qui reghdfe `y' firms firms_2, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(firms firms_2) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Aggregate Growth Validation]") ///
				mlabels(, depvar) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
					
		}
			
	/* Restore */
	restore
}

/* Log file: close */
log close Table_A6

********************************************************************************
**** Table A7: Interaction of Reporting and Auditing Mandates				****
********************************************************************************

/* Interactions */
qui gen mc_scope_unc = 0 if mc_scope != .
qui replace mc_scope_unc = mc_scope if mc_scope > mc_audit
label var mc_scope_unc "Reporting (w/o Auditing)"

qui gen mc_scope_con = 0 if mc_scope != .
qui replace mc_scope_con = mc_scope if mc_scope <= mc_audit
label var mc_scope_con "Reporting (w/ Auditing)"

qui gen mc_audit_unc = 0 if mc_audit != .
qui replace mc_audit_unc = mc_audit if mc_scope < mc_audit
label var mc_audit_unc "Auditing (w/o Reporting)"

qui gen mc_audit_con = 0 if mc_audit != .
qui replace mc_audit_con = mc_audit if mc_scope >= mc_audit
label var mc_audit_con "Auditing (w/ Reporting)"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A7.smcl, replace smcl name(Table_A7) 

/* Regression inputs */
local DepVar = "`All'"
	
/* Regression: country-year + industry-year fixed effects (scope + audit) [jointly] */
foreach y of varlist `DepVar' {
					
	/* Preserve */
	preserve

		/* Capture */
		capture noisily {
				
			/* Truncation */
			qui reghdfe `y' if mc_scope_unc!=. & mc_scope_con!=. & mc_audit_unc!=. & mc_audit_con!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope_unc if `y'!=. & mc_scope_con!=. & mc_audit_unc!=. & mc_audit_con!=., a(cy iy) residual(r_mc_scope_unc)
			qui reghdfe mc_scope_con if `y'!=. & mc_scope_unc!=. & mc_audit_unc!=. & mc_audit_con!=., a(cy iy) residual(r_mc_scope_con)
			qui reghdfe mc_audit_unc if `y'!=. & mc_scope_unc!=. & mc_scope_con!=. & mc_audit_con!=., a(cy iy) residual(r_mc_audit_unc)
			qui reghdfe mc_audit_con if `y'!=. & mc_scope_unc!=. & mc_scope_con!=. & mc_audit_unc!=., a(cy iy) residual(r_mc_audit_con)
			
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
					
			qui sum r_mc_scope_unc, d
			qui replace mc_scope_unc = . if r_mc_scope_unc < r(p1) | r_mc_scope_unc > r(p99)		

			qui sum r_mc_scope_con, d
			qui replace mc_scope_con = . if r_mc_scope_con < r(p1) | r_mc_scope_con > r(p99)
					
			qui sum r_mc_audit_unc, d
			qui replace mc_audit_unc = . if r_mc_audit_unc < r(p1) | r_mc_audit_unc > r(p99)		

			qui sum r_mc_audit_con, d
			qui replace mc_audit_con = . if r_mc_audit_con < r(p1) | r_mc_audit_con > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope_unc mc_scope_con mc_audit_unc mc_audit_con, a(cy iy) cluster(ci_cluster cy)
						
			/* Output */
			estout, keep(mc_scope_unc mc_scope_con mc_audit_unc mc_audit_con) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
	
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_A7

********************************************************************************
**** Supplemental information: Instrument F-stat, number of firms, and		****
****						   conditional standard deviations		 		****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Supplement.smcl, replace smcl name(Supplement) 

/* First stage F-staticts (instrument) */

	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe firms if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_firms)
			qui reghdfe mc_scope if firms!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if firms!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_firms, d
			qui replace firms = . if r_firms < r(p1) | r_firms > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			ivreghdfe firms (scope audit_scope = mc_scope mc_audit), a(cy iy) cluster(ci_cluster cy) ffirst
						
		}
		
	/* Restore */
	restore

/* Total number of firm-years */

	/* Preserve */
	preserve
	
		/* Exponentiate */
		qui gen number = exp(firms)
		
		/* Total */
		qui egen double total = total(number)
		
		/* Sum */
		qui sum total
		local sum = r(mean)
		
		/* Display */
		di "Total number of firm-year observations: " `sum'
		
	/* Restore */
	restore
	

/* Conditional standard deviation (covariance and growth) */
local DepVar = "cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace r_`y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Sum */
			sum r_`y' if mc_scope != . & mc_audit != . & ci_cluster != . & cy != . & iy != .
						
		}
		
	/* Restore */
	restore
}	

/* Log file: close */	
log close Supplement
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Panel of Amadeus ID and other static items 					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // insert directory for raw data

**** Project ****
project, original("`directory'\Amadeus\Amadeus_ID.txt")
project, original("`directory'\Amadeus\correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format.dta")

********************************************************************************
**** (1) Creating BvD ID and industry correspondence tables					****
********************************************************************************

/* BvD ID changes */

	/* Correspondence table */
	cd "`directory'\Amadeus"
	import delimited using Amadeus_ID.txt, delimiter(tab) varnames(1) clear

	/* Rename */
	rename oldid bvd_id
	
	/* Save */
	save Amadeus_ID, replace
		
	/* Project */
	project, creates("`directory'\Amadeus\Amadeus_ID.dta")

/* Industry (NACE) correspondence (Sebnem et al. (2015)) */

	/* Correspondence table */
	cd "`directory'\Amadeus"
	use correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format, clear

	/* Keep relevant variables */
	keep nacerev11 nacerev2
	
	/* Destring code */
	destring nacerev11 nacerev2, ignore(".") replace force
	
	/* Keep if non-missing */
	keep if nacerev11 != . & nacerev2 != .
	
	/* Rename */
	rename nacerev11 nace_ind
	rename nacerev2 nace2_ind_corr
	
	/* Save */
	save NACE_correspondence, replace
	
	/* Project */
	project, creates("`directory'\Amadeus\NACE_correspondence.dta")
	
********************************************************************************
**** (1) Constructing panel data by country									****
********************************************************************************

/* Sample countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop (loading data, keeping relevant variables, saving in local folder) */
foreach country of local countries {

	/* Delete existing data */
	cd "`directory'\Amadeus"
	cap rm Company_`country'.dta	
		
	forvalues year = 2005(1)2016 {	
		
		/* Delete */
		cap rm Auditors.dta
		cap rm Owners.dta
		
		/* Capture */
		capture noisily {
		
			/* Project */
			project, original("`data'\Company/`country'_Company_`year'.dta")

			/* Data */
			cd "`data'\Company"
			use `country'_Company_`year', clear
			
			/* Vintage */
			gen vintage = `year'
			label var vintage "Vintage (BvD Disc)"			
			
			/* Renaming, keeping relevant variables, merging missing variables */
			if `year' == 2005 {
			
				/* Rename */
				rename idnr bvd_id
				rename nacpri nace_ind
				
				/* Keep (only keep empl_c; no unit issues) */
				keep bvd_id company lstatus type quoted repbas typacc dateinc empl_c onbr indepind ad_name nace_ind consol vintage
				
				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol ad_name, replace force
				destring nace_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				cap rm Company_`country'.dta
				save Company_`country', replace

			}
			if `year' == 2006 {
			
				/* Rename */
				rename idnr bvd_id
				rename nacpri nace_ind
				
				/* Keep */
				keep bvd_id company lstatus type quoted repbas typacc dateinc empl_c onbr indepind ad_name nace_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol ad_name, replace force
				destring nace_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}			
			if `year' == 2007 {
			
				/* Rename */
				rename idnr bvd_id
				rename accpra* accpra
				rename nacpri nace_ind
				
				/* Keep */
				keep bvd_id company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol ad_name, replace force
				destring nace_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2008 {
			
				/* Rename */
				rename bvd_id_number bvd_id
				rename company_name company
				rename auditor_name ad_name
				rename accpra* accpra
				rename nac2pri nace2_ind

				/* Keep (w/o dateinc) */
				keep bvd_id company lstatus type quoted repbas accpra typacc empl_c onbr indepind ad_name nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas accpra typacc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2009 {
			
				/* Rename */
				rename bvd_id_number bvd_id
				rename legalstatus lstatus
				rename legalform type
				rename publiclyquoted quoted
				rename reportingbasis repbas
				rename typeofaccount* typacc
				rename accountingpractice* accpra
				rename dateofincorporation dateinc
				rename bvdepindependenceindicator indepind
				rename auditor_name ad_name
				rename nacerev2primarycode nace2_ind
				rename consol* consol
				
				/* Keep */
				keep bvd_id company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas accpra typacc dateinc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2010 {
				
				/* Rename */
				rename bvd_id_number bvd_id
				rename company_name company
				rename legalstatus lstatus
				rename legalform type
				rename publiclyquoted quoted
				rename dateofincorporation dateinc
				rename reportingbasis repbas
				rename typeofaccountavailable typacc
				rename accountingpractice* accpra
				rename bvdindependenceindicator indepind
				rename auditor_name ad_name
				rename nacerev2primarycode nace2_ind
				rename conscode consol
				
				/* Keep */
				keep bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace2_ind consol vintage
				
				/* Format */
				tostring bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Add further variables from separate files */
				
					/* Number of banks */
					capture {
					
						/* Data */
						cd "`data'\Bankers"
						use `country'_Bankers_`year', clear
						
						/* Keep */
						keep accnr b*
						
						/* Convert to string */
						cap tostring b*, replace force
						
						/* Drop missing */
						drop if b == ""
						
						/* Count banks */
						egen banks = count(accnr), by(accnr)
						
						/* Keep */
						keep accnr banks
						
						/* Duplicates */
						sort accnr banks
						duplicates drop accnr, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Bankers, replace
					}
					
					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					capture {	
						merge m:1 accnr using Bankers
						drop if _merge == 2
						drop _merge
					}
					
					/* Drop */
					drop accnr
					
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace	
				
			}
			if `year' == 2011 {
			
				/* Rename */
				rename bvd_id_number bvd_id
				rename company_name company
				cap rename legalstatus lstatus
				cap rename legal_status lstatus
				cap rename nationallegalform type
				cap rename national_legal_form type
				cap rename dateofincorporation dateinc
				cap rename date_of_incorporation dateinc
				cap rename publiclyquoted quoted
				cap rename publicly_quoted quoted
				cap rename reportingbasis repbas
				cap rename reporting_basis repbas
				cap rename typesofaccountsavailable typacc
				cap rename type_s__of_accounts* typacc
				rename accounting* accpra
				cap rename bvdindependenceindicator indepind
				cap rename bvd_indep* indepind
				rename auditor_name ad_name
				cap rename nacerev2primarycode nace2_ind
				cap rename nace_rev__2_primary_code nace2_ind
				cap rename cons* consol

				/* Keep */
				keep bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace2_ind consol vintage

				/* Format */
				tostring bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge

				/* Drop */
				drop accnr
					
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
			
			}
			if `year' == 2012 {

				/* Rename */
				rename idnr bvd_id
				rename name company
				rename quoted_str quoted
				rename nac2pri nace2_ind
				rename v30 indepind
				rename v31 onbr
				
				/* Keep */
				keep bvd_id record_id company lstatus type quoted repbas typacc dateinc indepind onbr nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring onbr nace2_ind, replace force ignore(",")

				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Add further variables from separate files */
				
					/* Auditor name */
						
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep record_id ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort record_id ad_name
						duplicates drop record_id, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace

					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					merge m:1 record_id using Auditors
					drop if _merge == 2
					drop _merge
					
					/* Drop */
					drop record_id
					
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace				
			}
			if `year' == 2013 {

				/* Rename */
				rename idnr bvd_id
				rename name company
				rename quoted_str quoted
				rename header_empl empl_c
				rename nac2pri nace2_ind
				rename v73 indepind
				rename v74 onbr
				
				/* Keep */
				keep record_id bvd_id company lstatus type quoted repbas typacc dateinc indepind onbr empl_c nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring onbr nace2_ind empl_c, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Add further variables from separate files */
				
					/* Auditor name */
						
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep record_id ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort record_id ad_name
						duplicates drop record_id, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace

					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					merge m:1 record_id using Auditors
					drop if _merge == 2
					drop _merge
					
					/* Drop */
					drop record_id
				
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2014 | `year' == 2015 {

				/* Rename */
				rename idnr bvd_id
				rename name company
				rename quoted_str quoted
				rename header_empl empl_c
				rename historic_status_str_lastyear lstatus
				rename v33 indepind
				rename v35 onbr
				rename nac2pri nace2_ind
				
				/* Keep */
				keep bvd_id record_id company lstatus type quoted repbas typacc dateinc empl_c indepind onbr nace2_ind consol vintage 

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring onbr nace2_ind empl_c, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
	
				/* Add further variables from separate files */
				
					/* Auditor name */
						
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep record_id ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort record_id ad_name
						duplicates drop record_id, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace
					
					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					merge m:1 record_id using Auditors
					drop if _merge == 2
					drop _merge

					/* Drop */
					drop record_id					
					
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace		
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
			}			
			if `year' == 2016 {
			
				/* Rename */
				rename name company
				rename repbas_header repbas
				drop dateinc
				rename dateinc_char dateinc
				rename nace_prim_code nace2_ind
				
				/* Keep */
				keep idnr company lstatus type quoted repbas typacc dateinc indepind nace2_ind consol vintage

				/* Format */
				tostring company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring nace2_ind, replace force ignore(",")
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace

			/* Add further variables from separate files */
				
					/* Auditor name */
					capture {
					
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep idnr ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort idnr ad_name
						duplicates drop idnr, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace
					}
					
					/* Ownership */
					
						/* Data */
						cd "`data'\Ownership"
						use `country'_Ownership_`year', clear
						
						/* Keep */
						keep idnr sh_name
						tostring sh_name, replace force
						drop if sh_name == ""
						
						/* Duplicates */
						sort idnr sh_name
						duplicates drop idnr sh_name, force
						
						/* Number of recorded shareholders */
						egen onbr = count(sh_name), by(idnr)
						
						/* Duplicates */
						duplicates drop idnr, force
						
						/* Drop */
						drop sh_name
						
						/* Save */
						cd "`directory'\Amadeus"
						save Owners, replace
					
					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					capture {
						merge m:1 idnr using Auditors
						drop if _merge == 2
						drop _merge
					}
					
					merge m:1 idnr using Owners
					drop if _merge == 2
					drop _merge	
					
					/* Rename */
					rename idnr bvd_id					
						
					/* Merge: prior ID */
					cd "`directory'\Amadeus"				
					merge m:1 bvd_id using Amadeus_ID
					drop if _merge == 2
					drop _merge
				
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace		
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
			}
						
		/* End: Capture */
		}
		
	/* End: Vintage/year loop */
	}
				
	/* Country */
	gen country = "`country'"
	replace country = "Czech Republic" if country == "Czech_Republic"
	replace country = "United Kingdom" if country == "United_Kingdom"
	label var country "Country"
		
	/* BvD ID definition */
	
		/* Latest ID */
		
			/* Update */
			rename bvd_id bvd_id_h
			gen bvd_id = bvd_id_h
			replace bvd_id = newid if newid != ""
			drop newid

			/* Mode */
			egen mode = mode(bvd_id), by(bvd_id_h)
			replace bvd_id = mode if bvd_id == ""
			drop mode
			
			/* Rename */
			rename bvd_id bvd_id_new
			rename bvd_id_h bvd_id	
			
	/* Sample restriction & ID */
	drop if bvd_id == "" & bvd_id_new == ""
	egen double id = group(bvd_id_new)

	/* Duplicates (tag) */
	duplicates tag id vintage, gen(dup)

	/* Drop: missing location or industry if duplicate */
	drop if dup > 0 & (nace_ind == . & nace2_ind == .)
	
	/* Consolidation: avoid duplication (drop duplicates associated with C2 (or C for 2016)) */
	gen con = (consol == "C2" | consol == "C")
	egen c2 = max(con), by(id)
	drop if dup != 0 & (consol != "C2" | consol != "C") & c2 == 1
	sort id vintage dup
	duplicates drop id vintage if dup != 0, force
	drop dup con c2

	/* Duplicates (drop) */
	sort id vintage
	duplicates drop id vintage, force
	
	/* Panel definition */
	xtset id vintage
	
	/* Industry definition */
	
		/* Merge: Industry correspondence */
		merge m:1 nace_ind using NACE_correspondence
		drop if _merge ==2
		drop _merge

		/* Generate converged industry */
		gen industry = nace2_ind
		label var industry "Industry (NACE rev 2)"
		
		/* Backfilling (using panel information) */
		xtset id vintage
		forvalues y = 1(1)11 {
			replace industry = f.industry if industry == . & f.industry != . & vintage == 2016 - `y'
		}

		/* Filling in missing values (using correspondence table) */
		replace industry = nace2_ind_corr if industry == .
		drop nace*

		/* Mode: Filling in missing values (using mode of industry code per firm) */
		egen industry_mode = mode(industry), by(id)
		replace industry = industry_mode if industry == .
		drop industry_mode
		
		/* Drop missing industry */
		drop if industry == .
		
	/* Clean auditor name */
	replace ad_name = "" if ad_name == "."
	
	/* Replace missing incorporation date (esp. 2008) */
	egen mode = mode(dateinc), by(id)
	replace dateinc = mode
	drop mode
	
	/* Drop */
	drop id
	
	/* Save */
	save Company_`country', replace	

	/* Project	*/
	project, creates("`directory'\Amadeus\Company_`country'.dta")

/* End: Country loop */
}

/* Delete intermediate data */
cd "`directory'\Amadeus"
cap rm Intermediate.dta
cap rm Auditors.dta
cap rm Owners.dta
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation 	****
**** Author:	M. Breuer													****
**** Date:		02/13/2017													****
**** Program:	Data for analyses											****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Outcomes.dta")	
project, uses("`directory'\Data\Scope.dta")	

********************************************************************************
**** (1) Combining data														****
********************************************************************************

/* Data */
use Outcomes, clear

/* Merge: Scope (Treatment) */
merge 1:1 country industry year using Scope
keep if _merge == 3
drop _merge

/* Merge: Regulation */
merge m:1 country year using Regulation
drop if _merge == 2
drop _merge

********************************************************************************
**** (2) Remaining variables												****
********************************************************************************

/* Other regulations */

	/* EU */
	gen EU = (year >= eu_date)
	label var EU "EU Member"
	
	/* EURO */
	gen EURO = (year >= euro_date)
	label var EURO "EURO Member"
	
	/* IFRS */
	gen ifrs_year = substr(ifrsdate, -4, 4)
	destring ifrs_year, force replace
	gen IFRS = (year >= ifrs_year)
	label var IFRS "IFRS Directive"
	drop ifrs_year
	
	/* TPD */
	gen TPD = (year >= tpdyear)
	label var TPD "TPD Directive"
	
	/* MAD */
	gen MAD = (year >= madyear)
	label var MAD "MAD Directive"

/* Exemptions */

	/* Preparation */
	egen preparation = rowtotal(bs_preparation_abridged is_preparation_abridged notes_preparation_abridged), missing
	label var preparation "Preparation exemptions (Small)"

	/* Publication */
	egen publication = rowtotal(bs_publication is_publication notes_publication), missing
	replace publication = 3 - publication
	label var publication "Publication exemptions (Small)"

	/* Combined exemptions */
	gen exemptions = (preparation + publication)/6
	label var exemptions "Exemptions (Small)"

********************************************************************************
**** (3) Country, industry, year indicator									****
********************************************************************************

/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Year */
egen y = group(year)
label var y "Year ID"

/* Country-industry */
egen ci = group(c i)
label var ci "Country-industry ID"

/* Country-year */
egen cy = group(c y)
label var cy "Country-year ID"

/* Industry-year */
egen iy = group(i y)
label var iy "Industry-year ID"

/* Cluster */
gen i_1 = floor(industry/1000)
egen ci_cluster = group(c i_1)
label var ci_cluster "Country-industry cluster (1-Digit)"
drop i_1

********************************************************************************
**** (4) Cleaning and saving												****
********************************************************************************

/* Save */
save Data, replace

/* Project */
project, creates("`directory'\Data\Data.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Installs external (user-written) programs					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

********************************************************************************
**** (1) Install external programs											****
********************************************************************************

**** Estout ****
ssc install estout, replace

**** Coefplot ****
ssc install coefplot, replace

**** Outreg2 ****
ssc install outreg2, replace

**** Reghdfe ****
ssc install reghdfe, replace

**** Ivreghdfe ***
ssc install ivreghdfe, replace // replaces former reghdfe IV command
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/13/2017													****
**** Program:	Graphs														****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Data.dta")		

********************************************************************************
**** (1) Sample selection and variable truncation							****
********************************************************************************

/* Data */
use Data, clear

/* Duplicates drop */
duplicates drop ci year, force

/* Sample period */
keep if year >= 2001 & year <= 2015

/* Panel: country-industry year */
xtset ci year

/* Directory */
cd "`directory'\Output\Figures"

********************************************************************************
**** Figure 2: Distribution & Time Trend of Reporting + Auditing Scopes		****
********************************************************************************

/* Scope variation within year and over time */

	/* Preserve */
	preserve	
	
		/* Graph */
		graph box mc_scope mc_audit ///
			, over(year, label(labsize(*.9) alternate)) nooutsides bar(1, color(black)) bar(2, color(gs10)) ///
			ylabel(0(0.1)1, angle(0) format(%9.2f)) ///
			legend(label(1 "Reporting Scope") label(2 "Audit Scope") rows(2) ring(0) position(2) bmargin(medium)) ///
			ytitle("Scope") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			name(Box, replace)
		
	/* Restore */
	restore
	
/* Average scope trend */

	/* Preserve */
	preserve
	
		/* Country level */
		duplicates drop c y, force
		
		/* Cross-country aggregation */
		foreach var of varlist mc_scope mc_audit {
			egen mean_`var' = mean(`var'), by(year)
		}
		
		/* Year level */
		duplicates drop year, force
		sort year
		
		/* Graph */
		graph twoway ///
			(connected mean_mc_scope year, lwidth(medium) color(black) msymbol(+)) ///
			(connected mean_mc_audit year, lwidth(medium) lpattern(dash) color(black) msymbol(x)) ///
				, ylabel(0(0.1)1, angle(0) format(%9.2f)) xlabel(2001(2)2015) ///
				legend(label(1 "Reporting Scope") label(2 "Audit Scope") rows(2) ring(0) position(2) bmargin(medium)) ///
				xtitle("Year") ///
				ytitle("Scope (Mean)") ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Time, replace)
		
	/* Restore */
	restore

/* Combine graphs */
graph combine Box Time ///
	, altshrink	title("DISTRIBUTION & TIME TREND" "OF REPORTING AND AUDITING SCOPES", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	ysize(5) xsize(10) ///
	saving(Figure_2, replace)
	
********************************************************************************
**** Figure 3: Reporting versus Auditing Scope								****
********************************************************************************

	
/* Raw scopes */

	/* Preserve */
	preserve
		
		/* Consolidate */
		gen auditing = round(mc_audit, 0.05)
		gen reporting = round(mc_scope, 0.05)
		duplicates tag auditing reporting, gen(dup)		
		
		/* Drop duplicates */
		duplicates drop auditing reporting, force
		
		/* Auditing vs. Reporting */
		graph twoway ///
			(scatter reporting auditing [w = dup], msymbol(circle_hollow) mcolor(black)) ///
				, ylabel(, angle(0) format(%9.1f)) xlabel(, format(%9.1f)) ///
				legend(off) ///
				xtitle("Standardized Auditing Scope") ///
				ytitle("Standardized Reporting Scope") ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Auditing_Raw, replace)
			
	/* Restore */
	restore		
	
/* Residualized scopes */

	/* Preserve */
	preserve
	
		/* Residual */
		qui reghdfe mc_scope if scope!=., a(cy iy) residuals(r_reporting)	
	
		qui reghdfe mc_audit if audit_scope!=., a(cy iy) residuals(r_auditing)
		
		/* Consolidate */
		gen auditing = round(r_auditing, 0.05)
		gen reporting = round(r_reporting, 0.05)
		duplicates tag auditing reporting, gen(dup)		
		
		/* Drop duplicates */
		duplicates drop auditing reporting, force
		
		/* Auditing vs. Reporting */
		graph twoway ///
			(scatter reporting auditing [w = dup], msymbol(circle_hollow) mcolor(black)) ///
				, ylabel(, angle(0) format(%9.1f)) xlabel(, format(%9.1f)) ///
				legend(off) ///
				xtitle("Res. Standardized Auditing Scope") ///
				ytitle("Res. Standardized Reporting Scope") ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Auditing_Res, replace)
			
	/* Restore */
	restore	
	
/* Combine graphs */
graph combine Auditing_Raw Auditing_Res ///
	, altshrink	title("REPORTING VERSUS AUDITING SCOPE", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	ysize(5) xsize(10) ///
	saving(Figure_3, replace)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		12/09/2020													****
**** Program:	Identifiers for publication [JAR Data & Code policy]		****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

********************************************************************************
**** (1) Sample firms														****
********************************************************************************

/* Delete existing outcomes data */
cd "`directory'\Data"
cap rm Identifiers.dta

/* Countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop */
foreach country of local countries {

	/* Project */
	project, uses("`directory'\Amadeus\Data_`country'.dta")

	/* Data */
	cd "`directory'\Amadeus"
	use Data_`country', clear

	/* Sample period (after EUR) */
	keep if year >= 1999 & year <= 2015	
	
	/* Non-missing industry */
	drop if industry == .

	/* BvD ID */
	label var bvd_id "BvD ID (original)"

	/* Panel */
	duplicates drop bvd_id, force
	
	/* Append */
	cd "`directory'\Data"
	cap append using Identifiers

	/* Save */
	save Identifiers, replace
			
/* End: Country loop */
}

/* Project	*/
project, creates("`directory'\Data\Identifiers.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/08/2017													****
**** Program:	Outcomes													****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // specify path of (raw) STATA files

/* Project */
project, original("`directory'\Data\WB_nominal_exchange_rate.txt")		
project, original("`directory'\Data\WB_GDP_deflator.txt")		

********************************************************************************
**** (1) Currency and inflation adjustments (World Bank)					****
********************************************************************************

/* Note on adjustment logic:
- Refer to Sebnem et al. (2015, p.32)

Step-by-step:
- convert account currency to official currency of the country (as used by GDP deflator; check for currency breaks for late EUR adopters: e.g., Slovenia)
- deflate the series by the national GDP deflator with 2015 base from the World Bank
- divide by exchange rate of official currency to U.S. dollar in 2015
*/

/* World Bank nominal exchange data */

	/* Data */
	import delimited using WB_nominal_exchange_rate.txt, delimiter(tab) varnames(1) clear
	
	/* Rename */
	rename countryname country
	label var country "Country"
	rename time year
	label var year "Year"
	rename value exch
	label var exch "Nominal exchange rate (local per USD)"
	
	/* Keep */
	keep country year exch
	
	/* Country name */
	replace country = "Slovakia" if country == "Slovak Republic"
	
	/* Keep non-missing */
	drop if year == . & exch == . & country == ""
	
	/* Currency codes */
	gen currency = "EUR" if country == "Euro area" & exch != .
	replace currency = "ATS" if country == "Austria" & exch != .
	replace currency = "BEF" if country == "Belgium" & exch != .
	replace currency = "BGN" if country == "Bulgaria" & exch != .
	replace currency = "CZK" if country == "Czech Republic" & exch != .
	replace currency = "DKK" if country == "Denmark" & exch != .
	replace currency = "EEK" if country == "Estonia" & exch != .
	replace currency = "FIM" if country == "Finland" & exch != .
	replace currency = "FRF" if country == "France" & exch != .
	replace currency = "DEM" if country == "Germany" & exch != .
	replace currency = "GRD" if country == "Greece" & exch != .
	replace currency = "IEP" if country == "Ireland" & exch != .
	replace currency = "ITL" if country == "Italy" & exch != .
	replace currency = "LTL" if country == "Lithuania" & exch != .
	replace currency = "LUF" if country == "Luxembourg" & exch != .
	replace currency = "ANG" if country == "Netherlands" & exch != .
	replace currency = "PTE" if country == "Portugal" & exch != .
	replace currency = "SKK" if country == "Slovakia" & exch != .
	replace currency = "SIT" if country == "Slovenia" & exch != .
	replace currency = "GBP" if country == "United Kingdom" & exch != .
	replace currency = "HRK" if country == "Croatia" & exch != .
	replace currency = "HUF" if country == "Hungary" & exch != .
	replace currency = "NOK" if country == "Norway" & exch != .
	replace currency = "PLN" if country == "Poland" & exch != .
	replace currency = "RON" if country == "Romania" & exch != .
	replace currency = "SEK" if country == "Sweden" & exch != .
	replace currency = "ESP" if country == "Spain" & exch != .
	label var currency "Currency"
	
	/* Euro */
	gen eu = exch if country == "Euro area"
	egen exch_eu = max(eu), by(year)
	replace currency = "EUR" if exch == . & currency == "" 
	replace exch = exch_eu if exch == . & currency == "EUR"
	label var exch_eu "Nominal exchange rate (local per EUR)"
	drop eu
		
	/* Drop missing */
	drop if exch == .
	
	/* Conversion: 2015 */
	gen ex = exch if year == 2015
	egen exch_2015 = max(ex), by(country)
	label var exch_2015 "Nominal exchange rate (local per USD in 2015)"
	drop ex	
	
	/* Save */
	save WB_nominal_exchange_rate, replace
	
	/* Project */
	project, creates("`directory'\Data\WB_nominal_exchange_rate.dta")		
	
/* World Bank GDP deflator data */	
	
	/* Data */
	import delimited using WB_GDP_deflator.txt, delimiter(tab) varnames(1) clear
	
	/* Rename */
	rename countryname country
	label var country "Country"
	rename time year
	label var year "Year"
	rename value deflator
	label var deflator "GDP deflator (USD)"
	
	/* Keep */
	keep country year deflator
	
	/* Country name */
	replace country = "Slovakia" if country == "Slovak Republic"
	
	/* Rebase (to 2015) */
	gen deflator_2015 = deflator if year == 2015
	egen base = max(deflator_2015), by(country)
	replace deflator = deflator/base
	drop deflator_2015 base	
	
	/* Drop missing */
	drop if deflator == .
	
	/* Save */
	save WB_GDP_deflator, replace
	
	/* Project */
	project, creates("`directory'\Data\WB_GDP_deflator.dta")

********************************************************************************
**** (2) Sample restriction	& variable definition							****
********************************************************************************

/* Delete existing outcomes data */
cd "`directory'\Data"
cap rm Outcomes.dta

/* Countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop */
foreach country of local countries {

	/* Project */
	project, uses("`directory'\Amadeus\Data_`country'.dta")

	/* Data */
	cd "`directory'\Amadeus"
	use Data_`country', clear

	/* Sample period (after EUR) */
	keep if year >= 1999 & year <= 2015	
	
	/* Non-missing industry */
	drop if industry == .

	/* BvD ID */
	drop bvd_id
	rename bvd_id_new bvd_id
	egen double id = group(bvd_id)
	
	/* Panel */
	duplicates drop id year, force
	xtset id year
	
	/* Limited liability (cf. BvD legal type document: focus on corporations; most directly affected by thresholds) */
	
		/* Other */
		gen other = 0
		replace other = 1 if ///
			regexm(lower(type), "unlimited") == 1 | ///
			regexm(lower(type), "unltd") == 1 | ///
			regexm(lower(type), "association") == 1 | ///
			regexm(lower(type), "partnership") == 1 | ///
			regexm(lower(type), "proprietorship") == 1 | ///
			regexm(lower(type), "cooperative") == 1
			
		/* Generic */
		gen limited = 1 if ///
			regexm(lower(type), "limited liability company") == 1 | ///
			regexm(lower(type), "limited company") == 1 | ///
			regexm(lower(type), "joint stock") == 1 | ///
			regexm(lower(type), "joint-stock") == 1 | ///
			regexm(lower(type), "share company") == 1 | ///
			regexm(lower(type), "one-person company with limited liability") == 1 | ///
			regexm(lower(type), "company limited by shares") == 1
		replace limited = 0 if limited == . | other == 1
		label var limited "Limited corporations"
		
		/* Country specific (legal forms) */
		replace limited = 1 if ///
			(lower(type) == "gmbh" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "AG" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "(E)BVBA / SPRL(U)" & (country == "Belgium" | country == "Luxembourg")) | ///
			(type == "AS" & country == "Czech Republic") | ///
			(type == "OY" & country == "Finland") | ///			
			(type == "OYJ" & country == "Finland") | ///			
			(type == "EURL" & country == "France") | ///			
			(type == "SARL" & country == "France") | ///			
			(type == "Société en action simple" & country == "France") | ///			
			(type == "SA" & (country == "France" | country == "Greece")) | ///			
			(regexm(type, "GmbH & Co KG") == 1 & country == "Germany") | ///			
			(regexm(type, "Limited liability company & partnership") ==1 & country == "Germany") | ///			
			(regexm(type, "AG & C0 KG") ==1 & country == "Germany") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(regexm(type, "Private") ==1 & country == "Ireland") | ///			
			(regexm(type, "Public") ==1 & country == "Ireland") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(type == "SRL" & country == "Italy") | ///			
			(type == "SPA" & country == "Italy") | ///			
			(regexm(type, "SCARL") == 1 & country == "Italy") | ///			
			(regexm(type, "SCRL") == 1 & country == "Italy") | ///			
			(type == "SA" & country == "Italy") | ///			
			(type == "NV / SA" & country == "Luxembourg") | ///			
			(type == "NV" & country == "Netherlands") | ///			
			(type == "BV" & country == "Netherlands") | ///			
			(type == "AS" & country == "Norway") | ///			
			(type == "ASA" & country == "Norway") | ///			
			(type == "SP. Z O.O." & country == "Poland") | ///			
			(type == "S.A." & country == "Poland") | ///			
			(type == "SA" & country == "Poland") | ///			
			(type == "Sp. z.o.o." & country == "Poland") | ///			
			(type == "S.R.L." & country == "Portugal") | ///			
			(type == "S.R.O." & country == "Slovakia") | ///			
			(type == "d.d." & country == "Slovenia") | ///			
			(type == "d.o.o." & country == "Slovenia") | ///			
			(regexm(type, "Sociedad anonima") == 1 & country == "Spain") | ///			
			(regexm(type, "Sociedad limitada") == 1 & country == "Spain") | ///			
			(regexm(type, "AB") == 1 & country == "Sweden") | ///
			(type == "Private" & country == "United Kingdom") | ///
			(type == "Private Limited" & country == "United Kingdom") | ///
			(regexm(type, "Public") == 1 & country == "United Kingdom")
		
		/* Backfill */
		egen mode = mode(limited), by(id)
		replace limited = mode
		label var limited "Limited liability"
		drop mode type
		keep if limited == 1
		
	/* Entry */
	egen mode = mode(dateinc), by(id)
	gen inc_year = substr(mode, -4, 4)
	destring inc_year, replace force
	gen entry = (inc_year + 2 >= year) if year >= inc_year
	label var entry "Entry (past 2 years)"
	drop mode inc_year dateinc
	
	/* Exit (broad definition: failing, consolidating/merging, stopping production) */
	bys year id (lstatus): replace lstatus = lstatus[_N] if missing(lstatus)
	gen exit = 1 if ///
		regexm(lower(lstatus), "insolvency") == 1 | ///
		regexm(lower(lstatus), "receivership") == 1 | ///
		regexm(lower(lstatus), "liquidation") == 1 | ///
		regexm(lower(lstatus), "dissolved") == 1 | ///
		regexm(lower(lstatus), "inactive") == 1 | ///
		regexm(lower(lstatus), "dormant") == 1 | ///
		regexm(lower(lstatus), "bankruptcy") == 1
	replace exit = 0 if exit == . & lstatus != ""
	label var exit "Exit"
	drop lstatus
	
	/* Quoted/listed */
	bys year id (quoted): replace quoted = quoted[_N] if missing(quoted)
	gen listed = (quoted == "Yes") if quoted != ""
	label var listed "Listed/quoted"
	drop quoted
	
	/* Auditor */
	gen audit = (ad_name != "")
	label var audit "Audit"
	drop ad_name
	
	/* Independence */
	gen indep = 1 if indepind == "A+"
	replace indep = 2 if indepind == "A"
	replace indep = 3 if indepind == "A-"
	replace indep = 4 if indepind == "B+"
	replace indep = 5 if indepind == "B"
	replace indep = 6 if indepind == "B-"
	replace indep = 7 if indepind == "C+"
	replace indep = 8 if indepind == "C"
	replace indep = 9 if indepind == "D"
	replace indep = (9 - indep)/(9 - 1)
	label var indep "Independence (Ownership)"
	drop indepind
	
	/* Shareholders */
	gen shareholders = ln(1+onbr)
	label var shareholders "Shareholders (Log)"
	drop onbr
	
	/* Peer group size */
	gen peers = ln(1+pgsize)
	label var peers "Number of peers (Log; acc. BvD)"
	drop pgsize
	
	/* Exchange rate and inflation adjustment (exchange rate and GDP deflator) */

		/* Currency translation (from account to local currency) */
		
			/* Filling missing */	
			egen firm_mode = mode(currency), by(id)
			egen country_mode = mode(currency), by(country year)
			replace currency = firm_mode if currency == "" | length(currency) > 3
			replace currency = country_mode if currency == "" | length(currency) > 3
			drop firm_mode country_mode
			
			/* Merge: account currency exchange rate */
			cd "`directory'\Data"
			merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch)
			drop if _merge == 2
			drop _merge
			rename currency currency_account
			rename exch exch_account
			replace exch_account = 1 if currency_account == "USD"
			
			/* Merge: local currency exchange rate */
			merge m:1 country year using WB_nominal_exchange_rate
			drop if _merge == 2
			drop _merge

			/* Conversion */
			local variables = "toas opre turn fias ifas ltdb cost mate staf inte av ebta"
			foreach var of varlist `variables' {
			
				/* Convert account currency to USD + USD to local currency */
				replace `var' = `var'/exch_account*exch if currency_account != currency
			}

		/* Deflating (price level as of 2015) */
		
			/* Merge: GDP deflator */
			merge m:1 country year using WB_GDP_deflator
			drop if _merge == 2
			drop _merge
			
			/* Deflating */
			foreach var of varlist `variables' {
			
				/* Deflate nominal variables (in local currency) with country-year specific GDP deflator */
				replace `var' = `var'/deflator
			}		
			
		/* Currency translation (to USD as of 2015) */
		
			/* Translation */
			foreach var of varlist `variables' {
			
				/* Translate real variables (in local currency) to USD */
				replace `var' = `var'/exch_2015
			}	
	
		/* Drop */
		drop exch* deflator currency*
	
	/* Panel (reset) */
	xtset id year
	
	/* Employees */
	replace empl = empl_c if empl == .
	drop empl_c
	
	/* Material costs */
	replace mate = cost if mate == .
	drop cost
	
	/* Total variable cost */
	egen vc = rowtotal(mate staf)
	label var vc "Variable cost"

	/* Output */
	gen sales = turn
	replace sales = opre if turn == .
	label var sales "Sales"
	
	/* Markup */
	gen markup = (sales - vc)/sales
	replace markup = . if markup > 1 | markup < 0
	label var markup "(Y-c)/Y (Markup)"
	
	/* Operating margin */
	gen margin = ebta/sales
	replace margin = . if margin > 1 | margin < 0	
	label var margin "(Y-c)/Y (Operating Margin)"
	
	/* Capital-labor ratio */
	gen cl_e = ln(fias/empl)
	label var cl_e "K/L (Employees)"
	
	gen cl_w = ln(fias/staf)
	label var cl_w "K/L (Wage)"
	
	/* Capital-output ratio */
	gen cy = ln(fias/sales)
	label var cy "K/Y"
		
	/* Productivity */
	
		/* Labor productivity */
		gen lp_e = ln(sales/empl)
		label var lp_e "Y/L (Employees)"
		
		gen lp_w = ln(sales/staf)
		label var lp_w "Y/L (Wage)"
		
		/* Total factor productivity (excl. materials) */
		gen tfp_e = ln(sales) - 0.3*ln(fias) - 0.7*ln(empl)
		label var tfp_e "TFP (Employees)"
		
		gen tfp_w = ln(sales) - 0.3*ln(fias) - 0.7*ln(staf)
		label var tfp_w "TFP (Wage)"
	
********************************************************************************
**** (3) Outcomes (aggregation)												****
********************************************************************************

/* Information environment */
	
	/* Number of firms (control in later specifications) */
	egen firms = count(id), by(industry year)
	replace firms = ln(firms)
	label var firms "Number of firms"
	
	/* Other information environment variables */
	local information = "audit listed"
	foreach var of varlist `information' {
	
		/* Mean */
		egen m_`var' = mean(`var'), by(industry year)
		
		/* Weighted */
		egen double total = total(sales) if `var' ! = ., by(industry year) missing
		egen w_`var' = total(`var'*sales/total), by(industry year) missing
		drop total `var'	
	}

/* Concentration measures */

	/* HHI */
	egen total = total(sales), by(industry year) missing
	egen hhi = total((sales/total)^2), by(industry year) missing
	label var hhi "Concentration (HHI)"
	drop total

/* Productivity and output */

	/* Input and output */
	local measures = "sales empl fias"
	foreach var of varlist `measures' {	
	
		/* Mean */
		gen ln_`var' = ln(`var')
		egen m_`var' = mean(ln_`var'), by(industry year)

	}
	
	/* Productivity, profitability, and markup measures  */
	local measures = "lp_* tfp_* markup margin"
	foreach var of varlist `measures' {
		
		/* Mean */
		egen m_`var' = mean(`var'), by(industry year)
		
		/* Mean (growth) */
		gen d_`var' = d.`var'
		egen dm_`var' = mean(d_`var'), by(industry year)				
		
		/* Weighted */
		egen double total = total(sales) if `var' ! = ., by(industry year) missing
		egen w_`var' = total(`var'*sales/total), by(industry year) missing
				
		/* Weighted (growth) */
		gen dw_`var' = d.w_`var'

		/* Upper and lower tails */
		egen  p20_`var' = pctile(`var'*sales/total), p(20) by(industry year)
		replace p20_`var' = . if p20_`var' == 0
		egen  p80_`var' = pctile(`var'*sales/total), p(80) by(industry year)
		replace p80_`var' = . if p80_`var' == 0
		
		/* Distance between 20-80 percentile */
		gen di_`var' = p80_`var' - p20_`var'
		replace di_`var' = . if di_`var' == 0
			
		/* Standardized range */
		gen sr_`var' = di_`var'/m_`var'
		
		/* Dispersion */
		egen sd_`var' = sd(`var'*sales/total), by(industry year)
		replace sd_`var' = . if sd_`var' == 0
		drop total
		
		/* Coefficient of variation */
		gen cv_`var' = sd_`var'/m_`var'
		
		/* Covariance */
		egen mean = mean(`var') if sales != . & `var' != ., by(industry year)
		egen double total = total(sales) if sales != . & `var' ! = ., by(industry year)
		gen cov = w_`var' - mean
		egen cov_`var' = mode(cov), by(industry year)
		replace cov_`var' = . if cov_`var' == 0
		drop total mean cov `var'
		
	}

/* Other */

	/* Other firm characteristics, entry, exit */
	local characteristics = "entry exit indep shareholders"
	foreach var of varlist `characteristics' {
		/* Mean */
		egen m_`var' = mean(`var'), by(industry year)
		
		/* Weighted */
		egen double total = total(sales) if `var' ! = ., by(industry year) missing
		egen w_`var' = total(`var'*sales/total), by(industry year) missing
		drop total `var'	
	}
	
********************************************************************************
**** (4) Outcome data														****
********************************************************************************

/* Keeping relevant variables */
keep country industry year firms hhi m_* dm_* w_* dw_* p20_* p80_* di_* sr_* sd_* cv_* cov_*

/* Duplicates drop */
duplicates drop industry year, force

/* Labeling */

	/* Information environment */
	label var m_audit "Audit (Mean)"
	label var w_audit "Audit (Weighted)"
	label var m_listed "Listed (Mean)"
	label var w_listed "Listed (Weighted)"	
	
	/* Output */
	label var m_sales "Mean Y (Log)"

	/* Employees */
	label var m_empl "Mean L (Log)"	
	
	/* Fixed assets */
	label var m_fias "Mean K (Log)"	
	
	/* Productivity */
	label var m_lp_e "Y/L (Employees; Mean)"
	label var dm_lp_e "Y/L (Employees; Growth; Mean)"		
	label var w_lp_e "Y/L (Employees; Weighted)"
	label var dw_lp_e "Y/L (Employees; Growth; Weighted)"	
	label var p20_lp_e "Y/L (Employees; p20)"
	label var p80_lp_e "Y/L (Employees; p80)"
	label var di_lp_e "Y/L (Employees; p80-p20)"
	label var sr_lp_e "Y/L (Employees; p80-p20; scaled)"
	label var sd_lp_e "Y/L (Employees; SD)"
	label var cv_lp_e "Y/L (Employees; SD; scaled)"
	label var cov_lp_e "Y/L (Employees; Cov)"	
	
	label var m_lp_w "Y/L (Wage; Mean)"
	label var dm_lp_w "Y/L (Wage; Growth; Mean)"		
	label var w_lp_w "Y/L (Wage; Weighted)"
	label var dw_lp_w "Y/L (Wage; Growth; Weighted)"	
	label var p20_lp_w "Y/L (Wage; p20)"
	label var p80_lp_w "Y/L (Wage; p80)"
	label var di_lp_w "Y/L (Wage; p80-p20)"	
	label var sr_lp_w "Y/L (Wage; p80-p20; scaled)"
	label var sd_lp_w "Y/L (Wage; SD)"
	label var cv_lp_w "Y/L (Wage; SD; scaled)"
	label var cov_lp_w "Y/L (Wage; Cov)"
	
	label var m_tfp_e "TFP (Employees; Mean)"
	label var dm_tfp_e "TFP (Employees; Growth; Mean)"		
	label var w_tfp_e "TFP (Employees; Weighted)"
	label var dw_tfp_e "TFP (Employees; Growth; Weighted)"	
	label var p20_tfp_e "TFP (Employees; p20)"
	label var p80_tfp_e "TFP (Employees; p80)"
	label var di_tfp_e "TFP (Employees; p80-p20)"
	label var sr_tfp_e "TFP (Employees; p80-p20; scaled)"
	label var sd_tfp_e "TFP (Employees; SD)"
	label var cv_tfp_e "TFP (Employees; SD; scaled)"
	label var cov_tfp_e "TFP (Employees; Cov)"	
	
	label var m_tfp_w "TFP (Wage; Mean)"
	label var dm_tfp_w "TFP (Wage; Growth; Mean)"		
	label var w_tfp_w "TFP (Wage; Weighted)"
	label var dw_tfp_w "TFP (Wage; Growth; Weighted)"	
	label var p20_tfp_w "TFP (Wage; p20)"
	label var p80_tfp_w "TFP (Wage; p80)"
	label var di_tfp_w "TFP (Wage; p80-p20)"
	label var sr_tfp_w "TFP (Wage; p80-p20; scaled)"
	label var sd_tfp_w "TFP (Wage; SD)"
	label var cv_tfp_w "TFP (Wage; SD; scaled)"
	label var cov_tfp_w "TFP (Wage; Cov)"	
	
	/* Markup and margin */
	label var m_markup "(Y-c)/Y (Markup; Mean)"
	label var dm_markup "(Y-c)/Y (Markup; Growth; Mean)"		
	label var w_markup "(Y-c)/Y (Markup; Weighted)"
	label var dw_markup "(Y-c)/Y (Markup; Growth; Weighted)"	
	label var p20_markup "(Y-c)/Y (Markup; p20)"
	label var p80_markup "(Y-c)/Y (Markup; p80)"
	label var di_markup "(Y-c)/Y (Markup; p80-p20)"
	label var sr_markup "(Y-c)/Y (Markup; p80-p20; scaled)"
	label var sd_markup "(Y-c)/Y (Markup; SD)"
	label var cv_markup "(Y-c)/Y (Markup; SD; scaled)"
	label var cov_markup "(Y-c)/Y (Markup; Cov)"	
	
	label var m_margin "(Y-c)/Y (Margin; Mean)"
	label var dm_margin "(Y-c)/Y (Margin; Growth; Mean)"		
	label var w_margin "(Y-c)/Y (Margin; Weighted)"
	label var dw_margin "(Y-c)/Y (Margin; Growth; Weighted)"	
	label var p20_margin "(Y-c)/Y (Margin; p20)"
	label var p80_margin "(Y-c)/Y (Margin; p80)"
	label var di_margin "(Y-c)/Y (Margin; p80-p20)"
	label var sr_margin "(Y-c)/Y (Margin; p80-p20; scaled)"
	label var sd_margin "(Y-c)/Y (Margin; SD)"
	label var cv_margin "(Y-c)/Y (Margin; SD; scaled)"
	label var cov_margin "(Y-c)/Y (Margin; Cov)"	
		
	/* Other firm characteristics, entry, exit */
	label var m_indep "Independence (Mean)"
	label var w_indep "Independence (Weighted)"	
	label var m_shareholders "Shareholders (Mean)"
	label var w_shareholders "Shareholders (Weighted)"
	label var m_entry "Entry (Mean)"
	label var w_entry "Entry (Weighted)"
	label var m_exit "Exit (Mean)"
	label var w_exit "Exit (Weighted)"		

/* Append */
cd "`directory'\Data"
cap append using Outcomes

/* Save */
save Outcomes, replace
		
/* End: Country loop */
}

/* Project	*/
project, creates("`directory'\Data\Outcomes.dta")
	
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Construct panel (financial, company, ownership information)	****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // specify location of (raw) STATA files

********************************************************************************
**** (1) Constructing panel data by country	and vintage						****
********************************************************************************

/* Sample countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Year/Vintage loop */
local years = "2005 2008 2012 2016"
	
/* Country loop */
foreach country of local countries {
	
	/* Vintage loop */
	foreach year of local years {
		
		/* Financials */
		
			/* Project */
			cap project, original("`data'\Financials\`country'_Financials_`year'.dta")		
		
			/* Vintages: 2005 and 2008 */
			if "`year'" == "2005" | "`year'" == "2008" {
			
				/* Data */
				cd "`data'\Financials"
				use `country'_Financials_`year', clear

				/* Relevant variables */
				keep accnr idnr consol statda toas empl opre turn fias ifas ltdb cost mate staf av inte ebta
				
				/* Generate year */
				split statda, p(/)
				destring statda*, replace
				replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
				replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
				rename statda3 year
				replace year = year - 1 if statda1 <=6
				label var year "Year"
				drop statda*
				
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Financials_`year', replace
			
			/* End: Vintages 2005 and 2008 */
			}

			/* Vintages: 2012 */
			if "`year'" == "2012" {
			
				/* Data */
				cd "`data'\Financials"
				use `country'_Financials_`year', clear

				/* Relevant variables (including R&D from 2012 on) */
				keep accnr idnr consol statda toas empl opre turn fias ifas ltdb cost mate staf av inte ebta				
				
				/* Generate year */
				split statda, p(/)
				destring statda*, replace
				replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
				replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
				rename statda3 year
				replace year = year - 1 if statda1 <=6
				label var year "Year"
				drop statda*
				
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Financials_`year', replace
			
			/* End: Vintages 2012 */
			}
			
			/* Vintage: 2016 */
			if "`year'" == "2016" {
	
				/* Data */
				cd "`data'\Financials"
				use `country'_Financials_`year', clear

				/* Relevant variables */
				keep idnr unit closdate closdate_year toas empl opre turn fias ifas ltdb cost mate staf inte av ebta
				
				/* Generate year */
				gen closdate_month = month(closdate)
				gen year = closdate_year
				replace year = year - 1 if closdate_month <= 6
				label var year "Year"
				drop closdate*	
	
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Financials_2016, replace
			
			/* End: Vintage 2016 */
			}
			
		/* Company (type, unit, currency) */

			/* Vintages: 2005 and 2008 */
			if "`year'" == "2005" | "`year'" == "2008" {
	
				/* Data */
				cd "`data'\Company"
				use `country'_Company_`year', clear
			
				/* Relevant variables */
				keep accnr type unit currency
				
				/* Destring unit */
				capture {
					destring unit, replace
					rename unit_string unit
				}

				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Company_`year', replace
			
			/* End: Vintages 2005 and 2008 */
			}
			
			/* Vintage: 2012 */
			if "`year'" == "2012" {			
	
				/* Data */
				cd "`data'\Company"
				use `country'_Company_`year', clear
			
				/* Relevant variables */
				keep accnr type currency
				
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"				
				save `country'_Company_`year', replace	
			
			/* End: Vintage 2012 */
			}
			
			/* Vintage: 2016 */
			if "`year'" == "2016" {
			
				/* Data */
				cd "`data'\Company"
				use `country'_Company_`year', clear
			
				/* Relevant variables */
				keep accnr consol idnr type currency

				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"				
				save `country'_Company_`year', replace
		
			/* End: Vintage 2016 */
			}		
		
		/* Combination */

			/* Vintages: 2005 (units: units) */
			if "`year'" == "2005" {
			
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
	
				/* Merge company data */
				merge m:m accnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge
		
				/* Unit conversion */
				local num_list = "toas opre turn fias ifas ltdb cost mate staf av inte ebta"
				foreach var of varlist `num_list' {
					replace `var' = `var'*10^unit
				}
				
				/* Consolidation: avoid duplication (drop duplicates associated with C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				duplicates drop idnr year if dup != 0, force
				drop dup con c2	
					
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge
				
				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
				
				/* Save */
				save `country'_Combined_`year', replace
		
			/* End: Vintages 2005 */
			}
			
			/* Vintage: 2008 (unit: thousands) */
			if "`year'" == "2008" {
			
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
	
				/* Merge company data */
				merge m:m accnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge
		
				/* Unit conversion */
				local num_list = "toas opre turn fias ifas ltdb cost mate staf av inte ebta"
				foreach var of varlist `num_list' {
					replace `var' = `var'*10^3
				}
				
				/* Consolidation: avoid duplication (drop duplicates associated with C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				cap duplicates drop idnr year if dup != 0, force
				drop dup con c2	
					
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge				
				
				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
				
				/* Save */
				save `country'_Combined_`year', replace
		
			/* End: Vintages 2008 */
			}
			
			/* Vintage: 2012 */
			if "`year'" == "2012" {
			
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
			
				/* Merge company data */
				merge m:m accnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge
	
				/* Consolidation: avoid duplication (drop duplicates associated with C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				cap duplicates drop idnr year if dup != 0, force
				drop dup con c2	
					
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge				

				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
				
				/* Save */
				save `country'_Combined_`year', replace
				
			/* End: Vintage 2012 */
			}
			
			/* Vintage: 2016 */
			if "`year'" == "2016" {
	
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
			
				/* Merge company data */
				merge m:m idnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge 

				/* Consolidation: avoid duplication (drop duplicates associated with C1 & C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				cap duplicates drop idnr year if dup != 0, force
				drop dup con c2	
		
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge
				
				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
		
				/* Save */
				save `country'_Combined_`year', replace
		
				/* Delete intermediate */
				rm `country'_Financials_`year'.dta
				rm `country'_Company_`year'.dta
				
			/* End: Vintage 2016 */
			}
	
	/* End: Vintage loop */
	}
			
/* End: Country loop */		
}

********************************************************************************
**** (2) Merging panel data by country										****
********************************************************************************

/* Years (start with latest vintage; after 2016) */
local years = "2012 2008 2005"

/* Country loop */
foreach country of local countries {
	
	/* Data: Vintage 2016 */
	cd "`directory'\Amadeus"				
	use `country'_Combined_2016, clear	
	
	/* Vintage loop */
	foreach year of local years {
			
		/* Merge: update */
		merge 1:1 bvd_id_new year using `country'_Combined_`year', update
		drop _merge
		
		/* Duplicates */
		egen id = group(bvd_id_new)
		duplicates drop id year, force
		drop id	
		
		/* Delete intermediate */
		rm `country'_Combined_`year'.dta
		
	/* End: Vintage loop */
	}
	
	/* Add company panel information */
	rename vintage vintage_disc
	gen vintage = year + 1
	merge m:1 bvd_id_new vintage using Company_`country'
	drop if _merge == 2
	drop _merge vintage
	rename vintage_disc vintage	
	
	/* Compress */
	compress
	
	/* Save */
	save Data_`country', replace
	
	/* Project	*/
	project, creates("`directory'\Amadeus\Data_`country'.dta")
	
/* End: Country loop */		
}
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/11/2017													****
**** Program:	Regulations													****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // insert path to (raw) STATA files

/* Project */
project, original("`directory'\Data\Regulation.csv")
project, original("`directory'\Data\MAD.csv")
project, original("`directory'\Data\IFRS.csv")				
project, uses("`directory'\Data\WB_nominal_exchange_rate.dta")		

********************************************************************************
**** (1) Regulatory thresholds												****
********************************************************************************

/* Data */
import delimited using Regulation.csv, delimiter(",") varnames(1) clear

/* Mode currency */
egen mode = mode(currency_reporting), by(country)
replace currency_reporting = mode if currency_reporting == ""
drop mode

egen mode = mode(currency_audit), by(country)
replace currency_audit = mode if currency_audit == ""
drop mode

/* Cleaning */
keep if year != . & year < 2016

/* Exchange rates */

	/* Reporting threshold currency */
	cd "`directory'\Data"
	rename currency_reporting currency
	merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch_eu)
	drop if _merge==2
	drop _merge
	rename exch_eu exch_reporting
	rename currency currency_reporting

	/* Audit threshold currency */
	rename currency_audit currency
	merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch_eu)
	drop if _merge==2
	drop _merge	
	rename exch_eu exch_audit
	rename currency currency_audit

/* Missing rates (Wikipedia: conversion rates to EUR at official conversion date) */

	/* Italian Lira */
	replace exch_reporting = 1936.27 if currency_reporting == "ITL"
	replace exch_audit = 1936.27 if currency_audit == "ITL"

	/* French Franc */
	replace exch_reporting = 6.55957 if currency_reporting == "FRF"
	replace exch_audit = 6.55957 if currency_audit == "FRF"
	
	/* German mark */
	replace exch_reporting = 1.95583 if currency_reporting == "DEM"
	replace exch_audit = 1.95583 if currency_audit == "DEM"	
	
	/* Finish marka */
	replace exch_reporting = 5.94 if currency_reporting == "FIM"
	replace exch_audit = 5.94 if currency_audit == "FIM"	
	
	/* Greek drachma */
	replace exch_reporting = 340.750 if currency_reporting == "GRD"
	replace exch_audit = 340.750 if currency_audit == "GRD"	
	
	/* Irish pound */
	replace exch_reporting = 0.787564 if currency_reporting == "IEP"
	replace exch_audit = 0.787564 if currency_audit == "IEP"		

	/* Dutch guilder */
	replace exch_reporting = 2.20371 if currency_reporting == "NLG"
	replace exch_audit = 2.20371 if currency_audit == "NLG"	

	/* Portuguese escudo */
	replace exch_reporting = 200.482 if currency_reporting == "PTE"
	replace exch_audit = 200.482 if currency_audit == "PTE"		
	
	/* Spanish peseta */
	replace exch_reporting = 166.386 if currency_reporting == "ESP"
	replace exch_audit = 166.386 if currency_audit == "ESP"		

/* Filling in missing exchange rates (forward) */
egen c = group(country)
duplicates drop c year, force
xtset c year
foreach var of varlist exch_reporting exch_audit {
	forvalues i = 1(1)15 {
		replace `var' = l.`var' if `var' == . & l.`var' != . & year == 1999 + `i'
	}
}

/* Keep relevant variables */
keep ///
	country ///
	year ///
	eu_date ///
	euro_date ///
	directive_4 ///
	directive_7 ///
	at_reporting ///
	sales_reporting ///
	empl_reporting ///
	bs_preparation_abridged ///
	is_preparation_abridged ///
	notes_preparation_abridged ///
	bs_publication ///
	is_publication ///
	notes_publication ///
	at_audit ///
	sales_audit ///
	empl_audit ///
	exch_* ///
	currency_reporting ///
	currency_audit
	
/* Labeling */
label var country "Country"
label var year "Year"
label var eu_date "EU Accession Year"
label var euro_date "EURO Accession Year"
label var directive_4 "4th Directive Implementation Year" 
label var directive_7 "7th Directive Implementation Year"
label var at_reporting "Total Assets Threshold (Reporting Requirements)"
label var sales_reporting "Sales Threshold (Reporting Requirements)"
label var empl_reporting "Employees Threshold (Reporting Requirements)"
label var bs_preparation_abridged "Balance Sheet Preparation (Abridged)"
label var is_preparation_abridged "Income Statement Preparation (Abridged)"
label var notes_preparation_abridged "Notes Preparation (Abridged)"
label var bs_publication "Balance Sheet Publication"
label var is_publication "Income Statement Publication"
label var notes_publication "Notes Publication"
label var at_audit "Total Assets Threshold (Audit Requirements)"
label var sales_audit "Sales Threshold (Audit Requirements)"
label var empl_audit "Employees Threshold (Audit Requirements)"
label var currency_reporting "Currency (Reporting Requirements)"
label var currency_audit "Currency (Audit Requirements)"

/* Save */
save Regulation, replace

********************************************************************************
**** (2) Adding concurrent regulations										****
********************************************************************************

/* MAD */

	/* Data */
	import delimited using MAD.csv, delimiter(",") varnames(1) clear

	/* Save */
	save MAD, replace
	
/* IFRS */

	/* Data */
	import delimited using IFRS.csv, delimiter(",") varnames(1) clear

	/* Save */
	save IFRS, replace

/* Data */
use Regulation, clear
merge m:1 country using MAD
drop if _merge == 2
drop _merge

merge m:1 country using IFRS
drop if _merge == 2
drop _merge

/* Sort */
sort country year

/* Save */
save Regulation, replace

********************************************************************************
**** (3) Thresholds (only)													****
********************************************************************************

/* Keep threshold variables */
keep ///
	country ///
	year ///
	at_reporting ///
	sales_reporting ///
	empl_reporting ///
	bs_preparation_abridged ///
	is_preparation_abridged ///
	notes_preparation_abridged ///
	bs_publication ///
	is_publication ///
	notes_publication ///
	at_audit ///
	sales_audit ///
	empl_audit ///
	exch_reporting ///
	exch_audit ///
	currency_reporting ///
	currency_audit

/* Save */
save Thresholds, replace

/* Project */
project, creates("`directory'\Data\Regulation.dta")	
project, creates("`directory'\Data\Thresholds.dta")	
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/11/2017													****
**** Program:	Scope [Excerpt]												****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // specify path to (raw) STATA files

/* Project */
project, uses("`directory'\Data\WB_nominal_exchange_rate.dta")	
project, uses("`directory'\Data\Regulation.dta")		

********************************************************************************
**** (1) Cross-country data													****
********************************************************************************

/* Delete existing outcomes data */
cd "`directory'\Data"
cap rm Scope_data.dta

/* Countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop */
foreach country of local countries {

	/* Project */
	project, uses("`directory'\Amadeus\Data_`country'.dta")		

	/* Data */
	cd "`directory'\Amadeus"
	use Data_`country', clear

	/* Keep relevant variables & observations */
	keep bvd_id_new toas empl empl_c opre turn year currency type industry country 
	drop if toas == . & empl == . & opre == . & turn == .
	
	/* Total assets */
	rename toas at
	
	/* Sales */
	gen sales = turn
	replace sales = opre if turn == .
	label var sales "Sales"
	drop opre turn
	
	/* Employees */
	replace empl = empl_c if empl == .
	drop empl_c
	
	/* Sample period (after EUR) */
	keep if year >= 1999 & year <= 2015	
	
	/* Non-missing industry */
	drop if industry == .

	/* BvD ID */
	rename bvd_id_new bvd_id
	egen double id = group(bvd_id)
	
	/* Panel */
	duplicates drop id year, force
	xtset id year
	
	/* Limited liability (cf. BvD legal type document: focus on corporations; most directly affected by thresholds) */
	
		/* Other */
		gen other = 0
		replace other = 1 if ///
			regexm(lower(type), "unlimited") == 1 | ///
			regexm(lower(type), "unltd") == 1 | ///
			regexm(lower(type), "association") == 1 | ///
			regexm(lower(type), "partnership") == 1 | ///
			regexm(lower(type), "proprietorship") == 1 | ///
			regexm(lower(type), "cooperative") == 1
			
		/* Generic */
		gen limited = 1 if ///
			regexm(lower(type), "limited liability company") == 1 | ///
			regexm(lower(type), "limited company") == 1 | ///
			regexm(lower(type), "joint stock") == 1 | ///
			regexm(lower(type), "joint-stock") == 1 | ///
			regexm(lower(type), "share company") == 1 | ///
			regexm(lower(type), "one-person company with limited liability") == 1 | ///
			regexm(lower(type), "company limited by shares") == 1
		replace limited = 0 if limited == . | other == 1
		label var limited "Limited corporations"
		
		/* Country specific (legal forms) */
		replace limited = 1 if ///
			(lower(type) == "gmbh" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "AG" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "(E)BVBA / SPRL(U)" & (country == "Belgium" | country == "Luxembourg")) | ///
			(type == "AS" & country == "Czech Republic") | ///
			(type == "OY" & country == "Finland") | ///			
			(type == "OYJ" & country == "Finland") | ///			
			(type == "EURL" & country == "France") | ///			
			(type == "SARL" & country == "France") | ///			
			(type == "Société en action simple" & country == "France") | ///			
			(type == "SA" & (country == "France" | country == "Greece")) | ///			
			(regexm(type, "GmbH & Co KG") == 1 & country == "Germany") | ///			
			(regexm(type, "Limited liability company & partnership") ==1 & country == "Germany") | ///			
			(regexm(type, "AG & C0 KG") ==1 & country == "Germany") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(regexm(type, "Private") ==1 & country == "Ireland") | ///			
			(regexm(type, "Public") ==1 & country == "Ireland") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(type == "SRL" & country == "Italy") | ///			
			(type == "SPA" & country == "Italy") | ///			
			(regexm(type, "SCARL") == 1 & country == "Italy") | ///			
			(regexm(type, "SCRL") == 1 & country == "Italy") | ///			
			(type == "SA" & country == "Italy") | ///			
			(type == "NV / SA" & country == "Luxembourg") | ///			
			(type == "NV" & country == "Netherlands") | ///			
			(type == "BV" & country == "Netherlands") | ///			
			(type == "AS" & country == "Norway") | ///			
			(type == "ASA" & country == "Norway") | ///			
			(type == "SP. Z O.O." & country == "Poland") | ///			
			(type == "S.A." & country == "Poland") | ///			
			(type == "SA" & country == "Poland") | ///			
			(type == "Sp. z.o.o." & country == "Poland") | ///			
			(type == "S.R.L." & country == "Portugal") | ///			
			(type == "S.R.O." & country == "Slovakia") | ///			
			(type == "d.d." & country == "Slovenia") | ///			
			(type == "d.o.o." & country == "Slovenia") | ///			
			(regexm(type, "Sociedad anonima") == 1 & country == "Spain") | ///			
			(regexm(type, "Sociedad limitada") == 1 & country == "Spain") | ///			
			(regexm(type, "AB") == 1 & country == "Sweden") | ///
			(type == "Private" & country == "United Kingdom") | ///
			(type == "Private Limited" & country == "United Kingdom") | ///
			(regexm(type, "Public") == 1 & country == "United Kingdom")
		
		/* Backfill */
		egen mode = mode(limited), by(id)
		replace limited = mode
		label var limited "Limited liability"
		drop mode type
		keep if limited == 1 
	
	/* Currency translation (to EURO; Lira conversion in "Regulation" also to EURO; scope is free of monetary unit) */
		
		/* Filling missing */	
		egen firm_mode = mode(currency), by(id)
		egen country_mode = mode(currency), by(country year)
		replace currency = firm_mode if currency == "" | length(currency) > 3
		replace currency = country_mode if currency == "" | length(currency) > 3
		drop firm_mode country_mode
			
		/* Merge: account currency exchange rate */
		cd "`directory'\Data"
		merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch_eu)
		drop if _merge == 2
		drop _merge
		rename currency currency_account
		rename exch_eu exch_account
			
		/* Merge: local currency exchange rate */
		merge m:1 country year using WB_nominal_exchange_rate
		drop if _merge == 2
		drop _merge

		/* Conversion */
		local sizes = "at sales"
		foreach var of varlist `sizes' {
			
			/* Convert account currency to EUR + EUR to local currency */
			replace `var' = `var'/exch_account*exch_eu if currency_account != currency
		}
	
	/* Keep relevant variables */
	keep bvd_id country industry year at sales empl 
	
	/* Append */
	cd "`directory'\Data"
	cap append using Scope_data
	 
	/*Save */
	save Scope_data, replace
}

/* Project */
project, creates("`directory'\Data\Scope_data.dta")		

********************************************************************************
**** (2) Thresholds															****
********************************************************************************

/* Data */
use Scope_data, clear

/* Merge: Thresholds */
merge m:1 country year using Thresholds
keep if _merge==3
drop _merge

/* Threshold currency translation */
foreach var of varlist at_reporting sales_reporting {
	replace `var'=`var'/exch_reporting if currency_reporting!="EUR" & currency_reporting!=""
}

foreach var of varlist at_audit sales_audit {
	replace `var'=`var'/exch_audit if currency_audit!="EUR" & currency_audit!=""
}

drop exch_* currency_*

** Reporting Requirements **
egen preparation=rowtotal(bs_preparation_abridged is_preparation_abridged notes_preparation_abridged), missing
replace preparation=3-preparation
label var preparation "Preparation Requirement Strength (Small)"

egen publication=rowtotal(bs_publication is_publication notes_publication), missing
label var publication "Publication Requirement Strength (Small)"

********************************************************************************
**** (3) Measured scope														****
********************************************************************************

/* Reporting scope indicator */
gen regulation = .
label var regulation "Reporting Regulation (Indicator)"

	/* Three thresholds */
	replace regulation = ((at>at_reporting & at!=. & sales>sales_reporting & sales!=.) | (at>at_reporting & at!=. & empl>empl_reporting & empl!=.) | (sales>sales_reporting & sales!=. & empl>empl_reporting & empl!=.)) ///
		if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.)
		
		/* Missing size values */
		replace regulation = (at>at_reporting & at!=.) ///
			if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.) & regulation == . & empl== . & sales== .
			
		replace regulation = (sales>sales_reporting & sales!=.) ///
			if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.) & regulation == . & at== . & empl== .
			
		replace regulation = (empl>empl_reporting & empl!=.) ///
			if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.) & regulation == . & at==. & sales==.		
		
	/* Two thresholds */	
	replace regulation = (at>at_reporting & at!=. & sales>sales_reporting & sales!=.) ///
		if at_reporting != . & sales_reporting != . & empl_reporting == .

		/* Missing size values */
		replace regulation = (at>at_reporting & at!=.) ///
			if (at_reporting != . & sales_reporting != . & empl_reporting == .) & regulation == . & sales== .
			
		replace regulation = (sales>sales_reporting & sales!=.) ///
			if (at_reporting != . & sales_reporting != . & empl_reporting == .) & regulation == . & at== .
			
	replace regulation = (at>at_reporting & at!=. & empl>empl_reporting & empl!=.) ///
		if at_reporting != . & sales_reporting == . & empl_reporting != .					

		/* Missing size values */
		replace regulation = (at>at_reporting & at!=.) ///
			if (at_reporting != . & sales_reporting == . & empl_reporting != .) & regulation == . & empl== .
			
		replace regulation = (empl>empl_reporting & empl!=.) ///
			if (at_reporting != . & sales_reporting == . & empl_reporting != .) & regulation == . & at== .
			
	replace regulation = (sales>sales_reporting & sales!=. & empl>empl_reporting & empl!=.) ///
		if at_reporting == . & sales_reporting != . & empl_reporting != .
		
		/* Missing size values */
		replace regulation = (sales>sales_reporting & sales!=.) ///
			if (at_reporting == . & sales_reporting != . & empl_reporting != .) & regulation == . & empl== .
			
		replace regulation = (empl>empl_reporting & empl!=.) ///
			if (at_reporting == . & sales_reporting != . & empl_reporting != .) & regulation == . & sales== .			
	
	/* One threshold  */
	replace regulation = (at>at_reporting & at!=.) ///
		if (at_reporting != . & sales_reporting == . & empl_reporting == .)	& regulation == .
		
	replace regulation = (sales>sales_reporting & sales!=.) ///
		if (at_reporting == . & sales_reporting != . & empl_reporting == .)	& regulation == .		

	replace regulation = (empl>empl_reporting & empl!=.) ///
		if (at_reporting == . & sales_reporting == . & empl_reporting != .)	& regulation == .

/* Audit scope indicator */
gen audit = .
label var audit "Audit Regulation (Indicator)"

	/* Three thresholds */
	replace audit = ((at>at_audit & at!=. & sales>sales_audit & sales!=.) | (at>at_audit & at!=. & empl>empl_audit & empl!=.) | (sales>sales_audit & sales!=. & empl>empl_audit & empl!=.)) ///
		if (at_audit!=. & sales_audit!=. & empl_audit!=.)
		
		/* Missing size values */
		replace audit = (at>at_audit & at!=.) ///
			if (at_audit!=. & sales_audit!=. & empl_audit!=.) & audit == . & empl== . & sales== .
			
		replace audit = (sales>sales_audit & sales!=.) ///
			if (at_audit!=. & sales_audit!=. & empl_audit!=.) & audit == . & at== . & empl== .
			
		replace audit = (empl>empl_audit & empl!=.) ///
			if (at_audit!=. & sales_audit!=. & empl_audit!=.) & audit == . & at==. & sales==.		
		
	/* Two thresholds */	
	replace audit = (at>at_audit & at!=. & sales>sales_audit & sales!=.) ///
		if at_audit != . & sales_audit != . & empl_audit == .

		/* Missing size values */
		replace audit = (at>at_audit & at!=.) ///
			if (at_audit != . & sales_audit != . & empl_audit == .) & audit == . & sales== .
			
		replace audit = (sales>sales_audit & sales!=.) ///
			if (at_audit != . & sales_audit != . & empl_audit == .) & audit == . & at== .
			
	replace audit = (at>at_audit & at!=. & empl>empl_audit & empl!=.) ///
		if at_audit != . & sales_audit == . & empl_audit != .					

		/* Missing size values */
		replace audit = (at>at_audit & at!=.) ///
			if (at_audit != . & sales_audit == . & empl_audit != .) & audit == . & empl== .
			
		replace audit = (empl>empl_audit & empl!=.) ///
			if (at_audit != . & sales_audit == . & empl_audit != .) & audit == . & at== .
			
	replace audit = (sales>sales_audit & sales!=. & empl>empl_audit & empl!=.) ///
		if at_audit == . & sales_audit != . & empl_audit != .
		
		/* Missing size values */
		replace audit = (sales>sales_audit & sales!=.) ///
			if (at_audit == . & sales_audit != . & empl_audit != .) & audit == . & empl== .
			
		replace audit = (empl>empl_audit & empl!=.) ///
			if (at_audit == . & sales_audit != . & empl_audit != .) & audit == . & sales== .			
	
	/* One threshold  */
	replace audit = (at>at_audit & at!=.) ///
		if (at_audit != . & sales_audit == . & empl_audit == .)	& audit == .
		
	replace audit = (sales>sales_audit & sales!=.) ///
		if (at_audit == . & sales_audit != . & empl_audit == .)	& audit == .		

	replace audit = (empl>empl_audit & empl!=.) ///
		if (at_audit == . & sales_audit == . & empl_audit != .)	& audit == .

/* Country-industry-level scope */
			
	/* Reporting */
	egen scope = mean(regulation), by(country industry year)
	label var scope "Scope (Country-Industry-Year)"
	 
	/* Audit */
	egen audit_scope = mean(audit), by(country industry year)
	label var audit_scope "Audit Scope (Country-Industry-Year)"
		
/* Preserve */
preserve

	/* Duplicates */
	duplicates drop country industry year, force
		
	/* Keep */
	keep country industry year scope audit_scope at_reporting at_* sales_* empl_*
	
	/* Save */
	save Scope, replace
	
/* Restore */
restore

********************************************************************************
**** (4) Simulated scope													****
********************************************************************************

/* Keep full disclosure countries */
keep if bs_publication == 1 & is_publication == 1 
drop bs_* is_* notes_*

/* Drop irrelevant data */
keep industry at empl sales

/* Delete prior Monte Carlo simulation */
capture {
	cd "`directory'\Data\Simulation"
	local datafiles: dir "`directory'\Data\Simulation" files "MC*.dta"
	foreach datafile of local datafiles {
			rm `datafile'
	}
}
	
/* Monte Carlo/Multivariate distribution */

	/* Logarithm (wse +1 adjustment in regulatory thresholds) */
	gen ln_at=ln(at)
	gen ln_sales=ln(sales+1)
	gen ln_empl=ln(empl+1)
 
	/* Draws (multivariate log-normal following Gibrat's Law) [growth rate independent of absolute size; see JEL article in IO] */
	gen n_at = (at != .)
	gen n_sa = (sales != .)
	gen n_em = (empl != .)
	egen count = total(n_at*n_sa*n_em), by(industry) missing
	egen group = group(industry) if count >= 200
	
	/* Loop through industries */
	sum group
	forvalues i=1/`r(max)' {
		
		/* Moments */
		foreach var of varlist at sales empl {
			sum ln_`var' if group==`i'
			local `var'_mean=`r(mean)'
			local `var'_sd=`r(sd)'
				
			foreach var2 of varlist at sales empl {
				corr ln_`var' ln_`var2' if group==`i'
				local `var'_`var2'=`r(rho)'
			}
		}
			
		/* Monte Carlo (use correlations: scale free; alleviates upward bias from missing variables in lower tail) */
		preserve
		
			/* Matrices */
			matrix mean_vector=(`at_mean' \ `sales_mean' \ `empl_mean')
			matrix sd_vector=(`at_sd' \ `sales_sd' \ `empl_sd')
			matrix corr_matrix=(1, `at_sales', `at_empl' \ `sales_at', 1, `sales_empl' \ `empl_at', `empl_sales', 1)
		
			/* MV-normal draw */
			set seed 1234
			drawnorm at sales empl, n(100000) means(mean_vector) sds(sd_vector) corr(corr_matrix) clear
			
			/* Log variables */
			gen y = sales
			gen k = at // approximation of fias
			gen l = empl
			
			/* Exponentiate (including adjustments -1) */
			replace at = exp(at)
			replace sales = exp(sales)-1
			replace empl = exp(empl)-1								
				
			/* Group ID */
			gen group=`i'
			
			/* Saving */
			cd "`directory'\Data\Simulation"
			save MC_industry_`i', replace
			
		restore
	}
	
	/* Save group-industry-correspondence */
	keep if group!=.
	duplicates drop group, force
	keep industry group
	save Correspondence, replace
	
/* Data */	
cd "`directory'\Data"
use Scope, clear

/* Monte Carlo simulation */
				
	/* MC consolidation */
	preserve
		clear all
		cd "`directory'\Data\Simulation"
		! dir MC_industry_*.dta /a-d /b >"`directory'\Data\Simulation\filelist.txt", replace

		file open myfile using "`directory'\Data\Simulation\filelist.txt", read

		file read myfile line
		use `line'
		save MC, replace

		file read myfile line
		while r(eof)==0 { /* while you're not at the end of the file */
			append using `line'
			file read myfile line
		}
		file close myfile
		
		/* Merge Correspondence */
		merge m:1 group using Correspondence
		keep if _merge==3
		drop _merge group
		
		/* Saving */
		save MC, replace
		
	restore

/* Country-industry looping: Monte Carlo */
egen cy_id = group(country year) if at_reporting != . | sales_reporting != . | empl_reporting != . | at_audit != . | sales_audit != . | empl_audit != .
sum cy_id
forvalues i=1/`r(max)' {
	
	/* Reporting */
	sum at_reporting if cy_id==`i'
	cap global at_rep=`r(mean)'
	
	sum sales_reporting if cy_id==`i'
	cap global sa_rep=`r(mean)'
	
	sum empl_reporting if cy_id==`i'
	cap global em_rep=`r(mean)'
	
	/* Audit */
	sum at_audit if cy_id==`i'
	cap global at_au=`r(mean)'
	
	sum sales_audit if cy_id==`i'
	cap global sa_au=`r(mean)'
	
	sum empl_audit if cy_id==`i'
	cap global em_au=`r(mean)'
	
	preserve

		/* MC Sample */
		cd "`directory'\Data\Simulation"
		use MC, clear
			
		/* Thresholds */

			/* Actual */	
				
				/* Reporting */
				gen rep = .
				
					/* Three thresholds */
					cap replace rep = ((at>${at_rep} & sales>${sa_rep}) | (at>${at_rep} & empl>${em_rep}) | (sales>${sa_rep} & empl>${em_rep})) ///
						if ${at_rep} != . & ${sa_rep} != . & ${em_rep} != .

					/* Two thresholds */
					cap replace rep = (at>${at_rep} & sales>${sa_rep}) ///
						if ${at_rep} != . & ${sa_rep} != . & ${em_rep} == .

					cap replace rep = (at>${at_rep} & empl>${em_rep}) ///
						if ${at_rep} != . & ${sa_rep} == . & ${em_rep} != .						

					cap replace rep = (sales>${sa_rep} & empl>${em_rep}) ///
						if ${at_rep} == . & ${sa_rep} != . & ${em_rep} != .	
						
					/* One threshold */
					cap replace rep = (at>${at_rep}) ///
						if ${at_rep} != . & ${sa_rep} == . & ${em_rep} == .					
					
					cap replace rep = (sales>${sa_rep}) ///
						if ${at_rep} == . & ${sa_rep} != . & ${em_rep} == .	

					cap replace rep = (empl>${em_rep}) ///
						if ${at_rep} == . & ${sa_rep} == . & ${em_rep} != .	
						
				/* Auditing */
				gen aud = .
				
					/* Three thresholds */
					cap replace aud = ((at>${at_au} & sales>${sa_au}) | (at>${at_au} & empl>${em_au}) | (sales>${sa_au} & empl>${em_au})) ///
						if ${at_au} != . & ${sa_au} != . & ${em_au} != .

					/* Two thresholds */
					cap replace aud = (at>${at_au} & sales>${sa_au}) ///
						if ${at_au} != . & ${sa_au} != . & ${em_au} == .

					cap replace aud = (at>${at_au} & empl>${em_au}) ///
						if ${at_au} != . & ${sa_au} == . & ${em_au} != .						

					cap replace aud = (sales>${sa_au} & empl>${em_au}) ///
						if ${at_au} == . & ${sa_au} != . & ${em_au} != .	
						
					/* One threshold */
					cap replace aud = (at>${at_au}) ///
						if ${at_au} != . & ${sa_au} == . & ${em_au} == .					
					
					cap replace aud = (sales>${sa_au}) ///
						if ${at_au} == . & ${sa_au} != . & ${em_au} == .	

					cap replace aud = (empl>${em_au}) ///
						if ${at_au} == . & ${sa_au} == . & ${em_au} != .	
			
		/* Aggregation */
				
			/* Reporting */	
			egen mc_scope = mean(rep), by(industry)
			
			/* Audit */
			egen mc_audit = mean(aud), by(industry)

		/* Relevant Observations */
		keep industry mc_*
		duplicates drop industry, force

		/* Identifier */
		gen cy_id = `i'			
			
		/* Saving */
		save MC_final_`i', replace
	
	restore
}

/* Merging */

	/* Monte Carlo (Industry) */
	sum cy_id, d
	forvalues i=1/`r(max)' {
		cd "`directory'\Data\Simulation\"
		merge m:m cy_id industry using MC_final_`i', update
		drop if _merge==2
		drop _merge
	}

********************************************************************************
**** (5) Cleaning, timing, and saving										****
********************************************************************************

/* Duplicates */
keep country industry year scope* audit_scope* joint_scope* mc_*
duplicates drop country industry year, force

/* Time (shifting back 1 year) */
replace year = year + 1

/* Labeling */
label var country "Country"
label var industry "NACE Industry (4-Digit)"
label var year "Year" 
label var mc_scope "Scope (MC)"
label var mc_audit "Audit Scope (MC)"

/* Save */
cd "`directory'\Data"
save Scope, replace

/* Project */
project, creates("`directory'\Data\Scope.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Database construction												****
********************************************************************************

/* Constructing company data */
project, do(Dofiles/Companies.do)

/* Constructing panel data (financials + company) */
project, do(Dofiles/Panel.do)

/* Constructing outcomes */
project, do(Dofiles/Outcomes.do)

/* Constructing regulatory threshold data */
project, do(Dofiles/Regulation.do)

/* Constructing scope measure */
project, do(Dofiles/Scope.do)


********************************************************************************
**** (3) Analyses															****
********************************************************************************

/* Constructing sample */
project, do(Dofiles/Data.do)

/* Running analyses */
project, do(Dofiles/Analyses.do)

/* Generating graphs */
project, do(Dofiles/Graphs.do)


********************************************************************************
**** (4) Identifiers [JAR Code & Data Policy]								****
********************************************************************************

/* Generating graphs */
project, do(Dofiles/Identifiers.do)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Setup of "project" program									****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Master directory ****
local master = "...\Project_Europe\Programs" // please insert/adjust directory path

********************************************************************************
**** (0) Install external program ("project")								****
********************************************************************************

**** Install ****
ssc install project

********************************************************************************
**** (1) Setup and building project: Local									****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Europe.do")

**** Build ****
cap noisily project Master_Europe, build
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Coverage (outcome) part calculated based on AMA	[Excerpt]	****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Amadeus"

**** Project ****
project, uses("`directory'\Amadeus\AMA_data.dta")

********************************************************************************
**** (1) Number of firms													****
********************************************************************************

/* Data */
use AMA_data, clear

/* Specify: level of industry (2-digit) */
rename industry industry_4
gen industry = floor(industry_4/100)
label var industry "Industry (2-Digit NACE/WZ)"

/* Restrict: limited liability firms */
keep if limited == 1
				
/* Balance sheet disclosure */
gen disclosure = (at != .)
label var disclosure "Disclosure (TA available from limited firms)"
				
/* Number of firms */
egen double no_firms = total(disclosure), by(county industry year)
label var no_firms "Number of disclosing (limited) firms"

********************************************************************************
**** (2) Cleaning, labeling, and saving										****
********************************************************************************

/* Keep relevant variables */
keep industry county year no_firms

/* Lag coverage/scope variables (t-2) */
replace year = year+2

/* Save */
cd "`directory'\Data"
save AMA_coverage, replace

/* Prior Stata Version for Destatis */
saveold AMA_coverage_2013, replace

/* Project */
project, creates("`directory'\Amadeus\AMA_coverage.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Amadeus dataset creation [Excerpt]							****
********************************************************************************
**** Note:		Executed on local computer to create AMA dataset to be 		****
****			transferred to and used by Statistisches Bundesamt (on-site)****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Amadeus"

**** Project ****
project, original("`directory'\Amadeus\germany_Financials_2005.dta")
project, original("`directory'\Amadeus\germany_Financials_2008.dta")
project, original("`directory'\Amadeus\germany_Financials_2012.dta")
project, original("`directory'\Amadeus\germany_Financials_2016.dta")
project, original("`directory'\Amadeus\germany_Company_2005.dta")
project, original("`directory'\Amadeus\germany_Company_2008.dta")
project, original("`directory'\Amadeus\germany_Company_2012.dta")
project, original("`directory'\Amadeus\germany_Company_2016.dta")
project, uses("`directory'\Amadeus\AMA_panel.dta")
project, uses("`directory'\Amadeus\AMA_panel_unique.dta")

********************************************************************************
**** (1) Creating unified datasets by vintage								****
********************************************************************************

/* Financials */

	/* Vintage: 2005 */
	
		/* Data */
		use germany_Financials_2005, clear
		
		/* Relevant variables */
		keep accnr idnr consol statda toas empl opre turn
		
		/* Generate year */
		split statda, p(/)
		destring statda*, replace
		replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
		replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
		rename statda3 year
		replace year = year - 1 if statda1 <=6
		drop statda*
		
		/* Save */
		save Financials_2005, replace

	/* Vintage: 2008 */
	
		/* Data */
		use germany_Financials_2008, clear
		
		/* Relevant variables */
		keep accnr idnr consol statda toas empl opre turn
		
		/* Generate year */
		split statda, p(/)
		destring statda*, replace
		replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
		replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
		rename statda3 year
		replace year = year - 1 if statda1 <=6
		drop statda*
		
		/* Save */
		save Financials_2008, replace	
	
	/* Vintage: 2012 */
	
		/* Data */
		use germany_Financials_2012, clear
		
		/* Relevant variables */
		keep accnr idnr consol statda toas empl opre turn
		
		/* Generate year */
		split statda, p(/)
		destring statda*, replace
		replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
		replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
		rename statda3 year
		replace year = year - 1 if statda1 <=6
		drop statda*
		
		/* Save */
		save Financials_2012, replace		
	
	/* Vintage: 2016 */

		/* Data */
		use germany_Financials_2016, clear
		
		/* Relevant variables */
		keep idnr unit closdate closdate_year toas empl opre turn
		
		/* Generate year */
		gen closdate_month = month(closdate)
		gen year = closdate_year
		replace year = year - 1 if closdate_month <= 6
		drop closdate*	
		
		/* Save */
		save Financials_2016, replace
	
/* Company (Type, unit, sales, and employees data) */

	/* Vintage: 2005 */
	
		/* Data */
		use germany_Company_2005, clear
	
		/* Relevant variables */
		keep accnr type unit 
		
		/* Save */
		save Company_2005, replace
		
	/* Vintage: 2008 */
	
		/* Data */
		use germany_Company_2008, clear
	
		/* Relevant variables */
		keep accnr type unit 
		
		/* Destring unit */
		destring unit_string, gen(unit)
		drop unit_string
		
		/* Save */
		save Company_2008, replace
	
	/* Vintage: 2012 */
	
		/* Data */
		use germany_Company_2012, clear
	
		/* Relevant variables */ /* missing: unit! */
		keep accnr type
		
		/* Save */
		save Company_2012, replace	
	
	/* Vintage: 2016 */

		/* Data */
		use germany_Company_2016, clear
	
		/* Relevant variables */
		keep accnr idnr type consol
		
		/* Save */
		save Company_2016, replace
		
/* Combination */

	/* Vintage: 2005 */
	
		/* Data */
		use Financials_2005, clear
	
		/* Merge company data */
		merge m:m accnr using Company_2005
		drop if _merge == 2
		drop _merge
		
		/* Unit conversion */
		local num_list = "toas"
		foreach var of varlist `num_list' {
			replace `var' = `var'*10^unit
		}

		/* Save */
		save Combined_2005, replace
		
	/* Vintage: 2008 (units: thousands) */
	
		/* Data */
		use Financials_2008, clear
	
		/* Merge company data */
		merge m:m accnr using Company_2008
		drop if _merge == 2
		drop _merge
		
		/* Unit conversion */
		local num_list = "toas"
		foreach var of varlist `num_list' {
			replace `var' = `var'*10^3 // in thousands
		}

		/* Save */
		save Combined_2008, replace
		
	/* Vintage: 2012 */
	
		/* Data */
		use Financials_2012, clear
	
		/* Merge company data */
		merge m:m accnr using Company_2012
		drop if _merge == 2
		drop _merge
		
		/* Save */
		save Combined_2012, replace

	/* Vintage: 2016 */
	
		/* Data */
		use Financials_2016, clear
	
		/* Merge company data */
		merge m:m idnr using Company_2016
		drop if _merge == 2
		drop _merge

		/* Save */
		save Combined_2016, replace
		
	/* Combined vintages (2005, 2008, 2012, and 2016) */
	
		/* Data */
		use Combined_2005, clear
		
		/* Update until 2008 */
		merge m:m accnr year using Combined_2008, update
		drop _merge
		
		/* Update until 2012 */
		merge m:m accnr year using Combined_2012, update
		drop _merge
		
		/* Update until 2016 */
		merge m:m accnr year using Combined_2016, update
		drop _merge

		/* Duplicates */
		egen double id = group(accnr)
		duplicates drop id year, force
		xtset id year
	
		/* Consolidation: avoid duplication (drop duplicates associated with C2) */
		rename idnr bvd_id	
		duplicates tag bvd_id year, gen(dup)
		gen con = (consol == "C2")
		egen c2 = max(con), by(bvd_id)
		drop if dup != 0 & (consol != "C2") & c2 == 1
		sort bvd_id year dup
		duplicates drop bvd_id year if dup != 0, force
		drop dup
		
		/* Sample period */
		keep if year >= 2000 & year <= 2014
		
		/* County & industry definitions */
			
			/* Define time dimension: vintage */
			gen vintage = year
			
			/* Merge company panel (bvd_id vintage: 2005-2014)*/
			merge 1:1 bvd_id vintage using AMA_panel, keepusing(industry ags)
			drop if _merge == 2
			drop _merge
			
			/* Apply earliest vintage to previous years (2000-2004) */
			drop id
			egen double id = group(bvd_id)
			xtset id year
			forvalues y = 1(1)6 {
				foreach var of varlist industry ags {
					replace `var' = f.`var' if `var' == . & f.`var' != . & vintage == 2008-`y'
				}
			}
			
			/* Merge company panel (bvd_id; update) */
			merge m:1 bvd_id using AMA_panel_unique, keepusing(industry ags) update
			drop if _merge == 2
			drop _merge
			
			/* Drop missing observations */
			drop if industry == . | ags ==.
			
			/* County identifier */
			tostring ags, gen(ags_string)
			gen county = substr(ags_string, -6, 3)
			egen county_id = group(county)
			drop ags_string

********************************************************************************
**** (2) (Re)Defining variables												****
********************************************************************************

/* Limited liability indicator */
gen limited = 0
replace limited = 1 if ///
	regexm(type, "AG") == 1 | ///
	regexm(type, "limited liability") == 1 | ///
	regexm(type, "European company") == 1 | ///
	regexm(type, "GmbH") == 1 | ///
	regexm(type, "Public limited") == 1

/* Total assets */
rename toas at

********************************************************************************
**** (3) Cleaning, labeling, and saving										****
********************************************************************************

/* Duplicates drop */
sort id year
duplicates drop id year, force

/* Keep relevant variables */
keep bvd_id year industry ags county county_id at sales empl limited
 
/* Labels */
label var bvd_id "BvD ID"
label var year "Fiscal Year"
label var industry "NACE 2 (WZ 2008)"
label var ags "AGS (BBSR, Destatis; manual)"
label var county "County (String)"
label var county_id "County ID (Numeric)"
label var at "Total Assets"
label var limited "Limited liability"

/* Save (final AMA data) */
save AMA_data, replace

/* Delete individual datasets */
forvalues y = 2005(1)2016 {
	capture {
		rm Company_`y'.dta
		rm Financials_`y'.dta
		rm Combined_`y'.dta
	}
}

/* Project */
project, creates("`directory'\Amadeus\AMA_data.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/23/2017													****
**** Program:	Amadeus ID and city panel [Excerpt]							****
********************************************************************************
**** Note:		Executed on local computer to create AMA dataset to be 		****
****			transferred to and used by Statistisches Bundesamt (on-site)****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Amadeus"

**** Project ****
forvalues year = 2005(1)2016 {
	project, original("`directory'\Amadeus\germany_Company_`year'.dta")
}
project, original("`directory'\Amadeus\correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format.dta")
project, original("`directory'\Amadeus\Counties.csv")

********************************************************************************
**** (1) Creating unified datasets by vintage								****
********************************************************************************

forvalues year = 2005(1)2016 {

	/* Data */
	use germany_Company_`year', clear
	
	/* Rename */
	cap rename company company_name
	cap rename name company_name
	cap rename zip zipcode
	cap rename bvd_id_number bvd_id
	cap rename idnr bvd_id
	cap rename nacpri nace_ind
	cap rename nac2pri nace2_ind
	cap rename nacerev2primarycode nace2_ind
	cap rename nace_prim_code nace2_ind
	
	/* Keep relevant data */
	cap keep bvd_id company_name city zipcode nace_ind
	cap keep bvd_id company_name city zipcode nace2_ind
	
	/* Industry */
	cap destring nace_ind, replace
	cap destring nace2_ind, replace
	
	/* Vintage */
	gen vintage = `year'
	
	/* Append */
	if `year' == 2005 {
		
		/* Save panel */
		cap rm AMA_panel.dta
		save AMA_panel, replace
	}
	
	if `year' > 2005 {
		
		/* Append */
		append using AMA_panel
		
		/* Save panel */
		save AMA_panel, replace	
	}
}

/* ID */
drop if bvd_id == "" | substr(bvd_id, 1, 2) != "DE"
egen double id = group(bvd_id)

/* Duplicates (tag) */
duplicates tag id vintage, gen(dup)

/* Drop: missing location or industry if duplicate */
drop if dup > 0 & (city == "" | (nace_ind == . & nace2_ind == .))
drop dup

/* Duplicates (drop) */
sort id vintage
duplicates drop id vintage, force

/* Panel */
xtset id vintage

/* Save */
save AMA_panel, replace

********************************************************************************
**** (2) Creating industry and location correspondence tables				****
********************************************************************************

/* Industry (NACE) correspondence (Sebnem et al. (2015)) */

	/* Correspondence table */
	use correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format, clear

	/* Keep relevant variables */
	keep nacerev11 nacerev2 descriptionrev2
	
	/* Destring code */
	destring nacerev11 nacerev2, ignore(".") replace force
	
	/* Keep if non-missing */
	keep if nacerev11 != . & nacerev2 != .
	
	/* Rename */
	rename nacerev11 nace_ind
	rename nacerev2 nace2_ind_corr
	
	/* Save */
	save NACE_correspondence, replace
	
	/* Project */
	project, creates("`directory'\Amadeus\NACE_correspondence.dta")

/* AGS correspondence (BBSR; Destatis; manual) */

	/* Import (.csv data from Excel match) */
	import delimited using Counties.csv, delimiter(",") varnames(1) clear
	
	/* Keep relevant variables */
	keep city zipcode match_name agsall
	
	/* Rename */
	rename agsall ags
	rename match_name city_1
	
	/* Save */
	save AGS_correspondence, replace
	
	/* Duplicates */
	sort city_1
	duplicates drop city_1, force
	
	/* Save */
	save AGS_correspondence_1, replace

	/* Project */
	project, creates("`directory'\Amadeus\AGS_correspondence.dta")
	project, creates("`directory'\Amadeus\AGS_correspondence_1.dta")
	
********************************************************************************
**** (3) Converging industry and location definitions						****
********************************************************************************

/* Data */
use AMA_panel, clear

/* Merge: Industry correspondence */
merge m:1 nace_ind using NACE_correspondence
drop if _merge ==2
drop _merge

/* Drop NACE description */
drop description*

/* Generate converged industry */
gen industry = nace2_ind

/* Backfilling (using panel information) */
xtset id vintage
forvalues y = 1(1)11 {
	replace industry = f.industry if industry == . & f.industry != . & vintage == 2016 - `y'
}

/* Filling in missing values (using correspondence table) */
replace industry = nace2_ind_corr if industry == .
drop nace*

/* Mode: Filling in missing values (using mode of industry code per firm) */
egen industry_mode = mode(industry), by(id)
replace industry = industry_mode if industry == .
drop industry_mode

/* Destring zipcode */
destring zipcode, replace force

/* Merge (1): Location correspondence (exact match) */
merge m:1 city zipcode using AGS_correspondence, keepusing(ags)
drop if _merge == 2
drop _merge

/* Merge (2): Location correspondence (name (city) match) */
merge m:1 city using AGS_correspondence, keepusing(ags) update
drop if _merge == 2
drop _merge

/* Merge (3): Location correspondence (name (city_1) match) */
rename city city_1
merge m:1 city_1 using AGS_correspondence_1, keepusing(ags) update
drop if _merge == 2
drop _merge
rename city_1 city

/* Destring AGS */
destring ags, replace force

/* Backfilling (using panel information: backward and forward) */
sort id vintage
duplicates drop id vintage, force
xtset id vintage
forvalues y = 1(1)11 {
	replace ags = f.ags if ags == . & f.ags != . & vintage == 2016 - `y'
}

forvalues y = 1(1)11 {
	replace ags = l.ags if ags == . & l.ags != . & vintage == 2005 + `y'
}

/* Mode: Filling in missing (using AGS by city and vintage) */
egen ags_mode = mode(ags), by(city vintage)
replace ags = ags_mode if ags_mode != .
drop ags_mode

********************************************************************************
**** (4) Cleaning, labeling, and saving										****
********************************************************************************

/* Keep relevant variables */
keep id bvd_id vintage industry ags

/* Keep observations with non-missing industry and location information */
drop if industry == . | ags == .

/* Label variables */
label var id "ID (Numeric)"
label var bvd_id "BvD ID (String)"
label var vintage "Vintage (Year of BvD disc)"
label var industry "NACE 2 (WZ 2008)"
label var ags "AGS (Location identifier)"

/* Save */
save AMA_panel, replace

********************************************************************************
**** (5) Unique																****
********************************************************************************

/* Duplicates drop */
sort bvd_id vintage
duplicates drop bvd_id, force

/* Save */
save AMA_panel_unique, replace

/* Project */
project, creates("`directory'\Amadeus\AMA_panel.dta")
project, creates("`directory'\Amadeus\AMA_panel_unique.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Analysis on county, industry, year level (AMA, URS, GWS)	****
****			[Excerpt]													****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: Data.dta
	Variables:
		- county			County (Kreis)
		- state				State (Bundesland)
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- sales 			Sales (Estimated taxable sales)
		- empl				Employees (1+Employees)
		- hhi				Herfindahl-Hirschman Index (Concentration)
		- entry_main		Entry (Log count; Main business)
		- entry_sub			Entry (Log count; Subsidiary)
		- exit_main			Exit (Log count; Main business)
		- exit_close 		Exit (Log count; Insolvency) 
		- coverage 			Coverage (Actual) (ratio of number of firms in AMA over number of firms in URS in same county-industry-year)
		- limited_share 	Share of limited firms among all firms (limited + unlimited; pre-period)
		- s_firms			Median split (number of firms, pre-period)
		- county_id 		County ID (numeric)
		- ci 				County-Industry ID (numeric)
		- cy 				County-Year ID (numeric)	
		- state_id 			State ID (numeric)
		- si 				State-Industry ID (numeric)
		- sy 				State-Year ID (numeric)
		- iy 				Industry-Year ID (numeric)	
		- post				Post (indicator taking value of 1 for years after 2007)
		- y_2003			Year 2003
		- y_2004			Year 2004
		- y_2005			Year 2005
		- y_2006			Year 2006
		- y_2007			Year 2007
		- y_2008			Year 2008
		- y_2009			Year 2009
		- y_2010			Year 2010
		- y_2011			Year 2011
		- y_2012			Year 2012		
		- trend				Linear time trend
	
Comment:
This program runs multivariate analyses using county-industry-year observations.
*/

**** Preliminaries ****
version 15.1
clear all
set more off
set varabbrev off

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Data.dta")

********************************************************************************
**** (1) Preparing data														****
********************************************************************************

/* Data (URS) */ 
use Data, clear

/* Duplicates drop */
duplicates drop county industry year, force

/* Sample period */
keep if year >= 2003 & year <= 2012

/* Panel */
xtset ci year
	
********************************************************************************
**** (2) Regressions: County-industry-year analyses							****
********************************************************************************

/* Panel: county-industry year */
xtset ci year

/* Log file: open */
cd "`directory'\Output\Logs"
log using Enforcement.smcl, replace smcl name(Enforcement) 

/* Regression inputs (treatment: lagged by two years (see AMA_coverage.do)) */
local DepVar = "coverage entry_main exit_main hhi"
local IndVar = "limited_share"

/* OLS Regression: county-industry + county-year + industry-year fixed effects with instrument */
foreach x of varlist `IndVar' {
	foreach y of varlist `DepVar' {

		/* Preserve */
		preserve
					
			/* Capture */
			capture noisily {
			
				/* Truncation */
				
					/* Outcome */
					qui reghdfe `y' if `x' != ., a(ci cy iy) residuals(res_`y')

					/* Treatment */
					qui reghdfe `x' if `y' != ., a(ci cy iy) residuals(res_`x')
					
					/* Replace */
					qui sum res_`y', d
					qui replace `y' = . if res_`y' > r(p99) | res_`y' < r(p1)
					
					qui sum res_`x', d
					qui replace `x' = . if res_`x' > r(p99) | res_`x' < r(p1)					
						
				/* Estimation */
				qui reghdfe `y' `x' c.`x'#1.y_2003 c.`x'#1.y_2004 c.`x'#1.y_2005 c.`x'#1.y_2007 c.`x'#1.y_2008 c.`x'#1.y_2009 c.`x'#1.y_2010 c.`x'#1.y_2011 c.`x'#1.y_2012, a(ci cy iy) cluster(county_id)
				
				/* Output */
				estout, keep(1.y_2003#c.`x' 1.y_2004#c.`x' 1.y_2005#c.`x' 1.y_2007#c.`x' 1.y_2008#c.`x' 1.y_2009#c.`x' 1.y_2010#c.`x' 1.y_2011#c.`x' 1.y_2012#c.`x') cells(b(star fmt(3)) t(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
					legend label title("SPECIFICATION: COUNTY-INDUSTRY, COUNTY-YEAR, INDUSTRY-YEAR FE WITH INSTRUMENT (Base: 2006; OLS)") ///
					mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
					stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "# Clusters" "Adjusted R-Squared"))
					
				/* Joint test */
				qui test (1.y_2003#c.`x'+1.y_2004#c.`x'+1.y_2005#c.`x')=(1.y_2007#c.`x'+1.y_2008#c.`x'+1.y_2009#c.`x'+1.y_2010#c.`x'+1.y_2011#c.`x'+1.y_2012#c.`x')
				di "Joint F-test (pre- vs. post-period): F " round(`r(F)', 0.01) ", p " round(`r(p)', 0.001)	
			}
						
		/* Restore */
		restore	
	}
}

********************************************************************************
**** (3) Cross-Section: County-industry-year analyses						****
********************************************************************************

/* Regression inputs */
local DepVar = "entry_sub exit_close hhi"
local IndVar = "limited_share"
local SplVar = "s_firms"

/* Split */
foreach s of varlist `SplVar' { 

	/* Generate split variable */
	egen median = median(`s')	
				
	/* Regression: county-industry + county-year + industry-year fixed effects */
	foreach x of varlist `IndVar' {
		foreach y of varlist `DepVar' {
			
			/* Preserve */
			preserve

				/* Capture */
				capture noisily {
				
					/* Truncation */
					
						/* Outcome */
						qui reghdfe `y' if `x' != ., a(ci cy iy) residuals(res_`y')

						/* Treatment */
						qui reghdfe `x' if `y' != ., a(ci cy iy) residuals(res_`x')
						
						/* Replace */
						qui sum res_`y', d
						qui replace `y' = . if res_`y' > r(p99) | res_`y' < r(p1)
						
						qui sum res_`x', d
						qui replace `x' = . if res_`x' > r(p99) | res_`x' < r(p1)					
							
					/* Estimation */
					qui reghdfe `y' `x' c.`x'#1.y_2003 c.`x'#1.y_2004 c.`x'#1.y_2005 c.`x'#1.y_2007 c.`x'#1.y_2008 c.`x'#1.y_2009 c.`x'#1.y_2010 c.`x'#1.y_2011 c.`x'#1.y_2012 if `s' >= median & `s' != ., a(ci cy iy) cluster(county_id)
						est store M1
						
					qui reghdfe `y' `x' c.`x'#1.y_2003 c.`x'#1.y_2004 c.`x'#1.y_2005 c.`x'#1.y_2007 c.`x'#1.y_2008 c.`x'#1.y_2009 c.`x'#1.y_2010 c.`x'#1.y_2011 c.`x'#1.y_2012 if `s' < median & `s' != ., a(ci cy iy) cluster(county_id)
						est store M2
						
					/* Output */
					estout M1 M2, keep(1.y_2003#c.`x' 1.y_2004#c.`x' 1.y_2005#c.`x' 1.y_2007#c.`x' 1.y_2008#c.`x' 1.y_2009#c.`x' 1.y_2010#c.`x' 1.y_2011#c.`x' 1.y_2012#c.`x') cells(b(star fmt(3)) t(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label title("SPECIFICATION: COUNTY-INDUSTRY, COUNTY-YEAR, INDUSTRY-YEAR FE WITH INSTRUMENT (Base: 2006)" "SPLIT: `s'") ///
						mgroups("High" "Low", pattern(0 1)) mlabels(, depvars) varwidth(40) modelwidth(22) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "# Clusters" "Adjusted R-Squared"))						
			}
						
			/* Restore */
			restore				
		}
	}
	
	/* Drop */
	drop median
	
}

/* Log file: close */
log close Enforcement
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Combining outcome (URS, GWS) and coverage (AMA) data 		****
****			[Excerpt]													****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: URS_outcome.dta
	Variables:
		- county			County (Kreis)
		- state				State (Bundesland)
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- sales 			Sales (Estimated taxable sales)
		- empl				Employees (1+Employees)
		- limited_fraction 	Fraction of limited firms in all firms
		- no_firms_URS 		Number of firms (URS)
		- hhi				Herfindahl-Hirschman Index (Concentration)
		
	Data file: GWS_outcome.dta
	Variables:
		- county			County (Kreis)
		- state				State (Bundesland)
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- entry_main 		Entry (Log count; Main business)
		- entry_sub			Entry (Log count; Subsidiary)
		- exit_main			Exit (Log count; Main business)
		- exit_close 		Exit (Log count; Insolvency) 
		
	Data file: AMA_coverage.dta
	Variables:
		- county			County (Kreis)
		- industry			Industry (2-Digit NACE/WZ 2008)
		- year				Fiscal Year
		- no_firms			Number of firms with non-missing total assets in Bureau van Dijk's Amadeus (AMA) database 
		
Newly created variables (kept):
		- coverage 			Coverage (Actual) (ratio of number of firms in AMA over number of firms in URS in same county-industry-year)
		- limited_share 	Share of limited firms among all firms (limited + unlimited; pre-period)
		- county_id 		County ID (numeric)
		- ci 				County-Industry ID (numeric)
		- cy 				County-Year ID (numeric)	
		- state_id 			State ID (numeric)
		- si 				State-Industry ID (numeric)
		- sy 				State-Year ID (numeric)
		- iy 				Industry-Year ID (numeric)	
		- post				Post (indicator taking value of 1 for years after 2007)	
		- y_2003			Year 2003
		- y_2004			Year 2004
		- y_2005			Year 2005
		- y_2006			Year 2006
		- y_2007			Year 2007
		- y_2008			Year 2008
		- y_2009			Year 2009
		- y_2010			Year 2010
		- y_2011			Year 2011
		- y_2012			Year 2012

Note:
		- suffix: lim		Uses limited liability firms only
		- suffix: unl		Uses unlimited liability firms only	
	
Comment:
This program merges the county-industry-year level outcomes (from URS and GWS) with the corresponding first-stage outcome (from AMA).
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, uses("`directory'\Data\URS_outcomes.dta")
project, uses("`directory'\Data\GWS_outcomes.dta")
project, original("`directory'\Data\AMA_coverage.dta") // not recreated at Destatis

********************************************************************************
**** (1) Combining datasets (AMA, URS, GWS)									****
********************************************************************************

/* Data (URS) */
use URS_outcomes, clear

/* Merge: GWS outcomes */
merge 1:1 county industry year using GWS_outcomes
drop _merge

/* Merge: AMA coverage */
merge 1:1 county industry year using AMA_coverage, keepusing(no_firms)
keep if _merge == 3
drop _merge

********************************************************************************
**** (2) Generating relevant variables										****
********************************************************************************
		
/* Coverage measures */

	/* Actual coverage */
	gen coverage = min(no_firms/no_firms_URS, 1) if no_firms != . & no_firms_URS != .
	replace coverage = 0 if no_firms == . & no_firms_URS != .
	label var coverage "Coverage (Actual)"

/* Treatment (limited share) */

	/* Limited vs. unlimited firms */
	gen pre = limited_fraction if year == 2006
	egen limited_share = mean(pre), by(county industry)
	label var limited_share "Share of limited firms among all firms (limited + unlimited; pre-period)"
	drop pre
		
/* Identifiers */

	/* Drop missing county, industry, year */
	drop if county == "" | industry == . | year == .
	
	/* County */
	egen county_id = group(county)
	label var county_id "County ID"

	/* Country-industry */
	egen ci = group(county industry)
	label var ci "County-Industry ID"
	
	/* County-year */
	egen cy = group(county year)
	label var cy "County-Year ID"	

	/* State */
	egen state_id = group(state)
	label var state_id "State ID"
	
	/* State-industry */
	egen si = group(state industry)
	label var si "State-Industry ID"
	
	/* State-year */
	egen sy = group(state year)
	label var sy "State-Year ID"
	
	/* Industry-year */
	egen iy = group(industry year)
	label var iy "Industry-Year ID"	
	
	/* Individual years */
	forvalues y = 2003(1)2012 {
		gen y_`y' = (year == `y')
		label var y_`y' "`y'"
	}

	/* Trend */
	gen trend = (year - 2003)
	label var trend "Trend"

********************************************************************************
**** (3) Saving combined dataset											****
********************************************************************************

/* Save */
save Data, replace

/* Project */
project, creates("`directory'\Data\Data.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Installs external (user-written) programs					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

********************************************************************************
**** (1) Install external programs											****
********************************************************************************

**** Estout ****
ssc install estout, replace

**** Coefplot ****
ssc install coefplot, replace

**** Outreg2 ****
ssc install outreg2, replace

**** Reghdfe ****
ssc install reghdfe, replace
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Graphs [hard-coded; created based on FDZ regression output]	****													
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set varabbrev off

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Output\Figures"

/* Observations */
set obs 10

/* Years */
gen year = 2002 + _n

********************************************************************************
**** Figure 4 Panel A: PUBLIC DISCLOSURE ENFORCEMENT AND ENTRY				****
********************************************************************************

/* Reduced Form: Limited share on entry */

	/* Results */

		/* Coefficients */
		
			/* Aggregate */
			gen b_entry = 0.005 if _n == 1
			replace b_entry = -0.080 if _n == 2
			replace b_entry = -0.053 if _n == 3
			replace b_entry = 0 if _n == 4
			replace b_entry = -0.029 if _n == 5
			replace b_entry = 0.067 if _n == 6
			replace b_entry = 0.160 if _n == 7
			replace b_entry = 0.153 if _n == 8
			replace b_entry = 0.167 if _n == 9
			replace b_entry = 0.150 if _n == 10	
		
		/* Standard errors */
		
			/* Aggregate */
			gen t_entry = 0.11 if _n == 1
			replace t_entry = -1.80 if _n == 2	
			replace t_entry = -1.18 if _n == 3
			replace t_entry = 0 if _n == 4
			replace t_entry = -0.64 if _n == 5
			replace t_entry = 1.54 if _n == 6
			replace t_entry = 3.45 if _n == 7
			replace t_entry = 3.37 if _n == 8
			replace t_entry = 3.70 if _n == 9
			replace t_entry = 3.16 if _n == 10
			gen se_entry = 1/(t_entry/b_entry)
			replace se_entry = 0 if _n == 4

		/* Confidence interval */
		gen ci_entry_low = b_entry - 1.96*se_entry
		gen ci_entry_high = b_entry + 1.96*se_entry
		
	/* Graph: Limited share on entry */
	graph twoway ///
		(rarea ci_entry_high ci_entry_low year, color(gs13)) ///
		(scatter b_entry year, msymbol(o) color(black)) ///		
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Entry") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" "AND ENTRY", color(black)) ///
			saving(Figure_4_Panel_A, replace)

********************************************************************************
**** Figure 4 Panel B: PUBLIC DISCLOSURE ENFORCEMENT AND EXIT				****
********************************************************************************

/* Reduced Form: Limited share on exit */

	/* Results */

		/* Coefficients */
		
			/* Aggregate */
			gen b_exit = -0.012 if _n == 1
			replace b_exit = 0.003 if _n == 2
			replace b_exit = -0.039 if _n == 3
			replace b_exit = 0 if _n == 4
			replace b_exit = -0.072 if _n == 5
			replace b_exit = 0.081 if _n == 6
			replace b_exit = 0.065 if _n == 7
			replace b_exit = 0.099 if _n == 8
			replace b_exit = 0.049 if _n == 9
			replace b_exit = 0.094 if _n == 10	
		
		/* Standard errors */
		
			/* Aggregate */
			gen t_exit = -0.28 if _n == 1
			replace t_exit = 0.07 if _n == 2	
			replace t_exit = -0.88 if _n == 3
			replace t_exit = 0 if _n == 4
			replace t_exit = -1.51 if _n == 5
			replace t_exit = 1.84 if _n == 6
			replace t_exit = 1.44 if _n == 7
			replace t_exit = 2.18 if _n == 8
			replace t_exit = 1.08 if _n == 9
			replace t_exit = 2.09 if _n == 10
			gen se_exit = 1/(t_exit/b_exit)
			replace se_exit = 0 if _n == 4

		/* Confidence interval */
		gen ci_exit_low = b_exit - 1.96*se_exit
		gen ci_exit_high = b_exit + 1.96*se_exit
		
	/* Graph: Limited share on exit */
	graph twoway ///
		(rarea ci_exit_high ci_exit_low year, color(gs13)) ///
		(scatter b_exit year, msymbol(o) color(black)) ///		
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Exit") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" "AND EXIT", color(black)) ///
			saving(Figure_4_Panel_B, replace)

********************************************************************************
**** Figure 4 Panel C: PUBLIC DISCLOSURE ENFORCEMENT AND CONCENTRATION		****
********************************************************************************

/* Reduced Form: Limited share on concentration */

	/* Results */

		/* Coefficients */
		
			/* Aggregate */
			gen b_hhi = -0.003 if _n == 1
			replace b_hhi = 0.006 if _n == 2
			replace b_hhi = 0.003 if _n == 3
			replace b_hhi = 0 if _n == 4
			replace b_hhi = -0.009 if _n == 5
			replace b_hhi = -0.015 if _n == 6
			replace b_hhi = -0.013 if _n == 7
			replace b_hhi = -0.016 if _n == 8
			replace b_hhi = -0.019 if _n == 9
			replace b_hhi = -0.017 if _n == 10	
		
		/* Standard errors */
		
			/* Aggregate */
			gen t_hhi = -0.37 if _n == 1
			replace t_hhi = 0.79 if _n == 2	
			replace t_hhi = 0.50 if _n == 3
			replace t_hhi = 0 if _n == 4
			replace t_hhi = -1.59 if _n == 5
			replace t_hhi = -2.00 if _n == 6
			replace t_hhi = -1.38 if _n == 7
			replace t_hhi = -1.74 if _n == 8
			replace t_hhi = -2.05 if _n == 9
			replace t_hhi = -1.98 if _n == 10
			gen se_hhi = 1/(t_hhi/b_hhi)
			replace se_hhi = 0 if _n == 4

		/* Confidence interval */
		gen ci_hhi_low = b_hhi - 1.96*se_hhi
		gen ci_hhi_high = b_hhi + 1.96*se_hhi
		
	/* Graph: Limited share on concentration */
	graph twoway ///
		(rarea ci_hhi_high ci_hhi_low year, color(gs13)) ///
		(scatter b_hhi year, msymbol(o) color(black)) ///		
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.06(0.02)0.06, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("HHI") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" "AND PRODUCT MARKET CONCENTRATION", color(black)) ///
			saving(Figure_4_Panel_C, replace)

********************************************************************************
**** Figure A1: PUBLIC DISCLOSURE ENFORCEMENT AND DISCLOSURE RATE			****
********************************************************************************

/* First Stage: Limited share on disclosure rate */

	/* Results */

		/* Coefficients */
		gen b_lshare = -0.071 if _n == 1
		replace b_lshare = -0.064 if _n == 2
		replace b_lshare = -0.026 if _n == 3
		replace b_lshare = 0 if _n == 4
		replace b_lshare = 0.26 if _n == 5
		replace b_lshare = 0.293 if _n == 6
		replace b_lshare = 0.275 if _n == 7
		replace b_lshare = 0.260 if _n == 8
		replace b_lshare = 0.250 if _n == 9
		replace b_lshare = 0.235 if _n == 10
		
		/* Standard errors */
		gen t_lshare = -9.04 if _n == 1
		replace t_lshare = -8.35 if _n == 2	
		replace t_lshare = -4.53 if _n == 3
		replace t_lshare = 0 if _n == 4
		replace t_lshare = 21.69 if _n == 5
		replace t_lshare = 27.32 if _n == 6
		replace t_lshare = 24.55 if _n == 7
		replace t_lshare = 21.91 if _n == 8
		replace t_lshare = 22.96 if _n == 9
		replace t_lshare = 22.40 if _n == 10
		gen se_lshare = 1/(t_lshare/b_lshare)
		replace se_lshare = 0 if _n == 4
				
		/* Confidence interval */
		gen ci_lshare_low = b_lshare - 1.96*se_lshare
		gen ci_lshare_high = b_lshare + 1.96*se_lshare
		
	/* Graph: Limited share on disclosure rate */
	graph twoway ///
		(rarea ci_lshare_high ci_lshare_low year, color(gs13)) ///
		(scatter b_lshare year, msymbol(o) color(black)) ///
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.1(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///
			xtitle("Year") ///
			ytitle("Disclosure rate") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" " AND DISCLOSURE RATE", color(black)) ///
			name(Figure_A1, replace)

********************************************************************************
**** Figure A2: PUBLIC DISCLOSURE ENFORCEMENT AND ENTRY OF SUBSIDIARIES		****
********************************************************************************

/* Reduced Form: Limited share on entry */

	/* Results */

		/* Coefficients */
		
			/* High */
			gen b_entry_h = -0.115 if _n == 1
			replace b_entry_h = -0.221 if _n == 2
			replace b_entry_h = -0.139 if _n == 3
			replace b_entry_h = 0 if _n == 4
			replace b_entry_h = 0.085 if _n == 5
			replace b_entry_h = -0.014 if _n == 6
			replace b_entry_h = 0.059 if _n == 7
			replace b_entry_h = -0.017 if _n == 8
			replace b_entry_h = -0.178 if _n == 9
			replace b_entry_h = -0.096 if _n == 10	
	
			/* Low */
			gen b_entry_l = 0.039 if _n == 1
			replace b_entry_l = 0.042 if _n == 2
			replace b_entry_l = -0.060 if _n == 3
			replace b_entry_l = 0 if _n == 4
			replace b_entry_l = 0.096 if _n == 5
			replace b_entry_l = 0.152 if _n == 6
			replace b_entry_l = 0.089 if _n == 7
			replace b_entry_l = 0.179 if _n == 8
			replace b_entry_l = 0.122 if _n == 9
			replace b_entry_l = 0.142 if _n == 10	
			
		/* Standard errors */
		
			/* High */
			gen t_entry_h = -1.15 if _n == 1
			replace t_entry_h = -2.24 if _n == 2	
			replace t_entry_h = -1.31 if _n == 3
			replace t_entry_h = 0 if _n == 4
			replace t_entry_h = 0.86 if _n == 5
			replace t_entry_h = -0.15 if _n == 6
			replace t_entry_h = 0.61 if _n == 7
			replace t_entry_h = -0.18 if _n == 8
			replace t_entry_h = -1.91 if _n == 9
			replace t_entry_h = -0.98 if _n == 10
			gen se_entry_h = 1/(t_entry_h/b_entry_h)
			replace se_entry_h = 0 if _n == 4

			/* Low */
			gen t_entry_l = 0.79 if _n == 1
			replace t_entry_l = 0.82 if _n == 2	
			replace t_entry_l = -1.22 if _n == 3
			replace t_entry_l = 0 if _n == 4
			replace t_entry_l = 1.92 if _n == 5
			replace t_entry_l = 3.29 if _n == 6
			replace t_entry_l = 1.89 if _n == 7
			replace t_entry_l = 3.68 if _n == 8
			replace t_entry_l = 2.48 if _n == 9
			replace t_entry_l = 2.88 if _n == 10
			gen se_entry_l = 1/(t_entry_l/b_entry_l)
			replace se_entry_l = 0 if _n == 4
			
		/* Confidence interval */
		gen ci_entry_h_low = b_entry_h - 1.96*se_entry_h
		gen ci_entry_h_high = b_entry_h + 1.96*se_entry_h

		gen ci_entry_l_low = b_entry_l - 1.96*se_entry_l
		gen ci_entry_l_high = b_entry_l + 1.96*se_entry_l
		
	/* Graph: Limited share on entry */
	graph twoway ///
		(rarea ci_entry_h_high ci_entry_h_low year, color(gs13)) ///
		(scatter b_entry_h year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Entry of subsidiaries") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("HIGH" "(NUMBER OF FIRMS)", color(black)) ///
			name(Entry_h, replace)	
	
	graph twoway ///
		(rarea ci_entry_l_high ci_entry_l_low year, color(gs13)) ///
		(scatter b_entry_l year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Entry of subsidiaries") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("LOW" "(NUMBER OF FIRMS)", color(black)) ///
			name(Entry_l, replace)		
			
	graph combine Entry_h Entry_l, ///
		altshrink cols(2) ysize(4) xsize(10) ///
		title("PUBLIC DISCLOSURE ENFORCEMENT" "AND ENTRY OF SUBSIDIARIES", color(black)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		saving(Figure_A2, replace)		

********************************************************************************
**** Figure A3: PUBLIC DISCLOSURE ENFORCEMENT AND EXIT DUE TO 				****
**** 			UNPROFITABILITY												****
********************************************************************************
		
/* Reduced Form: Limited share on exit */

	/* Results */

		/* Coefficients */
		
			/* High */
			gen b_exit_h = -0.049 if _n == 1
			replace b_exit_h = -0.052 if _n == 2
			replace b_exit_h = -0.098 if _n == 3
			replace b_exit_h = 0 if _n == 4
			replace b_exit_h = -0.127 if _n == 5
			replace b_exit_h = -0.009 if _n == 6
			replace b_exit_h = -0.029 if _n == 7
			replace b_exit_h = 0.074 if _n == 8
			replace b_exit_h = -0.188 if _n == 9
			replace b_exit_h = -0.131 if _n == 10	
	
			/* Low */
			gen b_exit_l = 0.002 if _n == 1
			replace b_exit_l = -0.002 if _n == 2
			replace b_exit_l = -0.016 if _n == 3
			replace b_exit_l = 0 if _n == 4
			replace b_exit_l = -0.074 if _n == 5
			replace b_exit_l = 0.084 if _n == 6
			replace b_exit_l = 0.086 if _n == 7
			replace b_exit_l = 0.108 if _n == 8
			replace b_exit_l = 0.049 if _n == 9
			replace b_exit_l = 0.087 if _n == 10	
			
		/* Standard errors */
		
			/* High */
			gen t_exit_h = -0.53 if _n == 1
			replace t_exit_h = -0.55 if _n == 2	
			replace t_exit_h = -1.07 if _n == 3
			replace t_exit_h = 0 if _n == 4
			replace t_exit_h = -1.31 if _n == 5
			replace t_exit_h = -0.10 if _n == 6
			replace t_exit_h = -0.36 if _n == 7
			replace t_exit_h = 0.86 if _n == 8
			replace t_exit_h = -2.04 if _n == 9
			replace t_exit_h = -1.45 if _n == 10
			gen se_exit_h = 1/(t_exit_h/b_exit_h)
			replace se_exit_h = 0 if _n == 4

			/* Low */
			gen t_exit_l = 0.04 if _n == 1
			replace t_exit_l = -0.04 if _n == 2	
			replace t_exit_l = -0.37 if _n == 3
			replace t_exit_l = 0 if _n == 4
			replace t_exit_l = -1.92 if _n == 5
			replace t_exit_l = 2.07 if _n == 6
			replace t_exit_l = 2.17 if _n == 7
			replace t_exit_l = 2.57 if _n == 8
			replace t_exit_l = 1.27 if _n == 9
			replace t_exit_l = 2.21 if _n == 10
			gen se_exit_l = 1/(t_exit_l/b_exit_l)
			replace se_exit_l = 0 if _n == 4
			
		/* Confidence interval */
		gen ci_exit_h_low = b_exit_h - 1.96*se_exit_h
		gen ci_exit_h_high = b_exit_h + 1.96*se_exit_h

		gen ci_exit_l_low = b_exit_l - 1.96*se_exit_l
		gen ci_exit_l_high = b_exit_l + 1.96*se_exit_l
		
	/* Graph: Limited share on exit */
	graph twoway ///
		(rarea ci_exit_h_high ci_exit_h_low year, color(gs13)) ///
		(scatter b_exit_h year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Exit due to unprofitability") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("HIGH" "(NUMBER OF FIRMS)", color(black)) ///
			name(Exit_h, replace)	
	
	graph twoway ///
		(rarea ci_exit_l_high ci_exit_l_low year, color(gs13)) ///
		(scatter b_exit_l year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Exit due to unprofitability") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("LOW" "(NUMBER OF FIRMS)", color(black)) ///
			name(Exit_l, replace)		
			
	graph combine Exit_h Exit_l, ///
		altshrink cols(2) ysize(4) xsize(10) ///
		title("PUBLIC DISCLOSURE ENFORCEMENT" "AND EXIT DUE TO UNPROFITABILITY", color(black)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		saving(Figure_A3, replace)	

********************************************************************************
**** Figure A4: PUBLIC DISCLOSURE ENFORCEMENT AND CONCENTRATION				****
********************************************************************************
		
/* Reduced Form: Limited share on concentration */

	/* Results */

		/* Coefficients */
		
			/* High */
			gen b_hhi_h = -0.008 if _n == 1
			replace b_hhi_h = -0.018 if _n == 2
			replace b_hhi_h = -0.007 if _n == 3
			replace b_hhi_h = 0 if _n == 4
			replace b_hhi_h = -0.001 if _n == 5
			replace b_hhi_h = -0.009 if _n == 6
			replace b_hhi_h = -0.005 if _n == 7
			replace b_hhi_h = 0.002 if _n == 8
			replace b_hhi_h = -0.002 if _n == 9
			replace b_hhi_h = 0.005 if _n == 10	
	
			/* Low */
			gen b_hhi_l = 0.002 if _n == 1
			replace b_hhi_l = 0.011 if _n == 2
			replace b_hhi_l = 0.005 if _n == 3
			replace b_hhi_l = 0 if _n == 4
			replace b_hhi_l = -0.012 if _n == 5
			replace b_hhi_l = -0.018 if _n == 6
			replace b_hhi_l = -0.015 if _n == 7
			replace b_hhi_l = -0.019 if _n == 8
			replace b_hhi_l = -0.020 if _n == 9
			replace b_hhi_l = -0.019 if _n == 10	
			
		/* Standard errors */
		
			/* High */
			gen t_hhi_h = -0.60 if _n == 1
			replace t_hhi_h = -1.44 if _n == 2	
			replace t_hhi_h = -0.73 if _n == 3
			replace t_hhi_h = 0 if _n == 4
			replace t_hhi_h = -0.08 if _n == 5
			replace t_hhi_h = -0.69 if _n == 6
			replace t_hhi_h = -0.33 if _n == 7
			replace t_hhi_h = 0.13 if _n == 8
			replace t_hhi_h = -0.13 if _n == 9
			replace t_hhi_h = 0.35 if _n == 10
			gen se_hhi_h = 1/(t_hhi_h/b_hhi_h)
			replace se_hhi_h = 0 if _n == 4

			/* Low */
			gen t_hhi_l = 0.18 if _n == 1
			replace t_hhi_l = 1.31 if _n == 2	
			replace t_hhi_l = 0.76 if _n == 3
			replace t_hhi_l = 0 if _n == 4
			replace t_hhi_l = -1.70 if _n == 5
			replace t_hhi_l = -1.99 if _n == 6
			replace t_hhi_l = -1.38 if _n == 7
			replace t_hhi_l = -1.72 if _n == 8
			replace t_hhi_l = -1.87 if _n == 9
			replace t_hhi_l = -1.87 if _n == 10
			gen se_hhi_l = 1/(t_hhi_l/b_hhi_l)
			replace se_hhi_l = 0 if _n == 4
			
		/* Confidence interval */
		gen ci_hhi_h_low = b_hhi_h - 1.96*se_hhi_h
		gen ci_hhi_h_high = b_hhi_h + 1.96*se_hhi_h

		gen ci_hhi_l_low = b_hhi_l - 1.96*se_hhi_l
		gen ci_hhi_l_high = b_hhi_l + 1.96*se_hhi_l
		
	/* Graph: Limited share on concentration */
	graph twoway ///
		(rarea ci_hhi_h_high ci_hhi_h_low year, color(gs13)) ///
		(scatter b_hhi_h year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.06(0.02)0.06, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("HHI") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("HIGH" "(NUMBER OF FIRMS)", color(black)) ///
			name(HHI_h, replace)	
	
	graph twoway ///
		(rarea ci_hhi_l_high ci_hhi_l_low year, color(gs13)) ///
		(scatter b_hhi_l year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.06(0.02)0.06, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("HHI") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("LOW" "(NUMBER OF FIRMS)", color(black)) ///
			name(HHI_l, replace)		
			
	graph combine HHI_h HHI_l, ///
		altshrink cols(2) ysize(4) xsize(10) ///
		title("PUBLIC DISCLOSURE ENFORCEMENT" "AND PRODUCT MARKET CONCENTRATION", color(black)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		saving(Figure_A4, replace)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Cleaning GWS data [Excerpt]									****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: GWS_panel.dta
	Variables:
		- gwa_jahr			gwa_jahr	
		- of2_2014			Amtlicher Gemeindeschluessel (AGS) der Betriebsstaette (Sitz) zum 31.12.2014
		- ef14				Schluessel der Rechtsform
		- ef81				Taetigkeit (Schwerpunktsangabe)
		- ef85 				Taetigkeit im Nebenerwerb?
		- ef86				Taetigkeit (Schwerpunktsangabe)
		- ef94				Anzahl der Vollzeitbeschaeftigten
		- ef95				Anzahl der Teilzeitbeschaeftigten
		- ef96				Keine Beschaeftigten
		- ef97				Erstattung fuer 1 = Hauptniederlassung; 2 = Zweigniederlassung; 3 = unselbstständige Zweigstelle
		- of1				Art der Meldung
		- ef99u1			Grund der Anmeldung: Neugruendung
		- ef99u2			Grund der Anmeldung: Wiedereroeffnung nach Verlegung aus einem anderen Meldebezirk
		- ef99u3			Grund der Anmeldung: Gruendung nach Umwandlungsgesetz
		- ef99u4			Grund der Anmeldung: Wechsel der Rechtsform
		- ef99u5			Grund der Anmeldung: Gesellschaftereintritt
		- ef99u6			Grund der Anmeldung: Erbfolge/Kauf/Pacht
		- ef100u1			Grund der Abmeldung: Vollstaendige Aufgabe
		- ef100u2			Grund der Abmeldung: Verlegung in einen anderen Meldebezirk
		- ef100u3			Grund der Abmeldung: Aufgabe infolge Umwandlungsgesetz
		- ef100u4			Grund der Abmeldung: Wechsel der Rechtsform
		- ef100u5			Grund der Abmeldung: Gesellschafteraustritt
		- ef100u6			Grund der Abmeldung: Erbfolge/Verkauf/Verpachtung
		- ef102				Ursache der Abmeldung
		- ef124				Grund der Ummeldung

Newly created variables (kept):
		- county 			County (Kreis)
		- state 			State (Bundesland)
		- industry 			Industry (2-Digit; WZ2008 (rev))
		- year 				Year (gwa_jahr)
		- limited 			Limited liability
		- empl 				Employees (incl. founder/owner)
		- main 				Main site
		- register 			Registration (Anmeldung)
		- change 			Change (Umwandlung)
		- deregister 		Deregistration (Abmeldung)
		- register_entry 	Entry (Registration)
		- register_move 	Move (Registration)
		- register_law		Legal split (Registration)
		- register_form		Legal form switch (Registration)
		- register_owner 	Entry of owner (Registration)
		- register_acquisition Acquisition (Registration)
		- deregister_exit 	Exit (Deregistration)
		- deregister_move 	Move (Deregistration)
		- deregister_law 	Legal combination (Deregistration)
		- deregister_form 	Legal form change (Deregistration)
		- deregister_owner 	Exit of owner (Deregistration)
		- deregister_sale 	Sale (Deregistration)
		- exit_close 		Exit (Unprofitable; Insolvency)
		- exit_sale 		Exit (Sale)
		- change_industry 	Industry change

Comment:
This program cleans the GWS panel creating selected variables required in subsequent analyses.
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, original("`directory'\Data\GWS_panel.dta")
project, uses("`directory'\Data\WZ_correspondence.dta")

********************************************************************************
**** (1) Industry correspondence (detailed WZ 2003 to WZ 2008)				****
********************************************************************************

/* Data */
use WZ_correspondence, clear

/* Two-digit industries */
foreach var of varlist wz* {
	replace `var' = floor(`var'/1000)
}

/* Approximation */
egen mode = mode(wz2008), by(wz2003)

gen approx = (mode != wz2008)
egen max = max(approx), by(wz2003)

replace approx = max
drop max mode

/* Duplicates */
duplicates drop wz2003, force

/* Save */
save WZ_correspondence_2, replace

/* Project */
project, creates("`directory'\Data\WZ_correspondence_2.dta")
	
********************************************************************************
**** (2) Variable definition												****
********************************************************************************

/* Data */
use GWS_panel, clear

/* Keep relevant obsevrations & variables */
drop if ef98 == "1" | ef98 == "2" // exclude: Automatenaufsteller und Reisegewerbe
keep gwa_jahr of2_2014 ef14 ef81 ef86 ef85 ef94 ef95 ef96 ef97 of1 ef99u* ef100u* ef102 ef124
	
/* Year */
rename gwa_jahr year

/* County */
gen county = substr(of2_2014, -6, 3)

/* State */
gen state = substr(of2_2014, -8, 2)
drop of2_2014

/* Limited company (incl. GmbH & Co. KG; incl. juristische Personen auslaendischer Rechtsformen (da gebuendelt in 991; verhindert Strukturbruch); excluding special forms (340)) */
gen limited = 0
replace limited = 1 if ///
	ef14 == "230" | ///
	ef14 == "232" | ///
	ef14 == "310" | ///
	ef14 == "320" | ///
	ef14 == "321" | ///
	ef14 == "322" | ///
	ef14 == "330" | ///
	ef14 == "350" | ///
	ef14 == "360" | ///
	(ef14 == "351" & year >= 2007) | ///
	(ef14 == "355" & year >= 2007) | ///
	(ef14 == "356" & year >= 2007) | ///	
	(ef14 == "910" & year < 2007) | ///
	(ef14 == "911" & year >= 2007)| ///
	(ef14 == "993" & year < 2007 & year >= 2005) | ///
	(ef14 == "991" & year < 2005) | ///
	(ef14 == "912" & year >= 2007) | ///
	(ef14 == "994" & year < 2007 & year >= 2005) | ///
	(ef14 == "992" & year >= 2007) | ///
	(ef14 == "996" & year < 2007 & year >= 2005)
drop ef14

/* Industry (WZ2003 or WZ2008) */
destring ef81 ef86, force replace /* FDZ comment: force-Option im FDZ hinzugefuegt, da irrelevante alphanumerische Zeichen vorkommen (vereinzelt)*/
replace ef81 = ef86 if ef81 == .
rename ef81 industry
drop ef86

/* Reclassification to WZ2008 */
gen wz2003 = industry if year < 2008
merge m:1 wz2003 using WZ_correspondence_2
drop if _merge == 2
drop _merge

replace industry = wz2008 if year < 2008
egen max = max(approx), by(industry)
replace approx = max
drop max wz2003 wz2008

drop if industry == 98 // only defined in WZ2008

/* Employees (Part-time employees: 1/2 FTE; Founder/Owner/Manager: 1 FTE; PT Founder/Owner/Manager: 1/2 FTE) */
destring ef85 ef96, replace /* FDZ comment: ef94 und ef95 liegen schon im Zahlenformat vor, daher im FDZ aus dieser Liste entfernt */
gen empl = 1 if ef96 == 1
replace empl = 0.5 if ef96 == 0 & ef85 == 1
replace empl = 1 + ef94 + ef95 if empl == . & ef94 != . & ef95 != .
replace empl = 1 + ef94 if empl == . & ef94 != . & ef95 == .
replace empl = 1 + ef95 if empl == . & ef94 == . & ef95 != .
drop ef85 ef94 ef95 ef96

/* Main site */
destring ef97, replace
gen main = (ef97 == 1) if ef97 != .
drop ef97

/* Register, change, deregister */
destring of1, replace
gen register = (of1 == 1) if of1 != .
gen change = (of1 == 2) if of1 != .
gen deregister = (of1 == 3) if of1 != .
drop of1

/* Registration: type */ 
destring ef99u*, replace
gen register_entry = (ef99u1 == 1) if ef99u1 != .
gen register_move = (ef99u2 == 1) if ef99u2 != .
gen register_law = (ef99u3 == 1) if ef99u3 != .
gen register_form = (ef99u4 == 1) if ef99u4 != .
gen register_owner = (ef99u5 == 1) if ef99u5 != .
gen register_sale = (ef99u6 == 1) if ef99u6 != .
drop ef99u*

/* Deregistration: type */
destring ef100u*, replace
gen deregister_exit = (ef100u1 == 1) if ef100u1 != .
gen deregister_move = (ef100u2 == 1) if ef100u2 != .
gen deregister_law = (ef100u3 == 1) if ef100u3 != .
gen deregister_form = (ef100u4 == 1) if ef100u4 != .
gen deregister_owner = (ef100u5 == 1) if ef100u5 != .
gen deregister_sale = (ef100u6 == 1) if ef100u6 != .
drop ef100u*

/* Deregistration: reason */
destring ef102, replace
gen exit_close = (ef102 == 11 | ef102 == 12)
gen exit_sale = (ef102 == 17)
drop ef102

********************************************************************************
**** (3) Labeling and saving												****
********************************************************************************

/* Labeling */
label var county "County"
label var state "State"
label var industry "Industry (2-Digit; WZ2008)"
label var year "Year"
label var limited "Limited liability"
label var empl "Employees (incl. founder/owner)"
label var main "Main site"
label var register "Registration"
label var change "Change"
label var deregister "Deregistration"
label var register_entry "Entry (Registration)"
label var register_move "Move (Registration)"
label var register_law "Legal split (Registration)"
label var register_form "Legal form switch (Registration)"
label var register_owner "Entry of owner (Registration)"
label var register_sale "Acquisition (Registration)"
label var deregister_exit "Exit (Deregistration)"
label var deregister_move "Move (Deregistration)"
label var deregister_law "Legal combination (Deregistration)"
label var deregister_form "Legal form change (Deregistration)"
label var deregister_owner "Exit of owner (Deregistration)"
label var deregister_sale "Sale (Deregistration)"
label var exit_close "Exit (Unprofitable; Insolvency)"
label var exit_sale "Exit (Sale)"

/* Save */
save GWS_data, replace

/* Project */
project, creates("`directory'\Data\GWS_data.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Aggregate outcomes from GWS	[Excerpt]						****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: GWS_data.dta
	Variables:
		- county 			County (Kreis)
		- state 			State (Bundesland)
		- industry 			Industry (2-Digit; WZ2008 (rev))
		- year 				Year (gwa_jahr)
		- limited 			Limited liability
		- empl 				Employees (incl. founder/owner)
		- register_entry 	Entry (Registration)
		- register_form		Entry (Legal form change)
		- register_owner 	Entry (Owner entry)
		- register_sale 	Entry (Acquisition)		
		- deregister_exit 	Exit (Deregistration)
		- deregister_form	Exit (Legal form change)
		- deregister_sale	Exit (Sale)
		- exit_close 		Exit (Unprofitable; Insolvency)
		
Newly created variables (kept):
		- entry_main		Entry (Log count; Main business)
		- entry_sub			Entry (Log count; Subsidiary)
		- exit_main			Exit (Log count; Main business)
		- exit_close 		Exit (Log count; Insolvency) 
		
Comment:
This program calculates county-industry-year level aggregates of firm entry and exit.
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, uses("`directory'\Data\GWS_data.dta")

********************************************************************************
**** (1) Aggregate outcomes													****
********************************************************************************

/* Data */
use GWS_data, clear

/* Aggregate outcomes */
  
	/* Count */
	local variables = "register_entry deregister_exit exit_close"
	foreach var of varlist `variables' {
		
		/* County-industry level */
		egen t_`var' = total(`var'), by(county industry year) missing
		
		/* County-industry level: Main vs. subsidiary */
		egen t_`var'_main = total(`var'*main), by(county industry year) missing
		gen t_`var'_sub = t_`var' - t_`var'_main	

		/* Drop */
		drop `var'
	}

********************************************************************************
**** (2) Entry and exit measures											****
********************************************************************************

/* Keep */
keep county state industry year t_*

/* Duplicates */
duplicates drop county industry year, force	
	
	/* Entry */
	
		/* Main */
		gen entry_main = ln(1+t_register_entry_main)
		label var entry_main "Entry (Log; Main)"

		/* Subsidiary */
		gen entry_sub = ln(1+t_register_entry_sub)
		label var entry_sub "Entry (Log; Subsidiary)"			
			
	/* Exit */
	
		/* True exit */			
		gen exit_close = ln(1+t_exit_close)
		label var exit_close "Exit (Insolvency; Log)"
		
		/* Main */
		gen exit_main = ln(1+t_deregister_exit_main)
		label var exit_main "Exit (Log; Main)"

********************************************************************************
**** (3) Cleaning, labeling, saving											****
********************************************************************************		

/* Keep relevant variables */
keep county industry year entry* exit*		

/* Save */
save GWS_outcomes, replace

/* Project */
project, creates("`directory'\Data\GWS_outcomes.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Converging industry	definitions (WZ 2003, 2008) in URS		****
****			[Excerpt]													****
********************************************************************************
/*
Original variables (used/kept): 	

	Data file: Klassifikationenwz2008_umsteiger.csv
	Variables:
		- wz2003			WZ 2003 code
		- wz2008			WZ 2008 code
		
	Data file: URS_panel.dta
	Variables:
		- UNR				systemfreie Unternehmensnummer
		- urs_jahr			Auswertungsjahr des Unternehmensregisters
		- aktiv				Aktive URS-Einheiten (=1) vs. inaktive URS-Einheiten (=0)
		- untern			Unternehmen=1, 0=sonst
		- urs_1ef6			Sitz der Einheit: Amtlicher Gemeindeschluessel
		- urs_1ef16			Zugangsmonat
		- urs_1ef17			Zugangsjahr
		- urs_1ef19			Art der Einheit
		- urs_1ef20			Wirtschaftszweig WZ2003 (fuer 2004-2007) bzw. WZ2008 (fuer 2008 und folgende Jahre)
		- urs_1ef26			Rechtsform
		- urs_5ef16u1		Steuerbarer Umsatz in 1000 EUR
		- urs_5ef16u2		Bezugszeit steuerbarer Umsatz (jjjj)
		- urs_5ef18u1		Sozialversicherungspflichtig Beschaeftigte: Anzahl
		- urs_5ef18u2		Sozialversicherungspflichtig Beschaeftigte: Bezugszeit (jjjj)
		- urs_5ef20u1		Beginn der Steuerpflicht (ttmmjjjj)
		- urs_5ef20u2		Zeitpunkt der Aufnahme der wirtschaftlichen Taetigkeit
		- urs_5ef21u1		Ende der Steuerpflicht (ttmmjjjj)
		- urs_5ef21u2		Zeitpunkt der engueltigen Aufgabe der betrieblichen Taetigkeit 
		- urs_5ef30u1		Schaetzumsatz nach Organschaftschaetzung in 1000 EUR
		- urs_5ef30u2		Bezugszeit Schaetzumsatz (jjjj)
		- GTAG				Gemeindeteilausgliederung gemaess BBSR-AGS-Umsteigern 2014
		- agsunsicher		agsunsicher: 1=gewisse Restunsicherheit in der (manuellen) Umkodierung des AGS
		- urs_1ef6_14		Amtlicher Gemeindeschluessel zum Gebietsstand 31.12.2014

Newly created variables (kept):
		- industry_5 		5-digit industry identifier (WZ 2003 before 2008 and WZ 2008 in and after 2008)
		- county			County identifier (Kreis)
		- state				State identifier (Bundesland)
		- legal_form		Legal form (limited vs. unlimited liability)
		- wz2008_rev		Updated/converged WZ 2008 for entire panel

Comment:
This program generates a firm-year panel with a common legal form definition, county identifiers as of 2014, and industry identifiers using WZ2008 (rev).
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, original("`directory'\Data\Klassifikationenwz2008_umsteiger.csv")
project, original("`directory'\Data\URS_panel.dta")

********************************************************************************
**** (1) Industry correspondence (detailed WZ 2003 to WZ 2008)				****
********************************************************************************

/* Data (WZ Umsteiger) */
import delimited Klassifikationenwz2008_umsteiger.csv, delimiter(",") varnames(nonames) rowrange(3:) clear

	/* Keep relevant variables */
	keep v2 v5

	/* Rename variables */
	rename v2 wz2003
	rename v5 wz2008
	
	/* Destring industry codes */
	destring wz*, replace ignore(".")
	
	/* Duplicates (ambiguous categories) */
	duplicates drop wz2003, force
	
	/* Save */
	save WZ_correspondence, replace
	
	/* Project */
	project, creates("`directory'\Data\WZ_correspondence.dta")
	
********************************************************************************
**** (2) Industry redefinition (URS) 										****
********************************************************************************

/* Data (URS) (Sample restriction: only corporations) */
use URS_panel if untern == 1 & aktiv == 1, clear

/* Make industry 5-digits */
replace urs_1ef20 = urs_1ef20 + "000" if length(urs_1ef20) == 2
replace urs_1ef20 = urs_1ef20 + "00" if length(urs_1ef20) == 3
replace urs_1ef20 = urs_1ef20 + "0" if length(urs_1ef20) == 4

/* Industry match variable */
destring urs_1ef20, gen(industry_5)
gen wz2003 = industry_5 if urs_jahr <= 2007

/* Merge: WZ correspondence */
merge m:1 wz2003 using WZ_correspondence
drop if _merge == 2
drop _merge

/* Panel */
duplicates drop UNR urs_jahr, force
xtset UNR urs_jahr

/* Backfilling legal form (no adjustment for legal form issues before 2005; proportions look fine in sample file) */
destring urs_1ef26, replace force
gen legal_form = urs_1ef26
forvalues y = 1(1)13 {
	replace legal_form = f.urs_1ef26 if (urs_1ef26 == . | urs_1ef26 == 9)  & f.urs_1ef26 != . & urs_jahr == 2014-`y' 
}

/* WZ 2008 (new) */
gen wz2008_rev = industry_5 if urs_jahr >= 2008

/* Backfilling */
forvalues y = 1(1)7 {
	replace wz2008_rev = f.wz2008_rev if wz2008_rev == . & f.wz2008_rev != . & urs_jahr == 2008-`y' 
}

/* WZ correspondence */
replace wz2008_rev = wz2008 if wz2008_rev == .

/* Drop */
drop untern aktiv

/* Save */
save URS_data, replace

********************************************************************************
**** (3) Panel information for industry redefinition (URS) 					****
********************************************************************************
	
/* Relevant variables */
keep wz2003 wz2008_rev
	
/* Mode */
egen wz2008_corr = mode(wz2008_rev), by(wz2003)
	
/* Keep correspondence */
keep wz2003 wz2008_corr
	
/* Duplicates */
duplicates drop wz2003, force
	
/* WZ panel correspondence */
save WZ_panel_correspondence, replace 

/* Project */
project, creates("`directory'\Data\WZ_panel_correspondence.dta")
project, uses("`directory'\Data\WZ_panel_correspondence.dta")

********************************************************************************
**** (4) Converged data (URS) 												****
********************************************************************************

/* Data */
use URS_data, clear

/* Merge: WZ panel correspondence */
merge m:1 wz2003 using WZ_panel_correspondence
drop if _merge == 2
drop _merge

/* Adjust correspondence (assumption: most frequent match) */
replace wz2008_rev = wz2008_corr if wz2008_rev == .

/* County identifier */
gen county = substr(urs_1ef6_14, -6, 3)
		
/* State identifier */
gen state = substr(urs_1ef6_14, -8, 2)

/* Keep relevant data */
keep ///
	UNR ///
	urs_jahr ///
	urs_1ef6 ///
	urs_1ef16 ///
	urs_1ef17 ///
	urs_1ef19 ///
	industry_5 ///
	urs_1ef26 ///
	urs_5ef16u1 ///
	urs_5ef16u2 ///
	urs_5ef18u1 ///
	urs_5ef18u2 ///
	urs_5ef20u1 ///
	urs_5ef20u2 ///
	urs_5ef21u1 ///
	urs_5ef21u2 ///
	urs_5ef30u1 ///
	urs_5ef30u2 ///
	GTAG ///
	agsunsicher ///
	urs_1ef6_14 ///
	county ///
	state ///
	wz2003 ///
	wz2008_rev ///
	legal_form
	
/* Labeling */
label var wz2003 "WZ 2003"
label var wz2008_rev "WZ 2008 (Revised)"
label var county "County (AGS)"
label var state "State (AGS)"
label var legal_form "Legal form (Revised)"

/* Save */
save URS_data, replace

/* Project */
project, creates("`directory'\Data\URS_data.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/21/2017													****
**** Program:	Aggregate outcomes from URS [Excerpt]						****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: URS_data.dta
	Variables:
		- UNR				systemfreie Unternehmensnummer
		- urs_jahr			Auswertungsjahr des Unternehmensregisters
		- urs_1ef26			Rechtsform
		- urs_5ef16u1		Steuerbarer Umsatz in 1000 EUR
		- urs_5ef16u2		Bezugszeit steuerbarer Umsatz (jjjj)
		- urs_5ef18u1		Sozialversicherungspflichtig Beschaeftigte: Anzahl
		- urs_5ef18u2		Sozialversicherungspflichtig Beschaeftigte: Bezugszeit (jjjj)
		- urs_5ef30u1		Schaetzumsatz nach Organschaftschaetzung in 1000 EUR
		- urs_5ef30u2		Bezugszeit Schaetzumsatz (jjjj)
		- urs_1ef6_14		Amtlicher Gemeindeschluessel zum Gebietsstand 31.12.2014
		- county			County identifier (Kreis)
		- state				State identifier (Bundesland)
		- legal_form		Legal form (limited vs. unlimited liability)
		- wz2008_rev		Updated/converged WZ 2008 for entire panel

Newly created variables (kept):
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- sales 			Sales (Estimated taxable sales)
		- empl				Employees (1+Employees)
		- limited_fraction 	Fraction of limited firms in all firms
		- no_firms_URS 		Number of firms (URS)
		- hhi				Herfindahl-Hirschman Index (Concentration)

Note:
		- suffix: lim		Uses limited liability firms only
		- suffix: unl		Uses unlimited liability firms only
		
Comment:
This program calculates county-industry-year level aggregates (e.g., product-market concentration).
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, uses("`directory'\Data\URS_data.dta")

********************************************************************************
**** (1) Number of limited liability firms in URS							****
********************************************************************************

/* Data */
use URS_data, clear

/* Keep relevant variables */
keep ///
	UNR ///
	urs_jahr ///
	county ///
	state ///
	urs_1ef17 ///
	urs_1ef26 ///
	urs_5ef16u2 ///
	urs_5ef18u2 ///
	urs_5ef30u2 ///
	urs_5ef16u1 ///
	urs_5ef30u1 ///
	urs_5ef18u1	///
	wz2008_rev ///
	legal_form	

/* Specify: level of industry (2-digit) */
gen industry = floor(wz2008_rev/1000)
label var industry "Industry (2-Digit NACE/WZ)"

/* Duplicates */
sort UNR urs_jahr
duplicates drop UNR urs_jahr, force

/* Sample restriction */
keep if legal_form >= 1 & legal_form <= 8
 
/* Number of all firms */
egen no_firms_URS = count(UNR), by(county industry urs_jahr)

/* Number of limited liability firms */
gen limited = (legal_form == 5 | legal_form == 6 | legal_form == 7)
label var limited "Limited firm"

egen no_firms_URS_lim = total(limited), by(county industry urs_jahr) missing

/* Number of unlimited liability firms */
gen unlimited = (legal_form == 1 | legal_form == 2 | legal_form == 3 | legal_form == 4 | legal_form == 8)
label var unlimited "Unlimited firm"

egen no_firms_URS_unl = total(unlimited), by(county industry urs_jahr) missing

********************************************************************************
**** (2) Weights and outcomes in URS										****
********************************************************************************

/* Year */
destring urs_5ef16u2 urs_5ef18u2 urs_5ef30u2, replace
gen year = urs_jahr - 2
label var year "Fiscal Year"

/* Panel entry year */
destring urs_1ef17, replace
rename urs_1ef17 entry_year
label var entry_year "Entry Year (URS)"

/* Sales */
gen sales = urs_5ef30u1 
replace sales = urs_5ef16u1 if sales == . & urs_jahr == 2008
replace sales = urs_5ef16u1 if urs_5ef30u2 != year & urs_5ef16u2 == year
replace sales = . if urs_5ef30u2 != year & urs_5ef16u2 != year
label var sales "Sales (Estimated taxable sales)"

/* Employees (replace for missing values with year + nonmissing value with wrong year) */
gen empl = urs_5ef18u1+1
replace empl = 1 if (empl == . & urs_5ef18u1 == . & urs_5ef18u2 != .) | (urs_5ef18u2 != year)
label var empl "Employees (1+Employees)"

/* Panel */
sort UNR year
duplicates drop UNR year, force
xtset UNR year

/* Sample restriction: period 2003 to 2012 */
keep if year >= 2003 & year <= 2012

/* Drop missing */
drop if sales == . & empl == .

/* Save firm sample */
save Firm, replace

/* Concentration measure (HHI) */

	/* All */
	egen total = total(sales), by(county industry year) missing
	egen hhi = total((sales/total)^2), by(county industry year) missing
	label var hhi "Concentration (HHI)"
	drop total
	
********************************************************************************
**** (5) Cleaning and labeling												****
********************************************************************************

/* Keep relevant variables */ 
keep ///
	county ///
	state ///
	industry ///
	year ///
	no_* ///
	hhi
	
/* Duplicates */
sort county industry year
duplicates drop county industry year, force

/* Labeling */
label var no_firms_URS "Number of firms (URS)"
label var no_firms_URS_lim "Number of (limited) firms (URS)"
label var no_firms_URS_unl "Number of (unlimited) firms (URS)"

********************************************************************************
**** (6) Additional variables												****
********************************************************************************

/* Duplicates */
duplicates drop county industry year, force
	
/* Fraction of firms */
gen limited_fraction = no_firms_URS_lim/no_firms_URS
label var limited_fraction "Fraction of limited firms in all firms"
	
/* Cross-sectional split variables */

	/* Number of firms */
	egen pre = mean(no_firms_URS) if year == 2006, by(county industry)
	egen s_firms = mean(pre), by(county industry)
	label var s_firms "Firms (pre)"
	drop pre
			
********************************************************************************
**** (7) Saving																****
********************************************************************************
			
/* Save */
cd "`directory'\Data"
save URS_outcomes, replace	

/* Project */	
project, creates("`directory'\Data\URS_outcomes.dta")
project, creates("`directory'\Data\Firm.dta")
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (0) Execute project programs 											****
****	 (Data source abbreviations:										****
****		- URS: Unternehmensregister										****
****		- GWS: Gewerbeanzeigenstatistik									****
****		- AMA: Amadeus (Bureau van Dijk) [separate do-file: AMA_data]	****
********************************************************************************

********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Unifying county & industry definitions 							****
********************************************************************************

/* Cleaning URS panel & converging industry (WZ) definitions */
project, do(Dofiles/URS_data.do)

/* Cleaning GWS panel */
project, do(Dofiles/GWS_data.do)


********************************************************************************
**** (3) Aggregate outcomes 												****
********************************************************************************

/* Obtaining aggregate outcomes from URS */
project, do(Dofiles/URS_outcomes.do)

/* Obtaining aggregate outcomes from GWS */
project, do(Dofiles/GWS_outcomes.do)


********************************************************************************
**** (4) Empirical analyses 												****
********************************************************************************

/* Merging outcome and treatment variables */
project, do(Dofiles/Data.do)

/* Regression analyses */
project, do(Dofiles/Analyses.do)

/* Graphs */
project, do(Dofiles/Graphs.do)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (0) Execute project programs 											****
****	 (Data source abbreviations:										****
****		- URS: Unternehmensregister										****
****		- GWS: Gewerbeanzeigenstatistik									****
****		- AMA: Amadeus (Bureau van Dijk) [separate do-file: AMA_data]	****
********************************************************************************

********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Coverage (treatment) [to be prepared for Destatis]					****
********************************************************************************

/* AMA panel data with converged industry (WZ) and location (AGS) definitions */
project, do(Dofiles/AMA_panel.do)

/* AMA data for coverage calculation */
project, do(Dofiles/AMA_data.do)

/* Obtaining coverage (treatment) from AMA (for Germany) */
project, do(Dofiles/AMA_coverage.do)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Setup of "project" program (German enforcement setting)		****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Master directory ****
local master = "...\Project_Germany\Programs" // specify directory path

********************************************************************************
**** (0) Install external program ("project")								****
********************************************************************************

**** Install ****
ssc install project


********************************************************************************
**** (1) Setup and building project: Local									****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Local.do")

**** Build ****
cap noisily project Master_Local, build


********************************************************************************
**** (2) Setup and building project: Destatis [to be run at FDZ]			****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Destatis.do")

**** Build ****
cap noisily project Master_Destatis, build
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Installs external (user-written) programs					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

********************************************************************************
**** (1) Install external programs											****
********************************************************************************

**** Estout ****
ssc install estout, replace

**** Reghdfe ****
ssc install reghdfe, replace
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		08/03/2020													****
**** Program:	EU KLEMS productivity data									****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, original("`directory'\Data\Statistical_National-Accounts.dta")	
project, original("`directory'\Data\Statistical_Growth-Accounts.dta")	
project, original("`directory'\Data\Statistical_Capital.dta")	

********************************************************************************
**** (1) Generate KLEMS data												****
********************************************************************************

/* Delete */
cap rm KLEMS.dta

/* Data */
use Statistical_National-Accounts, clear

/* Keep relevant data */
keep if var == "VA" | var == "COMP"

/* Reshape: Variable into columns */

	/* Obtain variable names */
	levelsof var, clean local(varlist) 

	/* Loop over variables */
	foreach var of local varlist {

		/* Preserve */
		preserve
			
			/* Variable */
			keep if var == "`var'"
			drop db var indnr Sort_ID
			
			/* Variable name */
			local name = lower("`var'")
			
			/* Rename */
			rename value `name'
			label var `name' "`var'"

			/* Merge */
			//cd "`directory'\Data"
			cap merge 1:1 country code year using KLEMS
			cap drop _merge
			
			/* Save */
			save KLEMS, replace
			
		/* Restore */
		restore
			
	}
	
/* Data: Growth Accounts */
use Statistical_Growth-Accounts, clear

/* Keep relevant data */
keep if var == "VA_G"

/* Reshape: Variable into columns */

	/* Obtain variable names */
	levelsof var, clean local(varlist) 

	/* Loop over variables */
	foreach var of local varlist {

		/* Preserve */
		preserve
			
			/* Variable */
			keep if var == "`var'"
			drop db var indnr Sort_ID
			
			/* Variable name */
			local name = lower("`var'")
			
			/* Rename */
			rename value `name'
			label var `name' "`var'"

			/* Merge */
			//cd "`directory'\Data"
			cap merge 1:1 country code year using KLEMS
			cap drop _merge
			
			/* Save */
			save KLEMS, replace
			
		/* Restore */
		restore
			
	}

/* Data: Capital Accounts */
use Statistical_Capital, clear

/* Keep relevant data */
keep if var == "K_GFCF"

/* Reshape: Variable into columns */

	/* Obtain variable names */
	levelsof var, clean local(varlist) 

	/* Loop over variables */
	foreach var of local varlist {

		/* Preserve */
		preserve
			
			/* Variable */
			keep if var == "`var'"
			drop db var indnr Sort_ID
			
			/* Variable name */
			local name = lower("`var'")
			
			/* Rename */
			rename value `name'
			label var `name' "`var'"

			/* Merge */
			//cd "`directory'\Data"
			cap merge 1:1 country code year using KLEMS
			cap drop _merge
			
			/* Save */
			save KLEMS, replace
			
		/* Restore */
		restore
			
	}

/* Data */
use KLEMS, clear
	
/* Cleaning */

	/* Country */
	replace country = "Austria" if country == "AT"
	replace country = "Belgium" if country == "BE"
	replace country = "Bulgaria" if country == "BG"
	replace country = "Cyprus" if country == "CY"
	replace country = "Czech Republic" if country == "CZ"
	replace country = "Germany" if country == "DE"
	replace country = "Denmark" if country == "DK"
	replace country = "Estonia" if country == "EE"
	replace country = "Greece" if country == "EL"
	replace country = "Spain" if country == "ES"
	replace country = "Finland" if country == "FI"
	replace country = "France" if country == "FR"
	replace country = "Croatia" if country == "HR"
	replace country = "Hungary" if country == "HU"
	replace country = "Ireland" if country == "IE"
	replace country = "Italy" if country == "IT"
	replace country = "Japan" if country == "JP"
	replace country = "Lithuania" if country == "LT"
	replace country = "Luxembourg" if country == "LU"
	replace country = "Latvia" if country == "LV"
	replace country = "Malta" if country == "MT"
	replace country = "Netherlands" if country == "NL"
	replace country = "Poland" if country == "PL"
	replace country = "Portugal" if country == "PT"
	replace country = "Romania" if country == "RO"
	replace country = "Sweden" if country == "SE"
	replace country = "Slovenia" if country == "SI"
	replace country = "Slovakia" if country == "SK"
	replace country = "United Kingdom" if country == "UK"
	replace country = "United States" if country == "US"
	drop if country == "EA19" | regexm(country, "EU") == 1

	/* Industry */
	rename code industry
	drop if industry == "MARKT" | regexm(industry, "TOT") == 1

/* Sort */
sort country industry year
		
/* Labels */  
label var country "Country"
label var industry "Industry"
label var year "Year"
label var va "GVA, current prices, NAC mn"
label var comp "Compensation of employees, current prices, NAC mn"
label var va_g "Growth rate of value added volume, %, log"
label var k_gfcf "Capital stock, net, current replacement (all assets)"

/* Save */
save KLEMS, replace

/* Project */
project, creates("`directory'\Data\KLEMS.dta")

********************************************************************************
**** (2) Industry link to Scopes											****
********************************************************************************

/* Data */
use Scope_2, clear // Scope calculated using Scope.do from Project_Europe (but for two-digit instead of four-digit NACE industries)

/* Rename industry */
rename industry industry_nace
	
/* Generate broad ISIC 4 */
gen industry = ""
replace industry = "A" if industry_nace >= 1 & industry_nace <= 3
replace industry = "B" if industry_nace >= 5 & industry_nace <= 9
replace industry = "C10-C12" if industry_nace >= 10 & industry_nace <= 12
replace industry = "C13-C15" if industry_nace >= 13 & industry_nace <= 15
replace industry = "C16-C18" if industry_nace >= 16 & industry_nace <= 18
replace industry = "C19" if industry_nace == 19
replace industry = "C20" if industry_nace == 20
replace industry = "C21" if industry_nace == 21
replace industry = "C22_C23" if industry_nace >= 22 & industry_nace <= 23
replace industry = "C24_C25" if industry_nace >= 24 & industry_nace <= 25
replace industry = "C26" if industry_nace == 26
replace industry = "C27" if industry_nace == 27
replace industry = "C28" if industry_nace == 28
replace industry = "C29_C30" if industry_nace >= 29 & industry_nace <= 30
replace industry = "C31_C33" if industry_nace >= 30 & industry_nace <= 33
replace industry = "D" if industry_nace == 35
replace industry = "E" if industry_nace >= 36 & industry_nace <= 39
replace industry = "F" if industry_nace >= 41 & industry_nace <= 43
replace industry = "G45" if industry_nace == 45
replace industry = "G46" if industry_nace == 46
replace industry = "G47" if industry_nace == 47
replace industry = "H49" if industry_nace == 49
replace industry = "H50" if industry_nace == 50
replace industry = "H51" if industry_nace == 51
replace industry = "H52" if industry_nace == 52
replace industry = "H53" if industry_nace == 53
replace industry = "I" if industry_nace >= 55 & industry_nace <= 56
replace industry = "J58-J60" if industry_nace >= 58 & industry_nace <= 60
replace industry = "J61" if industry_nace == 61
replace industry = "J62_J63" if industry_nace >= 62 & industry_nace <= 63
replace industry = "K" if industry_nace >= 64 & industry_nace <= 66
replace industry = "L" if industry_nace == 68
replace industry = "M_N" if industry_nace >= 69 & industry_nace <= 82
replace industry = "O" if industry_nace == 84
replace industry = "P" if industry_nace == 85
replace industry = "Q" if industry_nace >= 86 & industry_nace <= 88
replace industry = "R_S" if industry_nace >= 90 & industry_nace <= 96
replace industry = "T" if industry_nace >= 97 & industry_nace <= 98
replace industry = "U" if industry_nace == 99
label var industry "Industry (KLEMS)"

/* Aggregate scopes to broad KLEMS industries */
collapse (mean) mc_scope mc_audit, by(country industry year)

/* Save */
save Scope_KLEMS, replace

/* Project */
project, creates("`directory'\Data\Scope_KLEMS.dta")

********************************************************************************
**** (3) Combine KLEMS and Scopes											****
********************************************************************************

/* Data */
use KLEMS, clear

/* Scope */
		
	/* Merge: own scope */
	merge m:1 country industry year using Scope_KLEMS
	drop if _merge == 2
	drop _merge
	
/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Cluster */
egen cluster = group(c i)
label var cluster "Cluster (country-industry)"

********************************************************************************
**** (4) Generate relevant variables										****
********************************************************************************

/* Panel */
xtset cluster year

/* Combined scope */
egen min = rowmin(mc_scope mc_audit)
label var min "Reporting and Auditing"

/* Productivity */

	/* log */
	gen value = ln(va)
	gen lp = ln(va) - ln(comp)
	gen tfp = ln(va) - 0.7*ln(comp) - 0.3*ln(k_gfcf)
	gen growth = va_g/100 // already logarithmic
	
********************************************************************************
**** (5) Regression analysis												****
********************************************************************************

/* Keep relevant period */
keep if year >= 2001 & year <= 2015

/* Variable list */

	/* Parameters*/
	local FE = "c##year i##year"	
	local Cluster = "cluster"
	
	/* All outcomes */
	local Outcomes = "value lp tfp growth"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_8_Panel_A.smcl, replace smcl name(Table_8_Panel_A) 

/* Industry Level */
foreach y of varlist `Outcomes' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if mc_scope!=., a(`FE') residual(r_`y')
			qui reghdfe mc_scope if `y'!=., a(`FE') residual(r_mc_scope)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		

			/* Estimation */			
			qui reghdfe `y' mc_scope, a(`FE') cluster(`Cluster')    
				est store M1	
				
		}
		
	/* Restore */
	restore
	
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if min!=., a(`FE') residual(r_`y')
			qui reghdfe min if `y'!=., a(`FE') residual(r_min)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)

			qui sum r_min, d
			qui replace min = . if r_min < r(p1) | r_min > r(p99)
			
			/* Estimation */
			qui reghdfe `y' min, a(`FE') cluster(`Cluster')    
				est store M2
				
			/* Output */
			estout M1 M2, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("COUNTRY-INDUSTRY LEVEL: `y_label'") ///
				varlabels(mc_scope "Standardized Reporting Scope" min "Standardized Reporting and Auditing Scope") ///				
				mlabels(, depvars) varwidth(45) modelwidth(15) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "Clusters (Country-Industry)" "Adjusted R-Squared"))  	
				
		}
		
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_8_Panel_A
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		08/03/2020													****
**** Program:	OECD productivity data										****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, original("`directory'\Data\DATA.txt")

/******************************************************************************/
/* (1) Import OECD Industry Data										 	  */
/******************************************************************************/

/* Delete */
cap rm OECD.dta

/* Import */
import delimited using DATA.txt, delimiter("|") varnames(1) case(lower) clear

/* Keep relevant variables */
drop flag
keep if var == "VALU" | var == "LABR" | var == "GFCF"

/* Loop over variables */
local variables = "VALU LABR GFCF"
foreach var of local variables {

	/* Preserve */
	preserve 

		/* Keep relevant observations */
		keep if var == "`var'"
		
		/* Name */
		local name = lower("`var'")
		
		/* Rename */
		rename value `name'
		
		/* Drop */
		drop var
		
		/* Merge */
		//cd "`directory'\Data"
		cap merge 1:1 cou ind year using OECD
		cap drop _merge
		
		/* Save */
		save OECD, replace
	
	/* Restore */
	restore
	
}

/* Data */
use OECD, clear

/* Rename */
rename ind industry

/* Industry */
drop if ///
	industry == "ENERGYP" | ///
	industry == "ICTMS" | ///
	regexm(industry, "DT") == 1 | ///
	regexm(industry, "X") == 1
replace industry = substr(industry, 2,.)

/* Country */
gen country = "Australia" if cou == "AUS"
replace country = "Austria" if cou == "AUT"
replace country = "Belgium" if cou == "BEL"
replace country = "Canada" if cou == "CAN"
replace country = "Switzerland" if cou == "CHE"
replace country = "Chile" if cou == "CHL"
replace country = "Costa Rica" if cou == "CRI"
replace country = "Czech Republic" if cou == "CZE"
replace country = "Germany" if cou == "DEU"
replace country = "Denmark" if cou == "DNK"
replace country = "Spain" if cou == "ESP"
replace country = "Estonia" if cou == "EST"
replace country = "Finland" if cou == "FIN"
replace country = "France" if cou == "FRA"
replace country = "United Kingdom" if cou == "GBR"
replace country = "Greece" if cou == "GRC"
replace country = "Hungary" if cou == "HUN"
replace country = "Ireland" if cou == "IRL"
replace country = "Iceland" if cou == "ISL"
replace country = "Israel" if cou == "ISR"
replace country = "Italy" if cou == "ITA"
replace country = "Japan" if cou == "JPN"
replace country = "South Korea" if cou == "KOR"
replace country = "Lithuania" if cou == "LTU"
replace country = "Luxembourg" if cou == "LUX"
replace country = "Latvia" if cou == "LVA"
replace country = "Mexico" if cou == "MEX"
replace country = "Netherlands" if cou == "NLD"
replace country = "Norway" if cou == "NOR"
replace country = "New Zealand" if cou == "NZL"
replace country = "Poland" if cou == "POL"
replace country = "Portugal" if cou == "PRT"
replace country = "Slovakia" if cou == "SVK"
replace country = "Slovenia" if cou == "SVN"
replace country = "Sweden" if cou == "SWE"
replace country = "Turkey" if cou == "TUR"
replace country = "United States" if cou == "USA"
drop cou

/* Label */
label var country "Country"
label var industry "Industry"
label var year "Year"
label var valu "Value added, current prices (m national currency)"
label var labr "Labour costs (compensation of employees) (m national currency)"
label var gfcf "Gross fixed capital formation, current price (m national currency)"

/* Sample */
keep if year >= 2000 & year <= 2015

/* Order */
order country industry year

/* Sort */
sort country industry year

/* Save */
save OECD, replace

/* Project */
project, creates("`directory'\Data\OECD.dta")

/******************************************************************************/
/* (2) OECD Industries (broad ISIC 4)										  */
/******************************************************************************/

/* Data */
use Scope_2, clear

/* Rename */
rename industry industry_nace

/* Generate broad ISIC 4 */
gen industry = ""
replace industry = "01T03" if industry_nace >= 1 & industry_nace <= 3
replace industry = "05T06" if industry_nace >= 5 & industry_nace <= 6
replace industry = "07T08" if industry_nace >= 7 & industry_nace <= 8
replace industry = "09" if industry_nace == 9
replace industry = "10T12" if industry_nace >= 10 & industry_nace <= 12
replace industry = "13T15" if industry_nace >= 13 & industry_nace <= 15
replace industry = "16" if industry_nace == 16
replace industry = "17T18" if industry_nace >= 17 & industry_nace <= 18
replace industry = "19" if industry_nace == 19
replace industry = "20T21" if industry_nace >= 20 & industry_nace <= 21
replace industry = "22" if industry_nace == 22
replace industry = "23" if industry_nace == 23
replace industry = "24" if industry_nace == 24
replace industry = "25" if industry_nace == 25
replace industry = "26" if industry_nace == 26
replace industry = "27" if industry_nace == 27
replace industry = "28" if industry_nace == 28
replace industry = "29" if industry_nace == 29
replace industry = "30" if industry_nace == 30
replace industry = "31T33" if industry_nace >= 31 & industry_nace <= 33
replace industry = "35T39" if industry_nace >= 35 & industry_nace <= 39
replace industry = "41T43" if industry_nace >= 41 & industry_nace <= 43
replace industry = "45T47" if industry_nace >= 45 & industry_nace <= 47
replace industry = "49T53" if industry_nace >= 49 & industry_nace <= 53
replace industry = "55T56" if industry_nace >= 55 & industry_nace <= 56
replace industry = "58T60" if industry_nace >= 58 & industry_nace <= 60
replace industry = "61" if industry_nace == 61
replace industry = "62T63" if industry_nace >= 62 & industry_nace <= 63
replace industry = "64T66" if industry_nace >= 64 & industry_nace <= 66
replace industry = "68" if industry_nace == 68
replace industry = "69T82" if industry_nace >= 69 & industry_nace <= 82
replace industry = "84" if industry_nace == 84
replace industry = "84" if industry_nace == 85
replace industry = "86T88" if industry_nace >= 86 & industry_nace <= 88
replace industry = "90T96" if industry_nace >= 90 & industry_nace <= 96
replace industry = "97T98" if industry_nace >= 97 & industry_nace <= 98
label var industry "Industry (OECD)"

/* Aggregate scopes to broad ISIC 4 */
collapse (mean) mc_scope mc_audit, by(country industry year)

/* Save */
save Scope_OECD, replace

/* Project */
project, creates("`directory'\Data\Scope_OECD.dta")

********************************************************************************
**** (3) Combine OECD and Scopes											****
********************************************************************************

/* Data */
use OECD, clear

/* Scope */
		
	/* Merge: own scope */
	merge m:1 country industry year using Scope_OECD
	drop if _merge == 2
	drop _merge
	
/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Cluster */
egen cluster = group(c i)
label var cluster "Cluster (country-industry)"

********************************************************************************
**** (4) Generate relevant variables										****
********************************************************************************

/* Panel */
xtset cluster year

/* Combined scope */
egen min = rowmin(mc_scope mc_audit)
label var min "Reporting and Auditing"

/* Productivity */

	/* log */
	gen value = ln(valu)
	gen lp = ln(valu) - ln(labr)
	gen tfp = ln(valu) - 0.7*ln(labr) - 0.3*ln(gfcf)
	gen growth = ln(valu) - ln(l.valu)
	
********************************************************************************
**** (5) Regression analysis												****
********************************************************************************

/* Keep relevant period */
keep if year >= 2001 & year <= 2015

/* Variable list */

	/* Parameters*/
	local FE = "c##year i##year"	
	local Cluster = "cluster"
	
	/* All outcomes */
	local Outcomes = "value lp tfp growth"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_8_Panel_B.smcl, replace smcl name(Table_8_Panel_B) 

/* Industry Level */
foreach y of varlist `Outcomes' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if mc_scope!=., a(`FE') residual(r_`y')
			qui reghdfe mc_scope if `y'!=., a(`FE') residual(r_mc_scope)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		

			/* Estimation */			
			qui reghdfe `y' mc_scope, a(`FE') cluster(`Cluster')    
				est store M1	
				
		}
		
	/* Restore */
	restore
	
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if min!=., a(`FE') residual(r_`y')
			qui reghdfe min if `y'!=., a(`FE') residual(r_min)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)

			qui sum r_min, d
			qui replace min = . if r_min < r(p1) | r_min > r(p99)
			
			/* Estimation */
			qui reghdfe `y' min, a(`FE') cluster(`Cluster')    
				est store M2
				
			/* Output */
			estout M1 M2, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("COUNTRY-INDUSTRY LEVEL: `y_label'") ///
				varlabels(mc_scope "Standardized Reporting Scope" min "Standardized Reporting and Auditing Scope") ///				
				mlabels(, depvars) varwidth(45) modelwidth(15) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "Clusters (Country-Industry)" "Adjusted R-Squared"))  	
				
		}
		
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_8_Panel_B
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		08/03/2020													****
**** Program:	OECD productivity data										****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, original("`directory'\Data\WIOD_SEA_Nov16.xlsx")

/******************************************************************************/
/* (1) Import WIOD Socio Economic Data									 	  */
/******************************************************************************/

/* Delete */
cap rm WIOD.dta

/* Import */
import excel using WIOD_SEA_Nov16.xlsx, sheet("DATA") firstrow case(lower) clear

/* Rename variables */
local year = 2000
foreach var of varlist e-s {
	
	/* Rename */
	rename `var' v`year'
	
	/* Year */
	local year = `year' + 1

}

/* Id */
egen i = group(country variable code)

/* Reshape */
reshape long v, i(i) j(year)

/* Drop */
drop i

/* Destring */
destring v, force replace

/* Loop over variables */
local variables = "CAP LAB VA"
foreach var of local variables {

	/* Preserve */
	preserve 

		/* Keep relevant observations */
		keep if variable == "`var'"
		
		/* Name */
		local name = lower("`var'")
		
		/* Rename */
		rename v `name'
		
		/* Drop */
		drop variable
		
		/* Merge */
		//cd "`directory'\Data"
		cap merge 1:1 country code year using WIOD
		cap drop _merge
		
		/* Save */
		save WIOD, replace
	
	/* Restore */
	restore
	
}

/* Data */
use WIOD, clear

/* Country */
replace country = "Australia" if country == "AUS"
replace country = "Austria" if country == "AUT"
replace country = "Belgium" if country == "BEL"
replace country = "Bulgaria" if country == "BGR"
replace country = "Brazil" if country == "BRA"
replace country = "Canada" if country == "CAN"
replace country = "Switzerland" if country == "CHE"
replace country = "China" if country == "CHN"
replace country = "Cyprus" if country == "CYP"
replace country = "Czech Republic" if country == "CZE"
replace country = "Germany" if country == "DEU"
replace country = "Denmark" if country == "DNK"
replace country = "Spain" if country == "ESP"
replace country = "Estonia" if country == "EST"
replace country = "Finland" if country == "FIN"
replace country = "France" if country == "FRA"
replace country = "United Kingdom" if country == "GBR"
replace country = "Greece" if country == "GRC"
replace country = "Croatia" if country == "HRV"
replace country = "Hungary" if country == "HUN"
replace country = "Indonesia" if country == "IDN"
replace country = "India" if country == "IND"
replace country = "Ireland" if country == "IRL"
replace country = "Italy" if country == "ITA"
replace country = "Japan" if country == "JPN"
replace country = "South Korea" if country == "KOR"
replace country = "Lithuania" if country == "LTU"
replace country = "Luxembourg" if country == "LUX"
replace country = "Latvia" if country == "LVA"
replace country = "Mexico" if country == "MEX"
replace country = "Malta" if country == "MLT"
replace country = "Netherlands" if country == "NLD"
replace country = "Norway" if country == "NOR"
replace country = "Poland" if country == "POL"
replace country = "Portugal" if country == "PRT"
replace country = "Romania" if country == "ROU"
replace country = "Russia" if country == "RUS"
replace country = "Slovakia" if country == "SVK"
replace country = "Slovenia" if country == "SVN"
replace country = "Sweden" if country == "SWE"
replace country = "Turkey" if country == "TUR"
replace country = "Taiwan" if country == "TWN"
replace country = "United States" if country == "USA"

/* Industry */
rename code industry

/* Labels */
label var year "Year"
label var va "Gross value added at current basic prices (in m of national currency)"
label var lab "Labour compensation (in m of national currency)"	
label var cap "Capital compensation (in m of national currency)"		

/* Order */
order country industry year

/* Sort */
sort country industry year

/* Save */
save WIOD, replace

/* Project */
project, creates("`directory'\Data\WIOD.dta")

/******************************************************************************/
/* (2) WIOD Industries (broad ISIC 4)										  */
/******************************************************************************/

/* Data */
use Scope_2, clear

/* Rename */
rename industry industry_nace

/* Generate broad ISIC 4 */
gen industry = ""
replace industry = "A01" if industry_nace == 1
replace industry = "A02" if industry_nace == 2
replace industry = "A03" if industry_nace == 3
replace industry = "B" if industry_nace >= 5 & industry_nace <= 9
replace industry = "C10-C12" if industry_nace >= 10 & industry_nace <= 12
replace industry = "C13-C15" if industry_nace >= 13 & industry_nace <= 15
replace industry = "C16" if industry_nace == 16
replace industry = "C17" if industry_nace == 17
replace industry = "C18" if industry_nace == 18
replace industry = "C19" if industry_nace == 19
replace industry = "C20" if industry_nace == 20
replace industry = "C21" if industry_nace == 21
replace industry = "C22" if industry_nace == 22
replace industry = "C23" if industry_nace == 23
replace industry = "C24" if industry_nace == 24
replace industry = "C25" if industry_nace == 25
replace industry = "C26" if industry_nace == 26
replace industry = "C27" if industry_nace == 27
replace industry = "C28" if industry_nace == 28
replace industry = "C29" if industry_nace == 29
replace industry = "C30" if industry_nace == 30
replace industry = "C31_C32" if industry_nace >= 31 & industry_nace <= 32
replace industry = "C33" if industry_nace == 33
replace industry = "D35" if industry_nace == 35
replace industry = "E36" if industry_nace == 36
replace industry = "E37-E39" if industry_nace >= 37 & industry_nace <= 39
replace industry = "F" if industry_nace >= 41 & industry_nace <= 43
replace industry = "G45" if industry_nace == 45
replace industry = "G46" if industry_nace == 46
replace industry = "G47" if industry_nace == 47
replace industry = "H49" if industry_nace == 49
replace industry = "H50" if industry_nace == 50
replace industry = "H51" if industry_nace == 51
replace industry = "H52" if industry_nace == 52
replace industry = "H53" if industry_nace == 53
replace industry = "I" if industry_nace >= 55 & industry_nace <= 56
replace industry = "J58" if industry_nace == 58
replace industry = "J59_J60" if industry_nace >= 59 & industry_nace <= 60
replace industry = "J61" if industry_nace == 61
replace industry = "J62_J63" if industry_nace >= 62 & industry_nace <= 63
replace industry = "K64" if industry_nace == 64
replace industry = "K65" if industry_nace == 65
replace industry = "K66" if industry_nace == 66
replace industry = "L68" if industry_nace == 68
replace industry = "M69_M70" if industry_nace >= 69 & industry_nace <= 70
replace industry = "M71" if industry_nace == 71
replace industry = "M72" if industry_nace == 72
replace industry = "M73" if industry_nace == 73
replace industry = "M74_M75" if industry_nace >= 74 & industry_nace <= 75
replace industry = "N" if industry_nace >= 77 & industry_nace <= 82
replace industry = "O84" if industry_nace == 84
replace industry = "P85" if industry_nace == 85
replace industry = "Q" if industry_nace >= 86 & industry_nace <= 88
replace industry = "R_S" if industry_nace >= 90 & industry_nace <= 96
replace industry = "T" if industry_nace >= 97 & industry_nace <= 98
replace industry = "U" if industry_nace == 99
label var industry "Industry (WIOD)"

/* Aggregate scopes to broad ISIC 4 */
collapse (mean) mc_scope mc_audit, by(country industry year)

/* Save */
save Scope_WIOD, replace

/* Project */
project, creates("`directory'\Data\Scope_WIOD.dta")

********************************************************************************
**** (3) Combine WIOD and Scopes											****
********************************************************************************

/* Data */
use WIOD, clear

/* Scope */
		
	/* Merge: own scope */
	merge m:1 country industry year using Scope_WIOD
	drop if _merge == 2
	drop _merge
	
/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Cluster */
egen cluster = group(c i)
label var cluster "Cluster (country-industry)"

********************************************************************************
**** (4) Generate relevant variables										****
********************************************************************************

/* Panel */
xtset cluster year

/* Combined scope */
egen min = rowmin(mc_scope mc_audit)
label var min "Reporting and Auditing"

/* Productivity */

	/* log */
	gen value = ln(va)
	gen lp = ln(va) - ln(lab)
	gen tfp = ln(va) - 0.7*ln(lab) - 0.3*ln(cap)
	gen growth = ln(valu) - ln(l.valu)
	
********************************************************************************
**** (5) Regression analysis												****
********************************************************************************

/* Keep relevant period */
keep if year >= 2001 & year <= 2015

/* Variable list */

	/* Parameters*/
	local FE = "c##year i##year"	
	local Cluster = "cluster"
	
	/* All outcomes */
	local Outcomes = "value lp tfp growth"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_8_Panel_C.smcl, replace smcl name(Table_8_Panel_C) 

/* Industry Level */
foreach y of varlist `Outcomes' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if mc_scope!=., a(`FE') residual(r_`y')
			qui reghdfe mc_scope if `y'!=., a(`FE') residual(r_mc_scope)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		

			/* Estimation */			
			qui reghdfe `y' mc_scope, a(`FE') cluster(`Cluster')    
				est store M1	
				
		}
		
	/* Restore */
	restore
	
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if min!=., a(`FE') residual(r_`y')
			qui reghdfe min if `y'!=., a(`FE') residual(r_min)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)

			qui sum r_min, d
			qui replace min = . if r_min < r(p1) | r_min > r(p99)
			
			/* Estimation */
			qui reghdfe `y' min, a(`FE') cluster(`Cluster')    
				est store M2
				
			/* Output */
			estout M1 M2, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("COUNTRY-INDUSTRY LEVEL: `y_label'") ///
				varlabels(mc_scope "Standardized Reporting Scope" min "Standardized Reporting and Auditing Scope") ///				
				mlabels(, depvars) varwidth(45) modelwidth(15) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "Clusters (Country-Industry)" "Adjusted R-Squared"))  	
				
		}
		
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_8_Panel_C
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Construct Data & Run Analyses										****
********************************************************************************

/* EU KLEMS sample */
project, do(Dofiles/KLEMS.do)

/* OECD sample */
project, do(Dofiles/OECD.do)

/* WIOD sample */
project, do(Dofiles/WIOD.do)
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Setup of "project" program	(National Statistics)			****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Master directory ****
local master = "...\Project_Statistics\Programs" // please insert/adjust directory path

********************************************************************************
**** (0) Install external program ("project")								****
********************************************************************************

**** Install ****
ssc install project

********************************************************************************
**** (1) Setup and building project: Local									****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Statistics.do")

**** Build ****
cap noisily project Master_Statistics, build
********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
****																		****
**** Module:	Importing Amadeus Data (STATA Version)						****
**** Author: 	Matthias Breuer												****
**** Date: 	 	12/13/2016													****
********************************************************************************

*** Initiations ***
clear all
set more off
unicode encoding set UTF8 // STATA Version 14

********************************************************************************
**** (0) Choices/Options													****
********************************************************************************

/* Directory/Folder Path */
local directory = ".../IGM-BVD_Amadeus" // insert directory path for raw data (downloads from BvD discs)
local output = ".../IGM-BVD_Amadeus/STATA_Data" // insert directory for converted data

/* Section */
local section = "Company" // insert section (Financials, Company, Ownership, Subsidiaries)

/* Year */
local year = 2008 // insert year (of BvD disc)

********************************************************************************
**** (1) Importing: Financials												****
********************************************************************************

/* Section: Financials */
if "`section'" == "Financials" {

	/* Folder List */
	local folders: dir "`directory'/`year'/`section'" dirs "*"

	/* Folder Loop */
	foreach country of local folders {

		/* File List */
		local files: dir "`directory'/`year'/`section'/`country'" files "*"
		
		/* File Loop */
		foreach file of local files {
		
			/* Vintage Condition: Old Vintage */
			if `year' == 2005 | `year' == 2008 {
			
				/* Import */
				insheet using "`directory'/`year'/`section'/`country'/`file'", name tab clear double
			
				/* Check Import */
				if c(k) < 50 {
					insheet using "`directory'/`year'/`section'/`country'/`file'", name delimiter(".") clear double
				}
				
				if c(k) < 50 {
					insheet using "`directory'/`year'/`section'/`country'/`file'", name delimiter(";") clear double
				}
				
				/* Rename Header */
				
					/* Obtain Variable List */
					ds
					local varlist = r(varlist)
					
					/* Variable Loop */
					foreach var of local varlist {
						forvalues i = 0(1)9 {
							if strpos("`var'", "`i'") != 0 {
								local new_name = substr("`var'", 1, strpos("`var'", "`i'")-1)
								rename `var' `new_name'`i'
								local num_list: list num_list | new_name
							}
						}
					/* Close: Variable List */
					}

				/* Reshape */
				drop if (accnr == "" & idnr == "") | (accnr == "n.a." & idnr == "n.a.") | (accnr == "Credit needed" & idnr == "Credit needed")
				reshape long `num_list', i(company idnr accnr consol) j(rel_year) string
				
				/* Drop missing */
				drop if statda == "" | statda == "n.a."
				
				/* Save Intermediate Data */
				cd "`output'/`section'"
				save intermediate_`year', replace
		
			/* Close: Old Vintage */
			}
			
			/* Vintage Condition: New Vintage */
			if `year' == 2012 {
			
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(tab) varnames(1) clear
			
				/* Check Import */
				if c(k) < 50 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(".") varnames(1) clear
				}
				
				if c(k) < 50 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(";") varnames(1) clear
				}
				
				/* Rename Header */
				
					/* Manual Adjustment */
					cap rename v1 company
					cap rename ï company
					rename statdate statda
					drop v3-v11 v13-v21 v33-v41
					
					/* Obtain Variable List */
					ds, has(varlabel)
					local varlist = r(varlist)
					local static_list = "company idnr accnr consol"
					local num_list: list varlist - static_list
					ds
					local varlist = r(varlist)
					local long_list: list varlist - static_list

					/* Variable Loop */
					foreach var of local num_list {
						foreach v of local long_list {
							if "`var'" == "`v'" {
								local new_name = "`var'"
								local i = 0
							}

							if `i' < 10 {
								rename `v' `new_name'`i'
								local i = `i' +1
							}
						}
					/* Close: Variable List */
					}

				/* Reshape */
				drop if (accnr == "" & idnr == "") | (accnr == "n.a." & idnr == "n.a.") | (accnr == "Credit needed" & idnr == "Credit needed")
				reshape long `num_list', i(company idnr accnr consol) j(rel_year) string
				
				/* Drop missing */
				drop if statda == "" | statda == "n.a."
				
				/* Save Intermediate Data */
				cd "`output'/`section'"
				save intermediate_`year', replace
			
			/* Close: New Vintage */
			}
			
			/* Append Data */
			capture append using data_`year', force 
			
			/* Save Appended Data */
			save data_`year', replace
			
		/* Close: File Loop */
		}
		
		/* Reformat Variables */
		
			/* Obtain Variable List */
			ds
			local varlist = r(varlist)
			local char_list = "company idnr accnr consol statda"
			local num_list: list varlist - char_list
			
			/* Variable Loop */
			foreach var of local num_list {
				destring `var', replace ignore(",") force
			}	
		
		/* Save (by Country) */
		save "`country'_`section'_`year'", replace

		/* Deleting Intermediate Data */
		rm data_`year'.dta
		rm intermediate_`year'.dta
		
		/* Deleting Numlist Local */
		local num_list
		
	/* Close: Folder Loop */
	}

/* Close: Financials Section */
}	

********************************************************************************
**** (2) Importing: Company Sections										****
********************************************************************************

/* Section: Company */
if "`section'" == "Company" {

	/* Folder List */
	local folders: dir "`directory'/`year'/`section'" dirs "*"

	/* Folder Loop */
	foreach country of local folders {

		/* File List */
		local files: dir "`directory'/`year'/`section'/`country'" files "*"
	
		/* Vintage Condition: Old Vintage (2005-2007) */
		if `year' <= 2007 {
		
			/* File Loop */
			foreach file of local files {
			
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
			
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
				
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}
				
				/* Destring */
				destring ///
					months0* ///
					exchra0* ///
					unit0* ///
					opre0* ///
					pl0* ///
					empl0* ///
					hdr_mar ///
					onbr ///
					snbr ///
					, replace ignore(",")
					
				/* Rename */
				rename months* months
				rename exchra* exchrate
				rename unit* unit
				rename opre* opre_c
				rename pl* pl_c
				rename empl* empl_c
				
				/* Compress */
				compress
				
				/* Save Intermediate Data */
				cd "`output'/`section'"
				save intermediate_`year', replace
			
				/* Append Data */
				capture append using data_`year', force 
				
				/* Save Appended Data */
				save data_`year', replace
			
			/* Close: File Loop */
			}	
		
		/* Save (by Country) */
		save "`country'_`section'_`year'", replace

		/* Deleting Intermediate Data */
		rm data_`year'.dta
		rm intermediate_`year'.dta
		
		/* Close: Old Vintage (2005-2007) */
		}		
		
		/* Vintage Condition: Old Vintage (2008) */
		if `year' == 2008 {
		
			/* File Loop */
			foreach file of local files {
					
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
				
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
					
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}
 
				/* Destring */
				destring ///
					empl* ///
					opre* ///
					pl* ///
					onbr ///
					snbr ///
					hdr_mar ///
					months* ///
					exch* ///
					, replace ignore(",")
							
				/* Rename */
				rename months* months
				rename exchra* exchrate
				rename unit* unit_string
				rename opre* opre_c
				rename pl* pl_c
				rename empl* empl_c
				rename company company_name
				rename ad_name auditor_name
				rename idnr bvd_id_number
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Shareholders */
					preserve

						/* Keep shareholder information */
						keep accnr ult* d* is* shhtext oname oid oticker ocountry otype onace onaics odirect ototal osource odate ocldate ooprev ototas oempl
						
						/* Duplicates drop */
						duplicates drop accnr accnr ult* d* is* shhtext oname oid oticker ocountry otype onace onaics odirect ototal osource odate ocldate ooprev ototas oempl, force
						
						/* Save Intermediate Data */
						cd "`output'/Ownership"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Ownership_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Ownership_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore

					/* Subsidiaries */
					preserve

						/* Keep shareholder information */
						keep accnr subtext sname sid sticker scountry stype snace snaics sdirect stotal slevel sstatus ssource sdate scldate soprev subtast subempl
						
						/* Duplicates drop */
						duplicates drop accnr subtext sname sid sticker scountry stype snace snaics sdirect stotal slevel sstatus ssource sdate scldate soprev subtast subempl, force
						
						/* Save Intermediate Data */
						cd "`output'/Subsidiaries"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Subsidiaries_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Subsidiaries_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep mangers */
						keep accnr mg_*
						
						/* Duplicates drop */
						duplicates drop accnr mg_*, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop other */
						drop is* ult* d* mg_* shhtext oname oid oticker ocountry otype onace onaics odirect ototal osource odate ocldate ooprev ototas oempl subtext sname sid sticker scountry stype snace snaics sdirect stotal slevel sstatus ssource sdate scldate soprev subtast subempl
 
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2008) */
		}	
			
		/* Vintage Condition: Old Vintage (2009) */
		if `year' == 2009 {
		
			/* File Loop */
			foreach file of local files {
					
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
				
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
					
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}

				/* Destring */
				destring ///
					employees* ///
					operatingrevenueturnover* ///
					plforperiod** ///
					marketcapitalisation* ///
					noofrecordedshareholders ///
					noofrecsubsidiaries ///
					numberofmonthslast* ///
					exchangerate* ///
					, replace ignore(",")
							
				/* Rename */
				rename numberofmonthslast* months
				rename exchangerate* exchrate
				rename unit* unit_string
				rename operatingrevenueturnover* opre_c
				rename plforperiod* pl_c
				rename employees* empl_c
				rename marketcapital* hdr_mar
				rename noofrecordedshareholders onbr
				rename noofrecsubsidiaries snbr
				rename bvdepaccountnumber accnr
				rename companyname company_name
				rename auditorname auditor_name
				rename bvdepidnumber bvd_id_number
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Shareholders */
					preserve

						/* Keep shareholder information */
						keep accnr shareholder* domestic* immediate* global* v99 v114
						
						/* Duplicates drop */
						duplicates drop accnr shareholder* domestic* immediate* global* v99 v114, force
						
						/* Save Intermediate Data */
						cd "`output'/Ownership"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Ownership_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Ownership_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore

					/* Subsidiaries */
					preserve

						/* Keep shareholder information */
						keep accnr subsidiar*
						
						/* Duplicates drop */
						duplicates drop accnr subsidiar*, force
						
						/* Save Intermediate Data */
						cd "`output'/Subsidiaries"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Subsidiaries_`year'", force // note: drops information in using if string-numeric mismatch occurs
						
						/* Save Appended Data */
						save "`country'_Subsidiaries_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep bankers */
						keep accnr firstname middlename lastname fullname title salutation dateofbirth dateofbirth nationality homeaddress homecountry titlesince biography
						
						/* Duplicates drop */
						duplicates drop accnr firstname middlename lastname fullname title salutation dateofbirth dateofbirth nationality homeaddress homecountry titlesince biography, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop other */
						drop shareholder* domestic* immediate* global* v99 v114 subsidiar* firstname middlename lastname fullname title salutation dateofbirth dateofbirth nationality homeaddress homecountry titlesince biography
 
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2009) */
		}			
	
		/* Vintage Condition: Old Vintage (2010) */
		if `year' == 2010 {
		
			/* File Loop */
			foreach file of local files {

				/* Version 1 */
				capture {
					
					/* Error */
					local error = 1
					
					/* Import */
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(4) rowrange(5:) clear asdouble stringcols(_all) 
				
					/* Check Import */
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(4) rowrange(5:) clear asdouble stringcols(_all)
					}

					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(4) rowrange(5:) clear asdouble stringcols(_all)
					}
					
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(4) rowrange(5:) clear asdouble stringcols(_all)
					}
				
					/* Alternative variable names */
					
						/* Drop */
						drop v1
						
						/* Destring */
						destring ///
							oprevenuemileurlast* ///
							plforperiodmileurlast* ///
							marketcapitalisation* ///
							noofrecshareholders ///
							noofrecsubsidiaries ///
							peergroupsize ///
							numberofmonthslast* ///
							exchangeratefromlocalcurrencyeur ///
							, replace ignore(",")
							
						/* Rename */
						rename numberofmonthslast* months
						rename exchangeratefromlocalcurrencyeur exchrate
						rename accountunitlast* unit_string
						rename oprevenuemileurlast* opre_c
						rename plforperiodmileurlast* pl_c
						rename numberofemployeeslast* empl_c
						rename marketcapital* hdr_mar
						rename noofrecshareholders onbr
						rename noofrecsubsidiaries snbr
						rename bvdaccountnumber accnr
						rename companyname company_name
						rename auditorname auditor_name
						rename bvdidnumber bvd_id_number
						
						/* Error */
						local error = 0
				}
					
				/* Version 2: different datarows  */
				if `error' == 1  {
					
					/* Import */
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(16) rowrange(17:) clear asdouble stringcols(_all) 
				
					/* Check Import */
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(16) rowrange(17:) clear asdouble stringcols(_all)
					}

					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(16) rowrange(17:) clear asdouble stringcols(_all)
					}
					
					if c(k) < 10 {
						import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(16) rowrange(17:) clear asdouble stringcols(_all)
					}
				
					/* Alternative variable names */
					
						/* Drop */
						drop v1
						
						/* Destring */
						destring ///
							oprevenuemileurlast* ///
							plforperiodmileurlast* ///
							marketcapitalisation* ///
							noofrecshareholders ///
							noofrecsubsidiaries ///
							peergroupsize ///
							numberofmonthslast* ///
							exchangeratefromlocalcurrencyeur ///
							, replace ignore(",")
							
						/* Rename */
						rename numberofmonthslast* months
						rename exchangeratefromlocalcurrencyeur exchrate
						rename accountunitlast* unit_string
						rename oprevenuemileurlast* opre_c
						rename plforperiodmileurlast* pl_c
						rename numberofemployeeslast* empl_c
						rename marketcapital* hdr_mar
						rename noofrecshareholders onbr
						rename noofrecsubsidiaries snbr
						rename bvdaccountnumber accnr
						rename companyname company_name
						rename auditorname auditor_name
						rename bvdidnumber bvd_id_number
				}					
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Bankers */
					preserve

						/* Keep bankers */
						keep accnr banker*
						
						/* Duplicates drop */
						duplicates drop accnr banker*, force
						
						/* Save Intermediate Data */
						cd "`output'/Bankers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Bankers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Bankers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep bankers */
						keep accnr bm*
						
						/* Duplicates drop */
						duplicates drop accnr bm*, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop bankers & managers */
						drop banker* bm* 
						
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2010) */
		}			
	
		/* Vintage Condition: Old Vintage (2011) */
		if `year' == 2011 {
		
			/* File Loop */
			foreach file of local files {
			
				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(tab) varnames(1) clear asdouble stringcols(_all) 
			
				/* Check Import */
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(".") varnames(1) clear asdouble stringcols(_all)
				}

				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(";") varnames(1) clear asdouble stringcols(_all)
				}
				
				if c(k) < 10 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", delimiter(" ") varnames(1) clear asdouble stringcols(_all)
				}
				
				/* Alternative variable names */
				
					/* Version 1 */
					capture {
						
						/* Drop */
						drop mark
						
						/* Destring */
						destring ///
							op_revenue_mil_eur_last* ///
							p_l_for_period_mil_eur_last* ///
							total_assets_mil_eur_last* ///
							current_market_capitalisation* ///
							no_of_recorded_shareholders ///
							no_of_recorded_subsidiaries ///
							peer_group_size ///
							number_of_months_last* ///
							var98 ///
							, replace ignore(",")
							
						/* Rename */
						rename number_of_months_last* months
						rename var98 exchrate
						rename account_unit_last* unit_string
						rename op_revenue_mil_eur_last* opre_c
						rename p_l_for_period_mil_eur_last* pl_c
						rename total_assets_mil_eur_last* at_c
						rename number_of_employees_last* empl_c
						rename current_market_capitalisation hdr_mar
						rename no_of_recorded_shareholders onbr
						rename no_of_recorded_subsidiaries snbr
						rename bvd_account_number accnr

					}
					
					/* Version 2 */
					capture {
					
						/* Drop */
						drop *mark
						
						/* Destring */
						destring ///
							oprevenuemileurlast* ///
							plforperiodmileurlast* ///
							totalassetsmileurlast* ///
							currentmarketcapitalisation* ///
							noofrecordedshareholders ///
							noofrecordedsubsidiaries ///
							peergroupsize ///
							numberofmonthslast* ///
							exchangeratefromlocalcurrencyeur ///
							, replace ignore(",")
							
						/* Rename */
						rename numberofmonthslast* months
						rename exchangeratefromlocalcurrencyeur exchrate
						rename accountunitlast* unit_string
						rename oprevenuemileurlast* opre_c
						rename plforperiodmileurlast* pl_c
						rename totalassetsmileurlast* at_c
						rename numberofemployeeslast* empl_c
						rename currentmarketcapitalisation hdr_mar
						rename noofrecordedshareholders onbr
						rename noofrecordedsubsidiaries snbr
						rename bvdaccountnumber accnr
						rename companyname company_name
						rename auditorname auditor_name
						rename bvdidnumber bvd_id_number
					}
					
				/* Compress */
				compress
				
				/* Saving & appending in respective folder */
				
					/* Bankers */
					preserve

						/* Keep bankers */
						keep accnr banker*
						
						/* Duplicates drop */
						duplicates drop accnr banker*, force
						
						/* Save Intermediate Data */
						cd "`output'/Bankers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Bankers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Bankers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta

					restore
					
					/* Managers */
					preserve

						/* Keep bankers */
						keep accnr dm*
						
						/* Duplicates drop */
						duplicates drop accnr dm*, force
						
						/* Save Intermediate Data */
						cd "`output'/Managers"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_Managers_`year'", force 
						
						/* Save Appended Data */
						save "`country'_Managers_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
						
					restore					
					
					/* Company */
						
						/* Drop bankers & managers */
						drop banker* dm* 
						
						/* Duplicates drop */
						duplicates drop accnr, force //drops duplicate website, email etc. information
						
						/* Save Intermediate Data */
						cd "`output'/`section'"
						save intermediate_`year', replace
					
						/* Append Data */
						capture append using "`country'_`section'_`year'", force 
						
						/* Save Appended Data */
						save "`country'_`section'_`year'", replace

						/* Delete intermediate */
						rm intermediate_`year'.dta
			
			/* Close: File Loop */
			}
		
		/* Close: Old Vintage (2011) */
		}		
		
		/* Vintage Condition: New Vintage (2012) */
		if `year' >= 2012 {
			
			/* File Loop */
			foreach file of local files {
			
				/* Category */
				if regexm("`file'", "[0-9]+\.") == 1 {
					local category = "main"
				}
				
				if regexm("`file'", "[a-zA-Z]+\.") == 1 {
				
					qui di regexm("`file'", "[a-zA-Z]+\.")
					if substr(regexs(0), 1, 2) == "nr" {
						local category = substr(regexs(0), 3, length(regexs(0))-3)
					}

					if substr(regexs(0), 1, 4) == "nrof" {
						local category = substr(regexs(0), 5, length(regexs(0))-5)
					}
					
					if substr(regexs(0), 1, 2) != "nr" {
						local category = substr(regexs(0), 1, length(regexs(0))-1)
					}
				}

				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(tab) varnames(1) clear stringcols(_all)
			
				/* Check Import */
				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(".") varnames(1) clear stringcols(_all)
				}

				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(";") varnames(1) clear stringcols(_all)
				}

				/* Compress */
				compress
				
				/* Rename */
				capture rename ïrecord_id record_id
				
				/* Company data */
				if 	///
					regexm("`category'", "auditor") == 0 & ///
					regexm("`category'", "code") == 0 & ///
					regexm("`category'", "additional") == 0 & ///
					regexm("`category'", "banker") == 0 & ///
					regexm("`category'", "contacts") == 0 & ///
					regexm("`category'", "shareholder") == 0 & ///
					regexm("`category'", "subsidiar") == 0 & ///
					regexm("`category'", "acronym") == 0 & ///
					regexm("`category'", "nace") == 0 & ///
					regexm("`category'", "naics") == 0 & ///
					regexm("`category'", "national") == 0 & ///
					regexm("`category'", "email") == 0 & ///
					regexm("`category'", "faxes") == 0 & ///
					regexm("`category'", "identifiers") == 0 & ///
					regexm("`category'", "years") == 0 & ///
					regexm("`category'", "phones") == 0 & ///
					regexm("`category'", "website") == 0 & ///
					regexm("`category'", "previous") == 0 & ///
					regexm("`category'", "sic") == 0 {
				
					/* Save Intermediate Data */
					cd "`output'/`section'"
					if "`category'" != "main" {
						save intermediate_`year'_`category', replace
						local categories: list categories | category 
					}
					
					/* Merge, Append, & Save */
					if "`category'" == "main" { 
						/* Merge */
						foreach c of local categories {
							merge m:m record_id using intermediate_`year'_`c'
							drop _merge
							rm intermediate_`year'_`c'.dta
						}
					
						/* Append Data*/
						capture append using "`country'_`section'_`year'", force
						
						/* Save */
						save "`country'_`section'_`year'", replace
						
						/* Reset local */
						local categories
					}
				}

				/* Auditor data */
				if regexm("`category'", "auditor") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Auditors"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Auditors_`year'", force
					save "`country'_Auditors_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}				
				
				
				/* Banker data */
				if regexm("`category'", "banker") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Bankers"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Bankers_`year'", force
					save "`country'_Bankers_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Manager data */
				if regexm("`category'", "contacts") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Managers"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Managers_`year'", force
					save "`country'_Managers_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Ownership data */
				if regexm("`category'", "shareholder") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Ownership"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Ownership_`year'_`category'", force
					save "`country'_Ownership_`year'_`category'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Subsidiary data */
				if regexm("`category'", "subsidiar") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Subsidiaries"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Subsidiaries_`year'_`category'", force
					save "`country'_Subsidiaries_`year'_`category'", replace
				
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				}
	
				/* Subsidiary data */
				if ///
					regexm("`category'", "acronym") == 1 | ///
					regexm("`category'", "nace") == 1 | ///
					regexm("`category'", "naics") == 1 | ///
					regexm("`category'", "national") == 1 | ///
					regexm("`category'", "email") == 1 | ///
					regexm("`category'", "faxes") == 1 | ///
					regexm("`category'", "identifiers") == 1 | ///
					regexm("`category'", "years") == 1 | ///
					regexm("`category'", "phones") == 1 | ///
					regexm("`category'", "website") == 1 | ///
					regexm("`category'", "previous") == 1 | ///
					regexm("`category'", "code") == 1 | ///
					regexm("`category'", "additional") == 1 | ///
					regexm("`category'", "sic") == 1 {

					/* Save Intermediate Data */
					cd "`output'/Other"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Other_`year'_`category'", force
					save "`country'_Other_`year'_`category'", replace
				
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				}
				
			/* Close: File Loop */
			}
	
		/* Deleting Intermediate Data */
		cd "`output'/`section'"
		cap rm intermediate_`year'.dta
					
		/* Close: New Vintage */
		}
		
	/* Close: Folder Loop */
	}

/* Close: Company Section */
}	

********************************************************************************
**** (3) Importing: Ownership and Subsidiaries Sections						****
********************************************************************************

/* Section: Ownership */
if "`section'" == "Ownership" | "`section'" == "Subsidiaries" {

	/* Folder List */
	local folders: dir "`directory'/`year'/`section'" dirs "*"
	
	/* Folder Loop */
	foreach country of local folders {

		/* File List */
		local files: dir "`directory'/`year'/`section'/`country'" files "*"

		/* Vintage Condition: New Vintage (2012) */
		if `year' >= 2012 {
			
			/* File Loop */
			foreach file of local files {
		
				/* Category */
				if regexm("`file'", "[0-9]+\.") == 1 {
					local category = "main"
				}
				
				if regexm("`file'", "[a-zA-Z]+\.") == 1 {
				
					qui di regexm("`file'", "[a-zA-Z]+\.")
					if substr(regexs(0), 1, 2) == "nr" {
						local category = substr(regexs(0), 3, length(regexs(0))-3)
					}

					if substr(regexs(0), 1, 4) == "nrof" {
						local category = substr(regexs(0), 5, length(regexs(0))-5)
					}
					
					if substr(regexs(0), 1, 2) != "nr" {
						local category = substr(regexs(0), 1, length(regexs(0))-1)
					}
				}

				/* Import */
				import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(tab) varnames(1) clear stringcols(_all)
			
				/* Check Import */
				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(".") varnames(1) clear stringcols(_all)
				}

				if c(k) < 2 {
					import delimited using "`directory'/`year'/`section'/`country'/`file'", rowrange(3:) delimiter(";") varnames(1) clear stringcols(_all)
				}

				/* Compress */
				compress
				
				/* Rename */
				capture rename ïrecord_id record_id

				/* Main ownership data */
				if regexm("`category'", "main") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/`section'"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_`section'_`year'", force
					save "`country'_`section'_`year'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				
				}				
				
				/* Ownership data */
				if regexm("`category'", "shareholder") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Ownership"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Ownership_`year'_`category'", force
					save "`country'_Ownership_`year'_`category'", replace
					
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta
				}
				
				/* Subsidiary data */
				if regexm("`category'", "subsidiar") == 1 {
				
					/* Save Intermediate Data */
					cd "`output'/Subsidiaries"
					save intermediate_`year'_`category', replace

					/* Append Data & Save */
					capture append using "`country'_Subsidiaries_`year'_`category'", force
					save "`country'_Subsidiaries_`year'_`category'", replace
				
					/* Deleting Intermediate Data */
					rm intermediate_`year'_`category'.dta				
				}
				
			/* Close: File Loop */
			}
					
		/* Close: New Vintage */
		}
		
	/* Close: Folder Loop */
	}

/* Close: Ownership Section */
}	

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		12/07/2020													****
**** Program:	Analyses													****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Data.dta")		

********************************************************************************
**** (1) Sample selection and variable truncation							****
********************************************************************************

/* Data */
use Data, clear

/* Duplicates drop */
duplicates drop ci year, force

/* Sample period */
keep if year >= 2001 & year <= 2015

/* Panel */
xtset ci year

/* Variable list

Manuscript labels (Table 2):
	mc_scope		= Standardized Reporting Scope
	mc_audit		= Standardized Auditing Scope
	scope			= Actual Reporting Scope
	audit_scope		= Actual Auditing Scope
	m_audit			= Audit (Average)
	m_listed		= Publicly Listed (Average)
	w_listed		= Public Listed (Aggregate)
	m_shareholder	= Shareholders (Average)
	w_shareholder	= Shareholders (Aggregate)
	m_indep			= Independence (Average)
	w_indep			= Independence (Aggregate)
	m_entry			= Entry (Average)
	w_entry			= Entry (Aggregate)
	m_exit			= Exit (Average)
	w_exit			= Exit (Aggregate)
	hhi				= HHI
	cv_markup		= Dispersion (Gross Margin)
	sr_markup		= Distance (Gross Margin)
	cv_margin		= Dispersion (EBITDA/Sales)
	sr_margin		= Distance (EBITDA/Sales)
	cv_tfp_e		= Dispersion (TFP (Employees))
	sr_tfp_e		= Distance (TFP (Employees))
	p20_tfp_e		= Lower Tail (TFP (Employees))
	p80_tfp_e		= Upper Tail (TFP (Employees))
	cv_tfp_w		= Dispersion (TFP (Wage))
	sr_tfp_w		= Distance (TFP (Wage))
	p20_tfp_w		= Lower Tail (TFP (Wage))
	p80_tfp_w		= Upper Tail (TFP (Wage))
	cov_lp_e		= Covariance Y/L and Y (Employees)
	cov_tfp_e		= Covariance TFP and Y (Employees)
	cov_lp_w		= Covariance Y/L and Y (Wage)
	cov_tfp_w		= Covariance TFP and Y (Wage)
	m_lp_e			= Y/L (Employees) (Average)
	m_lp_w			= Y/L (Wage) (Average)
	m_tfp_e			= TFP (Employees) (Average)
	m_tfp_w			= TFP (Wage) (Average)
	w_lp_e			= Y/L (Employees) (Aggregate)
	w_lp_w			= Y/L (Wage) (Aggregate)
	w_tfp_e			= TFP (Employees) (Aggregate)
	w_tfp_w			= TFP (Wage) (Aggregate)
	dm_lp_e			= delta Y/L (Employees) (Average)
	dm_lp_w			= delta Y/L (Wage) (Average)
	dm_tfp_e		= delta TFP (Employees) (Average)
	dm_tfp_w		= delta TFP (Wage) (Average)
	dw_lp_e			= delta Y/L (Employees) (Aggregate)
	dw_lp_w			= delta Y/L (Wage) (Aggregate)
	dw_tfp_e		= delta TFP (Employees) (Aggregate)
	dw_tfp_w		= delta TFP (Wage) (Aggregate)

Notes:
	mc_ 		= prefix denoting simulated/standardized scopes (i.e., Monte Carlo simulation based scopes)
	m_ 			= prefix for equally-weighted mean
	w_			= prefix for sales-share-weighted total
	sr_			= prefix for standardized distance or range ((p80-p20)/mean)
	cv_			= prefix for coefficient of variation (standard deviation/mean)
	p20_		= prefix for 20th percentile
	p80_		= prefix for 80th percentile
	dm_			= prefix for mean growth (delta of mean)
	dw_ 		= prefix for aggregate growth (delta of sales-weighted total)
	_e			= suffix for employees-based measure (e.g., TFP calculated with number of employees as input)
	_w			= suffix for wage-based measure (e.g., TFP calculated with wage expense as input)
*/

	/* All outcomes */
	local All = "scope audit_scope m_audit m_listed w_listed m_shareholder w_shareholder m_indep w_indep m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w m_lp_e m_lp_w m_tfp_e m_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

	/* All second stage outcomes (excludes: scope and audit_scope) */
	local All_2SLS = "m_audit m_listed w_listed m_shareholder w_shareholder m_indep w_indep m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w m_lp_e m_lp_w m_tfp_e m_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

/* Panel: country-industry year */
xtset ci year

********************************************************************************
**** Table 1: Descriptive Statistics										****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_1.smcl, replace smcl name(Table_1) 

/* Descriptives */

	/* Financial reporting */
	local descriptives = "mc_scope mc_audit scope audit_scope m_audit"
	tabstat `descriptives' if mc_scope != . & mc_audit != . ///
		, col(stats) stat(N mean sd p10 p25 p50 p75 p90)
	
	/* Type of resource allocation */
	local descriptives = "m_listed w_listed m_shareholder w_shareholder m_indep w_indep m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin"
	tabstat `descriptives' if mc_scope != . & mc_audit != . ///
		, col(stats) stat(N mean sd p10 p25 p50 p75 p90)
		
	/* Efficiency of resource allocation */
	local descriptives = "cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w m_lp_e m_lp_w m_tfp_e m_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"
	tabstat `descriptives' if mc_scope != . & mc_audit != . ///
		, col(stats) stat(N mean sd p10 p25 p50 p75 p90)

/* Log file: close */
log close Table_1

********************************************************************************
**** Table 2: Standardized Scope and Actual Scope							****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_2.smcl, replace smcl name(Table_2) 		
	
/* Regression inputs */
local DepVar = "scope audit_scope m_audit"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_2	
	
********************************************************************************
**** Table 3: Standardized Scope and Ownership Concentration				****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_3.smcl, replace smcl name(Table_3) 		
		
/* Regression inputs */
local DepVar = "m_listed w_listed m_shareholder w_shareholder m_indep w_indep"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_3		
	
********************************************************************************
**** Table 4: Standardized Scope and Product-Market Competition				****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_4.smcl, replace smcl name(Table_4) 		
		
/* Regression inputs */
local DepVar = "m_entry w_entry m_exit w_exit hhi cv_markup sr_markup cv_margin sr_margin"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_4	
	
********************************************************************************
**** Table 5: Standardized Scope, Revenue-Productivity Dispersion, and		****
****          Size-Productivity Covariance,  and Product-Market Competition	****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_5.smcl, replace smcl name(Table_5) 		
		
/* Regression inputs */
local DepVar = "cv_tfp_e sr_tfp_e p20_tfp_e p80_tfp_e cov_lp_e cov_tfp_e cv_tfp_w sr_tfp_w p20_tfp_w p80_tfp_w cov_lp_w cov_tfp_w"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_5		
	
********************************************************************************
**** Table 6: Standardized Scope and Revenue Productivity					****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_6.smcl, replace smcl name(Table_6) 		
		
/* Regression inputs */
local DepVar = "m_lp_e m_lp_w m_tfp_e m_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w w_lp_e w_lp_w w_tfp_e w_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"

/* Regression */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope mc_audit, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(mc_scope mc_audit) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}
	
/* Log file: close */
log close Table_6	
		
********************************************************************************
**** Table 7: Correlated Factors											****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_7.smcl, replace smcl name(Table_7) 

/* Regression inputs */
local DepVar = "scope"
local CIY = "firms m_sales m_empl m_fias hhi"

/* Loop */
foreach y of varlist `DepVar' {

	/* Estimation */
	qui reghdfe mc_`y' `CIY' if `y'!=., a(cy iy) cluster(ci_cluster cy)
		est store M1
			
	qui reghdfe `y' `CIY' if mc_`y'!=., a(cy iy) cluster(ci_cluster cy)
		est store M2

				
	/* Output */
	estout M1 M2, cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
		legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE") ///
		mlabels(, depvars) varwidth(40) modelwidth(20) unstack ///
		stats(N N_clust1 N_clust2 r2_within, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "R-Squared (Within)"))			
			
}

/* Log file: close */
log close Table_7	
	
********************************************************************************
**** Table A2: Standardized Reporting and Auditing Scopes by Country + Year	****
********************************************************************************
		
/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A2.smcl, replace smcl name(Table_A2) 	
	
	
/* Scope by year */
forvalue y = 2001(1)2015 {
	di "Year: " `y'
	tabstat mc_scope mc_audit if year == `y', by(country) format(%9.2f)
}

/* Log file: close */
log close Table_A2

********************************************************************************
**** Table A5: Second Stage Estimates (IV)							 		****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A5.smcl, replace smcl name(Table_A5) 

/* Regression inputs */
local DepVar = "`All_2SLS'"

/* Regression: country-year + industry-year fixed effects (scope + audit) [IV] */
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			qui ivreghdfe `y' (scope audit_scope = mc_scope mc_audit), a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(scope audit_scope) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [IV]") ///
				varlabels(scope "Instrumented Reporting Scope" audit_scope "Instrumented Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
		
	/* Restore */
	restore
}

/* Log file: close */
log close Table_A5

********************************************************************************
**** Table A6: Firm Density and Resource Allocation					 		****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A6.smcl, replace smcl name(Table_A6) 

/* Regression inputs */
local DepVar = "`All'"

/* Regression: country-year + industry-year fixed effects (firms + firms^2) */
foreach y of varlist `DepVar' {
			
	/* Preserve */
	preserve
			
		/* Firms (squared) */
		gen firms_2 = firms^2
		label var firms_2 "Number of Firms (squared)"
			
		/* Capture */
		capture noisily {
				
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=. & firms!=., a(cy iy) residual(r_`y')
			qui reghdfe firms if `y'!=. & mc_audit!=. & firms!=., a(cy iy) residual(r_firms)
			qui reghdfe firms_2 if `y'!=. & mc_scope!=. & firms!=., a(cy iy) residual(r_firms_2)
					
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
					
			qui sum r_firms, d
			qui replace firms = . if r_firms < r(p1) | r_firms > r(p99)		
		
			qui sum r_firms_2, d
			qui replace firms_2 = . if r_firms_2 < r(p1) | r_firms_2 > r(p99)
				
			/* Estimation */
			qui reghdfe `y' firms firms_2, a(cy iy) cluster(ci_cluster cy)
					
			/* Output */
			estout, keep(firms firms_2) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Aggregate Growth Validation]") ///
				mlabels(, depvar) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
					
		}
			
	/* Restore */
	restore
}

/* Log file: close */
log close Table_A6

********************************************************************************
**** Table A7: Interaction of Reporting and Auditing Mandates				****
********************************************************************************

/* Interactions */
qui gen mc_scope_unc = 0 if mc_scope != .
qui replace mc_scope_unc = mc_scope if mc_scope > mc_audit
label var mc_scope_unc "Reporting (w/o Auditing)"

qui gen mc_scope_con = 0 if mc_scope != .
qui replace mc_scope_con = mc_scope if mc_scope <= mc_audit
label var mc_scope_con "Reporting (w/ Auditing)"

qui gen mc_audit_unc = 0 if mc_audit != .
qui replace mc_audit_unc = mc_audit if mc_scope < mc_audit
label var mc_audit_unc "Auditing (w/o Reporting)"

qui gen mc_audit_con = 0 if mc_audit != .
qui replace mc_audit_con = mc_audit if mc_scope >= mc_audit
label var mc_audit_con "Auditing (w/ Reporting)"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_A7.smcl, replace smcl name(Table_A7) 

/* Regression inputs */
local DepVar = "`All'"
	
/* Regression: country-year + industry-year fixed effects (scope + audit) [jointly] */
foreach y of varlist `DepVar' {
					
	/* Preserve */
	preserve

		/* Capture */
		capture noisily {
				
			/* Truncation */
			qui reghdfe `y' if mc_scope_unc!=. & mc_scope_con!=. & mc_audit_unc!=. & mc_audit_con!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope_unc if `y'!=. & mc_scope_con!=. & mc_audit_unc!=. & mc_audit_con!=., a(cy iy) residual(r_mc_scope_unc)
			qui reghdfe mc_scope_con if `y'!=. & mc_scope_unc!=. & mc_audit_unc!=. & mc_audit_con!=., a(cy iy) residual(r_mc_scope_con)
			qui reghdfe mc_audit_unc if `y'!=. & mc_scope_unc!=. & mc_scope_con!=. & mc_audit_con!=., a(cy iy) residual(r_mc_audit_unc)
			qui reghdfe mc_audit_con if `y'!=. & mc_scope_unc!=. & mc_scope_con!=. & mc_audit_unc!=., a(cy iy) residual(r_mc_audit_con)
			
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
					
			qui sum r_mc_scope_unc, d
			qui replace mc_scope_unc = . if r_mc_scope_unc < r(p1) | r_mc_scope_unc > r(p99)		

			qui sum r_mc_scope_con, d
			qui replace mc_scope_con = . if r_mc_scope_con < r(p1) | r_mc_scope_con > r(p99)
					
			qui sum r_mc_audit_unc, d
			qui replace mc_audit_unc = . if r_mc_audit_unc < r(p1) | r_mc_audit_unc > r(p99)		

			qui sum r_mc_audit_con, d
			qui replace mc_audit_con = . if r_mc_audit_con < r(p1) | r_mc_audit_con > r(p99)
			
			/* Estimation */
			qui reghdfe `y' mc_scope_unc mc_scope_con mc_audit_unc mc_audit_con, a(cy iy) cluster(ci_cluster cy)
						
			/* Output */
			estout, keep(mc_scope_unc mc_scope_con mc_audit_unc mc_audit_con) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("SPECIFICATION: COUNTRY-YEAR AND INDUSTRY-YEAR FE [Reduced Form]") ///
				varlabels(mc_scope "Standardized Reporting Scope" mc_audit "Standardized Auditing Scope") ///
				mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
				stats(N N_clust1 N_clust2 r2_a, fmt(0 0 0 3) label("Observations" "Clusters (Country-Industry)" "Clusters (Country-Year)" "Adjusted R-Squared"))		
				
		}
	
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_A7

********************************************************************************
**** Supplemental information: Instrument F-stat, number of firms, and		****
****						   conditional standard deviations		 		****
********************************************************************************

/* Log file: open */
cd "`directory'\Output\Logs"
log using Supplement.smcl, replace smcl name(Supplement) 

/* First stage F-staticts (instrument) */

	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe firms if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_firms)
			qui reghdfe mc_scope if firms!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if firms!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_firms, d
			qui replace firms = . if r_firms < r(p1) | r_firms > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Estimation */
			ivreghdfe firms (scope audit_scope = mc_scope mc_audit), a(cy iy) cluster(ci_cluster cy) ffirst
						
		}
		
	/* Restore */
	restore

/* Total number of firm-years */

	/* Preserve */
	preserve
	
		/* Exponentiate */
		qui gen number = exp(firms)
		
		/* Total */
		qui egen double total = total(number)
		
		/* Sum */
		qui sum total
		local sum = r(mean)
		
		/* Display */
		di "Total number of firm-year observations: " `sum'
		
	/* Restore */
	restore
	

/* Conditional standard deviation (covariance and growth) */
local DepVar = "cov_lp_e cov_tfp_e cov_lp_w cov_tfp_w dm_lp_e dm_lp_w dm_tfp_e dm_tfp_w dw_lp_e dw_lp_w dw_tfp_e dw_tfp_w"
foreach y of varlist `DepVar' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {
			
			/* Truncation */
			qui reghdfe `y' if mc_scope!=. & mc_audit!=., a(cy iy) residual(r_`y')
			qui reghdfe mc_scope if `y'!=. & mc_audit!=., a(cy iy) residual(r_mc_scope)
			qui reghdfe mc_audit if `y'!=. & mc_scope!=., a(cy iy) residual(r_mc_audit)
				
			qui sum r_`y', d
			qui replace r_`y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		
	
			qui sum r_mc_audit, d
			qui replace mc_audit = . if r_mc_audit < r(p1) | r_mc_audit > r(p99)
			
			/* Sum */
			sum r_`y' if mc_scope != . & mc_audit != . & ci_cluster != . & cy != . & iy != .
						
		}
		
	/* Restore */
	restore
}	

/* Log file: close */	
log close Supplement

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Panel of Amadeus ID and other static items 					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // insert directory for raw data

**** Project ****
project, original("`directory'\Amadeus\Amadeus_ID.txt")
project, original("`directory'\Amadeus\correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format.dta")

********************************************************************************
**** (1) Creating BvD ID and industry correspondence tables					****
********************************************************************************

/* BvD ID changes */

	/* Correspondence table */
	cd "`directory'\Amadeus"
	import delimited using Amadeus_ID.txt, delimiter(tab) varnames(1) clear

	/* Rename */
	rename oldid bvd_id
	
	/* Save */
	save Amadeus_ID, replace
		
	/* Project */
	project, creates("`directory'\Amadeus\Amadeus_ID.dta")

/* Industry (NACE) correspondence (Sebnem et al. (2015)) */

	/* Correspondence table */
	cd "`directory'\Amadeus"
	use correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format, clear

	/* Keep relevant variables */
	keep nacerev11 nacerev2
	
	/* Destring code */
	destring nacerev11 nacerev2, ignore(".") replace force
	
	/* Keep if non-missing */
	keep if nacerev11 != . & nacerev2 != .
	
	/* Rename */
	rename nacerev11 nace_ind
	rename nacerev2 nace2_ind_corr
	
	/* Save */
	save NACE_correspondence, replace
	
	/* Project */
	project, creates("`directory'\Amadeus\NACE_correspondence.dta")
	
********************************************************************************
**** (1) Constructing panel data by country									****
********************************************************************************

/* Sample countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop (loading data, keeping relevant variables, saving in local folder) */
foreach country of local countries {

	/* Delete existing data */
	cd "`directory'\Amadeus"
	cap rm Company_`country'.dta	
		
	forvalues year = 2005(1)2016 {	
		
		/* Delete */
		cap rm Auditors.dta
		cap rm Owners.dta
		
		/* Capture */
		capture noisily {
		
			/* Project */
			project, original("`data'\Company/`country'_Company_`year'.dta")

			/* Data */
			cd "`data'\Company"
			use `country'_Company_`year', clear
			
			/* Vintage */
			gen vintage = `year'
			label var vintage "Vintage (BvD Disc)"			
			
			/* Renaming, keeping relevant variables, merging missing variables */
			if `year' == 2005 {
			
				/* Rename */
				rename idnr bvd_id
				rename nacpri nace_ind
				
				/* Keep (only keep empl_c; no unit issues) */
				keep bvd_id company lstatus type quoted repbas typacc dateinc empl_c onbr indepind ad_name nace_ind consol vintage
				
				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol ad_name, replace force
				destring nace_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				cap rm Company_`country'.dta
				save Company_`country', replace

			}
			if `year' == 2006 {
			
				/* Rename */
				rename idnr bvd_id
				rename nacpri nace_ind
				
				/* Keep */
				keep bvd_id company lstatus type quoted repbas typacc dateinc empl_c onbr indepind ad_name nace_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol ad_name, replace force
				destring nace_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}			
			if `year' == 2007 {
			
				/* Rename */
				rename idnr bvd_id
				rename accpra* accpra
				rename nacpri nace_ind
				
				/* Keep */
				keep bvd_id company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol ad_name, replace force
				destring nace_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2008 {
			
				/* Rename */
				rename bvd_id_number bvd_id
				rename company_name company
				rename auditor_name ad_name
				rename accpra* accpra
				rename nac2pri nace2_ind

				/* Keep (w/o dateinc) */
				keep bvd_id company lstatus type quoted repbas accpra typacc empl_c onbr indepind ad_name nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas accpra typacc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2009 {
			
				/* Rename */
				rename bvd_id_number bvd_id
				rename legalstatus lstatus
				rename legalform type
				rename publiclyquoted quoted
				rename reportingbasis repbas
				rename typeofaccount* typacc
				rename accountingpractice* accpra
				rename dateofincorporation dateinc
				rename bvdepindependenceindicator indepind
				rename auditor_name ad_name
				rename nacerev2primarycode nace2_ind
				rename consol* consol
				
				/* Keep */
				keep bvd_id company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas accpra typacc dateinc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2010 {
				
				/* Rename */
				rename bvd_id_number bvd_id
				rename company_name company
				rename legalstatus lstatus
				rename legalform type
				rename publiclyquoted quoted
				rename dateofincorporation dateinc
				rename reportingbasis repbas
				rename typeofaccountavailable typacc
				rename accountingpractice* accpra
				rename bvdindependenceindicator indepind
				rename auditor_name ad_name
				rename nacerev2primarycode nace2_ind
				rename conscode consol
				
				/* Keep */
				keep bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace2_ind consol vintage
				
				/* Format */
				tostring bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Add further variables from separate files */
				
					/* Number of banks */
					capture {
					
						/* Data */
						cd "`data'\Bankers"
						use `country'_Bankers_`year', clear
						
						/* Keep */
						keep accnr b*
						
						/* Convert to string */
						cap tostring b*, replace force
						
						/* Drop missing */
						drop if b == ""
						
						/* Count banks */
						egen banks = count(accnr), by(accnr)
						
						/* Keep */
						keep accnr banks
						
						/* Duplicates */
						sort accnr banks
						duplicates drop accnr, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Bankers, replace
					}
					
					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					capture {	
						merge m:1 accnr using Bankers
						drop if _merge == 2
						drop _merge
					}
					
					/* Drop */
					drop accnr
					
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace	
				
			}
			if `year' == 2011 {
			
				/* Rename */
				rename bvd_id_number bvd_id
				rename company_name company
				cap rename legalstatus lstatus
				cap rename legal_status lstatus
				cap rename nationallegalform type
				cap rename national_legal_form type
				cap rename dateofincorporation dateinc
				cap rename date_of_incorporation dateinc
				cap rename publiclyquoted quoted
				cap rename publicly_quoted quoted
				cap rename reportingbasis repbas
				cap rename reporting_basis repbas
				cap rename typesofaccountsavailable typacc
				cap rename type_s__of_accounts* typacc
				rename accounting* accpra
				cap rename bvdindependenceindicator indepind
				cap rename bvd_indep* indepind
				rename auditor_name ad_name
				cap rename nacerev2primarycode nace2_ind
				cap rename nace_rev__2_primary_code nace2_ind
				cap rename cons* consol

				/* Keep */
				keep bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc empl_c onbr indepind ad_name nace2_ind consol vintage

				/* Format */
				tostring bvd_id accnr company lstatus type quoted repbas accpra typacc dateinc indepind consol ad_name, replace force
				destring nace2_ind empl_c onbr, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge

				/* Drop */
				drop accnr
					
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
			
			}
			if `year' == 2012 {

				/* Rename */
				rename idnr bvd_id
				rename name company
				rename quoted_str quoted
				rename nac2pri nace2_ind
				rename v30 indepind
				rename v31 onbr
				
				/* Keep */
				keep bvd_id record_id company lstatus type quoted repbas typacc dateinc indepind onbr nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring onbr nace2_ind, replace force ignore(",")

				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Add further variables from separate files */
				
					/* Auditor name */
						
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep record_id ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort record_id ad_name
						duplicates drop record_id, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace

					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					merge m:1 record_id using Auditors
					drop if _merge == 2
					drop _merge
					
					/* Drop */
					drop record_id
					
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace				
			}
			if `year' == 2013 {

				/* Rename */
				rename idnr bvd_id
				rename name company
				rename quoted_str quoted
				rename header_empl empl_c
				rename nac2pri nace2_ind
				rename v73 indepind
				rename v74 onbr
				
				/* Keep */
				keep record_id bvd_id company lstatus type quoted repbas typacc dateinc indepind onbr empl_c nace2_ind consol vintage

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring onbr nace2_ind empl_c, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
				
				/* Add further variables from separate files */
				
					/* Auditor name */
						
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep record_id ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort record_id ad_name
						duplicates drop record_id, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace

					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					merge m:1 record_id using Auditors
					drop if _merge == 2
					drop _merge
					
					/* Drop */
					drop record_id
				
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace					
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
				
			}
			if `year' == 2014 | `year' == 2015 {

				/* Rename */
				rename idnr bvd_id
				rename name company
				rename quoted_str quoted
				rename header_empl empl_c
				rename historic_status_str_lastyear lstatus
				rename v33 indepind
				rename v35 onbr
				rename nac2pri nace2_ind
				
				/* Keep */
				keep bvd_id record_id company lstatus type quoted repbas typacc dateinc empl_c indepind onbr nace2_ind consol vintage 

				/* Format */
				tostring bvd_id company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring onbr nace2_ind empl_c, replace force ignore(",")
				
				/* Merge: prior ID */
				cd "`directory'\Amadeus"				
				merge m:1 bvd_id using Amadeus_ID
				drop if _merge == 2
				drop _merge
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace
	
				/* Add further variables from separate files */
				
					/* Auditor name */
						
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep record_id ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort record_id ad_name
						duplicates drop record_id, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace
					
					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					merge m:1 record_id using Auditors
					drop if _merge == 2
					drop _merge

					/* Drop */
					drop record_id					
					
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace		
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
			}			
			if `year' == 2016 {
			
				/* Rename */
				rename name company
				rename repbas_header repbas
				drop dateinc
				rename dateinc_char dateinc
				rename nace_prim_code nace2_ind
				
				/* Keep */
				keep idnr company lstatus type quoted repbas typacc dateinc indepind nace2_ind consol vintage

				/* Format */
				tostring company lstatus type quoted repbas typacc dateinc indepind consol, replace force
				destring nace2_ind, replace force ignore(",")
				
				/* Save */
				cd "`directory'\Amadeus"
				save Intermediate, replace

			/* Add further variables from separate files */
				
					/* Auditor name */
					capture {
					
						/* Data */
						cd "`data'\Auditors"
						use `country'_Auditors_`year', clear
						
						/* Keep */
						keep idnr ad_name
									
						/* Convert to string */
						cap tostring ad_name, replace force
						
						/* Duplicates */
						sort idnr ad_name
						duplicates drop idnr, force
						
						/* Save */
						cd "`directory'\Amadeus"
						save Auditors, replace
					}
					
					/* Ownership */
					
						/* Data */
						cd "`data'\Ownership"
						use `country'_Ownership_`year', clear
						
						/* Keep */
						keep idnr sh_name
						tostring sh_name, replace force
						drop if sh_name == ""
						
						/* Duplicates */
						sort idnr sh_name
						duplicates drop idnr sh_name, force
						
						/* Number of recorded shareholders */
						egen onbr = count(sh_name), by(idnr)
						
						/* Duplicates */
						duplicates drop idnr, force
						
						/* Drop */
						drop sh_name
						
						/* Save */
						cd "`directory'\Amadeus"
						save Owners, replace
					
					/* Merging */
					cd "`directory'\Amadeus"
					use Intermediate, clear
					capture {
						merge m:1 idnr using Auditors
						drop if _merge == 2
						drop _merge
					}
					
					merge m:1 idnr using Owners
					drop if _merge == 2
					drop _merge	
					
					/* Rename */
					rename idnr bvd_id					
						
					/* Merge: prior ID */
					cd "`directory'\Amadeus"				
					merge m:1 bvd_id using Amadeus_ID
					drop if _merge == 2
					drop _merge
				
					/* Save */
					cd "`directory'\Amadeus"
					save Intermediate, replace		
				
				/* Data (save if prior years are missing) */
				cap save Company_`country'
				
				/* Append */
				use Company_`country', clear
				append using Intermediate
				
				/* Save */
				save Company_`country', replace
			}
						
		/* End: Capture */
		}
		
	/* End: Vintage/year loop */
	}
				
	/* Country */
	gen country = "`country'"
	replace country = "Czech Republic" if country == "Czech_Republic"
	replace country = "United Kingdom" if country == "United_Kingdom"
	label var country "Country"
		
	/* BvD ID definition */
	
		/* Latest ID */
		
			/* Update */
			rename bvd_id bvd_id_h
			gen bvd_id = bvd_id_h
			replace bvd_id = newid if newid != ""
			drop newid

			/* Mode */
			egen mode = mode(bvd_id), by(bvd_id_h)
			replace bvd_id = mode if bvd_id == ""
			drop mode
			
			/* Rename */
			rename bvd_id bvd_id_new
			rename bvd_id_h bvd_id	
			
	/* Sample restriction & ID */
	drop if bvd_id == "" & bvd_id_new == ""
	egen double id = group(bvd_id_new)

	/* Duplicates (tag) */
	duplicates tag id vintage, gen(dup)

	/* Drop: missing location or industry if duplicate */
	drop if dup > 0 & (nace_ind == . & nace2_ind == .)
	
	/* Consolidation: avoid duplication (drop duplicates associated with C2 (or C for 2016)) */
	gen con = (consol == "C2" | consol == "C")
	egen c2 = max(con), by(id)
	drop if dup != 0 & (consol != "C2" | consol != "C") & c2 == 1
	sort id vintage dup
	duplicates drop id vintage if dup != 0, force
	drop dup con c2

	/* Duplicates (drop) */
	sort id vintage
	duplicates drop id vintage, force
	
	/* Panel definition */
	xtset id vintage
	
	/* Industry definition */
	
		/* Merge: Industry correspondence */
		merge m:1 nace_ind using NACE_correspondence
		drop if _merge ==2
		drop _merge

		/* Generate converged industry */
		gen industry = nace2_ind
		label var industry "Industry (NACE rev 2)"
		
		/* Backfilling (using panel information) */
		xtset id vintage
		forvalues y = 1(1)11 {
			replace industry = f.industry if industry == . & f.industry != . & vintage == 2016 - `y'
		}

		/* Filling in missing values (using correspondence table) */
		replace industry = nace2_ind_corr if industry == .
		drop nace*

		/* Mode: Filling in missing values (using mode of industry code per firm) */
		egen industry_mode = mode(industry), by(id)
		replace industry = industry_mode if industry == .
		drop industry_mode
		
		/* Drop missing industry */
		drop if industry == .
		
	/* Clean auditor name */
	replace ad_name = "" if ad_name == "."
	
	/* Replace missing incorporation date (esp. 2008) */
	egen mode = mode(dateinc), by(id)
	replace dateinc = mode
	drop mode
	
	/* Drop */
	drop id
	
	/* Save */
	save Company_`country', replace	

	/* Project	*/
	project, creates("`directory'\Amadeus\Company_`country'.dta")

/* End: Country loop */
}

/* Delete intermediate data */
cd "`directory'\Amadeus"
cap rm Intermediate.dta
cap rm Auditors.dta
cap rm Owners.dta

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation 	****
**** Author:	M. Breuer													****
**** Date:		02/13/2017													****
**** Program:	Data for analyses											****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Outcomes.dta")	
project, uses("`directory'\Data\Scope.dta")	

********************************************************************************
**** (1) Combining data														****
********************************************************************************

/* Data */
use Outcomes, clear

/* Merge: Scope (Treatment) */
merge 1:1 country industry year using Scope
keep if _merge == 3
drop _merge

/* Merge: Regulation */
merge m:1 country year using Regulation
drop if _merge == 2
drop _merge

********************************************************************************
**** (2) Remaining variables												****
********************************************************************************

/* Other regulations */

	/* EU */
	gen EU = (year >= eu_date)
	label var EU "EU Member"
	
	/* EURO */
	gen EURO = (year >= euro_date)
	label var EURO "EURO Member"
	
	/* IFRS */
	gen ifrs_year = substr(ifrsdate, -4, 4)
	destring ifrs_year, force replace
	gen IFRS = (year >= ifrs_year)
	label var IFRS "IFRS Directive"
	drop ifrs_year
	
	/* TPD */
	gen TPD = (year >= tpdyear)
	label var TPD "TPD Directive"
	
	/* MAD */
	gen MAD = (year >= madyear)
	label var MAD "MAD Directive"

/* Exemptions */

	/* Preparation */
	egen preparation = rowtotal(bs_preparation_abridged is_preparation_abridged notes_preparation_abridged), missing
	label var preparation "Preparation exemptions (Small)"

	/* Publication */
	egen publication = rowtotal(bs_publication is_publication notes_publication), missing
	replace publication = 3 - publication
	label var publication "Publication exemptions (Small)"

	/* Combined exemptions */
	gen exemptions = (preparation + publication)/6
	label var exemptions "Exemptions (Small)"

********************************************************************************
**** (3) Country, industry, year indicator									****
********************************************************************************

/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Year */
egen y = group(year)
label var y "Year ID"

/* Country-industry */
egen ci = group(c i)
label var ci "Country-industry ID"

/* Country-year */
egen cy = group(c y)
label var cy "Country-year ID"

/* Industry-year */
egen iy = group(i y)
label var iy "Industry-year ID"

/* Cluster */
gen i_1 = floor(industry/1000)
egen ci_cluster = group(c i_1)
label var ci_cluster "Country-industry cluster (1-Digit)"
drop i_1

********************************************************************************
**** (4) Cleaning and saving												****
********************************************************************************

/* Save */
save Data, replace

/* Project */
project, creates("`directory'\Data\Data.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Installs external (user-written) programs					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

********************************************************************************
**** (1) Install external programs											****
********************************************************************************

**** Estout ****
ssc install estout, replace

**** Coefplot ****
ssc install coefplot, replace

**** Outreg2 ****
ssc install outreg2, replace

**** Reghdfe ****
ssc install reghdfe, replace

**** Ivreghdfe ***
ssc install ivreghdfe, replace // replaces former reghdfe IV command

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/13/2017													****
**** Program:	Graphs														****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Data.dta")		

********************************************************************************
**** (1) Sample selection and variable truncation							****
********************************************************************************

/* Data */
use Data, clear

/* Duplicates drop */
duplicates drop ci year, force

/* Sample period */
keep if year >= 2001 & year <= 2015

/* Panel: country-industry year */
xtset ci year

/* Directory */
cd "`directory'\Output\Figures"

********************************************************************************
**** Figure 2: Distribution & Time Trend of Reporting + Auditing Scopes		****
********************************************************************************

/* Scope variation within year and over time */

	/* Preserve */
	preserve	
	
		/* Graph */
		graph box mc_scope mc_audit ///
			, over(year, label(labsize(*.9) alternate)) nooutsides bar(1, color(black)) bar(2, color(gs10)) ///
			ylabel(0(0.1)1, angle(0) format(%9.2f)) ///
			legend(label(1 "Reporting Scope") label(2 "Audit Scope") rows(2) ring(0) position(2) bmargin(medium)) ///
			ytitle("Scope") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			name(Box, replace)
		
	/* Restore */
	restore
	
/* Average scope trend */

	/* Preserve */
	preserve
	
		/* Country level */
		duplicates drop c y, force
		
		/* Cross-country aggregation */
		foreach var of varlist mc_scope mc_audit {
			egen mean_`var' = mean(`var'), by(year)
		}
		
		/* Year level */
		duplicates drop year, force
		sort year
		
		/* Graph */
		graph twoway ///
			(connected mean_mc_scope year, lwidth(medium) color(black) msymbol(+)) ///
			(connected mean_mc_audit year, lwidth(medium) lpattern(dash) color(black) msymbol(x)) ///
				, ylabel(0(0.1)1, angle(0) format(%9.2f)) xlabel(2001(2)2015) ///
				legend(label(1 "Reporting Scope") label(2 "Audit Scope") rows(2) ring(0) position(2) bmargin(medium)) ///
				xtitle("Year") ///
				ytitle("Scope (Mean)") ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Time, replace)
		
	/* Restore */
	restore

/* Combine graphs */
graph combine Box Time ///
	, altshrink	title("DISTRIBUTION & TIME TREND" "OF REPORTING AND AUDITING SCOPES", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	ysize(5) xsize(10) ///
	saving(Figure_2, replace)
	
********************************************************************************
**** Figure 3: Reporting versus Auditing Scope								****
********************************************************************************

	
/* Raw scopes */

	/* Preserve */
	preserve
		
		/* Consolidate */
		gen auditing = round(mc_audit, 0.05)
		gen reporting = round(mc_scope, 0.05)
		duplicates tag auditing reporting, gen(dup)		
		
		/* Drop duplicates */
		duplicates drop auditing reporting, force
		
		/* Auditing vs. Reporting */
		graph twoway ///
			(scatter reporting auditing [w = dup], msymbol(circle_hollow) mcolor(black)) ///
				, ylabel(, angle(0) format(%9.1f)) xlabel(, format(%9.1f)) ///
				legend(off) ///
				xtitle("Standardized Auditing Scope") ///
				ytitle("Standardized Reporting Scope") ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Auditing_Raw, replace)
			
	/* Restore */
	restore		
	
/* Residualized scopes */

	/* Preserve */
	preserve
	
		/* Residual */
		qui reghdfe mc_scope if scope!=., a(cy iy) residuals(r_reporting)	
	
		qui reghdfe mc_audit if audit_scope!=., a(cy iy) residuals(r_auditing)
		
		/* Consolidate */
		gen auditing = round(r_auditing, 0.05)
		gen reporting = round(r_reporting, 0.05)
		duplicates tag auditing reporting, gen(dup)		
		
		/* Drop duplicates */
		duplicates drop auditing reporting, force
		
		/* Auditing vs. Reporting */
		graph twoway ///
			(scatter reporting auditing [w = dup], msymbol(circle_hollow) mcolor(black)) ///
				, ylabel(, angle(0) format(%9.1f)) xlabel(, format(%9.1f)) ///
				legend(off) ///
				xtitle("Res. Standardized Auditing Scope") ///
				ytitle("Res. Standardized Reporting Scope") ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Auditing_Res, replace)
			
	/* Restore */
	restore	
	
/* Combine graphs */
graph combine Auditing_Raw Auditing_Res ///
	, altshrink	title("REPORTING VERSUS AUDITING SCOPE", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	ysize(5) xsize(10) ///
	saving(Figure_3, replace)

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		12/09/2020													****
**** Program:	Identifiers for publication [JAR Data & Code policy]		****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

********************************************************************************
**** (1) Sample firms														****
********************************************************************************

/* Delete existing outcomes data */
cd "`directory'\Data"
cap rm Identifiers.dta

/* Countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop */
foreach country of local countries {

	/* Project */
	project, uses("`directory'\Amadeus\Data_`country'.dta")

	/* Data */
	cd "`directory'\Amadeus"
	use Data_`country', clear

	/* Sample period (after EUR) */
	keep if year >= 1999 & year <= 2015	
	
	/* Non-missing industry */
	drop if industry == .

	/* BvD ID */
	label var bvd_id "BvD ID (original)"

	/* Panel */
	duplicates drop bvd_id, force
	
	/* Append */
	cd "`directory'\Data"
	cap append using Identifiers

	/* Save */
	save Identifiers, replace
			
/* End: Country loop */
}

/* Project	*/
project, creates("`directory'\Data\Identifiers.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/08/2017													****
**** Program:	Outcomes													****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // specify path of (raw) STATA files

/* Project */
project, original("`directory'\Data\WB_nominal_exchange_rate.txt")		
project, original("`directory'\Data\WB_GDP_deflator.txt")		

********************************************************************************
**** (1) Currency and inflation adjustments (World Bank)					****
********************************************************************************

/* Note on adjustment logic:
- Refer to Sebnem et al. (2015, p.32)

Step-by-step:
- convert account currency to official currency of the country (as used by GDP deflator; check for currency breaks for late EUR adopters: e.g., Slovenia)
- deflate the series by the national GDP deflator with 2015 base from the World Bank
- divide by exchange rate of official currency to U.S. dollar in 2015
*/

/* World Bank nominal exchange data */

	/* Data */
	import delimited using WB_nominal_exchange_rate.txt, delimiter(tab) varnames(1) clear
	
	/* Rename */
	rename countryname country
	label var country "Country"
	rename time year
	label var year "Year"
	rename value exch
	label var exch "Nominal exchange rate (local per USD)"
	
	/* Keep */
	keep country year exch
	
	/* Country name */
	replace country = "Slovakia" if country == "Slovak Republic"
	
	/* Keep non-missing */
	drop if year == . & exch == . & country == ""
	
	/* Currency codes */
	gen currency = "EUR" if country == "Euro area" & exch != .
	replace currency = "ATS" if country == "Austria" & exch != .
	replace currency = "BEF" if country == "Belgium" & exch != .
	replace currency = "BGN" if country == "Bulgaria" & exch != .
	replace currency = "CZK" if country == "Czech Republic" & exch != .
	replace currency = "DKK" if country == "Denmark" & exch != .
	replace currency = "EEK" if country == "Estonia" & exch != .
	replace currency = "FIM" if country == "Finland" & exch != .
	replace currency = "FRF" if country == "France" & exch != .
	replace currency = "DEM" if country == "Germany" & exch != .
	replace currency = "GRD" if country == "Greece" & exch != .
	replace currency = "IEP" if country == "Ireland" & exch != .
	replace currency = "ITL" if country == "Italy" & exch != .
	replace currency = "LTL" if country == "Lithuania" & exch != .
	replace currency = "LUF" if country == "Luxembourg" & exch != .
	replace currency = "ANG" if country == "Netherlands" & exch != .
	replace currency = "PTE" if country == "Portugal" & exch != .
	replace currency = "SKK" if country == "Slovakia" & exch != .
	replace currency = "SIT" if country == "Slovenia" & exch != .
	replace currency = "GBP" if country == "United Kingdom" & exch != .
	replace currency = "HRK" if country == "Croatia" & exch != .
	replace currency = "HUF" if country == "Hungary" & exch != .
	replace currency = "NOK" if country == "Norway" & exch != .
	replace currency = "PLN" if country == "Poland" & exch != .
	replace currency = "RON" if country == "Romania" & exch != .
	replace currency = "SEK" if country == "Sweden" & exch != .
	replace currency = "ESP" if country == "Spain" & exch != .
	label var currency "Currency"
	
	/* Euro */
	gen eu = exch if country == "Euro area"
	egen exch_eu = max(eu), by(year)
	replace currency = "EUR" if exch == . & currency == "" 
	replace exch = exch_eu if exch == . & currency == "EUR"
	label var exch_eu "Nominal exchange rate (local per EUR)"
	drop eu
		
	/* Drop missing */
	drop if exch == .
	
	/* Conversion: 2015 */
	gen ex = exch if year == 2015
	egen exch_2015 = max(ex), by(country)
	label var exch_2015 "Nominal exchange rate (local per USD in 2015)"
	drop ex	
	
	/* Save */
	save WB_nominal_exchange_rate, replace
	
	/* Project */
	project, creates("`directory'\Data\WB_nominal_exchange_rate.dta")		
	
/* World Bank GDP deflator data */	
	
	/* Data */
	import delimited using WB_GDP_deflator.txt, delimiter(tab) varnames(1) clear
	
	/* Rename */
	rename countryname country
	label var country "Country"
	rename time year
	label var year "Year"
	rename value deflator
	label var deflator "GDP deflator (USD)"
	
	/* Keep */
	keep country year deflator
	
	/* Country name */
	replace country = "Slovakia" if country == "Slovak Republic"
	
	/* Rebase (to 2015) */
	gen deflator_2015 = deflator if year == 2015
	egen base = max(deflator_2015), by(country)
	replace deflator = deflator/base
	drop deflator_2015 base	
	
	/* Drop missing */
	drop if deflator == .
	
	/* Save */
	save WB_GDP_deflator, replace
	
	/* Project */
	project, creates("`directory'\Data\WB_GDP_deflator.dta")

********************************************************************************
**** (2) Sample restriction	& variable definition							****
********************************************************************************

/* Delete existing outcomes data */
cd "`directory'\Data"
cap rm Outcomes.dta

/* Countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop */
foreach country of local countries {

	/* Project */
	project, uses("`directory'\Amadeus\Data_`country'.dta")

	/* Data */
	cd "`directory'\Amadeus"
	use Data_`country', clear

	/* Sample period (after EUR) */
	keep if year >= 1999 & year <= 2015	
	
	/* Non-missing industry */
	drop if industry == .

	/* BvD ID */
	drop bvd_id
	rename bvd_id_new bvd_id
	egen double id = group(bvd_id)
	
	/* Panel */
	duplicates drop id year, force
	xtset id year
	
	/* Limited liability (cf. BvD legal type document: focus on corporations; most directly affected by thresholds) */
	
		/* Other */
		gen other = 0
		replace other = 1 if ///
			regexm(lower(type), "unlimited") == 1 | ///
			regexm(lower(type), "unltd") == 1 | ///
			regexm(lower(type), "association") == 1 | ///
			regexm(lower(type), "partnership") == 1 | ///
			regexm(lower(type), "proprietorship") == 1 | ///
			regexm(lower(type), "cooperative") == 1
			
		/* Generic */
		gen limited = 1 if ///
			regexm(lower(type), "limited liability company") == 1 | ///
			regexm(lower(type), "limited company") == 1 | ///
			regexm(lower(type), "joint stock") == 1 | ///
			regexm(lower(type), "joint-stock") == 1 | ///
			regexm(lower(type), "share company") == 1 | ///
			regexm(lower(type), "one-person company with limited liability") == 1 | ///
			regexm(lower(type), "company limited by shares") == 1
		replace limited = 0 if limited == . | other == 1
		label var limited "Limited corporations"
		
		/* Country specific (legal forms) */
		replace limited = 1 if ///
			(lower(type) == "gmbh" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "AG" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "(E)BVBA / SPRL(U)" & (country == "Belgium" | country == "Luxembourg")) | ///
			(type == "AS" & country == "Czech Republic") | ///
			(type == "OY" & country == "Finland") | ///			
			(type == "OYJ" & country == "Finland") | ///			
			(type == "EURL" & country == "France") | ///			
			(type == "SARL" & country == "France") | ///			
			(type == "Société en action simple" & country == "France") | ///			
			(type == "SA" & (country == "France" | country == "Greece")) | ///			
			(regexm(type, "GmbH & Co KG") == 1 & country == "Germany") | ///			
			(regexm(type, "Limited liability company & partnership") ==1 & country == "Germany") | ///			
			(regexm(type, "AG & C0 KG") ==1 & country == "Germany") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(regexm(type, "Private") ==1 & country == "Ireland") | ///			
			(regexm(type, "Public") ==1 & country == "Ireland") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(type == "SRL" & country == "Italy") | ///			
			(type == "SPA" & country == "Italy") | ///			
			(regexm(type, "SCARL") == 1 & country == "Italy") | ///			
			(regexm(type, "SCRL") == 1 & country == "Italy") | ///			
			(type == "SA" & country == "Italy") | ///			
			(type == "NV / SA" & country == "Luxembourg") | ///			
			(type == "NV" & country == "Netherlands") | ///			
			(type == "BV" & country == "Netherlands") | ///			
			(type == "AS" & country == "Norway") | ///			
			(type == "ASA" & country == "Norway") | ///			
			(type == "SP. Z O.O." & country == "Poland") | ///			
			(type == "S.A." & country == "Poland") | ///			
			(type == "SA" & country == "Poland") | ///			
			(type == "Sp. z.o.o." & country == "Poland") | ///			
			(type == "S.R.L." & country == "Portugal") | ///			
			(type == "S.R.O." & country == "Slovakia") | ///			
			(type == "d.d." & country == "Slovenia") | ///			
			(type == "d.o.o." & country == "Slovenia") | ///			
			(regexm(type, "Sociedad anonima") == 1 & country == "Spain") | ///			
			(regexm(type, "Sociedad limitada") == 1 & country == "Spain") | ///			
			(regexm(type, "AB") == 1 & country == "Sweden") | ///
			(type == "Private" & country == "United Kingdom") | ///
			(type == "Private Limited" & country == "United Kingdom") | ///
			(regexm(type, "Public") == 1 & country == "United Kingdom")
		
		/* Backfill */
		egen mode = mode(limited), by(id)
		replace limited = mode
		label var limited "Limited liability"
		drop mode type
		keep if limited == 1
		
	/* Entry */
	egen mode = mode(dateinc), by(id)
	gen inc_year = substr(mode, -4, 4)
	destring inc_year, replace force
	gen entry = (inc_year + 2 >= year) if year >= inc_year
	label var entry "Entry (past 2 years)"
	drop mode inc_year dateinc
	
	/* Exit (broad definition: failing, consolidating/merging, stopping production) */
	bys year id (lstatus): replace lstatus = lstatus[_N] if missing(lstatus)
	gen exit = 1 if ///
		regexm(lower(lstatus), "insolvency") == 1 | ///
		regexm(lower(lstatus), "receivership") == 1 | ///
		regexm(lower(lstatus), "liquidation") == 1 | ///
		regexm(lower(lstatus), "dissolved") == 1 | ///
		regexm(lower(lstatus), "inactive") == 1 | ///
		regexm(lower(lstatus), "dormant") == 1 | ///
		regexm(lower(lstatus), "bankruptcy") == 1
	replace exit = 0 if exit == . & lstatus != ""
	label var exit "Exit"
	drop lstatus
	
	/* Quoted/listed */
	bys year id (quoted): replace quoted = quoted[_N] if missing(quoted)
	gen listed = (quoted == "Yes") if quoted != ""
	label var listed "Listed/quoted"
	drop quoted
	
	/* Auditor */
	gen audit = (ad_name != "")
	label var audit "Audit"
	drop ad_name
	
	/* Independence */
	gen indep = 1 if indepind == "A+"
	replace indep = 2 if indepind == "A"
	replace indep = 3 if indepind == "A-"
	replace indep = 4 if indepind == "B+"
	replace indep = 5 if indepind == "B"
	replace indep = 6 if indepind == "B-"
	replace indep = 7 if indepind == "C+"
	replace indep = 8 if indepind == "C"
	replace indep = 9 if indepind == "D"
	replace indep = (9 - indep)/(9 - 1)
	label var indep "Independence (Ownership)"
	drop indepind
	
	/* Shareholders */
	gen shareholders = ln(1+onbr)
	label var shareholders "Shareholders (Log)"
	drop onbr
	
	/* Peer group size */
	gen peers = ln(1+pgsize)
	label var peers "Number of peers (Log; acc. BvD)"
	drop pgsize
	
	/* Exchange rate and inflation adjustment (exchange rate and GDP deflator) */

		/* Currency translation (from account to local currency) */
		
			/* Filling missing */	
			egen firm_mode = mode(currency), by(id)
			egen country_mode = mode(currency), by(country year)
			replace currency = firm_mode if currency == "" | length(currency) > 3
			replace currency = country_mode if currency == "" | length(currency) > 3
			drop firm_mode country_mode
			
			/* Merge: account currency exchange rate */
			cd "`directory'\Data"
			merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch)
			drop if _merge == 2
			drop _merge
			rename currency currency_account
			rename exch exch_account
			replace exch_account = 1 if currency_account == "USD"
			
			/* Merge: local currency exchange rate */
			merge m:1 country year using WB_nominal_exchange_rate
			drop if _merge == 2
			drop _merge

			/* Conversion */
			local variables = "toas opre turn fias ifas ltdb cost mate staf inte av ebta"
			foreach var of varlist `variables' {
			
				/* Convert account currency to USD + USD to local currency */
				replace `var' = `var'/exch_account*exch if currency_account != currency
			}

		/* Deflating (price level as of 2015) */
		
			/* Merge: GDP deflator */
			merge m:1 country year using WB_GDP_deflator
			drop if _merge == 2
			drop _merge
			
			/* Deflating */
			foreach var of varlist `variables' {
			
				/* Deflate nominal variables (in local currency) with country-year specific GDP deflator */
				replace `var' = `var'/deflator
			}		
			
		/* Currency translation (to USD as of 2015) */
		
			/* Translation */
			foreach var of varlist `variables' {
			
				/* Translate real variables (in local currency) to USD */
				replace `var' = `var'/exch_2015
			}	
	
		/* Drop */
		drop exch* deflator currency*
	
	/* Panel (reset) */
	xtset id year
	
	/* Employees */
	replace empl = empl_c if empl == .
	drop empl_c
	
	/* Material costs */
	replace mate = cost if mate == .
	drop cost
	
	/* Total variable cost */
	egen vc = rowtotal(mate staf)
	label var vc "Variable cost"

	/* Output */
	gen sales = turn
	replace sales = opre if turn == .
	label var sales "Sales"
	
	/* Markup */
	gen markup = (sales - vc)/sales
	replace markup = . if markup > 1 | markup < 0
	label var markup "(Y-c)/Y (Markup)"
	
	/* Operating margin */
	gen margin = ebta/sales
	replace margin = . if margin > 1 | margin < 0	
	label var margin "(Y-c)/Y (Operating Margin)"
	
	/* Capital-labor ratio */
	gen cl_e = ln(fias/empl)
	label var cl_e "K/L (Employees)"
	
	gen cl_w = ln(fias/staf)
	label var cl_w "K/L (Wage)"
	
	/* Capital-output ratio */
	gen cy = ln(fias/sales)
	label var cy "K/Y"
		
	/* Productivity */
	
		/* Labor productivity */
		gen lp_e = ln(sales/empl)
		label var lp_e "Y/L (Employees)"
		
		gen lp_w = ln(sales/staf)
		label var lp_w "Y/L (Wage)"
		
		/* Total factor productivity (excl. materials) */
		gen tfp_e = ln(sales) - 0.3*ln(fias) - 0.7*ln(empl)
		label var tfp_e "TFP (Employees)"
		
		gen tfp_w = ln(sales) - 0.3*ln(fias) - 0.7*ln(staf)
		label var tfp_w "TFP (Wage)"
	
********************************************************************************
**** (3) Outcomes (aggregation)												****
********************************************************************************

/* Information environment */
	
	/* Number of firms (control in later specifications) */
	egen firms = count(id), by(industry year)
	replace firms = ln(firms)
	label var firms "Number of firms"
	
	/* Other information environment variables */
	local information = "audit listed"
	foreach var of varlist `information' {
	
		/* Mean */
		egen m_`var' = mean(`var'), by(industry year)
		
		/* Weighted */
		egen double total = total(sales) if `var' ! = ., by(industry year) missing
		egen w_`var' = total(`var'*sales/total), by(industry year) missing
		drop total `var'	
	}

/* Concentration measures */

	/* HHI */
	egen total = total(sales), by(industry year) missing
	egen hhi = total((sales/total)^2), by(industry year) missing
	label var hhi "Concentration (HHI)"
	drop total

/* Productivity and output */

	/* Input and output */
	local measures = "sales empl fias"
	foreach var of varlist `measures' {	
	
		/* Mean */
		gen ln_`var' = ln(`var')
		egen m_`var' = mean(ln_`var'), by(industry year)

	}
	
	/* Productivity, profitability, and markup measures  */
	local measures = "lp_* tfp_* markup margin"
	foreach var of varlist `measures' {
		
		/* Mean */
		egen m_`var' = mean(`var'), by(industry year)
		
		/* Mean (growth) */
		gen d_`var' = d.`var'
		egen dm_`var' = mean(d_`var'), by(industry year)				
		
		/* Weighted */
		egen double total = total(sales) if `var' ! = ., by(industry year) missing
		egen w_`var' = total(`var'*sales/total), by(industry year) missing
				
		/* Weighted (growth) */
		gen dw_`var' = d.w_`var'

		/* Upper and lower tails */
		egen  p20_`var' = pctile(`var'*sales/total), p(20) by(industry year)
		replace p20_`var' = . if p20_`var' == 0
		egen  p80_`var' = pctile(`var'*sales/total), p(80) by(industry year)
		replace p80_`var' = . if p80_`var' == 0
		
		/* Distance between 20-80 percentile */
		gen di_`var' = p80_`var' - p20_`var'
		replace di_`var' = . if di_`var' == 0
			
		/* Standardized range */
		gen sr_`var' = di_`var'/m_`var'
		
		/* Dispersion */
		egen sd_`var' = sd(`var'*sales/total), by(industry year)
		replace sd_`var' = . if sd_`var' == 0
		drop total
		
		/* Coefficient of variation */
		gen cv_`var' = sd_`var'/m_`var'
		
		/* Covariance */
		egen mean = mean(`var') if sales != . & `var' != ., by(industry year)
		egen double total = total(sales) if sales != . & `var' ! = ., by(industry year)
		gen cov = w_`var' - mean
		egen cov_`var' = mode(cov), by(industry year)
		replace cov_`var' = . if cov_`var' == 0
		drop total mean cov `var'
		
	}

/* Other */

	/* Other firm characteristics, entry, exit */
	local characteristics = "entry exit indep shareholders"
	foreach var of varlist `characteristics' {
		/* Mean */
		egen m_`var' = mean(`var'), by(industry year)
		
		/* Weighted */
		egen double total = total(sales) if `var' ! = ., by(industry year) missing
		egen w_`var' = total(`var'*sales/total), by(industry year) missing
		drop total `var'	
	}
	
********************************************************************************
**** (4) Outcome data														****
********************************************************************************

/* Keeping relevant variables */
keep country industry year firms hhi m_* dm_* w_* dw_* p20_* p80_* di_* sr_* sd_* cv_* cov_*

/* Duplicates drop */
duplicates drop industry year, force

/* Labeling */

	/* Information environment */
	label var m_audit "Audit (Mean)"
	label var w_audit "Audit (Weighted)"
	label var m_listed "Listed (Mean)"
	label var w_listed "Listed (Weighted)"	
	
	/* Output */
	label var m_sales "Mean Y (Log)"

	/* Employees */
	label var m_empl "Mean L (Log)"	
	
	/* Fixed assets */
	label var m_fias "Mean K (Log)"	
	
	/* Productivity */
	label var m_lp_e "Y/L (Employees; Mean)"
	label var dm_lp_e "Y/L (Employees; Growth; Mean)"		
	label var w_lp_e "Y/L (Employees; Weighted)"
	label var dw_lp_e "Y/L (Employees; Growth; Weighted)"	
	label var p20_lp_e "Y/L (Employees; p20)"
	label var p80_lp_e "Y/L (Employees; p80)"
	label var di_lp_e "Y/L (Employees; p80-p20)"
	label var sr_lp_e "Y/L (Employees; p80-p20; scaled)"
	label var sd_lp_e "Y/L (Employees; SD)"
	label var cv_lp_e "Y/L (Employees; SD; scaled)"
	label var cov_lp_e "Y/L (Employees; Cov)"	
	
	label var m_lp_w "Y/L (Wage; Mean)"
	label var dm_lp_w "Y/L (Wage; Growth; Mean)"		
	label var w_lp_w "Y/L (Wage; Weighted)"
	label var dw_lp_w "Y/L (Wage; Growth; Weighted)"	
	label var p20_lp_w "Y/L (Wage; p20)"
	label var p80_lp_w "Y/L (Wage; p80)"
	label var di_lp_w "Y/L (Wage; p80-p20)"	
	label var sr_lp_w "Y/L (Wage; p80-p20; scaled)"
	label var sd_lp_w "Y/L (Wage; SD)"
	label var cv_lp_w "Y/L (Wage; SD; scaled)"
	label var cov_lp_w "Y/L (Wage; Cov)"
	
	label var m_tfp_e "TFP (Employees; Mean)"
	label var dm_tfp_e "TFP (Employees; Growth; Mean)"		
	label var w_tfp_e "TFP (Employees; Weighted)"
	label var dw_tfp_e "TFP (Employees; Growth; Weighted)"	
	label var p20_tfp_e "TFP (Employees; p20)"
	label var p80_tfp_e "TFP (Employees; p80)"
	label var di_tfp_e "TFP (Employees; p80-p20)"
	label var sr_tfp_e "TFP (Employees; p80-p20; scaled)"
	label var sd_tfp_e "TFP (Employees; SD)"
	label var cv_tfp_e "TFP (Employees; SD; scaled)"
	label var cov_tfp_e "TFP (Employees; Cov)"	
	
	label var m_tfp_w "TFP (Wage; Mean)"
	label var dm_tfp_w "TFP (Wage; Growth; Mean)"		
	label var w_tfp_w "TFP (Wage; Weighted)"
	label var dw_tfp_w "TFP (Wage; Growth; Weighted)"	
	label var p20_tfp_w "TFP (Wage; p20)"
	label var p80_tfp_w "TFP (Wage; p80)"
	label var di_tfp_w "TFP (Wage; p80-p20)"
	label var sr_tfp_w "TFP (Wage; p80-p20; scaled)"
	label var sd_tfp_w "TFP (Wage; SD)"
	label var cv_tfp_w "TFP (Wage; SD; scaled)"
	label var cov_tfp_w "TFP (Wage; Cov)"	
	
	/* Markup and margin */
	label var m_markup "(Y-c)/Y (Markup; Mean)"
	label var dm_markup "(Y-c)/Y (Markup; Growth; Mean)"		
	label var w_markup "(Y-c)/Y (Markup; Weighted)"
	label var dw_markup "(Y-c)/Y (Markup; Growth; Weighted)"	
	label var p20_markup "(Y-c)/Y (Markup; p20)"
	label var p80_markup "(Y-c)/Y (Markup; p80)"
	label var di_markup "(Y-c)/Y (Markup; p80-p20)"
	label var sr_markup "(Y-c)/Y (Markup; p80-p20; scaled)"
	label var sd_markup "(Y-c)/Y (Markup; SD)"
	label var cv_markup "(Y-c)/Y (Markup; SD; scaled)"
	label var cov_markup "(Y-c)/Y (Markup; Cov)"	
	
	label var m_margin "(Y-c)/Y (Margin; Mean)"
	label var dm_margin "(Y-c)/Y (Margin; Growth; Mean)"		
	label var w_margin "(Y-c)/Y (Margin; Weighted)"
	label var dw_margin "(Y-c)/Y (Margin; Growth; Weighted)"	
	label var p20_margin "(Y-c)/Y (Margin; p20)"
	label var p80_margin "(Y-c)/Y (Margin; p80)"
	label var di_margin "(Y-c)/Y (Margin; p80-p20)"
	label var sr_margin "(Y-c)/Y (Margin; p80-p20; scaled)"
	label var sd_margin "(Y-c)/Y (Margin; SD)"
	label var cv_margin "(Y-c)/Y (Margin; SD; scaled)"
	label var cov_margin "(Y-c)/Y (Margin; Cov)"	
		
	/* Other firm characteristics, entry, exit */
	label var m_indep "Independence (Mean)"
	label var w_indep "Independence (Weighted)"	
	label var m_shareholders "Shareholders (Mean)"
	label var w_shareholders "Shareholders (Weighted)"
	label var m_entry "Entry (Mean)"
	label var w_entry "Entry (Weighted)"
	label var m_exit "Exit (Mean)"
	label var w_exit "Exit (Weighted)"		

/* Append */
cd "`directory'\Data"
cap append using Outcomes

/* Save */
save Outcomes, replace
		
/* End: Country loop */
}

/* Project	*/
project, creates("`directory'\Data\Outcomes.dta")
	

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Construct panel (financial, company, ownership information)	****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // specify location of (raw) STATA files

********************************************************************************
**** (1) Constructing panel data by country	and vintage						****
********************************************************************************

/* Sample countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Year/Vintage loop */
local years = "2005 2008 2012 2016"
	
/* Country loop */
foreach country of local countries {
	
	/* Vintage loop */
	foreach year of local years {
		
		/* Financials */
		
			/* Project */
			cap project, original("`data'\Financials\`country'_Financials_`year'.dta")		
		
			/* Vintages: 2005 and 2008 */
			if "`year'" == "2005" | "`year'" == "2008" {
			
				/* Data */
				cd "`data'\Financials"
				use `country'_Financials_`year', clear

				/* Relevant variables */
				keep accnr idnr consol statda toas empl opre turn fias ifas ltdb cost mate staf av inte ebta
				
				/* Generate year */
				split statda, p(/)
				destring statda*, replace
				replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
				replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
				rename statda3 year
				replace year = year - 1 if statda1 <=6
				label var year "Year"
				drop statda*
				
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Financials_`year', replace
			
			/* End: Vintages 2005 and 2008 */
			}

			/* Vintages: 2012 */
			if "`year'" == "2012" {
			
				/* Data */
				cd "`data'\Financials"
				use `country'_Financials_`year', clear

				/* Relevant variables (including R&D from 2012 on) */
				keep accnr idnr consol statda toas empl opre turn fias ifas ltdb cost mate staf av inte ebta				
				
				/* Generate year */
				split statda, p(/)
				destring statda*, replace
				replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
				replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
				rename statda3 year
				replace year = year - 1 if statda1 <=6
				label var year "Year"
				drop statda*
				
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Financials_`year', replace
			
			/* End: Vintages 2012 */
			}
			
			/* Vintage: 2016 */
			if "`year'" == "2016" {
	
				/* Data */
				cd "`data'\Financials"
				use `country'_Financials_`year', clear

				/* Relevant variables */
				keep idnr unit closdate closdate_year toas empl opre turn fias ifas ltdb cost mate staf inte av ebta
				
				/* Generate year */
				gen closdate_month = month(closdate)
				gen year = closdate_year
				replace year = year - 1 if closdate_month <= 6
				label var year "Year"
				drop closdate*	
	
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Financials_2016, replace
			
			/* End: Vintage 2016 */
			}
			
		/* Company (type, unit, currency) */

			/* Vintages: 2005 and 2008 */
			if "`year'" == "2005" | "`year'" == "2008" {
	
				/* Data */
				cd "`data'\Company"
				use `country'_Company_`year', clear
			
				/* Relevant variables */
				keep accnr type unit currency
				
				/* Destring unit */
				capture {
					destring unit, replace
					rename unit_string unit
				}

				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"
				save `country'_Company_`year', replace
			
			/* End: Vintages 2005 and 2008 */
			}
			
			/* Vintage: 2012 */
			if "`year'" == "2012" {			
	
				/* Data */
				cd "`data'\Company"
				use `country'_Company_`year', clear
			
				/* Relevant variables */
				keep accnr type currency
				
				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"				
				save `country'_Company_`year', replace	
			
			/* End: Vintage 2012 */
			}
			
			/* Vintage: 2016 */
			if "`year'" == "2016" {
			
				/* Data */
				cd "`data'\Company"
				use `country'_Company_`year', clear
			
				/* Relevant variables */
				keep accnr consol idnr type currency

				/* Vintage */
				gen vintage = `year'
				label var vintage "Vintage (BvD Disc)"
					
				/* Country */
				gen country = "`country'"
				replace country = "Czech Republic" if country == "Czech_Republic"
				replace country = "United Kingdom" if country == "United_Kingdom"
				label var country "Country"				
				
				/* Save */
				cd "`directory'\Amadeus"				
				save `country'_Company_`year', replace
		
			/* End: Vintage 2016 */
			}		
		
		/* Combination */

			/* Vintages: 2005 (units: units) */
			if "`year'" == "2005" {
			
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
	
				/* Merge company data */
				merge m:m accnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge
		
				/* Unit conversion */
				local num_list = "toas opre turn fias ifas ltdb cost mate staf av inte ebta"
				foreach var of varlist `num_list' {
					replace `var' = `var'*10^unit
				}
				
				/* Consolidation: avoid duplication (drop duplicates associated with C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				duplicates drop idnr year if dup != 0, force
				drop dup con c2	
					
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge
				
				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
				
				/* Save */
				save `country'_Combined_`year', replace
		
			/* End: Vintages 2005 */
			}
			
			/* Vintage: 2008 (unit: thousands) */
			if "`year'" == "2008" {
			
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
	
				/* Merge company data */
				merge m:m accnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge
		
				/* Unit conversion */
				local num_list = "toas opre turn fias ifas ltdb cost mate staf av inte ebta"
				foreach var of varlist `num_list' {
					replace `var' = `var'*10^3
				}
				
				/* Consolidation: avoid duplication (drop duplicates associated with C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				cap duplicates drop idnr year if dup != 0, force
				drop dup con c2	
					
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge				
				
				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
				
				/* Save */
				save `country'_Combined_`year', replace
		
			/* End: Vintages 2008 */
			}
			
			/* Vintage: 2012 */
			if "`year'" == "2012" {
			
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
			
				/* Merge company data */
				merge m:m accnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge
	
				/* Consolidation: avoid duplication (drop duplicates associated with C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				cap duplicates drop idnr year if dup != 0, force
				drop dup con c2	
					
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge				

				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
				
				/* Save */
				save `country'_Combined_`year', replace
				
			/* End: Vintage 2012 */
			}
			
			/* Vintage: 2016 */
			if "`year'" == "2016" {
	
				/* Data */
				cd "`directory'\Amadeus"				
				use `country'_Financials_`year', clear
			
				/* Merge company data */
				merge m:m idnr using `country'_Company_`year'
				drop if _merge == 2
				drop _merge 

				/* Consolidation: avoid duplication (drop duplicates associated with C1 & C2) */
				duplicates tag idnr year, gen(dup)
				gen con = (consol == "C2")
				egen c2 = max(con), by(idnr)
				drop if dup != 0 & (consol != "C2") & c2 == 1
				sort idnr year dup
				cap duplicates drop idnr year if dup != 0, force
				drop dup con c2	
		
				/* Merge ID & industry (using company panel) */
				rename idnr bvd_id
				merge m:1 bvd_id vintage using Company_`country', keepusing(bvd_id_new industry)
				drop if _merge == 2
				drop _merge
				
				/* Duplicates */
				drop if bvd_id_new == ""
				egen double id = group(bvd_id_new)
				duplicates drop id year, force
				
				/* Panel */
				xtset id year 
				drop id
		
				/* Save */
				save `country'_Combined_`year', replace
		
				/* Delete intermediate */
				rm `country'_Financials_`year'.dta
				rm `country'_Company_`year'.dta
				
			/* End: Vintage 2016 */
			}
	
	/* End: Vintage loop */
	}
			
/* End: Country loop */		
}

********************************************************************************
**** (2) Merging panel data by country										****
********************************************************************************

/* Years (start with latest vintage; after 2016) */
local years = "2012 2008 2005"

/* Country loop */
foreach country of local countries {
	
	/* Data: Vintage 2016 */
	cd "`directory'\Amadeus"				
	use `country'_Combined_2016, clear	
	
	/* Vintage loop */
	foreach year of local years {
			
		/* Merge: update */
		merge 1:1 bvd_id_new year using `country'_Combined_`year', update
		drop _merge
		
		/* Duplicates */
		egen id = group(bvd_id_new)
		duplicates drop id year, force
		drop id	
		
		/* Delete intermediate */
		rm `country'_Combined_`year'.dta
		
	/* End: Vintage loop */
	}
	
	/* Add company panel information */
	rename vintage vintage_disc
	gen vintage = year + 1
	merge m:1 bvd_id_new vintage using Company_`country'
	drop if _merge == 2
	drop _merge vintage
	rename vintage_disc vintage	
	
	/* Compress */
	compress
	
	/* Save */
	save Data_`country', replace
	
	/* Project	*/
	project, creates("`directory'\Amadeus\Data_`country'.dta")
	
/* End: Country loop */		
}

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/11/2017													****
**** Program:	Regulations													****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // insert path to (raw) STATA files

/* Project */
project, original("`directory'\Data\Regulation.csv")
project, original("`directory'\Data\MAD.csv")
project, original("`directory'\Data\IFRS.csv")				
project, uses("`directory'\Data\WB_nominal_exchange_rate.dta")		

********************************************************************************
**** (1) Regulatory thresholds												****
********************************************************************************

/* Data */
import delimited using Regulation.csv, delimiter(",") varnames(1) clear

/* Mode currency */
egen mode = mode(currency_reporting), by(country)
replace currency_reporting = mode if currency_reporting == ""
drop mode

egen mode = mode(currency_audit), by(country)
replace currency_audit = mode if currency_audit == ""
drop mode

/* Cleaning */
keep if year != . & year < 2016

/* Exchange rates */

	/* Reporting threshold currency */
	cd "`directory'\Data"
	rename currency_reporting currency
	merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch_eu)
	drop if _merge==2
	drop _merge
	rename exch_eu exch_reporting
	rename currency currency_reporting

	/* Audit threshold currency */
	rename currency_audit currency
	merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch_eu)
	drop if _merge==2
	drop _merge	
	rename exch_eu exch_audit
	rename currency currency_audit

/* Missing rates (Wikipedia: conversion rates to EUR at official conversion date) */

	/* Italian Lira */
	replace exch_reporting = 1936.27 if currency_reporting == "ITL"
	replace exch_audit = 1936.27 if currency_audit == "ITL"

	/* French Franc */
	replace exch_reporting = 6.55957 if currency_reporting == "FRF"
	replace exch_audit = 6.55957 if currency_audit == "FRF"
	
	/* German mark */
	replace exch_reporting = 1.95583 if currency_reporting == "DEM"
	replace exch_audit = 1.95583 if currency_audit == "DEM"	
	
	/* Finish marka */
	replace exch_reporting = 5.94 if currency_reporting == "FIM"
	replace exch_audit = 5.94 if currency_audit == "FIM"	
	
	/* Greek drachma */
	replace exch_reporting = 340.750 if currency_reporting == "GRD"
	replace exch_audit = 340.750 if currency_audit == "GRD"	
	
	/* Irish pound */
	replace exch_reporting = 0.787564 if currency_reporting == "IEP"
	replace exch_audit = 0.787564 if currency_audit == "IEP"		

	/* Dutch guilder */
	replace exch_reporting = 2.20371 if currency_reporting == "NLG"
	replace exch_audit = 2.20371 if currency_audit == "NLG"	

	/* Portuguese escudo */
	replace exch_reporting = 200.482 if currency_reporting == "PTE"
	replace exch_audit = 200.482 if currency_audit == "PTE"		
	
	/* Spanish peseta */
	replace exch_reporting = 166.386 if currency_reporting == "ESP"
	replace exch_audit = 166.386 if currency_audit == "ESP"		

/* Filling in missing exchange rates (forward) */
egen c = group(country)
duplicates drop c year, force
xtset c year
foreach var of varlist exch_reporting exch_audit {
	forvalues i = 1(1)15 {
		replace `var' = l.`var' if `var' == . & l.`var' != . & year == 1999 + `i'
	}
}

/* Keep relevant variables */
keep ///
	country ///
	year ///
	eu_date ///
	euro_date ///
	directive_4 ///
	directive_7 ///
	at_reporting ///
	sales_reporting ///
	empl_reporting ///
	bs_preparation_abridged ///
	is_preparation_abridged ///
	notes_preparation_abridged ///
	bs_publication ///
	is_publication ///
	notes_publication ///
	at_audit ///
	sales_audit ///
	empl_audit ///
	exch_* ///
	currency_reporting ///
	currency_audit
	
/* Labeling */
label var country "Country"
label var year "Year"
label var eu_date "EU Accession Year"
label var euro_date "EURO Accession Year"
label var directive_4 "4th Directive Implementation Year" 
label var directive_7 "7th Directive Implementation Year"
label var at_reporting "Total Assets Threshold (Reporting Requirements)"
label var sales_reporting "Sales Threshold (Reporting Requirements)"
label var empl_reporting "Employees Threshold (Reporting Requirements)"
label var bs_preparation_abridged "Balance Sheet Preparation (Abridged)"
label var is_preparation_abridged "Income Statement Preparation (Abridged)"
label var notes_preparation_abridged "Notes Preparation (Abridged)"
label var bs_publication "Balance Sheet Publication"
label var is_publication "Income Statement Publication"
label var notes_publication "Notes Publication"
label var at_audit "Total Assets Threshold (Audit Requirements)"
label var sales_audit "Sales Threshold (Audit Requirements)"
label var empl_audit "Employees Threshold (Audit Requirements)"
label var currency_reporting "Currency (Reporting Requirements)"
label var currency_audit "Currency (Audit Requirements)"

/* Save */
save Regulation, replace

********************************************************************************
**** (2) Adding concurrent regulations										****
********************************************************************************

/* MAD */

	/* Data */
	import delimited using MAD.csv, delimiter(",") varnames(1) clear

	/* Save */
	save MAD, replace
	
/* IFRS */

	/* Data */
	import delimited using IFRS.csv, delimiter(",") varnames(1) clear

	/* Save */
	save IFRS, replace

/* Data */
use Regulation, clear
merge m:1 country using MAD
drop if _merge == 2
drop _merge

merge m:1 country using IFRS
drop if _merge == 2
drop _merge

/* Sort */
sort country year

/* Save */
save Regulation, replace

********************************************************************************
**** (3) Thresholds (only)													****
********************************************************************************

/* Keep threshold variables */
keep ///
	country ///
	year ///
	at_reporting ///
	sales_reporting ///
	empl_reporting ///
	bs_preparation_abridged ///
	is_preparation_abridged ///
	notes_preparation_abridged ///
	bs_publication ///
	is_publication ///
	notes_publication ///
	at_audit ///
	sales_audit ///
	empl_audit ///
	exch_reporting ///
	exch_audit ///
	currency_reporting ///
	currency_audit

/* Save */
save Thresholds, replace

/* Project */
project, creates("`directory'\Data\Regulation.dta")	
project, creates("`directory'\Data\Thresholds.dta")	

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/11/2017													****
**** Program:	Scope [Excerpt]												****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Data directory */
local data = "...\IGM-BVD_Amadeus\STATA_Data" // specify path to (raw) STATA files

/* Project */
project, uses("`directory'\Data\WB_nominal_exchange_rate.dta")	
project, uses("`directory'\Data\Regulation.dta")		

********************************************************************************
**** (1) Cross-country data													****
********************************************************************************

/* Delete existing outcomes data */
cd "`directory'\Data"
cap rm Scope_data.dta

/* Countries */
local countries = "Austria Belgium Bulgaria Croatia Czech_Republic Denmark Estonia Finland France Germany Greece Hungary Ireland Italy Lithuania Luxembourg Netherlands Norway Poland Portugal Romania Slovakia Slovenia Spain Sweden United_Kingdom"

/* Country loop */
foreach country of local countries {

	/* Project */
	project, uses("`directory'\Amadeus\Data_`country'.dta")		

	/* Data */
	cd "`directory'\Amadeus"
	use Data_`country', clear

	/* Keep relevant variables & observations */
	keep bvd_id_new toas empl empl_c opre turn year currency type industry country 
	drop if toas == . & empl == . & opre == . & turn == .
	
	/* Total assets */
	rename toas at
	
	/* Sales */
	gen sales = turn
	replace sales = opre if turn == .
	label var sales "Sales"
	drop opre turn
	
	/* Employees */
	replace empl = empl_c if empl == .
	drop empl_c
	
	/* Sample period (after EUR) */
	keep if year >= 1999 & year <= 2015	
	
	/* Non-missing industry */
	drop if industry == .

	/* BvD ID */
	rename bvd_id_new bvd_id
	egen double id = group(bvd_id)
	
	/* Panel */
	duplicates drop id year, force
	xtset id year
	
	/* Limited liability (cf. BvD legal type document: focus on corporations; most directly affected by thresholds) */
	
		/* Other */
		gen other = 0
		replace other = 1 if ///
			regexm(lower(type), "unlimited") == 1 | ///
			regexm(lower(type), "unltd") == 1 | ///
			regexm(lower(type), "association") == 1 | ///
			regexm(lower(type), "partnership") == 1 | ///
			regexm(lower(type), "proprietorship") == 1 | ///
			regexm(lower(type), "cooperative") == 1
			
		/* Generic */
		gen limited = 1 if ///
			regexm(lower(type), "limited liability company") == 1 | ///
			regexm(lower(type), "limited company") == 1 | ///
			regexm(lower(type), "joint stock") == 1 | ///
			regexm(lower(type), "joint-stock") == 1 | ///
			regexm(lower(type), "share company") == 1 | ///
			regexm(lower(type), "one-person company with limited liability") == 1 | ///
			regexm(lower(type), "company limited by shares") == 1
		replace limited = 0 if limited == . | other == 1
		label var limited "Limited corporations"
		
		/* Country specific (legal forms) */
		replace limited = 1 if ///
			(lower(type) == "gmbh" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "AG" & (country == "Austria" | country == "Germany" | country == "Lithuania")) | ///
			(type == "(E)BVBA / SPRL(U)" & (country == "Belgium" | country == "Luxembourg")) | ///
			(type == "AS" & country == "Czech Republic") | ///
			(type == "OY" & country == "Finland") | ///			
			(type == "OYJ" & country == "Finland") | ///			
			(type == "EURL" & country == "France") | ///			
			(type == "SARL" & country == "France") | ///			
			(type == "Société en action simple" & country == "France") | ///			
			(type == "SA" & (country == "France" | country == "Greece")) | ///			
			(regexm(type, "GmbH & Co KG") == 1 & country == "Germany") | ///			
			(regexm(type, "Limited liability company & partnership") ==1 & country == "Germany") | ///			
			(regexm(type, "AG & C0 KG") ==1 & country == "Germany") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(regexm(type, "Private") ==1 & country == "Ireland") | ///			
			(regexm(type, "Public") ==1 & country == "Ireland") | ///			
			(type == "Societe Anonyme" & country == "Greece") | ///			
			(type == "SRL" & country == "Italy") | ///			
			(type == "SPA" & country == "Italy") | ///			
			(regexm(type, "SCARL") == 1 & country == "Italy") | ///			
			(regexm(type, "SCRL") == 1 & country == "Italy") | ///			
			(type == "SA" & country == "Italy") | ///			
			(type == "NV / SA" & country == "Luxembourg") | ///			
			(type == "NV" & country == "Netherlands") | ///			
			(type == "BV" & country == "Netherlands") | ///			
			(type == "AS" & country == "Norway") | ///			
			(type == "ASA" & country == "Norway") | ///			
			(type == "SP. Z O.O." & country == "Poland") | ///			
			(type == "S.A." & country == "Poland") | ///			
			(type == "SA" & country == "Poland") | ///			
			(type == "Sp. z.o.o." & country == "Poland") | ///			
			(type == "S.R.L." & country == "Portugal") | ///			
			(type == "S.R.O." & country == "Slovakia") | ///			
			(type == "d.d." & country == "Slovenia") | ///			
			(type == "d.o.o." & country == "Slovenia") | ///			
			(regexm(type, "Sociedad anonima") == 1 & country == "Spain") | ///			
			(regexm(type, "Sociedad limitada") == 1 & country == "Spain") | ///			
			(regexm(type, "AB") == 1 & country == "Sweden") | ///
			(type == "Private" & country == "United Kingdom") | ///
			(type == "Private Limited" & country == "United Kingdom") | ///
			(regexm(type, "Public") == 1 & country == "United Kingdom")
		
		/* Backfill */
		egen mode = mode(limited), by(id)
		replace limited = mode
		label var limited "Limited liability"
		drop mode type
		keep if limited == 1 
	
	/* Currency translation (to EURO; Lira conversion in "Regulation" also to EURO; scope is free of monetary unit) */
		
		/* Filling missing */	
		egen firm_mode = mode(currency), by(id)
		egen country_mode = mode(currency), by(country year)
		replace currency = firm_mode if currency == "" | length(currency) > 3
		replace currency = country_mode if currency == "" | length(currency) > 3
		drop firm_mode country_mode
			
		/* Merge: account currency exchange rate */
		cd "`directory'\Data"
		merge m:m currency year using WB_nominal_exchange_rate, keepusing(exch_eu)
		drop if _merge == 2
		drop _merge
		rename currency currency_account
		rename exch_eu exch_account
			
		/* Merge: local currency exchange rate */
		merge m:1 country year using WB_nominal_exchange_rate
		drop if _merge == 2
		drop _merge

		/* Conversion */
		local sizes = "at sales"
		foreach var of varlist `sizes' {
			
			/* Convert account currency to EUR + EUR to local currency */
			replace `var' = `var'/exch_account*exch_eu if currency_account != currency
		}
	
	/* Keep relevant variables */
	keep bvd_id country industry year at sales empl 
	
	/* Append */
	cd "`directory'\Data"
	cap append using Scope_data
	 
	/*Save */
	save Scope_data, replace
}

/* Project */
project, creates("`directory'\Data\Scope_data.dta")		

********************************************************************************
**** (2) Thresholds															****
********************************************************************************

/* Data */
use Scope_data, clear

/* Merge: Thresholds */
merge m:1 country year using Thresholds
keep if _merge==3
drop _merge

/* Threshold currency translation */
foreach var of varlist at_reporting sales_reporting {
	replace `var'=`var'/exch_reporting if currency_reporting!="EUR" & currency_reporting!=""
}

foreach var of varlist at_audit sales_audit {
	replace `var'=`var'/exch_audit if currency_audit!="EUR" & currency_audit!=""
}

drop exch_* currency_*

** Reporting Requirements **
egen preparation=rowtotal(bs_preparation_abridged is_preparation_abridged notes_preparation_abridged), missing
replace preparation=3-preparation
label var preparation "Preparation Requirement Strength (Small)"

egen publication=rowtotal(bs_publication is_publication notes_publication), missing
label var publication "Publication Requirement Strength (Small)"

********************************************************************************
**** (3) Measured scope														****
********************************************************************************

/* Reporting scope indicator */
gen regulation = .
label var regulation "Reporting Regulation (Indicator)"

	/* Three thresholds */
	replace regulation = ((at>at_reporting & at!=. & sales>sales_reporting & sales!=.) | (at>at_reporting & at!=. & empl>empl_reporting & empl!=.) | (sales>sales_reporting & sales!=. & empl>empl_reporting & empl!=.)) ///
		if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.)
		
		/* Missing size values */
		replace regulation = (at>at_reporting & at!=.) ///
			if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.) & regulation == . & empl== . & sales== .
			
		replace regulation = (sales>sales_reporting & sales!=.) ///
			if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.) & regulation == . & at== . & empl== .
			
		replace regulation = (empl>empl_reporting & empl!=.) ///
			if (at_reporting!=. & sales_reporting!=. & empl_reporting!=.) & regulation == . & at==. & sales==.		
		
	/* Two thresholds */	
	replace regulation = (at>at_reporting & at!=. & sales>sales_reporting & sales!=.) ///
		if at_reporting != . & sales_reporting != . & empl_reporting == .

		/* Missing size values */
		replace regulation = (at>at_reporting & at!=.) ///
			if (at_reporting != . & sales_reporting != . & empl_reporting == .) & regulation == . & sales== .
			
		replace regulation = (sales>sales_reporting & sales!=.) ///
			if (at_reporting != . & sales_reporting != . & empl_reporting == .) & regulation == . & at== .
			
	replace regulation = (at>at_reporting & at!=. & empl>empl_reporting & empl!=.) ///
		if at_reporting != . & sales_reporting == . & empl_reporting != .					

		/* Missing size values */
		replace regulation = (at>at_reporting & at!=.) ///
			if (at_reporting != . & sales_reporting == . & empl_reporting != .) & regulation == . & empl== .
			
		replace regulation = (empl>empl_reporting & empl!=.) ///
			if (at_reporting != . & sales_reporting == . & empl_reporting != .) & regulation == . & at== .
			
	replace regulation = (sales>sales_reporting & sales!=. & empl>empl_reporting & empl!=.) ///
		if at_reporting == . & sales_reporting != . & empl_reporting != .
		
		/* Missing size values */
		replace regulation = (sales>sales_reporting & sales!=.) ///
			if (at_reporting == . & sales_reporting != . & empl_reporting != .) & regulation == . & empl== .
			
		replace regulation = (empl>empl_reporting & empl!=.) ///
			if (at_reporting == . & sales_reporting != . & empl_reporting != .) & regulation == . & sales== .			
	
	/* One threshold  */
	replace regulation = (at>at_reporting & at!=.) ///
		if (at_reporting != . & sales_reporting == . & empl_reporting == .)	& regulation == .
		
	replace regulation = (sales>sales_reporting & sales!=.) ///
		if (at_reporting == . & sales_reporting != . & empl_reporting == .)	& regulation == .		

	replace regulation = (empl>empl_reporting & empl!=.) ///
		if (at_reporting == . & sales_reporting == . & empl_reporting != .)	& regulation == .

/* Audit scope indicator */
gen audit = .
label var audit "Audit Regulation (Indicator)"

	/* Three thresholds */
	replace audit = ((at>at_audit & at!=. & sales>sales_audit & sales!=.) | (at>at_audit & at!=. & empl>empl_audit & empl!=.) | (sales>sales_audit & sales!=. & empl>empl_audit & empl!=.)) ///
		if (at_audit!=. & sales_audit!=. & empl_audit!=.)
		
		/* Missing size values */
		replace audit = (at>at_audit & at!=.) ///
			if (at_audit!=. & sales_audit!=. & empl_audit!=.) & audit == . & empl== . & sales== .
			
		replace audit = (sales>sales_audit & sales!=.) ///
			if (at_audit!=. & sales_audit!=. & empl_audit!=.) & audit == . & at== . & empl== .
			
		replace audit = (empl>empl_audit & empl!=.) ///
			if (at_audit!=. & sales_audit!=. & empl_audit!=.) & audit == . & at==. & sales==.		
		
	/* Two thresholds */	
	replace audit = (at>at_audit & at!=. & sales>sales_audit & sales!=.) ///
		if at_audit != . & sales_audit != . & empl_audit == .

		/* Missing size values */
		replace audit = (at>at_audit & at!=.) ///
			if (at_audit != . & sales_audit != . & empl_audit == .) & audit == . & sales== .
			
		replace audit = (sales>sales_audit & sales!=.) ///
			if (at_audit != . & sales_audit != . & empl_audit == .) & audit == . & at== .
			
	replace audit = (at>at_audit & at!=. & empl>empl_audit & empl!=.) ///
		if at_audit != . & sales_audit == . & empl_audit != .					

		/* Missing size values */
		replace audit = (at>at_audit & at!=.) ///
			if (at_audit != . & sales_audit == . & empl_audit != .) & audit == . & empl== .
			
		replace audit = (empl>empl_audit & empl!=.) ///
			if (at_audit != . & sales_audit == . & empl_audit != .) & audit == . & at== .
			
	replace audit = (sales>sales_audit & sales!=. & empl>empl_audit & empl!=.) ///
		if at_audit == . & sales_audit != . & empl_audit != .
		
		/* Missing size values */
		replace audit = (sales>sales_audit & sales!=.) ///
			if (at_audit == . & sales_audit != . & empl_audit != .) & audit == . & empl== .
			
		replace audit = (empl>empl_audit & empl!=.) ///
			if (at_audit == . & sales_audit != . & empl_audit != .) & audit == . & sales== .			
	
	/* One threshold  */
	replace audit = (at>at_audit & at!=.) ///
		if (at_audit != . & sales_audit == . & empl_audit == .)	& audit == .
		
	replace audit = (sales>sales_audit & sales!=.) ///
		if (at_audit == . & sales_audit != . & empl_audit == .)	& audit == .		

	replace audit = (empl>empl_audit & empl!=.) ///
		if (at_audit == . & sales_audit == . & empl_audit != .)	& audit == .

/* Country-industry-level scope */
			
	/* Reporting */
	egen scope = mean(regulation), by(country industry year)
	label var scope "Scope (Country-Industry-Year)"
	 
	/* Audit */
	egen audit_scope = mean(audit), by(country industry year)
	label var audit_scope "Audit Scope (Country-Industry-Year)"
		
/* Preserve */
preserve

	/* Duplicates */
	duplicates drop country industry year, force
		
	/* Keep */
	keep country industry year scope audit_scope at_reporting at_* sales_* empl_*
	
	/* Save */
	save Scope, replace
	
/* Restore */
restore

********************************************************************************
**** (4) Simulated scope													****
********************************************************************************

/* Keep full disclosure countries */
keep if bs_publication == 1 & is_publication == 1 
drop bs_* is_* notes_*

/* Drop irrelevant data */
keep industry at empl sales

/* Delete prior Monte Carlo simulation */
capture {
	cd "`directory'\Data\Simulation"
	local datafiles: dir "`directory'\Data\Simulation" files "MC*.dta"
	foreach datafile of local datafiles {
			rm `datafile'
	}
}
	
/* Monte Carlo/Multivariate distribution */

	/* Logarithm (wse +1 adjustment in regulatory thresholds) */
	gen ln_at=ln(at)
	gen ln_sales=ln(sales+1)
	gen ln_empl=ln(empl+1)
 
	/* Draws (multivariate log-normal following Gibrat's Law) [growth rate independent of absolute size; see JEL article in IO] */
	gen n_at = (at != .)
	gen n_sa = (sales != .)
	gen n_em = (empl != .)
	egen count = total(n_at*n_sa*n_em), by(industry) missing
	egen group = group(industry) if count >= 200
	
	/* Loop through industries */
	sum group
	forvalues i=1/`r(max)' {
		
		/* Moments */
		foreach var of varlist at sales empl {
			sum ln_`var' if group==`i'
			local `var'_mean=`r(mean)'
			local `var'_sd=`r(sd)'
				
			foreach var2 of varlist at sales empl {
				corr ln_`var' ln_`var2' if group==`i'
				local `var'_`var2'=`r(rho)'
			}
		}
			
		/* Monte Carlo (use correlations: scale free; alleviates upward bias from missing variables in lower tail) */
		preserve
		
			/* Matrices */
			matrix mean_vector=(`at_mean' \ `sales_mean' \ `empl_mean')
			matrix sd_vector=(`at_sd' \ `sales_sd' \ `empl_sd')
			matrix corr_matrix=(1, `at_sales', `at_empl' \ `sales_at', 1, `sales_empl' \ `empl_at', `empl_sales', 1)
		
			/* MV-normal draw */
			set seed 1234
			drawnorm at sales empl, n(100000) means(mean_vector) sds(sd_vector) corr(corr_matrix) clear
			
			/* Log variables */
			gen y = sales
			gen k = at // approximation of fias
			gen l = empl
			
			/* Exponentiate (including adjustments -1) */
			replace at = exp(at)
			replace sales = exp(sales)-1
			replace empl = exp(empl)-1								
				
			/* Group ID */
			gen group=`i'
			
			/* Saving */
			cd "`directory'\Data\Simulation"
			save MC_industry_`i', replace
			
		restore
	}
	
	/* Save group-industry-correspondence */
	keep if group!=.
	duplicates drop group, force
	keep industry group
	save Correspondence, replace
	
/* Data */	
cd "`directory'\Data"
use Scope, clear

/* Monte Carlo simulation */
				
	/* MC consolidation */
	preserve
		clear all
		cd "`directory'\Data\Simulation"
		! dir MC_industry_*.dta /a-d /b >"`directory'\Data\Simulation\filelist.txt", replace

		file open myfile using "`directory'\Data\Simulation\filelist.txt", read

		file read myfile line
		use `line'
		save MC, replace

		file read myfile line
		while r(eof)==0 { /* while you're not at the end of the file */
			append using `line'
			file read myfile line
		}
		file close myfile
		
		/* Merge Correspondence */
		merge m:1 group using Correspondence
		keep if _merge==3
		drop _merge group
		
		/* Saving */
		save MC, replace
		
	restore

/* Country-industry looping: Monte Carlo */
egen cy_id = group(country year) if at_reporting != . | sales_reporting != . | empl_reporting != . | at_audit != . | sales_audit != . | empl_audit != .
sum cy_id
forvalues i=1/`r(max)' {
	
	/* Reporting */
	sum at_reporting if cy_id==`i'
	cap global at_rep=`r(mean)'
	
	sum sales_reporting if cy_id==`i'
	cap global sa_rep=`r(mean)'
	
	sum empl_reporting if cy_id==`i'
	cap global em_rep=`r(mean)'
	
	/* Audit */
	sum at_audit if cy_id==`i'
	cap global at_au=`r(mean)'
	
	sum sales_audit if cy_id==`i'
	cap global sa_au=`r(mean)'
	
	sum empl_audit if cy_id==`i'
	cap global em_au=`r(mean)'
	
	preserve

		/* MC Sample */
		cd "`directory'\Data\Simulation"
		use MC, clear
			
		/* Thresholds */

			/* Actual */	
				
				/* Reporting */
				gen rep = .
				
					/* Three thresholds */
					cap replace rep = ((at>${at_rep} & sales>${sa_rep}) | (at>${at_rep} & empl>${em_rep}) | (sales>${sa_rep} & empl>${em_rep})) ///
						if ${at_rep} != . & ${sa_rep} != . & ${em_rep} != .

					/* Two thresholds */
					cap replace rep = (at>${at_rep} & sales>${sa_rep}) ///
						if ${at_rep} != . & ${sa_rep} != . & ${em_rep} == .

					cap replace rep = (at>${at_rep} & empl>${em_rep}) ///
						if ${at_rep} != . & ${sa_rep} == . & ${em_rep} != .						

					cap replace rep = (sales>${sa_rep} & empl>${em_rep}) ///
						if ${at_rep} == . & ${sa_rep} != . & ${em_rep} != .	
						
					/* One threshold */
					cap replace rep = (at>${at_rep}) ///
						if ${at_rep} != . & ${sa_rep} == . & ${em_rep} == .					
					
					cap replace rep = (sales>${sa_rep}) ///
						if ${at_rep} == . & ${sa_rep} != . & ${em_rep} == .	

					cap replace rep = (empl>${em_rep}) ///
						if ${at_rep} == . & ${sa_rep} == . & ${em_rep} != .	
						
				/* Auditing */
				gen aud = .
				
					/* Three thresholds */
					cap replace aud = ((at>${at_au} & sales>${sa_au}) | (at>${at_au} & empl>${em_au}) | (sales>${sa_au} & empl>${em_au})) ///
						if ${at_au} != . & ${sa_au} != . & ${em_au} != .

					/* Two thresholds */
					cap replace aud = (at>${at_au} & sales>${sa_au}) ///
						if ${at_au} != . & ${sa_au} != . & ${em_au} == .

					cap replace aud = (at>${at_au} & empl>${em_au}) ///
						if ${at_au} != . & ${sa_au} == . & ${em_au} != .						

					cap replace aud = (sales>${sa_au} & empl>${em_au}) ///
						if ${at_au} == . & ${sa_au} != . & ${em_au} != .	
						
					/* One threshold */
					cap replace aud = (at>${at_au}) ///
						if ${at_au} != . & ${sa_au} == . & ${em_au} == .					
					
					cap replace aud = (sales>${sa_au}) ///
						if ${at_au} == . & ${sa_au} != . & ${em_au} == .	

					cap replace aud = (empl>${em_au}) ///
						if ${at_au} == . & ${sa_au} == . & ${em_au} != .	
			
		/* Aggregation */
				
			/* Reporting */	
			egen mc_scope = mean(rep), by(industry)
			
			/* Audit */
			egen mc_audit = mean(aud), by(industry)

		/* Relevant Observations */
		keep industry mc_*
		duplicates drop industry, force

		/* Identifier */
		gen cy_id = `i'			
			
		/* Saving */
		save MC_final_`i', replace
	
	restore
}

/* Merging */

	/* Monte Carlo (Industry) */
	sum cy_id, d
	forvalues i=1/`r(max)' {
		cd "`directory'\Data\Simulation\"
		merge m:m cy_id industry using MC_final_`i', update
		drop if _merge==2
		drop _merge
	}

********************************************************************************
**** (5) Cleaning, timing, and saving										****
********************************************************************************

/* Duplicates */
keep country industry year scope* audit_scope* joint_scope* mc_*
duplicates drop country industry year, force

/* Time (shifting back 1 year) */
replace year = year + 1

/* Labeling */
label var country "Country"
label var industry "NACE Industry (4-Digit)"
label var year "Year" 
label var mc_scope "Scope (MC)"
label var mc_audit "Audit Scope (MC)"

/* Save */
cd "`directory'\Data"
save Scope, replace

/* Project */
project, creates("`directory'\Data\Scope.dta")


********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Database construction												****
********************************************************************************

/* Constructing company data */
project, do(Dofiles/Companies.do)

/* Constructing panel data (financials + company) */
project, do(Dofiles/Panel.do)

/* Constructing outcomes */
project, do(Dofiles/Outcomes.do)

/* Constructing regulatory threshold data */
project, do(Dofiles/Regulation.do)

/* Constructing scope measure */
project, do(Dofiles/Scope.do)


********************************************************************************
**** (3) Analyses															****
********************************************************************************

/* Constructing sample */
project, do(Dofiles/Data.do)

/* Running analyses */
project, do(Dofiles/Analyses.do)

/* Generating graphs */
project, do(Dofiles/Graphs.do)


********************************************************************************
**** (4) Identifiers [JAR Code & Data Policy]								****
********************************************************************************

/* Generating graphs */
project, do(Dofiles/Identifiers.do)

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Setup of "project" program									****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Master directory ****
local master = "...\Project_Europe\Programs" // please insert/adjust directory path

********************************************************************************
**** (0) Install external program ("project")								****
********************************************************************************

**** Install ****
ssc install project

********************************************************************************
**** (1) Setup and building project: Local									****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Europe.do")

**** Build ****
cap noisily project Master_Europe, build

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Coverage (outcome) part calculated based on AMA	[Excerpt]	****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Amadeus"

**** Project ****
project, uses("`directory'\Amadeus\AMA_data.dta")

********************************************************************************
**** (1) Number of firms													****
********************************************************************************

/* Data */
use AMA_data, clear

/* Specify: level of industry (2-digit) */
rename industry industry_4
gen industry = floor(industry_4/100)
label var industry "Industry (2-Digit NACE/WZ)"

/* Restrict: limited liability firms */
keep if limited == 1
				
/* Balance sheet disclosure */
gen disclosure = (at != .)
label var disclosure "Disclosure (TA available from limited firms)"
				
/* Number of firms */
egen double no_firms = total(disclosure), by(county industry year)
label var no_firms "Number of disclosing (limited) firms"

********************************************************************************
**** (2) Cleaning, labeling, and saving										****
********************************************************************************

/* Keep relevant variables */
keep industry county year no_firms

/* Lag coverage/scope variables (t-2) */
replace year = year+2

/* Save */
cd "`directory'\Data"
save AMA_coverage, replace

/* Prior Stata Version for Destatis */
saveold AMA_coverage_2013, replace

/* Project */
project, creates("`directory'\Amadeus\AMA_coverage.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Amadeus dataset creation [Excerpt]							****
********************************************************************************
**** Note:		Executed on local computer to create AMA dataset to be 		****
****			transferred to and used by Statistisches Bundesamt (on-site)****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Amadeus"

**** Project ****
project, original("`directory'\Amadeus\germany_Financials_2005.dta")
project, original("`directory'\Amadeus\germany_Financials_2008.dta")
project, original("`directory'\Amadeus\germany_Financials_2012.dta")
project, original("`directory'\Amadeus\germany_Financials_2016.dta")
project, original("`directory'\Amadeus\germany_Company_2005.dta")
project, original("`directory'\Amadeus\germany_Company_2008.dta")
project, original("`directory'\Amadeus\germany_Company_2012.dta")
project, original("`directory'\Amadeus\germany_Company_2016.dta")
project, uses("`directory'\Amadeus\AMA_panel.dta")
project, uses("`directory'\Amadeus\AMA_panel_unique.dta")

********************************************************************************
**** (1) Creating unified datasets by vintage								****
********************************************************************************

/* Financials */

	/* Vintage: 2005 */
	
		/* Data */
		use germany_Financials_2005, clear
		
		/* Relevant variables */
		keep accnr idnr consol statda toas empl opre turn
		
		/* Generate year */
		split statda, p(/)
		destring statda*, replace
		replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
		replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
		rename statda3 year
		replace year = year - 1 if statda1 <=6
		drop statda*
		
		/* Save */
		save Financials_2005, replace

	/* Vintage: 2008 */
	
		/* Data */
		use germany_Financials_2008, clear
		
		/* Relevant variables */
		keep accnr idnr consol statda toas empl opre turn
		
		/* Generate year */
		split statda, p(/)
		destring statda*, replace
		replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
		replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
		rename statda3 year
		replace year = year - 1 if statda1 <=6
		drop statda*
		
		/* Save */
		save Financials_2008, replace	
	
	/* Vintage: 2012 */
	
		/* Data */
		use germany_Financials_2012, clear
		
		/* Relevant variables */
		keep accnr idnr consol statda toas empl opre turn
		
		/* Generate year */
		split statda, p(/)
		destring statda*, replace
		replace statda3 = statda1 if statda2 ==. & statda3 ==. & statda1 >= 1990 & statda1 !=.
		replace statda3 = statda2 if statda1 ==. & statda3 ==. & statda2 >= 1990 & statda2 !=.
		rename statda3 year
		replace year = year - 1 if statda1 <=6
		drop statda*
		
		/* Save */
		save Financials_2012, replace		
	
	/* Vintage: 2016 */

		/* Data */
		use germany_Financials_2016, clear
		
		/* Relevant variables */
		keep idnr unit closdate closdate_year toas empl opre turn
		
		/* Generate year */
		gen closdate_month = month(closdate)
		gen year = closdate_year
		replace year = year - 1 if closdate_month <= 6
		drop closdate*	
		
		/* Save */
		save Financials_2016, replace
	
/* Company (Type, unit, sales, and employees data) */

	/* Vintage: 2005 */
	
		/* Data */
		use germany_Company_2005, clear
	
		/* Relevant variables */
		keep accnr type unit 
		
		/* Save */
		save Company_2005, replace
		
	/* Vintage: 2008 */
	
		/* Data */
		use germany_Company_2008, clear
	
		/* Relevant variables */
		keep accnr type unit 
		
		/* Destring unit */
		destring unit_string, gen(unit)
		drop unit_string
		
		/* Save */
		save Company_2008, replace
	
	/* Vintage: 2012 */
	
		/* Data */
		use germany_Company_2012, clear
	
		/* Relevant variables */ /* missing: unit! */
		keep accnr type
		
		/* Save */
		save Company_2012, replace	
	
	/* Vintage: 2016 */

		/* Data */
		use germany_Company_2016, clear
	
		/* Relevant variables */
		keep accnr idnr type consol
		
		/* Save */
		save Company_2016, replace
		
/* Combination */

	/* Vintage: 2005 */
	
		/* Data */
		use Financials_2005, clear
	
		/* Merge company data */
		merge m:m accnr using Company_2005
		drop if _merge == 2
		drop _merge
		
		/* Unit conversion */
		local num_list = "toas"
		foreach var of varlist `num_list' {
			replace `var' = `var'*10^unit
		}

		/* Save */
		save Combined_2005, replace
		
	/* Vintage: 2008 (units: thousands) */
	
		/* Data */
		use Financials_2008, clear
	
		/* Merge company data */
		merge m:m accnr using Company_2008
		drop if _merge == 2
		drop _merge
		
		/* Unit conversion */
		local num_list = "toas"
		foreach var of varlist `num_list' {
			replace `var' = `var'*10^3 // in thousands
		}

		/* Save */
		save Combined_2008, replace
		
	/* Vintage: 2012 */
	
		/* Data */
		use Financials_2012, clear
	
		/* Merge company data */
		merge m:m accnr using Company_2012
		drop if _merge == 2
		drop _merge
		
		/* Save */
		save Combined_2012, replace

	/* Vintage: 2016 */
	
		/* Data */
		use Financials_2016, clear
	
		/* Merge company data */
		merge m:m idnr using Company_2016
		drop if _merge == 2
		drop _merge

		/* Save */
		save Combined_2016, replace
		
	/* Combined vintages (2005, 2008, 2012, and 2016) */
	
		/* Data */
		use Combined_2005, clear
		
		/* Update until 2008 */
		merge m:m accnr year using Combined_2008, update
		drop _merge
		
		/* Update until 2012 */
		merge m:m accnr year using Combined_2012, update
		drop _merge
		
		/* Update until 2016 */
		merge m:m accnr year using Combined_2016, update
		drop _merge

		/* Duplicates */
		egen double id = group(accnr)
		duplicates drop id year, force
		xtset id year
	
		/* Consolidation: avoid duplication (drop duplicates associated with C2) */
		rename idnr bvd_id	
		duplicates tag bvd_id year, gen(dup)
		gen con = (consol == "C2")
		egen c2 = max(con), by(bvd_id)
		drop if dup != 0 & (consol != "C2") & c2 == 1
		sort bvd_id year dup
		duplicates drop bvd_id year if dup != 0, force
		drop dup
		
		/* Sample period */
		keep if year >= 2000 & year <= 2014
		
		/* County & industry definitions */
			
			/* Define time dimension: vintage */
			gen vintage = year
			
			/* Merge company panel (bvd_id vintage: 2005-2014)*/
			merge 1:1 bvd_id vintage using AMA_panel, keepusing(industry ags)
			drop if _merge == 2
			drop _merge
			
			/* Apply earliest vintage to previous years (2000-2004) */
			drop id
			egen double id = group(bvd_id)
			xtset id year
			forvalues y = 1(1)6 {
				foreach var of varlist industry ags {
					replace `var' = f.`var' if `var' == . & f.`var' != . & vintage == 2008-`y'
				}
			}
			
			/* Merge company panel (bvd_id; update) */
			merge m:1 bvd_id using AMA_panel_unique, keepusing(industry ags) update
			drop if _merge == 2
			drop _merge
			
			/* Drop missing observations */
			drop if industry == . | ags ==.
			
			/* County identifier */
			tostring ags, gen(ags_string)
			gen county = substr(ags_string, -6, 3)
			egen county_id = group(county)
			drop ags_string

********************************************************************************
**** (2) (Re)Defining variables												****
********************************************************************************

/* Limited liability indicator */
gen limited = 0
replace limited = 1 if ///
	regexm(type, "AG") == 1 | ///
	regexm(type, "limited liability") == 1 | ///
	regexm(type, "European company") == 1 | ///
	regexm(type, "GmbH") == 1 | ///
	regexm(type, "Public limited") == 1

/* Total assets */
rename toas at

********************************************************************************
**** (3) Cleaning, labeling, and saving										****
********************************************************************************

/* Duplicates drop */
sort id year
duplicates drop id year, force

/* Keep relevant variables */
keep bvd_id year industry ags county county_id at sales empl limited
 
/* Labels */
label var bvd_id "BvD ID"
label var year "Fiscal Year"
label var industry "NACE 2 (WZ 2008)"
label var ags "AGS (BBSR, Destatis; manual)"
label var county "County (String)"
label var county_id "County ID (Numeric)"
label var at "Total Assets"
label var limited "Limited liability"

/* Save (final AMA data) */
save AMA_data, replace

/* Delete individual datasets */
forvalues y = 2005(1)2016 {
	capture {
		rm Company_`y'.dta
		rm Financials_`y'.dta
		rm Combined_`y'.dta
	}
}

/* Project */
project, creates("`directory'\Amadeus\AMA_data.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/23/2017													****
**** Program:	Amadeus ID and city panel [Excerpt]							****
********************************************************************************
**** Note:		Executed on local computer to create AMA dataset to be 		****
****			transferred to and used by Statistisches Bundesamt (on-site)****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Amadeus"

**** Project ****
forvalues year = 2005(1)2016 {
	project, original("`directory'\Amadeus\germany_Company_`year'.dta")
}
project, original("`directory'\Amadeus\correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format.dta")
project, original("`directory'\Amadeus\Counties.csv")

********************************************************************************
**** (1) Creating unified datasets by vintage								****
********************************************************************************

forvalues year = 2005(1)2016 {

	/* Data */
	use germany_Company_`year', clear
	
	/* Rename */
	cap rename company company_name
	cap rename name company_name
	cap rename zip zipcode
	cap rename bvd_id_number bvd_id
	cap rename idnr bvd_id
	cap rename nacpri nace_ind
	cap rename nac2pri nace2_ind
	cap rename nacerev2primarycode nace2_ind
	cap rename nace_prim_code nace2_ind
	
	/* Keep relevant data */
	cap keep bvd_id company_name city zipcode nace_ind
	cap keep bvd_id company_name city zipcode nace2_ind
	
	/* Industry */
	cap destring nace_ind, replace
	cap destring nace2_ind, replace
	
	/* Vintage */
	gen vintage = `year'
	
	/* Append */
	if `year' == 2005 {
		
		/* Save panel */
		cap rm AMA_panel.dta
		save AMA_panel, replace
	}
	
	if `year' > 2005 {
		
		/* Append */
		append using AMA_panel
		
		/* Save panel */
		save AMA_panel, replace	
	}
}

/* ID */
drop if bvd_id == "" | substr(bvd_id, 1, 2) != "DE"
egen double id = group(bvd_id)

/* Duplicates (tag) */
duplicates tag id vintage, gen(dup)

/* Drop: missing location or industry if duplicate */
drop if dup > 0 & (city == "" | (nace_ind == . & nace2_ind == .))
drop dup

/* Duplicates (drop) */
sort id vintage
duplicates drop id vintage, force

/* Panel */
xtset id vintage

/* Save */
save AMA_panel, replace

********************************************************************************
**** (2) Creating industry and location correspondence tables				****
********************************************************************************

/* Industry (NACE) correspondence (Sebnem et al. (2015)) */

	/* Correspondence table */
	use correspondence_NACE_rev1_1_to_UNIQUErev2_stata9format, clear

	/* Keep relevant variables */
	keep nacerev11 nacerev2 descriptionrev2
	
	/* Destring code */
	destring nacerev11 nacerev2, ignore(".") replace force
	
	/* Keep if non-missing */
	keep if nacerev11 != . & nacerev2 != .
	
	/* Rename */
	rename nacerev11 nace_ind
	rename nacerev2 nace2_ind_corr
	
	/* Save */
	save NACE_correspondence, replace
	
	/* Project */
	project, creates("`directory'\Amadeus\NACE_correspondence.dta")

/* AGS correspondence (BBSR; Destatis; manual) */

	/* Import (.csv data from Excel match) */
	import delimited using Counties.csv, delimiter(",") varnames(1) clear
	
	/* Keep relevant variables */
	keep city zipcode match_name agsall
	
	/* Rename */
	rename agsall ags
	rename match_name city_1
	
	/* Save */
	save AGS_correspondence, replace
	
	/* Duplicates */
	sort city_1
	duplicates drop city_1, force
	
	/* Save */
	save AGS_correspondence_1, replace

	/* Project */
	project, creates("`directory'\Amadeus\AGS_correspondence.dta")
	project, creates("`directory'\Amadeus\AGS_correspondence_1.dta")
	
********************************************************************************
**** (3) Converging industry and location definitions						****
********************************************************************************

/* Data */
use AMA_panel, clear

/* Merge: Industry correspondence */
merge m:1 nace_ind using NACE_correspondence
drop if _merge ==2
drop _merge

/* Drop NACE description */
drop description*

/* Generate converged industry */
gen industry = nace2_ind

/* Backfilling (using panel information) */
xtset id vintage
forvalues y = 1(1)11 {
	replace industry = f.industry if industry == . & f.industry != . & vintage == 2016 - `y'
}

/* Filling in missing values (using correspondence table) */
replace industry = nace2_ind_corr if industry == .
drop nace*

/* Mode: Filling in missing values (using mode of industry code per firm) */
egen industry_mode = mode(industry), by(id)
replace industry = industry_mode if industry == .
drop industry_mode

/* Destring zipcode */
destring zipcode, replace force

/* Merge (1): Location correspondence (exact match) */
merge m:1 city zipcode using AGS_correspondence, keepusing(ags)
drop if _merge == 2
drop _merge

/* Merge (2): Location correspondence (name (city) match) */
merge m:1 city using AGS_correspondence, keepusing(ags) update
drop if _merge == 2
drop _merge

/* Merge (3): Location correspondence (name (city_1) match) */
rename city city_1
merge m:1 city_1 using AGS_correspondence_1, keepusing(ags) update
drop if _merge == 2
drop _merge
rename city_1 city

/* Destring AGS */
destring ags, replace force

/* Backfilling (using panel information: backward and forward) */
sort id vintage
duplicates drop id vintage, force
xtset id vintage
forvalues y = 1(1)11 {
	replace ags = f.ags if ags == . & f.ags != . & vintage == 2016 - `y'
}

forvalues y = 1(1)11 {
	replace ags = l.ags if ags == . & l.ags != . & vintage == 2005 + `y'
}

/* Mode: Filling in missing (using AGS by city and vintage) */
egen ags_mode = mode(ags), by(city vintage)
replace ags = ags_mode if ags_mode != .
drop ags_mode

********************************************************************************
**** (4) Cleaning, labeling, and saving										****
********************************************************************************

/* Keep relevant variables */
keep id bvd_id vintage industry ags

/* Keep observations with non-missing industry and location information */
drop if industry == . | ags == .

/* Label variables */
label var id "ID (Numeric)"
label var bvd_id "BvD ID (String)"
label var vintage "Vintage (Year of BvD disc)"
label var industry "NACE 2 (WZ 2008)"
label var ags "AGS (Location identifier)"

/* Save */
save AMA_panel, replace

********************************************************************************
**** (5) Unique																****
********************************************************************************

/* Duplicates drop */
sort bvd_id vintage
duplicates drop bvd_id, force

/* Save */
save AMA_panel_unique, replace

/* Project */
project, creates("`directory'\Amadeus\AMA_panel.dta")
project, creates("`directory'\Amadeus\AMA_panel_unique.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Analysis on county, industry, year level (AMA, URS, GWS)	****
****			[Excerpt]													****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: Data.dta
	Variables:
		- county			County (Kreis)
		- state				State (Bundesland)
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- sales 			Sales (Estimated taxable sales)
		- empl				Employees (1+Employees)
		- hhi				Herfindahl-Hirschman Index (Concentration)
		- entry_main		Entry (Log count; Main business)
		- entry_sub			Entry (Log count; Subsidiary)
		- exit_main			Exit (Log count; Main business)
		- exit_close 		Exit (Log count; Insolvency) 
		- coverage 			Coverage (Actual) (ratio of number of firms in AMA over number of firms in URS in same county-industry-year)
		- limited_share 	Share of limited firms among all firms (limited + unlimited; pre-period)
		- s_firms			Median split (number of firms, pre-period)
		- county_id 		County ID (numeric)
		- ci 				County-Industry ID (numeric)
		- cy 				County-Year ID (numeric)	
		- state_id 			State ID (numeric)
		- si 				State-Industry ID (numeric)
		- sy 				State-Year ID (numeric)
		- iy 				Industry-Year ID (numeric)	
		- post				Post (indicator taking value of 1 for years after 2007)
		- y_2003			Year 2003
		- y_2004			Year 2004
		- y_2005			Year 2005
		- y_2006			Year 2006
		- y_2007			Year 2007
		- y_2008			Year 2008
		- y_2009			Year 2009
		- y_2010			Year 2010
		- y_2011			Year 2011
		- y_2012			Year 2012		
		- trend				Linear time trend
	
Comment:
This program runs multivariate analyses using county-industry-year observations.
*/

**** Preliminaries ****
version 15.1
clear all
set more off
set varabbrev off

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, uses("`directory'\Data\Data.dta")

********************************************************************************
**** (1) Preparing data														****
********************************************************************************

/* Data (URS) */ 
use Data, clear

/* Duplicates drop */
duplicates drop county industry year, force

/* Sample period */
keep if year >= 2003 & year <= 2012

/* Panel */
xtset ci year
	
********************************************************************************
**** (2) Regressions: County-industry-year analyses							****
********************************************************************************

/* Panel: county-industry year */
xtset ci year

/* Log file: open */
cd "`directory'\Output\Logs"
log using Enforcement.smcl, replace smcl name(Enforcement) 

/* Regression inputs (treatment: lagged by two years (see AMA_coverage.do)) */
local DepVar = "coverage entry_main exit_main hhi"
local IndVar = "limited_share"

/* OLS Regression: county-industry + county-year + industry-year fixed effects with instrument */
foreach x of varlist `IndVar' {
	foreach y of varlist `DepVar' {

		/* Preserve */
		preserve
					
			/* Capture */
			capture noisily {
			
				/* Truncation */
				
					/* Outcome */
					qui reghdfe `y' if `x' != ., a(ci cy iy) residuals(res_`y')

					/* Treatment */
					qui reghdfe `x' if `y' != ., a(ci cy iy) residuals(res_`x')
					
					/* Replace */
					qui sum res_`y', d
					qui replace `y' = . if res_`y' > r(p99) | res_`y' < r(p1)
					
					qui sum res_`x', d
					qui replace `x' = . if res_`x' > r(p99) | res_`x' < r(p1)					
						
				/* Estimation */
				qui reghdfe `y' `x' c.`x'#1.y_2003 c.`x'#1.y_2004 c.`x'#1.y_2005 c.`x'#1.y_2007 c.`x'#1.y_2008 c.`x'#1.y_2009 c.`x'#1.y_2010 c.`x'#1.y_2011 c.`x'#1.y_2012, a(ci cy iy) cluster(county_id)
				
				/* Output */
				estout, keep(1.y_2003#c.`x' 1.y_2004#c.`x' 1.y_2005#c.`x' 1.y_2007#c.`x' 1.y_2008#c.`x' 1.y_2009#c.`x' 1.y_2010#c.`x' 1.y_2011#c.`x' 1.y_2012#c.`x') cells(b(star fmt(3)) t(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
					legend label title("SPECIFICATION: COUNTY-INDUSTRY, COUNTY-YEAR, INDUSTRY-YEAR FE WITH INSTRUMENT (Base: 2006; OLS)") ///
					mlabels(, depvars) varwidth(40) modelwidth(45) unstack ///
					stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "# Clusters" "Adjusted R-Squared"))
					
				/* Joint test */
				qui test (1.y_2003#c.`x'+1.y_2004#c.`x'+1.y_2005#c.`x')=(1.y_2007#c.`x'+1.y_2008#c.`x'+1.y_2009#c.`x'+1.y_2010#c.`x'+1.y_2011#c.`x'+1.y_2012#c.`x')
				di "Joint F-test (pre- vs. post-period): F " round(`r(F)', 0.01) ", p " round(`r(p)', 0.001)	
			}
						
		/* Restore */
		restore	
	}
}

********************************************************************************
**** (3) Cross-Section: County-industry-year analyses						****
********************************************************************************

/* Regression inputs */
local DepVar = "entry_sub exit_close hhi"
local IndVar = "limited_share"
local SplVar = "s_firms"

/* Split */
foreach s of varlist `SplVar' { 

	/* Generate split variable */
	egen median = median(`s')	
				
	/* Regression: county-industry + county-year + industry-year fixed effects */
	foreach x of varlist `IndVar' {
		foreach y of varlist `DepVar' {
			
			/* Preserve */
			preserve

				/* Capture */
				capture noisily {
				
					/* Truncation */
					
						/* Outcome */
						qui reghdfe `y' if `x' != ., a(ci cy iy) residuals(res_`y')

						/* Treatment */
						qui reghdfe `x' if `y' != ., a(ci cy iy) residuals(res_`x')
						
						/* Replace */
						qui sum res_`y', d
						qui replace `y' = . if res_`y' > r(p99) | res_`y' < r(p1)
						
						qui sum res_`x', d
						qui replace `x' = . if res_`x' > r(p99) | res_`x' < r(p1)					
							
					/* Estimation */
					qui reghdfe `y' `x' c.`x'#1.y_2003 c.`x'#1.y_2004 c.`x'#1.y_2005 c.`x'#1.y_2007 c.`x'#1.y_2008 c.`x'#1.y_2009 c.`x'#1.y_2010 c.`x'#1.y_2011 c.`x'#1.y_2012 if `s' >= median & `s' != ., a(ci cy iy) cluster(county_id)
						est store M1
						
					qui reghdfe `y' `x' c.`x'#1.y_2003 c.`x'#1.y_2004 c.`x'#1.y_2005 c.`x'#1.y_2007 c.`x'#1.y_2008 c.`x'#1.y_2009 c.`x'#1.y_2010 c.`x'#1.y_2011 c.`x'#1.y_2012 if `s' < median & `s' != ., a(ci cy iy) cluster(county_id)
						est store M2
						
					/* Output */
					estout M1 M2, keep(1.y_2003#c.`x' 1.y_2004#c.`x' 1.y_2005#c.`x' 1.y_2007#c.`x' 1.y_2008#c.`x' 1.y_2009#c.`x' 1.y_2010#c.`x' 1.y_2011#c.`x' 1.y_2012#c.`x') cells(b(star fmt(3)) t(par fmt(2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label title("SPECIFICATION: COUNTY-INDUSTRY, COUNTY-YEAR, INDUSTRY-YEAR FE WITH INSTRUMENT (Base: 2006)" "SPLIT: `s'") ///
						mgroups("High" "Low", pattern(0 1)) mlabels(, depvars) varwidth(40) modelwidth(22) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "# Clusters" "Adjusted R-Squared"))						
			}
						
			/* Restore */
			restore				
		}
	}
	
	/* Drop */
	drop median
	
}

/* Log file: close */
log close Enforcement

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Combining outcome (URS, GWS) and coverage (AMA) data 		****
****			[Excerpt]													****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: URS_outcome.dta
	Variables:
		- county			County (Kreis)
		- state				State (Bundesland)
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- sales 			Sales (Estimated taxable sales)
		- empl				Employees (1+Employees)
		- limited_fraction 	Fraction of limited firms in all firms
		- no_firms_URS 		Number of firms (URS)
		- hhi				Herfindahl-Hirschman Index (Concentration)
		
	Data file: GWS_outcome.dta
	Variables:
		- county			County (Kreis)
		- state				State (Bundesland)
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- entry_main 		Entry (Log count; Main business)
		- entry_sub			Entry (Log count; Subsidiary)
		- exit_main			Exit (Log count; Main business)
		- exit_close 		Exit (Log count; Insolvency) 
		
	Data file: AMA_coverage.dta
	Variables:
		- county			County (Kreis)
		- industry			Industry (2-Digit NACE/WZ 2008)
		- year				Fiscal Year
		- no_firms			Number of firms with non-missing total assets in Bureau van Dijk's Amadeus (AMA) database 
		
Newly created variables (kept):
		- coverage 			Coverage (Actual) (ratio of number of firms in AMA over number of firms in URS in same county-industry-year)
		- limited_share 	Share of limited firms among all firms (limited + unlimited; pre-period)
		- county_id 		County ID (numeric)
		- ci 				County-Industry ID (numeric)
		- cy 				County-Year ID (numeric)	
		- state_id 			State ID (numeric)
		- si 				State-Industry ID (numeric)
		- sy 				State-Year ID (numeric)
		- iy 				Industry-Year ID (numeric)	
		- post				Post (indicator taking value of 1 for years after 2007)	
		- y_2003			Year 2003
		- y_2004			Year 2004
		- y_2005			Year 2005
		- y_2006			Year 2006
		- y_2007			Year 2007
		- y_2008			Year 2008
		- y_2009			Year 2009
		- y_2010			Year 2010
		- y_2011			Year 2011
		- y_2012			Year 2012

Note:
		- suffix: lim		Uses limited liability firms only
		- suffix: unl		Uses unlimited liability firms only	
	
Comment:
This program merges the county-industry-year level outcomes (from URS and GWS) with the corresponding first-stage outcome (from AMA).
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, uses("`directory'\Data\URS_outcomes.dta")
project, uses("`directory'\Data\GWS_outcomes.dta")
project, original("`directory'\Data\AMA_coverage.dta") // not recreated at Destatis

********************************************************************************
**** (1) Combining datasets (AMA, URS, GWS)									****
********************************************************************************

/* Data (URS) */
use URS_outcomes, clear

/* Merge: GWS outcomes */
merge 1:1 county industry year using GWS_outcomes
drop _merge

/* Merge: AMA coverage */
merge 1:1 county industry year using AMA_coverage, keepusing(no_firms)
keep if _merge == 3
drop _merge

********************************************************************************
**** (2) Generating relevant variables										****
********************************************************************************
		
/* Coverage measures */

	/* Actual coverage */
	gen coverage = min(no_firms/no_firms_URS, 1) if no_firms != . & no_firms_URS != .
	replace coverage = 0 if no_firms == . & no_firms_URS != .
	label var coverage "Coverage (Actual)"

/* Treatment (limited share) */

	/* Limited vs. unlimited firms */
	gen pre = limited_fraction if year == 2006
	egen limited_share = mean(pre), by(county industry)
	label var limited_share "Share of limited firms among all firms (limited + unlimited; pre-period)"
	drop pre
		
/* Identifiers */

	/* Drop missing county, industry, year */
	drop if county == "" | industry == . | year == .
	
	/* County */
	egen county_id = group(county)
	label var county_id "County ID"

	/* Country-industry */
	egen ci = group(county industry)
	label var ci "County-Industry ID"
	
	/* County-year */
	egen cy = group(county year)
	label var cy "County-Year ID"	

	/* State */
	egen state_id = group(state)
	label var state_id "State ID"
	
	/* State-industry */
	egen si = group(state industry)
	label var si "State-Industry ID"
	
	/* State-year */
	egen sy = group(state year)
	label var sy "State-Year ID"
	
	/* Industry-year */
	egen iy = group(industry year)
	label var iy "Industry-Year ID"	
	
	/* Individual years */
	forvalues y = 2003(1)2012 {
		gen y_`y' = (year == `y')
		label var y_`y' "`y'"
	}

	/* Trend */
	gen trend = (year - 2003)
	label var trend "Trend"

********************************************************************************
**** (3) Saving combined dataset											****
********************************************************************************

/* Save */
save Data, replace

/* Project */
project, creates("`directory'\Data\Data.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Installs external (user-written) programs					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

********************************************************************************
**** (1) Install external programs											****
********************************************************************************

**** Estout ****
ssc install estout, replace

**** Coefplot ****
ssc install coefplot, replace

**** Outreg2 ****
ssc install outreg2, replace

**** Reghdfe ****
ssc install reghdfe, replace

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Graphs [hard-coded; created based on FDZ regression output]	****													
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set varabbrev off

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Output\Figures"

/* Observations */
set obs 10

/* Years */
gen year = 2002 + _n

********************************************************************************
**** Figure 4 Panel A: PUBLIC DISCLOSURE ENFORCEMENT AND ENTRY				****
********************************************************************************

/* Reduced Form: Limited share on entry */

	/* Results */

		/* Coefficients */
		
			/* Aggregate */
			gen b_entry = 0.005 if _n == 1
			replace b_entry = -0.080 if _n == 2
			replace b_entry = -0.053 if _n == 3
			replace b_entry = 0 if _n == 4
			replace b_entry = -0.029 if _n == 5
			replace b_entry = 0.067 if _n == 6
			replace b_entry = 0.160 if _n == 7
			replace b_entry = 0.153 if _n == 8
			replace b_entry = 0.167 if _n == 9
			replace b_entry = 0.150 if _n == 10	
		
		/* Standard errors */
		
			/* Aggregate */
			gen t_entry = 0.11 if _n == 1
			replace t_entry = -1.80 if _n == 2	
			replace t_entry = -1.18 if _n == 3
			replace t_entry = 0 if _n == 4
			replace t_entry = -0.64 if _n == 5
			replace t_entry = 1.54 if _n == 6
			replace t_entry = 3.45 if _n == 7
			replace t_entry = 3.37 if _n == 8
			replace t_entry = 3.70 if _n == 9
			replace t_entry = 3.16 if _n == 10
			gen se_entry = 1/(t_entry/b_entry)
			replace se_entry = 0 if _n == 4

		/* Confidence interval */
		gen ci_entry_low = b_entry - 1.96*se_entry
		gen ci_entry_high = b_entry + 1.96*se_entry
		
	/* Graph: Limited share on entry */
	graph twoway ///
		(rarea ci_entry_high ci_entry_low year, color(gs13)) ///
		(scatter b_entry year, msymbol(o) color(black)) ///		
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Entry") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" "AND ENTRY", color(black)) ///
			saving(Figure_4_Panel_A, replace)

********************************************************************************
**** Figure 4 Panel B: PUBLIC DISCLOSURE ENFORCEMENT AND EXIT				****
********************************************************************************

/* Reduced Form: Limited share on exit */

	/* Results */

		/* Coefficients */
		
			/* Aggregate */
			gen b_exit = -0.012 if _n == 1
			replace b_exit = 0.003 if _n == 2
			replace b_exit = -0.039 if _n == 3
			replace b_exit = 0 if _n == 4
			replace b_exit = -0.072 if _n == 5
			replace b_exit = 0.081 if _n == 6
			replace b_exit = 0.065 if _n == 7
			replace b_exit = 0.099 if _n == 8
			replace b_exit = 0.049 if _n == 9
			replace b_exit = 0.094 if _n == 10	
		
		/* Standard errors */
		
			/* Aggregate */
			gen t_exit = -0.28 if _n == 1
			replace t_exit = 0.07 if _n == 2	
			replace t_exit = -0.88 if _n == 3
			replace t_exit = 0 if _n == 4
			replace t_exit = -1.51 if _n == 5
			replace t_exit = 1.84 if _n == 6
			replace t_exit = 1.44 if _n == 7
			replace t_exit = 2.18 if _n == 8
			replace t_exit = 1.08 if _n == 9
			replace t_exit = 2.09 if _n == 10
			gen se_exit = 1/(t_exit/b_exit)
			replace se_exit = 0 if _n == 4

		/* Confidence interval */
		gen ci_exit_low = b_exit - 1.96*se_exit
		gen ci_exit_high = b_exit + 1.96*se_exit
		
	/* Graph: Limited share on exit */
	graph twoway ///
		(rarea ci_exit_high ci_exit_low year, color(gs13)) ///
		(scatter b_exit year, msymbol(o) color(black)) ///		
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Exit") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" "AND EXIT", color(black)) ///
			saving(Figure_4_Panel_B, replace)

********************************************************************************
**** Figure 4 Panel C: PUBLIC DISCLOSURE ENFORCEMENT AND CONCENTRATION		****
********************************************************************************

/* Reduced Form: Limited share on concentration */

	/* Results */

		/* Coefficients */
		
			/* Aggregate */
			gen b_hhi = -0.003 if _n == 1
			replace b_hhi = 0.006 if _n == 2
			replace b_hhi = 0.003 if _n == 3
			replace b_hhi = 0 if _n == 4
			replace b_hhi = -0.009 if _n == 5
			replace b_hhi = -0.015 if _n == 6
			replace b_hhi = -0.013 if _n == 7
			replace b_hhi = -0.016 if _n == 8
			replace b_hhi = -0.019 if _n == 9
			replace b_hhi = -0.017 if _n == 10	
		
		/* Standard errors */
		
			/* Aggregate */
			gen t_hhi = -0.37 if _n == 1
			replace t_hhi = 0.79 if _n == 2	
			replace t_hhi = 0.50 if _n == 3
			replace t_hhi = 0 if _n == 4
			replace t_hhi = -1.59 if _n == 5
			replace t_hhi = -2.00 if _n == 6
			replace t_hhi = -1.38 if _n == 7
			replace t_hhi = -1.74 if _n == 8
			replace t_hhi = -2.05 if _n == 9
			replace t_hhi = -1.98 if _n == 10
			gen se_hhi = 1/(t_hhi/b_hhi)
			replace se_hhi = 0 if _n == 4

		/* Confidence interval */
		gen ci_hhi_low = b_hhi - 1.96*se_hhi
		gen ci_hhi_high = b_hhi + 1.96*se_hhi
		
	/* Graph: Limited share on concentration */
	graph twoway ///
		(rarea ci_hhi_high ci_hhi_low year, color(gs13)) ///
		(scatter b_hhi year, msymbol(o) color(black)) ///		
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.06(0.02)0.06, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("HHI") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" "AND PRODUCT MARKET CONCENTRATION", color(black)) ///
			saving(Figure_4_Panel_C, replace)

********************************************************************************
**** Figure A1: PUBLIC DISCLOSURE ENFORCEMENT AND DISCLOSURE RATE			****
********************************************************************************

/* First Stage: Limited share on disclosure rate */

	/* Results */

		/* Coefficients */
		gen b_lshare = -0.071 if _n == 1
		replace b_lshare = -0.064 if _n == 2
		replace b_lshare = -0.026 if _n == 3
		replace b_lshare = 0 if _n == 4
		replace b_lshare = 0.26 if _n == 5
		replace b_lshare = 0.293 if _n == 6
		replace b_lshare = 0.275 if _n == 7
		replace b_lshare = 0.260 if _n == 8
		replace b_lshare = 0.250 if _n == 9
		replace b_lshare = 0.235 if _n == 10
		
		/* Standard errors */
		gen t_lshare = -9.04 if _n == 1
		replace t_lshare = -8.35 if _n == 2	
		replace t_lshare = -4.53 if _n == 3
		replace t_lshare = 0 if _n == 4
		replace t_lshare = 21.69 if _n == 5
		replace t_lshare = 27.32 if _n == 6
		replace t_lshare = 24.55 if _n == 7
		replace t_lshare = 21.91 if _n == 8
		replace t_lshare = 22.96 if _n == 9
		replace t_lshare = 22.40 if _n == 10
		gen se_lshare = 1/(t_lshare/b_lshare)
		replace se_lshare = 0 if _n == 4
				
		/* Confidence interval */
		gen ci_lshare_low = b_lshare - 1.96*se_lshare
		gen ci_lshare_high = b_lshare + 1.96*se_lshare
		
	/* Graph: Limited share on disclosure rate */
	graph twoway ///
		(rarea ci_lshare_high ci_lshare_low year, color(gs13)) ///
		(scatter b_lshare year, msymbol(o) color(black)) ///
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.1(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///
			xtitle("Year") ///
			ytitle("Disclosure rate") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("PUBLIC DISCLOSURE ENFORCEMENT" " AND DISCLOSURE RATE", color(black)) ///
			name(Figure_A1, replace)

********************************************************************************
**** Figure A2: PUBLIC DISCLOSURE ENFORCEMENT AND ENTRY OF SUBSIDIARIES		****
********************************************************************************

/* Reduced Form: Limited share on entry */

	/* Results */

		/* Coefficients */
		
			/* High */
			gen b_entry_h = -0.115 if _n == 1
			replace b_entry_h = -0.221 if _n == 2
			replace b_entry_h = -0.139 if _n == 3
			replace b_entry_h = 0 if _n == 4
			replace b_entry_h = 0.085 if _n == 5
			replace b_entry_h = -0.014 if _n == 6
			replace b_entry_h = 0.059 if _n == 7
			replace b_entry_h = -0.017 if _n == 8
			replace b_entry_h = -0.178 if _n == 9
			replace b_entry_h = -0.096 if _n == 10	
	
			/* Low */
			gen b_entry_l = 0.039 if _n == 1
			replace b_entry_l = 0.042 if _n == 2
			replace b_entry_l = -0.060 if _n == 3
			replace b_entry_l = 0 if _n == 4
			replace b_entry_l = 0.096 if _n == 5
			replace b_entry_l = 0.152 if _n == 6
			replace b_entry_l = 0.089 if _n == 7
			replace b_entry_l = 0.179 if _n == 8
			replace b_entry_l = 0.122 if _n == 9
			replace b_entry_l = 0.142 if _n == 10	
			
		/* Standard errors */
		
			/* High */
			gen t_entry_h = -1.15 if _n == 1
			replace t_entry_h = -2.24 if _n == 2	
			replace t_entry_h = -1.31 if _n == 3
			replace t_entry_h = 0 if _n == 4
			replace t_entry_h = 0.86 if _n == 5
			replace t_entry_h = -0.15 if _n == 6
			replace t_entry_h = 0.61 if _n == 7
			replace t_entry_h = -0.18 if _n == 8
			replace t_entry_h = -1.91 if _n == 9
			replace t_entry_h = -0.98 if _n == 10
			gen se_entry_h = 1/(t_entry_h/b_entry_h)
			replace se_entry_h = 0 if _n == 4

			/* Low */
			gen t_entry_l = 0.79 if _n == 1
			replace t_entry_l = 0.82 if _n == 2	
			replace t_entry_l = -1.22 if _n == 3
			replace t_entry_l = 0 if _n == 4
			replace t_entry_l = 1.92 if _n == 5
			replace t_entry_l = 3.29 if _n == 6
			replace t_entry_l = 1.89 if _n == 7
			replace t_entry_l = 3.68 if _n == 8
			replace t_entry_l = 2.48 if _n == 9
			replace t_entry_l = 2.88 if _n == 10
			gen se_entry_l = 1/(t_entry_l/b_entry_l)
			replace se_entry_l = 0 if _n == 4
			
		/* Confidence interval */
		gen ci_entry_h_low = b_entry_h - 1.96*se_entry_h
		gen ci_entry_h_high = b_entry_h + 1.96*se_entry_h

		gen ci_entry_l_low = b_entry_l - 1.96*se_entry_l
		gen ci_entry_l_high = b_entry_l + 1.96*se_entry_l
		
	/* Graph: Limited share on entry */
	graph twoway ///
		(rarea ci_entry_h_high ci_entry_h_low year, color(gs13)) ///
		(scatter b_entry_h year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Entry of subsidiaries") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("HIGH" "(NUMBER OF FIRMS)", color(black)) ///
			name(Entry_h, replace)	
	
	graph twoway ///
		(rarea ci_entry_l_high ci_entry_l_low year, color(gs13)) ///
		(scatter b_entry_l year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Entry of subsidiaries") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("LOW" "(NUMBER OF FIRMS)", color(black)) ///
			name(Entry_l, replace)		
			
	graph combine Entry_h Entry_l, ///
		altshrink cols(2) ysize(4) xsize(10) ///
		title("PUBLIC DISCLOSURE ENFORCEMENT" "AND ENTRY OF SUBSIDIARIES", color(black)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		saving(Figure_A2, replace)		

********************************************************************************
**** Figure A3: PUBLIC DISCLOSURE ENFORCEMENT AND EXIT DUE TO 				****
**** 			UNPROFITABILITY												****
********************************************************************************
		
/* Reduced Form: Limited share on exit */

	/* Results */

		/* Coefficients */
		
			/* High */
			gen b_exit_h = -0.049 if _n == 1
			replace b_exit_h = -0.052 if _n == 2
			replace b_exit_h = -0.098 if _n == 3
			replace b_exit_h = 0 if _n == 4
			replace b_exit_h = -0.127 if _n == 5
			replace b_exit_h = -0.009 if _n == 6
			replace b_exit_h = -0.029 if _n == 7
			replace b_exit_h = 0.074 if _n == 8
			replace b_exit_h = -0.188 if _n == 9
			replace b_exit_h = -0.131 if _n == 10	
	
			/* Low */
			gen b_exit_l = 0.002 if _n == 1
			replace b_exit_l = -0.002 if _n == 2
			replace b_exit_l = -0.016 if _n == 3
			replace b_exit_l = 0 if _n == 4
			replace b_exit_l = -0.074 if _n == 5
			replace b_exit_l = 0.084 if _n == 6
			replace b_exit_l = 0.086 if _n == 7
			replace b_exit_l = 0.108 if _n == 8
			replace b_exit_l = 0.049 if _n == 9
			replace b_exit_l = 0.087 if _n == 10	
			
		/* Standard errors */
		
			/* High */
			gen t_exit_h = -0.53 if _n == 1
			replace t_exit_h = -0.55 if _n == 2	
			replace t_exit_h = -1.07 if _n == 3
			replace t_exit_h = 0 if _n == 4
			replace t_exit_h = -1.31 if _n == 5
			replace t_exit_h = -0.10 if _n == 6
			replace t_exit_h = -0.36 if _n == 7
			replace t_exit_h = 0.86 if _n == 8
			replace t_exit_h = -2.04 if _n == 9
			replace t_exit_h = -1.45 if _n == 10
			gen se_exit_h = 1/(t_exit_h/b_exit_h)
			replace se_exit_h = 0 if _n == 4

			/* Low */
			gen t_exit_l = 0.04 if _n == 1
			replace t_exit_l = -0.04 if _n == 2	
			replace t_exit_l = -0.37 if _n == 3
			replace t_exit_l = 0 if _n == 4
			replace t_exit_l = -1.92 if _n == 5
			replace t_exit_l = 2.07 if _n == 6
			replace t_exit_l = 2.17 if _n == 7
			replace t_exit_l = 2.57 if _n == 8
			replace t_exit_l = 1.27 if _n == 9
			replace t_exit_l = 2.21 if _n == 10
			gen se_exit_l = 1/(t_exit_l/b_exit_l)
			replace se_exit_l = 0 if _n == 4
			
		/* Confidence interval */
		gen ci_exit_h_low = b_exit_h - 1.96*se_exit_h
		gen ci_exit_h_high = b_exit_h + 1.96*se_exit_h

		gen ci_exit_l_low = b_exit_l - 1.96*se_exit_l
		gen ci_exit_l_high = b_exit_l + 1.96*se_exit_l
		
	/* Graph: Limited share on exit */
	graph twoway ///
		(rarea ci_exit_h_high ci_exit_h_low year, color(gs13)) ///
		(scatter b_exit_h year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Exit due to unprofitability") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("HIGH" "(NUMBER OF FIRMS)", color(black)) ///
			name(Exit_h, replace)	
	
	graph twoway ///
		(rarea ci_exit_l_high ci_exit_l_low year, color(gs13)) ///
		(scatter b_exit_l year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.4(0.1)0.4, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("Exit due to unprofitability") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("LOW" "(NUMBER OF FIRMS)", color(black)) ///
			name(Exit_l, replace)		
			
	graph combine Exit_h Exit_l, ///
		altshrink cols(2) ysize(4) xsize(10) ///
		title("PUBLIC DISCLOSURE ENFORCEMENT" "AND EXIT DUE TO UNPROFITABILITY", color(black)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		saving(Figure_A3, replace)	

********************************************************************************
**** Figure A4: PUBLIC DISCLOSURE ENFORCEMENT AND CONCENTRATION				****
********************************************************************************
		
/* Reduced Form: Limited share on concentration */

	/* Results */

		/* Coefficients */
		
			/* High */
			gen b_hhi_h = -0.008 if _n == 1
			replace b_hhi_h = -0.018 if _n == 2
			replace b_hhi_h = -0.007 if _n == 3
			replace b_hhi_h = 0 if _n == 4
			replace b_hhi_h = -0.001 if _n == 5
			replace b_hhi_h = -0.009 if _n == 6
			replace b_hhi_h = -0.005 if _n == 7
			replace b_hhi_h = 0.002 if _n == 8
			replace b_hhi_h = -0.002 if _n == 9
			replace b_hhi_h = 0.005 if _n == 10	
	
			/* Low */
			gen b_hhi_l = 0.002 if _n == 1
			replace b_hhi_l = 0.011 if _n == 2
			replace b_hhi_l = 0.005 if _n == 3
			replace b_hhi_l = 0 if _n == 4
			replace b_hhi_l = -0.012 if _n == 5
			replace b_hhi_l = -0.018 if _n == 6
			replace b_hhi_l = -0.015 if _n == 7
			replace b_hhi_l = -0.019 if _n == 8
			replace b_hhi_l = -0.020 if _n == 9
			replace b_hhi_l = -0.019 if _n == 10	
			
		/* Standard errors */
		
			/* High */
			gen t_hhi_h = -0.60 if _n == 1
			replace t_hhi_h = -1.44 if _n == 2	
			replace t_hhi_h = -0.73 if _n == 3
			replace t_hhi_h = 0 if _n == 4
			replace t_hhi_h = -0.08 if _n == 5
			replace t_hhi_h = -0.69 if _n == 6
			replace t_hhi_h = -0.33 if _n == 7
			replace t_hhi_h = 0.13 if _n == 8
			replace t_hhi_h = -0.13 if _n == 9
			replace t_hhi_h = 0.35 if _n == 10
			gen se_hhi_h = 1/(t_hhi_h/b_hhi_h)
			replace se_hhi_h = 0 if _n == 4

			/* Low */
			gen t_hhi_l = 0.18 if _n == 1
			replace t_hhi_l = 1.31 if _n == 2	
			replace t_hhi_l = 0.76 if _n == 3
			replace t_hhi_l = 0 if _n == 4
			replace t_hhi_l = -1.70 if _n == 5
			replace t_hhi_l = -1.99 if _n == 6
			replace t_hhi_l = -1.38 if _n == 7
			replace t_hhi_l = -1.72 if _n == 8
			replace t_hhi_l = -1.87 if _n == 9
			replace t_hhi_l = -1.87 if _n == 10
			gen se_hhi_l = 1/(t_hhi_l/b_hhi_l)
			replace se_hhi_l = 0 if _n == 4
			
		/* Confidence interval */
		gen ci_hhi_h_low = b_hhi_h - 1.96*se_hhi_h
		gen ci_hhi_h_high = b_hhi_h + 1.96*se_hhi_h

		gen ci_hhi_l_low = b_hhi_l - 1.96*se_hhi_l
		gen ci_hhi_l_high = b_hhi_l + 1.96*se_hhi_l
		
	/* Graph: Limited share on concentration */
	graph twoway ///
		(rarea ci_hhi_h_high ci_hhi_h_low year, color(gs13)) ///
		(scatter b_hhi_h year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.06(0.02)0.06, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("HHI") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("HIGH" "(NUMBER OF FIRMS)", color(black)) ///
			name(HHI_h, replace)	
	
	graph twoway ///
		(rarea ci_hhi_l_high ci_hhi_l_low year, color(gs13)) ///
		(scatter b_hhi_l year, msymbol(o) color(black)) ///				
			, xline(2007, lpattern(dash) lcolor(black)) yline(0, lcolor(black)) ///
			xlabel(2003(1)2012) ylabel(-0.06(0.02)0.06, angle(0) format(%9.2f))  ///
			legend(off) ///			
			xtitle("Year") ///
			ytitle("HHI") ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			title("LOW" "(NUMBER OF FIRMS)", color(black)) ///
			name(HHI_l, replace)		
			
	graph combine HHI_h HHI_l, ///
		altshrink cols(2) ysize(4) xsize(10) ///
		title("PUBLIC DISCLOSURE ENFORCEMENT" "AND PRODUCT MARKET CONCENTRATION", color(black)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		saving(Figure_A4, replace)

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Cleaning GWS data [Excerpt]									****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: GWS_panel.dta
	Variables:
		- gwa_jahr			gwa_jahr	
		- of2_2014			Amtlicher Gemeindeschluessel (AGS) der Betriebsstaette (Sitz) zum 31.12.2014
		- ef14				Schluessel der Rechtsform
		- ef81				Taetigkeit (Schwerpunktsangabe)
		- ef85 				Taetigkeit im Nebenerwerb?
		- ef86				Taetigkeit (Schwerpunktsangabe)
		- ef94				Anzahl der Vollzeitbeschaeftigten
		- ef95				Anzahl der Teilzeitbeschaeftigten
		- ef96				Keine Beschaeftigten
		- ef97				Erstattung fuer 1 = Hauptniederlassung; 2 = Zweigniederlassung; 3 = unselbstständige Zweigstelle
		- of1				Art der Meldung
		- ef99u1			Grund der Anmeldung: Neugruendung
		- ef99u2			Grund der Anmeldung: Wiedereroeffnung nach Verlegung aus einem anderen Meldebezirk
		- ef99u3			Grund der Anmeldung: Gruendung nach Umwandlungsgesetz
		- ef99u4			Grund der Anmeldung: Wechsel der Rechtsform
		- ef99u5			Grund der Anmeldung: Gesellschaftereintritt
		- ef99u6			Grund der Anmeldung: Erbfolge/Kauf/Pacht
		- ef100u1			Grund der Abmeldung: Vollstaendige Aufgabe
		- ef100u2			Grund der Abmeldung: Verlegung in einen anderen Meldebezirk
		- ef100u3			Grund der Abmeldung: Aufgabe infolge Umwandlungsgesetz
		- ef100u4			Grund der Abmeldung: Wechsel der Rechtsform
		- ef100u5			Grund der Abmeldung: Gesellschafteraustritt
		- ef100u6			Grund der Abmeldung: Erbfolge/Verkauf/Verpachtung
		- ef102				Ursache der Abmeldung
		- ef124				Grund der Ummeldung

Newly created variables (kept):
		- county 			County (Kreis)
		- state 			State (Bundesland)
		- industry 			Industry (2-Digit; WZ2008 (rev))
		- year 				Year (gwa_jahr)
		- limited 			Limited liability
		- empl 				Employees (incl. founder/owner)
		- main 				Main site
		- register 			Registration (Anmeldung)
		- change 			Change (Umwandlung)
		- deregister 		Deregistration (Abmeldung)
		- register_entry 	Entry (Registration)
		- register_move 	Move (Registration)
		- register_law		Legal split (Registration)
		- register_form		Legal form switch (Registration)
		- register_owner 	Entry of owner (Registration)
		- register_acquisition Acquisition (Registration)
		- deregister_exit 	Exit (Deregistration)
		- deregister_move 	Move (Deregistration)
		- deregister_law 	Legal combination (Deregistration)
		- deregister_form 	Legal form change (Deregistration)
		- deregister_owner 	Exit of owner (Deregistration)
		- deregister_sale 	Sale (Deregistration)
		- exit_close 		Exit (Unprofitable; Insolvency)
		- exit_sale 		Exit (Sale)
		- change_industry 	Industry change

Comment:
This program cleans the GWS panel creating selected variables required in subsequent analyses.
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, original("`directory'\Data\GWS_panel.dta")
project, uses("`directory'\Data\WZ_correspondence.dta")

********************************************************************************
**** (1) Industry correspondence (detailed WZ 2003 to WZ 2008)				****
********************************************************************************

/* Data */
use WZ_correspondence, clear

/* Two-digit industries */
foreach var of varlist wz* {
	replace `var' = floor(`var'/1000)
}

/* Approximation */
egen mode = mode(wz2008), by(wz2003)

gen approx = (mode != wz2008)
egen max = max(approx), by(wz2003)

replace approx = max
drop max mode

/* Duplicates */
duplicates drop wz2003, force

/* Save */
save WZ_correspondence_2, replace

/* Project */
project, creates("`directory'\Data\WZ_correspondence_2.dta")
	
********************************************************************************
**** (2) Variable definition												****
********************************************************************************

/* Data */
use GWS_panel, clear

/* Keep relevant obsevrations & variables */
drop if ef98 == "1" | ef98 == "2" // exclude: Automatenaufsteller und Reisegewerbe
keep gwa_jahr of2_2014 ef14 ef81 ef86 ef85 ef94 ef95 ef96 ef97 of1 ef99u* ef100u* ef102 ef124
	
/* Year */
rename gwa_jahr year

/* County */
gen county = substr(of2_2014, -6, 3)

/* State */
gen state = substr(of2_2014, -8, 2)
drop of2_2014

/* Limited company (incl. GmbH & Co. KG; incl. juristische Personen auslaendischer Rechtsformen (da gebuendelt in 991; verhindert Strukturbruch); excluding special forms (340)) */
gen limited = 0
replace limited = 1 if ///
	ef14 == "230" | ///
	ef14 == "232" | ///
	ef14 == "310" | ///
	ef14 == "320" | ///
	ef14 == "321" | ///
	ef14 == "322" | ///
	ef14 == "330" | ///
	ef14 == "350" | ///
	ef14 == "360" | ///
	(ef14 == "351" & year >= 2007) | ///
	(ef14 == "355" & year >= 2007) | ///
	(ef14 == "356" & year >= 2007) | ///	
	(ef14 == "910" & year < 2007) | ///
	(ef14 == "911" & year >= 2007)| ///
	(ef14 == "993" & year < 2007 & year >= 2005) | ///
	(ef14 == "991" & year < 2005) | ///
	(ef14 == "912" & year >= 2007) | ///
	(ef14 == "994" & year < 2007 & year >= 2005) | ///
	(ef14 == "992" & year >= 2007) | ///
	(ef14 == "996" & year < 2007 & year >= 2005)
drop ef14

/* Industry (WZ2003 or WZ2008) */
destring ef81 ef86, force replace /* FDZ comment: force-Option im FDZ hinzugefuegt, da irrelevante alphanumerische Zeichen vorkommen (vereinzelt)*/
replace ef81 = ef86 if ef81 == .
rename ef81 industry
drop ef86

/* Reclassification to WZ2008 */
gen wz2003 = industry if year < 2008
merge m:1 wz2003 using WZ_correspondence_2
drop if _merge == 2
drop _merge

replace industry = wz2008 if year < 2008
egen max = max(approx), by(industry)
replace approx = max
drop max wz2003 wz2008

drop if industry == 98 // only defined in WZ2008

/* Employees (Part-time employees: 1/2 FTE; Founder/Owner/Manager: 1 FTE; PT Founder/Owner/Manager: 1/2 FTE) */
destring ef85 ef96, replace /* FDZ comment: ef94 und ef95 liegen schon im Zahlenformat vor, daher im FDZ aus dieser Liste entfernt */
gen empl = 1 if ef96 == 1
replace empl = 0.5 if ef96 == 0 & ef85 == 1
replace empl = 1 + ef94 + ef95 if empl == . & ef94 != . & ef95 != .
replace empl = 1 + ef94 if empl == . & ef94 != . & ef95 == .
replace empl = 1 + ef95 if empl == . & ef94 == . & ef95 != .
drop ef85 ef94 ef95 ef96

/* Main site */
destring ef97, replace
gen main = (ef97 == 1) if ef97 != .
drop ef97

/* Register, change, deregister */
destring of1, replace
gen register = (of1 == 1) if of1 != .
gen change = (of1 == 2) if of1 != .
gen deregister = (of1 == 3) if of1 != .
drop of1

/* Registration: type */ 
destring ef99u*, replace
gen register_entry = (ef99u1 == 1) if ef99u1 != .
gen register_move = (ef99u2 == 1) if ef99u2 != .
gen register_law = (ef99u3 == 1) if ef99u3 != .
gen register_form = (ef99u4 == 1) if ef99u4 != .
gen register_owner = (ef99u5 == 1) if ef99u5 != .
gen register_sale = (ef99u6 == 1) if ef99u6 != .
drop ef99u*

/* Deregistration: type */
destring ef100u*, replace
gen deregister_exit = (ef100u1 == 1) if ef100u1 != .
gen deregister_move = (ef100u2 == 1) if ef100u2 != .
gen deregister_law = (ef100u3 == 1) if ef100u3 != .
gen deregister_form = (ef100u4 == 1) if ef100u4 != .
gen deregister_owner = (ef100u5 == 1) if ef100u5 != .
gen deregister_sale = (ef100u6 == 1) if ef100u6 != .
drop ef100u*

/* Deregistration: reason */
destring ef102, replace
gen exit_close = (ef102 == 11 | ef102 == 12)
gen exit_sale = (ef102 == 17)
drop ef102

********************************************************************************
**** (3) Labeling and saving												****
********************************************************************************

/* Labeling */
label var county "County"
label var state "State"
label var industry "Industry (2-Digit; WZ2008)"
label var year "Year"
label var limited "Limited liability"
label var empl "Employees (incl. founder/owner)"
label var main "Main site"
label var register "Registration"
label var change "Change"
label var deregister "Deregistration"
label var register_entry "Entry (Registration)"
label var register_move "Move (Registration)"
label var register_law "Legal split (Registration)"
label var register_form "Legal form switch (Registration)"
label var register_owner "Entry of owner (Registration)"
label var register_sale "Acquisition (Registration)"
label var deregister_exit "Exit (Deregistration)"
label var deregister_move "Move (Deregistration)"
label var deregister_law "Legal combination (Deregistration)"
label var deregister_form "Legal form change (Deregistration)"
label var deregister_owner "Exit of owner (Deregistration)"
label var deregister_sale "Sale (Deregistration)"
label var exit_close "Exit (Unprofitable; Insolvency)"
label var exit_sale "Exit (Sale)"

/* Save */
save GWS_data, replace

/* Project */
project, creates("`directory'\Data\GWS_data.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Aggregate outcomes from GWS	[Excerpt]						****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: GWS_data.dta
	Variables:
		- county 			County (Kreis)
		- state 			State (Bundesland)
		- industry 			Industry (2-Digit; WZ2008 (rev))
		- year 				Year (gwa_jahr)
		- limited 			Limited liability
		- empl 				Employees (incl. founder/owner)
		- register_entry 	Entry (Registration)
		- register_form		Entry (Legal form change)
		- register_owner 	Entry (Owner entry)
		- register_sale 	Entry (Acquisition)		
		- deregister_exit 	Exit (Deregistration)
		- deregister_form	Exit (Legal form change)
		- deregister_sale	Exit (Sale)
		- exit_close 		Exit (Unprofitable; Insolvency)
		
Newly created variables (kept):
		- entry_main		Entry (Log count; Main business)
		- entry_sub			Entry (Log count; Subsidiary)
		- exit_main			Exit (Log count; Main business)
		- exit_close 		Exit (Log count; Insolvency) 
		
Comment:
This program calculates county-industry-year level aggregates of firm entry and exit.
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, uses("`directory'\Data\GWS_data.dta")

********************************************************************************
**** (1) Aggregate outcomes													****
********************************************************************************

/* Data */
use GWS_data, clear

/* Aggregate outcomes */
  
	/* Count */
	local variables = "register_entry deregister_exit exit_close"
	foreach var of varlist `variables' {
		
		/* County-industry level */
		egen t_`var' = total(`var'), by(county industry year) missing
		
		/* County-industry level: Main vs. subsidiary */
		egen t_`var'_main = total(`var'*main), by(county industry year) missing
		gen t_`var'_sub = t_`var' - t_`var'_main	

		/* Drop */
		drop `var'
	}

********************************************************************************
**** (2) Entry and exit measures											****
********************************************************************************

/* Keep */
keep county state industry year t_*

/* Duplicates */
duplicates drop county industry year, force	
	
	/* Entry */
	
		/* Main */
		gen entry_main = ln(1+t_register_entry_main)
		label var entry_main "Entry (Log; Main)"

		/* Subsidiary */
		gen entry_sub = ln(1+t_register_entry_sub)
		label var entry_sub "Entry (Log; Subsidiary)"			
			
	/* Exit */
	
		/* True exit */			
		gen exit_close = ln(1+t_exit_close)
		label var exit_close "Exit (Insolvency; Log)"
		
		/* Main */
		gen exit_main = ln(1+t_deregister_exit_main)
		label var exit_main "Exit (Log; Main)"

********************************************************************************
**** (3) Cleaning, labeling, saving											****
********************************************************************************		

/* Keep relevant variables */
keep county industry year entry* exit*		

/* Save */
save GWS_outcomes, replace

/* Project */
project, creates("`directory'\Data\GWS_outcomes.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Converging industry	definitions (WZ 2003, 2008) in URS		****
****			[Excerpt]													****
********************************************************************************
/*
Original variables (used/kept): 	

	Data file: Klassifikationenwz2008_umsteiger.csv
	Variables:
		- wz2003			WZ 2003 code
		- wz2008			WZ 2008 code
		
	Data file: URS_panel.dta
	Variables:
		- UNR				systemfreie Unternehmensnummer
		- urs_jahr			Auswertungsjahr des Unternehmensregisters
		- aktiv				Aktive URS-Einheiten (=1) vs. inaktive URS-Einheiten (=0)
		- untern			Unternehmen=1, 0=sonst
		- urs_1ef6			Sitz der Einheit: Amtlicher Gemeindeschluessel
		- urs_1ef16			Zugangsmonat
		- urs_1ef17			Zugangsjahr
		- urs_1ef19			Art der Einheit
		- urs_1ef20			Wirtschaftszweig WZ2003 (fuer 2004-2007) bzw. WZ2008 (fuer 2008 und folgende Jahre)
		- urs_1ef26			Rechtsform
		- urs_5ef16u1		Steuerbarer Umsatz in 1000 EUR
		- urs_5ef16u2		Bezugszeit steuerbarer Umsatz (jjjj)
		- urs_5ef18u1		Sozialversicherungspflichtig Beschaeftigte: Anzahl
		- urs_5ef18u2		Sozialversicherungspflichtig Beschaeftigte: Bezugszeit (jjjj)
		- urs_5ef20u1		Beginn der Steuerpflicht (ttmmjjjj)
		- urs_5ef20u2		Zeitpunkt der Aufnahme der wirtschaftlichen Taetigkeit
		- urs_5ef21u1		Ende der Steuerpflicht (ttmmjjjj)
		- urs_5ef21u2		Zeitpunkt der engueltigen Aufgabe der betrieblichen Taetigkeit 
		- urs_5ef30u1		Schaetzumsatz nach Organschaftschaetzung in 1000 EUR
		- urs_5ef30u2		Bezugszeit Schaetzumsatz (jjjj)
		- GTAG				Gemeindeteilausgliederung gemaess BBSR-AGS-Umsteigern 2014
		- agsunsicher		agsunsicher: 1=gewisse Restunsicherheit in der (manuellen) Umkodierung des AGS
		- urs_1ef6_14		Amtlicher Gemeindeschluessel zum Gebietsstand 31.12.2014

Newly created variables (kept):
		- industry_5 		5-digit industry identifier (WZ 2003 before 2008 and WZ 2008 in and after 2008)
		- county			County identifier (Kreis)
		- state				State identifier (Bundesland)
		- legal_form		Legal form (limited vs. unlimited liability)
		- wz2008_rev		Updated/converged WZ 2008 for entire panel

Comment:
This program generates a firm-year panel with a common legal form definition, county identifiers as of 2014, and industry identifiers using WZ2008 (rev).
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, original("`directory'\Data\Klassifikationenwz2008_umsteiger.csv")
project, original("`directory'\Data\URS_panel.dta")

********************************************************************************
**** (1) Industry correspondence (detailed WZ 2003 to WZ 2008)				****
********************************************************************************

/* Data (WZ Umsteiger) */
import delimited Klassifikationenwz2008_umsteiger.csv, delimiter(",") varnames(nonames) rowrange(3:) clear

	/* Keep relevant variables */
	keep v2 v5

	/* Rename variables */
	rename v2 wz2003
	rename v5 wz2008
	
	/* Destring industry codes */
	destring wz*, replace ignore(".")
	
	/* Duplicates (ambiguous categories) */
	duplicates drop wz2003, force
	
	/* Save */
	save WZ_correspondence, replace
	
	/* Project */
	project, creates("`directory'\Data\WZ_correspondence.dta")
	
********************************************************************************
**** (2) Industry redefinition (URS) 										****
********************************************************************************

/* Data (URS) (Sample restriction: only corporations) */
use URS_panel if untern == 1 & aktiv == 1, clear

/* Make industry 5-digits */
replace urs_1ef20 = urs_1ef20 + "000" if length(urs_1ef20) == 2
replace urs_1ef20 = urs_1ef20 + "00" if length(urs_1ef20) == 3
replace urs_1ef20 = urs_1ef20 + "0" if length(urs_1ef20) == 4

/* Industry match variable */
destring urs_1ef20, gen(industry_5)
gen wz2003 = industry_5 if urs_jahr <= 2007

/* Merge: WZ correspondence */
merge m:1 wz2003 using WZ_correspondence
drop if _merge == 2
drop _merge

/* Panel */
duplicates drop UNR urs_jahr, force
xtset UNR urs_jahr

/* Backfilling legal form (no adjustment for legal form issues before 2005; proportions look fine in sample file) */
destring urs_1ef26, replace force
gen legal_form = urs_1ef26
forvalues y = 1(1)13 {
	replace legal_form = f.urs_1ef26 if (urs_1ef26 == . | urs_1ef26 == 9)  & f.urs_1ef26 != . & urs_jahr == 2014-`y' 
}

/* WZ 2008 (new) */
gen wz2008_rev = industry_5 if urs_jahr >= 2008

/* Backfilling */
forvalues y = 1(1)7 {
	replace wz2008_rev = f.wz2008_rev if wz2008_rev == . & f.wz2008_rev != . & urs_jahr == 2008-`y' 
}

/* WZ correspondence */
replace wz2008_rev = wz2008 if wz2008_rev == .

/* Drop */
drop untern aktiv

/* Save */
save URS_data, replace

********************************************************************************
**** (3) Panel information for industry redefinition (URS) 					****
********************************************************************************
	
/* Relevant variables */
keep wz2003 wz2008_rev
	
/* Mode */
egen wz2008_corr = mode(wz2008_rev), by(wz2003)
	
/* Keep correspondence */
keep wz2003 wz2008_corr
	
/* Duplicates */
duplicates drop wz2003, force
	
/* WZ panel correspondence */
save WZ_panel_correspondence, replace 

/* Project */
project, creates("`directory'\Data\WZ_panel_correspondence.dta")
project, uses("`directory'\Data\WZ_panel_correspondence.dta")

********************************************************************************
**** (4) Converged data (URS) 												****
********************************************************************************

/* Data */
use URS_data, clear

/* Merge: WZ panel correspondence */
merge m:1 wz2003 using WZ_panel_correspondence
drop if _merge == 2
drop _merge

/* Adjust correspondence (assumption: most frequent match) */
replace wz2008_rev = wz2008_corr if wz2008_rev == .

/* County identifier */
gen county = substr(urs_1ef6_14, -6, 3)
		
/* State identifier */
gen state = substr(urs_1ef6_14, -8, 2)

/* Keep relevant data */
keep ///
	UNR ///
	urs_jahr ///
	urs_1ef6 ///
	urs_1ef16 ///
	urs_1ef17 ///
	urs_1ef19 ///
	industry_5 ///
	urs_1ef26 ///
	urs_5ef16u1 ///
	urs_5ef16u2 ///
	urs_5ef18u1 ///
	urs_5ef18u2 ///
	urs_5ef20u1 ///
	urs_5ef20u2 ///
	urs_5ef21u1 ///
	urs_5ef21u2 ///
	urs_5ef30u1 ///
	urs_5ef30u2 ///
	GTAG ///
	agsunsicher ///
	urs_1ef6_14 ///
	county ///
	state ///
	wz2003 ///
	wz2008_rev ///
	legal_form
	
/* Labeling */
label var wz2003 "WZ 2003"
label var wz2008_rev "WZ 2008 (Revised)"
label var county "County (AGS)"
label var state "State (AGS)"
label var legal_form "Legal form (Revised)"

/* Save */
save URS_data, replace

/* Project */
project, creates("`directory'\Data\URS_data.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		02/21/2017													****
**** Program:	Aggregate outcomes from URS [Excerpt]						****
********************************************************************************
/*
Original variables (used/kept): 	
		
	Data file: URS_data.dta
	Variables:
		- UNR				systemfreie Unternehmensnummer
		- urs_jahr			Auswertungsjahr des Unternehmensregisters
		- urs_1ef26			Rechtsform
		- urs_5ef16u1		Steuerbarer Umsatz in 1000 EUR
		- urs_5ef16u2		Bezugszeit steuerbarer Umsatz (jjjj)
		- urs_5ef18u1		Sozialversicherungspflichtig Beschaeftigte: Anzahl
		- urs_5ef18u2		Sozialversicherungspflichtig Beschaeftigte: Bezugszeit (jjjj)
		- urs_5ef30u1		Schaetzumsatz nach Organschaftschaetzung in 1000 EUR
		- urs_5ef30u2		Bezugszeit Schaetzumsatz (jjjj)
		- urs_1ef6_14		Amtlicher Gemeindeschluessel zum Gebietsstand 31.12.2014
		- county			County identifier (Kreis)
		- state				State identifier (Bundesland)
		- legal_form		Legal form (limited vs. unlimited liability)
		- wz2008_rev		Updated/converged WZ 2008 for entire panel

Newly created variables (kept):
		- industry 			Industry (2-Digit NACE/WZ 2008)
		- year 				Fiscal Year (Bezugsjahr)
		- sales 			Sales (Estimated taxable sales)
		- empl				Employees (1+Employees)
		- limited_fraction 	Fraction of limited firms in all firms
		- no_firms_URS 		Number of firms (URS)
		- hhi				Herfindahl-Hirschman Index (Concentration)

Note:
		- suffix: lim		Uses limited liability firms only
		- suffix: unl		Uses unlimited liability firms only
		
Comment:
This program calculates county-industry-year level aggregates (e.g., product-market concentration).
*/

**** Preliminaries ****
version 15.1
clear all
set more off

**** Seed ****
set seed 1234

**** Directory ****
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

**** Project ****
project, uses("`directory'\Data\URS_data.dta")

********************************************************************************
**** (1) Number of limited liability firms in URS							****
********************************************************************************

/* Data */
use URS_data, clear

/* Keep relevant variables */
keep ///
	UNR ///
	urs_jahr ///
	county ///
	state ///
	urs_1ef17 ///
	urs_1ef26 ///
	urs_5ef16u2 ///
	urs_5ef18u2 ///
	urs_5ef30u2 ///
	urs_5ef16u1 ///
	urs_5ef30u1 ///
	urs_5ef18u1	///
	wz2008_rev ///
	legal_form	

/* Specify: level of industry (2-digit) */
gen industry = floor(wz2008_rev/1000)
label var industry "Industry (2-Digit NACE/WZ)"

/* Duplicates */
sort UNR urs_jahr
duplicates drop UNR urs_jahr, force

/* Sample restriction */
keep if legal_form >= 1 & legal_form <= 8
 
/* Number of all firms */
egen no_firms_URS = count(UNR), by(county industry urs_jahr)

/* Number of limited liability firms */
gen limited = (legal_form == 5 | legal_form == 6 | legal_form == 7)
label var limited "Limited firm"

egen no_firms_URS_lim = total(limited), by(county industry urs_jahr) missing

/* Number of unlimited liability firms */
gen unlimited = (legal_form == 1 | legal_form == 2 | legal_form == 3 | legal_form == 4 | legal_form == 8)
label var unlimited "Unlimited firm"

egen no_firms_URS_unl = total(unlimited), by(county industry urs_jahr) missing

********************************************************************************
**** (2) Weights and outcomes in URS										****
********************************************************************************

/* Year */
destring urs_5ef16u2 urs_5ef18u2 urs_5ef30u2, replace
gen year = urs_jahr - 2
label var year "Fiscal Year"

/* Panel entry year */
destring urs_1ef17, replace
rename urs_1ef17 entry_year
label var entry_year "Entry Year (URS)"

/* Sales */
gen sales = urs_5ef30u1 
replace sales = urs_5ef16u1 if sales == . & urs_jahr == 2008
replace sales = urs_5ef16u1 if urs_5ef30u2 != year & urs_5ef16u2 == year
replace sales = . if urs_5ef30u2 != year & urs_5ef16u2 != year
label var sales "Sales (Estimated taxable sales)"

/* Employees (replace for missing values with year + nonmissing value with wrong year) */
gen empl = urs_5ef18u1+1
replace empl = 1 if (empl == . & urs_5ef18u1 == . & urs_5ef18u2 != .) | (urs_5ef18u2 != year)
label var empl "Employees (1+Employees)"

/* Panel */
sort UNR year
duplicates drop UNR year, force
xtset UNR year

/* Sample restriction: period 2003 to 2012 */
keep if year >= 2003 & year <= 2012

/* Drop missing */
drop if sales == . & empl == .

/* Save firm sample */
save Firm, replace

/* Concentration measure (HHI) */

	/* All */
	egen total = total(sales), by(county industry year) missing
	egen hhi = total((sales/total)^2), by(county industry year) missing
	label var hhi "Concentration (HHI)"
	drop total
	
********************************************************************************
**** (5) Cleaning and labeling												****
********************************************************************************

/* Keep relevant variables */ 
keep ///
	county ///
	state ///
	industry ///
	year ///
	no_* ///
	hhi
	
/* Duplicates */
sort county industry year
duplicates drop county industry year, force

/* Labeling */
label var no_firms_URS "Number of firms (URS)"
label var no_firms_URS_lim "Number of (limited) firms (URS)"
label var no_firms_URS_unl "Number of (unlimited) firms (URS)"

********************************************************************************
**** (6) Additional variables												****
********************************************************************************

/* Duplicates */
duplicates drop county industry year, force
	
/* Fraction of firms */
gen limited_fraction = no_firms_URS_lim/no_firms_URS
label var limited_fraction "Fraction of limited firms in all firms"
	
/* Cross-sectional split variables */

	/* Number of firms */
	egen pre = mean(no_firms_URS) if year == 2006, by(county industry)
	egen s_firms = mean(pre), by(county industry)
	label var s_firms "Firms (pre)"
	drop pre
			
********************************************************************************
**** (7) Saving																****
********************************************************************************
			
/* Save */
cd "`directory'\Data"
save URS_outcomes, replace	

/* Project */	
project, creates("`directory'\Data\URS_outcomes.dta")
project, creates("`directory'\Data\Firm.dta")

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (0) Execute project programs 											****
****	 (Data source abbreviations:										****
****		- URS: Unternehmensregister										****
****		- GWS: Gewerbeanzeigenstatistik									****
****		- AMA: Amadeus (Bureau van Dijk) [separate do-file: AMA_data]	****
********************************************************************************

********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Unifying county & industry definitions 							****
********************************************************************************

/* Cleaning URS panel & converging industry (WZ) definitions */
project, do(Dofiles/URS_data.do)

/* Cleaning GWS panel */
project, do(Dofiles/GWS_data.do)


********************************************************************************
**** (3) Aggregate outcomes 												****
********************************************************************************

/* Obtaining aggregate outcomes from URS */
project, do(Dofiles/URS_outcomes.do)

/* Obtaining aggregate outcomes from GWS */
project, do(Dofiles/GWS_outcomes.do)


********************************************************************************
**** (4) Empirical analyses 												****
********************************************************************************

/* Merging outcome and treatment variables */
project, do(Dofiles/Data.do)

/* Regression analyses */
project, do(Dofiles/Analyses.do)

/* Graphs */
project, do(Dofiles/Graphs.do)

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (0) Execute project programs 											****
****	 (Data source abbreviations:										****
****		- URS: Unternehmensregister										****
****		- GWS: Gewerbeanzeigenstatistik									****
****		- AMA: Amadeus (Bureau van Dijk) [separate do-file: AMA_data]	****
********************************************************************************

********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Coverage (treatment) [to be prepared for Destatis]					****
********************************************************************************

/* AMA panel data with converged industry (WZ) and location (AGS) definitions */
project, do(Dofiles/AMA_panel.do)

/* AMA data for coverage calculation */
project, do(Dofiles/AMA_data.do)

/* Obtaining coverage (treatment) from AMA (for Germany) */
project, do(Dofiles/AMA_coverage.do)

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/18/2017													****
**** Program:	Setup of "project" program (German enforcement setting)		****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Master directory ****
local master = "...\Project_Germany\Programs" // specify directory path

********************************************************************************
**** (0) Install external program ("project")								****
********************************************************************************

**** Install ****
ssc install project


********************************************************************************
**** (1) Setup and building project: Local									****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Local.do")

**** Build ****
cap noisily project Master_Local, build


********************************************************************************
**** (2) Setup and building project: Destatis [to be run at FDZ]			****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Destatis.do")

**** Build ****
cap noisily project Master_Destatis, build

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Installs external (user-written) programs					****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

********************************************************************************
**** (1) Install external programs											****
********************************************************************************

**** Estout ****
ssc install estout, replace

**** Reghdfe ****
ssc install reghdfe, replace

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		08/03/2020													****
**** Program:	EU KLEMS productivity data									****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, original("`directory'\Data\Statistical_National-Accounts.dta")	
project, original("`directory'\Data\Statistical_Growth-Accounts.dta")	
project, original("`directory'\Data\Statistical_Capital.dta")	

********************************************************************************
**** (1) Generate KLEMS data												****
********************************************************************************

/* Delete */
cap rm KLEMS.dta

/* Data */
use Statistical_National-Accounts, clear

/* Keep relevant data */
keep if var == "VA" | var == "COMP"

/* Reshape: Variable into columns */

	/* Obtain variable names */
	levelsof var, clean local(varlist) 

	/* Loop over variables */
	foreach var of local varlist {

		/* Preserve */
		preserve
			
			/* Variable */
			keep if var == "`var'"
			drop db var indnr Sort_ID
			
			/* Variable name */
			local name = lower("`var'")
			
			/* Rename */
			rename value `name'
			label var `name' "`var'"

			/* Merge */
			//cd "`directory'\Data"
			cap merge 1:1 country code year using KLEMS
			cap drop _merge
			
			/* Save */
			save KLEMS, replace
			
		/* Restore */
		restore
			
	}
	
/* Data: Growth Accounts */
use Statistical_Growth-Accounts, clear

/* Keep relevant data */
keep if var == "VA_G"

/* Reshape: Variable into columns */

	/* Obtain variable names */
	levelsof var, clean local(varlist) 

	/* Loop over variables */
	foreach var of local varlist {

		/* Preserve */
		preserve
			
			/* Variable */
			keep if var == "`var'"
			drop db var indnr Sort_ID
			
			/* Variable name */
			local name = lower("`var'")
			
			/* Rename */
			rename value `name'
			label var `name' "`var'"

			/* Merge */
			//cd "`directory'\Data"
			cap merge 1:1 country code year using KLEMS
			cap drop _merge
			
			/* Save */
			save KLEMS, replace
			
		/* Restore */
		restore
			
	}

/* Data: Capital Accounts */
use Statistical_Capital, clear

/* Keep relevant data */
keep if var == "K_GFCF"

/* Reshape: Variable into columns */

	/* Obtain variable names */
	levelsof var, clean local(varlist) 

	/* Loop over variables */
	foreach var of local varlist {

		/* Preserve */
		preserve
			
			/* Variable */
			keep if var == "`var'"
			drop db var indnr Sort_ID
			
			/* Variable name */
			local name = lower("`var'")
			
			/* Rename */
			rename value `name'
			label var `name' "`var'"

			/* Merge */
			//cd "`directory'\Data"
			cap merge 1:1 country code year using KLEMS
			cap drop _merge
			
			/* Save */
			save KLEMS, replace
			
		/* Restore */
		restore
			
	}

/* Data */
use KLEMS, clear
	
/* Cleaning */

	/* Country */
	replace country = "Austria" if country == "AT"
	replace country = "Belgium" if country == "BE"
	replace country = "Bulgaria" if country == "BG"
	replace country = "Cyprus" if country == "CY"
	replace country = "Czech Republic" if country == "CZ"
	replace country = "Germany" if country == "DE"
	replace country = "Denmark" if country == "DK"
	replace country = "Estonia" if country == "EE"
	replace country = "Greece" if country == "EL"
	replace country = "Spain" if country == "ES"
	replace country = "Finland" if country == "FI"
	replace country = "France" if country == "FR"
	replace country = "Croatia" if country == "HR"
	replace country = "Hungary" if country == "HU"
	replace country = "Ireland" if country == "IE"
	replace country = "Italy" if country == "IT"
	replace country = "Japan" if country == "JP"
	replace country = "Lithuania" if country == "LT"
	replace country = "Luxembourg" if country == "LU"
	replace country = "Latvia" if country == "LV"
	replace country = "Malta" if country == "MT"
	replace country = "Netherlands" if country == "NL"
	replace country = "Poland" if country == "PL"
	replace country = "Portugal" if country == "PT"
	replace country = "Romania" if country == "RO"
	replace country = "Sweden" if country == "SE"
	replace country = "Slovenia" if country == "SI"
	replace country = "Slovakia" if country == "SK"
	replace country = "United Kingdom" if country == "UK"
	replace country = "United States" if country == "US"
	drop if country == "EA19" | regexm(country, "EU") == 1

	/* Industry */
	rename code industry
	drop if industry == "MARKT" | regexm(industry, "TOT") == 1

/* Sort */
sort country industry year
		
/* Labels */  
label var country "Country"
label var industry "Industry"
label var year "Year"
label var va "GVA, current prices, NAC mn"
label var comp "Compensation of employees, current prices, NAC mn"
label var va_g "Growth rate of value added volume, %, log"
label var k_gfcf "Capital stock, net, current replacement (all assets)"

/* Save */
save KLEMS, replace

/* Project */
project, creates("`directory'\Data\KLEMS.dta")

********************************************************************************
**** (2) Industry link to Scopes											****
********************************************************************************

/* Data */
use Scope_2, clear // Scope calculated using Scope.do from Project_Europe (but for two-digit instead of four-digit NACE industries)

/* Rename industry */
rename industry industry_nace
	
/* Generate broad ISIC 4 */
gen industry = ""
replace industry = "A" if industry_nace >= 1 & industry_nace <= 3
replace industry = "B" if industry_nace >= 5 & industry_nace <= 9
replace industry = "C10-C12" if industry_nace >= 10 & industry_nace <= 12
replace industry = "C13-C15" if industry_nace >= 13 & industry_nace <= 15
replace industry = "C16-C18" if industry_nace >= 16 & industry_nace <= 18
replace industry = "C19" if industry_nace == 19
replace industry = "C20" if industry_nace == 20
replace industry = "C21" if industry_nace == 21
replace industry = "C22_C23" if industry_nace >= 22 & industry_nace <= 23
replace industry = "C24_C25" if industry_nace >= 24 & industry_nace <= 25
replace industry = "C26" if industry_nace == 26
replace industry = "C27" if industry_nace == 27
replace industry = "C28" if industry_nace == 28
replace industry = "C29_C30" if industry_nace >= 29 & industry_nace <= 30
replace industry = "C31_C33" if industry_nace >= 30 & industry_nace <= 33
replace industry = "D" if industry_nace == 35
replace industry = "E" if industry_nace >= 36 & industry_nace <= 39
replace industry = "F" if industry_nace >= 41 & industry_nace <= 43
replace industry = "G45" if industry_nace == 45
replace industry = "G46" if industry_nace == 46
replace industry = "G47" if industry_nace == 47
replace industry = "H49" if industry_nace == 49
replace industry = "H50" if industry_nace == 50
replace industry = "H51" if industry_nace == 51
replace industry = "H52" if industry_nace == 52
replace industry = "H53" if industry_nace == 53
replace industry = "I" if industry_nace >= 55 & industry_nace <= 56
replace industry = "J58-J60" if industry_nace >= 58 & industry_nace <= 60
replace industry = "J61" if industry_nace == 61
replace industry = "J62_J63" if industry_nace >= 62 & industry_nace <= 63
replace industry = "K" if industry_nace >= 64 & industry_nace <= 66
replace industry = "L" if industry_nace == 68
replace industry = "M_N" if industry_nace >= 69 & industry_nace <= 82
replace industry = "O" if industry_nace == 84
replace industry = "P" if industry_nace == 85
replace industry = "Q" if industry_nace >= 86 & industry_nace <= 88
replace industry = "R_S" if industry_nace >= 90 & industry_nace <= 96
replace industry = "T" if industry_nace >= 97 & industry_nace <= 98
replace industry = "U" if industry_nace == 99
label var industry "Industry (KLEMS)"

/* Aggregate scopes to broad KLEMS industries */
collapse (mean) mc_scope mc_audit, by(country industry year)

/* Save */
save Scope_KLEMS, replace

/* Project */
project, creates("`directory'\Data\Scope_KLEMS.dta")

********************************************************************************
**** (3) Combine KLEMS and Scopes											****
********************************************************************************

/* Data */
use KLEMS, clear

/* Scope */
		
	/* Merge: own scope */
	merge m:1 country industry year using Scope_KLEMS
	drop if _merge == 2
	drop _merge
	
/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Cluster */
egen cluster = group(c i)
label var cluster "Cluster (country-industry)"

********************************************************************************
**** (4) Generate relevant variables										****
********************************************************************************

/* Panel */
xtset cluster year

/* Combined scope */
egen min = rowmin(mc_scope mc_audit)
label var min "Reporting and Auditing"

/* Productivity */

	/* log */
	gen value = ln(va)
	gen lp = ln(va) - ln(comp)
	gen tfp = ln(va) - 0.7*ln(comp) - 0.3*ln(k_gfcf)
	gen growth = va_g/100 // already logarithmic
	
********************************************************************************
**** (5) Regression analysis												****
********************************************************************************

/* Keep relevant period */
keep if year >= 2001 & year <= 2015

/* Variable list */

	/* Parameters*/
	local FE = "c##year i##year"	
	local Cluster = "cluster"
	
	/* All outcomes */
	local Outcomes = "value lp tfp growth"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_8_Panel_A.smcl, replace smcl name(Table_8_Panel_A) 

/* Industry Level */
foreach y of varlist `Outcomes' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if mc_scope!=., a(`FE') residual(r_`y')
			qui reghdfe mc_scope if `y'!=., a(`FE') residual(r_mc_scope)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		

			/* Estimation */			
			qui reghdfe `y' mc_scope, a(`FE') cluster(`Cluster')    
				est store M1	
				
		}
		
	/* Restore */
	restore
	
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if min!=., a(`FE') residual(r_`y')
			qui reghdfe min if `y'!=., a(`FE') residual(r_min)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)

			qui sum r_min, d
			qui replace min = . if r_min < r(p1) | r_min > r(p99)
			
			/* Estimation */
			qui reghdfe `y' min, a(`FE') cluster(`Cluster')    
				est store M2
				
			/* Output */
			estout M1 M2, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("COUNTRY-INDUSTRY LEVEL: `y_label'") ///
				varlabels(mc_scope "Standardized Reporting Scope" min "Standardized Reporting and Auditing Scope") ///				
				mlabels(, depvars) varwidth(45) modelwidth(15) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "Clusters (Country-Industry)" "Adjusted R-Squared"))  	
				
		}
		
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_8_Panel_A

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		08/03/2020													****
**** Program:	OECD productivity data										****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, original("`directory'\Data\DATA.txt")

/******************************************************************************/
/* (1) Import OECD Industry Data										 	  */
/******************************************************************************/

/* Delete */
cap rm OECD.dta

/* Import */
import delimited using DATA.txt, delimiter("|") varnames(1) case(lower) clear

/* Keep relevant variables */
drop flag
keep if var == "VALU" | var == "LABR" | var == "GFCF"

/* Loop over variables */
local variables = "VALU LABR GFCF"
foreach var of local variables {

	/* Preserve */
	preserve 

		/* Keep relevant observations */
		keep if var == "`var'"
		
		/* Name */
		local name = lower("`var'")
		
		/* Rename */
		rename value `name'
		
		/* Drop */
		drop var
		
		/* Merge */
		//cd "`directory'\Data"
		cap merge 1:1 cou ind year using OECD
		cap drop _merge
		
		/* Save */
		save OECD, replace
	
	/* Restore */
	restore
	
}

/* Data */
use OECD, clear

/* Rename */
rename ind industry

/* Industry */
drop if ///
	industry == "ENERGYP" | ///
	industry == "ICTMS" | ///
	regexm(industry, "DT") == 1 | ///
	regexm(industry, "X") == 1
replace industry = substr(industry, 2,.)

/* Country */
gen country = "Australia" if cou == "AUS"
replace country = "Austria" if cou == "AUT"
replace country = "Belgium" if cou == "BEL"
replace country = "Canada" if cou == "CAN"
replace country = "Switzerland" if cou == "CHE"
replace country = "Chile" if cou == "CHL"
replace country = "Costa Rica" if cou == "CRI"
replace country = "Czech Republic" if cou == "CZE"
replace country = "Germany" if cou == "DEU"
replace country = "Denmark" if cou == "DNK"
replace country = "Spain" if cou == "ESP"
replace country = "Estonia" if cou == "EST"
replace country = "Finland" if cou == "FIN"
replace country = "France" if cou == "FRA"
replace country = "United Kingdom" if cou == "GBR"
replace country = "Greece" if cou == "GRC"
replace country = "Hungary" if cou == "HUN"
replace country = "Ireland" if cou == "IRL"
replace country = "Iceland" if cou == "ISL"
replace country = "Israel" if cou == "ISR"
replace country = "Italy" if cou == "ITA"
replace country = "Japan" if cou == "JPN"
replace country = "South Korea" if cou == "KOR"
replace country = "Lithuania" if cou == "LTU"
replace country = "Luxembourg" if cou == "LUX"
replace country = "Latvia" if cou == "LVA"
replace country = "Mexico" if cou == "MEX"
replace country = "Netherlands" if cou == "NLD"
replace country = "Norway" if cou == "NOR"
replace country = "New Zealand" if cou == "NZL"
replace country = "Poland" if cou == "POL"
replace country = "Portugal" if cou == "PRT"
replace country = "Slovakia" if cou == "SVK"
replace country = "Slovenia" if cou == "SVN"
replace country = "Sweden" if cou == "SWE"
replace country = "Turkey" if cou == "TUR"
replace country = "United States" if cou == "USA"
drop cou

/* Label */
label var country "Country"
label var industry "Industry"
label var year "Year"
label var valu "Value added, current prices (m national currency)"
label var labr "Labour costs (compensation of employees) (m national currency)"
label var gfcf "Gross fixed capital formation, current price (m national currency)"

/* Sample */
keep if year >= 2000 & year <= 2015

/* Order */
order country industry year

/* Sort */
sort country industry year

/* Save */
save OECD, replace

/* Project */
project, creates("`directory'\Data\OECD.dta")

/******************************************************************************/
/* (2) OECD Industries (broad ISIC 4)										  */
/******************************************************************************/

/* Data */
use Scope_2, clear

/* Rename */
rename industry industry_nace

/* Generate broad ISIC 4 */
gen industry = ""
replace industry = "01T03" if industry_nace >= 1 & industry_nace <= 3
replace industry = "05T06" if industry_nace >= 5 & industry_nace <= 6
replace industry = "07T08" if industry_nace >= 7 & industry_nace <= 8
replace industry = "09" if industry_nace == 9
replace industry = "10T12" if industry_nace >= 10 & industry_nace <= 12
replace industry = "13T15" if industry_nace >= 13 & industry_nace <= 15
replace industry = "16" if industry_nace == 16
replace industry = "17T18" if industry_nace >= 17 & industry_nace <= 18
replace industry = "19" if industry_nace == 19
replace industry = "20T21" if industry_nace >= 20 & industry_nace <= 21
replace industry = "22" if industry_nace == 22
replace industry = "23" if industry_nace == 23
replace industry = "24" if industry_nace == 24
replace industry = "25" if industry_nace == 25
replace industry = "26" if industry_nace == 26
replace industry = "27" if industry_nace == 27
replace industry = "28" if industry_nace == 28
replace industry = "29" if industry_nace == 29
replace industry = "30" if industry_nace == 30
replace industry = "31T33" if industry_nace >= 31 & industry_nace <= 33
replace industry = "35T39" if industry_nace >= 35 & industry_nace <= 39
replace industry = "41T43" if industry_nace >= 41 & industry_nace <= 43
replace industry = "45T47" if industry_nace >= 45 & industry_nace <= 47
replace industry = "49T53" if industry_nace >= 49 & industry_nace <= 53
replace industry = "55T56" if industry_nace >= 55 & industry_nace <= 56
replace industry = "58T60" if industry_nace >= 58 & industry_nace <= 60
replace industry = "61" if industry_nace == 61
replace industry = "62T63" if industry_nace >= 62 & industry_nace <= 63
replace industry = "64T66" if industry_nace >= 64 & industry_nace <= 66
replace industry = "68" if industry_nace == 68
replace industry = "69T82" if industry_nace >= 69 & industry_nace <= 82
replace industry = "84" if industry_nace == 84
replace industry = "84" if industry_nace == 85
replace industry = "86T88" if industry_nace >= 86 & industry_nace <= 88
replace industry = "90T96" if industry_nace >= 90 & industry_nace <= 96
replace industry = "97T98" if industry_nace >= 97 & industry_nace <= 98
label var industry "Industry (OECD)"

/* Aggregate scopes to broad ISIC 4 */
collapse (mean) mc_scope mc_audit, by(country industry year)

/* Save */
save Scope_OECD, replace

/* Project */
project, creates("`directory'\Data\Scope_OECD.dta")

********************************************************************************
**** (3) Combine OECD and Scopes											****
********************************************************************************

/* Data */
use OECD, clear

/* Scope */
		
	/* Merge: own scope */
	merge m:1 country industry year using Scope_OECD
	drop if _merge == 2
	drop _merge
	
/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Cluster */
egen cluster = group(c i)
label var cluster "Cluster (country-industry)"

********************************************************************************
**** (4) Generate relevant variables										****
********************************************************************************

/* Panel */
xtset cluster year

/* Combined scope */
egen min = rowmin(mc_scope mc_audit)
label var min "Reporting and Auditing"

/* Productivity */

	/* log */
	gen value = ln(valu)
	gen lp = ln(valu) - ln(labr)
	gen tfp = ln(valu) - 0.7*ln(labr) - 0.3*ln(gfcf)
	gen growth = ln(valu) - ln(l.valu)
	
********************************************************************************
**** (5) Regression analysis												****
********************************************************************************

/* Keep relevant period */
keep if year >= 2001 & year <= 2015

/* Variable list */

	/* Parameters*/
	local FE = "c##year i##year"	
	local Cluster = "cluster"
	
	/* All outcomes */
	local Outcomes = "value lp tfp growth"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_8_Panel_B.smcl, replace smcl name(Table_8_Panel_B) 

/* Industry Level */
foreach y of varlist `Outcomes' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if mc_scope!=., a(`FE') residual(r_`y')
			qui reghdfe mc_scope if `y'!=., a(`FE') residual(r_mc_scope)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		

			/* Estimation */			
			qui reghdfe `y' mc_scope, a(`FE') cluster(`Cluster')    
				est store M1	
				
		}
		
	/* Restore */
	restore
	
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if min!=., a(`FE') residual(r_`y')
			qui reghdfe min if `y'!=., a(`FE') residual(r_min)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)

			qui sum r_min, d
			qui replace min = . if r_min < r(p1) | r_min > r(p99)
			
			/* Estimation */
			qui reghdfe `y' min, a(`FE') cluster(`Cluster')    
				est store M2
				
			/* Output */
			estout M1 M2, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("COUNTRY-INDUSTRY LEVEL: `y_label'") ///
				varlabels(mc_scope "Standardized Reporting Scope" min "Standardized Reporting and Auditing Scope") ///				
				mlabels(, depvars) varwidth(45) modelwidth(15) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "Clusters (Country-Industry)" "Adjusted R-Squared"))  	
				
		}
		
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_8_Panel_B

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		08/03/2020													****
**** Program:	OECD productivity data										****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off
set maxvar 15000

**** Seed ****
set seed 1234

**** Directory ****

/* Working directory */
project, doinfo
local directory = "`r(pdir)'"
cd "`directory'\Data"

/* Project */
project, original("`directory'\Data\WIOD_SEA_Nov16.xlsx")

/******************************************************************************/
/* (1) Import WIOD Socio Economic Data									 	  */
/******************************************************************************/

/* Delete */
cap rm WIOD.dta

/* Import */
import excel using WIOD_SEA_Nov16.xlsx, sheet("DATA") firstrow case(lower) clear

/* Rename variables */
local year = 2000
foreach var of varlist e-s {
	
	/* Rename */
	rename `var' v`year'
	
	/* Year */
	local year = `year' + 1

}

/* Id */
egen i = group(country variable code)

/* Reshape */
reshape long v, i(i) j(year)

/* Drop */
drop i

/* Destring */
destring v, force replace

/* Loop over variables */
local variables = "CAP LAB VA"
foreach var of local variables {

	/* Preserve */
	preserve 

		/* Keep relevant observations */
		keep if variable == "`var'"
		
		/* Name */
		local name = lower("`var'")
		
		/* Rename */
		rename v `name'
		
		/* Drop */
		drop variable
		
		/* Merge */
		//cd "`directory'\Data"
		cap merge 1:1 country code year using WIOD
		cap drop _merge
		
		/* Save */
		save WIOD, replace
	
	/* Restore */
	restore
	
}

/* Data */
use WIOD, clear

/* Country */
replace country = "Australia" if country == "AUS"
replace country = "Austria" if country == "AUT"
replace country = "Belgium" if country == "BEL"
replace country = "Bulgaria" if country == "BGR"
replace country = "Brazil" if country == "BRA"
replace country = "Canada" if country == "CAN"
replace country = "Switzerland" if country == "CHE"
replace country = "China" if country == "CHN"
replace country = "Cyprus" if country == "CYP"
replace country = "Czech Republic" if country == "CZE"
replace country = "Germany" if country == "DEU"
replace country = "Denmark" if country == "DNK"
replace country = "Spain" if country == "ESP"
replace country = "Estonia" if country == "EST"
replace country = "Finland" if country == "FIN"
replace country = "France" if country == "FRA"
replace country = "United Kingdom" if country == "GBR"
replace country = "Greece" if country == "GRC"
replace country = "Croatia" if country == "HRV"
replace country = "Hungary" if country == "HUN"
replace country = "Indonesia" if country == "IDN"
replace country = "India" if country == "IND"
replace country = "Ireland" if country == "IRL"
replace country = "Italy" if country == "ITA"
replace country = "Japan" if country == "JPN"
replace country = "South Korea" if country == "KOR"
replace country = "Lithuania" if country == "LTU"
replace country = "Luxembourg" if country == "LUX"
replace country = "Latvia" if country == "LVA"
replace country = "Mexico" if country == "MEX"
replace country = "Malta" if country == "MLT"
replace country = "Netherlands" if country == "NLD"
replace country = "Norway" if country == "NOR"
replace country = "Poland" if country == "POL"
replace country = "Portugal" if country == "PRT"
replace country = "Romania" if country == "ROU"
replace country = "Russia" if country == "RUS"
replace country = "Slovakia" if country == "SVK"
replace country = "Slovenia" if country == "SVN"
replace country = "Sweden" if country == "SWE"
replace country = "Turkey" if country == "TUR"
replace country = "Taiwan" if country == "TWN"
replace country = "United States" if country == "USA"

/* Industry */
rename code industry

/* Labels */
label var year "Year"
label var va "Gross value added at current basic prices (in m of national currency)"
label var lab "Labour compensation (in m of national currency)"	
label var cap "Capital compensation (in m of national currency)"		

/* Order */
order country industry year

/* Sort */
sort country industry year

/* Save */
save WIOD, replace

/* Project */
project, creates("`directory'\Data\WIOD.dta")

/******************************************************************************/
/* (2) WIOD Industries (broad ISIC 4)										  */
/******************************************************************************/

/* Data */
use Scope_2, clear

/* Rename */
rename industry industry_nace

/* Generate broad ISIC 4 */
gen industry = ""
replace industry = "A01" if industry_nace == 1
replace industry = "A02" if industry_nace == 2
replace industry = "A03" if industry_nace == 3
replace industry = "B" if industry_nace >= 5 & industry_nace <= 9
replace industry = "C10-C12" if industry_nace >= 10 & industry_nace <= 12
replace industry = "C13-C15" if industry_nace >= 13 & industry_nace <= 15
replace industry = "C16" if industry_nace == 16
replace industry = "C17" if industry_nace == 17
replace industry = "C18" if industry_nace == 18
replace industry = "C19" if industry_nace == 19
replace industry = "C20" if industry_nace == 20
replace industry = "C21" if industry_nace == 21
replace industry = "C22" if industry_nace == 22
replace industry = "C23" if industry_nace == 23
replace industry = "C24" if industry_nace == 24
replace industry = "C25" if industry_nace == 25
replace industry = "C26" if industry_nace == 26
replace industry = "C27" if industry_nace == 27
replace industry = "C28" if industry_nace == 28
replace industry = "C29" if industry_nace == 29
replace industry = "C30" if industry_nace == 30
replace industry = "C31_C32" if industry_nace >= 31 & industry_nace <= 32
replace industry = "C33" if industry_nace == 33
replace industry = "D35" if industry_nace == 35
replace industry = "E36" if industry_nace == 36
replace industry = "E37-E39" if industry_nace >= 37 & industry_nace <= 39
replace industry = "F" if industry_nace >= 41 & industry_nace <= 43
replace industry = "G45" if industry_nace == 45
replace industry = "G46" if industry_nace == 46
replace industry = "G47" if industry_nace == 47
replace industry = "H49" if industry_nace == 49
replace industry = "H50" if industry_nace == 50
replace industry = "H51" if industry_nace == 51
replace industry = "H52" if industry_nace == 52
replace industry = "H53" if industry_nace == 53
replace industry = "I" if industry_nace >= 55 & industry_nace <= 56
replace industry = "J58" if industry_nace == 58
replace industry = "J59_J60" if industry_nace >= 59 & industry_nace <= 60
replace industry = "J61" if industry_nace == 61
replace industry = "J62_J63" if industry_nace >= 62 & industry_nace <= 63
replace industry = "K64" if industry_nace == 64
replace industry = "K65" if industry_nace == 65
replace industry = "K66" if industry_nace == 66
replace industry = "L68" if industry_nace == 68
replace industry = "M69_M70" if industry_nace >= 69 & industry_nace <= 70
replace industry = "M71" if industry_nace == 71
replace industry = "M72" if industry_nace == 72
replace industry = "M73" if industry_nace == 73
replace industry = "M74_M75" if industry_nace >= 74 & industry_nace <= 75
replace industry = "N" if industry_nace >= 77 & industry_nace <= 82
replace industry = "O84" if industry_nace == 84
replace industry = "P85" if industry_nace == 85
replace industry = "Q" if industry_nace >= 86 & industry_nace <= 88
replace industry = "R_S" if industry_nace >= 90 & industry_nace <= 96
replace industry = "T" if industry_nace >= 97 & industry_nace <= 98
replace industry = "U" if industry_nace == 99
label var industry "Industry (WIOD)"

/* Aggregate scopes to broad ISIC 4 */
collapse (mean) mc_scope mc_audit, by(country industry year)

/* Save */
save Scope_WIOD, replace

/* Project */
project, creates("`directory'\Data\Scope_WIOD.dta")

********************************************************************************
**** (3) Combine WIOD and Scopes											****
********************************************************************************

/* Data */
use WIOD, clear

/* Scope */
		
	/* Merge: own scope */
	merge m:1 country industry year using Scope_WIOD
	drop if _merge == 2
	drop _merge
	
/* Country */
egen c = group(country)
label var c "Country ID"

/* Industry */
egen i = group(industry)
label var i "Industry ID"

/* Cluster */
egen cluster = group(c i)
label var cluster "Cluster (country-industry)"

********************************************************************************
**** (4) Generate relevant variables										****
********************************************************************************

/* Panel */
xtset cluster year

/* Combined scope */
egen min = rowmin(mc_scope mc_audit)
label var min "Reporting and Auditing"

/* Productivity */

	/* log */
	gen value = ln(va)
	gen lp = ln(va) - ln(lab)
	gen tfp = ln(va) - 0.7*ln(lab) - 0.3*ln(cap)
	gen growth = ln(valu) - ln(l.valu)
	
********************************************************************************
**** (5) Regression analysis												****
********************************************************************************

/* Keep relevant period */
keep if year >= 2001 & year <= 2015

/* Variable list */

	/* Parameters*/
	local FE = "c##year i##year"	
	local Cluster = "cluster"
	
	/* All outcomes */
	local Outcomes = "value lp tfp growth"

/* Log file: open */
cd "`directory'\Output\Logs"
log using Table_8_Panel_C.smcl, replace smcl name(Table_8_Panel_C) 

/* Industry Level */
foreach y of varlist `Outcomes' {
		
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if mc_scope!=., a(`FE') residual(r_`y')
			qui reghdfe mc_scope if `y'!=., a(`FE') residual(r_mc_scope)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)
				
			qui sum r_mc_scope, d
			qui replace mc_scope = . if r_mc_scope < r(p1) | r_mc_scope > r(p99)		

			/* Estimation */			
			qui reghdfe `y' mc_scope, a(`FE') cluster(`Cluster')    
				est store M1	
				
		}
		
	/* Restore */
	restore
	
	/* Preserve */
	preserve
		
		/* Capture */
		capture noisily {

			/* Label */
			local y_label: variable label `y'

			/* Truncation */
			qui reghdfe `y' if min!=., a(`FE') residual(r_`y')
			qui reghdfe min if `y'!=., a(`FE') residual(r_min)
				
			qui sum r_`y', d
			qui replace `y' = . if r_`y' < r(p1) | r_`y' > r(p99)

			qui sum r_min, d
			qui replace min = . if r_min < r(p1) | r_min > r(p99)
			
			/* Estimation */
			qui reghdfe `y' min, a(`FE') cluster(`Cluster')    
				est store M2
				
			/* Output */
			estout M1 M2, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label title("COUNTRY-INDUSTRY LEVEL: `y_label'") ///
				varlabels(mc_scope "Standardized Reporting Scope" min "Standardized Reporting and Auditing Scope") ///				
				mlabels(, depvars) varwidth(45) modelwidth(15) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Observations" "Clusters (Country-Industry)" "Adjusted R-Squared"))  	
				
		}
		
	/* Restore */
	restore
	
}

/* Log file: close */
log close Table_8_Panel_C

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Master file (of "project" program)							****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Directory ****
project, doinfo
local master = "`r(pdir)'"


********************************************************************************
**** (1) Setting up STATA 													****
********************************************************************************

/* Installing external programs */
project, do(Dofiles/External_programs.do)


********************************************************************************
**** (2) Construct Data & Run Analyses										****
********************************************************************************

/* EU KLEMS sample */
project, do(Dofiles/KLEMS.do)

/* OECD sample */
project, do(Dofiles/OECD.do)

/* WIOD sample */
project, do(Dofiles/WIOD.do)

********************************************************************************
**** Title: 	Industry-wide Effects of Financial-Reporting Regulation		****
**** Author:	M. Breuer													****
**** Date:		01/30/2017													****
**** Program:	Setup of "project" program	(National Statistics)			****
********************************************************************************

**** Preliminaries ****
version 15.1
clear all
set more off

**** Master directory ****
local master = "...\Project_Statistics\Programs" // please insert/adjust directory path

********************************************************************************
**** (0) Install external program ("project")								****
********************************************************************************

**** Install ****
ssc install project

********************************************************************************
**** (1) Setup and building project: Local									****
********************************************************************************

**** Setup ****
cap project, setmaster("`master'\Master_Statistics.do")

**** Build ****
cap noisily project Master_Statistics, build

