// Example cohort analysis

version 15.1
clear all
set more off

loc OUTCOME isolated

use tmp/loneliness_cohorts
// ren age _age
// egen age = cut(_age), at(50(3)98)


// Model age and yob effect with restricted cubic splines
rcsgen age, df(5) gen(age_s) orthog
rcsgen yob, df(5) gen(bc_s) orthog

// Decompose wave into orthogonal polynomials
orthpoly wave, gen(_Owave*) deg(3)


// Model age effect ignoring birth cohort
ologit `OUTCOME' i.gender i.ethgrp age_s*, vce(cluster su_id)
estimates store m01
ologit `OUTCOME' i.gender i.ethgrp i.wave age_s*, vce(cluster su_id)
estimates store m02


// Basic APC model ignoring within-respondent correlation, and using 10-year
// grouping of birth cohorts to identify model
ologit `OUTCOME' i.gender i.ethgrp i.wave i.bc age_s*, vce(cluster su_id)
estimates store m1
mat b = e(b)
testparm i.wave
testparm i.bc
contrast g.bc
testparm age_s*
testparm age_s2-age_s5

// Re-estimate model with respondent-level random effects
meologit `OUTCOME' i.gender i.ethgrp i.wave i.bc age_s* || su_id:, vce(robust) ///
    from(b)
estimates store m2
testparm i.wave
testparm i.bc
contrast g.bc
testparm age_s*
testparm age_s2-age_s5


// Omit linear effect of wave to identify model
ologit `OUTCOME' i.gender i.ethgrp _Owave2 _Owave3 age_s* bc_s*, vce(cluster su_id)
estimates store m3
testparm bc_s2-bc_s5
testparm age_s2-age_s5
testparm _Owave2 _Owave3


// Plot results
preserve
    keep wave _Owave1 _Owave2 _Owave3
    duplicates drop
    gen byte _join = 1
    tempfile wave
    save `"`wave'"'
restore

preserve
    keep bc bc_s* yob
    duplicates drop
    gen byte _join = 1
    tempfile bc
    save `"`bc'"'
restore

keep age age_s*
duplicates drop
gen byte _join = 1
tempfile age
save `"`age'"'

joinby _join using `"`bc'"'
joinby _join using `"`wave'"'
gen su_id = ""
gen byte `OUTCOME' = 1
gen byte gender = 1
gen byte ethgrp = 1


estimates restore m01
predict p01, xb

estimates restore m02
predict p02, xb

line p01 age if wave==1 & yob==1920, sort name(g01) title("Age")
line p02 age if wave==1 & yob==1920, sort name(g02) title("Age plus wave")


estimates restore m1
predict p1, xb

estimates restore m2
predict p2, xb

// Exclude linear effects from plots
replace age_s1 = 0
replace bc_s1 = 0
estimates restore m3
predict p3, xb

line p1 age if wave==1 & yob==1920, sort name(g1) title("Model 1")
line p1 yob if wave==1 & age==65, sort name(g2) title("Model 1")

line p2 age if wave==1 & yob==1920, sort name(g3) title("Model 2")
line p2 yob if wave==1 & age==65, sort name(g4) title("Model 2")

line p3 age if wave==1 & yob==1920, sort name(g5) title("Model 3")
line p3 yob if wave==1 & age==65, sort name(g6) title("Model 3")

gr combine g01 g02 g1, ycommon name(cg1)
gr combine g1 g3 g5 g2 g4 g6, ycommon name(cg2)
