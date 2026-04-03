clear 
clear matrix
set more off

set seed 1234567
set matsize 11000

cd "/Users/jasonsandvik/Dropbox/Bol LaViers and Sandvik TAR 2022/Final Data and Code Files for JAR"
*cd "/Users/jasonjamessandvik/Dropbox/Bol LaViers and Sandvik TAR 2022/Final Data and Code Files for JAR"

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Extract accurate pre-screening survey completion times 
****
***
**
* 
import delimited "Data/Screening 1 (M'turk IDs).csv", varnames(1) clear

	keep amazonidentifier durationinseconds
	
save "Data/Screening (M'turk IDs).dta", replace

forvalues i = 2(1)7 {
	import delimited "Data/Screening `i' (M'turk IDs).csv", varnames(1) clear

	keep amazonidentifier durationinseconds

	append using "Data/Screening (M'turk IDs).dta"
	
	save "Data/Screening (M'turk IDs).dta", replace
}
	
	rename amazonidentifier q21

	drop if q21 == "A3K9GTQBOI7O5A" & _n == 898 // Someone submitted the survey twice, deleting the second submission.
	
save "Data/Screening (M'turk IDs).dta", replace	

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Clean up pre-screening survey data
****
***
**
* 
import delimited "Data/Pre-Screen Data.csv", varnames(1) clear

	*** Drop inaccurate duration variable (to be replaced later) ***
	drop durationinseconds

	*** Remove test responses ***
	drop if _n >= 1 & _n <= 12

	*** Check question completion (Risk) ***
	foreach i in 	q73		q81		q91		q101	q111	q121	q131	q141	///
					q151	q161	q171	q181	q191	q201	q211	q221	///
					q231	q241	q251	q261	q271	q281	q291	q301	///
					q311	q321	q331	q341	q351	q361	q371 			{
		gen temp`i' = (`i' != "")
	}
	
	egen NumRisk = rowtotal(tempq73-tempq371)
	
	*** Check question completion (Time) ***
	foreach i in 	q381	q391	q401	q411	q421	q431	q441	q451	///
					q461 	q471 	q481 	q491 	q501 	q511 	q521 	q531 	///
					q541 	q551 	q561 	q571 	q581 	q591 	q601 	q611 	///
					q621 	q631 	q641 	q651 	q661 	q671 	q681 			{
		gen temp`i' = (`i' != "")
	}
	
	egen NumTime = rowtotal(tempq381-tempq681)
	
	*** Recoding categorical variables numerically ***
	tab progress
		destring progress, replace
	
	tab q31 
	gen q31num = .
		replace q31num = 10 if q31 == "Under 18"
		replace q31num = 20 if q31 == "18 - 24"
		replace q31num = 30 if q31 == "25 - 34"
		replace q31num = 40 if q31 == "35 - 44"
		replace q31num = 50 if q31 == "45 - 54"
		replace q31num = 60 if q31 == "55 - 64"
		replace q31num = 70 if q31 == "65 - 74"
		replace q31num = 80 if q31 == "75 - 84"
		
	tab q32 
	gen q32num = .
		replace q32num = 10 if q32 == "Less than high school"
		replace q32num = 12 if q32 == "High school graduate"
		replace q32num = 13 if q32 == "Some college"
		replace q32num = 14 if q32 == "2-year degree"
		replace q32num = 16 if q32 == "4-year degree"
		replace q32num = 18 if q32 == "Masters degree"
		replace q32num = 20 if q32 == "Doctorate degree"
	
	tab q33 
	gen q33num = .
		replace q33num = 0 if q33 != "Male"
		replace q33num = 1 if q33 == "Male"
	
	tab q34 
	gen q34num = .
		replace q34num = 0/100     if q34 == "0 - 50"
		replace q34num = 51/100    if q34 == "51 - 200"
		replace q34num = 201/100   if q34 == "201 - 500"
		replace q34num = 501/100   if q34 == "501 - 1,000"
		replace q34num = 1001/100  if q34 == "1,001 - 2,000"
		replace q34num = 2001/100  if q34 == "2,001 - 5,000"
		replace q34num = 5001/100  if q34 == "5,001 - 10,000"
		replace q34num = 10000/100 if q34 == "Greater than 10,000"
	
	tab q51_1 
	gen q51_1num = .
		replace q51_1num = 5 if q51_1 == "Always"
		replace q51_1num = 4 if q51_1 == "Often"
		replace q51_1num = 3 if q51_1 == "Neither often nor infrequently"
		replace q51_1num = 2 if q51_1 == "Infrequently"
		replace q51_1num = 1 if q51_1 == "Never"
	
	tab q51_2 
	gen q51_2num = .
		replace q51_2num = 5 if q51_2 == "Always"
		replace q51_2num = 4 if q51_2 == "Often"
		replace q51_2num = 3 if q51_2 == "Neither often nor infrequently"
		replace q51_2num = 2 if q51_2 == "Infrequently"
		replace q51_2num = 1 if q51_2 == "Never"
	
	tab q51_3 
	gen q51_3num = .
		replace q51_3num = 5 if q51_3 == "Always"
		replace q51_3num = 4 if q51_3 == "Often"
		replace q51_3num = 3 if q51_3 == "Neither often nor infrequently"
		replace q51_3num = 2 if q51_3 == "Infrequently"
		replace q51_3num = 1 if q51_3 == "Never"	
	
	tab q51_4 
	gen q51_4num = .
		replace q51_4num = 5 if q51_4 == "Always"
		replace q51_4num = 4 if q51_4 == "Often"
		replace q51_4num = 3 if q51_4 == "Neither often nor infrequently"
		replace q51_4num = 2 if q51_4 == "Infrequently"
		replace q51_4num = 1 if q51_4 == "Never"
	
	tab q51_5 
	gen q51_5num = .
		replace q51_5num = 5 if q51_5 == "Always"
		replace q51_5num = 4 if q51_5 == "Often"
		replace q51_5num = 3 if q51_5 == "Neither often nor infrequently"
		replace q51_5num = 2 if q51_5 == "Infrequently"
		replace q51_5num = 1 if q51_5 == "Never"	
	
	tab q51_6 
	gen q51_6num = .
		replace q51_6num = 5 if q51_6 == "Always"
		replace q51_6num = 4 if q51_6 == "Often"
		replace q51_6num = 3 if q51_6 == "Neither often nor infrequently"
		replace q51_6num = 2 if q51_6 == "Infrequently"
		replace q51_6num = 1 if q51_6 == "Never"
	
	tab q711
	
	drop if q21  == ""
	
	drop if workerid == ""
	
	drop if progress != 100
	
	unique workerid if q711 == "Yes, please contact me." | strpos(q711,"No,")
		*** 999
	
	drop if q711 != "Yes, please contact me."
	
	gen no_missing = 0
		replace no_missing = 1 if q31    != "" & q32     != "" & q33     != "" & q34    != "" & q35    != "" & q36    != "" & q37_1  != "" & ///
								  q37_2  != "" & q37_3   != "" & q37_4   != "" & q37_5  != "" & q37_6  != "" & q41_1  != "" & q41_2  != "" & ///
								  q41_3  != "" & q41_4   != "" & q41_5   != "" & q41_6  != "" & q41_7  != "" & q41_8  != "" & q41_9  != "" & ///
								  q41_10 != "" & q51_1   != "" & q51_2   != "" & q51_3  != "" & q51_4  != "" & q51_5  != "" & q51_6  != "" & ///
								  q61_1  != "" & q61_2   != "" & q61_3   != "" & q61_4  != "" & q61_5  != "" & q61_6  != "" & q61_7  != "" & ///
								  q61_8  != "" & q61_9   != "" & q701    != "" & q702   != "" & q703   != "" & q704   != "" & q705   != "" & ///
								  q706   != "" & q707    != "" & NumRisk == 5  & NumTime == 5
		
	unique workerid
		*** 987
	
	keep if no_missing == 1	// Only keep individuals who responded to every question.	
	
	drop if q21 == "A3K9GTQBOI7O5A" & _n == 156 // Someone submitted the survey twice, deleting the second submission.
	drop if q21 == "AY3W2L53R7EL3"  & _n == 678 // Someone submitted the survey twice, deleting the second submission.
	
	gen str30 temp = q21 
	
	drop q21
	rename temp q21
	
	sort q21
	merge n:1 q21 using "Data/Screening (M'turk IDs).dta"
	keep if _merge == 3
	drop _merge
	
	unique workerid
		*** 941
	
	*** The code below was used for the initial allocation of workers to treatments ***
	*	gen temp_rand1 = runiform()
	*
	*	sort temp_rand1
	*
	*	gen Peer_100 = (_n >= 1   & _n <= 235)
	*	gen Peer_10  = (_n >= 236 & _n <= 470)
	*	gen Exec_100 = (_n >= 471 & _n <= 705)
	*	gen Exec_10  = (_n >= 706 & _n <= 941)
	*
	*** We now hard-code in treatments so nothing varies due to temp_rand1 ***
	
	gen Peer_100 = 0
		foreach i in	A200QDO8WE5TFK	A1MWYO3RFZW051	A83LGA6YEC488	A1TXW9TMMU6K2U	A3OLRWACCCCUTU	A1XVEKS9O73ERE	A2J6MMNWUJQUXS	A1BD1GI273RPFF	A19L8SNH73AX1Z	ADWFYAZ4C2E50	A2YVC1U50H2B4R	A1GZNVVE3PMM7Y	A4IH4CO046EV3	A9DEGNR0707LR	A3D3MQ814FCE0W	A3CWEN6Y21V7TL	A152OI3N7VA7A1	A1UBV2NP7OVDVV	A2BF3A9KYSEFPO	A1M682B2WUSYJP	A3QVZ4SZB79D8W	ASVRLMDNQBUD9	A11BACV6DY5S8M	A1945USNZHTROX	A2HJYX70UQW9XR	A3A1PMZDFJD218	A114JRUBJ5IN7D	A2DNLHS1RSTF5R	AWIYSXEA51PFZ	AYFDUTHXE54I	AAIQLE701DI9U	A37P8UZ3SAKM7A	A3EXEK028GISUY	AUFUUD4WG9CVO	A3774HPOUKYTX7	A3NH7YCJLJX082	A11EL5LWS2L1HX	A2WQCH2LL2ZB0D	A3AGQ2G8QI59EG	A2YTQDLACTLIBA	A2F2DDH12YU4AK	A3T8THFPERMABH	A10BH9PYCYUKDJ	A2EPBSY0VPI38S	A11U9MQRLTBD7S	A250FES5PFCGK9	AG9LMLEPXP2YC	A38DHLB88V8DL8	A31X0GSY38JNZY	A37E36IPU0BJX5	A1UZXOMO6BS6I2	AWNR2FOWI73GL	A38OVMF5OWW6JO	A3OMFPTDCHYTQG	AFGWDX72P1M12	A98E8M4QLI9RS	A1Y4PK1XCHCF6Q	A2XPWASDT8AYXH	A1VGQQPI02FE31	AV7UX8QQXABSK	A5Z9DOJRPICW1	A2IP3ZAFYGV8M9	A1HWMTN7NNV4UA	A3IXWFXJC2YKU7	A15340BRCER2UO	A2A91NSJ5LMGOT	AR17E7L7JAOBI	AZ0HX8I272RK3	A7T06JMP6BTDS	A34BOR3V0O2UD2	A1T8YT3FFIRM8N	A2GXLM74C7BDI8	A15XIKX3PI7SLK	A9OOV3976AFYF	A265Y95XHCU9AH	AV22FQTJNBUZT	A346XPIBKBQ8Z6	A12ATVBE1I4567	A397D1I20OGUK7	A2RUHO7I7Y4XFA	AND4JA5WQ3QS9	A10DTLF1LXFY0V	AQEP3H2QADT47	A2N9U74YIPDQ9F	A3KWDWJS73KEJ0	A1KGCOR8OXYR72	A3B8CHEB2ZS31K	A3N6RT3DKHYJED	A31ER1E1ZBM6OR	A8KX1HFH8NE2Q	A2UX7ZJEGGU5	A6KOTWP7N7RLU	A37E2SOKV6I0VZ	A25PFSORDO3SWQ	A10MSB9X1UFLJ5	AQP4PHYDXRBPI	A2A6FH0F7LD9ND	A12QYIZ5MFSRGU	A1S88VQY8G8CNC	A255CJSGL9QRFI	A1ZQ7A1CUV6RD8	AKYXQY5IP7S0Z	AFU00NU09CFXE	A2RSHXMN7VW1ZO	AT6LDQNLKTUSE	A1E2T84AUMW6ZC	A1242WFZD9T05W	A2CY1TSQ3KKP5Q	A1ZJM4WFHQ96DC	A1FSWCUUFJJRVQ	AJITIN95JSBAR	ASQW3O3FX8CL	A27KKIAT4KGUUC	A19BZSL0LVFBO2	A4T4577P6JL6R	AZ8JL3QNIPY4U	A38E7RFKL5PDFP	A11O7TTVXEP9KC	A233HZFRZ1FSNY	A3NGDNN139ED2K	A20SXG1DHDIDI7	A1ZKIH8L6648NG	A37GUFW4K6A1C8	A21EL5W6BYR0ZB	A2090SRVQLWA3F	A145ZMSDSX5W6K	A3FT3XPTOWHJMY	A3N5RLYH05PY8L	ARYL3C6N9SVV1	A2YAYHZYI7M3HD	A73UBWHFPAT7E	AURYD2FH3FUOQ	A1YTNGH5SMM2CJ	A2V4DP31BEVABF	A3KCAT0C3NWVDX	A2H8GNSEVUJXYL	A66GVEZ7BBLH	A2S2XDI50LCWN7	A2VGFS03KCCR1Q	AJRY9ALX8069Y	AA06VO3XJ6KZZ	ARI1EMAHUA9PO	A224I9B6RFJZEI	A2LQ9NP944M61Z	A2XPDRWL1KCWDM	A2WC8DV7EB0FOY	A7ERZELTAMWL5	A1ROEDVMTO9Y3X	ANR0LIX0VLUYJ	A11W6YR06JYK6P	A11YS0T8MV3Q7C	AEEEOIAM9LY7E	A34DYM8J0X5VK	A35O3H71CM4LVZ	AX7IKARE49HR7	A1NOHVLPYWB0TP	A2FL477TMKC91L	A1DKVUTOBPQH11	A1AD0XP7UTCMY2	A1WR6W4VJIT36P	A2NJ6AR78O07FD	A3CVY8G619MGTI	A2TWNZAXELMZXX	AWLT46A9EWTK8	AKMURQ1WQN9CX	A2W02BZI9OCDNX	A28XW9I1PZ8Q05	A3BVM9763IA3MJ	A3BSCX5Y5IFBN0	A2C84POENS2UNY	A3L0DCUXI7X3A9	A1ZD8RU6YB0VEU	A2GOS6NF74E2ST	A34SCRE20A7XV5	A2R0YYUAWNT7UD	A21HK1XWMEL393	A1NUW3AISE7RZC	A273EH17NSJRH0	A2ZNOBR1582SW3	A2Z6EQWA4XJQGI	AYW62R027PUT1	A1GKD3NG1NNHRP	AHRGRIQM9QGFQ	A29AF16RLMI0ES	A1Y25W1Y7KDE5	A3GVUYY3TWRPZT	A17PAE30BGBO1T	AWKUOA7M4P8YI	A3CWVSZAD35D89	A3RASHUE40BP0Q	A2IJMH2RIHEA6M	A1Z2QEEPKEK1X1	A314XJY8V1YL12	AXCIG7A957UO6	A33ST4DW1A4PGK	AWGV0FJZ1UTJ0	ANPKT83QAFZS4	A2VRDE2FHCBMF8	A279YSE7NB16M0	A37T1MVUL5YIC0	A3LT7W355XOAKF	A1O0BGHFTMPQM0	A3DUL880Y08G95	A3OITERGPA20M4	A3OW5EFQ5QFD19	A2EI9E6EBZEZO1	A1F9KLZGHE9DTA	A2GZ00IMOT6L3X	A1NDMFN9A5G25G	A2U66Y6NEEHXET	A1ZDT69ZSLWN29	A2287HLNN9EZ56	A1FG2G9TZSDN	A2AWSN5CWONM8	A39L5W9N08RN33	A3P74FP62XNVYI	A1XCD78DIGGURQ	A1K61OKMPRZUML	A2615YW1YERQBO	A3P57IUDHUKNCE	A2E86HP0ZU8LO4	A114INA2S32A8L	A2FLOH4DM8A4ZS	ARG392N6HWZCJ	A3JCMVMH9UQW88	A2R8IV2PWFTY00	ARSQQK8JASNOE	ACXP8KHFX06KR	A1S65MPJSSYO6D	A37GOGQDYDT44K	A3RACQ7F0RX2V7	A2X00KB1ZFMJEA	A2I960JYUZ8KAV	A2KSAAQBU5R0F6	A11Q8U6QTT8KGF {
			replace Peer_100 = 1 if q21 == "`i'"
	}

	gen Peer_10 = 0
		foreach i in	A25OK203N0QYH2	AR117V5SHH230	A2CK0OXMPOR9LE	A3GZXU4FUJTKZD	A312D4HWI6WC4N	A2CHDWKAYZ3P3E	A19QB9PIVEACNG	AEQ6KLNVTRKKR	APRZ7BR8C0ZMQ	A3KCFTR0HWOH46	A20CZCJPRP54G9	A32PMXX4P67Z56	A21Y7K669KM1PR	A30J4IZCMCR31F	A1Y9395AXC1FS0	A1LRJ4U04532TM	A2ZRL1ZWWXJ0L7	A5YRC4QT53JRO	A1YEHYI76FJTDG	A22DL4DE4DYB0	A196XR61DIW5GU	A1MN2PWAV10VAB	A2MCMD1228NCMP	A1PTH9KTRO06EG	A3GML9VVJ47HL4	AKMQH2MGTUWO9	A1RDGPR72UW206	AIHHRINW9IN1I	AAJ1ZQECDZBEE	A3QUAM5Y482D4U	A2WC2NO555XU3J	ADQYBLW89856C	A2W5MSZP0O4Y2P	A1Z8AOIDT5IV43	A1XZ40T91S5YFU	ADBDQ7FTFHKCR	A1Y0Y6U906ABT5	A55CXM7QR7R0N	ASXNA04AP6W4U	A33JJY3A6V90QM	A30MP4LXV4MIFD	A13WTEQ06V3B6D	AZT1D13D31N4Z	A1GYD62XNQT0O5	A204J4WHUZUN6S	A1DD39VFCRWI8G	AR0LAU6HMO8R1	A234UW0G9PMSCC	A28FL6XWONI7JX	A3RT6RZHJ0V7I1	A15UCCTMGXN62R	A2SWQM5X54P1O5	A18VIO909RWY6D	A3G8OON0TDPN1E	A3SYY5R44RAATE	AADRZTXSE7211	A26UIS59SY4NM6	AFWONF12T4R33	A3EVRS5DB4TE1A	A1SISJL5ST2PWH	A1WP1ED7JVG40P	A4158R4Y06ZB4	A32LHQYJY0ELFS	A2KBTDHM44J7X4	A1T643M1P572AA	A76JFNRDFGHYZ	A27W025UEXS1G0	A2JTSH1VPJQ8FR	A21D9YDJU8K2QI	A220ZCMBT1YMMU	A7VQJN8H4QMI6	A3FF5CCILJAWYT	AL83KKXUORS9Y	A1I7H6RDJS4EKN	AO32GL5867YY7	A3JHJ780SMQ8IB	A1CA6ZXKK09ZRI	A7P3R1AIA4TVV	A1OW526V2AFRQL	A30VLAIIJIG5IS	AL2JY5T878Z2H	A1OIHI9UX426J6	A15EF7P9VE9KDO	A35TE5QRB5ECBN	AMX5R6NLYNA2K	A3K9GTQBOI7O5A	AV7OKGJ2PJO30	A1KHRQ121JTDF6	A1G1OO4IWM8EP5	A3R7L5UI9IEWGD	A1FUWARMP40UX0	A1WR3WTEHJEY2D	A2GJYB46FWIB5Q	A1CT5YVQ1CKUV6	A3SMQNSK314EFB	A21SF3IKIZB0VN	AWAW665TQQP2F	A3JNSBGUKVX3D7	A2I6ZALE49CVSC	A17FGZ1I5P9RZA	A3PLWSCPFLCEGI	A2JW59JRBWUMR2	A1RBLG0D9IB7VD	A2V66KLFVJTLKC	A2YCMT5BPA0AG9	A3FAF93BMDJLAL	A1K8QNLYYYX21W	A1N62PWMUOG2YY	APLBF6JY2C1QZ	A39KUEDR8ZS1CF	A31AUIR5PDLYM	A1C8FN01981A69	A27LCUA35LPVM8	A207IHY6GERCFO	A3W4XLAHW96WQI	A3EQO5ZIDBTSVK	A3D70ANCSMGX5F	AEF74ZYJTTEIA	AH493IGHFX4J4	A392WXKX5TYZC2	A2ZHBK2MDL2L51	A3K2VSBTT3WUTI	A3FMBSTZ3ZGSV1	AL7UTA8J27TFK	AV7A20KYBTQHL	AXY0D2AMLKE2A	A27VFM67RPD2L5	A2DVV59R1CQU6T	A2E17BAZ8T6NQH	A2VX8B1CJXRN2	ACGGIBC0P38HU	AWQ2DG8RUK1ZS	AKSJ3C5O3V9RB	A3OVS29S2TYBQR	AAKBYJD64R6K	AGKCK081EU63R	A3180VXVP8MOIH	A2FWZR12905V6J	A3V5GWY8P6SRO7	A1NZFJHVJ9CNTO	A30CGO77OY7WP0	AU75DIKTVX5GP	A2DZW5E52SJ93H	A2VB8KX3XUA6WU	A1XFZWOOLJ1CGL	A6KB4VHCZYTY2	A1FP3SH704X01V	A2C54JB2A8I1YO	AGAEVJQD8EC7R	A1UOG38V6W8SF6	ACF8CYOJ1P4GC	A3B9QNYDDXGL9I	A2ZOYI7D4IR3PI	A3MWV912LNFD67	A3UV55HC87DO9C	A7EJUD0IAW7FV	A1TGV7LT6LTIQU	A37OUZOGQKGMW0	ASWUVL74BKVT4	A1UKZZL7ANOZRZ	ALTRIHXLUK71A	A3RI9RLBGPG2B6	AZ69TBTDH7AZS	A3AIRKDB2DMC7U	A1D9ZWU1M46SAF	A8C3WNWRBWUXO	A30HUZHJBOX1LK	A2Z6PZ1CYD8NQP	A2W434UNNBRS4L	A3K2I1RP5MQN8Y	A1MJWY7UO3CDSM	AF18OIZ0GWGP2	A3T9WZOUQGE2UW	A273B58CZCS643	AZ4NVW69W0R2	A3UP4PP3ZF1J39	A37XJVQF62ZYC	A23EWFNNOUS10B	AQAXDL1INQC9Q	A3FBC84OAHZ05K	A19DZAFFZEU6GN	A2DVT1QU9ZKVQB	A2YR29YNFLZSUG	A2NA6X1SON3KFH	A110KENBXU7SUJ	AJM4334V07JDQ	A24KZEEOBETVFU	A3TD3PWJ8BU2H1	A3CH1Z6J9R38G9	A3RDH0U2H6JCBC	A1QEQ64E22TNUZ	A26TA3HGBFSPYH	AX3N0BBAJ39GG	A272X64FOZFYLB	A1W7I6FN183I8F	AR5QVMHIITZSZ	A3C5G8LGIAW0XL	AA6RYE4V0IBKM	A35AEGPE73CX8Q	APJ3Z84350UWX	ASP32QB28TEZU	A3W1CKM4PBLRC0	A3UN1F1EOHKKE6	A2SM1GBN4ARGM4	A1HP506HGINWSV	A2MFMT03E21ZIT	A1T0S48O0CMXBC	A22ZYDQ7VRH6EL	A2D29YTN8FLONY	AWE9A4ZOP9LNU	A3RHJEMZ4EGY2U	A1P3HHEXWNLJMP	AKZD89B2WLSX7	A3ZWMVK6GNTJ8	A2DHKTD1GSBXR2	A173A97OFDAX9F	A36XTKYLP4IRDN	A48WNR6C4CI3J	A1FJU83NRI7H2N	AF6CWERDIMNIZ	A3TKA13VTOCJH6	A23G1L7KYHK9F2	A2G7DTL156PTKA	A3P7QP6K56ED2Z	A3N0QZ9ZKUCTCQ	A3NM3GAVMJEI3J	APO6KZZ79PO9Q	ACBSHAUF2NJVJ	A1OZPLHNIU1519	A29HFXCYLT9H8G	ATTGD1M94GFR	A1YFLIT0E5OJG4	AROOCBM042SJD	A2HNNNCB7WM8VD	A3F7IDKJWW8962 {
			replace Peer_10 = 1 if q21 == "`i'"
	}
	
	gen Exec_100 = 0
		foreach i in	A2O2Y99RA9GFUJ	A1PHDT66U6IK4Q	A297OTX4PW0XS3	A12OZ7P7Z41SJI	AOAZMLP27GD81	A1YGDCIKWRTGUR	AHOQWPD49OMW3	A31KYCI27P8OBX	A1TY1T80SHMHQQ	A2MOC4PTJYY15B	A394S7JSNUA3TS	A31Y2UA2LPDSWZ	AJACXA5FC5BYZ	A185ILB68O0TKB	A5BCSSPC180AG	A2EKR2ZFO10VMV	AETJ90D1RKFKE	A3NNDUCFA2MT0J	A47LY43WG0AHG	AK3H5QRAROFGP	A3C4Z92TK10YLG	A222R4PNCF08OF	AN7VKUM6J7KMS	A2V1T6RKD06I2X	A3C4G077LRTC6D	A1YZ0ETOCJO1B2	A3CGQOJC28OVGN	A1KZ21TSAYUHO4	A356795ET25HER	A2OFN0A5CPLH57	AI9QOT5C5DN1P	A3SH7B3UK915FC	A2CP3VS1DEJJLF	AF7D30XDBHKR5	A2GH9GHAPZ9SNH	A364CG5FD4E6H7	ACCNKTAM9UXI3	A1OBB3PWYWK9KK	A3AGU4FBSDDVYS	A2EGVA0ZQMDREH	A3FYWUZK52IC2J	AYYEQBUPC7IM5	A30UE6DWFNUCWX	A2NEFRREWF33YP	ASN25PIODXIPJ	A1NO6ZM4D7A6AB	A3K5HNLPS3F0I8	ALQXHK34IK8Q5	A9HQ3E0F2AGVO	AYY7JSAD0SGXL	A12XX35AAVF8CA	A3SLXLALO5SQXY	AGFWV1U4CJXP5	A1FKRZKU1H9YFC	A3KC385CZNYEG5	A2W3I2GBGDB637	A24B5UF6RMHYGX	AQJU0QTBRKJ3	A2SKXKH9YXZYRI	A3CD92C4577ZV4	A1R1E7TZ9OHFIG	A1LTLWLFZUM1A8	A2M5OXOREG5HYY	A770OB1ZAGJ4G	A2LCFORIW0NF1S	A3B1NS540TRRLW	A21UA6O7ZFAIQJ	AMI8H1U9OH4SM	A270HX8LH9LJ8W	A3HE8OAC0E81Z8	AGNEWBU7179GY	A213ZV8XMZZQ7D	A25W4US5JYIG3F	ALADMO4F1UNQ6	A2FC6G4YCZPSRG	AA4O2W236E3FW	A271V19C06841K	A2UK4UE5N47F3P	AXKTYKCT9NGHS	AHRM15WHLJRBX	A200RIU9CD4AJ8	A166A2M31CW2C7	A37VBAMFEQKJO4	A3C2X1L5PVNNLV	A2R1A479K07ME5	APGX2WZ59OWDN	AMPMTF5IAAMK8	A3UJSDFJ9LBQ6Z	A1D2ZSPIHOI23K	A36470UBRH28GO	A15QJ05RG9EQWD	A3NKBB58VQJY9Z	A25MZY0FNQAK5H	A1JL8N1PWIFDH2	A1NSHNH3MNFRGW	A3908297ZI3LES	A23KH0CK7RRUGX	A28AYIPE4Z2HZM	A2KFOOEQWGN0GK	AJI76D4U5WGBZ	AZZA3J049G7R5	A17K1CHOI773VZ	A8SHMEIEBI27Y	A1S5KQVM900NE	A1PK156G147FCR	A3NFGEUZAH9V5G	A1UCB0D27PY623	A235DXY5FJN0IW	AQY3P7G18A43H	ARWF605I7RWM7	A2UIGDOLX5RV95	AEV8XD03SW1HY	A2R75YFKVALBXE	A2EH0DH8QM4ZSB	A1H2UHJ78F185L	A2O7LNRIBPIHAF	AKVDK30EEV08C	AV30KMIUKDG	A22ZRXQU3UN2FD	A2FMEIDYEIWJA8	AGWWUXDX6CI38	A15PHPJA7AWCS3	A3JTDNRJYVCGQD	A20B6NK33MOBYF	A90T7I7KQIZQA	AIC8CB12DQC0K	A2UF2FRGVW4T89	A24NUJ0TMY0GBG	A3TXO6RKFIDFUV	A3G4VYIIJIUK8W	A3388HIWAKD3DV	A1YII2PYADZKBU	A1HWB810RJBV2K	A1LW7S3NBOSJPA	AJD2Q9O3GMUEX	AOOLS8280CL0Z	A3P5WIW36V70AI	A3EC3OP6U52JYC	AEKNKYFP4VEHM	A4ME21IV40EF6	A2XVOYY8BDEZXF	A1R5W4RQZTROD8	A3FQDPUAXJB0BS	A23EGLIF8IEH11	ALN47U1AGCWWD	A9MA34PVDV5T5	A1PRNTS6WY93GG	A1EIVUU0RIGPFT	A1V2H0UF94ATWY	AC3W6TPL0I3AY	AXQKGVWRFYMM	A18BD5BTUR0KZP	A1TBRQBLEJI3O5	A10AVWALIHR4UQ	A3DRKIY58M1KWO	A3O7X46E3REM7I	A2K287FPB9YFIE	A39GADIK8RLMVC	A2H2NYSFUUNAUB	A2LMQ4497NMK3S	A1VR1XQEQQXYUE	A33Z6BHAJUGCHY	A1ERMRNNR0CZ2Y	A3HHVE3A04F54K	A211HK32QNTYX1	A1NKBLZ8HK0W7	A1VAL7L9L79IN0	A2IJJOV2S8AYLW	A26M997VYVK0E6	A1SC3CR9BN0HZW	A14KEAL1OFB0AL	A14EYTLSMJRPUK	A13FUEPWBCLBUY	A26NGLGGFTATVN	A2BK9RMC0NOIH8	A1DZMZTXWOM9MR	A1Y9NJ9R8M1B1B	A3RRB2LG2DS94Q	A2DU0TGJDZWUCV	A363NKR14886XG	A2Q4Z6CADBW6WD	A1N7O7E8HC03D8	A15VCKELIEEPJN	A4M0D0IZH9XCE	AZLRPIAD0ZHAA	A3DUPRZSMU9W5R	A2ARWUMJ39H4C3	A37S96RT1P1IT2	A255RBA8P0K0XV	A1SLR72L2E2Y7Z	A2B8JGCVGBDTL5	AG7HIGV4SPMXP	A1B5SSGMTAQ9B5	A1QG4N21BF61PC	A3LL096CAY5WHB	A2JZUSRBP6H5S	A1CY7IOJ9YH136	A3BU69EKYL6SH3	A2NHP55T9ZX86Q	A2TKFZQRNAZS1L	A25D8MUZP7CQEY	AVBRJBJONL47I	A13Q8W0MU2Q928	A2JJF5OFND2KL5	A2OVX9UW5WANQE	AQXAQCJFY2ZA7	AYGJUG9FNEJVI	A2HJDLSU95MH8Q	A3HZFB2JLF3JMY	A2OS3NGWKOM69E	A3IA63S5XSB41S	AW5O1RK3W60FC	AMHUDJ44HF1ZH	AOIR8V07FYMH5	A25CZJEFKXF4UV	A2R0Y8A3SSZ30S	AXPBPXPFGL1VH	AVD6HMIO1HLFI	A2TLN8489YGY81	AVPW7AXI9AFSM	A19ZWBQT8A3LIR	AOS2PVHT2HYTL	A3CD3C99T8S6ON	A1IZXYBZFZAPAQ	A3N3RUB3OLAC1K	A2G43KS55YGYQE	A1ND4M1GR1L7LT	ABMPX2Y2IRBMG	A3RR85PK3AV9TU	A1TEXCUTI4IUUN	A1F1OZ54G177D8	A3R818WN41K12K	A237F8I5UDKP9C	A207RKO5B4ZJK6	A3FNC8ELMK8YJA {
			replace Exec_100 = 1 if q21 == "`i'"
	}
	
	gen Exec_10 = 0
		foreach i in	A2ZDEERVRN5AMC	A3IR7DFEKLLLO	A3RCX3IQ8L6HHW	A324M5ZRHX7RUV	A3L8LSM7V7KX3T	ASC6RHT8Z5ZK3	A2MM10557W7PLD	A1F61PZ0U3WK2V	AFSI4GMXWKC2U	A30RAYNDOWQ61S	A3SETW6ELRDABV	A3NMQ3019X6YE0	A2IOHBFHRC6LT4	A2CYY9VKYH1W45	A3UD3KTZ9BC406	A2HRUFTA09371Y	A1RC2ETLOSZGP0	A3EZ3BRM1C5WKV	A28AXX4NCWPH1F	A18SXC3JEN1O0U	A3RIAIOHV70UN1	A22BBAU24IEHPL	A2ONILC0LZKG6Y	A107RJSS561Y7R	A3HO117NQN73GE	A3CMWYLWMENHLZ	A27Y4NEIQQH00M	A3I1W58P6SIV26	A2WQPXGX5H7C0R	AJBOT9QX4WF9U	A1969Q0R4Y0E3J	A2HVYHMQH9DTWH	A1OU8F92A7M3MR	A320QA9HJFUOZO	A2Y1FIRFOQSEB2	A1X8YRYS8MBDWX	A3FJCLBK3HF4PD	A1H5Q9HRH4RPZU	AY2U544TCVPMQ	A183WYXN12P2TJ	A3CI73EFDLS3OF	A2LPP288NK76W4	A1PLQGQ95NICAF	A2E6YPCJHJOLRD	A1E235KE3CSO7H	A3U4MAPO0W65KH	A1WTUFTRMUN5IR	A1IRT5KE42KIIF	A2YGOORS5N9RW8	A17TKHT8FEVH0R	AMTTB8JUWRRM7	A362CV8OOYJA6W	A2JKETV64OU7DY	A2MWAXV1YRK5GH	A2X29OB7P3NBTD	A1LEC9PYYYXM1U	A18R8GG33EVI6C	ANPHAIIM8PSKR	APF1EAZT104LQ	A3R457FAWQXZN3	A288TV72SGDQWE	A19WXS1CLVLEEX	A397HP5TSIF2LO	A15HF9M3EGMCWL	A3B6ANBQU81J1J	A3C8JI69WPTKWH	A3RFCPYQ8A8NLB	A51U5BEIC5XVR	A8UY8LQZCVL7K	A32W24TWSWXW	A1PF01FF85HUY4	A3CDXWJMJ72VZU	A2XFO0X6RCS98M	A2YWSSQEXXCRGK	A1GV0UZU0T2ORS	A8O6G8WC2585	A2M45YGLOWMO4N	A2T007HZK66WM	A3KP8KFGG6734Q	A2SD10MLZVQZXV	A25R2OI9L2Q1OW	A3GEHH49HNJM57	A1Y62O63V3RI8P	A1SWV4X4PD25S1	A37JC45Y9GLSA7	A1PAMVTKGCXSWQ	A9OSWRV7X10FW	A230VUDYOCRZ4N	A1N0D7925N0060	A2NYDCQ3Y6QS4Q	A6YDORFZZXXPQ	AB8BRFF4ZTZ40	AY9155IK2JEMQ	A3W1M37EJKYIZI	A8T0OMJKQW52	A30XJHY5V549VC	A2DSSNN45FH4PG	AYN2UIUYSKVFA	A213AEBX8ZH75U	A258COTB80Y3UZ	A2FIMX1INRS3OG	A2LEY4X3LD8G26	A7OZPNXIVO1FX	A2QO8TLJCJDXU2	A1OWHPMKE7YAGL	A1QWB22PR3CG8N	A6SR4BU227GUH	AK4P9U9NS9DQF	AI4AO0O0WIJF7	A2HFK76PFSAXBE	A3JFC6OJ13O1XR	A1FVXS8IM5QYO8	A3VP27UUQ34OXK	A1WY3YGT618GC0	A2CNNBX9KLQUQJ	A2WVCXVSE0YGML	AEWPAZBYA7XE	A3E6HPXTP1ZCV6	AK2YUQUFZN1L6	A2XPQ8KYFKI6FD	A21XQYRKFFHL4A	AZV8213BMVMOT	A31H7O281ZXBVF	AL8KOIH1DJ7D9	A2IYR9HF66R029	A17LF7GCAFYMSL	AGDJB8B8CDZ71	A1KY0KOA9VWROL	A98QFUWNFJUS3	A1BBC3XMOB889H	A2OHAJ9VVMP90Q	A2WJMGV0HKQG3Z	A1AYMXZRDWWOER	ALYZEGVGT4CXD	AIWSB4YTN32GF	A2POU9TTW177VH	A1L69N4ECWU93U	A22DF0EWILGRLV	A1WLRHL0U23N38	A23KAJRDVCVGOE	A1J8TVICSRC70W	ASE79VYZNLPVD	A9MGD6PRW1N7K	A1QUNP6IYOQMZ5	AK6MQ4IK1A6JT	ACSS93E03ZUGX	A3ON09B35K1L3L	A31Z5TPD8QKE26	A19S4W3QLLQJ0T	A1N53V41FMCR7Q	A1QJ2VPPZG16EG	A23MUEBG3CX8ZH	A460DN2EEDJR9	A25I110YXT1QRA	A30AGR5KF8IEL	A1L1S0IAPZB4MO	A2QWVKYC4RSJKM	A3CP03KUNUMEWF	A31ZLT6OHU6CRY	AGHKGWDYPVDFE	A3R301TNWFNUOS	A12VOC0GO7PP0D	A32AHMZ9FWTBA8	A1BWS5AD2T4NIR	A2PIFMM4Q2I9ZS	ATU9GP0AIM0C2	A2CYT1T5918U1V	A2GV9WSNSPX53	A1LDO8EYGXOA9D	A23HJD4OO7A52G	ABQ4JY52NCREZ	A82Q1HS5CPZ5I	A3EUGO4VR2N4G1	AW0225ONUAPO5	A2ATXOR5WL2S0Q	AFUZULRKG61BD	A3OVXP13IQBN95	AMQGOTPBRWYSF	A2HSCKH5NKN5LP	A19H44LQJ0TEXF	A3C8NUIBNZYMT2	A3I448WWTX2A2D	A322RYFSXVYMRV	A2NNI32STAGVU8	A3792VGWOGILDP	A2V35L3RIRYYXV	A17AE0D93WVDXW	AIJT6YP8Y9V0V	A1JKSAQ8UNCE7B	A2AIR561PPZLT8	A39MKVROUZ1UWR	A1SIUJEL2LS8UO	A1YX4D517MM5M3	ACA4KLH8CR61L	A2E3SM3T01ENIR	A3KNLHB5684AK0	A3ORD55TVUBUGT	AVKCPL8XMWX0J	A2Y0WNHMT4PZ4C	AOWW3URQNRJ6U	ACJ6NSCIWMUZI	A29X5S2VA01LJH	A1LB8HVSXK66U0	A3HN4CIWMVWYVF	A2IQ0QCTQ3KWLT	A7MHJIPWRTJ8D	A12PUQIBXRBOXV	A2V3EB4PT4510C	A33VGSEJ44ORMF	A1UY2W2FL9CWN	AU849EHZNGV2Z	AY3W2L53R7EL3	A1U46YK7C5HEY1	A2ZL5GAZK6S0H1	A1QGG767E07WBA	AQORJW4W8U9YU	A3F51C49T9A34D	A2M9JNCHRKMCC4	A2G5ONLOJVOL2G	A2TG566B22E04	AQ9Y6WD8O72ZC	A1B5O1E2T429ET	A24LB89P1BPKKF	A0378987X22N6PHLDRIB	A36MOV8E6SYHCR	AS85HYEZQONS6	A2F6ZZGWUODNRT	AXAO7UJYYEFCO	AUCHGHY1IKZZK	A1BVG13MHBM1YD	A1AIMKA54UBYIQ	A2CPOBTXUNRSTK	A270SE2VESKXB8	A2WMRGEE0RXQWR	A2G7N0X0PNX0EE	A2RYP5HCVKX4A6 {
			replace Exec_10 = 1 if q21 == "`i'"
	}	
	
	count if Peer_100 == 1 
	count if Peer_10  == 1
	count if Exec_100 == 1
	count if Exec_10  == 1	
	
	gen ParticipantId = q21
	
