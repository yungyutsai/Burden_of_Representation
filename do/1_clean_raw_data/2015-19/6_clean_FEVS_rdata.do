global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"

clear
set more off

forv i = 2015(1)2019{
	cap import delimited "$rdata/FEVS/FEVS`i'_PRDF_CSV/FEVS_`i'_PRDF.csv", clear
	if _rc != 0{
		import delimited "$rdata/FEVS/FEVS`i'_PRDF_CSV/`i'_OPM_FEVS_PRDF.csv", clear
	}
	
	foreach var of varlist _all{
		local lower = lower("`var'")
		rename `var' `lower'
	}
	
	gen minor = 99
	cap replace minor = 1 if dminority == "A"
	cap replace minor = 0 if dminority == "B"
	cap replace minor = 1 if dminority == 1
	cap replace minor = 0 if dminority == 2
	
	gen ageover40 = 99
	cap replace ageover40 = 0 if dagegrp == "A"
	cap replace ageover40 = 1 if dagegrp == "B" | dagegrp == "C" | dagegrp == "D"
	
	gen super = 99
	replace super = 0 if dsuper == "A"
	replace super = 1 if dsuper == "B"
	
	gen tenure = 99
	if `i'==2015{
		replace tenure = 1 if dfedten == "A" //5 or fewer years
		replace tenure = 3 if dfedten == "B" //6-14 years
		replace tenure = 5 if dfedten == "C" //15 or more years
	}
	if `i'>=2017{
		replace tenure = 2 if dfedten == "A" //10 or fewer years
		replace tenure = 4 if dfedten == "B" //10-20 years
		replace tenure = 6 if dfedten == "C" //20 or more years
	}
	
	gen female = 99
	replace female = 0 if dsex == "A"
	replace female = 1 if dsex == "B"
	
	gen military = 99
	cap replace military = 1 if dmil == "B" | dmil == "C" | dmil == "D"
	cap replace military = 0 if dmil == "A"
	
	gen education = 99
	cap replace education = 1 if deduc == "A" //Education Prior to a Bachelors Degree
	cap replace education = 2 if deduc == "B" //Bachlors Degree
	cap replace education = 3 if deduc == "C" //Post-Bachelor's Degree
	
	if (`i'==2020) rename dleavinga dleaving
	gen leaving = 99
	replace leaving = 1 if dleaving == "A"
	replace leaving = 2 if dleaving == "B"
	replace leaving = 3 if dleaving == "C"
	replace leaving = 4 if dleaving == "D"
	
	gen leave = inrange(leaving,2,4) if leaving != 99

	rename q63 sat_involve
	rename q64 sat_information
	rename q65 sat_recognition
	rename q69 sat_job
	rename q70 sat_pay
	rename q71 sat_organization
	rename q20 cr_cooperate
	rename q47 sr_development
	rename q48 sr_listen
	rename q49 sr_respect
	rename q51 sr_confidence
	rename q52 sr_overall
	rename q61 sr_senior
	rename q6  rc_expected
	rename q12 rc_agencygoal
	
	cap destring sat* cr* sr* rc*, replace force
	cap gen year = `i'
	
	cap rename plevel1 unit
	cap rename level1 unit
	replace unit = agency + "ZZ" if unit == ""
	
	keep year agency unit minor ageover40 super tenure female military education sat* leaving leave cr* sr* rc* postwt
	order year agency unit minor ageover40 super tenure female military education sat* leaving leave cr* sr* rc* postwt

save "$rdata/FEVS/FEVS`i'.dta", replace
}
