// Compute comorbidity score that is comparable across waves

// See Kristen's notes describing rationale for scoring below

version 15.1
include config

args wave

tempvar hrt_attack chf pvd stroke dementia pulmonary arthritis diabetes cancer

gen `diabetes' = conditns_7

if `wave'==1 {
    gen `hrt_attack' = hrtprob
    gen `chf' = hrtfail
    gen `pvd' = uncloga
    gen `stroke' = conditns_5
    gen `dementia' = conditns_8
    gen `pulmonary' = 1 if conditns_3==1 | conditns_4==1
    replace `pulmonary' = 0 if !conditns_3 & !conditns_4
    gen `arthritis' = conditns_1
    gen `cancer' = 2 if conditns_11==1 | conditns_12==1 | conditns_14==1
    replace `cancer' = 0 if !conditns_11 & !conditns_12 & !conditns_14
    replace `cancer' = 6 if conditns_14==1 & (spread_1==1 | spread_2==1)
}

if inlist(`wave',2,3) {
    gen `hrt_attack' = hrtattack
    gen `chf' = hrtchf
    gen `pvd' = hrtcard
    gen `stroke' = stroke
    gen `pulmonary' = emphasth
    // Normally would use just rheumatoid, but didn't distinguish in Wave 1
    gen `arthritis' = arthritis
    gen `cancer' = othcan * 2
    replace `cancer' = 6 if othcan==1 & (spread_1==1 | spread_2==1)
}

if `wave'==2 {
    replace `hrt_attack' = 0 if !hrtprob2
    replace `chf' = 0 if !hrtprob2
    replace `pvd' = 0 if !hrtprob2
    gen `dementia' = 1 if dementia==1 | alzheimer==1
    replace `dementia' = 0 if !dementia & !alzheimer
}

if `wave'==3 {
    replace `hrt_attack' = 0 if !hrtprob3
    replace `chf' = 0 if !hrtprob3
    replace `pvd' = 0 if !hrtprob3
    gen `dementia' = conditns_83
}


// Treat missing as zero
egen comorb = rowtotal(`hrt_attack' `chf' `pvd' `stroke' `dementia' `pulmonary' ///
    `arthritis' `diabetes' `cancer'), missing