save "Data/Using Data/Sreening Data.dta", replace

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Prepare master idea file
****
***
**
* 
import excel "Data/Master Idea File.xlsx", sheet(Qualtrics Link) firstrow clear

	drop if Random == . // Drop observations in which no idea was shared

save "Data/Master Idea File - Qualtrics Link.dta", replace

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Clean up raw qualtrics idea files
****
***
**
* 
foreach treatment in "P10_" "P1_" "H10_" "H1_" {

import excel "Data/Raw Qualtrics - `treatment'.xlsx", sheet("Sheet1") firstrow clear

	drop if _n < 3

	foreach i in 	Progress Durationinseconds 										///
					Q12_FirstClick Q12_LastClick Q12_PageSubmit Q12_ClickCount 		///
					Q14_FirstClick Q14_LastClick Q14_PageSubmit Q14_ClickCount 		///
					Q22_FirstClick Q22_LastClick Q22_PageSubmit Q22_ClickCount 		///
					Q34_FirstClick Q34_LastClick Q34_PageSubmit Q34_ClickCount 		///
					Q63_FirstClick Q63_LastClick Q63_PageSubmit Q63_ClickCount 		///
					Q83_FirstClick Q83_LastClick Q83_PageSubmit Q83_ClickCount 		///
					Q103_FirstClick Q103_LastClick Q103_PageSubmit Q103_ClickCount 	///
					Q123_FirstClick Q123_LastClick Q123_PageSubmit Q123_ClickCount  {
		destring `i', replace
	}
	
	drop RecipientLastName RecipientFirstName RecipientEmail ExternalReference DistributionChannel Status
	
	expand 5 // Participants could submit up to five ideas were survey submission.
			 // We expand the sample here to capture these separate ideas and to
			 // set them within their own observation.
	
	sort ResponseId
	by ResponseId: gen ResponseNum = _n
	
	gen Idea = ""
		replace Idea = Q32  if ResponseNum == 1
		replace Idea = Q61  if ResponseNum == 2
		replace Idea = Q81  if ResponseNum == 3
		replace Idea = Q101 if ResponseNum == 4
		replace Idea = Q121 if ResponseNum == 5
	
	gen IdeaTiming_FirstClick = .
		replace IdeaTiming_FirstClick = Q34_FirstClick if ResponseNum == 1
		replace IdeaTiming_FirstClick = Q63_FirstClick if ResponseNum == 2
		replace IdeaTiming_FirstClick = Q83_FirstClick if ResponseNum == 3
		replace IdeaTiming_FirstClick = Q103_FirstClick if ResponseNum == 4
		replace IdeaTiming_FirstClick = Q123_FirstClick if ResponseNum == 5
	
	gen IdeaTiming_LastClick = .
		replace IdeaTiming_LastClick = Q34_LastClick if ResponseNum == 1
		replace IdeaTiming_LastClick = Q63_LastClick if ResponseNum == 2
		replace IdeaTiming_LastClick = Q83_LastClick if ResponseNum == 3
		replace IdeaTiming_LastClick = Q103_LastClick if ResponseNum == 4
		replace IdeaTiming_LastClick = Q123_LastClick if ResponseNum == 5
		
	gen IdeaTiming_PageSubmit = .
		replace IdeaTiming_PageSubmit = Q34_PageSubmit if ResponseNum == 1
		replace IdeaTiming_PageSubmit = Q63_PageSubmit if ResponseNum == 2
		replace IdeaTiming_PageSubmit = Q83_PageSubmit if ResponseNum == 3
		replace IdeaTiming_PageSubmit = Q103_PageSubmit if ResponseNum == 4
		replace IdeaTiming_PageSubmit = Q123_PageSubmit if ResponseNum == 5		
		
	gen IdeaTiming_ClickCount = .
		replace IdeaTiming_ClickCount = Q34_ClickCount if ResponseNum == 1
		replace IdeaTiming_ClickCount = Q63_ClickCount if ResponseNum == 2
		replace IdeaTiming_ClickCount = Q83_ClickCount if ResponseNum == 3
		replace IdeaTiming_ClickCount = Q103_ClickCount if ResponseNum == 4
		replace IdeaTiming_ClickCount = Q123_ClickCount if ResponseNum == 5		
	
	gen IdeaTimeThinking = ""
		replace IdeaTimeThinking = Q41 if ResponseNum == 1
		replace IdeaTimeThinking = Q64 if ResponseNum == 2
		replace IdeaTimeThinking = Q84 if ResponseNum == 3
		replace IdeaTimeThinking = Q104 if ResponseNum == 4
		replace IdeaTimeThinking = Q124 if ResponseNum == 5

	gen IdeaDifficulty = ""
		replace IdeaDifficulty = Q42 if ResponseNum == 1
		replace IdeaDifficulty = Q65 if ResponseNum == 2
		replace IdeaDifficulty = Q85 if ResponseNum == 3
		replace IdeaDifficulty = Q105 if ResponseNum == 4
		replace IdeaDifficulty = Q125 if ResponseNum == 5		
	
	count if Q31 != workerId
	*br Q31 workerId if Q31 != workerId

	*** Clean up messy participant identifiers by comparing to workerId
	replace Q31 = "AQP4PHYDXRBPI"  if Q31 == "AQP4PHYDXRBPI "
	replace Q31 = "A1ROEDVMTO9Y3X" if Q31 == "A1ROEDVMTO9Y3X "

	replace Q31 = "A3NFGEUZAH9V5G" if Q31 == " A3NFGEUZAH9V5G"
	replace Q31 = "A3BU69EKYL6SH3" if Q31 == "JJAN6E5CR"
	
	rename Q31 ParticipantId
	
	gen IdeaId = ResponseId + " " + string(ResponseNum)
	
	gen IdeaTimeThinkingNum = .
		replace IdeaTimeThinkingNum = 0    if strpos(IdeaTimeThinking,"I did not spend any")
		replace IdeaTimeThinkingNum = 2.5  if strpos(IdeaTimeThinking,"Less than 5 minutes")
		replace IdeaTimeThinkingNum = 10   if strpos(IdeaTimeThinking,"More than 5 minutes, less than 15")
		replace IdeaTimeThinkingNum = 22.5 if strpos(IdeaTimeThinking,"More than 15 minutes, less than 30")
		replace IdeaTimeThinkingNum = 45   if strpos(IdeaTimeThinking,"More than 30 minutes, less than 1")
		replace IdeaTimeThinkingNum = 60   if strpos(IdeaTimeThinking,"More than 1 hour")
	
	gen IdeaDifficultyNum = .
		replace IdeaDifficultyNum = 5 if strpos(IdeaDifficulty,"Extremely difficult")
		replace IdeaDifficultyNum = 4 if strpos(IdeaDifficulty,"Somewhat difficult")
		replace IdeaDifficultyNum = 3 if strpos(IdeaDifficulty,"Neither easy nor difficult")
		replace IdeaDifficultyNum = 2 if strpos(IdeaDifficulty,"Somewhat easy")
		replace IdeaDifficultyNum = 1 if strpos(IdeaDifficulty,"Extremely easy")
	
	drop if Idea == ""
	
	order IdeaId ParticipantId workerId ResponseId assignmentId hitId ResponseNum Idea IdeaTimeThinkingNum IdeaDifficultyNum ///
	      IdeaTiming_FirstClick IdeaTiming_LastClick IdeaTiming_PageSubmit IdeaTiming_ClickCount 
	
	drop Q32-Q125
	
	br
	
	gen Treatment = "`treatment'"
	
save "Data/Using Data/`treatment'.dta", replace 	
}
	
use "Data/Using Data/P10_.dta", clear

	append using "Data/Using Data/P1_.dta"
	append using "Data/Using Data/H10_.dta"
	append using "Data/Using Data/H1_.dta"
	
	replace workerId = ParticipantId if workerId == ""
	
	sort ParticipantId StartDate ResponseNum
	by ParticipantId: gen ParticipantIdeaNum = _n
	
save "Data/Using Data/Ideas (no scores).dta", replace	

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Merge in screening data 
****
***
**
* 
	sort ParticipantId
	
	merge n:1 ParticipantId using "Data/Using Data/Sreening Data.dta"
	drop _merge

	replace Treatment = "P1_"  if Peer_100 == 1
	replace Treatment = "P10_" if Peer_10 == 1
	replace Treatment = "H1_"  if Exec_100 == 1
	replace Treatment = "H10_" if Exec_10 == 1
	
	rename q31num Age
	rename q32num YearsofEducation
	rename q33num PercentMale
	rename q34num NumberofHITs
	
	rename q51_1num NewTechnologies
	rename q51_2num CreativeIdeas
	rename q51_3num PromoteIdeas
	rename q51_4num SecureFunds
	rename q51_5num DevelopPlans
	rename q51_6num HowInnovative
	
	gen Female = (q33 == "Female")
	gen OtherGender = (q33 == "Non-binary" | q33 == "Prefer not to say")
	
save "Data/Using Data/Ideas - Screening (no scores).dta", replace	
	
use "Data/Using Data/Ideas - Screening (no scores).dta", clear	

	sort ParticipantId
	by ParticipantId: egen ParticipatedCount = count(IdeaId)

	gen ParticipatedAny = (ParticipatedCount != 0)

	sort IdeaId
	
	merge n:1 IdeaId using "Data/Master Idea File - Qualtrics Link.dta"
	drop _merge
	
	replace SurveyNumber   = _n * 100 if SurveyNumber == . 
	replace QuestionNumber = _n * 100 if SurveyNumber == . 
	
save "Data/Using Data/Ideas - Screening (pre scores).dta", replace

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Prepare peer evaluation files
****
***
**
*  
import excel "Data/Raw Evaluations/Evaluation Survey (1) - Peers.xlsx", sheet("Evaluation Survey (1) - Peers") firstrow allstring clear

	drop if _n == 1 | _n == 2
	
	drop if workerId == ""
	drop if Finished == "0"
	
	unique workerId
	unique assignmentId
	
	rename Q32_FirstClick T2_FirstClick
	rename Q32_LastClick  T2_LastClick
	rename Q32_PageSubmit T2_PageSubmit
	rename Q32_ClickCount T2_ClickCount
	
	rename Q43_FirstClick T13_FirstClick 
	rename Q43_LastClick  T13_LastClick 
	rename Q43_PageSubmit T13_PageSubmit 
	rename Q43_ClickCount T13_ClickCount
	
	expand 20
	
	sort workerId
	by workerId: gen obs = _n
	
	gen SurveyNumber = 1
	gen QuestionNumber = obs
		
	gen Start 	 = StartDate
	gen End   	 = EndDate
	gen Prog     = Progress
	gen Duration = Durationinseconds 
	gen Finish   = Finished
	gen EvalID1  = MturkID
	gen EvalID2  = workerId
	gen JobID    = assignmentId
	gen HITID    = hitId
	
	gen Score_Novel    = ""
	gen Score_Useful   = ""
	gen Score_Creative = ""
	gen Time_First     = ""
	gen Time_Last      = ""
	gen Time_Submit    = ""
	gen Time_Count     = ""
	
	forvalues j = 1(1)20 {
		replace Score_Novel    = Q`j'_1 if QuestionNumber == `j'
		replace Score_Useful   = Q`j'_2 if QuestionNumber == `j'
		replace Score_Creative = Q`j'_3 if QuestionNumber == `j'
		replace Time_First     = T`j'_FirstClick if QuestionNumber == `j'
		replace Time_Last      = T`j'_LastClick  if QuestionNumber == `j'
		replace Time_Submit    = T`j'_PageSubmit if QuestionNumber == `j'
		replace Time_Count     = T`j'_ClickCount if QuestionNumber == `j'
	}
	
	destring Score_Novel   , replace
	destring Score_Useful  , replace
	destring Score_Creative, replace
	destring Time_First    , replace
	destring Time_Last     , replace
	destring Time_Submit   , replace
	destring Time_Count    , replace
	
	keep SurveyNumber-Time_Count
	
	sort SurveyNumber QuestionNumber EvalID1 EvalID2
	
save "Data/Using Data/Peer Evaluations (Compiled).dta", replace	

foreach i in 2 3 4 5 6 7 8 9 10 11 12 13 15 16 {
import excel "Data/Raw Evaluations/Evaluation Survey (`i') - Peers.xlsx", sheet("Evaluation Survey (`i') - Peers") firstrow allstring clear

	drop if _n == 1 | _n == 2
	
	drop if workerId == ""
	drop if Finished == "0"
	
	unique workerId
	unique assignmentId
	
	rename Q32_FirstClick T2_FirstClick
	rename Q32_LastClick  T2_LastClick
	rename Q32_PageSubmit T2_PageSubmit
	rename Q32_ClickCount T2_ClickCount
	
	rename Q43_FirstClick T13_FirstClick 
	rename Q43_LastClick  T13_LastClick 
	rename Q43_PageSubmit T13_PageSubmit 
	rename Q43_ClickCount T13_ClickCount
	
	expand 20
	
	sort workerId
	by workerId: gen obs = _n
	
	gen SurveyNumber = `i'
	gen QuestionNumber = obs
		
	gen Start 	 = StartDate
	gen End   	 = EndDate
	gen Prog     = Progress
	gen Duration = Durationinseconds 
	gen Finish   = Finished
	gen EvalID1  = MturkID
	gen EvalID2  = workerId
	gen JobID    = assignmentId
	gen HITID    = hitId
	
	gen Score_Novel    = ""
	gen Score_Useful   = ""
	gen Score_Creative = ""
	gen Time_First     = ""
	gen Time_Last      = ""
	gen Time_Submit    = ""
	gen Time_Count     = ""
	
	forvalues j = 1(1)20 {
		replace Score_Novel    = Q`j'_1 if QuestionNumber == `j'
		replace Score_Useful   = Q`j'_2 if QuestionNumber == `j'
		replace Score_Creative = Q`j'_3 if QuestionNumber == `j'
		replace Time_First     = T`j'_FirstClick if QuestionNumber == `j'
		replace Time_Last      = T`j'_LastClick  if QuestionNumber == `j'
		replace Time_Submit    = T`j'_PageSubmit if QuestionNumber == `j'
		replace Time_Count     = T`j'_ClickCount if QuestionNumber == `j'
	}
	
	destring Score_Novel   , replace
	destring Score_Useful  , replace
	destring Score_Creative, replace
	destring Time_First    , replace
	destring Time_Last     , replace
	destring Time_Submit   , replace
	destring Time_Count    , replace
	
	keep SurveyNumber-Time_Count
	
	sort SurveyNumber QuestionNumber EvalID1 EvalID2
	
	append using "Data/Using Data/Peer Evaluations (Compiled).dta"
	
save "Data/Using Data/Peer Evaluations (Compiled).dta", replace	
}

