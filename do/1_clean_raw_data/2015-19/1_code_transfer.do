global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"

clear
set more off

import excel "$rdata/agency_charc 1519.xlsx", clear firstrow sheet(agency_charc)
keep unit*

drop if unit_fedscope == ""
duplicates drop
save "$wdata/code_transfer.dta", replace

import excel "$rdata/agency_charc 1519.xlsx", clear firstrow sheet(agency_charc)

keep name_fevs agency_fevs unit_fevs Headquarters Founded Army
rename name_fevs unit_name
rename agency_fevs agency
rename unit_fevs unit
drop if unit == ""
duplicates drop

replace Headquarters = "Overseas" if Headquarters == "Germany"
encode Headquarters, gen(location)

recode Army . = 0

save "$wdata/unit_charc.dta", replace
