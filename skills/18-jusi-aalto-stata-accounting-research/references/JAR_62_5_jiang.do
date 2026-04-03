clear all
log using code_outputs, text replace

*****************************************************************************************************************************
*****************************************************************************************************************************
***JAR - Comply or Explain: Do Firms Opportunistically Claim Trade Secrets in Mandatory Environmental Disclosure Programs?***
****************************************************Yile (Anson) Jiang*******************************************************
*****************************************************************************************************************************
*This do file reproduces all of the figures and tables reported in the paper and the online appendix
*The log file is saved as 'code_outputs.txt'


*********************************************************************
***Online Appendix Table C.2: Determinants of innovative operators***
*********************************************************************
clear
import delimited "C:\Users\anson\Dropbox\Dissertation\Fracfocus\FracFocusCSV\final_data\fracfocus_within_op.csv", encoding(ISO-8859-2) 

encode play, gen(nplay)
encode operatorname, gen(nop)

*Panel A: Within-operator analysis
eststo clear 
eststo: quietly ppmlhdfe inn_play log_wellcount_byplay log_cumsum_byplay opexp_byplay ln_ogprod_byplay_y, absorb(nop nplay#year) vce(cluster nplay year)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe inn_play  log_wellcount_byplay log_cumsum_byplay opexp_byplay ln_ogprod_byplay_y, absorb(nop nplay#year) vce(cluster nplay year)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly ppmlhdfe inn_play log_wellcount_byplay log_cumsum_byplay opexp_byplay ln_ogprod_byplay_y if public==1,absorb(nop nplay#year) vce(cluster  nplay year)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe inn_play log_wellcount_byplay log_cumsum_byplay opexp_byplay ln_ogprod_byplay_y if public==1,absorb(nop nplay#year) vce(cluster  nplay year)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly ppmlhdfe inn_play log_wellcount_byplay log_cumsum_byplay opexp_byplay ln_ogprod_byplay_y if public==0,absorb(nop nplay#year) vce(cluster  nplay year)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe inn_play log_wellcount_byplay log_cumsum_byplay opexp_byplay ln_ogprod_byplay_y if public==0,absorb(nop nplay#year) vce(cluster  nplay year)
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01)  scalars("operator Operator FE" "optime Shale Play*Year FE" "N N ""r2 Adjusted R-squared")  drop(_cons) cells(b(star fmt(3)) se(par fmt(3)))

clear 
import delimited "C:\Users\anson\Dropbox\Dissertation\Fracfocus\FracFocusCSV\final_data\fracfocus_between_op.csv", encoding(ISO-8859-2) 

encode ticker, gen(nticker)

*Panel B: Between-operator analysis (public operators only)
eststo clear 
eststo: quietly ppmlhdfe inn_op size lev roa tobin cash capex rd_b profitmargin tort_op ln_media, absorb(year) vce(cluster nticker year)
estadd local operator "NO"
estadd local time "YES"
eststo: quietly reghdfe inn_op size lev roa tobin cash capex rd_b profitmargin tort_op ln_media, absorb(year) vce(cluster nticker year)
estadd local operator "NO"
estadd local time "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("operator Operator FE" "time Year FE" "N N ""r2 Adjusted R-squared") drop(_cons) cells(b(star fmt(3)) se(par fmt(3)))


*****************************************************************************
***Online Appendix  Table C.3: Validation tests for the INNOVATIVE measure***
*****************************************************************************
clear 
import delimited "C:\Users\anson\Dropbox\Dissertation\Fracfocus\FracFocusCSV\final_data\inn_validation.csv", encoding(ISO-8859-2) 

encode play, gen(nplay)
encode operatorname, gen(nop)
gen yearmonth=ym(year, month)
format yearmonth %tm

*Panel A: Innovative vs Non-innovative operators
eststo clear
eststo: quietly reghdfe ln_ogprod_byplay inn_play, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "NO"
estadd local optime "YES"
eststo: quietly reghdfe ln_ogprod_byplay inn_play, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ln_ogprod_byplay inn_play if public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "NO"
estadd local optime "YES"
eststo: quietly reghdfe  ln_ogprod_byplay inn_play if public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ln_ogprod_byplay inn_play if public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "NO"
estadd local optime "YES"
eststo: quietly reghdfe  ln_ogprod_byplay inn_play if public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) 

*Panel B: Imitative vs Non-imitative operators (exclude the innovative sample)
eststo clear
eststo: quietly reghdfe ln_ogprod_byplay imi if inn_play==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth )
estadd local operator "NO"
estadd local optime "YES"
eststo: quietly reghdfe ln_ogprod_byplay imi if inn_play==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth )
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ln_ogprod_byplay imi if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth )
estadd local operator "NO"
estadd local optime "YES"
eststo: quietly reghdfe ln_ogprod_byplay imi if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth )
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ln_ogprod_byplay imi if inn_play==0 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth )
estadd local operator "NO"
estadd local optime "YES"
eststo: quietly reghdfe ln_ogprod_byplay imi if inn_play==0 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth )
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) 


*********************************
***Table 2: Summary statistics***
*********************************
clear
import delimited "C:\Users\anson\Dropbox\Dissertation\Fracfocus\FracFocusCSV\final_data\fracfocus_welllevel.csv", encoding(ISO-8859-2) 

encode play, gen(nplay)
encode operatorname, gen(nop)
gen yearmonth=ym(year, month)
format yearmonth %tm

gen watch = 1 if watch_river_base==1 | watch_well==1 | watch_shalenet==1
replace  watch = 0 if missing(watch )
vl create cv = (log_wellcount_byplay log_cumsum_byplay opexp_byplay ln_ogprod_byplay)

*Panel A: Descriptive statistics
eststo clear
eststo full: quietly   estpost tabstat ts_percasall ts_percasuq hfper_ts_snw inn_play watch watch_river_base watch_well watch_shalenet $cv disc_strict budget_high urban tort_post, c(stat) stats(n mean p10 p25 p50 p75 p90 sd)
eststo noinno: quietly estpost tabstat ts_percasall ts_percasuq hfper_ts_snw inn_play watch watch_river_base watch_well watch_shalenet $cv disc_strict budget_high urban tort_post if public==1, c(stat) stats(n mean p50 sd)
eststo inno: quietly   estpost tabstat ts_percasall ts_percasuq hfper_ts_snw inn_play watch watch_river_base watch_well watch_shalenet $cv disc_strict budget_high urban tort_post if public==0, c(stat) stats(n mean p50 sd)
esttab full noinno inno, cells("n(pattern(1 1 1)) mean(pattern(1 1 1) fmt(3)) p10(pattern(1 0 0) fmt(3)) p25(pattern(1 0 0) fmt(3)) p50(pattern(1 1 1) fmt(3)) p75(pattern(1 0 0) fmt(3)) p90(pattern(1 0 0) fmt(3)) sd(pattern(1 1 1) fmt(3))")  rename(inn_play "INNOVATIVE")

*Panel B: Withholding rate by subgroup (full sample)
eststo clear
eststo noninn_watch: quietly   estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==0 & watch==1, c(stat) stats(n mean p50 sd)
eststo noninn_unwatch: quietly estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==0 & watch==0, c(stat) stats(n mean p50 sd)
eststo inn_watch: quietly      estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==1 & watch==1, c(stat) stats(n mean p50 sd)
eststo inn_unwatch: quietly    estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==1 & watch==0, c(stat) stats(n mean p50 sd)
esttab noninn_watch noninn_unwatch inn_watch inn_unwatch , cells("n(pattern(1 1 1)) mean(pattern(1 1 1) fmt(3))   p50(pattern(1 1 1) fmt(3))  sd(pattern(1 1 1) fmt(3))")  rename(exp_alltime_subplay "INNOVATIVE")

