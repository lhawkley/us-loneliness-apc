// Create combined file for cohort analyses

version 15.1
clear all
set more off

use data/nshap/w1/nshap_w1_core
keep su_id gender ethgrp companion leftout isolated
gen byte wave = 1
tempfile w1
save `"`w1'"'

use data/nshap/w2/nshap_w2_core, clear
keep su_id gender ethgrp companion2 leftout2 isolated2
gen byte wave = 2
tempfile w2
save `"`w2'"'

use data/nshap/w3/nshap_w3_core, clear
keep su_id gender ethgrp companion2 leftout2 isolated2
gen byte wave = 3

append using `"`w1'"' `"`w2'"'
bys su_id: ass (gender == gender[1]) & (ethgrp == ethgrp[1])

foreach var of varlist companion leftout isolated {
    replace `var' = 1 if inlist(`var'2,0,1)
    replace `var' = `var'2 if mi(`var')
}

merge 1:1 su_id wave using tmp/sample, assert(master match) keep(match) nogen

isid cohort su_id wave, so
cap mkdir tmp
save tmp/loneliness_cohorts, replace
