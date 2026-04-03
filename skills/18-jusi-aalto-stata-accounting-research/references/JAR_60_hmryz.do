	

/*a. Stata Main tests*/

/*b.Stata Robust Main test*/

/*c.Non-GAAP Diff-in-diff*/

/*d.MDA main tests*/


/*e.MDA Robust*/
/*f.MDA Diff-in-Diff*/
/*g.replicate folsom*/

	
	
/*BEGIN:a. Stata Main tests*/
		
	

	 
	 
	
	/*****MgrForecast tests in paper*******/

	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\evgx.dta", clear

	set matsize 2000
	
	 /*column 1 table 3 panel b*/
	 regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar i.indyear, absorb(cik) vce(cl cik)

	   /*column 1 table 5*/
	gen x1=drdscorerrl*drnumest
	 
	  regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar drnumest x1 i.indyear, absorb(cik) vce(cl cik)
		test drdscorerrl+x1=0
	  
	  /*column 2 table 5*/
	 gen x2=drdscorerrl*drpio
	 
	  regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar drpio x2 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x2=0
	
	

	
	
		 /*column 2 table 6*/
	 gen x4=drdscorerrl*drdliq
	 
	  regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar drdliq x4 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x4=0

		   /*column 1 table 7*/
	 gen x5=drdscorerrl*loss
	 
	  regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar x5 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x5=0
	
	
		  /*column 2 table 7*/
	 gen x6=drdscorerrl*drroa
	 
	  regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar x6 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x6=0
	
	
		use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\rbax.dta", clear

	set matsize 2000
	
		   /*column 1 table 6*/
	 gen x3=drdscorerrl*drdbax
	 
	  regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar drdbax x3 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x3=0
	
	
	
	
	
	
	/****Non-GAAP tests in paper*****/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalrr_notmgr.dta", clear
	 
	  /*industry by year fixed effects and firm fixed effects*/

	set matsize 2000
	 
	/*column 2 table 3 panel b*/
	 regress edum drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise i.indyear, absorb(cik) vce(cl cik)

	 
	 
	 /*column 3 table 5*/
	 gen x1=drdscorerrl*drnumest
	  regress edum drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drnumest x1 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x1=0
	
	  /*column 4 table 5*/
	  gen x2=drdscorerrl*drpio
	  regress edum drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drpio x2 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x2=0
	

	
		 /*column 4 table 6*/
	gen x4=drdscorerrl*drdliq
	  regress edum drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drdliq x4 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x4=0

		   /*column 4 table 7*/
	gen x5=drdscorerrl*loss
	  regress edum drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise loss x5 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x5=0
	
		  /*column 5 table 7*/
	gen x6=drdscorerrl*drroa
	  regress edum drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drroa x6 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x6=0

	
	 
	 		use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\rbax.dta", clear

	set matsize 2000
	
	 	   /*column 3 table 6*/
	gen x3=drdscorerrl*drdbax
	  regress edum drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drdbax x3 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x3=0
	 
	 
	 
	 
	 
	 /***********************************************
	 INTERNET APPENDIX TABLES
	 ***********************************************/
	 
	 	 /**************** use pscore*****************/
	 	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\evgx.dta", clear
	  set matsize 2000
	  
	/*column 1 table IA1*/
  	 regress n_guid_e pscore   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar i.indyear, absorb(cik) vce(cl cik)

	 
	 
	 
	  use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalrr_notmgr.dta", clear
	 
	 
	 set matsize 2000
	 
	 
	/*column 2 table IA1*/
	 regress edum pscore drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise i.indyear, absorb(cik) vce(cl cik)

	 
	 
	 
	 
	 	  /************ orthogonalize to rbc***************/
	  
	 	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\evgx.dta", clear
	  set matsize 2000
	  /*column 1 table IA2*/
	  regress n_guid_e drdscorerrl_rbc   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar i.indyear, absorb(cik) vce(cl cik)

	 
	  use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalrr_notmgr.dta", clear
	 
	 
	 set matsize 2000
	 
	 
	/*column 2 table IA2*/
	 regress edum drdscorerrl_rbc  drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise i.indyear, absorb(cik) vce(cl cik)
	 
	 
	 
	 
	 
	 
	  /*****EPS v. GPS*****/
	 
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\evg1.dta", clear



	 
	 
	 /*industry by year fixed effects and firm fixed effects*/

	set matsize 2000

	/*column 1 table IA6*/
	 regress n_guid_g drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar i.indyear, absorb(cik) vce(cl cik)
	/*column  2 table IA6*/
	 regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar i.indyear, absorb(cik) vce(cl cik)


	 
	 

	
	
	
	
	
	
	
	
	
	
	
		 /****************mgr_forecast = restrict in sample of non-gaap issuers based on IBES********************************/
		 /*ibes edum=0*/
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\h1c.dta", clear



	 
	 
	 /*industry by year fixed effects and firm fixed effects*/

	set matsize 2000

	/*Column 1 of table IA7*/
	 regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar i.indyear, absorb(cik) vce(cl cik)
	 
	
	
	
	

	/*ibes edum=1*/
	
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\h1a.dta", clear



	 
	 
	 /*industry by year fixed effects and firm fixed effects*/

	set matsize 2000

	/*Column 2 of table IA7*/
	 regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar i.indyear, absorb(cik) vce(cl cik)
	 
	
	
	
	
	
	
	 
	 
	 
	 /*************gee data*****************/
	 
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalrr_notmgr.dta", clear
	 
	 
	 set matsize 2000
	 
	 
	 
	/*column 1 IA9*/
	 regress mgr_exclude drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise i.indyear, absorb(cik) vce(cl cik)

	 
	/*column 2 IA9*/
	  gen x1=drdscorerrl*drnumest
	  regress mgr_exclude drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drnumest x1 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x1=0
	
	
	/*column 3 IA9*/
	  gen x2=drdscorerrl*drpio
	  regress mgr_exclude drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drpio x2 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x2=0
	
	

	
	/*column 5 IA9*/
	gen x4=drdscorerrl*drdliq
	  regress mgr_exclude drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drdliq x4 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x4=0
	
	

	/*column 6 IA9*/
	gen x5=drdscorerrl*loss
	  regress mgr_exclude drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise loss x5 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x5=0
	
	
	/*column 7 IA9*/
	gen x6=drdscorerrl*drroa
	  regress mgr_exclude drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drroa x6 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x6=0


	 
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\bamz1.dta", clear
	 
	 
	 set matsize 2000
	 
		/*column 4 IA9*/
	gen x3=drdscorerrl*drdbax	
	  regress mgr_exclude drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drdbax x3 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x3=0
	
	
	 
	
		 

	 
	 
	 
	 
	 

	 
	 
	 /*****************control for number of standards******/
	  
	  use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\evgx.dta", clear

	set matsize 2000
	
	 /*column 1 table IA11*/
	 regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar drn i.indyear, absorb(cik) vce(cl cik)
	  
	 
	  use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalrr_notmgr.dta", clear
	 
	 
	 set matsize 2000
	 
	/*column 2 table IA11*/
	 regress edum drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drn i.indyear, absorb(cik) vce(cl cik)

	 
		 
	 
	 
	 /*********************firm average***********************/
	 	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\evgx.dta", clear
		set matsize 2000
	  /*column 1 table IA12*/
	  	regress n_guid_e drmean_dscore  drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar i.indyear,  vce(cl cik)
		est tab,  stats(r2_a)
	 

	 
	  use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalrr_notmgr.dta", clear
	 
	 
	 set matsize 2000
	 
	 
	/*column 2 table IA12*/
	 regress edum drmean_dscore drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise i.indyear,  vce(cl cik)
	 est tab,  stats(r2_a)
	 
	 
	 

	  


	 /******************recognition only standards************/
	 
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\ronly.dta", clear

	set matsize 2000
	
	 /*column 1 table IA? */
	 regress n_guid_e drdscorerrl_ronly   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar i.indyear, absorb(cik) vce(cl cik)


	
	
	
	/****Non-GAAP tests recognition only*****/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\ronly.dta", clear
	 
	  /*industry by year fixed effects and firm fixed effects*/

	set matsize 2000
	 
	/*column 2 table IA?*/
	 regress edum drdscorerrl_ronly drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise i.indyear, absorb(cik) vce(cl cik)

	 
	 


	 
	 
	 
	 
	 
	








	
	

	 




	 
	
		