ttest ts_percasall if inn_play==0, by(watch)
ttest ts_percasuq  if inn_play==0, by(watch)
ttest hfper_ts_snw if inn_play==0, by(watch)
ttest ts_percasall if inn_play==1, by(watch)
ttest ts_percasuq  if inn_play==1, by(watch)
ttest hfper_ts_snw if inn_play==1, by(watch)

*Panel C: Withholding rate by subgroup (public sample)
eststo clear
eststo noninn_watch: quietly   estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==0 & watch==1 & public==1, c(stat) stats(n mean p50 sd)
eststo noninn_unwatch: quietly estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==0 & watch==0 & public==1, c(stat) stats(n mean p50 sd)
eststo inn_watch: quietly      estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==1 & watch==1 & public==1, c(stat) stats(n mean p50 sd)
eststo inn_unwatch: quietly    estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==1 & watch==0 & public==1, c(stat) stats(n mean p50 sd)
esttab noninn_watch noninn_unwatch inn_watch inn_unwatch , cells("n(pattern(1 1 1)) mean(pattern(1 1 1) fmt(3))   p50(pattern(1 1 1) fmt(3))  sd(pattern(1 1 1) fmt(3))")  rename(exp_alltime_subplay "INNOVATIVE")

ttest ts_percasall if inn_play==0 & public==1, by(watch)
ttest ts_percasuq  if inn_play==0 & public==1, by(watch)
ttest hfper_ts_snw if inn_play==0 & public==1, by(watch)
ttest ts_percasall if inn_play==1 & public==1, by(watch)
ttest ts_percasuq  if inn_play==1 & public==1, by(watch)
ttest hfper_ts_snw if inn_play==1 & public==1, by(watch)

*Panel D: Withholding rate by subgroup (private sample)
eststo clear
eststo noninn_watch: quietly   estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==0 & watch==1 & public==0, c(stat) stats(n mean p50 sd)
eststo noninn_unwatch: quietly estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==0 & watch==0 & public==0, c(stat) stats(n mean p50 sd)
eststo inn_watch: quietly      estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==1 & watch==1 & public==0, c(stat) stats(n mean p50 sd)
eststo inn_unwatch: quietly    estpost tabstat ts_percasall ts_percasuq hfper_ts_snw if inn_play==1 & watch==0 & public==0, c(stat) stats(n mean p50 sd)
esttab noninn_watch noninn_unwatch inn_watch inn_unwatch , cells("n(pattern(1 1 1)) mean(pattern(1 1 1) fmt(3))   p50(pattern(1 1 1) fmt(3))  sd(pattern(1 1 1) fmt(3))")  rename(exp_alltime_subplay "INNOVATIVE")

ttest ts_percasall if inn_play==0 & public==0, by(watch)
ttest ts_percasuq  if inn_play==0 & public==0, by(watch)
ttest hfper_ts_snw if inn_play==0 & public==0, by(watch)
ttest ts_percasall if inn_play==1 & public==0, by(watch)
ttest ts_percasuq  if inn_play==1 & public==0, by(watch)
ttest hfper_ts_snw if inn_play==1 & public==0, by(watch)


**********************************************************************
***Online Appendix Table C.4: Evidence of opportunistic withholding***
**********************************************************************
*Panel A: Non-innovative full sample
eststo clear 
eststo: quietly reghdfe ts_percasall watch public if inn_play==0, noabsorb vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch public if inn_play==0, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch public if inn_play==0, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch public $cv if inn_play==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch public $cv if inn_play==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch public $cv if inn_play==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch public $cv if inn_play==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch public $cv if inn_play==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch public $cv if inn_play==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) 

*Panel B: Innovative full sample
eststo clear 
eststo: quietly reghdfe ts_percasall watch public if inn_play==1, noabsorb vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch public if inn_play==1, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch public if inn_play==1, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch public $cv if inn_play==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch public $cv if inn_play==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch public $cv if inn_play==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch public $cv if inn_play==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch public $cv if inn_play==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch public $cv if inn_play==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) 

*Panel C: Non-innovative public sample
eststo clear 
eststo: quietly reghdfe ts_percasall watch if inn_play==0 & public==1, noabsorb vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch if inn_play==0 & public==1, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch if inn_play==0 & public==1, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) 

*Panel D: Innovative public sample
eststo clear 
eststo: quietly reghdfe ts_percasall watch if inn_play==1 & public==1, noabsorb vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch if inn_play==1 & public==1, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch if inn_play==1 & public==1, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) 

*Panel E: Non-innovative private sample
eststo clear 
eststo: quietly reghdfe ts_percasall watch if inn_play==0 & public==0, noabsorb vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch if inn_play==0 & public==0, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch if inn_play==0 & public==0, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==0 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==0 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==0 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==0 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==0 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==0 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) 

*Panel F: Innovative private sample
eststo clear 
eststo: quietly reghdfe ts_percasall watch if inn_play==1 & public==0, noabsorb vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch if inn_play==1 & public==0, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch if inn_play==1 & public==0, noabsorb vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==1 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==1 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==1 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==1 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==1 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==1 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop(_cons) cells(b(star fmt(3)) se(par fmt(3))) 


*****************************************************
***Figure 3: Evidence of opportunistic withholding***
*****************************************************
gen w1m1 = watch
gen w1m2 = watch
gen w1m3 = watch
gen w2m1 = watch
gen w2m2 = watch
gen w2m3 = watch
gen w3m1 = watch
gen w3m2 = watch
gen w3m3 = watch

*Panel A: Noninnovative sample
quietly reghdfe ts_percasall w1m1 public if inn_play==0, noabsorb vce(cluster nplay yearmonth) 
estimates store tsper_full_m1
quietly reghdfe ts_percasuq w1m1 public if inn_play==0, noabsorb vce(cluster nplay yearmonth)
estimates store tsuq_full_m1
quietly reghdfe hfper_ts_snw w1m1 public if inn_play==0, noabsorb vce(cluster nplay yearmonth)
estimates store hf_full_m1
quietly reghdfe ts_percasall w1m2 public $cv if inn_play==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_full_m2
quietly reghdfe ts_percasuq w1m2 public $cv if inn_play==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_full_m2
quietly reghdfe hfper_ts_snw w1m2 public $cv if inn_play==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_full_m2
quietly reghdfe ts_percasall w1m3 public $cv if inn_play==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_full_m3
quietly reghdfe ts_percasuq w1m3 public $cv if inn_play==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_full_m3
quietly reghdfe hfper_ts_snw w1m3 public $cv if inn_play==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_full_m3

quietly reghdfe ts_percasall w2m1 if inn_play==0 & public==1, noabsorb vce(cluster nplay yearmonth) 
estimates store tsper_pub_m1
quietly reghdfe ts_percasuq w2m1 if inn_play==0 & public==1, noabsorb vce(cluster nplay yearmonth)
estimates store tsuq_pub_m1
quietly reghdfe hfper_ts_snw w2m1 if inn_play==0 & public==1, noabsorb vce(cluster nplay yearmonth)
estimates store hf_pub_m1
quietly reghdfe ts_percasall w2m2 $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_pub_m2
quietly reghdfe ts_percasuq w2m2 $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_pub_m2
quietly reghdfe hfper_ts_snw w2m2 $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_pub_m2
quietly reghdfe ts_percasall w2m3 $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_pub_m3
quietly reghdfe ts_percasuq w2m3 $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_pub_m3
quietly reghdfe hfper_ts_snw w2m3 $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_pub_m3

