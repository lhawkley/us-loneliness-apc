// Compute and add network size

version 15.1
include config

args wave

preserve
    use `"`nshap_data'/w`wave'/nshap_w`wave'_network"'
    egen alters = total(section==1), by(su_id)
    keep su_id alters
    duplicates drop
    tempfile netvars
    save `"`netvars'"'
restore
merge 1:1 su_id using `"`netvars'"', assert(master match) nogen
ass rosterintro==1 if alters & !mi(alters)
replace alters = 0 if rosterintro==0 & mi(alters)
