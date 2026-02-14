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

cap mkdir "$wdata/Bootstrap Main"

** Bootstrap
forv i = 0(1)1000{
	if `i' == 1 {
		dis "Bootstrap (1,000)"
		dis "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
	}
	_dots `i' 0
	if `i' >= 0{
	qui{
		use "$wdata/FEVS_FedScope_2023_Supervisor_MI_30.dta", clear

		if `i' >= 1{
			set seed `i'
			egen cluster = group(agency race year)
			bsample, stra(cluster)
		}
		
		
		* Main
		foreach y in sat{
			mi estimate, ni(2) post: reg `y' prop_sub_samerace prop_sup_samerace $cov i.agencyrace i.year [aw=weight1], cl(agencyyear) 
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_TabA5_`y'_a.dta", replace) idstr("a") idnum(`i')
		}
		
		* by Race
		foreach y in sat{
			mi estimate, ni(2) post: reg `y' c.prop_sub_samerace#i.race prop_sup_samerace $cov i.agencyrace i.year [aw=weight1], cl(agencyyear) 
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_TabA5_`y'_b.dta", replace) idstr("b") idnum(`i')
		}
		
		* Interaction
		foreach y in sat{
			mi estimate, ni(2) post: reg `y' c.prop_sub_samerace##c.prop_sup_samerace $cov i.agencyrace i.year [aw=weight1], cl(agencyyear) 
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_TabA5_`y'_c.dta", replace) idstr("c") idnum(`i')
		}
		
		*** Append All
		clear
		local files : dir "$wdata/Bootstrap" files "Bootstrap_TabA5_*.dta" //Get data list
		foreach file in `files' {
			ap using "$wdata/Bootstrap/`file'"
		}
		gen keep = 0
		
		foreach x in sr rc{
			replace keep = 1 if parm == "`x'"
			replace keep = 1 if strpos(parm,"c.`x'")~= 0
		}
		replace keep = 1 if strpos(parm,"prop_sub_samerace")~= 0
		replace keep = 1 if strpos(parm,"prop_sup_samerace")~= 0
		replace keep = 1 if strpos(parm,"_at")~= 0
		keep if keep == 1
		
		if (`i' == 0) save "$wdata/Bootstrap_Estimations_TabA5_All.dta", replace
		else {
			ap using "$wdata/Bootstrap_Estimations_TabA5_All.dta"
			save "$wdata/Bootstrap_Estimations_TabA5_All.dta", replace
		}
	}
	}
}

use "$wdata/Bootstrap_Estimations_TabA5_All.dta", clear

gen b = est if idn == 0
gen se = est if idn != 0

collapse (mean)b (sd)se, by(idstr parm)

gen t = b/se
tostring b se, replace format(%4.3f) force

replace b = b + "*" if (t(1000,t)>=0.95) 
replace b = b + "*" if (t(1000,t)>=0.975) 
replace b = b + "*" if (t(1000,t)>=0.99) 

