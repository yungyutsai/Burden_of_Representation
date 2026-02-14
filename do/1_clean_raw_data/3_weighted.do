if "`c(username)'"=="yungyu"{
	global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
	global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
	global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"
	global tab = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/tab"
}
if "`c(username)'"=="ytvxq"{
	global rdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/rdata"
	global wdata = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/wdata"
	global log = "/Users/ytvxq/OneDrive - University of Missouri/02 Research/FEVS/log"
}

global cov1 = "age_sub age_sup eduyr_sub eduyr_sup los_sub los_sup fulltime_sub fulltime_sup lnsalary_sub lnsalary_sup prop_sub_female prop_sup_female lnemployee_sub lnemployee_sup"
global cov2 = "diversity_sub diversity_sup"
global cov3 = "i.ageover40 i.tenure i.female i.military"

use "$wdata/FEVS_FedScope_2023_Supervisor_MI_30.dta", clear

merge m:1 year race using "$wdata/FedScope_2023_Race_FedSum.dta", nogen

cap egen nsample = count(year), by(agencyyear)
cap egen nsample_race = count(year), by(agencyyear race)
cap egen nsample_race_all = count(year), by(year race)

cap gen npop = employee1 //number of supervisor in the agency of the given year
cap gen npop_race = .
replace npop_race = employee1 * prop_sup_white if race == 1 //White
replace npop_race = employee1 * prop_sup_black if race == 2 //Black
replace npop_race = employee1 * prop_sup_hisp  if race == 3 //Hispanic
replace npop_race = employee1 * prop_sup_asian if race == 4 //Asian
replace npop_race = employee1 * prop_sup_other if race == 5 //Others

cap drop weight1 weight2 weight3 weight4 sumw1 sumw2 sumw4 sumn4
* Weight 1: Adjust for race + agency
gen weight1 = npop_race / nsample_race
egen sumw1 = sum(weight1), by(agencyyear)

* Weight 2: Only adjust for race within each agency
gen weight2 = weight1 * nsample / sumw1
egen sumw2 = sum(weight2), by(agencyyear)

* Weight 3: Adjust for race distribution for entire federal agency
gen weight3 = .
replace weight3 = TotFedRacePop / nsample_race_all

* Weight 4: Sample weight
gen weight4 = postwt
egen sumw4 = sum(weight4), by(year)
egen sumn4 = count(weight4), by(year)
replace weight4 = weight4 * sumn4 / sumw4

save "$wdata/FEVS_FedScope_2023_Supervisor_MI_30.dta", replace
