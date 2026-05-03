clear all
sysuse auto, clear
qui sum price if foreign == 1
local m1 = r(mean)
local sd1 = r(sd)
qui sum price if foreign == 0
local m0 = r(mean)
local sd0 = r(sd)
local smd = (`m1' - `m0') / sqrt((`sd1'^2 + `sd0'^2)/2)
di "SMD with ^2 = " `smd'
local smd2 = (`m1' - `m0') / sqrt((`sd1'*`sd1' + `sd0'*`sd0')/2)
di "SMD with * = " `smd2'