foreach i in 14 17 18 19 20 21 22 24 25 26 27 {
import excel "Data/Raw Evaluations/Evaluation Survey (`i') - Peers.xlsx", sheet("Evaluation Survey (`i') - Peers") firstrow allstring clear

	drop if _n == 1 | _n == 2
	
	drop if workerId == ""
	drop if Finished == "0"
	
	drop if ResponseId == "R_3iLofgaRhGyQ3CV" // Someone submitted the survey twice, deleting the second submission.
	
	unique workerId
	unique assignmentId
	
	rename Q32_FirstClick T2_FirstClick
	rename Q32_LastClick  T2_LastClick
	rename Q32_PageSubmit T2_PageSubmit
	rename Q32_ClickCount T2_ClickCount
	
	rename Q43_FirstClick T13_FirstClick 
	rename Q43_LastClick  T13_LastClick 
	rename Q43_PageSubmit T13_PageSubmit 
	rename Q43_ClickCount T13_ClickCount
	
	expand 19
	
	sort workerId
	by workerId: gen obs = _n
	
	gen SurveyNumber = `i'
	gen QuestionNumber = obs
		
	gen Start 	 = StartDate
	gen End   	 = EndDate
	gen Prog     = Progress
	gen Duration = Durationinseconds 
	gen Finish   = Finished
	gen EvalID1  = MturkID
	gen EvalID2  = workerId
	gen JobID    = assignmentId
	gen HITID    = hitId
	
	gen Score_Novel    = ""
	gen Score_Useful   = ""
	gen Score_Creative = ""
	gen Time_First     = ""
	gen Time_Last      = ""
	gen Time_Submit    = ""
	gen Time_Count     = ""
	
	forvalues j = 1(1)19 {
		replace Score_Novel    = Q`j'_1 if QuestionNumber == `j'
		replace Score_Useful   = Q`j'_2 if QuestionNumber == `j'
		replace Score_Creative = Q`j'_3 if QuestionNumber == `j'
		replace Time_First     = T`j'_FirstClick if QuestionNumber == `j'
		replace Time_Last      = T`j'_LastClick  if QuestionNumber == `j'
		replace Time_Submit    = T`j'_PageSubmit if QuestionNumber == `j'
		replace Time_Count     = T`j'_ClickCount if QuestionNumber == `j'
	}
	
	destring Score_Novel   , replace
	destring Score_Useful  , replace
	destring Score_Creative, replace
	destring Time_First    , replace
	destring Time_Last     , replace
	destring Time_Submit   , replace
	destring Time_Count    , replace
	
	keep SurveyNumber-Time_Count
	
	sort SurveyNumber QuestionNumber EvalID1 EvalID2
	
	append using "Data/Using Data/Peer Evaluations (Compiled).dta"
	
