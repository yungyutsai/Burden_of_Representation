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

cap rm "$tab/Tab3.xls"
cap rm "$tab/Tab3.txt"
cap rm "$tab/Fig2.xls"
cap rm "$tab/Fig2.txt"

replace sat = (sat_job + sat_organization) / 2
replace sr = (sr_confidence + sr_overall + sr_senior + sr_development + sr_listen + sr_respect) / 6
replace rc = rc_expected
		
foreach y in sat rc sr{
		
	reghdfe `y' c.prop_sub_samerace##c.prop_sup_samerace $cov1 $cov2 $cov3, a(agencyrace year) cl(agencyyear)
	outreg2 using "$tab/Tab3.xls", append dec(3) keep(c.prop_sub_samerace##c.prop_sup_samerace)
	
	margins, dydx(prop_sub_samerace) at(prop_sup_samerace =(0(0.1)1)) post vsquish noestimcheck
	outreg2 using "$tab/Fig2.xls", append dec(3)
}

gen interaction = prop_sub_samerace*prop_sup_samerace

foreach y in leave{
	logit `y' prop_sub_samerace prop_sup_samerace interaction i.agency_cd#i.race i.year, cl(agencyyear)
	margins, dydx(prop_sub_samerace prop_sup_samerace interaction) post vsquish noestimcheck
	outreg2 using "$tab/Tab3.xls", append dec(3) 
	
	logit `y' prop_sub_samerace prop_sup_samerace interaction $cov1 i.agency_cd#i.race i.year, cl(agencyyear)
	margins, dydx(prop_sub_samerace prop_sup_samerace interaction) post vsquish noestimcheck
	outreg2 using "$tab/Tab3.xls", append dec(3)
	
	logit `y' prop_sub_samerace prop_sup_samerace interaction $cov1 $cov2 i.agency_cd#i.race i.year, cl(agencyyear)
	margins, dydx(prop_sub_samerace prop_sup_samerace interaction) post vsquish noestimcheck
	outreg2 using "$tab/Tab3.xls", append dec(3)
	
	logit `y' prop_sub_samerace prop_sup_samerace interaction $cov1 $cov2 $cov3 i.agency_cd#i.race i.year, cl(agencyyear)
	margins, dydx(prop_sub_samerace prop_sup_samerace interaction) post vsquish noestimcheck
	outreg2 using "$tab/Tab3.xls", append dec(3)
	
	logit `y' c.prop_sub_samerace##c.prop_sup_samerace $cov1 $cov2 $cov3 i.agency_cd#i.race i.year, cl(agencyyear)
	margins, dydx(prop_sub_samerace) at(prop_sup_samerace =(0(0.1)1)) post vsquish noestimcheck
	outreg2 using "$tab/Fig2.xls", append dec(3)
}