quietly reghdfe ts_percasall w3m1  if inn_play==0 & public==0, noabsorb vce(cluster nplay yearmonth) 
estimates store tsper_pri_m1
quietly reghdfe ts_percasuq w3m1 if inn_play==0 & public==0, noabsorb vce(cluster nplay yearmonth)
estimates store tsuq_pri_m1
quietly reghdfe hfper_ts_snw w3m1 if inn_play==0 & public==0, noabsorb vce(cluster nplay yearmonth)
estimates store hf_pri_m1
quietly reghdfe ts_percasall w3m2 $cv if inn_play==0 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_pri_m2
quietly reghdfe ts_percasuq w3m2 $cv if inn_play==0 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_pri_m2
quietly reghdfe hfper_ts_snw w3m2 $cv if inn_play==0 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_pri_m2
quietly reghdfe ts_percasall w3m3 $cv if inn_play==0 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_pri_m3
quietly reghdfe ts_percasuq w3m3 $cv if inn_play==0 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_pri_m3
quietly reghdfe hfper_ts_snw w3m3 $cv if inn_play==0 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_pri_m3

coefplot (tsper_full_m1, pstyle(p1) msymbol(D) label(TS_per)) (tsper_full_m2, pstyle(p1) msymbol(S) label(TS_per)) (tsper_full_m3, pstyle(p1) label(TS_per)) (tsper_pub_m1, pstyle(p2) msymbol(D) label(TS_per)) (tsper_pub_m2, pstyle(p2) msymbol(S) label(TS_per)) (tsper_pub_m3, pstyle(p2) label(TS_per)) (tsper_pri_m1, pstyle(p3) msymbol(D) label(TS_per)) (tsper_pri_m2, pstyle(p3) msymbol(S) label(TS_per)) (tsper_pri_m3, pstyle(p3) label(TS_per)), bylabel(TS_per)  ///
 || (tsuq_full_m1, label(CAS_anony)) (tsuq_full_m2, label(CAS_anony)) (tsuq_full_m3, label(CAS_anony)) (tsuq_pub_m1, label(CAS_anony)) (tsuq_pub_m2, label(CAS_anony)) (tsuq_pub_m3, label( CAS_anony)) (tsuq_pri_m1, label(CAS_anony)) (tsuq_pri_m2, label(CAS_anony)) (tsuq_pri_m3, label(CAS_anony)), bylabel(CAS_anony)  ///
 || (hf_full_m1, label(TS_conc)) (hf_full_m2, label(TS_conc)) (hf_full_m3, label(TS_conc)) (hf_pub_m1, label(TS_conc)) (hf_pub_m2, label(TS_conc)) (hf_pub_m3, label(TS_conc)) (hf_pri_m1, label(TS_conc)) (hf_pri_m2, label(TS_conc)) (hf_pri_m3, label(TS_conc)), bylabel(TS_conc)  ///
subtitle(, bcolor(white)) ///
groups(w1* = "{bf:Full sample}" w2* = "{bf:Pulic sample}"  w3* = "{bf:Private sample}", labsize(med)) ///
drop(public $cv _cons) xline(0) msize(medlarge) mfcolor(white) level(95) ciopts(lwidth(*2)) byopts(legend(off) xrescale rows(1) graphregion(color(white)) bgcol(white)) xsize(10) ylabel(,labsize(med)) xlabel(,labsize(med))  
 
*Panel B: Innovative sample
quietly reghdfe ts_percasall w1m1 public if inn_play==1, noabsorb vce(cluster nplay yearmonth) 
estimates store tsper_full_m1
quietly reghdfe ts_percasuq w1m1 public if inn_play==1, noabsorb vce(cluster nplay yearmonth)
estimates store tsuq_full_m1
quietly reghdfe hfper_ts_snw w1m1 public if inn_play==1, noabsorb vce(cluster nplay yearmonth)
estimates store hf_full_m1
quietly reghdfe ts_percasall w1m2 public $cv if inn_play==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_full_m2
quietly reghdfe ts_percasuq w1m2 public $cv if inn_play==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_full_m2
quietly reghdfe hfper_ts_snw w1m2 public $cv if inn_play==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_full_m2
quietly reghdfe ts_percasall w1m3 public $cv if inn_play==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_full_m3
quietly reghdfe ts_percasuq w1m3 public $cv if inn_play==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_full_m3
quietly reghdfe hfper_ts_snw w1m3 public $cv if inn_play==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_full_m3

quietly reghdfe ts_percasall w2m1 if inn_play==1 & public==1, noabsorb vce(cluster nplay yearmonth) 
estimates store tsper_pub_m1
quietly reghdfe ts_percasuq w2m1 if inn_play==1 & public==1, noabsorb vce(cluster nplay yearmonth)
estimates store tsuq_pub_m1
quietly reghdfe hfper_ts_snw w2m1 if inn_play==1 & public==1, noabsorb vce(cluster nplay yearmonth)
estimates store hf_pub_m1
quietly reghdfe ts_percasall w2m2 $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_pub_m2
quietly reghdfe ts_percasuq w2m2 $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_pub_m2
quietly reghdfe hfper_ts_snw w2m2 $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_pub_m2
quietly reghdfe ts_percasall w2m3 $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_pub_m3
quietly reghdfe ts_percasuq w2m3 $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_pub_m3
quietly reghdfe hfper_ts_snw w2m3 $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_pub_m3

quietly reghdfe ts_percasall w3m1  if inn_play==1 & public==0, noabsorb vce(cluster nplay yearmonth) 
estimates store tsper_pri_m1
quietly reghdfe ts_percasuq w3m1 if inn_play==1 & public==0, noabsorb vce(cluster nplay yearmonth)
estimates store tsuq_pri_m1
quietly reghdfe hfper_ts_snw w3m1 if inn_play==1 & public==0, noabsorb vce(cluster nplay yearmonth)
estimates store hf_pri_m1
quietly reghdfe ts_percasall w3m2 $cv if inn_play==1 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_pri_m2
quietly reghdfe ts_percasuq w3m2 $cv if inn_play==1 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_pri_m2
quietly reghdfe hfper_ts_snw w3m2 $cv if inn_play==1 & public==0, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_pri_m2
quietly reghdfe ts_percasall w3m3 $cv if inn_play==1 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estimates store tsper_pri_m3
quietly reghdfe ts_percasuq w3m3 $cv if inn_play==1 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_pri_m3
quietly reghdfe hfper_ts_snw w3m3 $cv if inn_play==1 & public==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_pri_m3

