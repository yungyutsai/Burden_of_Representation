if "`c(username)'"=="yungyu"{
	global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
	global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
	global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
	global tab = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/tab"
}
if "`c(username)'"=="ytvxq"{
	global rdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/rdata"
	global wdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/wdata"
	global log = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/log"
}

global cov1 = "i.ageover40 i.tenure i.female i.military i.education"
global cov2 = "age_sub age_sup eduyr_sub eduyr_sup los_sub los_sup fulltime_sub fulltime_sup lnsalary_sub lnsalary_sup prop_sub_female prop_sup_female lnemployee_sub lnemployee_sup diversity_sub diversity_sup"

use "$wdata/FEVS_FedScope_1519_Supervisor.dta", clear
encode unit, gen(unit_cd)
encode agency, gen(agency_cd)
egen agencyrace = group(agency minor)

replace sat = (sat_job + sat_organization) / 2
replace sr = (sr_confidence + sr_overall + sr_senior + sr_development + sr_listen + sr_respect) / 6
replace rc = rc_expected

cap rm "$tab/TabA4.xls"
cap rm "$tab/TabA4.txt"

foreach y in sat rc sr{
	reghdfe `y' unit_prop_sub_samerace unit_prop_sup_samerace $cov1 $cov2, a(agencyrace year) cl(unityear)
	outreg2 using "$tab/TabA4.xls", append dec(3) keep(unit_prop_sub_samerace unit_prop_sup_samerace)

	/*
	reghdfe `y' c.unit_prop_sub_samerace#i.minor c.unit_prop_sup_samerace $cov1 $cov2, a(agencyrace year) cl(unityear)
	outreg2 using "$tab/TabA4.xls", append dec(3) keep(c.unit_prop_sub_samerace#i.minor unit_prop_sup_samerace)

	
	reghdfe `y' c.unit_prop_sub_samerace##c.unit_prop_sup_samerace i.minor $cov1 $cov2, a(unitrace year) cl(unityear)
	outreg2 using "$tab/TabA4.xls", append dec(3) keep(c.unit_prop_sub_samerace##c.unit_prop_sup_samerace)
	*/
}

