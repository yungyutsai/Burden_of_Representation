global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"

clear
set more off

forv year = 2015(1)2019{
	foreach month in Sep{ //Mar June Sep Dec
		foreach level in agency subagency{
			import delimited using "$rdata/FedScope/demographic/`year'/`month'/`level'.csv", clear

			drop in 1
			
			if "`level'" == "agency"{
				rename v2 unit
				rename v4 race
				rename v5 Number1
				rename v6 Number2
				rename v7 Number3
				rename v8 Number4
				rename v9 Number5
				drop v1 v3 v10
				replace unit = substr(unit,1,2)
			}
			if "`level'" == "subagency"{
				rename v1 unit
				rename v3 race
				rename v4 Number1
				rename v5 Number2
				rename v6 Number3
				rename v7 Number4
				rename v8 Number5
				drop v2 v9
				replace unit = substr(unit,1,4)
			}
			
			replace unit = unit[_n-1] if unit == ""
			
			compress

			destring Number*, replace force

			gen missing = 0

			forv i = 1(1)5{
				replace missing = missing + 1 if Number`i' == .
			}	

			replace Number4 = Number5 - Number1 - Number2 - Number3 if missing == 1 & Number4 == .

			gen rowtotal = 0
			forv i = 1(1)4{
				replace rowtotal = rowtotal + Number`i' if Number`i' ~= .
			}

			forv i = 1(1)4{
				replace Number`i' = 0 if Number`i' == . & rowtotal == Number5
			}
			
			replace Number4 = 0 if Number4 == . //recode nonspecified missing as 0
			
			replace missing = 0

			forv i = 1(1)5{
				replace missing = missing + 1 if Number`i' == .
			}	

			replace Number2 = Number5 - Number1 - Number3 - Number4 if missing == 1 & Number2 == .
			
			replace Number2 = 0 if Number2 == . //recode leader missing as 0
			
			replace missing = 0

			forv i = 1(1)5{
				replace missing = missing + 1 if Number`i' == .
			}	

			replace Number1 = Number5 - Number2 - Number3 - Number4 if missing == 1 & Number1 == .
			
			drop missing rowtotal

			replace race = "1" if race == "Minority"
			replace race = "2" if race == "White"
			replace race = "3" if race == "Unspecified"
			replace race = "4" if race == "Ethnicity and Race Indicator - All"
			replace race = "5" if race == "American Indian or Alaskan Native"
			replace race = "6" if race == "Asian"
			replace race = "7" if race == "Black/African American"
			replace race = "8" if race == "Native Hawaiian or Pacific Islander"
			replace race = "9" if race == "More Than One Race"
			replace race = "10" if race == "Hispanic/Latino (H/L)"
			drop if race == "Non-Minority"
			destring race, replace force
			drop if race == .

			compress

			reshape long Number, i(unit race) j(SS)
			reshape wide Number, i(unit SS) j(race)


			gen missing = 0

			forv i = 1(1)4{
				replace missing = missing + 1 if Number`i' == .
			}	

			replace Number3 = Number4 - Number1 - Number2 if missing == 1 & Number3 == .
			replace Number3 = 0 if Number3 == . //Set Unspecified = 0 if missing

			gen rowtotal = 0
			forv i = 1(1)3{
				replace rowtotal = rowtotal + Number`i' if Number`i' ~= .
			}

			forv i = 1(1)3{
				replace Number`i' = 0 if Number`i' == . & rowtotal == Number4
			}

			drop missing rowtotal
			
			gen missing = 0

			forv i = 5(1)10{
				replace missing = missing + 1 if Number`i' == .
			}	

			replace Number5 = Number1 - Number6 - Number7 - Number8 - Number9 - Number10 if missing == 1 & Number5 == .
			replace Number6 = Number1 - Number5 - Number7 - Number8 - Number9 - Number10 if missing == 1 & Number6 == .
			replace Number7 = Number1 - Number5 - Number6 - Number8 - Number9 - Number10 if missing == 1 & Number7 == .
			replace Number8 = Number1 - Number5 - Number6 - Number7 - Number9 - Number10 if missing == 1 & Number8 == .
			replace Number9 = Number1 - Number5 - Number6 - Number7 - Number8 - Number10 if missing == 1 & Number9 == .
			replace Number10 = Number1 - Number5 - Number6 - Number7 - Number8 - Number9 if missing == 1 & Number10 == .

			gen rowtotal = 0
			forv i = 5(1)10{
				replace rowtotal = rowtotal + Number`i' if Number`i' ~= .
			}

			forv i = 5(1)10{
				replace Number`i' = 0 if Number`i' == . & rowtotal == Number1
			}

			drop missing rowtotal
			
			reshape long Number, i(unit SS) j(race)
			
			sort unit SS race Number
			duplicates drop unit SS race, force
			gen year = `year'
			order year
			gen month = 0
			replace month = 3 if "`month'" == "Mar"
			replace month = 6 if "`month'" == "June"
			replace month = 9 if "`month'" == "Sep"
			replace month = 12 if "`month'" == "Dec"
			gen level = 0
			replace level = 1 if "`level'" == "agency"
			replace level = 2 if "`level'" == "subagency"
			
			save "$wdata/FedScope_Race_`year'_`month'_`level'.dta", replace
		}
	}
}

