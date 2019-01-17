// Compare estimates of loneliness and covariates between W1 and W3 for those
// aged 57-85

version 15.1
clear all
include config
set more off

use `"`tmp'/loneliness_cohorts"'
keep if (wave==1) | (wave==3 & inrange(age,57,85))


table wave, c(count loneliness)
bys wave: sum loneliness [aweight=weight_adj]
reg loneliness i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave
gen byte lonely = (loneliness >= 5) if !mi(loneliness)
logit lonely i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)

bys wave: sum age [aweight=weight_adj]
reg age i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave

gen byte female = (gender==2) if !mi(gender)
logit female i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)

gen byte aa = (ethgrp==2) if !mi(ethgrp)
logit aa i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)
gen byte hisp = (ethgrp==3) if !mi(ethgrp)
logit hisp i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)

gen byte lths = (educ==1) if !mi(educ)
logit lths i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)
gen byte somcol = (educ==3) if !mi(educ)
logit somcol i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)
gen byte college = (educ==4) if !mi(educ)
logit college i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)

bys wave: sum physhlth [aweight=weight_adj]
reg physhlth i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave
gen byte gdhlth = (physhlth>2) if !mi(physhlth)
logit gdhlth i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)

bys wave: sum comorb [aweight=weight_adj]
reg comorb i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave
gen byte cmbd2plus = (comorb>1) if !mi(comorb)
logit cmbd2plus i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)

bys wave: sum adls [aweight=weight_adj]
reg adls i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave
logit adls i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)

gen byte liv_alone = (liv_arrange==2) if !mi(liv_arrange)
logit liv_alone i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)
gen byte liv_others = (liv_arrange==3) if !mi(liv_arrange)
logit liv_others i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave, pwcompare(cimargins cieffects)

bys wave: sum alters [aweight=weight_adj]
reg alters i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave

bys wave: sum clsrel [aweight=weight_adj]
reg clsrel i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave

bys wave: sum framt [aweight=weight_adj]
reg framt i.wave [pweight=weight_adj], vce(cluster su_id)
margins wave
