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

forv i = 2015(1)2019{
	ap using "$rdata/FEVS/FEVS`i'.dta", force
}

order year agency unit minor ageover40 super tenure female military education sat* leaving leave cr* sr* rc* postwt

label var cr_cooperate "The people I work with cooperate to get the job done."

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


lab de tenure 	1 "5 or fewer years" 2 "10 or fewer years" ///
				3 "6-14 years" 4 "10-20 years" ///
				5 "15 or more years" 6 "20 or more years"
lab val tenure tenure

lab de leaving 1 "No" 2 "Yes, to take another job within the Federal Government" 3 "Yes, to take another job outside the Federal Government" 4 "Yes, other"
lab val leaving leaving

recode minor . = 99

save "$wdata/FEVS_1519.dta", replace

use "$wdata/FEVS_1519.dta", clear

replace agency = "DN" if agency == "DR"

merge m:1 year agency unit using "$wdata/FedScope_Race_level2.dta", update
drop if _m == 2
drop _m
merge m:1 year agency using "$wdata/FedScope_Race_level1.dta", update
drop if _m == 2
drop _m

drop prop_sub0 prop_sup0
foreach var of varlist prop_sub_white-prop_sup_unspecified{
	rename `var' unit_`var'
}

merge m:1 year agency using "$wdata/FedScope_Race_level1.dta", update
drop if _m == 2
drop _m

foreach var of varlist prop_sub_white-prop_sup_unspecified{
	rename `var' agency_`var'
}


merge m:1 year agency unit using "$wdata/FedScope_Sex_level2.dta", update
drop if _m == 2
drop _m
merge m:1 year agency using "$wdata/FedScope_Sex_level1.dta", update
drop if _m == 2
drop _m

merge m:1 year agency unit using "$wdata/FedScope_level2.dta", update
drop if _m == 2
drop _m
merge m:1 year agency using "$wdata/FedScope_level1.dta", update
drop if _m == 2
drop _m

gen lnemployee_sub = log(employee0)
gen lnemployee_sup = log(employee1)
gen lnemployee = log(totemployee)
gen lnsalary_sub = log(salary_sub)
gen lnsalary_sup = log(salary_sup)

foreach x in sub sup{
	
	gen unit_prop_`x'_samerace = .
	replace unit_prop_`x'_samerace = unit_prop_`x'_white if minor == 0
	replace unit_prop_`x'_samerace = unit_prop_`x'_minor if minor == 1
	
	gen agency_prop_`x'_samerace = .
	replace agency_prop_`x'_samerace = agency_prop_`x'_white if minor == 0
	replace agency_prop_`x'_samerace = agency_prop_`x'_minor if minor == 1
	
}

foreach y in sub sup{
	gen diversity_`y' = 1 	- unit_prop_`y'_white^2 ///
							- unit_prop_`y'_black^2 ///
							- unit_prop_`y'_hisp^2 ///
							- unit_prop_`y'_asian^2 ///
							- unit_prop_`y'_aian^2 ///
							- unit_prop_`y'_nhpi^2 ///
							- unit_prop_`y'_twomore^2 ///
							- unit_prop_`y'_unspecified^2
}


save "$wdata/FEVS_FedScope_1519.dta", replace
use "$wdata/FEVS_FedScope_1519.dta", clear

keep if super == 1 & minor != 99
drop if agency == "XX" | agency == "SI" //small agency

egen unityear = group(agency unit year)
egen unitrace = group(agency unit minor)
egen yearrace = group(year minor)

factor sat_job sat_org, factor(1)
rotate, blank(0.3)
predict sat

factor sr_confidence sr_overall sr_senior sr_development sr_listen sr_respect, factor(1)
rotate, blank(0.3)
predict sr

factor rc_expected rc_agencygoal, factor(1)
rotate, blank(0.3)
predict rc

egen cr = std(cr_cooperate)

drop if sat == . | sr == . | rc == . | cr == . | leave == .

foreach x in sat sr rc cr{
	egen v1 = std(`x')
	replace `x' = v1
	drop v1
}

egen totweight = sum(postwt), by(year)
egen totn = count(postwt), by(year)
gen weight = postwt/totweight * totn

drop postwt totweight totn

save "$wdata/FEVS_FedScope_1519_Supervisor.dta", replace