clear
forv year = 2015(1)2019{
	foreach month in June /*Mar June Sep Dec*/{
		foreach level in agency subagency{
			ap using "$wdata/FedScope_Race_`year'_`month'_`level'.dta"
		}
	}
}

recode race (2=1)(1=2)(7=3)(10=4)(6=5)(5=6)(8=7)(9=8)(3=9)(4=0)
sort unit SS race Number

gen v1 = Number if race == 0
egen SSTot = sum(v1), by(unit SS year month)
egen UnitTot = sum(v1), by(unit year month)
drop v1

lab de race 1 "White" 2 "Minority" 3 "Black/African American" ///
			4 "Hispanic/Latino" 5 "Asian" 6 "American Indian or Alaskan Native" ///
			7 "Native Hawaiian or Pacific Islander" 8 "More Than One Race" ///
			9 "Unspecified" 0 "Total"
lab val race race

keep if SS == 1 | SS == 3
recode SS (1=1)(3=0)

lab de SS 1 "Supervisor" 0 "Non-Supervisor"
lab val SS SS

gen agency = substr(unit,1,2)

order year agency unit level SS race Number SSTot UnitTot
save "$wdata/FedScope_Race.dta", replace

*********************************** Level 2 ***********************************

use "$wdata/FedScope_Race.dta", clear
keep if level == 2

rename unit unit_fedscope
joinby unit_fedscope using "$wdata/code_transfer.dta"
order unit_fevs, a(unit_fedscope)

sort year agency unit_fedscope unit_fevs SS race

** Calculate the maxmium number of missing value
forv i = 3(1)8{
	gen v0 = Number if inrange(race,3,8)
	egen nonmissing = sum(v0), by(year agency unit_fedscope unit_fevs level SS) //Total minority number for non-missing
	gen v1 = Number if race == 2
	egen minority = sum(v1), by(year agency unit_fedscope unit_fevs level SS) //Total minority
	gen maxmium = minority - nonmissing //maxmium number of missing value
	replace maxmium = 0 if maxmium < 0 //replace negative to 0
	replace maxmium = round(maxmium,1) //round to integer
	set seed `i'
	replace Number = runiformint(0,maxmium) if Number == . & race == `i'
	drop v0 v1 nonmissing minority maxmium
}

collapse (sum)Number SSTot UnitTot, by(year agency unit_fevs level SS race)

gen prop = Number / SSTot

gen employee = UnitTot
drop Number SSTot UnitTot

reshape wide prop, i(year agency unit_fevs level race employee) j(SS)

