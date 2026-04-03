capture log close
clear
clear matrix
set mem 1000m
set matsize 1000
set more off

* Mac/Windows compatible file paths:
* Also, choose appropriate Dropbox folder (confirmdir returns "0" if dir exists and "170" otherwise)

if regexm(c(os),"Mac") == 1 {
	confirmdir "/Users/`c(username)'/Dropbox (Personal)/"
	if r(confirmdir)=="0" {
		local mypath = "/Users/`c(username)'/Dropbox (Personal)/Papers/013 - Fontaneros/data/final data/"
	}
	else local mypath = "/Users/`c(username)'/Dropbox/Papers/013 - Fontaneros/data/final data/"	
}
else if regexm(c(os),"Windows") == 1 local mypath = "//Client/H$/Dropbox (Personal)/Papers/013 - Fontaneros/data/final data/"

cd "`mypath'analysis/JAR final program/control_reparaciones"
log using tables_post_JAR2_cluster , text replace

cd "`mypath'"

cd ..
insheet using "experiment preliminary data/20130617-GM- Detractores- Bonus x operario.csv" , delimiter(",")
	rename delegacion delegacion2
	rename provincia provincia2

cd "`mypath'"

use "stata import data post/fontaneros_detalle_post.dta" , clear

replace encuesta = "." if encuesta=="SIN VALORACION"
destring encuesta , replace

encode gremio_codigo , generate (codigo_gremio)

tostring reparacion_fin , replace
gen date_fin = date(reparacion_fin, "DM20Y")
format date_fin %d
drop mes
gen mes = month(date_fin)
drop semana2
gen semana2 = int((date_fin - td(29apr2013))/7) if date_fin >= td(29apr2013)
replace semana2 = int((date_fin - td(29apr2013))/7) -1 if date_fin < td(29apr2013)

gen experimento = 0
replace experimento = 1 if date_fin>=td(01may2013) & date_fin<td(01aug2013)
gen experimento_post = 0
replace experimento_post = 1 if date_fin>=td(01aug2013)
gen detractor = 0 if encuesta>=0 & encuesta<11
replace detractor = 1 if encuesta<7 & encuesta>=0
gen promotor = 0 if encuesta>=0 & encuesta<11
replace promotor = 1 if encuesta<11 & encuesta>=9

generate insatisfechos = 0
replace insatisfechos = 1 if insatisfecho=="S"

bysort codigo_op mes: egen encuesta_mes = mean(encuesta)

cd "`mypath'analysis/JAR final program/control_reparaciones"

preserve

/* WEEKLY DATA */

collapse (mean) codigo_gremio tratamiento encuesta* detractor* promotor* verde* amarillo* rojo* insatisfechos* (count) reparaciones=num_reparacion num_encuestas=encuesta (sum) detractores=detractor , by(codigo_op semana2)

gen experimento = 0
replace experimento = 1 if semana2>=0 & semana2<14
gen experimento_post = 0
replace experimento_post = 1 if semana2>=14

gen mes = 0
replace mes = 1 if semana2>=0 & semana2<=4
replace mes = 2 if semana2>=5 & semana2<=8
replace mes = 3 if semana2>=9 & semana2<=13
replace mes = 4 if semana2>=14 & semana2<=17
replace mes = 5 if semana2>=18 & semana2<=21
replace mes = 6 if semana2>=22 & semana2<=26
replace mes = 7 if semana2>=27 & semana2<=30

gen ultima_semana = 0
replace ultima_semana = 1 if semana2==4
replace ultima_semana = 1 if semana2==8
replace ultima_semana = 1 if semana2==13

gen primera_semana = 0
replace primera_semana = 1 if semana2==0
replace primera_semana = 1 if semana2==5
replace primera_semana = 1 if semana2==9

gen firstpart1b = 0
replace firstpart1b = 1 if primera_semana==1
gen secondpart1b = 0
replace secondpart1b = 1 if semana2>0 & semana2<14 & firstpart1==0

gen detractores_sem1_temp = 0
replace detractores_sem1_temp = detractores if primera_semana==1
bysort codigo_op mes: egen detractores_sem1 = max(detractores_sem1_temp)
gen nobonus1 = 0
replace nobonus1 = 1 if detractores_sem1>0 
gen bonus1 = 0
replace bonus1 = 1 if detractores_sem1==0
gen secondpartnobonus1 = secondpart1 * nobonus1
gen secondpartbonus1 = secondpart1 * bonus1

encode codigo_op , generate (code)
tsset code semana2

gen detractor_ultima_semana1 = 0
replace detractor_ultima_semana1 = 1 if l.detractor>0 & l.ultima_semana==1
gen nodetractor_ultima_semana1 = 0
replace nodetractor_ultima_semana1 = 1 if l.detractor==0 & l.ultima_semana==1
gen firstpartdetractor1 = firstpart1 * detractor_ultima_semana1
gen firstpartnodetractor1 = firstpart1 * nodetractor_ultima_semana1

gen primera_semana_post_id = 0
replace primera_semana_post_id = 1 if semana2==14
replace primera_semana_post_id = 1 if semana2==18
replace primera_semana_post_id = 1 if semana2==22
replace primera_semana_post_id = 1 if semana2==27
gen ultima_semana_post_id = 0
replace ultima_semana_post_id = 1 if semana2==17
replace ultima_semana_post_id = 1 if semana2==21
replace ultima_semana_post_id = 1 if semana2==26
replace ultima_semana_post_id = 1 if semana2==30
gen detractor_ultima_semana_post1 = 0
replace detractor_ultima_semana_post1 = 1 if l.detractor>0 & l.ultima_semana_post_id==1
gen nodetractor_ultima_semana_post1 = 0
replace nodetractor_ultima_semana_post1 = 1 if l.detractor==0 & l.ultima_semana_post_id==1
gen firstpartdetractorpost1 = primera_semana_post_id * detractor_ultima_semana_post1
gen firstpartnodetractorpost1 = primera_semana_post_id * nodetractor_ultima_semana_post1
gen secondpartpost1 = 0
replace secondpartpost1 = 1 if primera_semana_post_id==0 & semana2>13

set more off

/* Table IV */

xi: tobit detractor i.tratamiento*experimento reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) replace excel drop(_Isemana* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4 , mtest(b)
test (_ItraXexper_2=_ItraXexper_3) (_ItraXexper_2=_ItraXexper_4) , mtest(b)
test (_ItraXexper_2=_ItraXexper_3) (_ItraXexper_2=_ItraXexper_4) , mtest

xi: tobit detractor i.tratamiento*firstpart1 i.tratamiento*secondpart1 reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) append excel drop(_Isemana* _Icodigo*)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

xi: tobit detractor i.tratamiento*firstpart1 i.tratamiento*secondpartbonus1 i.tratamiento*secondpartnobonus1 reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) append excel drop(_Isemana* _Icodigo*)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecona2 _ItraXsecona3 _ItraXsecona4 , mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest
/* then for the Dummy IV interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

/* THIS MODEL DOES NOT GO INTO THE PAPER  */
xi: tobit detractor i.tratamiento*firstpartdetractor1 i.tratamiento*firstpartnodetractor1 i.tratamiento*secondpart1 reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy I interactions */
test  _ItraXfirsta2  _ItraXfirsta3  _ItraXfirsta4, mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

	/* we drop the first month of the experiment, as the dynamic effects do not make sense there */
xi: tobit detractor i.tratamiento*firstpartdetractor1 i.tratamiento*firstpartnodetractor1 i.tratamiento*secondpart1 reparaciones i.semana2 i.codigo_gremio if semana2<14 & mes!=1 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) append excel drop(_Isemana* _Icodigo*)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy I interactions */
test  _ItraXfirsta2  _ItraXfirsta3  _ItraXfirsta4, mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