/*END:a. Stata Main tests*/


/*BEGIN:b.Stata Robust Main test*/


 /****WITH FOG****/
 
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalxxxzabcdefzj_rob_fog_mgr1.dta", clear



	 set matsize 2000

	/*column 1 table IA10*/
	 regress n_guid_e drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar drfog_m i.indyear, absorb(cik) vce(cl cik)
	 
	 
	 
 
	  use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\finalxxxzabcdefzj_rob_fog.dta", clear



	 set matsize 2000
	 
	 /*column 2 table IA10*/
	 regress edum drdscorerrl drsize  drleverage drmtb drspecial   drstd_ret drbhar drintan lit neg_surprise drfog_m i.indyear, absorb(cik) vce(cl cik)


	 
/*END:b.Stata Robust Main test*/

/*BEGIN:c.Non-GAAP Diff-in-diff*/

	/*column 6 panel b table 8*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_formaxza.dta"  , clear


	gen x1=post
	gen x2=treat1
	gen x3=post*treat1


	regress adj1 i.year x3, absorb(sta) vce(cl sta) 
	
	
	
	
	
		/*column 1 panel b table 8*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_forma5xza.dta"  , clear




	gen x1=post
	gen x2=treat1
	gen x3=post*treat1
	gen id = _n


	regress adj1 i.year x3, absorb(cusip) vce(cl cusip) 
	
	
	
	
		/*column 2 panel b table 8*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_forma3xza.dta"  , clear




	gen x1=post
	gen x2=treat1
	gen x3=post*treat1
	gen id = _n


	regress adj1 i.year x3, absorb(cusip) vce(cl cusip) 



	/*column 3 panel b table 8*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_forma1xza.dta"  , clear




	gen x1=post
	gen x2=treat1
	gen x3=post*treat1
	gen id = _n


	regress adj1 i.year x3, absorb(cusip) vce(cl cusip) 
	
	
	
	
	/*column 4 panel b table 8*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_forma4xza.dta"  , clear




	gen x1=post
	gen x2=treat1
	gen x3=post*treat1
	gen id = _n


	regress adj1 i.year x3, absorb(cusip) vce(cl cusip) 


	

	/*column 5 panel b table 8*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\apro_forma2xza.dta"  , clear




	gen x1=post
	gen x2=treat1
	gen x3=post*treat1
	gen id = _n


	regress adj1 i.year x3, absorb(cusip) vce(cl cusip) 






	

	/*column 1 Table IA8*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\f2ax.dta"  , clear




	gen x1=post
	gen x2=treat1
	gen x3=post*treat1
	gen id = _n


	regress adj1 i.year x3, absorb(cusip) vce(cl cusip) 



/*END:c.Non-GAAP Diff-in-diff*/


