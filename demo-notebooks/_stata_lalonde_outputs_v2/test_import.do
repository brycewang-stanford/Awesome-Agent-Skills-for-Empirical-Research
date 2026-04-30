* Test matrix and import
cd "/Users/brycewang/Documents/GitHub/Awesome-Agent-Skills-for-Empirical-Research/demo-notebooks/_stata_lalonde_outputs_v2"
import delimited "data/lalonde.csv", clear
display "Data: N=" _N
mat B = J(3,2,1)
mat list B
display "Matrix OK"
mat A = J(0,2,.)
mat list A
display "Empty matrix OK"
mat A = (nullmat(A) \ 1, 100)
mat list A
display "Append OK"
exit