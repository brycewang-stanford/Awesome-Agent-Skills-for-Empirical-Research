* ********************************************************************************
* ********************************************************************************
* Clean Poster Data
* ********************************************************************************
* ********************************************************************************
* author: Shelley Li
* date: January 20, 2017
* purpose: Generate A List of Posters Used for Customer Evaluation & Analysis
* ********************************************************************************
* ********************************************************************************

* Steps
	* 1. Join Monthly Collections to Generate Master List of Posters 
	* 2. Create Treatment Indicator 
	* 3. Generate a clean list of posters for customer evaluation
* ********************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

* start log
	cd "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\programs\logs"
	local c_date = c(current_date)
	local c_time = c(current_time)
	local c_time_date = "`c_date'"+"_" +"`c_time'"
	local time_string = subinstr("`c_time_date'", ":", "_", .)
	local time_string = subinstr("`time_string'", " ", "_", .)
	log using log_`time_string', text

* change into output folder
	cd "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\output"

***************************************************************************************
* 1. Join Monthly Collections to Generate Master List of Posters
***************************************************************************************

	//-----------------------------------
	// July
	//-----------------------------------

		* import 
			import excel using "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\input\PosterRegistry_WIP.xlsx", sheet("July") clear first

		* rename variables
			rename colors colors2
			rename L colors3

		* generate month and post indicator
			gen month=7
			gen post=0

		* save
			save july, replace

	//-----------------------------------
	// August
	//-----------------------------------

		*import 
			import excel using "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\input\PosterRegistry_WIP.xlsx", sheet("August") clear first
		
		* rename variables
			rename colors colors2
			rename L colors3

		* generate month and post indicator
			gen month=8
			gen post=0
		
		* save
			save august, replace

	//-----------------------------------
	// October
	//-----------------------------------

		* import
			import excel using "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\input\PosterRegistry_WIP.xlsx", sheet("October") clear first

		* rename variables
			rename colors colors2
			rename L colors3

		* generate month and post indicator
			gen month=10
			gen post=1

		*save 
			save october, replace

	//-----------------------------------
	// December
	//-----------------------------------

		* import
			import excel using "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\input\PosterRegistry_WIP.xlsx", sheet("December") clear first

		* rename variables
			rename colors colors2
			rename L colors3

		* generate month and post indicator
			gen month=12
			gen post=1

		* save
			save december, replace

	//-----------------------------------
	// Append Months 
	//-----------------------------------

		* append
			append using july, force
			append using august, force
			append using october, force

		* rename variables
			foreach v of varlist _all {
			      capture rename `v' `=lower("`v'")'
			   }

		*save and clear
			save posterregistry, replace
			clear

***************************************************************************************
* 2. Create Treatment Indicator
***************************************************************************************

	* import
		import excel using "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\input\tr_indicator.xlsx", clear first

	* lowercase variables
		replace shop=lower(shop)

	* save
		save tr_indicator, replace
		clear

********************************************************************************
* 3. Generate a clean list of posters for customer evaluation
********************************************************************************

	* use poster registry data 
		use posterregistry, clear

	//-----------------------------------
	// Fix store names
	//-----------------------------------

		* lower case variables
			replace shop=lower(shop)
			replace brand=lower(brand)

		*fix some store name and brand related errors and typos
			*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			*redacted
			*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

		*see which observations' shop or brand is missing
			gen missing_shopbrand=1 if shop=="" | brand==""
			replace missing_shopbrand=0 if missing_shopbrand==.
			keep if missing_shopbrand==0

		*fix more shop name related errors
			*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			*redacted
			*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	//-----------------------------------
	// Merge in treatment indicators
	//-----------------------------------

		* merge treatment indicator
			merge m:1 shop using tr_indicator
			keep if _m==3

		*drop the shops not in the experiment
			drop if tr==. 

	//-----------------------------------
	// Fix brand names
	//-----------------------------------

		*fix brand name related errors & typos
			*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			*redacted
			*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

		*drop the brands (usually with no or few promoters) not included in the experiment
			*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			*redacted
			*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

		*Only Keep the Store-brands that Appeared in Both Experimental Periods****
			sort shop brand post
			by shop brand: egen n=count(post)
			by shop brand post: egen n_post=count(post)
			gen sp=n-n_post
			drop if sp==0
			drop n n_p sp _m

	* save poster 
		save "T:\Data Prep and Analyses\C. Master Dataset\input\poster_clean731", replace

	* export to excel
		export excel poster_clean731, firstrow(variables) replace


***************************************************************************************
	* end log
		log close
* ********************************************************************************
* ********************************************************************************
* Prepare Customer Ratings
* ********************************************************************************
* ********************************************************************************
* author: Tatiana Sandino
* date: March 11, 2017
* purpose: Generate A List of Posters Used for Customer Evaluation & Analysis
* ********************************************************************************
* ********************************************************************************
*Description: 

*This program prepares data on creativity ratings at the store-brand-poster level.
*Its inputs, outputs, and the index with the steps followed are described below:

*Inputs (under "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\input"):
	*1) CustomerPanel.dta - Data from the Customer Panel app, prepared in Excel 
	*	(see app_combined.xlsx)
	*2) poster_clean731_Final_Stata.dta- Poster data (handcoded by Shelley, Kyle and Tatiana)
	*   (see poster_clean731_Final.xls)

*Outputs (under "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\output"):
	*Intermediate Outputs
	*Poster_AppRatings.dta- Stata dataset after processing customer panel app inputs
	
	*Final Output
	*CustomerPanel_Dataset- Stata dataset ready for customer panel analysis

	   /*Contains 731 observations and the following variables:	 

		variable name   type    format  label	
			
		poster          str5    %5s	 
		posterfilename  strL    %51s	 
		Store           str4    %4s	    Store code
		Brand           str11   %11s	 
		Poster_author   str22   %22s	Name of the author of the poster
		Poster_authorID int     %8.0g	Employee ID of the author of the poster
		Poster_clear    byte    %8.0g	Dummy indicating if poster picture was clear
		Poster_2colors  byte    %8.0g	Dummy indicating poster has 2 or more colors
		Poster_3colors  byte    %8.0g	Dummy indicating poster has 3 or more colors
		Poster_picture  byte    %8.0g	Dummy indicating poster has a picture or image in it
		Poster_multiple byte    %8.0g	Dummy indicating poster picture includes multiple posters
		Poster_alldups  str17   %17s	Variable identifying group for posters that look the same
		Poster_month    byte    %8.0g	Variable indicating month when the poster was collected
		post            byte    %8.0g	 
		Treatment       byte    %8.0g	Variable indicating that the psoter was produced in a treatment store
		
		Attractive_ra~t float   %9.0g	Average ratings 1 (least attractive) to 5 (most attractive)
		Attractive_ra~d float   %9.0g	Average ratings normalized for each rater as follows:(rating_bucket-meanbucket)
		Attractive_pc~s float   %9.0g	% attractiveness raters that could not read at least one language in the poster
		Attractive_p~25 float   %9.0g	% attractiveness raters with age<25 years
		Attractive_p~ee float   %9.0g	% attractiveness raters with a university degree
		Attractive_p~le float   %9.0g	% attractiveness raters that were female
		Useful_rating~t float   %9.0g	Average ratings 1 (least useful) to 5 (most useful)
		Useful_rating~d float   %9.0g	Average ratings normalized for each rater as follows:(rating_bucket-meanbucket)
		Useful_pctrat~s float   %9.0g	% usefulness raters that could not read at least one language in the poster
		Useful_pctra~25 float   %9.0g	% usefulness raters with age<25 years
		Useful_pctra~ee float   %9.0g	% usefulness raters with a university degree
		Useful_pctra~le float   %9.0g	% usefulness raters that were female

		M_Attractive_~t float   %9.0g	XXXX Trial- Average ratings 1 (least attractive) to 5 (most attractive)
		M_Attractive_~d float   %9.0g	XXXX Trial- Average ratings normalized for each rater as follows: (rating_bucket-meanbucket)
		M_Attractive_~s float   %9.0g	XXXX Trial- % attractiveness raters that could not read at least one language in the poster
		M_Attractive~25 float   %9.0g	XXXX Trial-% attractiveness raters with age<25 years
		M_Attractive~ee float   %9.0g	XXXX Trial- % attractiveness raters with a university degree
		M_Attractive~le float   %9.0g	XXXX Trial- % attractiveness raters that were female
		M_Useful_rati~t float   %9.0g	XXXX Trial- Average ratings 1 (least useful) to 5 (most useful)
		M_Useful_rati~d float   %9.0g	XXXX Trial- Average ratings normalized for each rater as follows:(rating_bucket-meanbucket)
		M_Useful_pctr~s float   %9.0g	XXXX Trial- % usefulness raters that could not read at least one language in the poster
		M_Useful_pct~25 float   %9.0g	XXXX Trial- % usefulness raters with age<25 years
		M_Useful_pct~ee float   %9.0g	XXXX Trial- % usefulness raters with a university degree
		M_Useful_pct~le float   %9.0g	XXXX Trial- % usefulness raters that were female
		
		A_Attractive_~t float   %9.0g	YYYY Trial- Average ratings 1 (least attractive) to 5 (most attractive)
		A_Attractive_~d float   %9.0g	YYYY Trial- Average ratings normalized for each rater as follows:(rating_bucket-meanbucket)
		A_Attractive_~s float   %9.0g	YYYY Trial- % attractiveness raters that could not read at least one language in the poster
		A_Attractive~25 float   %9.0g	YYYY Trial- % attractiveness raters with age<25 years
		A_Attractive~ee float   %9.0g	YYYY Trial- % attractiveness raters with a university degree
		A_Attractive~le float   %9.0g	YYYY Trial- % attractiveness raters that were female
		A_Useful_rati~t float   %9.0g	YYYY Trial- Average ratings 1 (least useful) to 5 (most useful)
		A_Useful_rati~d float   %9.0g	YYYY Trial- Average ratings normalized for each rater as follows:(rating_bucket-meanbucket)
		A_Useful_pctr~s float   %9.0g	YYYY Trial- % usefulness raters that could not read at least one language in the poster
		A_Useful_pct~25 float   %9.0g	YYYY Trial- % usefulness raters with age<25 years
		A_Useful_pct~ee float   %9.0g	YYYY Trial- % usefulness raters with a university degree
		A_Useful_pct~le float   %9.0g	YYYY Trial- % usefulness raters that were female*/ 
		
*Index

*1. Clean up and generate variables from Customer Panel app data
	*1.1 Create assignment variables consistently. We already have Assign_Dimension
	*	 specifying "attractive/useful", now we create Assign_Income specifying "high/low"
	*1.2 Create indicator for latest rating per trial/income/dimension/poster
	*1.3 Relabel rating variable, make it from 1 to 5 (instead of 0 to 4)
		*and define normalized rating
	*1.4 Keep only latest rating per income/dimension/poster for XXXX's and YYYY's trials
	*1.5 Define poster variable as a string
	*1.6 Count number of customer raters
	*1.7 Drop unnecessary variables
	*1.8 Save File as_Posters_AppRatings file 
	
*2. Prepare poster_clean handcoded data 
	*2.1. Rename variables
	*2.2 Label variables
	
*3. Merge Poster_Clean data with Posters_AppRatings 
	
*4. Identify cases where there was a poster-rater language mismatch
	
*5. Run interrater reliability analyses using intraclass correlations
	*5.1 Evaluate interrater reliability for attractiveness
	*5.2 Evaluate interrater reliability for useful
		
*6. Create one line per poster including ratings and rater characteristics for 
	*each trial-dimension-income using reshape function.
	*6.1 Create Trial_Dimension_Income variable based on which I plan to expand  
	*    the data(similar to "dadmom" in example above)
	*6.2 Widen the data expanding the following variables based on each 
		*Trial_Dimension_Income: rating_bucket rating_normalized rater_age 
		*rater_education rater_gender langmismatch
	
*7. Estimate correlations within and across trials

		*7.1 Examine correlation across attractiveness ratings:
		*7.2 Examine correlation across usefulness ratings:

*8. Fill in ratings for posters that were not rated (since a duplicate was rated)
	*8.1 Fill in numeric missing values
	*8.2 Fill in string missing values

*9. Create summary measures for ratings and rater characteristics per trial
	*	- Aggregate values for each dimension in each trial, 
	*	- Aggregate values for each dimension across trials

	*9.1 Aggregate variables for attractiveness
		*9.1.1 Across both trials
		*9.1.2 XXXX's Trial
		*9.1.3 YYYY's Trial

	*9.2 Aggregate variables for usefulness
		*9.2.1 Across both trials
		*9.2.2 XXXX's Trial
		*9.2.3 YYYY's Trial

*10. Delete input variables
*11. Save CustomerPanel Dataset

* ********************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************
clear

cd "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\output"

set more off
set memory 1g
set matsize 5000