coefplot (tsper_full_m1, pstyle(p1) msymbol(D) label(TS_per)) (tsper_full_m2, pstyle(p1) msymbol(S) label(TS_per)) (tsper_full_m3, pstyle(p1) label(TS_per)) (tsper_pub_m1, pstyle(p2) msymbol(D) label(TS_per)) (tsper_pub_m2, pstyle(p2) msymbol(S) label(TS_per)) (tsper_pub_m3, pstyle(p2) label(TS_per)) (tsper_pri_m1, pstyle(p3) msymbol(D) label(TS_per)) (tsper_pri_m2, pstyle(p3) msymbol(S) label(TS_per)) (tsper_pri_m3, pstyle(p3) label(TS_per)), bylabel(TS_per)  ///
 || (tsuq_full_m1, label(CAS_anony)) (tsuq_full_m2, label(CAS_anony)) (tsuq_full_m3, label(CAS_anony)) (tsuq_pub_m1, label(CAS_anony)) (tsuq_pub_m2, label(CAS_anony)) (tsuq_pub_m3, label( CAS_anony)) (tsuq_pri_m1, label(CAS_anony)) (tsuq_pri_m2, label(CAS_anony)) (tsuq_pri_m3, label(CAS_anony)), bylabel(CAS_anony)  ///
 || (hf_full_m1, label(TS_conc)) (hf_full_m2, label(TS_conc)) (hf_full_m3, label(TS_conc)) (hf_pub_m1, label(TS_conc)) (hf_pub_m2, label(TS_conc)) (hf_pub_m3, label(TS_conc)) (hf_pri_m1, label(TS_conc)) (hf_pri_m2, label(TS_conc)) (hf_pri_m3, label(TS_conc)), bylabel(TS_conc)  ///
subtitle(, bcolor(white)) ///
groups(w1* = "{bf:Full sample}" w2* = "{bf:Pulic sample}"  w3* = "{bf:Private sample}", labsize(med)) ///
drop(public $cv _cons) xline(0) msize(medlarge) mfcolor(white) level(95) ciopts(lwidth(*2)) byopts(legend(off) xrescale rows(1) graphregion(color(white)) bgcol(white)) xsize(10) ylabel(,labsize(med)) xlabel(,labsize(med))  


*******************************************************************
***Online Appendix Table C.5: Withholding result by monitor type***
*******************************************************************
*Panel A: Non-innovative public sample (without operator FE)
eststo clear 
eststo: quietly reghdfe ts_percasall watch_river_base $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasall watch_well $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasuq watch_well $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe hfper_ts_snw watch_well $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasall watch_shalenet $cv if inn_play==0 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq watch_shalenet $cv if inn_play==0 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw watch_shalenet $cv if inn_play==0 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) order(watch_river_base watch_well watch_shalenet) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "time Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel B: Non-innovative public sample (with operator FE)
eststo clear 
eststo: quietly reghdfe ts_percasall watch_river_base $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasall watch_well $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasuq watch_well $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe hfper_ts_snw watch_well $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasall watch_shalenet $cv if inn_play==0 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq watch_shalenet $cv if inn_play==0 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw watch_shalenet $cv if inn_play==0 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) order(watch_river_base watch_well watch_shalenet) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "time Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel C: Innovative public sample (without operator FE)
eststo clear 
eststo: quietly reghdfe ts_percasall watch_river_base $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasall watch_well $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasuq watch_well $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe hfper_ts_snw watch_well $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasall watch_shalenet $cv if inn_play==1 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq watch_shalenet $cv if inn_play==1 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw watch_shalenet $cv if inn_play==1 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) order(watch_river_base watch_well watch_shalenet) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "time Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel D: Innovative public sample (with operator FE)
eststo clear 
eststo: quietly reghdfe ts_percasall watch_river_base $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasall watch_well $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasuq watch_well $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe hfper_ts_snw watch_well $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "YES"
estadd local time "NO"
eststo: quietly reghdfe ts_percasall watch_shalenet $cv if inn_play==1 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq watch_shalenet $cv if inn_play==1 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw watch_shalenet $cv if inn_play==1 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "NO"
estadd local optime "NO"
estadd local time "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) order(watch_river_base watch_well watch_shalenet) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "time Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))


**************************************************
***Figure 4: Withholding result by monitor type***
**************************************************
gen riverm2 = watch_river_base
gen riverm3 = watch_river_base
gen wellm2 = watch_well
gen wellm3 = watch_well
gen shalem2 = watch_shalenet
gen shalem3 = watch_shalenet

*Panel A: Noninnovative public sample
quietly reghdfe ts_percasall riverm2 $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_river_no
quietly reghdfe ts_percasuq riverm2 $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_river_no
quietly reghdfe hfper_ts_snw riverm2 $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_river_no
quietly reghdfe ts_percasall wellm2 $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_well_no
quietly reghdfe ts_percasuq wellm2 $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_well_no
quietly reghdfe hfper_ts_snw wellm2 $cv if inn_play==0 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_well_no
quietly reghdfe ts_percasall shalem2 $cv if inn_play==0 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_shale_no
quietly reghdfe ts_percasuq shalem2 $cv if inn_play==0 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_shale_no
quietly reghdfe hfper_ts_snw shalem2 $cv if inn_play==0 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estimates store hf_shale_no

quietly reghdfe ts_percasall riverm3  $cv  if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_river_op
quietly reghdfe ts_percasuq riverm3  $cv  if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_river_op
quietly reghdfe hfper_ts_snw riverm3 $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_river_op
quietly reghdfe ts_percasall wellm3 $cv  if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_well_op
quietly reghdfe ts_percasuq wellm3 $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_well_op
quietly reghdfe hfper_ts_snw wellm3 $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_well_op
quietly reghdfe ts_percasall shalem3 $cv if inn_play==0 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_shale_op
quietly reghdfe ts_percasuq shalem3 $cv  if inn_play==0 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_shale_op
quietly reghdfe hfper_ts_snw shalem3 $cv if inn_play==0 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store hf_shale_op

coefplot (tsperc_river_no, pstyle(p2) msymbol(S) label(TS_per)) (tsperc_river_op, pstyle(p2) msymbol(O) label(TS_per)) (tsperc_well_no, pstyle(p3) msymbol(S) label(TS_per)) (tsperc_well_op, pstyle(p3) msymbol(O) label(TS_per)) (tsperc_shale_no, pstyle(p6) msymbol(S) label(TS_per)) (tsperc_shale_op, pstyle(p6) msymbol(O) label(TS_per)), bylabel(TS_per) ///
|| (tsuq_river_no, pstyle(p2) msymbol(S) label(CAS_anony)) (tsuq_river_op, pstyle(p2) msymbol(O) label(CAS_anony)) (tsuq_well_no, pstyle(p3) msymbol(S) label(CAS_anony)) (tsuq_well_op, pstyle(p3) msymbol(O) label(CAS_anony)) (tsuq_shale_no, pstyle(p6) msymbol(S) label(CAS_anony)) (tsuq_shale_op,pstyle(p6) msymbol(O) label( CAS_anony)), bylabel(CAS_anony) ///
|| (hf_river_no, pstyle(p2) msymbol(S) label(TS_conc)) (hf_river_op, pstyle(p2) msymbol(O) label(TS_conc)) (hf_well_no, pstyle(p3) msymbol(S) label(TS_conc)) (hf_well_op, pstyle(p3) msymbol(O) label(TS_conc)) (hf_shale_no, pstyle(p6) msymbol(S) label(TS_conc)) (hf_shale_op, pstyle(p6) msymbol(O) label(TS_conc)), bylabel(TS_conc) ///
rename(watch_river_base = "WATCH_river"  watch_well = "WATCH_well" watch_shalenet = "WATCH_shalenet") ///
subtitle(, bcolor(white)) ///
groups(river* = ""  well* = ""  shale* = "") ///
drop($cv _cons) xline(0) msize(medlarge) mfcolor(white) byopts(legend(off) xrescale rows(1)  graphregion(color(white)) bgcol(white)) xsize(10) ciopts(lwidth( *2)) ylabel(,labsize(med)) xlabel(,labsize(medium))  