/* Table VI, Model (2) */

xi: tobit detractor i.tratamiento*firstpartdetractor1 i.tratamiento*firstpartnodetractor1 i.tratamiento*secondpart1 i.tratamiento*firstpartdetractorpost1 i.tratamiento*firstpartnodetractorpost1 i.tratamiento*secondpartpost1 reparaciones i.semana2 i.codigo_gremio , ll(0) vce(cluster codigo_op)
outreg2 using "table6_2" , bdec(3) replace excel drop(_Isemana* _Icodigo*)
/* first for the Post Period I interactions */
test  _ItraXfirstb2  _ItraXfirstb3  _ItraXfirstb4, mtest(b)
test  (_ItraXfirstb2 = _ItraXfirstb3) (_ItraXfirstb2 = _ItraXfirstb4), mtest(b)
test  (_ItraXfirstb2 = _ItraXfirstb3) (_ItraXfirstb2 = _ItraXfirstb4), mtest
/* then for the Post Period II interactions */
test  _ItraXfirstc2  _ItraXfirstc3  _ItraXfirstc4, mtest(b)
test  (_ItraXfirstc2 = _ItraXfirstc3) (_ItraXfirstc2 = _ItraXfirstc4), mtest(b)
test  (_ItraXfirstc2 = _ItraXfirstc3) (_ItraXfirstc2 = _ItraXfirstc4), mtest
/* finally for the Post Period III interactions */
test  _ItraXsecona2 _ItraXsecona3 _ItraXsecona4 , mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest

/* Test of higher variance for weekly treatments */

sort tratamiento

by tratamiento: sum detractor if firstpartdetractor1==1 & mes>1 & mes<4
by tratamiento: sum detractor if firstpartdetractor1==0 & mes>1 & mes<4

hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==1
graph save Graph "Graph_tratamiento_1.gph", replace
hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==2
graph save Graph "Graph_tratamiento_2.gph", replace
hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==3
graph save Graph "Graph_tratamiento_3.gph", replace
hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==4
graph save Graph "Graph_tratamiento_4.gph", replace

gen freqfeed=1
replace freqfeed=2 if tratamiento==3 | tratamiento==4
sort freqfeed

by freqfeed: sum detractor if firstpartdetractor1==1 & mes>1 & mes<4
by freqfeed: sum detractor if firstpartdetractor1==0 & mes>1 & mes<4

robvar detractor if freqfeed==1 & mes>1 & mes<4 & firstpart1==1, by(firstpartdetractor1)
robvar detractor if freqfeed==2 & mes>1 & mes<4 & firstpart1==1, by(firstpartdetractor1)

robvar detractor if firstpartdetractor1==0 & mes>1 & mes<4 & firstpart1==1, by(freqfeed)
robvar detractor if firstpartdetractor1==1 & mes>1 & mes<4 & firstpart1==1, by(freqfeed)

robvar detractor if freqfeed==1 & mes>1 & mes<4 & firstpart1==0, by(secondpartbonus1)
robvar detractor if freqfeed==2 & mes>1 & mes<4 & firstpart1==0, by(secondpartbonus1)

gen detractorprior="NOSE"
replace detractorprior="SI" if (firstpartdetractor1==1 & firstpart1==1) | (secondpartbonus1==0 & firstpart1==0)
replace detractorprior="NO" if (firstpartdetractor1==0 & firstpart1==1) | (secondpartbonus1==1 & firstpart1==0)


/* Back to monthly data */

restore

collapse (mean) codigo_gremio tratamiento experimento* encuesta* detractor* promotor* verde* amarillo* rojo* insatisfechos* (count) reparaciones=num_reparacion num_encuestas=encuesta , by(codigo_op mes)
merge m:1 codigo_op mes using "`mypath'fontaneros_pda.dta"
drop _merge
merge m:1 codigo_op using "`mypath'stata import data post/fontaneros_region.dta"
drop _merge

set more off

gen operario = 0
replace operario = 1 if substr(codigo_op,1,2)=="71"

/* Table I - Summary stats */

bysort tratamiento: distinct codigo_op if experimento==0 & experimento_post==0
bysort tratamiento: distinct codigo_op if experimento==1
bysort tratamiento: sum reparaciones num_encuestas detractor verde if experimento==0 & experimento_post==0
bysort tratamiento: sum reparaciones num_encuestas detractor verde if experimento==1
gen detractor_cero = 0 if detractor!=.
replace detractor_cero = 1 if detractor==0
bysort tratamiento: sum detractor_cero if experimento==0 & experimento_post==0
bysort tratamiento: sum detractor_cero if experimento==1

gen promotor_cero = 0 if promotor!=.
replace promotor_cero = 1 if promotor==0
sum promotor_cero
gen promotor_uno = 0 if promotor!=.
replace promotor_uno = 1 if promotor==1
sum promotor_uno
gen encuesta_cero = 0 if encuesta!=.
replace encuesta_cero = 1 if encuesta==0
sum encuesta_cero
gen encuesta_diez = 0 if encuesta!=.
replace encuesta_diez = 1 if encuesta==10
sum encuesta_diez

/* there are very few observations with extreme values of Verde (either 0 or 100%) */
gen verde_cero = 0 if verde!=.
replace verde_cero = 1 if verde==0
gen verde_uno = 0 if verde!=.
replace verde_uno = 1 if verde==1
sum verde_cero verde_uno

bysort tratamiento: sum pda if experimento==0 & experimento_post==0 
bysort tratamiento: sum pda if experimento==1
/* there are very few observations with extreme values of PDA (either 0 or 100%) */
gen pda_cero = 0 if pda!=.
replace pda_cero = 1 if pda==0
gen pda_uno = 0 if pda!=.
replace pda_uno = 1 if pda==1
sum pda_cero pda_uno

/* Identify gremios with only one professional. Those gremios have only 7 or 11 observations, so gremio_count==7 or 11 */
/* Those gremios give problems when using gremio fixed effects and clustering std errors by operario (as gremio and operario are the same thing for these gremios) */
/* To avoid this problem, we group all the gremios with one operario into a single new gremio, with code = 0 */

egen gremio_count = count(1) , by(codigo_gremio)
replace codigo_gremio = 0 if gremio_count<12

/* Test whether the distribution of gremios is the same for all four treatments */

tabulate tratamiento codigo_gremio if mes==5 , chi2 lrchi2

/* Test whether the distribution of regions is the same for all four treatments */

tabulate tratamiento delegacion2 if mes==5 , chi2 lrchi2
tabulate tratamiento provincia2 if mes==5 , chi2 lrchi2


/* Table I Panel B.  Regression analysis to check randomization success  */

xi: tobit detractor i.tratamiento if experimento==0 & experimento_post==0, ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) replace excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit detractor i.tratamiento i.mes i.codigo_gremio if experimento==0 & experimento_post==0, ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit verde i.tratamiento if experimento==0 & experimento_post==0, ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit verde i.tratamiento i.mes i.codigo_gremio if experimento==0 & experimento_post==0 , ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit pda i.tratamiento if experimento==0 & experimento_post==0 , ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit pda i.tratamiento i.mes i.codigo_gremio if experimento==0 & experimento_post==0 , ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)


* Test whether the number of reparaciones and surveys is the same before and during the treatment

