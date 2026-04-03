/******************************************************************************/
/* Title:	Investment Dynamics and Earnings-Return Properties		 		  */
/* Authors: M. Breuer, D. Windisch       	                 	          	  */
/* Date:    11/19/2018                                                  	  */
/******************************************************************************/
/* Program description:														  */
/* Master do-file (setting directory & executing do-files)					  */
/******************************************************************************/

/* Directory (set to directory of folder) */
global directory `"..."'

/* Execute STATA do-files */

	/* 01 - Models (patterns in simulated data from base, accrual, and alternative models) */	
	cd "$directory\Code"	
	do 01-Models.do
	
	/* 02 - Compustat (patterns in Compustat data) */
	cd "$directory\Code"	
	do 02-Compustat.do

	/* 03 - Comparison graph (Figure 11) */
	cd "$directory\Code"	
	do 03-Comparison_Graph.do
/******************************************************************************/
/* Title:	Evaluation of Simulated Data from Dynamic Investment Model 		  */
/* Authors: M. Breuer, D. W. Windisch                        	          	  */
/* Date:    09/12/2017                                                  	  */
/******************************************************************************/
/* Program description:														  */
/* Generating Figures and Tables using simulated data						  */
/******************************************************************************/

/* Preliminaries */
version 13.1
clear all
set more off

/******************************************************************************/
/* Basic Model: Simulation data (based on calibrated parameter values)		  */
/******************************************************************************/

/* Directory */
cd "$directory\Code\Models\01-Basic model\Simulation\Data"

/* Data */
insheet using Simulations.csv, nonames clear

/* Time-series definition */

	/* Time dimension */
	gen t = _n
	label var t "Period"

	/* Set time series */
	tsset t
		
/* Model parameters */

	/* Discount rate (expected return) */
	local r = 0.1
	
	/* Persistence */
	local rho = 0.7
	
	/* Mean profitability */
	local mean = 1.5
	
/* Variables */

	/* Destring */
	qui destring v8, replace force
	
	/* Renaming model outputs */
	rename v1 earnings
	label var earnings "Earnings"

	rename v2 cash
	label var cash "Cash from Operations"

	rename v3 price
	label var price "Price"

	rename v4 profitability
	label var profitability "Profitability"

	rename v5 investment
	label var investment "Investment"

	rename v6 capital
	label var capital "Capital" // Note: Capital is beginning of period capital

	rename v7 adj_cost
	label var adj_cost "Adjustment cost"

	rename v8 surprise
	label var surprise "Surprise"
	
	/* Variable transformations */
	gen z = profitability - ((1-`rho')*`mean' + `rho'*l.profitability)
	label var z "Profitability shock"
	
	gen price_ex_div = price - cash + investment
	label var price_ex_div "Price (ex dividend)"

	gen ear = earnings/l.price_ex_div
	label var ear "Earnings(t)/Price(t-1)"

	gen l_ear = l.earnings/l.price_ex_div
	label var l_ear "Earnings(t-1)/Price(t-1)"
	
	gen cfo = cash/l.price_ex_div
	label var cfo "CFO(t)/Price(t-1)"

	gen ret = price/l.price_ex_div - (1 + `r')
	label var ret "Return"
	
	gen dear = d.earnings/l.price_ex_div
	label var dear "Change in Earnings/Price(t-1)"
	
	gen dear_c = d.earnings/capital
	label var dear "Change in Earnings/Capital(t-1)"
		
	gen fcapital = f.capital
	label var fcapital "Capital (t)"

	gen inv = investment/l.price_ex_div
	label var inv "Investment(t)/Price(t-1)"
	
	gen inv_price = 1/l.price_ex_div
	label var inv_price "1/Price(t-1)"

	gen mtb = price/capital
	label var mtb "Market-to-Book"	
	
	gen loss = (earnings < 0)
	label var loss "Loss"	
	
	gen d = (ret<0)
	label var d "Negative Return Indicator"
	
	gen d_earnings = (l.earnings < 0)
	label var d_earnings "Negative Earnings Indicator"
	
	gen d_dearnings = (l.d.earnings < 0)
	label var d_dearnings "Negative Earnings Change Indicator"
	
	gen d_dear = (l.dear < 0)
	label var d_dear "Negative Earnings Change/Price Indicator"
	
	gen d_dear_c = (l.dear_c < 0)
	label var d_dear_c "Negative Earnings Change/Capital Indicator"
		
	gen sue = surprise/l.price_ex_div
	label var sue "Earnings Surprise"
	
	gen abs_sue = abs(sue)
	label var sue "Absolute Earnings Surprise"
	
	/* AR(1) earnings surprise */
	qui reg earnings l.earnings
	qui predict sue_res, res
	label var sue_res "Earnings Surprise"

	gen sue_e = sue_res/l.price_ex_div
	label var sue_e "Earnings Surprise"	

/* Outlier treatment */

	/* Drop burn-in period */
	drop if t<=1000 | t>101000
	
	/* Drop extreme values (ensure positive value function) */
	drop if price < 0
	drop if abs(ret) > 1
	
/* Panel definition */
	
	/* Firm dimension */
	gen firm = ceil(t/25)
	label var firm "Firm"
	
	/* Set panel structure */
	xtset firm t
	
/* Endogenous split variables (by firm) */	

	/* Mean */
	egen mean_mtb = mean(mtb), by(firm)

	/* Standard deviation */
	egen sd_ear = sd(ear), by(firm)
	
/* Quintiles */
	
	/* Earnings volatility */
	xtile q_sd_ear = sd_ear, nq(5)
	
	/* Investment */
	xtile q_inv = investment, nq(5)

/* Persistence, earnings-response coefficient, and earnings-return asymmetry (by firm) */
 
	/* Placeholders */
	gen rho = .
	gen erc = .
	gen basu = .
	
	/* Loop */
	qui sum firm, d
	qui forvalues q = `r(min)'(1)`r(max)' {
		capture {
			/* Earnings persistence */
			reg earnings l.earnings if firm == `q'
			replace rho = _b[L.earnings] if firm == `q'
			
			/* Earnings response coefficient */
			reg ret sue if firm == `q'
			replace erc = _b[sue] if firm == `q'
			
			/* Earnings-return coefficient */
			reg ear c.ret##i.d if firm == `q'
			replace basu = _b[1.d#c.ret] if firm == `q'
			
		}
	}	
	
/* Leads and lags for future earnings-response coefficient regression */

	/* Earnings growth */
	gen x_0 = ln(earnings/l.earnings)
	gen x_1 = f1.x_0
	gen x_2 = f2.x_0
	gen x_3 = f3.x_0
	gen x_1_3 = exp(ln(1+x_1) + ln(1+x_2) + ln(1+x_3))-1 
	
	/* Returns */
	gen ret_1 = f1.ret
	gen ret_2 = f2.ret
	gen ret_3 = f3.ret
	gen ret_1_3 = exp(ln(1+ret_1) + ln(1+ret_2) + ln(1+ret_3))-1 

	/* Other */
	gen ep = l.earnings/l.price
	gen ag = ln(capital/l.capital)	
	
/* Save */
cd "$directory\Data\Output"
save Simulation, replace

/******************************************************************************/
/* Basic Model: Simulation data (based on varying parameter values)	  		  */
/******************************************************************************/

/* Directory */
cd "$directory\Code\Models\01-Basic model\Simulation\Data"

/* Data */
insheet using Predictions.csv,  clear

/* Variable names */

	/* Identifiers */
	rename v1 i
	label var i "Parameter"

	rename v2 j
	label var j "Step"

	/* Parameters */
	rename v3 p1
	rename v4 p2
	rename v5 p3
	rename v6 p4


	/* Destring */
	qui destring v*, replace force

	/* Coefficients */
	rename v7 ear_0
	label var ear_0 "Positive slope (Earnings)"

	rename v8 ear_1
	label var ear_1 "Incremental negative slope (Earnings)"

	rename v9 erc
	label var erc "Earnings-Response Coefficient"

	gen ear_2 = ear_0 + ear_1
	label var ear_2 "Negative slope (Earnings)"

	gen ear = ear_2 / (ear_0 + ear_2)
	label var ear "Share of negative slope (Earnings)"

/* Reshape */
egen ij=group(i j)
reshape long p, i(ij) j(parameter)

/* Paramter Values */
rename p values
label var values "Parameter Values"

label var parameter "Parameter"
label define parameter 1 "std_epsilon" 2 "psi" 3 "rho" 4 "r"
label values parameter parameter

/* Save */
cd "$directory\Data\Output"
save ComparativeStatics, replace

/******************************************************************************/
/* Alternative Models: Simulation data (based on calibrated parameter values) */
/******************************************************************************/

/* Model directories */
local directory_1 = "$directory\Code\Models\03-Model 1 (no delay, no adjustment cost)\Simulation\Data"
local directory_2 = "$directory\Code\Models\04-Model 2 (no adjustment cost)\Simulation\Data"
local directory_3 = "$directory\Code\Models\05-Model 3 (no delay)\Simulation\Data"

