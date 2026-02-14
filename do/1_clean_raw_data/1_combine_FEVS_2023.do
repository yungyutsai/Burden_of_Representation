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

clear

forv i = 2020(1)2023{
	ap using "$rdata/FEVS/FEVS`i'.dta", force
}

order year agency race minor ageover40 super tenure female military sat* leaving leave cr* sr* rc* sc* postwt

label var cr_cooperate "The people I work with cooperate to get the job done."
label var cr_share_knowledge "Employees in my work unit share job knowledge."

label var sr_development "Supervisors in my work unit support employee development."
label var sr_listen "My supervisor listens to what I have to say."
label var sr_respect "My supervisor treats me with respect."
label var sr_confidence "I have trust and confidence in my supervisor."
label var sr_overall "Overall, how good a job do you feel is being done by your immediate supervisor?"
label var sr_senior "I have a high level of respect for my organization's senior leaders."

label var sat_involve "How satisfied are you with your involvement in decisions that affect your work?"
label var sat_information "How satisfied are you with the information you receive from management on what's going on in your organization?"
label var sat_recognition "How satisfied are you with the recognition you receive for doing a good job?"
label var sat_job "Considering everything, how satisfied are you with your job?"
label var sat_pay "Considering everything, how satisfied are you with your pay?"
label var sat_organization "Considering everything, how satisfied are you with your organization?"

label var rc_expected "I know what is expected of me on the job."
label var rc_agencygoal "I know how my work relates to the agency's goals."
label var rc_communicate "Managers communicate the goals of the organization."

label var sc_accomplishment "My work gives me a feeling of personal accomplishment."
label var sc_talent "My talents are used well in the workplace."


lab de race 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Others"
lab val race race

lab de tenure 	1 "5 or fewer years" 2 "10 or fewer years" ///
				3 "6-14 years" 4 "10-20 years" ///
				5 "15 or more years" 6 "20 or more years"
lab val tenure tenure

lab de leaving 1 "No" 2 "Yes, to take another job within the Federal Government" 3 "Yes, to take another job outside the Federal Government" 4 "Yes, other"
lab val leaving leaving

recode race . = 99
recode minor . = 99

save "$wdata/FEVS_2023.dta", replace

use "$wdata/FEVS_2023.dta", clear

replace agency = "DN" if agency == "DR"

merge m:1 year agency using "$wdata/FedScope_Race_2023_level1.dta", update
drop if _m == 2
drop _m
merge m:1 year agency using "$wdata/FedScope_Race_2023_level1_All.dta", update
drop if _m == 2
drop _m

merge m:1 year agency using "$wdata/FedScope_Sex_2023_level1.dta", update
drop if _m == 2
drop _m
merge m:1 year agency using "$wdata/FedScope_2023_level1.dta", update
drop if _m == 2
drop _m

gen lnemployee_sub = log(employee0)
gen lnemployee_sup = log(employee1)
gen lnemployee = log(totemployee)
gen lnsalary_sub = log(salary_sub)
gen lnsalary_sup = log(salary_sup)

foreach x in sub sup{
	
	gen prop_`x'_other = prop_`x'_aian + prop_`x'_nhpi + prop_`x'_twomore
	order prop_`x'_other, b(prop_sub_unspecified)
	
	gen prop_`x'_samerace = .
	replace prop_`x'_samerace = prop_`x'_white if race == 1
	replace prop_`x'_samerace = prop_`x'_black if race == 2
	replace prop_`x'_samerace = prop_`x'_hisp  if race == 3
	replace prop_`x'_samerace = prop_`x'_asian if race == 4
	replace prop_`x'_samerace = prop_`x'_other if race == 5
	
}

foreach y in sub sup{
	gen diversity_`y' = 1 	- prop_`y'_white^2 ///
							- prop_`y'_black^2 ///
							- prop_`y'_hisp^2 ///
							- prop_`y'_asian^2 ///
							- prop_`y'_aian^2 ///
							- prop_`y'_nhpi^2 ///
							- prop_`y'_twomore^2 ///
							- prop_`y'_unspecified^2
	gen entropy_`y' = 	prop_`y'_white*ln(1/prop_`y'_white)/ln(8) ///
					+	prop_`y'_black*ln(1/prop_`y'_black)/ln(8) ///
					+	prop_`y'_hisp*ln(1/prop_`y'_hisp)/ln(8) ///
					+	prop_`y'_asian*ln(1/prop_`y'_asian)/ln(8) ///
					+	prop_`y'_aian*ln(1/prop_`y'_aian)/ln(8) ///
					+	prop_`y'_nhpi*ln(1/prop_`y'_nhpi)/ln(8) ///
					+	prop_`y'_twomore*ln(1/prop_`y'_twomore)/ln(8) ///
					+	prop_`y'_unspecified*ln(1/prop_`y'_unspecified)/ln(8)
}

gen diversity = 1 	- prop_white^2 ///
					- prop_black^2 ///
					- prop_hisp^2 ///
					- prop_asian^2 ///
					- prop_aian^2 ///
					- prop_nhpi^2 ///
					- prop_twomore^2 ///
					- prop_unspecified^2

save "$wdata/FEVS_FedScope_2023.dta", replace

use "$wdata/FEVS_FedScope_2023.dta", clear

keep if super == 1 & minor != 99
drop if agency == "XX" | agency == "SI" //small agency

egen agencyyear = group(agency year)
egen agencyrace = group(agency race)
egen yearrace = group(year race)

factor sat_job sat_org, factor(1)
rotate, blank(0.3)
predict sat

factor sr_confidence sr_overall sr_senior sr_development sr_listen sr_respect, factor(1)
rotate, blank(0.3)
predict sr

factor rc_expected rc_agencygoal, factor(1)
rotate, blank(0.3)
predict rc

factor sc_accomplishment sc_talent, factor(1)
rotate, blank(0.3)
predict sc

egen cr = std(cr_cooperate)

drop if sat == . | sr == . | rc == . | cr == . | leave == .

foreach x in sat sr rc cr sc{
	egen v1 = std(`x')
	replace `x' = v1
	drop v1
}

/*
egen totweight = sum(postwt), by(year)
egen totn = count(postwt), by(year)
gen weight = postwt/totweight * totn

drop postwt totweight totn
*/

encode agency, gen(agency_cd)

save "$wdata/FEVS_FedScope_2023_Supervisor.dta", replace