* start log
	cd "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\programs\logs"
	local c_date = c(current_date)
	local c_time = c(current_time)
	local c_time_date = "`c_date'"+"_" +"`c_time'"
	local time_string = subinstr("`c_time_date'", ":", "_", .)
	local time_string = subinstr("`time_string'", " ", "_", .)
	log using log_`time_string', text

*******************************************************************************************

use "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\input\CustomerPanel.dta", clear

*******************************************************************************************
*1. Clean up and generate variables from Customer Panel app data
*******************************************************************************************

	//-----------------------------------
	*1.1 Create assignment variables consistently. We already have Assign_Dimension
	*	 specifying "attractive/useful", now we create Assign_Income specifying "high/low"
	//-----------------------------------
	
		gen Assign_Income = "high" if(Assign_High_Income==1 & Assign_Low_Income==0)
		replace Assign_Income = "low" if(Assign_High_Income==0 & Assign_Low_Income==1)
		
		drop Assign_High_Income Assign_Low_Income
		
		*Label assignment variables
		label variable Assign_Income "Categorical variable indicating whether the rating was done by a 'high' or 'low' income customer"
		label variable Assign_Dimension "Categorical variable indicating whether the poster was rated based on the 'attractive' or 'useful' criterion"

	//-----------------------------------
	*1.2 Create indicator for latest rating per trial/income/dimension/poster
	//-----------------------------------
		gsort trial_name poster Assign_Income Assign_Dimension -time
		by trial_name poster Assign_Income Assign_Dimension: gen Lasttofirst_rating=_n
		gen Latest_rating=(Lasttofirst_rating==1)

		*Label latest rating
		label variable Latest_rating "Dummy indicating the rating was the last received for a given poster-trial-income-dimension condition"
	
	//-----------------------------------
	*1.3 Relabel rating variable, make it from 1 to 5 (instead of 0 to 4)
		*and define normalized rating
	//-----------------------------------
	
		rename bucket rating_bucket 
		
		replace rating_bucket=rating_bucket+1

		bysort trial_name time rater_id: egen meanbucket=mean(rating_bucket)
		bysort trial_name time rater_id: egen sdbucket=sd(rating_bucket)
		bysort trial_name time rater_id: egen countbucket=count(rating_bucket)
		drop countbucket
		
		gen rating_normalized=(rating_bucket-meanbucket)/sdbucket
		drop meanbucket sdbucket
	
	//-----------------------------------
	*1.4 Keep only latest rating per income/dimension/poster for XXXX's and YYYY's trials
	//-----------------------------------
	
		keep if(trial_name=="Trial XXXX" | trial_name=="2017-02-12 Trial YYYY")
		keep if Latest_rating==1
		drop time Lasttofirst_rating Latest_rating
		
	//-----------------------------------
	*1.5 Define poster variable as a string
	//-----------------------------------
		tostring poster, format(%05.0f) replace

	//-----------------------------------
	*1.6 Count number of customer raters
	//-----------------------------------
			sort rater_id
			by rater_id: gen r=_n==1 
			*# raters:
			count if r==1 
			*keep it sorted by trial_name
			sort trial_name
	
	//-----------------------------------
	*1.7 Drop unnecessary variables
	//-----------------------------------
		drop proctor_name rater_id rating_location rater_income r
	
	//-----------------------------------
	*1.8 Save File as_Posters_AppRatings file 
	//-----------------------------------
	save "Poster_AppRatings", replace

	clear
	
*******************************************************************************************
*2. Prepare poster_clean handcoded data 
*******************************************************************************************
	
	use "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\input\poster_clean731_Final_Stata.dta", clear
	
	//-----------------------------------
	*2.1. Rename variables
	//-----------------------------------
		rename shop Store
		rename brand Brand
		rename name Poster_author
		rename empid Poster_authorID
		rename clear Poster_clear
		rename hindi Poster_hindi
		rename english Poster_english
		rename colors2 Poster_2colors
		rename colors3 Poster_3colors
		rename imagepicture Poster_picture
		rename multiple Poster_multiple
		rename alldups Poster_alldups
		rename tr Treatment
		rename month Poster_month

	//-----------------------------------
	*2.2 Label variables
	//-----------------------------------
		label variable Store "Store code"
		label variable Poster_author "Name of the author of the poster"
		label variable Poster_authorID "Employee ID of the author of the poster"
		label variable Poster_clear "Dummy indicating if poster picture was clear"
		label variable Poster_hindi "Dummy indicating if poster has Hindi characters"
		label variable Poster_english "Dummy indicating if poster has English characters"
		label variable Poster_2colors "Dummy indicating poster has 2 or more colors"
		label variable Poster_3colors "Dummy indicating poster has 3 or more colors"
		label variable Poster_picture "Dummy indicating poster has a picture or image in it"
		label variable Poster_multiple "Dummy indicating poster picture includes multiple posters"
		label variable Poster_alldups "Variable identifying group for posters that look the same"
		label variable Treatment "Variable indicating that the psoter was produced in a treatment store"
		label variable Poster_month "Variable indicating month when the poster was collected"
		
*******************************************************************************************
*3. Merge Poster_Clean data with Posters_AppRatings 
*******************************************************************************************
	
	merge 1:m poster using  "Poster_AppRatings"
		
*******************************************************************************************
*4. Identify cases where there was a poster-rater language mismatch
*******************************************************************************************
	
		gen lang_mismatch=(Poster_hindi==1 & rater_readhindi==0 | Poster_english==1 & rater_readenglish==0)
		drop Poster_hindi rater_readhindi Poster_english rater_readenglish

*******************************************************************************************
*5. Run interrater reliability analyses using intraclass correlations
*******************************************************************************************

	gen 	ratertype="HIMa" if (trial_name=="Trial XXXX" & Assign_Income=="high")
	replace ratertype="LIMa" if (trial_name=="Trial XXXX" & Assign_Income=="low")
	replace	ratertype="HIAr" if (trial_name=="2017-02-12 Trial YYYY" & Assign_Income=="high")
	replace ratertype="LIAr" if (trial_name=="2017-02-12 Trial YYYY" & Assign_Income=="low")
	
	save temp1, replace
	
	//-----------------------------------
	*5.1 Evaluate interrater reliability for attractiveness
	//-----------------------------------
		
		*5.1.1 Agreement on attractiveness across all rater types of both trials 
				*Agreement among High Income-XXXX, Low Income-XXXX, 
				*High Income-YYYY, and Low Income-YYYY
				drop if(Assign_Dimension=="useful")
				icc rating_bucket poster ratertype, cons
		
		*5.1.2 Agreement on attractiveness across all XXXX raters
				*Agreement between High Income-XXXX& Low Income-XXXX
				drop if(trial_name=="2017-02-12 Trial YYYY")
				icc rating_bucket poster ratertype, cons
		
		*5.1.3 Agreement on attractiveness across all YYYY raters 
				*Agreement between High Income-YYYY and Low Income-YYYY
				clear
				use temp1
				drop if(Assign_Dimension=="useful" | trial_name=="Trial XXXX")
				icc rating_bucket poster ratertype, cons
	
	//-----------------------------------
	*5.2 Evaluate interrater reliability for useful
	//-----------------------------------
	
		*5.2.1 Agreement on usefulness across all rater types of both trials 
				clear
				use temp1
				drop if(Assign_Dimension=="attractive")
				icc rating_bucket poster ratertype, cons
		
		*5.2.2 Agreement on usefulness across all XXXX raters
				*Agreement between High Income-XXXX& Low Income-XXXX
				drop if(trial_name=="2017-02-12 Trial YYYY")
				icc rating_bucket poster ratertype, cons
		
		*5.2.3 Agreement on usefulness across all YYYY raters 
				*Agreement between High Income-YYYY and Low Income-YYYY
				clear
				use temp1
				drop if(Assign_Dimension=="attractive" | trial_name=="Trial XXXX")
				icc rating_bucket poster ratertype, cons

*******************************************************************************************
*6. Create one line per poster including ratings and rater characteristics for 
	*each trial-dimension-income using reshape function.
*******************************************************************************************

	*Bring in  temp1 dataset saved in step 5 before running interrater reliability analyses
		
		clear
		use temp1
		*Drop ratertype from interrater reliability analyses
		drop ratertype

	//-----------------------------------
	*6.1 Create Trial_Dimension_Income variable
	//-----------------------------------

		gen Trial_Dimension_Income="_Ma_At_HI" if(trial_name=="Trial XXXX" & Assign_Dimension=="attractive" & Assign_Income=="high")
		replace Trial_Dimension_Income="_Ma_At_LI" if(trial_name=="Trial XXXX" & Assign_Dimension=="attractive" & Assign_Income=="low")
		replace Trial_Dimension_Income="_Ma_Us_HI" if(trial_name=="Trial XXXX" & Assign_Dimension=="useful" & Assign_Income=="high")
		replace Trial_Dimension_Income="_Ma_Us_LI" if(trial_name=="Trial XXXX" & Assign_Dimension=="useful" & Assign_Income=="low")

		replace Trial_Dimension_Income="_Ar_At_HI" if(trial_name=="2017-02-12 Trial YYYY" & Assign_Dimension=="attractive" & Assign_Income=="high")
		replace Trial_Dimension_Income="_Ar_At_LI" if(trial_name=="2017-02-12 Trial YYYY" & Assign_Dimension=="attractive" & Assign_Income=="low")
		replace Trial_Dimension_Income="_Ar_Us_HI" if(trial_name=="2017-02-12 Trial YYYY" & Assign_Dimension=="useful" & Assign_Income=="high")
		replace Trial_Dimension_Income="_Ar_Us_LI" if(trial_name=="2017-02-12 Trial YYYY" & Assign_Dimension=="useful" & Assign_Income=="low")

		replace Trial_Dimension_Income="_Unrated_dup" if (rating_bucket==.)
		drop trial_name Assign_Dimension Assign_Income _merge

	//-----------------------------------
	*6.2 Widen the data expanding the following variables based on each 
		*Trial_Dimension_Income: rating_bucket rating_normalized rater_age 
		*rater_education rater_gender langmismatch
	//-----------------------------------
	
	reshape wide rating_bucket rating_normalized rater_age rater_education rater_gender lang_mismatch, i(poster) j(Trial_Dimension_Income) string
	drop  *_Unrated_dup

*******************************************************************************************
*7. Estimate correlations within and across trials
*******************************************************************************************

		//-----------------------------------
		*7.1 Examine correlation across attractiveness ratings:
		//-----------------------------------
			pwcorr rating_bucket_Ma_At_HI rating_bucket_Ma_At_LI rating_bucket_Ar_At_HI rating_bucket_Ar_At_LI
	
		//-----------------------------------
		*7.2 Examine correlation across usefulness ratings:
		//-----------------------------------	
			pwcorr rating_bucket_Ma_Us_HI rating_bucket_Ma_Us_LI rating_bucket_Ar_Us_HI rating_bucket_Ar_Us_LI
			
*******************************************************************************************
*8. Fill in ratings for posters that were not rated (since a duplicate was rated)
*******************************************************************************************

	//-----------------------------------
	*8.1 Fill in numeric missing values
	//-----------------------------------
		foreach x in rating_bucket rating_normalized lang_mismatch {
			foreach y in _Ma_At_HI _Ma_At_LI _Ma_Us_HI _Ma_Us_LI _Ar_At_HI _Ar_At_LI _Ar_Us_HI _Ar_Us_LI {
				sort Poster_alldups `x'`y'
				replace `x'`y' = `x'`y'[_n-1] if (Poster_alldups==Poster_alldups[_n-1] & `x'`y'==.)
			}
		}
		
	//-----------------------------------
	*8.2 Fill in string missing values
	//-----------------------------------
		foreach x in rater_age rater_education rater_gender {
			foreach y in _Ma_At_HI _Ma_At_LI _Ma_Us_HI _Ma_Us_LI _Ar_At_HI _Ar_At_LI _Ar_Us_HI _Ar_Us_LI {
				gsort Poster_alldups -`x'`y'
				replace `x'`y' = `x'`y'[_n-1] if (Poster_alldups==Poster_alldups[_n-1] & (`x'`y'=="."|`x'`y'==""))
			}
		}
		
		drop Poster_alldups

