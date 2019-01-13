// Read tracker file

version 15.1
clear
set more off

cap mkdir tmp
cap mkdir tmp/hrs

// Read tracker file
copy data/hrs/trk2014/TRK2014TR_R.da tmp/hrs/TRK2014TR_R.da, replace
filefilter data/hrs/trk2014/TRK2014TR_R.dct tmp/hrs/TRK2014TR_R.dct, ///
    from("c:\BStrk2014\BSdata\BS") to("tmp/hrs/") replace
infile using tmp/hrs/TRK2014TR_R.dct
ren _all, lower

isid hhid pn, so
gen id = _n

recode gender .=.u
lab def gender 1 "Male" 2 "Female" .u "Unknown"
lab val gender gender

lab def race 0 "Not obtained" 1 "White/Caucasian" 2 "Black or African American" ///
    7 "Other"
lab val race race

lab def hispanic 0 "Not obtained" 1 "Hispanic, Mexican" 2 "Hispanic, Other" ///
    3 "Hispanic, type unknown" 5 "Non-Hispanic"
lab val hispanic hispanic

lab def degree 0 "No degree" 1 "GED" 2 "High school diploma" ///
    3 "Two year college degree" 4 "Four year college degree" 5 "Master degree" ///
    6 "Professional degree (Ph.D., M.D., J.D.)" 9 "Degree unknown/Some College"
lab val degree degree

recode race 1=1 2=2 7=4 else=., gen(ethgrp)
replace ethgrp = 3 if inlist(hispanic,1,2,3) & race!=2
replace ethgrp = . if !hispanic & race!=2
lab def ethgrp 1 "white" 2 "black" 3 "hispanic, non-black" 4 "other"
lab val ethgrp ethgrp

recode degree (0=1) (1/2=2) (3 9 = 3) (4/6=4), gen(educ)
lab def educ 1 "< hs" 2 "hs/equiv" 3 "voc cert/some college/assoc" 4 "bachelors or more"
lab val educ educ

keep hhid pn id gender ethgrp educ kage lage mage nage oage ///
    kbiowgtr klbwgtr kpmwgtr kwgtr lbiowgtr llbwgtr lpmwgtr lwgtr ///
	mbiowgtr mlbwgtr mpmwgtr mwgtr nbiowgtr nlbwgtr npmwgtr nwgtr ///
	obiowgtr olbwgtr opmwgtr owgtr
ren (kage lage mage nage oage) (age06 age08 age10 age12 age14)
ren (kbiowgtr klbwgtr kpmwgtr kwgtr) (biowgtr06 lbwgtr06 pmwgtr06 wgtr06)
ren (lbiowgtr llbwgtr lpmwgtr lwgtr) (biowgtr08 lbwgtr08 pmwgtr08 wgtr08)
ren (mbiowgtr mlbwgtr mpmwgtr mwgtr) (biowgtr10 lbwgtr10 pmwgtr10 wgtr10)
ren (nbiowgtr nlbwgtr npmwgtr nwgtr) (biowgtr12 lbwgtr12 pmwgtr12 wgtr12)
ren (obiowgtr olbwgtr opmwgtr owgtr) (biowgtr14 lbwgtr14 pmwgtr14 wgtr14)
reshape long age biowgtr lbwgtr pmwgtr wgtr, i(hhid pn) j(yr) string
recode age (996=.a) (999=.b)
lab def age .a "Date of Birth info not available" .b "NO CORE INTERVIEW THIS WAVE"
lab val age age

lab var biowgtr "RESPONDENT WEIGHT FOR THE BIOMARKER SUBSAMPLE"
lab var lbwgtr "RESPONDENT WEIGHT FOR THE LEAVE BEHIND QNAIRE"
lab var pmwgtr "RESPONDENT WEIGHT FOR THE PHYSICAL MEASURES SUBSAMPLE"
lab var wgtr "RESPONDENT LEVEL WEIGHT"

compress
isid hhid pn yr, so
save tmp/hrs/tracker, replace