xi: reg reparaciones i.tratamiento if experimento==0 & experimento_post==0, vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) replace excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg reparaciones i.tratamiento i.mes if experimento==0 & experimento_post==0, absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg num_encuestas i.tratamiento if experimento==0 & experimento_post==0, vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg num_encuestas i.tratamiento i.mes if experimento==0 & experimento_post==0, absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg reparaciones i.tratamiento if experimento==1 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg reparaciones i.tratamiento i.mes if experimento==1 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg num_encuestas i.tratamiento if experimento==1 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg num_encuestas i.tratamiento i.mes if experimento==1 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg reparaciones i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: areg reparaciones i.tratamiento*experimento i.mes if mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: reg num_encuestas i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: areg num_encuestas i.tratamiento*experimento i.mes if mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)

xi: tobit reparaciones i.tratamiento*experimento if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) replace excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: tobit reparaciones i.tratamiento*experimento i.mes i.codigo_gremio if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: tobit num_encuestas i.tratamiento*experimento if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: tobit num_encuestas i.tratamiento*experimento i.mes i.codigo_gremio if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)


/* Table II */

xi: reg detractor i.tratamiento*experimento if mes>4 & mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) replace excel
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg detractor i.tratamiento*experimento reparaciones if mes>4 & mes<8 , vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: areg detractor i.tratamiento*experimento reparaciones i.mes if mes>4 & mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: reg detractor i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg detractor i.tratamiento*experimento reparaciones if mes<8 , vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: areg detractor i.tratamiento*experimento reparaciones i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit detractor i.tratamiento*experimento if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) replace excel
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: tobit detractor i.tratamiento*experimento reparaciones if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: tobit detractor i.tratamiento*experimento if mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) append excel
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: tobit detractor i.tratamiento*experimento reparaciones if mes<8 , ll(0) vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: reg promotor i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg promotor i.tratamiento*experimento reparaciones if mes<8 , vce(cluster codigo_op)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: areg promotor i.tratamiento*experimento reparaciones i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: reg encuesta i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg encuesta i.tratamiento*experimento reparaciones if mes<8 , vce(cluster codigo_op)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: areg encuesta i.tratamiento*experimento reparaciones i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The following regressions test the robustness of the inclusion of "verde" and "pda" as controls, for the referee only, not the paper
xi: areg detractor i.tratamiento*experimento reparaciones verde pda i.mes if mes>4 & mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: areg detractor i.tratamiento*experimento reparaciones verde pda i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones verde pda i.mes i.codigo_gremio if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones verde pda i.mes i.codigo_gremio if mes<8 , ll(0) vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

/* Table VI, Model (1) */

	* The next regression is for reference only, does not go into the table
xi: areg detractor i.tratamiento*experimento i.tratamiento*experimento_post reparaciones i.mes , absorb(codigo_op) vce(cluster codigo_op)

xi: tobit detractor i.tratamiento*experimento i.tratamiento*experimento_post reparaciones i.mes i.codigo_gremio , ll(0) vce(cluster codigo_op)
outreg2 using "table6_1" , bdec(3) replace excel drop(_Imes* _Icodigo*)
test _ItraXexpera2 _ItraXexpera3 _ItraXexpera4, mtest(b)
test (_ItraXexpera2 = _ItraXexpera3) (_ItraXexpera2 = _ItraXexpera4), mtest(b)
test (_ItraXexpera2 = _ItraXexpera3) (_ItraXexpera2 = _ItraXexpera4), mtest

/* Table III TOBIT */

xi: tobit verde i.tratamiento*experimento reparaciones if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) replace excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit verde i.tratamiento*experimento reparaciones i.mes if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit verde i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit pda i.tratamiento*experimento reparaciones if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit pda i.tratamiento*experimento reparaciones i.mes if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit pda i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest



encode codigo_op , generate (code)
tsset code mes

/* Generate variables identifying professionals that drop or join within the experiment period */
gen new = 0
gen old = 0
gen old2 = 0
gen drop = 0

replace new = 1 if code!=l2.code
replace drop = 1 if code!=f2.code
replace old = 1 if code==l2.code
replace old2 = 1 if code==f2.code

tab new if mes==7
tab old if mes==7
tab old2 if mes==5
tab drop if mes==5

/* Generate variables identifying professionals that drop or join between month 5 and 11 */
gen new_post = 0
gen old_post = 0
gen old2_post = 0
gen drop_post = 0

replace new_post = 1 if code!=l6.code
replace drop_post = 1 if code!=f6.code
replace old_post = 1 if code==l6.code
replace old2_post = 1 if code==f6.code

tab new_post if mes==11
tab old_post if mes==11
tab old2_post if mes==5
tab drop_post if mes==5


log close
capture log close
clear
clear matrix
set mem 1000m
set matsize 1000
set more off

* Mac/Windows compatible file paths:
* Also, choose appropriate Dropbox folder (confirmdir returns "0" if dir exists and "170" otherwise)

if regexm(c(os),"Mac") == 1 {
	confirmdir "/Users/`c(username)'/Dropbox (Personal)/"
	if r(confirmdir)=="0" {
		local mypath = "/Users/`c(username)'/Dropbox (Personal)/Papers/013 - Fontaneros/data/final data/"
	}
	else local mypath = "/Users/`c(username)'/Dropbox/Papers/013 - Fontaneros/data/final data/"	
}
else if regexm(c(os),"Windows") == 1 local mypath = "//Client/H$/Dropbox (Personal)/Papers/013 - Fontaneros/data/final data/"

cd "`mypath'analysis/JAR final program/control_reparaciones"
log using tables_post_JAR2_cluster , text replace

cd "`mypath'"

cd ..
insheet using "experiment preliminary data/20130617-GM- Detractores- Bonus x operario.csv" , delimiter(",")
	rename delegacion delegacion2
	rename provincia provincia2

cd "`mypath'"

use "stata import data post/fontaneros_detalle_post.dta" , clear

replace encuesta = "." if encuesta=="SIN VALORACION"
destring encuesta , replace

encode gremio_codigo , generate (codigo_gremio)

tostring reparacion_fin , replace
gen date_fin = date(reparacion_fin, "DM20Y")
format date_fin %d
drop mes
gen mes = month(date_fin)
drop semana2
gen semana2 = int((date_fin - td(29apr2013))/7) if date_fin >= td(29apr2013)
replace semana2 = int((date_fin - td(29apr2013))/7) -1 if date_fin < td(29apr2013)

gen experimento = 0
replace experimento = 1 if date_fin>=td(01may2013) & date_fin<td(01aug2013)
gen experimento_post = 0
replace experimento_post = 1 if date_fin>=td(01aug2013)
gen detractor = 0 if encuesta>=0 & encuesta<11
replace detractor = 1 if encuesta<7 & encuesta>=0
gen promotor = 0 if encuesta>=0 & encuesta<11
replace promotor = 1 if encuesta<11 & encuesta>=9

generate insatisfechos = 0
replace insatisfechos = 1 if insatisfecho=="S"

bysort codigo_op mes: egen encuesta_mes = mean(encuesta)

cd "`mypath'analysis/JAR final program/control_reparaciones"

preserve

/* WEEKLY DATA */

collapse (mean) codigo_gremio tratamiento encuesta* detractor* promotor* verde* amarillo* rojo* insatisfechos* (count) reparaciones=num_reparacion num_encuestas=encuesta (sum) detractores=detractor , by(codigo_op semana2)

gen experimento = 0
replace experimento = 1 if semana2>=0 & semana2<14
gen experimento_post = 0
replace experimento_post = 1 if semana2>=14

gen mes = 0
replace mes = 1 if semana2>=0 & semana2<=4
replace mes = 2 if semana2>=5 & semana2<=8
replace mes = 3 if semana2>=9 & semana2<=13
replace mes = 4 if semana2>=14 & semana2<=17
replace mes = 5 if semana2>=18 & semana2<=21
replace mes = 6 if semana2>=22 & semana2<=26
replace mes = 7 if semana2>=27 & semana2<=30