/*BEGIN: d.MDA main tests*/

	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zj.dta", clear



	 
	 /*industry by year fixed effects and firm fixed effects*/

	set matsize 2000

	/*column 3 and 4 table 3*/
	 regress llen drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog i.indyear, absorb(cik) vce(cl cik)
	 regress mfog drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk  i.indyear, absorb(cik) vce(cl cik)


	 /*column 5 and 7 table 5*/
	 gen x1=drdscorerrl*drnumest
	 
	  regress llen drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog drnumest x1 i.indyear, absorb(cik) vce(cl cik)
	  test drdscorerrl+x1=0
	 regress mfog drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk  drnumest x1 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x1=0
	 
	 
	  
	  /*column 6 and 8 table 5*/
	 gen x2=drdscorerrl*drpio
	 
	  regress llen drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog drpio x2 i.indyear, absorb(cik) vce(cl cik)
	  test drdscorerrl+x2=0
	 regress mfog drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk  drpio x2 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x2=0
	 










		 /*column 6 and 8 table 6*/
	 gen x4=drdscorerrl*drdliq
	 
	 regress llen drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog drdliq x4 i.indyear, absorb(cik) vce(cl cik)
	  test drdscorerrl+x4=0
	 regress mfog drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk  drdliq x4 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x4=0
	 

		    /*column 5 and 7 table 7*/
	 gen x5=drdscorerrl*loss
	 
	  regress llen drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog  x5 i.indyear, absorb(cik) vce(cl cik)
	  test drdscorerrl+x5=0
	 regress mfog drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk   x5 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x5=0


		  /*column 6 and 8 table 7*/
	 gen x6=drdscorerrl*drroa
	 
	   regress llen drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog  x6 i.indyear, absorb(cik) vce(cl cik)
	  test drdscorerrl+x6=0
	 regress mfog drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk   x6 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x6=0
	
	
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\Test Data\rbax1.dta", clear



	 
	 /*industry by year fixed effects and firm fixed effects*/

	set matsize 2000
	
		   /*column 5 and 7 table 6*/
	 gen x3=drdscorerrl*drdbax
	  regress llen drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog drdbax x3 i.indyear, absorb(cik) vce(cl cik)
	  test drdscorerrl+x3=0
	 regress mfog drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk  drdbax x3 i.indyear, absorb(cik) vce(cl cik)
	test drdscorerrl+x3=0
	 
	 
	 
		 /***********************************************
	 ROBUSTNESS
	 ***********************************************/
	 
	 
	 	  /* *******orthogonalize to rbc******/
	 
	   /*column 3 and 4 of Table IA2*/
	 regress llen drdscorerrl_rbc    drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog  i.indyear, absorb(cik) vce(cl cik)
	 regress mfog drdscorerrl_rbc   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk   i.indyear, absorb(cik) vce(cl cik)

	 
	 /*recognition only standards*/
	 
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\ronly1.dta", clear



	 
	 /*industry by year fixed effects and firm fixed effects*/

	set matsize 2000

	/*column 3 and 4 table IA?*/
	 regress llen drdscorerrl_ronly   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog i.indyear, absorb(cik) vce(cl cik)
	 regress mfog drdscorerrl_ronly   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk  i.indyear, absorb(cik) vce(cl cik)


	 	 
	 /* orthogonalize to length*/
	 
	 
	  /*column 3 and 4 of Table IA9*/
	 regress llen drdscorerrl_orth    drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog  i.indyear, absorb(cik) vce(cl cik)
	 regress mfog drdscorerrl_orth    drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk   i.indyear, absorb(cik) vce(cl cik)

	 
		 
	 
	 /***********using firm average dscore*/
	  
	  /*column 3 and 4 of Table IA12*/
	 regress llen drmean_dscore    drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog  i.indyear,  vce(cl cik)
	  est tab,  stats(r2_a)
	 regress mfog drmean_dscore   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk   i.indyear,  vce(cl cik)
	  est tab,  stats(r2_a)
 
	 
	 
		 

	 /* use pscore*/
 
	  /*column 3 and 4 table IA1*/
	 regress llen pscore    drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog  i.indyear, absorb(cik) vce(cl cik)
	 regress mfog pscore   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk   i.indyear, absorb(cik) vce(cl cik)

	 

