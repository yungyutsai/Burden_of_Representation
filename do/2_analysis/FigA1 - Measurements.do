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

global cov1 = "i.ageover40 i.tenure i.female i.military"
global cov2 = "age_sub age_sup eduyr_sub eduyr_sup los_sub los_sup fulltime_sub fulltime_sup lnsalary_sub lnsalary_sup prop_sub_female prop_sup_female lnemployee_sub lnemployee_sup diversity_sub diversity_sup"

use "$wdata/FEVS_FedScope_2023_Supervisor.dta", clear
encode agency, gen(agency_cd)

cap rm "$tab/FigA1.xls"
cap rm "$tab/FigA1.txt"

foreach y in sat_involve sat_information sat_recognition sat_job sat_pay sat_organization /*sr_development sr_listen sr_respect sr_confidence sr_overall sr_senior rc_expected rc_agencygoal*/{
	reghdfe `y' prop_sub_samerace prop_sup_samerace $cov1 $cov2, a(agencyrace year) cl(agencyyear)
	outreg2 using "$tab/FigA1.xls", append dec(3)
}


cap rm "$tab/FigA2.xls"
cap rm "$tab/FigA2.txt"

foreach y in sat_involve sat_information sat_recognition sat_job sat_pay sat_organization sr_development sr_listen sr_respect sr_confidence sr_overall sr_senior rc_expected rc_agencygoal{
	reghdfe `y' c.prop_sub_samerace#i.minor prop_sup_samerace i.race $cov1 $cov2, a(agencyrace year) cl(agencyyear)
	outreg2 using "$tab/FigA2.xls", append dec(3)
}
