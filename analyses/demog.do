// Basic models of loneliness with selected demographic covariates

version 15.1
clear
include config
set more off

use `"`tmp'/loneliness_cohorts"'

reg loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ, ///
    vce(cluster su_id)
reg loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    [pweight=weight_sel2], vce(cluster su_id)

ologit loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ, ///
    vce(cluster su_id)
ologit loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    [pweight=weight_sel2], vce(cluster su_id)

meologit loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    || su_id:, vce(robust)
meologit loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    || su_id:, pweight(weight_sel2) vce(robust)
nlcom (((-1) * _b[age_dev_70] / (2 * _b[c.age_dev_70#c.age_dev_70])) * 10) + 70
qui margins, predict(xb) at(age_dev_70=(-2(1)2)) nose
marginsplot
lincom 3.wave - 2.wave

meologit, or
lincom 3.wave - 2.wave, or
