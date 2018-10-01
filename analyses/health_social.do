// Ordinal regression models of loneliness on health and social characteristics

version 15.1
clear all
include config
set more off

use `"`tmp'/loneliness_cohorts"'


// Health characteristics
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
marginsplot, name(age_health, replace)


// Social characteristics
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
marginsplot, name(age_social, replace)


// Combine both in same model
meologit loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls ///
    i.liv_arrange alters clsrel framt ///    
    || su_id:, pweight(weight_sel2) vce(robust)
lincom 3.wave - 2.wave
lincom 3.liv_arrange - 2.liv_arrange
nlcom (((-1) * _b[age_dev_70] / (2 * _b[c.age_dev_70#c.age_dev_70])) * 10) + 70
qui margins, predict(xb) at(age_dev_70=(-2(1)2)) nose
marginsplot, name(age_combined, replace)

meologit, or
lincom 3.wave - 2.wave, or

// Test linear effect of education
meologit loneliness i.wave c.age_dev_70##c.age_dev_70 i.gender i.ethgrp educ ///
    physhlth comorb adls ///
    i.liv_arrange alters clsrel framt ///    
    || su_id:, pweight(weight_sel2) vce(robust)


// Finally, examine effect of birth cohort when adjusting for covariates
rcsgen age, df(4) gen(age_s) orthog
rcsgen yob, df(4) gen(bc_s) orthog
meologit loneliness i.wave age_s* bc_s2-bc_s4 i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls ///
    i.liv_arrange alters clsrel framt ///    
    || su_id:, pweight(weight_sel2) vce(robust)
testparm age_s*
testparm bc_s*
meologit loneliness i.wave age_s2-age_s4 bc_s* i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls ///
    i.liv_arrange alters clsrel framt ///    
    || su_id:, pweight(weight_sel2) vce(robust)
testparm age_s*
testparm bc_s*
meologit loneliness age_s* bc_s* i.gender i.ethgrp ib2.educ ///
    physhlth comorb adls ///
    i.liv_arrange alters clsrel framt ///    
    || su_id:, pweight(weight_sel2) vce(robust)
testparm age_s*
testparm bc_s*