gen ultima_semana = 0
replace ultima_semana = 1 if semana2==4
replace ultima_semana = 1 if semana2==8
replace ultima_semana = 1 if semana2==13

gen primera_semana = 0
replace primera_semana = 1 if semana2==0
replace primera_semana = 1 if semana2==5
replace primera_semana = 1 if semana2==9

gen firstpart1b = 0
replace firstpart1b = 1 if primera_semana==1
gen secondpart1b = 0
replace secondpart1b = 1 if semana2>0 & semana2<14 & firstpart1==0

gen detractores_sem1_temp = 0
replace detractores_sem1_temp = detractores if primera_semana==1
bysort codigo_op mes: egen detractores_sem1 = max(detractores_sem1_temp)
gen nobonus1 = 0
replace nobonus1 = 1 if detractores_sem1>0 
gen bonus1 = 0
replace bonus1 = 1 if detractores_sem1==0
gen secondpartnobonus1 = secondpart1 * nobonus1
gen secondpartbonus1 = secondpart1 * bonus1

encode codigo_op , generate (code)
tsset code semana2

gen detractor_ultima_semana1 = 0
replace detractor_ultima_semana1 = 1 if l.detractor>0 & l.ultima_semana==1
gen nodetractor_ultima_semana1 = 0
replace nodetractor_ultima_semana1 = 1 if l.detractor==0 & l.ultima_semana==1
gen firstpartdetractor1 = firstpart1 * detractor_ultima_semana1
gen firstpartnodetractor1 = firstpart1 * nodetractor_ultima_semana1

gen primera_semana_post_id = 0
replace primera_semana_post_id = 1 if semana2==14
replace primera_semana_post_id = 1 if semana2==18
replace primera_semana_post_id = 1 if semana2==22
replace primera_semana_post_id = 1 if semana2==27
gen ultima_semana_post_id = 0
replace ultima_semana_post_id = 1 if semana2==17
replace ultima_semana_post_id = 1 if semana2==21
replace ultima_semana_post_id = 1 if semana2==26
replace ultima_semana_post_id = 1 if semana2==30
gen detractor_ultima_semana_post1 = 0
replace detractor_ultima_semana_post1 = 1 if l.detractor>0 & l.ultima_semana_post_id==1
gen nodetractor_ultima_semana_post1 = 0
replace nodetractor_ultima_semana_post1 = 1 if l.detractor==0 & l.ultima_semana_post_id==1
gen firstpartdetractorpost1 = primera_semana_post_id * detractor_ultima_semana_post1
gen firstpartnodetractorpost1 = primera_semana_post_id * nodetractor_ultima_semana_post1
gen secondpartpost1 = 0
replace secondpartpost1 = 1 if primera_semana_post_id==0 & semana2>13

set more off

/* Table IV */

xi: tobit detractor i.tratamiento*experimento reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) replace excel drop(_Isemana* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4 , mtest(b)
test (_ItraXexper_2=_ItraXexper_3) (_ItraXexper_2=_ItraXexper_4) , mtest(b)
test (_ItraXexper_2=_ItraXexper_3) (_ItraXexper_2=_ItraXexper_4) , mtest

xi: tobit detractor i.tratamiento*firstpart1 i.tratamiento*secondpart1 reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) append excel drop(_Isemana* _Icodigo*)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

xi: tobit detractor i.tratamiento*firstpart1 i.tratamiento*secondpartbonus1 i.tratamiento*secondpartnobonus1 reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) append excel drop(_Isemana* _Icodigo*)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecona2 _ItraXsecona3 _ItraXsecona4 , mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest
/* then for the Dummy IV interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

/* THIS MODEL DOES NOT GO INTO THE PAPER  */
xi: tobit detractor i.tratamiento*firstpartdetractor1 i.tratamiento*firstpartnodetractor1 i.tratamiento*secondpart1 reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy I interactions */
test  _ItraXfirsta2  _ItraXfirsta3  _ItraXfirsta4, mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

	/* we drop the first month of the experiment, as the dynamic effects do not make sense there */
xi: tobit detractor i.tratamiento*firstpartdetractor1 i.tratamiento*firstpartnodetractor1 i.tratamiento*secondpart1 reparaciones i.semana2 i.codigo_gremio if semana2<14 & mes!=1 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) append excel drop(_Isemana* _Icodigo*)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy I interactions */
test  _ItraXfirsta2  _ItraXfirsta3  _ItraXfirsta4, mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

/* Table VI, Model (2) */

xi: tobit detractor i.tratamiento*firstpartdetractor1 i.tratamiento*firstpartnodetractor1 i.tratamiento*secondpart1 i.tratamiento*firstpartdetractorpost1 i.tratamiento*firstpartnodetractorpost1 i.tratamiento*secondpartpost1 reparaciones i.semana2 i.codigo_gremio , ll(0) vce(cluster codigo_op)
outreg2 using "table6_2" , bdec(3) replace excel drop(_Isemana* _Icodigo*)
/* first for the Post Period I interactions */
test  _ItraXfirstb2  _ItraXfirstb3  _ItraXfirstb4, mtest(b)
test  (_ItraXfirstb2 = _ItraXfirstb3) (_ItraXfirstb2 = _ItraXfirstb4), mtest(b)
test  (_ItraXfirstb2 = _ItraXfirstb3) (_ItraXfirstb2 = _ItraXfirstb4), mtest
/* then for the Post Period II interactions */
test  _ItraXfirstc2  _ItraXfirstc3  _ItraXfirstc4, mtest(b)
test  (_ItraXfirstc2 = _ItraXfirstc3) (_ItraXfirstc2 = _ItraXfirstc4), mtest(b)
test  (_ItraXfirstc2 = _ItraXfirstc3) (_ItraXfirstc2 = _ItraXfirstc4), mtest
/* finally for the Post Period III interactions */
test  _ItraXsecona2 _ItraXsecona3 _ItraXsecona4 , mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest

/* Test of higher variance for weekly treatments */

sort tratamiento

by tratamiento: sum detractor if firstpartdetractor1==1 & mes>1 & mes<4
by tratamiento: sum detractor if firstpartdetractor1==0 & mes>1 & mes<4

hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==1
graph save Graph "Graph_tratamiento_1.gph", replace
hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==2
graph save Graph "Graph_tratamiento_2.gph", replace
hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==3
graph save Graph "Graph_tratamiento_3.gph", replace
hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==4
graph save Graph "Graph_tratamiento_4.gph", replace

gen freqfeed=1
replace freqfeed=2 if tratamiento==3 | tratamiento==4
sort freqfeed

by freqfeed: sum detractor if firstpartdetractor1==1 & mes>1 & mes<4
by freqfeed: sum detractor if firstpartdetractor1==0 & mes>1 & mes<4

robvar detractor if freqfeed==1 & mes>1 & mes<4 & firstpart1==1, by(firstpartdetractor1)
robvar detractor if freqfeed==2 & mes>1 & mes<4 & firstpart1==1, by(firstpartdetractor1)

robvar detractor if firstpartdetractor1==0 & mes>1 & mes<4 & firstpart1==1, by(freqfeed)
robvar detractor if firstpartdetractor1==1 & mes>1 & mes<4 & firstpart1==1, by(freqfeed)

robvar detractor if freqfeed==1 & mes>1 & mes<4 & firstpart1==0, by(secondpartbonus1)
robvar detractor if freqfeed==2 & mes>1 & mes<4 & firstpart1==0, by(secondpartbonus1)

gen detractorprior="NOSE"
replace detractorprior="SI" if (firstpartdetractor1==1 & firstpart1==1) | (secondpartbonus1==0 & firstpart1==0)
replace detractorprior="NO" if (firstpartdetractor1==0 & firstpart1==1) | (secondpartbonus1==1 & firstpart1==0)


