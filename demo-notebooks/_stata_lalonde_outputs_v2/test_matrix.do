* Minimal test do-file
local ROOT "/Users/brycewang/Documents/GitHub/Awesome-Agent-Skills-for-Empirical-Research/demo-notebooks"
local OUT  "`ROOT'/_stata_lalonde_outputs_v2"
display "OUT = `OUT'"
cd "`OUT'"
import delimited "`OUT'/data/lalonde.csv", clear
display "Data imported: N = " _N
mat sample_log = J(0, 2, .)
display "Matrix created OK"
mat list sample_log
rename treat treated
display "Renamed treat to treated"
exit