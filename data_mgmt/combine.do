// Combine data across waves to create analysis file

version 15.1
clear all
include config
set more off

loc varlist su_id gender ethgrp maritlst educ
loc w1_vars `varlist' companion leftout isolated
loc w2_vars `varlist' companion2 leftout2 isolated2

use `w1_vars' using `"`nshap_data'/w1/nshap_w1_core"'
gen byte wave = 1
tempfile w1
save `"`w1'"'

use `w2_vars' using `"`nshap_data'/w2/nshap_w2_core"', clear
gen byte wave = 2
tempfile w2
save `"`w2'"'

use `w2_vars' using `"`nshap_data'/w3/nshap_w3_core"', clear
gen byte wave = 3

append using `"`w1'"' `"`w2'"'
bys su_id: ass (gender == gender[1]) & (ethgrp == ethgrp[1])

foreach var of varlist companion leftout isolated {
    recode `var'2 0/1=1
    replace `var' = `var'2 if `var'==.
}

merge 1:1 su_id wave using `"`tmp'/sample"', assert(master match) keep(match) nogen

compress
isid cohort su_id wave, so
datasig confirm using signatures/loneliness_cohorts, strict
save `"`tmp'/loneliness_cohorts"', replace