/*END: d.MDA main tests*/

/*BEGIN:e.MDA Robust*/


	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zj_rob_fog.dta", clear



	 
	 /*industry by year fixed effects and firm fixed effects*/

	set matsize 2000


	 
	 /***********************************************
	 ROBUSTNESS
	 ***********************************************/
	 
	 
	 /****WITH FOG****/
	 
	 
	 set matsize 2000

	 
	 /*column 3 and 4 table IA10*/
	 regress llen drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog drfog_m i.indyear, absorb(cik) vce(cl cik)
	 regress mfog drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk  drfog_m i.indyear, absorb(cik) vce(cl cik)

	 
	   
	 /*****************control for number of standards******/
	    /*column 3 and 4 table IA11*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zj_roba.dta", clear
	 
	set matsize 2000

	 
	 regress llen drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk drmfog drn  i.indyear, absorb(cik) vce(cl cik)
	 regress mfog drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar llenk   drn i.indyear, absorb(cik) vce(cl cik)
	 
	 
	 
	 /******portfolio tests******/
	 
	 
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb3.dta", clear


	 
	 set matsize 2000

	 
	/*Column 1 of Table 4 Panel B*/
	 regress sum_dv1 drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar  i.indyear, absorb(cik) vce(cl cik)
	 
	 
	 
	 
	 /****0 or 1****/
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb4x.dta", clear
 

	 set matsize 2000
 
	/*Column 2 of Table 4 Panel B*/
	 regress vd1 drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar  i.indyear, absorb(cik) vce(cl cik)
	 
	 
	 
	 /****0 or 2****/
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb5x.dta", clear


	 set matsize 2000

	 
	/*Column 3 of Table 4 Panel B*/
	 regress vd2 drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar  i.indyear, absorb(cik) vce(cl cik)
	 
	  /****0 or 3****/
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb6x.dta", clear

 
	
	 set matsize 2000

	 
	/*Column 4 of Table 4 Panel B*/
	 regress vd3 drdscorerrl   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar  i.indyear, absorb(cik) vce(cl cik)
	 
	 
	 /*recognition only*/
	  /******portfolio tests******/
	 
	 
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb3xa.dta", clear


	 
	 set matsize 2000

	 
	/*Column 1 of Table 4 Panel B*/
	 regress sum_dv1 drdscorerrl_ronly   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar  i.indyear, absorb(cik) vce(cl cik)
	 
	 
	 
	 
	 /****0 or 1****/
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb4xxa.dta", clear
 

	 set matsize 2000
 
	/*Column 2 of Table 4 Panel B*/
	 regress vd1 drdscorerrl_ronly   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar  i.indyear, absorb(cik) vce(cl cik)
	 
	 
	 
	 /****0 or 2****/
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb5xxa.dta", clear


	 set matsize 2000

	 
	/*Column 3 of Table 4 Panel B*/
	 regress vd2 drdscorerrl_ronly   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar  i.indyear, absorb(cik) vce(cl cik)
	 
	  /****0 or 3****/
	 use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjb6xxa.dta", clear

 
	
	 set matsize 2000

	 
	/*Column 4 of Table 4 Panel B*/
	 regress vd3 drdscorerrl_ronly   drsize drroa drleverage drmtb drspecial loss drstd_ret drbhar  i.indyear, absorb(cik) vce(cl cik)
	 
	 
	 
	 
		
	 
	  