*Panel B: Innovative public sample
quietly reghdfe ts_percasall riverm2 $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_river_no
quietly reghdfe ts_percasuq riverm2 $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_river_no
quietly reghdfe hfper_ts_snw riverm2 $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_river_no
quietly reghdfe ts_percasall wellm2 $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_well_no
quietly reghdfe ts_percasuq wellm2 $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_well_no
quietly reghdfe hfper_ts_snw wellm2 $cv if inn_play==1 & public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_well_no
quietly reghdfe ts_percasall shalem2 $cv if inn_play==1 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_shale_no
quietly reghdfe ts_percasuq shalem2 $cv if inn_play==1 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_shale_no
quietly reghdfe hfper_ts_snw shalem2 $cv if inn_play==1 & public==1, absorb(yearmonth) vce(cluster nplay yearmonth)
estimates store hf_shale_no

quietly reghdfe ts_percasall riverm3 $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_river_op
quietly reghdfe ts_percasuq riverm3 $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_river_op
quietly reghdfe hfper_ts_snw riverm3 $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_river_op
quietly reghdfe ts_percasall wellm3 $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_well_op
quietly reghdfe ts_percasuq wellm3 $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_well_op
quietly reghdfe hfper_ts_snw wellm3 $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_well_op
quietly reghdfe ts_percasall shalem3 $cv if inn_play==1 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_shale_op
quietly reghdfe ts_percasuq shalem3 $cv if inn_play==1 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_shale_op
quietly reghdfe hfper_ts_snw shalem3 $cv if inn_play==1 & public==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store hf_shale_op

coefplot (tsperc_river_no, pstyle(p2) msymbol(S) label(TS_per)) (tsperc_river_op, pstyle(p2) msymbol(O) label(TS_per)) (tsperc_well_no, pstyle(p3) msymbol(S) label(TS_per)) (tsperc_well_op, pstyle(p3) msymbol(O) label(TS_per)) (tsperc_shale_no, pstyle(p6) msymbol(S) label(TS_per)) (tsperc_shale_op, pstyle(p6) msymbol(O) label(TS_per)), bylabel(TS_per) ///
|| (tsuq_river_no, pstyle(p2) msymbol(S) label(CAS_anony)) (tsuq_river_op, pstyle(p2) msymbol(O) label(CAS_anony)) (tsuq_well_no, pstyle(p3) msymbol(S) label(CAS_anony)) (tsuq_well_op, pstyle(p3) msymbol(O) label(CAS_anony)) (tsuq_shale_no, pstyle(p6) msymbol(S) label(CAS_anony)) (tsuq_shale_op,pstyle(p6) msymbol(O) label( CAS_anony)), bylabel(CAS_anony) ///
|| (hf_river_no, pstyle(p2) msymbol(S) label(TS_conc)) (hf_river_op, pstyle(p2) msymbol(O) label(TS_conc)) (hf_well_no, pstyle(p3) msymbol(S) label(TS_conc)) (hf_well_op, pstyle(p3) msymbol(O) label(TS_conc)) (hf_shale_no, pstyle(p6) msymbol(S) label(TS_conc)) (hf_shale_op, pstyle(p6) msymbol(O) label(TS_conc)), bylabel(TS_conc) ///
rename(watch_river_base = "WATCH_river"  watch_well = "WATCH_well" watch_shalenet = "WATCH_shalenet") ///
subtitle(, bcolor(white)) ///
groups(river* = ""  well* = ""  shale* = "") ///
drop($cv _cons) xline(0) msize(medlarge) mfcolor(white) byopts(legend(off) xrescale rows(1)  graphregion(color(white)) bgcol(white)) xsize(10) ciopts(lwidth( *2)) ylabel(,labsize(med)) xlabel(,labsize(medium))  


*******************************************************************************************************
***Online Appendix Table C.6A: Corroborating evidence: Distance between monitors and operating sites***
*******************************************************************************************************
*Panel A: Distance between river/stream monitors and the non-innovative public sample
eststo clear 
eststo: quietly reghdfe ts_percasall watch_river_base $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch_river_5km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch_river_10km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_river_5km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_river_10km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_river_5km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_river_10km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) order(watch_river_base watch_river_5km watch_river_10km) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel B: Distance between river/stream monitors and the innovative public sample
eststo clear 
eststo: quietly reghdfe ts_percasall watch_river_base $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch_river_5km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch_river_10km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_river_5km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_river_10km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_river_5km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_river_10km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) order(watch_river_base watch_river_5km watch_river_10km) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))



**************************************************************************************
***Figure 5: Corroborating evidence - Distance between monitors and operating sites***
************************************************************************************** 
*Panel A: Noninnovative public sample
quietly reghdfe ts_percasall watch_river_base $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_river_2km
quietly reghdfe ts_percasall watch_river_5km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_river_5km
quietly reghdfe ts_percasall watch_river_10km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_river_10km

quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_river_2km
quietly reghdfe ts_percasuq watch_river_5km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_river_5km
quietly reghdfe ts_percasuq watch_river_10km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_river_10km

quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_river_2km
quietly reghdfe hfper_ts_snw watch_river_5km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_river_5km
quietly reghdfe hfper_ts_snw watch_river_10km $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_river_10km

coefplot (tsperc_non_river_2km, pstyle(p2) msymbol(O) label(TS_per)) (tsperc_non_river_5km, pstyle(p2) msymbol(O) label(TS_per)) (tsperc_non_river_10km, pstyle(p2) msymbol(O) label(TS_per)), bylabel(TS_per) ///
|| (tsuq_non_river_2km, pstyle(p2) msymbol(O) label(CAS_anony)) (tsuq_non_river_5km, pstyle(p2) msymbol(O) label(CAS_anony)) (tsuq_non_river_10km, pstyle(p2) msymbol(O) label( CAS_anony)), bylabel(CAS_anony) ///
|| (hf_non_river_2km, pstyle(p2) msymbol(O) label(TS_conc)) (hf_non_river_5km, pstyle(p2) msymbol(O) label(TS_conc)) (hf_non_river_10km, pstyle(p2) msymbol(O) label( TS_conc)), bylabel(TS_conc) ///
rename(watch_river_base = "WATCH_river(0-2.5km)"  watch_river_5km = "WATCH_river(0-5km)"  watch_river_10km = "WATCH_river(0-10km)") ///
subtitle(, bcolor(white)) ///
groups(WATCH_river* = ""   ) ///
drop($cv _cons) xline(0) msize(medlarge) mfcolor(white) byopts(legend(off) xrescale rows(1) graphregion(color(white)) bgcol(white)) xsize(10) ciopts(lwidth( *2)) ylabel(,labsize(med)) xlabel(,labsize(medium))  

*Panel B: Innovative public sample
quietly reghdfe ts_percasall watch_river_base $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_river_2km
quietly reghdfe ts_percasall watch_river_5km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_river_5km
quietly reghdfe ts_percasall watch_river_10km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_river_10km

quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_river_2km
quietly reghdfe ts_percasuq watch_river_5km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_river_5km
quietly reghdfe ts_percasuq watch_river_10km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_river_10km

quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_river_2km
quietly reghdfe hfper_ts_snw watch_river_5km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_river_5km
quietly reghdfe hfper_ts_snw watch_river_10km $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_river_10km