/* Back to monthly data */

restore

collapse (mean) codigo_gremio tratamiento experimento* encuesta* detractor* promotor* verde* amarillo* rojo* insatisfechos* (count) reparaciones=num_reparacion num_encuestas=encuesta , by(codigo_op mes)
merge m:1 codigo_op mes using "`mypath'fontaneros_pda.dta"
drop _merge
merge m:1 codigo_op using "`mypath'stata import data post/fontaneros_region.dta"
drop _merge

set more off

gen operario = 0
replace operario = 1 if substr(codigo_op,1,2)=="71"

/* Table I - Summary stats */

bysort tratamiento: distinct codigo_op if experimento==0 & experimento_post==0
bysort tratamiento: distinct codigo_op if experimento==1
bysort tratamiento: sum reparaciones num_encuestas detractor verde if experimento==0 & experimento_post==0
bysort tratamiento: sum reparaciones num_encuestas detractor verde if experimento==1
gen detractor_cero = 0 if detractor!=.
replace detractor_cero = 1 if detractor==0
bysort tratamiento: sum detractor_cero if experimento==0 & experimento_post==0
bysort tratamiento: sum detractor_cero if experimento==1

gen promotor_cero = 0 if promotor!=.
replace promotor_cero = 1 if promotor==0
sum promotor_cero
gen promotor_uno = 0 if promotor!=.
replace promotor_uno = 1 if promotor==1
sum promotor_uno
gen encuesta_cero = 0 if encuesta!=.
replace encuesta_cero = 1 if encuesta==0
sum encuesta_cero
gen encuesta_diez = 0 if encuesta!=.
replace encuesta_diez = 1 if encuesta==10
sum encuesta_diez

/* there are very few observations with extreme values of Verde (either 0 or 100%) */
gen verde_cero = 0 if verde!=.
replace verde_cero = 1 if verde==0
gen verde_uno = 0 if verde!=.
replace verde_uno = 1 if verde==1
sum verde_cero verde_uno

bysort tratamiento: sum pda if experimento==0 & experimento_post==0 
bysort tratamiento: sum pda if experimento==1
/* there are very few observations with extreme values of PDA (either 0 or 100%) */
gen pda_cero = 0 if pda!=.
replace pda_cero = 1 if pda==0
gen pda_uno = 0 if pda!=.
replace pda_uno = 1 if pda==1
sum pda_cero pda_uno

/* Identify gremios with only one professional. Those gremios have only 7 or 11 observations, so gremio_count==7 or 11 */
/* Those gremios give problems when using gremio fixed effects and clustering std errors by operario (as gremio and operario are the same thing for these gremios) */
/* To avoid this problem, we group all the gremios with one operario into a single new gremio, with code = 0 */

egen gremio_count = count(1) , by(codigo_gremio)
replace codigo_gremio = 0 if gremio_count<12

/* Test whether the distribution of gremios is the same for all four treatments */

tabulate tratamiento codigo_gremio if mes==5 , chi2 lrchi2

/* Test whether the distribution of regions is the same for all four treatments */

tabulate tratamiento delegacion2 if mes==5 , chi2 lrchi2
tabulate tratamiento provincia2 if mes==5 , chi2 lrchi2


/* Table I Panel B.  Regression analysis to check randomization success  */

xi: tobit detractor i.tratamiento if experimento==0 & experimento_post==0, ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) replace excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit detractor i.tratamiento i.mes i.codigo_gremio if experimento==0 & experimento_post==0, ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit verde i.tratamiento if experimento==0 & experimento_post==0, ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit verde i.tratamiento i.mes i.codigo_gremio if experimento==0 & experimento_post==0 , ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit pda i.tratamiento if experimento==0 & experimento_post==0 , ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit pda i.tratamiento i.mes i.codigo_gremio if experimento==0 & experimento_post==0 , ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)


* Test whether the number of reparaciones and surveys is the same before and during the treatment

xi: reg reparaciones i.tratamiento if experimento==0 & experimento_post==0, vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) replace excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg reparaciones i.tratamiento i.mes if experimento==0 & experimento_post==0, absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg num_encuestas i.tratamiento if experimento==0 & experimento_post==0, vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg num_encuestas i.tratamiento i.mes if experimento==0 & experimento_post==0, absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg reparaciones i.tratamiento if experimento==1 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg reparaciones i.tratamiento i.mes if experimento==1 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg num_encuestas i.tratamiento if experimento==1 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg num_encuestas i.tratamiento i.mes if experimento==1 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg reparaciones i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: areg reparaciones i.tratamiento*experimento i.mes if mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: reg num_encuestas i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: areg num_encuestas i.tratamiento*experimento i.mes if mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)

xi: tobit reparaciones i.tratamiento*experimento if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) replace excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: tobit reparaciones i.tratamiento*experimento i.mes i.codigo_gremio if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: tobit num_encuestas i.tratamiento*experimento if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: tobit num_encuestas i.tratamiento*experimento i.mes i.codigo_gremio if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)


/* Table II */

xi: reg detractor i.tratamiento*experimento if mes>4 & mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) replace excel
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg detractor i.tratamiento*experimento reparaciones if mes>4 & mes<8 , vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: areg detractor i.tratamiento*experimento reparaciones i.mes if mes>4 & mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: reg detractor i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg detractor i.tratamiento*experimento reparaciones if mes<8 , vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: areg detractor i.tratamiento*experimento reparaciones i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit detractor i.tratamiento*experimento if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) replace excel
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: tobit detractor i.tratamiento*experimento reparaciones if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: tobit detractor i.tratamiento*experimento if mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) append excel
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: tobit detractor i.tratamiento*experimento reparaciones if mes<8 , ll(0) vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: reg promotor i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg promotor i.tratamiento*experimento reparaciones if mes<8 , vce(cluster codigo_op)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: areg promotor i.tratamiento*experimento reparaciones i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: reg encuesta i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg encuesta i.tratamiento*experimento reparaciones if mes<8 , vce(cluster codigo_op)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: areg encuesta i.tratamiento*experimento reparaciones i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The following regressions test the robustness of the inclusion of "verde" and "pda" as controls, for the referee only, not the paper
xi: areg detractor i.tratamiento*experimento reparaciones verde pda i.mes if mes>4 & mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: areg detractor i.tratamiento*experimento reparaciones verde pda i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones verde pda i.mes i.codigo_gremio if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones verde pda i.mes i.codigo_gremio if mes<8 , ll(0) vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

/* Table VI, Model (1) */

	* The next regression is for reference only, does not go into the table
xi: areg detractor i.tratamiento*experimento i.tratamiento*experimento_post reparaciones i.mes , absorb(codigo_op) vce(cluster codigo_op)

xi: tobit detractor i.tratamiento*experimento i.tratamiento*experimento_post reparaciones i.mes i.codigo_gremio , ll(0) vce(cluster codigo_op)
outreg2 using "table6_1" , bdec(3) replace excel drop(_Imes* _Icodigo*)
test _ItraXexpera2 _ItraXexpera3 _ItraXexpera4, mtest(b)
test (_ItraXexpera2 = _ItraXexpera3) (_ItraXexpera2 = _ItraXexpera4), mtest(b)
test (_ItraXexpera2 = _ItraXexpera3) (_ItraXexpera2 = _ItraXexpera4), mtest

/* Table III TOBIT */

xi: tobit verde i.tratamiento*experimento reparaciones if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) replace excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit verde i.tratamiento*experimento reparaciones i.mes if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit verde i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit pda i.tratamiento*experimento reparaciones if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit pda i.tratamiento*experimento reparaciones i.mes if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit pda i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest



encode codigo_op , generate (code)
tsset code mes

