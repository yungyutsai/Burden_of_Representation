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

use "$wdata/FEVS_FedScope_2023_Supervisor_MI_30.dta", clear
cap encode agency, gen(agency_cd)

cap rm "$tab/FigA1a.xls"
cap rm "$tab/FigA1a.txt"

foreach y in sat_involve sat_information sat_recognition sat_job sat_pay sat_organization {
	mi estimate,post: reg `y' prop_sub_samerace prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year [aw=weight1], cl(agencyyear)
	outreg2 using "$tab/FigA1a.xls", append dec(3)
}


cap rm "$tab/FigA1b.xls"
cap rm "$tab/FigA1b.txt"

foreach y in sat_involve sat_information sat_recognition sat_job sat_pay sat_organization {
	mi estimate,post: reg `y' c.prop_sub_samerace#i.minor prop_sup_samerace i.race $cov1 $cov2 $cov3 i.agencyrace i.year [aw=weight1], cl(agencyyear)
	outreg2 using "$tab/FigA1b.xls", append dec(3)
}
