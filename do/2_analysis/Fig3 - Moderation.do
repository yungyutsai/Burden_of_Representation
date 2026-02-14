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

clear
set more off
 
import delimited using "$tab/Fig3.txt", clear
drop v1

keep in 4/25
gen x = (ceil(_n/2)-1)/10
gen type = mod(_n,2)

rename v2 estsat
rename v3 estrc
rename v4 estsr

foreach x in sat rc sr {
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

foreach x in sat {
	twoway 	(sc b x if model == "`x'", mc(navy)) ///
			(rcap upper lower x if model == "`x'", lc(navy)), ///
			scheme(s1color) legend(off) ///
			xlabel(0(0.1)1, format(%4.1f)) xscale(ra(-0.02 1.02)) ///
			yline(0, lc(black)) ylabel(, angle(0) format(%4.0f)) ///
			xtitle("Proportion of Same-race Colleagues") ///
			ytitle(Marginal Effect of Same-race Subordinates)
	graph export "$fig/Fig3_`x'.png", as(png) replace
}