save "Data/Using Data/Peer Evaluations (Compiled).dta", replace	
}

import excel "Data/Raw Evaluations/Evaluation Survey (23) - Peers.xlsx", sheet("Evaluation Survey (23) - Peers") firstrow allstring clear

	drop if _n == 1 | _n == 2
	
	drop if workerId == ""
	drop if Finished == "0"
	
	unique workerId
	unique assignmentId
	
	rename Q32_FirstClick T2_FirstClick
	rename Q32_LastClick  T2_LastClick
	rename Q32_PageSubmit T2_PageSubmit
	rename Q32_ClickCount T2_ClickCount
	
	rename Q43_FirstClick T13_FirstClick 
	rename Q43_LastClick  T13_LastClick 
	rename Q43_PageSubmit T13_PageSubmit 
	rename Q43_ClickCount T13_ClickCount
	
	expand 18
	
	sort workerId
	by workerId: gen obs = _n
	
	gen SurveyNumber = 23
	gen QuestionNumber = obs
		
	gen Start 	 = StartDate
	gen End   	 = EndDate
	gen Prog     = Progress
	gen Duration = Durationinseconds 
	gen Finish   = Finished
	gen EvalID1  = MturkID
	gen EvalID2  = workerId
	gen JobID    = assignmentId
	gen HITID    = hitId
	
	gen Score_Novel    = ""
	gen Score_Useful   = ""
	gen Score_Creative = ""
	gen Time_First     = ""
	gen Time_Last      = ""
	gen Time_Submit    = ""
	gen Time_Count     = ""
	
	forvalues j = 1(1)18 {
		replace Score_Novel    = Q`j'_1 if QuestionNumber == `j'
		replace Score_Useful   = Q`j'_2 if QuestionNumber == `j'
		replace Score_Creative = Q`j'_3 if QuestionNumber == `j'
		replace Time_First     = T`j'_FirstClick if QuestionNumber == `j'
		replace Time_Last      = T`j'_LastClick  if QuestionNumber == `j'
		replace Time_Submit    = T`j'_PageSubmit if QuestionNumber == `j'
		replace Time_Count     = T`j'_ClickCount if QuestionNumber == `j'
	}
	
	destring Score_Novel   , replace
	destring Score_Useful  , replace
	destring Score_Creative, replace
	destring Time_First    , replace
	destring Time_Last     , replace
	destring Time_Submit   , replace
	destring Time_Count    , replace
	
	keep SurveyNumber-Time_Count
	
	sort SurveyNumber QuestionNumber EvalID1 EvalID2
	
	append using "Data/Using Data/Peer Evaluations (Compiled).dta"
	
