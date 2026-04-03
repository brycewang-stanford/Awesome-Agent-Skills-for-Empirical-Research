/*******************************************************************************
.do file for "Implied Equity Duration: A Measure of Pandemic Shutdown Risk"
Dechow, Erhard, Sloan, and Soliman [2021], Journal of Accounting Research
*******************************************************************************/

clear
set graphics off

*Overleaf output
global path "/Users/rde/Dropbox/Apps/Overleaf/Duration JAR Final/Results"

*Daily panel data (downloaded via WRDS cloud on 5/14/20)
global panel "/Users/rde/Dropbox/Duration_JAR/Data/duration_panel.dta" 

*Daily portfolio data (downloaded via WRDS cloud on 5/14/20)
global port "/Users/rde/Dropbox/Duration_JAR/Data/duration_portfolios.dta" 

*IBES and MNC data (downloaded via WRDS cloud on 1/4/21)
global ibes "/Users/rde/Dropbox/Duration_JAR/Data/ibes_2020q2.dta" 

*FactSet Returns for 11/6/20-11/16/20 (downloaded via FactSet on 11/19/20)
global fs "/Users/rde/Dropbox/Duration_JAR/Data/FactSetReturns110520_111720.dta"

/* 
Requires packages: 
gtools [ssc install gtools]
asreg [ssc install asreg] 
fmb [run fmb.ado]
ffind [run ffind.ado]
*/


*Table 1 ***********************************************************************
use $panel,clear
rename *,lower
g post=year(ddate)==2020
rename ddate date
keep if year(date)>=1964
replace ret=(ret*25200) // daily decimal -> annualized percent 
g me_b=me_crsp/1000
g bm=bveq/me_crsp if bveq>0
replace bm=(bve/me_crsp) if bveq==. & bve>0 
g em=ibq4/me_crsp if ibq4>0
replace em=ib/me_crsp if ibq4==. & ib>0
sort permno date
foreach x in dur bm em lev oplev me_b ibq4 ib{
replace `x'=. if month(date)>1 & post==1
replace `x'=`x'[_n-1] if `x'==. & post==1 & permno==permno[_n-1] // values as of Dec 31, 2019
}

label var dur "Duration"
label var bm "BE/ME"
label var em "Earnings/ME"
label var lev "Financial leverage"
label var oplev "Operating leverage"
label var ret "Excess return"
label var me_b "ME (bn)"
label var g "Sales growth"

* Panel A: Distributions *
foreach x in dur bm em g lev oplev me_b ret{
preserve
if "`x'"!="ret"{
gstats winsor `x',by(post) cuts(1 99) replace // winsorize non-returns at 1% tails
}
ttest `x',by(post)
mat `x't=(r(mu_2)-r(mu_1))
if r(p)>=.1{
mat `x's=0
}
if r(p)<.1{
mat `x's=1
}
if r(p)<.05{
mat `x's=2
}
if r(p)<.01{
mat `x's=3
}
gcollapse (mean) mean`x'=`x' (sd) sd`x'=`x' (p50) p50`x'=`x',by(post) fast
expand 2
forvalues i=0/1{
foreach ds in mean sd p50{
reg `ds'`x' if post==`i'
mat `ds'`x'`i'=_b[_cons] 
}
mat `x'`i'=(mean`x'`i',p50`x'`i',sd`x'`i')
}
mat `x'=(`x'1,.,`x'0,`x't)
restore
}
mat table=(dur)
mat stars=(durs)
foreach x in  bm em g lev oplev me_b ret{
mat table=(table \ `x')
mat stars=(stars \ `x's)
}
mat stars=(J(8,7,0),stars)
frmttable using "$path/t1a", ///
replace tex fragment statmat(table) coljust(lc) squarebrack sdec(2) annotate(stars) asymbol("*","**","***") ///
ctitles("\hline \noalign{\smallskip} & \multicolumn{3}{c}{ \uline{\hfill 2020 \hfill}}  & & \multicolumn{3}{c}{\uline{\hfill 1964-2019 \hfill}} "  \ ///
 "Variable","Mean","Median","SD","","Mean","Median", "SD","Dif. in Means") ///
rtitles("Duration" \  "BE/ME" \ "Earnings/ME" \ "Sales growth" \ "Financial leverage" \ "Operating leverage" \ "ME (bn)" \ " Excess return (annualized)")

* Panels B,C: Correlations *
forvalues i=0/1{
preserve
keep post dur bm em lev oplev me_b ret date g
keep if post==`i'
eststo clear
local vlist "dur bm em g lev oplev me_b "
gstats winsor `vlist',by(post) replace cuts(1 99) 
local vlist "dur bm em g lev oplev me_b ret"
local upper
local lower `vlist'
expand 2, g(version)
foreach v of local vlist {
    gegen rank = rank(`v') if version == 1  
    replace `v' = rank if version ==1
    drop rank
}
foreach v of local vlist {
   estpost correlate `v' `lower' if version == 0
   foreach m in b rho p count {
       matrix `m' = e(`m')
   }
   if "`upper'"!="" {
   estpost correlate `v' `upper' if version == 1
       foreach m in b rho p count {
           matrix `m' = e(`m'), `m'
       }
   }
   ereturn post b
   foreach m in rho p count {
       quietly estadd matrix `m' = `m'
   }
   eststo `v', title(`v')
   local lower: list lower - v
   local upper `upper' `v'
 }

esttab using "$path/t1_`i'.tex", /// 
label nonumbers mtitles noobs not tex nostar b(%8.2f) substitute(\_ _) ///
mti( "Dur" "BE/ME" "E/ME" "SaleGr" "FinLev" "OpLev" "ME" "ExRet") replace
restore
}

*Table 2 ***********************************************************************
use $panel,clear
rename *,lower
rename ddate date
keep if year(date)==2020
g lret=ln(1+ret)
gegen ret2020=sum(lret),by(permno)
replace ret2020=(exp(ret2020)-1)*100
keep if year(date)==2020 & month(date)==1 & day(date)==2
keep if dur!=.
ffind siccd, newvar(ff49) type(49)
preserve
gstats winsor dur,cuts(1 99) replace 
gcollapse (mean) mean=dur (sd) sd=dur (p25) p25=dur (p50) p50=dur (p75) p75=dur (count) num=dur,by(ff49) fast
expand 2
forvalues i=1/49{
foreach ds in mean sd p25 p50 p75 num{
reg `ds' if ff49==`i'
mat `ds'`i'=_b[_cons] 
}
mat ff`i'=(mean`i',sd`i',p25`i',p50`i',p75`i',num`i') 
}
restore

gcollapse (mean) dur ret2020,by(ff49)
corr dur ret2020
expand 2
forvalues i=1/49{
reg ret2020 if ff49==`i'
mat ff`i'=(ff`i',_b[_cons])
}
mat table=(ff29)
local ff="ff25 ff30 ff4 ff28 ff46 ff32 ff23 ff45 ff18 ff19 ff47 ff16 ff39 ff48 ff14 ff10 ff43 ff42 ff20 ff41 ff7 ff44 ff8 ff21 ff24 ff17 ff9 ff31 ff1 ff6 ff33 ff37 ff40 ff15 ff11 ff22 ff34 ff2 ff27 ff26 ff3 ff38 ff35 ff49 ff13 ff12 ff5 ff36"
foreach x in `ff'{
mat table=(table \ `x')
}
mat avg=ff1
forvalues i=2/49{
mat avg=avg+ff`i'
}
mat avg=avg/49
mat table=(table \ avg)
frmttable using "$path/ind_dur", ///
replace tex fragment statmat(table) coljust(lc) squarebrack sdec(2) ///
ctitles("Industry","Dur. Mean","Dur. SD","Dur. P25","Dur. P50","Dur. P75","N","2020 Q1 Return") ///
rtitles("Coal" \ ///
"Shipbuilding, Railroad Equipment" \ ///
"Petroleum and Natural Gas" \ ///
"Beer \& Liquor" \ ///
"Non-Metallic and Industrial Metal Mining" \ ///
"Insurance" \ ///
"Communication" \ ///
"Automobiles and Trucks" \ ///
"Banking" \ ///
"Construction" \ ///
"Steel Works Etc" \ ///
"Real Estate" \ ///
"Textiles" \ ///
"Business Supplies" \ ///
"Trading" \ ///
"Chemicals" \ ///
"Apparel" \ ///
"Retail" \ ///
"Wholesale" \ ///
"Fabricated Products" \ ///
"Transportation" \ ///
"Entertainment" \ ///
"Restaurants, Hotels, Motels" \ ///
"Printing \& Publishing" \ ///
"Machinery" \ ///
"Aircraft" \ ///
"Construction Materials" \ ///
"Consumer Goods" \ ///
"Utilities" \ ///
"Agriculture" \ ///
"Recreation" \ ///
"Personal Services" \ ///
"Electronic Equipment" \ ///
"Shipping Containers" \ ///
"Rubber and Plastic Products" \ ///
"Healthcare" \ ///
"Electrical Equipment" \ ///
"Business Services" \ ///
"Food Products" \ ///
"Precious Metals" \ ///
"Defense" \ ///
"Candy \& Soda" \ ///
"Measuring and Control Equipment" \ ///
"Computer Hardware" \ ///
"Other" \ ///
"Pharmaceutical Products" \ ///
"Medical Equipment" \ ///
"Tobacco Products" \ ///
"Computer Software" \ ///
"\hline Average FF49 Industry")

*Tables 3-5 / Figures 2-3 ******************************************************
use $port,clear
g yearmo=year(ddate)*100+month(ddate)
keep if yearmo>=196401
g post=0 if yearmo<=201912  
replace post=1 if inrange(yearmo,202001,202003) 
replace dret=dret*100 // decimal -> percent 
replace dmktrf=dmktrf*100 // decimal -> percent 
g b=.
g capm_a=.
rename sortvarmean mean_

foreach m in durr bmr emr{
if "`m'"=="durr"{
local title="Duration" // durr = duration quintile rank
}

if "`m'"=="bmr"{
local title="Book-to-market" // bmr = be/me quintile rank
} 

if "`m'"=="emr"{
local title="Earnings-to-price" // emr = earnings/me quintile rank
} 

forvalues w=0/1{
preserve
keep if sortvar=="`m'" & vw==`w'
rename dret ret
gegen vola=sd(ret),by(port post)
g h=0 if port==1
replace h=1 if port==5
forvalues j=0/1{
sdtest ret if post==`j',by(h)
if r(p)>=.1{
mat starvola`j'=0
}
if r(p)<.1{
mat starvola`j'=1
}
if r(p)<.05{
mat starvola`j'=2
}
if r(p)<.01{
mat starvola`j'=3
}

if r(F)>=1{
mat f`j'=(r(F))
}
if r(F)<1{
mat f`j'=(1/r(F))
}
}
replace mean_=. if month(ddate)!=1 // keep portfolio chars. at beginning of year

*annualize returns and volatility 
g mktret=dmktrf*252 
replace ret=ret*252
replace vola=vola*sqrt(252) 

sort port ddate
g mktret_1=mktret[_n-1] if port==port[_n-1]
g mktret1=mktret[_n+1] if port==port[_n+1]
replace mktret1=-4.51*252 if mktret1==. // market return on 4/1/20 from K. French 
g b_d=.
g capm_a_d=.

forvalues j=1/5{
forvalues i=0/1{
*Dimson Beta
reg ret mktret mktret_1 mktret1 if port==`j' & post==`i'
replace b_d=_b[mktret_1]+_b[mktret]+_b[mktret1] if port==`j' & post==`i'
replace capm_a_d=_b[_cons] if port==`j' & post==`i'
}
}

local vars="ret b_d vola mean_"

*Gen 5-1 hedges: 
sort ddate port
foreach x in `vars'{
g `x'h51=`x'-`x'[_n-4] if port==5 & port[_n-4]==1
}
*Tables
foreach x in `vars'{
forvalues j=0/1{
mat `x'_`j'=(.)
forvalues i=1/5{
reg `x' if post==`j' & port==`i'
mat `x'`i'_`j'=(_b[_cons],.)
if inlist("`x'","b", "vola"){
mat `x'`i'=(_b[_cons],.)
}
if `i'==2{
matselrc `x'_`j' `x'_`j', col(2/3) 
}
mat `x'_`j'=(`x'_`j',`x'`i'_`j')
}
}
}

foreach x in ret{
forvalues j=0/1{
reg `x'h51 if post==`j'
mat `x'_`j'=(`x'_`j',_b[_cons],_b[_cons]/_se[_cons])
local p=2*ttail(e(df_r),abs(_b[_cons]/_se[_cons]))
if `p'>=.1{
mat star`x'`j'=0
}
if `p'<.1{
mat star`x'`j'=1
}
if `p'<.05{
mat star`x'`j'=2
}
if `p'<.01{
mat star`x'`j'=3
}
}
}

foreach x in mean_{
forvalues j=0/1{
reg `x'h51 if post==`j'
mat `x'_`j'=(`x'_`j',_b[_cons],.)
mat star`x'`j'=0
}
}

foreach x in vola{
forvalues j=0/1{
reg `x'h51 if post==`j'
mat `x'_`j'=(`x'_`j',_b[_cons],f`j')
}
}

