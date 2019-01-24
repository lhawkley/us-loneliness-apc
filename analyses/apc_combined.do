// Combined APC figure for paper

version 15.1
clear all
include config
set more off

// Age
use `"`tmp'/apc/nshap_age"'
gen byte hrs = 0
append using `"`tmp'/apc/hrs_age"'
replace hrs = 1 if mi(hrs)
format xb %3.1f
isid hrs age, so
line xb age if !hrs, lcolor("0 63 92") lpattern(shortdash) ///
    || rarea lb ub age if !hrs, color("0 63 92%40") lwidth(none) ///
    || line xb age if hrs, lcolor("188 80 144") ///
    || rarea lb ub age if hrs, color("188 80 144%40") lwidth(none) ///
    xscale(range(50 95)) xlab(50(10)95) xtitle("Age") ///
    ytitle("Linear prediction (xb)") name(g1) yline(0) ///
    title("A", pos(11)) ylab(-1.5(0.5)2, angle(horizontal)) ///
    legend(order(1 "NSHAP" 3 "HRS") ring(0) pos(5) cols(1)) ///
    yscale(range(-1.5 2))

// Year of birth (cohort)
use `"`tmp'/apc/nshap_cohort"', clear
gen byte hrs = 0
append using `"`tmp'/apc/hrs_cohort"'
replace hrs = 1 if mi(hrs)
format xb %3.1f
isid hrs yob, so
line xb yob if !hrs, lcolor("0 63 92") lpattern(shortdash) ///
    || rarea lb ub yob if !hrs, color("0 63 92%40") lwidth(none) ///
    || line xb yob if hrs, lcolor("188 80 144") ///
    || rarea lb ub yob if hrs, color("188 80 144%40") lwidth(none) ///
    xscale(range(1920 1965)) xlab(1920(10)1960) xtitle("Birth year") ///
    ytitle("Linear prediction (xb)") name(g2) legend(off) yline(0) ///
    title("B", pos(11)) ylab(-1.5(0.5)2, angle(horizontal)) ///
    yscale(range(-1.5 2))

// Survey year (period)
use `"`tmp'/apc/nshap_period"', clear
recode wave 1=5 2=10 3=15
replace wave = wave + 0.5
gen byte hrs = 0
append using `"`tmp'/apc/hrs_period"'
replace hrs = 1 if mi(hrs)
replace wave = wave + 2000
format ub %3.1f
isid hrs wave, so
tw rcap ub lb wave if !hrs, lcolor("0 63 92") ///
    || sc xb wave if !hrs, mcolor("0 63 92") ms(circle) msize(*0.8) ///
    || rcap ub lb wave if hrs, lcolor("188 80 144") ///
    || sc xb wave if hrs, mcolor("188 80 144") ms(circle) msize(*0.8) ///
    xlab(2006 `"`=char(39)'06"' 2008 `"`=char(39)'08"' 2010 `"`=char(39)'10"' ///
         2012 `"`=char(39)'12"' 2014 `"`=char(39)'14"' 2016 `"`=char(39)'16"') ///
    xtitle("Survey year") name(g3) legend(off) ///
    yline(0) ytitle("Linear prediction (xb)") title("C", pos(11)) ///
    ylab(-1.5(0.5)2, angle(horizontal)) yscale(range(-1.5 2))

// Age (including linear effect of birth year)
use `"`tmp'/apc/nshap_age2"', clear
gen byte hrs = 0
append using `"`tmp'/apc/hrs_age2"'
replace hrs = 1 if mi(hrs)
format xb %3.1f
isid hrs age, so
line xb age if !hrs, lcolor("0 63 92") lpattern(shortdash) ///
    || rarea lb ub age if !hrs, color("0 63 92%40") lwidth(none) ///
    || line xb age if hrs, lcolor("188 80 144") ///
    || rarea lb ub age if hrs, color("188 80 144%40") lwidth(none) ///
    xscale(range(50 95)) xlab(50(10)95) xtitle("Age") ///
    ytitle("Linear prediction (xb)") name(g4) legend(off) yline(0) ///
    title("D", pos(11)) ylab(-1.5(0.5)2, angle(horizontal)) ///
    yscale(range(-1.5 2))

// Year of birth (including linear effect)
use `"`tmp'/apc/nshap_cohort2"', clear
gen byte hrs = 0
append using `"`tmp'/apc/hrs_cohort2"'
replace hrs = 1 if mi(hrs)
format xb %3.1f
isid hrs yob, so
line xb yob if !hrs, lcolor("0 63 92") lpattern(shortdash) ///
    || rarea lb ub yob if !hrs, color("0 63 92%40") lwidth(none) ///
    || line xb yob if hrs, lcolor("188 80 144") ///
    || rarea lb ub yob if hrs, color("188 80 144%40") lwidth(none) ///
    xscale(range(1920 1965)) xlab(1920(10)1960) xtitle("Birth year") ///
    ytitle("Linear prediction (xb)") name(g5) legend(off) yline(0) ///
    title("E", pos(11)) ylab(-1.5(0.5)2, angle(horizontal)) ///
    yscale(range(-1.5 2))

// NSHAP: Age, adjusting for covariates
use `"`tmp'/apc/nshap_age_adj"', clear
format xb %3.1f
isid age, so
line xb age, lcolor("0 63 92") lpattern(shortdash) ///
    || rarea lb ub age, color("0 63 92%40") lwidth(none) ///
    xscale(range(50 95)) xlab(50(10)95) xtitle("Age") ///
    ytitle("Linear prediction (xb)") name(g6) legend(off) yline(0) ///
    title("F", pos(11)) ylab(-1.5(0.5)2, angle(horizontal)) ///
    yscale(range(-1.5 2))

gr combine g1 g2 g3 g4 g5 g6, cols(3)
gr export `"`tmp'/apc/apc_combined.pdf"', replace
