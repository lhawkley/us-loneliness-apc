// Plot loneliness against age, separately by wave

version 15.1
clear all
include config
set more off

use `"`tmp'/loneliness_cohorts"'
rcsgen age, df(4) gen(agesp) orthog
tempfile mydata
save `"`mydata'"'


// Generate plot for men
keep if gender==1
reg loneliness agesp* if wave==1 [pweight=weight_sel], vce(robust)
testparm agesp2-agesp4
predict p11 if e(sample)
predict se11 if e(sample), stdp
reg loneliness agesp* if wave==2 [pweight=weight_sel], vce(robust)
testparm agesp2-agesp4
predict p12 if e(sample)
predict se12 if e(sample), stdp
reg loneliness agesp* if wave==3 [pweight=weight_sel], vce(robust)
testparm agesp2-agesp4
predict p13 if e(sample)
predict se13 if e(sample), stdp

keep p11 p12 p13 se11 se12 se13 age
duplicates drop

forv i = 1/3 {
    gen lb1`i' = p1`i' - (2 * se1`i')
    gen ub1`i' = p1`i' + (2 * se1`i')
}

so age
line p11 age, lcolor("0 63 92") || rarea lb11 ub11 age, color("0 63 92%40") lwidth(none) ///
    || line p12 age, lcolor("188 80 144") || rarea lb12 ub12 age, color("188 80 144%40") lwidth(none) ///
    || line p13 age, lcolor("255 166 0") || rarea lb13 ub13 age, color("255 166 0%40") lwidth(none) ///
    xscale(range(46 95)) xlab(45(5)95) ///
    legend(order(1 "2005-06" 3 "2010-11" 5 "2015-16") ring(0) pos(1) cols(1)) ///
    ytitle("Mean loneliness") xtitle("Age") subtitle("Men") name(men)


// Generate plot for women
use `"`mydata'"', clear
keep if gender==2
reg loneliness agesp* if wave==1 [pweight=weight_sel], vce(robust)
testparm agesp2-agesp4
predict p11 if e(sample)
predict se11 if e(sample), stdp
reg loneliness agesp* if wave==2 [pweight=weight_sel], vce(robust)
testparm agesp2-agesp4
predict p12 if e(sample)
predict se12 if e(sample), stdp
reg loneliness agesp* if wave==3 [pweight=weight_sel], vce(robust)
testparm agesp2-agesp4
predict p13 if e(sample)
predict se13 if e(sample), stdp

keep p11 p12 p13 se11 se12 se13 age
duplicates drop

forv i = 1/3 {
    gen lb1`i' = p1`i' - (2 * se1`i')
    gen ub1`i' = p1`i' + (2 * se1`i')
}

so age
line p11 age, lcolor("0 63 92") || rarea lb11 ub11 age, color("0 63 92%40") lwidth(none) ///
    || line p12 age, lcolor("188 80 144") || rarea lb12 ub12 age, color("188 80 144%40") lwidth(none) ///
    || line p13 age, lcolor("255 166 0") || rarea lb13 ub13 age, color("255 166 0%40") lwidth(none) ///
    xscale(range(46 95)) xlab(45(5)95) legend(off) ///
    ytitle("Mean loneliness") xtitle("Age") subtitle("Women") name(women)


gr combine men women, rows(1) ycommon
mkdirp tmp
gr export tmp/loneliness.pdf, replace
gr export tmp/loneliness.eps, replace
