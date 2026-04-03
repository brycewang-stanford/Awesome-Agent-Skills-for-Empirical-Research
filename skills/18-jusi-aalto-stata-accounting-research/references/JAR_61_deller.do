
**************************************************************************************************************************************************************************************************************************
* DELLER: BEYOND PERFORMANCE: DOES ASSESSED POTENTIAL MATTER TO EMPLOYEES' VOLUNTARY DEPARTURE DECISIONS *
* PROGRAM 1 OF 2 *
* Note that specific country names and the local currency have been replaced and any company-specific terminology has been modified so as to protect the confidentiality of the company    
**************************************************************************************************************************************************************************************************************************

clear

cd "/Volumes/cdeller_project/Beyond Performance Project/_Final code_JAR"

version 15
clear all
set more off

**************************************************************************************************************************************************************************************************************************
*** >>> PROGRAMS IN THIS FILE <<< ***
		* PROGRAM 1: 2008 Data
		* PROGRAM 2: 2009 Data
		* PROGRAM 3: 2010 Data
		* PROGRAM 4: 2011 Data
		* PROGRAM 5: 2012 Data
		* PROGRAM 6: 2013 Data
		* PROGRAM 7: 2014 Data
		* PROGRAM 8: 2015 Data
		* PROGRAM 9: 2009-2014 Exit Data
		* PROGRAM 10: 2015 Exit Data
		* PROGRAM 11: Append 2008-2015 Data
		* PROGRAM 12: ML0 Data
		* PROGRAM 13: Additional Ratings Data
		* PROGRAM 14: Combined 2008-2015 Data -- Retain one observation per PersonID/Year
		* PROGRAM 15: Merge Additional Rating Data to Latest 2008-2015 File
		* PROGRAM 16: Combined Exit Data - Retain one observation per PersonID/Year
**************************************************************************************************************************************************************************************************************************

**************************************************************************************************************************************************************************************************************************
* PROGRAM 1: 2008 Data
* Input file: "Data Request_C. Deller_2008+31.12.2015.xlsx"
* Steps:
	* 1.1 Import excel spreadsheet and save as dta file
	* 1.2 Rename variables (to ensure consistency of variable names across files to be appended)
	* 1.3 Format variables
	* 1.4 Create year variable=2008
	* 1.5 Save output file
* Output file: "2008 Data.dta"
**************************************************************************************************************************************************************************************************************************

	** Excel **
	* Copy and paste "Data Request_C. Deller_2008+31.12.2015.xlsx", and rename copy as "Data Request_C. Deller_2008+31.12.2015_no password.xlsx" 
	* Open "Data Request_C. Deller_2008+31.12.2015_no password.xlsx" - File > Save As > Options (remove password to open) > OK > Save > Replace

	* 1.1 Import excel spreadsheet and save as dta file
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-02-09_2008 Data_Updated 2015 Data/Data Request_C.Deller_2008+31.12.2015_no password.xlsx", sheet("2008") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2008_no password.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2008_no password.dta"

	* 1.2 Rename variables (to ensure consistency of variable names across files to be appended)
	rename HomeCountryIncaseofExpats HomeCountryExpats
	rename HostCountryIncaseofExpats HostCountryExpats  
	rename STIpayoutin[Currency] STIin[Currency]

	* 1.3 Format variables
	tab PercentageofFullPartTime
	replace PercentageofFullPartTime="" if PercentageofFullPartTime=="#" 
	destring(PercentageofFullPartTime), replace

	replace Exitdate="" if Exitdate=="#"
	rename Exitdate Exitdate_2
	gen D_MMDDYYYY=0
	replace D_MMDDYYYY = 1 if strmatch(Exitdate_2, "*/*") 
	generate Exitdate=date(Exitdate_2,"MDY") if D_MMDDYYY==1
	gen D_DDMMYYYY=0
	replace D_DDMMYYYY = 1 if strmatch(Exitdate_2, "*.*") 
	replace Exitdate=date(Exitdate_2,"DMY") if D_DDMMYYY==1
	count if Exitdate==. & Exitdate_2!=""
	format Exitdate %tdnn/dd/CCYY

	rename SupervisorID ORIG_SupervisorID_Input
	tostring ORIG_SupervisorID_Input, gen(SupervisorID)  

	rename PersonID ORIG_PersonID_Input
	tostring ORIG_PersonID_Input, gen(PersonID)  

	* 1.4 Create year variable=2008
	gen Year=2008

	* 1.5 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2008 Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 2: 2009 Data
* Input file: "Data Request_C. Deller_2009-2010_no password.xlsx"
* Steps:
	* 2.1 Import excel spreadsheet and save as dta file
	* 2.2 Rename variables (to ensure consistency of variable names across files to be appended)
	* 2.3 Format variables
	* 2.4 Create year variable=2009
	* 2.5 Save output file
* Output file: "2009 Data.dta"
**************************************************************************************************************************************************************************************************************************

	** Excel **
	* Copy and paste "Data Request_C. Deller_2009-2010.xlsx", and rename copy as "Data Request_C. Deller_2009-2010_no password.xlsx" 
	* Open "Data Request_C. Deller_2009-2010_no password.xlsx" - File > Save As > Options (remove password to open) > OK > Save > Replace

	* 2.1 Import excel spreadsheet and save as dta file
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-01-25_2009-2010 Data/Data Request_C.Deller_2009-2010_no password.xlsx", sheet("2009 ") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2009_no password.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2009_no password.dta"

	* 2.2 Rename variables (to ensure consistency of variable names across files to be appended)
	rename PersonIDCP PersonID
	rename YearofBirth BirthYear
	rename Gender GenderKey
	rename EducationNameofInstitute NameofEducationInstitute
	rename EducationCountryofInstitute CountryofEducationInstitute

	rename EntryDate Entrydate
	rename ExitDate Exitdate
	rename PersonnelArea LocationofEmployment
	rename Country CountryofEmployment
	rename Region RegionofEmployment
	rename EmployeeGroup Employeegroup
	rename EmpSubgroupGlobal MgmtLevel
	rename CurrentMLDate MgmtLevelDate
	rename CapUtilizationLvl PercentageofFullPartTime
	rename FullTimePartTime FullPartTime
	rename FunctionCode1 Function
	rename OrganizationalUnit OrgUnit

	rename BaseSalaryin[Currency] ABSin[Currency]
	rename Comparatio SalaryPosition_inSalaryBand

	rename SupervisorPersonIDCP SupervisorID

	rename Rating2008 Rating_PastYear

	* 2.3 Format variables
	tab PercentageofFullPartTime
	replace PercentageofFullPartTime="" if PercentageofFullPartTime=="#" 
	destring(PercentageofFullPartTime), replace

	replace SupervisorID="" if SupervisorID=="#"

	rename PersonID ORIG_PersonID_Input
	tostring ORIG_PersonID_Input, gen(PersonID) 

	* 2.4 Create year variable=2009
	gen Year=2009

	* 2.5 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2009 Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 3: 2010 Data
* Input file: "Data Request_C. Deller_2009-2010_no password.xlsx"
* Steps:
	* 3.1 Import excel spreadsheet and save as dta file
	* 3.2 Rename variables (to ensure consistency of variable names across files to be appended)
	* 3.3 Format variables
	* 3.4 Create year variable=2010
	* 3.5 Save output file
* Output file: "2010 Data.dta"
**************************************************************************************************************************************************************************************************************************

	* 3.1 Import excel spreadsheet and save as dta file
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-01-25_2009-2010 Data/Data Request_C.Deller_2009-2010_no password.xlsx", sheet("2010 ") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2010_no password.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2010_no password.dta"

	* 3.2 Rename variables (to ensure consistency of variable names across files to be appended)
	rename PersonIDCP PersonID
	rename YearofBirth BirthYear
	rename Gender GenderKey
	rename EducationNameofInstitute NameofEducationInstitute
	rename EducationCountryofInstitute CountryofEducationInstitute

	rename EntryDate Entrydate
	rename ExitDate Exitdate
	rename PersonnelArea LocationofEmployment
	rename Country CountryofEmployment
	rename Region RegionofEmployment
	rename EmployeeGroup Employeegroup
	rename EmpSubgroupGlobal MgmtLevel
	rename CurrentMLDate MgmtLevelDate
	rename CapUtilizationLvl PercentageofFullPartTime
	rename FullTimePartTime FullPartTime
	rename FunctionCode1 Function
	rename OrganizationalUnit OrgUnit

	rename BaseSalaryin[Currency] ABSin[Currency]
	rename SalaryIncreaseasaofmerit SalaryIncrease_percofMB
	rename Comparatio SalaryPosition_inSalaryBand

	rename SupervisorPersonIDCP SupervisorID

	rename Rating2009 Rating_PastYear

	* 3.3 Format variables
	tab PercentageofFullPartTime
	replace PercentageofFullPartTime="" if PercentageofFullPartTime=="#" 
	destring(PercentageofFullPartTime), replace

	replace SupervisorID="" if SupervisorID=="#"

	replace SalaryIncrease_percofMB=SalaryIncrease_percofMB*100
	format SalaryIncrease_percofMB %10.0g

	rename PersonID ORIG_PersonID_Input
	tostring ORIG_PersonID_Input, gen(PersonID)

	* 3.4 Create year variable=2010
	gen Year=2010

	* 3.5 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2010 Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 4: 2011 Data
* Input file: "Data Request_C. Deller_2011_no password.xlsx"
* Steps:
	* 4.1 Import excel spreadsheet and save as dta file
	* 4.2 Rename variables (to ensure consistency of variable names across files to be appended)
	* 4.3 Format variables
	* 4.4 Create year variable=2011
	* 4.5 Save output file
* Output file: "2011 Data.dta"
**************************************************************************************************************************************************************************************************************************

	** Excel **
	* Copy and paste "Data Request_C. Deller_2011.xlsx", and rename copy as "Data Request_C. Deller_2011_no password.xlsx" 
	* Open "Data Request_C. Deller_2011_no password.xlsx" - File > Save As > Options (remove password to open) > OK > Save > Replace

	* 4.1 Import excel spreadsheet and save as dta file
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-01-22_2011 Data/Data Request_C.Deller_2011_no password.xlsx", sheet("2011") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2011_no password.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2011_no password.dta"

	* 4.2 Rename variables (to ensure consistency of variable names across files to be appended)
	rename PersonIDCP PersonID
	rename YearofBirth BirthYear
	rename Gender GenderKey
	rename NameofInstitute NameofEducationInstitute
	rename Degree EducationDegree
	rename CountryofInstitute CountryofEducationInstitute

	rename EntryDate Entrydate
	rename ExitDate Exitdate
	rename PersonnelArea LocationofEmployment
	
	rename Country CountryofEmployment
	rename Region RegionofEmployment
	rename EmployeeGroup Employeegroup
	rename EmpSubgroupGlobal MgmtLevel
	rename CurrentMLDate MgmtLevelDate
	rename CapUtilizationLvl PercentageofFullPartTime
	rename FullTimePartTime FullPartTime
	rename FunctionCode1 Function
	rename OrganizationalUnit OrgUnit

	rename BaseSalaryin[Currency] ABSin[Currency]
	rename SalaryIncreaseasaofmerit SalaryIncrease_percofMB
	rename Comparatio SalaryPosition_inSalaryBand

	rename SupervisorPersonIDCP SupervisorID
	rename PPADFSupervisorID PPADFSupervisorPersonID

	rename Rating2010 Rating_PastYear

	* 4.3 Format variables
	tab PercentageofFullPartTime
	replace PercentageofFullPartTime="" if PercentageofFullPartTime=="#" 
	destring(PercentageofFullPartTime), replace

	replace SupervisorID="" if SupervisorID=="#"

	replace SalaryIncrease_percofMB="" if SalaryIncrease_percofMB=="-"
	destring(SalaryIncrease_percofMB), replace
	replace SalaryIncrease_percofMB=SalaryIncrease_percofMB*100
	format SalaryIncrease_percofMB %10.0g

	rename PersonID ORIG_PersonID_Input
	tostring ORIG_PersonID_Input, gen(PersonID)

	* 4.4 Create year variable=2011
	gen Year=2011

	* 4.5 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2011 Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 5: 2012 Data
* Input file: "Data Request_C. Deller_2012_no password.xlsx"
* Steps:
	* 5.1 Import excel spreadsheet and save as dta file
	* 5.2 Rename variables (to ensure consistency of variable names across files to be appended)
	* 5.3 Format variables
	* 5.4 Drop blank variable
	* 5.5 Create year variable=2012
	* 5.6 Save output file
* Output file: "2012 Data.dta"
**************************************************************************************************************************************************************************************************************************

	** Excel **
	* Copy and paste "Data Request_C. Deller_2012.xlsx", and rename copy as "Data Request_C. Deller_2012_no password.xlsx" 
	* Open "Data Request_C. Deller_2012_no password.xlsx" - File > Save As > Options (remove password to open) > OK > Save > Replace

	* 5.1 Import excel spreadsheet and save as dta file
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-01-22_2012 Data/Data Request_C.Deller_2012_no password.xlsx", sheet("2012") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2012_no password.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2012_no password.dta"

	* 5.2 Rename variables (to ensure consistency of variable names across files to be appended)
	rename PersonIDCP PersonID
	rename YearofBirth BirthYear
	rename Gender GenderKey
	rename EducationNameofInstitute NameofEducationInstitute
	rename EducationCountryofInstitute CountryofEducationInstitute

	rename EntryDate Entrydate
	rename ExitDate Exitdate
	rename PersonnelArea LocationofEmployment
	rename Country CountryofEmployment
	rename Region RegionofEmployment
	rename EmployeeGroup Employeegroup
	rename EmpSubgroupGlobal MgmtLevel
	rename CurrentMLDate MgmtLevelDate
	rename CapUtilizationLvl PercentageofFullPartTime
	rename FullTimePartTime FullPartTime
	rename FunctionCode1 Function
	rename OrganizationalUnit OrgUnit

	rename BaseSalaryin[Currency] ABSin[Currency]
	rename SalaryIncreaseasaofmerit SalaryIncrease_percofMB
	rename Comparatio SalaryPosition_inSalaryBand

	rename SupervisorPersonIDCP SupervisorID
	rename PPADFSupervisorID PPADFSupervisorPersonID

	rename Rating2011 Rating_PastYear

	rename TotalTeamAchievment TeamTargetAchievement
	rename Individual1Achievement IndividualTargetAchievement1
	rename Individual2Achievement IndividualTargetAchievement2

	* 5.3 Format variables
	tab PercentageofFullPartTime
	replace PercentageofFullPartTime="" if PercentageofFullPartTime=="#" 
	destring(PercentageofFullPartTime), replace

	replace SupervisorID="" if SupervisorID=="#"

	replace SalaryIncrease_percofMB="" if SalaryIncrease_percofMB=="-"
	destring(SalaryIncrease_percofMB), replace
	replace SalaryIncrease_percofMB=SalaryIncrease_percofMB*100
	format SalaryIncrease_percofMB %10.0g

	replace OverallSTITA=OverallSTITA*100
	format OverallSTITA %10.0g

	rename PersonID ORIG_PersonID_Input
	tostring ORIG_PersonID_Input, gen(PersonID)

	* 5.4 Drop blank variable
	drop AY

	* 5.5 Create year variable=2012
	gen Year=2012

	* 5.6 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2012 Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 6: 2013 Data
* Input file: "Data Request_C. Deller_2013_no password.xlsx"
* Steps:
	* 6.1 Import excel spreadsheet and save as dta file
	* 6.2 Rename variables (to ensure consistency of variable names across files to be appended)
	* 6.3 Format variables
	* 6.4 Create year variable=2013
	* 6.5 Save output file
* Output file: "2013 Data.dta"
**************************************************************************************************************************************************************************************************************************

	** Excel **
	* Copy and paste "Data Request_C. Deller_2013.xlsx", and rename copy as "Data Request_C. Deller_2013_no password.xlsx" 
	* Open "Data Request_C. Deller_2013_no password.xlsx" - File > Save As > Options (remove password to open) > OK > Save > Replace

	* 6.1 Import excel spreadsheet and save as dta file
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-01-18_2013 Data/Data Request_C.Deller_2013_no password.xlsx", sheet("2013") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2013_no password.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2013_no password.dta"

	* 6.2 Rename variables (to ensure consistency of variable names across files to be appended)
	rename PersonIDCP PersonID
	rename YearofBirth BirthYear
	rename Gender GenderKey
	rename NameofInstitute NameofEducationInstitute
	rename Degree EducationDegree
	rename CountryofInstitute CountryofEducationInstitute

	rename EntryDate Entrydate
	rename ExitDate Exitdate
	rename PersonnelArea LocationofEmployment
	rename Country CountryofEmployment
	rename Region RegionofEmployment
	rename EmployeeGroup Employeegroup
	rename EmpSubgroupGlobal MgmtLevel
	rename CurrentMLDate MgmtLevelDate
	rename CapUtilizationLvl PercentageofFullPartTime
	rename FulltimeParttime FullPartTime
	rename FunctionCode1 Function
	rename OrganizationalUnit OrgUnit

	rename BaseSalaryin[Currency] ABSin[Currency]
	rename SalaryIncreaseasaofmerit SalaryIncrease_percofMB
	rename Comparatio SalaryPosition_inSalaryBand

	rename SupervisorPersonIDCP SupervisorID
	rename PPADFSupervisorID PPADFSupervisorPersonID

	rename Rating2012 Rating_PastYear

	rename TotalTeamAchievment TeamTargetAchievement
	rename Individual1Achievement IndividualTargetAchievement1
	rename Individual2Achievement IndividualTargetAchievement2

	* 6.3 Format variables
	tab PercentageofFullPartTime
	replace PercentageofFullPartTime="" if PercentageofFullPartTime=="#" 
	destring(PercentageofFullPartTime), replace

	replace SupervisorID="" if SupervisorID=="#"

	replace SalaryIncrease_percofMB=SalaryIncrease_percofMB*100
	format SalaryIncrease_percofMB %10.0g

	replace TeamTargetAchievement=TeamTargetAchievement*100
	format TeamTargetAchievement %10.0g

	replace OverallSTITA=OverallSTITA*100
	format OverallSTITA %10.0g

	rename PersonID ORIG_PersonID_Input
	tostring ORIG_PersonID_Input, gen(PersonID)

	* 6.4 Create year variable=2013
	gen Year=2013

	* 6.5 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2013 Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 7: 2014 Data
* Input file: "Data Request_C. Deller_2014_no password.xlsx"
* Steps:
	* 7.1 Import excel spreadsheet and save as dta file
	* 7.2 Rename variables (to ensure consistency of variable names across files to be appended)
	* 7.3 Format variables
	* 7.4 Create year variable=2014
	* 7.5 Save output file
* Output file: "2014 Data.dta"
**************************************************************************************************************************************************************************************************************************

	** Excel **
	* Copy and paste "Data Request_C. Deller_2014.xlsx", and rename copy as "Data Request_C. Deller_2014_no password.xlsx" 
	* Open "Data Request_C. Deller_2014_no password.xlsx" - File > Save As > Options (remove password to open) > OK > Save > Replace

	* 7.1 Import excel spreadsheet and save as dta file
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-01-15_2014 Data/Data Request_C.Deller_2014_no password.xlsx", sheet("2014") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2014_no password.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2014_no password.dta"

	* 7.2 Rename variables (to ensure consistency of variable names across files to be appended)
	rename Personnelarea LocationofEmployment
	rename Country CountryofEmployment
	rename Region RegionofEmployment 
	rename HomeCountry HomeCountryExpats
	rename Hostcountry HostCountryExpats  
	rename Employeesubgroup MgmtLevel
	rename UtilLvl PercentageofFullPartTime
	rename Orgunit OrgUnit

	rename SalaryincreaseasofMB SalaryIncrease_percofMB
	rename Comparatio SalaryPosition_inSalaryBand

	rename Rating2013 Rating_PastYear

	rename TeamAchievment TeamTargetAchievement
	rename Individual1Achievement IndividualTargetAchievement1
	rename Individual2Achievement IndividualTargetAchievement2

	* 7.3 Format variables
	replace SupervisorID="" if SupervisorID=="#"

	rename PPADFSupervisorPersonID ORIG_PPASupervisor_2014
	tostring ORIG_PPASupervisor_2014, gen(PPADFSupervisorPersonID)  

	replace OverallSTITA=OverallSTITA*100
	format OverallSTITA %10.0g

	replace SalaryIncrease_percofMB=SalaryIncrease_percofMB*100
	format SalaryIncrease_percofMB %10.0g

	rename PersonID ORIG_PersonID_Input
	tostring ORIG_PersonID_Input, gen(PersonID)

	* 7.4 Create year variable=2014
	gen Year=2014

	* 7.5 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2014 Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 8: 2015 Data 
* Input file: "Data Request_C. Deller_2008+31.12.2015.xlsx"
* Steps:
	* 8.1 Import excel spreadsheet and save as dta file
	* 8.2 Rename variables (to ensure consistency of variable names across files to be appended)
	* 8.3 Format variables
	* 8.4 Create year variable=2015
	* 8.5 Save output file
* Output file: "2015 Data.dta"
**************************************************************************************************************************************************************************************************************************

	* 8.1 Import excel spreadsheet and save as dta file
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-02-09_2008 Data_Updated 2015 Data/Data Request_C.Deller_2008+31.12.2015_no password.xlsx", sheet("2015") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2015_no password.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C.Deller_2015_no password.dta"

	* 8.2 Rename variables (to ensure consistency of variable names across files to be appended)
	rename PersonnelArea LocationofEmployment
	rename HomeCountryIncaseofExpats HomeCountryExpats
	rename HostCountryIncaseofExpats HostCountryExpats
	rename OrganizationUnit OrgUnit

	rename ABS ABSin[Currency]
	rename SalaryIncrease2015asapercen SalaryIncrease_percofMB 
	rename SalaryPositioninrespectiveSa SalaryPosition_inSalaryBand
	rename STIpayoutin[Currency] STIin[Currency]

	rename PPADFSupervisor PPADFSupervisorPersonID

	rename Rating2014 Rating_PastYear
	rename PerfQualityQuantityofPerf PerfQuality
	rename CustomerOrientation CustOr
	rename TeamworkCooperation Teamw
	rename PeopleManagementuntil2012 Peopleuntil2012
	rename Leadership Leader
	rename PotInitiativeDetermination PotInitiative
	rename DecisivenessRiskTaking Decisiv
	rename DrivingChangeInnovation Driving
	rename PerspectiveJudgement Perspec
	rename ConvincingInfluencing Convinc
	rename CoachingDevelopingPeople Coaching  

	rename PPA2014AreaofDevelopment Development_Area
	rename PPA2014DevAction Development_Actions

	* 8.3 Format variables
	replace SalaryIncrease_percofMB=SalaryIncrease_percofMB*100
	format SalaryIncrease_percofMB %10.0g

	replace Exitdate="" if Exitdate=="#"
	rename Exitdate Exitdate_2
	generate Exitdate=date(Exitdate_2,"DMY")
	format Exitdate %tdnn/dd/CCYY
	drop Exitdate_2

	rename PersonID ORIG_PersonID_Input
	tostring ORIG_PersonID_Input, gen(PersonID)

	* 8.4 Create year variable=2015
	gen Year=2015

	* 8.5 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2015 Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 9: 2009-2014 Exit Data
* Input file: "Data Request_C. Deller_Exits_no password.xlsx"
* Steps:
	* 9.1 Import excel spreadsheet and save as dta file
	* 9.2 Rename variables with _2014 (except PersonID) to ensure keep track of this data coming from an exit data file
	* 9.3 Format variables
	* 9.4 Create Year_Exit variable based on Exitdate
	* 9.5 Save output file
* Output file: "2009-2014 Exit Data.dta"
**************************************************************************************************************************************************************************************************************************

	** Excel **
	* Copy and paste "Data Request_C. Deller_Exits.xlsx", and rename copy as "Data Request_C. Deller_Exits_no password.xlsx" 
	* Open "Data Request_C. Deller_Exits_no password.xlsx" - File > Save As > Options (remove password to open) > OK > Save > Replace

	* 9.1 Import excel spreadsheet and save as dta file
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-01-22_Exits_2009-2014/Data Request_C.Deller_Exits_no password.xlsx", sheet("Exits_2009-2014") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C. Deller_Exits_no password.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C. Deller_Exits_no password.dta"

	* 9.2 Rename variables with _EXIT (except PersonID) to ensure keep track of this data coming from an exit data file
	rename PersonIDCP PersonID
	rename DateofAction Exitdate_EXIT
	rename ActionReasonGlobal ExitReasonCode_EXIT
	rename D ExitReason_EXIT
	rename EmployeeGroup Employeegroup_EXIT
	rename EmpSubgroupGlobal MgmtLevel_EXIT
	rename Region RegionofEmployment_EXIT
	rename Country CountryofEmployment_EXIT

	* 9.3 Format variables
	rename PersonID ORIG_PersonID_Input
	tostring ORIG_PersonID_Input, gen(PersonID)

	* 9.4 Create Year_Exit variable based on Exitdate
	gen Year_Exit=year(Exitdate_EXIT)
	tab Year_Exit
	* All 2009-2014 (inclusive)

	* 9.5 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2009-2014 Exit Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 10: 2015 Exit Data
* Input file: "Data Request_C. Deller_Exits 2015_no password.xlsx"
* Steps:
	* 10.1 Import excel spreadsheet and save as dta file
	* 10.2 Rename variables with _EXIT (except PersonID) to ensure keep track of this data coming from an exit data file (and to ensure consistency of variable names across files)
	* 10.3 Create Year_Exit variable based on Exitdate
	* 10.4 Save output file
* Output file: "2015 Exit Data.dta"
**************************************************************************************************************************************************************************************************************************

	** Excel **
	* Copy and paste "Data Request_C. Deller_Exits 2015.xlsx", and rename copy as "Data Request_C. Deller_Exits 2015_no password.xlsx" 
	* Open "Data Request_C. Deller_Exits 2015_no password.xlsx" - File > Save As > Options (remove password to open) > OK > Save > Replace

	* 10.1 Import excel spreadsheet and save as dta file
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-02-12_Exits 2015/Data Request_C.Deller_Exits 2015_no password.xlsx", sheet("Exits 2015") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C. Deller_Exits 2015_no password.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Data Request_C. Deller_Exits 2015_no password.dta"

	* 10.2 Rename variables with _EXIT (except PersonID) to ensure keep track of this data coming from an exit data file (and to ensure consistency of variable names across files)
	rename DateofAction Exitdate_EXIT
	rename ActionReasonGlobal ExitReasonCode_EXIT
	rename D ExitReason_EXIT
	rename EmployeeGroup Employeegroup_EXIT
	rename EmpSubgroupGlobal MgmtLevel_EXIT
	rename Region RegionofEmployment_EXIT
	rename Country CountryofEmployment_EXIT

	* 10.3 Create Year_Exit variable based on Exitdate
	gen Year_Exit=year(Exitdate_EXIT)
	tab Year_Exit
	* All 2015

	* 10.4 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2015 Exit Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 11: Append 2008-2015 Data 
* Input files: "2008 Data.dta";"2009 Data.dta"; "2010 Data.dta"; "2011 Data.dta"; "2012 Data.dta"; "2013 Data.dta"; 
* 			   "2014 Data.dta"; "2015 Data.dta"
* Steps:
	* 11.1 Append each of the 2008, 2009, 2010, 2011, 2012, 2013, 2014, and 2015 files
	* 11.2 Delete interim append files created during append process above
	* 11.3 Bring maximum exit date for an employee to all observations for the employee
	* 11.4 Create Year_Exit variable = Year+1 (in preparation for merging with exit data), or = Year if exit on last day of year but have an observation for the year 
	* 	   (& = . if calculated value is the same as a later observation since will merge exit data to the latest observation)
	* 11.5 Save output file
* Output file: "Combined 2008-2015 Data.dta"
**************************************************************************************************************************************************************************************************************************

	* 11.1 Append each of the 2008, 2009, 2010, 2011, 2012, 2013, 2014, and 2015 files (includes recreating Exit Date variable as necessary)
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2009 Data.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2010 Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 1.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 1.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2011 Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 2.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 2.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2012 Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 3.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 3.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2013 Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 4.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 4.dta"
	replace Exitdate="" if Exitdate=="#"
	gen New_Exitdate=date(Exitdate, "DMY")
	format New_Exitdate %tdnn/dd/CCYY 
	rename Exitdate Exitdate_ORIG
	rename New_Exitdate Exitdate
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 4_1.dta", replace 
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 4_1.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2014 Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 5.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 5.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2015 Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 6.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 6.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2008 Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined 2008-2015 Data_interim.dta", replace
	clear

	* 11.2 Delete interim append files created during append process above
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 1.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 2.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 3.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 4.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 4_1.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 5.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Append 6.dta"

	* 11.3 Bring maximum exit date for an employee to all observations for the employee
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined 2008-2015 Data_interim.dta"
	sort PersonID
	by PersonID: egen Max_Exitdate=max(Exitdate)

	* 11.4 Create Year_Exit variable = Year+1 (in preparation for merging with exit data), or = Year if exit on last day of year but have an observation for the year 
	*      (& = . if calculated value is the same as a later observation since will merge exit data to the latest observation)
	gen Year_Exit = Year+1
	gen LDOY=0
	replace LDOY=1 if day(Max_Exitdate)==31 & month(Max_Exitdate)==12
	gen OBS_LDOY=0 if LDOY==1
	gen LASTN=0
	sort PersonID Year
	by PersonID: replace LASTN=1 if _n==_N
	replace OBS_LDOY=1 if LDOY==1 & Year==year(Max_Exitdate) 
	tab OBS_LDOY
	replace Year_Exit = Year if OBS_LDOY==1 & LASTN==1
	sort PersonID Year
	by PersonID: replace Year_Exit=. if Year_Exit==Year_Exit[_n+1] & Year!=Year[_n+1] & LASTN!=1

	* 11.5 Save output file
	save  "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined 2008-2015 Data.dta", replace 
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 12: ML0 Data
* Input files: "ML 0 data 2009-2014_Annonymized_no password.xlsx"
* Steps:
	* 12.1 Import excel spreadsheets, create an ML_Year variable in each of the files, and save as dta files
	* 12.2 Append each of the 2009, 2010, 2011, 2012, 2013, 2014, and 2015 ML0 files 
	* 12.3 Rename variables (to ensure consistency of variable names with other files)
	* 12.4 Create Beg_ML0 and Beg_ML0_Yr variables = date / year the employee became an ML0
	* 12.5 Create a flag_ML variable which = 1 if Beg_ML0_Yr (i.e. the year the person became an ML0) differs across observations for an employee
	* 12.6 Since my dataset begins in 2008 and I want to identify employees promoted to the highest management level during my sample period, drop observations where the employee was an ML0 prior to 2009
	* 12.7 Keep only the first observation (year order) for each remaining ML 
	* 12.8 Save output file
* Output file: "Combined ML0 2009-2015 Data.dta"
**************************************************************************************************************************************************************************************************************************

	** Excel **
	* Copy and paste "ML 0 data 2009-2014_Annonymized.xlsx", and rename copy as "ML 0 data 2009-2014_Annonymized_no password.xlsx" 
	* Open "ML 0 data 2009-2014_Annonymized_no password.xlsx" - File > Save As > Options (remove password to open) > OK > Save > Replace

	* 12.1 Import excel spreadsheets, create an ML_Year variable in each of the files, and save as dta files
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2015-11-29_ML0 Data/ML 0 data 2009-2014_Annonymized_no password.xlsx", sheet("2009") firstrow
	gen ML_Year=2009
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2009_Annonymized_no password.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2015-11-29_ML0 Data/ML 0 data 2009-2014_Annonymized_no password.xlsx", sheet("2010") firstrow
	gen ML_Year=2010
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2010_Annonymized_no password.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2015-11-29_ML0 Data/ML 0 data 2009-2014_Annonymized_no password.xlsx", sheet("2011") firstrow
	gen ML_Year=2011
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2011_Annonymized_no password.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2015-11-29_ML0 Data/ML 0 data 2009-2014_Annonymized_no password.xlsx", sheet("2012") firstrow
	gen ML_Year=2012
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2012_Annonymized_no password.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2015-11-29_ML0 Data/ML 0 data 2009-2014_Annonymized_no password.xlsx", sheet("2013") firstrow
	gen ML_Year=2013
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2013_Annonymized_no password.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2015-11-29_ML0 Data/ML 0 data 2009-2014_Annonymized_no password.xlsx", sheet("2014") firstrow
	gen ML_Year=2014
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2014_Annonymized_no password.dta", replace

	* Despite the file name, it does include a tab for 2015 and the data included in this tab is more comprehensive than that provided in the original 2015 file ("2015-10-27_Data Template for ML0_input.xlsx")
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2015-11-29_ML0 Data/ML 0 data 2009-2014_Annonymized_no password.xlsx", sheet("2015") firstrow
	gen ML_Year=2015
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2015_Annonymized_no password.dta", replace

	* 12.2 Append each of the 2009, 2010, 2011, 2012, 2013, 2014, and 2015 ML0 files 
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2009_Annonymized_no password.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2010_Annonymized_no password.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 1.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 1.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2011_Annonymized_no password.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 2.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 2.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2012_Annonymized_no password.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 3.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 3.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2013_Annonymized_no password.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 4.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 4.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2014_Annonymized_no password.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 5.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 5.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0 data 2015_Annonymized_no password.dta"

	* 12.3 Rename variables (to ensure consistency of variable names with other files)
	rename PersonIDCP PersonID
	rename YearofBirth BirthYear
	rename Gender GenderKey

	rename EntryDate Entrydate
	rename ExitDate Exitdate
	rename EmpSubgroupGlobal MgmtLevel
	rename Country CountryofEmployment
	rename Region RegionofEmployment
	rename OrganizationalUnit OrgUnit
	rename BusinessUnit BU

	* 12.4 Create Beg_ML0 and Beg_ML0_Yr variables = date/year the employee became an ML0
	generate Beg_ML0=date(PromotionDateML0,"DMY")
	format Beg_ML0 %tdnn/dd/CCYY
	gen Beg_ML0_Yr=year(Beg_ML0)

	* 12.5 Create a flag_ML variable which = 1 if Beg_ML0_Yr (i.e. the year the person became an ML0) differs across observations for an employee
	sort PersonID ML_Year
	gen flag_ML=0
	by PersonID: replace flag_ML=1 if Beg_ML0_Yr!=Beg_ML0_Yr[_n-1] & _n!=1
	tab flag_ML
	* = 0 in all instances => GOOD

	* 12.6 Since my dataset begins in 2008 and I want to identify employees promoted to the highest management level during my sample period, drop observations where the employee was an ML0 prior to 2009
	drop if Beg_ML0_Yr<2009

	* 12.7 Keep only the first observation (year order) for each remaining ML 
	sort PersonID ML_Year
	by PersonID: gen ML_N = _n
	keep if ML_N==1

	* 12.8 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined ML0 2009-2015 Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 13: Additional Ratings Data
* Input files: "Rating list 2008, 2009.xls"; "[HR contact last name]_PerfPot2010-14_ake_anonim.xls"
* Steps:
	* 13.1 Import excel spreadsheets and save as dta files
	* 13.2 Create year variable in each file, rename variables as necessary to ensure consistency, format variables as needed, and save each file as a new output file
	* 13.3 Append updated/additional perf/pot ratings data files
	* 13.4 Drop headcount variable not needed
	* 13.5 Rename variables (except PersonID) with _ARating (Additional Rating Data)
	* 13.6 Drop if PersonID==., drop duplicates in terms of all variables, then identify duplicates in terms of PersonID & Year, and investigate
	* 13.7 Drop two duplicate observations, and check no duplicates remain
	* 13.8 Save output file
	* 13.9 Delete interim append files created during append process above
* Output file: "Combined Updated 2008-2014 Rating Data.dta"
**************************************************************************************************************************************************************************************************************************

	* 13.1 Import excel spreadsheets and save as dta files
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-02-12_2008_2009 Additional Rating Data/Rating list 2008, 2009.xls", sheet("Rating list 2008") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/PerfPot list 2008.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-02-12_2008_2009 Additional Rating Data/Rating list 2008, 2009.xls", sheet("Rating list 2009") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/PerfPot list 2009.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-03-18_Updated Rating Data/[HR contact last name]_PerfPot2010-14_ake_anonim.xls", sheet("2010") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2010 Rating.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-03-18_Updated Rating Data/[HR contact last name]_PerfPot2010-14_ake_anonim.xls", sheet("2011") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2011 Rating.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-03-18_Updated Rating Data/[HR contact last name]_PerfPot2010-14_ake_anonim.xls", sheet("2012") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2012 Rating.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-03-18_Updated Rating Data/[HR contact last name]_PerfPot2010-14_ake_anonim.xls", sheet("2013") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2013 Rating.dta", replace

	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Received/2016-03-18_Updated Rating Data/[HR contact last name]_PerfPot2010-14_ake_anonim.xls", sheet("2014") firstrow
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2014 Rating.dta", replace

	* 13.2 Create year variable in each file, rename variables as necessary to ensure consistency, format variables as needed, and save each file as a new output file
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/PerfPot list 2008.dta"
	rename RatingFinal Rating
	gen Year=year(RatingDate)
	drop RatingDate
	replace PersonID="" if PersonID=="#"
	save  "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Additional 2008 Rating Data.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/PerfPot list 2009.dta"
	rename RatingFinal Rating
	gen Year=year(RatingDate)
	drop RatingDate
	rename PersonID ORIG_PersonID_Rating
	tostring ORIG_PersonID_Rating, gen(PersonID)  
	save  "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Additional 2009 Rating Data.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2010 Rating.dta"
	gen Year=2010
	rename PersonID ORIG_PersonID_Rating
	tostring ORIG_PersonID_Rating, gen(PersonID) 
	save  "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2010 Rating Data.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2011 Rating.dta"
	gen Year=2011
	rename PersonID ORIG_PersonID_Rating
	tostring ORIG_PersonID_Rating, gen(PersonID) 
	save  "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2011 Rating Data.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2012 Rating.dta"
	gen Year=2012
	rename PersonID ORIG_PersonID_Rating
	tostring ORIG_PersonID_Rating, gen(PersonID) 
	save  "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2012 Rating Data.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2013 Rating.dta"
	gen Year=2013
	rename PersonID ORIG_PersonID_Rating
	tostring ORIG_PersonID_Rating, gen(PersonID) 
	save  "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2013 Rating Data.dta", replace

	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2014 Rating.dta"
	gen Year=2014
	rename PersonID ORIG_PersonID_Rating
	tostring ORIG_PersonID_Rating, gen(PersonID) 
	save  "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2014 Rating Data.dta", replace

	* 13.3 Append updated/additional perf/pot ratings data files
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Additional 2008 Rating Data.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Additional 2009 Rating Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 1.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 1.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2010 Rating Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 2.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 2.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2011 Rating Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 3.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 3.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2012 Rating Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 4.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 4.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2013 Rating Data.dta"

	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 5.dta", replace
	clear

	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 5.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2014 Rating Data.dta"

	* 13.4 Drop headcount variable not needed
	drop Headcount

	* 13.5 Rename variables (except PersonID) with _ARating (Additional Rating Data)
	rename Rating Rating_ARating
	rename PerfQuality PerfQuality_ARating
	rename CustOr CustOr_ARating
	rename Teamw Teamw_ARating
	rename Peopleuntil2012 Peopleuntil2012_ARating
	rename Leader Leader_ARating
	rename PotInitiative PotInitiative_ARating
	rename Decisiv Decisiv_ARating
	rename Driving Driving_ARating
	rename Perspec Perspec_ARating
	rename Convinc Convinc_ARating
	rename Coaching Coaching_ARating

	* 13.6 Drop if PersonID==., drop duplicates in terms of all variables, then identify duplicates in terms of PersonID & Year, and investigate
	drop if PersonID==""
	duplicates drop
	sort PersonID Year
	quietly by PersonID Year:  gen dup = cond(_N==1,0,_n)
	list PersonID Year if dup>1
	* Investigated these two instances - In each of the two cases, there is one observation that is complete, and one observation where the ratings for the individual performance criteria & potential competencies are #
	* > Hence, keep the complete observation

	* 13.7 Drop two duplicate observations, and check no duplicates remain
	drop if PersonID=="1927" & Year==2014 & PerfQuality_ARating=="#"
	drop if PersonID=="20236838" & Year==2013 & PerfQuality_ARating=="#"
	drop dup
	sort PersonID Year
	quietly by PersonID Year:  gen dup = cond(_N==1,0,_n)
	list PersonID Year if dup>1
	drop dup

	* 13.8 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined Updated 2008-2014 Rating Data.dta", replace
	clear

	* 13.9 Delete interim append files created during append process above
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 1.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 2.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 3.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 4.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim Additional Rating Data 5.dta"

**************************************************************************************************************************************************************************************************************************
* PROGRAM 14: Combined 2008-2015 Data -- Retain one observation per PersonID/Year
* Input files: "Combined 2008-2015 Data.dta"
* Steps:
	* 14.1 Call the 2008-2015 Data file
	* 14.2 Create duplicate variable in terms of PersonID and Year
	* 14.3 Examine handful of instances where dup>2 and deal with accordingly so that there is at most (for now) two observations for an employee in a given year
	* 14.4 Drop and recreate duplicate variable and tab
	* 14.5 Since have two observations for an employee for a year where dup>=1, fill CountryofBirth & Nationality where missing in one observation but available in the other 
	* 14.6 Create a variable which is the minimum value of Entrydate by PersonID Year, and set Entrydate to this minimum value for all observations for an employee-year 
	* 14.7 Create FLAG_MLDATE variable to flag any instances where an employee has more than one observation for a year and the MgmtLevelDate differs between the observations (conditional on same management level)
	* 14.8 Sort by PersonID Year Employeegroup, and create observation number within PersonID Year 
	* 14.9 Create a variable which is the management level for the employee per the other observation in the same year if the level per that observation does not equal the level per the current observation (to help in resolving any management level discrepancies later)	
	* 14.10 Create a variable, OTHER_OB, which, for employees with two observations in a given year, is the Employeegroup for the other observation in the year 
	* 14.11 Rename the following variables with (variable name)_THISOB, and then recreate the variables, setting = to (variable name)_THISOB: Function; SupervisorID; RegionofEmployment; CountryofEmployment; OrgUnit; BU
	** << 1. Delegate / Guest Observations << **
	* 14.12 Count instances where employeegroup = "Delegate" & OTHER_OB=="Guest"
	* 14.13 Create a new COUNTRYWORK variable, and for the "Delegate" observation, make this variable = the CountryofEmployment that appears in the "Guest" observation
	* 14.14 Count instances where COUNTRYWORK = HostCountryExpats and instances where COUNTRYWORK != HostCountryExpats for "Delegate" observations where the other observation is a "Guest" observation
	* 14.15 Investigate the one instance where COUNTRYWORK!=HostCountryExpats and adjust accordingly
	* 14.16 For employees with one delegate observation and one guest observation, replace Function, SupervisorID (don't replace non-missing with a missing though), RegionofEmployment, CountryofEmployment, OrgUnit & BU in the "Delegate" observation with the details from the "Guest" observation
	* 14.17 Create KEEP variable, setting to missing, replacing with 0 if dup>=1, and replacing with 1 if Employeegroup=="Delegate" & OTHER_OB=="Guest" (i.e. if an employee has both a guest and a delegate observation in a year, will retain the delegate observation only)
	* 14.18 Create SUM_KEEP variable = sum(KEEP) by PersonID Year, and tab if dup>=1
	** >> 2. Local employee / Impat Observations << **
	* 14.19 Count instances where Employeegroup=="Impat" & OTHER_OB=="Local employee"
	* 14.20 Create variables, Exit_day, Exit_month, and Exit_year, capturing the day, month, and year of Exit if an Exitdate is given
	* 14.21 Create Inc_Exit variable and set = 1 if exit occurs on the last day of the year, the observation is an impat observation, and the employee has another observation for the same year which is a local employee observation (will keep the impat observation) 
	* 14.22 Create Excl_Impat variable and set = 1 if impat assignment ends during the current year (but not on the last day of the year), observation is an impat observation, and the employee has another observation for the same year which is a local employee observation
	* 14.23 Create Excl_Impat_SUM variable = sum(Excl_Impat) by PersonID Year, and tab
	* 14.24 Replace KEEP with 1 if Employeegroup=="Impat" & OTHER_OB=="Local employee" & Exit date for the Impat observation is not during the current year (since want the observation that reflects where the employee is as of 12/31)
	* 14.25 Replace KEEP with 1 if Employeegroup=="Local employee" & OTHER_OB=="Impat" & not keeping Impat observation
	* 14.26 Recreate SUM_KEEP variable and tab if dup>=1
	** 3. Local employee / Local employee Observations **
	* 14.27 Count instances where Employeegroup=="Local employee" & OTHER_OB=="Local employee"
	* 14.28 Create Excl_LE variable and set = 1 if exit date is during the current year (here include 12/31, since both observations are "local employee" observations), observation is a local employee observation, and the employee has another observation for the same year which is a local employee observation
	* 14.28 Create Excl_LE_SUM variable = sum(Excl_LE) by PersonID Year, and tab
	* 14.29 Replace KEEP with 1 if Employeegroup=="Local employee" & OTHER_OB=="Local employee", Exit date for this local employee observation is not during the current 
	* year, and the Exit date for the other local employee observation is during the current year  
	* 14.30 Create LE_LATER and = 1 if Employeegroup==Local employee" & OTHER_OB=="Local employee", yet to select which local employee observation to keep, & the Exitdate 
	* pertains to a year > current year, since assume employee is a local employee in a country for a pre-specified time => I will retain that observation  
	* 14.31 Create LE_LATER and set = 1 if Employeegroup=="Local employee" & OTHER_OB=="Local employee", yet to select which local employee observation to keep, & the Exitdate pertains to a year > current year => will retain this observation (as has an exit date)  
	* 14.32 Replace KEEP with 1 if LE_LATER = 1
	* 14.33 Recreate SUM_KEEP variable and tab if dup>=1 & Employeegroup=="Local employee" & OTHER_OB=="Local employee" 
	* 14.34 For remaining employee with two "local employee" observations, retain the observation that appears the most complete
	* 14.35 Recreate SUM_KEEP variable & tab if dup>=1
	** 4. << Impat / Impat Observations >> **
	* 14.37 Count instances where Employeegroup=="Impat" & OTHER_OB=="Impat"
	* 14.38 Create Excl_Impat2 variable and set = 1 if exit date is during the current year (here include 12/31, since both observations are "impat" observations), observation is an impat observation, and the employee has another observation for the same year which is an impat observation
	* 14.39 Create Excl_Impat2_SUM variable = sum(Excl_Impat2) by PersonID Year, and tab
	* 14.40 Replace KEEP with 1 if Employeegroup=="Impat" & OTHER_OB=="Impat", Exit date for this impat observation is not during the current year, and the Exit date for the other impat observation is during the current year  
	* 14.41 Recreate SUM_KEEP variable & tab if dup>=1
	* 14.42 Tab Employeegroup OTHER_OB for remaining instances where SUM_KEEP==0 & dup>=1
	** << 5. Remaining Observations << **
	* 14.43 By PersonID Year, create Min_Exit date variable = minimum of Exitdate
	* 14.44 Create Incl_2 variable and set = 1 if there is an exit date given, the exit date occurs after the current year, the Exitdate = Min_Exit, and the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept
	* 14.45 Create Incl_2_SUM variable = sum(Inc_2) by PersonID Year, and tab
	* 14.46 Tab Employeegroup OTHER_OB if Incl_2_SUM==2 (need to choose which of the two observations for an employee to keep) 
	* 14.47 Replace Inc_2 variable with 0 if Inc_2_SUM==2 & Employeegroup is not Impat or Local employee (of the employee observations where Incl_2_SUM==2, the impat & local employee observations look the most complete/reasonable, so keep only those)
	* 14.48 Recreate Incl_2_SUM variable and tab
	* 14.49 Replace KEEP with 1 if the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept, there is an exit date given, the exit date occurs after the current year, the Exitdate = Min_Exit, and in instances where both observations met these criteria, the Employeegroup is Impat or Local employee 
	* 14.50 Recreate SUM_KEEP variable & tab if dup>=1
	* 14.51 Create supervisor dummy variable = 1 if SupervisorID not missing 
	* 14.52 Create Sup_DUM_SUM variable = sum(Sup_DUM) by PersonID Year, and tab
	* 14.53 Create Incl_3 variable and set = 1 if a SupervisorID is given, the other observation for the employee in the same year does not have a SupervisorID given, and the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept
	* 14.54 Create Incl_3_SUM variable = sum(Inc_3) by PersonID Year, and tab
	* 14.55 Replace KEEP with 1 if the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept, the observation has a SupervisorID and the other observation for the employee in the same year does not have a SupervisorID 
	* 14.56 Recreate SUM_KEEP variable & tab if dup>=1
	* 14.57 Create Inc_Exit_2 variable and = 1 if the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept and exit occurs on the last day of the year  
	* 14.58 Create Excl_2 variable and = 1 if Exit occurs during the current year (but not on the last day of the year) and the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept 
	* 14.59 Create Excl_2_SUM variable = sum(Excl_2) by PersonID Year, and tab
	* 14.60 Replace KEEP with 1 if the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept, the exit date  occurs on the last day of the year or there is no exit date given, and an exit date which occurs during the current year (but not on the last day of the year) exists for the other observation for the employee in the year 
	* 14.61 Recreate SUM_KEEP variable & tab if dup>=1
	* 14.62 Create Inc_Exit_R variable and set = 1 if exit linked to observation occurs on the last day of the current year and the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept
	* 14.63 Create Inc_Exit_R_SUM variable = sum(Inc_Exit_R) by PersonID Year, and tab
	* 14.64 Inc_Exit_R_SUM = 2 for an employee with a guest observation and an impat observation (exit date occurs on the last day of the current year for both observations) -- don't know which one is most likely the correct observation, retain "Impat" observation as countryofemployment = HomeCountryifExpat & HostCountryifExpat (though these two should not be the same)
	* 14.65 Recreate SUM_KEEP variable & tab if dup>=1, and then examine final employees where need to choose one of the two observations 
	* 14.66 For final three employees where need to choose one of the two observations, replace KEEP with 1 as seems most appropriate
	* 14.67a For employee 63498 where keeping delegate observation, replace Function, SupervisorID (don't replace non-missing with a missing though), RegionofEmployment, CountryofEmployment, OrgUnit & BU in the "Delegate" observation with the details from the "Impat" observation (like I did previously with the "Guest" observation)
	* 14.67b For employee 20165820, replace PercentageofFullPartTime with 100 and FullPartTime with "Full Time" to be consistent with observation not retaining (currently . and Part Time -- but Part Time may be automatic due to the .)
	* 14.68 Recreate SUM_KEEP variable & tab if dup>=1
	** > END OF OBSERVATION SELECTION < 
	* 14.69 Create (var name)_OTHEROB variables where KEEP==1 for the following variables: ExitReason; ABSin[Currency]; STIin[Currency]; SalaryPosition; SalaryIncrease; OverallSTITA; Exitdate, and set equal to the value of (var name) in the observation not being kept where an employee has two observations for a given year, and the value of (var name) in the KEEP observation differs to the value of (var name) in the observation not being kept      
	* 14.70 Where KEEP==1, replace the value of each of the following variables with the value of the variable in the observation not being kept where an employee has two observations for a given year, and the value of the variable in the KEEP observation is missing but not missing in the observation not being kept:
	*       PerformanceR; PotentialR; PerfQualit; CustOr; Teamw; Peopleuntil2012; Leader; PotInitiative; Decisiv; Driving; Perspec; Convinc; Coaching; GroupTargetAchievement; TeamTargetAchievement; RatingAchievement; IndividualTargetAchievement1; IndividualTargetAchievement2; Development_Area; Development_Actions        
	* 14.71 Where KEEP=1, create CHECK_EXIT variable and set = 1 if the exitdate listed with the KEEP observation occurs during the year, unless there is an earlier exit date listed against the observation not being kept or the exit date listed is the same as the exit date listed against the observation not being kept //
	*       (looking at employees that have two observations for a given year); also set = 1 if the Exitdate occurs in a prior year, and tab variable
	* 14.72 Drop observations where an employee has two observations for a year, and have chosen NOT to keep that observation 
	* 14.73 Recreate duplicate variable in terms of PersonID and Year, and tab
	* 14.74 Drop variables no longer needed
	* 14.75 Now that have one observation per employee per year, replace any instances where Year_Exit is the same value as a later observation (since will merge exit data to the latest observation)
	* 14.76 Save output file
* Output file: "ONE_OBS_PERSON_YEAR_2008-2015_Data.dta"
**************************************************************************************************************************************************************************************************************************

	* 14.1 Call the 2008-2015 Data file
	clear
	use  "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined 2008-2015 Data.dta"

	* 14.2 Create duplicate variable in terms of PersonID and Year
	sort PersonID Year
	quietly by PersonID Year:  gen dup = cond(_N==1,0,_n)
	tab dup
	count if dup>1

	* 14.3 Examine handful of instances where dup>2 and deal with accordingly so that there is at most (for now) two observations for an employee in a given year
	list PersonID Year if dup==3
	* > Investigate these 6 employee-year combinations individually and deal with accordingly
	* > 14905 (2010); 21077 (2010); 49013 (2014); 53260 (2014); 20165838 (2014); 20237293 (2014)
	* > For 14905, 21077, and 49013, keep one observation only -- observation that appears most complete/correct 
	drop if PersonID=="14905" & Year==2010 & PercentageofFullPartTime==.
	drop if PersonID=="21077" & Year==2010 & PercentageofFullPartTime==.
	drop if PersonID=="49013" & Year==2014 & CountryofEmployment!="Country 4"
		* > PersonID 49013 appears to have completed an impat assignment in [COUNTRY NAME REMOVED] on 3/1/2014, and then moved to [COUNTRY NAME REMOVED] (in [COUNTRY NAME REMOVED] on 12/31/2015), so keep Impat [COUNTRY NAME REMOVED] observation	
	* > For 53260 (2014); 20165838 (2014); 20237293 (2014), keep two observations for now
	drop if PersonID=="53260" & Year==2014 & CountryofEmployment=="Country 4"
		* > Keep one delegate & one guest observation for 53260; keep the guest observation that appears most likely to be active (appears finished assignment in [COUNTRY NAME REMOVED] on 2/1/2014, and moved to [COUNTRY NAME REMOVED])
	drop if PersonID=="20165838" & Year==2014 & CountryofEmployment=="Country 4"
		* > Keep one delegate & one guest observation for 20165838: keep the guest observation that appears most likely to be active (appears finished assignment in [COUNTRY NAME REMOVED] on 4/1/2014, and moved to [COUNTRY NAME REMOVED])
	drop if PersonID=="20237293" & Year==2014 & Employeegroup=="Guest"
		* > Keep one impat & one local employee observation for 20237293 (drop the guest observation which is the same country as the impat observation -- the impat observation is more complete): keep both for now to fill missing information in one row or the other, and choose which to keep later

	* 14.4 Drop and recreate duplicate variable and tab
	drop dup
	sort PersonID Year
	quietly by PersonID Year:  gen dup = cond(_N==1,0,_n)
	count if dup>1
	tab dup
	* > Now maximum = 2

	* 14.5 Since have two observations for an employee for a year where dup>=1, fill CountryofBirth & Nationality where missing in one observation but available in the other 
	sort PersonID Year
	by PersonID Year: replace CountryofBirth=CountryofBirth[_n-1] if CountryofBirth=="" & CountryofBirth[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace CountryofBirth=CountryofBirth[_n+1] if CountryofBirth=="" & CountryofBirth[_n+1]!="" & PersonID==PersonID[_n+1] & Year==Year[_n+1]
	by PersonID Year: replace Nationality=Nationality[_n-1] if (Nationality=="" | Nationality=="not reported") & (Nationality[_n-1]!="" & Nationality[_n-1]!="not reported") & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace Nationality=Nationality[_n+1] if (Nationality=="" | Nationality=="not reported") & (Nationality[_n+1]!="" & Nationality[_n+1]!="not reported") & PersonID==PersonID[_n+1] & Year==Year[_n+1]

	* 14.6 Create a variable which is the minimum value of Entrydate by PersonID Year, and set Entrydate to this minimum value for all observations for an employee-year 
	rename Entrydate Entrydate_ORIG
	gen Entrydate=Entrydate_ORIG
	sort PersonID Year
	by PersonID Year: egen Min_Entry=min(Entrydate)
	format Min_Entry %tdnn/dd/CCYY
	replace Entrydate=Min_Entry if Min_Entry!=Entrydate & dup>=1

	* 14.7 Create FLAG_MLDATE variable to flag any instances where an employee has more than one observation for a year and the MgmtLevelDate differs between the observations (conditional on same management level)
	sort PersonID Year MgmtLevel
	by PersonID Year MgmtLevel: gen FLAG_MLDATE=1 if MgmtLevel==MgmtLevel[_n+1] & PersonID==PersonID[_n+1] & Year==Year[_n+1] & MgmtLevelDate!=MgmtLevelDate[_n+1]
	tab FLAG_MLDATE
	* > No observations
	drop FLAG_MLDATE

	* 14.8 Sort by PersonID Year Employeegroup, and create observation number within PersonID Year 
	sort PersonID Year Employeegroup
	by PersonID Year: gen n=_n
	tab n

	* 14.9 Create a variable which is the management level for the employee per the other observation in the same year if the level per that observation does not equal the level per the current observation (to help in resolving any management level discrepancies later)
	gen Alt_MgmtLevel=""
	sort PersonID Year
	by PersonID Year: replace Alt_MgmtLevel=MgmtLevel[_n-1] if MgmtLevel!=MgmtLevel[_n-1] & n==2 & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	sort PersonID Year
	by PersonID Year: replace Alt_MgmtLevel=MgmtLevel[_n+1] if MgmtLevel!=MgmtLevel[_n+1] & n==1 & PersonID==PersonID[_n+1] & Year==Year[_n+1]

	* 14.10 Create a variable, OTHER_OB, which, for employees with two observations in a given year, is the Employeegroup for the other observation in the year 
	gen OTHER_OB=""
	sort PersonID Year n
	by PersonID Year: replace OTHER_OB=Employeegroup[_n-1] if n==2 & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace OTHER_OB=Employeegroup[_n+1] if n==1 & PersonID==PersonID[_n+1] & Year==Year[_n+1]
	tab OTHER_OB

	* 14.11 Rename the following variables with (variable name)_THISOB, and then recreate the variables, setting = to (variable name)_THISOB: Function; SupervisorID; RegionofEmployment; CountryofEmployment; OrgUnit; BU
	rename Function Function_THISOB
	rename SupervisorID SupervisorID_THISOB
	rename RegionofEmployment RegionofEmployment_THISOB
	rename CountryofEmployment CountryofEmployment_THISOB
	rename OrgUnit OrgUnit_THISOB
	rename BU BU_THISOB

	gen Function=Function_THISOB
	gen SupervisorID=SupervisorID_THISOB
	gen RegionofEmployment=RegionofEmployment_THISOB
	gen CountryofEmployment=CountryofEmployment_THISOB
	gen OrgUnit=OrgUnit_THISOB 
	gen BU=BU_THISOB

** >> 1. Delegate // Guest Observations << **

	* 14.12 Count instances where Employeegroup=="Delegate" & OTHER_OB=="Guest"
	count if Employeegroup=="Delegate" & OTHER_OB=="Guest"

	* 14.13 Create a new COUNTRYWORK variable, and for the "Delegate" observation, make this variable = the CountryofEmployment that appears in the "Guest" observation
	sort PersonID Year n
	by PersonID Year: gen COUNTRYWORK=CountryofEmployment[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace COUNTRYWORK=CountryofEmployment[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n+1] & Year==Year[_n+1] 

	* 14.14 Count instances where COUNTRYWORK = HostCountryExpats and instances where COUNTRYWORK != HostCountryExpats for "Delegate" observations where the other observation is a "Guest" observation
	count if COUNTRYWORK==HostCountryExpats & Employeegroup=="Delegate" & OTHER_OB=="Guest"
	count if COUNTRYWORK!=HostCountryExpats & Employeegroup=="Delegate" & OTHER_OB=="Guest"
	* > Deal with below

	* 14.15 Investigate the one instance where COUNTRYWORK!=HostCountryExpats and adjust accordingly
	list PersonID Year COUNTRYWORK HostCountryExpats HomeCountryExpats CountryofEmployment if COUNTRYWORK!=HostCountryExpats & Employeegroup=="Delegate" & OTHER_OB=="Guest" 
	* > Looking at observations for this employee, it seems the countryofemployment is [COUNTRY NAME REMOVED], even though the listed host country is [COUNTRY NAME REMOVED] (location of employment is [CAPITAL CITY NAME REMOVED])
	* > Change HostCountryExpats to [COUNTRY NAME REMOVED] to ensure consistency (2 observations)
	replace HostCountryExpats="Country 21" if PersonID=="16253" & Year==2009 

	* 14.16 For employees with one delegate observation and one guest observation, replace Function, SupervisorID (don't replace non-missing with a missing though), RegionofEmployment, CountryofEmployment, OrgUnit & BU in the "Delegate" observation with the details from the "Guest" observation
	* > [NAME OF COMPANY CONTACT REMOVED] advised me to retain the delegate observation since this should be the most complete, however this refers to the employee's home country, therefore I replace the relevant variables with the data that reflects their current employment situation using the "Guest" observation
	sort PersonID Year n
	by PersonID Year: replace Function=Function[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n-1] & Year==Year[_n-1] 
	by PersonID Year: replace Function=Function[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n+1] & Year==Year[_n+1]

	sort PersonID Year n
	by PersonID Year: replace SupervisorID=SupervisorID[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & SupervisorID[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace SupervisorID=SupervisorID[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & SupervisorID[_n+1]!="" & PersonID==PersonID[_n+1] & Year==Year[_n+1]

	sort PersonID Year n
	by PersonID Year: replace RegionofEmployment=RegionofEmployment[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace RegionofEmployment=RegionofEmployment[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n+1] & Year==Year[_n+1]  

	sort PersonID Year n
	by PersonID Year: replace CountryofEmployment=CountryofEmployment[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace CountryofEmployment=CountryofEmployment[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n+1] & Year==Year[_n+1]
	count if CountryofEmployment!=COUNTRYWORK & COUNTRYWORK!=""  

	sort PersonID Year n
	by PersonID Year: replace OrgUnit=OrgUnit[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace OrgUnit=OrgUnit[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n+1] & Year==Year[_n+1] 

	sort PersonID Year n
	by PersonID Year: replace BU=BU[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace BU=BU[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Guest" & PersonID==PersonID[_n+1] & Year==Year[_n+1]

	* 14.17 Create KEEP variable, setting to missing, replacing with 0 if dup>=1, and replacing with 1 if Employeegroup=="Delegate" & OTHER_OB=="Guest" (i.e. if an employee has both a guest and a delegate observation in a year, will retain the delegate observation only)
	gen KEEP=.
	replace KEEP=0 if dup>=1
	replace KEEP=1 if Employeegroup=="Delegate" & OTHER_OB=="Guest"

	* 14.18 Create SUM_KEEP variable = sum(KEEP) by PersonID Year, and tab if dup>=1
	* (Once have dealt with all instances of two observations in a year, SUM_KEEP will = 1 where dup>=1)
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

** >> 2. Local employee / Impat Observations << **

	* 14.19 Count instances where Employeegroup=="Impat" & OTHER_OB=="Local employee"
	count if Employeegroup=="Impat" & OTHER_OB=="Local employee"

	* 14.20 Create variables, Exit_day, Exit_month, and Exit_year, capturing the day, month, and year of Exit if an Exitdate is given
	gen Exit_day=day(Exitdate)
	gen Exit_month=month(Exitdate)
	gen Exit_year=year(Exitdate)

	* 14.21 Create Inc_Exit variable and set = 1 if exit occurs on the last day of the year, the observation is an impat observation, and the employee has another observation for the same year which is a local employee observation (will keep the impat observation) 
	gen Inc_Exit=0 if Employeegroup=="Impat" & OTHER_OB=="Local employee"
	replace Inc_Exit=1 if Exit_day==31 & Exit_month==12 & Exit_year==Year & Employeegroup=="Impat" & OTHER_OB=="Local employee"

	* 14.22 Create Excl_Impat variable and set = 1 if impat assignment ends during the current year (but not on the last day of the year), observation is an impat observation, and the employee has another observation for the same year which is a local employee observation
	gen Excl_Impat=1 if Exit_year==Year & Inc_Exit!=1 & Employeegroup=="Impat" & OTHER_OB=="Local employee"

	* 14.23 Create Excl_Impat_SUM variable = sum(Excl_Impat) by PersonID Year, and tab
	sort PersonID Year
	by PersonID Year: egen Excl_Impat_SUM = sum(Excl_Impat)
	tab Excl_Impat_SUM
	* > All = 0 or 1 => PROCEED

	* 14.24 Replace KEEP with 1 if Employeegroup=="Impat" & OTHER_OB=="Local employee" & Exit date for the Impat observation is not during the current year (since want the observation that reflects where the employee is as of 12/31)
	* > Note that while in most instances where the Target Achievement data appears is the Local employee observation, in terms of BU, Function, etc., the Impat observations appear most complete (thus will bring the Target Achievement data to the Impat observation later)
	replace KEEP=1 if Employeegroup=="Impat" & OTHER_OB=="Local employee" & Excl_Impat!=1

	* 14.25 Replace KEEP with 1 if Employeegroup=="Local employee" & OTHER_OB=="Impat" & not keeping Impat observation
	replace KEEP=1 if Employeegroup=="Local employee" & OTHER_OB=="Impat" & Excl_Impat_SUM==1

	* 14.26 Recreate SUM_KEEP variable and tab if dup>=1
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

** >> 3. Local employee / Local employee Observations << **

	* 14.27 Count instances where Employeegroup=="Local employee" & OTHER_OB=="Local employee"
	count if Employeegroup=="Local employee" & OTHER_OB=="Local employee"

	* 14.28 Create Excl_LE variable and set = 1 if exit date is during the current year (here include 12/31, since both observations are "local employee" observations), observation is a local employee observation, and the employee has another observation for the same year which is a local employee observation
	gen Excl_LE=1 if Exit_year==Year & Employeegroup=="Local employee" & OTHER_OB=="Local employee" 

	* 14.29 Create Excl_LE_SUM variable = sum(Excl_LE) by PersonID Year, and tab
	sort PersonID Year
	by PersonID Year: egen Excl_LE_SUM = sum(Excl_LE)
	tab Excl_LE_SUM
	* > All = 0 or 1 => PROCEED

	* 14.30 Replace KEEP with 1 if Employeegroup=="Local employee" & OTHER_OB=="Local employee", Exit date for this local employee observation is not during the current year, and the Exit date for the other local employee observation is during the current year  
	replace KEEP=1 if Employeegroup=="Local employee" & OTHER_OB=="Local employee" & Excl_LE!=1 & Excl_LE_SUM==1

	* 14.31 Create LE_LATER and set = 1 if Employeegroup=="Local employee" & OTHER_OB=="Local employee", yet to select which local employee observation to keep, & the Exitdate pertains to a year > current year => will retain this observation (as has an exit date)  
	gen LE_LATER=1 if Exit_year>Year & Exit_year!=. & Employeegroup=="Local employee" & OTHER_OB=="Local employee" & Excl_LE_SUM==0 

	* 14.32 Create LE_LATER_SUM variable = sum(LE_LATER) by PersonID Year, and tab
	sort PersonID Year
	by PersonID Year: egen LE_LATER_SUM = sum(LE_LATER)
	tab LE_LATER_SUM
	* > All = 0 or 1 => PROCEED

	* 14.33 Replace KEEP with 1 if LE_LATER = 1
	replace KEEP=1 if LE_LATER==1 

	* 14.34 Recreate SUM_KEEP variable and tab if dup>=1 & Employeegroup=="Local employee" & OTHER_OB=="Local employee" 
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1 & Employeegroup=="Local employee" & OTHER_OB=="Local employee" 

	* 14.35 For remaining employee with two "local employee" observations, retain the observation that appears the most complete
	replace KEEP=1 if BU!="" & Excl_LE_SUM==0 & Exit_year==. & Employeegroup=="Local employee" & OTHER_OB=="Local employee" & SUM_KEEP==0

	* 14.36 Recreate SUM_KEEP variable & tab if dup>=1
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

** << 4. Impat / Impat Observations << **

	* 14.37 Count instances where Employeegroup=="Impat" & OTHER_OB=="Impat"
	count if Employeegroup=="Impat" & OTHER_OB=="Impat"

	* 14.38 Create Excl_Impat2 variable and set = 1 if exit date is during the current year (here include 12/31, since both observations are "impat" observations), observation is an impat observation, and the employee has another observation for the same year which is an impat observation
	gen Excl_Impat2=1 if Exit_year==Year & Employeegroup=="Impat" & OTHER_OB=="Impat" 

	* 14.39 Create Excl_Impat2_SUM variable = sum(Excl_Impat2) by PersonID Year, and tab
	sort PersonID Year
	by PersonID Year: egen Excl_Impat2_SUM = sum(Excl_Impat2)
	tab Excl_Impat2_SUM
	* > All = 0 or 1 => PROCEED

	* 14.40 Replace KEEP with 1 if Employeegroup=="Impat" & OTHER_OB=="Impat", Exit date for this impat observation is not during the current year, and the Exit date for the other impat observation is during the current year  
	replace KEEP=1 if Employeegroup=="Impat" & OTHER_OB=="Impat" & Excl_Impat2!=1 & Excl_Impat2_SUM==1

	* 14.41 Recreate SUM_KEEP variable & tab if dup>=1
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 14.42 Tab Employeegroup OTHER_OB for remaining instances where SUM_KEEP==0 & dup>=1
	tab Employeegroup OTHER_OB if SUM_KEEP==0 & dup>=1
	* > Mix of employee categories, so deal with remaining instances below

** << 5. Remaining Observations >> **

	* 14.43 By PersonID Year, create Min_Exit date variable = minimum of Exitdate
	sort PersonID Year
	by PersonID Year: egen Min_Exit = min(Exitdate)

	* 14.44 Create Incl_2 variable and set = 1 if there is an exit date given, the exit date occurs after the current year, the Exitdate = Min_Exit, and the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept
	* > Will keep the observation where Exitdate = Min_Exit since assume that the employee is currently active in the position that has the earliest exit date that occurs after the current year
	gen Incl_2=1 if Exit_year>Year & Min_Exit==Exitdate & Exit_year!=. & dup>=1 & SUM_KEEP==0

	* 14.45 Create Incl_2_SUM variable = sum(Inc_2) by PersonID Year, and tab
	sort PersonID Year
	by PersonID Year: egen Incl_2_SUM = sum(Incl_2)
	tab Incl_2_SUM if dup>=1
	* > Deal with below

	* 14.46 Tab Employeegroup OTHER_OB if Incl_2_SUM==2 (need to choose which of the two observations for an employee to keep) 
	tab Employeegroup OTHER_OB if Incl_2_SUM==2

	* 14.47 Replace Inc_2 variable with 0 if Inc_2_SUM==2 & Employeegroup is not Impat or Local employee (of the employee observations where Incl_2_SUM==2, the impat & local employee observations look the most complete/reasonable, so keep only those)
	replace Incl_2=0 if Employeegroup!="Impat" & Employeegroup!="Local employee" & Incl_2_SUM==2

	* 14.48 Recreate Incl_2_SUM variable and tab
	drop Incl_2_SUM
	sort PersonID Year
	by PersonID Year: egen Incl_2_SUM = sum(Incl_2)
	tab Incl_2_SUM if dup>=1 & SUM_KEEP==0
	* > All = 0 or 1 => PROCEED

	* 14.49 Replace KEEP with 1 if the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept, there is an exit date given, the exit date occurs after the current year, the Exitdate = Min_Exit, and in instances where both observations meet these criteria, the Employeegroup is Impat or Local employee 
	replace KEEP=1 if Incl_2==1 & SUM_KEEP==0

	* 14.50 Recreate SUM_KEEP variable & tab if dup>=1
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 14.51 Create supervisor dummy variable = 1 if SupervisorID not missing 
	gen Sup_DUM=0
	replace Sup_DUM=1 if SupervisorID!=""

	* 14.52 Create Sup_DUM_SUM variable = sum(Sup_DUM) by PersonID Year, and tab
	sort PersonID Year
	by PersonID Year: egen Sup_DUM_SUM = sum(Sup_DUM)

	* 14.53 Create Incl_3 variable and set = 1 if a SupervisorID is given, the other observation for the employee in the same year does not have a SupervisorID given, and the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept
	* > Here I am using SupervisorID as a proxy to include the most "complete" employee record (looking at data, often cases where no SupervisorID there is also no BU or OrgUnit detail) 
	gen Incl_3=0 if SUM_KEEP==0 & dup>=1
	replace Incl_3=1 if Sup_DUM==1 & Sup_DUM_SUM==1 & SUM_KEEP==0 & dup>=1 

	* 14.54 Create Incl_3_SUM variable = sum(Inc_3) by PersonID Year, and tab
	sort PersonID Year
	by PersonID Year: egen Incl_3_SUM = sum(Incl_3)
	tab Incl_3_SUM if dup>=1
	* > All = 0 or 1 => PROCEED

	* 14.55 Replace KEEP with 1 if the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept, the observation has a SupervisorID and the other observation for the employee in the same year does not have a SupervisorID 
	replace KEEP=1 if Incl_3==1 & SUM_KEEP==0 & dup>=1

	* 14.56 Recreate SUM_KEEP variable & tab if dup>=1
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 14.57 Create Inc_Exit_2 variable and set = 1 if the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept and exit occurs on the last day of the year  
	gen Inc_Exit_2=0
	replace Inc_Exit_2=1 if Exit_day==31 & Exit_month==12 & Exit_year==Year & SUM_KEEP==0 & dup>=1

	* 14.58 Create Excl_2 variable and = 1 if Exit occurs during the current year (but not on the last day of the year) and the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept 
	gen Excl_2=1 if Exit_year==Year & Inc_Exit_2!=1 & SUM_KEEP==0 & dup>=1 

	* 14.59 Create Excl_2_SUM variable = sum(Excl_2) by PersonID Year, and tab
	sort PersonID Year
	by PersonID Year: egen Excl_2_SUM = sum(Excl_2)
	tab Excl_2_SUM
	* > All = 0 or 1 => PROCEED

	* 14.60 Replace KEEP with 1 if the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept, the exit date occurs on the last day of the year or there is no exit date given, and an exit date which occurs during the current year (but not on the last day of the year) exists for the other observation for the employee in the year 
	replace KEEP=1 if SUM_KEEP==0 & dup>=1 & Excl_2_SUM==1 & Excl_2!=1

	* 14.61 Recreate SUM_KEEP variable & tab if dup>=1
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 14.62 Create Inc_Exit_R variable and set = 1 if exit linked to observation occurs on the last day of the current year and the observation is one of the remaining observations where I am yet to choose which of the two observations will be kept
	gen Inc_Exit_R=0
	replace Inc_Exit_R=1 if Exit_day==31 & Exit_month==12 & Exit_year==Year & SUM_KEEP==0 & dup>=1

	* 14.63 Create Inc_Exit_R_SUM variable = sum(Inc_Exit_R) by PersonID Year, and tab
	sort PersonID Year
	by PersonID Year: egen Inc_Exit_R_SUM = sum(Inc_Exit_R)
	tab Inc_Exit_R_SUM 
	* > Deal with below
	
	* 14.64 Inc_Exit_R_SUM = 2 for an employee with a guest observation and an impat observation (exit date occurs on the last day of the current year for both observations) -- don't know which one is most likely the correct observation, retain "Impat" observation as countryofemployment = HomeCountryifExpat & HostCountryifExpat (though these two should not be the same)
	replace KEEP=1 if Employeegroup=="Impat" & SUM_KEEP==0 & Inc_Exit_R_SUM==2

	* 14.65 Recreate SUM_KEEP variable & tab if dup>=1, and then examine final employees where need to choose one of the two observations 
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1
	list PersonID Year if SUM_KEEP==0 & dup>=1

	* 14.66 For final three employees where need to choose one of the two observations, replace KEEP with 1 as seems most appropriate
	* > PersonID = 63498 -- set KEEP=1 if Employeegroup=="Delegate" (other observation is an impat observation -- for delegate/guest observations, I kept the delegate observation, so do the same here)
	replace KEEP=1 if PersonID=="63498" & Employeegroup=="Delegate" & Inc_Exit_R_SUM==0 & SUM_KEEP==0 & dup>=1
	* > PersonID = 20165820 -- set KEEP=1 if Employeegroup=="Guest" (other observation is a local employee observation - exit date against Guest observation is 31.12.2013, and observation is very complete, assume on international assignment as of 12/31)
	replace KEEP=1 if PersonID=="20165820" & Employeegroup=="Guest" & Inc_Exit_R_SUM==1 & SUM_KEEP==0 & dup>=1
	* > PersonID = 21077 - set KEEP=1 if Employeegroup=="Local employee" (other observation is an others observation - although exit date against Other observation is 31.12.2011, the observation is less complete than the local employee observation, and the management level is lower than that recorded against the local employee observation and in prior years (note: demotions are rare)
	replace KEEP=1 if PersonID=="21077" & Employeegroup=="Local employee" & Inc_Exit_R_SUM==1 & SUM_KEEP==0 & dup>=1

	* 14.67a For employee 63498 where keeping delegate observation, replace Function, SupervisorID (don't replace non-missing with a missing though), RegionofEmployment, CountryofEmployment, OrgUnit & BU in the "Delegate" observation with the details from the "Impat" observation (like I did previously with the "Guest" observation)
	* 14.67b For employee 20165820, replace PercentageofFullPartTime with 100 and FullPartTime with "Full Time" to be consistent with observation not retaining (currently . and Part Time -- but Part Time may be automatic due to the .)
	sort PersonID Year n
	by PersonID Year: replace Function=Function[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & PersonID=="63498"
	by PersonID Year: replace Function=Function[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & PersonID=="63498" 

	sort PersonID Year n
	by PersonID Year: replace SupervisorID=SupervisorID[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & SupervisorID[_n-1]!="" & PersonID=="63498"
	by PersonID Year: replace SupervisorID=SupervisorID[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & SupervisorID[_n+1]!="" & PersonID=="63498"

	sort PersonID Year n
	by PersonID Year: replace RegionofEmployment=RegionofEmployment[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & PersonID=="63498"
	by PersonID Year: replace RegionofEmployment=RegionofEmployment[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & PersonID=="63498"  

	sort PersonID Year n
	by PersonID Year: replace CountryofEmployment=CountryofEmployment[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & PersonID=="63498"
	by PersonID Year: replace CountryofEmployment=CountryofEmployment[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & PersonID=="63498"

	sort PersonID Year n
	by PersonID Year: replace OrgUnit=OrgUnit[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & PersonID=="63498"
	by PersonID Year: replace OrgUnit=OrgUnit[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & PersonID=="63498" 

	sort PersonID Year n 
	by PersonID Year: replace BU=BU[_n-1] if n==2 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & PersonID=="63498"
	by PersonID Year: replace BU=BU[_n+1] if n==1 & Employeegroup=="Delegate" & OTHER_OB=="Impat" & PersonID=="63498"

	replace PercentageofFullPartTime=100 if PersonID=="20165820" & Year==2013
	replace FullPartTime="Full Time" if PersonID=="20165820" & Year==2013
 
	* 14.68 Recreate SUM_KEEP variable & tab if dup>=1
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1
	tab KEEP
	tab dup
	* > For all instances where two observations for an employee in a given year, have chosen one observation to retain => GOOD 
	* > dup=0 for >98% of observations

** > END OF OBSERVATION SELECTION < 

	* 14.69 Create (var name)_OTHEROB variables where KEEP==1 for the following variables: ExitReason; ABSin[Currency]; STIin[Currency]; SalaryPosition; SalaryIncrease; OverallSTITA; Exitdate, and set equal to the value of (var name) in the observation not being kept where an employee has two observations for a given year, and the value of (var name) in the KEEP observation differs to the value of (var name) in the observation not being kept      
	sort PersonID Year KEEP
	by PersonID Year: gen ExitReason_OTHEROB=ExitReason[_n-1] if KEEP==1 & ExitReason!=ExitReason[_n-1] & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	* > no replacements
	
	sort PersonID Year KEEP
	by PersonID Year: gen ABSin[Currency]_OTHEROB=ABSin[Currency][_n-1] if KEEP==1 & ABSin[Currency]!=ABSin[Currency][_n-1] & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: gen STIin[Currency]_OTHEROB=STIin[Currency][_n-1] if KEEP==1 & STIin[Currency]!=STIin[Currency][_n-1] & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: gen SalaryPosition_OTHEROB=SalaryPosition_inSalaryBand[_n-1] if KEEP==1 & SalaryPosition_inSalaryBand!=SalaryPosition_inSalaryBand[_n-1] & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: gen SalaryIncrease_OTHEROB=SalaryIncrease_percofMB[_n-1] if KEEP==1 & SalaryIncrease_percofMB!=SalaryIncrease_percofMB[_n-1] & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: gen OverallSTITA_OTHEROB=OverallSTITA[_n-1] if KEEP==1 & OverallSTITA!=OverallSTITA[_n-1] & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: gen Exitdate_OTHEROB=Exitdate[_n-1] if KEEP==1 & Exitdate!=Exitdate[_n-1] & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	format Exitdate_OTHEROB %tdnn/dd/CCYY
	
	* 14.70 Where KEEP==1, replace the value of each of the following variables with the value of the variable in the observation not being kept where an employee has two observations for a given year, and the value of the variable in the KEEP observation is missing but not missing in the observation not being kept:
	*       PerformanceR; PotentialR; PerfQualit; CustOr; Teamw; Peopleuntil2012; Leader; PotInitiative; Decisiv; Driving; Perspec; Convinc; Coaching; GroupTargetAchievement; TeamTargetAchievement; RatingAchievement; IndividualTargetAchievement1; IndividualTargetAchievement2; Development_Area; Development_Actions        
	sort PersonID Year KEEP
	by PersonID Year: replace PerformanceR=PerformanceR[_n-1] if KEEP==1 & (PerformanceR=="#" | PerformanceR=="Z" | PerformanceR=="") & PerformanceR[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace PotentialR=PotentialR[_n-1] if KEEP==1 & (PotentialR=="#" | PotentialR=="Z" | PotentialR=="") & PotentialR[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace PerfQualit=PerfQualit[_n-1] if KEEP==1 & (PerfQualit=="#" | PerfQualit=="Z" | PerfQualit=="") & PerfQualit[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	 
	sort PersonID Year KEEP
	by PersonID Year: replace CustOr=CustOr[_n-1] if KEEP==1 & (CustO=="#" | CustO=="Z" | CustO=="") & CustOr[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace Teamw=Teamw[_n-1] if KEEP==1 & (Teamw=="#" | Teamw=="Z" | Teamw=="") & Teamw[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace Peopleuntil2012=Peopleuntil2012[_n-1] if KEEP==1  & (Peopleuntil2012=="#" | Peopleuntil2012=="Z" | Peopleuntil2012=="") & Peopleuntil2012[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace Leader=Leader[_n-1] if KEEP==1 & (Leader=="#" | Leader=="Z" | Leader=="") & Leader[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace PotInitiative=PotInitiative[_n-1] if KEEP==1 & (PotInitiative=="#" | PotInitiative=="Z" | PotInitiative=="") & PotInitiative[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace Decisiv=Decisiv[_n-1] if KEEP==1 & (Decisiv=="#" | Decisiv=="Z" | Decisiv=="") & Decisiv[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace Driving=Driving[_n-1] if KEEP==1 & (Driving=="#" | Driving=="Z" | Driving=="") & Driving[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace Perspec=Perspec[_n-1] if KEEP==1 & (Perspec=="#" | Perspec=="Z" | Perspec=="") & Perspec[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace Convinc=Convinc[_n-1] if KEEP==1 & (Convinc=="#" | Convinc=="Z" | Convinc=="") & Convinc[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace Coaching=Coaching[_n-1] if KEEP==1 & (Coaching=="#" | Coaching=="Z" | Coaching=="") & Coaching[_n-1]!="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace GroupTargetAchievement=GroupTargetAchievement[_n-1] if KEEP==1 & GroupTargetAchievement==. & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace TeamTargetAchievement=TeamTargetAchievement[_n-1] if KEEP==1 & TeamTargetAchievement==. & PersonID==PersonID[_n-1] & Year==Year[_n-1] 

	sort PersonID Year KEEP
	by PersonID Year: replace RatingAchievement=RatingAchievement[_n-1] if KEEP==1 & RatingAchievement==. & PersonID==PersonID[_n-1] & Year==Year[_n-1] 

	sort PersonID Year KEEP
	by PersonID Year: replace IndividualTargetAchievement1=IndividualTargetAchievement1[_n-1] if KEEP==1 & IndividualTargetAchievement1==. & PersonID==PersonID[_n-1] & Year==Year[_n-1] 

	sort PersonID Year KEEP
	by PersonID Year: replace IndividualTargetAchievement2=IndividualTargetAchievement2[_n-1] if KEEP==1 & IndividualTargetAchievement2==. & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace Development_Area=Development_Area[_n-1] if KEEP==1 & Development_Area=="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	sort PersonID Year KEEP
	by PersonID Year: replace Development_Actions=Development_Actions[_n-1] if KEEP==1 & Development_Actions=="" & PersonID==PersonID[_n-1] & Year==Year[_n-1]

	* 14.71 Where KEEP=1, create CHECK_EXIT variable and set = 1 if the exitdate listed with the KEEP observation occurs during the year, unless there is an earlier exit date listed against the observation not being kept or the exit date listed is the same as the exit date listed against the observation not being kept //
	*       (looking at employees that have two observations for a given year); also set = 1 if the Exitdate occurs in a prior year, and tab variable
	gen CHECK_EXIT=0 if KEEP==1
	sort PersonID Year KEEP
	by PersonID Year: replace CHECK_EXIT=1 if KEEP==1 & Exit_year==Year & Exit_month!=12 & Exit_day!=31  
	replace CHECK_EXIT=0 if CHECK_EXIT==1 & Exitdate>=Exitdate_OTHEROB & Exitdate_OTHEROB!=.
	replace CHECK_EXIT=0 if CHECK_EXIT==1 & Exitdate==Exitdate[_n-1] 
	replace CHECK_EXIT=1 if Exit_year<Year & KEEP==1
	tab CHECK_EXIT
	* > All 0 => OK (observations chosen to KEEP all appear reasonable)

	* 14.72 Drop observations where an employee has two observations for a year, and have chosen NOT to keep that observation 
	drop if SUM_KEEP==1 & KEEP==0

	* 14.73 Recreate duplicate variable in terms of PersonID and Year, and tab
	drop dup
	sort PersonID Year
	quietly by PersonID Year:  gen dup = cond(_N==1,0,_n)
	count if dup>1
	tab dup
	* > All 0 => GOOD

	* 14.74 Drop variables no longer needed
	drop Exit_day Exit_month Exit_year Inc_Exit Excl_Impat Excl_Impat_SUM Excl_LE Excl_LE_SUM LE_LATER LE_LATER_SUM Excl_Impat2 Excl_Impat2_SUM Min_Exit Incl_2 Incl_2_SUM Sup_DUM Sup_DUM_SUM Incl_3 Incl_3_SUM 
	drop Inc_Exit_2 Excl_2 Excl_2_SUM Inc_Exit_R Inc_Exit_R_SUM CHECK_EXIT SUM_KEEP KEEP dup

	* 14.75 Now that have one observation per employee per year, replace any instances where Year_Exit is the same value as a later observation (since will merge exit data to the latest observation)
	drop LASTN
	gen LASTN=0
	sort PersonID Year
	by PersonID: replace LASTN=1 if _n==_N
	sort PersonID Year
	by PersonID: replace Year_Exit=. if Year_Exit==Year_Exit[_n+1] & Year!=Year[_n+1] & LASTN!=1

	* 14.76 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ONE_OBS_PERSON_YEAR_2008-2015_Data.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 15: Merge Additional Rating Data to Latest 2008-2015 File
* Input files: "ONE_OBS_PERSON_YEAR_2008-2015_Data.dta"; "Combined Updated 2008-2014 Rating Data.dta"
* Steps:
	* 15.1 Call the latest 2008-2015 Data file
	* 15.2 Rename Rating_PastYear Rating
	* 15.3 Bring each of the variables associated with the performance evaluation cycle to the prior year since currently reported in the following year (e.g. the 2010 rating appears in the 2011 file), name with _YE
	* 15.4 Change the names of each of the original performance evaluation cycle variables to _PY to indicate that the value reported this year relates to the prior year
	* 15.5 Save interim output file
	* 15.6 Merge interim output file with Combined Updated 2008-2014 Rating Data file using PersonID and Year
	* 15.7 Create PerformanceR_ARating and PotentialR_ARating variables using Rating_ARating, and tab to ensure created correctly
	* 15.8 Rename Year_Exit variable Year_Exit_MERGE (for use with merging with Exit data)  
	* 15.9 Create Exit_Year variable = year of the Exitdate, and count instances where Exit_Year>Year and instances where Exit_Year=Year
	* 15.10 Drop observations pertaining to hierarchical levels not to be used
	* 15.11 Compare ratings between original data provided and additional rating data where rating in both datasets
	* 15.12 Replace the (varname)_YE variables with (varname)_ARating if (varname)_YE is missing 
	* 15.13 Count instances where there is a rating from [NAME OF COMPANY CONTACT REMOVED] but not from [NAME OF COMPANY CONTACT REMOVED] to ensure it's a low %
	* 15.14 Drop if _merge==2 
	* 15.15 Rename merge variable
	* 15.16 Save as new output file
* Output file: "ONE_OBS_PERSON_YEAR_2008-2015_Data_w_ARating.dta"
**************************************************************************************************************************************************************************************************************************

	* 15.1 Call the latest 2008-2015 Data file
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ONE_OBS_PERSON_YEAR_2008-2015_Data.dta"

	* 15.2 Rename Rating_PastYear Rating
	rename Rating_PastYear Rating

	* 15.3 Bring each of the variables associated with the performance evaluation cycle to the prior year since currently reported in the following year (e.g. the 2010 rating appears in the 2011 file), name with _YE
	sort PersonID Year
	foreach x of varlist Rating PerformanceR PotentialR PerfQuality CustOr Teamw Peopleuntil2012 Leader PotInitiative Decisiv Driving Perspec Convinc Coaching GroupTargetAchievement TeamTargetAchievement RatingAchievement IndividualTargetAchievement1 IndividualTargetAchievement2 OverallSTITA{
	by PersonID: gen `x'_YE = `x'[_n+1] if Year==Year[_n+1]-1 & PersonID==PersonID[_n+1]
	} 
	 
	* 15.4 Change the names of each of the original performance evaluation cycle variables to _PY to indicate that the value reported this year relates to the prior year
	foreach x of varlist Rating PerformanceR PotentialR PerfQuality CustOr Teamw Peopleuntil2012 Leader PotInitiative Decisiv Driving Perspec Convinc Coaching GroupTargetAchievement TeamTargetAchievement RatingAchievement IndividualTargetAchievement1 IndividualTargetAchievement2 OverallSTITA{
	rename `x' `x'_PY
	}

	* 15.5 Save interim output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ONE_OBS_PERSON_YEAR_2008-2015_Data_v2.dta", replace
	clear

	* 15.6 Merge interim output file with Additional 2008-2014 Rating Data file using PersonID and Year
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ONE_OBS_PERSON_YEAR_2008-2015_Data_v2.dta"
	merge m:1 PersonID Year using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined Updated 2008-2014 Rating Data.dta"
	 
	* 15.7 Create PerformanceR_ARating and PotentialR_ARating variables using Rating_ARating, and tab to ensure created correctly
	gen PerformanceR_ARating=""
	replace PerformanceR_ARating="L" if (Rating_ARating=="L3" | Rating_ARating=="L4")
	replace PerformanceR_ARating="M" if (Rating_ARating=="M1" | Rating_ARating=="M2" | Rating_ARating=="M3" | Rating_ARating=="M4")
	replace PerformanceR_ARating="S" if (Rating_ARating=="S1" | Rating_ARating=="S2" | Rating_ARating=="S3" | Rating_ARating=="S4")
	replace PerformanceR_ARating="T" if (Rating_ARating=="T1" | Rating_ARating=="T2" | Rating_ARating=="T3" | Rating_ARating=="T4")
	replace PerformanceR_ARating="#" if Rating_ARating=="#"
	replace PerformanceR_ARating="Z" if Rating_ARating=="Z"
	replace PerformanceR_ARating="ZZ" if Rating_ARating=="ZZ"

	gen PotentialR_ARating=""
	replace PotentialR_ARating="4" if (Rating_ARating=="L4" | Rating_ARating=="M4" | Rating_ARating=="S4" | Rating_ARating=="T4")
	replace PotentialR_ARating="3" if (Rating_ARating=="L3" | Rating_ARating=="M3" | Rating_ARating=="S3" | Rating_ARating=="T3")
	replace PotentialR_ARating="2" if (Rating_ARating=="M2" | Rating_ARating=="S2" | Rating_ARating=="T2")
	replace PotentialR_ARating="1" if (Rating_ARating=="M1" | Rating_ARating=="S1" | Rating_ARating=="T1")
	replace PotentialR_ARating="#" if Rating_ARating=="#"
	replace PotentialR_ARating="Z" if Rating_ARating=="Z"
	replace PotentialR_ARating="ZZ" if Rating_ARating=="ZZ"

	tab Rating_ARating PerformanceR_ARating
	tab Rating_ARating PotentialR_ARating

	* 15.8 Rename Year_Exit variable Year_Exit_MERGE (for use with merging with Exit data)  
	rename Year_Exit Year_Exit_MERGE

	* 15.9 Create Exit_Year variable = year of the Exitdate
	gen Exit_Year=year(Exitdate)

	* 15.10 Drop observations pertaining to hierarchical levels not to be used
	* In an email on 01/22/2016, [NAME OF COMPANY CONTACT REMOVED] advised: "N.B. in 2013 data you will find employees under Employee Subgroup [HIERARCHICAL LEVELS REMOVED]. 
	* Please exclude them from your analysis as these are special categorizations used only in the [NAME OF COUNTRY REMOVED]."
	drop if MgmtLevel== "ML A" | MgmtLevel== "ML Ax" | MgmtLevel== "ML Ay"

	* 15.11 Compare ratings between original data provided and additional rating data where rating in both datasets
	* Overall performance and potential ratings
	gen flag_PerformanceR=1 if PerformanceR_YE!=PerformanceR_ARating & PerformanceR_YE!="" & PerformanceR_ARating!="" & _merge==3
	tab PerformanceR_YE PerformanceR_ARating if flag_PerformanceR==1
	* > Only instances are Z / ZZ => GOOD

	gen flag_PotentialR=1 if PotentialR_YE!=PotentialR_ARating & PotentialR_YE!="" & PotentialR_ARating!="" & _merge==3
	tab PotentialR_YE PotentialR_ARating if flag_PotentialR==1
	* > Only instances are Z / ZZ => GOOD

	* 15.12 Replace the (varname)_YE variables with (varname)_ARating if (varname)_YE is missing 
	replace PerformanceR_YE=PerformanceR_ARating if PerformanceR_YE==""
	replace PotentialR_YE=PotentialR_ARating if PotentialR_YE=="" 
	replace Rating_YE=Rating_ARating if Rating_YE==""

	* 15.13 Count instances where there is a rating from [NAME OF COMPANY CONTACT REMOVED] but not from [NAME OF COMPANY CONTACT REMOVED] to ensure it's a low %
	* > (in a conversation with [NAME OF COMPANY CONTACT REMOVED] she said these instances could arise where a person received a rating outside of the formal process (e.g. because they were on some form of leave, etc.)
	count if Rating_YE!="" & Rating_ARating==""
	count if Rating_YE!="" & Rating_YE!="#" & Rating_YE!="Z" & Rating_YE!="ZZ" & Rating_ARating==""
	count if Rating_YE!="" & Rating_YE!="#" & Rating_YE!="Z" & Rating_YE!="ZZ"
	* > 925/68,600 = just 1.35% => SEEMS VERY REASONABLE, continue to use ratings even if only from [NAME OF COMPANY CONTACT REMOVED] not [NAME OF COMPANY CONTACT REMOVED]

	* 15.14 Drop if _merge==2 
	drop if _merge==2

	* 15.15 Rename merge variable
	rename _merge _merge_ARating

	* 15.16 Save as new output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ONE_OBS_PERSON_YEAR_2008-2015_Data_w_ARating.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 16: Combined Exit Data - Retain one observation per PersonID/Year
* Input files: "2009-2014 Exit Data.dta"; "2015 Exit Data.dta"
* Steps:
	* 16.1 Append 2015 Exit Data and 2009-2014 Exit Data
	* 16.2 Create duplicate variable in terms of PersonID and Year
	* 16.3 Examine instances where dup=3 and drop one observation pertaining to the PersonID/Year so as to retain maximum two observations for a PersonID/Year for now
	* 16.4 Recreate dup variable and check dup = 2 at most
	* 16.5 Create dup_CHECK variaable in terms of PersonID, Year, Exitdate, Employeegroup, ExitReason, and CountryofEmployment
	* 16.6 Create observation number, n, within PersonID and Year
	* 16.7 Create Exitdate_OTHEROB, ExitReason_OTHEROB, and Employeegroup_OTHEROB variables and set = to Exitdate, ExitReason, and Employeegroup respectively, found in the other observation for the employee for the year 
	* 16.8 Create KEEP variable, and set to missing if dup = 0, and = 0 if dup >=1
	** >> 1. Same Exit Reason for both exit observations for an Employee/Year << **
	* 16.9 Replace KEEP = 1 if an employee has the same exit reason for both observations, the exit date in the current observation > the exit date in the other observation for the employee for the year, 
	*      or the exit date in the current observation = the exit date in the other observation for the employee for the year and this is observation number 1 (arbitrary choice if same exit reason and same date) 
	* 16.10 Create SUM_KEEP variable which = sum(KEEP) by PersonID and Year, and tab if dup>=1 (keep recreating variable below as choose observations to keep)
	** >> 2. Same Employee Group for both exit observations for an Employee/Year << **
	* 16.11 Replace KEEP = 1 if an employee has the same employeegroup listed for both observations, the exit reason for the other observation is "limited work contract" and the exit reason for this observation is not "other exit reason" or "leaving"
	* 16.12 Replace KEEP = 1 if an employee has the same employeegroup for both observations, the exit reason for this observation is "limited work contract" and the exit reason for the other observation is "leaving" or "other exit reason" 
	* 16.13 Replace KEEP = 1 if an employee has the same employeegroup for both observations, the exit reason for the current observation is not "leaving" or "other exit reason" and the exit reason for the other observation is "leaving" or "other exit reason" (the "leaving" and "other exit reason" categories are not very informative)
	* 16.14 Replace KEEP = 1 if an employee has the same employeegroup listed for both observations and the exit reason for the current observation is "Early retirement" or "Death" (the other observation in each case had "Employee's reason", but "Early retirement" and "Death" are more informative) 
	* 16.15 Replace KEEP = 1 if an an employee has the same employeegroup listed for both observations and the exit reason for the current observation is "Mutual agreement" 
	* 16.16 Replace KEEP = 1 if an employee has the same employeegroup listed for both observations and the exit reason for the current observation is "Personal reason" and for the other observation is "Employee's reason" (personal reason is more informative)
	** >> 3. Different Employee Groups for the exit observations for an Employee/Year << **
	* 16.17 Replace KEEP = 1 the exit reason for the other observation is "limited work contract" and the exit reason for this observation is not "other exit reason" or "leaving"
	* 16.18 Replace KEEP = 1 if the exit reason for this observation is "limited work contract" and the exit reason for the other observation is "leaving" or "other exit reason" 
	* 16.19 Replace KEEP = 1 if the exit reason for this observation is "employer's reason" and the exit reason for the other observation is "mutual agreement" (these two categories are considered together in later analyses so choice of observation is arbitrary) 
	* 16.20 Replace KEEP = 1 if the exit reason for this observation is not "leaving" and the exit reason for the other observation is "leaving" 
	* 16.21 Replace KEEP = 1 if the exit reason for this observation is the most informative exit reason 
	* 16.22 Replace KEEP = 1 if the exit reason for this observation is employer's reason or mutual agreement, and the exit reason for the other observation in an employee reason 
	* 16.23 Replace KEEP = 1 if the exit reason for this observation is retirement and the exit reason for the other reason is personal reason (retirement is more informative)
	* 16.24 Recreate SUM_KEEP variable, and tab if dup>=1
	** > END OF OBSERVATION SELECTION < 
	* 16.25 Drop exit observations not keeping
	* 16.26 Recreate duplicate variable in terms of PersonID and Year, and tab to ensure no duplicates remain
	* 16.27 Rename Year_Exit Year_Exit_MERGE in preparation for merging
	* 16.28 Save output file
* Output file: "Combined_Exit_Data.dta"
**************************************************************************************************************************************************************************************************************************

	* 16.1 Append 2015 Exit Data and 2009-2014 Exit Data
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2009-2014 Exit Data.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2015 Exit Data.dta"

	* 16.2 Create duplicate variable in terms of PersonID and Year
	duplicates drop
	sort PersonID Year
	quietly by PersonID Year:  gen dup = cond(_N==1,0,_n)
	count if dup>1
	tab dup

	* 16.3 Examine instances where dup=3 and drop one observation pertaining to the PersonID/Year so as to retain maximum two observations for a PersonID/Year for now
	list PersonID Year if dup==3
	* > Only 7 instances (drop whichever observation seems most appropriate to drop based on visual inspection of data -- will choose between remaining two observations later in program)
	drop if PersonID=="142" & ExitReason_EXIT=="Death" & Employeegroup_EXIT=="Transfer" & Year==2010 & dup>=1
	drop if PersonID=="11483" & month(Exitdate_EXIT)==2 & Year==2009 & dup>=1
	drop if PersonID=="16926" & month(Exitdate_EXIT)==2 & Year==2010 & dup>=1
	drop if PersonID=="21077" & day(Exitdate_EXIT)==15 & Year==2010 & dup>=1
	drop if PersonID=="29802" & month(Exitdate_EXIT)==7 & Year==2011 & dup>=1
	drop if PersonID=="58717" & month(Exitdate_EXIT)==4 & Year==2015 & dup>=1
	drop if PersonID=="20174165" & month(Exitdate_EXIT)==2 & Year==2011 & dup>=1

	* 16.4 Recreate dup variable and check dup = 2 at most
	drop dup
	sort PersonID Year
	quietly by PersonID Year:  gen dup = cond(_N==1,0,_n)
	count if dup>1
	tab dup
	* > Now maximum = 2

	* 16.5 Create dup_CHECK variaable in terms of PersonID, Year, Exitdate, Employeegroup, ExitReason, and CountryofEmployment
	sort PersonID Year Exitdate_EXIT Employeegroup_EXIT ExitReason_EXIT CountryofEmployment_EXIT
	quietly by PersonID Year Exitdate_EXIT Employeegroup_EXIT ExitReason_EXIT CountryofEmployment_EXIT:  gen dup_CHECK = cond(_N==1,0,_n)
	tab dup_CHECK
	* > No duplicates

	* 16.6 Create observation number, n, within PersonID and Year
	sort PersonID Year Exitdate_EXIT Employeegroup_EXIT ExitReason_EXIT CountryofEmployment_EXIT
	by PersonID Year: gen n=_n

	* 16.7 Create Exitdate_OTHEROB, ExitReason_OTHEROB, and Employeegroup_OTHEROB variables and set = to Exitdate, ExitReason, and Employeegroup respectively, found in the other observation for the employee for the year 
	gen Exitdate_OTHEROB=.
	sort PersonID Year
	by PersonID Year: replace Exitdate_OTHEROB=Exitdate_EXIT[_n-1] if n==2 & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace Exitdate_OTHEROB=Exitdate_EXIT[_n+1] if n==1 & PersonID==PersonID[_n+1] & Year==Year[_n+1]
	format Exitdate_OTHEROB %td

	* Double-check that year(Exitdate) & year(Exitdate_OTHEROB) are always the same year
	count if year(Exitdate_EXIT)!=year(Exitdate_OTHEROB) & Exitdate_EXIT!=. & Exitdate_OTHEROB!=.
	* > 0 => OK
	 
	gen ExitReason_OTHEROB=""
	sort PersonID Year
	by PersonID Year: replace ExitReason_OTHEROB=ExitReason_EXIT[_n-1] if n==2 & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace ExitReason_OTHEROB=ExitReason_EXIT[_n+1] if n==1  & PersonID==PersonID[_n+1] & Year==Year[_n+1]

	gen Employeegroup_OTHEROB=""
	sort PersonID Year
	by PersonID Year: replace Employeegroup_OTHEROB=Employeegroup_EXIT[_n-1] if n==2 & PersonID==PersonID[_n-1] & Year==Year[_n-1]
	by PersonID Year: replace Employeegroup_OTHEROB=Employeegroup_EXIT[_n+1] if n==1 & PersonID==PersonID[_n+1] & Year==Year[_n+1]

	* 16.8 Create KEEP variable, and set to missing if dup = 0, and = 0 if dup >=1
	gen KEEP=0 if dup>=1

** >> 1. Same Exit Reason for both exit observations for an Employee/Year << **

	* 16.9 Replace KEEP = 1 if an employee has the same exit reason for both observations, the exit date in the current observation > the exit date in the other observation for the employee for the year, 
	*      or the exit date in the current observation = the exit date in the other observation for the employee for the year and this is observation number 1 (arbitrary choice if same exit reason and same date) 
	replace KEEP=1 if ExitReason_EXIT==ExitReason_OTHEROB & Exitdate_EXIT>Exitdate_OTHEROB & Exitdate_EXIT!=.   
	replace KEEP=1 if ExitReason_EXIT==ExitReason_OTHEROB & Exitdate_EXIT==Exitdate_OTHEROB & n==1

	* 16.10 Create SUM_KEEP variable which = sum(KEEP) by PersonID and Year, and tab if dup>=1 (keep recreating variable below as choose observations to keep)
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1
	* > Should all = 1 once dealt with all instances of two observations for an Employee/Year

** >> 2. Same Employee Group for both exit observations for an Employee/Year << **

	* 16.11 Replace KEEP = 1 if an employee has the same employeegroup listed for both observations, the exit reason for the other observation is "limited work contract" and the exit reason for this observation is not "other exit reason" or "leaving"
	replace KEEP = 1 if Employeegroup_EXIT==Employeegroup_OTHEROB & ExitReason_EXIT!="Other exit reason" & ExitReason_EXIT!="Leaving" & ExitReason_EXIT!="" & ExitReason_OTHEROB=="Limited work contract" & SUM_KEEP==0 
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 16.12 Replace KEEP = 1 if an employee has the same employeegroup for both observations, the exit reason for this observation is "limited work contract" and the exit reason for the other observation is "leaving" or "other exit reason" 
	replace KEEP = 1 if Employeegroup_EXIT==Employeegroup_OTHEROB & ExitReason_EXIT=="Limited work contract" & (ExitReason_OTHEROB=="Leaving" | ExitReason_OTHEROB=="Other exit reason") & SUM_KEEP==0 
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 16.13 Replace KEEP = 1 if an employee has the same employeegroup for both observations, the exit reason for the current observation is not "leaving" or "other exit reason" and the exit reason for the other observation is "leaving" or "other exit reason" (the "leaving" and "other exit reason" categories are not very informative)
	replace KEEP=1 if Employeegroup_EXIT==Employeegroup_OTHEROB & (ExitReason_EXIT!="Leaving" & ExitReason_EXIT!="Other exit reason" & ExitReason_EXIT!="") & (ExitReason_OTHEROB=="Leaving" | ExitReason_OTHEROB=="Other exit reason") & SUM_KEEP==0
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* > Inspect remaining instances
	list PersonID Exitdate_EXIT ExitReason_EXIT Exitdate_OTHEROB ExitReason_OTHEROB if Employeegroup_EXIT==Employeegroup_OTHEROB & SUM_KEEP==0

	* 16.14 Replace KEEP = 1 if an employee has the same employeegroup listed for both observations and the exit reason for the current observation is "Early retirement" or "Death" (the other observation in each case had "Employee's reason", but "Early retirement" and "Death" are more informative) 
	replace KEEP=1 if Employeegroup_EXIT==Employeegroup_OTHEROB & ExitReason_EXIT=="Early retirement" & SUM_KEEP==0
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1
	replace KEEP=1 if Employeegroup_EXIT==Employeegroup_OTHEROB & ExitReason_EXIT=="Death" & SUM_KEEP==0
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 16.15 Replace KEEP = 1 if an an employee has the same employeegroup listed for both observations and the exit reason for the current observation is "Mutual agreement" 
	* > (in one case the other observation had "Personal Reason" at a later date, and the other had "Employer's reason" at a later date - "Mutual agreement" & "Employer's reason" will be treated the same in my analyses, and "mutual agreeement" seems more likely than personal reason")
	replace KEEP=1 if Employeegroup_EXIT==Employeegroup_OTHEROB & ExitReason_EXIT=="Mutual agreement" & SUM_KEEP==0
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 16.16 Replace KEEP = 1 if an employee has the same employeegroup listed for both observations and the exit reason for the current observation is "Personal reason" and for the other observation is "Employee's reason" (personal reason is more informative)
	replace KEEP=1 if Employeegroup_EXIT==Employeegroup_OTHEROB & ExitReason_EXIT=="Personal Reason" & SUM_KEEP==0
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	count if Employeegroup_EXIT==Employeegroup_OTHEROB & SUM_KEEP==0 & dup>=1
	* > No instances => GOOD

** 3. >> Different Employee Groups for the exit observations for an Employee/Year << **

	* 16.17 Replace KEEP = 1 if the exit reason for the other observation is "limited work contract" and the exit reason for this observation is not "other exit reason" or "leaving"
	replace KEEP = 1 if ExitReason_EXIT!="Other exit reason" & ExitReason_EXIT!="Leaving" & ExitReason_EXIT!="" & ExitReason_OTHEROB=="Limited work contract" & SUM_KEEP==0 & Employeegroup_EXIT!="" & Employeegroup_OTHEROB!=""
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 16.18 Replace KEEP = 1 if the exit reason for this observation is "limited work contract" and the exit reason for the other observation is "leaving" or "other exit reason" 
	replace KEEP = 1 if ExitReason_EXIT=="Limited work contract" & (ExitReason_OTHEROB=="Leaving" | ExitReason_OTHEROB=="Other exit reason") & SUM_KEEP==0 & Employeegroup_EXIT!="" & Employeegroup_OTHEROB!="" 
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 16.19 Replace KEEP = 1 if the exit reason for this observation is "employer's reason" and the exit reason for the other observation is "mutual agreement" (these two categories are considered together in later analyses so choice of observation is arbitrary) 
	replace KEEP = 1 if ExitReason_EXIT=="Employer's reason" & ExitReason_OTHEROB=="Mutual agreement" & SUM_KEEP==0 & Employeegroup_EXIT!="" & Employeegroup_OTHEROB!="" 
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 16.20 Replace KEEP = 1 if the exit reason for this observation is not "leaving" and the exit reason for the other observation is "leaving" 
	replace KEEP = 1 if ExitReason_EXIT!="Leaving" & ExitReason_EXIT!="" & ExitReason_OTHEROB=="Leaving" & SUM_KEEP==0 & Employeegroup_EXIT!="" & Employeegroup_OTHEROB!="" 
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* 16.21 Replace KEEP = 1 if the exit reason for this observation is the most informative exit reason 
	replace KEEP = 1 if (ExitReason_EXIT=="Personal Reason" | ExitReason_EXIT=="Financial" | ExitReason_EXIT=="External Job Offer") & (ExitReason_OTHEROB=="Employee's reason" | ExitReason_OTHEROB=="Other exit reason") & SUM_KEEP==0 & Employeegroup_EXIT!="" & Employeegroup_OTHEROB!=""
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	replace KEEP = 1 if (ExitReason_EXIT=="Employer's reason" | ExitReason_EXIT=="Employee's reason") & ExitReason_OTHEROB=="Other exit reason" & SUM_KEEP==0 & Employeegroup_EXIT!="" & Employeegroup_OTHEROB!=""
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	replace KEEP = 1 if ExitReason_EXIT=="External Job Offer" & ExitReason_OTHEROB=="Personal Reason" & SUM_KEEP==0 & Employeegroup_EXIT!="" & Employeegroup_OTHEROB!=""
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* > Inspect remaining instances
	list PersonID Exitdate_EXIT ExitReason_EXIT Exitdate_OTHEROB ExitReason_OTHEROB if Employeegroup_EXIT!="" & Employeegroup_OTHEROB!="" & SUM_KEEP==0
	
	* 16.22 Replace KEEP = 1 if the exit reason for this observation is employer's reason or mutual agreement, and the exit reason for the other observation in an employee reason 
	* > (In these cases I think it's more likely that "employer reason" / "mutual agreement" (these two categories will be grouped together in analyses) is correct 
	* > Will not classify as "voluntary" these instances where there is evidence to suggest that the turnover was in fact "involuntary" 
	replace KEEP = 1 if (ExitReason_EXIT=="Mutual agreement" | ExitReason_EXIT=="Employer's reason") & (ExitReason_OTHEROB=="Retirement" | ExitReason_OTHEROB=="Early retirement") & SUM_KEEP==0 & Employeegroup_EXIT!="" & Employeegroup_OTHEROB!=""
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	replace KEEP = 1 if (ExitReason_EXIT=="Mutual agreement" | ExitReason_EXIT=="Employer's reason") & (ExitReason_OTHEROB=="Employee's reason" | ExitReason_OTHEROB=="Manager" | ExitReason_OTHEROB=="External Job Offer" | ExitReason_OTHEROB=="Personal Reason") & SUM_KEEP==0 & Employeegroup_EXIT!="" & Employeegroup_OTHEROB!=""
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1

	* > Inspect remaining instances
	list PersonID Exitdate_EXIT ExitReason_EXIT Exitdate_OTHEROB ExitReason_OTHEROB if Employeegroup_EXIT!="" & Employeegroup_OTHEROB!="" & SUM_KEEP==0

	* 16.23 Replace KEEP = 1 if the exit reason for this observation is retirement and the exit reason for the other reason is personal reason (retirement is more informative)
	replace KEEP = 1 if ExitReason_EXIT=="Retirement" & ExitReason_OTHEROB=="Personal Reason" & SUM_KEEP==0 & Employeegroup_EXIT!="" & Employeegroup_OTHEROB!=""

	* 16.24 Recreate SUM_KEEP variable, and tab if dup>=1
	drop SUM_KEEP
	sort PersonID Year
	by PersonID Year: egen SUM_KEEP = sum(KEEP)
	tab SUM_KEEP if dup>=1
	* > All = 1

** > END OF OBSERVATION SELECTION < 

	* 16.25 Drop exit observations not keeping
	drop if SUM_KEEP==1 & KEEP==0

	* 16.26 Recreate duplicate variable in terms of PersonID and Year, and tab to ensure no duplicates remain
	drop dup
	sort PersonID Year
	quietly by PersonID Year:  gen dup = cond(_N==1,0,_n)
	count if dup>1
	tab dup
	* > All 0 => GOOD

	* 16.27 Rename Year_Exit Year_Exit_MERGE in preparation for merging
	rename Year_Exit Year_Exit_MERGE

	* 16.28 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined_Exit_Data.dta", replace
	clear


clear

* EOF	
	

**************************************************************************************************************************************************************************************************************************
* DELLER: BEYOND PERFORMANCE: DOES ASSESSED POTENTIAL MATTER TO EMPLOYEES' VOLUNTARY DEPARTURE DECISIONS *
* PROGRAM 2 OF 2 *
* Note that specific country names and the local currency have been replaced and any company-specific terminology has been modified so as to protect the confidentiality of the company    
**************************************************************************************************************************************************************************************************************************

clear

cd "/Volumes/cdeller_project/Beyond Performance Project/_Final code_JAR"

version 15
clear all
set more off

**************************************************************************************************************************************************************************************************************************
*** >>> PROGRAMS IN THIS FILE <<< ***
		* PROGRAM 17: Combine 2008-2015 Data with Exit Data
		* PROGRAM 18: Further Data Processing & Validity Testing I
		* PROGRAM 19: Data Processing & Validity Testing 2
		* PROGRAM 20: Merge Management Level 0 Data into Processed Data
		* PROGRAM 21: Create Demographic & Employment Variables
		* PROGRAM 22: Create Performance & Potential Rating Variables and Promotion and Demotion Variables
		* PROGRAM 23: Create Manager Characteristics Variables
		* PROGRAM 24: Final Preparations Before Analyses
**************************************************************************************************************************************************************************************************************************

**************************************************************************************************************************************************************************************************************************
* PROGRAM 17: Combine 2008-2015 Data with Exit Data
* Input files: "ONE_OBS_PERSON_YEAR_2008-2015_Data_w_ARating.dta"; "Combined_Exit_Data.dta"
* Steps:
	* 17.0 Call latest 2008-2015 dataset
	* 17.1 Recreate LASTN dummy variable, = 1 for the last observation for an employee (when sorted by Year)
	* 17.2 Merge latest 2008-2015 data file with Exit data 
	** << Deal with instances where _merge==2 >> **
	* 17.3 Create countno variable = number of observations for an employee, and drop instances of _merge==2 where it is the only observation for an employee
	* 17.4 Create minyear variable = earliest year for which we have a year-end observation for the employee, and drop instances of _merge==2 where the exit year is prior to any year-end record years for an employee 
	* 17.5 Create dummy variable RECOVER, and set = 1 where will "recover" an exit observation (_merge==2) that did not match, generally due to a gap in an employee's year end records
	* 17.6 Record relevant exit details from non-matching exit observations (_merge==2) in year end record for the employee where RECOVER==1  
	* 17.7 Create D_merge dummy and set = 1 where "recovered" non-matching exit details from _merge==2 observation above
	* 17.8 Drop if D_merge==1, and drop RECOVER
	* 17.9 Recreate dummy variable RECOVER, and now set = 1 where will "recover" an exit observation (_merge==2) that did not match because the year of the exit in the exit data is greater than the year of any existing year-end observation 
	* 17.10 Record relevant exit details from non-matching exit observations (_merge==2) in year end record for the employee where RECOVER==1  
	* 17.11 Set D_merge dummy = 1 where "recovered" non-matching exit details from _merge==2 observation above
	* 17.12 Drop if D_merge==1, and drop RECOVER
	* 17.13 Create dummy variables for the merge values 2 & 3
	* 17.14 By PersonID, sum the dummies for merge = 2 and sum the dummies for merge = 3
	* 17.15 List relevant variables for all employee observations for employees with a remaining _merge==2 observation
	* 17.16 Create RETIRE_LATER dummy variable and set = 1 where _merge=3 for the employee's last observation, and for the later unmatched exit observation, the exit reason is "retirement" 
	* 17.17 Tab the exit reason for the matched exit observation where the employee "retires" later
	* 17.18 Set D_merge dummy = 1 where will not record exit details as relate to a later "retirement"
	* 17.19 Drop if D_merge==1
	* 17.20 Recreate the s_m2 and s_M3 variables
	* 17.21 List relevant variables for all employee observations for employees with a remaining _merge==2 observation
	* 17.22 Visually inspect remaining employee observations where the employee has a remaining _merge==2 observation, and change recorded exit reason to unmerged reason as appropriate; see if need to retain exit details 
	* 17.23 "Recover" exit details for one employee identified in listing above 
	* 17.24 Drop all remaining instances where _merge==2
	** > END OF DEALING WITH _MERGE==2 INSTANCES < 
	* 17.25 Format Entrydate
	** << Deal with multiple exit dates for an employee >> **
	* 17.26 Counts of Exitdate_OTHEROB and Exitdate variables
	* 17.27 List relevant variables where the employee has an entry for both Exitdate_OTHEROB and Exitdate
	* 17.28 Generate DateMin_Exitdate_OTHEROB which is the minimum of Exitdate_OTHEROB and Exitdate, and create FLAGDATE dummy variable and set = to 1 where this minimum exit date value occurs prior to the current year 
	* 17.29 Rename Exitdate Exitdate_PRIOR, and recreate Exitdate, filling with the prior exitdate value where available, then filling with the Exitdate_OTHEROB value where available, and then replacing with the value from DateMin_Exitdate_OTHEROB where this differs to the existing value and LASTN==1 (otherwise the Exitdate is likely to be ignored later anyway as the employee has an observation in a year after this year)
	* 17.30 Create MISS_YEAR dummy variable = 1 where an employee is "missing" (does not have) an observation for the previous year
	* 17.31 Create STRING variable = 1 where an observation falls in the first (or only) continuous string of observations for an employee, = 2 where an observation falls in the second continous string of observations, ...
	* 17.32 Within each STRING, create NS and maxNS variables to identify observation numbers, and create LNS dummy variable = 1 where it is the employee's last observation in that string
	* 17.33 Create M_Exitdate_EXIT and M_Exitdate variables which = max(Exitdate_EXIT) and max(Exitdate) respectively, within each STRING for an employee 
	* 17.34 Count instances where we have M_Exitdate_EXIT but no M_Exitdate and viceversa, and where we have both, count instances where the dates are the same, and where they differ (just for the last observation in the STRING) 
	** 1) Instances where M_Exitdate_EXIT & M_Exitdate are identical  **
	* 17.35 Create IDENTICAL dummy and set = 1 where M_Exitdate_EXIT and M_Exitdate are identical, and set = 0 where they are not equal (but have a value for both)
	* 17.36 Create Y_IDENTICAL = year of M_Exitdate if IDENTICAL is = 1
	* 17.37 Create EXCL dummy and set = 1 if Y_IDENTICAL < Year (i.e. if the maximum exit date occurs prior to the year end observation year) 
	* 17.38 Create EXAMINE dummy and set = 1 if Y_IDENTICAL > Year+1 (i.e. the exit date occurs at a time > current year + 1)
	* 17.39 Within an employee, where the value of STRING does not equal the value of STRING in the subsequent observation (i.e. there is at least one year end observation "missing"), in the current observation record the year that appears in the next observation 
	* 17.40 Create Min_Exitdate_EXIT and Min_Exitdate variables which = min(Exitdate_EXIT) and min(Exitdate) respectively, within each STRING for an employee, , and create MIN_ID=1 if these two dates are identical  
	* 17.41 Create EXAMINE_NOD dummy and set = 1 if EXAMINE=1 and Min_Exitdate_EXIT==M_Exitdate_EXIT & MIN_ID==1 (i.e. for those observations where the maximum exit date is at a time > current year + 1, we don't have an earlier exit date)
	* 17.42 Visually inspect the relevant variables where EXAMINE==1 and the employee has another string of observations in later years
	* 17.43 Create EXIT_DATE_USE and set = to M_Exitdate where IDENTICAL=1 & EXCL=0
	** 2) Instances where M_Exitdate_EXIT & M_Exitdate are not identical, but both have a value **
	* > 2a) Both have the same year -> 1,453 instances *
	* 17.44 Create Exit_diff_SAMEYEAR dummy and set = 1 where the exit date occurs in the same year (for instances where the two exit dates are not the same)
	* 17.45 Where Exit_diff_SAMEYEAR = 1, create FIRST_EXIT_DATE and set to the earlier of M_Exitdate and M_Exitdate_EXIT
	* 17.46 Create EXCL_2 dummy and set = 1 where FIRST_EXIT_DATE < Year (i.e. if the year of the maximum exit date occurs prior to the year end observation year)  
	* 17.47 Create EXAMINE_2 dummy and set = 1 if FIRST_EXIT_DATE > Year+1 (i.e. the exit date occurs at a time > current year + 1)
	* 17.48 Visually inspect the relevant variables where EXAMINE_2==1 
	* 17.49 Replace EXIT_DATE_USE with the FIRST_EXIT_DATE value if EXCL_2=0
	* > 2b) The exit dates pertain to different years  *
	* 17.50 Create Exit_diff_days = difference between M_Exitdate_EXIT and M_Exitdate (for instances where the two exit dates are not the same and the years differ)
	* >> 2b1) Different years - but less than 365 days difference  << *
	* 17.51 Create IMM_DIFF dummy and set = 1 if |Exit_diff_days| < 365 (where the two exit dates are not the same and the years differ)
	* 17.52 Where IMM_DIFF = 1, create FIRST_EXIT_DATE_2 and set to the earlier of M_Exitdate and M_Exitdate_EXIT; create FIRST_EXIT_DATE_2B and set to maximum of those two dates
	* 17.53 Create EXCL_3 dummy and set = 1 where FIRST_EXIT_DATE_2 < Year (i.e. if the year of the chosen maximum exit date occurs prior to the year end observation year) 
	* 17.54 Visually inspect the relevant variables where EXCL_3=1 in case the year of the later of M_Exitdate and M_Exitdate_EXIT is not < Year 
	* 17.55 Replace FIRST_EXIT_DATE_2 with M_Exitdate_EXIT for PersonID 2392 in Year 2015
	* 17.56 Drop, and recreate EXCL_3 dummy variable
	* 17.57 Create EXAMINE_3 dummy and set = 1 if FIRST_EXIT_DATE_2 > Year+1 (i.e. the exit date occurs at a time > current year + 1)
	* 17.58 Replace EXIT_DATE_USE with the FIRST_EXIT_DATE_2 value if EXCL_3=0  & difference in exit days is less than 185 days (6 months) (i.e. where difference in days across the two maximum exit dates is < than six months, 
	*       use the earliest date -- except for one change made above), replace with the FIRST_EXIT_DATE_2B value if EXCL_3 and difference in days is more than 185 days (6 months) (i.e. where difference in days across the two 
	*       maximum exit dates is greater than 185 days, use the latest date), provided year(FIRST_EXIT_DATE_2B) is not > Year+1 [assuming that if end relationship would leave within 6 months]
	* >> 2b2) Different years - and more than 365 days difference  << *
	* 17.59 Where IMM_DIFF = 0, create FIRST_EXIT_DATE_3 and set to the earlier of M_Exitdate and M_Exitdate_EXIT (where the two exit dates are not the same, the years differ, and the difference in dates is > 365 days)
	* 17.60 Create EXCL_4 dummy and set = 1 where FIRST_EXIT_DATE_3 < Year (i.e. if the year of the chosen maximum exit date occurs prior to the year end observation year) 
	* 17.61 For the instances where EXCL_4=1, replace FIRST_EXIT_DATE_3 with the alternative exit date (i.e. M_Exitdate instead of M_Exitdate_EXIT and vice versa), which will set the exitdate to a later date
	* 17.62 Drop, and recreate EXCL_4 dummy variable 
	* 17.63 Create EXAMINE_4 dummy and set = 1 if FIRST_EXIT_DATE_3 > Year+1 (i.e. the exit date occurs at a time > current year + 1)
	* 17.64 Visually inspect the relevant variables where EXAMINE_4==1 
	* 17.65 Replace FIRST_EXIT_DATE_3 with missing for 4 employees identified above
	* 17.66 Replace EXIT_DATE_USE with the FIRST_EXIT_DATE_3 value if EXCL_4=0 (i.e. where difference in the two maximum exit dates is > than a year, use the earliest date -- except for changes made above -- since perhaps on some type of leave before exiting, but is no longer active - so treat as exited)
	** 3) Instances where M_Exitdate_EXIT & M_Exitdate are identical  **
	* 17.67 Create EXCL_5 dummy and set = 1 where M_Exidate_EXIT < Year (i.e. if the year of the maximum exit date occurs prior to the year end observation year) (no M_Exitdate)
	* 17.68 Create EXAMINE_5 dummy and set = 1 if M_Exitdate_EXIT > Year+1 (i.e. the exit date occurs at a time > current year + 1) 
	* 17.69 Replace EXIT_DATE_USE with the M_Exitdate_EXIT value if EXCL_5=0
	** 4) Instances where exit date only in M_Exitdate  **
	* 17.70 Create EXCL_6 dummy and set = 1 where M_Exidate < Year (i.e. if the year of the maximum exit date occurs prior to the year end observation year) (no M_Exitdate_EXIT)
	* 17.71 Create EXAMINE_6 dummy and set = 1 if M_Exitdate > Year+1 (i.e. the exit date occurs at a time > current year + 1) 
	* 17.72 Create Use_Min variable and set = 1 if EXAMINE_6=1 & the exitdate is recorded against the last (or only) string for the employee, & Min_Exitdate differs to M_Exitdate & Min_Exitdate >= Year
	* 17.73 Replace EXAMINE_6 with a value of 0 (change from 1) if the exitdate is recorded against the last (or only) string for the employee => since will retain the exit date 
	* 17.74 Visually inspect the relevant variables where EXAMINE_6==1
	* 17.75 Count instances where M_Exitdate!=Min_Exitdate & EXAMINE_6=1 
	* 17.76 Visually inspect the relevant variables where M_Exitdate!=Min_Exitdate & EXAMINE_6=1 
	* 17.77 Replace EXCL_6 with a value of 1 if the next year (start of next string) for which an employee has an observation is >= the year of the exit date, exclude the exitdate
	* 17.78 Replace EXIT_DATE_USE with the M_Exitdate value if EXCL_6=0; replace EXIT_DATE_USE with the Min_Exitdate if Use_MIN==0
	* 17.79 Double-check EXIT_DATE_USE is only recorded against the last observation in a string for an employee; and ensure no exit date values are before the current year
	** > END OF DEALING WITH EXIT DATES < 
	* 17.80 Create ExitReason_EXIT2 and set = to ExitReason_EXIT, and ExitReason_EXIT from above observation within string if ExitReason_EXIT is blank
	* 17.81 Create EXIT_REASON_USE variable and set = to ExitReason_EXIT2
	* 17.82 Visually inspect employee observations where ExitReason_EXIT!=ExitReason, and replace EXIT_REASON_USE with ExitReason (in place of ExitReason_EXIT) as deemed appropriate 
	* 17.83 Where EXIT_REASON_USE is blank (ie. ExitReason_EXIT is blank), fill EXIT_REASON_USE with ExitReason
	* 17.84 Rename ExitReason ExitReason_ORIG and create ExitReason = ExitReason_ORIG
	* 17.85 Replace ExitReason with ExitReason from above observation (within the same string) where Exit dates are consistent across the observations
	* 17.86 Where EXIT_REASON_USE is blank (ie. ExitReason_EXIT is blank), fill EXIT_REASON_USE with ExitReason
	* 17.87 Gen SIM_Date variable and set = 1 where Exit date in above observation (within person, within string) has the same year as Exitdate in this observation 
	* 17.88 Replace ExitReason with ExitReason from above observation (within the same string) where Exitdates are similar across the observations
	* 17.89 Where EXIT_REASON_USE is blank (ie. ExitReason_EXIT is blank), fill EXIT_REASON_USE with ExitReason
	* 17.90 Create NO_REASON_EXIT_YEAR variable and set = to year of exit for instances where EXIT_DATE_USE!=. & EXIT_REASON_USE=="", and tab variable
	* 17.91 Drop variables no longer needed 
	* 17.92 Create PRIOR_EXIT_REASON and PRIOR_EXIT_DATE variables bringing exit reason and exit date to the subsequent observation for an employee where an employee has more than one string of observations
	* 17.93 Bring PRIOR_EXIT_DATE to all observations within a string for an employee
	** > END OF DEALING WITH EXIT REASONS < 
	* 17.94 Create NEW_ENTRYDATE variable and set = 1 if the employee has a prior exit date listed against the observation and the year of the Entrydate occurs after the year of the prior Exitdate (evidence that the employee did in fact leave the company and return at a later time)
	* 17.95 Create C_NEW_ENTRYDATE and sum over a PersonID/STRING the NEW_ENTRYDATE variable, then count where this variable > 0 & NS==1 (number of unique employees where there is evidence that the employee exited and re-entered)
	* 17.96 Create Min_Entrydate and Max_Entrydate variables and set = to the minimum Entrydate and maximum Entrydate respectively, within PersonID/STRING
	* 17.97 Count instances where NEW_ENTRYDATE==1, and within these, where Entrydate==Min_Entrydate and Entrydate==Max_Entrydate (but not Min_Entrydate)
	* 17.98 Examine relevant variables for 2 instances not accounted for above, and deal with accordingly
	* 17.99 Create USE_MINDATE and USE_MAXDATE variables and set = 1 to indicate which date will use for the employees' Entrydate (for those that exited and re-entered -- use the one that occurs after the prior exit date), and then sum over PersonID/STRING
	* 17.100 Rename Entrydate Entrydate_SUPERSEDED, and regenerate Entrydate populating with Entrydate_SUPERSEDED
	* 17.101 Replace Entrydate with Min_Entrydate (Max_Entrydate) if SUM_MINDATE>0 (SUM_MAXDATE>0)
	* 17.102 Count any instances where I believe an employee exited and reentered and the current Entrydate occurs BEFORE the prior exit date, and count where it occurs AFTER the prior exit date (one obs per employee)
	* 17.103 For those employees with an exit date, and then a later string of observations, but I don't believe the employee exited and reentered, replace EXIT_DATE_USE and EXIT_DATE_REASON with missing
	* 17.104 Create EMP_TIME variable, and set =1 for employee's string of observations up to and including first exit date, set = 2 for next string of observations up to and including second exit date (effectively recreating the STRING variable but this time only starting a new number where the employee actually exited the company and returned), and tab this variable
	* 17.105 Drop variables not needed
	* 17.106 Save output file
	* 17.107 Delete all preparation files created within program, except final file (and any ML5 files that will use in later programs)
* Output file: "Prepared_Data.dta"
**************************************************************************************************************************************************************************************************************************

	* 17.0 Call latest 2008-2015 dataset 
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ONE_OBS_PERSON_YEAR_2008-2015_Data_w_ARating.dta"

	* 17.1 Recreate LASTN dummy variable, = 1 for the last observation for an employee (when sorted by Year)
	drop LASTN
	gen LASTN=0
	sort PersonID Year
	by PersonID: replace LASTN=1 if _n==_N
	tab LASTN

	* 17.2 Merge latest 2008-2015 data file with Exit data 
	merge 1:1 PersonID Year_Exit_MERGE using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined_Exit_Data.dta"

** << Deal with instances where _merge==2 >> **

	* 17.3 Create countno variable = number of observations for an employee, and drop instances of _merge==2 where it is the only observation for an employee
	sort PersonID
	by PersonID: gen no=_n
	by PersonID: egen countno=max(no)
	tab countno if _merge==2
	* > If only record of employee is the exit record, then drop the exit record
	drop if countno==1 & _merge==2

	* 17.4 Create minyear variable = earliest year for which we have a year-end observation for the employee, and drop instances of _merge==2 where the exit year is prior to any year-end record years for an employee 
	sort PersonID Year
	by PersonID: egen MINYEAR=min(Year)
	* > If only exit record has exit year before any of the years we have a year end record for the employee then drop the exit record
	drop if _merge==2 & Year_Exit_MERGE<MINYEAR & MINYEAR!=.

	* 17.5 Create dummy variable RECOVER, and set = 1 where will "recover" an exit observation (_merge==2) that did not match, generally due to a gap in an employee's year end records
	* (e.g. if year(Year_Exit_MERGE) = 2012, but the employee did not have a 2011 record, then there would be no match(since Year_Exit_MERGE)=Year+1; will instead record relevant details against the 2012 observation)
	sort PersonID Year_Exit_MERGE
	by PersonID: gen RECOVER=1 if Year[_n-1]==. & Year_Exit_MERGE[_n-1]==Year & _merge[_n-1]==2 & Exitdate_EXIT==.
	count if RECOVER==1

	* 17.6 Record relevant exit details from non-matching exit observations (_merge==2) in year end record for the employee where RECOVER==1  
	sort PersonID Year_Exit_MERGE
	foreach x of varlist ExitReasonCode_EXIT ExitReason_EXIT Employeegroup_EXIT MgmtLevel_EXIT RegionofEmployment_EXIT CountryofEmployment_EXIT Employeegroup_OTHEROB{
	by PersonID: replace `x'= `x'[_n-1] if Year[_n-1]==. & Year_Exit_MERGE[_n-1]==Year & _merge[_n-1]==2 & `x'=="" & RECOVER==1 & PersonID==PersonID[_n-1]
	}

	sort PersonID Year_Exit_MERGE
	foreach x of varlist Exitdate_EXIT{
	by PersonID: replace `x'= `x'[_n-1] if Year[_n-1]==. & Year_Exit_MERGE[_n-1]==Year & _merge[_n-1]==2 & `x'==. & RECOVER==1 & PersonID==PersonID[_n-1]
	}

	* 17.7 Create D_merge dummy and set = 1 where "recovered" non-matching exit details from _merge==2 observation above
	sort PersonID Year_Exit_MERGE
	gen D_merge=0
	by PersonID: replace D_merge=1 if Year_Exit_MERGE==Year[_n+1] & _merge==2 & RECOVER[_n+1]==1

	* 17.8 Drop if D_merge==1, and drop RECOVER
	drop if D_merge==1
	drop RECOVER

	* 17.9 Recreate dummy variable RECOVER, and now set = 1 where will "recover" an exit observation (_merge==2) that did not match because the year of the exit in the exit data is greater than the year of any existing year-end observation 
	sort PersonID Year
	by PersonID: gen RECOVER=1 if Year[_n+1]==. & Year_Exit_MERGE<Year_Exit_MERGE[_n+1] & _merge[_n+1]==2 & _merge==1
	count if RECOVER==1

	* 17.10 Record relevant exit details from non-matching exit observations (_merge==2) in year end record for the employee where RECOVER==1  
	sort PersonID Year
	foreach x of varlist ExitReasonCode_EXIT ExitReason_EXIT Employeegroup_EXIT MgmtLevel_EXIT RegionofEmployment_EXIT CountryofEmployment_EXIT Employeegroup_OTHEROB{
	by PersonID: replace `x'= `x'[_n+1] if Year[_n+1]==. & Year_Exit_MERGE[_n+1]>=Year & _merge[_n+1]==2 & `x'=="" & _merge==1 & RECOVER==1 & PersonID==PersonID[_n+1]
	}

	sort PersonID Year
	foreach x of varlist Exitdate_EXIT{
	by PersonID: replace `x'= `x'[_n+1] if Year[_n+1]==. & Year_Exit_MERGE[_n+1]>=Year & _merge[_n+1]==2 & `x'==. & _merge==1 & RECOVER==1 & PersonID==PersonID[_n+1]
	}

	* 17.11 Set D_merge dummy = 1 where "recovered" non-matching exit details from _merge==2 observation above
	sort PersonID Year
	by PersonID: replace D_merge=1 if Year==. & RECOVER[_n-1]==1 & _merge==2

	* 17.12 Drop if D_merge==1, and drop RECOVER
	drop if D_merge==1
	drop RECOVER

	* 17.13 Create dummy variables for the merge values 2 & 3
	gen M2=0
	replace M2=1 if _merge==2
	gen M3=0
	replace M3=1 if _merge==3

	* 17.14 By PersonID, sum the dummies for merge = 2 and sum the dummies for merge = 3
	sort PersonID
	by PersonID: egen s_M2=sum(M2)
	by PersonID: egen s_M3=sum(M3)

	* 17.15 List relevant variables for all employee observations for employees with a remaining _merge==2 observation
	list PersonID Year Year_Exit_MERGE Exitdate_EXIT Exitdate ExitReason_EXIT if s_M2>=1
	* > Many of the instances listed here have a matched exit observation for the employee's year end record with a reason such as "mutual agreement" and then the unmatched exit observation pertains to a much later year with the reason "Retirement"

	* 17.16 Create RETIRE_LATER dummy variable and set = 1 where _merge=3 for the employee's last observation, and for the later unmatched exit observation, the exit reason is "retirement" 
	gen RETIRE_LATER=0 if s_M2>=1 & LASTN==1
	sort PersonID Year
	by PersonID: replace RETIRE_LATER=1 if _merge==3 & RETIRE_LATER==0 & Exitdate_EXIT[_n+1]>Year+1 & Year[_n+1]==. & ExitReason_EXIT[_n+1]=="Retirement"

	* 17.17 Tab the exit reason for the matched exit observation where the employee "retires" later
	tab ExitReason_EXIT if RETIRE_LATER==1 
	* > 6 instances of "employer's reason", 21 instances of "mutual agreement" and 1 instance of "retirement" -- these reasons seem more likely than the retirement at a later time, so drop the related _merge==2 observations

	* 17.18 Set D_merge dummy = 1 where will not record exit details as relate to a later "retirement"
	sort PersonID Year
	by PersonID: replace D_merge=1 if Year==. & _merge==2 & RETIRE_LATER[_n-1]==1

	* 17.19 Drop if D_merge==1
	drop if D_merge==1

	* 17.20 Recreate the s_m2 and s_M3 variables
	drop s_M2 s_M3
	sort PersonID
	by PersonID: egen s_M2=sum(M2)
	by PersonID: egen s_M3=sum(M3)
	tab s_M2
	tab PersonID if s_M2>=1

	* 17.21 List relevant variables for all employee observations for employees with a remaining _merge==2 observation
	list PersonID Year Year_Exit_MERGE Exitdate_EXIT Exitdate ExitReason_EXIT if s_M2>=1

	* 17.22 Visually inspect remaining employee observations where the employee has a remaining _merge==2 observation, and change recorded exit reason to unmerged reason as appropriate; see if need to retain exit details 
	* > Below -- picking up most informative exit reason, or if evidence of both voluntary and involuntary exit, treat as involuntary
	* > 616: Leave "mutual agreement" (don't change to "leaving")
	* > 926: Leave "mutual agreement" (don't change to "leaving")
	* > 1149: Leave "mutual agreement" (don't change to "death")
	* > 1736: Leave "other exit reason" (don't change to "leaving" -- both uninformative)
	* > 3333: Replace "leaving" with "mutual agreement"
	replace ExitReason_EXIT="Mutual agreement" if PersonID=="3333" & Year==2009 & ExitReason_EXIT!=""
	* > 3770: Replace "limited work contract" with "mutual agreement" 
	replace ExitReason_EXIT="Mutual agreement" if PersonID=="3770" & Year==2012 & ExitReason_EXIT!=""
	* > 9456: Replace "limited work contract" with "employer's reason" 
	replace ExitReason_EXIT="Employer's reason" if PersonID=="9456" & Year==2011 & ExitReason_EXIT!=""
	* > 9736: Replace "limited work contract" with "mutual agreement"
	replace ExitReason_EXIT="Mutual agreement" if PersonID=="9736" & Year==2011 & ExitReason_EXIT!=""
	* > 11304: Replace "personal reason" with "employer's reason" (if evidence to suggest involuntary, will include the involuntary reason)
	replace ExitReason_EXIT="Employer's reason" if PersonID=="11304" & Year==2009 & ExitReason_EXIT!=""
	* > 11609: Replace "personal reason" with "employer's reason" (if evidence to suggest involuntary, will include the involuntary reason)
	replace ExitReason_EXIT="Employer's reason" if PersonID=="11609" & Year==2009 & ExitReason_EXIT!=""
	* > 17197: Replace "retirement" with "employer's reason"
	replace ExitReason_EXIT="Employer's reason" if PersonID=="17197" & Year==2009 & ExitReason_EXIT!=""
	* > 18563: Replace "other exit reason" with "personal reason" 
	replace ExitReason_EXIT="Personal Reason" if PersonID=="18563" & Year==2008 & ExitReason_EXIT!=""
	* > 18991: Leave "mutual agreement" (don't change to "death")
	* > 19003: Ignore the _merge=2 observation, with exit date of 30apr2014 - no evidence employee left during 2014 as has a 2014 and 2015 observation exit date is 31dec2015
	* > 39165: Replace "dormant work contract" with "employee's reason" (other option was "personal reason" which is similar to "employee's reason")
	replace ExitReason_EXIT="Employee's reason" if PersonID=="39165" & Year==2009 & ExitReason_EXIT!=""
	* > 51796: Leave "personal reason" (don't change to "employee's reason" - both similar)
	* > 63572: Leave "employee's reason" (don't change to "other exit reason)
	* > 73062: Change "leaving" to "employee's reason"
	replace ExitReason_EXIT="Employee's reason" if PersonID=="73062" & Year==2009 & ExitReason_EXIT!=""
	* > 20163211: Change "leaving" to "employer's reason" 
	replace ExitReason_EXIT="Employer's reason" if PersonID=="20163211" & Year==2010 & ExitReason_EXIT!=""
	* > 20163878: Leave "personal reason" (don't change to "other exit reason) 
	* > 20164437: Leave "personal reason" (don't change to "limited work contract")
	* > 20172244: Replace "leaving" with "disinvestment" (more informative)
	replace ExitReason_EXIT="Disinvestment" if PersonID=="20172244" & Year==2009 & ExitReason_EXIT!=""
	* > 20227622: Leave "limited work contract" (don't change to "other exit reason")
	* > 20244702: Nothing to change to, both are "employee's reason"
	* > 20265486: Leave "development" (don't change to "mutual agreement" since present in the year after the exit date recorded with "mutual agreement"))
	   
	* 17.23 "Recover" exit details for one employee identified in listing above 
	* > 45047: Exit date per 2008 observation is 7feb2010, and there is a corresponding exit date where _merge==2 as the employee does not have a 2009 or 2010 observation (but has a 2011 and later observations)
	* > Bring this unmerged observation data to the 2008 observation for this employee  
	sort PersonID Year_Exit_MERGE
	foreach x of varlist ExitReasonCode_EXIT ExitReason_EXIT Employeegroup_EXIT MgmtLevel_EXIT RegionofEmployment_EXIT CountryofEmployment_EXIT Employeegroup_OTHEROB{
	by PersonID: replace `x'= `x'[_n+1] if Year[_n+1]==. & Year_Exit_MERGE[_n+1]==Year+2 & _merge[_n+1]==2 & `x'=="" & PersonID=="45047"
	}
	
	sort PersonID Year_Exit_MERGE
	foreach x of varlist Exitdate_EXIT{
	by PersonID: replace `x'= `x'[_n+1] if Year[_n+1]==. & Year_Exit_MERGE[_n+1]==Year+2 & _merge[_n+1]==2 & `x'==. & PersonID=="45047"
	}

	* 17.24 Drop all remaining instances where _merge==2
	drop if _merge==2
	
** > END OF DEALING WITH _MERGE==2 INSTANCES < 

	* 17.25 Format Entrydate
	format Entrydate %td

** >> Deal with multiple exit dates for an employee << **

	* 17.26 Counts of Exitdate_OTHEROB and Exitdate variables
	count if Exitdate_OTHEROB!=.
	count if Exitdate_OTHEROB!=. & Exitdate==.
	count if Exitdate_OTHEROB!=. & Exitdate!=.
	count if Exitdate_OTHEROB!=. & Exitdate!=. & Exitdate_OTHEROB==Exitdate 
	count if Exitdate_OTHEROB!=. & Exitdate!=. & Exitdate_OTHEROB!=Exitdate 

	* 17.27 List relevant variables where the employee has an entry for both Exitdate_OTHEROB and Exitdate
	list PersonID Year Exitdate_OTHEROB Exitdate if Exitdate_OTHEROB!=. & Exitdate!=. & Exitdate_OTHEROB!=Exitdate 

	* 17.28 Generate DateMin_Exitdate_OTHEROB which is the minimum of Exitdate_OTHEROB and Exitdate, and create FLAGDATE dummy variable and set = to 1 where this minimum exit date value occurs prior to the current year 
	egen DateMin_Exitdate_OTHEROB=rowmin(Exitdate_OTHEROB Exitdate) if Exitdate_OTHEROB!=. & Exitdate!=. & Exitdate_OTHEROB!=Exitdate 
	count if DateMin_Exitdate_OTHEROB!=.
	gen FLAGDATE=0 if DateMin_Exitdate_OTHEROB!=.
	replace FLAGDATE=1 if DateMin_Exitdate_OTHEROB!=. & year(DateMin_Exitdate_OTHEROB)<Year 
	tab FLAGDATE
	* > No instances where FLAGDATE=1 => GOOD

	* 17.29 Rename Exitdate Exitdate_PRIOR, and recreate Exitdate, filling with the prior exitdate value where available, then filling with the Exitdate_OTHEROB value where available, and then replacing with the value from DateMin_Exitdate_OTHEROB where this differs to the existing value and LASTN==1 (otherwise the Exitdate is likely to be ignored later anyway as the employee has an observation in a year after this year)
	rename Exitdate Exitdate_PRIOR
	gen Exitdate=Exitdate_PRIOR
	replace Exitdate=Exitdate_OTHEROB if Exitdate_OTHEROB!=. & Exitdate==.
	replace Exitdate=DateMin_Exitdate_OTHEROB if Exitdate_OTHEROB!=. & Exitdate!=. & Exitdate_OTHEROB!=Exitdate & LASTN==1  

	* 17.30 Create MISS_YEAR dummy variable = 1 where an employee is "missing" (does not have) an observation for the previous year
	drop n
	sort PersonID Year
	by PersonID: gen n=_n
	by PersonID: egen N=max(n)
	sort PersonID Year
	gen MISS_YEAR=0
	by PersonID: replace MISS_YEAR=1 if Year!=Year[_n-1]+1 & n!=1
	tab MISS_YEAR
	* > = 0 for >99% of observations 

	* 17.31 Create STRING variable = 1 where an observation falls in the first (or only) continuous string of observations for an employee, = 2 where an observation falls in the second continous string of observations, ...
	sort PersonID Year
	gen STRING=1 if n==1
	by PersonID: replace STRING=1 if MISS_YEAR==0 & STRING[_n-1]==1
	replace STRING=2 if STRING[_n-1]==1 & MISS_YEAR==1
	by PersonID: replace STRING=2 if MISS_YEAR==0 & STRING[_n-1]==2  
	replace STRING=3 if STRING[_n-1]==2 & MISS_YEAR==1
	by PersonID: replace STRING=3 if MISS_YEAR==0 & STRING[_n-1]==3  
	tab STRING
	count if STRING==.
	* > No instances where missing, creating up to STRING==3 sufficient for all observations

	* 17.32 Within each STRING, create NS and maxNS variables to identify observation numbers, and create LNS dummy variable = 1 where it is the employee's last observation in that string
	sort PersonID STRING Year
	by PersonID STRING: gen NS=_n
	tab NS
	by PersonID STRING: egen maxNS=max(NS)
	gen LNS = 1 if NS==maxNS

	* 17.33 Create M_Exitdate_EXIT and M_Exitdate variables which = max(Exitdate_EXIT) and max(Exitdate) respectively, within each STRING for an employee 
	sort PersonID STRING Year
	by PersonID STRING: egen M_Exitdate_EXIT=max(Exitdate_EXIT)
	by PersonID STRING: egen M_Exitdate=max(Exitdate)
	format Exitdate %td
	format M_Exitdate_EXIT %td
	format M_Exitdate %td

	* 17.34 Count instances where we have M_Exitdate_EXIT but no M_Exitdate and viceversa, and where we have both, count instances where the dates are the same, and where they differ (just for the last observation in the STRING) 
	count if M_Exitdate_EXIT!=. & M_Exitdate==. & LNS==1
	count if M_Exitdate_EXIT==. & M_Exitdate!=. & LNS==1 
	count if M_Exitdate_EXIT!=. & M_Exitdate!=. & LNS==1 
	count if M_Exitdate_EXIT!=. & M_Exitdate!=. & M_Exitdate_EXIT==M_Exitdate & LNS==1
	count if M_Exitdate_EXIT!=. & M_Exitdate!=. & M_Exitdate_EXIT!=M_Exitdate & LNS==1

** 1) Instances where M_Exitdate_EXIT & M_Exitdate are identical **

	* 17.35 Create IDENTICAL dummy and set = 1 where M_Exitdate_EXIT and M_Exitdate are identical, and set = 0 where they are not equal (but have a value for both)
	gen IDENTICAL=0 if M_Exitdate_EXIT!=. & M_Exitdate!=. & M_Exitdate_EXIT!=M_Exitdate & LNS==1 
	replace IDENTICAL=1 if M_Exitdate_EXIT!=. & M_Exitdate!=. & M_Exitdate_EXIT==M_Exitdate & LNS==1 
	tab IDENTICAL

	* 17.36 Create Y_IDENTICAL = year of M_Exitdate if IDENTICAL is = 1
	gen Y_IDENTICAL=year(M_Exitdate) if IDENTICAL==1
	tab Year Y_IDENTICAL

	* 17.37 Create EXCL dummy and set = 1 if Y_IDENTICAL < Year (i.e. if the maximum exit date occurs prior to the year end observation year) 
	gen EXCL=0 if IDENTICAL==1  
	replace EXCL=1 if IDENTICAL==1 & Y_IDENTICAL<Year

	* 17.38 Create EXAMINE dummy and set = 1 if Y_IDENTICAL > Year+1 (i.e. the exit date occurs at a time > current year + 1)
	gen EXAMINE=0 if IDENTICAL==1 & EXCL==0
	replace EXAMINE=1 if IDENTICAL==1 & EXCL==0 & Y_IDENTICAL>Year+1

	* 17.39 Within an employee, where the value of STRING does not equal the value of STRING in the subsequent observation (i.e. there is at least one year end observation "missing"), in the current observation record the year that appears in the next observation 
	sort PersonID Year
	by PersonID: gen NEXT_YEAR=Year[_n+1] if STRING!=STRING[_n+1] & n!=N

	* 17.40 Create Min_Exitdate_EXIT and Min_Exitdate variables which = min(Exitdate_EXIT) and min(Exitdate) respectively, within each STRING for an employee, and create MIN_ID=1 if these two dates are identical 
	sort PersonID STRING Year
	by PersonID STRING: egen Min_Exitdate_EXIT=min(Exitdate_EXIT)
	by PersonID STRING: egen Min_Exitdate=min(Exitdate)
	format Min_Exitdate_EXIT %td
	format Min_Exitdate %td
	gen MIN_ID=0 if Min_Exitdate_EXIT!=. & Min_Exitdate!=. & LNS==1
	replace MIN_ID=1 if Min_Exitdate_EXIT==Min_Exitdate & Min_Exitdate_EXIT!=. & Min_Exitdate!=. & LNS==1
	tab MIN_ID

	* 17.41 Create EXAMINE_NOD dummy and set = 1 if EXAMINE=1 and Min_Exitdate_EXIT==M_Exitdate_EXIT & MIN_ID==1 (i.e. for those observations where the maximum exit date is at a time > current year + 1, we don't have an earlier exit date)
	gen EXAMINE_NOD=0 if EXAMINE==1
	replace EXAMINE_NOD=1 if EXAMINE==1 & Min_Exitdate_EXIT==M_Exitdate_EXIT & MIN_ID==1
	tab EXAMINE_NOD
	* > All = 1 => i.e. those observations that have a much later exit date (> 1 year after the last y/e observation) do not have an earlier exit date recorded => keep the available exit date

	* 17.42 Visually inspect the relevant variables where EXAMINE==1 and the employee has another string of observations in later years
	list PersonID Year Exitdate Exitdate_EXIT M_Exitdate M_Exitdate_EXIT NEXT_YEAR if EXAMINE==1 & NEXT_YEAR!=.
	* > For the one observation that had > one string, the exitdate occurs before the first year in the next string => keep the exit date

	* 17.43 Create EXIT_DATE_USE and set = to M_Exitdate where IDENTICAL=1 & EXCL=0
	gen EXIT_DATE_USE=M_Exitdate if IDENTICAL==1 & EXCL==0
	count if EXIT_DATE_USE!=.
	format EXIT_DATE_USE %td

** 2) Instances where M_Exitdate_EXIT & M_Exitdate are not identical, but both have a value **

* > 2a) Both have the same year *

	* 17.44 Create Exit_diff_SAMEYEAR dummy and set = 1 where the exit date occurs in the same year (for instances where the two exit dates are not the same)
	gen Exit_diff_SAMEYEAR=0 if M_Exitdate_EXIT!=. & M_Exitdate!=. & M_Exitdate_EXIT!=M_Exitdate & LNS==1
	replace Exit_diff_SAMEYEAR=1 if M_Exitdate_EXIT!=. & M_Exitdate!=. & year(M_Exitdate_EXIT)==year(M_Exitdate) & M_Exitdate_EXIT!=M_Exitdate & LNS==1
	tab Exit_diff_SAMEYEAR 

	* 17.45 Where Exit_diff_SAMEYEAR = 1, create FIRST_EXIT_DATE and set to the earlier of M_Exitdate and M_Exitdate_EXIT (assume earliest date is date when decided to terminate relationship)
	* > First, create DAYS_DIFF variable, and summarize
	gen DAYS_DIFF=abs(M_Exitdate-M_Exitdate_EXIT) if Exit_diff_SAMEYEAR==1
	summarize DAYS_DIFF, detail
	tab DAYS_DIFF
	* > In 96% of these instances, the difference is only 1 day
	drop DAYS_DIFF
	egen FIRST_EXIT_DATE=rowmin(M_Exitdate M_Exitdate_EXIT) if Exit_diff_SAMEYEAR==1 

	* 17.46 Create EXCL_2 dummy and set = 1 where FIRST_EXIT_DATE < Year (i.e. if the year of the maximum exit date occurs prior to the year end observation year)  
	gen EXCL_2=0 if FIRST_EXIT_DATE!=. 
	replace EXCL_2=1 if FIRST_EXIT_DATE!=. & year(FIRST_EXIT_DATE)<Year

	* 17.47 Create EXAMINE_2 dummy and set = 1 if FIRST_EXIT_DATE > Year+1 (i.e. the exit date occurs at a time > current year + 1)
	gen EXAMINE_2=0 if FIRST_EXIT_DATE!=. & EXCL_2==0
	replace EXAMINE_2=1 if FIRST_EXIT_DATE!=. & EXCL_2==0 & year(FIRST_EXIT_DATE)>Year+1

	* 17.48 Visually inspect the relevant variables where EXAMINE_2==1 
	list PersonID Year Exitdate Exitdate_EXIT M_Exitdate M_Exitdate_EXIT Min_Exitdate Min_Exitdate_EXIT NEXT_YEAR if EXAMINE_2==1 
	* > No earlier exit date recorded for this employee => keep the available exit date

	* 17.49 Replace EXIT_DATE_USE with the FIRST_EXIT_DATE value if EXCL_2=0
	replace EXIT_DATE_USE=FIRST_EXIT_DATE if EXCL_2==0
	
* > 2b) The exit dates pertain to different years *

	* 17.50 Create Exit_diff_days = difference between M_Exitdate_EXIT and M_Exitdate (for instances where the two exit dates are not the same and the years differ)
	gen Exit_diff_days=M_Exitdate_EXIT-M_Exitdate if M_Exitdate_EXIT!=. & M_Exitdate!=. & M_Exitdate_EXIT!=M_Exitdate & Exit_diff_SAMEYEAR==0
	count if Exit_diff_days!=.

* >> 2b1) Different years - but less than 365 days difference << *

	* 17.51 Create IMM_DIFF dummy and set = 1 if |Exit_diff_days| < 365 (where the two exit dates are not the same and the years differ)
	gen IMM_DIFF=0 if Exit_diff_days!=. 
	replace IMM_DIFF=1 if Exit_diff_days!=. & Exit_diff_days>-365 & Exit_diff_days<365
	tab IMM_DIFF
	tab Exit_diff_days if IMM_DIFF==1
	* > 78% of cases, 1 day different (from visual inspection, generally where one exit date is 12/31/Year, and one exit date is 1/1/Year+1)

	* 17.52 Where IMM_DIFF = 1, create FIRST_EXIT_DATE_2 and set to the earlier of M_Exitdate and M_Exitdate_EXIT; create FIRST_EXIT_DATE_2B and set to maximum of those two dates
	egen FIRST_EXIT_DATE_2=rowmin(M_Exitdate M_Exitdate_EXIT) if IMM_DIFF==1 
	format FIRST_EXIT_DATE_2 %td
	egen FIRST_EXIT_DATE_2B=rowmax(M_Exitdate M_Exitdate_EXIT) if IMM_DIFF==1 
	format FIRST_EXIT_DATE_2B %td

	* 17.53 Create EXCL_3 dummy and set = 1 where FIRST_EXIT_DATE_2 < Year (i.e. if the year of the chosen maximum exit date occurs prior to the year end observation year) 
	gen EXCL_3=0 if IMM_DIFF==1
	replace EXCL_3=1 if IMM_DIFF==1 & year(FIRST_EXIT_DATE_2)<Year

	* 17.54 Visually inspect the relevant variables where EXCL_3=1 in case the year of the later of M_Exitdate and M_Exitdate_EXIT is not < Year 
	list PersonID Year Exitdate Exitdate_EXIT M_Exitdate M_Exitdate_EXIT Min_Exitdate Min_Exitdate_EXIT FIRST_EXIT_DATE_2 if EXCL_3==1 
	* > Minimum and maximum exit dates are all before Year, except for PersonID 2392 -- here use M_Exitdate_EXIT

	* 17.55 Replace FIRST_EXIT_DATE_2 with M_Exitdate_EXIT for PersonID 2392 in Year 2015
	replace FIRST_EXIT_DATE_2 = M_Exitdate_EXIT if PersonID=="2392" & Year==2015

	* 17.56 Drop, and recreate EXCL_3 dummy variable
	drop EXCL_3
	gen EXCL_3=0 if IMM_DIFF==1
	replace EXCL_3=1 if IMM_DIFF==1 & year(FIRST_EXIT_DATE_2)<Year

	* 17.57 Create EXAMINE_3 dummy and set = 1 if FIRST_EXIT_DATE_2 > Year+1 (i.e. the exit date occurs at a time > current year + 1)
	gen EXAMINE_3=0 if IMM_DIFF==1
	replace EXAMINE_3=1 if IMM_DIFF==1 & year(FIRST_EXIT_DATE_2)>Year+1 
	* > None

	* 17.58 Replace EXIT_DATE_USE with the FIRST_EXIT_DATE_2 value if EXCL_3=0  & difference in exit days is less than 185 days (6 months) (i.e. where difference in days across the two maximum exit dates is < than six months, 
	*       use the earliest date -- except one change made above), replace with the FIRST_EXIT_DATE_2B value if EXCL_3 and difference in days is more than 185 days (6 months) (i.e. where difference in days across the two 
	*       maximum exit dates is greater than 185 days, use the latest date), provided year(FIRST_EXIT_DATE_2B) is not > Year+1 [assuming that if end relationship would leave within 6 months]
	replace EXIT_DATE_USE=FIRST_EXIT_DATE_2 if EXCL_3==0 & abs(Exit_diff_days)<=185
	replace EXIT_DATE_USE=FIRST_EXIT_DATE_2B if EXCL_3==0 & abs(Exit_diff_days)>185 & Exit_diff_days!=. & year(FIRST_EXIT_DATE_2B)<=Year+1

* >> 2b2) Different years - and more than 365 days difference << *

	* 17.59 Where IMM_DIFF = 0, create FIRST_EXIT_DATE_3 and set to the earlier of M_Exitdate and M_Exitdate_EXIT (where the two exit dates are not the same, the years differ, and the difference in dates is > 365 days)
	egen FIRST_EXIT_DATE_3=rowmin(M_Exitdate M_Exitdate_EXIT) if IMM_DIFF==0 
	format FIRST_EXIT_DATE_3 %td

	* 17.60 Create EXCL_4 dummy and set = 1 where FIRST_EXIT_DATE_3 < Year (i.e. if the year of the chosen minimum exit date occurs prior to the year end observation year) 
	gen EXCL_4=0 if IMM_DIFF==0
	replace EXCL_4=1 if IMM_DIFF==0 & year(FIRST_EXIT_DATE_3)<Year

	* 17.61 For the instances where EXCL_4=1, replace FIRST_EXIT_DATE_3 with the alternative exit date (i.e. M_Exitdate instead of M_Exitdate_EXIT and vice versa), which will set the exitdate to a later date
	gen CHANGE=0 if EXCL_4==1
	replace CHANGE=1 if EXCL_4==1 & FIRST_EXIT_DATE_3!=M_Exitdate
	replace FIRST_EXIT_DATE_3 = M_Exitdate if FIRST_EXIT_DATE_3!=M_Exitdate & EXCL_4==1
	replace FIRST_EXIT_DATE_3 = M_Exitdate_EXIT if FIRST_EXIT_DATE_3!=M_Exitdate_EXIT & EXCL_4==1 & CHANGE==0 

	* 17.62 Drop, and recreate EXCL_4 dummy variable 
	drop EXCL_4
	gen EXCL_4=0 if IMM_DIFF==0
	replace EXCL_4=1 if IMM_DIFF==0 & year(FIRST_EXIT_DATE_3)<Year

	* 17.63 Create EXAMINE_4 dummy and set = 1 if FIRST_EXIT_DATE_3 > Year+1 (i.e. the exit date occurs at a time > current year + 1)
	gen EXAMINE_4=0 if FIRST_EXIT_DATE_3!=. & EXCL_4==0
	replace EXAMINE_4=1 if FIRST_EXIT_DATE_3!=. & EXCL_4==0 & year(FIRST_EXIT_DATE_3)>Year+1

	* 17.64 Visually inspect the relevant variables where EXAMINE_4==1 
	list PersonID Year Exitdate Exitdate_EXIT M_Exitdate M_Exitdate_EXIT Min_Exitdate Min_Exitdate_EXIT FIRST_EXIT_DATE_3 NEXT_YEAR if EXAMINE_4==1 
	* > PersonID: 1716; No earlier exit date recorded for this employee and only one string of observations - so keep date
	* > PersonIDs 16920, 58717, 61348, 71681 -- missing year-end observations (i.e. multiple strings) => visual inspections of these employees
	* > By no evidence of leaving company and returning, I mean no later entry date that lines up with pattern of observations and no exit reason such as employer's reason, etc.
	* > 16920 -- appears may have simply been inactive in 2011 (no evidence of leaving company and returning), but replace FIRST_EXIT_DATE_3 with missing as will pick up 2015 exit date against later string of observations 
	* > 58717 -- appears may have simply been inactive in 2013 (no evidence of leaving company and returning), but replace FIRST_EXIT_DATE_3 with missing since appears likely to simply be end of a limited work contract, not an actual exit
	* > 61348 -- appears may have simply been inactive in 2013 (no evidence of leaving company and returning), but replace FIRST_EXIT_DATE_3 with missing since will pick up 2014 exit date (reason - leaving) against later string of observations
	* > 71681 -- appears may have simply been inactive in 2011 (employee did have 31dec2009 exit date given with "employee's reason" but the employee had a 2010 observation so this does not line up), replace FIRST_EXIT_DATE_3 with missing as employee did not leave on this date (which is in 2012 -- employee still present in 2015)

	* 17.65 Replace FIRST_EXIT_DATE_3 with missing for employees identified above
	replace FIRST_EXIT_DATE_3=. if PersonID=="16920" | PersonID=="58717" | PersonID=="61348" | PersonID=="71681" 

	* 17.66 Replace EXIT_DATE_USE with the FIRST_EXIT_DATE_3 value if EXCL_4=0 (i.e. where difference in the two maximum exit dates is > than a year, use the earliest date -- except for changes made above -- since perhaps on some type of leave before exiting, but is no longer active - so treat as exited)
	replace EXIT_DATE_USE=FIRST_EXIT_DATE_3 if EXCL_4==0

** 3) Instances where M_Exitdate_EXIT & M_Exitdate are identical **	
	count if M_Exitdate_EXIT!=. & M_Exitdate==. & LNS==1

	* 17.67 Create EXCL_5 dummy and set = 1 where M_Exidate_EXIT < Year (i.e. if the year of the maximum exit date occurs prior to the year end observation year) (no M_Exitdate)
	gen EXCL_5=0 if  M_Exitdate_EXIT!=. & M_Exitdate==. & LNS==1
	replace EXCL_5=1 if EXCL_5==0 & year(M_Exitdate_EXIT)<Year

	* 17.68 Create EXAMINE_5 dummy and set = 1 if M_Exitdate_EXIT > Year+1 (i.e. the exit date occurs at a time > current year + 1) 
	gen EXAMINE_5=0 if M_Exitdate_EXIT!=. & M_Exitdate==. & LNS==1 & EXCL_5==0
	replace EXAMINE_5=1 if EXAMINE_5==0 & year(M_Exitdate_EXIT)>Year+1
	* > No instances

	* 17.69 Replace EXIT_DATE_USE with the M_Exitdate_EXIT value if EXCL_5=0
	replace EXIT_DATE_USE=M_Exitdate_EXIT if EXAMINE_5==0

** 4) Instances where exit date only in M_Exitdate **
	count if M_Exitdate_EXIT==. & M_Exitdate!=. & LNS==1

	* 17.70 Create EXCL_6 dummy and set = 1 where M_Exidate < Year (i.e. if the year of the maximum exit date occurs prior to the year end observation year) (no M_Exitdate_EXIT)
	gen EXCL_6=0 if  M_Exitdate_EXIT==. & M_Exitdate!=. & LNS==1
	replace EXCL_6=1 if EXCL_6==0 & year(M_Exitdate)<Year

	* 17.71 Create EXAMINE_6 dummy and set = 1 if M_Exitdate > Year+1 (i.e. the exit date occurs at a time > current year + 1) 
	gen EXAMINE_6=0 if EXCL_6==0
	replace EXAMINE_6=1 if EXAMINE_6==0 & year(M_Exitdate)>Year+1

	* 17.72 Create Use_Min variable and set = 1 if EXAMINE_6=1 & the exitdate is recorded against the last (or only) string for the employee, & Min_Exitdate differs to M_Exitdate & Min_Exitdate >= Year
	gen Use_MIN=0 if EXAMINE_6==1
	replace Use_MIN=1 if EXAMINE_6==1 & Min_Exitdate!=M_Exitdate & year(Min_Exitdate)>=Year

	* 17.73 Replace EXAMINE_6 with a value of 0 (change from 1) if the exitdate is recorded against the last (or only) string for the employee => since will retain the exit date 
	replace EXAMINE_6=0 if EXAMINE_6==1 & NEXT_YEAR==.

	* 17.74 Visually inspect the relevant variables where EXAMINE_6==1
	list PersonID Year M_Exitdate Min_Exitdate NEXT_YEAR if EXAMINE_6==1 

	* 17.75 Count instances where M_Exitdate!=Min_Exitdate & EXAMINE_6=1 
	count if M_Exitdate!=Min_Exitdate & EXAMINE_6==1

	* 17.76 Visually inspect the relevant variables where M_Exitdate!=Min_Exitdate & EXAMINE_6=1 
	list PersonID Year M_Exitdate Min_Exitdate NEXT_YEAR if EXAMINE_6==1 & M_Exitdate!=Min_Exitdate

	* 17.77 Replace EXCL_6 with a value of 1 if the next year (start of next string) for which an employee has an observation is >= the year of the exit date, exclude the exitdate
	replace EXCL_6=1 if year(M_Exitdate)>=NEXT_YEAR & EXAMINE_6==1

	* 17.78 Replace EXIT_DATE_USE with the M_Exitdate value if EXCL_6=0; replace EXIT_DATE_USE with the Min_Exitdate if Use_MIN==0
	replace EXIT_DATE_USE=M_Exitdate if EXCL_6==0
	replace EXIT_DATE_USE=Min_Exitdate if Use_MIN==1 & EXCL_6==0

	* 17.79 Double-check EXIT_DATE_USE is only recorded against the last observation in a string for an employee; and ensure no exit date values are before the current year
	count if EXIT_DATE_USE!=. & LNS!=1
	* > 0 => GOOD
	count if year(EXIT_DATE_USE)<Year
	* > 0 => GOOD
	count if EXIT_DATE_USE!=. & LNS==1
	count if year(EXIT_DATE_USE)>=Year & EXIT_DATE_USE!=.
	count if year(EXIT_DATE_USE)==Year & EXIT_DATE_USE!=.
	count if year(EXIT_DATE_USE)==Year+1 & EXIT_DATE_USE!=.
	count if year(EXIT_DATE_USE)>Year+1 & EXIT_DATE_USE!=.
	
** > END OF DEALING WITH EXIT DATES < 

	* 17.80 Create ExitReason_EXIT2 and set = to ExitReason_EXIT, and ExitReason_EXIT from above observation within string if ExitReason_EXIT is blank
	gen ExitReason_EXIT2 = ExitReason_EXIT
	sort PersonID STRING Year
	by PersonID: replace ExitReason_EXIT2=ExitReason_EXIT[_n-1] if ExitReason_EXIT=="" & NS!=1 & PersonID==PersonID[_n-1]

		* 17.81 Create EXIT_REASON_USE variable and set = to ExitReason_EXIT2
	gen EXIT_REASON_USE = ExitReason_EXIT2 if EXIT_DATE_USE!=.
	
	* 17.82 Visually inspect employee observations where ExitReason_EXIT!=ExitReason, and replace EXIT_REASON_USE with ExitReason (in place of ExitReason_EXIT) as deemed appropriate 
	* > If both reasons seem as likely as each other, rely on EXITReason_EXIT as this came from the exit data (as in the past, if evidence to suggest involuntary turnover, use that reason rather than a voluntary turnover reason)
	list PersonID Year EXIT_DATE_USE Exitdate_EXIT ExitReason_EXIT2 Exitdate ExitReason if ExitReason_EXIT2!="" & ExitReason!="" & EXIT_DATE_USE!=. & ExitReason_EXIT2!=ExitReason

	* 3483: Leave "development" (don't change to "limited work contract")
	* 7471: Leave "personal reason" (don't change to "leaving")
	* 7686: Leave "employee's reason" (don't change to "leaving")
	* 8135: Leave "early retirement" (don't change to "retirement")
	* 9179: Leave "mutual agreement" (don't change to "limited work contract")

	* 9355: Leave "development" (don't change to "limited work contract")
	* 9966: Leave "mutual agreement" (don't change to "limited work contract")
	* 12965: Leave "employer's reason" (don't change to "retirement")
	* 13514: Leave "employer's reason" (don't change to "early retirement")
	* 14928: Leave "early retirement" (don't change to "employee's reason")

	* 16872: Leave "employer's reason" (don't change to "mutual agreement")
	* 17348: Leave "financial" (don't change to "employee's reason")
	* 18439: Leave "personal reason" (don't change to "other exit reason")
	* 18563: Leave "personal reason" (don't change to "other exit reason")
	* 21083: Leave "personal reason" (don't change to "limited work contract")

	* 31010: Leave "limited work contract" (don't change to "leaving")
	* 31387: Leave "personal reason" (don't change to "limited work contract")
	* 40287: Leave "other exit reason" (don't change to "leaving")
	* 40764: Leave "personal reason" (don't change to "other exit reason")
	* 49686: Leave "employee's reason" (don't change to "limited work contract")

	* 58717: Leave "mutual agreement" (don't change to "limited work contract")
	* 71012: Leave "personal reason" (don't change to "limited work contract")
	* 71479: Leave "personal reason" (don't change to "limited work contract")
	* 77984: Leave "limited work contract" (don't change to "leaving") 
	* 20165860: Leave "external job offer" (don't change to "other exit reason")

	* 20170403: Replace "leaving" with "retirement"
	replace EXIT_REASON_USE="Retirement" if PersonID=="20170403" & Year==2008 & EXIT_REASON_USE!=""
	* 20170436: Replace "leaving" with "retirement"
	replace EXIT_REASON_USE="Retirement" if PersonID=="20170436" & Year==2008 & EXIT_REASON_USE!=""
	* 20170453: Replace "leaving" with "retirement"
	replace EXIT_REASON_USE="Retirement" if PersonID=="20170453" & Year==2008 & EXIT_REASON_USE!=""
	* 20172412: Leave "development" (don't change to "limited work contract")
	* 20227616: Leave "personal reason" (don't change to "limited work contract")

	* 20227881: Leave "personal reason" (don't change to "limited work contract")
	* 20228582: Leave "personal reason" (don't change to "limited work contract")
	* 20231191: Leave "external job offer" (don't change to "personal reason")
	* 20231424: Leave "personal reason" (don't change to "limited work contract")
	* 20237441: Replace "limited work contract" with "mutual agreement"
	replace EXIT_REASON_USE="Mutual agreement" if PersonID=="20237441" & Year==2015 & EXIT_REASON_USE!=""

	* 20242299: Leave "personal reason" (don't change to "limited work contract")
	* 20251872: Leave "mutual agreement" (don't replace with "limited work contract")
	* 20256128: Leave "personal reason" (don't change to "limited work contract")
	* 20263081: Replace "job design" with "mutual agreement"
	replace EXIT_REASON_USE="Mutual agreement" if PersonID=="20263081" & Year==2015 & EXIT_REASON_USE!=""
	* 20266523: Leave "personal reason" (don't replace with "limited work contract")

	* 20284962: Leave "personal reason" (don't replace with "limited work contract")

	* 17.83 Where EXIT_REASON_USE is blank (ie. ExitReason_EXIT is blank), fill EXIT_REASON_USE with ExitReason
	replace EXIT_REASON_USE=ExitReason if EXIT_REASON_USE=="" & ExitReason!="" & EXIT_DATE_USE!=.

	* 17.84 Rename ExitReason ExitReason_ORIG and create ExitReason = ExitReason_ORIG
	rename ExitReason ExitReason_ORIG
	gen ExitReason = ExitReason_ORIG

	* 17.85 Replace ExitReason with ExitReason from above observation (within the same string) where Exit dates are consistent across the observations
	sort PersonID STRING Year
	by PersonID STRING: replace ExitReason=ExitReason[_n-1] if (Exitdate==Exitdate[_n-1] | EXIT_DATE_USE==Exitdate[_n-1] | EXIT_DATE_USE==Exitdate_EXIT[_n-1]) & ExitReason=="" & ExitReason[_n-1]!="" & NS!=1 & PersonID==PersonID[_n-1] 
	by PersonID STRING: replace ExitReason=ExitReason[_n-2] if (Exitdate==Exitdate[_n-2] | EXIT_DATE_USE==Exitdate[_n-2] | EXIT_DATE_USE==Exitdate_EXIT[_n-2]) & ExitReason=="" & ExitReason[_n-2]!="" & NS!=1 & PersonID==PersonID[_n-2]
	by PersonID STRING: replace ExitReason=ExitReason[_n-3] if (Exitdate==Exitdate[_n-3] | EXIT_DATE_USE==Exitdate[_n-3] | EXIT_DATE_USE==Exitdate_EXIT[_n-3]) & ExitReason=="" & ExitReason[_n-3]!="" & NS!=1 & PersonID==PersonID[_n-3]
	by PersonID STRING: replace ExitReason=ExitReason[_n-4] if (Exitdate==Exitdate[_n-4] | EXIT_DATE_USE==Exitdate[_n-4] | EXIT_DATE_USE==Exitdate_EXIT[_n-4]) & ExitReason=="" & ExitReason[_n-4]!="" & NS!=1 & PersonID==PersonID[_n-4]
	by PersonID STRING: replace ExitReason=ExitReason[_n-5] if (Exitdate==Exitdate[_n-5] | EXIT_DATE_USE==Exitdate[_n-5] | EXIT_DATE_USE==Exitdate_EXIT[_n-5]) & ExitReason=="" & ExitReason[_n-5]!="" & NS!=1 & PersonID==PersonID[_n-5]
	by PersonID STRING: replace ExitReason=ExitReason[_n-6] if (Exitdate==Exitdate[_n-6] | EXIT_DATE_USE==Exitdate[_n-6] | EXIT_DATE_USE==Exitdate_EXIT[_n-6]) & ExitReason=="" & ExitReason[_n-6]!="" & NS!=1 & PersonID==PersonID[_n-6]
	by PersonID STRING: replace ExitReason=ExitReason[_n-7] if (Exitdate==Exitdate[_n-7] | EXIT_DATE_USE==Exitdate[_n-7] | EXIT_DATE_USE==Exitdate_EXIT[_n-7]) & ExitReason=="" & ExitReason[_n-7]!="" & NS!=1 & PersonID==PersonID[_n-7]

	* 17.86 Where EXIT_REASON_USE is blank (ie. ExitReason_EXIT is blank), fill EXIT_REASON_USE with ExitReason
	replace EXIT_REASON_USE=ExitReason if EXIT_REASON_USE=="" & ExitReason!="" & EXIT_DATE_USE!=.

	* 17.87 Gen SIM_Date variable and set = 1 where Exit date in above observation (within person, within string) has the same year as Exitdate in this observation 
	sort PersonID STRING Year
	by PersonID STRING: gen SIM_Date=1 if (year(Exitdate)==year(Exitdate[_n-1]) | year(EXIT_DATE_USE)==year(Exitdate[_n-1]) | year(EXIT_DATE_USE)==year(Exitdate_EXIT[_n-1])) & PersonID==PersonID[_n-1]

	* 17.88 Replace ExitReason with ExitReason from above observation (within the same string) where Exitdates are similar across the observations
	sort PersonID STRING Year
	by PersonID STRING: replace ExitReason=ExitReason[_n-1] if SIM_Date==1 & ExitReason=="" & ExitReason[_n-1]!="" & NS!=1 & PersonID==PersonID[_n-1]
	
	* 17.89 Where EXIT_REASON_USE is blank (ie. ExitReason_EXIT is blank), fill EXIT_REASON_USE with ExitReason
	replace EXIT_REASON_USE=ExitReason if EXIT_REASON_USE=="" & ExitReason!="" & EXIT_DATE_USE!=.

	* 17.90 Create NO_REASON_EXIT_YEAR variable and set = to year of exit for instances where EXIT_DATE_USE!=. & EXIT_REASON_USE=="", and tab variable
	gen NO_REASON_EXIT_YEAR = year(EXIT_DATE_USE) if EXIT_DATE_USE!=. & EXIT_REASON_USE==""  
	tab NO_REASON_EXIT_YEAR
	* > Only 46 employees who exited in the period 2009-2015 have an exit date but no exit reason ==> OK 

	* 17.91 Drop variables no longer needed 
	drop no countno MINYEAR D_merge M2 M3 s_M2 s_M3 RETIRE_LATER DateMin_Exitdate_OTHEROB  FLAGDATE M_Exitdate_EXIT  M_Exitdate Min_Exitdate_EXIT Min_Exitdate IDENTICAL Y_IDENTICAL EXCL EXAMINE EXAMINE_NOD 
	drop Exit_diff_SAMEYEAR FIRST_EXIT_DATE EXCL_2 EXAMINE_2 Exit_diff_days IMM_DIFF FIRST_EXIT_DATE_2 EXCL_3 EXAMINE_3 FIRST_EXIT_DATE_3 EXCL_4 CHANGE EXAMINE_4 EXCL_5 EXAMINE_5 EXCL_6 Use_MIN EXAMINE_6 SIM_Date

	* 17.92 Create PRIOR_EXIT_REASON and PRIOR_EXIT_DATE variables bringing exit reason and exit date to the subsequent observation for an employee where an employee has more than one string of observations
	count if NS==1 & n!=1
	gen PRIOR_EXIT_REASON=""
	sort PersonID STRING Year
	by PersonID: replace PRIOR_EXIT_REASON=EXIT_REASON_USE[_n-1] if NS==1 & n!=1
	by PersonID: gen PRIOR_EXIT_DATE=EXIT_DATE_USE[_n-1] if NS==1 & n!=1

	* 17.93 Bring PRIOR_EXIT_DATE to all observations within a string for an employee
	sort PersonID STRING Year
	by PersonID STRING: replace PRIOR_EXIT_DATE=PRIOR_EXIT_DATE[_n-1] if NS!=1 
	
** > END OF DEALING WITH EXIT REASONS < 

	* 17.94 Create NEW_ENTRYDATE variable and set = 1 if the employee has a prior exit date listed against the observation and the year of the Entrydate occurs after the year of the prior Exitdate (evidence that the employee did in fact leave the company and return at a later time)
	gen NEW_ENTRYDATE=1 if year(Entrydate)>year(PRIOR_EXIT_DATE) & PRIOR_EXIT_DATE!=.
	tab NEW_ENTRYDATE

	* 17.95 Create C_NEW_ENTRYDATE and sum over a PersonID/STRING the NEW_ENTRYDATE variable, then count where this variable > 0 & NS==1 (number of unique employees where there is evidence that the employee exited and re-entered)
	sort PersonID STRING Year
	by PersonID STRING: egen C_NEW_ENTRYDATE=sum(NEW_ENTRYDATE)
	count if C_NEW_ENTRYDATE>0 & NS==1
	* > 44 employees - evidence suggests that 44 employees left the company and then returned => seems more than reasonable given the number of employees
	
	* 17.96 Create Min_Entrydate and Max_Entrydate variables and set = to the minimum Entrydate and maximum Entrydate respectively, within PersonID/STRING
	sort PersonID STRING Year
	by PersonID STRING: egen Min_Entrydate=min(Entrydate)
	by PersonID STRING: egen Max_Entrydate=max(Entrydate)
	format Min_Entrydate %td
	format Max_Entrydate %td

	* 17.97 Count instances where NEW_ENTRYDATE==1, and within these, where Entrydate==Min_Entrydate and Entrydate==Max_Entrydate (but not Min_Entrydate)
	count if NEW_ENTRYDATE==1
	count if NEW_ENTRYDATE==1 & Entrydate==Min_Entrydate 
	count if NEW_ENTRYDATE==1 & Entrydate!=Min_Entrydate & Entrydate==Max_Entrydate

	* 17.98 Examine relevant variables for 2 instances not accounted for above, and deal with accordingly
	list PersonID Year Entrydate Min_Entrydate Max_Entrydate if NEW_ENTRYDATE==1 & Entrydate!=Min_Entrydate & Entrydate!=Max_Entrydate
	* > 8324 and 64105 
	* > 8324 has exit date on 01 jan 2009 (for 2008 observation), but a 2010 observation with 02 jan 2009 entry date (no 2009 observation)
	* > It does not appear this employee ever really exited (since why would they exit for one day), replace any instances of EXIT_DATE_USE and EXIT_REASON_USE with missing, as well as the PRIOR variables and NEW_ENTRYDATE
	replace EXIT_DATE_USE=. if PersonID=="8324"
	replace PRIOR_EXIT_DATE=. if PersonID=="8324"
	replace EXIT_REASON_USE="" if PersonID=="8324"
	replace PRIOR_EXIT_REASON="" if PersonID=="8324"
	replace NEW_ENTRYDATE=. if PersonID=="8324"
	* > 64105 - one instance where missing entrydate -- for this employee fine to use Min_Entrydate

	* 17.99 Create USE_MINDATE and USE_MAXDATE variables and set = 1 to indicate which date will use for the employees' Entrydate (for those that exited and re-entered -- use the one that occurs after the prior exit date), and then sum over PersonID/STRING
	gen USE_MINDATE=1 if NEW_ENTRYDATE==1 & Entrydate==Min_Entrydate
	replace USE_MINDATE=1 if NEW_ENTRYDATE==1 & PersonID=="64105" 
	gen USE_MAXDATE=1 if NEW_ENTRYDATE==1 & Entrydate!=Min_Entrydate & PersonID!="64105" 
	tab USE_MINDATE USE_MAXDATE  
	* > No overlaps 
	sort PersonID STRING Year
	by PersonID STRING: egen SUM_MINDATE=sum(USE_MINDATE)
	by PersonID STRING: egen SUM_MAXDATE=sum(USE_MAXDATE)
	tab SUM_MINDATE SUM_MAXDATE
	* > No instances where both > 0

	* 17.100 Rename Entrydate Entrydate_SUPERSEDED, and regenerate Entrydate populating with Entrydate_SUPERSEDED
	rename Entrydate Entrydate_SUPERSEDED
	gen Entrydate = Entrydate_SUPERSEDED

	* 17.101 Replace Entrydate with Min_Entrydate (Max_Entrydate) if SUM_MINDATE>0 (SUM_MAXDATE>0)
	replace Entrydate = Min_Entrydate if SUM_MINDATE>0
	replace Entrydate = Max_Entrydate if SUM_MAXDATE>0

	* 17.102 Count any instances where I believe an employee exited and reentered and the current Entrydate occurs BEFORE the prior exit date, and count where it occurs AFTER the prior exit date (one obs per employee)
	count if Entrydate<PRIOR_EXIT_DATE & PRIOR_EXIT_DATE!=. & C_NEW_ENTRYDATE>0
	count if Entrydate>PRIOR_EXIT_DATE & PRIOR_EXIT_DATE!=. & C_NEW_ENTRYDATE>0
	count if Entrydate>PRIOR_EXIT_DATE & PRIOR_EXIT_DATE!=. & C_NEW_ENTRYDATE>0 & NS==1

	* 17.103 For those employees with an exit date, and then a later string of observations, but I don't believe the employee exited and reentered, replace EXIT_DATE_USE and EXIT_DATE_REASON with missing
	count if PRIOR_EXIT_DATE!=. & C_NEW_ENTRYDATE==0 & NS==1
	sort PersonID STRING Year
	by PersonID: replace EXIT_DATE_USE=. if PRIOR_EXIT_DATE[_n+1]!=. & C_NEW_ENTRYDATE[_n+1]==0 & NS[_n+1]==1
	by PersonID: replace EXIT_REASON_USE="" if PRIOR_EXIT_DATE[_n+1]!=. & C_NEW_ENTRYDATE[_n+1]==0 & NS[_n+1]==1

	* 17.104 Create EMP_TIME variable, and set =1 for employee's string of observations up to and including first exit date, set = 2 for next string of observations up to and including second exit date (effectively recreating the STRING variable but this time only starting a new number where the employee actually exited the company and returned), and tab this variable
	sort PersonID Year
	gen EMP_TIME=1 if n==1
	by PersonID: replace EMP_TIME=1 if EMP_TIME[_n-1]==1 & EXIT_DATE_USE==.
	by PersonID: replace EMP_TIME=1 if EMP_TIME[_n-1]==1 & EXIT_DATE_USE!=.
	by PersonID: replace EMP_TIME=2 if EMP_TIME[_n-1]==1 & EXIT_DATE_USE[_n-1]!=.
	by PersonID: replace EMP_TIME=2 if EMP_TIME[_n-1]==2 & EXIT_DATE_USE==.
	by PersonID: replace EMP_TIME=2 if EMP_TIME[_n-1]==2 & EXIT_DATE_USE!=.
	tab EMP_TIME
	* All observations have a value for EMP_TIME

	* 17.105 Drop variables not needed
	drop PRIOR_EXIT_DATE C_NEW_ENTRYDATE MISS_YEAR ExitReason_EXIT2 ExitReason Min_Entrydate Max_Entrydate USE_MINDATE USE_MAXDATE SUM_MINDATE SUM_MAXDATE Exitdate _merge 
	drop D_MMDDYYYY D_DDMMYYYY Max_Exitdate 
	drop Min_Entry NO NEW_ENTRYDATE Exitdate_PRIOR Exitdate_2 LDOY OBS_LDOY Entrydate_SUPERSEDED ABSin[Currency]_OTHEROB
	drop Coaching_ARating Convinc_ARating CustOr_ARating Decisiv_ARating Driving_ARating Leader_ARating Rating_ARating Peopleuntil2012_ARating PerfQuality_ARating PerformanceR_ARating Perspec_ARating PotInitiative_ARating PotentialR_ARating Teamw_ARating _merge_ARating
	drop ExitReasonCode_EXIT ExitReason_EXIT ExitReason_OTHEROB ExitReason_ORIG Exitdate_EXIT Exitdate_ORIG Exitdate_OTHEROB KEEP RegionofEmployment_EXIT
	drop dup dup_CHECK STRING

	* 17.106 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Prepared_Data.dta", replace
	clear

	* 17.107 Delete all preparation files created within program, except final file (and any ML5 files that will use in later programs)
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2008 Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2009 Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2010 Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2011 Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2012 Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2013 Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2014 Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2015 Data.dta"

	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2009-2014 Exit Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/2015 Exit Data.dta"

	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined 2008-2015 Data_interim.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined 2008-2015 Data.dta"

	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Additional 2008 Rating Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Additional 2009 Rating Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2010 Rating Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2011 Rating Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2012 Rating Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2013 Rating Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Updated 2014 Rating Data.dta"

	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined Updated 2008-2014 Rating Data.dta"

	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ONE_OBS_PERSON_YEAR_2008-2015_Data.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ONE_OBS_PERSON_YEAR_2008-2015_Data_v2.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ONE_OBS_PERSON_YEAR_2008-2015_Data_w_ARating.dta"

	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined_Exit_Data.dta"

	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML5 Append 1.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML5 Append 2.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML5 Append 3.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML5 Append 4.dta"

**************************************************************************************************************************************************************************************************************************
* PROGRAM 18: Further Data Processing & Validity Testing I
* Input file: "Prepared_Data.dta"
* Steps:
	* 18.1 Import Functions_wCount excel spreadsheet, drop and modify variables as needed, and save as dta file
	* 18.2 Call prepared data dataset
	* 18.3 Tab BirthYear, rename BirthYear BirthYear_ORIG, create BIRTHYEAR and set = to BirthYear_ORIG, replace BIRTHYEAR with missing if = 1900
	* 18.4 Tab GenderKey, and create MALE dummy variable
	* 18.5 Tab HomeCountryExpats, rename HomeCountryExpats HomeCountryExpats_ORIG, create HOMECOUNTRY and set = to HomeCountryExpats_ORIG, replace with missing or modified name as appropriate to ensure consistency across variables
	* 18.6 Tab HostCountryExpats, rename HostCountryExpats HostCountryExpats_ORIG, create HOSTCOUNTRY and set = HostCountryExpats_ORIG, replace with missing or modified name as appropriate to ensure consistency across variables
	* 18.7 Replace CountryofEmployment with modified names as appropriate to ensure consistency across variables
	* 18.8 Replace COUNTRYWORK with modified names as appropriate to ensure consistency across variables, and relabel variable
	* 18.9 Count number of delegate observations where I previously had a corresponding observation in the same year (e.g. guest observation) but COUNTRYWORK is blank, list variables of interest for these instances
	* 18.10 Fill COUNTRYWORK as appropriate for case identified above where COUNTRYWORK is missing 
	* 18.11 Examine instances where COUNTRYWORK is blank (employee did not have more than one observation in a year), the employee has an entry for HOSTCOUNTRY and CountryofEmployment==HOSTCOUNTRY; then update COUNTRYWORK as deemed appropriate (generally filling with HOSTCOUNTRY unless the Employeegroup indicates the employee is not a guest, impat or delegate)
	* 18.12 Examine instances where COUNTRYWORK is blank (employee did not have more than one observation in a year), the employee has an entry for HOSTCOUNTRY and CountryofEmployment!=HOSTCOUNTRY; then update COUNTRYWORK as deemed appropriate (filling with HOSTCOUNTRY if the employee is an impat or delegate, otherwise filling with HOMECOUNTRY)
	* 18.13 Count if there are any instances where COUNTRYWORK is blank but there is an entry for HOSTCOUNTRY or HOMECOUNTRY, and update COUNTRYWORK as deemed appropriate
	* 18.14 Tab Employeegroup where COUNTRYWORK is blank (HOSTCOUNTRY and HOMECOUNTRY are also blank in these instances), and for these remaining instances where COUNTRYWORK is blank (vast majority of cases since most employees are local employees), fill with CountryofEmployment
	* 18.15 Merge file with Functions file using Function
	* 18.16 Tab Function where _merge==1 to check it's only observations missing Function, then drop _merge variable
	* 18.17 Rename Function Function_ORIG, and rename NEW_FUNCTION FUNCTION, tab FUNCTION
	* 18.18 Format and label Entrydate, rename ENTRYDATE, create and tab EntryYear (based on Entrydate), and create and tab EntryMonth (based on Entrydate) 
	* 18.19 Tab Employeegroup, rename TYPE and label variable
	* 18.20 Rename MgmtLevelDate MgmtLevelDate_ORIG, create MgmtLevelDate and set = to MgmtLevelDate_ORIG, and replace MgmtLevelDate with missing if = #
	* 18.21 Parse MgmtLevelDate into three variables because currently in the format DD.MM.YYYY in some instances and MM.YYYY in other instances
	* 18.22 Create MgmtLevelYear, MgmtLevelMonth, and MgmtLevelDay variables using split MgmtLevelDate variables, and destring created variables
	* 18.23 Generate dummy variable = 1 if full Mgmt Level date information available (i.e. DD.MM.YYYY)
	* 18.24 Create, label and format CURRENTMLDATE variable, and drop variables no longer needed to create this variable
	* 18.25 Check CURRENTMLDATE variable created for all instances where MgmtLevelDate available
	* 18.26 Rename MgmtLevel MgmtLevel_ORIG, create MGMTLEVEL=MgmtLevel_ORIG, tab MGMTLEVEL
	* 18.27 Tab PercentageofFullPartTime, rename PercentageofFullPartTime PercentageofFullPartTime_ORIG, create PercentageofFullPartTime=PercentageofFullPartTime_ORIG  
	* 18.28 Investigate handful of instances where PercentageofFullPartTime == 0 or PercentageofFullPartTime > 100, and deal with accordingly
	* 18.29 Rename PercentageofFullPartTime PERCWORK 
	* 18.30 Create FULLTIME dummy based on PERCWORK
	* 18.31 Rename BU BU_ORIG, create BU=BU_ORIG, tab BU and replace with missing if = #
	* 18.32 Create and label new BUSUNIT variable, mapping old and new business unit codes to the same new business unit code (based on phone call with [NAME OF COMPANY CONTACT REMOVED]), then rename BU bu
	* 18.33 Tab EducationDegree, rename EducationDegree EducationDegree_ORIG, create EducationDegree=EducationDegree_ORIG, replace with missing if = 0 or Not assigned
	* 18.34 Create EDUCLEVEL variable based on EducationDegree and mapping provided by company
	* 18.35 Create Rating_PY_NEW variable and set = to Rating_YE from the prior year where available 
	* 18.36 Count instances where Rating_PY_NEW==Rating_PY and instances where Rating_PY_NEW!=Rating_PY (Rating_PY using [NAME OF COMPANY CONTACT REMOVED]'s yearly data; Rating_PY from [NAME OF COMPANY CONTACT REMOVED]'s data), examine and deal with accordingly (repeat for performance and potential))
	* 18.37 Drop Rating_PY_NEW variable and relabel Rating_PY
	* 18.38 Tab Rating_PY & PerformanceR_PY, and Rating_PY & PotentialR_PY to ensure consistent, and repeat for Rating_YE and PerformanceR_YE, PotentialR_YE 
	* 18.39 Check if any instances where no Rating_PY rating but there is a PerformanceR_PY and vice versa, and repeat for YE variables, and deal with any instances accordingly
	* 18.40 Check if any instances where no Rating_PY rating but there is a PotentialR_PY and vice versa, and repeat for YE variables
	* 18.41 Create a dummy variable = 1 where PerformanceR_PY = L or M or S or T (i.e. a true performance rating), and create a dummy variable = 1 where PotentialR_PY = 1 or 2 or 3 or 4 (i.e. a true potential rating),  and repeat for YE variables
	* 18.42 List employee plus relevant variables if D_Performance_PY=1 & D_Potential_PY=0 or if D_Performance_PY=0 & D_Potential_PY=1, and repeat for YE variables
	* 18.43 Create new YEAR END and PRIOR YEAR performance and potential rating variables, with only L / M / S /T // 1 / 2 / 3 / 4, otherwise missing
	* 18.44 Rename performance and potential variables 
	* 18.45 Summarize ABSin[Currency], rename ABSin[Currency] ABSin[Currency]_ORIG, create ABSin[Currency] and set = to ABSin[Currency]_ORIG, count if ABSin[Currency]=0 and replace as missing
	* 18.46 Sort by variables of interest and list variables of interest if ABSin[Currency]<15,000
	* 18.47 Replace ABSin[Currency] with missing if ABSin[Currency]<15,000 (value appears too low) & SalaryPosition_inSalaryBand is 0 or missing 
	* 18.48 Summarize SalaryPosition_inSalaryBand, rename SalaryPosition_inSalaryBand SalaryPosition_inSalaryBand_ORIG, create SalaryPosition_inSalaryBand and set = SalaryPosition_inSalaryBand,  count if SalaryPosition_inSalaryBand=0, and replace as missing
	* 18.49 Summarize SalaryPosition_inSalaryBand again, create SALARYPOS_WINDSORIZED variable and set = to SalaryPosition_inSalaryBand, and then windsorize at the 1% and 99% levels
	* 18.50 Drop and then recreate n and N variables within PersonID
	* 18.51 Create STIin[Currency]_TY variable and set = to STIin[Currency] from the subsequent observation
	* 18.52 Summarize STIin[Currency]_TY, rename STIin[Currency]_TY STIin[Currency]_TY_ORIG, create STIin[Currency]_TY and set = to STIin[Currency]_TY_ORIG, count if STIin[Currency]_TY<0, and replace as missing if <0
	* 18.53 Create and label STI_ZERO dummy variable and set = 1 if STIin[Currency]_TY=0, then count if STIin[Currency]_TY=0, and replace as missing (my understanding is that everyone in the STI plan would receive at least some $ payout)
	* 18.54 Save output file
	* 18.55 Remove file no longer needed
* Output file: "Processed Data.dta"
**************************************************************************************************************************************************************************************************************************

	* 18.1 Import Functions_wCount excel spreadsheet, drop and modify variables as needed, and save as dta file
	** >> I had previously exported a listing of all functions to excel and then created a new function variable which groups similar functions together into a broader functional category 
	clear
	import excel "/Volumes/cdeller_project/Beyond Performance Project/Data Processing_Validity Testing/2016-04-14_Functions_wCount.xlsx", firstrow
	drop if B==0
	drop B Note
	replace NEW_FUNCTION="" if NEW_FUNCTION=="UNKNOWN"
	tab NEW_FUNCTION
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Functions.dta", replace
	clear

	* 18.2 Call prepared data dataset
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Prepared_Data.dta"		
	
	* 18.3 Tab BirthYear, rename BirthYear BirthYear_ORIG, create BIRTHYEAR and set = to BirthYear_ORIG, replace BIRTHYEAR with missing if = 1900
	tab BirthYear
	* > 2 instances where BirthYear=1900; next BirthYear=1938
	* > Replace birth years =1900 with missing ([NAME OF COMPANY CONTACT REMOVED] advised could be default date in system)
	rename BirthYear BirthYear_ORIG
	gen BIRTHYEAR=BirthYear_ORIG
	replace BIRTHYEAR=. if BIRTHYEAR==1900

	* 18.4 Tab GenderKey, and create MALE dummy variable
	tab GenderKey
	gen MALE=.
	replace MALE=1 if (GenderKey=="Male" | GenderKey=="male")
	replace MALE=0 if (GenderKey=="Female" | GenderKey=="female")
	tab MALE GenderKey
	label variable MALE "Male Dummy Variable (= 1 if Male, = 0 if Female)"

	* 18.5 Tab HomeCountryExpats, rename HomeCountryExpats HomeCountryExpats_ORIG, create HOMECOUNTRY and set = to HomeCountryExpats_ORIG, replace with missing or modified name as appropriate to ensure consistency across variables
	tab HomeCountryExpats
	rename HomeCountryExpats HomeCountryExpats_ORIG
	gen HOMECOUNTRY = HomeCountryExpats_ORIG
	replace HOMECOUNTRY="" if HOMECOUNTRY=="0"
	replace HOMECOUNTRY="" if HOMECOUNTRY=="Not assigned"
	replace HOMECOUNTRY="Country 56" if HOMECOUNTRY=="Country 56-variant"
	replace HOMECOUNTRY="Country 73" if HOMECOUNTRY=="Country 73-variant"
	replace HOMECOUNTRY="Country 76" if HOMECOUNTRY=="Country 76-variant"

	* 18.6 Tab HostCountryExpats, rename HostCountryExpats HostCountryExpats_ORIG, create HOSTCOUNTRY and set = HostCountryExpats_ORIG, replace with missing or modified name as appropriate to ensure consistency across variables
	tab HostCountryExpats
	rename HostCountryExpats HostCountryExpats_ORIG
	gen HOSTCOUNTRY=HostCountryExpats_ORIG
	replace HOSTCOUNTRY="" if HOSTCOUNTRY=="0"
	replace HOSTCOUNTRY="" if HOSTCOUNTRY=="Not assigned"
	replace HOSTCOUNTRY="Country 7" if HOSTCOUNTRY=="Country 7-variant"
	replace HOSTCOUNTRY="Country 19" if HOSTCOUNTRY=="Country 19-variant"
	replace HOSTCOUNTRY="Country 56" if HOSTCOUNTRY=="Country 56-variant"
	replace HOSTCOUNTRY="Country 73" if HOSTCOUNTRY=="Country 73-variant"
	replace HOSTCOUNTRY="Country 76" if HOSTCOUNTRY=="Country 76-variant"

	* 18.7 Replace CountryofEmployment with modified names as appropriate to ensure consistency across variables
	replace CountryofEmployment="Country 7" if CountryofEmployment=="Country 7-variant"
	replace CountryofEmployment="Country 19" if CountryofEmployment=="Country 19-variant"
	replace CountryofEmployment="Country 56" if CountryofEmployment=="Country 56-variant"
	replace CountryofEmployment="Country 73" if CountryofEmployment=="Country 73-variant"
	replace CountryofEmployment="Country 76" if CountryofEmployment=="Country 76-variant"

	* 18.8 Replace COUNTRYWORK with modified names as appropriate to ensure consistency across variables, and relabel variable
	replace COUNTRYWORK="Country 73" if COUNTRYWORK=="Country 73-variant"
	replace COUNTRYWORK="Country 76" if COUNTRYWORK=="Country 76-variant"
	label variable COUNTRYWORK "Country where Employee is Working"

	* 18.9 Count number of delegate observations where I previously had a corresponding observation in the same year (e.g. guest observation) but COUNTRYWORK is blank, list variables of interest for these instances
	count if COUNTRYWORK=="" & Employeegroup=="Delegate" & OTHER_OB!=""
	* > 1 instance
	list CountryofEmployment HOSTCOUNTRY OTHER_OB if COUNTRYWORK=="" & Employeegroup=="Delegate" & OTHER_OB!=""  
	* > Will simply replace COUNTRYWORK with CountryofEmployment or HOSTCOUNTRY for this case since CountryofEmployment=HOSTCOUNTRY

	* 18.10 Fill COUNTRYWORK as appropriate for case identified above where COUNTRYWORK is missing 
	replace COUNTRYWORK=CountryofEmployment if COUNTRYWORK=="" & Employeegroup=="Delegate" & OTHER_OB!=""
	count if COUNTRYWORK=="" & Employeegroup=="Delegate" & OTHER_OB!="" 
	* > 0 instances

	* 18.11 Examine instances where COUNTRYWORK is blank (employee did not have more than one observation in a year), the employee has an entry for HOSTCOUNTRY and CountryofEmployment==HOSTCOUNTRY; then update COUNTRYWORK as deemed appropriate (generally filling with HOSTCOUNTRY unless the Employeegroup indicates the employee is not a guest, impat or delegate)
	count if COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment==HOSTCOUNTRY
	tab Employeegroup if COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment==HOSTCOUNTRY
	count if HOMECOUNTRY!="" & COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment==HOSTCOUNTRY & Employeegroup!="Guest" & Employeegroup!="Impat" & Employeegroup!="Delegate"
	* > Use HOMECOUNTRY as COUNTRYWORK even though there is a HOSTCOUNTRY and HOSTCOUNTRY=CountryofEmployment, as assume Employeegroup is most reliable variable
	replace COUNTRYWORK=HOSTCOUNTRY if COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment==HOSTCOUNTRY & (Employeegroup=="Guest" | Employeegroup=="Impat" | Employeegroup=="Delegate") 
	replace COUNTRYWORK=HOMECOUNTRY if COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment==HOSTCOUNTRY & Employeegroup!="Guest" & Employeegroup!="Impat" & Employeegroup!="Delegate" 

	* 18.12 Examine instances where COUNTRYWORK is blank (employee did not have more than one observation in a year), the employee has an entry for HOSTCOUNTRY and CountryofEmployment!=HOSTCOUNTRY; then update COUNTRYWORK as deemed appropriate (filling with HOSTCOUNTRY if the employee is an impat or delegate, otherwise filling with HOMECOUNTRY)
	count if COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment!=HOSTCOUNTRY
	tab Employeegroup if COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment!=HOSTCOUNTRY 
	replace COUNTRYWORK=HOSTCOUNTRY if COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment!=HOSTCOUNTRY & (Employeegroup=="Impat" | Employeegroup=="Delegate") 
	* > Check if HOMECOUNTRY available for all employees above that are not "Delegate" or "Impat" 
	count if HOMECOUNTRY!="" & COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment!=HOSTCOUNTRY & Employeegroup!="Impat" & Employeegroup!="Delegate"
	* > Yes, all cases -- use HOMECOUNTRY as COUNTRYWORK 
	* > Check if for these cases CountryofEmployment=HOMECOUNTRY
	count if HOMECOUNTRY!="" & COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment!=HOSTCOUNTRY & CountryofEmployment==HOMECOUNTRY & Employeegroup!="Impat" & Employeegroup!="Delegate"
	* > Almost all cases
	replace COUNTRYWORK=HOMECOUNTRY if COUNTRYWORK=="" & HOSTCOUNTRY!="" & CountryofEmployment!=HOSTCOUNTRY & Employeegroup!="Impat" & Employeegroup!="Delegate" 

	* 18.13 Count if there are any instances where COUNTRYWORK is blank but there is an entry for HOSTCOUNTRY or HOMECOUNTRY, and update COUNTRYWORK as deemed appropriate
	count if COUNTRYWORK=="" & HOSTCOUNTRY!=""
	count if COUNTRYWORK=="" & HOMECOUNTRY!=""
	* > Check if here HOMECOUNTRY==CountryofEmployment
	count if COUNTRYWORK=="" & HOMECOUNTRY!="" & HOMECOUNTRY==CountryofEmployment
	* > Examine the instances where HOMECOUNTRY!=CountryofEmployment
	list CountryofEmployment HOMECOUNTRY HOSTCOUNTRY Employeegroup if COUNTRYWORK=="" & HOMECOUNTRY!="" & HOMECOUNTRY!=CountryofEmployment
	* > All Impats where CountryofEmployment!=HOMECOUNTRY and HOSTCOUNTRY is blank => use CountryofEmployment for COUNTRYWORK
	replace COUNTRYWORK=CountryofEmployment if COUNTRYWORK=="" & HOMECOUNTRY!="" & HOMECOUNTRY!=CountryofEmployment

	* 18.14 Tab Employeegroup where COUNTRYWORK is blank (HOSTCOUNTRY and HOMECOUNTRY are also blank in these instances), and for these remaining instances where COUNTRYWORK is blank (vast majority of cases since most employees are local employees), fill with CountryofEmployment
	tab Employeegroup if COUNTRYWORK==""
	replace COUNTRYWORK=CountryofEmployment if COUNTRYWORK==""

	* 18.15 Merge file with Functions file using Function
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Processed_Data_INTERIM_FILE.dta", replace 
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Processed_Data_INTERIM_FILE.dta"
	merge m:m Function using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Functions.dta"  

	* 18.16 Tab Function where _merge==1 to check it's only observations missing Function, then drop _merge variable
	tab Function if _merge==1
	* > No observations
	drop _merge

	* 18.17 Rename Function Function_ORIG, and rename NEW_FUNCTION FUNCTION, tab FUNCTION
	rename Function Function_ORIG
	rename NEW_FUNCTION FUNCTION
	label variable FUNCTION "Employee's Functional Area"
	tab FUNCTION

	* 18.18 Format and label Entrydate, rename ENTRYDATE, create and tab EntryYear (based on Entrydate), and create and tab EntryMonth (based on Entrydate)
	format Entrydate %td
	label variable Entrydate "Date Joined Company"
	rename Entrydate ENTRYDATE
	gen EntryYear=year(ENTRYDATE) if ENTRYDATE!=.
	tab EntryYear
	* > All look reasonable (1952 - 2015)
	gen EntryMonth=month(ENTRYDATE) if ENTRYDATE!=.
	tab EntryMonth

	* 18.19 Tab Employeegroup, rename TYPE and label variable
	tab Employeegroup
	rename Employeegroup TYPE
	label variable TYPE "Employee Type (e.g. impat, local employee)"
	
	* 18.20 Rename MgmtLevelDate MgmtLevelDate_ORIG, create MgmtLevelDate and set = to MgmtLevelDate_ORIG, and replace MgmtLevelDate with missing if = #
	rename MgmtLevelDate MgmtLevelDate_ORIG
	gen MgmtLevelDate=MgmtLevelDate_ORIG
	replace MgmtLevelDate="" if MgmtLevelDate=="#"

	* 18.21 Parse MgmtLevelDate into three variables because currently in the format DD.MM.YYYY in some instances and MM.YYYY in other instances
	split MgmtLevelDate, parse(.)

	* 18.22 Create MgmtLevelYear, MgmtLevelMonth, and MgmtLevelDay variables using split MgmtLevelDate variables, and destring created variables
	* > Note: If full date information, DD.MM.YYYY, MgmtLevelDate1 = day, MgmtLevelDate2 = month, MgmtLevelDate3 = year
	* >       If incomplete data information, MM.YYYY,  MgmtLevelDate1 = month, MgmtLevelDate2 = year
	gen MgmtLevelYear=MgmtLevelDate3
	replace MgmtLevelYear=MgmtLevelDate2 if MgmtLevelDate3==""
	gen MgmtLevelMonth=MgmtLevelDate2 if MgmtLevelDate3!=""
	replace MgmtLevelMonth=MgmtLevelDate1 if MgmtLevelDate3==""
	gen MgmtLevelDay= MgmtLevelDate1 if MgmtLevelDate3!=""
	destring(MgmtLevelYear), replace
	destring(MgmtLevelMonth), replace
	destring(MgmtLevelDay), replace

	* 18.23 Generate dummy variable = 1 if full Mgmt Level date information available (i.e. DD.MM.YYYY)
	gen Full_MLdate=0
	replace Full_MLdate=1 if (MgmtLevelYear!=. & MgmtLevelMonth!=. & MgmtLevelDay!=.)
	
	* 18.24 Create, label and format CURRENTMLDATE variable, and drop variables no longer needed to create this variable
	* > If full date information available, simply combine MgmtLevelMonth, MgmtLevelDay, MgmtLevelYear
	gen CURRENTMLDATE=mdy(MgmtLevelMonth,MgmtLevelDay,MgmtLevelYear) if Full_MLdate==1 
	* > If incomplete date information available, and entry month and year match management level month and year, use Entry date as CURRENTMLDATE
	replace CURRENTMLDATE=ENTRYDATE if (CURRENTMLDATE==. & EntryYear==MgmtLevelYear & EntryMonth==MgmtLevelMonth)
	* > Tab  MgmtLevelDay
	tab MgmtLevelDay
	* > Vast majority (75%) have MMgmtLevelDay=1 
	* > If incomplete data information available, and entry month and year do not match management level month and year, combine MgmtLevelMonth, MgmtLevelYear, and assume promoted on the 1st of the month 
	replace CURRENTMLDATE=mdy(MgmtLevelMonth,1,MgmtLevelYear) if (CURRENTMLDATE==. & MgmtLevelMonth!=. & MgmtLevelYear!=.)
	format CURRENTMLDATE %td
	label variable CURRENTMLDATE "Date Started at Current Mgmt Level"
	drop MgmtLevelYear MgmtLevelMonth MgmtLevelDay MgmtLevelDate1 MgmtLevelDate2 MgmtLevelDate3 Full_MLdate

	* 18.25 Check CURRENTMLDATE variable created for all instances where MgmtLevelDate available
	count if CURRENTMLDATE==. & MgmtLevelDate!=""
	* 0 => GOOD

	* 18.26 Rename MgmtLevel MgmtLevel_ORIG, create MGMTLEVEL=MgmtLevel_ORIG, tab MGMTLEVEL
	rename MgmtLevel MgmtLevel_ORIG
	gen MGMTLEVEL= MgmtLevel_ORIG
	tab MGMTLEVEL
	label variable MGMTLEVEL "Management Level"
	
	* 18.27 Tab PercentageofFullPartTime, rename PercentageofFullPartTime PercentageofFullPartTime_ORIG, create PercentageofFullPartTime=PercentageofFullPartTime_ORIG  
	tab PercentageofFullPartTime // values that appear invalid are 0 (can't be working 0% -- only 12 such instances) and 200% (can't be working more than 100% -- only one such instance)
	rename PercentageofFullPartTime PercentageofFullPartTime_ORIG
	gen PercentageofFullPartTime=PercentageofFullPartTime_ORIG

	* 18.28 Investigate handful of instances where PercentageofFullPartTime == 0 or PercentageofFullPartTime > 100, and deal with accordingly
	list PersonID Year EXIT_DATE_USE PercentageofFullPartTime if (PercentageofFullPartTime==0 | PercentageofFullPartTime==200)
	* > 10 instances have an EXIT_DATE_USE during the current year, perhaps explaining why the percentage = 0
	replace PercentageofFullPartTime=. if PercentageofFullPartTime==0 & EXIT_DATE_USE!=.
	* > 10 changes to missing
	* 66243 (2014) - year prior and susbsequent year, percentage is 100 -- replace 0 with 100
	* 20288365 (2014) - subsequent year (2014 was first year) percentage is 100 -- replace 0 with 100
	* 20277620 (2013) - subsequent year (2013 was first year) percentage is 100 -- replace 200 with 100
	replace PercentageofFullPartTime=100 if (PercentageofFullPartTime==0 | PercentageofFullPartTime==200) & EXIT_DATE_USE==.
	* > 3 changes made

	* 18.29 Rename PercentageofFullPartTime PERCWORK 
	rename PercentageofFullPartTime PERCWORK
	label variable PERCWORK "Employment Percentage"

	* 18.30 Create FULLTIME dummy based on PERCWORK
	gen FULLTIME=.
	replace FULLTIME=0 if PERCWORK!=. & PERCWORK<100
	replace FULLTIME=1 if PERCWORK!=. & PERCWORK==100
	tab PERCWORK FULLTIME 
	label variable FULLTIME "Full Time Dummy (= 1 if Full Time, = 0 if Part Time)"

	* 18.31 Rename BU BU_ORIG, create BU=BU_ORIG, tab BU and replace with missing if = #
	rename BU BU_ORIG 
	gen BU=BU_ORIG
	tab BU
	replace BU="" if BU=="#"
	tab BU Year

	* 18.32 Create and label new BUSUNIT variable, mapping old and new business unit codes to the same new business unit code (based on phone call with [NAME OF COMPANY CONTACT REMOVED]), then rename BU bu
	gen BUSUNIT=""
	replace BUSUNIT="BU1" if BU=="a"
	replace BUSUNIT="BU2" if (BU=="b" | BU=="c")
	replace BUSUNIT="BU3" if (BU=="d" | BU=="e")
	replace BUSUNIT="BU4" if (BU=="f" | BU=="g")
	replace BUSUNIT="BU5" if BU=="h"
	replace BUSUNIT="BU6" if BU=="i"
	label variable BUSUNIT "Business Unit"
	count if BUSUNIT=="" & BU!=""
	tab BUSUNIT BU
	rename BU bu

	* 18.33 Tab EducationDegree, rename EducationDegree EducationDegree_ORIG, create EducationDegree=EducationDegree_ORIG, replace with missing if = 0 or Not assigned
	tab EducationDegree
	rename EducationDegree EducationDegree_ORIG
	gen EducationDegree=EducationDegree_ORIG
	replace EducationDegree="" if EducationDegree=="0"
	replace EducationDegree="" if EducationDegree=="Not assigned"

	* 18.34 Create EDUCLEVEL variable based on EducationDegree and mapping provided by company
	gen EDUCLEVEL=""
	replace EDUCLEVEL="No formal education" if EducationDegree=="not specified"
	replace EDUCLEVEL="Vocational training" if EducationDegree=="Higher Education Entrance" | EducationDegree=="Vocational Training"
	replace EDUCLEVEL="Vocational training + add qual." if EducationDegree=="Examination" | EducationDegree=="HND" | EducationDegree=="Higher Education"
	replace EDUCLEVEL="Bachelor degree" if EducationDegree=="Diploma (College)" | EducationDegree=="Bachelor" | EducationDegree=="Degree"
	replace EDUCLEVEL="Master degree" if EducationDegree=="Diploma (University)" | EducationDegree=="Master" | EducationDegree=="State Examination"
	replace EDUCLEVEL="Post university degree" if EducationDegree=="Phd" | EducationDegree=="Post Graduate Qualification" | EducationDegree=="MBA"
	tab EducationDegree EDUCLEVEL
	label variable EDUCLEVEL "Highest Education Level Attained (Categorical Variable)"

** Performance variables ** 

	* 18.35 Create Rating_PY_NEW variable and set = to Rating_YE from the prior year where available 
	sort PersonID Year
	by PersonID: gen Rating_PY_NEW=Rating_YE[_n-1] if Year==Year[_n-1]+1 & n!=1 & PersonID==PersonID[_n-1]
	sort PersonID Year
	by PersonID: gen PerformanceR_PY_NEW=PerformanceR_YE[_n-1] if Year==Year[_n-1]+1 & n!=1 & PersonID==PersonID[_n-1]
	sort PersonID Year
	by PersonID: gen PotentialR_PY_NEW=PotentialR_YE[_n-1] if Year==Year[_n-1]+1 & n!=1 & PersonID==PersonID[_n-1]

	* 18.36 Count instances where Rating_PY_NEW==Rating_PY and instances where Rating_PY_NEW!=Rating_PY (Rating_PY using [NAME OF COMPANY CONTACT REMOVED]'s yearly data; Rating_PY from [NAME OF COMPANY CONTACT REMOVED]'s data), examine and deal with accordingly (repeat for performance and potential))
	count if Rating_PY_NEW==Rating_PY 
	count if Rating_PY_NEW!=Rating_PY & Rating_PY_NEW!="" & Rating_PY!=""
	* > 0 => Consistent where both available => GOOD
	count if Rating_PY_NEW!=Rating_PY & Rating_PY==""
	tab Rating_PY_NEW if Rating_PY_NEW!=Rating_PY & Rating_PY==""
	* > 15 instances where can recover a valid prior year performance rating from [NAME OF COMPANY CONTACT REMOVED]'s data that is not in [NAME OF COMPANY CONTACT REMOVED]'s data 
	replace Rating_PY=Rating_PY_NEW if Rating_PY_NEW!="" & Rating_PY==""
	replace PerformanceR_PY=PerformanceR_PY_NEW if PerformanceR_PY_NEW!="" & PerformanceR_PY==""
	replace PotentialR_PY=PotentialR_PY_NEW if PotentialR_PY_NEW!="" & PotentialR_PY==""
	count if Rating_PY_NEW!=Rating_PY & Rating_PY_NEW==""
	tab Rating_PY if Rating_PY_NEW!=Rating_PY & Rating_PY_NEW==""
	* > In a conversation with [NAME OF COMPANY CONTACT REMOVED] she said cases where there is a rating in [NAME OF COMPANY CONTACT REMOVED]'s data but not her data could arise where a person received an Rating rating outside of the formal process (e.g. because they were on some form of leave, etc.)) * Hence, use the Rating_PY variable as more complete

	* 18.37 Drop Rating_PY_NEW variable and relabel Rating_PY
	drop Rating_PY_NEW
	tab Rating_PY
	label variable Rating_PY "Combined Prior Year Performance & Potential Rating" 

	* 18.38 Tab Rating_PY & PerformanceR_PY, and Rating_PY & PotentialR_PY to ensure consistent, and repeat for Rating_YE and PerformanceR_YE, PotentialR_YE 
	tab Rating_PY PerformanceR_PY
	tab Rating_PY PotentialR_PY
	tab Rating_YE PerformanceR_YE
	tab Rating_YE PotentialR_YE
	* > Line up perfectly, so can ignore Rating after check below, and use PerformanceR and PotentialR only

	* 18.39 Check if any instances where no Rating_PY rating but there is a PerformanceR_PY and vice versa, and repeat for YE variables, and deal with any instances accordingly
	count if Rating_PY=="" & PerformanceR_PY!=""
	count if Rating_PY!="" & PerformanceR_PY==""
	* > No such instances
	count if Rating_YE=="" & PerformanceR_YE!=""
	count if Rating_YE!="" & PerformanceR_YE==""
	* > 1 instance
	list Rating_YE PerfQuality_YE if Rating_YE!="" & PerformanceR_YE==""
	* > Rating is "T" only (no potential); replace with missing
	replace Rating_YE="" if Rating_YE=="T"

	* 18.40 Check if any instances where no Rating_PY rating but there is a PotentialR_PY and vice versa, and repeat for YE variables
	count if Rating_PY=="" & PotentialR_PY!=""
	count if Rating_PY!="" & PotentialR_PY==""
	count if Rating_PY=="#" & PotentialR_PY==""
	* Accounts for all instances => OK
	count if Rating_YE=="" & PotentialR_YE!=""
	count if Rating_YE!="" & PotentialR_YE==""
	count if Rating_YE=="#" & PotentialR_YE==""
	* Accounts for all instances => OK

	* 18.41 Create a dummy variable = 1 where PerformanceR_PY = L or M or S or T (i.e. a true performance rating), and create a dummy variable = 1 where PotentialR_PY = 1 or 2 or 3 or 4 (i.e. a true potential rating),  and repeat for YE variables
	gen D_Performance_PY=0
	replace D_Performance_PY=1 if ( PerformanceR_PY=="L" | PerformanceR_PY=="M" | PerformanceR_PY=="S" | PerformanceR_PY=="T")

	gen D_Potential_PY=0
	replace D_Potential_PY=1 if (PotentialR_PY=="1" | PotentialR_PY=="2" | PotentialR_PY=="3" | PotentialR_PY=="4")

	gen D_Performance_YE=0
	replace D_Performance_YE=1 if ( PerformanceR_YE=="L" | PerformanceR_YE=="M" | PerformanceR_YE=="S" | PerformanceR_YE=="T")

	gen D_Potential_YE=0
	replace D_Potential_YE=1 if (PotentialR_YE=="1" | PotentialR_YE=="2" | PotentialR_YE=="3" | PotentialR_YE=="4")

	* 18.42 List employee plus relevant variables if D_Performance_PY=1 & D_Potential_PY=0 or if D_Performance_PY=0 & D_Potential_PY=1, and repeat for YE variables
	list PersonID Year Rating_PY PerformanceR_PY PotentialR_PY if D_Performance_PY==1 & D_Potential_PY==0
	* > No such instances
	list PersonID Year Rating_PY PerformanceR_PY PotentialR_PY if D_Performance_PY==0 & D_Potential_PY==1
	* > No such instances
	list PersonID Year Rating_YE PerformanceR_YE PotentialR_YE if D_Performance_YE==1 & D_Potential_YE==0
	* > No such instances
	list PersonID Year Rating_YE PerformanceR_YE PotentialR_YE if D_Performance_YE==0 & D_Potential_YE==1
	* > No such instances

	* 18.43 Create new YEAR END and PRIOR YEAR performance and potential rating variables, with only L / M / S /T // 1 / 2 / 3 / 4, otherwise missing
	gen Performance_YE=PerformanceR_YE
	replace Performance_YE="" if (Performance_YE=="#" | Performance_YE=="Z" | Performance_YE=="ZZ")
	tab Performance_YE
	label variable Performance_YE "Year End Performance Rating (L / M / S / T)"

	gen Potential_YE=PotentialR_YE
	replace Potential_YE="" if (Potential_YE=="#" | Potential_YE=="Z" | Potential_YE=="ZZ")
	tab Potential_YE
	label variable Potential_YE "Year End Potential Rating (1 / 2 / 3 / 4)"

	gen Performance_PY=PerformanceR_PY
	replace Performance_PY="" if (Performance_PY=="#" | Performance_PY=="Z" | Performance_PY=="ZZ")
	tab Performance_PY
	label variable Performance_PY "Prior Year Performance Rating (L / M / S / T)"

	gen Potential_PY=PotentialR_PY
	replace Potential_PY="" if (Potential_PY=="#" | Potential_PY=="Z" | Potential_PY=="ZZ")
	tab Potential_PY
	label variable Potential_PY "Prior Year Potential Rating (1 / 2 / 3 / 4)"

	* 18.44 Rename performance and potential variables 
	rename Performance_YE PERF_YE
	rename Potential_YE POT_YE
	rename Performance_PY PERF_PY
	rename Potential_PY POT_PY
	
** Compensation variables ** 

	* 18.45 Summarize ABSin[Currency], rename ABSin[Currency] ABSin[Currency]_ORIG, create ABSin[Currency] and set = to ABSin[Currency]_ORIG, count if ABSin[Currency]=0 and replace as missing
	summarize ABSin[Currency], detail
	rename ABSin[Currency] ABSin[Currency]_ORIG
	gen ABSin[Currency]=ABSin[Currency]_ORIG
	count if ABSin[Currency]==0
	replace ABSin[Currency]=. if ABSin[Currency]==0

	* 18.46 Sort by variables of interest and list variables of interest if ABSin[Currency]<15,000
	sort ABSin[Currency] CountryofEmployment PersonID Year 
	list PersonID CountryofEmployment MGMTLEVEL Year ABSin[Currency] PERCWORK SalaryPosition_inSalaryBand if ABSin[Currency]<15000

	* 18.47 Replace ABSin[Currency] with missing if ABSin[Currency]<15,000 (value appears too low) & SalaryPosition_inSalaryBand is 0 or missing 
	replace ABSin[Currency]=. if ABSin[Currency]<15000 & (SalaryPosition_inSalaryBand==0 | SalaryPosition_inSalaryBand==.)

	* 18.48 Summarize SalaryPosition_inSalaryBand, rename SalaryPosition_inSalaryBand SalaryPosition_inSalaryBand_ORIG, create SalaryPosition_inSalaryBand and set = SalaryPosition_inSalaryBand,  count if SalaryPosition_inSalaryBand=0, and replace as missing
	summarize SalaryPosition_inSalaryBand, detail
	rename SalaryPosition_inSalaryBand SalaryPosition_inSalaryBand_ORIG
	gen SalaryPosition_inSalaryBand=SalaryPosition_inSalaryBand_ORIG
	count if SalaryPosition_inSalaryBand==0
	replace SalaryPosition_inSalaryBand=. if SalaryPosition_inSalaryBand==0 // replacement per discussion with [NAME OF COMPANY CONTACT REMOVED]

	* 18.49 Summarize SalaryPosition_inSalaryBand again, create SALARYPOS_WINDSORIZED variable and set = to SalaryPosition_inSalaryBand, and then windsorize at the 1% and 99% levels
	summarize SalaryPosition_inSalaryBand, detail
	gen p99_SALARPOS=r(p99)
	gen p01_SALARPOS=r(p1)
	gen SALARYPOS_WINDSORIZED=SalaryPosition_inSalaryBand
	replace SALARYPOS_WINDSORIZED=p99_SALARPOS if SALARYPOS_WINDSORIZED>p99_SALARPOS & SALARYPOS_WINDSORIZED!=.
	replace SALARYPOS_WINDSORIZED=p01_SALARPOS if SALARYPOS_WINDSORIZED<p01_SALARPOS & SALARYPOS_WINDSORIZED!=.
	summarize SALARYPOS_WINDSORIZED, detail
	label variable SALARYPOS_WINDSORIZED "Salary Position in Salary Band windsorized at 1% level"

	* 18.50 Drop and then recreate n and N variables within PersonID
	drop n N
	sort PersonID Year
	by PersonID: gen n=_n
	by PersonID: egen N=max(n)
	label variable n "Employee Observation Number (first sorted by Year)"
	label variable N "Number of Employee Observations for this Employee"

	* 18.51 Create STIin[Currency]_TY variable and set = to STIin[Currency] from the subsequent observation
	* > At the moment, the STI shown in this year's spreadsheet is the STI payout for the prior performance year, per discussion with [NAME OF COMPANY CONTACT REMOVED]
	sort PersonID Year
	by PersonID: gen STIin[Currency]_TY=STIin[Currency][_n+1] if Year==Year[_n+1]-1 & n!=N

	* 18.52 Summarize STIin[Currency]_TY, rename STIin[Currency]_TY STIin[Currency]_TY_ORIG, create STIin[Currency]_TY and set = to STIin[Currency]_TY_ORIG, count if STIin[Currency]_TY<0, and replace as missing if <0
	summarize STIin[Currency]_TY, detail
	rename STIin[Currency]_TY STIin[Currency]_TY_ORIG
	gen STIin[Currency]_TY=STIin[Currency]_TY_ORIG
	count if STIin[Currency]_TY<0
	replace STIin[Currency]_TY=. if STIin[Currency]_TY<0

	* 18.53 Create and label STI_ZERO dummy variable and set = 1 if STIin[Currency]_TY=0, then count if STIin[Currency]_TY=0, and replace as missing (my understanding is that everyone in the STI plan would receive at least some $ payout)
	gen STI_ZERO=1 if STIin[Currency]_TY==0
	tab STI_ZERO
	label variable STI_ZERO "Dummy Variable = 1 if STI Payout was 0"
	count if STIin[Currency]_TY==0
	replace STIin[Currency]_TY=. if STIin[Currency]_TY==0

	* 18.54 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Processed Data.dta", replace
	clear

	* 18.55 Remove file no longer needed
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Processed_Data_INTERIM_FILE.dta"


** REVISIT - update steps at end as will likely drop some steps 
**************************************************************************************************************************************************************************************************************************
* PROGRAM 19: Data Processing & Validity Testing 2
* Input file: "Processed Data.dta"
* Steps:
	* 19.1 Read in processed data file 
	* 19.2 Conduct a high level analysis of MLZ observations, and replace Z with 4 or 5 (whichever seems most reasonable) 
	* 19.3 Sort by PersonID Year, and create observation number variable within PersonID (first drop n variable); create EMP_N = max observations number within EMP_TIME
	* 19.4 Flag instances where, by PersonID, BIRTHYEAR!=BIRTHYEAR[_n-1] -- set f_BirthYear=1
	* 19.5 By PersonID, create M_BirthYear variable, = mode of BIRTHYEAR for the employee (where tied mode, use the minimum value)
	* 19.6 Replace BIRTHYEAR with mode of BIRTHYEAR (M_BirthYear) if M_BirthYear is not missing and BIRTHYEAR does not equal M_BirthYear, tab BIRTHYEAR
	* 19.7 Flag instances where, by PersonID, MALE!=MALE[_n-1] -- set f_Male=1
	* 19.8 By PersonID, create M_Male variable, = mode of MALE for the employee (where tied mode, equal to missing)
	* 19.9 Count instances where MALE is not missing but M_Male is (means multiple modes for the employee) and list variables of interest for these employees)
	* 19.10 Rename MALE Male_ORIG and recreate MALE=Male_ORIG
	* 19.11 Replace MALE with mode of MALE (M_Male) if M_Male is not missing and MALE does not equal M_Male
	* 19.12 Replace MALE with mode of MALE (M_Male) if M_Male is missing (i.e. where multiple modes, replace MALE with missing)
	* 19.13 Flag instances where, by PersonID EMP_TIME, ENTRYDATE!=ENTRYDATE[_n-1] -- set f_Entrydate=1
	* 19.14 By PersonID EMP_TIME, create INV_Entrydate variable = sum(f_Entrydate) -- if >=1, employee has at least one instance where Entrydate differs from one observation to the next
	* 19.15 By PersonID EMP_TIME, create Min_Entrydate variable, = minimum of ENTRYDATE for the employee
	* 19.16 Replace ENTRYDATE with min of ENTRYDATE (Min_Entrydate) if Min_Entrydate is not missing and ENTRYDATE does not equal Min_Entrydate
	* 19.17 Rename CURRENTMLDATE CurrentMLDate_ORIG and recreate CURRENTMLDATE=CurrentMLDate_ORIG
	* 19.18 Create ML_STRING variable = the observation number for the employee within a string of observations (sorted by Year) with the same EMP_TIME value at the same MGMTLEVEL 
	* 19.19 By PersonID and ML_STRING, create Min_CurrentMLDate variable, = minimum of CURRENTMLDATE for the employee by ML_STRING
	* 19.20 Where CURRENTMLDATE is missing, but there is a value for Min_CurrentMLDate, replace CURRENTMLDATE with Min_CurrentMLDate
	* 19.21 Flag instances where, by PersonID EMP_TIME, CURRENTMLDATE!=CURRENTMLDATE[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] -- set f_CurrentMLDate=1	
	* 19.22 By PersonID EMP_TIME, create INV_CurrentMLDate variable = sum(f_CurrentMLDate) -- if >=1, employee has at least one instance where CURRENTMLDATE differs from one observation to the next and MGMTLEVEL is the same
	* 19.23 By PersonID and ML_STRING, create Min2_CurrentMLDate variable = next minimum of CURRENTMLDATE for the employee by ML_STRING (= Min_CurrentMLDate if no other ML date within the STRING)
	* 19.24 Replace CURRENTMLDATE with min of CURRENTMLDATE (Min_CurrentMLDate) if Min_CurrentMLDate is not missing and CURRENTMLDATE does not equal Min_CurrentMLDate
	* 19.25 Replace MGMTLEVEL with MGMTLEVEL from prior observation if appears promoted on the 1st day of the year next year and new management level was recorded against this year's observation; and replace CURRENTMLDATE with date from prior observation 
	* 19.26 Replace MGMTLEVEL with missing if appears new management level in the subsequent year (since an original ML date is in YEAR+1) but new management level is reflected in this year's observation, and this is the first observation for  the employee; replace CURRENTMLDATE with missing
	* 19.27 Replace CURRENTMLDATE with missing if appears new management level in the subsequent year (since an original ml date is in Year+1) but new management level date is recorded against this year, and this is the first observation for  the employee; leave MGMTLEVEL as is
	* 19.28 Given changes made above, recreate MGMTLEVEL string variable
	* 19.29 Count instances where year(CURRENTMLDATE)>Year, and replace these instances with missing (since cannot be promoted to the current management level after this year!); flag these occurences, and bring missing to all observations
	* 19.30 Replace MGMTLEVEL with MGMTLEVEL from prior observation if appears promoted in the subsequent year and new management level is reflected in this year's observation; update CURRENTMLDATE accordingly 
	* 19.31 For observations where the employee has a new management level this year and CURRENTMLDATE is missing, fill with Min_CurrentMLDate if year(Min_CurrentMLDate)=Year; otherwise assume the employee was promoted/demoted on  the first day of the current year
	* 19.32 Update CURRENTMLDATE for subsequent observations -- within same EMP_TIME only
	* 19.33 Replace CURRENTMLDATE with ENTRYDATE if first observation for an employee & year(ENTRYDATE)==Year, and bring to all observations for employee (within MGMTLEVEL)
	* 19.34 Replace CURRENTMLDATE with (1,1,Year) if first observation for an employee, Year>=2010, year(ENTRYDATE)<Year, and CURRENTMLDATE is missing, and bring to all observations for employee (within MGMTLEVEL) 
	* 19.35 Flag instances where, by PersonID, CURRENTMLDATE==CURRENTMLDATE[_n-1] BUT MGMTLEVEL!=MGMTLEVEL[_n-1] -- set f_MLDate_difflevel=1 (i.e. same management level start date is given for two different management levels)
	* 19.36 By PersonID and ML_STRING, create INV_MLDate_difflevel variable = sum(f_MLDate_difflevel) -- if >=1, the CURRENTMLDATE for the string of observations at this MGMTLEVEL = the CURRENTMLDATE for the observations at the previous MGMTLEVEL 
	* 19.37 If INV_MLDate_difflevel>=1 replace CURRENTMLDATE with second-to-minimum value of CURRENTMLDATE (prior to any replacements of CURRENTMLDATE) for this string of observations  (note: second-to-minimum may = minimum), but then replace CURRENTMLDATE with missing if year(CURRENTMLDATE)>Year 
	* 19.38 Recreate f_MLDate_difflevel given step above should have reduced the number of instances flagged
	* 19.39 By PersonID and ML_STRING, create INV_MLDate_difflevel variable = sum(f_MLDate_difflevel) -- if >=1, the CURRENTMLDATE for the string of observations at this MGMTLEVEL = the CURRENTMLDATE for the observations at  the previous MGMTLEVEL 
	* 19.40 Investigate the handful of instances flagged above, and deal with as seems most reasonable on a case-by-case basis
	* 19.41 Recreate f_MLDate_difflevel given step above should have reduced the number of instances flagged
	* 19.42 Flag instances where, by PersonID (sorted by Year), year(CURRENTMLDATE)<Year[_n-1]+1 but a different MGMTLEVEL compared to MGMTLEVEL[_n-1] -- set f_MLDate_early=1, create EARLY by PersonID 
	* 19.43 Count number of instances where the CURRENTMLDATE is within the year where an employee changed to a new management level, and where it is not to ensure accurate in majority of instances
	* 19.44 Create Mode_MLDate variable within PersonID and ML_STRING; also create Max_MLDate
	* 19.45 Replace CURRENTMLDATE if currently year(CURRENTMLDATE) is prior to this year, and this is the first year at a new MGMTLEVEL; replace first with Mode_MLDate if year(Mode_MLDate)==Year, then Max_MLDate if year(Max_MLDate)==Year, then (1,1,Year) for any  remaining instances, then flow down to subsequent observations at the same MGMTLEVEL
	* 19.46 Flag instances where, by PersonID (sorted by Year), CURRENTMLDATE<Year[_n-1]+1 but a different MGMTLEVEL compared to MGMTLEVEL[_n-1] -- set f_MLDate_early=1, create EARLY by PersonID 
	* 19.47 Flag instances where Year<Year(CURRENTMLDATE), display all observations for these employees, and deal with accordingly
	* 19.48 Recreate f_MLDate_difflevel & f_CurrentMLDate to check if any instances flagged
	* 19.49 By PersonID EMP_TIME, create INV_CurrentMLDate variable = sum(f_CurrentMLDate) -- if >=1, employee has at least one instance where CURRENTMLDATE differs from one observation to the next and MGMTLEVEL is the same
	* 19.50 Display all observations and relevant variables for employees where INV_CurrentMLDate>=1, and deal with on a case-by-case basis as seems appropriate
	* 19.51 Recreate f_MLDate_difflevel & f_CurrentMLDate to make sure no instances 
	* 19.52 Create MLdate_b_entrydate variable and set = 1 if ENTRYDATE>CURRENTMLDATE 
	* 19.53 Generate SAMEYM variable, = 1 if the year and month of CURRENTMLDATE = the year and month of ENTRYDATE (i.e. only the specific day differs) and MLdate_b_entrydate=1, and for these cases, replace CURRENTMLDATE  with ENTRYDATE
	* 19.54 Recreate MLdate_b_entrydate variable given step above should have reduced number of instances flagged; first create new variable FLAG and set = MLdate_b_entrydate
	* 19.55 Replace CURRENTMLDATE with ENTRYDATE if the CURRENTMLDATE and ENTRYDATE share the same year, and MLdate_b_entrydate==1
	* 19.56 Where ENTRYDATE>CURRENTMLDATE, replace ENTRYDATE with missing (since ENTRYDATE must be <= CURRENTMLDATE) since current ENTRYDATE is invalid; bring to all observations for the employee
	* 19.57 Recreate MLdate_b_entrydate variable given step above should have resolved flagged instances 
	* 19.58 Set MLdate_b_entrydate to 1 if FLAG!=1 (not previously flagged) & ENTRYDATE>CurrentMLDate_ORIG (may not have used the earliest ORIG date for the CURRENTMLDATE, but the entry date should not occur after the earliest CurrentMLDate on record)
	* 19.59 Display relevant variables for all observations for the employees flagged above and deal with on a case-by-case basis as seems appropriate
	* 19.60 Recreate MLdate_b_entrydate variable (two conditions) and ensure any flagged instances OK
	* 19.61 Recreate f_Entrydate, f_CurrentMLDate, and f_MLDate_difflevel to make sure all data consistent
	* 19.62 Create flag_ML variable and set =1 where CURRENTMLDATE is missing & MGMTLEVEL differs to prior MGMTLEVEL and EMP_TIME is the same
	* 19.63 By PersonID EMP_TIME, create INV_flag_ML variable = sum(flag_ML) 
	* 19.64 Display all observations and relevant variables for employees where INV_flag_ML>=1, and deal with on a case-by-case basis as seems approrpaite
	* 19.65 Recreate f_Entrydate, f_CurrentMLDate, and f_MLDate_difflevel to make sure all data consistent
	* 19.66 Create Exitdate_b_entrydate variable and set = 1 if EXIT_DATE_USE<ENTRYDATE (should be no instances); deal with any cases accordingly
	* 19.67 Create Exitdate_b_MLdate variable and set = 1 if EXIT_DATE_USE<CURRENTMLDATE
	* 19.68 Examine instances where Exitdate_b_MLdate=1 and deal with as deemed appropriate
	* 19.69 Drop variables no longer needed
	* 19.70 Recreate ML_STRING variable
	* 19.71 Where ENTRYDATE is missing, but CURRENTMLDATE is not and year(CURRENTMLDATE)=Year & first observation where EMP_TIME>1, set ENTRYDATE=CURRENTMLDATE and bring to relevant observations
	* 19.72 Where EMP_TIME=2, replace CURRENTMLDATE with missing if year(CURRENTMLDATE)<Year[_n-1] or year(CURRENTMLDATE)<year(ENTRYDATE) & first observation where EMP_TIME>1, and bring missing to relevant observations
	* 19.73 By PersonID EMP_TIME, create MAX and MIN for Entrydate_ORIG and MAX and MIN for CurrentMLDate_ORIG
	* 19.74 Create ENTRY_USE and ML_USE variables, and for the first observation where EMP_TIME>1, set = to MIN_ENTRY (MIN_ML) | MAX_ENTRY (MAX_ML) | Entrydate_ORIG (CurrentMLDate_ORIG) if year of that variable = Year 
	* 19.75 Replace ENTRYDATE and CURRENTMLDATE with ENTRY_USE if variable is missing and this is the first observation where EMP_TIME>1; replace with ML_USE if still missing after replacement with ENTRY_USE 
	* 19.76 Bring ENTRYDATE and CURRENTMLDATE from first observation where EMP_TIME>1, to all subsequent observations for the employee (with same MGMTLEVEL for CURRENTMLDATE)
	* 19.77 Where ENTRYDATE and CURRENTMLDATE are still missing and this is the first observation where EMP_TIME>1, assume ENTRYDATE / CURRENTMLDATE is (1,1,Year), and bring to all observations for the employee (with same  MGMTLEVEL for CURRENTMLDATE)
	* 19.78 Recreate f_Entrydate, f_CurrentMLDate, and f_MLDate_difflevel to make sure all data consistent
	* 19.79 Recreate other date validity testing variables and check no instances flagged
	* 19.80 Drop variables no longer needed
	* 19.81 Label variables
	* 19.82 Save output file
* Output file: "Processed_Data_2.dta"
**************************************************************************************************************************************************************************************************************************

	* 19.1 Read in processed data file 
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Processed Data.dta"

	* 19.2 Conduct a high level analysis of MLZ observations, and replace Z with 4 or 5 (whichever seems most reasonable) 
	* (only a small % of observations are MLZ, old manager level in specific countries only, thus company could not advise where sits in hierarchy of management levels)
	tab Year if MGMTLEVEL=="ML Z"

	tab COUNTRYWORK if MGMTLEVEL=="ML Z"
	* > Primarily used in [NAME OF COUNTRY REMOVED], [NAME OF COUNTRY REMOVED] and [NAME OF COUNTRY REMOVED]
	tab MGMTLEVEL Year if COUNTRYWORK=="Italy"
	* > In [NAME OF COUNTRY REMOVED], appears MLZs became level 4 or level 5
	tab MGMTLEVEL Year if COUNTRYWORK=="Austria"
	* > In [NAME OF COUNTRY REMOVED], appears MLZs became level 4
	tab MGMTLEVEL Year if COUNTRYWORK=="France"
	* > Not clear what happend in [NAME OF COUNTRY REMOVED]

	* Create NEW_ML and PRIOR_ML variables to capture the management level after / before an employee was MLZ
	sort PersonID Year
	by PersonID: gen NEW_ML=MGMTLEVEL if MGMTLEVEL!="ML Z" & MGMTLEVEL[_n-1]=="ML Z" & PersonID==PersonID[_n-1]
	by PersonID: gen PRIOR_ML=MGMTLEVEL if MGMTLEVEL!="ML Z" & MGMTLEVEL[_n+1]=="ML Z" & PersonID==PersonID[_n+1]

	tab NEW_ML
	tab PRIOR_ML

	gen D_NEW_ML=1 if NEW_ML!=""
	gen D_PRIOR_ML=1 if PRIOR_ML!=""

	sort PersonID
	by PersonID: egen S_NEW_ML=sum(D_NEW_ML)
	by PersonID: egen S_PRIOR_ML=sum(D_PRIOR_ML)

	list PersonID Year CURRENTMLDATE PRIOR_ML NEW_ML if (PRIOR_ML!="" | NEW_ML!="") & S_NEW_ML>=1 & S_PRIOR_ML>=1
	* > 8 employees have both PRIOR_ML and NEW_ML 
	* > 3 employees were management level 4 both before and after being MLZ
	* > 5 employees were management level 5 before being MLZ, and level 4 after being MLZ

	* Replace MLZ with management level 4 or 5 as appropriate
	sort PersonID Year
	by PersonID: replace MGMTLEVEL=MGMTLEVEL[_n+1] if MGMTLEVEL=="ML Z" & NEW_ML[_n+1]!="" & PersonID==PersonID[_n+1] & (NEW_ML[_n+1]=="ML 4" | NEW_ML[_n+1]=="ML 5")
	by PersonID: replace MGMTLEVEL=MGMTLEVEL[_n+2] if MGMTLEVEL=="ML Z" & NEW_ML[_n+2]!="" & PersonID==PersonID[_n+2] & (NEW_ML[_n+2]=="ML 4" | NEW_ML[_n+2]=="ML 5")
	by PersonID: replace MGMTLEVEL=MGMTLEVEL[_n+3] if MGMTLEVEL=="ML Z" & NEW_ML[_n+3]!="" & PersonID==PersonID[_n+3] & (NEW_ML[_n+3]=="ML 4" | NEW_ML[_n+3]=="ML 5")
	by PersonID: replace MGMTLEVEL=MGMTLEVEL[_n+4] if MGMTLEVEL=="ML Z" & NEW_ML[_n+4]!="" & PersonID==PersonID[_n+4] & (NEW_ML[_n+4]=="ML 4" | NEW_ML[_n+4]=="ML 5")
	by PersonID: replace MGMTLEVEL=MGMTLEVEL[_n-1] if MGMTLEVEL=="ML Z" & PRIOR_ML[_n-1]!="" & PersonID==PersonID[_n-1] & (PRIOR_ML[_n-1]=="ML 4" | PRIOR_ML[_n-1]=="ML 5")

	tab MGMTLEVEL

	* Where became management level 3 assume that was a promotion and replace management level Z with management level 4
	sort PersonID Year
	by PersonID: replace MGMTLEVEL="ML 4" if NEW_ML[_n+1]=="ML 3" & MGMTLEVEL=="ML Z" & PersonID==PersonID[_n+1]
	by PersonID: replace MGMTLEVEL="ML 4" if NEW_ML[_n+2]=="ML 3" & MGMTLEVEL=="ML Z" & PersonID==PersonID[_n+2]
	by PersonID: replace MGMTLEVEL="ML 4" if NEW_ML[_n+3]=="ML 3" & MGMTLEVEL=="ML Z" & PersonID==PersonID[_n+3]
	by PersonID: replace MGMTLEVEL="ML 4" if NEW_ML[_n+4]=="ML 3" & MGMTLEVEL=="ML Z" & PersonID==PersonID[_n+4]

	tab MGMTLEVEL

	count if MGMTLEVEL=="ML Z" & S_NEW_ML==0 & S_PRIOR_ML==0
	* Where no prior or subsequent observation, replace MLZ with management level 4 as it seems most MLZs became management level 4 employees when this management level disappeared
	replace MGMTLEVEL="ML 4" if MGMTLEVEL=="ML Z" & S_NEW_ML==0 & S_PRIOR_ML==0

	tab MGMTLEVEL
	* > No remaining MLZ instances

	* 19.3 Sort by PersonID Year, and create observation number variable within PersonID (first drop n variable); create EMP_N = max observations number within EMP_TIME
	drop n
	sort PersonID Year
	by PersonID: gen OBS=_n
	label variable OBS "Employee Observation Number (first sorted by Year)"
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: egen EMP_N=max(OBS) 
	label variable EMP_N "Maximum Employee Observation Number within EMP_TIME"

** Flag and deal with instances where timeinvariant employee characteristics differ between observations for an employee **

	* 19.4 Flag instances where, by PersonID, BIRTHYEAR!=BIRTHYEAR[_n-1] -- set f_BirthYear=1
	sort PersonID Year OBS
	by PersonID: gen f_BirthYear=1 if BIRTHYEAR!=BIRTHYEAR[_n-1]
	replace f_BirthYear=. if OBS==1
	tab f_BirthYear
	* > 21 instances flagged

	* 19.5 By PersonID, create M_BirthYear variable, = mode of BIRTHYEAR for the employee (where tied mode, use the minimum value)
	sort PersonID
	by PersonID: egen M_BirthYear=mode(BIRTHYEAR), minmode
	count if M_BirthYear==. & BIRTHYEAR!=.
	* 0 => GOOD
                                                                                
	* 19.6 Replace BIRTHYEAR with mode of BIRTHYEAR (M_BirthYear) if M_BirthYear is not missing and BIRTHYEAR does not equal M_BirthYear, tab BIRTHYEAR
	replace BIRTHYEAR=M_BirthYear if M_BirthYear!=. & BIRTHYEAR!=M_BirthYear
	tab BIRTHYEAR
	* Years are 1938-1993 (inclusive) -> all reasonable dates => GOOD

	* 19.7 Flag instances where, by PersonID, MALE!=MALE[_n-1] -- set f_Male=1
	sort PersonID Year OBS
	by PersonID: gen f_Male=1 if MALE!=MALE[_n-1]
	replace f_Male=. if OBS==1
	tab f_Male
	* > 21 instances flagged

	* 19.8 By PersonID, create M_Male variable, = mode of MALE for the employee (where tied mode, equal to missing)
	sort PersonID
	by PersonID: egen M_Male=mode(MALE)

	* 19.9 Count instances where MALE is not missing but M_Male is (means multiple modes for the employee) and list variables of interest for these employees)
	count if M_Male==. & MALE!=.
	list PersonID Year MALE if M_Male==. & MALE!=.

	* 19.10 Rename MALE Male_ORIG and recreate MALE=Male_ORIG
	rename MALE Male_ORIG
	gen MALE=Male_ORIG

	* 19.11 Replace MALE with mode of MALE (M_Male) if M_Male is not missing and MALE does not equal M_Male
	replace MALE=M_Male if  M_Male!=. & MALE!=M_Male

	* 19.12 Replace MALE with mode of MALE (M_Male) if M_Male is missing (i.e. where multiple modes, replace MALE with missing)
	replace MALE=M_Male if M_Male==. & MALE!=.

	* 19.13 Flag instances where, by PersonID EMP_TIME, ENTRYDATE!=ENTRYDATE[_n-1] -- set f_Entrydate=1
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: gen f_Entrydate=1 if ENTRYDATE!=ENTRYDATE[_n-1]
	replace f_Entrydate=. if OBS==1
	by PersonID: replace f_Entrydate=. if EMP_TIME[_n-1]!=EMP_TIME
	tab f_Entrydate

	* 19.14 By PersonID EMP_TIME, create INV_Entrydate variable = sum(f_Entrydate) -- if >=1, employee has at least one instance where Entrydate differs from one observation to the next
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: egen INV_Entrydate=sum(f_Entrydate)
	tab INV_Entrydate
	count if OBS==1 & INV_Entrydate>=1

	* 19.15 By PersonID EMP_TIME, create Min_Entrydate variable, = minimum of ENTRYDATE for the employee
	sort PersonID EMP_TIME
	by PersonID EMP_TIME: egen Min_Entrydate=min(ENTRYDATE)
	* > Per [NAME OF COMPANY CONTACT REMOVED]: Changes in entrydate could possibly have arisen when an employee moves from one country to another; use the oldest date. 

	* 19.16 Replace ENTRYDATE with min of ENTRYDATE (Min_Entrydate) if Min_Entrydate is not missing and ENTRYDATE does not equal Min_Entrydate
	replace ENTRYDATE=Min_Entrydate if Min_Entrydate!=. & ENTRYDATE!=Min_Entrydate
	format ENTRYDATE %tdnn/dd/CCYY

	* 19.17 Rename CURRENTMLDATE CurrentMLDate_ORIG and recreate CURRENTMLDATE=CurrentMLDate_ORIG
	rename CURRENTMLDATE CurrentMLDate_ORIG
	gen CURRENTMLDATE=CurrentMLDate_ORIG

	* 19.18 Create ML_STRING variable = the observation number for the employee within a string of observations (sorted by Year) with the same EMP_TIME value at the same MGMTLEVEL 
	sort PersonID EMP_TIME Year OBS
	gen ML_STRING=1 if OBS==1
	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1)) 

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	count if ML_STRING==.
	tab ML_STRING
	* > No instances of ML_STRING==.

	* 19.19 By PersonID and ML_STRING, create Min_CurrentMLDate variable, = minimum of CURRENTMLDATE for the employee by ML_STRING
	sort PersonID ML_STRING Year
	by PersonID ML_STRING: egen Min_CurrentMLDate=min(CURRENTMLDATE)
	format Min_CurrentMLDate %tdnn/dd/CCYY
	* > Per [NAME OF COMPANY CONTACT REMOVED]: Changes in entrydate could possibly have arisen when an employee moves from one country to another; use the oldest date. Again, date for same management level, use the earliest date. [Date] can change when an employee transfers to a new legal entity, etc.

	* 19.20 Where CURRENTMLDATE is missing, but there is a value for Min_CurrentMLDate, replace CURRENTMLDATE with Min_CurrentMLDate
	replace CURRENTMLDATE=Min_CurrentMLDate if CURRENTMLDATE==. & Min_CurrentMLDate!=.

	* 19.21 Flag instances where, by PersonID EMP_TIME, CURRENTMLDATE!=CURRENTMLDATE[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] -- set f_CurrentMLDate=1
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: gen f_CurrentMLDate=1 if CURRENTMLDATE!=CURRENTMLDATE[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] 
	replace f_CurrentMLDate=. if OBS==1
	tab f_CurrentMLDate

	* 19.22 By PersonID EMP_TIME, create INV_CurrentMLDate variable = sum(f_CurrentMLDate) -- if >=1, employee has at least one instance where CURRENTMLDATE differs from one observation to the next and MGMTLEVEL is the same
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: egen INV_CurrentMLDate=sum(f_CurrentMLDate)
	tab INV_CurrentMLDate
	count if OBS==1 & INV_CurrentMLDate>=1

	* 19.23 By PersonID and ML_STRING, create Min2_CurrentMLDate variable = next minimum of CURRENTMLDATE for the employee by ML_STRING (= Min_CurrentMLDate if no other ML date within the STRING)
	gen EXCL=0
	replace EXCL=1 if Min_CurrentMLDate==CURRENTMLDATE
	sort PersonID ML_STRING EXCL Year
	by PersonID ML_STRING EXCL: egen Min2=min(CURRENTMLDATE)
	sort PersonID ML_STRING Year
	by PersonID ML_STRING : egen Min2_CurrentMLDate=max(Min2)
	format Min2_CurrentMLDate %tdnn/dd/CCYY

	* 19.24 Replace CURRENTMLDATE with min of CURRENTMLDATE (Min_CurrentMLDate) if Min_CurrentMLDate is not missing and CURRENTMLDATE does not equal Min_CurrentMLDate
	replace CURRENTMLDATE=Min_CurrentMLDate if Min_CurrentMLDate!=. & CURRENTMLDATE!=Min_CurrentMLDate 
	format CURRENTMLDATE %tdnn/dd/CCYY

	* 19.25 Replace MGMTLEVEL with MGMTLEVEL from prior observation if appears promoted on the 1st day of the year next year and new management level was recorded against this year's observation; and replace CURRENTMLDATE with date from prior observation 
	sort PersonID Year OBS
	by PersonID: gen C_MGMTLEVEL=1 if MGMTLEVEL==MGMTLEVEL[_n+1] & CURRENTMLDATE==mdy(1,1,Year+1) & OBS!=1 & PersonID==PersonID[_n-1] & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n-1] & EMP_TIME==EMP_TIME[_n+1]
	by PersonID: replace MGMTLEVEL=MGMTLEVEL[_n-1] if MGMTLEVEL==MGMTLEVEL[_n+1] & CURRENTMLDATE==mdy(1,1,Year+1) & OBS!=1 & PersonID==PersonID[_n-1] & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n-1] & EMP_TIME==EMP_TIME[_n+1]
	sort PersonID Year OBS
	by PersonID: replace CURRENTMLDATE=CURRENTMLDATE[_n-1] if MGMTLEVEL==MGMTLEVEL[_n-1] & MGMTLEVEL!=MGMTLEVEL[_n+1] & C_MGMTLEVEL==1 & OBS!=1 & PersonID==PersonID[_n-1] & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n-1] & EMP_TIME==EMP_TIME[_n+1]
	drop C_MGMTLEVEL

	* 19.26 Replace MGMTLEVEL with missing if appears new management level in the subsequent year (since an original ML date is in YEAR+1) but new management level is reflected in this year's observation, and this is the first observation for  the employee; replace CURRENTMLDATE with missing
	* First, if an original mgmtdate is 1/1/Year+1
	sort PersonID EMP_TIME Year OBS
	by PersonID: gen FLAG_MGMTLEVELC=1 if ((year(CURRENTMLDATE)==Year+1 & month(CURRENTMLDATE)==1 & day(CURRENTMLDATE)==1)) & OBS==1 & MGMTLEVEL==MGMTLEVEL[_n+1] & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1]
	by PersonID: replace MGMTLEVEL="" if ((year(CURRENTMLDATE)==Year+1 & month(CURRENTMLDATE)==1 & day(CURRENTMLDATE)==1)) & OBS==1 & MGMTLEVEL==MGMTLEVEL[_n+1] & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1] 
	replace CURRENTMLDATE=. if FLAG_MGMTLEVELC==1
	drop FLAG_MGMTLEVELC
	* Second, if an original mgmtdate is any date in Year+1
	sort PersonID EMP_TIME Year OBS
	by PersonID: gen FLAG_MGMTLEVELC=1 if year(CURRENTMLDATE)==Year+1 & OBS==1 & MGMTLEVEL==MGMTLEVEL[_n+1] & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1]
	by PersonID: replace MGMTLEVEL="" if year(CURRENTMLDATE)==Year+1 & OBS==1 & MGMTLEVEL==MGMTLEVEL[_n+1] & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1]
	replace CURRENTMLDATE=. if FLAG_MGMTLEVELC==1
	drop FLAG_MGMTLEVELC
	
	* 19.27 Replace CURRENTMLDATE with missing if appears new management level in the subsequent year (since an original ml date is in Year+1) but new management level date is recorded against this year, and this is the first observation for  the employee; leave MGMTLEVEL as is
	* First, if an original mgmtdate is 1/1/Year+1
	sort PersonID EMP_TIME Year OBS
	by PersonID: gen FLAG_MGMTLEVELC=1 if ((year(CURRENTMLDATE)==Year+1 & month(CURRENTMLDATE)==1 & day(CURRENTMLDATE)==1)) & OBS==1 & MGMTLEVEL!=MGMTLEVEL[_n+1] & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1]
	replace CURRENTMLDATE=. if FLAG_MGMTLEVELC==1
	drop FLAG_MGMTLEVELC
	* Second, if an original mgmtdate is any date in Year+1
	sort PersonID EMP_TIME Year OBS
	by PersonID: gen FLAG_MGMTLEVELC=1 if year(CURRENTMLDATE)==Year+1 & OBS==1 & MGMTLEVEL!=MGMTLEVEL[_n+1] & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1]
	replace CURRENTMLDATE=. if FLAG_MGMTLEVELC==1
	drop FLAG_MGMTLEVELC

	* 19.28 Given changes made above, recreate MGMTLEVEL string variable
	drop ML_STRING

	sort PersonID EMP_TIME Year OBS
	gen ML_STRING=1 if OBS==1
	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1)) 

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	count if ML_STRING==.
	tab ML_STRING
	* > No instances of ML_STRING==.

	* 19.29 Count instances where year(CURRENTMLDATE)>Year, and replace these instances with missing (since cannot be promoted to the current management level after this year!); flag these occurences, and bring missing to all observations
	count if year(CURRENTMLDATE)>Year & CURRENTMLDATE!=.
	gen IMPLAUS_MLDATE=1 if year(CURRENTMLDATE)>Year & CURRENTMLDATE!=.
	sort PersonID ML_STRING
	by PersonID ML_STRING: egen SUM_IMPLAUS_MLDATE=min(IMPLAUS_MLDATE) 
	tab SUM_IMPLAUS_MLDATE
	replace CURRENTMLDATE=. if SUM_IMPLAUS_MLDATE==1
	drop IMPLAUS_MLDATE SUM_IMPLAUS_MLDATE  

	* 19.30 Replace MGMTLEVEL with MGMTLEVEL from prior observation if appears promoted in the subsequent year and new management level is reflected in this year's observation; update CURRENTMLDATE accordingly 
	sort PersonID EMP_TIME Year OBS
	by PersonID: gen C_MGMTLEVEL=1 if year(CurrentMLDate_ORIG)==Year+1 & CURRENTMLDATE==. & EMP_TIME==EMP_TIME[_n-1] & EMP_TIME==EMP_TIME[_n+1] & OBS!=1 & MGMTLEVEL==MGMTLEVEL[_n+1] 
	by PersonID: replace MGMTLEVEL=MGMTLEVEL[_n-1] if year(CurrentMLDate_ORIG)==Year+1 & CURRENTMLDATE==. & EMP_TIME==EMP_TIME[_n-1] & EMP_TIME==EMP_TIME[_n+1] & OBS!=1 & MGMTLEVEL==MGMTLEVEL[_n+1]
	by PersonID: replace CURRENTMLDATE = CURRENTMLDATE[_n-1] if year(CurrentMLDate_ORIG)==Year+1 & CURRENTMLDATE==. & MGMTLEVEL==MGMTLEVEL[_n-1]  & EMP_TIME==EMP_TIME[_n-1] & OBS!=1 & C_MGMTLEVEL==1
	drop C_MGMTLEVEL

	* 19.31 For observations where the employee has a new management level this year and CURRENTMLDATE is missing, fill with Min_CurrentMLDate if year(Min_CurrentMLDate)=Year; otherwise assume the employee was promoted/demoted on  the first day of the current year
	sort PersonID Year OBS
	by PersonID: replace CURRENTMLDATE=Min_CurrentMLDate if CURRENTMLDATE==. & year(Min_CurrentMLDate)==Year & MGMTLEVEL!=MGMTLEVEL[_n-1] & OBS!=1 & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace CURRENTMLDATE=mdy(1,1,Year) if CURRENTMLDATE==. & MGMTLEVEL!=MGMTLEVEL[_n-1] & OBS!=1 & EMP_TIME==EMP_TIME[_n-1]

	* 19.32 Update CURRENTMLDATE for subsequent observations -- within same EMP_TIME only
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: replace CURRENTMLDATE=CURRENTMLDATE[_n-1] if CURRENTMLDATE!=CURRENTMLDATE[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] & CURRENTMLDATE[_n-1]!=. & EMP_TIME==EMP_TIME[_n-1] & OBS!=1

	* 19.33 Replace CURRENTMLDATE with ENTRYDATE if first observation for an employee & year(ENTRYDATE)==Year, and bring to all observations for employee (within MGMTLEVEL)
	replace CURRENTMLDATE=ENTRYDATE if OBS==1 & year(ENTRYDATE)==Year & CURRENTMLDATE==.
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: replace CURRENTMLDATE=CURRENTMLDATE[_n-1] if MGMTLEVEL==MGMTLEVEL[_n-1] & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]

	* 19.34 Replace CURRENTMLDATE with (1,1,Year) if first observation for an employee, Year>=2010, year(ENTRYDATE)<Year, and CURRENTMLDATE is missing, and bring to all observations for employee (within MGMTLEVEL) 
	* > Assuming that it would be very unlikely for an existing manager to be on leave for both 2008 and 2009 (hence set the Year>=2010 requirement) 
	replace CURRENTMLDATE=mdy(1,1,Year) if OBS==1 & CURRENTMLDATE==. & Year>=2010 & year(ENTRYDATE)<Year
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: replace CURRENTMLDATE=CURRENTMLDATE[_n-1] if MGMTLEVEL==MGMTLEVEL[_n-1] & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]

	* 19.35 Flag instances where, by PersonID, CURRENTMLDATE==CURRENTMLDATE[_n-1] BUT MGMTLEVEL!=MGMTLEVEL[_n-1] -- set f_MLDate_difflevel=1 (i.e. same management level start date is given for two different management levels)
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_difflevel=1 if CURRENTMLDATE==CURRENTMLDATE[_n-1] & MGMTLEVEL!=MGMTLEVEL[_n-1] & CURRENTMLDATE!=.
	replace f_MLDate_difflevel=. if OBS==1 
	tab f_MLDate_difflevel
	
	* 19.36 By PersonID and ML_STRING, create INV_MLDate_difflevel variable = sum(f_MLDate_difflevel) -- if >=1, the CURRENTMLDATE for the string of observations at this MGMTLEVEL = the CURRENTMLDATE for the observations at the previous MGMTLEVEL 
	* > First, recreate ML_STRING
	drop ML_STRING
	sort PersonID EMP_TIME Year OBS
	gen ML_STRING=1 if OBS==1
	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1)) 

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	count if ML_STRING==.
	tab ML_STRING

	sort PersonID ML_STRING Year
	by PersonID ML_STRING: egen INV_MLDate_difflevel=sum(f_MLDate_difflevel)

	* 19.37 If INV_MLDate_difflevel>=1 replace CURRENTMLDATE with second-to-minimum value of CURRENTMLDATE (prior to any replacements of CURRENTMLDATE) for this string of observations  (note: second-to-minimum may = minimum), but then replace CURRENTMLDATE with missing if year(CURRENTMLDATE)>Year 
	replace CURRENTMLDATE=Min2_CurrentMLDate if INV_MLDate_difflevel>=1
	replace CURRENTMLDATE=. if year(CURRENTMLDATE)>Year & CURRENTMLDATE!=.

	* 19.38 Recreate f_MLDate_difflevel given step above should have reduced the number of instances flagged
	drop f_MLDate_difflevel
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_difflevel=1 if CURRENTMLDATE==CURRENTMLDATE[_n-1] & MGMTLEVEL!=MGMTLEVEL[_n-1] & CURRENTMLDATE!=.
	replace f_MLDate_difflevel=. if OBS==1 
	tab f_MLDate_difflevel

	* 19.39 By PersonID and ML_STRING, create INV_MLDate_difflevel variable = sum(f_MLDate_difflevel) -- if >=1, the CURRENTMLDATE for the string of observations at this MGMTLEVEL = the CURRENTMLDATE for the observations at  the previous MGMTLEVEL 
	drop INV_MLDate_difflevel
	sort PersonID ML_STRING Year
	by PersonID: egen INV_MLDate_difflevel=sum(f_MLDate_difflevel)

	* 19.40 Investigate the handful of instances flagged above, and deal with as seems most reasonable on a case-by-case basis
	list PersonID Year MGMTLEVEL MgmtLevel_ORIG CURRENTMLDATE CurrentMLDate_ORIG if INV_MLDate_difflevel>=1
	* > 6316: CurrentMLDate_ORIG = 1oct2006 for all years (2008-2015), though management level 5 in 2008 and management level 4 in 2009-2015 => seems most likely was management level 4 in 2008, so replace MGMTLEVEL accordingly
	replace MGMTLEVEL="ML 4" if PersonID=="6316" & Year==2008
	* > 10978: CurrentMLDate_ORIG = 1jan2008 for all years (2008-2015), though management level 5 in 2008 and management level 3 in 2009-2015 => seems most likely management level 3 in 2008 as unlikely to be promoted two levels in a year, replace
	replace MGMTLEVEL="ML 3" if PersonID=="10978" & Year==2008
	* > 15272: CurrentMLDate_ORIG = 1may2002 for both 2009 and 2010, though management level 4 in 2008 & 2009 and manaement level 3 in 2010 => CurrentMLDate_ORIG against 2008 observation is 01jan2011, so perhaps recorded at new level at end of 2010 though promoted at start of 2011 - change 2010 management level
	replace MGMTLEVEL="ML 4" if PersonID=="15272" & Year==2010
	* > 38594: CurrentMLDate_ORIG = 01feb2010 for 2008 (not possible!) and 01jan2008 for 2009 and 2010; management level 4 in 2008 and 2009 and management level 3 in 2010 => seems management level date recorded against 2008 observations may be 2010 promotion date => replace CURRENTMLDATE in 2010 (2008 CURRENTMLDATE already changed to 1/1/2008)
	replace CURRENTMLDATE=date("02-01-2010", "MDY") if PersonID=="38594" & Year==2010
	* > 40431: CurrentMLDate_ORIG = 01nov2008 for all years (2008-2011), though management level 4 in 2008 and management level 3 in 2009-2011 => seems likely that promoted to management level 3 on 01nov2008, but management level 4 still listed as MGMTLEVEL at year end => change MGMTLEVEL for 2008
	replace MGMTLEVEL="ML 3" if PersonID=="40431" & Year==2008
	* > 45091: CurrentMLDate_ORIG = 01oct2008 for all years (2008-2015), though management level 5 in 2008 and management level 4 in 2009-2015 => seems likely that promoted to management level 4 on 01oct2008, but management level 5 still listed as MGMTLEVEL at year end => change MGMTLEVEL for 2008
	replace MGMTLEVEL="ML 4" if PersonID=="45091" & Year==2008
	* > 48977: CURRENTMLDATE is 4/1/2009 for 2009 and 2010, but management level 5 in 2009 and management level 4 in 2010. Was management level 5 in 2008 but had put MGMTLEVEL="" as original date was 01aug2012. Change 2009 MGMTLEVEL to management level 4, and MGMTLEVEL 2008 back to management level 5, but leave CURRENTMLDATE for 2008 as missing
	replace MGMTLEVEL="ML 5" if PersonID=="48977" & Year==2008 
	replace MGMTLEVEL="ML 4" if PersonID=="48977" & Year==2009
	* > 57897: CurrentMLDate_ORIG = 01nov2008 for both 2008 & 2009 (no observations in later years), though management level 5 in 2008 and management level 4 in 2009 => seems likely that promoted to management level 4 on 01nov2008, but management level 5 still listed as MGMTLEVEL at year end => change MGMTLEVEL for 2008
	replace MGMTLEVEL="ML 4" if PersonID=="57897" & Year==2008
	* > 20167503: CurrentMLDate_ORIG = 01apr2008 for both 2008 & 2009 (no observations in later years), though management level 4 in 2008 and management level 3 in 2009 
	* >> Not sure what is correct for this employee (not sure how likely to be promoted to a new level after one year at previous level - seems very unlikely), so assume MgmtLevel is management level 3 in 2008
	replace MGMTLEVEL="ML 3" if PersonID=="20167503" & Year==2008

	* 19.41 Recreate f_MLDate_difflevel given step above should have reduced the number of instances flagged
	drop f_MLDate_difflevel
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_difflevel=1 if CURRENTMLDATE==CURRENTMLDATE[_n-1] & MGMTLEVEL!=MGMTLEVEL[_n-1] & CURRENTMLDATE!=.
	replace f_MLDate_difflevel=. if OBS==1 
	tab f_MLDate_difflevel
	* > No instances flagged

	* 19.42 Flag instances where, by PersonID (sorted by Year), year(CURRENTMLDATE)<Year[_n-1]+1 but a different MGMTLEVEL compared to MGMTLEVEL[_n-1] -- set f_MLDate_early=1, create EARLY by PersonID 
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_early=1 if year(CURRENTMLDATE)<Year[_n-1]+1 & MGMTLEVEL!=MGMTLEVEL[_n-1] & OBS!=1 & PersonID==PersonID[_n-1]
	tab f_MLDate_early
	sort PersonID
	by PersonID: egen EARLY=sum(f_MLDate_early)

	* 19.43 Count number of instances where the CURRENTMLDATE is within the year where an employee changed to a new management level, and where it is not to ensure accurate in majority of instances
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_correct=1 if year(CURRENTMLDATE)==Year & MGMTLEVEL!=MGMTLEVEL[_n-1] & OBS!=1 & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: gen f_MLDate_incorrect=1 if year(CURRENTMLDATE)!=Year & MGMTLEVEL!=MGMTLEVEL[_n-1] & OBS!=1 & EMP_TIME==EMP_TIME[_n-1]
	tab f_MLDate_correct
	tab f_MLDate_incorrect
	* > Accurate in the vast majority of cases

	sort PersonID Year OBS
	by PersonID: gen f_MLDate_correctORIG=1 if year(CurrentMLDate_ORIG)==Year & MGMTLEVEL!=MGMTLEVEL[_n-1] & OBS!=1 & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: gen f_MLDate_incorrectORIG=1 if year(CurrentMLDate_ORIG)!=Year & MGMTLEVEL!=MGMTLEVEL[_n-1] & OBS!=1 & EMP_TIME==EMP_TIME[_n-1]
	tab f_MLDate_correctORIG
	tab f_MLDate_incorrectORIG
	* > Again, largely accurate

	* 19.44 Create Mode_MLDate variable within PersonID and ML_STRING; also create Max_MLDate
	sort PersonID ML_STRING Year
	by PersonID ML_STRING: egen Mode_MLDate=mode(CurrentMLDate_ORIG)
	format Mode_MLDate %td
	sort PersonID ML_STRING Year
	by PersonID ML_STRING: egen Max_MLDate=max(CurrentMLDate_ORIG)
	format Max_MLDate %td

	* 19.45 Replace CURRENTMLDATE if currently year(CURRENTMLDATE) is prior to this year, and this is the first year at a new MGMTLEVEL; replace first with Mode_MLDate if year(Mode_MLDate)==Year, then Max_MLDate if year(Max_MLDate)==Year, then (1,1,Year) for any  remaining instances, then flow down to subsequent observations at the same MGMTLEVEL
	sort PersonID Year OBS
	by PersonID: replace CURRENTMLDATE=Mode_MLDate if year(CURRENTMLDATE)<Year[_n-1]+1 & MGMTLEVEL!=MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1] & year(Mode_MLDate)>=Year[_n-1]+1 & year(Mode_MLDate)<=Year & OBS!=1
	by PersonID: replace CURRENTMLDATE=Mode_MLDate if year(CURRENTMLDATE)<Year[_n-1]+1 & MGMTLEVEL!=MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1] & year(Mode_MLDate)==Year+1 & month(Mode_MLDate)==1 
	by PersonID: replace CURRENTMLDATE=Max_MLDate if year(CURRENTMLDATE)<Year[_n-1]+1 & MGMTLEVEL!=MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1] & year(Max_MLDate)>=Year[_n-1]+1 & year(Max_MLDate)<=Year & OBS!=1
	by PersonID: replace CURRENTMLDATE=mdy(1,1,Year) if year(CURRENTMLDATE)<Year[_n-1]+1 & MGMTLEVEL!=MGMTLEVEL[_n-1] & Year==Year[_n-1]+1 & EMP_TIME==EMP_TIME[_n-1] & OBS!=1
	by PersonID: replace CURRENTMLDATE=mdy(1,1,Year) if year(CURRENTMLDATE)<Year[_n-1]+1 & MGMTLEVEL!=MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1] & OBS!=1
	by PersonID: replace CURRENTMLDATE=CURRENTMLDATE[_n-1] if CURRENTMLDATE!=CURRENTMLDATE[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1] & OBS!=1 & EARLY>=1

	* 19.46 Flag instances where, by PersonID (sorted by Year), CURRENTMLDATE<Year[_n-1]+1 but a different MGMTLEVEL compared to MGMTLEVEL[_n-1] -- set f_MLDate_early=1, create EARLY by PersonID 
	drop f_MLDate_early EARLY
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_early=1 if year(CURRENTMLDATE)<Year[_n-1]+1 & MGMTLEVEL!=MGMTLEVEL[_n-1] & OBS!=1
	tab f_MLDate_early
	* > No instances

	* 19.47 Flag instances where Year<Year(CURRENTMLDATE), display all observations for these employees, and deal with accordingly
	gen f_MLDate_late=1 if Year<year(CURRENTMLDATE) & CURRENTMLDATE!=.
	tab f_MLDate_late
	* > 1 instance only
	sort PersonID EMP_TIME
	by PersonID EMP_TIME: egen LATE=sum(f_MLDate_late)
	list PersonID Year MGMTLEVEL MgmtLevel_ORIG CURRENTMLDATE CurrentMLDate_ORIG if LATE>=1
	* > 45028: Management level 4 from 2010 onwards but CURRENTMLDATE is 01jan2011; seems MGMTLEVEL udpated at end of 2010 but not promoted until start of 2011; change MGMTLEVEL for 2010 to management level 5 (like 2009) and update date
	replace MGMTLEVEL="ML 5" if PersonID=="45028" & Year==2010
	replace CURRENTMLDATE=date("07-01-2009", "MDY") if PersonID=="45028" & Year==2010

	* 19.48 Recreate f_MLDate_difflevel & f_CurrentMLDate to check if any instances flagged
	drop f_MLDate_difflevel
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_difflevel=1 if CURRENTMLDATE==CURRENTMLDATE[_n-1] & MGMTLEVEL!=MGMTLEVEL[_n-1] & CURRENTMLDATE!=.
	replace f_MLDate_difflevel=. if OBS==1 
	tab f_MLDate_difflevel
	* > No instances flagged
	drop f_CurrentMLDate
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: gen f_CurrentMLDate=1 if CURRENTMLDATE!=CURRENTMLDATE[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] 
	replace f_CurrentMLDate=. if OBS==1
	by PersonID: replace f_CurrentMLDate=. if EMP_TIME[_n-1]!=EMP_TIME & OBS!=1
	tab f_CurrentMLDate
	* > 5 instances flagged

	* 19.49 By PersonID EMP_TIME, create INV_CurrentMLDate variable = sum(f_CurrentMLDate) -- if >=1, employee has at least one instance where CURRENTMLDATE differs from one observation to the next and MGMTLEVEL is the same
	drop INV_CurrentMLDate
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: egen INV_CurrentMLDate=sum(f_CurrentMLDate)
	tab INV_CurrentMLDate
	
	* 19.50 Display all observations and relevant variables for employees where INV_CurrentMLDate>=1, and deal with on a case-by-case basis as seems appropriate
	list PersonID Year MGMTLEVEL MgmtLevel_ORIG CURRENTMLDATE CurrentMLDate_ORIG if INV_CurrentMLDate>=1
	* > 55614: Management level 3 from 2012 onwards, but CURRENTMLDATE for that level is 4/1/2013 => assume still management level 4 in 2012 but recorded as management level 3 => change level and date for 2012
	replace MGMTLEVEL="ML 4" if PersonID=="55614" & Year==2012
	replace CURRENTMLDATE=date("10-01-2008", "MDY") if PersonID=="55614" & Year==2012
	* > 70547: Management level 3 from 2012 onwards, but CURRENTMLDATE for that level is 1/1/2013 => assume still management level 4 in 2012 but recorded as management level 3 => change level and date for 2012
	replace MGMTLEVEL="ML 4" if PersonID=="70547" & Year==2012
	replace CURRENTMLDATE=date("08-01-2010", "MDY") if PersonID=="70547" & Year==2012
	 * > 20230820: Management level 4 from 2012 onwards, but CURRENTMLDATE for that level is 4/1/2013 => assume still management level 3 in 2012 (must have been demoted) but recorded as management level 4 => change level and date for 2012
	replace MGMTLEVEL="ML 3" if PersonID=="20230820" & Year==2012
	replace CURRENTMLDATE=date("08-01-2009", "MDY") if PersonID=="20230820" & Year==2012
	* > 20237234: Management level 4 from 2012 onwards, but CURRENTMLDATE for that level is 1/1/2013 => assume still management level 5 in 2012 but recorded as management level 4 => change level and date for 2012
	replace MGMTLEVEL="ML 5" if PersonID=="20237234" & Year==2012
	replace CURRENTMLDATE=date("03-29-2010", "MDY") if PersonID=="20237234" & Year==2012
	* > 20238475: Management level 4 from 2012 onwards, but CURRENTMLDATE for that level is 4/1/2013 => assume still management level 5 in 2012 but recorded as management level 4 => change level and date for 2012
	replace MGMTLEVEL="ML 5" if PersonID=="20238475" & Year==2012
	replace CURRENTMLDATE=date("05-17-2010", "MDY") if PersonID=="20238475" & Year==2012

	* 19.51 Recreate f_MLDate_difflevel & f_CurrentMLDate to make sure no instances 
	drop f_MLDate_difflevel
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_difflevel=1 if CURRENTMLDATE==CURRENTMLDATE[_n-1] & MGMTLEVEL!=MGMTLEVEL[_n-1] & CURRENTMLDATE!=.
	replace f_MLDate_difflevel=. if OBS==1 
	tab f_MLDate_difflevel
	* > No instances flagged => GOOD
	drop f_CurrentMLDate
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: gen f_CurrentMLDate=1 if CURRENTMLDATE!=CURRENTMLDATE[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] 
	replace f_CurrentMLDate=. if OBS==1
	by PersonID: replace f_CurrentMLDate=. if EMP_TIME[_n-1]!=EMP_TIME & OBS!=1
	tab f_CurrentMLDate
	* > No instances flagged => GOOD

	* 19.52 Create MLdate_b_entrydate variable and set = 1 if ENTRYDATE>CURRENTMLDATE 
	gen MLdate_b_entrydate=1 if ENTRYDATE>CURRENTMLDATE & ENTRYDATE!=.
	tab MLdate_b_entrydate 

	* 19.53 Generate SAMEYM variable, = 1 if the year and month of CURRENTMLDATE = the year and month of ENTRYDATE (i.e. only the specific day differs) and MLdate_b_entrydate=1, and for these cases, replace CURRENTMLDATE  with ENTRYDATE
	gen SAMEYEAR=1 if year(ENTRYDATE)==year(CURRENTMLDATE) & MLdate_b_entrydate==1
	gen SAMEMONTH=1 if month(ENTRYDATE)==month(CURRENTMLDATE) & MLdate_b_entrydate==1
	gen SAMEYM=1 if SAMEYEAR==1 & SAMEMONTH==1
	replace CURRENTMLDATE=ENTRYDATE if SAMEYM==1 & MLdate_b_entrydate==1
	
	* 19.54 Recreate MLdate_b_entrydate variable given step above should have reduced number of instances flagged; first create new variable FLAG and set = MLdate_b_entrydate
	gen FLAG=MLdate_b_entrydate
	drop MLdate_b_entrydate
	gen MLdate_b_entrydate=1 if ENTRYDATE>CURRENTMLDATE & ENTRYDATE!=.
	tab MLdate_b_entrydate 

	* 19.55 Replace CURRENTMLDATE with ENTRYDATE if the CURRENTMLDATE and ENTRYDATE share the same year, and MLdate_b_entrydate==1
	replace CURRENTMLDATE=ENTRYDATE if SAMEYEAR==1 & MLdate_b_entrydate==1 

	* 19.56 Where ENTRYDATE>CURRENTMLDATE, replace ENTRYDATE with missing (since ENTRYDATE must be <= CURRENTMLDATE) since current ENTRYDATE is invalid; bring to all observations for the employee
	replace ENTRYDATE=. if ENTRYDATE>CURRENTMLDATE & MLdate_b_entrydate==1 & ENTRYDATE!=.
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: replace ENTRYDATE=. if ENTRYDATE[_n-1]==. & EMP_TIME==EMP_TIME[_n-1] & OBS!=1

	* 19.57 Recreate MLdate_b_entrydate variable given step above should have resolved flagged instances 
	drop MLdate_b_entrydate
	gen MLdate_b_entrydate=1 if ENTRYDATE>CURRENTMLDATE & ENTRYDATE!=.
	tab MLdate_b_entrydate
	* > No instances => GOOD
	
	* 19.58 Set MLdate_b_entrydate to 1 if FLAG!=1 (not previously flagged) & ENTRYDATE>CurrentMLDate_ORIG (may not have used the earliest ORIG date for the CURRENTMLDATE, but the entry date should not occur after the earliest CurrentMLDate on record)
	drop MLdate_b_entrydate
	gen MLdate_b_entrydate=1 if ENTRYDATE>CurrentMLDate_ORIG & ENTRYDATE!=. & FLAG!=1
	replace MLdate_b_entrydate=0 if MLdate_b_entrydate==.
	tab MLdate_b_entrydate 

	* 19.59 Display relevant variables for all observations for the employees flagged above and deal with on a case-by-case basis as seems appropriate
	sort PersonID
	by PersonID: egen EXAMINE=sum(MLdate_b_entrydate)
	list PersonID Year ENTRYDATE Entrydate_ORIG MGMTLEVEL MgmtLevel_ORIG CURRENTMLDATE CurrentMLDate_ORIG EMP_TIME if EXAMINE>=1
	* > PersonID 2113, earliest CurrentMLDate_ORIG is 01apr2006, but earliest Entrydate_ORIG is 01feb2007 - suggests entrydate is incorrect, replace ENTRYDATE with missing
	replace ENTRYDATE=. if PersonID=="2113"
	* > PersonID 8038, earliest CurrentMLDate_ORIG is 24nov2000, but earliest Entrydate_ORIG is 14jun2004 - suggests entrydate is incorrect, replace ENTRYDATE with missing
	replace ENTRYDATE=. if PersonID=="8038"
	* > PersonID 45047, for EMP_TIME=2, earliest CurrentMLDate_ORIG is 04may1998, but ENTRYDATE=21feb2011, old CurrentMLDate_ORIG must have been in employee record from first string of employment with company - no action needed

	* 19.60 Recreate MLdate_b_entrydate variable (two conditions) and ensure any flagged instances OK
	drop MLdate_b_entrydate
	gen MLdate_b_entrydate=1 if ENTRYDATE>CURRENTMLDATE & ENTRYDATE!=.
	replace MLdate_b_entrydate=1 if ENTRYDATE>CurrentMLDate_ORIG & ENTRYDATE!=. & FLAG!=1
	tab MLdate_b_entrydate
	* > 1 instance
	tab PersonID if MLdate_b_entrydate==1
	* > PersonID 45047 ==> OK

	* 19.61 Recreate f_Entrydate, f_CurrentMLDate, and f_MLDate_difflevel to make sure all data consistent
	drop f_Entrydate
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: gen f_Entrydate=1 if ENTRYDATE!=ENTRYDATE[_n-1]
	replace f_Entrydate=. if OBS==1
	replace f_Entrydate=. if EMP_TIME[_n-1]!=EMP_TIME
	tab f_Entrydate
	* > No instances flagged
	drop f_MLDate_difflevel
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_difflevel=1 if CURRENTMLDATE==CURRENTMLDATE[_n-1] & MGMTLEVEL!=MGMTLEVEL[_n-1] & CURRENTMLDATE!=.
	replace f_MLDate_difflevel=. if OBS==1 
	tab f_MLDate_difflevel
	* > No instances flagged
	drop f_CurrentMLDate
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: gen f_CurrentMLDate=1 if CURRENTMLDATE!=CURRENTMLDATE[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] 
	replace f_CurrentMLDate=. if OBS==1
	by PersonID: replace f_CurrentMLDate=. if EMP_TIME[_n-1]!=EMP_TIME & OBS!=1
	tab f_CurrentMLDate
	* > No instances flagged

	* 19.62 Create flag_ML variable and set =1 where CURRENTMLDATE is missing & MGMTLEVEL differs to prior MGMTLEVEL and EMP_TIME is the same
	sort PersonID Year OBS
	by PersonID: gen flag_ML=1 if CURRENTMLDATE==. & MGMTLEVEL!=MGMTLEVEL[_n-1] & OBS!=1 & MGMTLEVEL!="" & EMP_TIME==EMP_TIME[_n-1]

	* 19.63 By PersonID EMP_TIME, create INV_flag_ML variable = sum(flag_ML) 
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: egen INV_flag_ML=sum(flag_ML)
	tab INV_flag_ML

	* 19.64 Display all observations and relevant variables for employees where INV_flag_ML>=1, and deal with on a case-by-case basis as seems approrpaite
	list PersonID Year MGMTLEVEL MgmtLevel_ORIG CURRENTMLDATE CurrentMLDate_ORIG if INV_flag_ML>=1
	* > 44379: Currently MGMTLEVEL is management level 4 for 2009, management level 5 for 2010, 2011, and management level 4 for 2012 - given original management level dates, seems most likely management level 5 in 2009, so change 2009 MGMTLEVEL, and CURRENTMLDATE for 2010 and 2011 (currently missing)
	* >> Also update CURRENTMLDATE for 2012 to 01apr2012 (CurrentMLDate_ORIG from another observation that appears to appply for this observation)
	replace MGMTLEVEL="ML 5" if PersonID=="44379" & Year==2009
	replace CURRENTMLDATE=date("11-01-2009", "MDY") if PersonID=="44379" & (Year==2010 | Year==2011)
	replace CURRENTMLDATE=date("04-01-2012", "MDY") if PersonID=="44379" & Year==2012
	* > 52508: No CURRENTMLDATE for 2011 and 2012 as CurrentMLDate_ORIG seem to apply to other MGMTLEVEL observations; assume promoted on 1/1/2011, and update CURRENTMLDATE accordingly
	replace CURRENTMLDATE=date("01-01-2011", "MDY") if PersonID=="52508" & (Year==2011 | Year==2012)
	* > 53447: No CURRENTMLDATE for 2010 and 2011 as CurrentMLDate_ORIG seem to apply to other MGMTLEVEL observations; assume promoted on 1/1/2010, and update CURRENTMLDATE accordingly
	replace CURRENTMLDATE=date("01-01-2010", "MDY") if PersonID=="53447" & (Year==2010 | Year==2011)
	* > 66562: No CURRENTMLDATE for 2011 or 2012 as CurrentMLDate_ORIG seems to apply to other MGMTLEVEL observations; assume promoted on 1/1/2011 (may have been on 4/1/2010 given dates, but doesn't match MGMTLEVEL, so use 1/1/2011)  
	replace CURRENTMLDATE=date("01-01-2011", "MDY") if PersonID=="66562" & (Year==2011 | Year==2012)

	* 19.65 Recreate f_Entrydate, f_CurrentMLDate, and f_MLDate_difflevel to make sure all data consistent
	drop f_Entrydate
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: gen f_Entrydate=1 if ENTRYDATE!=ENTRYDATE[_n-1]
	replace f_Entrydate=. if OBS==1
	replace f_Entrydate=. if EMP_TIME[_n-1]!=EMP_TIME
	tab f_Entrydate
	* > No instances flagged
	drop f_MLDate_difflevel
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_difflevel=1 if CURRENTMLDATE==CURRENTMLDATE[_n-1] & MGMTLEVEL!=MGMTLEVEL[_n-1] & CURRENTMLDATE!=.
	replace f_MLDate_difflevel=. if OBS==1 
	tab f_MLDate_difflevel
	* > No instances flagged
	drop f_CurrentMLDate
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: gen f_CurrentMLDate=1 if CURRENTMLDATE!=CURRENTMLDATE[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] 
	replace f_CurrentMLDate=. if OBS==1
	by PersonID: replace f_CurrentMLDate=. if EMP_TIME[_n-1]!=EMP_TIME & OBS!=1
	tab f_CurrentMLDate
	* > No instances flagged

	* 19.66 Create Exitdate_b_entrydate variable and set = 1 if EXIT_DATE_USE<ENTRYDATE (should be no instances); deal with any cases accordingly
	gen Exitdate_b_entrydate=1 if EXIT_DATE_USE<ENTRYDATE & ENTRYDATE!=.
	tab Exitdate_b_entrydate
	* > 1 instance flagged
	* 20293973: Only one observation for this employee 2015-- orig entrydate was 04dec2015; orig management level date was 01aug2015; exitdate was 06nov2015 --  employee won't appear in any analyses, but update entrydate and maangement level date to original MLdate
	replace ENTRYDATE=date("08-01-2015", "MDY") if Exitdate_b_entrydate==1
	replace CURRENTMLDATE=ENTRYDATE if Exitdate_b_entrydate==1

	* 19.67 Create Exitdate_b_MLdate variable and set = 1 if EXIT_DATE_USE<CURRENTMLDATE
	gen Exitdate_b_MLdate=1 if EXIT_DATE_USE<CURRENTMLDATE & CURRENTMLDATE!=.
	tab Exitdate_b_MLdate

	* 19.68 Examine instances where Exitdate_b_MLdate=1 and deal with as deemed appropriate
	list PersonID Year ENTRYDATE CURRENTMLDATE Entrydate_ORIG CurrentMLDate_ORIG EXIT_DATE_USE EXIT_REASON_USE if Exitdate_b_MLdate==1
	tab Year if Exitdate_b_MLdate==1
	* > 28 instances 2015, 2 instances 2014, 1 instance 2010 => replace EXIT_DATE_USE and EXIT_REASON_USE with missing for 2014 and 2015 instances as evidence suggests employees still present (highly unlikely to move to a new management level after termination decided; for 2010 observation, the employee has no subsequent observations; here set CURRENTMLDATE=EXIT_DATE_USE
	replace EXIT_DATE_USE=. if Exitdate_b_MLdate==1 & (Year==2014 | Year==2015)
	replace EXIT_REASON_USE="" if Exitdate_b_MLdate==1 & (Year==2014 | Year==2015)
	replace CURRENTMLDATE=EXIT_DATE_USE if Year==2010 & Exitdate_b_MLdate==1

	* 19.69 Drop variables no longer needed
	drop S_NEW_ML S_PRIOR_ML SUM_KEEP
	drop EXCL Exitdate_b_MLdate Exitdate_b_entrydate f_CurrentMLDate f_MLDate_difflevel f_Entrydate INV_flag_ML flag_ML SAMEYEAR SAMEMONTH f_MLDate_early INV_CurrentMLDate Max_MLDate Mode_MLDate INV_MLDate_difflevel
	drop f_BirthYear  M_BirthYear f_Male M_Male INV_Entrydate Min_Entrydate Alt_MgmtLevel Min_CurrentMLDate Min2 Min2_CurrentMLDate f_MLDate_correct f_MLDate_late LATE SAMEYM MLdate_b_entrydate 

	* 19.70 Recreate ML_STRING variable
	drop ML_STRING
	sort PersonID EMP_TIME Year OBS
	gen ML_STRING=1 if OBS==1
	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1)) 

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	by PersonID: replace ML_STRING=ML_STRING[_n-1] if OBS==[_n-1]+1 & ML_STRING==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace ML_STRING=ML_STRING[_n-1]+1 if ((OBS==OBS[_n-1]+1 & ML_STRING==. & MGMTLEVEL!=MGMTLEVEL[_n-1]) | (EMP_TIME!=EMP_TIME[_n-1] & OBS!=1))

	count if ML_STRING==.
	tab ML_STRING
	* > Looks good 
	
*** DEALING WITH DATES FOR EMPLOYEES WHO APPEAR TO HAVE EXITED & RE-ENTERED ***

	* 19.71 Where ENTRYDATE is missing, but CURRENTMLDATE is not and year(CURRENTMLDATE)=Year & first observation where EMP_TIME>1, set ENTRYDATE=CURRENTMLDATE and bring to relevant observations
	sort PersonID EMP_TIME Year OBS
	by PersonID: replace ENTRYDATE=CURRENTMLDATE if ENTRYDATE==. & year(CURRENTMLDATE)==Year & EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace ENTRYDATE=ENTRYDATE[_n-1] if EMP_TIME==2 & EMP_TIME[_n-1]==2

	* 19.72 Where EMP_TIME=2, replace CURRENTMLDATE with missing if year(CURRENTMLDATE)<Year[_n-1] or year(CURRENTMLDATE)<year(ENTRYDATE) & first observation where EMP_TIME>1, and bring missing to relevant observations
	sort PersonID EMP_TIME Year OBS
	by PersonID: replace CURRENTMLDATE=. if (year(CURRENTMLDATE)<Year[_n-1] | year(CURRENTMLDATE)<year(ENTRYDATE)) & EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace CURRENTMLDATE=. if CURRENTMLDATE[_n-1]==. & MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==2 & EMP_TIME[_n-1]==2

	* 19.73 By PersonID EMP_TIME, create MAX and MIN for Entrydate_ORIG and MAX and MIN for CurrentMLDate_ORIG
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: egen MAX_ENTRY=max(Entrydate_ORIG)
	by PersonID EMP_TIME: egen MIN_ENTRY=min(Entrydate_ORIG)
	by PersonID EMP_TIME: egen MAX_ML=max(CurrentMLDate_ORIG)
	by PersonID EMP_TIME: egen MIN_ML=min(CurrentMLDate_ORIG)

	* 19.74 Create ENTRY_USE and ML_USE variables, and for the first observation where EMP_TIME>1, set = to MIN_ENTRY (MIN_ML) | MAX_ENTRY (MAX_ML) | Entrydate_ORIG (CurrentMLDate_ORIG) if year of that variable = Year 
	gen ENTRY_USE=.
	gen ML_USE=.
	sort PersonID EMP_TIME Year OBS
	by PersonID: replace ENTRY_USE=MIN_ENTRY if year(MIN_ENTRY)==Year & EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace ENTRY_USE=MAX_ENTRY if year(MAX_ENTRY)==Year & EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace ENTRY_USE=Entrydate_ORIG if year(Entrydate_ORIG)==Year & EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace ML_USE=MIN_ML if year(MIN_ML)==Year & EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace ML_USE=MAX_ML if year(MAX_ML)==Year & EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace ML_USE=CurrentMLDate_ORIG if year(CurrentMLDate_ORIG)==Year & EMP_TIME==2 & EMP_TIME[_n-1]==1
	 
	* 19.75 Replace ENTRYDATE and CURRENTMLDATE with ENTRY_USE if variable is missing and this is the first observation where EMP_TIME>1; replace with ML_USE if still missing after replacement with ENTRY_USE 
	sort PersonID EMP_TIME Year OBS 
	by PersonID: replace ENTRYDATE=ENTRY_USE if ENTRYDATE==. & EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace CURRENTMLDATE=ENTRY_USE if CURRENTMLDATE==. & EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace ENTRYDATE=ML_USE if ENTRYDATE==. &  EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace CURRENTMLDATE=ML_USE if CURRENTMLDATE==. & EMP_TIME==2 & EMP_TIME[_n-1]==1

	* 19.76 Bring ENTRYDATE and CURRENTMLDATE from first observation where EMP_TIME>1, to all subsequent observations for the employee (with same MGMTLEVEL for CURRENTMLDATE)
	sort PersonID EMP_TIME Year OBS
	by PersonID: replace ENTRYDATE=ENTRYDATE[_n-1] if EMP_TIME==2 & EMP_TIME[_n-1]==2
	by PersonID: replace CURRENTMLDATE=CURRENTMLDATE[_n-1] if MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==2 & EMP_TIME[_n-1]==2

	* 19.77 Where ENTRYDATE and CURRENTMLDATE are still missing and this is the first observation where EMP_TIME>1, assume ENTRYDATE / CURRENTMLDATE is (1,1,Year), and bring to all observations for the employee (with same  MGMTLEVEL for CURRENTMLDATE)
	sort PersonID EMP_TIME Year OBS
	by PersonID: replace ENTRYDATE=mdy(1,1,Year) if ENTRYDATE==. & EMP_TIME==2 & EMP_TIME[_n-1]==1
	by PersonID: replace ENTRYDATE=ENTRYDATE[_n-1] if EMP_TIME==2 & EMP_TIME[_n-1]==2
	by PersonID: replace CURRENTMLDATE=mdy(1,1,Year) if CURRENTMLDATE==. & EMP_TIME==2 & EMP_TIME[_n-1]==1 
	by PersonID: replace CURRENTMLDATE=CURRENTMLDATE[_n-1] if MGMTLEVEL==MGMTLEVEL[_n-1] & EMP_TIME==2 & EMP_TIME[_n-1]==2

	** >> Appears that for many of the employees who appear to have exited & re-entered that dates from their earlier stint at the company are recorded against observations from their later stint  - observations pertaining to their later stint are not used in my analyses -> OK **

*** END DEALING WITH DATES FOR EMPLOYEES WHO EXITED & RE-ENTERED ***

	* 19.78 Recreate f_Entrydate, f_CurrentMLDate, and f_MLDate_difflevel to make sure all data consistent
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: gen f_Entrydate=1 if ENTRYDATE!=ENTRYDATE[_n-1]
	replace f_Entrydate=. if OBS==1
	replace f_Entrydate=. if EMP_TIME[_n-1]!=EMP_TIME
	tab f_Entrydate
	* > No instances flagged
	sort PersonID Year OBS
	by PersonID: gen f_MLDate_difflevel=1 if CURRENTMLDATE==CURRENTMLDATE[_n-1] & MGMTLEVEL!=MGMTLEVEL[_n-1] & CURRENTMLDATE!=.
	replace f_MLDate_difflevel=. if OBS==1 
	tab f_MLDate_difflevel
	* > No instances flagged
	sort PersonID EMP_TIME Year OBS
	by PersonID EMP_TIME: gen f_CurrentMLDate=1 if CURRENTMLDATE!=CURRENTMLDATE[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] 
	replace f_CurrentMLDate=. if OBS==1
	by PersonID: replace f_CurrentMLDate=. if EMP_TIME[_n-1]!=EMP_TIME & OBS!=1
	tab f_CurrentMLDate
	* > No instances flagged

	* 19.79 Recreate other date validity testing variables and check no instances flagged
	gen Exitdate_b_entrydate=1 if EXIT_DATE_USE<ENTRYDATE & ENTRYDATE!=.
	tab Exitdate_b_entrydate
	* > No instances flagged
	gen Exitdate_b_MLdate=1 if EXIT_DATE_USE<CURRENTMLDATE & CURRENTMLDATE!=.
	tab Exitdate_b_MLdate
	* > No instances flagged
	gen MLdate_b_entrydate=1 if ENTRYDATE>CURRENTMLDATE & ENTRYDATE!=.
	tab MLdate_b_entrydate
	* > No instances flagged

	* 19.80 Drop variables no longer needed
	drop MAX_ENTRY MIN_ENTRY ENTRY_USE MAX_ML MIN_ML ML_USE f_Entrydate f_MLDate_difflevel f_CurrentMLDate Exitdate_b_entrydate Exitdate_b_MLdate EXAMINE FLAG

	* 19.81 Label variables
	label variable BIRTHYEAR "Year of Birth"
	label variable CURRENTMLDATE "Date Began in Current Mgmt Level"
	label variable EMP_TIME "= 1 if First Tenure in the Company; = 2 if Second Tenure (exited and rejoined)"
	label variable EXIT_DATE_USE "Exit Date From Company"
	label variable EXIT_REASON_USE "Reason for Exiting the Company"
	label variable HOMECOUNTRY "Home Country of Employment (typically blank unless expat)"
	label variable HOSTCOUNTRY "Host Country (where presently) of Employment (typically blank unless expat)"
	label variable MALE "Male Dummy, = 1 if Male, = 0 if Female"
	label variable Rating_YE "Current Year Performance & Potential Rating"

	* 19.82 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Processed_Data_2.dta", replace 
	clear
	
**************************************************************************************************************************************************************************************************************************
* PROGRAM 20: Merge Management Level 0 Data into Processed Data
* Input file: "Processed_Data_2.dta"
* Steps:
	* 20.1 Read in Management Level 0 data
	* 20.2 Keep only PersonID, Entrydate, Exitdate, and PromotionDateML0 variables
	* 20.3 Rename Entrydate and Exitdate to (var name)_ML0data
	* 20.4 Merge file with Processed_Date_2 output file from above using PersonID
	* 20.5 Drop if _merge==2
	* 20.6 Save output file
	* 20.7 Remove interim files created in this program  
* Output file: "Analysis_Data.dta"
**************************************************************************************************************************************************************************************************************************

	* 20.1 Read in management level 0 data
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Combined ML0 2009-2015 Data.dta"

	* 20.2 Keep only PersonID, Entrydate, Exitdate, and PromotionDateML0 variables
	keep PersonID Entrydate Exitdate PromotionDateML0

	* 20.3 Rename Entrydate and Exitdate to (var name)_ML0data
	rename Entrydate Entrydate_ML0data
	rename Exitdate Exitdate_ML0data

	* 20.4 Merge file with Processed_Date_2 output file from above using PersonID
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML0_Data_2.dta", replace 
	clear 
	use "/Volumes/cdeller_project/Beyond Performance/JAR Data/Processed_Data_2.dta"
	merge m:1 PersonID using "/Volumes/cdeller_project/Beyond Performance/JAR Data/ML0_Data_2.dta"

	* 20.5 Drop if _merge==2
	drop if _merge==2

	* 20.6 Save output file
	save "/Volumes/cdeller_project/Beyond Performance/JAR Data/Analysis_Data.dta", replace 
	clear

	* 20.7 Remove interim files created in this program  
	rm "/Volumes/cdeller_project/Beyond Performance/JAR Data/Processed_Data_2.dta"
	rm "/Volumes/cdeller_project/Beyond Performance/JAR Data/ML0_Data_2.dta"

**************************************************************************************************************************************************************************************************************************
* PROGRAM 21: Create Demographic & Employment Variables
* Input file: "Analysis_Data.dta"
* Steps:
	* 21.1 Read in data file 
	* 21.2 Create age variable
	* 21.3 Create age at entry variable and replace ENTRYDATE with missing if age at entry seems too low 
	* 21.4 Create company tenure variable (as of end of year)
	* 21.5 Create management level tenure variable (as of year end)
	* 21.6 Create expat dummy variable
	* 21.7 Create observation number within EMP_TIME for each PersonID
	* 21.8 Create dummy variable, PROM_MGMTLEVEL, = 1 if management level this year is one level higher than last year (i.e. promoted one level) 
	* 21.9 Create dummy variable, DEM_MGMTLEVEL, = 1 if management level this year is one level lower than last year (i.e. demoted one level) 
	* 21.10 Investigate any instances where a change in management level is not recorded as a promotion or demotion (e.g., if management level this year is two levels higher than last year), and update variables/observations as deemed appropriate
	* 21.11 Create LDOY variable and set = 1 if EXIT_DATE_USE is last day (12/31) of the year
	* 21.12 Create dummy variable, EXIT_OB_SY, = 1 if an employee has an observation for the year in which they exited
	* 21.13 Bring EXIT_DATE_USE and EXIT_REASON_USE to the prior year observation for an employee where the employee exits during the current year (but not on the last day of the year) and has an observation for the current year
	* 21.14 Create and label EXCL dummy and set = 1 if EXIT_OB_SY==1 & LDOY!=1 (i.e. employee exited during the current year, but not on the last day of the year, and has an observation for the year)
	* 21.15 Create variable PROM_NY, = 1 if promoted in subsequent year
	* 21.16 Create and format PROMDATE_ML0 variable and set = date promoted to ML0
	* 21.17 Create ML_PROM variable, = 1 if promoted to ML0 in subsequent year
	* 21.18 Count instances where ML_PROM=1 and last record for the employee in my data (should disappear from my data once becomes ML0); list instances where ML_PROM=1 & not last record for the employee, and deal with accordingly
	* 21.19 Examine any instances where ML_PROM=1 but there is an EXIT_DATE_USE for the employee, and deal with accordingly; ensure EXIT_DATE_USE and EXIT_REASON_USE are blank for employees that became ML0
	* 21.20 Set PROM_NY=1 for employees who became ML0 in the next year, and tab PROM_NY variable
	* 21.21 Create PROM_NY_MONTH to capture the month in which the employee was promoted	
	* 21.22 Create PROM_2Y variable -- promoted in year t+2
	* 21.23 Recreate EXIT_OBS_SY due to changes to EXIT_DATE_USE above
	* 21.24 Recreate EXCL variable
	* 21.25 Create dummy variable DEM_NY, = 1 if demoted in subsequent year
	* 21.26 Create EXCL2 dummy = 1 if EXIT_OB_SY==1 (irrespective of whether LDOY==1 or !=1; i.e. employee exited during the current year, including on the last day of the year, and has an observation for the year)
	* 21.27 Create dummy variable EXIT_NY = 1 if exited in subsequent year 
	* 21.28 Bring EXIT_DATE_USE and EXIT_REASON_USE to the prior year observation for an employee where the employee exits in the current year and has an observation for the current year
	* 21.29 Create EXIT_CATEGORY variable categorizing the reasons in EXIT_REASON_USE into broader categories
	* 21.30 Create EXIT_VOLUNTARY and EXIT_INVOLUNTARY dummy variables
	* 21.31 Create EXIT_NY_MONTH to capture the month the employee exited
	* 21.32 Create EXITINVOL_2Y var -- involuntary exit in year t+2
	* 21.33 Save output file
* Output file: "Analysis_Data_v1.dta"
**************************************************************************************************************************************************************************************************************************
	
	* 21.1 Read in data file 
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data.dta"

	* 21.2 Create age variable
	gen AGE=Year-BIRTHYEAR if BIRTHYEAR!=.
	label variable AGE "Age (in years)"

	* 21.3 Create age at entry variable and replace ENTRYDATE with missing if age at entry seems too low 
	gen E_AGE=year(ENTRYDATE)-BIRTHYEAR if ENTRYDATE!=. & BIRTHYEAR!=.
	summarize E_AGE, detail
	* > assume AGE is correct; therefore E_AGE cannot be <=0
	replace ENTRYDATE=. if E_AGE<=0
	drop E_AGE
	gen E_AGE=year(ENTRYDATE)-BIRTHYEAR if ENTRYDATE!=. & BIRTHYEAR!=.
	* > assume AGE is correct and any instances with E_AGE <9 the ENTRYDATE is incorrect (set to missing) (in any case, observation will be excluded from analyses as ENTRYDATE is used to construct company tenure variable)
	replace ENTRYDATE=. if E_AGE<9

	* 21.4 Create company tenure variable (as of end of year)
	gen YE_month=12
	gen YE_day=31
	gen YE_date=mdy(YE_month, YE_day, Year)
	format YE_date %td

	gen COY_TENURE=((YE_date-ENTRYDATE)/365.25) if ENTRYDATE!=.
	label variable COY_TENURE "Tenure with Company (in years)"

	* 21.5 Create management level tenure variable (as of year end)
	gen MGMTLEVEL_TENURE=((YE_date-CURRENTMLDATE)/365.25) if CURRENTMLDATE!=.
	label variable MGMTLEVEL_TENURE "Tenure in Current Mgmt Level (in years)"

	* 21.6 Create expat dummy variable
	gen EXPAT=0 if TYPE!=""
	replace EXPAT=1 if (TYPE=="Delegate" | TYPE=="Guest" | TYPE=="Impat")
	tab TYPE EXPAT
	label variable EXPAT "Expat Dummy (= 1 if Expat, = 0 if Not an Expat)"
	
	* 21.7 Create observation number within EMP_TIME for each PersonID
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: gen N_OBS = _n
	label variable N_OBS "Observation number within EMP_TIME for PersonID"

	* 21.8 Create dummy variable, PROM_MGMTLEVEL, = 1 if management level this year is one level higher than last year (i.e. promoted one level) 
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: gen PROM_MGMTLEVEL=1 if ((MGMTLEVEL[_n-1]=="ML 5" & MGMTLEVEL=="ML 4") | (MGMTLEVEL[_n-1]=="ML 4" & MGMTLEVEL=="ML 3") | (MGMTLEVEL[_n-1]=="ML 3" & MGMTLEVEL=="ML 2") | (MGMTLEVEL[_n-1]=="ML 2" & MGMTLEVEL=="ML 1")) & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	tab Year PROM_MGMTLEVEL

	* 21.9 Create dummy variable, DEM_MGMTLEVEL, = 1 if management level this year is one level lower than last year (i.e. demoted one level) 
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: gen DEM_MGMTLEVEL=1 if ((MGMTLEVEL[_n-1]=="ML 1" & MGMTLEVEL=="ML 2") | (MGMTLEVEL[_n-1]=="ML 2" & MGMTLEVEL=="ML 3") | (MGMTLEVEL[_n-1]=="ML 3" & MGMTLEVEL=="ML 4") | (MGMTLEVEL[_n-1]=="ML 4" & MGMTLEVEL=="ML 5")) & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	tab Year DEM_MGMTLEVEL 

	* 21.10 Investigate any instances where a change in management level is not recorded as a promotion or demotion (e.g., if management level this year is two levels higher than last year), and update variables/observations as deemed appropriate
	sort PersonID Year
	by PersonID: gen flag_CH=1 if MGMTLEVEL[_n-1]!=MGMTLEVEL & PROM_MGMTLEVEL==. & DEM_MGMTLEVEL==. & Year==Year[_n-1]+1 & MGMTLEVEL!="" & MGMTLEVEL[_n-1]!="" & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	tab flag_CH
	sort PersonID Year
	by PersonID: egen SUM_flag_CH=sum(flag_CH)
	tab Year if flag_CH==1
	list PersonID Year MGMTLEVEL CURRENTMLDATE CurrentMLDate_ORIG Rating_YE Rating_PY EMP_TIME flag_CH if SUM_flag_CH>=1 
	* > 6218: Seems highly unlikely would be demoted from ML 3 to ML 5 when received S2 in prior year; seems likely was ML5 in 2008, so change MGMTLEVEL, and then use the 12nov1990 ML date that was the original date against 2009, 2010, 2012 observations
	replace MGMTLEVEL="ML 5" if PersonID=="6218" & Year==2008
	replace CURRENTMLDATE=mdy(11,12,1990) if PersonID=="6218" & MGMTLEVEL=="ML 5"
	* > 77918: Seems highly unlikely would be demoted to ML5 when have S2 in prior year, and then to be promoted to ML3 the next year; apparently ML5 in 2014, but no original current mldate for the employee has that year; seems more likely was incorrectly recorded at ML5 as became ML3 on first day of next year; update management level accordingly, and use 01jan2015 for 2015 promotion date rather than 01oct2015 (date appears against other obs)
	replace MGMTLEVEL="ML 4" if PersonID=="77918" & Year==2014
	replace CURRENTMLDATE=mdy(7,1,2011) if PersonID=="77918" & MGMTLEVEL=="ML 4"
	replace CURRENTMLDATE=mdy(1,1,2015) if PersonID=="77918" & Year==2015
	replace DEM_MGMTLEVEL=. if PersonID=="77918" & Year==2014
	* > 20243176: I had replaced CURRENTMLDATE for 2014 with 1/1/2014 as first observation for employee even though entered in 2010 and I assumed would not have been on leave as a manager for extended period of time. BUT Rating_PY has a valid rating in 2014 observation, so must have been a manager (at some level) prior to 2014 - replace CURRENTMLDATE with missing for 2014
	replace CURRENTMLDATE=. if PersonID=="20243176" & Year==2014
	* > Other observations, several instances where promotion from ML5 to ML3, but it may be that there was no ML4 position to be promoted to, and generally at least a "2" for potential in these instances
	* > Few instances of demotion from ML3 to ML5, generally where "4" for potential so seems reasonable
	* > Handful of instances where promotion/demotion two levels seems unlikely, but in most cases the CURRENTMLDATE is missing, so promotion/demotion won't be included in analyses 
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: replace PROM_MGMTLEVEL=1 if (MGMTLEVEL[_n-1]=="ML 5" & (MGMTLEVEL=="ML 4" | MGMTLEVEL=="ML 3")) & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	* > Repeat code for promotion one level to account for a change made above
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: replace PROM_MGMTLEVEL=1 if ((MGMTLEVEL[_n-1]=="ML 5" & MGMTLEVEL=="ML 4") | (MGMTLEVEL[_n-1]=="ML 4" & MGMTLEVEL=="ML 3") | (MGMTLEVEL[_n-1]=="ML 3" & MGMTLEVEL=="ML 2") | (MGMTLEVEL[_n-1]=="ML 2" & MGMTLEVEL=="ML 1")) & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]

	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: replace DEM_MGMTLEVEL=1 if (MGMTLEVEL[_n-1]=="ML 3" & (MGMTLEVEL=="ML 4" | MGMTLEVEL=="ML 5")) & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	
	* 21.11 Create LDOY variable and set = 1 if EXIT_DATE_USE is last day (12/31) of the year
	gen LM=1 if month(EXIT_DATE_USE)==12
	gen LD=1 if day(EXIT_DATE_USE)==31
	gen LY=1 if (year(EXIT_DATE_USE)==2008 | year(EXIT_DATE_USE)==2009 | year(EXIT_DATE_USE)==2010 | year(EXIT_DATE_USE)==2011  | year(EXIT_DATE_USE)==2012  | year(EXIT_DATE_USE)==2013  | year(EXIT_DATE_USE)==2014  | year(EXIT_DATE_USE)==2015)
	gen LDOY=1 if LM==1 & LD==1 & LY==1 
	tab LDOY
	
	* 21.12 Create dummy variable, EXIT_OB_SY, = 1 if an employee has an observation for the year in which they exited
	gen EXIT_OB_SY=1 if year(EXIT_DATE_USE)==Year
	
	* 21.13 Bring EXIT_DATE_USE and EXIT_REASON_USE to the prior year observation for an employee where the employee exits during the current year (but not on the last day of the year) and has an observation for the current year
	sort PersonID EMP_TIME OBS
	by PersonID EMP_TIME: replace EXIT_DATE_USE=EXIT_DATE_USE[_n+1] if EXIT_DATE_USE==. & EXIT_DATE_USE[_n+1]!=. & Year==Year[_n+1]-1 & LDOY[_n+1]!=1 & EXIT_OB_SY[_n+1]==1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1]
	by PersonID EMP_TIME: replace EXIT_REASON_USE=EXIT_REASON_USE[_n+1] if EXIT_REASON_USE=="" & EXIT_REASON_USE[_n+1]!="" & Year==Year[_n+1]-1 & LDOY[_n+1]!=1 & EXIT_OB_SY[_n+1]==1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1] 

	* 21.14 Create and label EXCL dummy and set = 1 if EXIT_OB_SY==1 & LDOY!=1 (i.e. employee exited during the current year, but not on the last day of the year, and has an observation for the year)
	gen EXCL=1 if EXIT_OB_SY==1 & LDOY!=1
	tab EXCL
	label variable EXCL "Excl Employee Obs Dummy (= 1 if obs for year of exit and exit date is not 12/31)"

	* 21.15 Create variable PROM_NY, = 1 if promoted in subsequent year
	sort PersonID Year
	by PersonID: gen PROM_NY=0 if PROM_MGMTLEVEL[_n+1]!=1 & Year==Year[_n+1]-1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1] & EXCL[_n+1]!=1 & MGMTLEVEL!="" & MGMTLEVEL[_n+1]!="" 
	by PersonID: replace PROM_NY=1 if PROM_MGMTLEVEL[_n+1]==1 & Year==Year[_n+1]-1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1] & EXCL[_n+1]!=1 & MGMTLEVEL!="" & MGMTLEVEL[_n+1]!="" 
	tab PROM_NY
	label variable PROM_NY "Promoted Next Year Dummy (= 1 if promoted,= 0 if not; present on 12/31 nextyear)"

	* 21.16 Create and format PROMDATE_ML0 variable and set = date promoted to ML0
	tab PromotionDateML0
	gen PROMDATE_ML0 = date(PromotionDateML0, "DMY") 
	format PROMDATE_ML0 %td
	tab PROMDATE_ML0

	* 21.17 Create ML_PROM variable, = 1 if promoted to ML0 in subsequent year
	gen ML_PROM=1 if year(PROMDATE_ML0)==Year+1
	tab ML_PROM

	* 21.18 Count instances where ML_PROM=1 and last record for the employee in my data (should disappear from my data once becomes ML0); list instances where ML_PROM=1 & not last record for the employee, and deal with accordingly
	count if OBS==N & ML_PROM==1
	list PersonID Year OBS N if ML_PROM==1 & OBS!=N
	* > 49815 - became ML0 on 1 Apr 2014, so drop 2014 observation from the dataset, and set EXIT_DATE_USE=. in 2013 observation (current exit date = 3/31/2014 - which would be when stopped being ML1)
	drop if PersonID=="49815" & Year==2014
	replace EXIT_DATE_USE=. if PersonID=="49815" & Year==2013

	* 21.19 Examine any instances where ML_PROM=1 but there is an EXIT_DATE_USE for the employee, and deal with accordingly; ensure EXIT_DATE_USE and EXIT_REASON_USE are blank for employees that became ML0
	list PersonID Year PROMDATE_ML0 EXIT_DATE_USE EXIT_REASON_USE if ML_PROM==1
	* > From a visual inspection of the data, PersonID 1254 had an exit date of 31mar2010 recorded against the 2009 observation -- this employee also has a 2010 observation, and ML0 promotion date of 1feb2011
	* > No Rating for 2010, so consider promotion to occur in 2010 - drop 2010 observation for this employee
	drop if PersonID=="1254" & Year==2010
	replace PROM_NY=1 if PersonID=="1254" & Year==2009
	replace ML_PROM=1 if PersonID=="1254" & Year==2009
	* > Will not follow employees once they become ML0, so set EXIT_DATE_USE=. for all instances where !=., and set EXIT_REASON_USE="" for all instances where !=""
	replace EXIT_DATE_USE=. if ML_PROM==1
	replace EXIT_REASON_USE="" if ML_PROM==1

	* 21.20 Set PROM_NY=1 for employees who became ML0 in the next year, and tab PROM_NY variable
	replace PROM_NY=1 if year(PROMDATE_ML0)==Year+1 
	tab PROM_NY
	
	* 21.21 Create PROM_NY_MONTH to capture the month in which the employee was promoted
	sort PersonID Year
	gen PROM_NY_MONTH = month(CURRENTMLDATE[_n+1]) if PROM_NY==1 & PersonID==PersonID[_n+1] & Year==Year[_n+1]-1
	replace PROM_NY_MONTH=month(PROMDATE_ML0) if PROM_NY==1 & year(PROMDATE_ML0)==Year+1
	tab PROM_NY_MONTH
	tab PROM_NY
	* > for employee above where assumed promotion occurred in 2010, assume December promotion
	replace PROM_NY_MONTH=12 if PersonID=="1254" & Year==2009
	tab PROM_NY_MONTH
	tab PROM_NY
	* > now observation count matches => GOOD
	
	* 21.22 Create PROM_2Y variable -- promoted in year t+2
	sort PersonID Year
	by PersonID: gen PROM_2Y=0 if PROM_NY[_n+1]==0 & Year==Year[_n+1]-1
	by PersonID: replace PROM_2Y=1 if PROM_NY[_n+1]==1 & Year==Year[_n+1]-1
	tab PROM_2Y
	
	* 21.23 Recreate EXIT_OBS_SY due to changes to EXIT_DATE_USE above
	drop EXIT_OB_SY
	gen EXIT_OB_SY=1 if year(EXIT_DATE_USE)==Year

	* 21.24 Recreate EXCL variable
	drop EXCL
	gen EXCL=1 if EXIT_OB_SY==1 & LDOY!=1
	tab EXCL
	label variable EXCL "Excl Employee Obs Dummy (= 1 if obs for year of exit and exit date is not 12/31)"
	
	* 21.25 Create dummy variable DEM_NY, = 1 if demoted in subsequent year
	gen DEM_NY=.
	sort PersonID Year
	by PersonID: replace DEM_NY=0 if DEM_MGMTLEVEL[_n+1]!=1 & Year==Year[_n+1]-1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1] & EXCL[_n+1]!=1 & MGMTLEVEL!="" & MGMTLEVEL[_n+1]!=""
	by PersonID: replace DEM_NY=1 if DEM_MGMTLEVEL[_n+1]==1 & Year==Year[_n+1]-1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1] & EXCL[_n+1]!=1 & MGMTLEVEL!="" & MGMTLEVEL[_n+1]!="" 
	replace DEM_NY=0 if ML_PROM==1
	tab DEM_NY
	label variable DEM_NY "Demoted Next Year Dummy (= 1 if demoted, = 0 if not; present on 12/31 next year)"

	* 21.26 Create EXCL2 dummy = 1 if EXIT_OB_SY==1 (irrespective of whether LDOY==1 or !=1; i.e. employee exited during the current year, including on the last day of the year, and has an observation for the year)
	gen EXCL2=1 if EXIT_OB_SY==1 
	tab EXCL2
	label variable EXCL2 "Excl Employee Obs Dummy (= 1 if obs for year of exit)"

	* 21.27 Create dummy variable EXIT_NY = 1 if exited in subsequent year 
	gen EXIT_NY=.
	sort PersonID Year
	by PersonID: replace EXIT_NY=0 if EXIT_DATE_USE==. & OBS!=N & Year!=2015 & EXCL2[_n+1]!=1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1]  
	by PersonID: replace EXIT_NY=0 if EXIT_DATE_USE==. & OBS!=N & Year!=2015 & Year[_n+1]>Year+1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1]
	by PersonID: replace EXIT_NY=1 if year(EXIT_DATE_USE)==Year+1 & OBS==N & Year!=2015 
	by PersonID: replace EXIT_NY=1 if year(EXIT_DATE_USE)==Year+1 & OBS==EMP_N & Year!=2015 
	sort PersonID Year
	by PersonID: replace EXIT_NY=1 if EXIT_DATE_USE[_n+1]!=. & OBS[_n+1]==EMP_N & EXCL2[_n+1]==1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1] & Year==Year[_n+1]-1 
	replace EXIT_NY=0 if ML_PROM==1
	tab EXIT_NY
	label variable EXIT_NY "Exited Next Year Dummy (= 1 if exited,= 0 if didn't and has a later observation)"

	* 21.28 Bring EXIT_DATE_USE and EXIT_REASON_USE to the prior year observation for an employee where the employee exits in the current year and has an observation for the current year
	sort PersonID Year
	by PersonID: replace EXIT_DATE_USE=EXIT_DATE_USE[_n+1] if EXIT_NY==1 & EXIT_DATE_USE==. & EXIT_DATE_USE[_n+1]!=. & EXIT_OB_SY[_n+1]==1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1]  
	sort PersonID Year
	by PersonID: replace EXIT_REASON_USE=EXIT_REASON_USE[_n+1] if EXIT_NY==1 & EXIT_REASON_USE=="" & EXIT_REASON_USE[_n+1]!="" & EXIT_OB_SY[_n+1]==1 & PersonID==PersonID[_n+1] & EMP_TIME==EMP_TIME[_n+1]  

	* 21.29 Create EXIT_CATEGORY variable categorizing the reasons in EXIT_REASON_USE into broader categories
	gen EXIT_CATEGORY=""
	replace EXIT_CATEGORY="Employee reason" if (EXIT_REASON_USE=="Development" | EXIT_REASON_USE=="Employee's reason" | EXIT_REASON_USE=="External Job Offer" | EXIT_REASON_USE=="Financial" | EXIT_REASON_USE=="Job Design" | EXIT_REASON_USE=="Manager" | EXIT_REASON_USE=="Personal Reason")
	replace EXIT_CATEGORY="Employer reason" if EXIT_REASON_USE=="Employer's reason"
	replace EXIT_CATEGORY="Retirement" if (EXIT_REASON_USE=="Retirement" | EXIT_REASON_USE=="Early retirement")
	replace EXIT_CATEGORY="Mutual agreement" if EXIT_REASON_USE=="Mutual agreement"
	replace EXIT_CATEGORY="Other" if (EXIT_REASON_USE=="Death" | EXIT_REASON_USE=="Disinvestment" | EXIT_REASON_USE=="Dormant work contract" | EXIT_REASON_USE=="End of probation period" | EXIT_REASON_USE=="Leaving" | EXIT_REASON_USE=="Limited work contract" | EXIT_REASON_USE=="Other exit reason")
	tab EXIT_CATEGORY EXIT_REASON_USE if EXIT_NY!=.
	tab EXIT_CATEGORY if EXIT_NY!=.
	label variable EXIT_CATEGORY "Exit Reason Category (5 Categories)" 

	* 21.30 Create EXIT_VOLUNTARY and EXIT_INVOLUNTARY dummy variables
	gen EXIT_VOLUNTARY=.
	replace EXIT_VOLUNTARY=0 if (EXIT_CATEGORY=="Employer reason" | EXIT_CATEGORY=="Mutual agreement") & EXIT_NY==1
	replace EXIT_VOLUNTARY=0 if EXIT_NY==0
	replace EXIT_VOLUNTARY=1 if EXIT_CATEGORY=="Employee reason" & EXIT_NY==1
	label variable EXIT_VOLUNTARY "Voluntary Exit Dummy (= 1 if voluntary exit, = 0 if no exit or involuntary exit)" 
	tab EXIT_NY
	tab EXIT_VOLUNTARY
	* > Difference in totals due to "Other" exits, "Retirement" exits, and exits with no exit reason 

	gen EXIT_INVOL=.
	replace EXIT_INVOL=0 if EXIT_CATEGORY=="Employee reason" & EXIT_NY==1
	replace EXIT_INVOL=0 if EXIT_NY==0
	replace EXIT_INVOL=1 if (EXIT_CATEGORY=="Employer reason" | EXIT_CATEGORY=="Mutual agreement") & EXIT_NY==1
	label variable EXIT_INVOL "Involuntary Exit Dummy (= 1 if involuntary exit, = 0 if no exit or voluntary exit)" 
	tab EXIT_INVOL

	* 21.31 Create EXIT_NY_MONTH to capture the month the employee exited
	gen EXIT_NY_MONTH=month(EXIT_DATE_USE) if EXIT_NY==1 & year(EXIT_DATE_USE)==Year+1 
	tab EXIT_NY_MONTH
	tab EXIT_NY
		
	* 21.32 Create EXITINVOL_2Y var -- involuntary exit in year t+2
	sort PersonID Year
	by PersonID: gen EXITINVOL_2Y=0 if EXIT_INVOL[_n+1]==0 & Year==Year[_n+1]-1
	by PersonID: replace EXITINVOL_2Y=1 if EXIT_INVOL[_n+1]==1 & Year==Year[_n+1]-1
	tab EXITINVOL_2Y

	* 21.33 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v1.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 22: Create Performance & Potential Rating Variables and Promotion and Demotion Variables
* Input file: "Analysis_Data_v1.dta"
* Steps:
	* 22.1 Read in data file
	* 22.2 Tab Rating_YE and PERF_YE; tab Rating_YE and POT_YE; and deal with any inconsistencies as deemed appropriate (repeat for Rating_PY)
	* 22.3 Bring PPA supervisor ID from next year's observation (since that's when performance ratings were finalized) to this year's observation, by creating PPA_Supervisor_TY variable
	* 22.4 Drop observations where EXCL=1 (i.e. employee exited in this year, but not on the last day of the year)
	* 22.5 Create COUNTRY_reg, BU_reg, ML_reg, and FUNCTION_reg variables (by grouping existing variables)
	* 22.6 Create new numerical variables for PERF_YE (PERF_NUM) and POT_YE (POT_NUM) and repeat for prior year variables
	* 22.7 Modify employee variable values where encountered an anomaly (in course of inspecting variables, etc.)
	* 22.8 Recreate company tenure and management level tenure (as of end of year) variables 
	* 22.9 Create missing next year's observation dummy variable 
	* 22.10 Create missing prior year observation (N-1 = same management level) and missing prior year observation (N-1 = different management level) dummy variables 
	* 22.11 Create MIN_EY = year of the earliest Entrydate_ORIG by PersonID & EMP_TIME
	* 22.12 Create promotion this year, promotion last year, demotion this year, and demotion last year variables
	* 22.13 Replace PERF_NUM_PY and POT_NUM_PY with missing if EMP_TIME==2 & N_OBS=1 (i.e. disregard prior year rating if this is the first year for an employee who left & returned)
	* 22.14 Drop 2015 observations
	* 22.15 Create dummy variable, POT_DROP, = 1 if potential rating is lower this year compared to last year (= 0 if same or lower rating last year)
	* 22.16 Create dummy variable, PERF_DROP, = 1 if performance rating is lower this year compared to last year (= 0 if same or lower rating last year)
	* 22.17 Create dummy variable POT_INC, = 1 if potential rating is higher this year compared to last year (= 0 if same or higher rating last year)
	* 22.18 Create dummy variable PERF_INC, = 1 if performance rating is higher this year compared to last year (= 0 if same or higher rating last year)
	* 22.19 Create continuous performance and potential variables, PERF_ORDER and POT_ORDER 
	* 22.20 Create dummy variable for whether employee changed supervisor between last year and this year (= 0 if same supervisor this year and last year, and not missing)
	* 22.21 Save output file
* Output file: "Analysis_Data_v2.dta"
**************************************************************************************************************************************************************************************************************************

	* 22.1 Read in data file
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v1.dta"

	* 22.2 Tab Rating_YE and PERF_YE; tab Rating_YE and POT_YE; and deal with any inconsistencies as deemed appropriate (repeat for Rating_PY)
	tab Rating_YE PERF_YE
	tab Rating_YE POT_YE
	tab Rating_PY PERF_PY
	tab Rating_PY POT_PY
	* > One instance of L3 -- my understanding is this is not a valid rating => replace Rating_YE, PERF_YE and POT_YE with missing  (repeat for Rating_PY)
	replace PERF_YE="" if Rating_YE=="L3"
	replace POT_YE="" if Rating_YE=="L3"
	replace Rating_YE="" if Rating_YE=="L3"
	replace PERF_PY="" if Rating_PY=="L3"
	replace POT_PY="" if Rating_PY=="L3"
	replace Rating_PY="" if Rating_PY=="L3"

	* 22.3 Bring PPA supervisor ID from next year's observation (since that's when performance ratings were finalized) to this year's observation, by creating PPA_Supervisor_TY variable
	sort PersonID Year
	by PersonID: gen PPA_Supervisor_TY=PPADFSupervisorPersonID[_n+1] if PPADFSupervisorPersonID[_n+1]!="" & PersonID==PersonID[_n+1] & Year==Year[_n+1]-1 & EMP_TIME==EMP_TIME[_n+1] 
	label variable PPA_Supervisor_TY "PPA Supervisor ID - This Year's Rating"

	* 22.4 Drop observations where EXCL=1 (i.e. employee exited in this year, but not on the last day of the year)
	drop if EXCL==1

	* 22.5 Create COUNTRY_reg, BU_reg, ML_reg, and FUNCTION_reg variables (by grouping existing variables)
	tab COUNTRYWORK
	egen COUNTRY_reg = group(COUNTRYWORK), label
	tab BUSUNIT
	egen BU_reg = group(BUSUNIT), label
	tab MGMTLEVEL
	egen ML_reg = group(MGMTLEVEL), label
	tab FUNCTION
	egen FUNCTION_reg = group(FUNCTION), label

	* 22.6 Create new numerical variables for PERF_YE (PERF_NUM) and POT_YE (POT_NUM) and repeat for prior year variables
	gen PERF_NUM=0 if PERF_YE!=""
	replace PERF_NUM=1 if PERF_YE=="T"
	replace PERF_NUM=2 if PERF_YE=="S"
	replace PERF_NUM=3 if PERF_YE=="M"
	replace PERF_NUM=4 if PERF_YE=="L"
	label define PERF_NUM 1 "T" 2 "S" 3 "M" 4 "L"
	label values PERF_NUM PERF_NUM
	label list PERF_NUM
	tab PERF_NUM PERF_YE
	label variable PERF_NUM "Year End Performance Rating Numerical Value (T=1)"

	gen PERF_NUM_PY=0 if PERF_PY!=""
	replace PERF_NUM_PY=1 if PERF_PY=="T"
	replace PERF_NUM_PY=2 if PERF_PY=="S"
	replace PERF_NUM_PY=3 if PERF_PY=="M"
	replace PERF_NUM_PY=4 if PERF_PY=="L"
	label define PERF_NUM_PY 1 "T" 2 "S" 3 "M" 4 "L"
	label values PERF_NUM_PY PERF_NUM_PY
	label list PERF_NUM_PY
	tab PERF_NUM_PY PERF_PY
	label variable PERF_NUM_PY "Prior Year Performance Rating Numerical Value (T=1)"

	gen POT_NUM=0 if POT_YE!=""
	replace POT_NUM=1 if POT_YE=="1"
	replace POT_NUM=2 if POT_YE=="2"
	replace POT_NUM=3 if POT_YE=="3"
	replace POT_NUM=4 if POT_YE=="4"
	label define POT_NUM 1 "Vertical - 2 levels" 2 "Vertical - 1 level" 3 "Horizontal" 4 "Well placed"
	label values POT_NUM POT_NUM
	label list POT_NUM
	tab POT_NUM POT_YE
	label variable POT_NUM "Year End Potential Rating Numerical Value (1=2 levels)"

	gen POT_NUM_PY=0 if POT_PY!=""
	replace POT_NUM_PY=1 if POT_PY=="1"
	replace POT_NUM_PY=2 if POT_PY=="2"
	replace POT_NUM_PY=3 if POT_PY=="3"
	replace POT_NUM_PY=4 if POT_PY=="4"
	label define POT_NUM_PY 1 "Vertical - 2 levels" 2 "Vertical - 1 level" 3 "Horizontal" 4 "Well placed"
	label values POT_NUM_PY POT_NUM_PY
	label list POT_NUM_PY
	tab POT_NUM_PY POT_PY
	label variable POT_NUM_PY "Prior Year Potential Rating Numerical Value (1=2 levels)"

	* 22.7 Modify employee variable values where encountered an anomaly (in course of inspecting variables, etc.)
	* > Employee 3959 - CurrentMLDate_ORIG was 01sep2008 in 2008, and 02sep2008 in 2009 and 2010, but MGMTLEVEL is ML 4 in 2008 and ML 3 in 2009 and 2010 -- seems likely became ML 3 in 2008, but 2008 observation does not reflect this -- update variables accordingly
	replace MGMTLEVEL="ML 3" if PersonID=="3959" & Year==2008
	replace CURRENTMLDATE=mdy(9,1,2008) if PersonID=="3959" & (Year==2009 | Year==2010)
	replace PROM_NY=0 if PersonID=="3959" & Year==2008
	replace PROM_MGMTLEVEL=. if PersonID=="3959" & Year==2009
	* > Employee 9914 - ML4 for 2009-2010, then ML5 in 2011, then ML4 from 2012 onwards - CurrentMLDate_ORIG are a mix of 01jan2012 and 01apr2003 -- seems highly unlikely to be ML5 for one year (especially given CurrentMLdate can't be right), so change to ML4 for 2011
	replace MGMTLEVEL="ML 4" if PersonID=="9914" & Year==2011
	replace CURRENTMLDATE=mdy(4,1,2003) if PersonID=="9914" 
	replace DEM_NY=0 if PersonID=="9914" & Year==2010
	replace PROM_NY=0 if PersonID=="9914" & Year==2011
	replace DEM_MGMTLEVEL=. if PersonID=="9914" & Year==2011
	replace PROM_MGMTLEVEL=. if PersonID=="9914" & Year==2012
	* >> Update PROM_NY_MONTH variable
	replace PROM_NY_MONTH=. if PROM_NY==0

	* 22.8 Recreate company tenure and management level tenure (as of end of year) variables 
	drop COY_TENURE
	gen COY_TENURE=((YE_date-ENTRYDATE)/365.25) if ENTRYDATE!=.
	label variable COY_TENURE "Tenure with Company (in years)"

	drop MGMTLEVEL_TENURE
	gen MGMTLEVEL_TENURE=((YE_date-CURRENTMLDATE)/365.25) if CURRENTMLDATE!=.
	label variable MGMTLEVEL_TENURE "Tenure in Current Mgmt Level (in years)"

	* 22.9 Create  missing next year's observation dummy variable 
	sort PersonID Year
	by PersonID: gen NY_MISS=1 if PersonID==PersonID[_n+1] & Year!=Year[_n+1]-1 & EMP_TIME==EMP_TIME[_n+1]
	tab NY_MISS
	label variable NY_MISS "Missing Observation Next Year Dummy"

	* 22.10 Create missing prior year observation (N-1 = same management level) and missing prior year observation (N-1 = different management level) dummy variables 
	gen MISS_PY_ATL=1 if NY_MISS[_n-1]==1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1] & MGMTLEVEL==MGMTLEVEL[_n-1] 
	label variable MISS_PY_ATL "Missing Prior Year Observation (N-1 = Same Mgmt Level) Dummy"

	sort PersonID Year
	gen MISS_PY_ADL=1 if NY_MISS[_n-1]==1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1] & MGMTLEVEL!=MGMTLEVEL[_n-1] 
	label variable MISS_PY_ADL "Missing Prior Year Observation (N-1 = Different Mgmt Level) Dummy"
	
	* 22.11 Create MIN_EY = year of the earliest Entrydate_ORIG by PersonID & EMP_TIME
	sort PersonID EMP_TIME
	by PersonID EMP_TIME: egen MIN_ENTRY=min(Entrydate_ORIG)
	gen MIN_EY=year(MIN_ENTRY)

	* 22.12 Create promotion this year, promotion last year, demotion this year, and demotion last year variables
	* > Promotion this year
	* First, fill using PROM_NY variable, then proceed as seems appropriate
	sort PersonID Year
	by PersonID: gen PROM_TY=0 if PROM_NY[_n-1]==0 & PersonID==PersonID[_n-1] & Year==Year[_n-1]+1 & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace PROM_TY=1 if PROM_NY[_n-1]==1 & PersonID==PersonID[_n-1] & Year==Year[_n-1]+1 & EMP_TIME==EMP_TIME[_n-1]
	replace PROM_TY=0 if PROM_TY==. & ENTRYDATE==CURRENTMLDATE & year(ENTRYDATE)==Year
	* > If entrydate = currentmldate, then external hire not promotion
	replace PROM_TY=1 if PROM_TY==. & year(CURRENTMLDATE)==Year & year(ENTRYDATE)<year(CURRENTMLDATE) & Year==2008 & MGMTLEVEL=="ML 5"
	* > Assume if became ML5 in 2008 it was an internal promotion from a non-manager level 
	replace PROM_TY=1 if PROM_TY==. & year(CURRENTMLDATE)==Year & year(ENTRYDATE)<year(CURRENTMLDATE) & Year==2008 & MGMTLEVEL!=""
	* > Assume if became this management level in 2008 and entered company prior to 2008, that it was an internal promotion 
	replace PROM_TY=1 if PROM_TY==. & year(CURRENTMLDATE)==Year & year(ENTRYDATE)<year(CURRENTMLDATE) & Year!=2008 & OBS==1 & MGMTLEVEL=="ML 5"
	* > Assume if became ML5 this year, and first observation, that was promoted internally to ML5
	replace PROM_TY=1 if PROM_TY==. & year(CURRENTMLDATE)==Year & year(ENTRYDATE)<year(CURRENTMLDATE) & Year!=2008 & N_OBS==1 & EMP_TIME==2 & MGMTLEVEL=="ML 5"
	* > Assume if became ML5 this year, and first observation in EMP_TIME=2, was promoted internally to ML5
	replace PROM_TY=1 if PROM_TY==. & year(CURRENTMLDATE)==Year & year(ENTRYDATE)<year(CURRENTMLDATE) & Year!=2008 & OBS==1 & MGMTLEVEL=="ML 4"
	* > Assume if became ML4 this year, and first observation, that was promoted internally to ML4
	replace PROM_TY=1 if PROM_TY==. & year(CURRENTMLDATE)==Year & year(ENTRYDATE)<year(CURRENTMLDATE) & MGMTLEVEL!="" & OBS==1
	* > Assume if first observation and became this management level this year, and joined company prior to this year, that it was a promotion
	replace PROM_TY=0 if PROM_TY==. & year(CURRENTMLDATE)<Year & MGMTLEVEL!=""
	* > No promotion if most recent observation pertains to same management level)
	replace PROM_TY=0 if PROM_TY==. & CURRENTMLDATE==. & PROM_TY==. & MGMTLEVEL!="" & OBS!=1 & MISS_PY_ATL==1 
	* > Assume promoted this year if hired last year and promoted this year variable is blank
	replace PROM_TY=1 if year(CURRENTMLDATE)==Year & year(ENTRYDATE)==Year-1 & PROM_TY==.
	* > Most recent observation was at a different management level, but occurs > Year-1 ago, and at a new management level this year => pick up as promotion where more senior management level
	sort PersonID Year
	by PersonID: replace PROM_TY=1 if year(CURRENTMLDATE)>year(ENTRYDATE) & Year==year(CURRENTMLDATE) & PROM_TY==. & MGMTLEVEL!="" & OBS!=1 & MISS_PY_ADL==1 & ((MGMTLEVEL=="ML 4" & MGMTLEVEL[_n-1]=="ML 5") | (MGMTLEVEL=="ML 3" & (MGMTLEVEL[_n-1]=="ML 4" | MGMTLEVEL[_n-1]=="ML 5")) | (MGMTLEVEL=="ML 2" & MGMTLEVEL[_n-1]=="ML 3") | (MGMTLEVEL=="ML 1" & MGMTLEVEL[_n-1]=="ML 2"))
	replace PROM_TY=1 if PROM_TY==. & year(CURRENTMLDATE)==Year & MIN_EY<year(CURRENTMLDATE) & MGMTLEVEL!="" & OBS==1 & EMP_TIME==1
	* > Assume just timing difference in recording dates rather than a promotion if year of entry date is same as year of management level date 
	replace PROM_TY=0 if PROM_TY==. & year(CURRENTMLDATE)==year(ENTRYDATE) & year(ENTRYDATE)==Year
	label variable PROM_TY "Promoted This Year Dummy"
	tab PROM_TY 

	* > Demotion this year
	* First, fill using DEM_NY variable, then proceed as seems appropriate
	sort PersonID Year
	by PersonID: gen DEM_TY=0 if DEM_NY[_n-1]==0 & PersonID==PersonID[_n-1] & Year==Year[_n-1]+1 & EMP_TIME==EMP_TIME[_n-1]
	by PersonID: replace DEM_TY=1 if DEM_NY[_n-1]==1 & PersonID==PersonID[_n-1] & Year==Year[_n-1]+1 & EMP_TIME==EMP_TIME[_n-1]
	sort PersonID Year
	by PersonID: replace DEM_TY=1 if year(CURRENTMLDATE)>year(ENTRYDATE) & Year==year(CURRENTMLDATE) & DEM_TY==. & MGMTLEVEL!="" & OBS!=1 & MISS_PY_ADL==1 & ((MGMTLEVEL=="ML 5" & (MGMTLEVEL[_n-1]=="ML 4" | MGMTLEVEL[_n-1]=="ML 3")) | ((MGMTLEVEL=="ML 4" & (MGMTLEVEL[_n-1]=="ML 3" | MGMTLEVEL[_n-1]=="ML 2"))))
	replace DEM_TY=0 if DEM_TY==. & ENTRYDATE==CURRENTMLDATE & year(ENTRYDATE)==Year
	replace DEM_TY=0 if DEM_TY==. & year(CURRENTMLDATE)<Year & MGMTLEVEL!=""
	replace DEM_TY=0 if DEM_TY==. & CURRENTMLDATE==. & DEM_TY==. & MGMTLEVEL!="" & OBS!=1 & MISS_PY_ATL==1 
	replace DEM_TY=0 if DEM_TY==. & PROM_TY==1
	replace DEM_TY=0 if DEM_TY==. & year(CURRENTMLDATE)==year(ENTRYDATE) & year(ENTRYDATE)==Year
	label variable DEM_TY "Demoted This Year Dummy"
	tab DEM_TY 

	replace PROM_TY=0 if DEM_TY==1 & PROM_TY==.

	* > Promotion last year 
	sort PersonID Year
	by PersonID: gen PROM_LY=0 if PROM_TY[_n-1]==0 & PersonID==PersonID[_n-1] & Year==Year[_n-1]+1 & EMP_TIME==EMP_TIME[_n-1] 
	by PersonID: replace PROM_LY=1 if PROM_TY[_n-1]==1 & PersonID==PersonID[_n-1] & Year==Year[_n-1]+1 & EMP_TIME==EMP_TIME[_n-1] 
	label variable PROM_LY "Promoted Last Year Dummy"  

	* > Demotion last year 
	sort PersonID Year
	by PersonID: gen DEM_LY=0 if DEM_TY[_n-1]==0 & PersonID==PersonID[_n-1] & Year==Year[_n-1]+1 & EMP_TIME==EMP_TIME[_n-1] & PersonID==PersonID[_n-1]
	by PersonID: replace DEM_LY=1 if DEM_TY[_n-1]==1 & PersonID==PersonID[_n-1] & Year==Year[_n-1]+1 & EMP_TIME==EMP_TIME[_n-1] & PersonID==PersonID[_n-1]
	label variable DEM_LY "Demoted Last Year Dummy"

	* 22.13 Replace PERF_NUM_PY and POT_NUM_PY with missing if EMP_TIME==2 & N_OBS=1 (i.e. disregard prior year rating if this is the first year for an employee who left & returned)
	replace PERF_NUM_PY=. if EMP_TIME==2 & N_OBS==1
	replace POT_NUM_PY=. if EMP_TIME==2 & N_OBS==1

	* 22.14 Drop 2015 observations
	drop if Year==2015
	
	unique PersonID
	*** OBSERVATION COUNT = 68,678 (number of unique values of PersonID = 16732) => initial sample in paper ***

	* 22.15 Create dummy variable, POT_DROP, = 1 if potential rating is lower this year compared to last year (= 0 if same or lower rating last year)
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: gen POT_DROP=1 if POT_YE[_n-1]=="1" & (POT_YE=="2" | POT_YE=="3" | POT_YE=="4") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_DROP=1 if POT_YE[_n-1]=="2" & (POT_YE=="3" | POT_YE=="4") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_DROP=1 if POT_YE[_n-1]=="3" & POT_YE=="4" & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_DROP=0 if POT_YE[_n-1]=="1" & POT_YE=="1" & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_DROP=0 if POT_YE[_n-1]=="2" & (POT_YE=="2" | POT_YE=="1") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_DROP=0 if POT_YE[_n-1]=="3" & (POT_YE=="3" | POT_YE=="2" | POT_YE=="1") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_DROP=0 if POT_YE[_n-1]=="4" & (POT_YE=="4" | POT_YE=="3" | POT_YE=="2" | POT_YE=="1") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	tab POT_DROP
	label variable POT_DROP "Drop in Potential Rating This Year Dummy (Compared to Last Year)"

	* 22.16 Create dummy variable, PERF_DROP, = 1 if performance rating is lower this year compared to last year (= 0 if same or lower rating last year)
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: gen PERF_DROP=1 if PERF_YE[_n-1]=="T" & (PERF_YE=="S" | PERF_YE=="M" | PERF_YE=="L") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_DROP=1 if PERF_YE[_n-1]=="S" & (PERF_YE=="M" | PERF_YE=="L") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_DROP=1 if PERF_YE[_n-1]=="M" & PERF_YE=="L" & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_DROP=0 if PERF_YE[_n-1]=="T" & PERF_YE=="T" & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_DROP=0 if PERF_YE[_n-1]=="S" & (PERF_YE=="S" | PERF_YE=="T") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_DROP=0 if PERF_YE[_n-1]=="M" & (PERF_YE=="M" | PERF_YE=="S" | PERF_YE=="T") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_DROP=0 if PERF_YE[_n-1]=="L" & (PERF_YE=="L" | PERF_YE=="M" | PERF_YE=="S" | PERF_YE=="T") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	tab PERF_DROP
	label variable PERF_DROP "Drop in Performance Rating This Year Dummy (Compared to Last Year)"

	* 22.17 Create dummy variable POT_INC, = 1 if potential rating is higher this year compared to last year (= 0 if same or higher rating last year)
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: gen POT_INC=1 if POT_YE[_n-1]=="4" & (POT_YE=="3" | POT_YE=="2" | POT_YE=="1") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_INC=1 if POT_YE[_n-1]=="3" & (POT_YE=="2" | POT_YE=="1") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_INC=1 if POT_YE[_n-1]=="2" & POT_YE=="1" & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_INC=0 if POT_YE[_n-1]=="4" & POT_YE=="4" & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_INC=0 if POT_YE[_n-1]=="3" & (POT_YE=="3" | POT_YE=="4") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_INC=0 if POT_YE[_n-1]=="2" & (POT_YE=="2" | POT_YE=="3" | POT_YE=="4") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace POT_INC=0 if POT_YE[_n-1]=="1" & (POT_YE=="1" | POT_YE=="2" | POT_YE=="3" | POT_YE=="4") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	tab POT_INC
	label variable POT_INC "Increase in Potential Rating This Year Dummy (Compared to Last Year)"

	* 22.18 Create dummy variable PERF_INC, = 1 if performance rating is higher this year compared to last year (= 0 if same or higher rating last year)
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: gen PERF_INC=1 if PERF_YE[_n-1]=="L" & (PERF_YE=="M" | PERF_YE=="S" | PERF_YE=="T") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_INC=1 if PERF_YE[_n-1]=="M" & (PERF_YE=="S" | PERF_YE=="T") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_INC=1 if PERF_YE[_n-1]=="S" & PERF_YE=="T" & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_INC=0 if PERF_YE[_n-1]=="L" & PERF_YE=="L" & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_INC=0 if PERF_YE[_n-1]=="M" & (PERF_YE=="M" | PERF_YE=="L") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_INC=0 if PERF_YE[_n-1]=="S" & (PERF_YE=="S" | PERF_YE=="M" | PERF_YE=="L") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	by PersonID EMP_TIME: replace PERF_INC=0 if PERF_YE[_n-1]=="T" & (PERF_YE=="T" | PERF_YE=="S" | PERF_YE=="M" | PERF_YE=="L") & Year==Year[_n-1]+1 & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1]
	tab PERF_INC
	label variable PERF_INC "Increase in Performance Rating This Year Dummy (Compared to Last Year)"

	* 22.19 Create continuous performance and potential variables, PERF_ORDER and POT_ORDER 
	gen PERF_ORDER=0 if PERF_YE!=""
	replace PERF_ORDER=1 if PERF_YE=="L"
	replace PERF_ORDER=2 if PERF_YE=="M"
	replace PERF_ORDER=3 if PERF_YE=="S"
	replace PERF_ORDER=4 if PERF_YE=="T"
	label define PERF_ORDER 1 "L" 2 "M" 3 "S" 4 "T"
	label values PERF_ORDER PERF_ORDER
	label list PERF_ORDER
	tab PERF_ORDER PERF_YE
	label variable PERF_ORDER "Year End Performance Ordinal Value (T=4)"

	gen POT_ORDER=0 if POT_YE!=""
	replace POT_ORDER=1 if POT_YE=="4"
	replace POT_ORDER=2 if POT_YE=="3"
	replace POT_ORDER=3 if POT_YE=="2"
	replace POT_ORDER=4 if POT_YE=="1"
	label define POT_ORDER 1 "Well placed" 2 "Horizontal" 3 "Vertical - 1 level" 4 "Vertical - 2 levels"
	label values POT_ORDER POT_ORDER
	label list POT_ORDER
	tab POT_ORDER POT_YE
	label variable POT_ORDER "Year End Potential Rating Ordinal Value (2 levels=4)"
	
	* 22.20 Create dummy variable for whether employee changed supervisor between last year and this year (= 0 if same supervisor this year and last year, and not missing)
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: gen CHGD_MGR=1 if SupervisorID!="" & SupervisorID!=SupervisorID[_n-1] & SupervisorID[_n-1]!="" & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1] & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace CHGD_MGR=0 if SupervisorID!="" & SupervisorID==SupervisorID[_n-1] & SupervisorID[_n-1]!="" & PersonID==PersonID[_n-1] & EMP_TIME==EMP_TIME[_n-1] & Year==Year[_n-1]+1 
	tab CHGD_MGR
	label variable CHGD_MGR "Change in Manager From Last Year to This Year Dummy"

	* 22.21 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v2.dta", replace
	clear

**************************************************************************************************************************************************************************************************************************
* PROGRAM 23: Create Manager Characteristics Variables
* Input files: "Analysis_Data_v2.dta"; "Interim ML0 Append 5.dta"; "ML 0  data 2015_Annonymized_no password.dta"
* Steps:
	* 23.1 Append ML0 data files
	* 23.2 Rename Country variable to COUNTRYWORK,and update any country names to ensure consistency 	
	* 23.3 Rename variables
	* 23.4 Create current management level data variable
	* 23.5 For ML0s whose CURRENTMLDATE<=2008, assume the same employment details in 2008 & 2009 (since don't have 2008 details) and create 2008 observations
	* 23.6 Identify any instances where there is more than one observation for a year for a PersonID and deal with as seems most appropriate to yield one observation per person per year 
	* 23.7 Save interim file
	* 23.8 Append current analysis data file and interim ML0 file saved above
	* 23.9 Drop SupervisorID variable, rename PersonID SupervisorID and rename variables of interest with a preceding MGR_
	* 23.10 Keep only variables of interest and then save interim file (manager variables file)
	* 23.11 Open current analysis data file, rename SupervisorID SupervisorID_beforereplace, create new SupervisorID variable and set = to SupervisorID_beforereplace and where SupervisorID is missing, replace with PPA_Supervisor_TY (to lose fewer observations due to missing SupervisorID)
	* 23.12 Merge file, using SupervisorID and Year, with interim manager variables file saved above
	* 23.13 Replace SupervisorID with PPA_Supervisor_TY, if the existing SupervisorID was not matched in the above merge procedure  
	* 23.14 Again, merge file, using SupervisorID and Year, with interim manager variables file saved above
	* 23.15 Save interim file
	* 23.16 Tab MGMTLEVEL and MGR_MGMTLEVEL and create a dummy variable, MGR_LESS_SENIOR, = 1 if an employee's manager is at a management level level less senior than their own level
	* 23.17 Set SupervisorID to missing where MGR_LESS_SENIOR=1 (seems likely to be inaccurate)
	* 23.18 Save output file
	* 23.19 Remove files no longer needed
* Output file: "Analysis_Data_Prepared.dta"
**************************************************************************************************************************************************************************************************************************

	* 23.1 Append ML0 data files
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Interim ML0 Append 5.dta"
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML 0  data 2015_Annonymized_no password.dta"
	
	* 23.2 Rename Country variable to COUNTRYWORK,and update any country names to ensure consistency 
	tab Country
	rename Country COUNTRYWORK
	replace COUNTRYWORK="Country 73" if COUNTRYWORK=="Country 73-variant"
	replace COUNTRYWORK="Country 76" if COUNTRYWORK=="Country 76-variant"
	tab COUNTRYWORK
	
	* 23.3 Rename variables
	rename ML_Year Year
	rename PersonIDCP PersonID
	
	* 23.4 Create current management level data variable
	tab PromotionDateML0
	generate Beg_ML0=date(PromotionDateML0,"DMY")
	format Beg_ML0 %tdnn/dd/CCYY
	tab Beg_ML0
	rename Beg_ML0 CURRENTMLDATE
	drop PromotionDateML0
	
	* 23.5 For ML0s whose CURRENTMLDATE<=2008, assume the same employment details in 2008 & 2009 (since don't have 2008 details) and create 2008 observations
	gen ML0_2008=1 if year(CURRENTMLDATE)<=2008
	replace ML0_2008=0 if year(CURRENTMLDATE)>2008 & CURRENTMLDATE!=.
	tab ML0_2008
	* > Assume same employment data for 2008 as 2009
	expand 2 if Year==2009 & ML0_2008==1
	sort PersonID Year
	by PersonID Year: gen OBS=_n
	replace Year=2008 if OBS==1 & Year==2009 & ML0_2008==1
	drop OBS

	* 23.6 Identify any instances where there is more than one observation for a year for a PersonID and deal with as seems most appropriate to yield one observation per person per year 
	sort PersonID Year
	by PersonID Year: gen OBS=_n
	tab PersonID Year if OBS>1
	drop if PersonID=="9759" & (Year==2012 | Year==2013 | Year==2014 | Year==2015) & COUNTRYWORK=="Country 12"
	drop if PersonID=="12767" & (Year==2012 | Year==2013 | Year==2014 | Year==2015) & COUNTRYWORK!="Country 73"
	drop OBS

	* 23.7 Save interim file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML0_Data_TEMP.dta", replace

	* 23.8 Append current analysis data file and interim ML0 file saved above
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v2.dta"
	drop _merge
	append using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML0_Data_TEMP.dta"

	* 23.9 Drop SupervisorID variable, rename PersonID SupervisorID and rename variables of interest with a preceding MGR_
	drop SupervisorID
	rename PersonID SupervisorID
	rename MGMTLEVEL MGR_MGMTLEVEL

	* 23.10 Keep only variables of interest and then save interim file (manager variables file)
	keep SupervisorID Year MGR_MGMTLEVEL 
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/MgrData_TEMP.dta", replace

	* 23.11 Open current analysis data file, rename SupervisorID SupervisorID_beforereplace, create new SupervisorID variable and set = to SupervisorID_beforereplace and where SupervisorID is missing, replace with PPA_Supervisor_TY (to lose fewer observations due to missing SupervisorID)
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v2.dta"
	drop _merge
	rename SupervisorID SupervisorID_beforereplace
	gen SupervisorID=SupervisorID_beforereplace
	* > If SupervisorID is missing, replace with PPA_Supervisor_TY (supervisor for the performance evaluation cycle for this year) (better than leaving SupervisorID missing)
	replace SupervisorID=PPA_Supervisor_TY if SupervisorID==""

	* 23.12 Merge file, using SupervisorID and Year, with interim manager variables file saved above
	merge m:1 SupervisorID Year using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/MgrData_TEMP.dta" 
	drop if _merge==2
	rename _merge _mergeFIRST

	* 23.13 Replace SupervisorID with PPA_Supervisor_TY, if the existing SupervisorID was not matched in the above merge procedure  
	replace SupervisorID=PPA_Supervisor_TY if _mergeFIRST==1 & PPA_Supervisor_TY!=""
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v3.dta",replace

	* 23.14 Again, merge file, using SupervisorID and Year, with interim manager variables file saved above
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v3.dta"
	sort PersonID Year
	merge m:1 SupervisorID Year using "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/MgrData_TEMP.dta" 
	drop if _merge==2
	rename _merge _mergeSECOND
	
	* 23.15 Save interim file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v4.dta",replace
	clear
	use "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v4.dta"

	* 23.16 Tab MGMTLEVEL and MGR_MGMTLEVEL and create a dummy variable, MGR_LESS_SENIOR, = 1 if an employee's manager is at a management level less senior than their own level
	tab MGMTLEVEL MGR_MGMTLEVEL
	gen MGR_LESS_SENIOR=0 if MGR_MGMTLEVEL!=""
	replace MGR_LESS_SENIOR=1 if MGMTLEVEL=="ML 1" & (MGR_MGMTLEVEL=="ML 2" | MGR_MGMTLEVEL=="ML 3" | MGR_MGMTLEVEL=="ML 4" | MGR_MGMTLEVEL=="ML 5")
	replace MGR_LESS_SENIOR=1 if MGMTLEVEL=="ML 2" & (MGR_MGMTLEVEL=="ML 3" | MGR_MGMTLEVEL=="ML 4" | MGR_MGMTLEVEL=="ML 5")
	replace MGR_LESS_SENIOR=1 if MGMTLEVEL=="ML 3" & (MGR_MGMTLEVEL=="ML 4" | MGR_MGMTLEVEL=="ML 5")
	replace MGR_LESS_SENIOR=1 if MGMTLEVEL=="ML 4" & MGR_MGMTLEVEL=="ML 5"
	tab MGR_LESS_SENIOR

	* 23.17 Set SupervisorID to missing where MGR_LESS_SENIOR=1 (seems likely to be inaccurate)
	replace SupervisorID="" if MGR_LESS_SENIOR==1

	* 23.18 Save output file
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_Prepared.dta",replace
	clear

	* 23.19 Remove files no longer needed
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v1.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v2.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v3.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_v4.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/ML0_Data_TEMP.dta"
	rm "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/MgrData_TEMP.dta" 

**************************************************************************************************************************************************************************************************************************
* PROGRAM 24: Final Preparations Before Analyses
* Input files: "Analysis_Data_Prepared.dta"
* Steps:
	* 24.1 Read in data file
	* 24.2 Tell Stata it's panel data
	* 24.3 Replace Supervisor ID with missing if SupervisorID = .
	* 24.4 Create count of observations within country variable; all years and each year individually 
	* 24.5 Create count of observations within function variable; all years and each year individually
	* 24.6 Create perf/pot indicator variable for analyses -- all possible combinations of performance and potential
	* 24.7 Create promotion and demotion variables for additional analyses to capture if employees who exited were promoted or demoted in the year of exit
	* 24.8 Create supervisor high rater indicator variable for subsample analysis (require supervisor to have given at least three ratings in the year)
	* 24.9 Create indicator for including country in sample (require at least 25 observations in 2008 and an average of at least 25 per year (so 25 x 7 = minimum of 175 obs))
	* 24.10 Drop second spell for any employees who left and returned to company during my sample period 	
	* 24.11 Drop current year observation where the employee exited on last day of the current year  
	* 24.12 Employees become "at risk" of departure for the purposes of my analyses once they receive a valid performance/potential rating, so drop any observations for an employee prior to that time
	* 24.13 Count observations available for analyses imposing minimum count requirements and data availability for control variables
	* 24.14 Recreate observation number variable		
	* 24.15 Set up dates for survival analysis (date 1 is exit one year later, date 2 is specific exit date)	
	* 24.16 Create rating variables
	* 24.17 Create NONPROMSTRETCH variable - sequential observations have the same NONPROMSTRETCH value for the period where an employee is not promoted, once employee is promoted the value of the variable increases by 1 compared to the prior observation
	* 24.18 Create HIPOPROM_SEQ variable - number of times in a row the employee has received a "HIPO" (T1, T2 or S1) rating without being promoted
	* 24.19 Populate HIPOPROM_SEQ variable for non-HiPo ratings 	
	* 24.20 Save final file for analyses
* Output file: "Analysis_Data_FINAL.dta"
**************************************************************************************************************************************************************************************************************************
	
	* 24.1 Read in data file
	clear
	use"/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_Prepared.dta"
	
	* 24.2 Tell Stata it's panel data
	encode PersonID, gen(id)
	xtset id Year

	* 24.3 Replace Supervisor ID with missing if SupervisorID = .
	replace SupervisorID="" if SupervisorID=="."

	* 24.4 Create count of observations within country variable; all years and each year individually 
	sort COUNTRYWORK
	by COUNTRYWORK: egen C_COUNTRYWORK=count(COUNTRYWORK)
	sort Year COUNTRYWORK
	by Year COUNTRYWORK: egen CYR_COUNTRYWORK=count(COUNTRYWORK)

	* 24.5 Create count of observations within function variable; all years and each year individually
	sort FUNCTION
	by FUNCTION: egen C_FUNCTION=count(FUNCTION)
	sort Year FUNCTION
	by Year FUNCTION: egen CYR_FUNCTION=count(FUNCTION) 

	* 24.6 Create perf/pot indicator variable for analyses -- all possible combinations of performance and potential
	gen GRP_NUM=1 if POT_YE=="1" & PERF_YE=="T"
	replace GRP_NUM=2 if POT_YE=="2" & PERF_YE=="T"
	replace GRP_NUM=3 if POT_YE=="3" & PERF_YE=="T"
	replace GRP_NUM=4 if POT_YE=="4" & PERF_YE=="T"
	replace GRP_NUM=5 if POT_YE=="1" & PERF_YE=="S"
	replace GRP_NUM=6 if POT_YE=="2" & PERF_YE=="S"
	replace GRP_NUM=7 if POT_YE=="3" & PERF_YE=="S"
	replace GRP_NUM=8 if POT_YE=="4" & PERF_YE=="S"
	replace GRP_NUM=9 if POT_YE=="1" & PERF_YE=="M"
	replace GRP_NUM=10 if POT_YE=="2" & PERF_YE=="M"
	replace GRP_NUM=11 if POT_YE=="3" & PERF_YE=="M"
	replace GRP_NUM=12 if POT_YE=="4" & PERF_YE=="M"
	replace GRP_NUM=13 if POT_YE=="4" & PERF_YE=="L"
		
	tab GRP_NUM
	label define GRP_NUM 1 "Vertical Potential 2, T" 2 "Vertical Potential 1, T" 3 "Horizontal, T" 4 "Well Placed, T" 5 "Vertical Potential 2, S" 6 "Vertical Potential 1, S" 7 "Horizontal, S" 8 "Well Placed, S" 9 "Vertical Potential 2, M" 10 "Vertical Potential 1, M" 11 "Horizontal, M" 12 "Well Placed, M" 13 "Clearly Below"
	label values GRP_NUM GRP_NUM
	label list GRP_NUM
	tab GRP_NUM
	
	* 24.7 Create promotion and demotion variables for additional analyses to capture if employees who exited were promoted or demoted in the year of exit
	gen PROM_BEXIT=1 if (EXIT_VOL==1 | EXIT_INVOL==1) & ((MGMTLEVEL=="ML 5" & MgmtLevel_EXIT=="ML 4") | (MGMTLEVEL=="ML 4" & MgmtLevel_EXIT=="ML 3") | (MGMTLEVEL=="ML 3" & MgmtLevel_EXIT=="ML 2") | (MGMTLEVEL=="ML 2" & MgmtLevel_EXIT=="ML 1"))
	gen DEM_BEXIT=1 if (EXIT_VOL==1 | EXIT_INVOL==1) & ((MGMTLEVEL=="ML 1" & MgmtLevel_EXIT=="ML 2") | (MGMTLEVEL=="ML 2" & MgmtLevel_EXIT=="ML 3") | (MGMTLEVEL=="ML 3" & MgmtLevel_EXIT=="ML 4") | (MGMTLEVEL=="ML 4" & MgmtLevel_EXIT=="ML 5"))	
	replace PROM_BEXIT=0 if DEM_BEXIT==1
	replace PROM_BEXIT=0 if (EXIT_VOL==1 | EXIT_INVOL==1) & MGMTLEVEL==MgmtLevel_EXIT	
	replace DEM_BEXIT=0 if PROM_BEXIT==1
	replace DEM_BEXIT=0 if (EXIT_VOL==1 | EXIT_INVOL==1) & MGMTLEVEL==MgmtLevel_EXIT
	replace PROM_BEXIT=0 if (EXIT_VOL==1 | EXIT_INVOL==1) & (MGMTLEVEL=="ML 4" | MGMTLEVEL=="ML 5") & MgmtLevel_EXIT=="ML Z" // assume same management level for those with management level no longer in use if management level is ML 4 or ML 5
	replace DEM_BEXIT=0 if (EXIT_VOL==1 | EXIT_INVOL==1) & (MGMTLEVEL=="ML 4" | MGMTLEVEL=="ML 5") & MgmtLevel_EXIT=="ML Z" // assume same management level for those with management level no longer in use if management level is ML 4 or ML 5
	replace PROM_BEXIT=2 if (EXIT_VOL==1 | EXIT_INVOL==1) & MgmtLevel_EXIT==""
	replace DEM_BEXIT=2 if (EXIT_VOL==1 | EXIT_INVOL==1) & MgmtLevel_EXIT==""
	replace DEM_BEXIT=1 if (EXIT_VOL==1 | EXIT_VOL==0) & (MGMTLEVEL=="ML 3" & MgmtLevel_EXIT=="ML 5") 
	replace PROM_BEXIT=0 if (EXIT_VOL==1 | EXIT_VOL==0) & (MGMTLEVEL=="ML 3" & MgmtLevel_EXIT=="ML 5") 
	replace PROM_BEXIT=PROM_NY if PROM_NY!=. & PROM_BEXIT==2 & (EXIT_VOL==1 | EXIT_INVOL==1)
	replace DEM_BEXIT=DEM_NY if DEM_NY!=. & DEM_BEXIT==2 & (EXIT_VOL==1 | EXIT_INVOL==1)
	
	gen PROM_REG=PROM_NY
	replace PROM_REG=0 if PROM_REG==. & PROM_BEXIT==0
	replace PROM_REG=1 if PROM_REG==. & PROM_BEXIT==1
	
	gen DEM_REG=DEM_NY
	replace DEM_REG=0 if DEM_REG==. & DEM_BEXIT==0
	replace DEM_REG=1 if DEM_REG==. & DEM_BEXIT==1
	
	* 24.8 Create supervisor high rater indicator variable for subsample analysis (require supervisor to have given at least three ratings in the year)
	gen PERF_VALID=1 if PERF_NUM!=.
	sort SupervisorID Year PERF_VALID
	by SupervisorID Year PERF_VALID: gen SUP_VAR_YEAR=_N
	replace SUP_VAR_YEAR=. if PERF_VALID!=1
	replace SUP_VAR_YEAR=. if SupervisorID==""

	sort SupervisorID Year PERF_VALID
	by SupervisorID Year PERF_VALID: egen AVG_EMP_PERF_ORD = mean(PERF_ORD)
	by SupervisorID Year PERF_VALID: gen SUPOBS = _n
	replace SUPOBS=. if PERF_VALID!=1
	sum AVG_EMP_PERF_ORD if SUPOBS==1 & SUP_VAR_YEAR>=3 & SUP_VAR_YEAR!=., detail
	* >> median is 2.8 
	
	sort SupervisorID Year PERF_VALID
	by SupervisorID Year PERF_VALID: egen AVG_EMP_POT_ORD = mean(POT_ORD)
	sum AVG_EMP_POT_ORD if SUPOBS==1 & SUP_VAR_YEAR>=3 & SUP_VAR_YEAR!=., detail
	* >> median is 2
		
	gen HIGH_RATE=0 if (AVG_EMP_PERF_ORD<2.8 | AVG_EMP_POT_ORD<2) & SUP_VAR_YEAR>=3 & SUP_VAR_YEAR!=.
	replace HIGH_RATE=1 if AVG_EMP_PERF_ORD>=2.8 & AVG_EMP_POT_ORD>=2 & AVG_EMP_PERF_ORD!=. & AVG_EMP_POT_ORD!=. & SUP_VAR_YEAR>=3 & SUP_VAR_YEAR!=.
	tab HIGH_RATE

	* 24.9 Create indicator for including country in sample (require at least 25 observations in 2008 and an average of at least 25 per year (so 25 x 7 = minimum of 175 obs))
	gen in_c25=1 if CYR_COUNTRYWORK>=25 & Year==2008
	sort COUNTRYWORK
	by COUNTRYWORK: egen COUNTRY_INCL25=max(in_c25)
	tab COUNTRYWORK if COUNTRY_INCL25==1
	gen COUNTRY_INSAMPLE=1 if COUNTRY_INCL25==1 & C_COUNTRYWORK>=175 & C_COUNTRYWORK!=.
	
	* 24.10 Drop second spell for any employees who left and returned to company during my sample period 	
	drop if EMP_TIME==2

	* 24.11 Drop current year observation where the employee exited on last day of the current year  
	sort PersonID Year
	by PersonID: gen VOL_LY=1 if EXIT_VOL[_n-1]==1 & PersonID==PersonID[_n-1] 
	drop if VOL_LY==1
	
	sort PersonID Year
	by PersonID: gen EXIT_LY_NOTVOL=1 if EXIT_NY[_n-1]==1 & EXIT_VOL[_n-1]!=1 & PersonID==PersonID[_n-1] 
	drop if EXIT_LY_NOTVOL==1 
	
	tab EXIT_DATE_USE if Year==year(EXIT_DATE_USE)
	* > these all pertain to employees that either have only this one observation OR they do not have an observation for the year prior to the exit year
	drop if Year==year(EXIT_DATE_USE) 
	
	* 24.12 Employees become "at risk" of departure for the purposes of my analyses once they receive a valid performance/potential rating, so drop any observations for an employee prior to that time
	drop N_OBS
	sort PersonID Year
	by PersonID: gen N_OBS=_n
	sort PersonID Year
	by PersonID: egen NOM=max(N_OBS)
	label variable NOM "Maximum Observation Number" 
	
	gen NEW_FIRST_RATE=1 if PERF_YE!="" & POT_YE!="" & N_OBS==1 
	sort PersonID EMP_TIME
	by PersonID EMP_TIME: egen NEW_RATE_CT=sum(NEW_FIRST_RATE)
	tab NEW_RATE_CT	
	replace NEW_FIRST_RATE=1 if PERF_YE!="" & POT_YE!="" & NEW_RATE_CT==0 & N_OBS==2 
	drop NEW_RATE_CT
	sort PersonID EMP_TIME
	by PersonID EMP_TIME: egen NEW_RATE_CT=sum(NEW_FIRST_RATE)
	tab NEW_RATE_CT	
	replace NEW_FIRST_RATE=1 if PERF_YE!="" & POT_YE!="" & NEW_RATE_CT==0 & N_OBS==3 
	drop NEW_RATE_CT
	sort PersonID EMP_TIME
	by PersonID EMP_TIME: egen NEW_RATE_CT=sum(NEW_FIRST_RATE)
	tab NEW_RATE_CT	
	replace NEW_FIRST_RATE=1 if PERF_YE!="" & POT_YE!="" & NEW_RATE_CT==0 & N_OBS==4 
	drop NEW_RATE_CT
	sort PersonID EMP_TIME
	by PersonID EMP_TIME: egen NEW_RATE_CT=sum(NEW_FIRST_RATE)
	tab NEW_RATE_CT	
	replace NEW_FIRST_RATE=1 if PERF_YE!="" & POT_YE!="" & NEW_RATE_CT==0 & N_OBS==5 
	drop NEW_RATE_CT
	sort PersonID EMP_TIME
	by PersonID EMP_TIME: egen NEW_RATE_CT=sum(NEW_FIRST_RATE)
	tab NEW_RATE_CT	
	replace NEW_FIRST_RATE=1 if PERF_YE!="" & POT_YE!="" & NEW_RATE_CT==0 & N_OBS==6 
	drop NEW_RATE_CT
	sort PersonID EMP_TIME
	by PersonID EMP_TIME: egen NEW_RATE_CT=sum(NEW_FIRST_RATE)
	tab NEW_RATE_CT	
	replace NEW_FIRST_RATE=1 if PERF_YE!="" & POT_YE!="" & NEW_RATE_CT==0 & N_OBS==7 
	drop NEW_RATE_CT
	sort PersonID EMP_TIME
	by PersonID EMP_TIME: egen NEW_RATE_CT=sum(NEW_FIRST_RATE)
	tab NEW_RATE_CT
	
	gen first_rating_year=Year if NEW_FIRST_RATE==1
	sort PersonID Year
	by PersonID: egen m_first_rating_year=max(first_rating_year)
	drop if Year<m_first_rating_year 
	
	unique PersonID
	*** OBSERVATION COUNT = 64,494  => count in paper ***
	
	* 24.13 Count observations available for analyses imposing minimum count requirements and data availability for control variables
	count if COUNTRY_INSAMPLE==1 & CYR_FUNCTION>=20 & CYR_FUNCTION!=. & MALE!=. & AGE!=. & COY_TENURE!=. & FULLTIME!=. & EXPAT!=. & BU_reg!=. & ML_reg!=. & FUNCTION_reg!=. & COUNTRY_reg!=. & Year!=.
	* OBSERVATION COUNT = 59,435
	count if PERF_YE!="" & COUNTRY_INSAMPLE==1 & CYR_FUNCTION>=20 & CYR_FUNCTION!=. & MALE!=. & AGE!=. & COY_TENURE!=. & FULLTIME!=. & EXPAT!=. & BU_reg!=. & ML_reg!=. & FUNCTION_reg!=. & COUNTRY_reg!=. & Year!=.
	* OBSERVATION COUNT = 58,572
	
	* 24.14 Recreate observation number variable
	drop OBS
	sort PersonID Year
	by PersonID: gen OBS = _n
				
	* 24.15 Set up dates for survival analysis (date 1 is exit one year later, date 2 is specific exit date)	
	gen text="31/12/2008" if Year==2008
	replace text="31/12/2009" if Year==2009
	replace text="31/12/2010" if Year==2010
	replace text="31/12/2011" if Year==2011
	replace text="31/12/2012" if Year==2012
	replace text="31/12/2013" if Year==2013
	replace text="31/12/2014" if Year==2014

	gen date_0=date(text,"DMY")
	gen date_1=date_0+365
	replace date_1=date_1+1 if Year==2011 // to account for leap year
	format date_0 %td
	format date_1 %td
		
	gen exit_c=1 if year(EXIT_DATE_USE)==year(date_1)

	gen date_2=date_1
	replace date_2=EXIT_DATE_USE if exit_c==1 & EXIT_VOL!=.
	tab date_2 if exit_c==1 & EXIT_VOL!=.	
	format date_2 %td
	
	* 24.16 Create rating variables
	gen PERF_TOP=0 if PERF_YE!=""
	replace PERF_TOP=1 if PERF_YE=="T"
	label variable PERF_TOP "PERF-TOP"

	gen PERF_STR=0 if PERF_YE!=""
	replace PERF_STR=1 if PERF_YE=="S"
	label variable PERF_STR "PERF-STR"

	gen PERF_MOD=0 if PERF_YE!=""
	replace PERF_MOD=1 if PERF_YE=="M"
	label variable PERF_MOD "PERF-MOD"

	gen PERF_LOW=0 if PERF_YE!=""
	replace PERF_LOW=1 if PERF_YE=="L"
	label variable PERF_LOW "PERF-LOW"

	gen POT_1=0 if POT_YE!=""
	replace POT_1=1 if POT_YE=="1"
	label variable POT_1 "POT-1"

	gen POT_2=0 if POT_YE!=""
	replace POT_2=1 if POT_YE=="2"
	label variable POT_2 "POT-2"

	gen POT_3=0 if POT_YE!=""
	replace POT_3=1 if POT_YE=="3"
	label variable POT_3 "POT-3"

	gen POT_4=0 if POT_YE!=""
	replace POT_4=1 if POT_YE=="4"
	label variable POT_4 "POT-4"

	gen T1=0 if GRP_NUM!=.
	replace T1=1 if POT_YE=="1" & PERF_YE=="T"
	label variable T1 "TOP-1"

	gen T2=0 if GRP_NUM!=.
	replace T2=1 if POT_YE=="2" & PERF_YE=="T"
	label variable T2 "TOP-2"

	gen T3=0 if GRP_NUM!=.
	replace T3=1 if POT_YE=="3" & PERF_YE=="T"
	label variable T3 "TOP-3"

	gen T4=0 if GRP_NUM!=.
	replace T4=1 if POT_YE=="4" & PERF_YE=="T"
	label variable T4 "TOP-4"

	gen S1=0 if GRP_NUM!=.
	replace S1=1 if POT_YE=="1" & PERF_YE=="S"
	label variable S1 "STR-1"

	gen S2=0 if GRP_NUM!=.
	replace S2=1 if POT_YE=="2" & PERF_YE=="S"
	label variable S2 "STR-2"

	gen S3=0 if GRP_NUM!=.
	replace S3=1 if POT_YE=="3" & PERF_YE=="S"
	label variable S3 "STR-3"

	gen S4=0 if GRP_NUM!=.
	replace S4=1 if POT_YE=="4" & PERF_YE=="S"
	label variable S4 "STR-4"

	gen M1=0 if GRP_NUM!=.
	replace M1=1 if POT_YE=="1" & PERF_YE=="M"
	label variable M1 "MOD-1"

	gen M2=0 if GRP_NUM!=.
	replace M2=1 if POT_YE=="2" & PERF_YE=="M"
	label variable M2 "MOD-2"

	gen M3=0 if GRP_NUM!=.
	replace M3=1 if POT_YE=="3" & PERF_YE=="M"
	label variable M3 "MOD-3"

	gen M4=0 if GRP_NUM!=.
	replace M4=1 if POT_YE=="4" & PERF_YE=="M"
	label variable M4 "MOD-4"

	gen L4=0 if GRP_NUM!=.
	replace L4=1 if POT_YE=="4" & PERF_YE=="L"
	label variable L4 "LOW-4"
	
	gen HIPO=1 if GRP_NUM==1 | GRP_NUM==2 | GRP_NUM==5
	replace HIPO=0 if GRP_NUM==3 | GRP_NUM==4 | GRP_NUM==6 | GRP_NUM==7 | GRP_NUM==8 | GRP_NUM==9 | GRP_NUM==10 | GRP_NUM==11 | GRP_NUM==12 | GRP_NUM==13
	tab HIPO

	* 24.17 Create NONPROMSTRETCH variable - sequential observations have the same NONPROMSTRETCH value for the period where an employee is not promoted, once employee is promoted the value of the variable increases by 1 compared to the prior observation
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: gen NONPROMSTRETCH=1 if OBS==1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1] if OBS==OBS[_n-1]+1 & PROM_TY==0 & DEM_TY==0 & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1]+1 if OBS==OBS[_n-1]+1 & (PROM_TY==1 | DEM_TY==1) & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1] if OBS==OBS[_n-1]+1 & PROM_TY==0 & DEM_TY==0 & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1]+1 if OBS==OBS[_n-1]+1 & (PROM_TY==1 | DEM_TY==1) & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1] if OBS==OBS[_n-1]+1 & (PROM_TY==0 & DEM_TY==0) & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1]+1 if OBS==OBS[_n-1]+1 & (PROM_TY==1 | DEM_TY==1) & Year==Year[_n-1]+1

	* > Repeat code from above, except for the first instance of PROM_TY==0 & DEM_TY==0, set to . -- assume not promoted/demoted if unsure
	sort PersonID EMP_TIME Year
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1] if OBS==OBS[_n-1]+1 & PROM_TY==. & DEM_TY==. & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1]+1 if OBS==OBS[_n-1]+1 & (PROM_TY==1 | DEM_TY==1) & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1] if OBS==OBS[_n-1]+1 & PROM_TY==0 & DEM_TY==0 & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1]+1 if OBS==OBS[_n-1]+1 & (PROM_TY==1 | DEM_TY==1) & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1] if OBS==OBS[_n-1]+1 & (PROM_TY==0 & DEM_TY==0) & Year==Year[_n-1]+1
	by PersonID EMP_TIME: replace NONPROMSTRETCH=NONPROMSTRETCH[_n-1]+1 if OBS==OBS[_n-1]+1 & (PROM_TY==1 | DEM_TY==1) & Year==Year[_n-1]+1

	* 24.18 Create HIPOPROM_SEQ variable - number of times in a row the employee has received a "HIPO" (T1, T2 or S1) rating without being promoted
	sort PersonID EMP_TIME NONPROMSTRETCH Year
	by PersonID EMP_TIME NONPROMSTRETCH: gen HIPOPROM_SEQ=1 if HIPO==1 & HIPO[_n-1]!=1 & NONPROMSTRETCH!=.
	by PersonID EMP_TIME NONPROMSTRETCH: replace HIPOPROM_SEQ=2 if HIPO==1 & HIPO[_n-1]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-1] & NONPROMSTRETCH!=.
	by PersonID EMP_TIME NONPROMSTRETCH: replace HIPOPROM_SEQ=3 if HIPO==1 & HIPO[_n-1]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-1] & HIPO[_n-2]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-2] & NONPROMSTRETCH!=.
	by PersonID EMP_TIME NONPROMSTRETCH: replace HIPOPROM_SEQ=4 if HIPO==1 & HIPO[_n-1]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-1] & HIPO[_n-2]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-2] & HIPO[_n-3]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-3] & NONPROMSTRETCH!=.
	by PersonID EMP_TIME NONPROMSTRETCH: replace HIPOPROM_SEQ=5 if HIPO==1 & HIPO[_n-1]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-1] & HIPO[_n-2]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-2] & HIPO[_n-3]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-3] & HIPO[_n-4]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-4] & NONPROMSTRETCH!=.
	by PersonID EMP_TIME NONPROMSTRETCH: replace HIPOPROM_SEQ=6 if HIPO==1 & HIPO[_n-1]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-1] & HIPO[_n-2]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-2] & HIPO[_n-3]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-3] & HIPO[_n-4]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-4] & HIPO[_n-5]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-5] & NONPROMSTRETCH!=.
	by PersonID EMP_TIME NONPROMSTRETCH: replace HIPOPROM_SEQ=7 if HIPO==1 & HIPO[_n-1]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-1] & HIPO[_n-2]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-2] & HIPO[_n-3]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-3] & HIPO[_n-4]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-4] & HIPO[_n-5]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-5] & HIPO[_n-6]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-6] & NONPROMSTRETCH!=.

	* > Here, I allow the sequence to continue if the employee was HIPO this year, and HIPO two years ago, but they did not have a rating last year (though they must have an observation)
	sort PersonID EMP_TIME NONPROMSTRETCH Year
	by PersonID EMP_TIME NONPROMSTRETCH: replace HIPOPROM_SEQ=[_n-2]+1 if HIPO==1 & POT_YE[_n-1]=="" & HIPO[_n-2]==1 & NONPROMSTRETCH==NONPROMSTRETCH[_n-2] & NONPROMSTRETCH!=.


	* 24.19 Populate HIPOPROM_SEQ variable for non-HiPo ratings 
	replace HIPOPROM_SEQ=8 if GRP_NUM==3
	replace HIPOPROM_SEQ=9 if GRP_NUM==4
	replace HIPOPROM_SEQ=10 if GRP_NUM==6
	replace HIPOPROM_SEQ=11 if GRP_NUM==7
	replace HIPOPROM_SEQ=12 if GRP_NUM==8
	replace HIPOPROM_SEQ=13 if GRP_NUM==9
	replace HIPOPROM_SEQ=14 if GRP_NUM==10
	replace HIPOPROM_SEQ=15 if GRP_NUM==11
	replace HIPOPROM_SEQ=16 if GRP_NUM==12
	
	* 24.20 Save final file for analyses
	save "/Volumes/cdeller_project/Beyond Performance Project/JAR Data/Analysis_Data_FINAL.dta", replace
	clear
	

clear

* EOF

		
		


