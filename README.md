This package contains code to perform analyses reported in "Are U.S. older
adults getting lonelier?: Age, period, and cohort differences" by Hawkley et
al. (2019).

These analyses use data from Waves 1–3 of the National Social Life, Health and
Aging Project (NSHAP) available from the National Archive of Computerized Data
on Aging [here](https://www.icpsr.umich.edu/icpsrweb/NACDA/series/706), as well
as data from the Health and Retirement Study (HRS) including the HRS Core data
from 2006–16 and the Cross-Wave Tracker file available
[here](http://hrsonline.isr.umich.edu/index.php?p=avail).

The code is written in [Stata](https://www.stata.com) (developed and tested
with Version 15.1).

To run, unpack the NSHAP and HRS datasets and modify `config.do` to point to
the resulting files, as necessary. The NSHAP files (in Stata format) should be
organized like

    nshap/
        w1/
            nshap_w1_core.dta
            nshap_w1_network.dta
            ...
        w2/
            nshap_w2_core.dta
            nshap_w2_network.dta
            ...
        w3/
            nshap_w3_core.dta
            nshap_w3_network.dta
            ...

and the HRS files should be organized like

    hrs/
        h06core/
        h08core/
        h10core/
        h12core/
        h14core/
        h16core/
        trk2014/

Then launch Stata and type

    make data
    make analyses
