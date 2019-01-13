// Fit APC models to HRS data

version 15.1
clear all
include config
set more off

use `"`tmp'/hrs"'

// Generate orthogonal spline variables for age, yob and yr
rcsgen age, df(4) gen(age_s) orthog
rcsgen yob, df(4) gen(bc_s) orthog
rcsgen yr, df(4) gen(yr_s) orthog

ren yr wave

prog plot_age
    syntax, name(string) [keep(varlist numeric) title(string) yrspline ///
        saving(string) replace]
    preserve
    
    qui replace su_id = ""
    qui replace loneliness = .
    if mi("`yrspline'") {
        qui replace wave = 1
        loc wave wave
    }
    else {
        loc yrspline "yr_s*"
    }
    qui foreach var of varlist bc_s* `yrspline' {
        sum `var'
        replace `var' = r(mean)
    }
    if !mi("`keep'") {
        qui foreach var of varlist `keep' {
            replace `var' = 0
        }
    }
    
    keep su_id loneliness age age_s* `wave' bc_s* `yrspline' `keep'
    duplicates drop
    predict xb, xb
    predict stdp, stdp
    gen lb = xb - (2 * stdp)
    gen ub = xb + (2 * stdp)
    isid age, so
    line xb age || rarea lb ub age, color(%30) lwidth(none) ///
        xscale(range(50 95)) xlab(50(10)95) xtitle("Age") ///
        ytitle("Linear predictor") name(`name', replace) legend(off) yline(0) ///
        title(`"`title'"', pos(11))
    
    if !mi(`"`saving'"') {
        keep xb lb ub age
        save `"`saving'"', `replace'
    }
    
    restore
end

prog plot_cohort
    syntax, name(string) [keep(varlist numeric) title(string) yrspline ///
        saving(string) replace]
    preserve
    
    qui replace su_id = ""
    qui replace loneliness = .
    if mi("`yrspline'") {
        qui replace wave = 1
        loc wave wave
    }
    else {
        loc yrspline "yr_s*"
    }
    qui foreach var of varlist age_s* `yrspline' {
        sum `var'
        replace `var' = r(mean)
    }
    if !mi("`keep'") {
        qui foreach var of varlist `keep' {
            replace `var' = 0
        }
    }
    
    keep su_id loneliness yob age_s* `wave' bc_s* `yrspline' `keep'
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
        xlab(6 "06" 8 "08" 10 "10" 12 "12" 14 "14" 16 "16") xtitle("Survey year") ///
        ms(circle) yline(0) ytitle("Linear predictor") title(`"`title'"', pos(11))
    
    if !mi(`"`saving'"') {
        keep xb lb ub wave
        save `"`saving'"', `replace'
    }
    
    restore
end


// APC models
// Discrete specification
// No real evidence of cohort effects; very weak evidence of period effects in
// mixed models
ologit loneliness age_s* i.wave bc10 [pweight=wgtr2], vce(cluster su_id)
testparm i.wave
ologit loneliness age_s* i.wave i.bc10 [pweight=wgtr2], vce(cluster su_id)
testparm age_s*
testparm i.wave
testparm i.bc10
meologit loneliness age_s* i.wave bc10 || su_id:, pweight(wgtr2) ///
    vce(robust)
testparm i.wave
meologit loneliness age_s* i.wave i.bc10 || su_id:, pweight(wgtr2) ///
    vce(robust)
testparm age_s*
testparm i.wave
testparm i.bc10

// Continuous specification
// Weak evidence of cohort and period effects in the presence of a linear age
// effect; second model not very informative given the rather obvious linear
// effect of age
ologit loneliness age_s* i.wave bc_s2-bc_s4 [pweight=wgtr2], ///
    vce(cluster su_id)
testparm age_s*
testparm i.wave
testparm bc_s*
ologit loneliness age_s2-age_s4 i.wave bc_s* [pweight=wgtr2], ///
    vce(cluster su_id)
testparm age_s*
testparm i.wave
testparm bc_s*

meologit loneliness age_s* i.wave bc_s2-bc_s4 || su_id:, pweight(wgtr2) ///
    vce(robust)
testparm age_s*
testparm i.wave
testparm bc_s*

mkdirp `"`tmp'/apc"'
plot_age, name(age1) title("A") saving(`"`tmp'/apc/hrs_age"') replace
plot_cohort, name(cohort1) title("B") saving(`"`tmp'/apc/hrs_cohort"') replace
plot_wave, name(wave1) title("C") saving(`"`tmp'/apc/hrs_period"') replace

// Model period/year using splines
meologit loneliness age_s* yr_s* bc_s2-bc_s4 || su_id:, pweight(wgtr2) ///
    vce(robust)
testparm age_s*
testparm yr_s*
testparm bc_s*
meologit loneliness age_s* yr_s2-yr_s4 bc_s* || su_id:, pweight(wgtr2) ///
    vce(robust)
testparm age_s*
testparm yr_s*
testparm bc_s*
plot_age, name(age2) title("D") yrspline
plot_cohort, name(cohort2) title("E") yrspline

gr combine age1 cohort1 wave1 age2 cohort2, cols(3) ycommon name(apc, replace)
mkdirp tmp
gr export `"`tmp'/apc/apc_hrs.pdf"', replace
gr export `"`tmp'/apc/apc_hrs.eps"', replace