coefplot (tsperc_non_river_2km, pstyle(p2) msymbol(O) label(TS_per)) (tsperc_non_river_5km, pstyle(p2) msymbol(O) label(TS_per)) (tsperc_non_river_10km, pstyle(p2) msymbol(O) label(TS_per)), bylabel(TS_per) ///
|| (tsuq_non_river_2km, pstyle(p2) msymbol(O) label(CAS_anony)) (tsuq_non_river_5km, pstyle(p2) msymbol(O) label(CAS_anony)) (tsuq_non_river_10km, pstyle(p2) msymbol(O) label(CAS_anony)), bylabel(CAS_anony) ///
|| (hf_non_river_2km, pstyle(p2) msymbol(O) label(TS_conc)) (hf_non_river_5km, pstyle(p2) msymbol(O) label(TS_conc)) (hf_non_river_10km, pstyle(p2) msymbol(O) label(TS_conc)), bylabel(TS_conc) ///
rename(watch_river_base = "WATCH_river(0-2.5km)"  watch_river_5km = "WATCH_river(0-5km)"  watch_river_10km = "WATCH_river(0-10km)") ///
subtitle(, bcolor(white)) ///
groups(WATCH_river* = ""  ) ///
drop($cv _cons) xline(0) msize(medlarge) mfcolor(white) byopts(legend(off) xrescale rows(1) graphregion(color(white)) bgcol(white)) xsize(10) ciopts(lwidth( *2)) ylabel(,labsize(med)) xlabel(,labsize(medium))  


*********************************************************************************
***Online Appendix Table C.6B: Corroborating evidence: Rainy and snowy seasons***
*********************************************************************************
*Panel A: All monitors
eststo clear 
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel B: River/stream monitors
eststo clear 
eststo: quietly reghdfe ts_percasall watch_river_base $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch_river_base $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch_river_base $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch_river_base $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_river_base $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_river_base $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel C: Well monitors
eststo clear 
eststo: quietly reghdfe ts_percasall watch_well $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_well $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_well $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch_well $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_well $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_well $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch_well $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_well $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_well $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch_well $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch_well $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch_well $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel D: Shale network monitors
eststo clear 
eststo: quietly reghdfe ts_percasall watch_shalenet $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq watch_shalenet $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw watch_shalenet $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasall watch_shalenet $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq watch_shalenet $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw watch_shalenet $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasall watch_shalenet $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq watch_shalenet $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw watch_shalenet $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasall watch_shalenet $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq watch_shalenet $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw watch_shalenet $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local time "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "time Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))


****************************************************************
***Figure 6: Corroborating evidence - Rainy and snowy seasons***
****************************************************************
gen dry_watch = watch
gen dry_river = watch_river_base
gen dry_well = watch_well
gen dry_shale = watch_shalenet 
gen wet_watch = watch
gen wet_river = watch_river_base
gen wet_well = watch_well
gen wet_shale = watch_shalenet

*Panel A: Noninnovative public sample
quietly reghdfe ts_percasall dry_watch $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_watch_dry
quietly reghdfe ts_percasall dry_river $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_river_dry
quietly reghdfe ts_percasall dry_well $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_well_dry
quietly reghdfe ts_percasall dry_shale $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_shale_dry

quietly reghdfe ts_percasuq dry_watch $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_watch_dry
quietly reghdfe ts_percasuq dry_river $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_river_dry
quietly reghdfe ts_percasuq dry_well $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_well_dry
quietly reghdfe ts_percasuq dry_shale $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_shale_dry

quietly reghdfe hfper_ts_snw dry_watch $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_watch_dry
quietly reghdfe hfper_ts_snw dry_river $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_river_dry
quietly reghdfe hfper_ts_snw dry_well $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_well_dry
quietly reghdfe hfper_ts_snw dry_shale $cv if inn_play==0 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_shale_dry

quietly reghdfe ts_percasall wet_watch $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_watch_wet
quietly reghdfe ts_percasall wet_river $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_river_wet
quietly reghdfe ts_percasall wet_well $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_well_wet
quietly reghdfe ts_percasall wet_shale $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_shale_wet

quietly reghdfe ts_percasuq wet_watch $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_watch_wet
quietly reghdfe  ts_percasuq wet_river $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_river_wet
quietly reghdfe ts_percasuq wet_well $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_well_wet
quietly reghdfe  ts_percasuq wet_shale $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_shale_wet

quietly reghdfe hfper_ts_snw wet_watch $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_watch_wet
quietly reghdfe  hfper_ts_snw wet_river $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_river_wet
quietly reghdfe hfper_ts_snw wet_well $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_well_wet
quietly reghdfe  hfper_ts_snw wet_shale $cv if inn_play==0 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_shale_wet

coefplot (tsperc_non_watch_dry, pstyle(p1) label(TS_per)) (tsperc_non_river_dry,pstyle(p2) label(TS_per)) (tsperc_non_well_dry, pstyle(p3) label( TS_per)) (tsperc_non_shale_dry, pstyle(p6) label(TS_per)) (tsperc_non_watch_wet, pstyle(p1) label(TS_per)) (tsperc_non_river_wet, pstyle(p2) label(TS_per)) (tsperc_non_well_wet, pstyle(p3) label(TS_per)) (tsperc_non_shale_wet, pstyle(p6) label(TS_per)), bylabel(TS_per) ///
|| (tsuq_non_watch_dry, pstyle(p1) label(CAS_anony)) (tsuq_non_river_dry,pstyle(p2) label(CAS_anony)) (tsuq_non_well_dry, pstyle(p3) label(CAS_anony)) (tsuq_non_shale_dry, pstyle(p6)  label(CAS_anony)) (tsuq_non_watch_wet, pstyle(p1) label(CAS_anony)) (tsuq_non_river_wet, pstyle(p2) label(CAS_anony)) (tsuq_non_well_wet, pstyle(p3) label(CAS_anony)) (tsuq_non_shale_wet, pstyle(p6) label(CAS_anony)), bylabel(CAS_anony) ///
|| (hf_non_watch_dry, pstyle(p1) label(TS_conc)) (hf_non_river_dry, pstyle(p2) label(TS_conc)) (hf_non_well_dry, pstyle(p3) label(TS_conc)) (hf_non_shale_dry, pstyle(p6) label(TS_conc)) (hf_non_watch_wet, pstyle(p1) label(TS_conc)) (hf_non_river_wet, pstyle(p2) label(TS_conc)) (hf_non_well_wet, pstyle(p3) label(TS_conc)) (hf_non_shale_wet, pstyle(p6) label(TS_conc)), bylabel(TS_conc) ///
subtitle(, bcolor(white)) ///
groups(dry_* = "{bf:Dry season}"  wet_* = "{bf:Wet season}" ,labsize(med)) ///
drop($cv _cons) xline(0) msize(medlarge) msymbol(O) mfcolor(white) byopts(legend(off) xrescale rows(1) graphregion(color(white)) bgcol(white)) xsize(10) ciopts(lwidth( *2)) ylabel(,labsize(med)) xlabel(,labsize(medium))  

*Panel B: Innovative public sample
quietly reghdfe ts_percasall dry_watch $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_watch_dry
quietly reghdfe ts_percasall dry_river $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_river_dry
quietly reghdfe ts_percasall dry_well $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_well_dry
quietly reghdfe ts_percasall dry_shale $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_shale_dry

quietly reghdfe ts_percasuq dry_watch $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_watch_dry
quietly reghdfe ts_percasuq dry_river $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_river_dry
quietly reghdfe ts_percasuq dry_well $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_well_dry
quietly reghdfe ts_percasuq dry_shale $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_shale_dry

quietly reghdfe hfper_ts_snw dry_watch $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_watch_dry
quietly reghdfe hfper_ts_snw dry_river $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_river_dry
quietly reghdfe hfper_ts_snw dry_well $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_well_dry
quietly reghdfe hfper_ts_snw dry_shale $cv if inn_play==1 & public==1 & rainsnow==0, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_shale_dry

