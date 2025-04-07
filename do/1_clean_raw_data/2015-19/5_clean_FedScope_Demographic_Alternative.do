global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"

clear
set more off

*********************************** Level 2 ***********************************

use "$wdata/FedScope_Race.dta", clear
keep if level == 2

rename unit unit_fedscope
joinby unit_fedscope using "$wdata/code_transfer.dta"
order unit_fevs, a(unit_fedscope)

sort year agency unit_fedscope unit_fevs SS race

** Calculate the maxmium number of missing value
gen missing = Number == . if inrange(race,3,8)
egen totmissing = sum(missing), by(year agency unit_fedscope unit_fevs level SS)
gen v0 = Number if inrange(race,3,8)
egen nonmissing = sum(v0), by(year agency unit_fedscope unit_fevs level SS) //Total minority number for non-missing
gen v1 = Number if race == 2
egen minority = sum(v1), by(year agency unit_fedscope unit_fevs level SS) //Total minority
gen maxmium = minority - nonmissing //maxmium number of missing value
replace maxmium = 0 if maxmium < 0 //replace negative to 0
replace maxmium = round(maxmium,1) //round to integer
replace Number = maxmium / totmissing if Number == . & inrange(race,3,8)
drop v0 v1 missing totmissing nonmissing minority maxmium

collapse (sum)Number SSTot UnitTot, by(year agency unit_fevs level SS race)

gen prop = Number / SSTot

gen employee = UnitTot
drop Number SSTot UnitTot

reshape wide prop, i(year agency unit_fevs level race employee) j(SS)

rename prop0 prop_sub
rename prop1 prop_sup

reshape wide prop*, i(year agency unit_fevs level employee) j(race)

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

rename unit_fevs unit

replace agency = substr(unit,1,2)
drop if substr(unit,3,2) == "ZZ"

save "$wdata/FedScope_Race_level2_OO_alternative.dta", replace

******************************** Level 2 of ZZ ********************************

use "$wdata/FedScope_Race.dta", clear
keep if level == 2
replace agency = "SN" if agency == "SM"
replace agency = "DR" if unit == "DNFE"

rename unit unit_fedscope
joinby unit_fedscope using "$wdata/code_transfer.dta", unmatched(master) _merge(_merge)
gen matched = _m == 3
drop _m

egen anymatched = max(matched), by(agency)
keep if anymatched == 1
keep if matched == 0 | substr(unit_fevs,3,2) == "ZZ"

sort year agency unit_fedscope unit_fevs SS race
by year agency unit_fedscope unit_fevs SS: replace Number = Number[_n-2] - Number[_n-1] - Number[_n+7] if race == 2 & Number == . //Minority = Total - White - Unspecified
by year agency unit_fedscope unit_fevs SS: replace Number = Number[_n-1] - Number[_n+1] - Number[_n+8] if race == 1 & Number == . //White = Total - Minority - Unspecified

** Drop if total is missing
gen v1 = race == 0 & Number == .
egen v2 = sum(v1), by(year agency unit_fedscope unit_fevs level SS)
drop if v2 == 1
drop v1 v2

** If both white or minority are missing
gen missing = Number == . if inrange(race,1,2)
egen totmissing = sum(missing), by(year agency unit_fedscope unit_fevs level SS)
gen v1 = Number if race == 0
egen total = sum(v1), by(year agency unit_fedscope unit_fevs level SS) //Total employee
gen maxmium = total //maxmium number of missing value
replace Number = maxmium / totmissing if Number == . & inrange(race,1,2)
drop missing totmissing maxmium v1 total

** Calculate the maxmium number of missing value
gen missing = Number == . if inrange(race,3,8)
egen totmissing = sum(missing), by(year agency unit_fedscope unit_fevs level SS)
gen v0 = Number if inrange(race,3,8)
egen nonmissing = sum(v0), by(year agency unit_fedscope unit_fevs level SS) //Total minority number for non-missing
gen v1 = Number if race == 2
egen minority = sum(v1), by(year agency unit_fedscope unit_fevs level SS) //Total minority
gen maxmium = minority - nonmissing //maxmium number of missing value
replace maxmium = 0 if maxmium < 0 //replace negative to 0
replace maxmium = round(maxmium,1) //round to integer
replace Number = maxmium / totmissing if Number == . & inrange(race,3,8)
drop v0 v1 missing totmissing nonmissing minority maxmium

collapse (sum)Number SSTot UnitTot, by(year agency unit_fevs level SS race)

gen prop = Number / SSTot

gen employee = UnitTot
drop Number SSTot UnitTot

reshape wide prop, i(year agency unit_fevs level race employee) j(SS)

rename prop0 prop_sub
rename prop1 prop_sup

drop if race == 0
reshape wide prop*, i(year agency unit_fevs level employee) j(race)

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

rename unit_fevs unit

order year agency unit
save "$wdata/FedScope_Race_level2_ZZ_alternative.dta", replace

use "$wdata/FedScope_Race_level2_OO_alternative.dta",clear
ap using "$wdata/FedScope_Race_level2_ZZ_alternative.dta"

sort year agency unit
duplicates drop
drop if unit == ""

save "$wdata/FedScope_Race_level2_alternative.dta", replace


*********************************** Level 1 ***********************************

import excel "$rdata/agency_charc.xlsx", clear firstrow sheet(agency_charc)

keep agency_fevs 
duplicates drop
rename agency_fevs agency 

merge 1:m agency using "$wdata/FedScope_Race.dta"
replace _m = 3 if agency == "SM" | unit == "DNFE"
keep if _m == 3
replace level = . if agency == "DN"
replace level = 1 if unit == "DNFE" | unit == "DN00"
keep if level == 1
drop _m

replace agency = "SN" if agency == "SM"
replace agency = "DR" if unit == "DNFE"

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

save "$wdata/FedScope_Race_level1_alternative.dta", replace
