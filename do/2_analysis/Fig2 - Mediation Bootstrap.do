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

cap mkdir "$wdata/Bootstrap"

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
		replace sr = (sr_confidence + sr_overall + sr_senior + sr_development + sr_listen + sr_respect) / 6
		replace rc = rc_expected

		if `i' >= 1{
			set seed `i'
			egen cluster = group(agency race year)
			bsample, stra(cluster)
		}
		
		
		* IV -> Mediation
		foreach y in /*sr rc*/{
			reghdfe `y' prop_sub_samerace prop_sup_samerace i.race $cov, a(agency year) cl(agencyyear)
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_b1.dta", replace) idstr("`y',b1") idnum(`i')
			reghdfe `y' c.prop_sub_samerace#i.minor prop_sup_samerace $cov, a(agencyrace year) cl(agencyyear)
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_b2.dta", replace) idstr("`y',b2") idnum(`i')
			reghdfe `y' c.prop_sub_samerace#i.race prop_sup_samerace $cov, a(agencyrace year) cl(agencyyear)
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_b3.dta", replace) idstr("`y',b3") idnum(`i')
		}
		* IV -> DV
		foreach y in /*sat*/{
			reghdfe `y' prop_sub_samerace prop_sup_samerace i.race $cov, a(agency year) cl(agencyyear)
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_a1.dta", replace) idstr("`y',a1") idnum(`i')
			reghdfe `y' c.prop_sub_samerace#i.minor prop_sup_samerace $cov, a(agencyrace year) cl(agencyyear)
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_a2.dta", replace) idstr("`y',a2") idnum(`i')
			reghdfe `y' c.prop_sub_samerace#i.race prop_sup_samerace $cov, a(agencyrace year) cl(agencyyear)
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_a3.dta", replace) idstr("`y',a3") idnum(`i')
		}
		foreach y in leave{
			logit `y' prop_sub_samerace prop_sup_samerace i.race $cov i.agency_cd i.year, cl(agencyyear)
			margins, dydx(prop_sub_samerace prop_sup_samerace) post vsquish noestimcheck
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_a1.dta", replace) idstr("`y',a1") idnum(`i')
			logit `y' c.prop_sub_samerace#i.minor prop_sup_samerace $cov i.agency_cd#i.race i.year, cl(agencyyear)
			margins, dydx(prop_sub_samerace) at(minor =(0 1)) post vsquish noestimcheck
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_a2.dta", replace) idstr("`y',a2")idnum(`i')
			logit `y' c.prop_sub_samerace#i.race prop_sup_samerace $cov i.agency_cd#i.race i.year, cl(agencyyear)
			margins, dydx(prop_sub_samerace) at(race =(1 2 3 4 5)) post vsquish noestimcheck
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_a3.dta", replace) idstr("`y',a3")idnum(`i')
		}
		
		* IV -> DV | M
		foreach y in /*sat*/{
			reghdfe `y' prop_sub_samerace prop_sup_samerace i.race sr rc $cov, a(agency year) cl(agencyyear)
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_c1.dta", replace) idstr("`y',c1") idnum(`i')
			reghdfe `y' c.prop_sub_samerace#i.minor prop_sup_samerace c.sr#i.minor c.rc#i.minor $cov, a(agencyrace year) cl(agencyyear)
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_c2.dta", replace) idstr("`y',c2") idnum(`i')
			reghdfe `y' c.prop_sub_samerace#i.race prop_sup_samerace c.sr#i.race c.rc#i.race $cov, a(agencyrace year) cl(agencyyear)
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_c3.dta", replace) idstr("`y',c3") idnum(`i')
		}
		
		foreach y in leave{
			logit `y' prop_sub_samerace prop_sup_samerace i.race sr rc $cov i.agency_cd i.year, cl(agencyyear)
			margins, dydx(prop_sub_samerace prop_sup_samerace sr rc) post vsquish noestimcheck
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_c1.dta", replace) idstr("`y',c1") idnum(`i')
			logit `y' c.prop_sub_samerace#i.minor prop_sup_samerace c.sr#i.minor c.rc#i.minor $cov i.agency_cd#i.race i.year, cl(agencyyear)
			margins, dydx(prop_sub_samerace sr rc) at(minor =(0 1)) post vsquish noestimcheck
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_c2.dta", replace) idstr("`y',c2")idnum(`i')
			logit `y' c.prop_sub_samerace#i.race prop_sup_samerace c.sr#i.race c.rc#i.race $cov i.agency_cd#i.race i.year, cl(agencyyear)
			margins, dydx(prop_sub_samerace sr rc) at(race =(1 2 3 4 5)) post vsquish noestimcheck
			cap parmest , saving("$wdata/Bootstrap/Bootstrap_Mediation_`y'_c3.dta", replace) idstr("`y',c3")idnum(`i')
		}
		
		*** Append All
		clear
		local files : dir "$wdata/Bootstrap" files "Bootstrap_Mediation_*.dta" //Get data list
		foreach file in `files' {
			ap using "$wdata/Bootstrap/`file'"
		}
		gen keep = 0
		
		foreach x in sr rc{
			replace keep = 1 if parm == "`x'"
			replace keep = 1 if strpos(parm,"c.`x'")~= 0
		}
		replace keep = 1 if strpos(parm,"prop_sub_samerace")~= 0
		replace keep = 1 if strpos(parm,"_at")~= 0
		keep if keep == 1
		
		if (`i' == 0) save "$wdata/Bootstrap_Estimations_All.dta", replace
		else {
			ap using "$wdata/Bootstrap_Estimations_All.dta"
			save "$wdata/Bootstrap_Estimations_All.dta", replace
		}
	}
	}
}
