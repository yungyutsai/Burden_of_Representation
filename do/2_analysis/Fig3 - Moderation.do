if "`c(username)'"=="yungyu"{
	global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
	global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
	global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
	global tab = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/tab"
	global fig = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/fig"
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

cap rm "$tab/Fig3.xls"
cap rm "$tab/Fig3.txt"

replace sat = (sat_job + sat_organization) / 2
replace sr = (sr_confidence + sr_overall + sr_senior + sr_development + sr_listen + sr_respect) / 6
replace rc = rc_expected

foreach y in sat{
	
	reghdfe `y' c.prop_sub_samerace##c.prop_sup_samerace $cov1 $cov2 $cov3, a(agencyrace year) cl(agencyyear)
	margins, dydx(prop_sub_samerace) at(prop_sup_samerace =(0(0.1)1)) post vsquish noestimcheck
	outreg2 using "$tab/Fig3.xls", append dec(3)
}

foreach y in leave{
	logit `y' c.prop_sub_samerace##c.prop_sup_samerace $cov1 $cov2 $cov3 i.agency_cd#i.race i.year, cl(agencyyear)
	margins, dydx(prop_sub_samerace) at(prop_sup_samerace =(0(0.1)1)) post vsquish noestimcheck
	outreg2 using "$tab/Fig3.xls", append dec(3)
}

foreach y in rc sr{
	
	reghdfe `y' c.prop_sub_samerace##c.prop_sup_samerace $cov1 $cov2 $cov3, a(agencyrace year) cl(agencyyear)
	margins, dydx(prop_sub_samerace) at(prop_sup_samerace =(0(0.1)1)) post vsquish noestimcheck
	outreg2 using "$tab/Fig3.xls", append dec(3)
}




clear
set more off
 
import delimited using "$tab/Fig3.txt", clear
drop v1

keep in 4/25
gen x = (ceil(_n/2)-1)/10
gen type = mod(_n,2)

rename v2 estsat
rename v3 estleave
rename v4 estrc
rename v5 estsr

foreach x in sat leave rc sr{
	replace est`x' = subinstr(est`x',"*","",.)
	replace est`x' = subinstr(est`x',"(","",.)
	replace est`x' = subinstr(est`x',")","",.)
	destring est`x', replace
}

reshape long est, i(x type) j(model) string
reshape wide est, i(x model) j(type)
rename est1 b
rename est0 se
gen upper = b + 1.96 * se
gen lower = b - 1.96 * se

foreach x in sat leave rc sr{
	twoway 	(sc b x if model == "`x'", mc(navy)) ///
			(rcap upper lower x if model == "`x'", lc(navy)), ///
			scheme(s1color) legend(off) ///
			xlabel(0(0.1)1, format(%4.1f)) xscale(ra(-0.02 1.02)) ///
			yline(0, lc(black)) ylabel(, angle(0) format(%4.0f)) ///
			xtitle("Proportion of Same-race Colleagues") ///
			ytitle(Marginal Effect of Same-race Subordinates)
	graph export "$fig/Fig3_`x'.png", as(png) replace
}
