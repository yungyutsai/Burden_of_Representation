global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"

clear
set more off

forv year = 2020(1)2023{
	foreach month in March June September December{
			local month2 = upper(substr("`month'",1,3))
			import delimited using "$rdata/FedScope/`year'/`month'/FACTDATA_`month2'`year'.TXT", clear

			
			keep agysub agelvl edlvl patco loslvl sallvl supervis workstat salary los
			
			rename agysub unit_fedscope
			
			replace agelvl = "18" if agelvl == "A"
			replace agelvl = "22" if agelvl == "B"
			replace agelvl = "27" if agelvl == "C"
			replace agelvl = "32" if agelvl == "D"
			replace agelvl = "37" if agelvl == "E"
			replace agelvl = "42" if agelvl == "F"
			replace agelvl = "47" if agelvl == "G"
			replace agelvl = "52" if agelvl == "H"
			replace agelvl = "57" if agelvl == "I"
			replace agelvl = "62" if agelvl == "J"
			replace agelvl = "67" if agelvl == "K"
			destring agelvl, gen(age) force
			
			gen eduyr = .
			replace eduyr = 0 if edlvl == "01"
			replace eduyr = 6 if edlvl == "02"
			replace eduyr = 9 if edlvl == "03"
			replace eduyr = 12 if edlvl == "04"
			replace eduyr = 12 if edlvl == "05"
			replace eduyr = 12 if edlvl == "06"
			replace eduyr = 13 if edlvl == "07"
			replace eduyr = 13 if edlvl == "08"
			replace eduyr = 14 if edlvl == "09"
			replace eduyr = 14 if edlvl == "10"
			replace eduyr = 15 if edlvl == "11"
			replace eduyr = 16 if edlvl == "12"
			replace eduyr = 16 if edlvl == "13"
			replace eduyr = 17 if edlvl == "14"
			replace eduyr = 17 if edlvl == "15"
			replace eduyr = 17 if edlvl == "16"
			replace eduyr = 18 if edlvl == "17"
			replace eduyr = 20 if edlvl == "18"
			replace eduyr = 22 if edlvl == "19"
			replace eduyr = 22 if edlvl == "20"
			replace eduyr = 22 if edlvl == "21"
			replace eduyr = 24 if edlvl == "22"
			
			gen Professional = patco == 1
			gen Administrative = patco == 2
			gen Technical = patco == 3
			gen Clerical = patco == 4
			gen White_Collar = patco == 5
			gen Blue_Collar = patco == 6
			
			replace los = 0.5 if los == . & loslvl == "A"
			replace los = 1.5 if los == . & loslvl == "B"
			replace los = 3.5 if los == . & loslvl == "C"
			replace los = 7 if los == . & loslvl == "D"
			replace los = 12 if los == . & loslvl == "E"
			replace los = 17 if los == . & loslvl == "F"
			replace los = 22 if los == . & loslvl == "G"
			replace los = 27 if los == . & loslvl == "H"
			replace los = 32 if los == . & loslvl == "I"
			replace los = 36 if los == . & loslvl == "J"
			
			cap replace salary = subinstr(salary,"$","",.)
			cap replace salary = subinstr(salary,",","",.)
			destring salary, replace
			replace salary = 15000 if salary == . & sallvl == "A"
			replace salary = 25000 if salary == . & sallvl == "B"
			replace salary = 35000 if salary == . & sallvl == "C"
			replace salary = 45000 if salary == . & sallvl == "D"
			replace salary = 55000 if salary == . & sallvl == "E"
			replace salary = 65000 if salary == . & sallvl == "F"
			replace salary = 75000 if salary == . & sallvl == "G"
			replace salary = 85000 if salary == . & sallvl == "H"
			replace salary = 95000 if salary == . & sallvl == "I"
			replace salary = 105000 if salary == . & sallvl == "J"
			replace salary = 115000 if salary == . & sallvl == "K"
			replace salary = 125000 if salary == . & sallvl == "L"
			replace salary = 135000 if salary == . & sallvl == "M"
			replace salary = 145000 if salary == . & sallvl == "N"
			replace salary = 155000 if salary == . & sallvl == "O"
			replace salary = 165000 if salary == . & sallvl == "P"
			replace salary = 175000 if salary == . & sallvl == "Q"
			replace salary = 185000 if salary == . & sallvl == "R"
			replace salary = 195000 if salary == . & sallvl == "S"
			replace salary = 205000 if salary == . & sallvl == "T"
			replace salary = 225000 if salary == . & sallvl == "U"
			replace salary = 245000 if salary == . & sallvl == "V"
			replace salary = 265000 if salary == . & sallvl == "W"
			replace salary = 285000 if salary == . & sallvl == "X"
			replace salary = 305000 if salary == . & sallvl == "Y"
			
			gen fulltime = workstat == 1
			gen supervisor = .
			replace supervisor = 1 if supervis == "2"
			replace supervisor = 0 if supervis == "8"
			
			drop if supervisor == .
			
			gen employee = 1
			collapse (sum)employee (mean)age eduyr salary los Professional Administrative Technical Clerical White_Collar Blue_Collar fulltime , by(unit_fedscope supervisor)
			
			gen year = `year'
			gen month = 0
			replace month = 3 if "`month'" == "March"
			replace month = 6 if "`month'" == "June"
			replace month = 9 if "`month'" == "September"
			replace month = 12 if "`month'" == "December"
			order year month
			
			save "$wdata/FedScope_`year'_`month'.dta", replace
	}
}


clear
forv year = 2020(1)2023{
	foreach month in June /*March June September December*/{
			ap using "$wdata/FedScope_`year'_`month'.dta"
	}
}

gen SS = supervisor
lab de SS 1 "Supervisor" 0 "Non-Supervisor"
lab val SS SS

gen agency = substr(unit,1,2)

order year agency unit SS
save "$wdata/FedScope_2023.dta", replace

*********************************** Level 1 ***********************************

import excel "$rdata/agency_charc 2023.xlsx", clear firstrow sheet(agency_charc)

keep agency_fedscope 
duplicates drop
rename agency_fedscope agency 

merge 1:m agency using "$wdata/FedScope_2023.dta"
keep if _m == 3
drop _m

gen w = employee

collapse (mean) age eduyr salary los Professional Administrative Technical Clerical White_Collar Blue_Collar fulltime (sum)employee [aweight = 2], by(year agency SS)

reshape wide age eduyr salary los Professional Administrative Technical Clerical White_Collar Blue_Collar fulltime employee, i(year agency) j(SS)

foreach x in age eduyr salary los Professional Administrative Technical Clerical White_Collar Blue_Collar fulltime employee{
	rename `x'0 `x'_sub
	rename `x'1 `x'_sup
}

gen totemployee = employee_sub + employee_sup

order year agency
save "$wdata/FedScope_2023_level1.dta", replace