forvalues j=0/1{
*Dimson betas
mat dalpha_`j'=(.)
mat dbeta_`j'=(.)
forvalues i=1/5{
reg ret mktret mktret_1 mktret1 if post==`j' & port==`i'
mat dalpha_`j'=(dalpha_`j',_b[_cons],.)
mat dbeta_`j'=(dbeta_`j',_b[mktret]+_b[mktret1]+_b[mktret_1],.)

if `i'==1{
matselrc dalpha_`j' dalpha_`j', col(2/3) 
matselrc dbeta_`j' dbeta_`j', col(2/3) 
}
}

reg reth51 mktret mktret_1 mktret1 if post==`j' 
mat dalpha_`j'=(dalpha_`j',_b[_cons],_b[_cons]/_se[_cons])
mat dbeta_`j'=(dbeta_`j',_b[mktret]+_b[mktret1]+_b[mktret_1])

local palpha=2*ttail(e(df_r),abs(_b[_cons]/_se[_cons]))

test (_b[mktret]+_b[mktret1]+_b[mktret_1])=0

mat dbeta_`j'=(dbeta_`j',r(F))

mat dstarbeta`j'=0
if r(p)<.1{
mat dstarbeta`j'=1 
}
if r(p)<.05{
mat dstarbeta`j'=2 
}
if r(p)<.01{
mat dstarbeta`j'=3 
}

if `palpha'>=.1{
mat dstaralpha`j'=0
}
if `palpha'<.1{
mat dstaralpha`j'=1
}
if `palpha'<.05{
mat dstaralpha`j'=2
}
if `palpha'<.01{
mat dstaralpha`j'=3
}

}

mat tab=(mean__1 \ mean__0 \ ret_1 \ ret_0  \ dalpha_1 \ dalpha_0 \ dbeta_1 \ dbeta_0 \ vola_1 \ vola_0 )
mat star=(starmean_1,0 \ starmean_0,0 \ starret1,0 \ starret0,0 \ dstaralpha1,0 \ dstaralpha0, 0 \ dstarbeta1, 0 \ dstarbeta0,0 \ starvola1,0 \ starvola0,0)
mat star=(J(10,10,0),star)
frmttable using "$path/t_vw`w'_`m'.tex", ///
replace tex fragment statmat(tab) substat(1) coljust(c) squarebrack  annotate(star) asymbol("*","**","***") ///
sdec(2) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{`title'} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("\rowcolor{Gray} `title' (01/20 - 03/20)" \"\rowcolor{Gray}"\" `title' (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Excess return (01/20 - 03/20)" \"\rowcolor{Gray}"\"Excess return (01/64 - 12/19)"\""\  ///
"\rowcolor{Gray} $ \alpha\sb{\text{CAPM}} $  (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \alpha\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} $ \beta\sb{\text{CAPM}} $ (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \beta\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Volatility (01/20 - 03/20)" \"\rowcolor{Gray}"\"Volatility (01/64 - 12/19)")


if inlist("`m'","durr"){
frmttable using "$path/t_vw`w'_`m'.tex", ///
replace tex fragment statmat(tab) substat(1) coljust(c) squarebrack  annotate(star) asymbol("*","**","***") ///
sdec(2) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{`title'} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("\rowcolor{Gray} `title' (01/20 - 03/20)" \"\rowcolor{Gray}"\" `title' (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Excess return (01/20 - 03/20)" \"\rowcolor{Gray}"\"Excess return (01/64 - 12/19)"\""\  ///
"\rowcolor{Gray} $ \alpha\sb{\text{CAPM}} $  (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \alpha\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} $ \beta\sb{\text{CAPM}} $ (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \beta\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Volatility (01/20 - 03/20)" \"\rowcolor{Gray}"\"Volatility (01/64 - 12/19)")
}

if "`m'"=="durr"{
local vars="ret vola b_d capm_a_d"

gcollapse (mean) `vars',by(port post) fast
local v=""
foreach x in `vars'{
g `x'0=`x' if post==0
g `x'1=`x' if post==1
local v="`v' `x'0 `x'1"
}

gcollapse (firstnm) `v',by(port) fast
label var ret0 "01/64 - 12/19"
label var ret1 "01/20 - 03/20"
label var capm_a_d0 "01/64 - 12/19"
label var capm_a_d1 "01/20 - 03/20"
label var b_d0 "01/64 - 12/19"
label var b_d1 "01/20 - 03/20"
label var vola0 "01/64 - 12/19"
label var vola1 "01/20 - 03/20"
label var port "`title'"

if `w'==0{
local mina=5
local ra=5
local maxa=25
}
if `w'==1{
local mina=-2
local ra=2
local maxa=4
}

if `w'==0{
local minr=10
local rr=5
local maxr=30
}

if `w'==1{
local minr=5
local rr=1
local maxr=10
}

local s="huge"

twoway (line ret1 ret0 port), ytitle("Excess return (% annualized)" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(-200(50)50,nogrid labsize(`s')) xlabel(1(1)5,labsize(`s')) ///
legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5)) 
graph export "$path/ret1_vw`w'_`m'.eps",replace fontface(Cmr10)

twoway (line capm_a_d1 capm_a_d0 port,lpattern(solid dash )), ytitle("CAPM alpha (% annualized)" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(-100(50)50,nogrid labsize(`s')) ///
xlabel(1(1)5,labsize(`s')) legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5))  
graph export "$path/dalpha1_vw`w'_`m'.eps",replace fontface(Cmr10)

twoway (line b_d1 b_d0 port,lpattern(solid dash )), ytitle("CAPM beta" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(.6(.2)1.4,nogrid labsize(`s')) ///
xlabel(1(1)5,labsize(`s')) legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5))  
graph export "$path/dbeta_vw`w'_`m'.eps",replace fontface(Cmr10)

twoway (line vola1 vola0 port,lpattern(solid dash )), ytitle("Volatility (% annualized)" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(10(20)80,nogrid labsize(`s')) ///
xlabel(1(1)5,labsize(`s')) legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5))  
graph export "$path/vola_vw`w'_`m'.eps",replace fontface(Cmr10)

}
restore
}
}


*Figure 4 *********************************************************************
preserve
g ret=dret/100
g mktret=dmktrf/100

g dur5_vw=ret if sortvar=="durr" & port==5 & vw==1
g dur1_vw=ret if sortvar=="durr" & port==1 & vw==1

g dur5_ew=ret if sortvar=="durr" & port==5 & vw==0
g dur1_ew=ret if sortvar=="durr" & port==1 & vw==0

gcollapse (firstnm) dur1_vw dur5_vw dur1_ew dur5_ew mktret,by(ddate)
g year=year(ddate)
g dur_ew=ln(1+dur5_ew-dur1_ew)
g dur_vw=ln(1+dur5_vw-dur1_vw)
replace mktret=ln(1+mktret)

gcollapse (sum) dur_ew dur_vw mktret,by(year)
foreach x in dur_ew dur_vw mktret{
replace `x'=100*(exp(`x')-1)
}

replace dur_ew=-dur_ew 
replace dur_vw=-dur_vw 

local min=-50
local max=50
g rec1=`min' if (y>=1969&y<=1970)
g rec2=`min' if (y>=1973&y<=1975)
g rec3=`min' if (y>=1980&y<=1982)
g rec5=`min' if (y>=1990&y<=1991)
g rec6=`min' if (y>=2001&y<=2001)
g rec7=`min' if (y>=2008&y<=2009)
g rec8=`min' if (y==2020)

g rec_1=`max' if (y>=1969&y<=1970)
g rec_2=`max' if (y>=1973&y<=1975)
g rec_3=`max' if (y>=1980&y<=1982)
g rec_5=`max' if (y>=1990&y<=1991)
g rec_6=`max' if (y>=2001&y<=2001)
g rec_7=`max' if (y>=2008&y<=2009)
g rec_8=`max' if (y==2020)

foreach x in dur_vw dur_ew{
corr `x' mktret if y<2020
local corr=round(10000*r(rho))/100
twoway ///
(area rec1 y, bcolor(gs14)) ///
(area rec2 y, bcolor(gs14)) ///
(area rec3 y, bcolor(gs14)) ///
(area rec5 y, bcolor(gs14)) ///
(area rec6 y, bcolor(gs14)) ///
(area rec7 y, bcolor(gs14)) /// 
(area rec_1 y, bcolor(gs14)) ///
(area rec_2 y, bcolor(gs14)) ///
(area rec_3 y, bcolor(gs14)) ///
(area rec_5 y, bcolor(gs14)) ///
(area rec_6 y, bcolor(gs14)) ///
(area rec_7 y, bcolor(gs14)) /// 
(line  dur_vw mktret y,lpattern(solid dash) lcolor(cranberry navy))  , xline(2020,lcolor(gs14)) ///
text(-45 2000 "Corr. Dur, Mkt: `corr'% ", box placement(w) bcolor(white)) ///
title("") ytitle("Return") ylab(-50(20)50,nogrid) yline(0) /// 
xtitle("") legend(on) plotregion(margin(zero)) graphregion(color(white)) ///
legend(pos(7) ring(0) col(1) order(13 14) label(13 "Duration") label(14 "Market") ///
region(lstyle(color(white)))) xlab(1964(4)2020,angle(45)) xtitle("Year")
graph export "$path/ts_`x'.eps",replace fontface(Cmr10)
}
restore

*Figure 5 *********************************************************************
forvalues w=0/1{
preserve
keep if sortvar=="durr" & vw==`w' & year(ddate)==2020
sort ddate
expand 5
replace dret=ln(1+dret/100) // for compounding 
forvalues i=1/5{
g r`i'=dret if port==`i'
}
gcollapse (firstnm) r1-r5,by(ddate)
sort ddate
forvalues i=1/5{
g cr`i'=r`i' if r`i'[_n-1]==.
replace cr`i'=r`i'+cr`i'[_n-1] if cr`i'==.
replace cr`i'=100*(exp(cr`i')-1)
}

local wu=date("01232020","MDY")
local it=date("02222020","MDY")
local eu=date("03112020","MDY")
local ne=date("03132020","MDY")
local st=date("03242020","MDY")
local d1=date("01022020","MDY")
local d2=date("02032020","MDY")
local d3=date("03022020","MDY")
local d4=date("03312020","MDY")

tsset ddate
twoway (line cr1-cr5 ddate,lcolor(emerald teal eltgreen olive_teal gray)), ///
legend(pos(7) ring(0) col(1) order(5 4 3 2 1) label(1 "Low Duration") label(2 "Q2") label(3 "Q3")  ///
label(4 "Q4") label(5 "High Duration") region(lstyle(color(white)))) xtitle("Date") ///
plotregion(margin(zero)) graphregion(color(white)) ylabel(-60(20)20,nogrid) ///
xline(`wu' `it' `eu' `ne' `st', lpat(dash)) ///
text(-20 `wu' "Wuhan lockdown",placement(w) orientation(vertical)) ///
text(-20 `it' "Italy quarantine",placement(w) orientation(vertical)) ///
text(-48 `eu' "EU Travel Ban",placement(w) orientation(vertical)) ///
text(10 `ne' "Natl. Emer.",placement(e) orientation(vertical)) ///
text(10 `st' "Fiscal stimulus",placement(e) orientation(vertical)) ///
xlabel(`d1' "Jan 2" `d2' "Feb 3" `d3' "Mar 2" `d4' "Mar 31      ") ytitle("Cumulative Excess Return")
graph export "$path/etime_vw`w'.eps",replace fontface(Cmr10)
restore
}

*Table 6 ***********************************************************************
use $panel, clear
rename *,lower
rename ddate date
keep if year(date)==2020
*Merge IBES data
g PERMNO=permno
joinby PERMNO using $ibes,unm(master)
drop PERMNO

g revision=100*((e_eps_may-e_eps_dec)/prc_a) // Q2 quarterly forecast revision (%)
g fy2p=100*(e_eps_fy2_dec/prc_a) // FY 2 consensus annual EPS (%)
g fep=100*((actual-e_eps_dec)/prc_a) // Q2 forecast error (relative to Dec. consensus) (%)
replace ret=(ret*100*252) // annualized percent 
g me_b=me_crsp/1000
g bm=bveq/me_crsp if bveq>0
replace bm=(bve/me_crsp) if bveq==. & bve>0 
g em=ibq4/me_crsp if ibq4>0
replace em=ib/me_crsp if ibq4==. & ib>0

sort permno date
foreach x in dur bm em lev oplev me_b ibq4 ib{
replace `x'=. if month(date)>1 
replace `x'=`x'[_n-1] if `x'==. & permno==permno[_n-1] // values as of Dec 31, 2019
}

label var dur "Duration"
label var bm "BE/ME"
label var em "Earnings/ME"
label var me_b "ME"
label var lev "Financial leverage"
label var oplev "Operating leverage"
label var ret "Excess return"

preserve
keep if month(date)==1 & day(date)==2
count if revision>0 & revision!=.
count if revision<0 & revision!=.
fasterxtile durr=dur,by(date) n(5)
gstats winsor revision fy2p fep,cuts(1 99) replace
foreach y in revision fy2p fep{
foreach x in durr{
g hi=1 if `x'==5
replace hi=0 if `x'==1
forvalues i=1/5{
reg `y' if `x'==`i'
mat y`i'ew=(_b[_cons],.)
reg `y' if `x'==`i' [w=me]
mat y`i'vw=(_b[_cons],.)
mat n`i'=e(N)
}
mat n`x'=(n1,.,n2,.,n3,.,n4,.,n5,.,.,.)
reg `y' hi
mat `x'ew=(y1ew,y2ew,y3ew,y4ew,y5ew, _b[hi],_b[hi]/_se[hi])

local pvalue=2*ttail(e(df_r),abs(_b[hi]/_se[hi]))

if `pvalue'>=.1{
mat `x'sew=0
}
if `pvalue'<.1{
mat `x'sew`j'=1
}
if `pvalue'<.05{
mat `x'sew`j'=2
}
if `pvalue'<.01{
mat `x'sew`j'=3
}

reg `y' hi [w=me]
mat `x'vw=(y1vw,y2vw,y3vw,y4vw,y5vw,_b[hi],_b[hi]/_se[hi])
local pvalue=2*ttail(e(df_r),abs(_b[hi]/_se[hi]))
if `pvalue'>=.1{
mat `x'svw=0
}
if `pvalue'<.1{
mat `x'svw`j'=1
}
if `pvalue'<.05{
mat `x'svw`j'=2
}
if `pvalue'<.01{
mat `x'svw`j'=3
}

drop hi
}
mat dur`y'vw=(durrvw \ ndurr)
mat dur`y'ew=(durrew \ ndurr)
mat stardurvw=(durrsvw,0)
mat stardurew=(durrsew,0)
mat stardur`y'vw=(J(1,10,0),stardurvw)
mat stardur`y'ew=(J(1,10,0),stardurew)
}
mat durvw=(durfy2pvw \ durrevisionvw \ durfepvw)
mat durew=(durfy2pew \ durrevisionew \ durfepew)
mat stardurvw=(stardurfy2pvw \ J(1,12,0)  \ stardurrevisionvw  \ J(1,12,0) \ stardurfepvw)
mat stardurew=(stardurfy2pew \ J(1,12,0)  \ stardurrevisionew  \ J(1,12,0) \ stardurfepew)

