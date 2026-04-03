/******************************************************************************/
/* Title: 	Using and Interpreting Fixed Effects Models						  */
/* Author:  Matthias Breuer, Ed deHaan										  */
/* Year:	2024															  */
/******************************************************************************/

/* Preliminaries */
clear all
version 15.1
set more off
set seed 1234

/* Directory */
local directory = "" // Enter working directory
cd "`directory'"

/******************************************************************************/
/* Sample																	  */
/******************************************************************************/

/* Parameters */
	
	/* Number of firms */
	local M = 3
	
	/* Number of observations per firm */
	local T = 6
	
	/* True regression */
			
		/* Coefficient */
		local b = -1
		
		/* Heterogeneity */
		
			/* Firm 1 */
			local a1_y = 1.5
			local a1_x = 1
			
			/* Firm 2 */
			local a2_y = 3
			local a2_x = 2
			
			/* Firm 3 */
			local a3_y = 4.5
			local a3_x = 3		


/* Sample */
local obs = `M'*`T'
set obs `obs'			

/* Panel */
gen i = ceil(_n/`T')
gen t = _n - (i-1)*`T'

/* X */
gen x = rnormal(0, 0.5)

	/* Loop over firms */
	qui sum i
	forvalues i = `r(min)'(1)`r(max)' {
	
		/* Replace */
		replace x = x + `a`i'_x' if i == `i'

	}
	
/* Y */
gen y = rnormal(0, 0.5)

	/* Loop over firms */
	qui sum i
	forvalues i = `r(min)'(1)`r(max)' {
	
		/* Replace */
		replace y = y + `b'*x + `a`i'_y' if i == `i'

	}

	
/******************************************************************************/
/* Regressions																  */
/******************************************************************************/

/* Constant regression */

	/* Recentered Y */
	qui reg y
	predict e_y, res	
 
	/* Recentered X */
	qui reg x
	predict e_x, res		
	
	/* Means for recentering */
	
		/* Loop over Y and X */
		foreach var of varlist y x {
			
			/* Mean */
			qui sum `var'
			local m_`var' = r(mean)
		
			/* Min / max scale for (recentered) graph */
			local min_`var' = -1
			local max_`var' = 4
			local min_`var'_r = round(-1 - `m_`var'', 0.01)
			local max_`var'_r = round(4 - `m_`var'', 0.01)
		
		}
		
/* FE regression */

	/* Recentered Y */
	qui reg y i.i
	predict e_y_FE, res
	
	/* Recentered X */
	qui reg x i.i
	predict e_x_FE, res

	/* Predicted Y */
	qui reg y x i.i
	predict y_hat, xb
	
	/* Means for recentering */
	
		/* Loop over Y and X */
		foreach var of varlist y x {
			
			/* Recentered axis */
			gen axis_`var' =.
			
			/* Loop over firms */
			qui sum i
			forvalues i = `r(min)'(1)`r(max)' {		
			
				/* Mean */
				qui sum `var' if i == `i'
				local m_`var'`i' = r(mean)
				
				/* Replace recentered axis */
				replace axis_`var' = r(mean) if i == `i'
			
			}		
		}
		
		/* Replace recentered axis */
		replace axis_x = axis_x + (t - ceil(`T'/4))/2 if t <= `T'/2
		replace axis_y = axis_y + (t - ceil(`T'/4) - `T'/2)/2 if t > `T'/2
	
	
/******************************************************************************/
/* Figures																	  */
/******************************************************************************/
	
/* Figure 1: Histograms of X & Y */

	/* Panel A: Y */
	graph twoway ///
		(hist y, color(gs14) freq width(0.5) start(-4)) ///
		(hist y if i == 1 | i == 2, color(gs10) freq  width(0.5) start(-4)) ///
		(hist y if i == 1, color(gs6) freq  width(0.5) start(-4)) ///
		(hist y, lcolor(black) fcolor(none) freq  width(0.5) start(-4) lwidth(thin)) ///
		, xline(0, lcolor(black) lwidth(thin) lpattern(dash)) ///
		ylabel(0(2)10, angle(0) format(%9.0f)) xlabel(, angle(0) format(%9.0f)) ///
		xlabel(-4(1)4) ///
		legend(label(1 "Firm 3") label(2 "Firm 2") label(3 "Firm 1") order(3 2 1) rows(3) ring(0) position(2) bmargin(medium)) ///
		xtitle("y{subscript:i,t}") ///
		ytitle("Frequency") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel A}" "Raw y{subscript:i,t}", color(black)) ///
		name(Figure_1a, replace)
	
	/* Panel B: X */
	graph twoway ///
		(hist x, color(gs14) freq width(0.5) start(-4)) ///
		(hist x if i == 1 | i == 2, color(gs10) freq  width(0.5) start(-4)) ///
		(hist x if i == 1, color(gs6) freq  width(0.5) start(-4)) ///
		(hist x, lcolor(black) fcolor(none) freq  width(0.5) start(-4) lwidth(thin)) ///
		, xline(0, lcolor(black) lwidth(thin) lpattern(dash)) ///
		ylabel(0(2)10, angle(0) format(%9.0f)) xlabel(, angle(0) format(%9.0f)) ///
		xlabel(-4(1)4) ///
		legend(off) ///
		xtitle("y{subscript:i,t}") ///
		ytitle("Frequency") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel B}" "Raw x{subscript:i,t}", color(black)) ///
		name(Figure_1b, replace)	
	
	/* Panel C: Y residualized to constant */
	graph twoway ///
		(hist e_y, color(gs14) freq width(0.5) start(`min_y_r')) ///
		(hist e_y if i == 1 | i == 2, color(gs10) freq  width(0.5) start(`min_y_r')) ///
		(hist e_y if i == 1, color(gs6) freq  width(0.5) start(`min_y_r')) ///
		(hist e_y, lcolor(black) fcolor(none) freq  width(0.5) start(`min_y_r') lwidth(thin)) ///
		, xline(0, lcolor(black) lwidth(thin) lpattern(dash)) ///
		ylabel(0(2)10, angle(0) format(%9.0f)) xlabel(, angle(0) format(%9.0f)) ///
		xlabel(-4(1)4) ///
		legend(off) ///
		xtitle("{&epsilon}{subscript:y{subscript:i,t}}") ///
		ytitle("Frequency") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel C}" "y{subscript:i,t} residualized to constant ({&epsilon}{subscript:y{subscript:i,t}})", color(black)) ///
		name(Figure_1c, replace)	
	
	/* Panel D: X residulaizd to constant */
	graph twoway ///
		(hist e_x, color(gs14) freq width(0.5) start(`min_x_r')) ///
		(hist e_x if i == 1 | i == 2, color(gs10) freq  width(0.5) start(`min_x_r')) ///
		(hist e_x if i == 1, color(gs6) freq  width(0.5) start(`min_x_r')) ///
		(hist e_x, lcolor(black) fcolor(none) freq  width(0.5) start(`min_x_r') lwidth(thin)) ///
		, xline(0, lcolor(black) lwidth(thin) lpattern(dash)) ///
		ylabel(0(2)10, angle(0) format(%9.0f)) xlabel(, angle(0) format(%9.0f)) ///
		xlabel(-4(1)4) ///
		legend(off) ///
		xtitle("{&epsilon}{subscript:x{subscript:i,t}}") ///
		ytitle("Frequency") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel D}" "x{subscript:i,t} residualized to constant ({&epsilon}{subscript:x{subscript:i,t}})", color(black)) ///
		name(Figure_1d, replace)	
	
	/* Panel E: Y residualized to firm FE */
	graph twoway ///
		(hist e_y_FE, color(gs14) freq width(0.5) start(`min_y_r')) ///
		(hist e_y_FE if i == 1 | i == 2, color(gs10) freq  width(0.5) start(`min_y_r')) ///
		(hist e_y_FE if i == 1, color(gs6) freq  width(0.5) start(`min_y_r')) ///
		(hist e_y_FE, lcolor(black) fcolor(none) freq  width(0.5) start(`min_y_r') lwidth(thin)) ///
		, xline(0, lcolor(black) lwidth(thin) lpattern(dash)) ///
		ylabel(0(2)10, angle(0) format(%9.0f)) xlabel(, angle(0) format(%9.0f)) ///
		xlabel(-4(1)4) ///
		legend(off) ///
		xtitle("{&epsilon}{subscript:y{subscript:i,t}}") ///
		ytitle("Frequency") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel E}" "y{subscript:i,t} residualized to firm FE ({&epsilon}{subscript:y{subscript:i,t}})", color(black)) ///
		name(Figure_1e, replace)	
	
	/* Panel F: X residualized to firm FE */
	graph twoway ///
		(hist e_x_FE, color(gs14) freq width(0.5) start(`min_x_r')) ///
		(hist e_x_FE if i == 1 | i == 2, color(gs10) freq  width(0.5) start(`min_x_r')) ///
		(hist e_x_FE if i == 1, color(gs6) freq  width(0.5) start(`min_x_r')) ///
		(hist e_x_FE, lcolor(black) fcolor(none) freq  width(0.5) start(`min_x_r') lwidth(thin)) ///
		, xline(0, lcolor(black) lwidth(thin) lpattern(dash)) ///
		ylabel(0(2)10, angle(0) format(%9.0f)) xlabel(, angle(0) format(%9.0f)) ///
		xlabel(-4(1)4) ///
		legend(off) ///
		xtitle("{&epsilon}{subscript:x{subscript:i,t}}") ///
		ytitle("Frequency") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel F}" "x{subscript:i,t} residualized to firm FE ({&epsilon}{subscript:x{subscript:i,t}})", color(black)) ///
		name(Figure_1f, replace)	

	/* Combined */
	
		/* Two histograms per page */
		
			/* Panels A and B */
			graph combine Figure_1a Figure_1b ///
				, altshrink cols(2) ysize(10) xsize(30) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_1ab, replace) saving(Figure_1ab, replace)
			
				/* Export */
				graph export Figure_1ab.pdf, replace	
	
			/* Panels C and D */
			graph combine Figure_1c Figure_1d ///
				, altshrink cols(2) ysize(10) xsize(30) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_1cd, replace) saving(Figure_1cd, replace)
			
				/* Export */
				graph export Figure_1cd.pdf, replace	
				
			/* Panels E and F */
			graph combine Figure_1e Figure_1f ///
				, altshrink cols(2) ysize(10) xsize(30) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_1ef, replace) saving(Figure_1ef, replace)
			
				/* Export */
				graph export Figure_1ef.pdf, replace	
				
/* Figure 2: Regression Plots */

	/* Panel A: Observations */
	graph twoway ///
		(scatter y x if i == 1, color(gs6)) ///
		(scatter y x if i == 2, color(gs10)) ///
		(scatter y x if i == 3, color(gs14)) ///		
		(pcarrowi 2.5 -0.5 1.15 0.2 (11) "Firm 1", color(black) msymbol(A) mlabcolor(black)) ///
		(pcarrowi 3 1.3 2.1 1.51 (11) "Firm 2", color(black) msymbol(A) mlabcolor(black)) ///
		(pcarrowi 3 3.3 2.1 2.9 (2) "Firm 3", color(black) msymbol(A) mlabcolor(black)) ///
		, xline(0, lcolor(black) lwidth(thin)) yline(0, lcolor(black) lwidth(thin)) ///
		ylabel(-4(1)4, angle(0) format(%9.0f)) xlabel(-4(1)4, angle(0) format(%9.0f)) ///
		legend(off) ///
		xtitle("x{subscript:i,t}") ///
		ytitle("y{subscript:i,t}") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel A}" "Observations", color(black)) ///
		name(Figure_2a, replace)
		
	/* Panel B: No constant */
	graph twoway ///
		(scatter y x if i == 1, color(gs6)) ///
		(scatter y x if i == 2, color(gs10)) ///
		(scatter y x if i == 3, color(gs14)) ///		
		(lfit y x, estopts(nocons) lcolor(red) lwidth(medthick)) ///
		(pcarrowi -1 -0.5 -0.1 -0.1 (7) "Origin", color(black) msymbol(A) mlabcolor(black)) ///		
		, xline(0, lcolor(black) lwidth(thin)) yline(0, lcolor(black) lwidth(thin)) ///
		ylabel(-4(1)4, angle(0) format(%9.0f)) xlabel(-4(1)4, angle(0) format(%9.0f)) ///
		legend(off) ///
		xtitle("x{subscript:i,t}") ///
		ytitle("y{subscript:i,t}") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel B}" "No constant", color(black)) ///
		name(Figure_2b, replace)		
	
	/* Panel C: With constant */
	graph twoway ///
		(scatter y x if i == 1, color(gs6)) ///
		(scatter y x if i == 2, color(gs10)) ///
		(scatter y x if i == 3, color(gs14)) ///		
		(lfit y x, lcolor(red) lwidth(medthick)) ///
		(pcarrowi -1 3 1.1 2.05 (6) "Point of means", color(black) msymbol(A) mlabcolor(black)) ///
		, xline(0, lcolor(black) lwidth(thin)) yline(0, lcolor(black) lwidth(thin)) ///
		xline(`m_x', lcolor(black) lwidth(thin) lpattern(dash)) yline(`m_y', lcolor(black) lwidth(thin) lpattern(dash)) ///
		ylabel(-4(1)4, angle(0) format(%9.0f)) xlabel(-4(1)4, angle(0) format(%9.0f)) ///
		legend(off) ///
		xtitle("x{subscript:i,t}") ///
		ytitle("y{subscript:i,t}") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel C}" "With constant", color(black)) ///
		name(Figure_2c, replace)	

	/* Panel D: Residualized to constant */
	graph twoway ///
		(scatter e_y e_x if i == 1, color(gs6)) ///
		(scatter e_y e_x if i == 2, color(gs10)) ///
		(scatter e_y e_x if i == 3, color(gs14)) ///		
		(lfit e_y e_x, lcolor(red) lwidth(medthick)) ///
		(pcarrowi -1 -0.5 -0.1 -0.1 (7) "Re-centered origin", color(black) msymbol(A) mlabcolor(black)) ///				
		, xline(0, lcolor(black) lwidth(thin)) yline(0, lcolor(black) lwidth(thin)) ///
		ylabel(-4(1)4, angle(0) format(%9.0f)) xlabel(-4(1)4, angle(0) format(%9.0f)) ///
		legend(off) ///
		xtitle("{&epsilon}{subscript:x{subscript:i,t}}") ///
		ytitle("{&epsilon}{subscript:y{subscript:i,t}}") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel D}" "Residualized to constant", color(black)) ///
		name(Figure_2d, replace)
	
	/* Panel E: With firm FE */	
	graph twoway ///
		(line axis_y axis_x if i == 1 & t <= `T'/2, color(black) lwidth(thin) lpattern(dash)) ///
		(line axis_y axis_x if i == 1 & t > `T'/2, color(black) lwidth(thin) lpattern(dash)) ///
		(line axis_y axis_x if i == 2 & t <= `T'/2, color(black) lwidth(thin) lpattern(dash)) ///
		(line axis_y axis_x if i == 2 & t > `T'/2, color(black) lwidth(thin) lpattern(dash)) ///
		(line axis_y axis_x if i == 3 & t <= `T'/2, color(black) lwidth(thin) lpattern(dash)) ///
		(line axis_y axis_x if i == 3 & t > `T'/2, color(black) lwidth(thin) lpattern(dash)) ///
		(scatter y x if i == 1, color(gs6)) ///
		(scatter y x if i == 2, color(gs10)) ///
		(scatter y x if i == 3, color(gs14)) ///		
		(lfit y_hat x if i == 1, lcolor(red) lwidth(medthick)) ///
		(lfit y_hat x if i == 2, lcolor(red) lwidth(medthick)) ///
		(lfit y_hat x if i == 3, lcolor(red) lwidth(medthick)) ///
		(pcarrowi -1 3 0.73 1.05 (6) "Points of firm-specific means", color(black) msymbol(A) mlabcolor(black)) ///
		(pcarrowi -1 3 1.41 1.9 (11) "", color(black) msymbol(A) mlabcolor(black)) ///
		(pcarrowi -1 3 1.2 3.1 (2) "", color(black) msymbol(A) mlabcolor(black)) ///		
		, xline(0, lcolor(black) lwidth(thin)) yline(0, lcolor(black) lwidth(thin)) ///
		ylabel(-4(1)4, angle(0) format(%9.0f)) xlabel(-4(1)4, angle(0) format(%9.0f)) ///
		legend(off) ///
		xtitle("x{subscript:i,t}") ///
		ytitle("y{subscript:i,t}") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel E}" "With firm FE", color(black)) ///
		name(Figure_2e, replace)	
	
	/* Panel F: Residualized to firm FE */
	graph twoway ///
		(scatter e_y_FE e_x_FE if i == 1, color(gs6)) ///
		(scatter e_y_FE e_x_FE if i == 2, color(gs10)) ///
		(scatter e_y_FE e_x_FE if i == 3, color(gs14)) ///		
		(lfit e_y_FE e_x_FE, lcolor(red) lwidth(medthick)) ///
		(pcarrowi -1 -0.5 -0.1 -0.1 (7) "Re-centered origin", color(black) msymbol(A) mlabcolor(black)) ///						
		, xline(0, lcolor(black) lwidth(thin)) yline(0, lcolor(black) lwidth(thin)) ///
		ylabel(-4(1)4, angle(0) format(%9.0f)) xlabel(-4(1)4, angle(0) format(%9.0f)) ///
		legend(off) ///
		xtitle("{&epsilon}{subscript:x{subscript:i,t}}") ///
		ytitle("{&epsilon}{subscript:y{subscript:i,t}}") ///
		graphregion(color(white)) plotregion(fcolor(white)) ///
		title("{bf:Panel F}" "Residualized to firm FE", color(black)) ///
		name(Figure_2f, replace)	
		
	/* Combined */
	
		/* Two histograms per page */
		
			/* Panels A and B */	
			graph combine Figure_2a Figure_2b ///
				, altshrink cols(2)  ysize(10) xsize(20) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_2ab, replace) saving(Figure_2ab, replace)
				
				/* Export */
				graph export Figure_2ab.pdf, replace
				
			/* Panels C and D */	
			graph combine Figure_2c Figure_2d ///
				, altshrink cols(2) ysize(10) xsize(20) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_2cd, replace) saving(Figure_2cd, replace)
				
				/* Export */
				graph export Figure_2cd.pdf, replace
				
			/* Panels E and F */	
			graph combine Figure_2e Figure_2f ///
				, altshrink cols(2) ysize(10) xsize(20) ///
				graphregion(color(white)) plotregion(fcolor(white)) ///
				name(Figure_2ef, replace) saving(Figure_2ef, replace)
				
				/* Export */
				graph export Figure_2ef.pdf, replace				