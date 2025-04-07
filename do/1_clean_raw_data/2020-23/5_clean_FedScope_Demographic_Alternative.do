global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"

clear
set more off

*********************************** Level 1 ***********************************

import excel "$rdata/agency_charc 2023.xlsx", clear firstrow sheet(agency_charc)

keep agency_fedscope 
duplicates drop
rename agency_fedscope agency 

merge 1:m agency using "$wdata/FedScope_2023_Race.dta"
keep if _m == 3
keep if level == 1
drop _m

collapse (mean)Number SSTot UnitTot, by(year agency level SS race)

replace Number = round(Number,1)

sort year agency SS race

** Calculate the maxmium number of missing value
forv i = 3(1)8{
	gen v0 = Number if inrange(race,3,8)
	egen nonmissing = sum(v0), by(year agency level SS) //Total minority number for non-missing
	gen v1 = Number if race == 2
	egen minority = sum(v1), by(year agency level SS) //Total minority
	gen maxmium = minority - nonmissing //maxmium number of missing value
	replace maxmium = 0 if maxmium < 0 //replace negative to 0
	replace maxmium = round(maxmium,1) //round to integer
	set seed `i'
	replace Number = runiformint(0,maxmium) if Number == . & race == `i'
	drop v0 v1 nonmissing minority maxmium
}

collapse (sum)Number SSTot UnitTot, by(year agency level SS race)

gen prop = Number / SSTot

gen employee = UnitTot

keep year agency race employee SS prop

reshape wide prop, i(year agency race employee) j(SS)

rename prop0 prop_sub
rename prop1 prop_sup

drop if race == 0
reshape wide prop*, i(year agency employee) j(race)

foreach x in sub sup{
	rename prop_`x'1 alt_prop_`x'_white
	rename prop_`x'2 alt_prop_`x'_minority
	rename prop_`x'3 alt_prop_`x'_black
	rename prop_`x'4 alt_prop_`x'_hisp
	rename prop_`x'5 alt_prop_`x'_asian
	rename prop_`x'6 alt_prop_`x'_aian
	rename prop_`x'7 alt_prop_`x'_nhpi
	rename prop_`x'8 alt_prop_`x'_twomore
	rename prop_`x'9 alt_prop_`x'_unspecified
}

order year agency

save "$wdata/FedScope_Race_2023_level1_alternative.dta", replace