/*END:e.MDA Robust*/

/*BEGIN: f.MDA Diff-in-Diff*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\statamda3zjz.dta", clear


	gen x1=post
	gen x2=treat
	gen x3=post*treat
	gen id = _n

	/*column 5 of table 9*/
	 regress words i.year x3, absorb(sta) vce(cl sta) 

	regress words i.year x3 len drmfog, absorb(sta) vce(cl sta) 


	/*individual accounts*/
	/*123R*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\s1tatamda3zjz.dta", clear


	gen x1=post
	gen x2=treat
	gen x3=post*treat
	gen id = _n

	/*column 1 of table 9*/
	 regress words i.year x3, absorb(cusip) vce(cl cusip) 

	regress words i.year x3 len drmfog, absorb(cusip) vce(cl cusip) 
	/*142*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\s2tatamda3zjz.dta", clear


	gen x1=post
	gen x2=treat
	gen x3=post*treat
	gen id = _n

	/*column 2 of table 9*/
	 regress words i.year x3, absorb(cusip) vce(cl cusip)  


	regress words i.year x3 len drmfog,absorb(cusip) vce(cl cusip)  

	/*141a*/

	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\s3tatamda3zjz.dta", clear


	gen x1=post
	gen x2=treat
	gen x3=post*treat
	gen id = _n

	/*column 3 of table 9*/
	 regress words i.year x3, absorb(cusip) vce(cl cusip)  


	regress words i.year x3 len drmfog, absorb(cusip) vce(cl cusip)  
	/*146*/
	use "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\MDA\Data\s4tatamda3zjz.dta", clear


	gen x1=post
	gen x2=treat
	gen x3=post*treat
	gen id = _n

	/*column 4 of table 9*/
	 regress words i.year x3, absorb(cusip) vce(cl cusip) 

	regress words i.year x3 len drmfog, absorb(cusip) vce(cl cusip) 

