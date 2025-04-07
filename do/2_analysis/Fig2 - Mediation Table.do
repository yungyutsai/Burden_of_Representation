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

use "$wdata/Bootstrap_Estimations_All.dta", clear
duplicates drop

keep idn idstr eq parm est 

gen y = substr(idstr,1,strpos(idstr,",")-1)
gen model = substr(idstr,strpos(idstr,",")+1,.)
gen race = substr(parm,1,strpos(parm,".")-1) if strpos(parm,".") != 0
replace race = "1" if race == "0b"
replace race = "2" if strpos(parm,"1.minor") != 0
replace race = "1" if race == "1b"

destring race, replace
recode race . = 0

replace parm = "srsub" if strpos(parm,"prop_sub_samerace") != 0
replace parm = "srsub" if strpos(eq,"prop_sub_samerace") != 0
replace parm = "sr" if eq == "sr"
replace parm = "rc" if eq == "rc"
replace parm = "sr" if strpos(parm,"c.sr") != 0
replace parm = "rc" if strpos(parm,"c.rc") != 0

gen subgrp = substr(model,2,1)
destring subgrp, replace

replace model = substr(model,1,1)
replace model = "1" if model == "c" & parm == "srsub" & (y == "leave" | y == "sat")
replace model = "0" if model != "1"
destring model, replace

drop idstr
drop eq

rename est est_

reshape wide est, i(idn subgrp model race parm) j(y) string
reshape wide est*, i(idn subgrp model race) j(parm) string

keep subgrp idnum model race est_leaverc est_satrc est_leavesr est_satsr est_leavesrsub est_rcsrsub est_satsrsub est_srsrsub

sort subgrp idnum race model 

foreach x of varlist est*{
	by subgrp idnum: replace `x' = `x'[_n-1] if `x' == .
}

gen leave_srsub_direct = est_leavesrsub[_n+1] if model == 0
gen sat_srsub_direct = est_satsrsub[_n+1] if model == 0

drop if model == 1
drop model

sort subgrp race idnum
order subgrp race idnum

foreach y in sat leave{
	rename est_`y'srsub `y'_srsub_total
	gen `y'_sr_med = est_srsrsub * est_`y'sr
	gen `y'_rc_med = est_rcsrsub * est_`y'rc
}

keep subgrp idnum race leave_srsub_total sat_srsub_total leave_srsub_direct sat_srsub_direct sat_sr_med sat_rc_med leave_sr_med leave_rc_med
format leave_srsub_total sat_srsub_total leave_srsub_direct sat_srsub_direct sat_sr_med sat_rc_med leave_sr_med leave_rc_med %4.3f

order 	subgrp idnum race ///
		sat_srsub_direct sat_sr_med sat_rc_med sat_srsub_total ///
		leave_srsub_direct leave_sr_med leave_rc_med leave_srsub_total
		
foreach x in sat_srsub_direct sat_sr_med sat_rc_med sat_srsub_total leave_srsub_direct leave_sr_med leave_rc_med leave_srsub_total{
	gen b_`x' = `x' if idn == 0
	gen se_`x' = `x' if idn != 0
}

collapse (mean)b* (sd)se*, by(subgrp race)

tostring b* se*, format(%4.3f) replace force
tostring race, replace
replace race = "All" if race == "0"
replace race = "White" if race == "1"
replace race = "Non-White" if race == "2" & subgrp == 2
replace race = "Black" if race == "2" & subgrp == 3
replace race = "Hispanic" if race == "3"
replace race = "Asian" if race == "4"
replace race = "Others" if race == "5"

tostring subgrp, replace

set obs 9
foreach x of varlist _all{
	replace `x' = "`x'" in 9
}

sxpose, clear

order _var9
rename _var9 _var0
replace _var0 = "" in 1

gen type = 0
replace type = 1 if substr(_var0,1,1) == "b"
replace type = 2 if substr(_var0,1,1) == "s"
gen order = _n
replace order = order - 8 if type == 2

sort order type   

drop in 1

forv i = 1(1)8{
	forv j = 3(1)10{
		loc k = (`j'-2) * 2
		loc b = _var`i'[`k']
		loc se = _var`i'[`k'+1]
		loc t = abs(`b'/`se')
		if (t(1000,`t')>=0.95) replace _var`i' = _var`i' + "*" if type == 1 & order == `j'
		if (t(1000,`t')>=0.975) replace _var`i' = _var`i' + "*" if type == 1 & order == `j'
		if (t(1000,`t')>=0.99) replace _var`i' = _var`i' + "*" if type == 1 & order == `j'
	}
	replace _var`i' = "[" + _var`i' + "]" if type == 2
}

replace _var0 = "" if type == 2
