global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"

clear
set more off

import excel "$rdata/agency_charc 2023.xlsx", clear firstrow sheet(agency_charc)
keep agency*
duplicates drop
save "$wdata/code_transfer_2023.dta", replace

import excel "$rdata/agency_charc 2023.xlsx", clear firstrow sheet(agency_charc)

keep name_fevs agency_fevs Headquarters Founded Army
rename name_fevs agency_name
rename agency_fevs agency
duplicates drop

replace Headquarters = "Overseas" if Headquarters == "Germany"
encode Headquarters, gen(location)

recode Army . = 0

save "$wdata/agency_charc.dta", replace
