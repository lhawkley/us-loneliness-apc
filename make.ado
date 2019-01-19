// Stata language pseudo-Makefile

prog make
    version 15.1
    set more off
    
    // Add ./ado temporarily to path
    foreach directory in ./ado . SITE BASE {
        qui adopath ++ `directory'
    }
    
    syntax [name(name=target local)] [, *]
    
    if mi(`"`target'"') loc target all
    
    _`target', `options'
    qui adopath - ./ado
end

// Build analytic datasets
prog _data
    syntax [, *]
    
    run data_mgmt/sample
    run data_mgmt/combine
    run data_mgmt/hrs
end

// Perform analyses
prog _analyses
    syntax [, *]
    
    do analyses/w1_w3
    do analyses/loneliness_by_age
    do analyses/apc
    do analyses/apc_hrs
    do analyses/apc_combined
    do analyses/demog
    do analyses/health_social
    do analyses/cohort_comparison
end

prog _all
    syntax [, *]
    
    _data, `options'
    _analyses, `options'
end