quietly reghdfe ts_percasall wet_watch $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_watch_wet
quietly reghdfe ts_percasall wet_river $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_river_wet
quietly reghdfe ts_percasall wet_well $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_well_wet
quietly reghdfe ts_percasall wet_shale $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsperc_non_shale_wet

quietly reghdfe ts_percasuq wet_watch $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_watch_wet
quietly reghdfe  ts_percasuq wet_river $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_river_wet
quietly reghdfe ts_percasuq wet_well $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_well_wet
quietly reghdfe  ts_percasuq wet_shale $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store tsuq_non_shale_wet

quietly reghdfe hfper_ts_snw wet_watch $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_watch_wet
quietly reghdfe  hfper_ts_snw wet_river $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_river_wet
quietly reghdfe hfper_ts_snw wet_well $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_well_wet
quietly reghdfe  hfper_ts_snw wet_shale $cv if inn_play==1 & public==1 & rainsnow==1, absorb(nop yearmonth) vce(cluster nplay yearmonth)
estimates store hf_non_shale_wet

coefplot (tsperc_non_watch_dry, pstyle(p1) label(TS_per)) (tsperc_non_river_dry,pstyle(p2) label(TS_per)) (tsperc_non_well_dry, pstyle(p3) label( TS_per)) (tsperc_non_shale_dry, pstyle(p6) label(TS_per)) (tsperc_non_watch_wet, pstyle(p1) label(TS_per)) (tsperc_non_river_wet, pstyle(p2) label(TS_per)) (tsperc_non_well_wet, pstyle(p3) label(TS_per)) (tsperc_non_shale_wet, pstyle(p6) label(TS_per)), bylabel(TS_per) ///
|| (tsuq_non_watch_dry, pstyle(p1) label(CAS_anony)) (tsuq_non_river_dry,pstyle(p2) label(CAS_anony)) (tsuq_non_well_dry, pstyle(p3) label(CAS_anony)) (tsuq_non_shale_dry, pstyle(p6)  label(CAS_anony)) (tsuq_non_watch_wet, pstyle(p1) label(CAS_anony)) (tsuq_non_river_wet, pstyle(p2) label(CAS_anony)) (tsuq_non_well_wet, pstyle(p3) label(CAS_anony)) (tsuq_non_shale_wet, pstyle(p6) label(CAS_anony)), bylabel(CAS_anony) ///
|| (hf_non_watch_dry, pstyle(p1) label(TS_conc)) (hf_non_river_dry, pstyle(p2) label(TS_conc)) (hf_non_well_dry, pstyle(p3) label(TS_conc)) (hf_non_shale_dry, pstyle(p6) label(TS_conc)) (hf_non_watch_wet, pstyle(p1) label(TS_conc)) (hf_non_river_wet, pstyle(p2) label(TS_conc)) (hf_non_well_wet, pstyle(p3) label(TS_conc)) (hf_non_shale_wet, pstyle(p6) label(TS_conc)), bylabel(TS_conc) ///
subtitle(, bcolor(white)) ///
groups(dry_* = "{bf:Dry season}"  wet_* = "{bf:Wet season}" ,labsize(med)) ///
drop($cv _cons) xline(0) msize(medlarge) msymbol(O) mfcolor(white) byopts(legend(off) xrescale rows(1) graphregion(color(white)) bgcol(white)) xsize(10) ciopts(lwidth( *2)) ylabel(,labsize(med)) xlabel(,labsize(medium))  


***************************************************************************
***Table 3: Cross-sectional results - Strictness of the disclosure rules***
***************************************************************************
eststo clear 
eststo: quietly reghdfe ts_percasall c.watch##c.disc_strict $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq c.watch##c.disc_strict $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw c.watch##c.disc_strict $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall c.watch##c.disc_strict $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq c.watch##c.disc_strict $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw c.watch##c.disc_strict $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))


***********************************************************************
***Table 4: Cross-sectional results - Regulator resource constraints***
***********************************************************************
eststo clear 
eststo: quietly reghdfe ts_percasall c.watch##c.budget_high $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq c.watch##c.budget_high $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw c.watch##c.budget_high $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall c.watch##c.budget_high $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq c.watch##c.budget_high $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw c.watch##c.budget_high $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))


**************************************************************
***Table 5: Cross-sectional results - Urban and rural wells***
**************************************************************
eststo clear 
eststo: quietly reghdfe ts_percasall c.watch##c.urban $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq c.watch##c.urban $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw c.watch##c.urban $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall c.watch##c.urban $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq c.watch##c.urban $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw c.watch##c.urban $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))


*****************************************************************************
***Table 6: Cross-sectional results - Tort litigation against HF operators***
*****************************************************************************
eststo clear 
eststo: quietly reghdfe ts_percasall c.watch##c.tort_post $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq c.watch##c.tort_post $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw c.watch##c.tort_post $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall c.watch##c.tort_post $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq c.watch##c.tort_post $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw c.watch##c.tort_post $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

 
******************************************************************************************************************************************
***Online Appendix Table C.8A: Proprietary cost results - Withholding difference between innovative and non-innovative public operators***
******************************************************************************************************************************************
eststo clear 
eststo: quietly reghdfe ts_percasall inn_play if public==1, noabsorb vce(cluster nplay yearmonth) 
estadd local control "NO" 
estadd local operator "NO"
estadd local optime "NO" 
eststo: quietly reghdfe ts_percasuq inn_play if public==1, noabsorb vce(cluster nplay yearmonth) 
estadd local control "NO" 
estadd local operator "NO"
estadd local optime "NO"
eststo: quietly reghdfe hfper_ts_snw inn_play if public==1, noabsorb vce(cluster nplay yearmonth) 
estadd local control "NO" 
estadd local operator "NO"
estadd local optime "NO"
eststo: quietly reghdfe ts_percasall inn_play $cv if public==1 , absorb(nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local control "YES" 
estadd local operator "NO"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq inn_play $cv if public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "NO"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw inn_play $cv if public==1, absorb(nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "NO"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall inn_play $cv if public==1 , absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth) 
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES" 
eststo: quietly reghdfe ts_percasuq inn_play $cv if public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw inn_play $cv if public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))


