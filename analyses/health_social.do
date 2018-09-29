// Ordinal regression models of loneliness on health and social characteristics

version 15.1
clear
include config
set more off

use `"`tmp'/loneliness_cohorts"'


// Exclude MoCA-SA and sensory items because they were not asked in all waves
ologit loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls ///
    [pweight=weight_sel2], vce(cluster su_id)

meologit loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls ///
    || su_id:, pweight(weight_sel2) vce(robust)
lincom 3.wave - 2.wave
nlcom (((-1) * _b[age_dev_70] / (2 * _b[c.age_dev_70#c.age_dev_70])) * 10) + 70
qui margins, predict(xb) at(age_dev_70=(-2(1)2)) nose
marginsplot


ologit loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    i.liv_arrange alters clsrel framt ///
    [pweight=weight_sel2], vce(cluster su_id)

meologit loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    i.liv_arrange alters clsrel framt ///
    || su_id:, pweight(weight_sel2) vce(robust)
lincom 3.wave - 2.wave
lincom 3.liv_arrange - 2.liv_arrange
nlcom (((-1) * _b[age_dev_70] / (2 * _b[c.age_dev_70#c.age_dev_70])) * 10) + 70
qui margins, predict(xb) at(age_dev_70=(-2(1)2)) nose
marginsplot