*******************************************************************************************
*9. Create summary measures for ratings and rater characteristics per trial
*******************************************************************************************
	*	- Aggregate values for each dimension in each trial, 
	*	- Aggregate values for each dimension across trials
		
	*Notice we need the labels for categorical variables, which are as follows:
	*	Education: 	phd, ma, ba, 12 or 10
	*				phd- Doctorate (PhD/DBA)
	*				ma-	Masters (MA/MSc/MTech)
	*				ba- Bachelors (BA/BSc/BTech)
	*				12-	12th
	*				10- 10th or less
	*	Gender: male, female
	*	Age: 18_to_24, 25_to_39, 40_to_60 (there was a 60 Plus but nobody answered that) 

	//-----------------------------------
	*9.1 Aggregate across both trials
	//-----------------------------------
		*9.1.1 Aggregate variables for attractiveness
			egen Attractive_rating_bucket = rowmean(rating_bucket_Ma_At_HI rating_bucket_Ma_At_LI rating_bucket_Ar_At_HI rating_bucket_Ar_At_LI)

			egen Attractive_rating_normalized = rowmean(rating_normalized_Ma_At_HI rating_normalized_Ma_At_LI rating_normalized_Ar_At_HI rating_normalized_Ar_At_LI)

			egen Attractive_pctraters_langmiss = rowmean(lang_mismatch_Ma_At_HI lang_mismatch_Ma_At_LI lang_mismatch_Ar_At_HI lang_mismatch_Ar_At_LI)
				
			gen Attractive_pctraters_under25 = 0
				foreach v in rater_age_Ma_At_HI rater_age_Ma_At_LI rater_age_Ar_At_HI rater_age_Ar_At_LI{
					replace Attractive_pctraters_under25 = Attractive_pctraters_under25 + 0.25 if(`v'=="18_to_24")
				}
			gen Attractive_pctraters_udegree = 0
				foreach v in rater_education_Ma_At_HI rater_education_Ma_At_LI rater_education_Ar_At_HI rater_education_Ar_At_LI{
					replace Attractive_pctraters_udegree = Attractive_pctraters_udegree + 0.25 if(`v'=="ba" | `v'=="ma" | `v'=="phd")
				}			

			gen Attractive_pctraters_female = 0
				foreach v in rater_gender_Ma_At_HI rater_gender_Ma_At_LI rater_gender_Ar_At_HI rater_gender_Ar_At_LI{
					replace Attractive_pctraters_female = Attractive_pctraters_female + 0.25 if(`v'=="female")
				}
				
			label variable Attractive_rating_bucket "Average ratings 1 (least attractive) to 5 (most attractive)"
			label variable Attractive_rating_normalized "Average ratings normalized for each rater as follows: (rating_bucket-meanbucket)/sdbucket"
			label variable Attractive_pctraters_langmiss "% attractiveness raters that could not read at least one language in the poster"
			label variable Attractive_pctraters_under25 "% attractiveness raters with age<25 years"
			label variable Attractive_pctraters_udegree "% attractiveness raters with a university degree"
			label variable Attractive_pctraters_female "% attractiveness raters that were female"

		*9.1.2 Aggregate variables for usefulness
	
			egen Useful_rating_bucket = rowmean(rating_bucket_Ma_Us_HI rating_bucket_Ma_Us_LI rating_bucket_Ar_Us_HI rating_bucket_Ar_Us_LI)

			egen Useful_rating_normalized = rowmean(rating_normalized_Ma_Us_HI rating_normalized_Ma_Us_LI rating_normalized_Ar_Us_HI rating_normalized_Ar_Us_LI)

			egen Useful_pctraters_langmiss = rowmean(lang_mismatch_Ma_Us_HI lang_mismatch_Ma_Us_LI lang_mismatch_Ar_Us_HI lang_mismatch_Ar_Us_LI)

			gen Useful_pctraters_under25 = 0
				foreach v in rater_age_Ma_Us_HI rater_age_Ma_Us_LI rater_age_Ar_Us_HI rater_age_Ar_Us_LI{
					replace Useful_pctraters_under25 = Useful_pctraters_under25 + 0.25 if(`v'=="18_to_24")
				}
			gen Useful_pctraters_udegree = 0
				foreach v in rater_education_Ma_Us_HI rater_education_Ma_Us_LI rater_education_Ar_Us_HI rater_education_Ar_Us_LI{
					replace Useful_pctraters_udegree = Useful_pctraters_udegree + 0.25 if(`v'=="ba" | `v'=="ma" | `v'=="phd")
				}			

			gen Useful_pctraters_female = 0
				foreach v in rater_gender_Ma_Us_HI rater_gender_Ma_Us_LI rater_gender_Ar_Us_HI rater_gender_Ar_Us_LI{
					replace Useful_pctraters_female = Useful_pctraters_female + 0.25 if(`v'=="female")
				}

			label variable Useful_rating_bucket "Average ratings 1 (least useful) to 5 (most useful)"
			label variable Useful_rating_normalized "Average ratings normalized for each rater as follows: (rating_bucket-meanbucket)/sdbucket"
			label variable Useful_pctraters_langmiss "% usefulness raters that could not read at least one language in the poster"
			label variable Useful_pctraters_under25 "% usefulness raters with age<25 years"
			label variable Useful_pctraters_udegree "% usefulness raters with a university degree"
			label variable Useful_pctraters_female "% usefulness raters that were female"
		
	//-----------------------------------
	*9.2 Aggregate variables only in XXXX's Trial
	//-----------------------------------
	
		*9.2.1 Aggregate variables for attractiveness in XXXX's trial

			egen M_Attractive_rating_bucket = rowmean(rating_bucket_Ma_At_HI rating_bucket_Ma_At_LI)

			egen M_Attractive_rating_normalized = rowmean(rating_normalized_Ma_At_HI rating_normalized_Ma_At_LI )

			egen M_Attractive_pctraters_langmiss = rowmean(lang_mismatch_Ma_At_HI lang_mismatch_Ma_At_LI )
				
			gen M_Attractive_pctraters_under25 = 0
				foreach v in rater_age_Ma_At_HI rater_age_Ma_At_LI {
					replace M_Attractive_pctraters_under25 = M_Attractive_pctraters_under25 + 0.5 if(`v'=="18_to_24")
				}
			gen M_Attractive_pctraters_udegree = 0
				foreach v in rater_education_Ma_At_HI rater_education_Ma_At_LI {
					replace M_Attractive_pctraters_udegree = M_Attractive_pctraters_udegree + 0.5 if(`v'=="ba" | `v'=="ma" | `v'=="phd")
				}			

			gen M_Attractive_pctraters_female = 0
				foreach v in rater_gender_Ma_At_HI rater_gender_Ma_At_LI {
					replace M_Attractive_pctraters_female = M_Attractive_pctraters_female + 0.5 if(`v'=="female")
				}

			label variable M_Attractive_rating_bucket "XXXX Trial- Average ratings 1 (least attractive) to 5 (most attractive)"
			label variable M_Attractive_rating_normalized "XXXX Trial- Average ratings normalized for each rater as follows: (rating_bucket-meanbucket)/sdbucket"
			label variable M_Attractive_pctraters_langmiss "XXXX Trial- % attractiveness raters that could not read at least one language in the poster"
			label variable M_Attractive_pctraters_under25 "XXXX Trial-% attractiveness raters with age<25 years"
			label variable M_Attractive_pctraters_udegree "XXXX Trial- % attractiveness raters with a university degree"
			label variable M_Attractive_pctraters_female "XXXX Trial- % attractiveness raters that were female"
		
		*9.2.2 Aggregate variables for usefulness in XXXX's Trial
		
			egen M_Useful_rating_bucket = rowmean(rating_bucket_Ma_Us_HI rating_bucket_Ma_Us_LI)

			egen M_Useful_rating_normalized = rowmean(rating_normalized_Ma_Us_HI rating_normalized_Ma_Us_LI )

			egen M_Useful_pctraters_langmiss = rowmean(lang_mismatch_Ma_Us_HI lang_mismatch_Ma_Us_LI )
				
			gen M_Useful_pctraters_under25 = 0
				foreach v in rater_age_Ma_Us_HI rater_age_Ma_Us_LI {
					replace M_Useful_pctraters_under25 = M_Useful_pctraters_under25 + 0.5 if(`v'=="18_to_24")
				}
			gen M_Useful_pctraters_udegree = 0
				foreach v in rater_education_Ma_Us_HI rater_education_Ma_Us_LI {
					replace M_Useful_pctraters_udegree = M_Useful_pctraters_udegree + 0.5 if(`v'=="ba" | `v'=="ma" | `v'=="phd")
				}			

			gen M_Useful_pctraters_female = 0
				foreach v in rater_gender_Ma_Us_HI rater_gender_Ma_Us_LI {
					replace M_Useful_pctraters_female = M_Useful_pctraters_female + 0.5 if(`v'=="female")
				}
				
			label variable M_Useful_rating_bucket "XXXX Trial- Average ratings 1 (least useful) to 5 (most useful)"
			label variable M_Useful_rating_normalized "XXXX Trial- Average ratings normalized for each rater as follows: (rating_bucket-meanbucket)/sdbucket"
			label variable M_Useful_pctraters_langmiss "XXXX Trial- % usefulness raters that could not read at least one language in the poster"
			label variable M_Useful_pctraters_under25 "XXXX Trial- % usefulness raters with age<25 years"
			label variable M_Useful_pctraters_udegree "XXXX Trial- % usefulness raters with a university degree"
			label variable M_Useful_pctraters_female "XXXX Trial- % usefulness raters that were female"
		
	//-----------------------------------
	*9.3 Aggregate variables only in YYYY's Trial
	//-----------------------------------

		*9.3.1 Aggregate variables for attractiveness in YYYY's Trial
		
			egen A_Attractive_rating_bucket = rowmean(rating_bucket_Ar_At_HI rating_bucket_Ar_At_LI)

			egen A_Attractive_rating_normalized = rowmean(rating_normalized_Ar_At_HI rating_normalized_Ar_At_LI )

			egen A_Attractive_pctraters_langmiss = rowmean(lang_mismatch_Ar_At_HI lang_mismatch_Ar_At_LI )

			gen A_Attractive_pctraters_under25 = 0
				foreach v in rater_age_Ar_At_HI rater_age_Ar_At_LI {
					replace A_Attractive_pctraters_under25 = A_Attractive_pctraters_under25 + 0.5 if(`v'=="18_to_24")
				}
			gen A_Attractive_pctraters_udegree = 0
				foreach v in rater_education_Ar_At_HI rater_education_Ar_At_LI {
					replace A_Attractive_pctraters_udegree = A_Attractive_pctraters_udegree + 0.5 if(`v'=="ba" | `v'=="ma" | `v'=="phd")
				}			

			gen A_Attractive_pctraters_female = 0
				foreach v in rater_gender_Ar_At_HI rater_gender_Ar_At_LI {
					replace A_Attractive_pctraters_female = A_Attractive_pctraters_female + 0.5 if(`v'=="female")
				}
				
			label variable A_Attractive_rating_bucket "YYYY Trial- Average ratings 1 (least attractive) to 5 (most attractive)"
			label variable A_Attractive_rating_normalized "YYYY Trial- Average ratings normalized for each rater as follows: (rating_bucket-meanbucket)/sdbucket"
			label variable A_Attractive_pctraters_langmiss "YYYY Trial- % attractiveness raters that could not read at least one language in the poster"
			label variable A_Attractive_pctraters_under25 "YYYY Trial- % attractiveness raters with age<25 years"
			label variable A_Attractive_pctraters_udegree "YYYY Trial- % attractiveness raters with a university degree"
			label variable A_Attractive_pctraters_female "YYYY Trial- % attractiveness raters that were female"
	
		*9.3.2 Aggregate variables for usefulness in YYYY's Trial
		
			egen A_Useful_rating_bucket = rowmean(rating_bucket_Ar_Us_HI rating_bucket_Ar_Us_LI)

			egen A_Useful_rating_normalized = rowmean(rating_normalized_Ar_Us_HI rating_normalized_Ar_Us_LI )

			egen A_Useful_pctraters_langmiss = rowmean(lang_mismatch_Ar_Us_HI lang_mismatch_Ar_Us_LI )

			gen A_Useful_pctraters_under25 = 0
				foreach v in rater_age_Ar_Us_HI rater_age_Ar_Us_LI {
					replace A_Useful_pctraters_under25 = A_Useful_pctraters_under25 + 0.5 if(`v'=="18_to_24")
				}

			gen A_Useful_pctraters_udegree = 0
				foreach v in rater_education_Ar_Us_HI rater_education_Ar_Us_LI {
					replace A_Useful_pctraters_udegree = A_Useful_pctraters_udegree + 0.5 if(`v'=="ba" | `v'=="ma" | `v'=="phd")
				}			

			gen A_Useful_pctraters_female = 0
				foreach v in rater_gender_Ar_Us_HI rater_gender_Ar_Us_LI {
					replace A_Useful_pctraters_female = A_Useful_pctraters_female + 0.5 if(`v'=="female")
				}
				
			label variable A_Useful_rating_bucket "YYYY Trial- Average ratings 1 (least useful) to 5 (most useful)"
			label variable A_Useful_rating_normalized "YYYY Trial- Average ratings normalized for each rater as follows: (rating_bucket-meanbucket)/sdbucket"
			label variable A_Useful_pctraters_langmiss "YYYY Trial- % usefulness raters that could not read at least one language in the poster"
			label variable A_Useful_pctraters_under25 "YYYY Trial- % usefulness raters with age<25 years"
			label variable A_Useful_pctraters_udegree "YYYY Trial- % usefulness raters with a university degree"
			label variable A_Useful_pctraters_female "YYYY Trial- % usefulness raters that were female"

*******************************************************************************************
*10. Delete input variables
*******************************************************************************************
	drop rating_bucket_* rating_normalized_* rater_age_* rater_education_* rater_gender_* lang_mismatch_*

*******************************************************************************************
*11. Save CustomerPanel Dataset
*******************************************************************************************
	save "CustomerPanel_Dataset", replace

*******************************************************************************************
log close
* ********************************************************************************
* ********************************************************************************
* Attendance
* ********************************************************************************
* ********************************************************************************
* author: Kyle Thomas
* modified by: Tatiana Sandino 
* date: February 14, 2017
* purpose: compute weekly attendance promoter data
* ********************************************************************************
* Inputs: B. Data Preparation/02. Attendance Data/input
* Outputs: B. Data Preparation/02. Attendance Data/output
* Steps:
* 1. Read and Merge Data
* 2. Generate weekly unique promoters on store-brand level
* ********************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
		cd "T:\Data Prep and Analyses\B. Data Preparation\02. Attendance Data\programs\logs"
		local c_date = c(current_date)
		local c_time = c(current_time)
		local c_time_date = "`c_date'"+"_" +"`c_time'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using log_`time_string', text

	* change into working directory
		cd "T:\Data Prep and Analyses\B. Data Preparation\02. Attendance Data\output"

* ********************************************************************************
* 1. Read and Merge Data
* ********************************************************************************

	* local for each sheet
		local months jan-2017 dec-2016 nov-2016 oct-2016 sep-2016 aug-2016 jul-2016 jun-2016 may-2016

	* import 
		foreach i in `months'{
			import excel "T:\Data Prep and Analyses\B. Data Preparation\02. Attendance Data\input\attendance_work.xlsx", sheet("`i'") firstrow clear
			save `i', replace
		}
		
	* combine data
		qui foreach x in `months'{
			append using `x', force
		}

* ********************************************************************************
* 2. Generate Weekly Measures
* ********************************************************************************

	*format date
		gen week = wofd(date)
		format week %tw

	* fix brands 
		replace brand = lower(brand)
		**fix brand name related typos
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	* redefine shop for promoters that were misidentified (confirmed with MPR)
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		
	* drop locations not in experiment
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	/*Adjustments to exclude one-time promoter visits to stores 
	for induction or training, and to fix misspellings leading to
	double-counting promoters (TATIANA CHANGE)*/
	
		* before counting names, fix misspelled names (when caught) and 
		* make all names lower case 
		
			* fix misspelled names 
				*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
				*redacted
				*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			
			* make all names lower case
				replace name=lower(name)
			
		* exclude promoters that did not last more than 7 days at the company
			bysort brand name: egen GM_totaldays=nvals(date)
			drop if GM_totaldays<=7
			*2,483 out of 111,171 observations were excluded
			
		* exclude promoters visiting a shop only occassionally
			gen month=mofd(date)
			format month %tm

			bysort shop brand month name: egen visitshopmonth=nvals(date)
			bysort shop brand name: egen maxvisitshopmonth=max(visitshopmonth)
			bysort shop brand name: egen visitshoptotal=nvals(date)
			
			gen pctvisitshop=visitshoptotal/GM_totaldays
			
			drop if (visitshopmonth<=2)
		
	/*End of adjustments to exclude exceptional promoter visits to stores*/
	
	* generate number of unique promoters per shop-brand-week
		bysort shop week brand : egen n_promoters = nvals(name)

		drop GM_totaldays month visitshopmonth maxvisitshopmonth visitshoptotal pctvisitshop
		
	* generate count to be summed
		gen count = 1

	* drop duplicate day entries
		duplicates drop shop brand name date, force

	save "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\output\attendance_name", replace

	* save data 
		save attendance_name, replace

	* generate count
		collapse (sum) count (mean) n_promoters, by(shop week brand)

	* generate attendance variable
		gen attendance = count/n_promoters

	*replace to zero if  brand = corporate brand
		replace brand = "corporate brand" if brand == "corporate"
		replace count = 0 if brand == "corporate brand"
		replace n_promoters = 0 if brand == "corporate brand"
		replace attendance = 0 if brand == "corporate brand"

	* save data
		save "T:\Data Prep and Analyses\C. Master Dataset\input\attendance_count", replace

***************************************************************************************
	* end log
		log close


* ********************************************************************************
* ********************************************************************************
* Prepare Pre-experimental Survey Data
* ********************************************************************************
* ********************************************************************************
* author: Shelley Li
* date: February 1, 2017
* purpose: Prepare Pre-experimental Survey Data
* ********************************************************************************
* Inputs: B. Data Preparation/03. Surveys/input
* Outputs: B. Data Preparation/03. Surveys/output
* Steps:
* 1. Import and clean data
* ********************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
		cd "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\programs\logs"
		local c_date = c(current_date)
		local c_time = c(current_time)
		local c_time_date = "`c_date'"+"_" +"`c_time'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using log_`time_string', text

	* change into working directory
		cd "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\output"

* ********************************************************************************
* 1. Import and clean data
* ********************************************************************************
	
	****import and clean the missing demographic information from the pre-experimental surveys
		import excel using "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\input\PreSurveys_missinginfo.xlsx", clear first
	
	* lowercase vars
		replace shop=lower(shop)
		replace shopname=lower(shopname)
		replace brand=lower(brand)

	* rename stores to make store names consistent across data files
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
	* make "brand" consisent with poster data file
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	*code the variables the same way as in the variable definitions for the proposed analyses	
		gen pre_gender=1 if gender=="FEMALE"
		replace pre_gender=0 if gender=="MALE"
		drop gender
		rename pre_gender gender
		
		gen edu=1 if education=="M.A." | education=="M.B.A." | education=="M.B.A. MARKETING" ///
		| education=="M.SC."  | education=="MASTER" | education=="MASTERS"
		
		replace edu=3 if education=="12th" | education=="PERSUING (B.A.)" | education=="PERSUING (BACHELOR)" ///
		| education=="PURSUING (B.A.)" | education=="PURSUING (BACHELOR)"
		
		replace edu=4 if education=="10th"
		
		replace edu=2 if education!="" & edu==.
		
		rename tenure_company_coded tenure_survey
		
		sort shop brand
		
		keep shop brand tenure_survey gender edu age 
		
		duplicates tag shop brand, gen (dup)
		tab dup
		br if dup==1
		
		foreach var in tenure_survey gender edu age{
		by shop brand: egen ave`var'=mean(`var') 
		replace `var'=ave`var'
		drop ave`var'
		}
		
		duplicates drop shop brand, force
		drop dup
		
		save PreSurveys_missinginfo, replace
	
	****import quantitiative assessment data from pre-experimental surveys
		import excel using "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\input\PreSurveys.xlsx", clear first

	*	drop missing
		drop if missing(Name)==1

		gen str6 PreQ_= string(Q)
		gen one=_n
		sort Name one
		by Name: replace PreQ_="1.10" if PreQ_[_n-1]=="1.9" & PreQ_[_n+1]=="1.11"
		drop one Region Designation Mobile CoreValue Q
	
	* rename variables 
		rename StoreCode shop
		rename Brand brand
		rename Name employee_name
		rename ANS ANS_

	* lowercase vars
		replace shop=lower(shop)
		replace brand=lower(brand)

	* rename stores to make store names consistent across data files
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
	* make "brand" consisent with poster data file
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	* group ids
		egen employeeid=group(employee_name TLName)
		*this is because employee name cannot uniquely identify an employee
		egen qid=group(PreQ_)
		**tab PreQ_ qid can tell you the qid that corresponds to the PreQ_ # 
		**note that qid=2 when PreQ_==1.10 (rather than when PreQ==1.2) - but I will clean this up in the end with Q #s similar to the post-survey questions
	
	* duplicates drop 
		duplicates tag employeeid qid, gen (dup)
		tab dup
		***no dup
		drop dup
	
	* reshape data
		sort employeeid qid ANS_
		reshape wide PreQ_ ANS_, i(employeeid) j(qid)
	
	* keep relevant data
		keep ANS_1 ANS_7 ANS_11 ANS_3 ANS_14 ANS_18 ANS_20 ANS_21 ANS_24 ANS_26 ANS_27 ANS_30 ANS_31 shop brand employee_name TLName
	
	* rename variables
		rename ANS_1 engagement1
		rename ANS_7 engagement2
		rename ANS_11 engagement3
		rename ANS_3 engagement4
		rename ANS_14 quality1
		rename ANS_18 quality2
		rename ANS_20 quality3
		rename ANS_21 motivation1
		rename ANS_24 motivation2
		rename ANS_26 motivation3
		rename ANS_27 ability1
		rename ANS_30 ability3
		rename ANS_31 ability4
	
		sort shop brand

	*investigate and process duplicated shop-brands
		duplicates tag shop brand, gen (dup)
		tab dup
		br if dup==1
		
		foreach var in engagement1 engagement4 engagement2 engagement3 quality1 quality2 quality3 motivation1 motivation2 motivation3 ability1 ability3 ability4 {
			by shop brand: egen ave`var'=mean(`var') 
			replace `var'=ave`var'
			drop ave`var'
		}
		
		duplicates drop shop brand, force
		drop dup
		
	*merge with the demographic information
		merge 1:1 shop brand using PreSurveys_missinginfo

	*all matched
		drop _m employee_name TLName
		
		gen post=0
		order shop brand post
		
		* save data
		save "T:\Data Prep and Analyses\C. Master Dataset\input\presurvey", replace
	
***************************************************************************************
	* end log
		log close

	
* ********************************************************************************
* ********************************************************************************
* Prepare Post-experimental Survey Data
* ********************************************************************************
* ********************************************************************************
* author: Shelley Li
* date: February 1, 2017
* purpose: Prepare Pre-experimental Survey Data
* ********************************************************************************
* Inputs: B. Data Preparation/03. Surveys/input
* Outputs: B. Data Preparation/03. Surveys/output
* Steps:
* 1. Import and clean data
* ********************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
		cd "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\programs\logs"
		local c_date = c(current_date)
		local c_time = c(current_time)
		local c_time_date = "`c_date'"+"_" +"`c_time'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using log_`time_string', text

	*change into working directory
		cd "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\output"

* ********************************************************************************
* 1. Imort and clean data
* ********************************************************************************

	//-----------------------------------
	// Import the list that links survey ID for employees with employees' shop, brand, and employee ID
	//-----------------------------------

		* import data
			import excel using "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\input\PostSurveys_list.xlsx", sheet ("Eid") clear first

		* sort by id
			sort Eid

		* lower case shops and brands
			replace shop=lower(shop)
			replace brand=lower(brand)

		* make "brand" consisent with poster data file
			*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			*redacted
			*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

		* save
			save eid, replace

	//-----------------------------------
	// Import the list that links survey ID for TLs with TL's shop - in case that the survey ID for employees is missing in the responses
	//-----------------------------------

		* import 
			import excel using "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\input\PostSurveys_list.xlsx", sheet ("TLid") clear first
			
		* cleanup data
			sort Tlid
			rename Tlid TLid
			replace shop=lower(shop)
			replace brand=lower(brand)
			keep TLid shop
			rename shop TLshop

		*save
			save tlid, replace

	*-------------------------------------------------
	* import tenure and gender information on shop XXXX
	*-------------------------------------------------
	
	import excel using "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\input\PostSurveys_XXXX.xlsx", clear first

	sort shop brand
	
	save postsurvey_scbl, replace
	
	*************************************************************************************
	****Prepare Post-experimental Survey Data*******************************************
	*************************************************************************************

	import excel using "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\input\PostSurveys.xlsx", clear first

	***drop responses that are missing all identifying information or all valid answers
	drop if missing(Q17_1) & missing(Q17_2)==1 & missing(Q3)==1 & missing(Q4)==1
	drop if missing(Q12_1)==1 & missing(Q12_2)==1 & missing(Q12_3)==1 & missing(Q12_4)==1 & missing(Q13_1)==1 ///
	& missing(Q13_2)==1 & missing(Q13_3)==1 & missing(Q14_1)==1 & missing(Q14_2)==1 & missing(Q14_3)==1 ///
	& missing(Q15_1)==1 & missing(Q15_2)==1 & missing(Q15_3)==1 & missing(Q15_4)==1

	rename Q17_1 TLid
	rename Q17_2 Eid

	**identify the employees for whom there are more than one set of responses
	duplicates tag Eid if Eid!=., gen (dup)
	tab dup
	*br if dup==1
	sort Eid RecordedDate

	**eliminate duplicates case by case (based on the quality of the answers and when it was answered)
	drop if Eid==32 & Q5==""
	drop if Eid==71 & Q4==""
	drop if Eid==74 & Q4==""
	drop if Eid==182 & Q4==""
	drop if Eid==208 & Q4==""
	replace Q5="YYYY" if Eid==208
	drop if Eid==256 & Q6_2=="0"
	drop dup

	**merge in the shop, brand, and employee ID of the employees
	sort Eid
	merge m:1 Eid using eid
	drop if _m==2
	drop _m

	**merge in the shop of the TL (which would be the shop of the employee in the case of missing info on employee's shop)
	sort TLid 
	merge m:1 TLid using tlid

	**fill in the missing brand and shop information for the employees
	*br if Eid==.
	replace brand= Q5 if brand==""
	replace brand=lower(brand)
	replace shop=TLshop if shop==""


	**fill in manually the missing employee IDs from company records
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
	**drop variables that we do not see use for the future analysis
	drop _m EmployeeName_ID TLshop StartDate EndDate Status IPAddress Progress Durationinseconds Finished RecordedDate ResponseId RecipientLastName RecipientFirstName RecipientEmail ///
		 ExternalReference LocationLatitude LocationLongitude DistributionChannel TLid Eid

	**rename variables so that we can tell the post-experimental responses from the pre-experimental ones once we merge them into a final dataset

	rename Q6_1 post_startmo
	rename Q6_2 post_startyr
	**the above two use textual information

	rename Q7 gender

	*code the variables the same way as in the variable definitions for the proposed analyses	
	replace gender=gender-1

	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	rename Q8 age
	**in years
	rename Q10 edu
	**1= masters; 2=bachelors; 3=12th; 4=10th
	drop Q11 
	**Question on experience working for a mobile phone company; 
	**not in pre-experimental survey - so deleted here. 

	rename Q12_1 engagement1
	rename Q12_2 engagement2
	rename Q12_3 engagement3
	rename Q12_4 engagement4

	rename Q13_1 quality1
	rename Q13_2 quality2
	rename Q13_3 quality3

	rename Q14_1 motivation1
	rename Q14_2 motivation2
	rename Q14_3 motivation3

	rename Q15_1 ability1
	drop Q15_2 
	**Q15_2 only in post_experimental survey
	rename Q15_3 ability3
	rename Q15_4 ability4

	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	rename tenure_coded tenure_survey
	
	**Add 3 more observations for Store XYYY (late responses)
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
	drop Q3 Q4 Q5 post_startmo post_startyr EmployeeID
	**NO missing stores or brands and 7 missing EmployeeIDs
	
	sort shop brand
	duplicates tag shop brand, gen (dup)
	br if dup!=0
	
	foreach var in tenure_survey gender edu age engagement1 engagement2 engagement3 engagement4 ///
	quality1 quality2 quality3 motivation1 motivation2 motivation3 ability1 ability3 ability4{
		by shop brand: egen ave`var'=mean(`var') 
		replace `var'=ave`var'
		drop ave`var'
		}
	
	duplicates drop shop brand, force
	drop dup
	
	gen post=1
	order shop brand post
	
	save "T:\Data Prep and Analyses\C. Master Dataset\input\PostSurvey", replace

***************************************************************************************
	* end log
		log close

 
* ********************************************************************************
* ********************************************************************************
* Sales Data
* ********************************************************************************
* ********************************************************************************
* author: Kyle Thomas
* reviewed by: Tatiana Sandino and Shelley Li
* date: January 26, 2017
* purpose: take individual store sales data and generate store-brand-week
* ********************************************************************************
* ********************************************************************************
* Inputs: B. Data Preparation\04. Sales Data\input
* Outputs: B. Data Preparation\04. Sales Data\output
* Steps
	* 1. Import and combine data
	* 2. Generate Weekly Measures
* ********************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
		cd "T:\Data Prep and Analyses\B. Data Preparation\04. Sales Data\programs\logs"
		local c_date = c(current_date)
		local c_time = c(current_time)
		local c_time_date = "`c_date'"+"_" +"`c_time'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using log_`time_string', text

	* change into working directory
		cd "T:\Data Prep and Analyses\B. Data Preparation\04. Sales Data\output"

* ********************************************************************************
* 1. Import and combine data
* ********************************************************************************

* set up local to contain all store abbreviations
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted (local store contains store names)
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	* use for loop to import each file
		qui foreach x in `stores'{
			* import
				cd "T:\Data Prep and Analyses\B. Data Preparation\04. Sales Data\input"
				import delimited `x'_sales.csv, clear
				cd "T:\Data Prep and Analyses\B. Data Preparation\04. Sales Data\output"
			* drop unnecessary data
				cap drop invoiceno
				cap drop itemcolour
				cap drop cc
				cap drop imei
				cap drop imei2mobile
				cap drop isbajaj
				cap drop customername
				cap drop customerphone
				cap drop shopcomments
				cap drop datecreated
			* rename data
				rename salesamtincltax sales_tax_amt
				rename amountexclvat sales_notax_amt
			* convert strings to numbers
				foreach z in sales_tax_amt sales_notax_amt totalprofit{
					replace `z'=subinstr(`z',",","",.)
					destring `z', replace
				}
			* save and clear
				save `x'_sales.dta, replace
				clear
		}
		
	* combine data
		qui foreach x in `stores'{
			append using `x'_sales, force
		}

