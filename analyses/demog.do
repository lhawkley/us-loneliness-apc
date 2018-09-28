// Basic models of loneliness with selected demographic covariates

version 15.1
clear
include config
set more off

use `"`tmp'/loneliness_cohorts"'

sum age
replace age = (age - 70) / 10

reg loneliness i.wave c.age##c.age i.gender i.ethgrp i.educ, vce(cluster su_id)
reg loneliness i.wave c.age##c.age i.gender i.ethgrp i.educ ///
    [pweight=weight_sel2], vce(cluster su_id)

ologit loneliness i.wave c.age##c.age i.gender i.ethgrp i.educ, vce(cluster su_id)
ologit loneliness i.wave c.age##c.age i.gender i.ethgrp i.educ ///
    [pweight=weight_sel2], vce(cluster su_id)

meologit loneliness i.wave c.age##c.age i.gender i.ethgrp i.educ || su_id:, ///
    vce(robust)
meologit loneliness i.wave c.age##c.age i.gender i.ethgrp i.educ || su_id:, ///
    pweight(weight_sel2) vce(robust)
nlcom (((-1) * _b[age] / (2 * _b[c.age#c.age])) * 10) + 70
qui margins, predict(xb) at(age=(-2(1)2)) nose
marginsplot
lincom 3.wave - 2.wave

meologit, or
lincom 3.wave - 2.wave, or
