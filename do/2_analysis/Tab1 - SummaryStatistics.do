if "`c(username)'"=="yungyu"{
	global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
	global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
	global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
	global do = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/do"
	global tab = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/tab"
}
if "`c(username)'"=="ytvxq"{
	global rdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/rdata"
	global wdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/wdata"
	global log = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/log"
	global do = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/do"
	global tab = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/tab"
}

clear
set more off

use "$wdata/FEVS_FedScope_2023_Supervisor_MI_30.dta", clear

foreach x in race female ageover40 tenure military{
	recode `x' 99 = .
}
gen tenure2 = tenure == 2
gen tenure4 = tenure == 4
gen tenure6 = tenure == 6

global varlist = "sat sr rc prop_sub_samerace prop_sup_samerace female ageover40 military tenure2 tenure4 tenure6"

cap log close
log using "$log/summary_stat.log", replace

proportion race [pw=weight1]
loc mean00 = e(N)

mat B = e(b)
forv i = 1(1)5{
	loc sd`i'0 = B[1,`i']
	loc mean`i'0 = `mean00' * `sd`i'0'
}

forv i = 0(1)5{
	dis "Race Group `i':"
	if (`i'==0) mi estimate,post: mean $varlist [aweight=weight1]
	if (`i'!=0) mi estimate,post: mean $varlist [aweight=weight1] if race == `i'
	mat B = e(b)
	mat V = e(V)
	
	forv j = 1(1)11{
		loc mean`i'`j' = B[1,`j']
		loc sd`i'`j'   = sqrt(V[`j',`j'])
	}
}

clear 
set obs 25

gen var = ""
forv i = 0(1)5{
	gen v`i' = ""
}

forv i = 0(1)5{
	forv j = 0(1)11{
		loc k0 = (`j'+1)*2-1
		loc k1 = `k0' + 1
		replace v`i' = "`mean`i'`j''" in `k0'
		replace v`i' = "`sd`i'`j''"   in `k1'
	}
}

save "$tab/Tab1.dta", replace

use "$tab/Tab1.dta", clear

destring _all, replace

forv i = 1(1)5{
	replace v`i' = round(v`i',1) in 1
}

forv i = 1(1)5{
	replace v`i' = round(v`i',.001) * 100 in 2
}

forv i = 0(1)5{
	loc N: dis v`i'[1]
	replace v`i' = round(v`i',.01) if _n > 2 & mod(_n,2) == 1
	replace v`i' = round(v`i'*sqrt(`N'),.01) if _n > 2 & mod(_n,2) == 0
}

tostring _all , replace format(%15.2fc) force

forv i = 1(1)5{
	replace v`i' = subinstr(v`i',".00","",.) in 1
	replace v`i' = substr(v`i',1,4) in 2
}

gen order = _n
replace order = 0 if order == 25
sort order
drop order

forv i = 0(1)5{
	replace v`i' = "("+v`i'+")" if mod(_n,2) == 1 & _n > 1
}

replace v0 = "All" in 1
replace v1 = "White" in 1
replace v2 = "Black" in 1
replace v3 = "Hispanic" in 1
replace v4 = "Asian" in 1
replace v5 = "Others" in 1

replace var = "Number of Observation" in 2
replace var = "Job Satisfaction" in 4
replace var = "Supervisor Relationship" in 6
replace var = "Role Clarity" in 8
replace var = "% Same Race Subordinates" in 10
replace var = "% Same Race Colleagues" in 12
replace var = "Female" in 14
replace var = "Age over 40" in 16
replace var = "Military" in 18
replace var = "<10" in 20
replace var = "10-20" in 22
replace var = "20+" in 24

replace var = "" if var == "."

export excel "$tab/Tab1.xlsx", replace