/* Generate variables identifying professionals that drop or join within the experiment period */
gen new = 0
gen old = 0
gen old2 = 0
gen drop = 0

replace new = 1 if code!=l2.code
replace drop = 1 if code!=f2.code
replace old = 1 if code==l2.code
replace old2 = 1 if code==f2.code

tab new if mes==7
tab old if mes==7
tab old2 if mes==5
tab drop if mes==5

/* Generate variables identifying professionals that drop or join between month 5 and 11 */
gen new_post = 0
gen old_post = 0
gen old2_post = 0
gen drop_post = 0

replace new_post = 1 if code!=l6.code
replace drop_post = 1 if code!=f6.code
replace old_post = 1 if code==l6.code
replace old2_post = 1 if code==f6.code

tab new_post if mes==11
tab old_post if mes==11
tab old2_post if mes==5
tab drop_post if mes==5


log close
capture log close
clear
clear matrix
set mem 1000m
set matsize 1000
set more off

* Mac/Windows compatible file paths:
* Also, choose appropriate Dropbox folder (confirmdir returns "0" if dir exists and "170" otherwise)

if regexm(c(os),"Mac") == 1 {
	confirmdir "/Users/`c(username)'/Dropbox (Personal)/"
	if r(confirmdir)=="0" {
		local mypath = "/Users/`c(username)'/Dropbox (Personal)/Papers/013 - Fontaneros/data/final data/"
	}
	else local mypath = "/Users/`c(username)'/Dropbox/Papers/013 - Fontaneros/data/final data/"	
}
else if regexm(c(os),"Windows") == 1 local mypath = "//Client/H$/Dropbox (Personal)/Papers/013 - Fontaneros/data/final data/"

cd "`mypath'analysis/JAR final program/control_reparaciones"
log using tables_post_JAR2_cluster , text replace

cd "`mypath'"

cd ..
insheet using "experiment preliminary data/20130617-GM- Detractores- Bonus x operario.csv" , delimiter(",")
	rename delegacion delegacion2
	rename provincia provincia2

cd "`mypath'"

use "stata import data post/fontaneros_detalle_post.dta" , clear

replace encuesta = "." if encuesta=="SIN VALORACION"
destring encuesta , replace

encode gremio_codigo , generate (codigo_gremio)

tostring reparacion_fin , replace
gen date_fin = date(reparacion_fin, "DM20Y")
format date_fin %d
drop mes
gen mes = month(date_fin)
drop semana2
gen semana2 = int((date_fin - td(29apr2013))/7) if date_fin >= td(29apr2013)
replace semana2 = int((date_fin - td(29apr2013))/7) -1 if date_fin < td(29apr2013)

gen experimento = 0
replace experimento = 1 if date_fin>=td(01may2013) & date_fin<td(01aug2013)
gen experimento_post = 0
replace experimento_post = 1 if date_fin>=td(01aug2013)
gen detractor = 0 if encuesta>=0 & encuesta<11
replace detractor = 1 if encuesta<7 & encuesta>=0
gen promotor = 0 if encuesta>=0 & encuesta<11
replace promotor = 1 if encuesta<11 & encuesta>=9

generate insatisfechos = 0
replace insatisfechos = 1 if insatisfecho=="S"

bysort codigo_op mes: egen encuesta_mes = mean(encuesta)

cd "`mypath'analysis/JAR final program/control_reparaciones"

preserve

/* WEEKLY DATA */

collapse (mean) codigo_gremio tratamiento encuesta* detractor* promotor* verde* amarillo* rojo* insatisfechos* (count) reparaciones=num_reparacion num_encuestas=encuesta (sum) detractores=detractor , by(codigo_op semana2)

gen experimento = 0
replace experimento = 1 if semana2>=0 & semana2<14
gen experimento_post = 0
replace experimento_post = 1 if semana2>=14

gen mes = 0
replace mes = 1 if semana2>=0 & semana2<=4
replace mes = 2 if semana2>=5 & semana2<=8
replace mes = 3 if semana2>=9 & semana2<=13
replace mes = 4 if semana2>=14 & semana2<=17
replace mes = 5 if semana2>=18 & semana2<=21
replace mes = 6 if semana2>=22 & semana2<=26
replace mes = 7 if semana2>=27 & semana2<=30

gen ultima_semana = 0
replace ultima_semana = 1 if semana2==4
replace ultima_semana = 1 if semana2==8
replace ultima_semana = 1 if semana2==13

gen primera_semana = 0
replace primera_semana = 1 if semana2==0
replace primera_semana = 1 if semana2==5
replace primera_semana = 1 if semana2==9

gen firstpart1b = 0
replace firstpart1b = 1 if primera_semana==1
gen secondpart1b = 0
replace secondpart1b = 1 if semana2>0 & semana2<14 & firstpart1==0

gen detractores_sem1_temp = 0
replace detractores_sem1_temp = detractores if primera_semana==1
bysort codigo_op mes: egen detractores_sem1 = max(detractores_sem1_temp)
gen nobonus1 = 0
replace nobonus1 = 1 if detractores_sem1>0 
gen bonus1 = 0
replace bonus1 = 1 if detractores_sem1==0
gen secondpartnobonus1 = secondpart1 * nobonus1
gen secondpartbonus1 = secondpart1 * bonus1

encode codigo_op , generate (code)
tsset code semana2

gen detractor_ultima_semana1 = 0
replace detractor_ultima_semana1 = 1 if l.detractor>0 & l.ultima_semana==1
gen nodetractor_ultima_semana1 = 0
replace nodetractor_ultima_semana1 = 1 if l.detractor==0 & l.ultima_semana==1
gen firstpartdetractor1 = firstpart1 * detractor_ultima_semana1
gen firstpartnodetractor1 = firstpart1 * nodetractor_ultima_semana1

gen primera_semana_post_id = 0
replace primera_semana_post_id = 1 if semana2==14
replace primera_semana_post_id = 1 if semana2==18
replace primera_semana_post_id = 1 if semana2==22
replace primera_semana_post_id = 1 if semana2==27
gen ultima_semana_post_id = 0
replace ultima_semana_post_id = 1 if semana2==17
replace ultima_semana_post_id = 1 if semana2==21
replace ultima_semana_post_id = 1 if semana2==26
replace ultima_semana_post_id = 1 if semana2==30
gen detractor_ultima_semana_post1 = 0
replace detractor_ultima_semana_post1 = 1 if l.detractor>0 & l.ultima_semana_post_id==1
gen nodetractor_ultima_semana_post1 = 0
replace nodetractor_ultima_semana_post1 = 1 if l.detractor==0 & l.ultima_semana_post_id==1
gen firstpartdetractorpost1 = primera_semana_post_id * detractor_ultima_semana_post1
gen firstpartnodetractorpost1 = primera_semana_post_id * nodetractor_ultima_semana_post1
gen secondpartpost1 = 0
replace secondpartpost1 = 1 if primera_semana_post_id==0 & semana2>13

set more off

/* Table IV */

xi: tobit detractor i.tratamiento*experimento reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) replace excel drop(_Isemana* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4 , mtest(b)
test (_ItraXexper_2=_ItraXexper_3) (_ItraXexper_2=_ItraXexper_4) , mtest(b)
test (_ItraXexper_2=_ItraXexper_3) (_ItraXexper_2=_ItraXexper_4) , mtest

xi: tobit detractor i.tratamiento*firstpart1 i.tratamiento*secondpart1 reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) append excel drop(_Isemana* _Icodigo*)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