frmttable using "$path/durvwibes.tex", ///
replace tex fragment statmat(durvw) substat(1) coljust(c) squarebrack  annotate(stardurvw) asymbol("*","**","***") ///
sdec(2 \ 2 \ 0 \ 0 \ 2\ 2 \ 0 \ 0 \ 2 \ 2 \ 0 \ 0) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{Duration} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("Pre-pandemic Forward Yield (FY2/P)" \"" \ "N"\""\ "Q2 2020 Earnings Revision" \ ""\"N"\""\"Q2 2020 Earnings Surprise"\""\"N")

frmttable using "$path/durewibes.tex", ///
replace tex fragment statmat(durew) substat(1) coljust(c) squarebrack  annotate(stardurew) asymbol("*","**","***") ///
sdec(2 \ 2 \ 0 \ 0 \ 2\ 2 \ 0 \ 0 \ 2 \ 2 \ 0 \ 0) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{Duration} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("Pre-pandemic Forward Yield (FY2/P)" \"" \ "N"\""\ "Q2 2020 Earnings Revision" \ ""\"N"\""\"Q2 2020 Earnings Surprise"\""\"N")
restore



*Tables 7-9 ********************************************************************

*Table 7: Full Sample
forvalues j=7/9{
preserve

*Table 8: Drop stocks with positive cumulative 2020 Q1 returns
if `j'==8{
g lret=ln(1+ret/25200)
gegen ret2020=sum(lret),by(permno)
keep if (exp(ret2020)-1)<0 & ret2020!=.
}

*Table 9: Drop stocks with positive revisions for Q2 EPS in the IBES subsample
if `j'==9{
keep if revision != . & revision<0
}
drop if dur==. // constant sample
foreach x in dur bm em lev oplev me_b{
fasterxtile r=`x',by(date) n(5)
replace `x'=(r-1)/4
drop r 
}

replace em=0 if ibq4<0
replace em=0 if em==. & ib<0
g loss=(ibq4<0)
replace loss=1 if ibq4==. & ib<0
replace loss=. if ibq4==. & ib==.
replace lev=0 if lev==. 
replace oplev=0 if oplev==. 

label var loss "Loss"
ffind siccd, newvar(ff49) type(49)
forvalues i=1/49{
g ff__`i'=(ff49==`i')
}

g multi=(pifo!=. | txfo !=. | txdfo !=.)
label var multi "MNC"
sort date
gegen t=group(date)

tsset permno t
local cont= "lev oplev loss me_b multi"

eststo clear
foreach v in dur bm em{
eststo:asreg ret `v' `cont',fmb
estadd local ind_fe "No"
estadd local avgn = round(e(N)/62)
eststo:asreg ret `v' `cont' ff__1-ff__48,fmb 
estadd local ind_fe "Yes" 
estadd local avgn =round(e(N)/62)
}

esttab using "$path/fm_ew_`j'.tex", ///
label b(%8.2f) stats(adjr2 ind_fe avgn, fmt(%8.3f) labels(`"Avg. Adj. $ R^2 $ "' "FF 49 Indicators" "Avg. N"))   ///
brackets nonotes substitute(\_ _) star(* 0.10 ** 0.05 *** 0.01) ///
keep(dur bm em `cont') order(dur bm em  `cont') nomti   mgroups("Daily excess return $\times$ 252 ", pattern(1 0 0 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
alignment(D{.}{.}{-1}) replace


local cont= "lev oplev loss me_b multi"
*Weighted FM
eststo clear
foreach v in dur bm em{
eststo:fmb ret `v' `cont' [w=me]
estadd local ind_fe "No" 
estadd local avgn = round(e(N)/62)
eststo:fmb ret `v' `cont' ff__1-ff__48 [w=me]
estadd local ind_fe "Yes" 
estadd local avgn = round(e(N)/62)
}

esttab using "$path/fm_vw_`j'.tex", ///
label b(%8.2f) stats(r2 ind_fe avgn, fmt(%8.3f) labels(`"Avg. Adj. $ R^2 $ "' "FF 49 Indicators" "Avg. N"))   ///
 brackets nonotes substitute(\_ _) star(* 0.10 ** 0.05 *** 0.01) ///
keep(dur bm em `cont') order(dur bm em  `cont') nomti  mgroups("Daily excess return $\times$ 252 ", pattern(1 0 0 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
alignment(D{.}{.}{-1}) replace
restore
}

*Figure 6 **********************************************************************
*Add Factset data
keep if date==date("01022020","MDY") // use rankings at beginning of year
fasterxtile durr=dur,by(date) n(5)
append using $fs
sort permno date
replace durr=durr[_n-1] if permno==permno[_n-1]
keep if month(date)==11

*Duration portfolio returns around good news about vaccine efficacy 
forvalues w=0/1{
preserve
if `w'==0{
gcollapse (mean) ret,by(date durr)
}

if `w'==1{
replace me=1 if date==date("11052020","MDY")
gcollapse (mean) ret [w=me],by(date durr)
}

sort date
expand 5
keep if inrange(date,date("11052020","MDY"),date("11172020","MDY"))
replace ret=0 if date==date("11052020","MDY")

replace ret=ln(1+ret)
forvalues i=1/5{
g r`i'=ret if durr==`i'
}
gcollapse (firstnm) r1-r5,by(date)

sort date

forvalues i=1/5{
g cr`i'=0 if r`i'[_n-1]==.
replace cr`i'=r`i'+cr`i'[_n-1] if cr`i'==.
replace cr`i'=100*(exp(cr`i')-1)
}

tsset date

gegen t=group(date)

g v1=14 if t==2 | t==3
g v2=14 if t==7 | t==8
g v_1=-4 if t==2 | t==3
g v_2=-4 if t==7 | t==8

local esize = "medsmall"
label var t "Date"
twoway (area v1 t, bcolor(gs15)) (area v_1 t, bcolor(gs15)) ///
(area v2 t, bcolor(gs15)) (area v_2 t, bcolor(gs15)) ///
(line cr1-cr5 t,lcolor(emerald teal eltgreen olive_teal gray) lpattern(solid dash shortdash dash_dot longdash  )) , ///
legend(pos(12) ring(1) col(5) order(5 6 7 8 9) label(5 "Low Duration") label(6 "Q2") label(7 "Q3")  ///
label(8 "Q4") label(9 "High Duration") size(medsmall) region(lstyle(color(white)))) xtitle("Date") ///
plotregion(margin(zero)) graphregion(color(white)) ylabel(-4(2)14,nogrid) yscale(range(-4 16) noextend)  ///
text(15 1.95 "Pfizer 90%",placement(e) orientation(horizontal) size(`esize')) ///
text(15 6.7 "Moderna 94.5%",placement(e) orientation(horizontal) size(`esize')) ///
xlabel(1 "Nov 5" 2 "Nov 6" 3 "Nov 9" 4 "Nov 10" 5 "Nov 11" 6 "Nov 12" 7 "Nov 13" 8 "Nov 16" 9 "Nov 17   " ) ///
ytitle("Cumulative Excess Return (%)" " ") 
graph export "$path/etime_vw`w'_vn.eps",replace fontface(Cmr10)
restore
}

* End of Code ******************************************************************
/*******************************************************************************
.do file for "Implied Equity Duration: A Measure of Pandemic Shutdown Risk"
Dechow, Erhard, Sloan, and Soliman [2021], Journal of Accounting Research
*******************************************************************************/

clear
set graphics off

*Overleaf output
global path "/Users/rde/Dropbox/Apps/Overleaf/Duration JAR Final/Results"

*Daily panel data (downloaded via WRDS cloud on 5/14/20)
global panel "/Users/rde/Dropbox/Duration_JAR/Data/duration_panel.dta" 

*Daily portfolio data (downloaded via WRDS cloud on 5/14/20)
global port "/Users/rde/Dropbox/Duration_JAR/Data/duration_portfolios.dta" 

*IBES and MNC data (downloaded via WRDS cloud on 1/4/21)
global ibes "/Users/rde/Dropbox/Duration_JAR/Data/ibes_2020q2.dta" 

*FactSet Returns for 11/6/20-11/16/20 (downloaded via FactSet on 11/19/20)
global fs "/Users/rde/Dropbox/Duration_JAR/Data/FactSetReturns110520_111720.dta"

/* 
Requires packages: 
gtools [ssc install gtools]
asreg [ssc install asreg] 
fmb [run fmb.ado]
ffind [run ffind.ado]
*/


*Table 1 ***********************************************************************
use $panel,clear
rename *,lower
g post=year(ddate)==2020
rename ddate date
keep if year(date)>=1964
replace ret=(ret*25200) // daily decimal -> annualized percent 
g me_b=me_crsp/1000
g bm=bveq/me_crsp if bveq>0
replace bm=(bve/me_crsp) if bveq==. & bve>0 
g em=ibq4/me_crsp if ibq4>0
replace em=ib/me_crsp if ibq4==. & ib>0
sort permno date
foreach x in dur bm em lev oplev me_b ibq4 ib{
replace `x'=. if month(date)>1 & post==1
replace `x'=`x'[_n-1] if `x'==. & post==1 & permno==permno[_n-1] // values as of Dec 31, 2019
}

label var dur "Duration"
label var bm "BE/ME"
label var em "Earnings/ME"
label var lev "Financial leverage"
label var oplev "Operating leverage"
label var ret "Excess return"
label var me_b "ME (bn)"
label var g "Sales growth"

* Panel A: Distributions *
foreach x in dur bm em g lev oplev me_b ret{
preserve
if "`x'"!="ret"{
gstats winsor `x',by(post) cuts(1 99) replace // winsorize non-returns at 1% tails
}
ttest `x',by(post)
mat `x't=(r(mu_2)-r(mu_1))
if r(p)>=.1{
mat `x's=0
}
if r(p)<.1{
mat `x's=1
}
if r(p)<.05{
mat `x's=2
}
if r(p)<.01{
mat `x's=3
}
gcollapse (mean) mean`x'=`x' (sd) sd`x'=`x' (p50) p50`x'=`x',by(post) fast
expand 2
forvalues i=0/1{
foreach ds in mean sd p50{
reg `ds'`x' if post==`i'
mat `ds'`x'`i'=_b[_cons] 
}
mat `x'`i'=(mean`x'`i',p50`x'`i',sd`x'`i')
}
mat `x'=(`x'1,.,`x'0,`x't)
restore
}
mat table=(dur)
mat stars=(durs)
foreach x in  bm em g lev oplev me_b ret{
mat table=(table \ `x')
mat stars=(stars \ `x's)
}
mat stars=(J(8,7,0),stars)
frmttable using "$path/t1a", ///
replace tex fragment statmat(table) coljust(lc) squarebrack sdec(2) annotate(stars) asymbol("*","**","***") ///
ctitles("\hline \noalign{\smallskip} & \multicolumn{3}{c}{ \uline{\hfill 2020 \hfill}}  & & \multicolumn{3}{c}{\uline{\hfill 1964-2019 \hfill}} "  \ ///
 "Variable","Mean","Median","SD","","Mean","Median", "SD","Dif. in Means") ///
rtitles("Duration" \  "BE/ME" \ "Earnings/ME" \ "Sales growth" \ "Financial leverage" \ "Operating leverage" \ "ME (bn)" \ " Excess return (annualized)")

* Panels B,C: Correlations *
forvalues i=0/1{
preserve
keep post dur bm em lev oplev me_b ret date g
keep if post==`i'
eststo clear
local vlist "dur bm em g lev oplev me_b "
gstats winsor `vlist',by(post) replace cuts(1 99) 
local vlist "dur bm em g lev oplev me_b ret"
local upper
local lower `vlist'
expand 2, g(version)
foreach v of local vlist {
    gegen rank = rank(`v') if version == 1  
    replace `v' = rank if version ==1
    drop rank
}
foreach v of local vlist {
   estpost correlate `v' `lower' if version == 0
   foreach m in b rho p count {
       matrix `m' = e(`m')
   }
   if "`upper'"!="" {
   estpost correlate `v' `upper' if version == 1
       foreach m in b rho p count {
           matrix `m' = e(`m'), `m'
       }
   }
   ereturn post b
   foreach m in rho p count {
       quietly estadd matrix `m' = `m'
   }
   eststo `v', title(`v')
   local lower: list lower - v
   local upper `upper' `v'
 }

esttab using "$path/t1_`i'.tex", /// 
label nonumbers mtitles noobs not tex nostar b(%8.2f) substitute(\_ _) ///
mti( "Dur" "BE/ME" "E/ME" "SaleGr" "FinLev" "OpLev" "ME" "ExRet") replace
restore
}

*Table 2 ***********************************************************************
use $panel,clear
rename *,lower
rename ddate date
keep if year(date)==2020
g lret=ln(1+ret)
gegen ret2020=sum(lret),by(permno)
replace ret2020=(exp(ret2020)-1)*100
keep if year(date)==2020 & month(date)==1 & day(date)==2
keep if dur!=.
ffind siccd, newvar(ff49) type(49)
preserve
gstats winsor dur,cuts(1 99) replace 
gcollapse (mean) mean=dur (sd) sd=dur (p25) p25=dur (p50) p50=dur (p75) p75=dur (count) num=dur,by(ff49) fast
expand 2
forvalues i=1/49{
foreach ds in mean sd p25 p50 p75 num{
reg `ds' if ff49==`i'
mat `ds'`i'=_b[_cons] 
}
mat ff`i'=(mean`i',sd`i',p25`i',p50`i',p75`i',num`i') 
}
restore

gcollapse (mean) dur ret2020,by(ff49)
corr dur ret2020
expand 2
forvalues i=1/49{
reg ret2020 if ff49==`i'
mat ff`i'=(ff`i',_b[_cons])
}
mat table=(ff29)
local ff="ff25 ff30 ff4 ff28 ff46 ff32 ff23 ff45 ff18 ff19 ff47 ff16 ff39 ff48 ff14 ff10 ff43 ff42 ff20 ff41 ff7 ff44 ff8 ff21 ff24 ff17 ff9 ff31 ff1 ff6 ff33 ff37 ff40 ff15 ff11 ff22 ff34 ff2 ff27 ff26 ff3 ff38 ff35 ff49 ff13 ff12 ff5 ff36"
foreach x in `ff'{
mat table=(table \ `x')
}
mat avg=ff1
forvalues i=2/49{
mat avg=avg+ff`i'
}
mat avg=avg/49
mat table=(table \ avg)
frmttable using "$path/ind_dur", ///
replace tex fragment statmat(table) coljust(lc) squarebrack sdec(2) ///
ctitles("Industry","Dur. Mean","Dur. SD","Dur. P25","Dur. P50","Dur. P75","N","2020 Q1 Return") ///
rtitles("Coal" \ ///
"Shipbuilding, Railroad Equipment" \ ///
"Petroleum and Natural Gas" \ ///
"Beer \& Liquor" \ ///
"Non-Metallic and Industrial Metal Mining" \ ///
"Insurance" \ ///
"Communication" \ ///
"Automobiles and Trucks" \ ///
"Banking" \ ///
"Construction" \ ///
"Steel Works Etc" \ ///
"Real Estate" \ ///
"Textiles" \ ///
"Business Supplies" \ ///
"Trading" \ ///
"Chemicals" \ ///
"Apparel" \ ///
"Retail" \ ///
"Wholesale" \ ///
"Fabricated Products" \ ///
"Transportation" \ ///
"Entertainment" \ ///
"Restaurants, Hotels, Motels" \ ///
"Printing \& Publishing" \ ///
"Machinery" \ ///
"Aircraft" \ ///
"Construction Materials" \ ///
"Consumer Goods" \ ///
"Utilities" \ ///
"Agriculture" \ ///
"Recreation" \ ///
"Personal Services" \ ///
"Electronic Equipment" \ ///
"Shipping Containers" \ ///
"Rubber and Plastic Products" \ ///
"Healthcare" \ ///
"Electrical Equipment" \ ///
"Business Services" \ ///
"Food Products" \ ///
"Precious Metals" \ ///
"Defense" \ ///
"Candy \& Soda" \ ///
"Measuring and Control Equipment" \ ///
"Computer Hardware" \ ///
"Other" \ ///
"Pharmaceutical Products" \ ///
"Medical Equipment" \ ///
"Tobacco Products" \ ///
"Computer Software" \ ///
"\hline Average FF49 Industry")

*Tables 3-5 / Figures 2-3 ******************************************************
use $port,clear
g yearmo=year(ddate)*100+month(ddate)
keep if yearmo>=196401
g post=0 if yearmo<=201912  
replace post=1 if inrange(yearmo,202001,202003) 
replace dret=dret*100 // decimal -> percent 
replace dmktrf=dmktrf*100 // decimal -> percent 
g b=.
g capm_a=.
rename sortvarmean mean_

foreach m in durr bmr emr{
if "`m'"=="durr"{
local title="Duration" // durr = duration quintile rank
}

if "`m'"=="bmr"{
local title="Book-to-market" // bmr = be/me quintile rank
} 

if "`m'"=="emr"{
local title="Earnings-to-price" // emr = earnings/me quintile rank
} 

forvalues w=0/1{
preserve
keep if sortvar=="`m'" & vw==`w'
rename dret ret
gegen vola=sd(ret),by(port post)
g h=0 if port==1
replace h=1 if port==5
forvalues j=0/1{
sdtest ret if post==`j',by(h)
if r(p)>=.1{
mat starvola`j'=0
}
if r(p)<.1{
mat starvola`j'=1
}
if r(p)<.05{
mat starvola`j'=2
}
if r(p)<.01{
mat starvola`j'=3
}

if r(F)>=1{
mat f`j'=(r(F))
}
if r(F)<1{
mat f`j'=(1/r(F))
}
}
replace mean_=. if month(ddate)!=1 // keep portfolio chars. at beginning of year

*annualize returns and volatility 
g mktret=dmktrf*252 
replace ret=ret*252
replace vola=vola*sqrt(252) 

sort port ddate
g mktret_1=mktret[_n-1] if port==port[_n-1]
g mktret1=mktret[_n+1] if port==port[_n+1]
replace mktret1=-4.51*252 if mktret1==. // market return on 4/1/20 from K. French 
g b_d=.
g capm_a_d=.

forvalues j=1/5{
forvalues i=0/1{
*Dimson Beta
reg ret mktret mktret_1 mktret1 if port==`j' & post==`i'
replace b_d=_b[mktret_1]+_b[mktret]+_b[mktret1] if port==`j' & post==`i'
replace capm_a_d=_b[_cons] if port==`j' & post==`i'
}
}

local vars="ret b_d vola mean_"

*Gen 5-1 hedges: 
sort ddate port
foreach x in `vars'{
g `x'h51=`x'-`x'[_n-4] if port==5 & port[_n-4]==1
}
*Tables
foreach x in `vars'{
forvalues j=0/1{
mat `x'_`j'=(.)
forvalues i=1/5{
reg `x' if post==`j' & port==`i'
mat `x'`i'_`j'=(_b[_cons],.)
if inlist("`x'","b", "vola"){
mat `x'`i'=(_b[_cons],.)
}
if `i'==2{
matselrc `x'_`j' `x'_`j', col(2/3) 
}
mat `x'_`j'=(`x'_`j',`x'`i'_`j')
}
}
}

foreach x in ret{
forvalues j=0/1{
reg `x'h51 if post==`j'
mat `x'_`j'=(`x'_`j',_b[_cons],_b[_cons]/_se[_cons])
local p=2*ttail(e(df_r),abs(_b[_cons]/_se[_cons]))
if `p'>=.1{
mat star`x'`j'=0
}
if `p'<.1{
mat star`x'`j'=1
}
if `p'<.05{
mat star`x'`j'=2
}
if `p'<.01{
mat star`x'`j'=3
}
}
}