* ********************************************************************************
* 2. Generate Weekly Measures
* ********************************************************************************

	* total sales for store week; total sales for each brand for each week for each store
	* primary brands and "other brand" category

	* -----------------------------------
	* Create Date
	* -----------------------------------

	* generate unique id for sorting
		gen id = _n

	* format date
		gen x = substr(invoicedatetime,1,10)
		gen x2 = date(x,"MDY")
		format x2 %td
		drop x invoicedatetime
		rename x2 sales_date

	* generate week
		gen week = wofd(sales_date)
		format week %tw

	* rename location to shop
		rename location shop

	* -----------------------------------
	* Flag Brands
	* -----------------------------------

	* fix brand variable
		rename group2 brands
		replace brands = lower(brands)

	* fix brand name related errors
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	* flag main brands
		gen main_brands = 0

		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		foreach i in XXX{
			replace main_brands = 1 if brands == "`i'"
		}

	* flag other brands
		gen other_brands = 0
		replace other_brands = 1 if main_brands == 0
		replace brands = "other" if other_brands==1

	* -----------------------------------
	* Related to the brand "Home Credit"
	* -----------------------------------

	* fix variable
		replace homecreditcharges = subinstr(homecreditcharges,",","",.)
		replace homecreditcharges = "0" if homecreditcharges==""
		destring homecreditcharges, replace

	* get shop-week totals
		gen hcsale = sales_tax_amt if ishomecredit=="yes"
		bysort shop week : egen sales_hc = total(hcsale)
		gen profit_hc = 0

	* -----------------------------------
	* Generate Sales for Each Brand
	* -----------------------------------

	* generate sales for each main brand
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted: brand names removed
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		foreach i in XXX{

			* initiate blank sales vars
			gen totalprofit_`i' = 0
			gen sales_tax_amt_`i' = 0

			* replace blanks with values
			replace totalprofit_`i' = totalprofit if brands == "`i'"
			replace sales_tax_amt_`i' = sales_tax_amt if brands == "`i'"

			*create weekly sales
			bysort shop week : egen profit_`i' = total(totalprofit_`i')
			bysort shop week : egen sales_`i' = total(sales_tax_amt_`i')

			*drop individual sales
			drop totalprofit_`i'
			drop sales_tax_amt_`i'

		}	

	* -----------------------------------
	* Create Total Sales for Store-Week (no home credit numbers are included)
	* -----------------------------------

	bysort shop week : egen profit_all = total(totalprofit)
	bysort shop week : egen sales_all = total(sales_tax_amt)

	* -----------------------------------
	* Number of Sales-Days for Store-Week
	* -----------------------------------

	bysort shop week : egen days = nvals(sales_date)

	* -----------------------------------
	* clean data
	* -----------------------------------
		duplicates drop shop week, force
		drop group1 brands itemname incentive totalprofit homecreditcharges sales_tax_amt budgetused sales_notax_amt taxrate vatamt discount profit salesamtdifference normaldpinclvat finalnetdpinclvat id sales_date main_brands other_brands

	* -----------------------------------
	* create sales and profit
	* -----------------------------------
	
		gen id = _n
		reshape long sales profit, i(id) j(brand) string
		replace brand = subinstr(brand,"_","",.)
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		rename sales sales_tax
		drop id
		
	* save sales data
		save "T:\Data Prep and Analyses\C. Master Dataset\input\store_week_brand_sales", replace

