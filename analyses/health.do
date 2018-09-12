// Models of loneliness incorporating time-varying health covariates

version 15.1
clear
include config
set more off

use `"`tmp'/loneliness_cohorts"'

// keep if inrange(yob,1920,1933)
// keep if inrange(yob,1934,1947)
// keep if inrange(yob,1948,1965)

meologit loneliness i.gender i.educ i.ethgrp i.married c.age##c.age i.bc i.wave ///
    || su_id:, vce(robust)
meologit loneliness i.gender i.educ i.ethgrp i.married c.age##c.age i.bc i.wave ///
    ib3.alters || su_id:, vce(robust)
meologit loneliness i.gender i.educ i.ethgrp i.married c.age##c.age i.bc i.wave ///
    i.framt i.clsrel || su_id:, vce(robust)
meologit loneliness i.gender i.educ i.ethgrp i.married c.age##c.age i.bc i.wave ///
    eyesight hearing || su_id:, vce(robust)
meologit loneliness i.gender i.educ i.ethgrp i.married c.age##c.age i.bc i.wave ///
    moca_sa || su_id:, vce(robust)