foreach x in mean_{
forvalues j=0/1{
reg `x'h51 if post==`j'
mat `x'_`j'=(`x'_`j',_b[_cons],.)
mat star`x'`j'=0
}
}

foreach x in vola{
forvalues j=0/1{
reg `x'h51 if post==`j'
mat `x'_`j'=(`x'_`j',_b[_cons],f`j')
}
}

forvalues j=0/1{
*Dimson betas
mat dalpha_`j'=(.)
mat dbeta_`j'=(.)
forvalues i=1/5{
reg ret mktret mktret_1 mktret1 if post==`j' & port==`i'
mat dalpha_`j'=(dalpha_`j',_b[_cons],.)
mat dbeta_`j'=(dbeta_`j',_b[mktret]+_b[mktret1]+_b[mktret_1],.)

if `i'==1{
matselrc dalpha_`j' dalpha_`j', col(2/3) 
matselrc dbeta_`j' dbeta_`j', col(2/3) 
}
}

reg reth51 mktret mktret_1 mktret1 if post==`j' 
mat dalpha_`j'=(dalpha_`j',_b[_cons],_b[_cons]/_se[_cons])
mat dbeta_`j'=(dbeta_`j',_b[mktret]+_b[mktret1]+_b[mktret_1])

local palpha=2*ttail(e(df_r),abs(_b[_cons]/_se[_cons]))

test (_b[mktret]+_b[mktret1]+_b[mktret_1])=0

mat dbeta_`j'=(dbeta_`j',r(F))

mat dstarbeta`j'=0
if r(p)<.1{
mat dstarbeta`j'=1 
}
if r(p)<.05{
mat dstarbeta`j'=2 
}
if r(p)<.01{
mat dstarbeta`j'=3 
}

if `palpha'>=.1{
mat dstaralpha`j'=0
}
if `palpha'<.1{
mat dstaralpha`j'=1
}
if `palpha'<.05{
mat dstaralpha`j'=2
}
if `palpha'<.01{
mat dstaralpha`j'=3
}

}

mat tab=(mean__1 \ mean__0 \ ret_1 \ ret_0  \ dalpha_1 \ dalpha_0 \ dbeta_1 \ dbeta_0 \ vola_1 \ vola_0 )
mat star=(starmean_1,0 \ starmean_0,0 \ starret1,0 \ starret0,0 \ dstaralpha1,0 \ dstaralpha0, 0 \ dstarbeta1, 0 \ dstarbeta0,0 \ starvola1,0 \ starvola0,0)
mat star=(J(10,10,0),star)
frmttable using "$path/t_vw`w'_`m'.tex", ///
replace tex fragment statmat(tab) substat(1) coljust(c) squarebrack  annotate(star) asymbol("*","**","***") ///
sdec(2) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{`title'} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("\rowcolor{Gray} `title' (01/20 - 03/20)" \"\rowcolor{Gray}"\" `title' (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Excess return (01/20 - 03/20)" \"\rowcolor{Gray}"\"Excess return (01/64 - 12/19)"\""\  ///
"\rowcolor{Gray} $ \alpha\sb{\text{CAPM}} $  (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \alpha\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} $ \beta\sb{\text{CAPM}} $ (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \beta\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Volatility (01/20 - 03/20)" \"\rowcolor{Gray}"\"Volatility (01/64 - 12/19)")


if inlist("`m'","durr"){
frmttable using "$path/t_vw`w'_`m'.tex", ///
replace tex fragment statmat(tab) substat(1) coljust(c) squarebrack  annotate(star) asymbol("*","**","***") ///
sdec(2) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{`title'} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("\rowcolor{Gray} `title' (01/20 - 03/20)" \"\rowcolor{Gray}"\" `title' (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Excess return (01/20 - 03/20)" \"\rowcolor{Gray}"\"Excess return (01/64 - 12/19)"\""\  ///
"\rowcolor{Gray} $ \alpha\sb{\text{CAPM}} $  (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \alpha\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} $ \beta\sb{\text{CAPM}} $ (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \beta\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Volatility (01/20 - 03/20)" \"\rowcolor{Gray}"\"Volatility (01/64 - 12/19)")
}

if "`m'"=="durr"{
local vars="ret vola b_d capm_a_d"

gcollapse (mean) `vars',by(port post) fast
local v=""
foreach x in `vars'{
g `x'0=`x' if post==0
g `x'1=`x' if post==1
local v="`v' `x'0 `x'1"
}

gcollapse (firstnm) `v',by(port) fast
label var ret0 "01/64 - 12/19"
label var ret1 "01/20 - 03/20"
label var capm_a_d0 "01/64 - 12/19"
label var capm_a_d1 "01/20 - 03/20"
label var b_d0 "01/64 - 12/19"
label var b_d1 "01/20 - 03/20"
label var vola0 "01/64 - 12/19"
label var vola1 "01/20 - 03/20"
label var port "`title'"

if `w'==0{
local mina=5
local ra=5
local maxa=25
}
if `w'==1{
local mina=-2
local ra=2
local maxa=4
}

if `w'==0{
local minr=10
local rr=5
local maxr=30
}

if `w'==1{
local minr=5
local rr=1
local maxr=10
}

local s="huge"

