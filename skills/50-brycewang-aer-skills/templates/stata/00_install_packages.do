/*------------------------------------------------------------------
  00_install_packages.do
  Pin every user-written package. Comment out after first run.
-------------------------------------------------------------------*/

* ---- Identification toolkit --------------------------------------
ssc install reghdfe, replace          // high-dimensional FE OLS
ssc install ftools, replace           // reghdfe dependency
ssc install ivreg2, replace           // IV with weak-IV diagnostics
ssc install ranktest, replace         // weak identification tests
ssc install weakivtest, replace       // Olea-Pflueger effective F

* ---- Modern DiD --------------------------------------------------
ssc install csdid, replace            // Callaway-Sant'Anna
ssc install drdid, replace            // doubly-robust DiD
ssc install did_imputation, replace   // Borusyak-Jaravel-Spiess
ssc install did_multiplegt, replace   // de Chaisemartin-D'Haultfœuille
ssc install eventstudyinteract, replace // Sun-Abraham
ssc install bacondecomp, replace      // Goodman-Bacon decomposition
ssc install honestdid, replace        // Rambachan-Roth sensitivity

* ---- RDD ---------------------------------------------------------
ssc install rdrobust, replace         // Calonico-Cattaneo-Titiunik
ssc install rddensity, replace        // Cattaneo-Jansson-Ma density test

* ---- SCM ---------------------------------------------------------
ssc install synth, replace
ssc install synth2, replace
net install scul, from("https://raw.githubusercontent.com/hollina/scul/master/")

* ---- Tables & figures --------------------------------------------
ssc install estout, replace           // esttab / estout
ssc install coefplot, replace         // forest plots & event-study viz
ssc install binscatter, replace       // efficient binned scatter
ssc install asdoc, replace            // alternative reporter
ssc install boottest, replace         // wild cluster bootstrap

display as result "All packages installed and pinned."
