/*------------------------------------------------------------------
  00_install_packages.do
  Install and pin user-written Stata packages.

  Replace placeholder versions with the versions used in the paper.
-------------------------------------------------------------------*/

version 18.0

local packages reghdfe ftools csdid estout coefplot rdrobust rddensity

foreach pkg of local packages {
    capture which `pkg'
    if _rc {
        ssc install `pkg', replace
    }
}