/*END: f.MDA Diff-in-Diff*/

/*BEGIN:g.replicate folsom*/


	clear all
	set maxvar 15000
	set matsize 11000
	cd "C:\Users\spencery\OneDrive - University of Arizona\U of A\Projects\Rick Mergenthaler\Discretion and Disclosure\Tests\RR round 1\FOLSOM DATA"
	use finaldatawdscore1abz.dta, clear



	*****************************************
	* Returns / Forecast Error REGRESSIONS
	*****************************************


	/*Column 1 table IA3*/
	gen  x1=lrann_fcerr_lpricew*drdscorerrlf
	reg annret lrann_fcerr_lpricew drdscorerrlf x1 sizew fcerr_size lbtmw fcerr_btm leveragew fcerr_lev earn_volw fcerr_earnvol ret_volw fcerr_retvol busseg fcerr_busseg geoseg fcerr_geoseg i.fyear i.sic2, cluster(gvkey)
	 est tab, stats(r2_a)
	 
	 /*Column 2 table IA3*/
	 reg annret lrann_fcerr_lpricew drdscorerrlf x1 sizew fcerr_size lbtmw fcerr_btm leveragew fcerr_lev earn_volw fcerr_earnvol ret_volw fcerr_retvol busseg fcerr_busseg geoseg fcerr_geoseg i.fyear ,absorb(gvkey) cluster(gvkey)
	est tab, stats(r2_a)


	************************************
	* EARNINGS PERSISTENCE REGRESSIONS
	************************************


	/*my code*/
	gen  x2=earnw*drdscorerrlf
	/*Column 1 table IA4*/
	reg fearnw earnw drdscorerrlf x2 sizew earn_size lbtmw earn_btm leveragew earn_lev div earn_div age earn_age earn_volw earn_earnvol ret_volw earn_retvol busseg earn_busseg geoseg earn_geoseg i.fyear i.sic2, cluster(gvkey)
	est tab, stats(r2_a)
	/*Column 2 table IA4*/
	reg fearnw earnw drdscorerrlf x2 sizew earn_size lbtmw earn_btm leveragew earn_lev div earn_div age earn_age earn_volw earn_earnvol ret_volw earn_retvol busseg earn_busseg geoseg earn_geoseg i.fyear ,absorb(gvkey) cluster(gvkey)




	*********************************
	* FUTURE CASH FLOW REGRESSIONS
	*********************************


	/*Column 1 table IA5*/
	reg fcfow earnw drdscorerrlf x2 sizew earn_size lbtmw earn_btm leveragew earn_lev div earn_div age earn_age earn_volw earn_earnvol ret_volw earn_retvol busseg earn_busseg geoseg earn_geoseg i.fyear i.sic2, cluster(gvkey)
	 est tab, stats(r2_a)
	 /*Column 2 table IA5*/
	reg fcfow earnw drdscorerrlf x2 sizew earn_size lbtmw earn_btm leveragew earn_lev div earn_div age earn_age earn_volw earn_earnvol ret_volw earn_retvol busseg earn_busseg geoseg earn_geoseg i.fyear ,absorb(gvkey) cluster(gvkey)





/*END:g.replicate folsom*/






