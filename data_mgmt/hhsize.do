// Compute and add household size

version 15.1
include config

args wave

preserve
    use `"`nshap_data'/w`wave'/nshap_w`wave'_network"', clear
    egen hh_size = total(inlist(livewith,1,2)), by(su_id)
    keep su_id hh_size
    duplicates drop
    tempfile hh_size
    save `"`hh_size'"'
restore
merge 1:1 su_id using `"`hh_size'"', assert(master match) nogen
replace hh_size = 0 if mi(hh_size)
