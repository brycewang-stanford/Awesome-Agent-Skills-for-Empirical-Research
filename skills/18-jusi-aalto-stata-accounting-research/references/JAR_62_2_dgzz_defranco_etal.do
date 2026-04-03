*The Impact of Credit Market Development on Auditor Choice: Evidence from Banking Deregulation*

*Run regressions based on stacked DiD sample*

*Use the sample for tests that predict INDEXP*


use "g:\bdac\dataindexp.dta"


*The effect of interstate branching deregulation event on auditor choice, proxied by INDEXP*

areg indexp sposttreat i.fyearcohort, absorb (gvkeycohort) robust cluster (stateyear) //without control variables

areg indexp sposttreat size invrec nbs ngs mb loss lev merge finance unemploy population i.fyearcohort, absorb (gvkeycohort) robust cluster (stateyear) //with control variables


*The effect of state-level openness to branching on auditor choice, proxied by INDEXP*

areg indexp open i.fyearcohort, absorb (gvkeycohort) robust cluster (stateyear) //without control variables

areg indexp open size invrec nbs ngs mb loss lev merge finance unemploy population i.fyearcohort, absorb (gvkeycohort) robust cluster (stateyear) //with control variables


clear 


*Use the sample for tests that predict BIGN*


use "g:\bdac\databign.dta"


*The effect of interstate branching deregulation event on auditor choice, proxied by BIGN*

areg bign sposttreat i.fyearcohort, absorb (gvkeycohort) robust cluster (stateyear) //without control variables

areg bign sposttreat size invrec nbs ngs mb loss lev merge finance unemploy population i.fyearcohort, absorb (gvkeycohort) robust cluster (stateyear) //with control variables


*The effect of state-level openness to branching on auditor choice, proxied by BIGN*

areg bign open i.fyearcohort, absorb (gvkeycohort) robust cluster (stateyear) //without control variables

areg bign open size invrec nbs ngs mb loss lev merge finance unemploy population i.fyearcohort, absorb (gvkeycohort) robust cluster (stateyear) //with control variables

