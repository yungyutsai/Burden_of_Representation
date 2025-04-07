global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
global tab = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/tab"

use "$wdata/FEVS_FedScope_2023_Supervisor.dta", clear

local i = 1
foreach x in sat_job sat_organization cr_cooperate sr_development sr_listen sr_respect sr_confidence sr_overall sr_senior rc_expected rc_agencygoal{
	sum `x'
	local mean`i': dis %4.3f r(mean)
	local sd`i': dis %4.3f r(sd)
	loc i = `i'+1
}

** Job Satisfaction
factor  sat_job sat_organization, factor(1)
rotate, blank(0.3)
matrix M1 = e(r_L)
alpha sat_job sat_organization, asis
local alpha1 = r(alpha)

** Supervisor Relationship
factor 	sr_development sr_listen sr_respect sr_confidence sr_overall sr_senior, factor(1)
rotate, blank(0.3)
matrix M2 = e(r_L)
alpha sr_development sr_listen sr_respect sr_confidence sr_overall sr_senior
local alpha3 = r(alpha)

** Role Clarity
factor 	rc_expected rc_agencygoal, factor(1)
rotate, blank(0.3)
matrix M3 = e(r_L)
alpha rc_expected rc_agencygoal
local alpha2 = r(alpha)

clear
set obs 15

gen item = ""
replace item = "Considering everything, how satisfied are you with your job?" in 1
replace item = "Considering everything, how satisfied are you with your organization?" in 2
replace item = "The people I work with cooperate to get the job done." in 3
replace item = "Supervisors in my work unit support employee development." in 4
replace item = "My supervisor listens to what I have to say." in 5
replace item = "My supervisor treats me with respect." in 6
replace item = "I have trust and confidence in my supervisor." in 7
replace item = "Overall, how good a job do you feel is being done by your immediate supervisor?" in 8
replace item = "I have a high level of respect for my organization's senior leaders." in 9
replace item = "I know what is expected of me on the job." in 10
replace item = "I know how my work relates to the agency's goals." in 11

replace item = "Job Satisfaction" in 12
replace item = "Co-worker Relationship" in 13
replace item = "Supervisor Relationship" in 14
replace item = "Role Clarity" in 15


gen mean = .
gen sd = .
forv i = 1(1)11{
	replace mean = `mean`i'' in `i'
	replace sd = `sd`i'' in `i'
}


gen facload = .
forv i = 1(1)2{
	replace facload = M1[`i',1] if _n == `i'
}
forv i = 1(1)6{
	local j = `i' + 3
	replace facload = M2[`i',1] if _n == `j'
}
forv i = 1(1)2{
	local j = `i' + 9
	replace facload = M3[`i',1] if _n == `j'
}

gen alpha = .
replace alpha = `alpha1' in 12
replace alpha = `alpha2' in 14
replace alpha = `alpha3' in 15

gen row = _n
recode row 12=0.5 13=2.5 14=3.5 15=9.5

sort row
drop row

format facload alpha %9.3f
export excel "$tab/Tables_v17.xlsx", sheet(TabA1, replace)