/* Loop over models */
forvalues i = 1(1)3 {

	/* Directory */
	cd "`directory_`i''"

	/* Data */
	if `i' == 1 {
		insheet using Simulations_nodelay_nocost.csv, nonames clear
	}
	
	if `i' == 2 {
		insheet using Simulations_nocost.csv, nonames clear
	}
	
	if `i' == 3 {
		insheet using Simulations_nodelay.csv, nonames clear
	}	
	
	/* Time-series definition */

		/* Time dimension */
		gen t = _n
		label var t "Period"

		/* Set time series */
		tsset t
		
	/* Variables */

		/* Destring */
		qui destring v8, replace force
		
		/* Renaming model outputs */
		rename v1 earnings
		label var earnings "Earnings"

		rename v2 cash
		label var cash "Cash from Operations"

		rename v3 price
		label var price "Price"

		rename v4 profitability
		label var profitability "Profitability"

		rename v5 investment
		label var investment "Investment"

		rename v6 capital
		label var capital "Capital" // Note: Capital is beginning of period capital

		rename v7 adj_cost
		label var adj_cost "Adjustment cost"

		rename v8 surprise
		label var surprise "Surprise"
		
		/* Variable transformations */
		gen z = profitability - ((1-`rho')*`mean' + `rho'*l.profitability)
		label var z "Profitability shock"
		
		gen price_ex_div = price - cash + investment
		label var price_ex_div "Price (ex dividend)"

		gen ear = earnings/l.price_ex_div
		label var ear "Earnings(t)/Price(t-1)"

		gen cfo = cash/l.price_ex_div
		label var cfo "CFO(t)/Price(t-1)"

		gen ret = price/l.price_ex_div - (1 + `r')
		label var ret "Return"
		
		gen dear = d.earnings/l.price_ex_div
		label var dear "Change in Earnings/Price(t-1)"
		
		gen dear_c = d.earnings/capital
		label var dear "Change in Earnings/Capital(t-1)"
			
		gen fcapital = f.capital
		label var fcapital "Capital (t)"

		gen inv_price = 1/l.price_ex_div
		label var inv_price "1/Price(t-1)"

		gen mtb = price/capital
		label var mtb "Market-to-Book"	
		
		gen loss = (earnings < 0)
		label var loss "Loss"	
		
		gen d = (ret<0)
		label var d "Negative Return Indicator"
		
		gen d_earnings = (l.earnings < 0)
		label var d_earnings "Negative Earnings Indicator"
		
		gen d_dearnings = (l.d.earnings < 0)
		label var d_dearnings "Negative Earnings Change Indicator"
		
		gen d_dear = (l.dear < 0)
		label var d_dear "Negative Earnings Change/Price Indicator"
		
		gen d_dear_c = (l.dear_c < 0)
		label var d_dear_c "Negative Earnings Change/Capital Indicator"
			
		gen sue = surprise/l.price_ex_div
		label var sue "Earnings Surprise"
		
		gen abs_sue = abs(sue)
		label var sue "Absolute Earnings Surprise"
		
		/* AR(1) earnings surprise */
		qui reg earnings l.earnings
		qui predict sue_res, res
		label var sue_res "Earnings Surprise"

		gen sue_e = sue_res/l.price_ex_div
		label var sue_e "Earnings Surprise"	

	/* Outlier treatment */

		/* Drop burn-in period */
		drop if t<=1000 | t>101000
		
		/* Drop extreme values (ensure positive value function) */
		drop if price < 0
		drop if abs(ret) > 1
		
	/* Panel definition */
		
		/* Firm dimension */
		gen firm = ceil(t/25)
		label var firm "Firm"
		
		/* Set panel structure */
		xtset firm t
		
	/* Endogenous split variables (by firm)*/	

		/* Mean */
		egen mean_mtb = mean(mtb), by(firm)

		/* Standard deviation */
		egen sd_ear = sd(ear), by(firm)

	/* Quintiles */
		
		/* Earnings volatility */
		xtile q_sd_ear = sd_ear, nq(5)
		
		/* Investment */
		xtile q_inv = investment, nq(5)
	
	/* Persistence, earnings-response coefficient, and earnings-return asymmetry (by firm) */
	 
		/* Placeholders */
		gen rho = .
		gen erc = .
		gen basu = .
		
		/* Loop */
		qui sum firm, d
		qui forvalues q = `r(min)'(1)`r(max)' {
			capture {
				/* Earnings persistence */
				reg earnings l.earnings if firm == `q'
				replace rho = _b[L.earnings] if firm == `q'
				
				/* Earnings response coefficient */
				reg ret sue if firm == `q'
				replace erc = _b[sue] if firm == `q'
				
				/* Earnings-return coefficient */
				reg ear c.ret##i.d if firm == `q'
				replace basu = _b[1.d#c.ret] if firm == `q'
				
			}
		}	
		
	/* Leads and lags for future earnings-response coefficient regression */

		/* Earnings growth */
		gen x_0 = ln(earnings/l.earnings)
		gen x_1 = f1.x_0
		gen x_2 = f2.x_0
		gen x_3 = f3.x_0
		gen x_1_3 = exp(ln(1+x_1) + ln(1+x_2) + ln(1+x_3))-1 
		
		/* Returns */
		gen ret_1 = f1.ret
		gen ret_2 = f2.ret
		gen ret_3 = f3.ret
		gen ret_1_3 = exp(ln(1+ret_1) + ln(1+ret_2) + ln(1+ret_3))-1 

		/* Other */
		gen ep = l.earnings/l.price
		gen ag = ln(capital/l.capital)	
			
	/* Save */
	cd "$directory\Data\Output"
	save Simulation_Model_`i', replace

/* End: loop over models */
}

/******************************************************************************/
/* Manuscript: Figures and Tables											  */
/******************************************************************************/

/* Log */
cd "$directory\Results\Models\Logs"
log using Manuscript, replace smcl name(Manuscript)
	
/* 3. Economic model */	
	
	/* d. Policy function */	
	
		/* Figure 1: Capital and profitability */
			
			/* Data: Simulation */
			cd "$directory\Data\Output"
			use Simulation, clear
			
			/* Results Directory */
			cd "$directory\Results\Models\Figures"			
		
			/* Figure */
			graph twoway ///
				(lpolyci capital profitability, clcolor(black)) ///
				(lpolyci fcapital profitability, clcolor(black) clpattern(dash)) ///
				, legend(label(2 "Capital (t)") label(4 "Capital (t+1)") rows(3) order(1 2 4) ring(0) position(11) bmargin(medium) symxsize(5)) /// 
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xtitle("Profitability (t)") ///
				xline(1.5, lcolor(gs10) lpattern(dash)) ///
				ylabel(, format(%9.0f) angle(0)) /// 				
				title("Capital and Profitability", color(black)) ///
				name(Figure_1, replace) saving(Figure_1, replace)
	
		/* Figure 2: Impulse response of investment and capital with respect to profitability shocks */

			/* IRF investment */
			qui var investment profitability, lags(1/10)
			qui irf create irf, set(irf, replace)
			irf graph irf ///
				, impulse(profitability) response(investment) ///
				legend(label(1 "CI 95%") label(2 "Impulse Response Function") rows(1) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Impulse Response: Profitability and Investment", color(black)) ///
				name(IRF_Investment, replace)
	
			/* IRF capital */
			qui var capital profitability, lags(1/10)
			qui irf create irf, set(irf, replace)
			irf graph irf ///
				, impulse(profitability) response(capital) ///
				legend(label(1 "CI 95%") label(2 "Impulse Response Function") rows(1) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Impulse Response: Profitability and Capital", color(black)) ///
				name(IRF_Capital, replace)
	
			/* Combined figure */
			graph combine IRF_Investment IRF_Capital, ///
				altshrink cols(3)  ysize(4) xsize(10) ///
				title("Investment and Capital Dynamics", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_2, replace)	saving(Figure_2, replace)	
		
/* 4. Model predictions */

	/* a. Distributions */
	
		/* Figure 3: Histograms of profitability, investment, earnings, and returns */
		
			/* Profitability */
			hist profitability ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Profitability Levels", color(black)) ///
				ylabel(, format(%9.1f) angle(0)) /// 								
				name(Profitability, replace)

			/* Investment */				
			hist investment ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Investment Levels", color(black)) ///
				ylabel(, format(%9.2f) angle(0)) /// 												
				name(Investment, replace)
	
			/* Earnings */
			hist earnings ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Earnings Levels", color(black)) ///
				ylabel(, format(%9.3f) angle(0)) /// 								
				name(Earnings, replace)
	
			/* Returns */
			hist ret ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Returns", color(black)) ///
				ylabel(, format(%9.0f) angle(0)) /// 								
				name(Returns, replace)

			/* Combined figure */
			graph combine Profitability Investment Earnings Returns, ///
				altshrink cols(4) ysize(4) xsize(15) ///
				title("Profitability, Investment, Earnings, and Returns", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_3, replace) saving(Figure_3, replace)
	
		/* Figure 4: Histograms of price and earnings scaled by lagged price */
	
			/* Price */
			hist price ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Price Levels", color(black)) ///
				ylabel(, format(%9.3f) angle(0)) /// 
				name(Price, replace)
			
			/* Earnings scaled by lagged price */
			hist ear ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Scaled Earnings", color(black)) ///
				ylabel(, format(%9.0f) angle(0)) /// 								
				name(Earnings_Scaled, replace)
				
			/* Combined figure */
			graph combine Price Earnings_Scaled, ///
				altshrink cols(2) ysize(4) xsize(10) ///
				title("Price and Scaled Earnings", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_4, replace)	saving(Figure_4, replace) 	
				
	/* b. Persistence of earnings levels and changes */
	
		/* Table 3: Differential persistence */
		
			/* Column 1: Earnings persistence */
			qui xtreg earnings c.l.earnings##1.d_earnings, fe cluster(firm)
				est store M1
				
			/* Column 2: Earnings change persistence */
			qui xtreg d.earnings c.l.d.earnings##1.d_dearnings, fe cluster(firm)
				est store M2
		
			/* Column 3: Earnings change (scaled by price) persistence (Basu (1997)) */
			qui xtreg dear c.l.dear##1.d_dear, fe cluster(firm)
				est store M3		
		
			/* Column 4: Earnings change (scaled by capital) persistence (Ball/Shivakumar (2005)) */
			qui xtreg dear_c c.l.dear_c##1.d_dear_c, fe cluster(firm)
				est store M4			

			/* Combined table */
			estout M1 M2 M3 M4, keep(L.earnings 1.d_earnings 1.d_earnings#cL.earnings LD.earnings 1.d_dearnings 1.d_dearnings#cLD.earnings ///
				L.dear 1.d_dear 1.d_dear#cL.dear L.dear_c 1.d_dear_c 1.d_dear_c#cL.dear_c) ///
				cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(L.earnings "E (t-1)" 1.d_earnings "D(E (t-1) < 0)" 1.d_earnings#cL.earnings "E*D(E < 0)" ///
				LD.earnings "d.E (t-1)" 1.d_dearnings "D(d.E < 0)" 1.d_dearnings#cLD.earnings "d.E*D(d.E < 0)" ///
				L.dear "d.E/P (t-1)" 1.d_dear "D(d.E/P < 0)" 1.d_dear#cL.dear "d.E/P*D(d.E/P < 0)" ///
				L.dear_c "d.E/K (t-1)" 1.d_dear_c "D(d.E/K < 0)" 1.d_dear_c#cL.dear_c "d.E/K*D(d.E/K < 0)") ///
				mlabels("[1] Earnings" "[2] d.Earnings" "[3] d.Earnings/Price" "[4] d.Earnings/Capital")  modelwidth(20) unstack ///
				title("Table 3: Asymmetric Earnings Persistence") ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
		
	/* c. Earnings-response coefficient */
	
		/* Figure 5: Earnings-response  */
		
			/* Data: ComparativeStatics */
			cd "$directory\Data\Output"
			use ComparativeStatics, clear
			
			/* Discount rate */
			graph twoway ///
				(lpolyci erc values if parameter==4 & i==4, clcolor(black)), ///
						legend(off) ///
						ytitle("ERC") ///
						xtitle("Discount rate (r)") xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Discount, replace)	
						
			/* Persistence */
			graph twoway ///
				(lpolyci erc values if parameter==3 & i==3, clcolor(black)), ///
						legend(off) ///
						xtitle("Persistence (rho)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Persistence, replace)
						
			/* Data: Simulation */
			cd "$directory\Data\Output"
			use Simulation, clear
			
			/* Market-to-book */
			preserve
				
				/* Duplicates (by firm) */
				duplicates drop firm, force
				
				/* ERC and market-to-book */
				graph twoway (lpolyci erc mean_mtb, clcolor(black)) ///
					, legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xtitle("Market-to-Book (V/K)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
					name(ERC_MTB, replace)
					
			restore
			
			/* Results Directory */
			cd "$directory\Results\Models\Figures"

			/* Combined figure */
			graph combine ERC_Discount ERC_Persistence ERC_MTB, ///
				altshrink cols(3) ysize(4) xsize(10) ///
				title("Determinants of Earnings-Response Coefficients: Discount Rate, Persistence, and Market-to-Book", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_5, replace) saving(Figure_5, replace)	
		
		/* Table 4: Earnings-response coefficient */
		
			/* ERC */
			qui xtreg ret sue, fe cluster(firm)
				est store M1
				
			/* Cross-sectional determinants */
			qui xtreg ret sue c.sue##c.rho c.sue##c.abs_sue c.sue##c.mtb c.sue##1.loss, fe cluster(firm)
				est store M2
				
			/* Output table */
			estout M1 M2, keep(sue c.sue#c.rho abs_sue c.sue#c.abs_sue mtb c.sue#c.mtb 1.loss 1.loss#c.sue) ///
				cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(c.sue "UE" c.sue#c.rho "UE*Persistence" abs_sue "|UE|" c.sue#c.abs_sue "UE*|UE|" mtb "Market-to-Book" c.sue#c.mtb "UE*MTB" 1.loss "Loss" 1.loss#c.sue "UE*Loss") ///
				title("Table 4: Determinants of Earnings-Response Coefficient") ///								
				mlabels("[1] Return" "[2] Return")  modelwidth(20) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))							
		
		/* Figure 6: Shape of earnings-response coefficient */
		graph twoway ///
			(fpfitci ret sue , clcolor(black)) ///
			(fpfitci ret sue_e , clcolor(black) clpattern(dash)) ///
			, legend(label(2 "ERC (correct expectation)") label(4 "ERC (AR(1) expectation)") order(1 2 4) rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xtitle("Earnings Surprise (t)") ytitle("Return (t)") xlabel(, format(%9.1f)) ylabel(, format(%9.1f) angle(0)) ///
			title("Earnings-Response Coefficient", color(black)) ///
			name(Figure_6, replace) saving(Figure_6, replace)
			
		/* Table 5: Future earnings-response coefficient (Collins et al. (1994)) */
		
			/* Original firm-level specifications */
			qui xtreg ret x_0, fe cluster(firm)
				est store M1
				
			qui xtreg ret x_0 x_1 x_2 x_3, fe cluster(firm)
				est store M2
				
			qui xtreg ret x_0 x_1 x_2 x_3 ret_1 ret_2 ret_3 ep ag, fe cluster(firm)
				est store M3
	
			/* Current firm-level specification */
			qui xtreg ret x_0, fe cluster(firm)
				est store M4
				
			qui xtreg ret x_0 x_1_3, fe cluster(firm)
				est store M5			
			
			qui xtreg ret x_0 x_1_3 ret_1_3 ep ag, fe cluster(firm)
				est store M6
				
			/* Output table */
			estout M1 M2 M3, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(x_0 "X (t)" x_1 "X (t+1)" x_2 "X (t+2)" x_3 "X (t+3)" ret_1 "R (t+1)" ret_2 "R (t+2)" ret_3 "R (t+3)" ep "EP (t-1)" ag "AG (t)") ///
				title("Table 5: Future Earnings-Response Coefficient (Original Specification)") ///				
				mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Original Model")  modelwidth(20) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))

			estout M4 M5 M6, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(x_0 "X (t)" x_1_3 "X (t+1 to t+3)" ret_1_3 "R (t+1 to t+3)" ep "EP (t-1)" ag "AG (t)") ///
				title("Table 5: Future Earnings-Response Coefficient (Current Specification)") ///								
				mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Current Model")  modelwidth(20) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
				
	/* d. Earnings-return asymmetry */
	
		/* Figure 7: Earnings-return concavity */
		
			/* Earnings levels */
			graph twoway ///
				(fpfitci earn ret, clcolor(black)) ///
				, legend(label(2 "Earnings") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Basu_level, replace)
			
			/* Earnings scaled by lagged price */
			graph twoway ///
				(fpfitci ear ret, clcolor(black)) ///
				, legend(label(2 "Earnings/Price") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.1f) angle(0)) ///
				name(Basu, replace)
				
			/* Combined figure */	
			graph combine Basu_level Basu, ///
				altshrink cols(2) ysize(4) xsize(10) ///
				title("Earnings-Return Concavity", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_7, replace) saving(Figure_7, replace)
				
		/* Untabulated: Placebo test */
			
			/* Lagged earnings */
			qui xtreg l_ear c.ret##i.d, fe cluster(firm)
			
			/* Output */
			estout, keep(ret 1.d 1.d#c.ret) ///
				cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(ret "Return" 1.d "D(Return<0)" 1.d#c.ret "Return*D(Return<0)") ///
				title("Untabulated: Placebo Test with Lagged Earnings/Price") ///								
				modelwidth(40) mlabels("Earnings(t-1)/Price(t-1)") ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))				
					
		/* Figure 8: Channels */
		
			/* Earnings-news */
			graph twoway ///
				(fpfitci earnings z, clcolor(black)) ///
				(lfit earnings z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Earnings") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.0f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Earnings_news, replace)			
			
			/* Adjustment costs-news (note: small in terms of magnitude) */
			graph twoway ///
				(fpfitci adj_cost z, clcolor(black)) ///
				, legend(label(2 "Adjustment costs") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.0f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Adj_cost_news, replace)	
			
			/* Return-news */
			graph twoway ///
				(fpfitci ret z, clcolor(black)) ///
				(lfit ret z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Returns") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.0f)) ylabel(, format(%9.1f) angle(0)) ///
				name(Return_news, replace)
				
			/* Combined figure */	
			graph combine Earnings_news Adj_cost_news Return_news, ///
				altshrink cols(3) ysize(4) xsize(10) ///
				title("Relation of Earnings, Adjustment Costs, and Returns to Profitability Shocks (News)", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_8, replace)	saving(Figure_8, replace)	 			
				
		/* Figure 9: Other asymmetries */
			
			/* Profitability-returns */
			graph twoway ///
				(fpfitci profitability ret, clcolor(black)) ///
				(lfit profitability ret, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Profitability_returns, replace)			

			/* Profitability-news */			
			graph twoway ///
				(fpfitci profitability z, clcolor(black)) ///
				(lfit profitability z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///			
				name(Profitability_news, replace)
				
			/* Investment-returns */
			graph twoway ///
				(fpfitci investment ret, clcolor(black)) ///
				(lfit investment ret, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///			
				name(Investment_returns, replace)			
			
			/* Investment-returns */
			graph twoway ///
				(fpfitci investment z, clcolor(black)) ///
				(lfit investment z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///				
				name(Investment_news, replace)	
				
			/* Combined figure */	
			graph combine Profitability_returns Investment_returns Profitability_news Investment_news, ///
				altshrink cols(2) ysize(4) xsize(5) ///
				title("Relation of Profitability and Investment to Returns and Profitability Shocks (News)", color(black) size(medium)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_9, replace) saving(Figure_9, replace)	
			
	/* Results */	

		/* Table 6, Panel A: Earnings-return asymmetry and volatility */
		
			/* Loop across volatility quantiles */
			qui sum q_sd_ear, d
			qui forvalues q = `r(min)'/`r(max)' {

				/* Earnings-return asymmetry */
				reg ear c.ret##i.d if q_sd_ear == `q', cluster(firm)
				est store M`q'
					
			}

			/* Output table */
			estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") ///
				title("Table 6, Panel A: Earnings-Return Asymmetry and Volatility") ///												
				mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))
		
		/* Table 6, Panel B: Earnings-return asymmetry and investment */
		
			/* Loop across volatility quantiles */
			qui sum q_inv, d
			qui forvalues q = `r(min)'/`r(max)' {

				/* Earnings-return asymmetry */
				reg ear c.ret##i.d if q_inv == `q', cluster(firm)
				est store M`q'
					
			}

			/* Output table */
			estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") ///
				title("Table 6, Panel B: Earnings-Return Asymmetry and Investment") ///																
				mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
	
	/* Figure 10: Comparative Statics */
	
		/* Data: ComparativeStatics */
		cd "$directory\Data\Output"
		use ComparativeStatics, clear
			
		/* Basu */

			/* Volatility */
			graph twoway ///
				(lpolyci ear_1 values if parameter==1 & i==1, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Volatility (standard deviation of epsilon)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						title("Earnings-Return Concavity", color(black) size(vhuge)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_Volatility, replace)
						
			/* Adjustment Cost */			
			graph twoway ///
				(lpolyci ear_1 values if parameter==2 & i==2, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Adjustment Costs (psi)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_AdjCost, replace)				

			/* Persistence */
			graph twoway ///
				(lpolyci ear_1 values if parameter==3 & i==3, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Persistence (rho)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_Persistence, replace)
			
			/* Discount rate */			
			graph twoway ///
				(lpolyci ear_1 values if parameter==4 & i==4, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Discount rate (r)") xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_Discount, replace)

		/* ERC */

			/* Volatility */
			graph twoway ///
				(lpolyci erc values if parameter==1 & i==1, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Volatility (standard deviation of epsilon)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						title("Earnings-Response Coefficient", color(black) size(vhuge)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Volatility, replace)
						
			/* Adjustment Cost */			
			graph twoway ///
				(lpolyci erc values if parameter==2 & i==2, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Adjustment Costs (psi)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_AdjCost, replace)				

			/* Persistence */
			graph twoway ///
				(lpolyci erc values if parameter==3 & i==3, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Persistence (rho)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Persistence, replace)
			
			/* Discount rate */			
			graph twoway ///
				(lpolyci erc values if parameter==4 & i==4, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Discount rate (r)") xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Discount, replace)
			
			/* Results directory */
			cd "$directory\Results\Models\Figures"

			/* Combination */
			graph combine Basu_Volatility ERC_Volatility Basu_AdjCost ERC_AdjCost Basu_Persistence ERC_Persistence Basu_Discount ERC_Discount, ///
				rows(4) cols(2) altshrink ysize(10) xsize(10) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Comparative Statics", color(black) size(small)) ///
				name(Figure_10, replace) saving(Figure_10, replace)		
	
/* Log close */
log close Manuscript
	
/******************************************************************************/
/* Online Appendix: Figures and Tables										  */
/******************************************************************************/

/* Log */
cd "$directory\Results\Models\Logs"
log using Appendix, replace smcl name(Appendix)

/* Model comparison */

	/* Loop over models */
	forvalues i = 1(1)3 {

		/* Data */
		cd "$directory\Data\Output"
		use Simulation_Model_`i', clear	
		
		/* Results Directory */
		cd "$directory\Results\Models\Figures\Alternative Models"
		
		/* Model predictions */
		
			/* a. Distributions */
			
				/* Figure 3: Histograms of profitability, investment, earnings, and returns */
				
					/* Profitability */
					hist profitability ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Profitability Levels", color(black)) ///
						name(Profitability, replace)

					/* Investment */				
					hist investment ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Investment Levels", color(black)) ///
						name(Investment, replace)
			
					/* Earnings */
					hist earnings ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Earnings Levels", color(black)) ///
						name(Earnings, replace)
			
					/* Returns */
					hist ret ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Returns", color(black)) ///
						name(Returns, replace)

					/* Combined figure */
					graph combine Profitability Investment Earnings Returns, ///
						altshrink cols(4) ysize(4) xsize(15) ///
						title("Profitability, Investment, Earnings, and Returns", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_3_M`i', replace) saving(Figure_3_M`i', replace)
			
				/* Figure 4: Histograms of price and earnings scaled by lagged price */
			
					/* Price */
					hist price ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Price Levels", color(black)) ///
						name(Price, replace)
					
					/* Earnings scaled by lagged price */
					hist ear ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Scaled Earnings", color(black)) ///
						name(Earnings_Scaled, replace)
						
					/* Combined figure */
					graph combine Price Earnings_Scaled, ///
						altshrink cols(2) ysize(4) xsize(10) ///
						title("Price and Scaled Earnings", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_4_M`i', replace) saving(Figure_4_M`i', replace)		
						
			/* b. Persistence of earnings levels and changes */
			
				/* Table 3: Differential persistence */
				
					/* Column 1: Earnings persistence */
					qui xtreg earnings c.l.earnings##1.d_earnings, fe cluster(firm)
						est store M1
						
					/* Column 2: Earnings change persistence */
					qui xtreg d.earnings c.l.d.earnings##1.d_dearnings, fe cluster(firm)
						est store M2
				
					/* Column 3: Earnings change (scaled by price) persistence (Basu (1997)) */
					qui xtreg dear c.l.dear##1.d_dear, fe cluster(firm)
						est store M3		
				
					/* Column 4: Earnings change (scaled by capital) persistence (Ball/Shivakumar (2005)) */
					qui xtreg dear_c c.l.dear_c##1.d_dear_c, fe cluster(firm)
						est store M4			

					/* Combined table */
					estout M1 M2 M3 M4, keep(L.earnings 1.d_earnings 1.d_earnings#cL.earnings LD.earnings 1.d_dearnings 1.d_dearnings#cLD.earnings ///
						L.dear 1.d_dear 1.d_dear#cL.dear L.dear_c 1.d_dear_c 1.d_dear_c#cL.dear_c) ///
						cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(L.earnings "E (t-1)" 1.d_earnings "D(E (t-1) < 0)" 1.d_earnings#cL.earnings "E*D(E < 0)" ///
						LD.earnings "d.E (t-1)" 1.d_dearnings "D(d.E < 0)" 1.d_dearnings#cLD.earnings "d.E*D(d.E < 0)" ///
						L.dear "d.E/P (t-1)" 1.d_dear "D(d.E/P < 0)" 1.d_dear#cL.dear "d.E/P*D(d.E/P < 0)" ///
						L.dear_c "d.E/K (t-1)" 1.d_dear_c "D(d.E/K < 0)" 1.d_dear_c#cL.dear_c "d.E/K*D(d.E/K < 0)") ///
						mlabels("[1] Earnings" "[2] d.Earnings" "[3] d.Earnings/Price" "[4] d.Earnings/Capital")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
				
			/* c. Earnings-response coefficient */
			
				/* Figure 5: Earnings-response  (w/o comparative static/predictions part) */
					
					/* Market-to-book */
					preserve
						
						/* Duplicates (by firm) */
						duplicates drop firm, force
						
						/* ERC and market-to-book */
						graph twoway (lpolyci erc mean_mtb, clcolor(black)) ///
							, legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
							graphregion(color(white)) plotregion(fcolor(white)) ///
							xtitle("Market-to-Book (V/K)") ///
							name(Figure_5_M`i', replace) saving(Figure_5_M`i', replace)
							
					restore	
				
				/* Table 4: Earnings-response coefficient */
				
					/* ERC */
					qui xtreg ret sue, fe cluster(firm)
						est store M1
						
					/* Cross-sectional determinants */
					qui xtreg ret sue c.sue##c.rho c.sue##c.abs_sue c.sue##c.mtb c.sue##1.loss, fe cluster(firm)
						est store M2
						
					/* Output table */
					estout M1 M2, keep(sue c.sue#c.rho abs_sue c.sue#c.abs_sue mtb c.sue#c.mtb 1.loss 1.loss#c.sue) ///
						cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(sue "UE" c.sue#c.rho "UE*Persistence" abs_sue "|UE|" c.sue#c.abs_sue "UE*|UE|" mtb "Market-to-Book" c.sue#c.mtb "UE*MTB" 1.loss "Loss" 1.loss#c.sue "UE*Loss") ///
						title("Determinants of Earnings-Response Coefficient") ///
						mlabels("[1] Return" "[2] Return")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))									
				
				/* Figure 6: Shape of earnings-response coefficient */
				graph twoway ///
					(fpfitci ret sue, clcolor(black)) ///
					(fpfitci ret sue_e, clcolor(black) clpattern(dash)) ///
					, legend(label(2 "ERC (correct expectation)") label(3 "ERC (AR(1) expectation)") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xtitle("Earnings Surprise (t)") ytitle("Return (t)") ///
					title("Earnings Response Coefficient", color(black)) ///
					name(Figure_6_M`i', replace) saving(Figure_6_M`i', replace)
					
				/* Table 5: Future earnings-response coefficient (Collins et al. (1994)) */
				
					/* Original firm-level specifications */
					qui xtreg ret x_0, fe cluster(firm)
						est store M1
						
					qui xtreg ret x_0 x_1 x_2 x_3, fe cluster(firm)
						est store M2
						
					qui xtreg ret x_0 x_1 x_2 x_3 ret_1 ret_2 ret_3 ep ag, fe cluster(firm)
						est store M3
			
					/* Current firm-level specification */
					qui xtreg ret x_0, fe cluster(firm)
						est store M4
						
					qui xtreg ret x_0 x_1_3, fe cluster(firm)
						est store M5			
					
					qui xtreg ret x_0 x_1_3 ret_1_3 ep ag, fe cluster(firm)
						est store M6
						
					/* Output table */
					estout M1 M2 M3, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(x_0 "X (t)" x_1 "X (t+1)" x_2 "X (t+2)" x_3 "X (t+3)" ret_1 "R (t+1)" ret_2 "R (t+2)" ret_3 "R (t+3)" ep "EP (t-1)" ag "AG (t)") ///
						title("Future Earnings-Response Regressions (following Collins et al. (1994))") ///
						mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Original Model")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))

					estout M4 M5 M6, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(x_0 "X (t)" x_1_3 "X (t+1 to t+3)" ret_1_3 "R (t+1 to t+3)" ep "EP (t-1)" ag "AG (t)") ///
						title("Future Earnings-Response Regressions (Current Firm-Level Specification)") ///
						mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Current Model")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
						
			/* d. Earnings-return asymmetry */
			
				/* Figure 7: Earnings-return concavity */
				
					/* Earnings levels */
					graph twoway ///
						(fpfitci earn ret, clcolor(black)) ///
						, legend(label(2 "Earnings") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_level, replace)
					
					/* Earnings scaled by lagged price */
					graph twoway ///
						(fpfitci ear ret, clcolor(black)) ///
						, legend(label(2 "Earnings/Price") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu, replace)
						
					/* Combined figure */	
					graph combine Basu_level Basu, ///
						altshrink cols(2) ysize(4) xsize(10) ///
						title("Earnings-Return Concavity", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_7_M`i', replace) saving(Figure_7_M`i', replace)
					
				/* Figure 8: Channels */
				
					/* Earnings-news */
					graph twoway ///
						(fpfitci earnings z, clcolor(black)) ///
						(lfit earnings z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Earnings") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Earnings_news, replace)			
					
					/* Adjustment costs-news (note: small in terms of magnitude) */
					graph twoway ///
						(fpfitci adj_cost z, clcolor(black)) ///
						, legend(label(2 "Adjustment costs") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Adj_cost_news, replace)	
					
					/* Return-news */
					graph twoway ///
						(fpfitci ret z, clcolor(black)) ///
						(lfit ret z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Returns") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Return_news, replace)
						
					/* Combined figure */	
					graph combine Earnings_news Adj_cost_news Return_news, ///
						altshrink cols(3) ysize(4) xsize(10) ///
						title("Relation of Earnings, Adjustment Costs, and Returns" "to Profitability Shocks (News)", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_8_M`i', replace) saving(Figure_8_M`i', replace)				
						
				/* Figure 9: Other asymmetries */
					
					/* Profitability-returns */
					graph twoway ///
						(fpfitci profitability ret, clcolor(black)) ///
						(lfit profitability ret, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
						name(Profitability_returns, replace)			

					/* Profitability-news */			
					graph twoway ///
						(fpfitci profitability z, clcolor(black)) ///
						(lfit profitability z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
						name(Profitability_news, replace)
						
					/* Investment-returns */
					graph twoway ///
						(fpfitci investment ret, clcolor(black)) ///
						(lfit investment ret, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///						
						name(Investment_returns, replace)			
					
					/* Investment-returns */
					graph twoway ///
						(fpfitci investment z, clcolor(black)) ///
						(lfit investment z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///						
						name(Investment_news, replace)	
						
					/* Combined figure */	
					graph combine Profitability_returns Investment_returns Profitability_news Investment_news, ///
						altshrink cols(2) ysize(4) xsize(5) ///
						title("Relation of Profitability and Investment" "to Returns and Profitability Shocks (News)", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_9_M`i', replace) saving(Figure_9_M`i', replace)	
								
			/* Results */

				/* Table 6, Panel A: Earnings-return asymmetry and volatility */
				
					/* Loop across volatility quantiles */
					qui sum q_sd_ear, d
					qui forvalues q = `r(min)'/`r(max)' {

						/* Earnings-return asymmetry */
						reg ear c.ret##i.d if q_sd_ear == `q', cluster(firm)
						est store M`q'
							
					}

					/* Output table */
					estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") title("Earnings/Price Volatility")  ///
						mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))
				
				/* Table 6, Panel B: Earnings-return asymmetry and investment */
				
					/* Loop across volatility quantiles */
					qui sum q_inv, d
					qui forvalues q = `r(min)'/`r(max)' {

						/* Earnings-return asymmetry */
						reg ear c.ret##i.d if q_inv == `q', cluster(firm)
						est store M`q'
							
					}

					/* Output table */
					estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") title("Investment Levels")  ///
						mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))							
	
	/* End: model loop */
	}
	
/* Data */
cd "$directory\Data\Output"
use Simulation, clear	

/* Further Appendix Tables */

	/* Table A5: Asymmetries */
		
		/* Earnings levels */
		qui xtreg earnings c.ret##i.d, fe cluster(firm)
			est store M1
			
		/* Earnings scaled by lagged price */
		qui xtreg ear c.ret##i.d, fe cluster(firm)
			est store M2
			
		/* Cash flow */
		qui xtreg cash c.ret##i.d, fe cluster(firm)
			est store M3
			
		/* Cash flow scaled by lagged price */
		qui xtreg cfo c.ret##i.d, fe cluster(firm)
			est store M4
						
		/* Investment */
		qui xtreg investment c.ret##i.d, fe cluster(firm)
			est store M5
			
		/* Investment scaled by lagged price */
		qui xtreg inv c.ret##i.d, fe cluster(firm)
			est store M6

		/* Output table */
		estout M1 M2 M3 M4 M5 M6, keep(ret 1.d 1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
			legend label varlabels(ret "Return" 1.d "D(Return<0)" 1.d#c.ret "Return*D") title("Earnings, Cash Flow, And Investment Asymmetry")  ///
			mlabels("Earnings" "Earnings/Price" "Cash Flow" "Cash Flow/Price" "Investment" "Investment/Price")  modelwidth(8) unstack ///
			stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
		
	/* Table A6: Decomposition */	
			
		/* Firm-fixed effects decomposition */
		qui {
		
			/* Partialling firm effects out */
			xtreg ear d, fe
			predict r_ear, e

			xtreg ret d, fe
			predict r_ret, e
	
			/* Negative return partition: variance/covariance */
			corr r_ear r_ret if ret<0, cov
			local cov_neg = r(cov_12)
			local var_neg = r(Var_2)

			/* Positive return partition: variance/covariance */
			corr r_ear r_ret if ret>=0, cov
			local cov_pos = r(cov_12)
			local var_pos = r(Var_2)
		}
		
		/* Output */
		di "___________________________"
		di "Negative Return Partition"
		di "Return variance: " round(`var_neg',.0001)
		di "Earnings-Return covariance: " round(`cov_neg',.0001)
		di "___________________________"
		di "Positive Return Partition"
		di "Return variance: " round(`var_pos',.0001)
		di "Earnings-Return covariance: " round(`cov_pos',.0001)
		di "___________________________"
		di "Spreads/Differences (Negative - Positive)"
		di "Variance: " round(`var_neg'-`var_pos',.0001)
		di "Earnings-Return covariance: " round(`cov_neg'-`cov_pos',.0001)
	
/* Log: close */
log close Appendix

/******************************************************************************/
/* Accrual Model: Simulation data (based on calibrated parameter values)	  */
/******************************************************************************/

/* Directory */
cd "$directory\Code\Models\02-Accrual model\Simulation\Data"

/* Data */
insheet using SimulationsWorkingCapital.csv,  clear
save Simulation_workingcapital, replace

/* Time Series */
gen t = _n
label var t "Period"

tsset t

/* Variables */
rename v1 earnings
label var earnings "Earnings"

rename v2 cash
label var cash "Cash from Operations"

rename v3 price
label var price "Price"

rename v4 profitability
label var profitability "Profitability"

rename v5 investment
label var investment "Investment"

rename v6 capital
label var capital "Capital"

rename v7 adj_cost
label var adj_cost "Adjustment cost"

rename v8 working_capital
label var working_capital "Working Capital"

gen price_ex_div = price-cash+investment
label var price_ex_div "Price (ex dividend)"

gen ret = d.price/l.price_ex_div
label var ret "Return"

gen wc_accruals = d.working_capital
label var wc_accruals "Working Capital Accruals"

gen wca = wc_accruals/l.price_ex_div
label var wca "Working Capital Accruals(t)/Price(t-1)"

/* Outlier Treatment */
drop if t<=1000 | t>101000
drop if abs(ret)>1

/* Figure A1: Working Capital Accruals */

	/* Results Directory */
	cd "$directory\Results\Models\Figures"
	
	/* Graphs */
	graph twoway ///
		(fpfitci wca ret, clcolor(black)) ///
		, legend(label(2 "Working Capital Accruals(t)/Price(t-1)") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///	
		title("Working Capital Accruals and Returns", color(black)) ///
		name(Figure_A1, replace) saving(Figure_A1, replace)

/******************************************************************************/
/* Non-Parametric Comparison												  */
/******************************************************************************/

/* Figure A2: Simulated Patterns */

	/* Data */
	cd "$directory\Data\Output"
	use Simulation, clear
	
	/* Results Directory */
	cd "$directory\Results\Models\Figures"
	
	/* Graph 1: Earnings-Return Concavity */
	graph twoway ///
		(fpfitci ear ret, clcolor(black)) ///
		, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
		ytitle("Earnings/Price") ///
		xtitle("Return") ///		
		title("Earnings-Return Concavity", color(black)) ///
		name(Figure_A2_1, replace) saving(Figure_A2_1, replace)

	
	/* Graph 2: Concavity and Volatility*/
	preserve
	
		/* Drop duplicates */
		duplicates drop firm, force
		
		/* Graph */
		graph twoway (lpolyci basu sd_ear, clcolor(black)) ///
			, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
			ytitle("Earnings-Return Concavity") ///
			xtitle("Earnings Volatility") ///
			title("Earnings-Return Concavity and Earnings Volatility", color(black)) ///
			name(Figure_A2_2, replace) saving(Figure_A2_2, replace)
			
	restore
	
	/* Graph 3: ERC */
	graph twoway ///
		(fpfitci ret sue_e, clcolor(black)) ///
		, legend(label(1 "CI 95%") label(2 "ERC") order(1 2 4) rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
		ytitle("Return") ///
		xtitle("Earnings Surprise") ///
		title("Earnings-Response Coefficient", color(black)) ///
		name(Figure_A2_3, replace) saving(Figure_A2_3, replace)
	
	/* Graph 4: ERC and Volatilty */
	preserve
	
		/* Drop duplicates */
		duplicates drop firm, force
		
		/* Graph */
		graph twoway (lpolyci erc sd_ear, clcolor(black)) ///
			, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
			ytitle("ERC") ///
			xtitle("Earnings Volatility") ///
			title("ERC and Volatility", color(black)) ///
			name(Figure_A2_4, replace) saving(Figure_A2_4, replace)
	
	restore
	
	/* Graph 5: ERC and MTB */
	preserve
	
		/* Drop duplicates */
		duplicates drop firm, force
		
		/* Graph */
		graph twoway (lpolyci erc mean_mtb, clcolor(black)) ///
			, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///					
			ytitle("ERC") ///
			xtitle("Market-to-Book") ///
			title("ERC and Market-to-Book", color(black)) ///
			name(Figure_A2_5, replace) saving(Figure_A2_5, replace)
		
	restore
/******************************************************************************/
/* Title:   Evaluation of Model Predictions in Compustat Data                 */
/* Authors: M. Breuer, D. Windisch                                            */
/* Date:    11/29/2018                                                        */
/******************************************************************************/
/* Program description:                                                       */
/* Generates Figures and Tables using Compustat, CRSP, and I/B/E/S data       */
/******************************************************************************/

*Preliminaries*
version 13.1
clear all
set more off
set type double

********************************************************************************
*** Annual Return Calculation ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\CRSP_monthly.dta", clear
egen start = min(date), by(permno)
egen end   = max(date), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_CRSP_monthly.dta", replace

**Data**
use "$directory\Data\Original\CRSP_monthly.dta", clear

**Sample**

*Ordinary shares of stocks listed on NYSE, AMEX, or NASDAQ*
keep if shrcd == 10|shrcd == 11|shrcd == 12
keep if exchcd == 1|exchcd == 2|exchcd == 3

*Panel*
gen tradingdate = mofd(date)
xtset permno tradingdate, monthly

*Cumulative 1-year returns (at fiscal year end + 3m)*
gen r = ln(1+ret)
gen v = ln(1+vwretd)
gen ret1y = r
gen vwret1y = v
forvalues i = 1/11 {
	replace ret1y = ret1y+l`i'.r
	replace vwret1y = vwret1y+l`i'.v
}
replace ret1y = exp(f3.ret1y)-1
replace vwret1y = exp(f3.vwret1y)-1

*Market-adjusted 1-year returns*
gen aret1y = ret1y - vwret1y
label var aret1y "Market Adjusted Annual Return (-9 to +3)"

*Matchdate (year-month)*
gen matchdate = tradingdate

*Saving*
keep permno matchdate aret1y
save "$directory\Data\Output\annualreturns.dta", replace

********************************************************************************
*** Announcement Return Calculation ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\CRSP_daily", clear
egen start = min(date), by(permno)
egen end   = max(date), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_CRSP_daily.dta", replace

**Data**
use "$directory\Data\Original\CRSP_daily", clear

*Ordinary shares of stocks listed on NYSE, AMEX, or NASDAQ*
keep if shrcd == 10|shrcd == 11|shrcd == 12
keep if exchcd == 1|exchcd == 2|exchcd == 3

*Panel*
bcal create allshares, from(date) dateformat(dmy) replace
gen tradingdate = bofd("allshares", date)
format tradingdate %tballshares
xtset permno tradingdate

*Cumulative 3-day returns*
gen r = ln(1+ret)
gen v = ln(1+vwretd)
gen ret3d = l1.r+r+f1.r
gen vwret3d = l1.v+v+f1.v

replace ret3d = exp(ret3d)-1
replace vwret3d = exp(vwret3d)-1

*Market-adjusted 3-day returns*
gen aret3d = ret3d - vwret3d
label var aret3d "Market Adjusted 3-day Return (centered)"

*Price data in d-2*
replace prc = abs(prc)
gen prcl2d = l2.prc
label var prcl2d "Price at d-2"

*Matchdate*
gen matchdate = date

*Saving*
keep permno matchdate aret3d prcl2d
save "$directory\Data\Output\dailyreturns.dta", replace

********************************************************************************
*** Earnings Surprise Calculation ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\IBES_act_unadj", clear
egen start = min(pends), by(ticker)
egen end   = max(pends), by(ticker)
bys ticker: keep if _n==1
format %td start end
keep ticker start end
save "$directory\Data\Identifiers\ID_IBES_act_unadj.dta", replace

use "$directory\Data\Original\IBES_fcact_adj", clear
egen start = min(fpedats), by(ticker)
egen end   = max(fpedats), by(ticker)
bys ticker: keep if _n==1
format %td start end
keep ticker start end
save "$directory\Data\Identifiers\ID_IBES_fcact_adj.dta", replace

use "$directory\Data\Original\IBES_fc_unadj.dta", clear
egen start = min(fpedats), by(ticker)
egen end   = max(fpedats), by(ticker)
bys ticker: keep if _n==1
format %td start end
keep ticker start end
save "$directory\Data\Identifiers\ID_IBES_fc_unadj.dta", replace

use "$directory\Data\Original\iclink.dta", clear
drop if permno == .
egen start = min(sdate), by(permno)
egen end   = max(edate), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_iclink.dta", replace

use "$directory\Data\Original\Compu_quarterly", clear
egen start = min(datadate), by(permno)
egen end   = max(datadate), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_Compu_quarterly.dta", replace

**Data**
use "$directory\Data\Original\IBES_act_unadj", clear

*Missing actuals*
drop if value == .

*Non-USD data*
keep if curr_act == "USD"

*Saving*
ren pends fpedats
ren anndats anndats_act
ren anntims anntims_act
ren value actual
keep ticker fpedats anndats_act anntims_act actual
save "$directory\Data\Output\ibesunadj_actuals", replace

**Data**
use "$directory\Data\Original\IBES_fcact_adj", clear

*Missing forecasts, actuals, announcement dates*
drop if value == .|actual == .|anndats_act == .

*Non-USD data*
keep if curr_act 	== "USD"
keep if report_curr == "USD"

*Keep only last estimate of each analyst on the same day (for merging)*
gen anntime = clock(anntims, "hms")
gen acttime = clock(acttims, "hms")
gsort ticker fpedats estimator analys -anndats -anntime -actdats -acttime
duplicates drop ticker fpedats estimator analys anndats, force

*Saving*
ren value value_adj
ren actual actual_adj
keep ticker fpedats estimator analys anndats value_adj actual_adj
save "$directory\Data\Output\ibesadj", replace

**Prepare ticker-permno link file**
use "$directory\Data\Original\iclink.dta", clear
drop if permno == .

bys ticker: gen position = _n
forvalues i = 1(1)10 {
gen sdatetmp_`i' = sdate if position == `i'
bys ticker: egen sdate_`i' = mean(sdatetmp_`i')
gen edatetmp_`i' = edate if position == `i'
bys ticker: egen edate_`i' = mean(edatetmp_`i')
format %td sdate_`i' edate_`i'
drop sdatetmp* edatetmp*
}

duplicates drop ticker, force
keep ticker permno sdate_* edate_*

*Saving*
save "$directory\Data\Output\iclink_unique.dta", replace

**Data**
use "$directory\Data\Original\IBES_fc_unadj.dta", clear

*Merge with undadjusted actuals*
merge m:1 ticker fpedats using "$directory\Data\Output\ibesunadj_actuals", keep(match) nogenerate

*Non-USD data*
keep if report_curr == "USD"

*Keep only last estimate of each analyst on the same day (for merging)*
gen anntime = clock(anntims, "hms")
gen acttime = clock(acttims, "hms")
gsort ticker fpedats estimator analys -anndats -anntime -actdats -acttime
duplicates drop ticker fpedats estimator analys anndats, force

merge 1:1 ticker fpedats estimator analys anndats using "$directory\Data\Output\ibesadj", keep(match) nogenerate

*Adjust for stock splits between forecast and actual announcement date*
gen value_ratio = value/value_adj
replace value_ratio = 1 if value == 0 & value_adj == 0
gen actual_ratio = actual/actual_adj
replace actual_ratio = 1 if actual == 0 & actual_adj == 0
gen adjfactor = actual_ratio/value_ratio
gen feps1y = value*adjfactor

*Missing forecast*
drop if feps1y == .

*Merge with ticker-permno link file*
merge m:1 ticker using "$directory\Data\Output\iclink_unique.dta", keep(match) nogenerate
gen timelink = .
forvalues i = 1(1)10 {
replace timelink = 1 if fpedats >= sdate_`i' & fpedats <= edate_`i'
}
drop if timelink == .

*Shift IBES announcement date if release is after 04:00 EST*
gen ahour = substr(anntims_act,1,2)
destring ahour, replace
replace anndats_act = anndats_act + 1 if ahour >= 16

*Correct IBES announcement date*
ren fpedats datadate
merge m:1 permno datadate using "$directory\Data\Original\Compu_quarterly", keep(1 3) nogenerate
gen eadate = anndats_act if anndats_act > datadate
replace eadate = rdq if rdq < anndats_act & rdq > datadate
drop if eadate == .

*Keep only forecasts in -95 to -3 days window before actual announcement date*
drop if eadate - anndats > 95
drop if eadate - anndats < 3

*Keep only last forecast of every analyst for each firm-year*
gsort ticker analys -anndats -anntims
duplicates drop ticker analys datadate, force

*Compute median consensus forecast by firm-year*
bys ticker datadate: egen epsmed  = median(feps1y)

*Keep only one observation per firm-year*
duplicates drop ticker datadate, force

*Duplicates*
duplicates tag permno datadate, gen(dup)
drop if dup > 0

*Earnings surprise*
gen surp = actual - epsmed
format surp %3.2f

*Saving*
keep cname datadate permno eadate surp
save "$directory\Data\Output\ibes.dta", replace

********************************************************************************
*** Prepare Compustat Sample ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\Compu_annual.dta", clear
egen start = min(datadate), by(lpermno)
egen end   = max(datadate), by(lpermno)
bys lpermno: keep if _n==1
format %td start end
keep lpermno start end
save "$directory\Data\Identifiers\ID_Compu_annual.dta", replace

**Data**
use "$directory\Data\Original\Compu_annual.dta", clear

*Select data*
keep lpermno fyear datadate ib cshpri prcc_f oancf xidoc act lct che dlc ///
txp dp ppegt invt at capx ivncf xrd ceq sic

*Add annual returns*
ren lpermno permno
gen matchdate = mofd(datadate)
merge 1:1 permno matchdate using "$directory\Data\Output\annualreturns.dta", keep(1 3) nogenerate

*Add IBES data*
merge 1:1 permno datadate using "$directory\Data\Output\ibes.dta", keep(1 3) nogenerate

*Add 3-day returns (repeated for eadates on non-trading days)*
replace matchdate = eadate
replace matchdate = _n*10000 if matchdate == .
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", keep(1 3) nogenerate
replace matchdate = matchdate + 1
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", update keep(1 3 4 5) nogenerate
replace matchdate = matchdate + 1
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", update keep(1 3 4 5) nogenerate
replace matchdate = matchdate + 1
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", update keep(1 3 4 5) nogenerate

*Panel*
sort permno datadate
duplicates drop permno fyear, force
xtset permno fyear

********************************************************************************
*** Main Variables Definition ***
********************************************************************************

*Earnings*
gen inc = ib/cshpri/l.prcc_f if l.prcc_f >= 1 
label var inc "Earnings"

*Operating Cash Flow*
gen cfo	= (oancf-xidoc)/cshpri/l.prcc_f if l.prcc_f >= 1
label var cfo "Operating Cash Flow"

*Accruals*
gen acc = inc - cfo
label var acc "Accruals"

*Accruals/Operating Cash Flow from Balance Sheet Approach*
gen acc_bs = (d.act - d.lct - d.che + d.dlc + d.txp - dp)/cshpri/l.prcc_f if l.prcc_f >= 1
gen cfo_bs = inc - acc_bs

replace acc = acc_bs if acc == .
replace cfo = cfo_bs if cfo == .

*Earnings: Operating Cash Flow less Depreciation*
gen oancfdp = oancf - xidoc - dp
replace oancfdp = ib - (d.act - d.lct - d.che + d.dlc + d.txp) if oancfdp == .
gen mic = oancfdp/cshpri/l.prcc_f if l.prcc_f >= 1
label var mic "Model Earnings"

*Negative Return Dummy*
gen d = (aret1y < 0) if aret1y != .
label var d "Negative Returns"

*Investment-to-Assets Ratio*
gen iva = (d.ppegt + d.invt)/l.at if l.prcc_f >= 1
label var iva "Investment-to-Assets Ratio"

*Investment Growth*
replace xrd = 0 if xrd == .
gen ivg = (d.capx + d.xrd)/(l.capx + l.xrd)
replace ivg = 0 if d.capx == 0 & d.xrd == 0 & l.capx == 0 & l.xrd == 0
replace ivg = . if l.prcc_f < 1
label var ivg "Investment Growth"

*Investing Cash Flow*
replace ivncf = ivncf*-1
gen ivc = ivncf/l.at if l.prcc_f >= 1
label var ivc "Investing Cash Flow"

*Earnings Surprise (IBES)*
replace surp = . if fyear < 1993
gen sue = surp/prcl2d if prcl2d >= 1

*Volatility Measures* (Min. obs = 5)*
egen ct_inc = count(inc) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_inc = sd(inc) if ct_inc >= 5 & inc != . & fyear >= 1963 & fyear <= 2014, by(permno)
egen ct_cfo = count(cfo) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_cfo = sd(cfo) if ct_cfo >= 5 & cfo != . & fyear >= 1963 & fyear <= 2014, by(permno)
egen ct_acc = count(acc) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_acc = sd(acc) if ct_acc >= 5 & acc != . & fyear >= 1963 & fyear <= 2014, by(permno)
egen ct_in2 = count(inc) if fyear >= 1993 & fyear <= 2014, by(permno)
egen sd_in2 = sd(inc) if ct_inc >= 5 & inc != . & fyear >= 1993 & fyear <= 2014, by(permno)
egen ct_mic = count(mic) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_mic = sd(mic) if ct_mic >= 5 & mic != . & fyear >= 1963 & fyear <= 2014, by(permno)
drop ct_*

*Market-to-Book*
gen mtb = (prcc_f*cshpri)/ceq if ceq > 0

*Define time-period*
drop if fyear < 1963|fyear > 2014

*Trim variables at 1%*
qui {
local variables="aret* inc cfo acc mic iva ivg ivc ib mtb"
foreach var of varlist `variables' {
sum `var', d
replace `var'=. if `var'>=r(p99)
replace `var'=. if `var'<=r(p1)
}
}

*Saving*
save "$directory\Data\Output\finaldata.dta", replace
	
********************************************************************************
*** TABLE 7: Compustat Concavities and Volatility ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

local sorts = "sd_inc sd_cfo sd_acc"
	foreach var of varlist `sorts' {
	qui bys permno: replace `var' = . if missing(aret1y, inc, cfo, acc)
	qui bys permno `var': replace `var' = . if _n!=1
	qui xtile `var'_q = `var', nq(5)
	qui bys permno: replace `var'_q = `var'_q[_n-1] if `var'_q == . 
}

forvalues k = 1/5 {
	xtreg inc c.aret1y##i.d i.fyear if sd_inc_q == `k', fe cluster(permno)
	est store inc_q
	xtreg cfo c.aret1y##i.d i.fyear if sd_cfo_q == `k', fe cluster(permno)
	est store cfo_q
	xtreg acc c.aret1y##i.d i.fyear if sd_acc_q == `k', fe cluster(permno)
	est store acc_q

	esttab inc_q cfo_q acc_q using "$directory\Results\Compustat\Tables\Table_7.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}

********************************************************************************
*** TABLE 8: Compustat Concavities and Investment ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

replace iva = . if missing(aret1y, inc, cfo, acc)
qui xtile iva_q = iva if iva != ., nq(5)

forvalues k = 1/5 {
	xtreg inc c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store inc_q
	xtreg cfo c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store cfo_q
	xtreg acc c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store acc_q

	esttab inc_q cfo_q acc_q using "$directory\Results\Compustat\Tables\Table_8.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}
	
********************************************************************************
*** Table A1: Data Moments (representing stable, industrial firm) ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear		
		
**Sample restrictions**

*Industries*
destring sic, force replace
drop if (sic >= 4000 & sic < 5000) | (sic >= 6000 & sic < 7000)
 
*Panel*
duplicates drop permno fyear, force
egen id = group(permno)
xtset id fyear

*Constant sample (firms with about 20-30 observations)*
keep if fyear >= (2014-30) & fyear <= 2014
foreach var of varlist oancf ivncf mtb {
	egen count = total(`var'!=.), by(id) missing	
	keep if count >= 20
	drop count
}

**Variables**

*(1) Cash flow variability*
gen cfo_at = oancf/l.at
egen std_cfo_at = sd(cfo_at), by(id)

*(2) Cash flow autocorrelation [note: pooled regression to improve precision]*
xtreg oancf l.oancf i.fyear, fe
gen ar_cfo = _b[L.oancf]
		
*(3) Investment level*
gen inv_at = ivncf/l.at
egen m_inv_at = mean(inv_at), by(id)

*(4) Investment variability*
egen std_inv_at = sd(inv_at), by(id)

*(5) Investment autocorrelation [note: pooled regression to improve precision]*
xtreg ivncf l.ivncf i.fyear, fe
gen ar_inv = _b[L.ivncf]
		
*(6) Market to book*
egen m_mtb = mean(mtb), by(id)

**Moments**
local M = "m_* std_* ar_*"
keep `M'

*Average moment*
qui foreach var of varlist `M' {
	sum `var'
	replace `var' = r(mean)
}

*Keep first observation*
keep if _n==1

*Order*
order std_cfo_at ar_cfo m_inv_at std_inv_at ar_inv m_mtb

*Output directory*
cd "$directory\Data\Output"
save Moments, replace
export delimited Moments.csv, replace novarnames	

********************************************************************************
*** TABLE A5: Concavities ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

foreach depvar of varlist inc cfo acc iva ivg ivc{

xtreg `depvar' c.aret1y##d i.fyear, fe cluster(permno)
est store `depvar'

esttab `depvar' using "$directory\Results\Compustat\Tables\Table_A5.rtf", ///
keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
}

********************************************************************************
*** TABLE A6: Decomposition of Earnings-Return Concavity ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

xtreg inc c.aret1y##i.d i.fyear, fe
local basu = _b[1.d#aret1y]
gen sample = e(sample)

xtreg inc d if sample==1, fe
predict r_inc if sample==1, e

xtreg aret1y d if sample==1, fe
predict r_aret1y if sample==1, e

*Log: open*
cd "$directory\Results\Compustat\Logs"
log using Appendix_Compustat, replace smcl name(Appendix_Compustat)

*Table A6: Decomposition of Earnings-Return Concavity*

	/* Firm-fixed effects decomposition */
	qui {
		
		/* Negative return partition: variance/covariance */
		corr r_inc r_aret1y if d == 1 & sample==1, cov
		local cov_neg = r(cov_12)
		local var_neg = r(Var_2)

		/* Positive return partition: variance/covariance */
		corr r_inc r_aret1y if d == 0 & sample==1, cov
		local cov_pos = r(cov_12)
		local var_pos = r(Var_2)
	}
		
	/* Output */
	di "___________________________"
	di "Negative Return Partition"
	di "Return variance: " round(`var_neg',.0001)
	di "Earnings-Return covariance: " round(`cov_neg',.0001)
	di "___________________________"
	di "Positive Return Partition"
	di "Return variance: " round(`var_pos',.0001)
	di "Earnings-Return covariance: " round(`cov_pos',.0001)
	di "___________________________"
	di "Spreads/Differences (Negative - Positive)"
	di "Variance: " round(`var_neg'-`var_pos',.0001)
	di "Earnings-Return covariance: " round(`cov_neg'-`cov_pos',.0001)		
		
*Log: close*
log close Appendix_Compustat

********************************************************************************
*** TABLE A7: Compustat Earnings-Return Concavity and Volatility/Investment 
***           with Alternative Earnings Definition ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

local sorts = "sd_mic"
	foreach var of varlist `sorts' {
	qui bys permno: replace `var' = . if missing(aret1y, inc, cfo, acc)
	qui bys permno `var': replace `var' = . if _n!=1
	qui xtile `var'_q = `var', nq(5)
	qui bys permno: replace `var'_q = `var'_q[_n-1] if `var'_q == . 
}

forvalues k = 1/5 {
	xtreg mic c.aret1y##i.d i.fyear if sd_mic_q == `k', fe cluster(permno)
	est store mic_q

	esttab mic_q using "$directory\Results\Compustat\Tables\Table_A7_A.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}
	
use "$directory\Data\Output\finaldata.dta", clear

replace iva = . if missing(aret1y, inc, cfo, acc)
qui xtile iva_q = iva if iva != ., nq(5)

forvalues k = 1/5 {
	xtreg mic c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store mic_q

	esttab mic_q using "$directory\Results\Compustat\Tables\Table_A7_B.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}

********************************************************************************
*** FIGURE A2: Non-Parametric Comparison of Simulated and Compustat 
***            Earnings-Return Patterns ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

**Compute firm-specific Basu coefficients**

	*ID*
	egen firmid = group(permno)

	*Placeholders*
	gen basu = .
	gen basu_obs = .

	*Loop over firms*
	qui sum firmid, d
	qui forvalues i = `r(min)'(1)`r(max)' {
	
		*Capture*
		capture {
		
			*Basu*/
			reg inc c.aret1y##i.d if firmid == `i'
			replace basu = _b[1.d#c.aret1y] if firmid == `i'
			replace basu_obs = e(N) if firmid == `i'

		}
	}

	*Drop estimates with less than 5 obs.*
	replace basu = . if basu_obs < 5	
	
	*Output directory*
	cd "$directory\Results\Compustat\Figures"
	
	*Basu
	
		*Graph 1: Earnings-Return Concavity*
		graph twoway ///
			(fpfitci inc aret1y if abs(aret1y)<1, clcolor(black)) ///
				, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///	
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
				ytitle("Earnings/Price") ///
				xtitle("Return") ///
				title("Earnings-Return Concavity", color(black)) ///
				name(Figure_A2_1, replace) saving(Figure_A2_1, replace) 	
		
		*Graph 2: Earnings-Return Concavity and Volatility*
		preserve
		
			*Missing*
			replace fyear = . if firmid == .
			xtset firmid fyear

			*Drop to firm-level*
			duplicates drop firmid, force
			
			*Outlier*
			qui sum basu, d
			local basu_min = r(p5)
			local basu_max = r(p95)
				
			*Basu and Volatility*
			qui sum sd_inc, d
			local sd_inc_max = r(p95)
			
			graph twoway ///
				(lpolyci basu sd_inc if `basu_min'<basu & basu<`basu_max' & sd_inc<`sd_inc_max', clcolor(black)) ///
					, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
					ytitle("Earnings-Return Concavity") ///
					xtitle("Earnings Volatility") ///
					title("Earnings-Return Concavity and Volatility", color(black)) ///
					name(Figure_A2_2, replace) saving(Figure_A2_2, replace)

		restore

**Compute firm-specific Basu coefficients**

	*ID8
	drop firmid
	egen firmid = group(permno) if fyear >= 1993
	
	*Outliers (Cohen et al., 2007)*
	replace sue = . if abs(sue) > 0.1
	
	*Placeholders*
	gen erc = .
	gen erc_obs = .

	*Loop over firms*
	qui sum firmid, d
	qui forvalues i = `r(min)'(1)`r(max)' {
	
		*Capture*
		capture {

			*ERC*
			reg aret3d sue if firmid == `i'
			replace erc = _b[sue] if firmid == `i'
			replace erc_obs = e(N) if firmid == `i'

		}
	}

	*Drop estimates with less than 5 obs.*
	replace erc = . if erc_obs < 5		
		
	*ERC*
	
		*Graph 3: Earnings-Response Coefficient*
		graph twoway ///
			(fpfitci aret3d sue, clcolor(black)) ///
				, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///	
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
				ytitle("Return") ///
				xtitle("Earnings Surprise") ///
				title("Earnings-Response Coefficient", color(black)) ///
				name(Figure_A2_3, replace) saving(Figure_A2_3, replace)

		*Graphs 4, 5: ERC, Volatility, and Market-to-Book*
		preserve

			*Missing*
			replace fyear = . if firmid == .
			xtset firmid fyear

			*Keep one observation for each firm*
			duplicates drop firmid, force
				
			*Mark outliers*
			qui sum erc, d
			local erc_min = r(p5)
			local erc_max = r(p95)
			qui sum sd_in2, d
			local sd_in2_max = r(p95)
			qui sum mtb, d
			local mtb_max = r(p95)

			*Graph 4: ERC and Volatility*
			graph twoway ///
				(lpolyci erc sd_in2 if `erc_min'<erc & erc<`erc_max' & sd_in2<`sd_in2_max', clcolor(black)) ///
					, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
					ytitle("ERC") ///
					xtitle("Earnings Volatility") ///
					title("ERC and Volatility", color(black)) ///
					name(Figure_A2_4, replace) saving(Figure_A2_4, replace)

			*Graph 5: ERC and Market-to-Book*
			graph twoway ///
				(lpolyci erc mtb if `erc_min'<erc & erc<`erc_max' & mtb<`mtb_max', clcolor(black)) ///
					, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
					ytitle("ERC") ///
					xtitle("Market-to-Book") ///
					title("ERC and Market-to-Book", color(black)) ///
					name(Figure_A2_5, replace) saving(Figure_A2_5, replace)

		restore
/******************************************************************************/
/* Illustration of Cross-Sectional Volatility Results						  */
/******************************************************************************/
/* Simulated Results:														  */
/*	0.086***	0.113***	0.135***	0.153***	0.202***				  */
/*	(0.005)		(0.005)		(0.005)		(0.006)		(0.006)					  */
/* Compustat Results:														  */
/* 	0.022***	0.039***	0.068***	0.153***	0.259***			      */
/*	(0.002)		(0.003)		(0.005)		(0.007)		(0.011)					  */
/******************************************************************************/

**** Preliminaries ****
clear all
set more off

**** Results Directory ****
cd "$directory\Results\Models\Figures"

**** Observations ****
set obs 5

**** Coefficients ****
gen quintile = _n
label var quintile "Quintile" 

gen simulated = 0.086 if quintile == 1
replace simulated = 0.113 if quintile == 2
replace simulated = 0.135 if quintile == 3
replace simulated = 0.153 if quintile == 4
replace simulated = 0.202 if quintile == 5

gen compustat = 0.022 if quintile == 1
replace compustat = 0.039 if quintile == 2
replace compustat = 0.068 if quintile == 3
replace compustat = 0.153 if quintile == 4
replace compustat = 0.259 if quintile == 5

**** Standard Errors ****
gen se_simulated = 0.005
replace se_simulated = 0.006 if quintile == 4 | quintile == 5

gen se_compustat = 0.002 if quintile == 1
replace se_compustat = 0.003 if quintile == 2
replace se_compustat = 0.005 if quintile == 3
replace se_compustat = 0.007 if quintile == 4
replace se_compustat = 0.011 if quintile == 5

**** Upper/Lower ****
gen l_simulated = simulated - 1.96*se_simulated
gen l_compustat = compustat - 1.96*se_compustat
gen u_simulated = simulated + 1.96*se_simulated
gen u_compustat = compustat + 1.96*se_compustat

**** Graph ****
graph twoway ///
	(rcap l_simulated u_simulated quintile, color(gs10)) ///
	(rcap l_compustat u_compustat quintile, color(black)) ///
	(connected simulated quintile, lpattern(dash) lwidth(medium) msize(vlarge) msymbol(d) color(gs10)) ///
	(connected compustat quintile, lwidth(medium) msize(vlarge) msymbol(s) color(black)) ///
	, legend(label(1 "95% CI") label(3 "Simulated data") label(4 "Compustat")  rows(3) order(1 3 4) ring(0) position(11) bmargin(medium) symxsize(5)) ///
	xtitle("Quintile (Standard deviation of Earnings (t)/Price (t-1))") xlabel(, format(%9.0f)) ylabel(, format(%9.2f) angle(0)) ///
	title("Earnings-Return Concavity and Volatility", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	name(Volatility, replace) saving(Volatility, replace)
	
/******************************************************************************/
/* Illustration of Cross-Sectional Investment Results	(Lyandres et al. 2008)*/
/******************************************************************************/
/* Simulated Results:														  */
/*	0.175***	0.030***	0.021***	0.020***	0.000					  */
/*	(0.027)		(0.006)		(0.004)		(0.004)		(0.008)					  */
/* Compustat Results:														  */
/* 	0.172***	0.088***	0.084***	0.071***	0.060***			      */
/*	(0.010)		(0.008)		(0.007)		(0.006)		(0.005)					  */
/******************************************************************************/

**** Preliminaries ****
clear

**** Observations ****
set obs 5

**** Coefficients ****
gen quintile = _n
label var quintile "Quintile" 

gen simulated = 0.175 if quintile == 1
replace simulated = 0.030 if quintile == 2
replace simulated = 0.021 if quintile == 3
replace simulated = 0.020 if quintile == 4
replace simulated = 0.000 if quintile == 5

gen compustat = 0.172 if quintile == 1
replace compustat = 0.088 if quintile == 2
replace compustat = 0.084 if quintile == 3
replace compustat = 0.071 if quintile == 4
replace compustat = 0.060 if quintile == 5

**** Standard Errors ****
gen se_simulated = 0.027 if quintile == 1
replace se_simulated = 0.006 if quintile == 2
replace se_simulated = 0.004 if quintile == 3
replace se_simulated = 0.004 if quintile == 4
replace se_simulated = 0.008 if quintile == 5

gen se_compustat = 0.010 if quintile == 1
replace se_compustat = 0.008 if quintile == 2
replace se_compustat = 0.007 if quintile == 3
replace se_compustat = 0.006 if quintile == 4
replace se_compustat = 0.005 if quintile == 5

**** Upper/Lower ****
gen l_simulated = simulated - 1.96*se_simulated
gen l_compustat = compustat - 1.96*se_compustat
gen u_simulated = simulated + 1.96*se_simulated
gen u_compustat = compustat + 1.96*se_compustat

**** Graph ****
graph twoway ///
	(rcap l_simulated u_simulated quintile, color(gs10)) ///
	(rcap l_compustat u_compustat quintile, color(black)) ///
	(connected simulated quintile, lpattern(dash) lwidth(medium) msize(vlarge) msymbol(d) color(gs10)) ///
	(connected compustat quintile, lwidth(medium) msize(vlarge) msymbol(s) color(black)) ///
	, legend(label(1 "95% CI") label(3 "Simulated data") label(4 "Compustat")  rows(3) order(1 3 4) ring(0) position(11) bmargin(medium) symxsize(5)) ///
	xtitle("Quintile (Investment (t))") xlabel(, format(%9.0f)) ylabel(, format(%9.2f) angle(0)) ///
	title("Earnings-Return Concavity and Investment", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	name(Investment, replace)
	
/* Figure 11: Earnings-Return Asymmetry, Volatility, and Investment */
graph combine Volatility Investment, ///
	altshrink cols(2) ysize(5) xsize(10) ///
	title("Earnings-Return Concavity, Volatility, and Investment", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	name(Figure_11, replace) saving(Figure_11, replace)		
/******************************************************************************/
/* Title:	Investment Dynamics and Earnings-Return Properties		 		  */
/* Authors: M. Breuer, D. Windisch       	                 	          	  */
/* Date:    11/19/2018                                                  	  */
/******************************************************************************/
/* Program description:														  */
/* Master do-file (setting directory & executing do-files)					  */
/******************************************************************************/

/* Directory (set to directory of folder) */
global directory `"..."'

/* Execute STATA do-files */

	/* 01 - Models (patterns in simulated data from base, accrual, and alternative models) */	
	cd "$directory\Code"	
	do 01-Models.do
	
	/* 02 - Compustat (patterns in Compustat data) */
	cd "$directory\Code"	
	do 02-Compustat.do

	/* 03 - Comparison graph (Figure 11) */
	cd "$directory\Code"	
	do 03-Comparison_Graph.do
/******************************************************************************/
/* Title:	Evaluation of Simulated Data from Dynamic Investment Model 		  */
/* Authors: M. Breuer, D. W. Windisch                        	          	  */
/* Date:    09/12/2017                                                  	  */
/******************************************************************************/
/* Program description:														  */
/* Generating Figures and Tables using simulated data						  */
/******************************************************************************/

/* Preliminaries */
version 13.1
clear all
set more off

/******************************************************************************/
/* Basic Model: Simulation data (based on calibrated parameter values)		  */
/******************************************************************************/

/* Directory */
cd "$directory\Code\Models\01-Basic model\Simulation\Data"

/* Data */
insheet using Simulations.csv, nonames clear

/* Time-series definition */

	/* Time dimension */
	gen t = _n
	label var t "Period"

	/* Set time series */
	tsset t
		
/* Model parameters */

	/* Discount rate (expected return) */
	local r = 0.1
	
	/* Persistence */
	local rho = 0.7
	
	/* Mean profitability */
	local mean = 1.5
	
/* Variables */

	/* Destring */
	qui destring v8, replace force
	
	/* Renaming model outputs */
	rename v1 earnings
	label var earnings "Earnings"

	rename v2 cash
	label var cash "Cash from Operations"

	rename v3 price
	label var price "Price"

	rename v4 profitability
	label var profitability "Profitability"

	rename v5 investment
	label var investment "Investment"

	rename v6 capital
	label var capital "Capital" // Note: Capital is beginning of period capital

	rename v7 adj_cost
	label var adj_cost "Adjustment cost"

	rename v8 surprise
	label var surprise "Surprise"
	
	/* Variable transformations */
	gen z = profitability - ((1-`rho')*`mean' + `rho'*l.profitability)
	label var z "Profitability shock"
	
	gen price_ex_div = price - cash + investment
	label var price_ex_div "Price (ex dividend)"

	gen ear = earnings/l.price_ex_div
	label var ear "Earnings(t)/Price(t-1)"

	gen l_ear = l.earnings/l.price_ex_div
	label var l_ear "Earnings(t-1)/Price(t-1)"
	
	gen cfo = cash/l.price_ex_div
	label var cfo "CFO(t)/Price(t-1)"

	gen ret = price/l.price_ex_div - (1 + `r')
	label var ret "Return"
	
	gen dear = d.earnings/l.price_ex_div
	label var dear "Change in Earnings/Price(t-1)"
	
	gen dear_c = d.earnings/capital
	label var dear "Change in Earnings/Capital(t-1)"
		
	gen fcapital = f.capital
	label var fcapital "Capital (t)"

	gen inv = investment/l.price_ex_div
	label var inv "Investment(t)/Price(t-1)"
	
	gen inv_price = 1/l.price_ex_div
	label var inv_price "1/Price(t-1)"

	gen mtb = price/capital
	label var mtb "Market-to-Book"	
	
	gen loss = (earnings < 0)
	label var loss "Loss"	
	
	gen d = (ret<0)
	label var d "Negative Return Indicator"
	
	gen d_earnings = (l.earnings < 0)
	label var d_earnings "Negative Earnings Indicator"
	
	gen d_dearnings = (l.d.earnings < 0)
	label var d_dearnings "Negative Earnings Change Indicator"
	
	gen d_dear = (l.dear < 0)
	label var d_dear "Negative Earnings Change/Price Indicator"
	
	gen d_dear_c = (l.dear_c < 0)
	label var d_dear_c "Negative Earnings Change/Capital Indicator"
		
	gen sue = surprise/l.price_ex_div
	label var sue "Earnings Surprise"
	
	gen abs_sue = abs(sue)
	label var sue "Absolute Earnings Surprise"
	
	/* AR(1) earnings surprise */
	qui reg earnings l.earnings
	qui predict sue_res, res
	label var sue_res "Earnings Surprise"

	gen sue_e = sue_res/l.price_ex_div
	label var sue_e "Earnings Surprise"	

/* Outlier treatment */

	/* Drop burn-in period */
	drop if t<=1000 | t>101000
	
	/* Drop extreme values (ensure positive value function) */
	drop if price < 0
	drop if abs(ret) > 1
	
/* Panel definition */
	
	/* Firm dimension */
	gen firm = ceil(t/25)
	label var firm "Firm"
	
	/* Set panel structure */
	xtset firm t
	
/* Endogenous split variables (by firm) */	

	/* Mean */
	egen mean_mtb = mean(mtb), by(firm)

	/* Standard deviation */
	egen sd_ear = sd(ear), by(firm)
	
/* Quintiles */
	
	/* Earnings volatility */
	xtile q_sd_ear = sd_ear, nq(5)
	
	/* Investment */
	xtile q_inv = investment, nq(5)

/* Persistence, earnings-response coefficient, and earnings-return asymmetry (by firm) */
 
	/* Placeholders */
	gen rho = .
	gen erc = .
	gen basu = .
	
	/* Loop */
	qui sum firm, d
	qui forvalues q = `r(min)'(1)`r(max)' {
		capture {
			/* Earnings persistence */
			reg earnings l.earnings if firm == `q'
			replace rho = _b[L.earnings] if firm == `q'
			
			/* Earnings response coefficient */
			reg ret sue if firm == `q'
			replace erc = _b[sue] if firm == `q'
			
			/* Earnings-return coefficient */
			reg ear c.ret##i.d if firm == `q'
			replace basu = _b[1.d#c.ret] if firm == `q'
			
		}
	}	
	
/* Leads and lags for future earnings-response coefficient regression */

	/* Earnings growth */
	gen x_0 = ln(earnings/l.earnings)
	gen x_1 = f1.x_0
	gen x_2 = f2.x_0
	gen x_3 = f3.x_0
	gen x_1_3 = exp(ln(1+x_1) + ln(1+x_2) + ln(1+x_3))-1 
	
	/* Returns */
	gen ret_1 = f1.ret
	gen ret_2 = f2.ret
	gen ret_3 = f3.ret
	gen ret_1_3 = exp(ln(1+ret_1) + ln(1+ret_2) + ln(1+ret_3))-1 

	/* Other */
	gen ep = l.earnings/l.price
	gen ag = ln(capital/l.capital)	
	
/* Save */
cd "$directory\Data\Output"
save Simulation, replace

/******************************************************************************/
/* Basic Model: Simulation data (based on varying parameter values)	  		  */
/******************************************************************************/

/* Directory */
cd "$directory\Code\Models\01-Basic model\Simulation\Data"

/* Data */
insheet using Predictions.csv,  clear

/* Variable names */

	/* Identifiers */
	rename v1 i
	label var i "Parameter"

	rename v2 j
	label var j "Step"

	/* Parameters */
	rename v3 p1
	rename v4 p2
	rename v5 p3
	rename v6 p4


	/* Destring */
	qui destring v*, replace force

	/* Coefficients */
	rename v7 ear_0
	label var ear_0 "Positive slope (Earnings)"

	rename v8 ear_1
	label var ear_1 "Incremental negative slope (Earnings)"

	rename v9 erc
	label var erc "Earnings-Response Coefficient"

	gen ear_2 = ear_0 + ear_1
	label var ear_2 "Negative slope (Earnings)"

	gen ear = ear_2 / (ear_0 + ear_2)
	label var ear "Share of negative slope (Earnings)"

/* Reshape */
egen ij=group(i j)
reshape long p, i(ij) j(parameter)

/* Paramter Values */
rename p values
label var values "Parameter Values"

label var parameter "Parameter"
label define parameter 1 "std_epsilon" 2 "psi" 3 "rho" 4 "r"
label values parameter parameter

/* Save */
cd "$directory\Data\Output"
save ComparativeStatics, replace

/******************************************************************************/
/* Alternative Models: Simulation data (based on calibrated parameter values) */
/******************************************************************************/

/* Model directories */
local directory_1 = "$directory\Code\Models\03-Model 1 (no delay, no adjustment cost)\Simulation\Data"
local directory_2 = "$directory\Code\Models\04-Model 2 (no adjustment cost)\Simulation\Data"
local directory_3 = "$directory\Code\Models\05-Model 3 (no delay)\Simulation\Data"

/* Loop over models */
forvalues i = 1(1)3 {

	/* Directory */
	cd "`directory_`i''"

	/* Data */
	if `i' == 1 {
		insheet using Simulations_nodelay_nocost.csv, nonames clear
	}
	
	if `i' == 2 {
		insheet using Simulations_nocost.csv, nonames clear
	}
	
	if `i' == 3 {
		insheet using Simulations_nodelay.csv, nonames clear
	}	
	
	/* Time-series definition */

		/* Time dimension */
		gen t = _n
		label var t "Period"

		/* Set time series */
		tsset t
		
	/* Variables */

		/* Destring */
		qui destring v8, replace force
		
		/* Renaming model outputs */
		rename v1 earnings
		label var earnings "Earnings"

		rename v2 cash
		label var cash "Cash from Operations"

		rename v3 price
		label var price "Price"

		rename v4 profitability
		label var profitability "Profitability"

		rename v5 investment
		label var investment "Investment"

		rename v6 capital
		label var capital "Capital" // Note: Capital is beginning of period capital

		rename v7 adj_cost
		label var adj_cost "Adjustment cost"

		rename v8 surprise
		label var surprise "Surprise"
		
		/* Variable transformations */
		gen z = profitability - ((1-`rho')*`mean' + `rho'*l.profitability)
		label var z "Profitability shock"
		
		gen price_ex_div = price - cash + investment
		label var price_ex_div "Price (ex dividend)"

		gen ear = earnings/l.price_ex_div
		label var ear "Earnings(t)/Price(t-1)"

		gen cfo = cash/l.price_ex_div
		label var cfo "CFO(t)/Price(t-1)"

		gen ret = price/l.price_ex_div - (1 + `r')
		label var ret "Return"
		
		gen dear = d.earnings/l.price_ex_div
		label var dear "Change in Earnings/Price(t-1)"
		
		gen dear_c = d.earnings/capital
		label var dear "Change in Earnings/Capital(t-1)"
			
		gen fcapital = f.capital
		label var fcapital "Capital (t)"

		gen inv_price = 1/l.price_ex_div
		label var inv_price "1/Price(t-1)"

		gen mtb = price/capital
		label var mtb "Market-to-Book"	
		
		gen loss = (earnings < 0)
		label var loss "Loss"	
		
		gen d = (ret<0)
		label var d "Negative Return Indicator"
		
		gen d_earnings = (l.earnings < 0)
		label var d_earnings "Negative Earnings Indicator"
		
		gen d_dearnings = (l.d.earnings < 0)
		label var d_dearnings "Negative Earnings Change Indicator"
		
		gen d_dear = (l.dear < 0)
		label var d_dear "Negative Earnings Change/Price Indicator"
		
		gen d_dear_c = (l.dear_c < 0)
		label var d_dear_c "Negative Earnings Change/Capital Indicator"
			
		gen sue = surprise/l.price_ex_div
		label var sue "Earnings Surprise"
		
		gen abs_sue = abs(sue)
		label var sue "Absolute Earnings Surprise"
		
		/* AR(1) earnings surprise */
		qui reg earnings l.earnings
		qui predict sue_res, res
		label var sue_res "Earnings Surprise"

		gen sue_e = sue_res/l.price_ex_div
		label var sue_e "Earnings Surprise"	

	/* Outlier treatment */

		/* Drop burn-in period */
		drop if t<=1000 | t>101000
		
		/* Drop extreme values (ensure positive value function) */
		drop if price < 0
		drop if abs(ret) > 1
		
	/* Panel definition */
		
		/* Firm dimension */
		gen firm = ceil(t/25)
		label var firm "Firm"
		
		/* Set panel structure */
		xtset firm t
		
	/* Endogenous split variables (by firm)*/	

		/* Mean */
		egen mean_mtb = mean(mtb), by(firm)

		/* Standard deviation */
		egen sd_ear = sd(ear), by(firm)

	/* Quintiles */
		
		/* Earnings volatility */
		xtile q_sd_ear = sd_ear, nq(5)
		
		/* Investment */
		xtile q_inv = investment, nq(5)
	
	/* Persistence, earnings-response coefficient, and earnings-return asymmetry (by firm) */
	 
		/* Placeholders */
		gen rho = .
		gen erc = .
		gen basu = .
		
		/* Loop */
		qui sum firm, d
		qui forvalues q = `r(min)'(1)`r(max)' {
			capture {
				/* Earnings persistence */
				reg earnings l.earnings if firm == `q'
				replace rho = _b[L.earnings] if firm == `q'
				
				/* Earnings response coefficient */
				reg ret sue if firm == `q'
				replace erc = _b[sue] if firm == `q'
				
				/* Earnings-return coefficient */
				reg ear c.ret##i.d if firm == `q'
				replace basu = _b[1.d#c.ret] if firm == `q'
				
			}
		}	
		
	/* Leads and lags for future earnings-response coefficient regression */

		/* Earnings growth */
		gen x_0 = ln(earnings/l.earnings)
		gen x_1 = f1.x_0
		gen x_2 = f2.x_0
		gen x_3 = f3.x_0
		gen x_1_3 = exp(ln(1+x_1) + ln(1+x_2) + ln(1+x_3))-1 
		
		/* Returns */
		gen ret_1 = f1.ret
		gen ret_2 = f2.ret
		gen ret_3 = f3.ret
		gen ret_1_3 = exp(ln(1+ret_1) + ln(1+ret_2) + ln(1+ret_3))-1 

		/* Other */
		gen ep = l.earnings/l.price
		gen ag = ln(capital/l.capital)	
			
	/* Save */
	cd "$directory\Data\Output"
	save Simulation_Model_`i', replace

/* End: loop over models */
}

/******************************************************************************/
/* Manuscript: Figures and Tables											  */
/******************************************************************************/

/* Log */
cd "$directory\Results\Models\Logs"
log using Manuscript, replace smcl name(Manuscript)
	
/* 3. Economic model */	
	
	/* d. Policy function */	
	
		/* Figure 1: Capital and profitability */
			
			/* Data: Simulation */
			cd "$directory\Data\Output"
			use Simulation, clear
			
			/* Results Directory */
			cd "$directory\Results\Models\Figures"			
		
			/* Figure */
			graph twoway ///
				(lpolyci capital profitability, clcolor(black)) ///
				(lpolyci fcapital profitability, clcolor(black) clpattern(dash)) ///
				, legend(label(2 "Capital (t)") label(4 "Capital (t+1)") rows(3) order(1 2 4) ring(0) position(11) bmargin(medium) symxsize(5)) /// 
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xtitle("Profitability (t)") ///
				xline(1.5, lcolor(gs10) lpattern(dash)) ///
				ylabel(, format(%9.0f) angle(0)) /// 				
				title("Capital and Profitability", color(black)) ///
				name(Figure_1, replace) saving(Figure_1, replace)
	
		/* Figure 2: Impulse response of investment and capital with respect to profitability shocks */

			/* IRF investment */
			qui var investment profitability, lags(1/10)
			qui irf create irf, set(irf, replace)
			irf graph irf ///
				, impulse(profitability) response(investment) ///
				legend(label(1 "CI 95%") label(2 "Impulse Response Function") rows(1) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Impulse Response: Profitability and Investment", color(black)) ///
				name(IRF_Investment, replace)
	
			/* IRF capital */
			qui var capital profitability, lags(1/10)
			qui irf create irf, set(irf, replace)
			irf graph irf ///
				, impulse(profitability) response(capital) ///
				legend(label(1 "CI 95%") label(2 "Impulse Response Function") rows(1) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Impulse Response: Profitability and Capital", color(black)) ///
				name(IRF_Capital, replace)
	
			/* Combined figure */
			graph combine IRF_Investment IRF_Capital, ///
				altshrink cols(3)  ysize(4) xsize(10) ///
				title("Investment and Capital Dynamics", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_2, replace)	saving(Figure_2, replace)	
		
/* 4. Model predictions */

	/* a. Distributions */
	
		/* Figure 3: Histograms of profitability, investment, earnings, and returns */
		
			/* Profitability */
			hist profitability ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Profitability Levels", color(black)) ///
				ylabel(, format(%9.1f) angle(0)) /// 								
				name(Profitability, replace)

			/* Investment */				
			hist investment ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Investment Levels", color(black)) ///
				ylabel(, format(%9.2f) angle(0)) /// 												
				name(Investment, replace)
	
			/* Earnings */
			hist earnings ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Earnings Levels", color(black)) ///
				ylabel(, format(%9.3f) angle(0)) /// 								
				name(Earnings, replace)
	
			/* Returns */
			hist ret ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Returns", color(black)) ///
				ylabel(, format(%9.0f) angle(0)) /// 								
				name(Returns, replace)

			/* Combined figure */
			graph combine Profitability Investment Earnings Returns, ///
				altshrink cols(4) ysize(4) xsize(15) ///
				title("Profitability, Investment, Earnings, and Returns", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_3, replace) saving(Figure_3, replace)
	
		/* Figure 4: Histograms of price and earnings scaled by lagged price */
	
			/* Price */
			hist price ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Price Levels", color(black)) ///
				ylabel(, format(%9.3f) angle(0)) /// 
				name(Price, replace)
			
			/* Earnings scaled by lagged price */
			hist ear ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Scaled Earnings", color(black)) ///
				ylabel(, format(%9.0f) angle(0)) /// 								
				name(Earnings_Scaled, replace)
				
			/* Combined figure */
			graph combine Price Earnings_Scaled, ///
				altshrink cols(2) ysize(4) xsize(10) ///
				title("Price and Scaled Earnings", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_4, replace)	saving(Figure_4, replace) 	
				
	/* b. Persistence of earnings levels and changes */
	
		/* Table 3: Differential persistence */
		
			/* Column 1: Earnings persistence */
			qui xtreg earnings c.l.earnings##1.d_earnings, fe cluster(firm)
				est store M1
				
			/* Column 2: Earnings change persistence */
			qui xtreg d.earnings c.l.d.earnings##1.d_dearnings, fe cluster(firm)
				est store M2
		
			/* Column 3: Earnings change (scaled by price) persistence (Basu (1997)) */
			qui xtreg dear c.l.dear##1.d_dear, fe cluster(firm)
				est store M3		
		
			/* Column 4: Earnings change (scaled by capital) persistence (Ball/Shivakumar (2005)) */
			qui xtreg dear_c c.l.dear_c##1.d_dear_c, fe cluster(firm)
				est store M4			

			/* Combined table */
			estout M1 M2 M3 M4, keep(L.earnings 1.d_earnings 1.d_earnings#cL.earnings LD.earnings 1.d_dearnings 1.d_dearnings#cLD.earnings ///
				L.dear 1.d_dear 1.d_dear#cL.dear L.dear_c 1.d_dear_c 1.d_dear_c#cL.dear_c) ///
				cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(L.earnings "E (t-1)" 1.d_earnings "D(E (t-1) < 0)" 1.d_earnings#cL.earnings "E*D(E < 0)" ///
				LD.earnings "d.E (t-1)" 1.d_dearnings "D(d.E < 0)" 1.d_dearnings#cLD.earnings "d.E*D(d.E < 0)" ///
				L.dear "d.E/P (t-1)" 1.d_dear "D(d.E/P < 0)" 1.d_dear#cL.dear "d.E/P*D(d.E/P < 0)" ///
				L.dear_c "d.E/K (t-1)" 1.d_dear_c "D(d.E/K < 0)" 1.d_dear_c#cL.dear_c "d.E/K*D(d.E/K < 0)") ///
				mlabels("[1] Earnings" "[2] d.Earnings" "[3] d.Earnings/Price" "[4] d.Earnings/Capital")  modelwidth(20) unstack ///
				title("Table 3: Asymmetric Earnings Persistence") ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
		
	/* c. Earnings-response coefficient */
	
		/* Figure 5: Earnings-response  */
		
			/* Data: ComparativeStatics */
			cd "$directory\Data\Output"
			use ComparativeStatics, clear
			
			/* Discount rate */
			graph twoway ///
				(lpolyci erc values if parameter==4 & i==4, clcolor(black)), ///
						legend(off) ///
						ytitle("ERC") ///
						xtitle("Discount rate (r)") xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Discount, replace)	
						
			/* Persistence */
			graph twoway ///
				(lpolyci erc values if parameter==3 & i==3, clcolor(black)), ///
						legend(off) ///
						xtitle("Persistence (rho)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Persistence, replace)
						
			/* Data: Simulation */
			cd "$directory\Data\Output"
			use Simulation, clear
			
			/* Market-to-book */
			preserve
				
				/* Duplicates (by firm) */
				duplicates drop firm, force
				
				/* ERC and market-to-book */
				graph twoway (lpolyci erc mean_mtb, clcolor(black)) ///
					, legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xtitle("Market-to-Book (V/K)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
					name(ERC_MTB, replace)
					
			restore
			
			/* Results Directory */
			cd "$directory\Results\Models\Figures"

			/* Combined figure */
			graph combine ERC_Discount ERC_Persistence ERC_MTB, ///
				altshrink cols(3) ysize(4) xsize(10) ///
				title("Determinants of Earnings-Response Coefficients: Discount Rate, Persistence, and Market-to-Book", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_5, replace) saving(Figure_5, replace)	
		
		/* Table 4: Earnings-response coefficient */
		
			/* ERC */
			qui xtreg ret sue, fe cluster(firm)
				est store M1
				
			/* Cross-sectional determinants */
			qui xtreg ret sue c.sue##c.rho c.sue##c.abs_sue c.sue##c.mtb c.sue##1.loss, fe cluster(firm)
				est store M2
				
			/* Output table */
			estout M1 M2, keep(sue c.sue#c.rho abs_sue c.sue#c.abs_sue mtb c.sue#c.mtb 1.loss 1.loss#c.sue) ///
				cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(c.sue "UE" c.sue#c.rho "UE*Persistence" abs_sue "|UE|" c.sue#c.abs_sue "UE*|UE|" mtb "Market-to-Book" c.sue#c.mtb "UE*MTB" 1.loss "Loss" 1.loss#c.sue "UE*Loss") ///
				title("Table 4: Determinants of Earnings-Response Coefficient") ///								
				mlabels("[1] Return" "[2] Return")  modelwidth(20) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))							
		
		/* Figure 6: Shape of earnings-response coefficient */
		graph twoway ///
			(fpfitci ret sue , clcolor(black)) ///
			(fpfitci ret sue_e , clcolor(black) clpattern(dash)) ///
			, legend(label(2 "ERC (correct expectation)") label(4 "ERC (AR(1) expectation)") order(1 2 4) rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xtitle("Earnings Surprise (t)") ytitle("Return (t)") xlabel(, format(%9.1f)) ylabel(, format(%9.1f) angle(0)) ///
			title("Earnings-Response Coefficient", color(black)) ///
			name(Figure_6, replace) saving(Figure_6, replace)
			
		/* Table 5: Future earnings-response coefficient (Collins et al. (1994)) */
		
			/* Original firm-level specifications */
			qui xtreg ret x_0, fe cluster(firm)
				est store M1
				
			qui xtreg ret x_0 x_1 x_2 x_3, fe cluster(firm)
				est store M2
				
			qui xtreg ret x_0 x_1 x_2 x_3 ret_1 ret_2 ret_3 ep ag, fe cluster(firm)
				est store M3
	
			/* Current firm-level specification */
			qui xtreg ret x_0, fe cluster(firm)
				est store M4
				
			qui xtreg ret x_0 x_1_3, fe cluster(firm)
				est store M5			
			
			qui xtreg ret x_0 x_1_3 ret_1_3 ep ag, fe cluster(firm)
				est store M6
				
			/* Output table */
			estout M1 M2 M3, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(x_0 "X (t)" x_1 "X (t+1)" x_2 "X (t+2)" x_3 "X (t+3)" ret_1 "R (t+1)" ret_2 "R (t+2)" ret_3 "R (t+3)" ep "EP (t-1)" ag "AG (t)") ///
				title("Table 5: Future Earnings-Response Coefficient (Original Specification)") ///				
				mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Original Model")  modelwidth(20) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))

			estout M4 M5 M6, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(x_0 "X (t)" x_1_3 "X (t+1 to t+3)" ret_1_3 "R (t+1 to t+3)" ep "EP (t-1)" ag "AG (t)") ///
				title("Table 5: Future Earnings-Response Coefficient (Current Specification)") ///								
				mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Current Model")  modelwidth(20) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
				
	/* d. Earnings-return asymmetry */
	
		/* Figure 7: Earnings-return concavity */
		
			/* Earnings levels */
			graph twoway ///
				(fpfitci earn ret, clcolor(black)) ///
				, legend(label(2 "Earnings") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Basu_level, replace)
			
			/* Earnings scaled by lagged price */
			graph twoway ///
				(fpfitci ear ret, clcolor(black)) ///
				, legend(label(2 "Earnings/Price") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.1f) angle(0)) ///
				name(Basu, replace)
				
			/* Combined figure */	
			graph combine Basu_level Basu, ///
				altshrink cols(2) ysize(4) xsize(10) ///
				title("Earnings-Return Concavity", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_7, replace) saving(Figure_7, replace)
				
		/* Untabulated: Placebo test */
			
			/* Lagged earnings */
			qui xtreg l_ear c.ret##i.d, fe cluster(firm)
			
			/* Output */
			estout, keep(ret 1.d 1.d#c.ret) ///
				cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(ret "Return" 1.d "D(Return<0)" 1.d#c.ret "Return*D(Return<0)") ///
				title("Untabulated: Placebo Test with Lagged Earnings/Price") ///								
				modelwidth(40) mlabels("Earnings(t-1)/Price(t-1)") ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))				
					
		/* Figure 8: Channels */
		
			/* Earnings-news */
			graph twoway ///
				(fpfitci earnings z, clcolor(black)) ///
				(lfit earnings z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Earnings") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.0f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Earnings_news, replace)			
			
			/* Adjustment costs-news (note: small in terms of magnitude) */
			graph twoway ///
				(fpfitci adj_cost z, clcolor(black)) ///
				, legend(label(2 "Adjustment costs") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.0f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Adj_cost_news, replace)	
			
			/* Return-news */
			graph twoway ///
				(fpfitci ret z, clcolor(black)) ///
				(lfit ret z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Returns") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.0f)) ylabel(, format(%9.1f) angle(0)) ///
				name(Return_news, replace)
				
			/* Combined figure */	
			graph combine Earnings_news Adj_cost_news Return_news, ///
				altshrink cols(3) ysize(4) xsize(10) ///
				title("Relation of Earnings, Adjustment Costs, and Returns to Profitability Shocks (News)", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_8, replace)	saving(Figure_8, replace)	 			
				
		/* Figure 9: Other asymmetries */
			
			/* Profitability-returns */
			graph twoway ///
				(fpfitci profitability ret, clcolor(black)) ///
				(lfit profitability ret, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Profitability_returns, replace)			

			/* Profitability-news */			
			graph twoway ///
				(fpfitci profitability z, clcolor(black)) ///
				(lfit profitability z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///			
				name(Profitability_news, replace)
				
			/* Investment-returns */
			graph twoway ///
				(fpfitci investment ret, clcolor(black)) ///
				(lfit investment ret, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///			
				name(Investment_returns, replace)			
			
			/* Investment-returns */
			graph twoway ///
				(fpfitci investment z, clcolor(black)) ///
				(lfit investment z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///				
				name(Investment_news, replace)	
				
			/* Combined figure */	
			graph combine Profitability_returns Investment_returns Profitability_news Investment_news, ///
				altshrink cols(2) ysize(4) xsize(5) ///
				title("Relation of Profitability and Investment to Returns and Profitability Shocks (News)", color(black) size(medium)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_9, replace) saving(Figure_9, replace)	
			
	/* Results */	

		/* Table 6, Panel A: Earnings-return asymmetry and volatility */
		
			/* Loop across volatility quantiles */
			qui sum q_sd_ear, d
			qui forvalues q = `r(min)'/`r(max)' {

				/* Earnings-return asymmetry */
				reg ear c.ret##i.d if q_sd_ear == `q', cluster(firm)
				est store M`q'
					
			}

			/* Output table */
			estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") ///
				title("Table 6, Panel A: Earnings-Return Asymmetry and Volatility") ///												
				mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))
		
		/* Table 6, Panel B: Earnings-return asymmetry and investment */
		
			/* Loop across volatility quantiles */
			qui sum q_inv, d
			qui forvalues q = `r(min)'/`r(max)' {

				/* Earnings-return asymmetry */
				reg ear c.ret##i.d if q_inv == `q', cluster(firm)
				est store M`q'
					
			}

			/* Output table */
			estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") ///
				title("Table 6, Panel B: Earnings-Return Asymmetry and Investment") ///																
				mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
	
	/* Figure 10: Comparative Statics */
	
		/* Data: ComparativeStatics */
		cd "$directory\Data\Output"
		use ComparativeStatics, clear
			
		/* Basu */

			/* Volatility */
			graph twoway ///
				(lpolyci ear_1 values if parameter==1 & i==1, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Volatility (standard deviation of epsilon)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						title("Earnings-Return Concavity", color(black) size(vhuge)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_Volatility, replace)
						
			/* Adjustment Cost */			
			graph twoway ///
				(lpolyci ear_1 values if parameter==2 & i==2, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Adjustment Costs (psi)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_AdjCost, replace)				

			/* Persistence */
			graph twoway ///
				(lpolyci ear_1 values if parameter==3 & i==3, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Persistence (rho)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_Persistence, replace)
			
			/* Discount rate */			
			graph twoway ///
				(lpolyci ear_1 values if parameter==4 & i==4, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Discount rate (r)") xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_Discount, replace)

		/* ERC */

			/* Volatility */
			graph twoway ///
				(lpolyci erc values if parameter==1 & i==1, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Volatility (standard deviation of epsilon)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						title("Earnings-Response Coefficient", color(black) size(vhuge)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Volatility, replace)
						
			/* Adjustment Cost */			
			graph twoway ///
				(lpolyci erc values if parameter==2 & i==2, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Adjustment Costs (psi)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_AdjCost, replace)				

			/* Persistence */
			graph twoway ///
				(lpolyci erc values if parameter==3 & i==3, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Persistence (rho)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Persistence, replace)
			
			/* Discount rate */			
			graph twoway ///
				(lpolyci erc values if parameter==4 & i==4, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Discount rate (r)") xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Discount, replace)
			
			/* Results directory */
			cd "$directory\Results\Models\Figures"

			/* Combination */
			graph combine Basu_Volatility ERC_Volatility Basu_AdjCost ERC_AdjCost Basu_Persistence ERC_Persistence Basu_Discount ERC_Discount, ///
				rows(4) cols(2) altshrink ysize(10) xsize(10) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Comparative Statics", color(black) size(small)) ///
				name(Figure_10, replace) saving(Figure_10, replace)		
	
/* Log close */
log close Manuscript
	
/******************************************************************************/
/* Online Appendix: Figures and Tables										  */
/******************************************************************************/

/* Log */
cd "$directory\Results\Models\Logs"
log using Appendix, replace smcl name(Appendix)

/* Model comparison */

	/* Loop over models */
	forvalues i = 1(1)3 {

		/* Data */
		cd "$directory\Data\Output"
		use Simulation_Model_`i', clear	
		
		/* Results Directory */
		cd "$directory\Results\Models\Figures\Alternative Models"
		
		/* Model predictions */
		
			/* a. Distributions */
			
				/* Figure 3: Histograms of profitability, investment, earnings, and returns */
				
					/* Profitability */
					hist profitability ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Profitability Levels", color(black)) ///
						name(Profitability, replace)

					/* Investment */				
					hist investment ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Investment Levels", color(black)) ///
						name(Investment, replace)
			
					/* Earnings */
					hist earnings ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Earnings Levels", color(black)) ///
						name(Earnings, replace)
			
					/* Returns */
					hist ret ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Returns", color(black)) ///
						name(Returns, replace)

					/* Combined figure */
					graph combine Profitability Investment Earnings Returns, ///
						altshrink cols(4) ysize(4) xsize(15) ///
						title("Profitability, Investment, Earnings, and Returns", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_3_M`i', replace) saving(Figure_3_M`i', replace)
			
				/* Figure 4: Histograms of price and earnings scaled by lagged price */
			
					/* Price */
					hist price ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Price Levels", color(black)) ///
						name(Price, replace)
					
					/* Earnings scaled by lagged price */
					hist ear ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Scaled Earnings", color(black)) ///
						name(Earnings_Scaled, replace)
						
					/* Combined figure */
					graph combine Price Earnings_Scaled, ///
						altshrink cols(2) ysize(4) xsize(10) ///
						title("Price and Scaled Earnings", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_4_M`i', replace) saving(Figure_4_M`i', replace)		
						
			/* b. Persistence of earnings levels and changes */
			
				/* Table 3: Differential persistence */
				
					/* Column 1: Earnings persistence */
					qui xtreg earnings c.l.earnings##1.d_earnings, fe cluster(firm)
						est store M1
						
					/* Column 2: Earnings change persistence */
					qui xtreg d.earnings c.l.d.earnings##1.d_dearnings, fe cluster(firm)
						est store M2
				
					/* Column 3: Earnings change (scaled by price) persistence (Basu (1997)) */
					qui xtreg dear c.l.dear##1.d_dear, fe cluster(firm)
						est store M3		
				
					/* Column 4: Earnings change (scaled by capital) persistence (Ball/Shivakumar (2005)) */
					qui xtreg dear_c c.l.dear_c##1.d_dear_c, fe cluster(firm)
						est store M4			

					/* Combined table */
					estout M1 M2 M3 M4, keep(L.earnings 1.d_earnings 1.d_earnings#cL.earnings LD.earnings 1.d_dearnings 1.d_dearnings#cLD.earnings ///
						L.dear 1.d_dear 1.d_dear#cL.dear L.dear_c 1.d_dear_c 1.d_dear_c#cL.dear_c) ///
						cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(L.earnings "E (t-1)" 1.d_earnings "D(E (t-1) < 0)" 1.d_earnings#cL.earnings "E*D(E < 0)" ///
						LD.earnings "d.E (t-1)" 1.d_dearnings "D(d.E < 0)" 1.d_dearnings#cLD.earnings "d.E*D(d.E < 0)" ///
						L.dear "d.E/P (t-1)" 1.d_dear "D(d.E/P < 0)" 1.d_dear#cL.dear "d.E/P*D(d.E/P < 0)" ///
						L.dear_c "d.E/K (t-1)" 1.d_dear_c "D(d.E/K < 0)" 1.d_dear_c#cL.dear_c "d.E/K*D(d.E/K < 0)") ///
						mlabels("[1] Earnings" "[2] d.Earnings" "[3] d.Earnings/Price" "[4] d.Earnings/Capital")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
				
			/* c. Earnings-response coefficient */
			
				/* Figure 5: Earnings-response  (w/o comparative static/predictions part) */
					
					/* Market-to-book */
					preserve
						
						/* Duplicates (by firm) */
						duplicates drop firm, force
						
						/* ERC and market-to-book */
						graph twoway (lpolyci erc mean_mtb, clcolor(black)) ///
							, legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
							graphregion(color(white)) plotregion(fcolor(white)) ///
							xtitle("Market-to-Book (V/K)") ///
							name(Figure_5_M`i', replace) saving(Figure_5_M`i', replace)
							
					restore	
				
				/* Table 4: Earnings-response coefficient */
				
					/* ERC */
					qui xtreg ret sue, fe cluster(firm)
						est store M1
						
					/* Cross-sectional determinants */
					qui xtreg ret sue c.sue##c.rho c.sue##c.abs_sue c.sue##c.mtb c.sue##1.loss, fe cluster(firm)
						est store M2
						
					/* Output table */
					estout M1 M2, keep(sue c.sue#c.rho abs_sue c.sue#c.abs_sue mtb c.sue#c.mtb 1.loss 1.loss#c.sue) ///
						cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(sue "UE" c.sue#c.rho "UE*Persistence" abs_sue "|UE|" c.sue#c.abs_sue "UE*|UE|" mtb "Market-to-Book" c.sue#c.mtb "UE*MTB" 1.loss "Loss" 1.loss#c.sue "UE*Loss") ///
						title("Determinants of Earnings-Response Coefficient") ///
						mlabels("[1] Return" "[2] Return")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))									
				
				/* Figure 6: Shape of earnings-response coefficient */
				graph twoway ///
					(fpfitci ret sue, clcolor(black)) ///
					(fpfitci ret sue_e, clcolor(black) clpattern(dash)) ///
					, legend(label(2 "ERC (correct expectation)") label(3 "ERC (AR(1) expectation)") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xtitle("Earnings Surprise (t)") ytitle("Return (t)") ///
					title("Earnings Response Coefficient", color(black)) ///
					name(Figure_6_M`i', replace) saving(Figure_6_M`i', replace)
					
				/* Table 5: Future earnings-response coefficient (Collins et al. (1994)) */
				
					/* Original firm-level specifications */
					qui xtreg ret x_0, fe cluster(firm)
						est store M1
						
					qui xtreg ret x_0 x_1 x_2 x_3, fe cluster(firm)
						est store M2
						
					qui xtreg ret x_0 x_1 x_2 x_3 ret_1 ret_2 ret_3 ep ag, fe cluster(firm)
						est store M3
			
					/* Current firm-level specification */
					qui xtreg ret x_0, fe cluster(firm)
						est store M4
						
					qui xtreg ret x_0 x_1_3, fe cluster(firm)
						est store M5			
					
					qui xtreg ret x_0 x_1_3 ret_1_3 ep ag, fe cluster(firm)
						est store M6
						
					/* Output table */
					estout M1 M2 M3, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(x_0 "X (t)" x_1 "X (t+1)" x_2 "X (t+2)" x_3 "X (t+3)" ret_1 "R (t+1)" ret_2 "R (t+2)" ret_3 "R (t+3)" ep "EP (t-1)" ag "AG (t)") ///
						title("Future Earnings-Response Regressions (following Collins et al. (1994))") ///
						mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Original Model")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))

					estout M4 M5 M6, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(x_0 "X (t)" x_1_3 "X (t+1 to t+3)" ret_1_3 "R (t+1 to t+3)" ep "EP (t-1)" ag "AG (t)") ///
						title("Future Earnings-Response Regressions (Current Firm-Level Specification)") ///
						mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Current Model")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
						
			/* d. Earnings-return asymmetry */
			
				/* Figure 7: Earnings-return concavity */
				
					/* Earnings levels */
					graph twoway ///
						(fpfitci earn ret, clcolor(black)) ///
						, legend(label(2 "Earnings") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_level, replace)
					
					/* Earnings scaled by lagged price */
					graph twoway ///
						(fpfitci ear ret, clcolor(black)) ///
						, legend(label(2 "Earnings/Price") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu, replace)
						
					/* Combined figure */	
					graph combine Basu_level Basu, ///
						altshrink cols(2) ysize(4) xsize(10) ///
						title("Earnings-Return Concavity", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_7_M`i', replace) saving(Figure_7_M`i', replace)
					
				/* Figure 8: Channels */
				
					/* Earnings-news */
					graph twoway ///
						(fpfitci earnings z, clcolor(black)) ///
						(lfit earnings z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Earnings") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Earnings_news, replace)			
					
					/* Adjustment costs-news (note: small in terms of magnitude) */
					graph twoway ///
						(fpfitci adj_cost z, clcolor(black)) ///
						, legend(label(2 "Adjustment costs") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Adj_cost_news, replace)	
					
					/* Return-news */
					graph twoway ///
						(fpfitci ret z, clcolor(black)) ///
						(lfit ret z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Returns") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Return_news, replace)
						
					/* Combined figure */	
					graph combine Earnings_news Adj_cost_news Return_news, ///
						altshrink cols(3) ysize(4) xsize(10) ///
						title("Relation of Earnings, Adjustment Costs, and Returns" "to Profitability Shocks (News)", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_8_M`i', replace) saving(Figure_8_M`i', replace)				
						
				/* Figure 9: Other asymmetries */
					
					/* Profitability-returns */
					graph twoway ///
						(fpfitci profitability ret, clcolor(black)) ///
						(lfit profitability ret, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
						name(Profitability_returns, replace)			

					/* Profitability-news */			
					graph twoway ///
						(fpfitci profitability z, clcolor(black)) ///
						(lfit profitability z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
						name(Profitability_news, replace)
						
					/* Investment-returns */
					graph twoway ///
						(fpfitci investment ret, clcolor(black)) ///
						(lfit investment ret, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///						
						name(Investment_returns, replace)			
					
					/* Investment-returns */
					graph twoway ///
						(fpfitci investment z, clcolor(black)) ///
						(lfit investment z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///						
						name(Investment_news, replace)	
						
					/* Combined figure */	
					graph combine Profitability_returns Investment_returns Profitability_news Investment_news, ///
						altshrink cols(2) ysize(4) xsize(5) ///
						title("Relation of Profitability and Investment" "to Returns and Profitability Shocks (News)", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_9_M`i', replace) saving(Figure_9_M`i', replace)	
								
			/* Results */

				/* Table 6, Panel A: Earnings-return asymmetry and volatility */
				
					/* Loop across volatility quantiles */
					qui sum q_sd_ear, d
					qui forvalues q = `r(min)'/`r(max)' {

						/* Earnings-return asymmetry */
						reg ear c.ret##i.d if q_sd_ear == `q', cluster(firm)
						est store M`q'
							
					}

					/* Output table */
					estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") title("Earnings/Price Volatility")  ///
						mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))
				
				/* Table 6, Panel B: Earnings-return asymmetry and investment */
				
					/* Loop across volatility quantiles */
					qui sum q_inv, d
					qui forvalues q = `r(min)'/`r(max)' {

						/* Earnings-return asymmetry */
						reg ear c.ret##i.d if q_inv == `q', cluster(firm)
						est store M`q'
							
					}

					/* Output table */
					estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") title("Investment Levels")  ///
						mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))							
	
	/* End: model loop */
	}
	
/* Data */
cd "$directory\Data\Output"
use Simulation, clear	

/* Further Appendix Tables */

	/* Table A5: Asymmetries */
		
		/* Earnings levels */
		qui xtreg earnings c.ret##i.d, fe cluster(firm)
			est store M1
			
		/* Earnings scaled by lagged price */
		qui xtreg ear c.ret##i.d, fe cluster(firm)
			est store M2
			
		/* Cash flow */
		qui xtreg cash c.ret##i.d, fe cluster(firm)
			est store M3
			
		/* Cash flow scaled by lagged price */
		qui xtreg cfo c.ret##i.d, fe cluster(firm)
			est store M4
						
		/* Investment */
		qui xtreg investment c.ret##i.d, fe cluster(firm)
			est store M5
			
		/* Investment scaled by lagged price */
		qui xtreg inv c.ret##i.d, fe cluster(firm)
			est store M6

		/* Output table */
		estout M1 M2 M3 M4 M5 M6, keep(ret 1.d 1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
			legend label varlabels(ret "Return" 1.d "D(Return<0)" 1.d#c.ret "Return*D") title("Earnings, Cash Flow, And Investment Asymmetry")  ///
			mlabels("Earnings" "Earnings/Price" "Cash Flow" "Cash Flow/Price" "Investment" "Investment/Price")  modelwidth(8) unstack ///
			stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
		
	/* Table A6: Decomposition */	
			
		/* Firm-fixed effects decomposition */
		qui {
		
			/* Partialling firm effects out */
			xtreg ear d, fe
			predict r_ear, e

			xtreg ret d, fe
			predict r_ret, e
	
			/* Negative return partition: variance/covariance */
			corr r_ear r_ret if ret<0, cov
			local cov_neg = r(cov_12)
			local var_neg = r(Var_2)

			/* Positive return partition: variance/covariance */
			corr r_ear r_ret if ret>=0, cov
			local cov_pos = r(cov_12)
			local var_pos = r(Var_2)
		}
		
		/* Output */
		di "___________________________"
		di "Negative Return Partition"
		di "Return variance: " round(`var_neg',.0001)
		di "Earnings-Return covariance: " round(`cov_neg',.0001)
		di "___________________________"
		di "Positive Return Partition"
		di "Return variance: " round(`var_pos',.0001)
		di "Earnings-Return covariance: " round(`cov_pos',.0001)
		di "___________________________"
		di "Spreads/Differences (Negative - Positive)"
		di "Variance: " round(`var_neg'-`var_pos',.0001)
		di "Earnings-Return covariance: " round(`cov_neg'-`cov_pos',.0001)
	
/* Log: close */
log close Appendix

/******************************************************************************/
/* Accrual Model: Simulation data (based on calibrated parameter values)	  */
/******************************************************************************/

/* Directory */
cd "$directory\Code\Models\02-Accrual model\Simulation\Data"

/* Data */
insheet using SimulationsWorkingCapital.csv,  clear
save Simulation_workingcapital, replace

/* Time Series */
gen t = _n
label var t "Period"

tsset t

/* Variables */
rename v1 earnings
label var earnings "Earnings"

rename v2 cash
label var cash "Cash from Operations"

rename v3 price
label var price "Price"

rename v4 profitability
label var profitability "Profitability"

rename v5 investment
label var investment "Investment"

rename v6 capital
label var capital "Capital"

rename v7 adj_cost
label var adj_cost "Adjustment cost"

rename v8 working_capital
label var working_capital "Working Capital"

gen price_ex_div = price-cash+investment
label var price_ex_div "Price (ex dividend)"

gen ret = d.price/l.price_ex_div
label var ret "Return"

gen wc_accruals = d.working_capital
label var wc_accruals "Working Capital Accruals"

gen wca = wc_accruals/l.price_ex_div
label var wca "Working Capital Accruals(t)/Price(t-1)"

/* Outlier Treatment */
drop if t<=1000 | t>101000
drop if abs(ret)>1

/* Figure A1: Working Capital Accruals */

	/* Results Directory */
	cd "$directory\Results\Models\Figures"
	
	/* Graphs */
	graph twoway ///
		(fpfitci wca ret, clcolor(black)) ///
		, legend(label(2 "Working Capital Accruals(t)/Price(t-1)") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///	
		title("Working Capital Accruals and Returns", color(black)) ///
		name(Figure_A1, replace) saving(Figure_A1, replace)

/******************************************************************************/
/* Non-Parametric Comparison												  */
/******************************************************************************/

/* Figure A2: Simulated Patterns */

	/* Data */
	cd "$directory\Data\Output"
	use Simulation, clear
	
	/* Results Directory */
	cd "$directory\Results\Models\Figures"
	
	/* Graph 1: Earnings-Return Concavity */
	graph twoway ///
		(fpfitci ear ret, clcolor(black)) ///
		, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
		ytitle("Earnings/Price") ///
		xtitle("Return") ///		
		title("Earnings-Return Concavity", color(black)) ///
		name(Figure_A2_1, replace) saving(Figure_A2_1, replace)

	
	/* Graph 2: Concavity and Volatility*/
	preserve
	
		/* Drop duplicates */
		duplicates drop firm, force
		
		/* Graph */
		graph twoway (lpolyci basu sd_ear, clcolor(black)) ///
			, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
			ytitle("Earnings-Return Concavity") ///
			xtitle("Earnings Volatility") ///
			title("Earnings-Return Concavity and Earnings Volatility", color(black)) ///
			name(Figure_A2_2, replace) saving(Figure_A2_2, replace)
			
	restore
	
	/* Graph 3: ERC */
	graph twoway ///
		(fpfitci ret sue_e, clcolor(black)) ///
		, legend(label(1 "CI 95%") label(2 "ERC") order(1 2 4) rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
		ytitle("Return") ///
		xtitle("Earnings Surprise") ///
		title("Earnings-Response Coefficient", color(black)) ///
		name(Figure_A2_3, replace) saving(Figure_A2_3, replace)
	
	/* Graph 4: ERC and Volatilty */
	preserve
	
		/* Drop duplicates */
		duplicates drop firm, force
		
		/* Graph */
		graph twoway (lpolyci erc sd_ear, clcolor(black)) ///
			, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
			ytitle("ERC") ///
			xtitle("Earnings Volatility") ///
			title("ERC and Volatility", color(black)) ///
			name(Figure_A2_4, replace) saving(Figure_A2_4, replace)
	
	restore
	
	/* Graph 5: ERC and MTB */
	preserve
	
		/* Drop duplicates */
		duplicates drop firm, force
		
		/* Graph */
		graph twoway (lpolyci erc mean_mtb, clcolor(black)) ///
			, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///					
			ytitle("ERC") ///
			xtitle("Market-to-Book") ///
			title("ERC and Market-to-Book", color(black)) ///
			name(Figure_A2_5, replace) saving(Figure_A2_5, replace)
		
	restore
/******************************************************************************/
/* Title:   Evaluation of Model Predictions in Compustat Data                 */
/* Authors: M. Breuer, D. Windisch                                            */
/* Date:    11/29/2018                                                        */
/******************************************************************************/
/* Program description:                                                       */
/* Generates Figures and Tables using Compustat, CRSP, and I/B/E/S data       */
/******************************************************************************/

*Preliminaries*
version 13.1
clear all
set more off
set type double

********************************************************************************
*** Annual Return Calculation ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\CRSP_monthly.dta", clear
egen start = min(date), by(permno)
egen end   = max(date), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_CRSP_monthly.dta", replace

**Data**
use "$directory\Data\Original\CRSP_monthly.dta", clear

**Sample**

*Ordinary shares of stocks listed on NYSE, AMEX, or NASDAQ*
keep if shrcd == 10|shrcd == 11|shrcd == 12
keep if exchcd == 1|exchcd == 2|exchcd == 3

*Panel*
gen tradingdate = mofd(date)
xtset permno tradingdate, monthly

*Cumulative 1-year returns (at fiscal year end + 3m)*
gen r = ln(1+ret)
gen v = ln(1+vwretd)
gen ret1y = r
gen vwret1y = v
forvalues i = 1/11 {
	replace ret1y = ret1y+l`i'.r
	replace vwret1y = vwret1y+l`i'.v
}
replace ret1y = exp(f3.ret1y)-1
replace vwret1y = exp(f3.vwret1y)-1

*Market-adjusted 1-year returns*
gen aret1y = ret1y - vwret1y
label var aret1y "Market Adjusted Annual Return (-9 to +3)"

*Matchdate (year-month)*
gen matchdate = tradingdate

*Saving*
keep permno matchdate aret1y
save "$directory\Data\Output\annualreturns.dta", replace

********************************************************************************
*** Announcement Return Calculation ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\CRSP_daily", clear
egen start = min(date), by(permno)
egen end   = max(date), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_CRSP_daily.dta", replace

**Data**
use "$directory\Data\Original\CRSP_daily", clear

*Ordinary shares of stocks listed on NYSE, AMEX, or NASDAQ*
keep if shrcd == 10|shrcd == 11|shrcd == 12
keep if exchcd == 1|exchcd == 2|exchcd == 3

*Panel*
bcal create allshares, from(date) dateformat(dmy) replace
gen tradingdate = bofd("allshares", date)
format tradingdate %tballshares
xtset permno tradingdate

*Cumulative 3-day returns*
gen r = ln(1+ret)
gen v = ln(1+vwretd)
gen ret3d = l1.r+r+f1.r
gen vwret3d = l1.v+v+f1.v

replace ret3d = exp(ret3d)-1
replace vwret3d = exp(vwret3d)-1

*Market-adjusted 3-day returns*
gen aret3d = ret3d - vwret3d
label var aret3d "Market Adjusted 3-day Return (centered)"

*Price data in d-2*
replace prc = abs(prc)
gen prcl2d = l2.prc
label var prcl2d "Price at d-2"

*Matchdate*
gen matchdate = date

*Saving*
keep permno matchdate aret3d prcl2d
save "$directory\Data\Output\dailyreturns.dta", replace

********************************************************************************
*** Earnings Surprise Calculation ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\IBES_act_unadj", clear
egen start = min(pends), by(ticker)
egen end   = max(pends), by(ticker)
bys ticker: keep if _n==1
format %td start end
keep ticker start end
save "$directory\Data\Identifiers\ID_IBES_act_unadj.dta", replace

use "$directory\Data\Original\IBES_fcact_adj", clear
egen start = min(fpedats), by(ticker)
egen end   = max(fpedats), by(ticker)
bys ticker: keep if _n==1
format %td start end
keep ticker start end
save "$directory\Data\Identifiers\ID_IBES_fcact_adj.dta", replace

use "$directory\Data\Original\IBES_fc_unadj.dta", clear
egen start = min(fpedats), by(ticker)
egen end   = max(fpedats), by(ticker)
bys ticker: keep if _n==1
format %td start end
keep ticker start end
save "$directory\Data\Identifiers\ID_IBES_fc_unadj.dta", replace

use "$directory\Data\Original\iclink.dta", clear
drop if permno == .
egen start = min(sdate), by(permno)
egen end   = max(edate), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_iclink.dta", replace

use "$directory\Data\Original\Compu_quarterly", clear
egen start = min(datadate), by(permno)
egen end   = max(datadate), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_Compu_quarterly.dta", replace

**Data**
use "$directory\Data\Original\IBES_act_unadj", clear

*Missing actuals*
drop if value == .

*Non-USD data*
keep if curr_act == "USD"

*Saving*
ren pends fpedats
ren anndats anndats_act
ren anntims anntims_act
ren value actual
keep ticker fpedats anndats_act anntims_act actual
save "$directory\Data\Output\ibesunadj_actuals", replace

**Data**
use "$directory\Data\Original\IBES_fcact_adj", clear

*Missing forecasts, actuals, announcement dates*
drop if value == .|actual == .|anndats_act == .

*Non-USD data*
keep if curr_act 	== "USD"
keep if report_curr == "USD"

*Keep only last estimate of each analyst on the same day (for merging)*
gen anntime = clock(anntims, "hms")
gen acttime = clock(acttims, "hms")
gsort ticker fpedats estimator analys -anndats -anntime -actdats -acttime
duplicates drop ticker fpedats estimator analys anndats, force

*Saving*
ren value value_adj
ren actual actual_adj
keep ticker fpedats estimator analys anndats value_adj actual_adj
save "$directory\Data\Output\ibesadj", replace

**Prepare ticker-permno link file**
use "$directory\Data\Original\iclink.dta", clear
drop if permno == .

bys ticker: gen position = _n
forvalues i = 1(1)10 {
gen sdatetmp_`i' = sdate if position == `i'
bys ticker: egen sdate_`i' = mean(sdatetmp_`i')
gen edatetmp_`i' = edate if position == `i'
bys ticker: egen edate_`i' = mean(edatetmp_`i')
format %td sdate_`i' edate_`i'
drop sdatetmp* edatetmp*
}

duplicates drop ticker, force
keep ticker permno sdate_* edate_*

*Saving*
save "$directory\Data\Output\iclink_unique.dta", replace

**Data**
use "$directory\Data\Original\IBES_fc_unadj.dta", clear

*Merge with undadjusted actuals*
merge m:1 ticker fpedats using "$directory\Data\Output\ibesunadj_actuals", keep(match) nogenerate

*Non-USD data*
keep if report_curr == "USD"

*Keep only last estimate of each analyst on the same day (for merging)*
gen anntime = clock(anntims, "hms")
gen acttime = clock(acttims, "hms")
gsort ticker fpedats estimator analys -anndats -anntime -actdats -acttime
duplicates drop ticker fpedats estimator analys anndats, force

merge 1:1 ticker fpedats estimator analys anndats using "$directory\Data\Output\ibesadj", keep(match) nogenerate

*Adjust for stock splits between forecast and actual announcement date*
gen value_ratio = value/value_adj
replace value_ratio = 1 if value == 0 & value_adj == 0
gen actual_ratio = actual/actual_adj
replace actual_ratio = 1 if actual == 0 & actual_adj == 0
gen adjfactor = actual_ratio/value_ratio
gen feps1y = value*adjfactor

*Missing forecast*
drop if feps1y == .

*Merge with ticker-permno link file*
merge m:1 ticker using "$directory\Data\Output\iclink_unique.dta", keep(match) nogenerate
gen timelink = .
forvalues i = 1(1)10 {
replace timelink = 1 if fpedats >= sdate_`i' & fpedats <= edate_`i'
}
drop if timelink == .

*Shift IBES announcement date if release is after 04:00 EST*
gen ahour = substr(anntims_act,1,2)
destring ahour, replace
replace anndats_act = anndats_act + 1 if ahour >= 16

*Correct IBES announcement date*
ren fpedats datadate
merge m:1 permno datadate using "$directory\Data\Original\Compu_quarterly", keep(1 3) nogenerate
gen eadate = anndats_act if anndats_act > datadate
replace eadate = rdq if rdq < anndats_act & rdq > datadate
drop if eadate == .

*Keep only forecasts in -95 to -3 days window before actual announcement date*
drop if eadate - anndats > 95
drop if eadate - anndats < 3

*Keep only last forecast of every analyst for each firm-year*
gsort ticker analys -anndats -anntims
duplicates drop ticker analys datadate, force

*Compute median consensus forecast by firm-year*
bys ticker datadate: egen epsmed  = median(feps1y)

*Keep only one observation per firm-year*
duplicates drop ticker datadate, force

*Duplicates*
duplicates tag permno datadate, gen(dup)
drop if dup > 0

*Earnings surprise*
gen surp = actual - epsmed
format surp %3.2f

*Saving*
keep cname datadate permno eadate surp
save "$directory\Data\Output\ibes.dta", replace

********************************************************************************
*** Prepare Compustat Sample ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\Compu_annual.dta", clear
egen start = min(datadate), by(lpermno)
egen end   = max(datadate), by(lpermno)
bys lpermno: keep if _n==1
format %td start end
keep lpermno start end
save "$directory\Data\Identifiers\ID_Compu_annual.dta", replace

**Data**
use "$directory\Data\Original\Compu_annual.dta", clear

*Select data*
keep lpermno fyear datadate ib cshpri prcc_f oancf xidoc act lct che dlc ///
txp dp ppegt invt at capx ivncf xrd ceq sic

*Add annual returns*
ren lpermno permno
gen matchdate = mofd(datadate)
merge 1:1 permno matchdate using "$directory\Data\Output\annualreturns.dta", keep(1 3) nogenerate

*Add IBES data*
merge 1:1 permno datadate using "$directory\Data\Output\ibes.dta", keep(1 3) nogenerate

*Add 3-day returns (repeated for eadates on non-trading days)*
replace matchdate = eadate
replace matchdate = _n*10000 if matchdate == .
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", keep(1 3) nogenerate
replace matchdate = matchdate + 1
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", update keep(1 3 4 5) nogenerate
replace matchdate = matchdate + 1
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", update keep(1 3 4 5) nogenerate
replace matchdate = matchdate + 1
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", update keep(1 3 4 5) nogenerate

*Panel*
sort permno datadate
duplicates drop permno fyear, force
xtset permno fyear

********************************************************************************
*** Main Variables Definition ***
********************************************************************************

*Earnings*
gen inc = ib/cshpri/l.prcc_f if l.prcc_f >= 1 
label var inc "Earnings"

*Operating Cash Flow*
gen cfo	= (oancf-xidoc)/cshpri/l.prcc_f if l.prcc_f >= 1
label var cfo "Operating Cash Flow"

*Accruals*
gen acc = inc - cfo
label var acc "Accruals"

*Accruals/Operating Cash Flow from Balance Sheet Approach*
gen acc_bs = (d.act - d.lct - d.che + d.dlc + d.txp - dp)/cshpri/l.prcc_f if l.prcc_f >= 1
gen cfo_bs = inc - acc_bs

replace acc = acc_bs if acc == .
replace cfo = cfo_bs if cfo == .

*Earnings: Operating Cash Flow less Depreciation*
gen oancfdp = oancf - xidoc - dp
replace oancfdp = ib - (d.act - d.lct - d.che + d.dlc + d.txp) if oancfdp == .
gen mic = oancfdp/cshpri/l.prcc_f if l.prcc_f >= 1
label var mic "Model Earnings"

*Negative Return Dummy*
gen d = (aret1y < 0) if aret1y != .
label var d "Negative Returns"

*Investment-to-Assets Ratio*
gen iva = (d.ppegt + d.invt)/l.at if l.prcc_f >= 1
label var iva "Investment-to-Assets Ratio"

*Investment Growth*
replace xrd = 0 if xrd == .
gen ivg = (d.capx + d.xrd)/(l.capx + l.xrd)
replace ivg = 0 if d.capx == 0 & d.xrd == 0 & l.capx == 0 & l.xrd == 0
replace ivg = . if l.prcc_f < 1
label var ivg "Investment Growth"

*Investing Cash Flow*
replace ivncf = ivncf*-1
gen ivc = ivncf/l.at if l.prcc_f >= 1
label var ivc "Investing Cash Flow"

*Earnings Surprise (IBES)*
replace surp = . if fyear < 1993
gen sue = surp/prcl2d if prcl2d >= 1

*Volatility Measures* (Min. obs = 5)*
egen ct_inc = count(inc) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_inc = sd(inc) if ct_inc >= 5 & inc != . & fyear >= 1963 & fyear <= 2014, by(permno)
egen ct_cfo = count(cfo) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_cfo = sd(cfo) if ct_cfo >= 5 & cfo != . & fyear >= 1963 & fyear <= 2014, by(permno)
egen ct_acc = count(acc) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_acc = sd(acc) if ct_acc >= 5 & acc != . & fyear >= 1963 & fyear <= 2014, by(permno)
egen ct_in2 = count(inc) if fyear >= 1993 & fyear <= 2014, by(permno)
egen sd_in2 = sd(inc) if ct_inc >= 5 & inc != . & fyear >= 1993 & fyear <= 2014, by(permno)
egen ct_mic = count(mic) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_mic = sd(mic) if ct_mic >= 5 & mic != . & fyear >= 1963 & fyear <= 2014, by(permno)
drop ct_*

*Market-to-Book*
gen mtb = (prcc_f*cshpri)/ceq if ceq > 0

*Define time-period*
drop if fyear < 1963|fyear > 2014

*Trim variables at 1%*
qui {
local variables="aret* inc cfo acc mic iva ivg ivc ib mtb"
foreach var of varlist `variables' {
sum `var', d
replace `var'=. if `var'>=r(p99)
replace `var'=. if `var'<=r(p1)
}
}

*Saving*
save "$directory\Data\Output\finaldata.dta", replace
	
********************************************************************************
*** TABLE 7: Compustat Concavities and Volatility ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

local sorts = "sd_inc sd_cfo sd_acc"
	foreach var of varlist `sorts' {
	qui bys permno: replace `var' = . if missing(aret1y, inc, cfo, acc)
	qui bys permno `var': replace `var' = . if _n!=1
	qui xtile `var'_q = `var', nq(5)
	qui bys permno: replace `var'_q = `var'_q[_n-1] if `var'_q == . 
}

forvalues k = 1/5 {
	xtreg inc c.aret1y##i.d i.fyear if sd_inc_q == `k', fe cluster(permno)
	est store inc_q
	xtreg cfo c.aret1y##i.d i.fyear if sd_cfo_q == `k', fe cluster(permno)
	est store cfo_q
	xtreg acc c.aret1y##i.d i.fyear if sd_acc_q == `k', fe cluster(permno)
	est store acc_q

	esttab inc_q cfo_q acc_q using "$directory\Results\Compustat\Tables\Table_7.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}

********************************************************************************
*** TABLE 8: Compustat Concavities and Investment ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

replace iva = . if missing(aret1y, inc, cfo, acc)
qui xtile iva_q = iva if iva != ., nq(5)

forvalues k = 1/5 {
	xtreg inc c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store inc_q
	xtreg cfo c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store cfo_q
	xtreg acc c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store acc_q

	esttab inc_q cfo_q acc_q using "$directory\Results\Compustat\Tables\Table_8.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}
	
********************************************************************************
*** Table A1: Data Moments (representing stable, industrial firm) ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear		
		
**Sample restrictions**

*Industries*
destring sic, force replace
drop if (sic >= 4000 & sic < 5000) | (sic >= 6000 & sic < 7000)
 
*Panel*
duplicates drop permno fyear, force
egen id = group(permno)
xtset id fyear

*Constant sample (firms with about 20-30 observations)*
keep if fyear >= (2014-30) & fyear <= 2014
foreach var of varlist oancf ivncf mtb {
	egen count = total(`var'!=.), by(id) missing	
	keep if count >= 20
	drop count
}

**Variables**

*(1) Cash flow variability*
gen cfo_at = oancf/l.at
egen std_cfo_at = sd(cfo_at), by(id)

*(2) Cash flow autocorrelation [note: pooled regression to improve precision]*
xtreg oancf l.oancf i.fyear, fe
gen ar_cfo = _b[L.oancf]
		
*(3) Investment level*
gen inv_at = ivncf/l.at
egen m_inv_at = mean(inv_at), by(id)

*(4) Investment variability*
egen std_inv_at = sd(inv_at), by(id)

*(5) Investment autocorrelation [note: pooled regression to improve precision]*
xtreg ivncf l.ivncf i.fyear, fe
gen ar_inv = _b[L.ivncf]
		
*(6) Market to book*
egen m_mtb = mean(mtb), by(id)

**Moments**
local M = "m_* std_* ar_*"
keep `M'

*Average moment*
qui foreach var of varlist `M' {
	sum `var'
	replace `var' = r(mean)
}

*Keep first observation*
keep if _n==1

*Order*
order std_cfo_at ar_cfo m_inv_at std_inv_at ar_inv m_mtb

*Output directory*
cd "$directory\Data\Output"
save Moments, replace
export delimited Moments.csv, replace novarnames	

********************************************************************************
*** TABLE A5: Concavities ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

foreach depvar of varlist inc cfo acc iva ivg ivc{

xtreg `depvar' c.aret1y##d i.fyear, fe cluster(permno)
est store `depvar'

esttab `depvar' using "$directory\Results\Compustat\Tables\Table_A5.rtf", ///
keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
}

********************************************************************************
*** TABLE A6: Decomposition of Earnings-Return Concavity ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

xtreg inc c.aret1y##i.d i.fyear, fe
local basu = _b[1.d#aret1y]
gen sample = e(sample)

xtreg inc d if sample==1, fe
predict r_inc if sample==1, e

xtreg aret1y d if sample==1, fe
predict r_aret1y if sample==1, e

*Log: open*
cd "$directory\Results\Compustat\Logs"
log using Appendix_Compustat, replace smcl name(Appendix_Compustat)

*Table A6: Decomposition of Earnings-Return Concavity*

	/* Firm-fixed effects decomposition */
	qui {
		
		/* Negative return partition: variance/covariance */
		corr r_inc r_aret1y if d == 1 & sample==1, cov
		local cov_neg = r(cov_12)
		local var_neg = r(Var_2)

		/* Positive return partition: variance/covariance */
		corr r_inc r_aret1y if d == 0 & sample==1, cov
		local cov_pos = r(cov_12)
		local var_pos = r(Var_2)
	}
		
	/* Output */
	di "___________________________"
	di "Negative Return Partition"
	di "Return variance: " round(`var_neg',.0001)
	di "Earnings-Return covariance: " round(`cov_neg',.0001)
	di "___________________________"
	di "Positive Return Partition"
	di "Return variance: " round(`var_pos',.0001)
	di "Earnings-Return covariance: " round(`cov_pos',.0001)
	di "___________________________"
	di "Spreads/Differences (Negative - Positive)"
	di "Variance: " round(`var_neg'-`var_pos',.0001)
	di "Earnings-Return covariance: " round(`cov_neg'-`cov_pos',.0001)		
		
*Log: close*
log close Appendix_Compustat

********************************************************************************
*** TABLE A7: Compustat Earnings-Return Concavity and Volatility/Investment 
***           with Alternative Earnings Definition ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

local sorts = "sd_mic"
	foreach var of varlist `sorts' {
	qui bys permno: replace `var' = . if missing(aret1y, inc, cfo, acc)
	qui bys permno `var': replace `var' = . if _n!=1
	qui xtile `var'_q = `var', nq(5)
	qui bys permno: replace `var'_q = `var'_q[_n-1] if `var'_q == . 
}

forvalues k = 1/5 {
	xtreg mic c.aret1y##i.d i.fyear if sd_mic_q == `k', fe cluster(permno)
	est store mic_q

	esttab mic_q using "$directory\Results\Compustat\Tables\Table_A7_A.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}
	
use "$directory\Data\Output\finaldata.dta", clear

replace iva = . if missing(aret1y, inc, cfo, acc)
qui xtile iva_q = iva if iva != ., nq(5)

forvalues k = 1/5 {
	xtreg mic c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store mic_q

	esttab mic_q using "$directory\Results\Compustat\Tables\Table_A7_B.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}

********************************************************************************
*** FIGURE A2: Non-Parametric Comparison of Simulated and Compustat 
***            Earnings-Return Patterns ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

**Compute firm-specific Basu coefficients**

	*ID*
	egen firmid = group(permno)

	*Placeholders*
	gen basu = .
	gen basu_obs = .

	*Loop over firms*
	qui sum firmid, d
	qui forvalues i = `r(min)'(1)`r(max)' {
	
		*Capture*
		capture {
		
			*Basu*/
			reg inc c.aret1y##i.d if firmid == `i'
			replace basu = _b[1.d#c.aret1y] if firmid == `i'
			replace basu_obs = e(N) if firmid == `i'

		}
	}

	*Drop estimates with less than 5 obs.*
	replace basu = . if basu_obs < 5	
	
	*Output directory*
	cd "$directory\Results\Compustat\Figures"
	
	*Basu
	
		*Graph 1: Earnings-Return Concavity*
		graph twoway ///
			(fpfitci inc aret1y if abs(aret1y)<1, clcolor(black)) ///
				, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///	
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
				ytitle("Earnings/Price") ///
				xtitle("Return") ///
				title("Earnings-Return Concavity", color(black)) ///
				name(Figure_A2_1, replace) saving(Figure_A2_1, replace) 	
		
		*Graph 2: Earnings-Return Concavity and Volatility*
		preserve
		
			*Missing*
			replace fyear = . if firmid == .
			xtset firmid fyear

			*Drop to firm-level*
			duplicates drop firmid, force
			
			*Outlier*
			qui sum basu, d
			local basu_min = r(p5)
			local basu_max = r(p95)
				
			*Basu and Volatility*
			qui sum sd_inc, d
			local sd_inc_max = r(p95)
			
			graph twoway ///
				(lpolyci basu sd_inc if `basu_min'<basu & basu<`basu_max' & sd_inc<`sd_inc_max', clcolor(black)) ///
					, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
					ytitle("Earnings-Return Concavity") ///
					xtitle("Earnings Volatility") ///
					title("Earnings-Return Concavity and Volatility", color(black)) ///
					name(Figure_A2_2, replace) saving(Figure_A2_2, replace)

		restore

**Compute firm-specific Basu coefficients**

	*ID8
	drop firmid
	egen firmid = group(permno) if fyear >= 1993
	
	*Outliers (Cohen et al., 2007)*
	replace sue = . if abs(sue) > 0.1
	
	*Placeholders*
	gen erc = .
	gen erc_obs = .

	*Loop over firms*
	qui sum firmid, d
	qui forvalues i = `r(min)'(1)`r(max)' {
	
		*Capture*
		capture {

			*ERC*
			reg aret3d sue if firmid == `i'
			replace erc = _b[sue] if firmid == `i'
			replace erc_obs = e(N) if firmid == `i'

		}
	}

	*Drop estimates with less than 5 obs.*
	replace erc = . if erc_obs < 5		
		
	*ERC*
	
		*Graph 3: Earnings-Response Coefficient*
		graph twoway ///
			(fpfitci aret3d sue, clcolor(black)) ///
				, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///	
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
				ytitle("Return") ///
				xtitle("Earnings Surprise") ///
				title("Earnings-Response Coefficient", color(black)) ///
				name(Figure_A2_3, replace) saving(Figure_A2_3, replace)

		*Graphs 4, 5: ERC, Volatility, and Market-to-Book*
		preserve

			*Missing*
			replace fyear = . if firmid == .
			xtset firmid fyear

			*Keep one observation for each firm*
			duplicates drop firmid, force
				
			*Mark outliers*
			qui sum erc, d
			local erc_min = r(p5)
			local erc_max = r(p95)
			qui sum sd_in2, d
			local sd_in2_max = r(p95)
			qui sum mtb, d
			local mtb_max = r(p95)

			*Graph 4: ERC and Volatility*
			graph twoway ///
				(lpolyci erc sd_in2 if `erc_min'<erc & erc<`erc_max' & sd_in2<`sd_in2_max', clcolor(black)) ///
					, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
					ytitle("ERC") ///
					xtitle("Earnings Volatility") ///
					title("ERC and Volatility", color(black)) ///
					name(Figure_A2_4, replace) saving(Figure_A2_4, replace)

			*Graph 5: ERC and Market-to-Book*
			graph twoway ///
				(lpolyci erc mtb if `erc_min'<erc & erc<`erc_max' & mtb<`mtb_max', clcolor(black)) ///
					, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
					ytitle("ERC") ///
					xtitle("Market-to-Book") ///
					title("ERC and Market-to-Book", color(black)) ///
					name(Figure_A2_5, replace) saving(Figure_A2_5, replace)

		restore
/******************************************************************************/
/* Illustration of Cross-Sectional Volatility Results						  */
/******************************************************************************/
/* Simulated Results:														  */
/*	0.086***	0.113***	0.135***	0.153***	0.202***				  */
/*	(0.005)		(0.005)		(0.005)		(0.006)		(0.006)					  */
/* Compustat Results:														  */
/* 	0.022***	0.039***	0.068***	0.153***	0.259***			      */
/*	(0.002)		(0.003)		(0.005)		(0.007)		(0.011)					  */
/******************************************************************************/

**** Preliminaries ****
clear all
set more off

**** Results Directory ****
cd "$directory\Results\Models\Figures"

**** Observations ****
set obs 5

**** Coefficients ****
gen quintile = _n
label var quintile "Quintile" 

gen simulated = 0.086 if quintile == 1
replace simulated = 0.113 if quintile == 2
replace simulated = 0.135 if quintile == 3
replace simulated = 0.153 if quintile == 4
replace simulated = 0.202 if quintile == 5

gen compustat = 0.022 if quintile == 1
replace compustat = 0.039 if quintile == 2
replace compustat = 0.068 if quintile == 3
replace compustat = 0.153 if quintile == 4
replace compustat = 0.259 if quintile == 5

**** Standard Errors ****
gen se_simulated = 0.005
replace se_simulated = 0.006 if quintile == 4 | quintile == 5

gen se_compustat = 0.002 if quintile == 1
replace se_compustat = 0.003 if quintile == 2
replace se_compustat = 0.005 if quintile == 3
replace se_compustat = 0.007 if quintile == 4
replace se_compustat = 0.011 if quintile == 5

**** Upper/Lower ****
gen l_simulated = simulated - 1.96*se_simulated
gen l_compustat = compustat - 1.96*se_compustat
gen u_simulated = simulated + 1.96*se_simulated
gen u_compustat = compustat + 1.96*se_compustat

**** Graph ****
graph twoway ///
	(rcap l_simulated u_simulated quintile, color(gs10)) ///
	(rcap l_compustat u_compustat quintile, color(black)) ///
	(connected simulated quintile, lpattern(dash) lwidth(medium) msize(vlarge) msymbol(d) color(gs10)) ///
	(connected compustat quintile, lwidth(medium) msize(vlarge) msymbol(s) color(black)) ///
	, legend(label(1 "95% CI") label(3 "Simulated data") label(4 "Compustat")  rows(3) order(1 3 4) ring(0) position(11) bmargin(medium) symxsize(5)) ///
	xtitle("Quintile (Standard deviation of Earnings (t)/Price (t-1))") xlabel(, format(%9.0f)) ylabel(, format(%9.2f) angle(0)) ///
	title("Earnings-Return Concavity and Volatility", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	name(Volatility, replace) saving(Volatility, replace)
	
/******************************************************************************/
/* Illustration of Cross-Sectional Investment Results	(Lyandres et al. 2008)*/
/******************************************************************************/
/* Simulated Results:														  */
/*	0.175***	0.030***	0.021***	0.020***	0.000					  */
/*	(0.027)		(0.006)		(0.004)		(0.004)		(0.008)					  */
/* Compustat Results:														  */
/* 	0.172***	0.088***	0.084***	0.071***	0.060***			      */
/*	(0.010)		(0.008)		(0.007)		(0.006)		(0.005)					  */
/******************************************************************************/

**** Preliminaries ****
clear

**** Observations ****
set obs 5

**** Coefficients ****
gen quintile = _n
label var quintile "Quintile" 

gen simulated = 0.175 if quintile == 1
replace simulated = 0.030 if quintile == 2
replace simulated = 0.021 if quintile == 3
replace simulated = 0.020 if quintile == 4
replace simulated = 0.000 if quintile == 5

gen compustat = 0.172 if quintile == 1
replace compustat = 0.088 if quintile == 2
replace compustat = 0.084 if quintile == 3
replace compustat = 0.071 if quintile == 4
replace compustat = 0.060 if quintile == 5

**** Standard Errors ****
gen se_simulated = 0.027 if quintile == 1
replace se_simulated = 0.006 if quintile == 2
replace se_simulated = 0.004 if quintile == 3
replace se_simulated = 0.004 if quintile == 4
replace se_simulated = 0.008 if quintile == 5

gen se_compustat = 0.010 if quintile == 1
replace se_compustat = 0.008 if quintile == 2
replace se_compustat = 0.007 if quintile == 3
replace se_compustat = 0.006 if quintile == 4
replace se_compustat = 0.005 if quintile == 5

**** Upper/Lower ****
gen l_simulated = simulated - 1.96*se_simulated
gen l_compustat = compustat - 1.96*se_compustat
gen u_simulated = simulated + 1.96*se_simulated
gen u_compustat = compustat + 1.96*se_compustat

**** Graph ****
graph twoway ///
	(rcap l_simulated u_simulated quintile, color(gs10)) ///
	(rcap l_compustat u_compustat quintile, color(black)) ///
	(connected simulated quintile, lpattern(dash) lwidth(medium) msize(vlarge) msymbol(d) color(gs10)) ///
	(connected compustat quintile, lwidth(medium) msize(vlarge) msymbol(s) color(black)) ///
	, legend(label(1 "95% CI") label(3 "Simulated data") label(4 "Compustat")  rows(3) order(1 3 4) ring(0) position(11) bmargin(medium) symxsize(5)) ///
	xtitle("Quintile (Investment (t))") xlabel(, format(%9.0f)) ylabel(, format(%9.2f) angle(0)) ///
	title("Earnings-Return Concavity and Investment", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	name(Investment, replace)
	
/* Figure 11: Earnings-Return Asymmetry, Volatility, and Investment */
graph combine Volatility Investment, ///
	altshrink cols(2) ysize(5) xsize(10) ///
	title("Earnings-Return Concavity, Volatility, and Investment", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	name(Figure_11, replace) saving(Figure_11, replace)		
/******************************************************************************/
/* Title:	Investment Dynamics and Earnings-Return Properties		 		  */
/* Authors: M. Breuer, D. Windisch       	                 	          	  */
/* Date:    11/19/2018                                                  	  */
/******************************************************************************/
/* Program description:														  */
/* Master do-file (setting directory & executing do-files)					  */
/******************************************************************************/

/* Directory (set to directory of folder) */
global directory `"..."'

/* Execute STATA do-files */

	/* 01 - Models (patterns in simulated data from base, accrual, and alternative models) */	
	cd "$directory\Code"	
	do 01-Models.do
	
	/* 02 - Compustat (patterns in Compustat data) */
	cd "$directory\Code"	
	do 02-Compustat.do

	/* 03 - Comparison graph (Figure 11) */
	cd "$directory\Code"	
	do 03-Comparison_Graph.do

/******************************************************************************/
/* Title:	Evaluation of Simulated Data from Dynamic Investment Model 		  */
/* Authors: M. Breuer, D. W. Windisch                        	          	  */
/* Date:    09/12/2017                                                  	  */
/******************************************************************************/
/* Program description:														  */
/* Generating Figures and Tables using simulated data						  */
/******************************************************************************/

/* Preliminaries */
version 13.1
clear all
set more off

/******************************************************************************/
/* Basic Model: Simulation data (based on calibrated parameter values)		  */
/******************************************************************************/

/* Directory */
cd "$directory\Code\Models\01-Basic model\Simulation\Data"

/* Data */
insheet using Simulations.csv, nonames clear

/* Time-series definition */

	/* Time dimension */
	gen t = _n
	label var t "Period"

	/* Set time series */
	tsset t
		
/* Model parameters */

	/* Discount rate (expected return) */
	local r = 0.1
	
	/* Persistence */
	local rho = 0.7
	
	/* Mean profitability */
	local mean = 1.5
	
/* Variables */

	/* Destring */
	qui destring v8, replace force
	
	/* Renaming model outputs */
	rename v1 earnings
	label var earnings "Earnings"

	rename v2 cash
	label var cash "Cash from Operations"

	rename v3 price
	label var price "Price"

	rename v4 profitability
	label var profitability "Profitability"

	rename v5 investment
	label var investment "Investment"

	rename v6 capital
	label var capital "Capital" // Note: Capital is beginning of period capital

	rename v7 adj_cost
	label var adj_cost "Adjustment cost"

	rename v8 surprise
	label var surprise "Surprise"
	
	/* Variable transformations */
	gen z = profitability - ((1-`rho')*`mean' + `rho'*l.profitability)
	label var z "Profitability shock"
	
	gen price_ex_div = price - cash + investment
	label var price_ex_div "Price (ex dividend)"

	gen ear = earnings/l.price_ex_div
	label var ear "Earnings(t)/Price(t-1)"

	gen l_ear = l.earnings/l.price_ex_div
	label var l_ear "Earnings(t-1)/Price(t-1)"
	
	gen cfo = cash/l.price_ex_div
	label var cfo "CFO(t)/Price(t-1)"

	gen ret = price/l.price_ex_div - (1 + `r')
	label var ret "Return"
	
	gen dear = d.earnings/l.price_ex_div
	label var dear "Change in Earnings/Price(t-1)"
	
	gen dear_c = d.earnings/capital
	label var dear "Change in Earnings/Capital(t-1)"
		
	gen fcapital = f.capital
	label var fcapital "Capital (t)"

	gen inv = investment/l.price_ex_div
	label var inv "Investment(t)/Price(t-1)"
	
	gen inv_price = 1/l.price_ex_div
	label var inv_price "1/Price(t-1)"

	gen mtb = price/capital
	label var mtb "Market-to-Book"	
	
	gen loss = (earnings < 0)
	label var loss "Loss"	
	
	gen d = (ret<0)
	label var d "Negative Return Indicator"
	
	gen d_earnings = (l.earnings < 0)
	label var d_earnings "Negative Earnings Indicator"
	
	gen d_dearnings = (l.d.earnings < 0)
	label var d_dearnings "Negative Earnings Change Indicator"
	
	gen d_dear = (l.dear < 0)
	label var d_dear "Negative Earnings Change/Price Indicator"
	
	gen d_dear_c = (l.dear_c < 0)
	label var d_dear_c "Negative Earnings Change/Capital Indicator"
		
	gen sue = surprise/l.price_ex_div
	label var sue "Earnings Surprise"
	
	gen abs_sue = abs(sue)
	label var sue "Absolute Earnings Surprise"
	
	/* AR(1) earnings surprise */
	qui reg earnings l.earnings
	qui predict sue_res, res
	label var sue_res "Earnings Surprise"

	gen sue_e = sue_res/l.price_ex_div
	label var sue_e "Earnings Surprise"	

/* Outlier treatment */

	/* Drop burn-in period */
	drop if t<=1000 | t>101000
	
	/* Drop extreme values (ensure positive value function) */
	drop if price < 0
	drop if abs(ret) > 1
	
/* Panel definition */
	
	/* Firm dimension */
	gen firm = ceil(t/25)
	label var firm "Firm"
	
	/* Set panel structure */
	xtset firm t
	
/* Endogenous split variables (by firm) */	

	/* Mean */
	egen mean_mtb = mean(mtb), by(firm)

	/* Standard deviation */
	egen sd_ear = sd(ear), by(firm)
	
/* Quintiles */
	
	/* Earnings volatility */
	xtile q_sd_ear = sd_ear, nq(5)
	
	/* Investment */
	xtile q_inv = investment, nq(5)

/* Persistence, earnings-response coefficient, and earnings-return asymmetry (by firm) */
 
	/* Placeholders */
	gen rho = .
	gen erc = .
	gen basu = .
	
	/* Loop */
	qui sum firm, d
	qui forvalues q = `r(min)'(1)`r(max)' {
		capture {
			/* Earnings persistence */
			reg earnings l.earnings if firm == `q'
			replace rho = _b[L.earnings] if firm == `q'
			
			/* Earnings response coefficient */
			reg ret sue if firm == `q'
			replace erc = _b[sue] if firm == `q'
			
			/* Earnings-return coefficient */
			reg ear c.ret##i.d if firm == `q'
			replace basu = _b[1.d#c.ret] if firm == `q'
			
		}
	}	
	
/* Leads and lags for future earnings-response coefficient regression */

	/* Earnings growth */
	gen x_0 = ln(earnings/l.earnings)
	gen x_1 = f1.x_0
	gen x_2 = f2.x_0
	gen x_3 = f3.x_0
	gen x_1_3 = exp(ln(1+x_1) + ln(1+x_2) + ln(1+x_3))-1 
	
	/* Returns */
	gen ret_1 = f1.ret
	gen ret_2 = f2.ret
	gen ret_3 = f3.ret
	gen ret_1_3 = exp(ln(1+ret_1) + ln(1+ret_2) + ln(1+ret_3))-1 

	/* Other */
	gen ep = l.earnings/l.price
	gen ag = ln(capital/l.capital)	
	
/* Save */
cd "$directory\Data\Output"
save Simulation, replace

/******************************************************************************/
/* Basic Model: Simulation data (based on varying parameter values)	  		  */
/******************************************************************************/

/* Directory */
cd "$directory\Code\Models\01-Basic model\Simulation\Data"

/* Data */
insheet using Predictions.csv,  clear

/* Variable names */

	/* Identifiers */
	rename v1 i
	label var i "Parameter"

	rename v2 j
	label var j "Step"

	/* Parameters */
	rename v3 p1
	rename v4 p2
	rename v5 p3
	rename v6 p4


	/* Destring */
	qui destring v*, replace force

	/* Coefficients */
	rename v7 ear_0
	label var ear_0 "Positive slope (Earnings)"

	rename v8 ear_1
	label var ear_1 "Incremental negative slope (Earnings)"

	rename v9 erc
	label var erc "Earnings-Response Coefficient"

	gen ear_2 = ear_0 + ear_1
	label var ear_2 "Negative slope (Earnings)"

	gen ear = ear_2 / (ear_0 + ear_2)
	label var ear "Share of negative slope (Earnings)"

/* Reshape */
egen ij=group(i j)
reshape long p, i(ij) j(parameter)

/* Paramter Values */
rename p values
label var values "Parameter Values"

label var parameter "Parameter"
label define parameter 1 "std_epsilon" 2 "psi" 3 "rho" 4 "r"
label values parameter parameter

/* Save */
cd "$directory\Data\Output"
save ComparativeStatics, replace

/******************************************************************************/
/* Alternative Models: Simulation data (based on calibrated parameter values) */
/******************************************************************************/

/* Model directories */
local directory_1 = "$directory\Code\Models\03-Model 1 (no delay, no adjustment cost)\Simulation\Data"
local directory_2 = "$directory\Code\Models\04-Model 2 (no adjustment cost)\Simulation\Data"
local directory_3 = "$directory\Code\Models\05-Model 3 (no delay)\Simulation\Data"

/* Loop over models */
forvalues i = 1(1)3 {

	/* Directory */
	cd "`directory_`i''"

	/* Data */
	if `i' == 1 {
		insheet using Simulations_nodelay_nocost.csv, nonames clear
	}
	
	if `i' == 2 {
		insheet using Simulations_nocost.csv, nonames clear
	}
	
	if `i' == 3 {
		insheet using Simulations_nodelay.csv, nonames clear
	}	
	
	/* Time-series definition */

		/* Time dimension */
		gen t = _n
		label var t "Period"

		/* Set time series */
		tsset t
		
	/* Variables */

		/* Destring */
		qui destring v8, replace force
		
		/* Renaming model outputs */
		rename v1 earnings
		label var earnings "Earnings"

		rename v2 cash
		label var cash "Cash from Operations"

		rename v3 price
		label var price "Price"

		rename v4 profitability
		label var profitability "Profitability"

		rename v5 investment
		label var investment "Investment"

		rename v6 capital
		label var capital "Capital" // Note: Capital is beginning of period capital

		rename v7 adj_cost
		label var adj_cost "Adjustment cost"

		rename v8 surprise
		label var surprise "Surprise"
		
		/* Variable transformations */
		gen z = profitability - ((1-`rho')*`mean' + `rho'*l.profitability)
		label var z "Profitability shock"
		
		gen price_ex_div = price - cash + investment
		label var price_ex_div "Price (ex dividend)"

		gen ear = earnings/l.price_ex_div
		label var ear "Earnings(t)/Price(t-1)"

		gen cfo = cash/l.price_ex_div
		label var cfo "CFO(t)/Price(t-1)"

		gen ret = price/l.price_ex_div - (1 + `r')
		label var ret "Return"
		
		gen dear = d.earnings/l.price_ex_div
		label var dear "Change in Earnings/Price(t-1)"
		
		gen dear_c = d.earnings/capital
		label var dear "Change in Earnings/Capital(t-1)"
			
		gen fcapital = f.capital
		label var fcapital "Capital (t)"

		gen inv_price = 1/l.price_ex_div
		label var inv_price "1/Price(t-1)"

		gen mtb = price/capital
		label var mtb "Market-to-Book"	
		
		gen loss = (earnings < 0)
		label var loss "Loss"	
		
		gen d = (ret<0)
		label var d "Negative Return Indicator"
		
		gen d_earnings = (l.earnings < 0)
		label var d_earnings "Negative Earnings Indicator"
		
		gen d_dearnings = (l.d.earnings < 0)
		label var d_dearnings "Negative Earnings Change Indicator"
		
		gen d_dear = (l.dear < 0)
		label var d_dear "Negative Earnings Change/Price Indicator"
		
		gen d_dear_c = (l.dear_c < 0)
		label var d_dear_c "Negative Earnings Change/Capital Indicator"
			
		gen sue = surprise/l.price_ex_div
		label var sue "Earnings Surprise"
		
		gen abs_sue = abs(sue)
		label var sue "Absolute Earnings Surprise"
		
		/* AR(1) earnings surprise */
		qui reg earnings l.earnings
		qui predict sue_res, res
		label var sue_res "Earnings Surprise"

		gen sue_e = sue_res/l.price_ex_div
		label var sue_e "Earnings Surprise"	

	/* Outlier treatment */

		/* Drop burn-in period */
		drop if t<=1000 | t>101000
		
		/* Drop extreme values (ensure positive value function) */
		drop if price < 0
		drop if abs(ret) > 1
		
	/* Panel definition */
		
		/* Firm dimension */
		gen firm = ceil(t/25)
		label var firm "Firm"
		
		/* Set panel structure */
		xtset firm t
		
	/* Endogenous split variables (by firm)*/	

		/* Mean */
		egen mean_mtb = mean(mtb), by(firm)

		/* Standard deviation */
		egen sd_ear = sd(ear), by(firm)

	/* Quintiles */
		
		/* Earnings volatility */
		xtile q_sd_ear = sd_ear, nq(5)
		
		/* Investment */
		xtile q_inv = investment, nq(5)
	
	/* Persistence, earnings-response coefficient, and earnings-return asymmetry (by firm) */
	 
		/* Placeholders */
		gen rho = .
		gen erc = .
		gen basu = .
		
		/* Loop */
		qui sum firm, d
		qui forvalues q = `r(min)'(1)`r(max)' {
			capture {
				/* Earnings persistence */
				reg earnings l.earnings if firm == `q'
				replace rho = _b[L.earnings] if firm == `q'
				
				/* Earnings response coefficient */
				reg ret sue if firm == `q'
				replace erc = _b[sue] if firm == `q'
				
				/* Earnings-return coefficient */
				reg ear c.ret##i.d if firm == `q'
				replace basu = _b[1.d#c.ret] if firm == `q'
				
			}
		}	
		
	/* Leads and lags for future earnings-response coefficient regression */

		/* Earnings growth */
		gen x_0 = ln(earnings/l.earnings)
		gen x_1 = f1.x_0
		gen x_2 = f2.x_0
		gen x_3 = f3.x_0
		gen x_1_3 = exp(ln(1+x_1) + ln(1+x_2) + ln(1+x_3))-1 
		
		/* Returns */
		gen ret_1 = f1.ret
		gen ret_2 = f2.ret
		gen ret_3 = f3.ret
		gen ret_1_3 = exp(ln(1+ret_1) + ln(1+ret_2) + ln(1+ret_3))-1 

		/* Other */
		gen ep = l.earnings/l.price
		gen ag = ln(capital/l.capital)	
			
	/* Save */
	cd "$directory\Data\Output"
	save Simulation_Model_`i', replace

/* End: loop over models */
}

/******************************************************************************/
/* Manuscript: Figures and Tables											  */
/******************************************************************************/

/* Log */
cd "$directory\Results\Models\Logs"
log using Manuscript, replace smcl name(Manuscript)
	
/* 3. Economic model */	
	
	/* d. Policy function */	
	
		/* Figure 1: Capital and profitability */
			
			/* Data: Simulation */
			cd "$directory\Data\Output"
			use Simulation, clear
			
			/* Results Directory */
			cd "$directory\Results\Models\Figures"			
		
			/* Figure */
			graph twoway ///
				(lpolyci capital profitability, clcolor(black)) ///
				(lpolyci fcapital profitability, clcolor(black) clpattern(dash)) ///
				, legend(label(2 "Capital (t)") label(4 "Capital (t+1)") rows(3) order(1 2 4) ring(0) position(11) bmargin(medium) symxsize(5)) /// 
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xtitle("Profitability (t)") ///
				xline(1.5, lcolor(gs10) lpattern(dash)) ///
				ylabel(, format(%9.0f) angle(0)) /// 				
				title("Capital and Profitability", color(black)) ///
				name(Figure_1, replace) saving(Figure_1, replace)
	
		/* Figure 2: Impulse response of investment and capital with respect to profitability shocks */

			/* IRF investment */
			qui var investment profitability, lags(1/10)
			qui irf create irf, set(irf, replace)
			irf graph irf ///
				, impulse(profitability) response(investment) ///
				legend(label(1 "CI 95%") label(2 "Impulse Response Function") rows(1) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Impulse Response: Profitability and Investment", color(black)) ///
				name(IRF_Investment, replace)
	
			/* IRF capital */
			qui var capital profitability, lags(1/10)
			qui irf create irf, set(irf, replace)
			irf graph irf ///
				, impulse(profitability) response(capital) ///
				legend(label(1 "CI 95%") label(2 "Impulse Response Function") rows(1) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Impulse Response: Profitability and Capital", color(black)) ///
				name(IRF_Capital, replace)
	
			/* Combined figure */
			graph combine IRF_Investment IRF_Capital, ///
				altshrink cols(3)  ysize(4) xsize(10) ///
				title("Investment and Capital Dynamics", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_2, replace)	saving(Figure_2, replace)	
		
/* 4. Model predictions */

	/* a. Distributions */
	
		/* Figure 3: Histograms of profitability, investment, earnings, and returns */
		
			/* Profitability */
			hist profitability ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Profitability Levels", color(black)) ///
				ylabel(, format(%9.1f) angle(0)) /// 								
				name(Profitability, replace)

			/* Investment */				
			hist investment ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Investment Levels", color(black)) ///
				ylabel(, format(%9.2f) angle(0)) /// 												
				name(Investment, replace)
	
			/* Earnings */
			hist earnings ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Earnings Levels", color(black)) ///
				ylabel(, format(%9.3f) angle(0)) /// 								
				name(Earnings, replace)
	
			/* Returns */
			hist ret ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Returns", color(black)) ///
				ylabel(, format(%9.0f) angle(0)) /// 								
				name(Returns, replace)

			/* Combined figure */
			graph combine Profitability Investment Earnings Returns, ///
				altshrink cols(4) ysize(4) xsize(15) ///
				title("Profitability, Investment, Earnings, and Returns", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_3, replace) saving(Figure_3, replace)
	
		/* Figure 4: Histograms of price and earnings scaled by lagged price */
	
			/* Price */
			hist price ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Price Levels", color(black)) ///
				ylabel(, format(%9.3f) angle(0)) /// 
				name(Price, replace)
			
			/* Earnings scaled by lagged price */
			hist ear ///
				, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Histogram of Scaled Earnings", color(black)) ///
				ylabel(, format(%9.0f) angle(0)) /// 								
				name(Earnings_Scaled, replace)
				
			/* Combined figure */
			graph combine Price Earnings_Scaled, ///
				altshrink cols(2) ysize(4) xsize(10) ///
				title("Price and Scaled Earnings", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_4, replace)	saving(Figure_4, replace) 	
				
	/* b. Persistence of earnings levels and changes */
	
		/* Table 3: Differential persistence */
		
			/* Column 1: Earnings persistence */
			qui xtreg earnings c.l.earnings##1.d_earnings, fe cluster(firm)
				est store M1
				
			/* Column 2: Earnings change persistence */
			qui xtreg d.earnings c.l.d.earnings##1.d_dearnings, fe cluster(firm)
				est store M2
		
			/* Column 3: Earnings change (scaled by price) persistence (Basu (1997)) */
			qui xtreg dear c.l.dear##1.d_dear, fe cluster(firm)
				est store M3		
		
			/* Column 4: Earnings change (scaled by capital) persistence (Ball/Shivakumar (2005)) */
			qui xtreg dear_c c.l.dear_c##1.d_dear_c, fe cluster(firm)
				est store M4			

			/* Combined table */
			estout M1 M2 M3 M4, keep(L.earnings 1.d_earnings 1.d_earnings#cL.earnings LD.earnings 1.d_dearnings 1.d_dearnings#cLD.earnings ///
				L.dear 1.d_dear 1.d_dear#cL.dear L.dear_c 1.d_dear_c 1.d_dear_c#cL.dear_c) ///
				cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(L.earnings "E (t-1)" 1.d_earnings "D(E (t-1) < 0)" 1.d_earnings#cL.earnings "E*D(E < 0)" ///
				LD.earnings "d.E (t-1)" 1.d_dearnings "D(d.E < 0)" 1.d_dearnings#cLD.earnings "d.E*D(d.E < 0)" ///
				L.dear "d.E/P (t-1)" 1.d_dear "D(d.E/P < 0)" 1.d_dear#cL.dear "d.E/P*D(d.E/P < 0)" ///
				L.dear_c "d.E/K (t-1)" 1.d_dear_c "D(d.E/K < 0)" 1.d_dear_c#cL.dear_c "d.E/K*D(d.E/K < 0)") ///
				mlabels("[1] Earnings" "[2] d.Earnings" "[3] d.Earnings/Price" "[4] d.Earnings/Capital")  modelwidth(20) unstack ///
				title("Table 3: Asymmetric Earnings Persistence") ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
		
	/* c. Earnings-response coefficient */
	
		/* Figure 5: Earnings-response  */
		
			/* Data: ComparativeStatics */
			cd "$directory\Data\Output"
			use ComparativeStatics, clear
			
			/* Discount rate */
			graph twoway ///
				(lpolyci erc values if parameter==4 & i==4, clcolor(black)), ///
						legend(off) ///
						ytitle("ERC") ///
						xtitle("Discount rate (r)") xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Discount, replace)	
						
			/* Persistence */
			graph twoway ///
				(lpolyci erc values if parameter==3 & i==3, clcolor(black)), ///
						legend(off) ///
						xtitle("Persistence (rho)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Persistence, replace)
						
			/* Data: Simulation */
			cd "$directory\Data\Output"
			use Simulation, clear
			
			/* Market-to-book */
			preserve
				
				/* Duplicates (by firm) */
				duplicates drop firm, force
				
				/* ERC and market-to-book */
				graph twoway (lpolyci erc mean_mtb, clcolor(black)) ///
					, legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xtitle("Market-to-Book (V/K)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
					name(ERC_MTB, replace)
					
			restore
			
			/* Results Directory */
			cd "$directory\Results\Models\Figures"

			/* Combined figure */
			graph combine ERC_Discount ERC_Persistence ERC_MTB, ///
				altshrink cols(3) ysize(4) xsize(10) ///
				title("Determinants of Earnings-Response Coefficients: Discount Rate, Persistence, and Market-to-Book", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_5, replace) saving(Figure_5, replace)	
		
		/* Table 4: Earnings-response coefficient */
		
			/* ERC */
			qui xtreg ret sue, fe cluster(firm)
				est store M1
				
			/* Cross-sectional determinants */
			qui xtreg ret sue c.sue##c.rho c.sue##c.abs_sue c.sue##c.mtb c.sue##1.loss, fe cluster(firm)
				est store M2
				
			/* Output table */
			estout M1 M2, keep(sue c.sue#c.rho abs_sue c.sue#c.abs_sue mtb c.sue#c.mtb 1.loss 1.loss#c.sue) ///
				cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(c.sue "UE" c.sue#c.rho "UE*Persistence" abs_sue "|UE|" c.sue#c.abs_sue "UE*|UE|" mtb "Market-to-Book" c.sue#c.mtb "UE*MTB" 1.loss "Loss" 1.loss#c.sue "UE*Loss") ///
				title("Table 4: Determinants of Earnings-Response Coefficient") ///								
				mlabels("[1] Return" "[2] Return")  modelwidth(20) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))							
		
		/* Figure 6: Shape of earnings-response coefficient */
		graph twoway ///
			(fpfitci ret sue , clcolor(black)) ///
			(fpfitci ret sue_e , clcolor(black) clpattern(dash)) ///
			, legend(label(2 "ERC (correct expectation)") label(4 "ERC (AR(1) expectation)") order(1 2 4) rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xtitle("Earnings Surprise (t)") ytitle("Return (t)") xlabel(, format(%9.1f)) ylabel(, format(%9.1f) angle(0)) ///
			title("Earnings-Response Coefficient", color(black)) ///
			name(Figure_6, replace) saving(Figure_6, replace)
			
		/* Table 5: Future earnings-response coefficient (Collins et al. (1994)) */
		
			/* Original firm-level specifications */
			qui xtreg ret x_0, fe cluster(firm)
				est store M1
				
			qui xtreg ret x_0 x_1 x_2 x_3, fe cluster(firm)
				est store M2
				
			qui xtreg ret x_0 x_1 x_2 x_3 ret_1 ret_2 ret_3 ep ag, fe cluster(firm)
				est store M3
	
			/* Current firm-level specification */
			qui xtreg ret x_0, fe cluster(firm)
				est store M4
				
			qui xtreg ret x_0 x_1_3, fe cluster(firm)
				est store M5			
			
			qui xtreg ret x_0 x_1_3 ret_1_3 ep ag, fe cluster(firm)
				est store M6
				
			/* Output table */
			estout M1 M2 M3, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(x_0 "X (t)" x_1 "X (t+1)" x_2 "X (t+2)" x_3 "X (t+3)" ret_1 "R (t+1)" ret_2 "R (t+2)" ret_3 "R (t+3)" ep "EP (t-1)" ag "AG (t)") ///
				title("Table 5: Future Earnings-Response Coefficient (Original Specification)") ///				
				mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Original Model")  modelwidth(20) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))

			estout M4 M5 M6, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(x_0 "X (t)" x_1_3 "X (t+1 to t+3)" ret_1_3 "R (t+1 to t+3)" ep "EP (t-1)" ag "AG (t)") ///
				title("Table 5: Future Earnings-Response Coefficient (Current Specification)") ///								
				mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Current Model")  modelwidth(20) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
				
	/* d. Earnings-return asymmetry */
	
		/* Figure 7: Earnings-return concavity */
		
			/* Earnings levels */
			graph twoway ///
				(fpfitci earn ret, clcolor(black)) ///
				, legend(label(2 "Earnings") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Basu_level, replace)
			
			/* Earnings scaled by lagged price */
			graph twoway ///
				(fpfitci ear ret, clcolor(black)) ///
				, legend(label(2 "Earnings/Price") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.1f) angle(0)) ///
				name(Basu, replace)
				
			/* Combined figure */	
			graph combine Basu_level Basu, ///
				altshrink cols(2) ysize(4) xsize(10) ///
				title("Earnings-Return Concavity", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_7, replace) saving(Figure_7, replace)
				
		/* Untabulated: Placebo test */
			
			/* Lagged earnings */
			qui xtreg l_ear c.ret##i.d, fe cluster(firm)
			
			/* Output */
			estout, keep(ret 1.d 1.d#c.ret) ///
				cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(ret "Return" 1.d "D(Return<0)" 1.d#c.ret "Return*D(Return<0)") ///
				title("Untabulated: Placebo Test with Lagged Earnings/Price") ///								
				modelwidth(40) mlabels("Earnings(t-1)/Price(t-1)") ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))				
					
		/* Figure 8: Channels */
		
			/* Earnings-news */
			graph twoway ///
				(fpfitci earnings z, clcolor(black)) ///
				(lfit earnings z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Earnings") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.0f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Earnings_news, replace)			
			
			/* Adjustment costs-news (note: small in terms of magnitude) */
			graph twoway ///
				(fpfitci adj_cost z, clcolor(black)) ///
				, legend(label(2 "Adjustment costs") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.0f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Adj_cost_news, replace)	
			
			/* Return-news */
			graph twoway ///
				(fpfitci ret z, clcolor(black)) ///
				(lfit ret z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Returns") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.0f)) ylabel(, format(%9.1f) angle(0)) ///
				name(Return_news, replace)
				
			/* Combined figure */	
			graph combine Earnings_news Adj_cost_news Return_news, ///
				altshrink cols(3) ysize(4) xsize(10) ///
				title("Relation of Earnings, Adjustment Costs, and Returns to Profitability Shocks (News)", color(black)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_8, replace)	saving(Figure_8, replace)	 			
				
		/* Figure 9: Other asymmetries */
			
			/* Profitability-returns */
			graph twoway ///
				(fpfitci profitability ret, clcolor(black)) ///
				(lfit profitability ret, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
				name(Profitability_returns, replace)			

			/* Profitability-news */			
			graph twoway ///
				(fpfitci profitability z, clcolor(black)) ///
				(lfit profitability z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///			
				name(Profitability_news, replace)
				
			/* Investment-returns */
			graph twoway ///
				(fpfitci investment ret, clcolor(black)) ///
				(lfit investment ret, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///			
				name(Investment_returns, replace)			
			
			/* Investment-returns */
			graph twoway ///
				(fpfitci investment z, clcolor(black)) ///
				(lfit investment z, clcolor(black) clpattern(dash)) ///				
				, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///				
				name(Investment_news, replace)	
				
			/* Combined figure */	
			graph combine Profitability_returns Investment_returns Profitability_news Investment_news, ///
				altshrink cols(2) ysize(4) xsize(5) ///
				title("Relation of Profitability and Investment to Returns and Profitability Shocks (News)", color(black) size(medium)) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_9, replace) saving(Figure_9, replace)	
			
	/* Results */	

		/* Table 6, Panel A: Earnings-return asymmetry and volatility */
		
			/* Loop across volatility quantiles */
			qui sum q_sd_ear, d
			qui forvalues q = `r(min)'/`r(max)' {

				/* Earnings-return asymmetry */
				reg ear c.ret##i.d if q_sd_ear == `q', cluster(firm)
				est store M`q'
					
			}

			/* Output table */
			estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") ///
				title("Table 6, Panel A: Earnings-Return Asymmetry and Volatility") ///												
				mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))
		
		/* Table 6, Panel B: Earnings-return asymmetry and investment */
		
			/* Loop across volatility quantiles */
			qui sum q_inv, d
			qui forvalues q = `r(min)'/`r(max)' {

				/* Earnings-return asymmetry */
				reg ear c.ret##i.d if q_inv == `q', cluster(firm)
				est store M`q'
					
			}

			/* Output table */
			estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
				legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") ///
				title("Table 6, Panel B: Earnings-Return Asymmetry and Investment") ///																
				mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
				stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
	
	/* Figure 10: Comparative Statics */
	
		/* Data: ComparativeStatics */
		cd "$directory\Data\Output"
		use ComparativeStatics, clear
			
		/* Basu */

			/* Volatility */
			graph twoway ///
				(lpolyci ear_1 values if parameter==1 & i==1, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Volatility (standard deviation of epsilon)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						title("Earnings-Return Concavity", color(black) size(vhuge)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_Volatility, replace)
						
			/* Adjustment Cost */			
			graph twoway ///
				(lpolyci ear_1 values if parameter==2 & i==2, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Adjustment Costs (psi)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_AdjCost, replace)				

			/* Persistence */
			graph twoway ///
				(lpolyci ear_1 values if parameter==3 & i==3, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Persistence (rho)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_Persistence, replace)
			
			/* Discount rate */			
			graph twoway ///
				(lpolyci ear_1 values if parameter==4 & i==4, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Discount rate (r)") xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_Discount, replace)

		/* ERC */

			/* Volatility */
			graph twoway ///
				(lpolyci erc values if parameter==1 & i==1, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Volatility (standard deviation of epsilon)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						title("Earnings-Response Coefficient", color(black) size(vhuge)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Volatility, replace)
						
			/* Adjustment Cost */			
			graph twoway ///
				(lpolyci erc values if parameter==2 & i==2, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Adjustment Costs (psi)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_AdjCost, replace)				

			/* Persistence */
			graph twoway ///
				(lpolyci erc values if parameter==3 & i==3, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Persistence (rho)") xlabel(, format(%9.1f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Persistence, replace)
			
			/* Discount rate */			
			graph twoway ///
				(lpolyci erc values if parameter==4 & i==4, clcolor(black)), ///
						legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						xtitle("Discount rate (r)") xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(ERC_Discount, replace)
			
			/* Results directory */
			cd "$directory\Results\Models\Figures"

			/* Combination */
			graph combine Basu_Volatility ERC_Volatility Basu_AdjCost ERC_AdjCost Basu_Persistence ERC_Persistence Basu_Discount ERC_Discount, ///
				rows(4) cols(2) altshrink ysize(10) xsize(10) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				title("Comparative Statics", color(black) size(small)) ///
				name(Figure_10, replace) saving(Figure_10, replace)		
	
/* Log close */
log close Manuscript
	
/******************************************************************************/
/* Online Appendix: Figures and Tables										  */
/******************************************************************************/

/* Log */
cd "$directory\Results\Models\Logs"
log using Appendix, replace smcl name(Appendix)

/* Model comparison */

	/* Loop over models */
	forvalues i = 1(1)3 {

		/* Data */
		cd "$directory\Data\Output"
		use Simulation_Model_`i', clear	
		
		/* Results Directory */
		cd "$directory\Results\Models\Figures\Alternative Models"
		
		/* Model predictions */
		
			/* a. Distributions */
			
				/* Figure 3: Histograms of profitability, investment, earnings, and returns */
				
					/* Profitability */
					hist profitability ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Profitability Levels", color(black)) ///
						name(Profitability, replace)

					/* Investment */				
					hist investment ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Investment Levels", color(black)) ///
						name(Investment, replace)
			
					/* Earnings */
					hist earnings ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Earnings Levels", color(black)) ///
						name(Earnings, replace)
			
					/* Returns */
					hist ret ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Returns", color(black)) ///
						name(Returns, replace)

					/* Combined figure */
					graph combine Profitability Investment Earnings Returns, ///
						altshrink cols(4) ysize(4) xsize(15) ///
						title("Profitability, Investment, Earnings, and Returns", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_3_M`i', replace) saving(Figure_3_M`i', replace)
			
				/* Figure 4: Histograms of price and earnings scaled by lagged price */
			
					/* Price */
					hist price ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Price Levels", color(black)) ///
						name(Price, replace)
					
					/* Earnings scaled by lagged price */
					hist ear ///
						, color(gs10) graphregion(color(white)) plotregion(fcolor(white)) ///
						title("Histogram of Scaled Earnings", color(black)) ///
						name(Earnings_Scaled, replace)
						
					/* Combined figure */
					graph combine Price Earnings_Scaled, ///
						altshrink cols(2) ysize(4) xsize(10) ///
						title("Price and Scaled Earnings", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_4_M`i', replace) saving(Figure_4_M`i', replace)		
						
			/* b. Persistence of earnings levels and changes */
			
				/* Table 3: Differential persistence */
				
					/* Column 1: Earnings persistence */
					qui xtreg earnings c.l.earnings##1.d_earnings, fe cluster(firm)
						est store M1
						
					/* Column 2: Earnings change persistence */
					qui xtreg d.earnings c.l.d.earnings##1.d_dearnings, fe cluster(firm)
						est store M2
				
					/* Column 3: Earnings change (scaled by price) persistence (Basu (1997)) */
					qui xtreg dear c.l.dear##1.d_dear, fe cluster(firm)
						est store M3		
				
					/* Column 4: Earnings change (scaled by capital) persistence (Ball/Shivakumar (2005)) */
					qui xtreg dear_c c.l.dear_c##1.d_dear_c, fe cluster(firm)
						est store M4			

					/* Combined table */
					estout M1 M2 M3 M4, keep(L.earnings 1.d_earnings 1.d_earnings#cL.earnings LD.earnings 1.d_dearnings 1.d_dearnings#cLD.earnings ///
						L.dear 1.d_dear 1.d_dear#cL.dear L.dear_c 1.d_dear_c 1.d_dear_c#cL.dear_c) ///
						cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(L.earnings "E (t-1)" 1.d_earnings "D(E (t-1) < 0)" 1.d_earnings#cL.earnings "E*D(E < 0)" ///
						LD.earnings "d.E (t-1)" 1.d_dearnings "D(d.E < 0)" 1.d_dearnings#cLD.earnings "d.E*D(d.E < 0)" ///
						L.dear "d.E/P (t-1)" 1.d_dear "D(d.E/P < 0)" 1.d_dear#cL.dear "d.E/P*D(d.E/P < 0)" ///
						L.dear_c "d.E/K (t-1)" 1.d_dear_c "D(d.E/K < 0)" 1.d_dear_c#cL.dear_c "d.E/K*D(d.E/K < 0)") ///
						mlabels("[1] Earnings" "[2] d.Earnings" "[3] d.Earnings/Price" "[4] d.Earnings/Capital")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
				
			/* c. Earnings-response coefficient */
			
				/* Figure 5: Earnings-response  (w/o comparative static/predictions part) */
					
					/* Market-to-book */
					preserve
						
						/* Duplicates (by firm) */
						duplicates drop firm, force
						
						/* ERC and market-to-book */
						graph twoway (lpolyci erc mean_mtb, clcolor(black)) ///
							, legend(label(1 "95% CI") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
							graphregion(color(white)) plotregion(fcolor(white)) ///
							xtitle("Market-to-Book (V/K)") ///
							name(Figure_5_M`i', replace) saving(Figure_5_M`i', replace)
							
					restore	
				
				/* Table 4: Earnings-response coefficient */
				
					/* ERC */
					qui xtreg ret sue, fe cluster(firm)
						est store M1
						
					/* Cross-sectional determinants */
					qui xtreg ret sue c.sue##c.rho c.sue##c.abs_sue c.sue##c.mtb c.sue##1.loss, fe cluster(firm)
						est store M2
						
					/* Output table */
					estout M1 M2, keep(sue c.sue#c.rho abs_sue c.sue#c.abs_sue mtb c.sue#c.mtb 1.loss 1.loss#c.sue) ///
						cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(sue "UE" c.sue#c.rho "UE*Persistence" abs_sue "|UE|" c.sue#c.abs_sue "UE*|UE|" mtb "Market-to-Book" c.sue#c.mtb "UE*MTB" 1.loss "Loss" 1.loss#c.sue "UE*Loss") ///
						title("Determinants of Earnings-Response Coefficient") ///
						mlabels("[1] Return" "[2] Return")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))									
				
				/* Figure 6: Shape of earnings-response coefficient */
				graph twoway ///
					(fpfitci ret sue, clcolor(black)) ///
					(fpfitci ret sue_e, clcolor(black) clpattern(dash)) ///
					, legend(label(2 "ERC (correct expectation)") label(3 "ERC (AR(1) expectation)") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xtitle("Earnings Surprise (t)") ytitle("Return (t)") ///
					title("Earnings Response Coefficient", color(black)) ///
					name(Figure_6_M`i', replace) saving(Figure_6_M`i', replace)
					
				/* Table 5: Future earnings-response coefficient (Collins et al. (1994)) */
				
					/* Original firm-level specifications */
					qui xtreg ret x_0, fe cluster(firm)
						est store M1
						
					qui xtreg ret x_0 x_1 x_2 x_3, fe cluster(firm)
						est store M2
						
					qui xtreg ret x_0 x_1 x_2 x_3 ret_1 ret_2 ret_3 ep ag, fe cluster(firm)
						est store M3
			
					/* Current firm-level specification */
					qui xtreg ret x_0, fe cluster(firm)
						est store M4
						
					qui xtreg ret x_0 x_1_3, fe cluster(firm)
						est store M5			
					
					qui xtreg ret x_0 x_1_3 ret_1_3 ep ag, fe cluster(firm)
						est store M6
						
					/* Output table */
					estout M1 M2 M3, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(x_0 "X (t)" x_1 "X (t+1)" x_2 "X (t+2)" x_3 "X (t+3)" ret_1 "R (t+1)" ret_2 "R (t+2)" ret_3 "R (t+3)" ep "EP (t-1)" ag "AG (t)") ///
						title("Future Earnings-Response Regressions (following Collins et al. (1994))") ///
						mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Original Model")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))

					estout M4 M5 M6, drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(x_0 "X (t)" x_1_3 "X (t+1 to t+3)" ret_1_3 "R (t+1 to t+3)" ep "EP (t-1)" ag "AG (t)") ///
						title("Future Earnings-Response Regressions (Current Firm-Level Specification)") ///
						mlabels("[1] Simple Model" "[2] Augmented Model" "[3] Current Model")  modelwidth(20) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
						
			/* d. Earnings-return asymmetry */
			
				/* Figure 7: Earnings-return concavity */
				
					/* Earnings levels */
					graph twoway ///
						(fpfitci earn ret, clcolor(black)) ///
						, legend(label(2 "Earnings") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu_level, replace)
					
					/* Earnings scaled by lagged price */
					graph twoway ///
						(fpfitci ear ret, clcolor(black)) ///
						, legend(label(2 "Earnings/Price") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Basu, replace)
						
					/* Combined figure */	
					graph combine Basu_level Basu, ///
						altshrink cols(2) ysize(4) xsize(10) ///
						title("Earnings-Return Concavity", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_7_M`i', replace) saving(Figure_7_M`i', replace)
					
				/* Figure 8: Channels */
				
					/* Earnings-news */
					graph twoway ///
						(fpfitci earnings z, clcolor(black)) ///
						(lfit earnings z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Earnings") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Earnings_news, replace)			
					
					/* Adjustment costs-news (note: small in terms of magnitude) */
					graph twoway ///
						(fpfitci adj_cost z, clcolor(black)) ///
						, legend(label(2 "Adjustment costs") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Adj_cost_news, replace)	
					
					/* Return-news */
					graph twoway ///
						(fpfitci ret z, clcolor(black)) ///
						(lfit ret z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Returns") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Return_news, replace)
						
					/* Combined figure */	
					graph combine Earnings_news Adj_cost_news Return_news, ///
						altshrink cols(3) ysize(4) xsize(10) ///
						title("Relation of Earnings, Adjustment Costs, and Returns" "to Profitability Shocks (News)", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_8_M`i', replace) saving(Figure_8_M`i', replace)				
						
				/* Figure 9: Other asymmetries */
					
					/* Profitability-returns */
					graph twoway ///
						(fpfitci profitability ret, clcolor(black)) ///
						(lfit profitability ret, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
						name(Profitability_returns, replace)			

					/* Profitability-news */			
					graph twoway ///
						(fpfitci profitability z, clcolor(black)) ///
						(lfit profitability z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Profitability level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///
						name(Profitability_news, replace)
						
					/* Investment-returns */
					graph twoway ///
						(fpfitci investment ret, clcolor(black)) ///
						(lfit investment ret, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///						
						name(Investment_returns, replace)			
					
					/* Investment-returns */
					graph twoway ///
						(fpfitci investment z, clcolor(black)) ///
						(lfit investment z, clcolor(black) clpattern(dash)) ///				
						, legend(label(2 "Investment level") label(3 "Linear fit") rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						xlabel(, format(%9.1f)) ylabel(, format(%9.0f) angle(0)) ///						
						name(Investment_news, replace)	
						
					/* Combined figure */	
					graph combine Profitability_returns Investment_returns Profitability_news Investment_news, ///
						altshrink cols(2) ysize(4) xsize(5) ///
						title("Relation of Profitability and Investment" "to Returns and Profitability Shocks (News)", color(black)) ///
						graphregion(color(white)) plotregion(fcolor(white)) ///
						name(Figure_9_M`i', replace) saving(Figure_9_M`i', replace)	
								
			/* Results */

				/* Table 6, Panel A: Earnings-return asymmetry and volatility */
				
					/* Loop across volatility quantiles */
					qui sum q_sd_ear, d
					qui forvalues q = `r(min)'/`r(max)' {

						/* Earnings-return asymmetry */
						reg ear c.ret##i.d if q_sd_ear == `q', cluster(firm)
						est store M`q'
							
					}

					/* Output table */
					estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") title("Earnings/Price Volatility")  ///
						mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))
				
				/* Table 6, Panel B: Earnings-return asymmetry and investment */
				
					/* Loop across volatility quantiles */
					qui sum q_inv, d
					qui forvalues q = `r(min)'/`r(max)' {

						/* Earnings-return asymmetry */
						reg ear c.ret##i.d if q_inv == `q', cluster(firm)
						est store M`q'
							
					}

					/* Output table */
					estout M1 M2 M3 M4 M5, keep(1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
						legend label varlabels(1.d#c.ret "Earnings-Return Asymmetry") title("Investment Levels")  ///
						mlabels("[1] Low" "[2]" "[3]" "[4]" "[5] High")  modelwidth(8) unstack ///
						stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))							
	
	/* End: model loop */
	}
	
/* Data */
cd "$directory\Data\Output"
use Simulation, clear	

/* Further Appendix Tables */

	/* Table A5: Asymmetries */
		
		/* Earnings levels */
		qui xtreg earnings c.ret##i.d, fe cluster(firm)
			est store M1
			
		/* Earnings scaled by lagged price */
		qui xtreg ear c.ret##i.d, fe cluster(firm)
			est store M2
			
		/* Cash flow */
		qui xtreg cash c.ret##i.d, fe cluster(firm)
			est store M3
			
		/* Cash flow scaled by lagged price */
		qui xtreg cfo c.ret##i.d, fe cluster(firm)
			est store M4
						
		/* Investment */
		qui xtreg investment c.ret##i.d, fe cluster(firm)
			est store M5
			
		/* Investment scaled by lagged price */
		qui xtreg inv c.ret##i.d, fe cluster(firm)
			est store M6

		/* Output table */
		estout M1 M2 M3 M4 M5 M6, keep(ret 1.d 1.d#c.ret) cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
			legend label varlabels(ret "Return" 1.d "D(Return<0)" 1.d#c.ret "Return*D") title("Earnings, Cash Flow, And Investment Asymmetry")  ///
			mlabels("Earnings" "Earnings/Price" "Cash Flow" "Cash Flow/Price" "Investment" "Investment/Price")  modelwidth(8) unstack ///
			stats(N N_clust r2_a, fmt(0 0 3) label("Obs." "# Clusters" "Ad. R-Squared"))		
		
	/* Table A6: Decomposition */	
			
		/* Firm-fixed effects decomposition */
		qui {
		
			/* Partialling firm effects out */
			xtreg ear d, fe
			predict r_ear, e

			xtreg ret d, fe
			predict r_ret, e
	
			/* Negative return partition: variance/covariance */
			corr r_ear r_ret if ret<0, cov
			local cov_neg = r(cov_12)
			local var_neg = r(Var_2)

			/* Positive return partition: variance/covariance */
			corr r_ear r_ret if ret>=0, cov
			local cov_pos = r(cov_12)
			local var_pos = r(Var_2)
		}
		
		/* Output */
		di "___________________________"
		di "Negative Return Partition"
		di "Return variance: " round(`var_neg',.0001)
		di "Earnings-Return covariance: " round(`cov_neg',.0001)
		di "___________________________"
		di "Positive Return Partition"
		di "Return variance: " round(`var_pos',.0001)
		di "Earnings-Return covariance: " round(`cov_pos',.0001)
		di "___________________________"
		di "Spreads/Differences (Negative - Positive)"
		di "Variance: " round(`var_neg'-`var_pos',.0001)
		di "Earnings-Return covariance: " round(`cov_neg'-`cov_pos',.0001)
	
/* Log: close */
log close Appendix

/******************************************************************************/
/* Accrual Model: Simulation data (based on calibrated parameter values)	  */
/******************************************************************************/

/* Directory */
cd "$directory\Code\Models\02-Accrual model\Simulation\Data"

/* Data */
insheet using SimulationsWorkingCapital.csv,  clear
save Simulation_workingcapital, replace

/* Time Series */
gen t = _n
label var t "Period"

tsset t

/* Variables */
rename v1 earnings
label var earnings "Earnings"

rename v2 cash
label var cash "Cash from Operations"

rename v3 price
label var price "Price"

rename v4 profitability
label var profitability "Profitability"

rename v5 investment
label var investment "Investment"

rename v6 capital
label var capital "Capital"

rename v7 adj_cost
label var adj_cost "Adjustment cost"

rename v8 working_capital
label var working_capital "Working Capital"

gen price_ex_div = price-cash+investment
label var price_ex_div "Price (ex dividend)"

gen ret = d.price/l.price_ex_div
label var ret "Return"

gen wc_accruals = d.working_capital
label var wc_accruals "Working Capital Accruals"

gen wca = wc_accruals/l.price_ex_div
label var wca "Working Capital Accruals(t)/Price(t-1)"

/* Outlier Treatment */
drop if t<=1000 | t>101000
drop if abs(ret)>1

/* Figure A1: Working Capital Accruals */

	/* Results Directory */
	cd "$directory\Results\Models\Figures"
	
	/* Graphs */
	graph twoway ///
		(fpfitci wca ret, clcolor(black)) ///
		, legend(label(2 "Working Capital Accruals(t)/Price(t-1)") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///	
		title("Working Capital Accruals and Returns", color(black)) ///
		name(Figure_A1, replace) saving(Figure_A1, replace)

/******************************************************************************/
/* Non-Parametric Comparison												  */
/******************************************************************************/

/* Figure A2: Simulated Patterns */

	/* Data */
	cd "$directory\Data\Output"
	use Simulation, clear
	
	/* Results Directory */
	cd "$directory\Results\Models\Figures"
	
	/* Graph 1: Earnings-Return Concavity */
	graph twoway ///
		(fpfitci ear ret, clcolor(black)) ///
		, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
		ytitle("Earnings/Price") ///
		xtitle("Return") ///		
		title("Earnings-Return Concavity", color(black)) ///
		name(Figure_A2_1, replace) saving(Figure_A2_1, replace)

	
	/* Graph 2: Concavity and Volatility*/
	preserve
	
		/* Drop duplicates */
		duplicates drop firm, force
		
		/* Graph */
		graph twoway (lpolyci basu sd_ear, clcolor(black)) ///
			, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///
			ytitle("Earnings-Return Concavity") ///
			xtitle("Earnings Volatility") ///
			title("Earnings-Return Concavity and Earnings Volatility", color(black)) ///
			name(Figure_A2_2, replace) saving(Figure_A2_2, replace)
			
	restore
	
	/* Graph 3: ERC */
	graph twoway ///
		(fpfitci ret sue_e, clcolor(black)) ///
		, legend(label(1 "CI 95%") label(2 "ERC") order(1 2 4) rows(3) ring(0) position(11) bmargin(medium) symxsize(5)) ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
		ytitle("Return") ///
		xtitle("Earnings Surprise") ///
		title("Earnings-Response Coefficient", color(black)) ///
		name(Figure_A2_3, replace) saving(Figure_A2_3, replace)
	
	/* Graph 4: ERC and Volatilty */
	preserve
	
		/* Drop duplicates */
		duplicates drop firm, force
		
		/* Graph */
		graph twoway (lpolyci erc sd_ear, clcolor(black)) ///
			, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
			ytitle("ERC") ///
			xtitle("Earnings Volatility") ///
			title("ERC and Volatility", color(black)) ///
			name(Figure_A2_4, replace) saving(Figure_A2_4, replace)
	
	restore
	
	/* Graph 5: ERC and MTB */
	preserve
	
		/* Drop duplicates */
		duplicates drop firm, force
		
		/* Graph */
		graph twoway (lpolyci erc mean_mtb, clcolor(black)) ///
			, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
			graphregion(color(white)) plotregion(fcolor(white)) ///
			xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///					
			ytitle("ERC") ///
			xtitle("Market-to-Book") ///
			title("ERC and Market-to-Book", color(black)) ///
			name(Figure_A2_5, replace) saving(Figure_A2_5, replace)
		
	restore

/******************************************************************************/
/* Title:   Evaluation of Model Predictions in Compustat Data                 */
/* Authors: M. Breuer, D. Windisch                                            */
/* Date:    11/29/2018                                                        */
/******************************************************************************/
/* Program description:                                                       */
/* Generates Figures and Tables using Compustat, CRSP, and I/B/E/S data       */
/******************************************************************************/

*Preliminaries*
version 13.1
clear all
set more off
set type double

********************************************************************************
*** Annual Return Calculation ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\CRSP_monthly.dta", clear
egen start = min(date), by(permno)
egen end   = max(date), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_CRSP_monthly.dta", replace

**Data**
use "$directory\Data\Original\CRSP_monthly.dta", clear

**Sample**

*Ordinary shares of stocks listed on NYSE, AMEX, or NASDAQ*
keep if shrcd == 10|shrcd == 11|shrcd == 12
keep if exchcd == 1|exchcd == 2|exchcd == 3

*Panel*
gen tradingdate = mofd(date)
xtset permno tradingdate, monthly

*Cumulative 1-year returns (at fiscal year end + 3m)*
gen r = ln(1+ret)
gen v = ln(1+vwretd)
gen ret1y = r
gen vwret1y = v
forvalues i = 1/11 {
	replace ret1y = ret1y+l`i'.r
	replace vwret1y = vwret1y+l`i'.v
}
replace ret1y = exp(f3.ret1y)-1
replace vwret1y = exp(f3.vwret1y)-1

*Market-adjusted 1-year returns*
gen aret1y = ret1y - vwret1y
label var aret1y "Market Adjusted Annual Return (-9 to +3)"

*Matchdate (year-month)*
gen matchdate = tradingdate

*Saving*
keep permno matchdate aret1y
save "$directory\Data\Output\annualreturns.dta", replace

********************************************************************************
*** Announcement Return Calculation ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\CRSP_daily", clear
egen start = min(date), by(permno)
egen end   = max(date), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_CRSP_daily.dta", replace

**Data**
use "$directory\Data\Original\CRSP_daily", clear

*Ordinary shares of stocks listed on NYSE, AMEX, or NASDAQ*
keep if shrcd == 10|shrcd == 11|shrcd == 12
keep if exchcd == 1|exchcd == 2|exchcd == 3

*Panel*
bcal create allshares, from(date) dateformat(dmy) replace
gen tradingdate = bofd("allshares", date)
format tradingdate %tballshares
xtset permno tradingdate

*Cumulative 3-day returns*
gen r = ln(1+ret)
gen v = ln(1+vwretd)
gen ret3d = l1.r+r+f1.r
gen vwret3d = l1.v+v+f1.v

replace ret3d = exp(ret3d)-1
replace vwret3d = exp(vwret3d)-1

*Market-adjusted 3-day returns*
gen aret3d = ret3d - vwret3d
label var aret3d "Market Adjusted 3-day Return (centered)"

*Price data in d-2*
replace prc = abs(prc)
gen prcl2d = l2.prc
label var prcl2d "Price at d-2"

*Matchdate*
gen matchdate = date

*Saving*
keep permno matchdate aret3d prcl2d
save "$directory\Data\Output\dailyreturns.dta", replace

********************************************************************************
*** Earnings Surprise Calculation ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\IBES_act_unadj", clear
egen start = min(pends), by(ticker)
egen end   = max(pends), by(ticker)
bys ticker: keep if _n==1
format %td start end
keep ticker start end
save "$directory\Data\Identifiers\ID_IBES_act_unadj.dta", replace

use "$directory\Data\Original\IBES_fcact_adj", clear
egen start = min(fpedats), by(ticker)
egen end   = max(fpedats), by(ticker)
bys ticker: keep if _n==1
format %td start end
keep ticker start end
save "$directory\Data\Identifiers\ID_IBES_fcact_adj.dta", replace

use "$directory\Data\Original\IBES_fc_unadj.dta", clear
egen start = min(fpedats), by(ticker)
egen end   = max(fpedats), by(ticker)
bys ticker: keep if _n==1
format %td start end
keep ticker start end
save "$directory\Data\Identifiers\ID_IBES_fc_unadj.dta", replace

use "$directory\Data\Original\iclink.dta", clear
drop if permno == .
egen start = min(sdate), by(permno)
egen end   = max(edate), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_iclink.dta", replace

use "$directory\Data\Original\Compu_quarterly", clear
egen start = min(datadate), by(permno)
egen end   = max(datadate), by(permno)
bys permno: keep if _n==1
format %td start end
keep permno start end
save "$directory\Data\Identifiers\ID_Compu_quarterly.dta", replace

**Data**
use "$directory\Data\Original\IBES_act_unadj", clear

*Missing actuals*
drop if value == .

*Non-USD data*
keep if curr_act == "USD"

*Saving*
ren pends fpedats
ren anndats anndats_act
ren anntims anntims_act
ren value actual
keep ticker fpedats anndats_act anntims_act actual
save "$directory\Data\Output\ibesunadj_actuals", replace

**Data**
use "$directory\Data\Original\IBES_fcact_adj", clear

*Missing forecasts, actuals, announcement dates*
drop if value == .|actual == .|anndats_act == .

*Non-USD data*
keep if curr_act 	== "USD"
keep if report_curr == "USD"

*Keep only last estimate of each analyst on the same day (for merging)*
gen anntime = clock(anntims, "hms")
gen acttime = clock(acttims, "hms")
gsort ticker fpedats estimator analys -anndats -anntime -actdats -acttime
duplicates drop ticker fpedats estimator analys anndats, force

*Saving*
ren value value_adj
ren actual actual_adj
keep ticker fpedats estimator analys anndats value_adj actual_adj
save "$directory\Data\Output\ibesadj", replace

**Prepare ticker-permno link file**
use "$directory\Data\Original\iclink.dta", clear
drop if permno == .

bys ticker: gen position = _n
forvalues i = 1(1)10 {
gen sdatetmp_`i' = sdate if position == `i'
bys ticker: egen sdate_`i' = mean(sdatetmp_`i')
gen edatetmp_`i' = edate if position == `i'
bys ticker: egen edate_`i' = mean(edatetmp_`i')
format %td sdate_`i' edate_`i'
drop sdatetmp* edatetmp*
}

duplicates drop ticker, force
keep ticker permno sdate_* edate_*

*Saving*
save "$directory\Data\Output\iclink_unique.dta", replace

**Data**
use "$directory\Data\Original\IBES_fc_unadj.dta", clear

*Merge with undadjusted actuals*
merge m:1 ticker fpedats using "$directory\Data\Output\ibesunadj_actuals", keep(match) nogenerate

*Non-USD data*
keep if report_curr == "USD"

*Keep only last estimate of each analyst on the same day (for merging)*
gen anntime = clock(anntims, "hms")
gen acttime = clock(acttims, "hms")
gsort ticker fpedats estimator analys -anndats -anntime -actdats -acttime
duplicates drop ticker fpedats estimator analys anndats, force

merge 1:1 ticker fpedats estimator analys anndats using "$directory\Data\Output\ibesadj", keep(match) nogenerate

*Adjust for stock splits between forecast and actual announcement date*
gen value_ratio = value/value_adj
replace value_ratio = 1 if value == 0 & value_adj == 0
gen actual_ratio = actual/actual_adj
replace actual_ratio = 1 if actual == 0 & actual_adj == 0
gen adjfactor = actual_ratio/value_ratio
gen feps1y = value*adjfactor

*Missing forecast*
drop if feps1y == .

*Merge with ticker-permno link file*
merge m:1 ticker using "$directory\Data\Output\iclink_unique.dta", keep(match) nogenerate
gen timelink = .
forvalues i = 1(1)10 {
replace timelink = 1 if fpedats >= sdate_`i' & fpedats <= edate_`i'
}
drop if timelink == .

*Shift IBES announcement date if release is after 04:00 EST*
gen ahour = substr(anntims_act,1,2)
destring ahour, replace
replace anndats_act = anndats_act + 1 if ahour >= 16

*Correct IBES announcement date*
ren fpedats datadate
merge m:1 permno datadate using "$directory\Data\Original\Compu_quarterly", keep(1 3) nogenerate
gen eadate = anndats_act if anndats_act > datadate
replace eadate = rdq if rdq < anndats_act & rdq > datadate
drop if eadate == .

*Keep only forecasts in -95 to -3 days window before actual announcement date*
drop if eadate - anndats > 95
drop if eadate - anndats < 3

*Keep only last forecast of every analyst for each firm-year*
gsort ticker analys -anndats -anntims
duplicates drop ticker analys datadate, force

*Compute median consensus forecast by firm-year*
bys ticker datadate: egen epsmed  = median(feps1y)

*Keep only one observation per firm-year*
duplicates drop ticker datadate, force

*Duplicates*
duplicates tag permno datadate, gen(dup)
drop if dup > 0

*Earnings surprise*
gen surp = actual - epsmed
format surp %3.2f

*Saving*
keep cname datadate permno eadate surp
save "$directory\Data\Output\ibes.dta", replace

********************************************************************************
*** Prepare Compustat Sample ***
********************************************************************************

**Sample identifiers**
use "$directory\Data\Original\Compu_annual.dta", clear
egen start = min(datadate), by(lpermno)
egen end   = max(datadate), by(lpermno)
bys lpermno: keep if _n==1
format %td start end
keep lpermno start end
save "$directory\Data\Identifiers\ID_Compu_annual.dta", replace

**Data**
use "$directory\Data\Original\Compu_annual.dta", clear

*Select data*
keep lpermno fyear datadate ib cshpri prcc_f oancf xidoc act lct che dlc ///
txp dp ppegt invt at capx ivncf xrd ceq sic

*Add annual returns*
ren lpermno permno
gen matchdate = mofd(datadate)
merge 1:1 permno matchdate using "$directory\Data\Output\annualreturns.dta", keep(1 3) nogenerate

*Add IBES data*
merge 1:1 permno datadate using "$directory\Data\Output\ibes.dta", keep(1 3) nogenerate

*Add 3-day returns (repeated for eadates on non-trading days)*
replace matchdate = eadate
replace matchdate = _n*10000 if matchdate == .
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", keep(1 3) nogenerate
replace matchdate = matchdate + 1
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", update keep(1 3 4 5) nogenerate
replace matchdate = matchdate + 1
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", update keep(1 3 4 5) nogenerate
replace matchdate = matchdate + 1
merge 1:1 permno matchdate using "$directory\Data\Output\dailyreturns.dta", update keep(1 3 4 5) nogenerate

*Panel*
sort permno datadate
duplicates drop permno fyear, force
xtset permno fyear

********************************************************************************
*** Main Variables Definition ***
********************************************************************************

*Earnings*
gen inc = ib/cshpri/l.prcc_f if l.prcc_f >= 1 
label var inc "Earnings"

*Operating Cash Flow*
gen cfo	= (oancf-xidoc)/cshpri/l.prcc_f if l.prcc_f >= 1
label var cfo "Operating Cash Flow"

*Accruals*
gen acc = inc - cfo
label var acc "Accruals"

*Accruals/Operating Cash Flow from Balance Sheet Approach*
gen acc_bs = (d.act - d.lct - d.che + d.dlc + d.txp - dp)/cshpri/l.prcc_f if l.prcc_f >= 1
gen cfo_bs = inc - acc_bs

replace acc = acc_bs if acc == .
replace cfo = cfo_bs if cfo == .

*Earnings: Operating Cash Flow less Depreciation*
gen oancfdp = oancf - xidoc - dp
replace oancfdp = ib - (d.act - d.lct - d.che + d.dlc + d.txp) if oancfdp == .
gen mic = oancfdp/cshpri/l.prcc_f if l.prcc_f >= 1
label var mic "Model Earnings"

*Negative Return Dummy*
gen d = (aret1y < 0) if aret1y != .
label var d "Negative Returns"

*Investment-to-Assets Ratio*
gen iva = (d.ppegt + d.invt)/l.at if l.prcc_f >= 1
label var iva "Investment-to-Assets Ratio"

*Investment Growth*
replace xrd = 0 if xrd == .
gen ivg = (d.capx + d.xrd)/(l.capx + l.xrd)
replace ivg = 0 if d.capx == 0 & d.xrd == 0 & l.capx == 0 & l.xrd == 0
replace ivg = . if l.prcc_f < 1
label var ivg "Investment Growth"

*Investing Cash Flow*
replace ivncf = ivncf*-1
gen ivc = ivncf/l.at if l.prcc_f >= 1
label var ivc "Investing Cash Flow"

*Earnings Surprise (IBES)*
replace surp = . if fyear < 1993
gen sue = surp/prcl2d if prcl2d >= 1

*Volatility Measures* (Min. obs = 5)*
egen ct_inc = count(inc) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_inc = sd(inc) if ct_inc >= 5 & inc != . & fyear >= 1963 & fyear <= 2014, by(permno)
egen ct_cfo = count(cfo) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_cfo = sd(cfo) if ct_cfo >= 5 & cfo != . & fyear >= 1963 & fyear <= 2014, by(permno)
egen ct_acc = count(acc) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_acc = sd(acc) if ct_acc >= 5 & acc != . & fyear >= 1963 & fyear <= 2014, by(permno)
egen ct_in2 = count(inc) if fyear >= 1993 & fyear <= 2014, by(permno)
egen sd_in2 = sd(inc) if ct_inc >= 5 & inc != . & fyear >= 1993 & fyear <= 2014, by(permno)
egen ct_mic = count(mic) if fyear >= 1963 & fyear <= 2014, by(permno)
egen sd_mic = sd(mic) if ct_mic >= 5 & mic != . & fyear >= 1963 & fyear <= 2014, by(permno)
drop ct_*

*Market-to-Book*
gen mtb = (prcc_f*cshpri)/ceq if ceq > 0

*Define time-period*
drop if fyear < 1963|fyear > 2014

*Trim variables at 1%*
qui {
local variables="aret* inc cfo acc mic iva ivg ivc ib mtb"
foreach var of varlist `variables' {
sum `var', d
replace `var'=. if `var'>=r(p99)
replace `var'=. if `var'<=r(p1)
}
}

*Saving*
save "$directory\Data\Output\finaldata.dta", replace
	
********************************************************************************
*** TABLE 7: Compustat Concavities and Volatility ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

local sorts = "sd_inc sd_cfo sd_acc"
	foreach var of varlist `sorts' {
	qui bys permno: replace `var' = . if missing(aret1y, inc, cfo, acc)
	qui bys permno `var': replace `var' = . if _n!=1
	qui xtile `var'_q = `var', nq(5)
	qui bys permno: replace `var'_q = `var'_q[_n-1] if `var'_q == . 
}

forvalues k = 1/5 {
	xtreg inc c.aret1y##i.d i.fyear if sd_inc_q == `k', fe cluster(permno)
	est store inc_q
	xtreg cfo c.aret1y##i.d i.fyear if sd_cfo_q == `k', fe cluster(permno)
	est store cfo_q
	xtreg acc c.aret1y##i.d i.fyear if sd_acc_q == `k', fe cluster(permno)
	est store acc_q

	esttab inc_q cfo_q acc_q using "$directory\Results\Compustat\Tables\Table_7.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}

********************************************************************************
*** TABLE 8: Compustat Concavities and Investment ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

replace iva = . if missing(aret1y, inc, cfo, acc)
qui xtile iva_q = iva if iva != ., nq(5)

forvalues k = 1/5 {
	xtreg inc c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store inc_q
	xtreg cfo c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store cfo_q
	xtreg acc c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store acc_q

	esttab inc_q cfo_q acc_q using "$directory\Results\Compustat\Tables\Table_8.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}
	
********************************************************************************
*** Table A1: Data Moments (representing stable, industrial firm) ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear		
		
**Sample restrictions**

*Industries*
destring sic, force replace
drop if (sic >= 4000 & sic < 5000) | (sic >= 6000 & sic < 7000)
 
*Panel*
duplicates drop permno fyear, force
egen id = group(permno)
xtset id fyear

*Constant sample (firms with about 20-30 observations)*
keep if fyear >= (2014-30) & fyear <= 2014
foreach var of varlist oancf ivncf mtb {
	egen count = total(`var'!=.), by(id) missing	
	keep if count >= 20
	drop count
}

**Variables**

*(1) Cash flow variability*
gen cfo_at = oancf/l.at
egen std_cfo_at = sd(cfo_at), by(id)

*(2) Cash flow autocorrelation [note: pooled regression to improve precision]*
xtreg oancf l.oancf i.fyear, fe
gen ar_cfo = _b[L.oancf]
		
*(3) Investment level*
gen inv_at = ivncf/l.at
egen m_inv_at = mean(inv_at), by(id)

*(4) Investment variability*
egen std_inv_at = sd(inv_at), by(id)

*(5) Investment autocorrelation [note: pooled regression to improve precision]*
xtreg ivncf l.ivncf i.fyear, fe
gen ar_inv = _b[L.ivncf]
		
*(6) Market to book*
egen m_mtb = mean(mtb), by(id)

**Moments**
local M = "m_* std_* ar_*"
keep `M'

*Average moment*
qui foreach var of varlist `M' {
	sum `var'
	replace `var' = r(mean)
}

*Keep first observation*
keep if _n==1

*Order*
order std_cfo_at ar_cfo m_inv_at std_inv_at ar_inv m_mtb

*Output directory*
cd "$directory\Data\Output"
save Moments, replace
export delimited Moments.csv, replace novarnames	

********************************************************************************
*** TABLE A5: Concavities ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

foreach depvar of varlist inc cfo acc iva ivg ivc{

xtreg `depvar' c.aret1y##d i.fyear, fe cluster(permno)
est store `depvar'

esttab `depvar' using "$directory\Results\Compustat\Tables\Table_A5.rtf", ///
keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
}

********************************************************************************
*** TABLE A6: Decomposition of Earnings-Return Concavity ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

xtreg inc c.aret1y##i.d i.fyear, fe
local basu = _b[1.d#aret1y]
gen sample = e(sample)

xtreg inc d if sample==1, fe
predict r_inc if sample==1, e

xtreg aret1y d if sample==1, fe
predict r_aret1y if sample==1, e

*Log: open*
cd "$directory\Results\Compustat\Logs"
log using Appendix_Compustat, replace smcl name(Appendix_Compustat)

*Table A6: Decomposition of Earnings-Return Concavity*

	/* Firm-fixed effects decomposition */
	qui {
		
		/* Negative return partition: variance/covariance */
		corr r_inc r_aret1y if d == 1 & sample==1, cov
		local cov_neg = r(cov_12)
		local var_neg = r(Var_2)

		/* Positive return partition: variance/covariance */
		corr r_inc r_aret1y if d == 0 & sample==1, cov
		local cov_pos = r(cov_12)
		local var_pos = r(Var_2)
	}
		
	/* Output */
	di "___________________________"
	di "Negative Return Partition"
	di "Return variance: " round(`var_neg',.0001)
	di "Earnings-Return covariance: " round(`cov_neg',.0001)
	di "___________________________"
	di "Positive Return Partition"
	di "Return variance: " round(`var_pos',.0001)
	di "Earnings-Return covariance: " round(`cov_pos',.0001)
	di "___________________________"
	di "Spreads/Differences (Negative - Positive)"
	di "Variance: " round(`var_neg'-`var_pos',.0001)
	di "Earnings-Return covariance: " round(`cov_neg'-`cov_pos',.0001)		
		
*Log: close*
log close Appendix_Compustat

********************************************************************************
*** TABLE A7: Compustat Earnings-Return Concavity and Volatility/Investment 
***           with Alternative Earnings Definition ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

local sorts = "sd_mic"
	foreach var of varlist `sorts' {
	qui bys permno: replace `var' = . if missing(aret1y, inc, cfo, acc)
	qui bys permno `var': replace `var' = . if _n!=1
	qui xtile `var'_q = `var', nq(5)
	qui bys permno: replace `var'_q = `var'_q[_n-1] if `var'_q == . 
}

forvalues k = 1/5 {
	xtreg mic c.aret1y##i.d i.fyear if sd_mic_q == `k', fe cluster(permno)
	est store mic_q

	esttab mic_q using "$directory\Results\Compustat\Tables\Table_A7_A.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}
	
use "$directory\Data\Output\finaldata.dta", clear

replace iva = . if missing(aret1y, inc, cfo, acc)
qui xtile iva_q = iva if iva != ., nq(5)

forvalues k = 1/5 {
	xtreg mic c.aret1y##i.d i.fyear if iva_q == `k', fe cluster(permno)
	est store mic_q

	esttab mic_q using "$directory\Results\Compustat\Tables\Table_A7_B.rtf", ///
	keep(1.d#c.aret1y) cells(b(star fmt(3)) se(par fmt(3))) ar2 scalars(N_clust) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) nocons append
	}

********************************************************************************
*** FIGURE A2: Non-Parametric Comparison of Simulated and Compustat 
***            Earnings-Return Patterns ***
********************************************************************************

use "$directory\Data\Output\finaldata.dta", clear

**Compute firm-specific Basu coefficients**

	*ID*
	egen firmid = group(permno)

	*Placeholders*
	gen basu = .
	gen basu_obs = .

	*Loop over firms*
	qui sum firmid, d
	qui forvalues i = `r(min)'(1)`r(max)' {
	
		*Capture*
		capture {
		
			*Basu*/
			reg inc c.aret1y##i.d if firmid == `i'
			replace basu = _b[1.d#c.aret1y] if firmid == `i'
			replace basu_obs = e(N) if firmid == `i'

		}
	}

	*Drop estimates with less than 5 obs.*
	replace basu = . if basu_obs < 5	
	
	*Output directory*
	cd "$directory\Results\Compustat\Figures"
	
	*Basu
	
		*Graph 1: Earnings-Return Concavity*
		graph twoway ///
			(fpfitci inc aret1y if abs(aret1y)<1, clcolor(black)) ///
				, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///	
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
				ytitle("Earnings/Price") ///
				xtitle("Return") ///
				title("Earnings-Return Concavity", color(black)) ///
				name(Figure_A2_1, replace) saving(Figure_A2_1, replace) 	
		
		*Graph 2: Earnings-Return Concavity and Volatility*
		preserve
		
			*Missing*
			replace fyear = . if firmid == .
			xtset firmid fyear

			*Drop to firm-level*
			duplicates drop firmid, force
			
			*Outlier*
			qui sum basu, d
			local basu_min = r(p5)
			local basu_max = r(p95)
				
			*Basu and Volatility*
			qui sum sd_inc, d
			local sd_inc_max = r(p95)
			
			graph twoway ///
				(lpolyci basu sd_inc if `basu_min'<basu & basu<`basu_max' & sd_inc<`sd_inc_max', clcolor(black)) ///
					, legend(label(1 "CI 95%") label(2 "Earnings-Return Concavity") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
					ytitle("Earnings-Return Concavity") ///
					xtitle("Earnings Volatility") ///
					title("Earnings-Return Concavity and Volatility", color(black)) ///
					name(Figure_A2_2, replace) saving(Figure_A2_2, replace)

		restore

**Compute firm-specific Basu coefficients**

	*ID8
	drop firmid
	egen firmid = group(permno) if fyear >= 1993
	
	*Outliers (Cohen et al., 2007)*
	replace sue = . if abs(sue) > 0.1
	
	*Placeholders*
	gen erc = .
	gen erc_obs = .

	*Loop over firms*
	qui sum firmid, d
	qui forvalues i = `r(min)'(1)`r(max)' {
	
		*Capture*
		capture {

			*ERC*
			reg aret3d sue if firmid == `i'
			replace erc = _b[sue] if firmid == `i'
			replace erc_obs = e(N) if firmid == `i'

		}
	}

	*Drop estimates with less than 5 obs.*
	replace erc = . if erc_obs < 5		
		
	*ERC*
	
		*Graph 3: Earnings-Response Coefficient*
		graph twoway ///
			(fpfitci aret3d sue, clcolor(black)) ///
				, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///	
				graphregion(color(white)) plotregion(fcolor(white)) ///
				xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
				ytitle("Return") ///
				xtitle("Earnings Surprise") ///
				title("Earnings-Response Coefficient", color(black)) ///
				name(Figure_A2_3, replace) saving(Figure_A2_3, replace)

		*Graphs 4, 5: ERC, Volatility, and Market-to-Book*
		preserve

			*Missing*
			replace fyear = . if firmid == .
			xtset firmid fyear

			*Keep one observation for each firm*
			duplicates drop firmid, force
				
			*Mark outliers*
			qui sum erc, d
			local erc_min = r(p5)
			local erc_max = r(p95)
			qui sum sd_in2, d
			local sd_in2_max = r(p95)
			qui sum mtb, d
			local mtb_max = r(p95)

			*Graph 4: ERC and Volatility*
			graph twoway ///
				(lpolyci erc sd_in2 if `erc_min'<erc & erc<`erc_max' & sd_in2<`sd_in2_max', clcolor(black)) ///
					, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
					ytitle("ERC") ///
					xtitle("Earnings Volatility") ///
					title("ERC and Volatility", color(black)) ///
					name(Figure_A2_4, replace) saving(Figure_A2_4, replace)

			*Graph 5: ERC and Market-to-Book*
			graph twoway ///
				(lpolyci erc mtb if `erc_min'<erc & erc<`erc_max' & mtb<`mtb_max', clcolor(black)) ///
					, legend(label(1 "CI 95%") label(2 "ERC") rows(2) ring(0) position(11) bmargin(medium) symxsize(5)) ///
					graphregion(color(white)) plotregion(fcolor(white)) ///
					xlabel(, format(%9.2f)) ylabel(, format(%9.2f) angle(0)) ///		
					ytitle("ERC") ///
					xtitle("Market-to-Book") ///
					title("ERC and Market-to-Book", color(black)) ///
					name(Figure_A2_5, replace) saving(Figure_A2_5, replace)

		restore

/******************************************************************************/
/* Illustration of Cross-Sectional Volatility Results						  */
/******************************************************************************/
/* Simulated Results:														  */
/*	0.086***	0.113***	0.135***	0.153***	0.202***				  */
/*	(0.005)		(0.005)		(0.005)		(0.006)		(0.006)					  */
/* Compustat Results:														  */
/* 	0.022***	0.039***	0.068***	0.153***	0.259***			      */
/*	(0.002)		(0.003)		(0.005)		(0.007)		(0.011)					  */
/******************************************************************************/

**** Preliminaries ****
clear all
set more off

**** Results Directory ****
cd "$directory\Results\Models\Figures"

**** Observations ****
set obs 5

**** Coefficients ****
gen quintile = _n
label var quintile "Quintile" 

gen simulated = 0.086 if quintile == 1
replace simulated = 0.113 if quintile == 2
replace simulated = 0.135 if quintile == 3
replace simulated = 0.153 if quintile == 4
replace simulated = 0.202 if quintile == 5

gen compustat = 0.022 if quintile == 1
replace compustat = 0.039 if quintile == 2
replace compustat = 0.068 if quintile == 3
replace compustat = 0.153 if quintile == 4
replace compustat = 0.259 if quintile == 5

**** Standard Errors ****
gen se_simulated = 0.005
replace se_simulated = 0.006 if quintile == 4 | quintile == 5

gen se_compustat = 0.002 if quintile == 1
replace se_compustat = 0.003 if quintile == 2
replace se_compustat = 0.005 if quintile == 3
replace se_compustat = 0.007 if quintile == 4
replace se_compustat = 0.011 if quintile == 5

**** Upper/Lower ****
gen l_simulated = simulated - 1.96*se_simulated
gen l_compustat = compustat - 1.96*se_compustat
gen u_simulated = simulated + 1.96*se_simulated
gen u_compustat = compustat + 1.96*se_compustat

**** Graph ****
graph twoway ///
	(rcap l_simulated u_simulated quintile, color(gs10)) ///
	(rcap l_compustat u_compustat quintile, color(black)) ///
	(connected simulated quintile, lpattern(dash) lwidth(medium) msize(vlarge) msymbol(d) color(gs10)) ///
	(connected compustat quintile, lwidth(medium) msize(vlarge) msymbol(s) color(black)) ///
	, legend(label(1 "95% CI") label(3 "Simulated data") label(4 "Compustat")  rows(3) order(1 3 4) ring(0) position(11) bmargin(medium) symxsize(5)) ///
	xtitle("Quintile (Standard deviation of Earnings (t)/Price (t-1))") xlabel(, format(%9.0f)) ylabel(, format(%9.2f) angle(0)) ///
	title("Earnings-Return Concavity and Volatility", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	name(Volatility, replace) saving(Volatility, replace)
	
/******************************************************************************/
/* Illustration of Cross-Sectional Investment Results	(Lyandres et al. 2008)*/
/******************************************************************************/
/* Simulated Results:														  */
/*	0.175***	0.030***	0.021***	0.020***	0.000					  */
/*	(0.027)		(0.006)		(0.004)		(0.004)		(0.008)					  */
/* Compustat Results:														  */
/* 	0.172***	0.088***	0.084***	0.071***	0.060***			      */
/*	(0.010)		(0.008)		(0.007)		(0.006)		(0.005)					  */
/******************************************************************************/

**** Preliminaries ****
clear

**** Observations ****
set obs 5

**** Coefficients ****
gen quintile = _n
label var quintile "Quintile" 

gen simulated = 0.175 if quintile == 1
replace simulated = 0.030 if quintile == 2
replace simulated = 0.021 if quintile == 3
replace simulated = 0.020 if quintile == 4
replace simulated = 0.000 if quintile == 5

gen compustat = 0.172 if quintile == 1
replace compustat = 0.088 if quintile == 2
replace compustat = 0.084 if quintile == 3
replace compustat = 0.071 if quintile == 4
replace compustat = 0.060 if quintile == 5

**** Standard Errors ****
gen se_simulated = 0.027 if quintile == 1
replace se_simulated = 0.006 if quintile == 2
replace se_simulated = 0.004 if quintile == 3
replace se_simulated = 0.004 if quintile == 4
replace se_simulated = 0.008 if quintile == 5

gen se_compustat = 0.010 if quintile == 1
replace se_compustat = 0.008 if quintile == 2
replace se_compustat = 0.007 if quintile == 3
replace se_compustat = 0.006 if quintile == 4
replace se_compustat = 0.005 if quintile == 5

**** Upper/Lower ****
gen l_simulated = simulated - 1.96*se_simulated
gen l_compustat = compustat - 1.96*se_compustat
gen u_simulated = simulated + 1.96*se_simulated
gen u_compustat = compustat + 1.96*se_compustat

**** Graph ****
graph twoway ///
	(rcap l_simulated u_simulated quintile, color(gs10)) ///
	(rcap l_compustat u_compustat quintile, color(black)) ///
	(connected simulated quintile, lpattern(dash) lwidth(medium) msize(vlarge) msymbol(d) color(gs10)) ///
	(connected compustat quintile, lwidth(medium) msize(vlarge) msymbol(s) color(black)) ///
	, legend(label(1 "95% CI") label(3 "Simulated data") label(4 "Compustat")  rows(3) order(1 3 4) ring(0) position(11) bmargin(medium) symxsize(5)) ///
	xtitle("Quintile (Investment (t))") xlabel(, format(%9.0f)) ylabel(, format(%9.2f) angle(0)) ///
	title("Earnings-Return Concavity and Investment", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	name(Investment, replace)
	
/* Figure 11: Earnings-Return Asymmetry, Volatility, and Investment */
graph combine Volatility Investment, ///
	altshrink cols(2) ysize(5) xsize(10) ///
	title("Earnings-Return Concavity, Volatility, and Investment", color(black)) ///
	graphregion(color(white)) plotregion(fcolor(white)) ///
	name(Figure_11, replace) saving(Figure_11, replace)		