twoway (line ret1 ret0 port), ytitle("Excess return (% annualized)" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(-200(50)50,nogrid labsize(`s')) xlabel(1(1)5,labsize(`s')) ///
legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5)) 
graph export "$path/ret1_vw`w'_`m'.eps",replace fontface(Cmr10)

twoway (line capm_a_d1 capm_a_d0 port,lpattern(solid dash )), ytitle("CAPM alpha (% annualized)" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(-100(50)50,nogrid labsize(`s')) ///
xlabel(1(1)5,labsize(`s')) legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5))  
graph export "$path/dalpha1_vw`w'_`m'.eps",replace fontface(Cmr10)

twoway (line b_d1 b_d0 port,lpattern(solid dash )), ytitle("CAPM beta" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(.6(.2)1.4,nogrid labsize(`s')) ///
xlabel(1(1)5,labsize(`s')) legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5))  
graph export "$path/dbeta_vw`w'_`m'.eps",replace fontface(Cmr10)

twoway (line vola1 vola0 port,lpattern(solid dash )), ytitle("Volatility (% annualized)" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(10(20)80,nogrid labsize(`s')) ///
xlabel(1(1)5,labsize(`s')) legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5))  
graph export "$path/vola_vw`w'_`m'.eps",replace fontface(Cmr10)

}
restore
}
}


*Figure 4 *********************************************************************
preserve
g ret=dret/100
g mktret=dmktrf/100

g dur5_vw=ret if sortvar=="durr" & port==5 & vw==1
g dur1_vw=ret if sortvar=="durr" & port==1 & vw==1

g dur5_ew=ret if sortvar=="durr" & port==5 & vw==0
g dur1_ew=ret if sortvar=="durr" & port==1 & vw==0

gcollapse (firstnm) dur1_vw dur5_vw dur1_ew dur5_ew mktret,by(ddate)
g year=year(ddate)
g dur_ew=ln(1+dur5_ew-dur1_ew)
g dur_vw=ln(1+dur5_vw-dur1_vw)
replace mktret=ln(1+mktret)

gcollapse (sum) dur_ew dur_vw mktret,by(year)
foreach x in dur_ew dur_vw mktret{
replace `x'=100*(exp(`x')-1)
}

replace dur_ew=-dur_ew 
replace dur_vw=-dur_vw 

local min=-50
local max=50
g rec1=`min' if (y>=1969&y<=1970)
g rec2=`min' if (y>=1973&y<=1975)
g rec3=`min' if (y>=1980&y<=1982)
g rec5=`min' if (y>=1990&y<=1991)
g rec6=`min' if (y>=2001&y<=2001)
g rec7=`min' if (y>=2008&y<=2009)
g rec8=`min' if (y==2020)

g rec_1=`max' if (y>=1969&y<=1970)
g rec_2=`max' if (y>=1973&y<=1975)
g rec_3=`max' if (y>=1980&y<=1982)
g rec_5=`max' if (y>=1990&y<=1991)
g rec_6=`max' if (y>=2001&y<=2001)
g rec_7=`max' if (y>=2008&y<=2009)
g rec_8=`max' if (y==2020)

foreach x in dur_vw dur_ew{
corr `x' mktret if y<2020
local corr=round(10000*r(rho))/100
twoway ///
(area rec1 y, bcolor(gs14)) ///
(area rec2 y, bcolor(gs14)) ///
(area rec3 y, bcolor(gs14)) ///
(area rec5 y, bcolor(gs14)) ///
(area rec6 y, bcolor(gs14)) ///
(area rec7 y, bcolor(gs14)) /// 
(area rec_1 y, bcolor(gs14)) ///
(area rec_2 y, bcolor(gs14)) ///
(area rec_3 y, bcolor(gs14)) ///
(area rec_5 y, bcolor(gs14)) ///
(area rec_6 y, bcolor(gs14)) ///
(area rec_7 y, bcolor(gs14)) /// 
(line  dur_vw mktret y,lpattern(solid dash) lcolor(cranberry navy))  , xline(2020,lcolor(gs14)) ///
text(-45 2000 "Corr. Dur, Mkt: `corr'% ", box placement(w) bcolor(white)) ///
title("") ytitle("Return") ylab(-50(20)50,nogrid) yline(0) /// 
xtitle("") legend(on) plotregion(margin(zero)) graphregion(color(white)) ///
legend(pos(7) ring(0) col(1) order(13 14) label(13 "Duration") label(14 "Market") ///
region(lstyle(color(white)))) xlab(1964(4)2020,angle(45)) xtitle("Year")
graph export "$path/ts_`x'.eps",replace fontface(Cmr10)
}
restore

*Figure 5 *********************************************************************
forvalues w=0/1{
preserve
keep if sortvar=="durr" & vw==`w' & year(ddate)==2020
sort ddate
expand 5
replace dret=ln(1+dret/100) // for compounding 
forvalues i=1/5{
g r`i'=dret if port==`i'
}
gcollapse (firstnm) r1-r5,by(ddate)
sort ddate
forvalues i=1/5{
g cr`i'=r`i' if r`i'[_n-1]==.
replace cr`i'=r`i'+cr`i'[_n-1] if cr`i'==.
replace cr`i'=100*(exp(cr`i')-1)
}

local wu=date("01232020","MDY")
local it=date("02222020","MDY")
local eu=date("03112020","MDY")
local ne=date("03132020","MDY")
local st=date("03242020","MDY")
local d1=date("01022020","MDY")
local d2=date("02032020","MDY")
local d3=date("03022020","MDY")
local d4=date("03312020","MDY")

tsset ddate
twoway (line cr1-cr5 ddate,lcolor(emerald teal eltgreen olive_teal gray)), ///
legend(pos(7) ring(0) col(1) order(5 4 3 2 1) label(1 "Low Duration") label(2 "Q2") label(3 "Q3")  ///
label(4 "Q4") label(5 "High Duration") region(lstyle(color(white)))) xtitle("Date") ///
plotregion(margin(zero)) graphregion(color(white)) ylabel(-60(20)20,nogrid) ///
xline(`wu' `it' `eu' `ne' `st', lpat(dash)) ///
text(-20 `wu' "Wuhan lockdown",placement(w) orientation(vertical)) ///
text(-20 `it' "Italy quarantine",placement(w) orientation(vertical)) ///
text(-48 `eu' "EU Travel Ban",placement(w) orientation(vertical)) ///
text(10 `ne' "Natl. Emer.",placement(e) orientation(vertical)) ///
text(10 `st' "Fiscal stimulus",placement(e) orientation(vertical)) ///
xlabel(`d1' "Jan 2" `d2' "Feb 3" `d3' "Mar 2" `d4' "Mar 31      ") ytitle("Cumulative Excess Return")
graph export "$path/etime_vw`w'.eps",replace fontface(Cmr10)
restore
}

*Table 6 ***********************************************************************
use $panel, clear
rename *,lower
rename ddate date
keep if year(date)==2020
*Merge IBES data
g PERMNO=permno
joinby PERMNO using $ibes,unm(master)
drop PERMNO

g revision=100*((e_eps_may-e_eps_dec)/prc_a) // Q2 quarterly forecast revision (%)
g fy2p=100*(e_eps_fy2_dec/prc_a) // FY 2 consensus annual EPS (%)
g fep=100*((actual-e_eps_dec)/prc_a) // Q2 forecast error (relative to Dec. consensus) (%)
replace ret=(ret*100*252) // annualized percent 
g me_b=me_crsp/1000
g bm=bveq/me_crsp if bveq>0
replace bm=(bve/me_crsp) if bveq==. & bve>0 
g em=ibq4/me_crsp if ibq4>0
replace em=ib/me_crsp if ibq4==. & ib>0

sort permno date
foreach x in dur bm em lev oplev me_b ibq4 ib{
replace `x'=. if month(date)>1 
replace `x'=`x'[_n-1] if `x'==. & permno==permno[_n-1] // values as of Dec 31, 2019
}

label var dur "Duration"
label var bm "BE/ME"
label var em "Earnings/ME"
label var me_b "ME"
label var lev "Financial leverage"
label var oplev "Operating leverage"
label var ret "Excess return"

preserve
keep if month(date)==1 & day(date)==2
count if revision>0 & revision!=.
count if revision<0 & revision!=.
fasterxtile durr=dur,by(date) n(5)
gstats winsor revision fy2p fep,cuts(1 99) replace
foreach y in revision fy2p fep{
foreach x in durr{
g hi=1 if `x'==5
replace hi=0 if `x'==1
forvalues i=1/5{
reg `y' if `x'==`i'
mat y`i'ew=(_b[_cons],.)
reg `y' if `x'==`i' [w=me]
mat y`i'vw=(_b[_cons],.)
mat n`i'=e(N)
}
mat n`x'=(n1,.,n2,.,n3,.,n4,.,n5,.,.,.)
reg `y' hi
mat `x'ew=(y1ew,y2ew,y3ew,y4ew,y5ew, _b[hi],_b[hi]/_se[hi])

local pvalue=2*ttail(e(df_r),abs(_b[hi]/_se[hi]))

if `pvalue'>=.1{
mat `x'sew=0
}
if `pvalue'<.1{
mat `x'sew`j'=1
}
if `pvalue'<.05{
mat `x'sew`j'=2
}
if `pvalue'<.01{
mat `x'sew`j'=3
}

reg `y' hi [w=me]
mat `x'vw=(y1vw,y2vw,y3vw,y4vw,y5vw,_b[hi],_b[hi]/_se[hi])
local pvalue=2*ttail(e(df_r),abs(_b[hi]/_se[hi]))
if `pvalue'>=.1{
mat `x'svw=0
}
if `pvalue'<.1{
mat `x'svw`j'=1
}
if `pvalue'<.05{
mat `x'svw`j'=2
}
if `pvalue'<.01{
mat `x'svw`j'=3
}

drop hi
}
mat dur`y'vw=(durrvw \ ndurr)
mat dur`y'ew=(durrew \ ndurr)
mat stardurvw=(durrsvw,0)
mat stardurew=(durrsew,0)
mat stardur`y'vw=(J(1,10,0),stardurvw)
mat stardur`y'ew=(J(1,10,0),stardurew)
}
mat durvw=(durfy2pvw \ durrevisionvw \ durfepvw)
mat durew=(durfy2pew \ durrevisionew \ durfepew)
mat stardurvw=(stardurfy2pvw \ J(1,12,0)  \ stardurrevisionvw  \ J(1,12,0) \ stardurfepvw)
mat stardurew=(stardurfy2pew \ J(1,12,0)  \ stardurrevisionew  \ J(1,12,0) \ stardurfepew)

frmttable using "$path/durvwibes.tex", ///
replace tex fragment statmat(durvw) substat(1) coljust(c) squarebrack  annotate(stardurvw) asymbol("*","**","***") ///
sdec(2 \ 2 \ 0 \ 0 \ 2\ 2 \ 0 \ 0 \ 2 \ 2 \ 0 \ 0) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{Duration} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("Pre-pandemic Forward Yield (FY2/P)" \"" \ "N"\""\ "Q2 2020 Earnings Revision" \ ""\"N"\""\"Q2 2020 Earnings Surprise"\""\"N")

frmttable using "$path/durewibes.tex", ///
replace tex fragment statmat(durew) substat(1) coljust(c) squarebrack  annotate(stardurew) asymbol("*","**","***") ///
sdec(2 \ 2 \ 0 \ 0 \ 2\ 2 \ 0 \ 0 \ 2 \ 2 \ 0 \ 0) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{Duration} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("Pre-pandemic Forward Yield (FY2/P)" \"" \ "N"\""\ "Q2 2020 Earnings Revision" \ ""\"N"\""\"Q2 2020 Earnings Surprise"\""\"N")
restore



*Tables 7-9 ********************************************************************

*Table 7: Full Sample
forvalues j=7/9{
preserve

*Table 8: Drop stocks with positive cumulative 2020 Q1 returns
if `j'==8{
g lret=ln(1+ret/25200)
gegen ret2020=sum(lret),by(permno)
keep if (exp(ret2020)-1)<0 & ret2020!=.
}

*Table 9: Drop stocks with positive revisions for Q2 EPS in the IBES subsample
if `j'==9{
keep if revision != . & revision<0
}
drop if dur==. // constant sample
foreach x in dur bm em lev oplev me_b{
fasterxtile r=`x',by(date) n(5)
replace `x'=(r-1)/4
drop r 
}

replace em=0 if ibq4<0
replace em=0 if em==. & ib<0
g loss=(ibq4<0)
replace loss=1 if ibq4==. & ib<0
replace loss=. if ibq4==. & ib==.
replace lev=0 if lev==. 
replace oplev=0 if oplev==. 

label var loss "Loss"
ffind siccd, newvar(ff49) type(49)
forvalues i=1/49{
g ff__`i'=(ff49==`i')
}

g multi=(pifo!=. | txfo !=. | txdfo !=.)
label var multi "MNC"
sort date
gegen t=group(date)

tsset permno t
local cont= "lev oplev loss me_b multi"

eststo clear
foreach v in dur bm em{
eststo:asreg ret `v' `cont',fmb
estadd local ind_fe "No"
estadd local avgn = round(e(N)/62)
eststo:asreg ret `v' `cont' ff__1-ff__48,fmb 
estadd local ind_fe "Yes" 
estadd local avgn =round(e(N)/62)
}

