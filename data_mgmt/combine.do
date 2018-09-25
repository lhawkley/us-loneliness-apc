// Combine data across waves to create analysis file

version 15.1
clear all
include config
set more off

loc varlist su_id gender ethgrp maritlst educ alters hh_size framt clsrel ///
    physhlth comorb
loc w1_vars `varlist' companion leftout isolated eyesight hearing
loc w2_vars `varlist' companion2 leftout2 isolated2 moca_sa eyesight hearing
loc w3_vars `varlist' companion2 leftout2 isolated2 moca_sa

use `"`nshap_data'/w1/nshap_w1_core"'
run data_mgmt/hhsize 1
run data_mgmt/comorb 1
keep `w1_vars'
// Recode Wave 1 to match other waves
recode alters 6=5
gen byte wave = 1
tempfile w1
save `"`w1'"'

use `"`nshap_data'/w2/nshap_w2_core"', clear
run data_mgmt/netsize 2
run data_mgmt/hhsize 2
run data_mgmt/comorb 2
run data_mgmt/moca-sa
keep `w2_vars'
gen byte wave = 2
tempfile w2
save `"`w2'"'

use `"`nshap_data'/w3/nshap_w3_core"', clear
run data_mgmt/netsize 3
run data_mgmt/hhsize 3
run data_mgmt/comorb 3
run data_mgmt/moca-sa
keep `w3_vars'
gen byte wave = 3

append using `"`w1'"' `"`w2'"'
bys su_id: ass (gender == gender[1]) & (ethgrp == ethgrp[1])

foreach var of varlist companion leftout isolated {
    recode `var'2 0/1=1
    replace `var' = `var'2 if `var'==.
}

merge 1:1 su_id wave using `"`tmp'/sample"', assert(master match) keep(match) nogen

gen loneliness = companion + leftout + isolated
recode maritlst 1/2=1 3/6=0, gen(married)

compress
isid cohort su_id wave, so
datasig confirm using signatures/loneliness_cohorts, strict
save `"`tmp'/loneliness_cohorts"', replace
