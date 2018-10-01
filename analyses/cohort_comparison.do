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
    if inrange(yob,1920,1947) & wave==1 [pweight=weight_sel], vce(robust)
ologit loneliness c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls eyesight hearing ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1920,1947) & wave==2 [pweight=weight_sel], vce(robust)


// Models with quadratic age effects
ologit loneliness c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls moca_sa eyesight hearing ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1920,1947) & wave==2 [pweight=weight_sel], vce(robust)

ologit loneliness c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls moca_sa ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1948,1965) & wave==3 [pweight=weight_sel], vce(robust)

// Repeat without quadratic age effects
ologit loneliness c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls moca_sa eyesight hearing ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1920,1947) & wave==2 [pweight=weight_sel], vce(robust)
lincom 3.liv_arrange - 2.liv_arrange

ologit loneliness c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls moca_sa ///
    i.liv_arrange alters clsrel framt ///
    if inrange(yob,1948,1965) & wave==3 [pweight=weight_sel], vce(robust)
lincom 3.liv_arrange - 2.liv_arrange


// Test a few differences between models
svyset [pweight=weight_sel]
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
    if inrange(yob,1920,1947) [pweight=weight_sel], vce(robust)