***************************************************************************************
	* end log
		log close

 



* ********************************************************************************
* ********************************************************************************
* Store Characteristics
* ********************************************************************************
* ********************************************************************************
* author: Kyle Thomas
* reviewed by: Shelley Li and Tatiana Sandino
* date: February 16, 2017
* purpose: calculate distance between stores and between stores and head office
* ********************************************************************************
* ********************************************************************************
* Inputs: B. Data Preparation\05. Store Characteristics\input
* Outputs: B. Data Preparation\05. Store Characteristics\output
* Steps
	* 1. Make dataset of store latitude and longitude
	* 2. Get store distances
	* 3. Make final dataset
	* 4. Add store characteristics
***************************************************************************************
***************************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
		cd "T:\Data Prep and Analyses\B. Data Preparation\05. Store Characteristics\programs\logs"
		local c_date = c(current_date)
		local c_time = c(current_time)
		local c_time_date = "`c_date'"+"_" +"`c_time'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using log_`time_string', text

	* change into working directory
		cd "T:\Data Prep and Analyses\B. Data Preparation\05. Store Characteristics\output"

*********************************************************************
*********************************************************************
* 1. Make dataset of store latitude and longitude
*********************************************************************
*********************************************************************

	*----------------------------------------
	* get new addresses
	*----------------------------------------

	* import latitude and longitude data
		import excel "T:\Data Prep and Analyses\B. Data Preparation\05. Store Characteristics\input\mpr_coordinates_new.xlsx", sheet("detail") firstrow clear

	* drop blank coordinates 
		drop if lon==.

	* keep relevant variables
		keep stata_store lat lon

	* save new data 
		save mpr_coordinates_new, replace

	*----------------------------------------
	* get old addresses
	*----------------------------------------

	* import old data
		use "T:\Data Prep and Analyses\B. Data Preparation\05. Store Characteristics\input\_mpr_coordinates_combined", clear

	* keep relevant data
		keep stata_store lat lon

	* append new addresses
		append using mpr_coordinates_new

	* drop stores not in experiment
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	* drop duplicates
		duplicates drop stata_store, force

	* make head office entry last in list
		replace stata_store = "Zmpr_HEAD_OFFICE" if stata_store=="mpr_HEAD_OFFICE"
		sort stata_store
		replace stata_store = "mpr_HEAD_OFFICE" if stata_store=="Zmpr_HEAD_OFFICE"

	* save
		save new_mpr_coor, replace

*********************************************************************
*********************************************************************
* 2. Get store distances
*********************************************************************
*********************************************************************

	*initiate an incremental variable at one
		local x 1

	*establish store names that can be used in creating unique variable identifiers and unique file names
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted: removed store names
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	foreach val in XXXX{

		*use original dataset
			use new_mpr_coor, clear

		*generate id
			gen id = _n

		*create starting location by concatenating latitude and longitude
			gen lat_start = lat 
			gen lon_start = lon

		*set ending location to be the same as the starting location of whichever site we are on
			gen lat_end=lat_start if id==`x'
			gen lon_end=lon_start if id==`x'

		*these next steps fill lat_lon_end with the same end location coordinates,
			gsort -lat_end
			replace lat_end=lat_end[_n-1] if missing(lat_end)

			gsort -lon_end
			replace lon_end=lon_end[_n-1] if missing(lon_end)
		
			sort id

		*the distance calculation function
			geodist lat_start lon_start lat_end lon_end, gen(dist) miles

		*prep data for merge by giving each calculation a unqiue name in accordance with whatever store we are currently on
			rename dist dist_`val'

		*save with unique name in accordance with whatever store we are currently on and clear
			save mpr_coordinates_`val', replace
			clear

		*increment the x counter by 1, e.g., on the third time through this will increment x to 4
			local x `++x'
	}

*********************************************************************
*********************************************************************
* 3. Make final dataset
*********************************************************************
*********************************************************************

	*----------------------------------------
	* combine store data
	*----------------------------------------

		use mpr_coordinates_XXX, clear

		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted: removed store names
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

		foreach val in XXX {

			*merge the datasets
				merge 1:1 id using mpr_coordinates_`val'.dta

			*drop the merge indicator to prevent error
				drop _merge
		}

		*save final results
			save mpr_coordinates_combined_new, replace

	*----------------------------------------
	* reshape data
	*----------------------------------------

		drop lat lon id lat_start lon_start lat_end lon_end 

		gen id = _n

		reshape long dist_, i(id) j(end_store) string

	*----------------------------------------
	* clean data
	*----------------------------------------

		*rename and order
			rename stata_store start_store
			drop id 
			rename dist_ distance
			order start_store end_store distance

		*flag if distance is a head office to distance
			gen ho_dist = 1 if end_store=="mpr_HEAD_OFFICE"

		* drop if distance is greater than 1 mile and it is not a head office distance
			drop if distance>1 & ho_dist!=1
		
		* drop if distance is distance to itself
			drop if distance==0

		* drop if store is head office
			drop if start_store=="mpr_HEAD_OFFICE"

		* compute head office distance; take min by store for collapse
			replace ho_dist = ho_dist*distance
			bysort start_store : egen hodist = min(ho_dist)

		* intialize counter for stores
			gen close_stores = 1

		* drop the head office rows
			bysort start_store : egen nclose = nvals(end_store)
			drop if end_store == "mpr_HEAD_OFFICE" & nclose!=1
			replace close_stores = 0 if end_store=="mpr_HEAD_OFFICE"

		* collapse to get number of close stores
			collapse (sum) close_stores (min) hodist, by(start_store)

		* rename variable
			rename start_store shop

		* save
			save store_distances, replace

*********************************************************************
*********************************************************************
* 4. Add store characteristics
*********************************************************************
*********************************************************************

	* import store characteristics
		import excel "T:\Data Prep and Analyses\B. Data Preparation\05. Store Characteristics\input\store_characteristics.xlsx", sheet("details") firstrow clear

	*merge in distances
		merge 1:1 shop using store_distances
		drop _m

	* save
		save "T:\Data Prep and Analyses\C. Master Dataset\input\store_characteristics", replace

***************************************************************************************
	* end log
		log close




* ********************************************************************************
* ********************************************************************************
* Clean Poster System Activity Data*
* ********************************************************************************
* ********************************************************************************
* author: Shelley Li
* date: January 26, 2017
* purpose: Clean Poster System Activity Data*
* ********************************************************************************
* ********************************************************************************
* Inputs: B. Data Preparation\06. Poster System Data\input
* Outputs: B. Data Preparation\06. Poster System Data\output
* Steps
	* 1. Import and clean
