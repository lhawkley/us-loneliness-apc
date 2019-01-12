// Plot loneliness against age using most recent data (NSHAP 2015-16, HRS
// 2014-2016), separately by gender and study

// Use plot with HRS 2014 since this year has final leave-behind weights

version 15.1
clear all
include config
set more off


// Generate curves for NSHAP 2015-16
use `"`tmp'/loneliness_cohorts"' if wave==3
rcsgen age, df(4) gen(agesp) orthog

reg loneliness agesp* if gender==1 [pweight=weight_adj], vce(robust)
testparm agesp2-agesp4
predict p_m if e(sample)
predict se_m if e(sample), stdp

reg loneliness agesp* if gender==2 [pweight=weight_adj], vce(robust)
testparm agesp2-agesp4
predict p_f if e(sample)
predict se_f if e(sample), stdp

keep age gender p_* se_*
duplicates drop
gen p = cond(gender==1, p_m, p_f)
gen se = cond(gender==1, se_m, se_f)
drop if mi(p)
drop p_* se_*

gen byte hrs = 0
tempfile nshap
save `"`nshap'"'


// Generate curves for HRS 2014
use `"`tmp'/hrs"' if yr==14, clear
rcsgen age, df(4) gen(agesp) orthog

reg loneliness agesp* if gender==1 [pweight=lbwgtr], vce(robust)
testparm agesp2-agesp4
predict p_m if e(sample)
predict se_m if e(sample), stdp

reg loneliness agesp* if gender==2 [pweight=lbwgtr], vce(robust)
testparm agesp2-agesp4
predict p_f if e(sample)
predict se_f if e(sample), stdp

keep age gender p_* se_*
duplicates drop
gen p = cond(gender==1, p_m, p_f)
gen se = cond(gender==1, se_m, se_f)
drop if mi(p)
drop p_* se_*

gen byte hrs = 1
gen byte yr = 14
tempfile hrs
save `"`hrs'"'


// Generate curves for HRS 2016
use `"`tmp'/hrs"' if yr==16, clear
rcsgen age, df(4) gen(agesp) orthog

reg loneliness agesp* if gender==1 [pweight=wgtr], vce(robust)
testparm agesp2-agesp4
predict p_m if e(sample)
predict se_m if e(sample), stdp

reg loneliness agesp* if gender==2 [pweight=wgtr], vce(robust)
testparm agesp2-agesp4
predict p_f if e(sample)
predict se_f if e(sample), stdp

keep age gender p_* se_*
duplicates drop
gen p = cond(gender==1, p_m, p_f)
gen se = cond(gender==1, se_m, se_f)
drop if mi(p)
drop p_* se_*

gen byte hrs = 1
gen byte yr = 16


append using `"`nshap'"' `"`hrs'"'

gen lb = p - (2 * se)
gen ub = p + (2 * se)


// Plot 2014-16
so age
line p age if gender==1 & !hrs, lcolor("0 63 92") lpattern(dash) ///
    || rarea lb ub age if gender==1 & !hrs, color("0 63 92%40") lwidth(none) ///
    || line p age if gender==1 & hrs & yr==14, lcolor("188 80 144") ///
    || rarea lb ub age if gender==1 & hrs & yr==14, color("188 80 144%40") lwidth(none) ///
    xscale(range(46 95)) xlab(45(5)95) yscale(range(3 6)) ///
    legend(order(1 "NSHAP 2015-16" 3 "HRS 2014") ring(0) pos(1) cols(1)) ///
    ytitle("Mean loneliness") xtitle("Age") subtitle("Men") name(men)

line p age if gender==2 & !hrs, lcolor("0 63 92") lpattern(dash) ///
    || rarea lb ub age if gender==2 & !hrs, color("0 63 92%40") lwidth(none) ///
    || line p age if gender==2 & hrs & yr==14, lcolor("188 80 144") ///
    || rarea lb ub age if gender==2 & hrs & yr==14, color("188 80 144%40") lwidth(none) ///
    xscale(range(46 95)) xlab(45(5)95) yscale(range(3 6)) ///
    legend(off) ///
    ytitle("Mean loneliness") xtitle("Age") subtitle("Women") name(women)

gr combine men women, rows(1) ycommon name(hrs14)
gr export `"`tmp'/loneliness_hrs14.pdf"', replace
gr export `"`tmp'/loneliness_hrs14.eps"', replace


// Plot 2015-16
so age
line p age if gender==1 & !hrs, lcolor("0 63 92") lpattern(dash) ///
    || rarea lb ub age if gender==1 & !hrs, color("0 63 92%40") lwidth(none) ///
    || line p age if gender==1 & hrs & yr==16, lcolor("188 80 144") ///
    || rarea lb ub age if gender==1 & hrs & yr==16, color("188 80 144%40") lwidth(none) ///
    xscale(range(46 95)) xlab(45(5)95) yscale(range(3 6)) ///
    legend(order(1 "NSHAP 2015-16" 3 "HRS 2016") ring(0) pos(1) cols(1)) ///
    ytitle("Mean loneliness") xtitle("Age") subtitle("Men") name(men, replace)

line p age if gender==2 & !hrs, lcolor("0 63 92") lpattern(dash) ///
    || rarea lb ub age if gender==2 & !hrs, color("0 63 92%40") lwidth(none) ///
    || line p age if gender==2 & hrs & yr==16, lcolor("188 80 144") ///
    || rarea lb ub age if gender==2 & hrs & yr==16, color("188 80 144%40") lwidth(none) ///
    xscale(range(46 95)) xlab(45(5)95) yscale(range(3 6)) ///
    legend(off) ///
    ytitle("Mean loneliness") xtitle("Age") subtitle("Women") name(women, replace)

gr combine men women, rows(1) ycommon name(hrs16)
gr export `"`tmp'/loneliness_hrs16.pdf"', replace
gr export `"`tmp'/loneliness_hrs16.eps"', replace