*******************************************************************************
***Online Appendix Table C.8B: Proprietary cost results by monitoring status***
*******************************************************************************
*Panel A: When public operators are watched by monitors
eststo clear 
eststo: quietly reghdfe ts_percasall inn_play $cv if watch==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
estadd local op "NO"
estadd local time "NO"
eststo: quietly reghdfe ts_percasuq  inn_play $cv if watch==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
estadd local op "NO"
estadd local time "NO"
eststo: quietly reghdfe hfper_ts_snw inn_play $cv if watch==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
estadd local op "NO"
estadd local time "NO"
eststo: quietly reghdfe ts_percasall inn_play $cv if watch_river_base==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
estadd local op "NO"
estadd local time "NO"
eststo: quietly reghdfe ts_percasuq inn_play $cv if watch_river_base==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
estadd local op "NO"
estadd local time "NO"
eststo: quietly reghdfe hfper_ts_snw inn_play $cv if watch_river_base==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
estadd local op "NO"
estadd local time "NO"
eststo: quietly reghdfe ts_percasall inn_play $cv if watch_well==1 & public==1, absorb(nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "NO"
estadd local optime "NO"
estadd local op "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq inn_play $cv if watch_well==1 & public==1, absorb(nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "NO"
estadd local optime "NO"
estadd local op "YES"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw inn_play $cv if watch_well==1 & public==1, absorb(nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "NO"
estadd local optime "NO"
estadd local op "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasall inn_play $cv if watch_shalenet==1 & public==1, absorb(nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "NO"
estadd local optime "NO"
estadd local op "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq inn_play $cv if watch_shalenet==1 & public==1, absorb(nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "NO"
estadd local optime "NO"
estadd local op "YES"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw inn_play $cv if watch_shalenet==1 & public==1, absorb(nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "NO"
estadd local optime "NO"
estadd local op "YES"
estadd local time "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year Month FE" "op Shale Play FE" "time Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel B: When public operators are not watched by monitors
eststo clear 
eststo: quietly reghdfe ts_percasall inn_play $cv if watch==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq inn_play $cv if watch==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw inn_play $cv if watch==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall inn_play $cv if watch_river_base==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq  inn_play $cv if watch_river_base==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw inn_play $cv if watch_river_base==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall inn_play $cv if watch_well==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq  inn_play $cv if watch_well==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw inn_play $cv if watch_well==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall inn_play $cv if watch_shalenet==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq inn_play $cv if watch_shalenet==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw inn_play $cv if watch_shalenet==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES" 
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))


**************************************************************************************
***Online Appendix Table C.7B: Robustness checks - Alternative model specifications***
**************************************************************************************
*Panel A: Cluster standard errors at the operator and year-month level
eststo clear 
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nop yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly  reghdfe ts_percasuq watch $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nop yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly  reghdfe hfper_ts_snw watch $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nop yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nop yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nop yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly  reghdfe hfper_ts_snw watch $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nop yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel B: Operator×Year-Month FE and Shale Play×Year-Month FE
eststo clear 
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==0 & public==1, absorb(nop#yearmonth nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operatortime "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==0 & public==1, absorb(nop#yearmonth nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operatortime "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==0 & public==1, absorb(nop#yearmonth nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operatortime "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==1 & public==1, absorb(nop#yearmonth nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operatortime "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==1 & public==1, absorb(nop#yearmonth nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operatortime "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==1 & public==1, absorb(nop#yearmonth nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operatortime "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operatortime Operator*Year Month FE" "optime Oil Play*Year Month FE" "N N ""r2 Adjusted R-squared")  drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel C: Operator FE, Shale Play FE, and Year-Month FE
eststo clear 
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==0 & public==1, absorb(nop nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local op "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==0 & public==1, absorb(nop nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local op "YES"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==0 & public==1, absorb(nop nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local op "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasall watch $cv if inn_play==1 & public==1, absorb(nop nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local op "YES"
estadd local time "YES"
eststo: quietly reghdfe ts_percasuq watch $cv if inn_play==1 & public==1, absorb(nop nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local op "YES"
estadd local time "YES"
eststo: quietly reghdfe hfper_ts_snw watch $cv if inn_play==1 & public==1, absorb(nop nplay yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local op "YES"
estadd local time "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01)  scalars("control Controls" "operator Operator FE" "op Shale Play FE" "time Year-Month FE" "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))

*Panel D: Operator-Shale Play-Month level data
keep ts_percasall ts_percasuq hfper_ts_snw nop nplay yearmonth $cv public watch inn_play
bysort nop nplay yearmonth: egen mean_ts_percasall = mean(ts_percasall)
bysort nop nplay yearmonth: egen mean_ts_percasuq = mean(ts_percasuq)
bysort nop nplay yearmonth: egen mean_hfper_ts_snw = mean(hfper_ts_snw)

drop ts_percasall ts_percasuq hfper_ts_snw
duplicates drop 

eststo clear 
eststo: quietly reghdfe mean_ts_percasall watch $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe  mean_ts_percasuq watch $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe mean_hfper_ts_snw watch $cv if inn_play==0 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe mean_ts_percasall watch $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe  mean_ts_percasuq watch $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe mean_hfper_ts_snw watch $cv if inn_play==1 & public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Shale Play*Year-Month FE"  "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3)))


*******************************************************************************
***Online Appendix Table C.7A: Robustness checks - Refine the WATCH variable***
*******************************************************************************
***Steps to compile 'refined_distance.csv'
*import welldata and monitor data to QGIS
*join the monitors with the wells using 'join attributes by nearest'
*set maximum nearest neighbor as 1
*save 'distance' as rob_dist
*export the shapefile as 'refined_distance.csv'

clear 
import delimited "C:\Users\anson\Dropbox\Dissertation\Fracfocus\FracFocusCSV\final_data\refined_distance.csv", encoding(ISO-8859-2) 

encode play, gen(nplay)
encode operatorname, gen(nop)
gen yearmonth=ym(year, month)
format yearmonth %tm

gen watch = 1 if watch_river_base==1 | watch_well==1 | watch_shalenet==1
replace  watch = 0 if missing(watch)
vl create cv = (log_wellcount_byplay log_cumsum_byplay opexp_byplay ln_ogprod_byplay)
gen refine_watch_p90 = 1 if watch==1& rob_dist<= 22.89611 
replace refine_watch_p90 = 0 if missing(refine_watch_p90)
gen refine_watch_p75 = 1 if watch==1& rob_dist<= 14.39551
replace refine_watch_p75 = 0 if missing(refine_watch_p75)
gen refine_watch_p50 = 1 if watch==1 & rob_dist<= 7.722767
replace refine_watch_p50 = 0 if missing(refine_watch_p50)

*Panel A: P90 as the cutoff distance for remotely/closely monitored wells
eststo clear 
eststo: quietly reghdfe ts_percasall refine_watch_p90 $cv if inn_play==0 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq refine_watch_p90 $cv if inn_play==0 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw refine_watch_p90 $cv if inn_play==0 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall refine_watch_p90 $cv if inn_play==1 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq refine_watch_p90 $cv if inn_play==1 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw refine_watch_p90 $cv if inn_play==1 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Oil Play*Year Month FE"  "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3))) 

*Panel B: P75 as the cutoff distance for remotely/closely monitored wells
eststo clear 
eststo: quietly reghdfe ts_percasall refine_watch_p75 $cv if inn_play==0 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq refine_watch_p75 $cv if inn_play==0 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw refine_watch_p75 $cv if inn_play==0 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall refine_watch_p75 $cv if inn_play==1 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq refine_watch_p75 $cv if inn_play==1 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw refine_watch_p75 $cv if inn_play==1 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Oil Play*Year Month FE"  "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3))) 

*Panel C: P50 as the cutoff distance for remotely/closely monitored wells
eststo clear 
eststo: quietly reghdfe ts_percasall refine_watch_p50 $cv if inn_play==0 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq refine_watch_p50 $cv if inn_play==0 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw refine_watch_p50 $cv if inn_play==0 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasall refine_watch_p50 $cv if inn_play==1 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe ts_percasuq refine_watch_p50 $cv if inn_play==1 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
eststo: quietly reghdfe hfper_ts_snw refine_watch_p50 $cv if inn_play==1 &public==1, absorb(nop nplay#yearmonth) vce(cluster nplay yearmonth)
estadd local control "YES"
estadd local operator "YES"
estadd local optime "YES"
esttab, star(* 0.10 ** 0.05 *** 0.01) scalars("control Controls" "operator Operator FE" "optime Oil Play*Year Month FE"  "N N ""r2 Adjusted R-squared") drop($cv _cons) cells(b(star fmt(3)) se(par fmt(3))) 

log close