***************************************************************************************
***************************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
	  cd "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\programs\logs"
	  local c_date = c(current_date)
	  local c_time = c(current_time)
	  local c_time_date = "`c_date'"+"_" +"`c_time'"
	  local time_string = subinstr("`c_time_date'", ":", "_", .)
	  local time_string = subinstr("`time_string'", " ", "_", .)
	  log using log_`time_string', text

	* change into output folder
	  cd "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\output"

***************************************************************************************
* 1. Import and clean
***************************************************************************************

	import excel using "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\input\EmployeeList_01302017.xlsx", clear first

	keep user_name store_code employee_ID brand employee_internal_ID
	rename user_name account_name
	sort employee_internal_ID

	save employeeaccounts, replace


	import excel using "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\input\ActivityLog_01232017.xlsx", clear first

	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted: private information, e.g. usernames, etc. 
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	gen month=month(timestamp)
	gen day=day(timestamp)
	gen year=year(timestamp)

	merge m:1 employee_internal_ID using employeeaccounts
	drop if _m==2
	drop _m

	rename store_code shop
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted: private information, e.g. store names, etc.
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
	drop if shop==""

	replace shop=lower(shop)
	replace brand=lower(brand)
	
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted: private information, e.g. store names and brand names
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	save activitylog, replace

	**generate store-level frequency of access variable
	tab1 shop brand
	gen one=1
	sort shop
	collapse (sum) one, by(shop)
	rename one accessfreq
	sort shop

	save shop_accessfreq, replace
	
	**generate store-level frequency of active access
	use activitylog, clear
	drop if action=="Leave" | action=="Logout"
	gen one=1
	sort shop
	collapse (sum) one, by(shop)
	rename one accessfreq_active
	sort shop
	
	save shop_activeaccessfreq, replace
	
	**generate store-level frequency of access using only "log ins"
	use activitylog, clear
	keep if action=="Login"
	gen one=1
	sort shop
	collapse (sum) one, by(shop)
	rename one accessfreq_login
	sort shop
	
	save shop_loginaccessfreq, replace

***************************************************************************************
  log close
* ********************************************************************************
* ********************************************************************************
* Merge Store Data
* ********************************************************************************
* ********************************************************************************
* author: Kyle Thomas, Shelley Li
* date: February 16, 2017
* modified: Tatiana Sandino 
* date: 3/18/2017
* modified: Shelley Li
* date: 3/19/2017
* purpose: merge store characteristics, sales data, survey, and attendance data
* ********************************************************************
* ********************************************************************************
* Inputs: C. Master Dataset\input
* Outputs: C. Master Dataset\output
* Steps
	* 1. Import and clean sales data
	* 2. Merge in other datasets
	* 3. Construct new measures and clean  
* **************************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
	  cd "T:\Data Prep and Analyses\C. Master Dataset\programs\logs"
	  local c_date = c(current_date)
	  local c_time = c(current_time)
	  local c_time_date = "`c_date'"+"_" +"`c_time'"
	  local time_string = subinstr("`c_time_date'", ":", "_", .)
	  local time_string = subinstr("`time_string'", " ", "_", .)
	  log using log_`time_string', text

	* change into output folder
	  cd "T:\Data Prep and Analyses\C. Master Dataset\input"

***************************************************************************************
* 1. Import and clean sales data
***************************************************************************************

	* use sales data
		use store_week_brand_sales, clear

	* drop dates before experiment started
		drop if week < tw(2016w18)

		drop if brand=="all" 
		drop if brand=="other"

	* merge in attendance data 
		merge 1:1 shop brand week using attendance_count
		drop if _m==2
		drop _m 

		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		
	* merge in store characteristics
		merge m:1 shop using store_characteristics
		drop _m
		
	* set sales and attendance as missing during renovation or after closing (*TATIANA CHANGE)
	
		* sales missing during renovation or during closing week
		replace sales_tax=. if (week>=wofd(closed) & week<=wofd(reopen) & closed!=. & reopen!=.)
		replace sales_tax=. if (week>=wofd(closed) & closed!=. & reopen==.)

		* attendance missing during renovation or during closing week
		replace attendance=. if (week>=wofd(closed) & week<=wofd(reopen) & closed!=. & reopen!=.)
		replace attendance=. if (week>=wofd(closed) & closed!=. & reopen==.)

	* define or redefine three store characteristics variables 
				
		* market type (to include store characteristics according to the managing director)
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		*redacted: private information related to store names
		*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		
		* renovation (defined as dummy=1 after a renovation during the period, zero otherwise)
		replace renovation=0 if(renovation==.)
		replace renovation=0 if(week<wofd(closed) & closed!=. & reopen!=.)
		
		*monthbeforeclosing
		replace permanent_closed=0 if(permanent_closed==.)
		gen monthbeforeclosing=permanent_closed
		replace monthbeforeclosing=0 if(week<(wofd(closed)-4) & closed!=.)

	* generate post indicator
		**Sep 1, 2016 is the last day of 2016w35; 
		**Sep 1 to Sep 5 is the first system update. 
		gen post=1 if week>=tw(2016w36)
		replace post=0 if week<tw(2016w36)
	
	*Other data preparations originally done under Proposed Analyses program 
			* check the sales number 
				sum sales,d
				drop if sales_tax<=0
				winsor sales_tax, gen (sales_w) p(0.01)
				
			* set maximum attendance=7 but leave another variable, attendanceUC, unconstrained
				gen attendanceUC=attendance
				replace attendance=7 if(attendance>7 & attendance!=.)
	
			**Only Keep the Store-brands that Appeared in Both Pre- and Post- Periods
				sort shop brand post
				by shop brand: egen n=count(post)
				by shop brand post: egen n_post=count(post)
				by shop brand post: egen msales=mean(sales_tax)
				by shop brand post: egen mattendance=mean(attendance)
				by shop brand post: egen mattendanceUC=mean(attendanceUC)
				gen sp=n-n_post
				drop if sp==0
				drop n n_post sp 
					
			**generate pre-period average sales and attendance data
				gen lmsales=log(1+msales)
				sort shop brand post
				by shop brand: replace lmsales=lmsales[1]
				by shop brand: replace mattendance=mattendance[1]
				by shop brand: replace mattendanceUC=mattendanceUC[1]

			***we should determine which weeks in November to drop
			***Dec 1 is the last day of w48, Nov 3 is the last day of w44.
				gen nov=1 if week>tw(2016w44) & week <=tw(2016w48)
				replace nov=0 if nov==.
				
			**drop the weeks after Jan 28, 2017
				drop if week>=tw(2017w5) 

			**generate more regression variables
				gen lsales=log(1+sales_tax)
				gen trxpost=tr*post
				gen store_age= end_age/365
	
			*make brand names consistent across files
				*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
				*redacted
				*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			
			* refinement of sales days -t here are a few cases where days>7 
			* this is because Stata defines w52 as a longer week
			* - In these cases, redefine sales days as 7
				replace days=7 if(days>7 & week==tw(2016w52))

***************************************************************************************
* 2. Merge in other datasets
***************************************************************************************			

	* merge in survey data
		replace shop=lower(shop)
		merge m:1 shop brand post using "T:\Data Prep and Analyses\C. Master Dataset\output\master_survey.dta"
		drop if _m==2
		drop _m
		
	*merge in the median tenure data to fill the missing values in tenure
		sort brand post
		merge m:1 brand post using "T:\Data Prep and Analyses\C. Master Dataset\output\median_tenuregender_brand.dta"
		drop if _m==2
		drop _m med_tenureBG ave_gender
		
		sort post
		merge m:1 post using "T:\Data Prep and Analyses\C. Master Dataset\output\median_tenuregender.dta"
		drop if _m==2

***************************************************************************************
* 3. Construct new measures and clean
***************************************************************************************
	
	*construct tenure measures using median brand-period value and median period value to fill the missing values
		gen tenure_bg_brand=tenure_bestguess
		replace tenure_bg_brand=med_tenureBG_brand if tenure_bestguess==.
		
		gen tenure_bg_period=tenure_bestguess
		replace tenure_bg_period=med_tenureBG if tenure_bestguess==.
		
	*construct gender measures using average brand-period value and average period value to fill the missing values
		gen gender_fmissing_brand=gender
		replace gender_fmissing_brand=ave_gender_brand if gender==.
		
		gen gender_fmissing=gender
		replace gender_fmissing=ave_gender if gender==.
		
		drop med_tenureBG_brand med_tenureBG ave_gender_brand ave_gender
		
		* clean data
		replace count = 0 if count == .
		rename count promoter_days
		replace n_promoter=0 if n_promoter==.
		
		**drop those with 0 promoters (indicating that this brand didn't exist at this store)
				drop if n_promoter==0

		sort shop week brand
		order shop week brand sales_tax days promoter_days
		drop open start_date end_date _m 
		destring sqft, replace
		destring start_age, replace
		destring end_age, replace
		destring hodist, replace
		destring close_stores, replace
		drop if tr==.
		gen motivation= (motivation1+motivation2+motivation3)/3
		gen ability= (ability1+ability3+ability4)/3


	**label variables
		label variable sales_tax "Sales w VAT Tax"
		label variable promoter_days "Promoter_days"
		label variable days "Sales Days"
		label var lsales "Sales"
		label var tr "Info Sharing"
		label var post "Post"
		label var trxpost "Info Sharing x Post"
		label var n_promoters "# of promoters for the brand at the store"
		label var sqft "store physical size"
		label var store_age "store age"
		label var days "sales days"
		label var close_stores "# of nearby stores"
		label var hodist "distance to head office"
		label var tenure_survey "Tenure_Survey"
		label var tenure_bestguess "Tenure_BestGuess"
		label var tenure_bg_period "Tenure fill w/ median period"
		label var tenure_bg_brand "Tenure fill w/ median brand"
		label var TL_changed "TL Change"
		
		label var gender "Gender"
		label var gender_fmissing "Gender fill w/ mean period"
		label var gender_fmissing_brand "Gender fill w/ mean brand"
		label var lmsales "Pre-Intervention Sales"
		label var mattendance "Pre-Intervention Attendance"
		label var age "Age" 
		label var edu  "Education"
		label var renovation "Renovation"
		label var permanent_closed "Permanent Close"
		label var monthbeforeclosing "Month Before Closing"
		
	* save data
		cd ../output
		save store_data, replace
		save "T:\Data Prep and Analyses\D. Analyses\05. Graphs\inputs\store_data", replace

***************************************************************************************
  log close

* ********************************************************************************
* ********************************************************************************
* Create the Master Survey Dataset
* ********************************************************************************
* ********************************************************************************
* author: Shelley Li
* date: March 5, 2017
* purpose: create master survey dataset
* ********************************************************************
* ********************************************************************************
* Inputs: C. Master Dataset\input
* Outputs: C. Master Dataset\output
* Steps
	* 1. Import treatment indicator
	* 2. Import "best guesses" of the tenure measures
	* 3. Import data on TL change
	* 4. Append the Two Survey Datasets
* **************************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
	  cd "T:\Data Prep and Analyses\C. Master Dataset\programs\logs"
	  local c_date = c(current_date)
	  local c_time = c(current_time)
	  local c_time_date = "`c_date'"+"_" +"`c_time'"
	  local time_string = subinstr("`c_time_date'", ":", "_", .)
	  local time_string = subinstr("`time_string'", " ", "_", .)
	  log using log_`time_string', text

	* change into output folder
	  cd "T:\Data Prep and Analyses\C. Master Dataset\input"

***************************************************************************************
* 1. Import treatment indicator
***************************************************************************************

	import excel using "T:\Data Prep and Analyses\C. Master Dataset\input\tr_indicator.xlsx", clear first
	replace shop=lower(shop)
	save tr_indicator.dta, replace
	
***************************************************************************************
* 2. Import "best guesses" of the tenure measures
***************************************************************************************

	*import best guesses for the pre-experimental survey
	
	import excel using "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\input\tenure_bestguess.xlsx", sheet ("bestguess_pre") first clear
	
	sort shop brand
	
	drop EmployeeName
	
	foreach var in tenure_survey tenure_QB tenure_bestguess {
	by shop brand: egen ave`var'=mean(`var')
	replace `var'=ave`var'
	drop ave`var'
	}
	
	duplicates drop shop brand, force
	
	gen post=0
	
	save bestguess_pre, replace
	
	*import best guesses for the post-experimental survey
	
	import excel using "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\input\tenure_bestguess.xlsx", sheet ("bestguess_post") first clear
	
	sort shop brand
	
	drop EmployeeName_ID EmployeeID
	
	foreach var in tenure_survey tenure_QB tenure_bestguess {
	by shop brand: egen ave`var'=mean(`var')
	replace `var'=ave`var'
	drop ave`var'
	}
	
	duplicates drop shop brand, force
	
	gen post=1
	
	save bestguess_post, replace
	
	*append the "best guesses" files
	append using bestguess_pre
	
	sort shop brand post
	
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted: private information on store names
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
	save bestguess, replace
	
	***COMMENT: WE DID NOT USE THE "BESTGUESS" DATA IN OUR FINAL REGRESSION
	
***************************************************************************************
* 3. Import data on manager (team leader) change
***************************************************************************************
	
	import excel using "T:\Data Prep and Analyses\B. Data Preparation\03. Surveys\input\tl_change.xlsx", clear first
	
	replace shop=lower(shop)
	sort shop
	save tl_change, replace
	
***************************************************************************************
* 4. Append the Two Survey Datasets
***************************************************************************************

	use "T:\Data Prep and Analyses\C. Master Dataset\input\presurvey.dta", clear
	append using "T:\Data Prep and Analyses\C. Master Dataset\input\PostSurvey.dta"
	
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted: include private information, e.g. store names
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	drop tenure_survey
	
	**merge with "best guesses" of tenure var
	sort shop brand post
	merge 1:1 shop brand post using bestguess
	drop _m
	
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	*redacted: include private information, e.g. store names
	*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	**merge with treatment indicator
	merge m:1 shop using tr_indicator
	drop if _m==2
	drop _m
	drop if tr==.
	
	**merge with data on TL changes
	sort shop
	merge m:1 shop using tl_change
	drop if _m==2
	drop _m

	* save data
	save master_survey, replace
	
	**GENERATE MEDIAN VALUES FOR TENURE_BESTGUESS TO FILL IN MISSING VALUES ON TENURE LATER
	keep shop brand post tenure_bestguess gender
	
	sort brand post
	by brand post: egen med_tenureBG_brand=median(tenure_bestguess)
	by brand post: egen ave_gender_brand=mean(gender)
	
	sort post
	by post: egen med_tenureBG=median(tenure_bestguess)
	by post: egen ave_gender=mean(gender)
	
	drop tenure_bestguess gender
	
	duplicates drop brand post, force
	save median_tenuregender_brand, replace 
	
	drop med_tenureBG_brand ave_gender_brand
	duplicates drop post, force
	save median_tenuregender, replace 
	
***************************************************************************************
	* end log
		log close
* ********************************************************************************
* ********************************************************************************
* Generate Datasets for Poster Analyses
* ********************************************************************************
* ********************************************************************************
* author: Shelley Li
* date: March 13, 2017
* purpose: Generate Datasets for Poster Analyses
* ********************************************************************
* ********************************************************************************
* Inputs: C. Master Dataset\input
* Outputs: C. Master Dataset\output
* Steps
	*1. Generate the dataset for the analyses that use poster data as DVs
	*2. Generate the Dataset for "Poster data as explanatory variables" Analyses
* **************************************************************************************

***************************************************************************************
* preliminaries
***************************************************************************************

	* start log
		cd "T:\Data Prep and Analyses\C. Master Dataset\programs\logs"
		local c_date = c(current_date)
		local c_time = c(current_time)
		local c_time_date = "`c_date'"+"_" +"`c_time'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using log_`time_string', text

	* change into working directory
		cd "T:\Data Prep and Analyses\C. Master Dataset\output"
		
****************************************************************************************
*1. Generate the dataset for the analyses that use poster data as DVs
****************************************************************************************
	
	*----------------------------------------------------------------------------------------
	*1.1 Prepare store data to be later merged with poster data for "poster data as DV" analyses
	*-----------------------------------------------------------------------------------------
		
		*load sales data
		use "T:\Data Prep and Analyses\C. Master Dataset\output\store_data.dta", clear
				
		sort shop week brand
		by shop week: gen n_brand=_N

		*keep the four weeks of data around each poster collection		
		gen Poster_month=7 if week>=tw(2016w26) & week<=tw(2016w29)
		replace Poster_month=8 if week>=tw(2016w31) & week<=tw(2016w34)
		replace Poster_month=10 if week>=tw(2016w37) & week<=tw(2016w40)
		replace Poster_month=12 if week>=tw(2016w49) & week<=tw(2016w52)
		drop if Poster_month==.
		
		*make the brand names consistent for later merging 
		*XXXXXXXXXXXXXXXXX
		*redacted
		*XXXXXXXXXXXXXXXXX
			
		keep shop brand n_brand Poster_month tenure_survey tenure_QB tenure_bestguess tenure_bg_brand tenure_bg_period TL_changed age gender gender_fmissing_brand gender_fmissing edu days n_promoters sqft store_age close_stores hodist market
		
		*generate the average of four weeks of data
		sort shop brand Poster_month
		foreach var in n_brand tenure_survey tenure_QB tenure_bestguess tenure_bg_brand tenure_bg_period TL_changed age gender gender_fmissing_brand gender_fmissing edu days n_promoters sqft store_age close_stores hodist {
		by shop brand Poster_month: egen average_`var'=mean(`var')
		replace `var'=average_`var'
		drop average_`var'
		}

		*keep unique shop-brand-poster collection observations
		duplicates drop shop brand Poster_month, force
		*save the temporary file for later merging
		save temp1, replace
		
		*----------------------------------------------------------------
		*1.2 prepare the survey data to be merged with the poster data 
		*----------------------------------------------------------------
		
		use "T:\Data Prep and Analyses\C. Master Dataset\output\master_survey.dta"
		drop tenure_survey age gender edu tr_notes tr tenure_QB tenure_bestguess pre_period_TL post_period_TL TL_changed
		sort shop brand post

		*save the temp file for later merging
		save temp2, replace
		
		*---------------------------------------------------------------------------------
		*1.3 merge the above sales file and survey data with the poster data
		*---------------------------------------------------------------------------------
		*load the poster data
		use "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\output\CustomerPanel_Dataset.dta", clear
		*rename var names for consistency across files 
		rename Store shop
		rename Brand brand
		rename Treatment tr
		
		*merge with store characteristics from the sales file "temp1"
		sort shop brand Poster_month
		merge m:1 shop brand Poster_month using temp1
		drop if _m==2
		drop _m
		
		*merge with survey data from temp2
		merge m:1 shop brand post using temp2
		drop if _m==2
		drop _m

		gen trxpost=tr*post
		
		**label variables
		label var tr "Info Sharing"
		label var post "Post"
		label var trxpost "Info Sharing x Post"
		label var n_promoters "# of promoters for the brand at the store"
		label var sqft "store physical size"
		label var store_age "store age"
		label var days "sales days"
		label var close_stores "# of nearby stores"
		label var hodist "distance to head office"
		label var tenure_survey "Tenure_Survey"
		label var tenure_bestguess "Tenure_BestGuess"
		label var TL_changed "TL Change"
		label var gender "Gender"
		label var age "Age" 
		label var edu "Education"
		
		*save the dataset
		save PosterData_DV, replace
		
**********************************************************************************************************
*2. Generate the Dataset for "Poster data as explanatory variables" Analyses
**********************************************************************************************************
		
	*--------------------------------------------------------------
	*2.1 Prepare poster data to be later merged with sales data
	*--------------------------------------------------------------
		*load poster data
		use "T:\Data Prep and Analyses\B. Data Preparation\01. Customer Panel Data\output\CustomerPanel_Dataset.dta", clear
		*rename for consistency across files
		rename Store shop
		rename Brand brand
				
		*collapse to the shop-brand-Poster_month level
		drop poster posterfilename Poster_author Poster_authorID Treatment
		order shop brand Poster_month
		sort shop brand Poster_month
		
		collapse (mean)Poster_clear-A_Useful_pctraters_female, by (shop brand Poster_month) 
				
		**Generate an overall quality score that incorporates both attractiveness and usefulness for table 7
		gen quality_rating=(Attractive_rating_bucket+Useful_rating_bucket)/2
		gen quality_rating_norm=(Attractive_rating_normalized+Useful_rating_normalized)/2
		gen A_quality_rating=(A_Attractive_rating_bucket+A_Useful_rating_bucket)/2
		gen A_quality_rating_norm=(A_Attractive_rating_normalized+A_Useful_rating_normalized)/2
		gen M_quality_rating=(M_Attractive_rating_bucket+M_Useful_rating_bucket)/2
		gen M_quality_rating_norm=(M_Attractive_rating_normalized+M_Useful_rating_normalized)/2
		
		**generate period-average, pre-period value, indicators on whether the pre-period value is above or below (equal to) the sample median
		foreach var in Attractive_rating_bucket Attractive_rating_normalized Useful_rating_bucket Useful_rating_normalized ///
						M_Attractive_rating_bucket M_Attractive_rating_normalized M_Useful_rating_bucket M_Useful_rating_normalized ///
						A_Attractive_rating_bucket A_Attractive_rating_normalized A_Useful_rating_bucket A_Useful_rating_normalized ///
						quality_rating quality_rating_norm A_quality_rating A_quality_rating_norm M_quality_rating M_quality_rating_norm{
		sort shop brand post
		by shop brand post: egen m`var'=mean(`var')
		by shop brand: gen p`var'=m`var'[1]
		sort post
		by post: egen md`var'=median(p`var')
		gen pm`var'=md`var'[1]
		gen am`var'=1 if p`var'>pm`var'
		replace am`var'=0 if p`var'<=pm`var'
		drop md`var' pm`var'
		}
		
		sort shop brand Poster_month
		*save shop-brand-collection level data for later merging
		save shop_brand_postermonth, replace
		
		**for later merge with the sales dataset (but only use the pre- and post-period averages of the poster data)
		sort shop brand post
		*keep unique shop-brand-experimental period observations
		duplicates drop shop brand post, force
		*save shop-brand-experimentalperiod level data for later merging
		save poster_shop_brand_post, replace
		
		**for later merge with the main sales dataset to import the indicators on whether pre-period value is above or below sample median
		keep shop brand am*
		duplicates drop shop brand, force
		save poster_preindicator, replace
		
	*----------------------------------------------------------------------------------
	*2.2. Merge the poster data with sales data (Merge with each collection of posters)
	*----------------------------------------------------------------------------------
		
		use "T:\Data Prep and Analyses\C. Master Dataset\output\store_data.dta", clear
		
		**only keep the 2 weeks leading up to each collection and the weeks after each collection (until 2 weeks leading up to the next collection)
		gen Poster_month=7 if week>=tw(2016w28) & week<=tw(2016w32)
		replace Poster_month=8 if week>=tw(2016w33) & week<=tw(2016w38)
		replace Poster_month=10 if week>=tw(2016w39) & week<=tw(2016w50)
		replace Poster_month=12 if week>=tw(2016w51) & week<=tw(2017w5)
		drop if Poster_month==.
			
		*merge with poster data at the shop-brand-collection level
		sort shop brand Poster_month
		merge m:1 shop brand Poster_month using shop_brand_postermonth
		drop if _m==2
		gen submit=1 if _m==3
		replace submit=0 if _m==1
		drop _m
				
		*save the sales dataset that uses each collection of the poster data as the explanatory variables
		save Sales_PosterData_EV, replace
	
	*--------------------------------------------------------------------------------------------------------------
	*2.3 Merge the poster data with sales data (with the average poster quality for the pre-and post-periods)
	*--------------------------------------------------------------------------------------------------------------
		*load data
		use "T:\Data Prep and Analyses\C. Master Dataset\output\store_data.dta", clear

		*merge with poster data at the shop-brand-experimentalperiod level
		sort shop brand post
		merge m:1 shop brand post using poster_shop_brand_post
		drop if _m==2
		drop _m
		
		drop am* Poster_month- M_quality_rating_norm
		*save the sales dataset that uses the pre- and post-period averages of the poster data as the explanatory variables
		save Sales_PosterData_EV_Average, replace
		