esttab using "$path/fm_ew_`j'.tex", ///
label b(%8.2f) stats(adjr2 ind_fe avgn, fmt(%8.3f) labels(`"Avg. Adj. $ R^2 $ "' "FF 49 Indicators" "Avg. N"))   ///
brackets nonotes substitute(\_ _) star(* 0.10 ** 0.05 *** 0.01) ///
keep(dur bm em `cont') order(dur bm em  `cont') nomti   mgroups("Daily excess return $\times$ 252 ", pattern(1 0 0 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
alignment(D{.}{.}{-1}) replace


local cont= "lev oplev loss me_b multi"
*Weighted FM
eststo clear
foreach v in dur bm em{
eststo:fmb ret `v' `cont' [w=me]
estadd local ind_fe "No" 
estadd local avgn = round(e(N)/62)
eststo:fmb ret `v' `cont' ff__1-ff__48 [w=me]
estadd local ind_fe "Yes" 
estadd local avgn = round(e(N)/62)
}

esttab using "$path/fm_vw_`j'.tex", ///
label b(%8.2f) stats(r2 ind_fe avgn, fmt(%8.3f) labels(`"Avg. Adj. $ R^2 $ "' "FF 49 Indicators" "Avg. N"))   ///
 brackets nonotes substitute(\_ _) star(* 0.10 ** 0.05 *** 0.01) ///
keep(dur bm em `cont') order(dur bm em  `cont') nomti  mgroups("Daily excess return $\times$ 252 ", pattern(1 0 0 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
alignment(D{.}{.}{-1}) replace
restore
}

*Figure 6 **********************************************************************
*Add Factset data
keep if date==date("01022020","MDY") // use rankings at beginning of year
fasterxtile durr=dur,by(date) n(5)
append using $fs
sort permno date
replace durr=durr[_n-1] if permno==permno[_n-1]
keep if month(date)==11

*Duration portfolio returns around good news about vaccine efficacy 
forvalues w=0/1{
preserve
if `w'==0{
gcollapse (mean) ret,by(date durr)
}

if `w'==1{
replace me=1 if date==date("11052020","MDY")
gcollapse (mean) ret [w=me],by(date durr)
}

sort date
expand 5
keep if inrange(date,date("11052020","MDY"),date("11172020","MDY"))
replace ret=0 if date==date("11052020","MDY")

replace ret=ln(1+ret)
forvalues i=1/5{
g r`i'=ret if durr==`i'
}
gcollapse (firstnm) r1-r5,by(date)

sort date

forvalues i=1/5{
g cr`i'=0 if r`i'[_n-1]==.
replace cr`i'=r`i'+cr`i'[_n-1] if cr`i'==.
replace cr`i'=100*(exp(cr`i')-1)
}

tsset date

gegen t=group(date)

g v1=14 if t==2 | t==3
g v2=14 if t==7 | t==8
g v_1=-4 if t==2 | t==3
g v_2=-4 if t==7 | t==8

local esize = "medsmall"
label var t "Date"
twoway (area v1 t, bcolor(gs15)) (area v_1 t, bcolor(gs15)) ///
(area v2 t, bcolor(gs15)) (area v_2 t, bcolor(gs15)) ///
(line cr1-cr5 t,lcolor(emerald teal eltgreen olive_teal gray) lpattern(solid dash shortdash dash_dot longdash  )) , ///
legend(pos(12) ring(1) col(5) order(5 6 7 8 9) label(5 "Low Duration") label(6 "Q2") label(7 "Q3")  ///
label(8 "Q4") label(9 "High Duration") size(medsmall) region(lstyle(color(white)))) xtitle("Date") ///
plotregion(margin(zero)) graphregion(color(white)) ylabel(-4(2)14,nogrid) yscale(range(-4 16) noextend)  ///
text(15 1.95 "Pfizer 90%",placement(e) orientation(horizontal) size(`esize')) ///
text(15 6.7 "Moderna 94.5%",placement(e) orientation(horizontal) size(`esize')) ///
xlabel(1 "Nov 5" 2 "Nov 6" 3 "Nov 9" 4 "Nov 10" 5 "Nov 11" 6 "Nov 12" 7 "Nov 13" 8 "Nov 16" 9 "Nov 17   " ) ///
ytitle("Cumulative Excess Return (%)" " ") 
graph export "$path/etime_vw`w'_vn.eps",replace fontface(Cmr10)
restore
}

* End of Code ******************************************************************
/*******************************************************************************
.do file for "Implied Equity Duration: A Measure of Pandemic Shutdown Risk"
Dechow, Erhard, Sloan, and Soliman [2021], Journal of Accounting Research
*******************************************************************************/

clear
set graphics off

*Overleaf output
global path "/Users/rde/Dropbox/Apps/Overleaf/Duration JAR Final/Results"

*Daily panel data (downloaded via WRDS cloud on 5/14/20)
global panel "/Users/rde/Dropbox/Duration_JAR/Data/duration_panel.dta" 

*Daily portfolio data (downloaded via WRDS cloud on 5/14/20)
global port "/Users/rde/Dropbox/Duration_JAR/Data/duration_portfolios.dta" 

*IBES and MNC data (downloaded via WRDS cloud on 1/4/21)
global ibes "/Users/rde/Dropbox/Duration_JAR/Data/ibes_2020q2.dta" 

*FactSet Returns for 11/6/20-11/16/20 (downloaded via FactSet on 11/19/20)
global fs "/Users/rde/Dropbox/Duration_JAR/Data/FactSetReturns110520_111720.dta"

/* 
Requires packages: 
gtools [ssc install gtools]
asreg [ssc install asreg] 
fmb [run fmb.ado]
ffind [run ffind.ado]
*/


*Table 1 ***********************************************************************
use $panel,clear
rename *,lower
g post=year(ddate)==2020
rename ddate date
keep if year(date)>=1964
replace ret=(ret*25200) // daily decimal -> annualized percent 
g me_b=me_crsp/1000
g bm=bveq/me_crsp if bveq>0
replace bm=(bve/me_crsp) if bveq==. & bve>0 
g em=ibq4/me_crsp if ibq4>0
replace em=ib/me_crsp if ibq4==. & ib>0
sort permno date
foreach x in dur bm em lev oplev me_b ibq4 ib{
replace `x'=. if month(date)>1 & post==1
replace `x'=`x'[_n-1] if `x'==. & post==1 & permno==permno[_n-1] // values as of Dec 31, 2019
}

label var dur "Duration"
label var bm "BE/ME"
label var em "Earnings/ME"
label var lev "Financial leverage"
label var oplev "Operating leverage"
label var ret "Excess return"
label var me_b "ME (bn)"
label var g "Sales growth"

* Panel A: Distributions *
foreach x in dur bm em g lev oplev me_b ret{
preserve
if "`x'"!="ret"{
gstats winsor `x',by(post) cuts(1 99) replace // winsorize non-returns at 1% tails
}
ttest `x',by(post)
mat `x't=(r(mu_2)-r(mu_1))
if r(p)>=.1{
mat `x's=0
}
if r(p)<.1{
mat `x's=1
}
if r(p)<.05{
mat `x's=2
}
if r(p)<.01{
mat `x's=3
}
gcollapse (mean) mean`x'=`x' (sd) sd`x'=`x' (p50) p50`x'=`x',by(post) fast
expand 2
forvalues i=0/1{
foreach ds in mean sd p50{
reg `ds'`x' if post==`i'
mat `ds'`x'`i'=_b[_cons] 
}
mat `x'`i'=(mean`x'`i',p50`x'`i',sd`x'`i')
}
mat `x'=(`x'1,.,`x'0,`x't)
restore
}
mat table=(dur)
mat stars=(durs)
foreach x in  bm em g lev oplev me_b ret{
mat table=(table \ `x')
mat stars=(stars \ `x's)
}
mat stars=(J(8,7,0),stars)
frmttable using "$path/t1a", ///
replace tex fragment statmat(table) coljust(lc) squarebrack sdec(2) annotate(stars) asymbol("*","**","***") ///
ctitles("\hline \noalign{\smallskip} & \multicolumn{3}{c}{ \uline{\hfill 2020 \hfill}}  & & \multicolumn{3}{c}{\uline{\hfill 1964-2019 \hfill}} "  \ ///
 "Variable","Mean","Median","SD","","Mean","Median", "SD","Dif. in Means") ///
rtitles("Duration" \  "BE/ME" \ "Earnings/ME" \ "Sales growth" \ "Financial leverage" \ "Operating leverage" \ "ME (bn)" \ " Excess return (annualized)")

* Panels B,C: Correlations *
forvalues i=0/1{
preserve
keep post dur bm em lev oplev me_b ret date g
keep if post==`i'
eststo clear
local vlist "dur bm em g lev oplev me_b "
gstats winsor `vlist',by(post) replace cuts(1 99) 
local vlist "dur bm em g lev oplev me_b ret"
local upper
local lower `vlist'
expand 2, g(version)
foreach v of local vlist {
    gegen rank = rank(`v') if version == 1  
    replace `v' = rank if version ==1
    drop rank
}
foreach v of local vlist {
   estpost correlate `v' `lower' if version == 0
   foreach m in b rho p count {
       matrix `m' = e(`m')
   }
   if "`upper'"!="" {
   estpost correlate `v' `upper' if version == 1
       foreach m in b rho p count {
           matrix `m' = e(`m'), `m'
       }
   }
   ereturn post b
   foreach m in rho p count {
       quietly estadd matrix `m' = `m'
   }
   eststo `v', title(`v')
   local lower: list lower - v
   local upper `upper' `v'
 }

esttab using "$path/t1_`i'.tex", /// 
label nonumbers mtitles noobs not tex nostar b(%8.2f) substitute(\_ _) ///
mti( "Dur" "BE/ME" "E/ME" "SaleGr" "FinLev" "OpLev" "ME" "ExRet") replace
restore
}

*Table 2 ***********************************************************************
use $panel,clear
rename *,lower
rename ddate date
keep if year(date)==2020
g lret=ln(1+ret)
gegen ret2020=sum(lret),by(permno)
replace ret2020=(exp(ret2020)-1)*100
keep if year(date)==2020 & month(date)==1 & day(date)==2
keep if dur!=.
ffind siccd, newvar(ff49) type(49)
preserve
gstats winsor dur,cuts(1 99) replace 
gcollapse (mean) mean=dur (sd) sd=dur (p25) p25=dur (p50) p50=dur (p75) p75=dur (count) num=dur,by(ff49) fast
expand 2
forvalues i=1/49{
foreach ds in mean sd p25 p50 p75 num{
reg `ds' if ff49==`i'
mat `ds'`i'=_b[_cons] 
}
mat ff`i'=(mean`i',sd`i',p25`i',p50`i',p75`i',num`i') 
}
restore

gcollapse (mean) dur ret2020,by(ff49)
corr dur ret2020
expand 2
forvalues i=1/49{
reg ret2020 if ff49==`i'
mat ff`i'=(ff`i',_b[_cons])
}
mat table=(ff29)
local ff="ff25 ff30 ff4 ff28 ff46 ff32 ff23 ff45 ff18 ff19 ff47 ff16 ff39 ff48 ff14 ff10 ff43 ff42 ff20 ff41 ff7 ff44 ff8 ff21 ff24 ff17 ff9 ff31 ff1 ff6 ff33 ff37 ff40 ff15 ff11 ff22 ff34 ff2 ff27 ff26 ff3 ff38 ff35 ff49 ff13 ff12 ff5 ff36"
foreach x in `ff'{
mat table=(table \ `x')
}
mat avg=ff1
forvalues i=2/49{
mat avg=avg+ff`i'
}
mat avg=avg/49
mat table=(table \ avg)
frmttable using "$path/ind_dur", ///
replace tex fragment statmat(table) coljust(lc) squarebrack sdec(2) ///
ctitles("Industry","Dur. Mean","Dur. SD","Dur. P25","Dur. P50","Dur. P75","N","2020 Q1 Return") ///
rtitles("Coal" \ ///
"Shipbuilding, Railroad Equipment" \ ///
"Petroleum and Natural Gas" \ ///
"Beer \& Liquor" \ ///
"Non-Metallic and Industrial Metal Mining" \ ///
"Insurance" \ ///
"Communication" \ ///
"Automobiles and Trucks" \ ///
"Banking" \ ///
"Construction" \ ///
"Steel Works Etc" \ ///
"Real Estate" \ ///
"Textiles" \ ///
"Business Supplies" \ ///
"Trading" \ ///
"Chemicals" \ ///
"Apparel" \ ///
"Retail" \ ///
"Wholesale" \ ///
"Fabricated Products" \ ///
"Transportation" \ ///
"Entertainment" \ ///
"Restaurants, Hotels, Motels" \ ///
"Printing \& Publishing" \ ///
"Machinery" \ ///
"Aircraft" \ ///
"Construction Materials" \ ///
"Consumer Goods" \ ///
"Utilities" \ ///
"Agriculture" \ ///
"Recreation" \ ///
"Personal Services" \ ///
"Electronic Equipment" \ ///
"Shipping Containers" \ ///
"Rubber and Plastic Products" \ ///
"Healthcare" \ ///
"Electrical Equipment" \ ///
"Business Services" \ ///
"Food Products" \ ///
"Precious Metals" \ ///
"Defense" \ ///
"Candy \& Soda" \ ///
"Measuring and Control Equipment" \ ///
"Computer Hardware" \ ///
"Other" \ ///
"Pharmaceutical Products" \ ///
"Medical Equipment" \ ///
"Tobacco Products" \ ///
"Computer Software" \ ///
"\hline Average FF49 Industry")

*Tables 3-5 / Figures 2-3 ******************************************************
use $port,clear
g yearmo=year(ddate)*100+month(ddate)
keep if yearmo>=196401
g post=0 if yearmo<=201912  
replace post=1 if inrange(yearmo,202001,202003) 
replace dret=dret*100 // decimal -> percent 
replace dmktrf=dmktrf*100 // decimal -> percent 
g b=.
g capm_a=.
rename sortvarmean mean_

foreach m in durr bmr emr{
if "`m'"=="durr"{
local title="Duration" // durr = duration quintile rank
}

if "`m'"=="bmr"{
local title="Book-to-market" // bmr = be/me quintile rank
} 

if "`m'"=="emr"{
local title="Earnings-to-price" // emr = earnings/me quintile rank
} 

forvalues w=0/1{
preserve
keep if sortvar=="`m'" & vw==`w'
rename dret ret
gegen vola=sd(ret),by(port post)
g h=0 if port==1
replace h=1 if port==5
forvalues j=0/1{
sdtest ret if post==`j',by(h)
if r(p)>=.1{
mat starvola`j'=0
}
if r(p)<.1{
mat starvola`j'=1
}
if r(p)<.05{
mat starvola`j'=2
}
if r(p)<.01{
mat starvola`j'=3
}

if r(F)>=1{
mat f`j'=(r(F))
}
if r(F)<1{
mat f`j'=(1/r(F))
}
}
replace mean_=. if month(ddate)!=1 // keep portfolio chars. at beginning of year

*annualize returns and volatility 
g mktret=dmktrf*252 
replace ret=ret*252
replace vola=vola*sqrt(252) 

sort port ddate
g mktret_1=mktret[_n-1] if port==port[_n-1]
g mktret1=mktret[_n+1] if port==port[_n+1]
replace mktret1=-4.51*252 if mktret1==. // market return on 4/1/20 from K. French 
g b_d=.
g capm_a_d=.

forvalues j=1/5{
forvalues i=0/1{
*Dimson Beta
reg ret mktret mktret_1 mktret1 if port==`j' & post==`i'
replace b_d=_b[mktret_1]+_b[mktret]+_b[mktret1] if port==`j' & post==`i'
replace capm_a_d=_b[_cons] if port==`j' & post==`i'
}
}

local vars="ret b_d vola mean_"

*Gen 5-1 hedges: 
sort ddate port
foreach x in `vars'{
g `x'h51=`x'-`x'[_n-4] if port==5 & port[_n-4]==1
}
*Tables
foreach x in `vars'{
forvalues j=0/1{
mat `x'_`j'=(.)
forvalues i=1/5{
reg `x' if post==`j' & port==`i'
mat `x'`i'_`j'=(_b[_cons],.)
if inlist("`x'","b", "vola"){
mat `x'`i'=(_b[_cons],.)
}
if `i'==2{
matselrc `x'_`j' `x'_`j', col(2/3) 
}
mat `x'_`j'=(`x'_`j',`x'`i'_`j')
}
}
}

foreach x in ret{
forvalues j=0/1{
reg `x'h51 if post==`j'
mat `x'_`j'=(`x'_`j',_b[_cons],_b[_cons]/_se[_cons])
local p=2*ttail(e(df_r),abs(_b[_cons]/_se[_cons]))
if `p'>=.1{
mat star`x'`j'=0
}
if `p'<.1{
mat star`x'`j'=1
}
if `p'<.05{
mat star`x'`j'=2
}
if `p'<.01{
mat star`x'`j'=3
}
}
}

