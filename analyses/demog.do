// Basic models of loneliness with selected demographic covariates

version 15.1
clear
include config
set more off

use `"`tmp'/loneliness_cohorts"'
gen loneliness = companion + leftout + isolated
recode maritlst 1/2=1 3/6=0, gen(married)

meologit loneliness i.gender i.educ i.ethgrp i.married c.age##c.age ///
    || su_id:, vce(robust)

meologit loneliness i.gender i.educ i.ethgrp i.married c.age##c.age i.bc i.wave ///
    || su_id:, vce(robust)

meologit loneliness i.educ i.ethgrp i.married c.age##c.age if gender==1 ///
    || su_id:, vce(robust)
meologit loneliness i.educ i.ethgrp i.married c.age##c.age if gender==2 ///
    || su_id:, vce(robust)

meologit loneliness i.gender i.educ i.ethgrp  i.married age if inrange(yob,1920,1933) ///
    || su_id:, vce(robust)
meologit loneliness i.gender i.educ i.ethgrp  i.married age if inrange(yob,1934,1947) ///
    || su_id:, vce(robust)
meologit loneliness i.gender i.educ i.ethgrp  i.married age if inrange(yob,1948,1965) ///
    || su_id:, vce(robust)

egen id = group(su_id)
xtset id
xtreg loneliness i.gender i.educ i.ethgrp i.married c.age##c.age, be
xtreg loneliness i.gender i.educ i.ethgrp i.married c.age##c.age, fe vce(cluster id)
