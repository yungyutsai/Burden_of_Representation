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

cap rm "$tab/Tab3.xls"
cap rm "$tab/Tab3.txt"
cap rm "$tab/Fig3.xls"
cap rm "$tab/Fig3.txt"
		
foreach y in sat rc sr{	
	mi estimate,post: reg `y' c.prop_sub_samerace##c.prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year [aw=weight1], cl(agencyyear) 
	outreg2 using "$tab/Tab3.xls", append dec(3) keep(c.prop_sub_samerace##c.prop_sup_samerace)
	
	mimrgns, dydx(prop_sub_samerace) at(prop_sup_samerace =(0(0.1)1)) post vsquish noestimcheck
	outreg2 using "$tab/Fig3.xls", append dec(3)
}

cap program drop emargins
program emargins , eclass properties(mi)
reg `y' c.prop_sub_samerace##c.prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year [aw=weight1], cl(agencyyear)
margins, dydx(prop_sub_samerace) at(prop_sup_samerace =(0(0.1)1)) post vsquish noestimcheck
end

mi estimate : emargins whatever
