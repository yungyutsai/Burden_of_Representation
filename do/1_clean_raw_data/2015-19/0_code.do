global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"

clear
set more off

forv i = 2015(1)2019{
	import delimited "$rdata/FedScope/`i'/September/DTagy.txt", clear

	keep agysub agysubt
	duplicates drop
	sort agysub

	save "$rdata/FedScope/FedScope`i'_code.dta", replace
}

clear

forv i = 2015(1)2019{
	ap using "$rdata/FedScope/FedScope`i'_code.dta"
}

duplicates drop
sort agysub
replace agysubt = substr(agysubt,6,.)
replace agysubt = proper(agysubt)

save "$rdata/FedScope/FedScope1519_code.dta", replace
