// Extract information on social factors from Lifestyle Questionnaire

version 15.1
clear all
include config

cap mkdir `"`tmp'/hrs"'

prog _lb_r
    syntax anything, year(string) prefix(string) [drive(string) ///
                                                  hrs_release(string) tmp(string)]
    loc yr = substr("`year'",3,.)
    if mi("`drive'") loc drive c
    copy `"`hrs_release'/h`yr'core/H`yr'LB_R.da"' `"`tmp'/hrs/H`yr'LB_R.da"', replace
    filefilter `"`hrs_release'/h`yr'core/H`yr'LB_R.dct"' `"`tmp'/hrs/H`yr'LB_R.dct"', ///
        from("`drive':\BShrs`year'\BSdata\BS") to(`"`tmp'/hrs/"') replace
    
    preserve
        qui infile using `"`tmp'/hrs/H`yr'LB_R.dct"', clear
        ren _all, lower
        while 1 {
            gettoken varnames anything: anything, match(paren)
            if mi("`varnames'") continue, break
            gettoken old new: varnames
            clonevar `new' = `prefix'`old'
            loc varlist "`varlist' `new'"
        }
        keep hhid pn `varlist'
        gen yr = "`yr'"
        tempfile mydata
        save `"`mydata'"'
    restore
    append using `"`mydata'"'
    
end

loc varlist (lb015 any_frnds) (lb018 no_frnds) (lb007 any_kids) (lb010 no_kids) ///
            (lb011 any_fam) (lb014 no_fam) (lb020a companion) (lb020b leftout) ///
            (lb020c isolated)
_lb_r `varlist', year(2006) prefix(k) drive(C) tmp(`"`tmp'"') hrs_release(`"`hrs_release'"')
_lb_r `varlist', year(2008) prefix(l) tmp(`"`tmp'"') hrs_release(`"`hrs_release'"')
_lb_r `varlist', year(2010) prefix(m) tmp(`"`tmp'"') hrs_release(`"`hrs_release'"')
_lb_r `varlist', year(2012) prefix(n) tmp(`"`tmp'"') hrs_release(`"`hrs_release'"')

_lb_r (lb014 any_frnds) (lb017 no_frnds) (lb006 any_kids) (lb009 no_kids) ///
      (lb010 any_fam) (lb013 no_fam) (lb019a companion) (lb019b leftout) ///
      (lb019c isolated), ///
      year(2014) prefix(o) tmp(`"`tmp'"') hrs_release(`"`hrs_release'"')
_lb_r (lb014 any_frnds) (lb017 no_frnds) (lb006 any_kids) (lb009 no_kids) ///
      (lb010 any_fam) (lb013 no_fam) (lb019a companion) (lb019b leftout) ///
      (lb019c isolated), ///
      year(2016) prefix(p) tmp(`"`tmp'"') hrs_release(`"`hrs_release'"')

foreach i of varlist any_frnds any_kids any_fam {
recode `i' 1=1 5=0 7=.
lab def `i' 1 "Yes" 0 "No"
lab val `i' `i'
}

// reverse code and label
replace companion=4-companion
replace leftout=4-leftout
replace isolated=4-isolated
lab def companion 3 "often" 2 "some of the time" 1 "hardly ever or never"
lab val companion companion
lab def leftout 3 "often" 2 "some of the time" 1 "hardly ever or never"
lab val leftout leftout
lab def isolated 3 "often" 2 "some of the time" 1 "hardly ever or never"
lab val isolated isolated

replace pn="020" if hhid=="526934" & pn=="010"  & yr=="10"
replace hhid="525520" if hhid=="526934" & yr=="10"

replace pn="020" if hhid=="529766" & pn=="010"  & yr=="10"
replace hhid="520845" if hhid=="529766" & yr=="10"


compress
isid hhid pn yr, so
save `"`tmp'/hrs/social"', replace