rename prop0 prop_sub
rename prop1 prop_sup

reshape wide prop*, i(year agency unit_fevs level employee) j(race)

foreach x in sub sup{
	rename prop_`x'1 prop_`x'_white
	rename prop_`x'2 prop_`x'_minority
	rename prop_`x'3 prop_`x'_black
	rename prop_`x'4 prop_`x'_hisp
	rename prop_`x'5 prop_`x'_asian
	rename prop_`x'6 prop_`x'_aian
	rename prop_`x'7 prop_`x'_nhpi
	rename prop_`x'8 prop_`x'_twomore
	rename prop_`x'9 prop_`x'_unspecified
}

rename unit_fevs unit

replace agency = substr(unit,1,2)
drop if substr(unit,3,2) == "ZZ"

save "$wdata/FedScope_Race_level2_OO.dta", replace

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
forv i = 1(1)2{
	gen v0 = Number if inrange(race,1,2)
	egen nonmissing = sum(v0), by(year agency unit_fedscope unit_fevs level SS) //Total minority number for non-missing
	gen v1 = Number if race == 0
	egen total = sum(v1), by(year agency unit_fedscope unit_fevs level SS) //Total employee
	gen maxmium = total - nonmissing //maxmium number of missing value
	replace maxmium = 0 if maxmium < 0 //replace negative to 0
	replace maxmium = round(maxmium,1) //round to integer
	set seed `i'
	replace Number = runiformint(0,maxmium) if Number == . & race == `i'
	drop v0 v1 nonmissing total maxmium
}

** Calculate the maxmium number of missing value
forv i = 3(1)8{
	gen v0 = Number if inrange(race,3,8)
	egen nonmissing = sum(v0), by(year agency unit_fedscope unit_fevs level SS) //Total minority number for non-missing
	gen v1 = Number if race == 2
	egen minority = sum(v1), by(year agency unit_fedscope unit_fevs level SS) //Total minority
	gen maxmium = minority - nonmissing //maxmium number of missing value
	replace maxmium = 0 if maxmium < 0 //replace negative to 0
	replace maxmium = round(maxmium,1) //round to integer
	set seed `i'
	replace Number = runiformint(0,maxmium) if Number == . & race == `i'
	drop v0 v1 nonmissing minority maxmium
}

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
	rename prop_`x'1 prop_`x'_white
	rename prop_`x'2 prop_`x'_minority
	rename prop_`x'3 prop_`x'_black
	rename prop_`x'4 prop_`x'_hisp
	rename prop_`x'5 prop_`x'_asian
	rename prop_`x'6 prop_`x'_aian
	rename prop_`x'7 prop_`x'_nhpi
	rename prop_`x'8 prop_`x'_twomore
	rename prop_`x'9 prop_`x'_unspecified
}

rename unit_fevs unit

order year agency unit
save "$wdata/FedScope_Race_level2_ZZ.dta", replace

use "$wdata/FedScope_Race_level2_OO.dta",clear
ap using "$wdata/FedScope_Race_level2_ZZ.dta"

sort year agency unit
duplicates drop
drop if unit == ""

save "$wdata/FedScope_Race_level2.dta", replace


*********************************** Level 1 ***********************************

import excel "$rdata/agency_charc.xlsx", clear firstrow sheet(agency_charc_1719)

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
	rename prop_`x'1 prop_`x'_white
	rename prop_`x'2 prop_`x'_minority
	rename prop_`x'3 prop_`x'_black
	rename prop_`x'4 prop_`x'_hisp
	rename prop_`x'5 prop_`x'_asian
	rename prop_`x'6 prop_`x'_aian
	rename prop_`x'7 prop_`x'_nhpi
	rename prop_`x'8 prop_`x'_twomore
	rename prop_`x'9 prop_`x'_unspecified
}

order year agency
save "$wdata/FedScope_Race_level1.dta", replace
