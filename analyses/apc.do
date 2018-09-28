// Examine cohort differences in loneliness, overall and separately by gender

version 15.1
clear all
include config
set more off

use `"`tmp'/loneliness_cohorts"'

// Generate orthogonal polynomials for age and yob
rcsgen age, df(5) gen(age_s) orthog
rcsgen yob, df(5) gen(bc_s) orthog

prog plot_age
    args name
    preserve
    
    qui replace su_id = ""
    qui replace loneliness = .
    qui replace wave = 1
    qui foreach var of varlist bc_s* {
        sum `var'
        replace `var' = r(mean)
    }
    
    keep su_id loneliness age age_s* wave bc_s*
    duplicates drop
    predict xb, xb
    predict stdp, stdp
    gen lb = xb - (2 * stdp)
    gen ub = xb + (2 * stdp)
    so age
    line xb age || rarea lb ub age, color(%30) lwidth(none) ///
        xscale(range(46 95)) xlab(45(10)95) xtitle("Age") ///
        ytitle("Linear predictor") name(`name', replace) legend(off) yline(0)
    
    restore
end

prog plot_cohort
    args name
    preserve
    
    qui replace su_id = ""
    qui replace loneliness = .
    qui replace wave = 1
    qui foreach var of varlist age_s* {
        sum `var'
        replace `var' = r(mean)
    }
    
    keep su_id loneliness yob age_s* wave bc_s*
    duplicates drop
    predict xb, xb
    predict stdp, stdp
    gen lb = xb - (2 * stdp)
    gen ub = xb + (2 * stdp)
    so yob
    line xb yob || rarea lb ub yob, color(%30) lwidth(none) ///
        xscale(range(1920 1965)) xlab(1920(10)1960) xtitle("Birth year") ///
        ytitle("Linear predictor") name(`name', replace) legend(off) yline(0)
    
    restore
end

prog plot_wave
    args name
    preserve
    
    qui replace su_id = ""
    qui replace loneliness = .
    qui foreach var of varlist age_s* bc_s* {
        sum `var'
        replace `var' = r(mean)
    }
    
    keep su_id loneliness wave age_s* bc_s*
    duplicates drop
    predict xb, xb
    predict stdp, stdp
    // Wihtout constant, at Wave 1 SD is effectively 0
    li wave xb stdp
    gen lb = xb - (2 * stdp) if wave!=1
    gen ub = xb + (2 * stdp) if wave!=1
    tw rcap ub lb wave || sc xb wave, name(`name', replace) legend(off) ///
        xlab(1 "2005-06" 2 "2010-11" 3 "2015-16") xtitle("Survey year") ///
        ms(circle) yline(0)
    
    restore
end


// Loneliness by age and wave (changes over time)
reg loneliness age_s* i.wave [pweight=weight_sel], vce(cluster su_id)
reg loneliness age_s* i.wave [pweight=weight_sel2], vce(cluster su_id)
mixed loneliness age_s* i.wave || su_id:, pweight(weight_sel2) vce(robust)
test 2.wave = 3.wave

ologit loneliness age_s* i.wave [pweight=weight_sel], vce(cluster su_id)
ologit loneliness age_s* i.wave [pweight=weight_sel2], vce(cluster su_id)
meologit loneliness age_s* i.wave || su_id:, pweight(weight_sel2) vce(robust)
test 2.wave = 3.wave

// Separately by gender; evidence slightly stronger in men, but difference not
// statistically significant
meologit loneliness age_s* i.wave if gender==1 || su_id:, pweight(weight_sel2) ///
    vce(robust)
meologit loneliness age_s* i.wave if gender==2 || su_id:, pweight(weight_sel2) ///
    vce(robust)
meologit loneliness age_s* i.wave i.gender || su_id:, pweight(weight_sel2) ///
    vce(robust)
meologit loneliness age_s* i.wave##i.gender || su_id:, pweight(weight_sel2) ///
    vce(robust)
testparm wave#gender


// APC models
// Discrete specification
// Weak evidence of higher loneliness among those born in the 50s, but this
// is not present in the mixed-effects model below
ologit loneliness age_s* i.wave bc10 [pweight=weight_sel2], vce(cluster su_id)
ologit loneliness age_s* i.wave i.bc10 [pweight=weight_sel2], vce(cluster su_id)
testparm age_s*
testparm i.wave
testparm i.bc10

meologit loneliness age_s* i.wave bc10 || su_id:, pweight(weight_sel2) ///
    vce(robust)
meologit loneliness age_s* i.wave i.bc10 || su_id:, pweight(weight_sel2) ///
    vce(robust)
testparm age_s*
testparm i.wave
testparm i.bc10

// Continuous specification
// No evidence of cohort effect(s) with continuous specification, even with
// the marginal model (i.e., without the random effect)
ologit loneliness age_s* i.wave bc_s2-bc_s5 [pweight=weight_sel2], ///
    vce(cluster su_id)
testparm age_s*
testparm i.wave
testparm bc_s*
ologit loneliness age_s2-age_s5 i.wave bc_s* [pweight=weight_sel2], ///
    vce(cluster su_id)
testparm age_s*
testparm i.wave
testparm bc_s*

meologit loneliness age_s* i.wave bc_s2-bc_s5 || su_id:, pweight(weight_sel2) ///
    vce(robust)
testparm age_s*
testparm i.wave
testparm bc_s*
plot_age age1
plot_cohort cohort1
plot_wave wave1

meologit loneliness age_s2-age_s5 i.wave bc_s* || su_id:, pweight(weight_sel2) ///
    vce(robust)
testparm age_s*
testparm i.wave
testparm bc_s*
plot_age age2
plot_cohort cohort2
plot_wave wave2

gr combine age1 cohort1 wave1 age2 cohort2 wave2, cols(3) ycommon
mkdirp tmp
graph export tmp/apc.pdf, replace
