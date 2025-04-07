if "`c(username)'"=="yungyu"{
	global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
	global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
	global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
}
if "`c(username)'"=="ytvxq"{
	global rdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/rdata"
	global wdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/wdata"
	global log = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/log"
}

clear
set more off

forv year = 2020(1)2023{
	foreach month in Mar June Sep Dec{ //Mar June Sep Dec
		foreach level in agency subagency{ //
			import delimited using "$rdata/FedScope/sex/`year'/`month'/`level'.csv", clear

			drop in 1
			
			if "`level'" == "agency"{
				rename v2 unit
				rename v3 sex
				rename v4 Number1
				rename v5 Number2
				rename v6 Number3
				rename v7 Number4
				rename v8 Number5
				drop v1 v9
				replace unit = substr(unit,1,2)
			}
			if "`level'" == "subagency"{
				rename v1 unit
				rename v2 sex
				rename v3 Number1
				rename v4 Number2
				rename v5 Number3
				rename v6 Number4
				rename v7 Number5
				drop v8
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

			replace sex = "1" if sex == "Male"
			replace sex = "2" if sex == "Female"
			replace sex = "3" if sex == "Unspecified"
			replace sex = "4" if sex == "Gender - All"
			destring sex, replace force
			drop if sex == .

			compress

			reshape long Number, i(unit sex) j(SS)
			reshape wide Number, i(unit SS) j(sex)


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
			
			reshape long Number, i(unit SS) j(sex)
			
			sort unit SS sex Number
			duplicates drop unit SS sex, force
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
			
			save "$wdata/FedScope_Sex_`year'_`month'_`level'.dta", replace
		}
	}
}

clear
forv year = 2020(1)2023{
	foreach month in Sep /*Mar June Sep Dec*/{
		foreach level in agency subagency{
			ap using "$wdata/FedScope_Sex_`year'_`month'_`level'.dta"
		}
	}
}

sort unit SS sex Number

gen v1 = Number if sex == 4
egen SSTot = sum(v1), by(unit SS year month)
replace v1 = .
replace v1 = Number if sex == 4 & SS == 5
egen UnitTot = sum(v1), by(unit year month)
drop v1

lab de sex 1 "Male" 2 "Female" 3 "Unspecified" 4 "Total"
lab val sex sex

keep if SS == 1 | SS == 3
recode SS (1=1)(3=0)

lab de SS 1 "Supervisor" 0 "Non-Supervisor"
lab val SS SS

gen agency = substr(unit,1,2)

order year agency unit level SS sex Number SSTot UnitTot
save "$wdata/FedScope_2023_Sex.dta", replace

*********************************** Level 1 ***********************************

import excel "$rdata/agency_charc 2023.xlsx", clear firstrow sheet(agency_charc)

keep agency_fevs 
duplicates drop
rename agency_fevs agency 

merge 1:m agency using "$wdata/FedScope_2023_Sex.dta"
keep if _m == 3
keep if level == 1
drop _m

collapse (mean)Number SSTot UnitTot, by(year agency level SS sex)

replace Number = round(Number,1)

sort year agency SS sex

collapse (sum)Number SSTot UnitTot, by(year agency level SS sex)

gen prop = Number / SSTot

gen employee = SSTot
gen totemployee = UnitTot
drop Number SSTot UnitTot

reshape wide prop employee, i(year agency level sex totemployee) j(SS)

rename prop0 prop_sub
rename prop1 prop_sup

drop if sex == 4
reshape wide prop*, i(year agency level employee0 employee1 totemployee) j(sex)

foreach x in sub sup{
	rename prop_`x'1 prop_`x'_male
	rename prop_`x'2 prop_`x'_female
	rename prop_`x'3 prop_`x'_unspecified
}

order year agency
save "$wdata/FedScope_Sex_2023_level1.dta", replace
