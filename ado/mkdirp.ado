*! Simulate bash's -mkdir- with the -p option

program mkdirp
    version 13
    syntax anything(name=directory_name id="directory name")
    tokenize `"`directory_name'"'
    if `"`2'"'!="" {
        di as error "directory name invalid"
        exit(198)
    }
    
    loc path .
    tokenize `directory_name', parse("/")
    while `"`1'"'!="" {
        if `"`1'"'!="/" {
            loc path `path'/`1'
            cap mkdir `"`path'"'            
        }
        mac shift
    }

end
