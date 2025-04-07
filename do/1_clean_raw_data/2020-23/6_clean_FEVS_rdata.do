global rdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/wdata"
global log = "/Users/yungyu/Dropbox/02 Research/PA/FEVS/log"

clear
set more off

forv i = 2020(1)2023{
	cap import delimited "$rdata/FEVS/FEVS`i'_PRDF_CSV/FEVS_`i'_PRDF.csv", clear
	if _rc != 0{
		import delimited "$rdata/FEVS/FEVS`i'_PRDF_CSV/`i'_OPM_FEVS_PRDF.csv", clear
	}
	
	foreach var of varlist _all{
		local lower = lower("`var'")
		rename `var' `lower'
	}
	
	gen race = 99
	replace race = 1 if drno == "B" //White
	replace race = 2 if drno == "A" //Black
	replace race = 4 if drno == "C" //Asian
	replace race = 5 if drno == "D" //Others
	replace race = 3 if dhisp == "A" //Hispanic
	
	gen minor = race != 1 if race != 99
	
	gen ageover40 = 99
	replace ageover40 = 0 if dagegrp == "A"
	replace ageover40 = 1 if dagegrp == "B"
	
	gen super = 99
	replace super = 0 if dsuper == "A"
	replace super = 1 if dsuper == "B"
	
	gen tenure = 99
	replace tenure = 2 if dfedten == "A" //10 or fewer years
	replace tenure = 4 if dfedten == "B" //10-20 years
	replace tenure = 6 if dfedten == "C" //20 or more years
	
	gen female = 99
	replace female = 0 if dsex == "A"
	replace female = 1 if dsex == "B"
	
	gen military = 99
	replace military = 1 if dmil == "A"
	replace military = 0 if dmil == "B"
	
	if (`i'==2020) rename dleavinga dleaving
	gen leaving = 99
	replace leaving = 1 if dleaving == "A" //No
	replace leaving = 2 if dleaving == "C" //Yes, to take another job within the Federal Government
	replace leaving = 3 if dleaving == "D" //Yes, to take another job outside the Federal Government
	replace leaving = 4 if dleaving == "B" //Yes, other

	gen leave = inrange(leaving,2,4) if leaving != 99

	if `i' == 2023{
		rename q67 sat_involve
		rename q68 sat_information
		rename q69 sat_recognition
		rename q70 sat_job
		rename q71 sat_pay
		rename q72 sat_organization
		rename q15 cr_cooperate
		rename q18 cr_share_knowledge
		rename q48 sr_development
		rename q50 sr_listen
		rename q51 sr_respect
		rename q52 sr_confidence
		rename q54 sr_overall
		rename q62 sr_senior
		rename q4  rc_expected
		rename q7  rc_agencygoal
		rename q59 rc_communicate
		rename q3  sc_accomplishment
		rename q6  sc_talent
	}
	if `i' == 2022{
		rename q65 sat_involve
		rename q66 sat_information
		rename q67 sat_recognition
		rename q68 sat_job
		rename q69 sat_pay
		rename q70 sat_organization
		rename q14 cr_cooperate
		rename q17 cr_share_knowledge
		rename q46 sr_development
		rename q48 sr_listen
		rename q49 sr_respect
		rename q50 sr_confidence
		rename q52 sr_overall
		rename q60 sr_senior
		rename q4  rc_expected
		rename q7  rc_agencygoal
		rename q57 rc_communicate
		rename q3  sc_accomplishment
		rename q6  sc_talent
	}
	if `i' == 2021{
		rename q39 sat_involve
		rename q40 sat_information
		rename q41 sat_recognition
		rename q42 sat_job
		rename q43 sat_pay
		rename q44 sat_organization
		rename q9  cr_cooperate
		rename q27 sr_development
		rename q28 sr_listen
		rename q29 sr_respect
		rename q30 sr_confidence
		rename q31 sr_overall
		rename q37 sr_senior
		rename q4  rc_expected
		rename q7  rc_agencygoal
		rename q34 rc_communicate
		rename q3  sc_accomplishment
		rename q6  sc_talent
	}
	if `i' == 2020{
		rename q33 sat_involve
		rename q34 sat_information
		rename q35 sat_recognition
		rename q36 sat_job
		rename q37 sat_pay
		rename q38 sat_organization
		rename q9  cr_cooperate
		rename q21 sr_development
		rename q22 sr_listen
		rename q23 sr_respect
		rename q24 sr_confidence
		rename q25 sr_overall
		rename q31 sr_senior
		rename q4  rc_expected
		rename q7  rc_agencygoal
		rename q28 rc_communicate
		rename q3  sc_accomplishment
		rename q6  sc_talent
	}
	
	cap destring sat* cr* sr* rc* sc*, replace force
	cap gen year = `i'
	
	keep year randomid agency race minor ageover40 super tenure female military sat* leaving leave cr* sr* rc* sc* postwt
	order year randomid agency race minor ageover40 super tenure female military sat* leaving leave cr* sr* rc* sc* postwt

save "$rdata/FEVS/FEVS`i'.dta", replace
}
