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

global cov1 = "age_sub age_sup eduyr_sub eduyr_sup los_sub los_sup fulltime_sub fulltime_sup lnsalary_sub lnsalary_sup prop_sub_female prop_sup_female lnemployee_sub lnemployee_sup"
global cov2 = "diversity_sub diversity_sup"
global cov3 = "i.ageover40 i.tenure i.female i.military"

use "$wdata/FEVS_FedScope_2023_Supervisor.dta", clear

cap rm "$tab/Fig2.xls"
cap rm "$tab/Fig2.txt"

replace sat = (sat_job + sat_organization) / 2
replace sr = (sr_confidence + sr_overall + sr_senior + sr_development + sr_listen + sr_respect) / 5
replace rc = rc_expected

foreach y in sr rc sat{
	reghdfe `y' prop_sub_samerace prop_sup_samerace i.race $cov1 $cov2 $cov3, a(agency year) cl(agencyyear) 
	outreg2 using "$tab/Fig2.xls", append dec(3) keep(prop_sub_samerace)
}
	
foreach y in sat{
	reghdfe `y' prop_sub_samerace prop_sup_samerace sr rc i.race $cov1 $cov2 $cov3, a(agency year) cl(agencyyear) 
	outreg2 using "$tab/Fig2.xls", append dec(3) keep(prop_sub_samerace sr rc)
}

**
	
foreach y in sr rc sat{
	reghdfe `y' c.prop_sub_samerace#i.minor prop_sup_samerace $cov1 $cov2 $cov3, a(agencyrace year) cl(agencyyear) 
	outreg2 using "$tab/Fig2.xls", append dec(3) keep(c.prop_sub_samerace#i.minor)
}
	
foreach y in sat{
	reghdfe `y' c.prop_sub_samerace#i.minor prop_sup_samerace c.sr#i.minor c.rc#i.minor $cov1 $cov2 $cov3, a(agencyrace year) cl(agencyyear) 
	outreg2 using "$tab/Fig2.xls", append dec(3) keep(c.prop_sub_samerace#i.minor c.sr#i.minor c.rc#i.minor)
}


**
		
foreach y in sr rc sat{
	reghdfe `y' c.prop_sub_samerace#i.race prop_sup_samerace $cov1 $cov2 $cov3, a(agencyrace year) cl(agencyyear) 
	outreg2 using "$tab/Fig2.xls", append dec(3) keep(c.prop_sub_samerace#i.race)
}
	
foreach y in sat{
	reghdfe `y' c.prop_sub_samerace#i.race prop_sup_samerace c.sr#i.race c.rc#i.race $cov1 $cov2 $cov3, a(agencyrace year) cl(agencyyear) 
	outreg2 using "$tab/Fig2.xls", append dec(3) keep(c.prop_sub_samerace#i.race c.sr#i.race c.rc#i.race)
}