xi: tobit detractor i.tratamiento*firstpart1 i.tratamiento*secondpartbonus1 i.tratamiento*secondpartnobonus1 reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) append excel drop(_Isemana* _Icodigo*)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecona2 _ItraXsecona3 _ItraXsecona4 , mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest
/* then for the Dummy IV interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

/* THIS MODEL DOES NOT GO INTO THE PAPER  */
xi: tobit detractor i.tratamiento*firstpartdetractor1 i.tratamiento*firstpartnodetractor1 i.tratamiento*secondpart1 reparaciones i.semana2 i.codigo_gremio if semana2<14 , ll(0) vce(cluster codigo_op)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy I interactions */
test  _ItraXfirsta2  _ItraXfirsta3  _ItraXfirsta4, mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

	/* we drop the first month of the experiment, as the dynamic effects do not make sense there */
xi: tobit detractor i.tratamiento*firstpartdetractor1 i.tratamiento*firstpartnodetractor1 i.tratamiento*secondpart1 reparaciones i.semana2 i.codigo_gremio if semana2<14 & mes!=1 , ll(0) vce(cluster codigo_op)
outreg2 using "table4" , bdec(3) append excel drop(_Isemana* _Icodigo*)
/* first for the Dummy I interactions */
test  _ItraXfirst_2  _ItraXfirst_3  _ItraXfirst_4, mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest(b)
test  (_ItraXfirst_2 =_ItraXfirst_3) (_ItraXfirst_2 =_ItraXfirst_4), mtest
/* then for the Dummy I interactions */
test  _ItraXfirsta2  _ItraXfirsta3  _ItraXfirsta4, mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest(b)
test  (_ItraXfirsta2 =_ItraXfirsta3) (_ItraXfirsta2 =_ItraXfirsta4), mtest
/* then for the Dummy III interactions */
test  _ItraXsecon_2 _ItraXsecon_3 _ItraXsecon_4 , mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest(b)
test  (_ItraXsecon_2 =_ItraXsecon_3) (_ItraXsecon_2=_ItraXsecon_4), mtest

/* Table VI, Model (2) */

xi: tobit detractor i.tratamiento*firstpartdetractor1 i.tratamiento*firstpartnodetractor1 i.tratamiento*secondpart1 i.tratamiento*firstpartdetractorpost1 i.tratamiento*firstpartnodetractorpost1 i.tratamiento*secondpartpost1 reparaciones i.semana2 i.codigo_gremio , ll(0) vce(cluster codigo_op)
outreg2 using "table6_2" , bdec(3) replace excel drop(_Isemana* _Icodigo*)
/* first for the Post Period I interactions */
test  _ItraXfirstb2  _ItraXfirstb3  _ItraXfirstb4, mtest(b)
test  (_ItraXfirstb2 = _ItraXfirstb3) (_ItraXfirstb2 = _ItraXfirstb4), mtest(b)
test  (_ItraXfirstb2 = _ItraXfirstb3) (_ItraXfirstb2 = _ItraXfirstb4), mtest
/* then for the Post Period II interactions */
test  _ItraXfirstc2  _ItraXfirstc3  _ItraXfirstc4, mtest(b)
test  (_ItraXfirstc2 = _ItraXfirstc3) (_ItraXfirstc2 = _ItraXfirstc4), mtest(b)
test  (_ItraXfirstc2 = _ItraXfirstc3) (_ItraXfirstc2 = _ItraXfirstc4), mtest
/* finally for the Post Period III interactions */
test  _ItraXsecona2 _ItraXsecona3 _ItraXsecona4 , mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest(b)
test  (_ItraXsecona2 =_ItraXsecona3) (_ItraXsecona2=_ItraXsecona4), mtest

/* Test of higher variance for weekly treatments */

sort tratamiento

by tratamiento: sum detractor if firstpartdetractor1==1 & mes>1 & mes<4
by tratamiento: sum detractor if firstpartdetractor1==0 & mes>1 & mes<4

hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==1
graph save Graph "Graph_tratamiento_1.gph", replace
hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==2
graph save Graph "Graph_tratamiento_2.gph", replace
hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==3
graph save Graph "Graph_tratamiento_3.gph", replace
hist detractor if firstpartdetractor1==1 & mes>1 &mes<4 & tratamiento==4
graph save Graph "Graph_tratamiento_4.gph", replace

gen freqfeed=1
replace freqfeed=2 if tratamiento==3 | tratamiento==4
sort freqfeed

by freqfeed: sum detractor if firstpartdetractor1==1 & mes>1 & mes<4
by freqfeed: sum detractor if firstpartdetractor1==0 & mes>1 & mes<4

robvar detractor if freqfeed==1 & mes>1 & mes<4 & firstpart1==1, by(firstpartdetractor1)
robvar detractor if freqfeed==2 & mes>1 & mes<4 & firstpart1==1, by(firstpartdetractor1)

robvar detractor if firstpartdetractor1==0 & mes>1 & mes<4 & firstpart1==1, by(freqfeed)
robvar detractor if firstpartdetractor1==1 & mes>1 & mes<4 & firstpart1==1, by(freqfeed)

robvar detractor if freqfeed==1 & mes>1 & mes<4 & firstpart1==0, by(secondpartbonus1)
robvar detractor if freqfeed==2 & mes>1 & mes<4 & firstpart1==0, by(secondpartbonus1)

gen detractorprior="NOSE"
replace detractorprior="SI" if (firstpartdetractor1==1 & firstpart1==1) | (secondpartbonus1==0 & firstpart1==0)
replace detractorprior="NO" if (firstpartdetractor1==0 & firstpart1==1) | (secondpartbonus1==1 & firstpart1==0)


/* Back to monthly data */

restore

collapse (mean) codigo_gremio tratamiento experimento* encuesta* detractor* promotor* verde* amarillo* rojo* insatisfechos* (count) reparaciones=num_reparacion num_encuestas=encuesta , by(codigo_op mes)
merge m:1 codigo_op mes using "`mypath'fontaneros_pda.dta"
drop _merge
merge m:1 codigo_op using "`mypath'stata import data post/fontaneros_region.dta"
drop _merge

set more off

gen operario = 0
replace operario = 1 if substr(codigo_op,1,2)=="71"

/* Table I - Summary stats */

bysort tratamiento: distinct codigo_op if experimento==0 & experimento_post==0
bysort tratamiento: distinct codigo_op if experimento==1
bysort tratamiento: sum reparaciones num_encuestas detractor verde if experimento==0 & experimento_post==0
bysort tratamiento: sum reparaciones num_encuestas detractor verde if experimento==1
gen detractor_cero = 0 if detractor!=.
replace detractor_cero = 1 if detractor==0
bysort tratamiento: sum detractor_cero if experimento==0 & experimento_post==0
bysort tratamiento: sum detractor_cero if experimento==1

gen promotor_cero = 0 if promotor!=.
replace promotor_cero = 1 if promotor==0
sum promotor_cero
gen promotor_uno = 0 if promotor!=.
replace promotor_uno = 1 if promotor==1
sum promotor_uno
gen encuesta_cero = 0 if encuesta!=.
replace encuesta_cero = 1 if encuesta==0
sum encuesta_cero
gen encuesta_diez = 0 if encuesta!=.
replace encuesta_diez = 1 if encuesta==10
sum encuesta_diez

/* there are very few observations with extreme values of Verde (either 0 or 100%) */
gen verde_cero = 0 if verde!=.
replace verde_cero = 1 if verde==0
gen verde_uno = 0 if verde!=.
replace verde_uno = 1 if verde==1
sum verde_cero verde_uno

bysort tratamiento: sum pda if experimento==0 & experimento_post==0 
bysort tratamiento: sum pda if experimento==1
/* there are very few observations with extreme values of PDA (either 0 or 100%) */
gen pda_cero = 0 if pda!=.
replace pda_cero = 1 if pda==0
gen pda_uno = 0 if pda!=.
replace pda_uno = 1 if pda==1
sum pda_cero pda_uno

