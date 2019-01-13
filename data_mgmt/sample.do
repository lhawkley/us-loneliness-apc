// Compile sample for cohort analyses

// Requires access to original raw data for DOB

version 15.1
clear
include config

use su_id age weight_sel weight_adj using `"`nshap_data'/w1/nshap_w1_core"'
merge 1:1 su_id using `"`raw_data'/w1/interview_data/capi/nshap_final_capi"', ///
    assert(match) nogen keepusing(ageyear)
merge 1:1 su_id using `"`nshap_data'/w2/nshap_w2_core"', keep(master match) ///
    keepusing(su_id) nolabel
gen weight_sel2 = weight_sel if _merge==1
sum weight_sel2
replace weight_sel2 = weight_sel2 * (r(N)/r(sum))
drop _merge
ren ageyear yob
gen byte cohort = 1  // NSHAP cohort (1 or 2)
gen byte wave = 1
tempfile w1
save `"`w1'"'

use su_id age weight_sel weight_adj using `"`nshap_data'/w2/nshap_w2_core"'
ren su_id SU_ID
merge 1:1 SU_ID using `"`raw_data'/w2/main_capi_2011-08-05/nshapw2_main_results"', ///
    assert(match) nogen keepusing(ageyear)
ren SU_ID su_id
gen weight_sel2 = weight_sel
ren ageyear yob
replace yob = . if yob == -5
merge 1:1 su_id using `"`w1'"', keepusing(yob) update nogen ///
    assert(master using match match_update) keep(master match match_update)
gen byte cohort = 1
gen byte wave = 2
tempfile w2
save `"`w2'"'

use su_id surveytype3 age weight_sel weight_adj using `"`nshap_data'/w3/nshap_w3_core"'
merge 1:1 su_id using `"`raw_data'/w3/capi/nshapw3_main"', assert(match) ///
    nogen keepusing(ageyear)
ren ageyear yob
replace yob = . if yob == -5
gen double weight_sel2 = weight_sel if surveytype==2
sum weight_sel2
replace weight_sel2 = weight_sel2 * (r(N)/r(sum))
merge 1:1 su_id using `"`w1'"', keepusing(yob weight_sel2) update nogen ///
    assert(master using match match_update) keep(master match match_update)
merge 1:1 su_id using `"`w2'"', keepusing(yob weight_sel2) update nogen ///
    assert(master using match match_update) keep(master match match_update)
ren surveytype3 cohort
gen byte wave = 3

append using `"`w1'"' `"`w2'"'

// Fill in weights for W1 respondents who were also interviewed in W2
bys su_id (weight_sel2): ass weight_sel2 == weight_sel2[1] if !mi(weight_sel2)
bys su_id (weight_sel2): replace weight_sel2 = weight_sel2[1] if mi(weight_sel2)

drop if !inrange(yob,1920,1965)
drop if !inrange(age,50,95)
egen bc3 = cut(yob), at(1920 1934 1948 1966)
egen bc10 = cut(yob), at(1920(10)1970)

compress
isid cohort su_id wave, so
datasig confirm using signatures/sample, strict
mkdirp `"`tmp'"'
save `"`tmp'/sample"', replace
