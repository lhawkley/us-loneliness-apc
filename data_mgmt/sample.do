// Compile sample for cohort analyses

// Note: Result will differ slightly from that generated using actual yob,
// since (year(dofm(int_start)) - age) may be off by +/- 1 year

version 15.1
clear
include config

use su_id int_start age using `"`data'/nshap/w1/nshap_w1_core"'
gen yob = year(dofm(int_start)) - age
gen byte cohort = 1  // NSHAP cohort (1 or 2)
gen byte wave = 1
tempfile w1
save `"`w1'"'

use su_id int_start age ageelig using `"`data'/nshap/w2/nshap_w2_core"'
gen yob = year(dofm(int_start)) - age
merge 1:1 su_id using `"`w1'"', keepusing(yob) update replace ///
    assert(master using match match_conflict) keep(master match match_conflict)
replace age = year(dofm(int_start)) - yob if _merge==5
gen byte cohort = 1
gen byte wave = 2
tempfile w2
save `"`w2'"'

use su_id surveytype3 int_start age using `"`data'/nshap/w3/nshap_w3_core"'
gen yob = year(dofm(int_start)) - age
merge 1:1 su_id using `"`w2'"', keepusing(yob ageelig) update replace ///
    assert(master using match match_conflict) keep(master match match_conflict)
replace age = year(dofm(int_start)) - yob if _merge==5
ren surveytype3 cohort
gen byte wave = 3

append using `"`w1'"' `"`w2'"'

drop if !ageelig
drop if cohort==2 & !inrange(yob,1948,1965)

egen bc = cut(yob), at(1920(10)1970)

drop int_start ageelig _merge
compress
isid cohort su_id wave, so
datasig confirm using signatures/sample, strict
mkdirp `"`tmp'"'
save `"`tmp'/sample"', replace