/* Identify gremios with only one professional. Those gremios have only 7 or 11 observations, so gremio_count==7 or 11 */
/* Those gremios give problems when using gremio fixed effects and clustering std errors by operario (as gremio and operario are the same thing for these gremios) */
/* To avoid this problem, we group all the gremios with one operario into a single new gremio, with code = 0 */

egen gremio_count = count(1) , by(codigo_gremio)
replace codigo_gremio = 0 if gremio_count<12

/* Test whether the distribution of gremios is the same for all four treatments */

tabulate tratamiento codigo_gremio if mes==5 , chi2 lrchi2

/* Test whether the distribution of regions is the same for all four treatments */

tabulate tratamiento delegacion2 if mes==5 , chi2 lrchi2
tabulate tratamiento provincia2 if mes==5 , chi2 lrchi2


/* Table I Panel B.  Regression analysis to check randomization success  */

xi: tobit detractor i.tratamiento if experimento==0 & experimento_post==0, ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) replace excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit detractor i.tratamiento i.mes i.codigo_gremio if experimento==0 & experimento_post==0, ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit verde i.tratamiento if experimento==0 & experimento_post==0, ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit verde i.tratamiento i.mes i.codigo_gremio if experimento==0 & experimento_post==0 , ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit pda i.tratamiento if experimento==0 & experimento_post==0 , ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: tobit pda i.tratamiento i.mes i.codigo_gremio if experimento==0 & experimento_post==0 , ll(0) vce(cluster codigo_op)
outreg2 using "table1b" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)


* Test whether the number of reparaciones and surveys is the same before and during the treatment

xi: reg reparaciones i.tratamiento if experimento==0 & experimento_post==0, vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) replace excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg reparaciones i.tratamiento i.mes if experimento==0 & experimento_post==0, absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg num_encuestas i.tratamiento if experimento==0 & experimento_post==0, vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg num_encuestas i.tratamiento i.mes if experimento==0 & experimento_post==0, absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg reparaciones i.tratamiento if experimento==1 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg reparaciones i.tratamiento i.mes if experimento==1 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg num_encuestas i.tratamiento if experimento==1 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: areg num_encuestas i.tratamiento i.mes if experimento==1 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)

xi: reg reparaciones i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: areg reparaciones i.tratamiento*experimento i.mes if mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: reg num_encuestas i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: areg num_encuestas i.tratamiento*experimento i.mes if mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table1c" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)

xi: tobit reparaciones i.tratamiento*experimento if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) replace excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: tobit reparaciones i.tratamiento*experimento i.mes i.codigo_gremio if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: tobit num_encuestas i.tratamiento*experimento if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
xi: tobit num_encuestas i.tratamiento*experimento i.mes i.codigo_gremio if mes<8 , ll(1) vce(cluster codigo_op)
outreg2 using "table1ct" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)


/* Table II */

xi: reg detractor i.tratamiento*experimento if mes>4 & mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) replace excel
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg detractor i.tratamiento*experimento reparaciones if mes>4 & mes<8 , vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: areg detractor i.tratamiento*experimento reparaciones i.mes if mes>4 & mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: reg detractor i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg detractor i.tratamiento*experimento reparaciones if mes<8 , vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: areg detractor i.tratamiento*experimento reparaciones i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit detractor i.tratamiento*experimento if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) replace excel
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: tobit detractor i.tratamiento*experimento reparaciones if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: tobit detractor i.tratamiento*experimento if mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) append excel
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: tobit detractor i.tratamiento*experimento reparaciones if mes<8 , ll(0) vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes<8 , ll(0) vce(cluster codigo_op)
outreg2 using "table2t" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: reg promotor i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg promotor i.tratamiento*experimento reparaciones if mes<8 , vce(cluster codigo_op)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: areg promotor i.tratamiento*experimento reparaciones i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: reg encuesta i.tratamiento*experimento if mes<8 , vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The next reg is only for reference. Does not go into the paper
xi: reg encuesta i.tratamiento*experimento reparaciones if mes<8 , vce(cluster codigo_op)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: areg encuesta i.tratamiento*experimento reparaciones i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
outreg2 using "table2" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

	* The following regressions test the robustness of the inclusion of "verde" and "pda" as controls, for the referee only, not the paper
xi: areg detractor i.tratamiento*experimento reparaciones verde pda i.mes if mes>4 & mes<8 , absorb(codigo_gremio) vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: areg detractor i.tratamiento*experimento reparaciones verde pda i.mes if mes<8 , absorb(codigo_op) vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones verde pda i.mes i.codigo_gremio if mes>4 & mes<8 , ll(0) vce(cluster codigo_op)
test _Itratamien_2= _Itratamien_4
test _Itratamien_2 _Itratamien_3 _Itratamien_4, mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest(b)
test (_Itratamien_2=_Itratamien_3) (_Itratamien_2=_Itratamien_4), mtest

xi: tobit detractor i.tratamiento*experimento reparaciones verde pda i.mes i.codigo_gremio if mes<8 , ll(0) vce(cluster codigo_op)
test _ItraXexper_2= _ItraXexper_4
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

/* Table VI, Model (1) */

	* The next regression is for reference only, does not go into the table
xi: areg detractor i.tratamiento*experimento i.tratamiento*experimento_post reparaciones i.mes , absorb(codigo_op) vce(cluster codigo_op)

xi: tobit detractor i.tratamiento*experimento i.tratamiento*experimento_post reparaciones i.mes i.codigo_gremio , ll(0) vce(cluster codigo_op)
outreg2 using "table6_1" , bdec(3) replace excel drop(_Imes* _Icodigo*)
test _ItraXexpera2 _ItraXexpera3 _ItraXexpera4, mtest(b)
test (_ItraXexpera2 = _ItraXexpera3) (_ItraXexpera2 = _ItraXexpera4), mtest(b)
test (_ItraXexpera2 = _ItraXexpera3) (_ItraXexpera2 = _ItraXexpera4), mtest

/* Table III TOBIT */

xi: tobit verde i.tratamiento*experimento reparaciones if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) replace excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit verde i.tratamiento*experimento reparaciones i.mes if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit verde i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit pda i.tratamiento*experimento reparaciones if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit pda i.tratamiento*experimento reparaciones i.mes if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest

xi: tobit pda i.tratamiento*experimento reparaciones i.mes i.codigo_gremio if mes<8 , ll(0) ul(1) vce(cluster codigo_op)
outreg2 using "table3" , bdec(3) append excel drop(_Imes* _Icodigo*)
test _ItraXexper_2 _ItraXexper_3 _ItraXexper_4, mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest(b)
test (_ItraXexper_2 = _ItraXexper_3) (_ItraXexper_2 = _ItraXexper_4), mtest



encode codigo_op , generate (code)
tsset code mes

/* Generate variables identifying professionals that drop or join within the experiment period */
gen new = 0
gen old = 0
gen old2 = 0
gen drop = 0

replace new = 1 if code!=l2.code
replace drop = 1 if code!=f2.code
replace old = 1 if code==l2.code
replace old2 = 1 if code==f2.code

tab new if mes==7
tab old if mes==7
tab old2 if mes==5
tab drop if mes==5

/* Generate variables identifying professionals that drop or join between month 5 and 11 */
gen new_post = 0
gen old_post = 0
gen old2_post = 0
gen drop_post = 0

replace new_post = 1 if code!=l6.code
replace drop_post = 1 if code!=f6.code
replace old_post = 1 if code==l6.code
replace old2_post = 1 if code==f6.code

tab new_post if mes==11
tab old_post if mes==11
tab old2_post if mes==5
tab drop_post if mes==5


log close

