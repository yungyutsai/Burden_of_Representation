if "`c(username)'"=="yungyu"{
	global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
	global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
	global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
	global do = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/do"
	global tab = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/tab"
	global fig = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/fig"
}
if "`c(username)'"=="ytvxq"{
	global rdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/rdata"
	global wdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/wdata"
	global log = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/log"
	global do = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/do"
	global tab = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/tab"
	global fig = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/fig"
}

clear
set more off
 
import delimited using "$tab/FigA1a.txt", clear

keep v2-v7

keep in 2/5
drop in 2

gen type = mod(_n,3)
recode type 0=3

reshape long v, i(type) j(var)
replace var = var-1

foreach x in v{
	replace `x' = subinstr(`x',"*","",.)
	replace `x' = subinstr(`x',"(","",.)
	replace `x' = subinstr(`x',")","",.)
}

reshape wide v, i(var) j(type)
rename v1 dv
rename v2 b
rename v3 se
destring b se, replace
gen upper = b + 1.96 * se
gen lower = b - 1.96 * se

gen label = ""
replace label = "Involvement in decisions" if var == 1
replace label = "Information received from management" if var == 2
replace label = "Recognition received for doing a good job" if var == 3
replace label = "Overall with job" if var == 4
replace label = "Overall with pay" if var == 5
replace label = "Overall with organization" if var == 6

replace label = "Supervisor support employee development" if var == 7
replace label = "Supervisor listens to what I have to say" if var == 8
replace label = "Supervisor treats me with respect" if var == 9
replace label = "Have trust and confidence in supervisor" if var == 10
replace label = "Overall Evaluation on immediate supervisor" if var == 11
replace label = "Respect for organization's senior leaders" if var == 12

replace label = "Clarity on expectation of job" if var == 13
replace label = "Clarity on work relates agency goals" if var == 14


replace var = var + 9 if inrange(var,7,12)
replace var = var - 5 if var > 12

gen placey = var + 0.1
gen placex = lower + 0.005
gen placex2 = lower - 0.005

twoway 	(sc var b if var <= 6, mc(navy)) ///
		(rcap upper lower var if var <= 6, lc(navy) hori), ///
		scheme(s1color) legend(off) ///
		xlabel(, format(%4.1f)) xline(0, lc(black) lp(dash))  ///
		yscale(ra(0.5 6.5)) ///
		xtitle("Effect of % Same-race Subordinates") ///
		ytitle("Satisfaction on:") ///
		ylabel(	1 "Involvement in decisions" ///
				2 "Information received" ///
				3 "Recognition received" ///
				4 "Overall with job" ///
				5 "Overall with pay" ///
				6 "Overall with organization", angle(0) labsize(small))
graph export "$fig/FigA1_Sat.png", as(png) replace


***************************


import delimited using "$tab/FigA1b.txt", clear

keep v2-v7

keep in 2/7
drop in 2

gen type = mod(_n,5)
recode type 0=5

reshape long v, i(type) j(var)
replace var = var-1

foreach x in v{
	replace `x' = subinstr(`x',"*","",.)
	replace `x' = subinstr(`x',"(","",.)
	replace `x' = subinstr(`x',")","",.)
}

reshape wide v, i(var) j(type)
rename v1 dv
rename v2 b1
rename v3 se1
rename v4 b2
rename v5 se2
destring b* se*, replace
forv i = 1(1)2{
	gen upper`i' = b`i' + 1.96 * se`i'
	gen lower`i' = b`i' - 1.96 * se`i'
}

gen label = ""
replace label = "Involvement in decisions" if var == 1
replace label = "Information received from management" if var == 2
replace label = "Recognition received for doing a good job" if var == 3
replace label = "Overall with job" if var == 4
replace label = "Overall with pay" if var == 5
replace label = "Overall with organization" if var == 6


replace var = var + 9 if inrange(var,7,12)
replace var = var - 5 if var > 12

gen placey1 = var + 0.1
gen placey2 = var - 0.1

gen placex = lower2 + 0.005
gen placex2 = lower2 - 0.005

twoway 	(sc placey1 b1 if var <= 6, mc(navy)) ///
		(sc placey2 b2 if var <= 6, mc(maroon) ms(Sh)) ///
		(rcap upper1 lower1 placey1 if var <= 6, lc(navy) hori) ///
		(rcap upper2 lower2 placey2 if var <= 6, lc(maroon) hori lp(dash)) ///
		(connect placey1 b1 if var ==0, mc(navy)) ///
		(connect placey1 b1 if var ==0, mc(maroon) ms(Sh)), ///
		scheme(s1color) ///
		xlabel(-8(2)4, format(%4.0f)) xline(0, lc(black) lp(dash))  ///
		yscale(ra(0.5 6.5)) ///
		xtitle("Effect of % Same-race Subordinates") ///
		ytitle("Satisfaction on:") legend(order(5 "White" 6 "non-White")) ///
		ylabel(	1 "Involvement in decisions" ///
				2 "Information received" ///
				3 "Recognition received" ///
				4 "Overall with job" ///
				5 "Overall with pay" ///
				6 "Overall with organization", angle(0) labsize(small))
graph export "$fig/FigA2_Sat.png", as(png) replace
