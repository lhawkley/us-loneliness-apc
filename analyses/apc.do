// Examine cohort differences in loneliness, overall and separately by gender

version 15.1
clear all
include config
set more off

use `"`tmp'/loneliness_cohorts"'

// Generate orthogonal spline variables for age and yob
rcsgen age, df(4) gen(age_s) orthog
rcsgen yob, df(4) gen(bc_s) orthog

prog plot_age
    syntax, name(string) [keep(varlist numeric) title(string) saving(string) replace]
    preserve
    
    qui replace su_id = ""
    qui replace loneliness = .
    qui replace wave = 1
    qui foreach var of varlist bc_s* {
        sum `var'
        replace `var' = r(mean)
    }
    if !mi("`keep'") {
        qui foreach var of varlist `keep' {
            replace `var' = 0
        }
    }
    
    keep su_id loneliness age age_s* wave bc_s* `keep'
    duplicates drop
    predict xb, xb
    predict stdp, stdp
    gen lb = xb - (2 * stdp)
    gen ub = xb + (2 * stdp)
    isid age, so
    line xb age || rarea lb ub age, color(%30) lwidth(none) ///
        xscale(range(50 95)) xlab(50(10)90) xtitle("Age") ///
        ytitle("Linear predictor") name(`name', replace) legend(off) yline(0) ///
        title(`"`title'"', pos(11))
    
    if !mi(`"`saving'"') {
        keep xb lb ub age
        save `"`saving'"', `replace'
    }
    
    restore
end

prog plot_cohort
    syntax, name(string) [keep(varlist numeric) title(string) saving(string) replace]
    preserve
    
    qui replace su_id = ""
    qui replace loneliness = .
    qui replace wave = 1
    qui foreach var of varlist age_s* {
        sum `var'
        replace `var' = r(mean)
    }
    if !mi("`keep'") {
        qui foreach var of varlist `keep' {
            replace `var' = 0
        }
    }
    
    keep su_id loneliness yob age_s* wave bc_s* `keep'
    duplicates drop
    predict xb, xb
    predict stdp, stdp
    gen lb = xb - (2 * stdp)
    gen ub = xb + (2 * stdp)
    isid yob, so
    line xb yob || rarea lb ub yob, color(%30) lwidth(none) ///
        xscale(range(1920 1965)) xlab(1920(10)1960) xtitle("Birth year") ///
        ytitle("Linear predictor") name(`name', replace) legend(off) yline(0) ///
        title(`"`title'"', pos(11))
    
    if !mi(`"`saving'"') {
        keep xb lb ub yob
        save `"`saving'"', `replace'
    }
    
    restore
end

prog plot_wave
    syntax, name(string) [keep(varlist numeric) title(string) saving(string) replace]
    preserve
    
    qui replace su_id = ""
    qui replace loneliness = .
    qui foreach var of varlist age_s* bc_s* {
        sum `var'
        replace `var' = r(mean)
    }
    if !mi("`keep'") {
        qui foreach var of varlist `keep' {
            replace `var' = 0
        }
    }
    
    keep su_id loneliness wave age_s* bc_s* `keep'
    duplicates drop
    predict xb, xb
    predict stdp, stdp
    // Without constant, at Wave 1 SD is effectively 0
    li wave xb stdp
    gen lb = xb - (2 * stdp) if wave!=1
    gen ub = xb + (2 * stdp) if wave!=1
    isid wave, so
    tw rcap ub lb wave || sc xb wave, name(`name', replace) legend(off) ///
        xlab(1 "2005-06" 2 "2010-11" 3 "2015-16") xtitle("Survey year") ///
        ms(circle) yline(0) ytitle("Linear predictor") title(`"`title'"', pos(11))
    
    if !mi(`"`saving'"') {
        keep xb lb ub wave
        save `"`saving'"', `replace'
    }
    
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
ologit loneliness age_s* i.wave bc_s2-bc_s4 [pweight=weight_sel2], ///
    vce(cluster su_id)
testparm age_s*
testparm i.wave
testparm bc_s*
ologit loneliness age_s2-age_s4 i.wave bc_s* [pweight=weight_sel2], ///
    vce(cluster su_id)
testparm age_s*
testparm i.wave
testparm bc_s*

meologit loneliness age_s* i.wave bc_s2-bc_s4 || su_id:, pweight(weight_sel2) ///
    vce(robust)
testparm age_s*
testparm i.wave
testparm bc_s*
mkdirp `"`tmp'/apc"'
plot_age, name(age1) title("A") saving(`"`tmp'/apc/nshap_age"') replace
plot_cohort, name(cohort1) title("B") saving(`"`tmp'/apc/nshap_cohort"') replace
plot_wave, name(wave1) title("C") saving(`"`tmp'/apc/nshap_period"') replace

meologit loneliness age_s2-age_s4 i.wave bc_s* || su_id:, pweight(weight_sel2) ///
    vce(robust)
testparm age_s*
testparm i.wave
testparm bc_s*
plot_age, name(age2) title("D")
plot_cohort, name(cohort2) title("E")
plot_wave, name(wave2) title("F")

// Yet another specification; still no evidence of any cohort effects
gen byte w2 = (wave==2)
meologit loneliness age_s* w2 bc_s* || su_id:, pweight(weight_sel2) ///
    vce(robust)
testparm age_s*
testparm bc_s*

gr combine age1 cohort1 wave1 age2 cohort2 wave2, cols(3) ycommon name(apc, replace)
mkdirp tmp
gr export `"`tmp'/apc/apc_nshap.pdf"', replace
gr export `"`tmp'/apc/apc_nshap.eps"', replace


// Plot age and survey year effects for full model
gen female = (gender==2) if !mi(gender)
gen aa = (ethgrp==2) if !mi(ethgrp)
gen hisp = (ethgrp==3) if !mi(ethgrp)
gen other = (ethgrp==4) if !mi(ethgrp)
gen lths = (educ==1) if !mi(educ)
gen somecol = (educ==3) if !mi(educ)
gen college = (educ==4) if !mi(educ)
gen liv_alone = (liv_arrange==2) if !mi(liv_arrange)
gen liv_other = (liv_arrange==3) if !mi(liv_arrange)
meologit loneliness age_s1 age_s2 i.wave ///
    female aa hisp other lths somecol college ///
    physhlth comorb adls ///
    liv_alone liv_other alters clsrel framt ///
    || su_id:, pweight(weight_sel2) vce(robust)
plot_age, keep(female aa hisp other lths somecol college physhlth ///
               comorb adls liv_alone liv_other alters clsrel framt) ///
          name(age3) title("D") saving(`"`tmp'/apc/nshap_age_adj"')
plot_wave, keep(female aa hisp other lths somecol college physhlth ///
                comorb adls liv_alone liv_other alters clsrel framt) ///
           name(wave3) title("E") saving(`"`tmp'/apc/nshap_period_adj"')

gr combine age1 cohort1 wave1 age3 wave3, cols(3) ycommon name(apc2, replace)
gr export `"`tmp'/apc/apc_nshap2.pdf"', replace
gr export `"`tmp'/apc/apc_nshap2.eps"', replace
