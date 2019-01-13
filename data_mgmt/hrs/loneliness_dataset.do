version 15.1
clear

use hhid-id using tmp/hrs/tracker
merge 1:1 hhid pn yr using tmp/hrs/social, keepusing(companion leftout isolated)

destring yr, gen(yr_)
bysort hhid pn (yr): replace gender=gender[_n-1] if mi(gender)
bysort hhid pn (yr): gen lapse=yr_-yr_[_n-1] if mi(age)
bysort hhid pn (yr): replace age=age[_n-1]+lapse if mi(age)


drop if _merge==1 

// exclude those missing all 3 loneliness questions
egen nmiss=rowmiss( companion leftout isolated)
tab nmiss
drop if nmiss==3

// for those completely new to 2016, won't have gender or age or weights on them

// restrict to those age eligible (birthyr 1920-1965)
//??
gen birthyr=2000+yr_-age
bysort hhid pn (yr): replace birthyr=birthyr[1]
//assert !mi(age)
drop if (birthyr<1920 | birthyr>1965) & !mi(age)


isid hhid pn yr
bysort hhid pn  (yr): gen index=_n
count if index==1
replace id=.
replace id=_n if index==1
bysort hhid pn (yr): replace id=id[_n-1] if mi(id)

//drop with 0 or missing LBQ weights, not sure that this is needed
//drop if inlist(lbwgtr,.,0)

egen loneliness=rowmean(companion isolated leftout)
replace loneliness=loneliness*3

compress
isid hhid pn yr, so
save tmp/hrs/loneliness_dataset, replace
