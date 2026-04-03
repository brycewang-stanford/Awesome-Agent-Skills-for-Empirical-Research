clear
use "C:\Users\data\main.dta"

rename *,lower
egen nb = group(cik)
gen constant = 1

gen sic_real=real(sic)
gen sic3=int(sic_real/10)

global control_em size btm leverage roa return retvol capital intangibles financing acq ic sale_gr numest instown shortint
global control_erc betaff size btm leverage loss persistpx

*Descriptive Stats (Table 1)
tabstat restatehlm_lead1 bias_lead1, by(fyear) s(n mean)
univar searchfunda searchinc bhaer3 acq betaff btm capital financing intangibles instown ic leverage loss numest persistpx return retvol roa sale_gr shortint size sur_eps, dec(3)

*Descriptive Stats (Figure 2)
mean searchfunda searchinc, over(fyear)

winsor2 search10ks search10qs search4 search8k searchdefs searchtot, by(fyear) cuts(1 99) replace
gen pct10ks=search10ks/searchtot
gen pct10qs=search10qs/searchtot
gen pct8k=search8k/searchtot
gen pct4=search4/searchtot
gen pctdefs=searchdefs/searchtot
mean pct10ks pct10qs pct8k pct4 pctdefs

*ERC (Table 2)
drop surfunda surinc
gen surfunda = sur_eps*searchfunda
gen surinc =  sur_eps*searchinc
global surcontrol surbetaff sursize surbtm surleverage surloss surpersistpx
drop ${surcontrol}
foreach i in betaff size btm leverage loss persistpx {
gen sur`i'=sur_eps*`i'
}
reghdfe bhaer3 surfunda surinc sur_eps ${control_erc} searchfunda searchinc, absorb(nb fyear) vce(cluster nb) keepsin
reghdfe bhaer3 surfunda surinc sur_eps ${control_erc} searchfunda searchinc ${surcontrol}, absorb(nb fyear) vce(cluster nb) keepsin
reghdfe bhaer3 surfunda surinc sur_eps ${control_erc} searchfunda searchinc, absorb(i.nb#c.sur_eps i.fyear#c.sur_eps nb fyear) vce(cluster nb) keepsin
reghdfe bhaer3 surfunda surinc sur_eps ${control_erc} searchfunda searchinc ${surcontrol}, absorb(i.nb#c.sur_eps i.fyear#c.sur_eps nb fyear) vce(cluster nb) keepsin
reghdfe bhaer3 surfunda surinc sur_eps ${control_erc} searchfunda searchinc ${surcontrol}, absorb(sic3 fyear) vce(cluster nb) keepsin
reghdfe bhaer3 surfunda surinc sur_eps ${control_erc} searchfunda searchinc ${surcontrol}, absorb(i.sic3#c.sur_eps i.fyear#c.sur_eps sic3 fyear) vce(cluster nb) keepsin

*Misreporting (Table 3)
reghdfe restatehlm_lead1 searchfunda searchinc, absorb(nb fyear) vce(cluster nb) keepsin
reghdfe restatehlm_lead1 searchfunda searchinc ${control_em}, absorb(nb fyear) vce(cluster nb) keepsin

reghdfe bias_lead1 searchfunda searchinc, absorb(nb fyear) vce(cluster nb) keepsin
reghdfe bias_lead1 searchfunda searchinc ${control_em}, absorb(nb fyear) vce(cluster nb) keepsin

*Export identifiers
keep cik fyear
export excel "C:\Users\data\K_Identifiers.xlsx", firstrow(variables) replace

