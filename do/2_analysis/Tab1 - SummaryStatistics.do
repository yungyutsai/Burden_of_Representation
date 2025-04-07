if "`c(username)'"=="yungyu"{
	global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
	global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
	global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
	global do = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/do"
	global tab = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/tab"
}
if "`c(username)'"=="ytvxq"{
	global rdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/rdata"
	global wdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/wdata"
	global log = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/log"
	global do = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/do"
	global tab = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/tab"
}

clear
set more off

use "$wdata/FEVS_FedScope_2023_Supervisor.dta", clear

foreach x in race female ageover40 tenure military{
	recode `x' 99 = .
}

replace sat = (sat_job + sat_organization) / 2
replace sr = (sr_confidence + sr_overall + sr_senior + sr_development + sr_listen + sr_respect) / 6
replace rc = rc_expected

summarystat (sr rc sat leave) (prop_sub_samerace prop_sup_samerace)(i.female i.ageover40 i.tenure i.military) , by(race) all obs(top) format(%15.2fc) pan("Individual Demographics" "Dependent/Mediation Variables" "Independent Variables") save("$tab/Tab1.dta") replace 

use "$tab/Tab1.dta", clear

export excel "$tab/Tables_v31.xlsx", sheet(Tab1, replace)
