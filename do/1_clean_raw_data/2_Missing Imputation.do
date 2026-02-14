if "`c(username)'"=="yungyu"{
	global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
	global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
	global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
	global tab = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/tab"
}

global cov1 = "age_sub age_sup eduyr_sub eduyr_sup los_sub los_sup fulltime_sub fulltime_sup lnsalary_sub lnsalary_sup prop_sub_female prop_sup_female lnemployee_sub lnemployee_sup"
global cov2 = "diversity_sub diversity_sup"
global cov3 = "i.ageover40 i.tenure i.female i.military"

use "$wdata/FEVS_FedScope_2023.dta", clear

keep if super == 1 
drop if agency == "XX" | agency == "SI" //small agency
keep if minor != 99

egen agencyyear = group(agency year)
egen agencyrace = group(agency race)
egen yearrace = group(year race)

cap gen sat = .
cap gen sr = .
cap gen rc = .

replace sat = (sat_job + sat_organization) / 2
replace sr = (sr_confidence + sr_overall + sr_senior + sr_development + sr_listen + sr_respect) / 6
replace rc = rc_expected

cap encode agency, gen(agency_cd)

mi unset, asis
mi set wide
mi register imputed sat sr rc
mi impute mvn sat sr rc = $cov3 i.race i.agency_cd i.year, add(30)

save "$wdata/FEVS_FedScope_2023_Supervisor_MI_30.dta", replace
use "$wdata/FEVS_FedScope_2023_Supervisor_MI_30.dta", replace

mi estimate: reg sat c.prop_sub_samerace#i.minor prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year, cl(agencyyear)

cap rm "$tab/TabC1_MI.xls"
cap rm "$tab/TabC1_MI.txt"

mi estimate,post: reg sat c.prop_sub_samerace prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year, cl(agencyyear) 
outreg2 using "$tab/TabC1_MI.xls", append dec(3) keep(c.prop_sub_samerace prop_sup_samerace)

mi estimate,post: reg sat c.prop_sub_samerace#i.minor prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year, cl(agencyyear)
outreg2 using "$tab/TabC1_MI.xls", append dec(3) keep(c.prop_sub_samerace#i.minor prop_sup_samerace)
	
mi estimate,post: reg sat c.prop_sub_samerace#i.race prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year, cl(agencyyear)
outreg2 using "$tab/TabC1_MI.xls", append dec(3) keep(c.prop_sub_samerace#i.race prop_sup_samerace)
	
mi estimate,post: reg sat c.prop_sub_samerace##c.prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year, cl(agencyyear)
outreg2 using "$tab/TabC1_MI.xls", append dec(3) keep(c.prop_sub_samerace##c.prop_sup_samerace prop_sup_samerace)