save "Data/Using Data/Peer Evaluations (Compiled).dta", replace	

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Prepare exec evaluation files
****
***
**
*  
import excel "Data/Raw Evaluations/Evaluation Survey (1) - Exec.xlsx", sheet("Evaluation Survey (1) - Exec") firstrow allstring clear

	drop if _n == 1 | _n == 2
	
	drop if Finished == "0"
	
	unique MturkID
	
	rename Q32_FirstClick T2_FirstClick
	rename Q32_LastClick  T2_LastClick
	rename Q32_PageSubmit T2_PageSubmit
	rename Q32_ClickCount T2_ClickCount
	
	rename Q43_FirstClick T13_FirstClick 
	rename Q43_LastClick  T13_LastClick 
	rename Q43_PageSubmit T13_PageSubmit 
	rename Q43_ClickCount T13_ClickCount
	
	expand 20
	
	sort MturkID
	by MturkID: gen obs = _n
	
	gen SurveyNumber = 1
	gen QuestionNumber = obs
		
	gen Start 	 = StartDate
	gen End   	 = EndDate
	gen Prog     = Progress
	gen Duration = Durationinseconds 
	gen Finish   = Finished
	gen EvalID1  = MturkID
	gen EvalID2  = MturkID
	
	gen Score_Novel    = ""
	gen Score_Useful   = ""
	gen Score_Creative = ""
	gen Time_First     = ""
	gen Time_Last      = ""
	gen Time_Submit    = ""
	gen Time_Count     = ""
	
	forvalues j = 1(1)20 {
		replace Score_Novel    = Q`j'_1 if QuestionNumber == `j'
		replace Score_Useful   = Q`j'_2 if QuestionNumber == `j'
		replace Score_Creative = Q`j'_3 if QuestionNumber == `j'
		replace Time_First     = T`j'_FirstClick if QuestionNumber == `j'
		replace Time_Last      = T`j'_LastClick  if QuestionNumber == `j'
		replace Time_Submit    = T`j'_PageSubmit if QuestionNumber == `j'
		replace Time_Count     = T`j'_ClickCount if QuestionNumber == `j'
	}
	
	destring Score_Novel   , replace
	destring Score_Useful  , replace
	destring Score_Creative, replace
	destring Time_First    , replace
	destring Time_Last     , replace
	destring Time_Submit   , replace
	destring Time_Count    , replace
	
	keep SurveyNumber-Time_Count
	
	sort SurveyNumber QuestionNumber EvalID1
	
save "Data/Using Data/Exec Evaluations (Compiled).dta", replace	

foreach i in 2 3 4 5 6 7 8 9 10 11 12 13 15 16 {
import excel "Data/Raw Evaluations/Evaluation Survey (`i') - Exec.xlsx", sheet("Evaluation Survey (`i') - Exec") firstrow allstring clear

	drop if _n == 1 | _n == 2
	
	drop if Finished == "0"
	
	unique MturkID
	
	rename Q32_FirstClick T2_FirstClick
	rename Q32_LastClick  T2_LastClick
	rename Q32_PageSubmit T2_PageSubmit
	rename Q32_ClickCount T2_ClickCount
	
	rename Q43_FirstClick T13_FirstClick 
	rename Q43_LastClick  T13_LastClick 
	rename Q43_PageSubmit T13_PageSubmit 
	rename Q43_ClickCount T13_ClickCount
	
	expand 20
	
	sort MturkID
	by MturkID: gen obs = _n
	
	gen SurveyNumber = `i'
	gen QuestionNumber = obs
		
	gen Start 	 = StartDate
	gen End   	 = EndDate
	gen Prog     = Progress
	gen Duration = Durationinseconds 
	gen Finish   = Finished
	gen EvalID1  = MturkID
	gen EvalID2  = MturkID
	
	gen Score_Novel    = ""
	gen Score_Useful   = ""
	gen Score_Creative = ""
	gen Time_First     = ""
	gen Time_Last      = ""
	gen Time_Submit    = ""
	gen Time_Count     = ""
	
	forvalues j = 1(1)20 {
		replace Score_Novel    = Q`j'_1 if QuestionNumber == `j'
		replace Score_Useful   = Q`j'_2 if QuestionNumber == `j'
		replace Score_Creative = Q`j'_3 if QuestionNumber == `j'
		replace Time_First     = T`j'_FirstClick if QuestionNumber == `j'
		replace Time_Last      = T`j'_LastClick  if QuestionNumber == `j'
		replace Time_Submit    = T`j'_PageSubmit if QuestionNumber == `j'
		replace Time_Count     = T`j'_ClickCount if QuestionNumber == `j'
	}
	
	destring Score_Novel   , replace
	destring Score_Useful  , replace
	destring Score_Creative, replace
	destring Time_First    , replace
	destring Time_Last     , replace
	destring Time_Submit   , replace
	destring Time_Count    , replace
	
	keep SurveyNumber-Time_Count
	
	sort SurveyNumber QuestionNumber EvalID1 EvalID2
	
	append using "Data/Using Data/Exec Evaluations (Compiled).dta"
	
save "Data/Using Data/Exec Evaluations (Compiled).dta", replace	
}