***************************************************************************************
* end log
log close
	***************************************************************************************
	*****Purpose: Generate Analyses Tables Listed in the Original Proposal *******
	*****Created by: Shelley Li
	*****Date: Feb 14, 2017
	*****Modifications by: Tatiana Sandino
	*****Date: Mar 19, 2017
	*****      Sept 13, 2017- Verified if we had more than one poster per shop-brand-month
	*****                     in the creativity regressions
	***************************************************************************************

	* start log
		cd "T:\Data Prep and Analyses\D. Analyses\02. Main Analysis\programs\logs"
		local c_date = c(current_date)
		local c_time = c(current_time)
		local c_time_date = "`c_date'"+"_" +"`c_time'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using log_`time_string', text
		
	* change into working directory
		cd "T:\Data Prep and Analyses\D. Analyses\02. Main Analysis\output"

	set more off
	
	*Choose tenure from the choices: tenure_survey tenure_bg_period tenure_bg_brand 
	local tenure="tenure_survey"

	*Choose gender from the choices: gender gender_fmissing gender_fmissing_brand
	local gender="gender"
	
	*Choose whether to exclude november or not: 
		*to exclude it choose exclnov="if nov==0" and exclnovinlist= "if nov==0 &"
		*to NOT exclude it choose exclnov="" and exclnovinlist= "if"
	local exclnov="if nov==0"
	local exclnovinlist= "if nov==0 &"
	
	****************************************************************************************
	******ANALYSES THAT USE THE MASTER SALES-ATTENDANCE DATASET store_data.dta**************
	******i.e. TABLES 1, 3, 6, 7, 10, TABLE 5 COLUMNS 1&2************************************
	****************************************************************************************
	
	* load the master file for sales-attendance-store characteristics
	use "T:\Data Prep and Analyses\C. Master Dataset\output\store_data.dta", clear
	
	merge m:1 shop using "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\output\shop_activeaccessfreq.dta"
	drop if _m==2
	drop _m
	
	merge m:1 shop using "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\output\shop_accessfreq.dta"
	drop if _m==2
	drop _m
	
	gen engagement= engagement1+engagement4+engagement2+engagement3
	gen quality= quality1+quality2+quality3
	
	
	*Keep the sales-analysis sample the same as the attendance-analysis sample
	keep if mattendance!=.
	
	qui: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	keep if e(sample)
	
	estpost sum lsales attendance tr post n_promoters sqft store_age days close_stores hodist tenure_survey gender lmsales mattendance accessfreq_active
	esttab,replace label cells("count mean sd min max")
	
	pwcorr lsales attendance tr post n_promoters sqft store_age days close_stores hodist tenure_survey gender lmsales mattendance accessfreq_active, sig
	
	
	*get descriptive stats for accessfreq
	summarize accessfreq accessfreq_active, detail
	tabulate accessfreq 
	
	pwcorr accessfreq accessfreq_active sales_tax attendance engagement quality, sig
	
	*--------------------------------------------------------------------------
	*Descriptive Statistics of Main Financial/Attendance Variables- Spot Errors
	*(NEW TATIANA CHANGES)
	*--------------------------------------------------------------------------
	*Summarize DV
	summarize sales_tax lsales attendance attendanceUC motivation ability, detail
	histogram lsales
	set more off
	graph save Graph "Histogram LnSales (Excludes sales less than or equal to 0).gph", replace
	histogram attendance
	set more off
	graph save Graph "Histogram Attendance (Setting attendance greater than 7 to 7).gph", replace
	histogram attendanceUC
	graph save Graph "Histogram Attendance Unconstrained.gph", replace


	* sales have been already restricted to be > 0 in "merge.do"
	
	*Summarize EV
	summarize n_promoters sqft store_age days close_stores hodist tenure_survey tenure_bestguess tenure_bg_period tenure_bg_brand gender gender_fmissing_brand gender_fmissing TL_changed lmsales mattendance age edu renovation monthbeforeclosing close_stores, detail
	tabulate market, missing
	
	***RED FLAGS AND RESOLUTIONS: 
	*n_promoters: large numbers, going up to 19- these had to be trainings, not promoters working at the stores
		*this was fixed to exclude promoters that showed up at a store that was not their home store
		*see explanations on attendance.do
	*days: we have some sales days equal to 9- weeks cannot have more than 7 days
		*clarified by Shelley and Kyle, this is just based on Stata convention (accomodating the last week of the year)
		*we cap days at 7 in the program merge.do
	*attendance: we had some attending more than 7 days a week. This is partly 		
		* but not entirely explained by the week 52 defined by Stata
		* We cap attendance at 7 in program merge.do
	*sqft: one of the stores appeared to be 15525 sqft big
		*there was a typo with DGJF which should have read 155.25 
		*this was fixed on the excel spreadsheet used as input
				
	label var `tenure' "Tenure" 
	label var `gender' "Gender"

	*----------------------------------------------
	*Table 1 - Financial Performance and Engagement
	*----------------------------------------------
	
	eststo clear
	
	*Financial performance
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	*Attendance
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnov', vce (cluster shop) ul(7)
		
	*show formatted table results directly in the command window
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	*export formatted table results into a csv file that can be opened and editted in Excel
	esttab using table1_sales-attendance.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")
    eststo clear

	*--------------------------------------------------------------------------------------
	*Table 2 - Financial Performance and Attendance: Split by Post_Early & Post_Late
	*--------------------------------------------------------------------------------------

	gen Post_Early=1 if week>=tw(2016w36) & week<=tw(2016w44)
	replace Post_Early=0 if Post_Early==.
	gen Post_Late=1 if week>=tw(2016w45) 
	replace Post_Late=0 if Post_Late==.
	gen trxPost_Early=tr*Post_Early
	gen trxPost_Late=tr*Post_Late

	eststo clear

	*Excluding Nov
	qui: eststo: xi: reg lsales tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	qui: eststo: xi: tobit attendance tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnov', vce (cluster shop) ul(7)

	esttab, replace b(4) r2 label ///
    keep(tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	esttab using table2_EarlyLate.csv, replace b(4) r2 label ///
    keep(tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr Post_Early Post_Late trxPost_Early trxPost_Late n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

    eststo clear	
set more off
	*-------------------------------------------------------------------------------------------------
	*Table 3 (Prev Table 9) - Financial Performance and Attendance: Contingent on Frequency of Access
	*--------------------------------------------------------------------------------------------------
	**Proposed Analysis
	replace accessfreq=0 if tr==0
	replace accessfreq_active=0 if tr==0 
	replace accessfreq=0 if tr==1 & post==0
	replace accessfreq_active=0 if tr==1 & post==0
	
	gen trxpostxaccessfreq=tr*post*accessfreq
	gen trxpostxactiveaccess=tr*post*accessfreq_active
	
	label var trxpostxaccessfreq "Info Sharing x Access to System x Post"
	label var trxpostxactiveaccess "Info Sharing x Active Access to System x Post"

	summarize accessfreq_active if(tr==1 & post==1 & lsales!=. & n_promoters!=.	& sqft!=. & store_age!=. & days!=. & close_stores!=. & hodist!=. & `tenure'!=. & `gender'!=.), detail 
		*Shows what stats I can save
		return list	
		gen mean_activeaccess=r(mean)
		gen med_activeaccess=r(p50)
		gen topQ_activeaccess=r(p75)
	
	bysort shop: egen shop_activeaccess=max(accessfreq_active)
	
	gen trHIaccess=(tr==1 & shop_activeaccess>med_activeaccess)
	gen trLOaccess=(tr==1 & shop_activeaccess<=med_activeaccess)
	gen trHIaccessxpost=trHIaccess*post
	gen trLOaccessxpost=trLOaccess*post
	
	label var trHIaccess "High Access"
	label var trLOaccess "Low Access"
	label var trHIaccessxpost "High Access x Post"
	label var trLOaccessxpost "Low Access x Post"
	
	eststo clear
	*qui: eststo: xi: reg lsales tr post trxpost trxpostxaccessfreq n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	*qui: eststo: xi: tobit attendance tr post trxpost trxpostxaccessfreq n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnov', vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnov', vce (cluster shop) ul(7)
	
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	esttab using table3_prev9_access_fin-att.csv, replace b(4) r2 label ///
    keep(tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")
	
	**Fixed effects

	eststo clear
	qui: eststo: xi: reg lsales post trxpost trxpostxactiveaccess i.shop i.brand `exclnov', vce (cluster shop)
	qui: eststo: xi: tobit attendance post trxpost trxpostxactiveaccess i.shop i.brand `exclnov', vce (cluster shop) ul(7)
	
	esttab, replace b(4) r2 label ///
    keep(post trxpost trxpostxactiveaccess) ///
    order(post trxpost trxpostxactiveaccess) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	esttab using table3__FEaccess_fin-att.csv, replace b(4) r2 label ///
    keep(post trxpost trxpostxactiveaccess) ///
    order(post trxpost trxpostxactiveaccess) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	eststo clear
	
	**Include in a single analysis above and below or equal to median 
	qui: eststo: xi: reg lsales trHIaccess trLOaccess post trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnov', vce (cluster shop)
	qui: eststo: xi: tobit attendance trHIaccess trLOaccess post trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnov', vce (cluster shop) ul(7)

	esttab, replace b(4) r2 label ///
    keep(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	esttab using table3_prev9_hiaccess_fin-att.csv, replace b(4) r2 label ///
    keep(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) ///
    order(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

    eststo clear	
	
	*---------------------------------------------------------------------------------
	*Table 4 (Prev Table 10)- Financial Performance: Robustness Check with Store Fixed Effects
	*---------------------------------------------------------------------------------
	
	**NOTE THAT N_PROMOTER ENDS UP NOT BEING ESTIMATED IN THESE REGRESISONS
	**SUGGESTING THAT THE FEW VARIATIONS IN THIS VARIBLE ARE PERHAPS ENTIRELY CONTROLLED VIA BRAND AND SHOP FIXED EFFECS
	
		
	eststo clear

	qui: eststo: xi: reg lsales post trxpost i.brand i.shop `exclnov', vce (cluster shop)
	qui: eststo: xi: tobit attendance post trxpost i.brand i.shop `exclnov', vce (cluster shop) ul(7)
	
	esttab, replace b(4) r2 label ///
    keep(post trxpost ) ///
    order(post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")

	esttab using table4_prev10_storeFE_exclcontrols.csv, replace b(4) r2 label ///
    keep(post trxpost ) ///
    order(post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Sales" "Attendance")
	
	eststo clear
	*------------------------------------------------------------------
	*Table 5 (Prev Table 6-8) - Financial Performance: Subsample Analysis
	*------------------------------------------------------------------
	
	**the median number of closeby stores is 2 - SEE the store characteristics data and do files
	**Use the main specification - i.e. excluding the November data
	
	
	sort shop brand
	merge m:1 shop brand using "T:\Data Prep and Analyses\C. Master Dataset\output\poster_preindicator.dta"
	drop if _m==2
	drop _m
	
		
	eststo clear
	*6.1 More vs Fewer Nearby Stores - Original Survey Measures
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' close_stores<=2, vce (cluster shop)
	*6.2 High vs Low Creative Talent - Original Survey Measures
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' amquality_rating==1, vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' amquality_rating==0, vce (cluster shop)
	*6.3 Mainstream vs Divergent markets
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales i.brand `exclnovinlist' market=="divergent", vce (cluster shop)

	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")

	esttab using table5_fin_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' lmsales) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")

	eststo clear

	
	*FIXED EFFECTS VERSION
	eststo clear
	*6.1 More vs Fewer Nearby Stores - Original Survey Measures
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' close_stores<=2, vce (cluster shop)
	*6.2 High vs Low Creative Talent - Original Survey Measures
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' amquality_rating==1, vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' amquality_rating==0, vce (cluster shop)
	*6.3 Mainstream vs Divergent markets
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg lsales tr post trxpost  i.shop i.brand `exclnovinlist' market=="divergent", vce (cluster shop)

	esttab, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")

	esttab using table5_FEfin_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")

	eststo clear
	
	*------------------------------------------------------------------
	* Table 8 (Similar to Previous Table 6-8) - Attendance: Subsample Analysis
	*------------------------------------------------------------------
	
	*Exploratory analyses>> do this partition using attendance
	eststo clear

	*6.1 More vs Fewer Nearby Stores - Original Survey Measures
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' close_stores>2, vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' close_stores<=2, vce (cluster shop) ul(7)
	*6.2 High vs Low Creative Talent - Original Survey Measures
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' amquality_rating==1, vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' amquality_rating==0, vce (cluster shop) ul(7)
	*6.3 Mainstream vs Divergent markets
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' market=="mainstream", vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance i.brand `exclnovinlist' market=="divergent", vce (cluster shop) ul(7)

	*show formatted table results directly in the command window
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")
	
	esttab using table8_attend_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' mattendance) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "LowCreativeTalent" "Mainstream" "Divergent")

	eststo clear
	
	
	*FIXED EFFECTS VERSION
	eststo clear

	*6.1 More vs Fewer Nearby Stores - Original Survey Measures
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' close_stores>2, vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' close_stores<=2, vce (cluster shop) ul(7)
	*6.2 High vs Low Creative Talent - Original Survey Measures
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' amquality_rating==1, vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' amquality_rating==0, vce (cluster shop) ul(7)
	*6.3 Mainstream vs Divergent markets
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' market=="mainstream", vce (cluster shop) ul(7)
	qui: eststo: xi: tobit attendance tr post trxpost  i.shop i.brand `exclnovinlist' market=="divergent", vce (cluster shop) ul(7)

	*show formatted table results directly in the command window
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "Low Creative Talent" "Mainstream" "Divergent")
	
	esttab using table8_FEattend_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creative Talent" "LowCreativeTalent" "Mainstream" "Divergent")

	eststo clear
	
	****************************************************************************************
	******ANALYSES THAT USE THE POSTER VARIABLES AS DVs "PosterData_DV.dta"****************
	******i.e. TABLES 2 & 5 COLUMNS 3&4 ****************************************************
	****************************************************************************************
	
	*--------------------------------------------
	*Table 1 - Quality of Creative Work
	*--------------------------------------------
	
	*load the poster data as DV dataset
	use "T:\Data Prep and Analyses\C. Master Dataset\output\PosterData_DV.dta", clear	
		*TATIANA: THIS DATASET COMES FROM 03. Prepare Poster Datasets.do 
		*		  AND ADDS STORE MEASURES TO THE POSTER RATINGS, USING 
		*		  AVERAGES BASED ON THE 4 WEEKS SURROUNDING THE POSTER
		*		  COLLECTION.	
	merge m:1 shop using "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\output\shop_activeaccessfreq.dta"
	drop if _m==2
	drop _m
	merge m:1 shop using "T:\Data Prep and Analyses\B. Data Preparation\06. Poster System Data\output\shop_accessfreq.dta"
	drop if _m==2
	drop _m
				
	*local tenure="tenure_survey"
	*local gender="gender"

	gen engagement= engagement1+engagement4+engagement2+engagement3
	gen quality= quality1+quality2+quality3
	
	pwcorr accessfreq accessfreq_active engagement quality Useful_rating_bucket Attractive_rating_bucket, sig
	**as you can see, access frequency is positively and significantly correlated with survey_based engagement measures, with survey-based quality measures, 
	**and with poster quality measures from customer panels.
	**survey-based engagement measure is also positively and significantly correlated with poster quality measures
	
	bysort Poster_month tr: sum Useful_rating_bucket
	bysort Poster_month tr:sum Attractive_rating_bucket
	**not so much for the novelty measure
	
	bysort Poster_month: egen ave_value=mean(Useful_rating_bucket)
	bysort Poster_month: egen ave_novelty=mean(Attractive_rating_bucket)
	bysort Poster_month: egen sd_value=sd(Useful_rating_bucket)
	bysort Poster_month: egen sd_novelty=sd(Attractive_rating_bucket)
	gen value_fromMean=abs(Useful_rating_bucket-ave_value)
	gen value_SDfromMean=abs(Useful_rating_bucket-ave_value)/sd_value
	gen novelty_fromMean=abs(Attractive_rating_bucket-ave_novelty)
	gen novelty_SDfromMean=abs(Attractive_rating_bucket-ave_novelty)/sd_novelty
			
	*--------------------------------------
	*Analyses using the AVERAGE measures
	*--------------------------------------
	
	**generate pre-period average novelty and value data
	sort shop brand post
	by shop brand post: egen mAttractive=mean(Attractive_rating_bucket)
	by shop brand post: egen mAttractiveNorm=mean(Attractive_rating_normalized)
	by shop brand post: egen mUseful=mean(Useful_rating_bucket)
	by shop brand post: egen mUsefulNorm=mean(Useful_rating_normalized)
	
	by shop brand: gen pre_Attractive=mAttractive[1]
	by shop brand: gen pre_AttractiveNorm=mAttractiveNorm[1]
	by shop brand: gen pre_Useful=mUseful[1]
	by shop brand: gen pre_UsefulNorm=mUsefulNorm[1]
	
	**label vars
	label var pre_Attractive "Pre-Intervention Novelty of Creative Work"
	label var pre_Useful "Pre-Intervention Value of Creative Work"
	label var Poster_clear "Poster Image is Clear"
	label var Poster_multiple "Containing Multiple Poster Images"
	label var Useful_pctraters_langmiss "Value_Language Mismatch"
	label var Attractive_pctraters_langmiss "Novelty_Language Mismatch"
	
	
	qui: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist tenure_survey gender pre_Useful i.brand, vce (cluster shop)
	keep if e(sample)
	
	sum Useful_rating_bucket Attractive_rating_bucket pre_Useful pre_Attractive
	
	pwcorr Useful_rating_bucket Attractive_rating_bucket tr post n_promoters sqft store_age days close_stores hodist tenure_survey gender pre_Useful pre_Attractive accessfreq_active, sig

		
	*-------------------------------	
	* Table 1- Creativity Measures
	*-------------------------------
		
	eststo clear
	
	**Specified as proposed 
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand, vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")
	
	esttab using table1_poster.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")
	
	eststo clear
		
		*Check whether there is more than one poster per shop-brand-month in these regressions
		xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand, vce(cluster shop)
		predict attres, residual
		gen attresdummy=(attres!=.)
		bysort Poster_month shop brand attresdummy: gen poscount=_n
		count if poscount==1 & attresdummy==1
		count if poscount==2 & attresdummy==1
		count if poscount==3 & attresdummy==1
		count if poscount==4 & attresdummy==1
		count if poscount==5 & attresdummy==1 
		br Poster_month shop brand poscount attres Attractive_rating_bucket Useful_rating_bucket
		*ANSWER: YES, 64 observations correspond to cases where there was more than one poster per shop-brand-month;*/
	
	*-----------------------------------------------------------------
	* Table 3- Exploratory similar to Table 9: Contingent on Frequency of Access
	*-----------------------------------------------------------------
	**Proposed Analysis
	replace accessfreq=0 if tr==0
	replace accessfreq_active=0 if tr==0 
	replace accessfreq=0 if tr==1 & post==0
	replace accessfreq_active=0 if tr==1 & post==0
	
	gen trxpostxaccessfreq=tr*post*accessfreq
	gen trxpostxactiveaccess=tr*post*accessfreq_active
	
	label var trxpostxaccessfreq "Info Sharing x Access x Post"
	label var trxpostxactiveaccess "Info Sharing x Active Access x Post"

	summarize accessfreq_active if(tr==1 & post==1 & Useful_rating_bucket!=. & n_promoters!=. & sqft!=. & store_age!=. & days!=. & close_stores!=. & hodist!=. & `tenure'!=. & `gender'!=.), detail 
		*Shows what stats I can save
		return list	
		gen mean_activeaccess=r(mean)
		gen med_activeaccess=r(p50)
		gen topQ_activeaccess=r(p75)
	
	bysort shop: egen shop_activeaccess=max(accessfreq_active)

	gen trHIaccess=(tr==1 & shop_activeaccess>med_activeaccess)
	gen trLOaccess=(tr==1 & shop_activeaccess<=med_activeaccess)
	gen trHIaccessxpost=trHIaccess*post
	gen trLOaccessxpost=trLOaccess*post
	
	label var trHIaccess "High Access"
	label var trLOaccess "Low Access"
	label var trHIaccessxpost "High Access x Post"
	label var trLOaccessxpost "Low Access x Post"

	*Quality of creative work-

	eststo clear
	*qui: eststo: xi: reg Useful_rating_bucket tr post trxpost trxpostxaccessfreq n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand, vce (cluster shop)
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand, vce (cluster shop)
	*qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost trxpostxaccessfreq n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand, vce (cluster shop) 
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand, vce (cluster shop) 

	esttab, replace b(4) r2 label ///
    keep(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	esttab using table3_prev9_creative.csv, replace b(4) r2 label ///
    keep(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")
	eststo clear

	*Fixed Effects- Quality of creative work-

	eststo clear
	qui: eststo: xi: reg Useful_rating_bucket post trxpost trxpostxactiveaccess  i.shop i.brand, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket post trxpost trxpostxactiveaccess  i.shop i.brand, vce (cluster shop) 

	esttab, replace b(4) r2 label ///
    keep(post trxpost trxpostxaccessfreq trxpostxactiveaccess ) ///
    order(post trxpost trxpostxaccessfreq trxpostxactiveaccess ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	esttab using table3_FEaccess_creative.csv, replace b(4) r2 label ///
    keep(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess ) ///
    order(tr post trxpost trxpostxaccessfreq trxpostxactiveaccess ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")
	eststo clear
		
 	**Include a single analysis above and below or equal to the top quartile

	eststo clear
	
	qui: eststo: xi: reg Useful_rating_bucket trHIaccess trLOaccess post trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket trHIaccess trLOaccess post trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand, vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(tr post trxpost trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Useful" "Attractive")

	esttab using table3_freqaccess_creative.csv, replace b(4) r2 label ///
    keep(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) ///
    order(post trHIaccess trLOaccess trHIaccessxpost trLOaccessxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Useful" "Attractive")

	eststo clear

	*------------------------------------------------------------
	* Table 4-Exploratory analyses similar to Table 10
	*------------------------------------------------------------
	eststo clear

	*Shop and brand fixed effects
	*Including controls
	qui: eststo: xi: reg Useful_rating_bucket post trxpost n_promoters days `tenure' `gender' i.brand i.shop, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket post trxpost n_promoters days `tenure' `gender' i.brand i.shop, vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(post trxpost n_promoters days `tenure' `gender') ///
    order(post trxpost n_promoters days `tenure' `gender') nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	esttab using table4_storeFE_creative.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters days `tenure' `gender') ///
    order(tr post trxpost n_promoters days `tenure' `gender') nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	eststo clear

	*Shop and brand fixed effects
	*Excluding controls
	qui: eststo: xi: reg Useful_rating_bucket post trxpost i.brand i.shop if n_promoters!=. & days!=. & `tenure'!=. & `gender'!=., vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket post trxpost i.brand i.shop if n_promoters!=. & days!=. & `tenure'!=. & `gender'!=., vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(post trxpost ) ///
    order(post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	esttab using table4_storeFE_creative_exclcontrols.csv, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("Value" "Novelty")

	eststo clear
		
	*------------------------------------------------------------------
	* Exploratory similar to Table 6-8 - Subsamples
	*------------------------------------------------------------------
	**the median number of closeby stores is 2 - SEE the store characteristics data and do files
	**Use the main specification - i.e. excluding the November data
	
	sort shop brand
	merge m:1 shop brand using "T:\Data Prep and Analyses\C. Master Dataset\output\poster_preindicator.dta"
	drop if _m==2
	drop _m

	eststo clear
	
	**Useful- More vs Fewer Nearby Stores
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if close_stores<=2, vce (cluster shop)
	**Useful- High vs Low ex-ante Creative Talent
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if amquality_rating==1, vce (cluster shop) 
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if amquality_rating==0, vce (cluster shop) 
	*Useful- Mainstream vs Divergent
	qui: eststo: xi: reg  Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg  Useful_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful i.brand if market=="divergent", vce (cluster shop)
		
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' gender pre_Useful) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	esttab using table6_useful_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Useful) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	eststo clear
	
	**Attractive- More vs Fewer Nearby Stores
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if close_stores<=2, vce (cluster shop)
	**Attractive- High vs Low ex-ante Creative Talent
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if amquality_rating==1, vce (cluster shop) 
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if amquality_rating==0, vce (cluster shop) 
	*Attractive- Mainstream vs Divergent
	qui: eststo: xi: reg  Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg  Attractive_rating_bucket tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive i.brand if market=="divergent", vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	esttab using table7_attractive_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' `gender' pre_Attractive) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	eststo clear
		
	*FIXED EFFECTS VERSIONS
	
	eststo clear
	
	**Useful- More vs Fewer Nearby Stores
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost  i.shop i.brand if close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost  i.shop i.brand if close_stores<=2, vce (cluster shop)
	**Useful- High vs Low ex-ante Creative Talent
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost  i.shop i.brand if amquality_rating==1, vce (cluster shop) 
	qui: eststo: xi: reg Useful_rating_bucket tr post trxpost  i.shop i.brand if amquality_rating==0, vce (cluster shop) 
	*Useful- Mainstream vs Divergent
	qui: eststo: xi: reg  Useful_rating_bucket tr post trxpost  i.shop i.brand if market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg  Useful_rating_bucket tr post trxpost  i.shop i.brand if market=="divergent", vce (cluster shop)
		
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost n_promoters sqft store_age days close_stores hodist `tenure' gender ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0fc %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	esttab using table6_FEuseful_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	eststo clear
	
	**Attractive- More vs Fewer Nearby Stores
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost  i.shop i.brand if close_stores>2, vce (cluster shop)
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost  i.shop i.brand if close_stores<=2, vce (cluster shop)
	**Attractive- High vs Low ex-ante Creative Talent
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost  i.shop i.brand if amquality_rating==1, vce (cluster shop) 
	qui: eststo: xi: reg Attractive_rating_bucket tr post trxpost  i.shop i.brand if amquality_rating==0, vce (cluster shop) 
	*Attractive- Mainstream vs Divergent
	qui: eststo: xi: reg  Attractive_rating_bucket tr post trxpost  i.shop i.brand if market=="mainstream", vce (cluster shop)
	qui: eststo: xi: reg  Attractive_rating_bucket tr post trxpost  i.shop i.brand if market=="divergent", vce (cluster shop)
	
	esttab, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	esttab using table7_FEattractive_subsamples.csv, replace b(4) r2 label ///
    keep(tr post trxpost ) ///
    order(tr post trxpost ) nogap star(* 0.10 ** .05 *** 0.01) ///
    stats(N r2, fmt(%9.0f %9.4f) labels("Observations" "Adj. Rsq")) nonotes mtitle("More Nearby Stores" "Fewer Nearby Stores" "High Creativity" "Low Creativity" "Mainstream" "Divergent")
	
	eststo clear


	
	***************************************************************************************
	* end log
		log close

	
	
