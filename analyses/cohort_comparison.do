// Ordinal regression models of loneliness, fit separately by birth cohort

version 15.1
clear
include config
set more off

use `"`tmp'/loneliness_cohorts"'


// Black/white difference slightly larger in 2005-06 than in 2010-11
ologit loneliness c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls eyesight hearing ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1920,1947) & wave==1 [pweight=weight_adj], vce(robust)
ologit loneliness c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls eyesight hearing ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1920,1947) & wave==2 [pweight=weight_adj], vce(robust)


// Models with quadratic age effects
ologit loneliness c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls moca_sa eyesight hearing ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1920,1947) & wave==2 [pweight=weight_adj], vce(robust)
ologit loneliness c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls moca_sa ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1948,1965) & wave==3 [pweight=weight_adj], vce(robust)

// Repeat without quadratic age effects
ologit loneliness c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls moca_sa eyesight hearing ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1920,1947) & wave==2 [pweight=weight_adj], vce(robust)
lincom 3.liv_arrange - 2.liv_arrange
mat b1 = e(b)
mat v1 = e(V)

ologit loneliness c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls moca_sa ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1948,1965) & wave==3 [pweight=weight_adj], vce(robust)
lincom 3.liv_arrange - 2.liv_arrange
mat b2 = e(b)
mat v2 = e(V)


// Test a few differences between models
svyset [pweight=weight_adj]
qui svy, subpop(if inrange(yob,1920,1947) & wave==2): ///
    ologit loneliness c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls moca_sa eyesight hearing ///
    i.liv_arrange alters clsrel framt
estimates store m1
qui svy, subpop(if inrange(yob,1948,1965) & wave==3): ///
    ologit loneliness c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls moca_sa ///
    i.liv_arrange alters clsrel framt
estimates store m2
suest m1 m2
test [m1_loneliness]3.ethgrp = [m2_loneliness]3.ethgrp
test [m1_loneliness]physhlth = [m2_loneliness]physhlth
test [m1_loneliness]adls = [m2_loneliness]adls
test [m1_loneliness]2.liv_arrange = [m2_loneliness]2.liv_arrange
test [m1_loneliness]3.liv_arrange = [m2_loneliness]3.liv_arrange
test [m1_loneliness]clsrel = [m2_loneliness]clsrel
test [m1_loneliness]framt = [m2_loneliness]framt


// Repeat 1920-47 with data from Waves 1 and 2, for comparison
// Use marginal model so that coefficients are comparable
// Results very similar; only differences are: (1) AA/white difference
// larger (see W1/W2 comparison above), and (2) coefficients for hearing and
// close relatives are slightly larger
ologit loneliness c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls eyesight hearing ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1920,1947) [pweight=weight_adj], vce(robust)


// Plot estimates from models above
drop _all
loc c1: colsof b1
loc cnames1: colnames b1
loc c2: colsof b2
loc cnames2: colnames b2
set obs `=max(`c1',`c2')'
gen var1 = ""
gen var2 = ""
foreach var in b1 lb1 ub1 b2 lb2 ub2 {
    gen `var' = .
}
forv i = 1/`c(N)' {
    replace var1 = `"`:word `i' of `cnames1''"' in `i'
    replace var2 = `"`:word `i' of `cnames2''"' in `i'
    replace b1 = b1[1,`i'] in `i'
    replace lb1 = b1 - 1.96*sqrt(v1[`i',`i']) in `i'
    replace ub1 = b1 + 1.96*sqrt(v1[`i',`i']) in `i'
    replace b2 = b2[1,`i'] in `i'
    replace lb2 = b2 - 1.96*sqrt(v2[`i',`i']) in `i'
    replace ub2 = b2 + 1.96*sqrt(v2[`i',`i']) in `i'
}
gen id = _n
reshape long var b lb ub, i(id) j(model)

gen y = 10 if var=="framt"
replace y = 20 if var=="clsrel"
replace y = 30 if var=="alters"
replace y = 40 if var=="3.liv_arrange"
replace y = 50 if var=="2.liv_arrange"
replace y = 70 if var=="hearing"
replace y = 80 if var=="eyesight"
replace y = 90 if var=="moca_sa"
replace y = 100 if var=="adls"
replace y = 110 if var=="comorb"
replace y = 120 if var=="physhlth"
replace y = 140 if var=="4.educ"
replace y = 150 if var=="3.educ"
replace y = 160 if var=="1.educ"
replace y = 170 if var=="4.ethgrp"
replace y = 180 if var=="3.ethgrp"
replace y = 190 if var=="2.ethgrp"
replace y = 200 if var=="2.gender"
replace y = 210 if var=="age_dev_70"

keep if !mi(y)
replace y = y - 3.5 if model==2
sc y b if model==1, ms(circle) msize(*0.75) mcolor("0 63 92") ///
    || rcap lb ub y if model==1, horizontal lcolor("0 63 92") ///
    || sc y b if model==2, ms(circle) msize(*0.75) mcolor("188 80 144") ///
    || rcap lb ub y if model==2, horizontal lcolor("188 80 144") ///    
    ylab(10 "Number of friends" 20 "Number of close family" 30 "Network size" ///
         40 "Living w/others vs. spouse" ///
         50 "Living alone vs. spouse" ///
         70 "Self-rated hearing" 80 "Self-rated vision" ///
         90 "MoCA-SA" 100 "ADLs" 110 "Comorbidities" 120 "Self-rated health" ///
         140 "Bachelors" 150 "Some college" 160 "< HS vs. HS" ///
         170 "Other vs. white" 180 "Hispanic vs. white" 190 "AA/black vs. white" ///
         200 "Women vs. men" 210 "Age (decades)" ///
         , angle(horizontal) notick labsize(*0.9)) yscale(lstyle(none)) ///
    ytitle("") xline(0, lwidth(thin)) xscale(range(-1.5 1.5)) ///
    xlab(-1.5(0.5)1.5, labsize(*0.9)) plotregion(lcolor(none)) ///
    legend(order(1 "Born 1920-47" 3 "Born 1948-65") cols(1) ring(0) pos(3) size(*0.9)) ///
    xtitle("Coefficient (95% CI)")

gr export `"`tmp'/loneliness_covars.pdf"', replace
gr export `"`tmp'/loneliness_covars.eps"', replace
