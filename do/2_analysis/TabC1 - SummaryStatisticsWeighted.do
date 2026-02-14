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

use "$wdata/FEVS_FedScope_2023_Supervisor_MI_30.dta", clear

foreach x in race female ageover40 tenure military{
	recode `x' 99 = .
}

egen sat0 = rowmean(_*_sat)
egen sr0  = rowmean(_*_sr)
egen rc0  = rowmean(_*_rc)

mi unset

gen weight5=1
forv i = 1(1)5{
	summarystat (i.race) [aw=weight`i'], format(%15.3fc) stat(mean) save("$tab/Tab1_weighted`i'.dta") replace 
}

clear
forv i = 5(-1)1{
	use "$tab/Tab1_weighted`i'.dta",clear
	rename v2 weighted`i'
	if (`i'<5) merge 1:1 _n using "$tab/TabB1_weighted.dta", nogen
	save "$tab/TabB1_weighted.dta",replace
}

export excel "$tab/TabB1.xlsx", replace