foreach x in mean_{
forvalues j=0/1{
reg `x'h51 if post==`j'
mat `x'_`j'=(`x'_`j',_b[_cons],.)
mat star`x'`j'=0
}
}

foreach x in vola{
forvalues j=0/1{
reg `x'h51 if post==`j'
mat `x'_`j'=(`x'_`j',_b[_cons],f`j')
}
}

forvalues j=0/1{
*Dimson betas
mat dalpha_`j'=(.)
mat dbeta_`j'=(.)
forvalues i=1/5{
reg ret mktret mktret_1 mktret1 if post==`j' & port==`i'
mat dalpha_`j'=(dalpha_`j',_b[_cons],.)
mat dbeta_`j'=(dbeta_`j',_b[mktret]+_b[mktret1]+_b[mktret_1],.)

if `i'==1{
matselrc dalpha_`j' dalpha_`j', col(2/3) 
matselrc dbeta_`j' dbeta_`j', col(2/3) 
}
}

reg reth51 mktret mktret_1 mktret1 if post==`j' 
mat dalpha_`j'=(dalpha_`j',_b[_cons],_b[_cons]/_se[_cons])
mat dbeta_`j'=(dbeta_`j',_b[mktret]+_b[mktret1]+_b[mktret_1])

local palpha=2*ttail(e(df_r),abs(_b[_cons]/_se[_cons]))

test (_b[mktret]+_b[mktret1]+_b[mktret_1])=0

mat dbeta_`j'=(dbeta_`j',r(F))

mat dstarbeta`j'=0
if r(p)<.1{
mat dstarbeta`j'=1 
}
if r(p)<.05{
mat dstarbeta`j'=2 
}
if r(p)<.01{
mat dstarbeta`j'=3 
}

if `palpha'>=.1{
mat dstaralpha`j'=0
}
if `palpha'<.1{
mat dstaralpha`j'=1
}
if `palpha'<.05{
mat dstaralpha`j'=2
}
if `palpha'<.01{
mat dstaralpha`j'=3
}

}

mat tab=(mean__1 \ mean__0 \ ret_1 \ ret_0  \ dalpha_1 \ dalpha_0 \ dbeta_1 \ dbeta_0 \ vola_1 \ vola_0 )
mat star=(starmean_1,0 \ starmean_0,0 \ starret1,0 \ starret0,0 \ dstaralpha1,0 \ dstaralpha0, 0 \ dstarbeta1, 0 \ dstarbeta0,0 \ starvola1,0 \ starvola0,0)
mat star=(J(10,10,0),star)
frmttable using "$path/t_vw`w'_`m'.tex", ///
replace tex fragment statmat(tab) substat(1) coljust(c) squarebrack  annotate(star) asymbol("*","**","***") ///
sdec(2) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{`title'} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("\rowcolor{Gray} `title' (01/20 - 03/20)" \"\rowcolor{Gray}"\" `title' (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Excess return (01/20 - 03/20)" \"\rowcolor{Gray}"\"Excess return (01/64 - 12/19)"\""\  ///
"\rowcolor{Gray} $ \alpha\sb{\text{CAPM}} $  (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \alpha\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} $ \beta\sb{\text{CAPM}} $ (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \beta\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Volatility (01/20 - 03/20)" \"\rowcolor{Gray}"\"Volatility (01/64 - 12/19)")


if inlist("`m'","durr"){
frmttable using "$path/t_vw`w'_`m'.tex", ///
replace tex fragment statmat(tab) substat(1) coljust(c) squarebrack  annotate(star) asymbol("*","**","***") ///
sdec(2) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{`title'} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("\rowcolor{Gray} `title' (01/20 - 03/20)" \"\rowcolor{Gray}"\" `title' (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Excess return (01/20 - 03/20)" \"\rowcolor{Gray}"\"Excess return (01/64 - 12/19)"\""\  ///
"\rowcolor{Gray} $ \alpha\sb{\text{CAPM}} $  (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \alpha\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} $ \beta\sb{\text{CAPM}} $ (01/20 - 03/20)" \"\rowcolor{Gray}"\"$ \beta\sb{\text{CAPM}} $ (01/64 - 12/19)"\""\ ///
"\rowcolor{Gray} Volatility (01/20 - 03/20)" \"\rowcolor{Gray}"\"Volatility (01/64 - 12/19)")
}

if "`m'"=="durr"{
local vars="ret vola b_d capm_a_d"

gcollapse (mean) `vars',by(port post) fast
local v=""
foreach x in `vars'{
g `x'0=`x' if post==0
g `x'1=`x' if post==1
local v="`v' `x'0 `x'1"
}

gcollapse (firstnm) `v',by(port) fast
label var ret0 "01/64 - 12/19"
label var ret1 "01/20 - 03/20"
label var capm_a_d0 "01/64 - 12/19"
label var capm_a_d1 "01/20 - 03/20"
label var b_d0 "01/64 - 12/19"
label var b_d1 "01/20 - 03/20"
label var vola0 "01/64 - 12/19"
label var vola1 "01/20 - 03/20"
label var port "`title'"

if `w'==0{
local mina=5
local ra=5
local maxa=25
}
if `w'==1{
local mina=-2
local ra=2
local maxa=4
}

if `w'==0{
local minr=10
local rr=5
local maxr=30
}

if `w'==1{
local minr=5
local rr=1
local maxr=10
}

local s="huge"