foreach i in 14 17 18 19 20 21 22 24 25 26 27 {
import excel "Data/Raw Evaluations/Evaluation Survey (`i') - Exec.xlsx", sheet("Evaluation Survey (`i') - Exec") firstrow allstring clear

	drop if _n == 1 | _n == 2
	
	drop if Finished == "0"
	
	drop if MturkID == "303" & (strpos(StartDate,"9/14/2020") | strpos(StartDate,"9/29/2020")) // Submitted three times, deleting the one with empty responses and the last one.
	
	unique MturkID
	
	rename Q32_FirstClick T2_FirstClick
	rename Q32_LastClick  T2_LastClick
	rename Q32_PageSubmit T2_PageSubmit
	rename Q32_ClickCount T2_ClickCount
	
	rename Q43_FirstClick T13_FirstClick 
	rename Q43_LastClick  T13_LastClick 
	rename Q43_PageSubmit T13_PageSubmit 
	rename Q43_ClickCount T13_ClickCount
	
	expand 19
	
	sort MturkID
	by MturkID: gen obs = _n
	
	gen SurveyNumber = `i'
	gen QuestionNumber = obs
		
	gen Start 	 = StartDate
	gen End   	 = EndDate
	gen Prog     = Progress
	gen Duration = Durationinseconds 
	gen Finish   = Finished
	gen EvalID1  = MturkID
	gen EvalID2  = MturkID
	
	gen Score_Novel    = ""
	gen Score_Useful   = ""
	gen Score_Creative = ""
	gen Time_First     = ""
	gen Time_Last      = ""
	gen Time_Submit    = ""
	gen Time_Count     = ""
	
	forvalues j = 1(1)19 {
		replace Score_Novel    = Q`j'_1 if QuestionNumber == `j'
		replace Score_Useful   = Q`j'_2 if QuestionNumber == `j'
		replace Score_Creative = Q`j'_3 if QuestionNumber == `j'
		replace Time_First     = T`j'_FirstClick if QuestionNumber == `j'
		replace Time_Last      = T`j'_LastClick  if QuestionNumber == `j'
		replace Time_Submit    = T`j'_PageSubmit if QuestionNumber == `j'
		replace Time_Count     = T`j'_ClickCount if QuestionNumber == `j'
	}
	
	destring Score_Novel   , replace
	destring Score_Useful  , replace
	destring Score_Creative, replace
	destring Time_First    , replace
	destring Time_Last     , replace
	destring Time_Submit   , replace
	destring Time_Count    , replace
	
	keep SurveyNumber-Time_Count
	
	sort SurveyNumber QuestionNumber EvalID1 EvalID2
	
	append using "Data/Using Data/Exec Evaluations (Compiled).dta"
	
save "Data/Using Data/Exec Evaluations (Compiled).dta", replace	
}

import excel "Data/Raw Evaluations/Evaluation Survey (23) - Exec.xlsx", sheet("Evaluation Survey (23) - Exec") firstrow allstring clear

	drop if _n == 1 | _n == 2
	
	drop if Finished == "0"
	
	unique MturkID
	
	rename Q32_FirstClick T2_FirstClick
	rename Q32_LastClick  T2_LastClick
	rename Q32_PageSubmit T2_PageSubmit
	rename Q32_ClickCount T2_ClickCount
	
	rename Q43_FirstClick T13_FirstClick 
	rename Q43_LastClick  T13_LastClick 
	rename Q43_PageSubmit T13_PageSubmit 
	rename Q43_ClickCount T13_ClickCount
	
	expand 18
	
	sort MturkID
	by MturkID: gen obs = _n
	
	gen SurveyNumber = 23
	gen QuestionNumber = obs
		
	gen Start 	 = StartDate
	gen End   	 = EndDate
	gen Prog     = Progress
	gen Duration = Durationinseconds 
	gen Finish   = Finished
	gen EvalID1  = MturkID
	gen EvalID2  = MturkID
	
	gen Score_Novel    = ""
	gen Score_Useful   = ""
	gen Score_Creative = ""
	gen Time_First     = ""
	gen Time_Last      = ""
	gen Time_Submit    = ""
	gen Time_Count     = ""
	
	forvalues j = 1(1)18 {
		replace Score_Novel    = Q`j'_1 if QuestionNumber == `j'
		replace Score_Useful   = Q`j'_2 if QuestionNumber == `j'
		replace Score_Creative = Q`j'_3 if QuestionNumber == `j'
		replace Time_First     = T`j'_FirstClick if QuestionNumber == `j'
		replace Time_Last      = T`j'_LastClick  if QuestionNumber == `j'
		replace Time_Submit    = T`j'_PageSubmit if QuestionNumber == `j'
		replace Time_Count     = T`j'_ClickCount if QuestionNumber == `j'
	}
	
	destring Score_Novel   , replace
	destring Score_Useful  , replace
	destring Score_Creative, replace
	destring Time_First    , replace
	destring Time_Last     , replace
	destring Time_Submit   , replace
	destring Time_Count    , replace
	
	keep SurveyNumber-Time_Count
	
	sort SurveyNumber QuestionNumber EvalID1 EvalID2
	
	append using "Data/Using Data/Exec Evaluations (Compiled).dta"
	
	gen ExecEval = 1
	
save "Data/Using Data/Exec Evaluations (Compiled).dta", replace	

	append using "Data/Using Data/Peer Evaluations (Compiled).dta"

	replace ExecEval = 0 if ExecEval == .

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Create idea-level score variables	
****
***
**
*  
	sort SurveyNumber QuestionNumber
	merge n:1 SurveyNumber QuestionNumber using "Data/Using Data/Ideas - Screening (pre scores).dta"
	drop _merge

	gen Score_Novel_Both = Score_Novel		
	gen Score_Useful_Both = Score_Useful
	gen Score_Creative_Both = Score_Creative	
	
	gen Score_Novel_Exec = Score_Novel	
	gen Score_Useful_Exec = Score_Useful	
	gen Score_Creative_Exec = Score_Creative
		
		replace Score_Novel_Exec = . if ExecEval == 0
		replace Score_Useful_Exec = . if ExecEval == 0
		replace Score_Creative_Exec = . if ExecEval == 0
	
	gen Score_Novel_Peer = Score_Novel
	gen Score_Useful_Peer = Score_Useful
	gen Score_Creative_Peer = Score_Creative
	
		replace Score_Novel_Peer = . if ExecEval == 1
		replace Score_Useful_Peer = . if ExecEval == 1
		replace Score_Creative_Peer = . if ExecEval == 1
	
	gen Peer = (Peer_100 == 1 | Peer_10 == 1)
	gen Exec = (Exec_100 == 1 | Exec_10 == 1)
	gen Ten_10 = (Peer_10 == 1 | Exec_10 == 1)
	gen One_100 = (Peer_100 == 1 | Exec_100 == 1)
		
	sort IdeaId
	
	*** PEER ***
	by IdeaId: egen Overall_Novel_Peer = mean(Score_Novel_Peer)
	by IdeaId: egen Overall_Useful_Peer = mean(Score_Useful_Peer)
	by IdeaId: egen Overall_Creative_Peer = mean(Score_Creative_Peer)
	
	*** EXEC ***
	by IdeaId: egen Overall_Novel_Exec = mean(Score_Novel_Exec)
	by IdeaId: egen Overall_Useful_Exec = mean(Score_Useful_Exec)
	by IdeaId: egen Overall_Creative_Exec = mean(Score_Creative_Exec)
	
	*** BOTH ***
	by IdeaId: egen Overall_Novel_Both = mean(Score_Novel_Both)
	by IdeaId: egen Overall_Useful_Both = mean(Score_Useful_Both)
	by IdeaId: egen Overall_Creative_Both = mean(Score_Creative_Both)
	
	by IdeaId: gen Idea_obs = _n
	
	foreach i in Novel Useful Creative {
		*** Evaluated all surveys or all but one ***
		gen Score_`i'2 = .
			replace Score_`i'2 = Score_`i' if EvalID2 == "A11TPUPFP2S4MK"
			replace Score_`i'2 = Score_`i' if EvalID2 == "A1JJYY622DGE5L"
			replace Score_`i'2 = Score_`i' if EvalID2 == "A2CJYS92WX7HN6"
			replace Score_`i'2 = Score_`i' if EvalID2 == "A3L2FPKRD46FRW"
			replace Score_`i'2 = Score_`i' if EvalID2 == "A2NUGRVI6IEGN7"
			replace Score_`i'2 = Score_`i' if EvalID2 == "101"	
			replace Score_`i'2 = Score_`i' if EvalID2 == "202"
			replace Score_`i'2 = Score_`i' if EvalID2 == "404"
			replace Score_`i'2 = Score_`i' if EvalID2 == "505"
			replace Score_`i'2 = Score_`i' if EvalID2 == "707"
	}		
	
	sort IdeaId
	by IdeaId: egen Overall2_Novel = mean(Score_Novel2)
	by IdeaId: egen Overall2_Useful = mean(Score_Useful2)
	by IdeaId: egen Overall2_Creative = mean(Score_Creative2) 
	
	foreach i in Useful Novel Creative {	
		gen `i'_Treat = .
			replace `i'_Treat = Score_`i' if `i'_Treat == . & Exec == 1 & strlen(EvalID2) == 3
			replace `i'_Treat = Score_`i' if `i'_Treat == . & Peer == 1 & strlen(EvalID2) >  3
			
		sort IdeaId	
		by IdeaId: egen Overall_`i'_Treat = mean(Score_`i') 
	}
	
	sort ParticipantId
	by ParticipantId: gen ParticipantObs = _n
	
	foreach i in Novel Useful Creative {
		gen neg_Overall2_`i' = -1 * Overall2_`i' 
	
		sort Idea_obs Exec One_100 neg_Overall2_`i' IdeaId
		by Idea_obs Exec One_100: gen rank_Overall2_`i' = _n
		
		sort Idea_obs neg_Overall2_`i' IdeaId
		by Idea_obs: gen overallrank_Overall2_`i' = _n
	}

	foreach i in Novel Useful Creative {
		gen neg_Overall_`i'_Exec = -1 * Overall_`i'_Exec
		gen neg_Overall_`i'_Peer = -1 * Overall_`i'_Peer
		gen neg_Overall_`i'_Both = -1 * Overall_`i'_Both
	
		sort Idea_obs Exec One_100 neg_Overall_`i'_Exec
		by Idea_obs Exec One_100: gen rank_Overall_`i'_Exec = _n

		sort Idea_obs neg_Overall_`i'_Exec
		by Idea_obs: gen orank_Overall_`i'_Exec = _n		
		
		sort Idea_obs Exec One_100 neg_Overall_`i'_Peer
		by Idea_obs Exec One_100: gen rank_Overall_`i'_Peer = _n
	
		sort Idea_obs neg_Overall_`i'_Peer
		by Idea_obs: gen orank_Overall_`i'_Peer = _n	
	
		sort Idea_obs Exec One_100 neg_Overall_`i'_Both
		by Idea_obs Exec One_100: gen rank_Overall_`i'_Both = _n	
		
		sort Idea_obs neg_Overall_`i'_Both
		by Idea_obs: gen orank_Overall_`i'_Both = _n		
	}	
	
	gen IdeaLength = strlen(Idea)
	
	gen ten_10 = 1 if Ten_10 == 1
		replace ten_10 = -1 if Ten_10 == 0
	gen peer = 1 if Peer == 1
		replace peer = -1 if Peer == 0
	
	gen Minority40 = .
		replace Minority40 = 0 if (Age <  40 & Female == 0) 
		replace Minority40 = 1 if (Age >= 40 | Female == 1 | OtherGender == 1)
	gen Minority50 = .
		replace Minority50 = 0 if (Age <  50 & Female == 0) 
		replace Minority50 = 1 if (Age >= 50 | Female == 1 | OtherGender == 1)
	
	keep Overall2_Creative Overall2_Useful Overall2_Novel IdeaLength IdeaTimeThinkingNum IdeaDifficultyNum Idea_obs 	///
		 Age Female YearsofEducation NumberofHITs OtherGender Peer_100 Peer_10 Exec_100 Exec_10 						///
		 ParticipantObs ParticipatedCount ParticipatedAny Overall_Creative_Both Overall_Useful_Both Overall_Novel_Both	///
		 IdeaId ParticipantId ten_10 peer Minority50 CreativeIdeas HowInnovative DevelopPlans SecureFunds PromoteIdeas	///
		 rank_Overall2_Useful rank_Overall2_Novel rank_Overall2_Creative Overall_Creative_Peer Overall_Novel_Peer Overall_Useful_Peer	///	
		 Overall_Creative_Exec Overall_Novel_Exec Overall_Useful_Exec Overall_Creative_Treat Overall_Novel_Treat Overall_Useful_Treat	///
		 ExecEval EvalID2 q33 Score_Creative Score_Novel Score_Useful
	
save "Data/Using Data/Data for Analysis (2022-10-18).dta", replace			

stop

