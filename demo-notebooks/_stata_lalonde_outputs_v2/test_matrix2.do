log using "test_matrix2.log", replace
cd "/Users/brycewang/Documents/GitHub/Awesome-Agent-Skills-for-Empirical-Research/demo-notebooks/_stata_lalonde_outputs_v2"
display "CWD: `c(pwd)'"
import delimited "data/lalonde.csv", clear
display "Data imported: N=" _N
mat B = J(3,2,1)
mat list B
display "3x2 matrix OK"
mat A = J(0,2,.)
mat list A
display "Empty 0x2 matrix OK"
mat A = (nullmat(A) \ 1, 100)
mat list A
display "Append row OK"
mat A = (nullmat(A) \ 2, 200)
mat list A
display "Second append OK"
rename treat treated
display "Rename OK"
log close
exit