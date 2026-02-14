if "`c(username)'"=="yungyu"{
	global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
	global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
	global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
	global tab = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/tab"
}
if "`c(username)'"=="yungyu" & "`c(os)'" == "Windows"{
	global rdata = "C:/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
	global wdata = "C:/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
	global log = "C:/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
	global tab = "C:/Users/yungyu/Dropbox/02 Research/PA/FEVS/tab"
}
if "`c(username)'"=="ytvxq"{
	global rdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/rdata"
	global wdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/wdata"
	global log = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/log"
}

global cov = "i.ageover40 i.tenure i.female i.military age_sub age_sup eduyr_sub eduyr_sup los_sub los_sup fulltime_sub fulltime_sup lnsalary_sub lnsalary_sup prop_sub_female prop_sup_female lnemployee_sub lnemployee_sup diversity_sub diversity_sup"

cap mkdir "$wdata/Bootstrap TabA5"

** Bootstrap
forv i = 0(1)1000{
	if `i' == 1 {
		dis "Bootstrap (1,000)"
		dis "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
	}
	_dots `i' 0
	if `i' >= 0{
	qui{
		use "$wdata/FEVS_FedScope_2023_Supervisor.dta", clear
		replace sat = (sat_job + sat_organization) / 2

		if `i' >= 1{
			set seed `i'
			egen cluster = group(agency race year)
			bsample, stra(cluster)
		}

		foreach y in sat{
			reghdfe `y' c.prop_sub_samerace##c.prop_sup_samerace $cov, a(agencyrace year) cl(agencyyear)
			cap parmest , saving("$wdata/Bootstrap TabA5/Bootstrap_Mediation.dta", replace) idnum(`i') idstr(`y')
		}
		
		use "$wdata/Bootstrap TabA5/Bootstrap_Mediation.dta", clear
		gen keep = 0
		
		replace keep = 1 if strpos(parm,"prop_sub_samerace")~= 0
		replace keep = 1 if strpos(parm,"prop_sup_samerace")~= 0
		keep if keep == 1
		
		if (`i' == 0) save "$wdata/BootstrapTabA5_Estimations_All.dta", replace
		else {
			ap using "$wdata/BootstrapTabA5_Estimations_All.dta"
			save "$wdata/BootstrapTabA5_Estimations_All.dta", replace
		}
	}
	}
}

use "$wdata/BootstrapTabA5_Estimations_All.dta", clear

gen b = est if idn == 0
gen se = est if idn != 0

collapse (mean)b (sd)se, by(idstr parm)

gen t = b/se
tostring b se, replace format(%4.3f) force

replace b = b + "*" if (t(1000,t)>=0.95) 
replace b = b + "*" if (t(1000,t)>=0.975) 
replace b = b + "*" if (t(1000,t)>=0.99) 

