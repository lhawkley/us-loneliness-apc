// Example cohort analysis

version 15.1
clear all
set more off

loc OUTCOME companion

use tmp/loneliness_cohorts


// Balance dataset (useful for plotting)
fillin wave age yob
drop bc
egen bc = cut(yob), at(1920(10)1970)

// Model age and yob effect with restricted cubic splines
rcsgen age, percentiles(5 27.5 50 72.5 95) gen(age_s) orthog
rcsgen yob, percentiles(5 27.5 50 72.5 95) gen(bc_s) orthog


// Basic model ignoring within-respondent correlation, and using 10-year
// grouping of birth cohorts to identify model
ologit `OUTCOME' i.gender i.ethgrp i.wave i.bc age_s*, vce(cluster su_id)
estimates store m1
mat b = e(b)
testparm i.wave
testparm i.bc
contrast g.bc
testparm age_s*

// Re-estimate model with respondent-level random effects
meologit `OUTCOME' i.gender i.ethgrp i.wave i.bc age_s* || su_id:, vce(robust) ///
    from(b)
estimates store m2
testparm i.wave
testparm i.bc
contrast g.bc
testparm age_s*


// Omit linear effect of wave to identify model
orthpoly wave, gen(_Owave*) deg(3)
ologit `OUTCOME' i.gender i.ethgrp _Owave2 _Owave3 age_s* bc_s*, vce(cluster su_id)
testparm bc_s2-bc_s4
testparm age_s2-age_s4
testparm _Owave2 _Owave3


// Plot results
replace gender = 1
replace ethgrp = 1

// Exclude linear effects from plot
replace age_s1 = 0
replace bc_s1 = 0

predict p3, xb

estimates restore m2
predict p2, xb

estimates restore m1
predict p1, xb

line p1 age if wave==1 & yob==1920, sort name(g1) title("Model 1")
line p1 yob if wave==1 & age==65, sort name(g2) title("Model 1")

line p2 age if wave==1 & yob==1920, sort name(g3) title("Model 2")
line p2 yob if wave==1 & age==65, sort name(g4) title("Model 2")

line p3 age if wave==1 & yob==1920, sort name(g5) title("Model 3")
line p3 yob if wave==1 & age==65, sort name(g6) title("Model 3")

gr combine g1 g3 g5 g2 g4 g6, ycommon