use "Data/Using Data/Data for Analysis (2022-10-18).dta", clear	
	
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Table 1: Descriptive Statistics 
****
***
**
*	
	*** Panel A (Ideas) ***	
	gen C0  = ""
	gen C0_ = "&"
	
	forvalues i = 1(1)4 {
		gen C`i'  = .
		gen C`i'_ = "&"
	}
	
	gen C5  = .
	gen C5_ = "\\"
	
	replace C0 = "Creativity" 					in 1
	replace C0 = "Usefulness" 					in 2
	replace C0 = "Novelty" 						in 3
	replace C0 = "Idea Length (characters)" 	in 4
	replace C0 = "Time Spent Thinking (min.)" 	in 5
	replace C0 = "Difficulty of Thinking" 		in 6
	
	local tick = 1
	
	foreach i in Overall2_Creative Overall2_Useful Overall2_Novel IdeaLength IdeaTimeThinkingNum IdeaDifficultyNum {
		sum `i' if Idea_obs == 1 & Overall2_Creative != ., d
			replace C1 = r(N)    in `tick'
			replace C2 = round(r(mean),0.01) in `tick'
			replace C3 = round(r(sd),0.01)   in `tick'
			replace C4 = round(r(min),0.01)  in `tick'
			replace C5 = round(r(max),0.01)  in `tick'
			
		local tick = `tick' + 1
	}
	
	br C0-C5_
	
	drop C0-C5_
	
	*** Panel B (Participants) ***	
	gen C0  = ""
	gen C0_ = "&"
	
	forvalues i = 1(1)4 {
		gen C`i'  = .
		gen C`i'_ = "&"
	}
	
	gen C5  = .
	gen C5_ = "\\"
	
	replace C0 = "Age" 					in 1
	replace C0 = "Female" 	            in 2
	replace C0 = "Years of Education" 	in 3
	replace C0 = "Number of HITs (00s)" in 4
	
	local tick = 1
	
	foreach i in Age Female YearsofEducation NumberofHITs {
		sum `i' if ParticipantObs == 1 & Peer_100 == 1
			replace C1 = round(r(mean),0.01) in `tick'
			replace C1 = r(N) in 6
		sum `i' if ParticipantObs == 1 & Peer_10  == 1	
			replace C2 = round(r(mean),0.01) in `tick'
			replace C2 = r(N) in 6
		sum `i' if ParticipantObs == 1 & Exec_100 == 1	
			replace C3 = round(r(mean),0.01) in `tick'
			replace C3 = r(N) in 6
		sum `i' if ParticipantObs == 1 & Exec_10  == 1	
			replace C4 = round(r(mean),0.01) in `tick'
			replace C4 = r(N) in 6
			
		regress `i' Peer_100 Peer_10 Exec_100 Exec_10 if ParticipantObs == 1, noconstant   
		test Peer_100 = Peer_10 = Exec_100 = Exec_10
			replace C5 = round(r(p),0.001) in `tick'	
			
		local tick = `tick' + 1
	}
	
	br C0-C5_
	
	drop C0-C5_
	
	*** Variation in Participant Demographics ***
	sum Age 				if ParticipantObs == 1, d 
	sum Female 				if ParticipantObs == 1, d 
	
	tab q33 if ParticipantObs == 1
	
	sum YearsofEducation 	if ParticipantObs == 1, d 
	sum NumberofHITs 		if ParticipantObs == 1, d
	
	count if (Age <  30 | Age >  50) & ParticipantObs == 1
		local temp1 = r(N)
	count if (Age >= 30 & Age <= 50) & ParticipantObs == 1
		local temp2 = r(N)
		local temp3 = `temp2' / (`temp1' + `temp2')
		display `temp3'
	
	tab Age if ParticipantObs == 1 
	
	*** Panel C (Participation Rates)
	unique IdeaId if ParticipatedCount != 0 & Overall_Creative_Both != . & Peer_100 == 1
		*** 138
	unique IdeaId if ParticipatedCount != 0 & Overall_Creative_Both != . & Peer_10  == 1
		*** 170
	unique IdeaId if ParticipatedCount != 0 & Overall_Creative_Both != . & Exec_100 == 1
		*** 113
	unique IdeaId if ParticipatedCount != 0 & Overall_Creative_Both != . & Exec_10  == 1
		*** 106

	unique ParticipantId if ParticipatedCount != 0 & Peer_100 == 1
		*** 50
	unique ParticipantId if ParticipatedCount != 0 & Peer_10  == 1
		*** 67
	unique ParticipantId if ParticipatedCount != 0 & Exec_100 == 1
		*** 55
	unique ParticipantId if ParticipatedCount != 0 & Exec_10  == 1
		*** 56			
		
	unique ParticipantId if ParticipatedCount == 0 & Peer_100 == 1
		*** 185
	unique ParticipantId if ParticipatedCount == 0 & Peer_10  == 1
		*** 168
	unique ParticipantId if ParticipatedCount == 0 & Exec_100 == 1
		*** 180
	unique ParticipantId if ParticipatedCount == 0 & Exec_10  == 1
		*** 180	
	
	unique ParticipantId if ParticipatedCount == 1 & Peer_100 == 1
		*** 24
	unique ParticipantId if ParticipatedCount == 1 & Peer_10  == 1
		*** 36
	unique ParticipantId if ParticipatedCount == 1 & Exec_100 == 1
		*** 32
	unique ParticipantId if ParticipatedCount == 1 & Exec_10  == 1
		*** 27	
	
	unique ParticipantId if ParticipatedCount >= 2 & ParticipatedCount <= 5 & Peer_100 == 1
		*** 22
	unique ParticipantId if ParticipatedCount >= 2 & ParticipatedCount <= 5 & Peer_10  == 1
		*** 26
	unique ParticipantId if ParticipatedCount >= 2 & ParticipatedCount <= 5 & Exec_100 == 1
		*** 20
	unique ParticipantId if ParticipatedCount >= 2 & ParticipatedCount <= 5 & Exec_10  == 1
		*** 28	
		
	unique ParticipantId if ParticipatedCount >= 6 & ParticipatedCount <= 10 & Peer_100 == 1
		*** 3
	unique ParticipantId if ParticipatedCount >= 6 & ParticipatedCount <= 10 & Peer_10  == 1
		*** 3
	unique ParticipantId if ParticipatedCount >= 6 & ParticipatedCount <= 10 & Exec_100 == 1
		*** 2
	unique ParticipantId if ParticipatedCount >= 6 & ParticipatedCount <= 10 & Exec_10  == 1
		*** 1			
	
	unique ParticipantId if ParticipatedCount >= 11 & ParticipatedCount <= 15 & Peer_100 == 1
		*** 0
	unique ParticipantId if ParticipatedCount >= 11 & ParticipatedCount <= 15 & Peer_10  == 1
		*** 2
	unique ParticipantId if ParticipatedCount >= 11 & ParticipatedCount <= 15 & Exec_100 == 1
		*** 1
	unique ParticipantId if ParticipatedCount >= 11 & ParticipatedCount <= 15 & Exec_10  == 1
		*** 0	
	
	unique ParticipantId if ParticipatedCount >= 16 & ParticipatedCount < . & Peer_100 == 1
		*** 1
	unique ParticipantId if ParticipatedCount >= 16 & ParticipatedCount < . & Peer_10  == 1
		*** 0
	unique ParticipantId if ParticipatedCount >= 16 & ParticipatedCount < . & Exec_100 == 1
		*** 0
	unique ParticipantId if ParticipatedCount >= 16 & ParticipatedCount < . & Exec_10  == 1
		*** 0	
	
	unique ParticipantId if ParticipatedCount != 0 
	
	*** Treatment Cell of the Outlier ***
	count if ParticipatedCount == 26 & Peer_100 == 1 // Outlier is here
	count if ParticipatedCount == 26 & Peer_10  == 1
	count if ParticipatedCount == 26 & Exec_100 == 1
	count if ParticipatedCount == 26 & Exec_10  == 1
	
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Table 2: Correlation Table 
****
***
**
*		
	pwcorr Overall2_Creative Overall2_Useful Overall2_Novel IdeaLength IdeaTimeThinkingNum IdeaDifficultyNum if Idea_obs == 1 & Overall2_Creative != ., sig
	
	*** Correlation between usefulness and creativity is much higher when execs eval, then when peers eval ***
	*** 0.6569 vs. 0.3580

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Table 3: Participation with Dummy Coding and Effects Coding for Interaction
****
***
**
* 	
	local controls "Age Female YearsofEducation NumberofHITs OtherGender"
	
	estimates clear
	qui: reghdfe ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1, noabsorb vce(robust)
		est store A	
	qui: reghdfe ParticipatedAny   c.ten_10##c.peer `controls' if ParticipantObs == 1, noabsorb vce(robust)
		est store B			
	estout1 A B, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") ///
			     stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  ///
				 keep(c.peer c.ten c.ten_10#c.peer) replace

*
**
*** Sans-Controls
**
*
	estimates clear
	qui: reghdfe ParticipatedCount c.ten_10##c.peer if ParticipantObs == 1, noabsorb vce(robust)
		est store A	
	qui: reghdfe ParticipatedAny   c.ten_10##c.peer if ParticipantObs == 1, noabsorb vce(robust)
		est store B			
	estout1 A B, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") ///
			     stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  ///
				 keep(c.peer c.ten c.ten_10#c.peer) replace						  
						  
*
**
*** Result Among Contributors Only
**
*
	local controls "Age Female YearsofEducation NumberofHITs OtherGender"
	
	estimates clear
	qui: reghdfe ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1 & ParticipatedCount > 0, noabsorb vce(robust)
		est store A	
	estout1 A, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations")  ///
			   stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                   ///
			   keep(c.peer c.ten c.ten_10#c.peer) replace						  
						  
*
**
*** Outlier Controlled Specifications
**
*
	local controls "Age Female YearsofEducation NumberofHITs OtherGender"
	
	estimates clear
	qui: reghdfe ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1 & ParticipatedCount < 26, noabsorb vce(robust)
		est store A	
	qui: reghdfe ParticipatedAny   c.ten_10##c.peer `controls' if ParticipantObs == 1 & ParticipatedCount < 26, noabsorb vce(robust)
		est store B			
	estout1 A B, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") ///
			     stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  ///
				 keep(c.peer c.ten c.ten_10#c.peer) replace
					  
	foreach i in 10 11 12 13 14 15 {
		gen ParticipatedCount`i' = ParticipatedCount
			replace ParticipatedCount`i' = `i' if ParticipatedCount > `i'
	}		
	
	foreach i in 10 11 12 13 14 15 { 
		local controls "Age Female YearsofEducation NumberofHITs OtherGender"
		
		display " "
		display "`i'"
	
		estimates clear
		qui: reghdfe ParticipatedCount`i' c.ten_10##c.peer `controls' if ParticipantObs == 1, noabsorb vce(robust)
			est store A	
		qui: reghdfe ParticipatedAny      c.ten_10##c.peer `controls' if ParticipantObs == 1, noabsorb vce(robust)
			est store B			
		estout1 A B, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") ///
					 stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  ///
					 keep(c.peer c.ten c.ten_10#c.peer) replace
	}

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Table 4: Effect of Contest Design Feature Among Young/Male vs. non-Young/Male
****
***
**
*		
	local controls "Age YearsofEducation NumberofHITs"
	
	estimates clear
	qui: reghdfe ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 1, noabsorb vce(robust)
		est store A
	     reg     ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 1
		est store A1
	qui: reghdfe ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 0, noabsorb vce(robust)
		est store B
	     reg     ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 0
		est store B1
		suest A1 B1
		test [A1_mean]c.peer   		  = [B1_mean]c.peer		
		test [A1_mean]c.ten_10 		  = [B1_mean]c.ten_10
		test [A1_mean]c.ten_10#c.peer = [B1_mean]c.ten_10#c.peer
	qui: reghdfe ParticipatedCount c.ten_10##c.peer##Minority50 `controls' if ParticipantObs == 1, noabsorb vce(robust)
		est store C
	qui: reghdfe ParticipatedAny c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 1, noabsorb vce(robust)
		est store D
	     reg     ParticipatedAny c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 1
		est store D1
	qui: reghdfe ParticipatedAny c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 0, noabsorb vce(robust)
		est store E
	     reg     ParticipatedAny c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 0
		est store E1
		suest D1 E1
		test [D1_mean]c.peer   		  = [E1_mean]c.peer		
		test [D1_mean]c.ten_10 		  = [E1_mean]c.ten_10
		test [D1_mean]c.ten_10#c.peer = [E1_mean]c.ten_10#c.peer
	qui: reghdfe ParticipatedAny c.ten_10##c.peer##Minority50 `controls' if ParticipantObs == 1, noabsorb vce(robust)
		est store F		
	estout1 A B C D E F, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") 	///
						 stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  	///
						 keep(c.peer c.ten c.ten_10#c.peer c.peer#1.Minority50						   		///
							  c.ten_10#1.Minority50 c.ten_10#c.peer#1.Minority50 1.Minority50) replace							  

*
**
*** With Gender Control
**
*
	local controls "Age Female YearsofEducation NumberofHITs OtherGender"
	
	estimates clear
	qui: reghdfe ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 1, noabsorb vce(robust)
		est store A
	     reg     ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 1
		est store A1
	qui: reghdfe ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 0, noabsorb vce(robust)
		est store B
	     reg     ParticipatedCount c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 0
		est store B1
		suest A1 B1
		test [A1_mean]c.peer   		  = [B1_mean]c.peer		
		test [A1_mean]c.ten_10 		  = [B1_mean]c.ten_10
		test [A1_mean]c.ten_10#c.peer = [B1_mean]c.ten_10#c.peer
	qui: reghdfe ParticipatedCount c.ten_10##c.peer##Minority50 `controls' if ParticipantObs == 1, noabsorb vce(robust)
		est store C
	qui: reghdfe ParticipatedAny c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 1, noabsorb vce(robust)
		est store D
	     reg     ParticipatedAny c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 1
		est store D1
	qui: reghdfe ParticipatedAny c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 0, noabsorb vce(robust)
		est store E
	     reg     ParticipatedAny c.ten_10##c.peer `controls' if ParticipantObs == 1 & Minority50 == 0
		est store E1
		suest D1 E1
		test [D1_mean]c.peer   		  = [E1_mean]c.peer		
		test [D1_mean]c.ten_10 		  = [E1_mean]c.ten_10
		test [D1_mean]c.ten_10#c.peer = [E1_mean]c.ten_10#c.peer
	qui: reghdfe ParticipatedAny c.ten_10##c.peer##Minority50 `controls' if ParticipantObs == 1, noabsorb vce(robust)
		est store F		
	estout1 A B C D E F, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") 	///
						 stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  	///
						 keep(c.peer c.ten c.ten_10#c.peer c.peer#1.Minority50						   		///
							  c.ten_10#1.Minority50 c.ten_10#c.peer#1.Minority50 1.Minority50) replace
							  
*
**
*** Without Any Contorls
**
*							  	
	estimates clear
	qui: reghdfe ParticipatedCount c.ten_10##c.peer if ParticipantObs == 1 & Minority50 == 1, noabsorb vce(robust)
		est store A
	     reg     ParticipatedCount c.ten_10##c.peer if ParticipantObs == 1 & Minority50 == 1
		est store A1
	qui: reghdfe ParticipatedCount c.ten_10##c.peer if ParticipantObs == 1 & Minority50 == 0, noabsorb vce(robust)
		est store B
	     reg     ParticipatedCount c.ten_10##c.peer if ParticipantObs == 1 & Minority50 == 0
		est store B1
		suest A1 B1
		test [A1_mean]c.peer   		  = [B1_mean]c.peer		
		test [A1_mean]c.ten_10 		  = [B1_mean]c.ten_10
		test [A1_mean]c.ten_10#c.peer = [B1_mean]c.ten_10#c.peer
	qui: reghdfe ParticipatedCount c.ten_10##c.peer##Minority50 if ParticipantObs == 1, noabsorb vce(robust)
		est store C
	qui: reghdfe ParticipatedAny c.ten_10##c.peer if ParticipantObs == 1 & Minority50 == 1, noabsorb vce(robust)
		est store D
	     reg     ParticipatedAny c.ten_10##c.peer if ParticipantObs == 1 & Minority50 == 1
		est store D1
	qui: reghdfe ParticipatedAny c.ten_10##c.peer if ParticipantObs == 1 & Minority50 == 0, noabsorb vce(robust)
		est store E
	     reg     ParticipatedAny c.ten_10##c.peer if ParticipantObs == 1 & Minority50 == 0
		est store E1
		suest D1 E1
		test [D1_mean]c.peer   		  = [E1_mean]c.peer		
		test [D1_mean]c.ten_10 		  = [E1_mean]c.ten_10
		test [D1_mean]c.ten_10#c.peer = [E1_mean]c.ten_10#c.peer
	qui: reghdfe ParticipatedAny c.ten_10##c.peer##Minority50 if ParticipantObs == 1, noabsorb vce(robust)
		est store F		
	estout1 A B C D E F, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") 	///
						 stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  	///
						 keep(c.peer c.ten c.ten_10#c.peer c.peer#1.Minority50						   		///
							  c.ten_10#1.Minority50 c.ten_10#c.peer#1.Minority50 1.Minority50) replace		

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Figure 1: Compare Self-Reported Creativity of Young/Male vs. non-Young/Male
****
***
**
*	
	ttest CreativeIdeas if ParticipantObs == 1, by(Minority50)
	ttest HowInnovative if ParticipantObs == 1, by(Minority50)
	ttest DevelopPlans  if ParticipantObs == 1, by(Minority50)
	ttest SecureFunds   if ParticipantObs == 1, by(Minority50)
	ttest PromoteIdeas  if ParticipantObs == 1, by(Minority50)
	
	gen beta = .
	gen _se1 = .
	gen _se2 = .
	gen spot = .
	
	local temp = 1
	foreach i in CreativeIdeas HowInnovative DevelopPlans SecureFunds PromoteIdeas {
		
		ttest `i' if ParticipantObs == 1, by(Minority50)
		
		replace beta = r(mu_2) - r(mu_1) in `temp'
		replace _se1 = beta + r(se)*1.645 in `temp'
		replace _se2 = beta - r(se)*1.645 in `temp'
		replace spot = `temp' in `temp'
		
		local temp = `temp' + 1
	}	

	graph set window fontface "Times New Roman"
	
	twoway 	(connected beta spot, mcolor(maroon) lcolor(white) lwidth(medthick) lpattern(dash)) || 	///
			(rcap _se1 _se2 spot, lcolor(maroon) lwidth(medthick)), 								///
			graphregion(color(white)) bgcolor(white) plotregion(color(white)) legend(off)			///			
			xlabel(.75 " " 5.25 " " 																///
				   1 `" "Creative" "Ideas" "' 2 `" "Are" "Innovative" "'							///
			       3 `" "Develop" "Plans" "'  4 `" "Secure" "Funds" "' 								///
				   5 `" "Promote" "Ideas" "', notick) xtitle("")  									///
			ytitle("Difference and 90% Confidence Interval") yline(0, lcolor(black) lpattern(dash))  
			graph export "Analysis and Documentation/Tables and Figures/CreativityFigures(Minority50).png", as(png) name("Graph") replace
	
	graph set window fontface default
	
	drop beta _se1 _se2 spot		
			
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Table 5: Main Quality Results w/ Top Idea Columns
****
***
**
*	
	local controls "Age Female YearsofEducation NumberofHITs OtherGender"
	
	foreach i in Useful Novel Creative {
		estimates clear
		qui: reghdfe Overall2_`i' c.ten_10##c.peer `controls' if Idea_obs == 1							 , noabsorb vce(robust)
			est store A
		qui: reghdfe Overall2_`i' c.ten_10##c.peer `controls' if Idea_obs == 1 & rank_Overall2_`i' <=  50, noabsorb vce(robust)
			est store B
		qui: reghdfe Overall2_`i' c.ten_10##c.peer `controls' if Idea_obs == 1 & rank_Overall2_`i' <=  25, noabsorb vce(robust)
			est store C	
		estout1 A B C, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") 	///
					   stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  	///
					   keep(c.peer c.ten_10 c.ten_10#c.peer) replace						 
		display " "
		display " "
	}

	sum Overall2_Useful   if Idea_obs == 1, d
	sum Overall2_Novel    if Idea_obs == 1, d
	sum Overall2_Creative if Idea_obs == 1, d
	
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Table 6: Effort Exertion Results w/ Top Idea Columns 
***** 
****
***
**
*		
	local controls "Age Female YearsofEducation NumberofHITs OtherGender"
	
	foreach i in IdeaTimeThinkingNum IdeaDifficultyNum IdeaLength {
		estimates clear
		qui: reghdfe `i' c.ten_10##c.peer `controls' if Idea_obs == 1 & Overall2_Creative != .						          , noabsorb vce(robust)
			est store A
		qui: reghdfe `i' c.ten_10##c.peer `controls' if Idea_obs == 1 & Overall2_Creative != . & rank_Overall2_Creative <=  50, noabsorb vce(robust)
			est store B
		qui: reghdfe `i' c.ten_10##c.peer `controls' if Idea_obs == 1 & Overall2_Creative != . & rank_Overall2_Creative <=  25, noabsorb vce(robust)
			est store C	
		estout1 A B C, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") 	///
					   stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  	///
					   keep(c.peer c.ten_10 c.ten_10#c.peer) replace						 
		display " "
		display " "
	}

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Table A.1: Main Results Table (Robustness)
****
***
**
*	
	local controls "Age Female YearsofEducation NumberofHITs OtherGender"
	
	foreach i in Useful Novel Creative {
		estimates clear
		qui: reghdfe Overall2_`i'      c.ten_10##c.peer `controls' if Idea_obs == 1, noabsorb vce(robust)
			est store A
		qui: reghdfe Overall_`i'_Both  c.ten_10##c.peer `controls' if Idea_obs == 1, noabsorb vce(robust)
			est store B
		qui: reghdfe Overall_`i'_Exec  c.ten_10##c.peer `controls' if Idea_obs == 1, noabsorb vce(robust)
			est store C
		qui: reghdfe Overall_`i'_Peer  c.ten_10##c.peer `controls' if Idea_obs == 1, noabsorb vce(robust)
			est store D
		qui: reghdfe Overall_`i'_Treat c.ten_10##c.peer `controls' if Idea_obs == 1, noabsorb vce(robust)
			est store E	
		estout1 A B C D E, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") ///
						   stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  ///
						   keep(c.peer c.ten_10 c.ten_10#c.peer) replace						 
		display " "
		display " "	
	}						 	 

********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*
**
***
****
***** Table 7: Did PhD Students Care More or Less About Usefulness?
***** 
****
***
**
*		
	estimates clear 
	qui: reghdfe Overall_Creative_Peer Overall_Novel_Peer Overall_Useful_Peer if Idea_obs == 1, noabsorb 			   vce(robust)
		est store A
		test _b[Overall_Novel_Peer] = _b[Overall_Useful_Peer]
	qui: reghdfe Score_Creative Score_Novel Score_Useful 					  if ExecEval == 0, noabsorb 			   vce(robust)
		est store B
		test _b[Score_Novel] = _b[Score_Useful]
	qui: reghdfe Score_Creative Score_Novel Score_Useful 					  if ExecEval == 0, absorb(EvalID2) 	   vce(robust)
		est store C
		test _b[Score_Novel] = _b[Score_Useful]
	qui: reghdfe Score_Creative Score_Novel Score_Useful 					  if ExecEval == 0, absorb(EvalID2 IdeaId) vce(robust)
		est store D
		test _b[Score_Novel] = _b[Score_Useful]
	estout1 A B C D, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") ///
					 stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  ///
					 keep(Overall_Useful_Peer Overall_Novel_Peer Score_Useful Score_Novel) replace
  
	estimates clear   
	qui: reghdfe Overall_Creative_Exec Overall_Novel_Exec Overall_Useful_Exec if Idea_obs == 1, noabsorb 			   vce(robust)   
		est store A
		test _b[Overall_Novel_Exec] = _b[Overall_Useful_Exec]
	qui: reghdfe Score_Creative Score_Novel Score_Useful 					  if ExecEval == 1, noabsorb 			   vce(robust)
		est store B
		test _b[Score_Novel] = _b[Score_Useful]
	qui: reghdfe Score_Creative Score_Novel Score_Useful 					  if ExecEval == 1, absorb(EvalID2) 	   vce(robust)
		est store C
		test _b[Score_Novel] = _b[Score_Useful]
	qui: reghdfe Score_Creative Score_Novel Score_Useful 					  if ExecEval == 1, absorb(EvalID2 IdeaId) vce(robust)
		est store D
		test _b[Score_Novel] = _b[Score_Useful]
	estout1 A B C D, style(tex) p(par) stats(r2_a N) nohead stlabels("Adj. R-Square" "Observations") ///
					 stfmt(%9.3f %9.0fc %9.0fc) star(0.10 0.05 0.01) cons(Constant)                  ///
					 keep(Overall_Useful_Exec Overall_Novel_Exec Score_Useful Score_Novel) replace

*
**
*** Compare Coefficients
**
*
	estimates clear 
	reg Overall_Creative_Peer Overall_Novel_Peer Overall_Useful_Peer if Idea_obs == 1
		est store A1
	reg Overall_Creative_Exec Overall_Novel_Exec Overall_Useful_Exec if Idea_obs == 1 
		est store A2
		suest A1 A2
	test [A1_mean]Overall_Novel_Peer  = [A2_mean]Overall_Novel_Exec
	test [A1_mean]Overall_Useful_Peer = [A2_mean]Overall_Useful_Exec
			
	reg Score_Creative Score_Novel Score_Useful if ExecEval == 0
		est store B1
	reg Score_Creative Score_Novel Score_Useful if ExecEval == 1
		est store B2
		suest B1 B2
	test [B1_mean]Score_Novel  = [B2_mean]Score_Novel
	test [B1_mean]Score_Useful = [B2_mean]Score_Useful		
		
	egen EvalID2_num = group(EvalID2)	
		
	reg Score_Creative Score_Novel Score_Useful c.EvalID2_num if ExecEval == 0
		est store C1
	reg Score_Creative Score_Novel Score_Useful c.EvalID2_num if ExecEval == 1
		est store C2	
		suest C1 C2
	test [C1_mean]Score_Novel  = [C2_mean]Score_Novel
	test [C1_mean]Score_Useful = [C2_mean]Score_Useful		
	
	egen IdeaId_num = group(IdeaId)
	
	reg Score_Creative Score_Novel Score_Useful c.EvalID2_num c.IdeaId_num if ExecEval == 0
		est store D1
	reg Score_Creative Score_Novel Score_Useful c.EvalID2_num c.IdeaId_num if ExecEval == 1
		est store D2
		suest D1 D2
	test [D1_mean]Score_Novel  = [D2_mean]Score_Novel
	test [D1_mean]Score_Useful = [D2_mean]Score_Useful	
			