twoway (line ret1 ret0 port), ytitle("Excess return (% annualized)" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(-200(50)50,nogrid labsize(`s')) xlabel(1(1)5,labsize(`s')) ///
legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5)) 
graph export "$path/ret1_vw`w'_`m'.eps",replace fontface(Cmr10)

twoway (line capm_a_d1 capm_a_d0 port,lpattern(solid dash )), ytitle("CAPM alpha (% annualized)" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(-100(50)50,nogrid labsize(`s')) ///
xlabel(1(1)5,labsize(`s')) legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5))  
graph export "$path/dalpha1_vw`w'_`m'.eps",replace fontface(Cmr10)

twoway (line b_d1 b_d0 port,lpattern(solid dash )), ytitle("CAPM beta" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(.6(.2)1.4,nogrid labsize(`s')) ///
xlabel(1(1)5,labsize(`s')) legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5))  
graph export "$path/dbeta_vw`w'_`m'.eps",replace fontface(Cmr10)

twoway (line vola1 vola0 port,lpattern(solid dash )), ytitle("Volatility (% annualized)" " ",size(`s')) ///
xtitle(`port',size(`s')) graphregion(color(white)) ylabel(10(20)80,nogrid labsize(`s')) ///
xlabel(1(1)5,labsize(`s')) legend(size(vlarge) ring(1) pos(12) region(lstyle(color(white))) cols(5))  
graph export "$path/vola_vw`w'_`m'.eps",replace fontface(Cmr10)

}
restore
}
}


*Figure 4 *********************************************************************
preserve
g ret=dret/100
g mktret=dmktrf/100

g dur5_vw=ret if sortvar=="durr" & port==5 & vw==1
g dur1_vw=ret if sortvar=="durr" & port==1 & vw==1

g dur5_ew=ret if sortvar=="durr" & port==5 & vw==0
g dur1_ew=ret if sortvar=="durr" & port==1 & vw==0

gcollapse (firstnm) dur1_vw dur5_vw dur1_ew dur5_ew mktret,by(ddate)
g year=year(ddate)
g dur_ew=ln(1+dur5_ew-dur1_ew)
g dur_vw=ln(1+dur5_vw-dur1_vw)
replace mktret=ln(1+mktret)

gcollapse (sum) dur_ew dur_vw mktret,by(year)
foreach x in dur_ew dur_vw mktret{
replace `x'=100*(exp(`x')-1)
}

replace dur_ew=-dur_ew 
replace dur_vw=-dur_vw 

local min=-50
local max=50
g rec1=`min' if (y>=1969&y<=1970)
g rec2=`min' if (y>=1973&y<=1975)
g rec3=`min' if (y>=1980&y<=1982)
g rec5=`min' if (y>=1990&y<=1991)
g rec6=`min' if (y>=2001&y<=2001)
g rec7=`min' if (y>=2008&y<=2009)
g rec8=`min' if (y==2020)

g rec_1=`max' if (y>=1969&y<=1970)
g rec_2=`max' if (y>=1973&y<=1975)
g rec_3=`max' if (y>=1980&y<=1982)
g rec_5=`max' if (y>=1990&y<=1991)
g rec_6=`max' if (y>=2001&y<=2001)
g rec_7=`max' if (y>=2008&y<=2009)
g rec_8=`max' if (y==2020)

foreach x in dur_vw dur_ew{
corr `x' mktret if y<2020
local corr=round(10000*r(rho))/100
twoway ///
(area rec1 y, bcolor(gs14)) ///
(area rec2 y, bcolor(gs14)) ///
(area rec3 y, bcolor(gs14)) ///
(area rec5 y, bcolor(gs14)) ///
(area rec6 y, bcolor(gs14)) ///
(area rec7 y, bcolor(gs14)) /// 
(area rec_1 y, bcolor(gs14)) ///
(area rec_2 y, bcolor(gs14)) ///
(area rec_3 y, bcolor(gs14)) ///
(area rec_5 y, bcolor(gs14)) ///
(area rec_6 y, bcolor(gs14)) ///
(area rec_7 y, bcolor(gs14)) /// 
(line  dur_vw mktret y,lpattern(solid dash) lcolor(cranberry navy))  , xline(2020,lcolor(gs14)) ///
text(-45 2000 "Corr. Dur, Mkt: `corr'% ", box placement(w) bcolor(white)) ///
title("") ytitle("Return") ylab(-50(20)50,nogrid) yline(0) /// 
xtitle("") legend(on) plotregion(margin(zero)) graphregion(color(white)) ///
legend(pos(7) ring(0) col(1) order(13 14) label(13 "Duration") label(14 "Market") ///
region(lstyle(color(white)))) xlab(1964(4)2020,angle(45)) xtitle("Year")
graph export "$path/ts_`x'.eps",replace fontface(Cmr10)
}
restore

*Figure 5 *********************************************************************
forvalues w=0/1{
preserve
keep if sortvar=="durr" & vw==`w' & year(ddate)==2020
sort ddate
expand 5
replace dret=ln(1+dret/100) // for compounding 
forvalues i=1/5{
g r`i'=dret if port==`i'
}
gcollapse (firstnm) r1-r5,by(ddate)
sort ddate
forvalues i=1/5{
g cr`i'=r`i' if r`i'[_n-1]==.
replace cr`i'=r`i'+cr`i'[_n-1] if cr`i'==.
replace cr`i'=100*(exp(cr`i')-1)
}

local wu=date("01232020","MDY")
local it=date("02222020","MDY")
local eu=date("03112020","MDY")
local ne=date("03132020","MDY")
local st=date("03242020","MDY")
local d1=date("01022020","MDY")
local d2=date("02032020","MDY")
local d3=date("03022020","MDY")
local d4=date("03312020","MDY")

tsset ddate
twoway (line cr1-cr5 ddate,lcolor(emerald teal eltgreen olive_teal gray)), ///
legend(pos(7) ring(0) col(1) order(5 4 3 2 1) label(1 "Low Duration") label(2 "Q2") label(3 "Q3")  ///
label(4 "Q4") label(5 "High Duration") region(lstyle(color(white)))) xtitle("Date") ///
plotregion(margin(zero)) graphregion(color(white)) ylabel(-60(20)20,nogrid) ///
xline(`wu' `it' `eu' `ne' `st', lpat(dash)) ///
text(-20 `wu' "Wuhan lockdown",placement(w) orientation(vertical)) ///
text(-20 `it' "Italy quarantine",placement(w) orientation(vertical)) ///
text(-48 `eu' "EU Travel Ban",placement(w) orientation(vertical)) ///
text(10 `ne' "Natl. Emer.",placement(e) orientation(vertical)) ///
text(10 `st' "Fiscal stimulus",placement(e) orientation(vertical)) ///
xlabel(`d1' "Jan 2" `d2' "Feb 3" `d3' "Mar 2" `d4' "Mar 31      ") ytitle("Cumulative Excess Return")
graph export "$path/etime_vw`w'.eps",replace fontface(Cmr10)
restore
}

*Table 6 ***********************************************************************
use $panel, clear
rename *,lower
rename ddate date
keep if year(date)==2020
*Merge IBES data
g PERMNO=permno
joinby PERMNO using $ibes,unm(master)
drop PERMNO

g revision=100*((e_eps_may-e_eps_dec)/prc_a) // Q2 quarterly forecast revision (%)
g fy2p=100*(e_eps_fy2_dec/prc_a) // FY 2 consensus annual EPS (%)
g fep=100*((actual-e_eps_dec)/prc_a) // Q2 forecast error (relative to Dec. consensus) (%)
replace ret=(ret*100*252) // annualized percent 
g me_b=me_crsp/1000
g bm=bveq/me_crsp if bveq>0
replace bm=(bve/me_crsp) if bveq==. & bve>0 
g em=ibq4/me_crsp if ibq4>0
replace em=ib/me_crsp if ibq4==. & ib>0

sort permno date
foreach x in dur bm em lev oplev me_b ibq4 ib{
replace `x'=. if month(date)>1 
replace `x'=`x'[_n-1] if `x'==. & permno==permno[_n-1] // values as of Dec 31, 2019
}

label var dur "Duration"
label var bm "BE/ME"
label var em "Earnings/ME"
label var me_b "ME"
label var lev "Financial leverage"
label var oplev "Operating leverage"
label var ret "Excess return"

preserve
keep if month(date)==1 & day(date)==2
count if revision>0 & revision!=.
count if revision<0 & revision!=.
fasterxtile durr=dur,by(date) n(5)
gstats winsor revision fy2p fep,cuts(1 99) replace
foreach y in revision fy2p fep{
foreach x in durr{
g hi=1 if `x'==5
replace hi=0 if `x'==1
forvalues i=1/5{
reg `y' if `x'==`i'
mat y`i'ew=(_b[_cons],.)
reg `y' if `x'==`i' [w=me]
mat y`i'vw=(_b[_cons],.)
mat n`i'=e(N)
}
mat n`x'=(n1,.,n2,.,n3,.,n4,.,n5,.,.,.)
reg `y' hi
mat `x'ew=(y1ew,y2ew,y3ew,y4ew,y5ew, _b[hi],_b[hi]/_se[hi])

local pvalue=2*ttail(e(df_r),abs(_b[hi]/_se[hi]))

if `pvalue'>=.1{
mat `x'sew=0
}
if `pvalue'<.1{
mat `x'sew`j'=1
}
if `pvalue'<.05{
mat `x'sew`j'=2
}
if `pvalue'<.01{
mat `x'sew`j'=3
}

reg `y' hi [w=me]
mat `x'vw=(y1vw,y2vw,y3vw,y4vw,y5vw,_b[hi],_b[hi]/_se[hi])
local pvalue=2*ttail(e(df_r),abs(_b[hi]/_se[hi]))
if `pvalue'>=.1{
mat `x'svw=0
}
if `pvalue'<.1{
mat `x'svw`j'=1
}
if `pvalue'<.05{
mat `x'svw`j'=2
}
if `pvalue'<.01{
mat `x'svw`j'=3
}

drop hi
}
mat dur`y'vw=(durrvw \ ndurr)
mat dur`y'ew=(durrew \ ndurr)
mat stardurvw=(durrsvw,0)
mat stardurew=(durrsew,0)
mat stardur`y'vw=(J(1,10,0),stardurvw)
mat stardur`y'ew=(J(1,10,0),stardurew)
}
mat durvw=(durfy2pvw \ durrevisionvw \ durfepvw)
mat durew=(durfy2pew \ durrevisionew \ durfepew)
mat stardurvw=(stardurfy2pvw \ J(1,12,0)  \ stardurrevisionvw  \ J(1,12,0) \ stardurfepvw)
mat stardurew=(stardurfy2pew \ J(1,12,0)  \ stardurrevisionew  \ J(1,12,0) \ stardurfepew)

frmttable using "$path/durvwibes.tex", ///
replace tex fragment statmat(durvw) substat(1) coljust(c) squarebrack  annotate(stardurvw) asymbol("*","**","***") ///
sdec(2 \ 2 \ 0 \ 0 \ 2\ 2 \ 0 \ 0 \ 2 \ 2 \ 0 \ 0) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{Duration} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("Pre-pandemic Forward Yield (FY2/P)" \"" \ "N"\""\ "Q2 2020 Earnings Revision" \ ""\"N"\""\"Q2 2020 Earnings Surprise"\""\"N")

frmttable using "$path/durewibes.tex", ///
replace tex fragment statmat(durew) substat(1) coljust(c) squarebrack  annotate(stardurew) asymbol("*","**","***") ///
sdec(2 \ 2 \ 0 \ 0 \ 2\ 2 \ 0 \ 0 \ 2 \ 2 \ 0 \ 0) ctitles("& \multicolumn{5}{c}{\uline{\hfill \textbf{Duration} \hfill}} " \ ///
"","Low","Q2","Q3","Q4","High","Q5-Q1") ///
rtitles("Pre-pandemic Forward Yield (FY2/P)" \"" \ "N"\""\ "Q2 2020 Earnings Revision" \ ""\"N"\""\"Q2 2020 Earnings Surprise"\""\"N")
restore



*Tables 7-9 ********************************************************************

*Table 7: Full Sample
forvalues j=7/9{
preserve

*Table 8: Drop stocks with positive cumulative 2020 Q1 returns
if `j'==8{
g lret=ln(1+ret/25200)
gegen ret2020=sum(lret),by(permno)
keep if (exp(ret2020)-1)<0 & ret2020!=.
}

*Table 9: Drop stocks with positive revisions for Q2 EPS in the IBES subsample
if `j'==9{
keep if revision != . & revision<0
}
drop if dur==. // constant sample
foreach x in dur bm em lev oplev me_b{
fasterxtile r=`x',by(date) n(5)
replace `x'=(r-1)/4
drop r 
}

replace em=0 if ibq4<0
replace em=0 if em==. & ib<0
g loss=(ibq4<0)
replace loss=1 if ibq4==. & ib<0
replace loss=. if ibq4==. & ib==.
replace lev=0 if lev==. 
replace oplev=0 if oplev==. 

label var loss "Loss"
ffind siccd, newvar(ff49) type(49)
forvalues i=1/49{
g ff__`i'=(ff49==`i')
}

g multi=(pifo!=. | txfo !=. | txdfo !=.)
label var multi "MNC"
sort date
gegen t=group(date)

tsset permno t
local cont= "lev oplev loss me_b multi"

eststo clear
foreach v in dur bm em{
eststo:asreg ret `v' `cont',fmb
estadd local ind_fe "No"
estadd local avgn = round(e(N)/62)
eststo:asreg ret `v' `cont' ff__1-ff__48,fmb 
estadd local ind_fe "Yes" 
estadd local avgn =round(e(N)/62)
}

esttab using "$path/fm_ew_`j'.tex", ///
label b(%8.2f) stats(adjr2 ind_fe avgn, fmt(%8.3f) labels(`"Avg. Adj. $ R^2 $ "' "FF 49 Indicators" "Avg. N"))   ///
brackets nonotes substitute(\_ _) star(* 0.10 ** 0.05 *** 0.01) ///
keep(dur bm em `cont') order(dur bm em  `cont') nomti   mgroups("Daily excess return $\times$ 252 ", pattern(1 0 0 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
alignment(D{.}{.}{-1}) replace


local cont= "lev oplev loss me_b multi"
*Weighted FM
eststo clear
foreach v in dur bm em{
eststo:fmb ret `v' `cont' [w=me]
estadd local ind_fe "No" 
estadd local avgn = round(e(N)/62)
eststo:fmb ret `v' `cont' ff__1-ff__48 [w=me]
estadd local ind_fe "Yes" 
estadd local avgn = round(e(N)/62)
}

esttab using "$path/fm_vw_`j'.tex", ///
label b(%8.2f) stats(r2 ind_fe avgn, fmt(%8.3f) labels(`"Avg. Adj. $ R^2 $ "' "FF 49 Indicators" "Avg. N"))   ///
 brackets nonotes substitute(\_ _) star(* 0.10 ** 0.05 *** 0.01) ///
keep(dur bm em `cont') order(dur bm em  `cont') nomti  mgroups("Daily excess return $\times$ 252 ", pattern(1 0 0 0 0 0) ///
prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
alignment(D{.}{.}{-1}) replace
restore
}

*Figure 6 **********************************************************************
*Add Factset data
keep if date==date("01022020","MDY") // use rankings at beginning of year
fasterxtile durr=dur,by(date) n(5)
append using $fs
sort permno date
replace durr=durr[_n-1] if permno==permno[_n-1]
keep if month(date)==11

*Duration portfolio returns around good news about vaccine efficacy 
forvalues w=0/1{
preserve
if `w'==0{
gcollapse (mean) ret,by(date durr)
}

if `w'==1{
replace me=1 if date==date("11052020","MDY")
gcollapse (mean) ret [w=me],by(date durr)
}

sort date
expand 5
keep if inrange(date,date("11052020","MDY"),date("11172020","MDY"))
replace ret=0 if date==date("11052020","MDY")

replace ret=ln(1+ret)
forvalues i=1/5{
g r`i'=ret if durr==`i'
}
gcollapse (firstnm) r1-r5,by(date)

sort date

forvalues i=1/5{
g cr`i'=0 if r`i'[_n-1]==.
replace cr`i'=r`i'+cr`i'[_n-1] if cr`i'==.
replace cr`i'=100*(exp(cr`i')-1)
}

tsset date

gegen t=group(date)

g v1=14 if t==2 | t==3
g v2=14 if t==7 | t==8
g v_1=-4 if t==2 | t==3
g v_2=-4 if t==7 | t==8

local esize = "medsmall"
label var t "Date"
twoway (area v1 t, bcolor(gs15)) (area v_1 t, bcolor(gs15)) ///
(area v2 t, bcolor(gs15)) (area v_2 t, bcolor(gs15)) ///
(line cr1-cr5 t,lcolor(emerald teal eltgreen olive_teal gray) lpattern(solid dash shortdash dash_dot longdash  )) , ///
legend(pos(12) ring(1) col(5) order(5 6 7 8 9) label(5 "Low Duration") label(6 "Q2") label(7 "Q3")  ///
label(8 "Q4") label(9 "High Duration") size(medsmall) region(lstyle(color(white)))) xtitle("Date") ///
plotregion(margin(zero)) graphregion(color(white)) ylabel(-4(2)14,nogrid) yscale(range(-4 16) noextend)  ///
text(15 1.95 "Pfizer 90%",placement(e) orientation(horizontal) size(`esize')) ///
text(15 6.7 "Moderna 94.5%",placement(e) orientation(horizontal) size(`esize')) ///
xlabel(1 "Nov 5" 2 "Nov 6" 3 "Nov 9" 4 "Nov 10" 5 "Nov 11" 6 "Nov 12" 7 "Nov 13" 8 "Nov 16" 9 "Nov 17   " ) ///
ytitle("Cumulative Excess Return (%)" " ") 
graph export "$path/etime_vw`w'_vn.eps",replace fontface(Cmr10)
restore
}

* End of Code ******************************************************************

