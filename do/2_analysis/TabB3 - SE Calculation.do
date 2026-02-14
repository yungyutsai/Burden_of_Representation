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

egen agencyyearrace = group(agencyyear race)

cap rm "$tab/TabA5.xls"
cap rm "$tab/TabA5.txt"

foreach y in sat {
foreach x in "agency" "year" "agencyrace" "agencyyearrace"{
	
	mi estimate,post: reg `y' c.prop_sub_samerace prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year [aw=weight1], cl(`x') 
	outreg2 using "$tab/TabA5.xls", append dec(3)

	mi estimate,post: reg `y' c.prop_sub_samerace#i.minor prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year [aw=weight1], cl(`x') 
	outreg2 using "$tab/TabA5.xls", append dec(3)
	
	mi estimate,post: reg `y' c.prop_sub_samerace#i.race prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year [aw=weight1], cl(`x') 
	outreg2 using "$tab/TabA5.xls", append dec(3)
	
	mi estimate,post: reg `y' c.prop_sub_samerace##c.prop_sup_samerace $cov1 $cov2 $cov3 i.agencyrace i.year [aw=weight1], cl(`x') 
	outreg2 using "$tab/TabA5.xls", append dec(3)
	
}
}


cap program drop postmlm
program define postmlm
	estat icc
	estadd scalar icc2 = r(icc2)
	estat ic
	matrix s = r(S)
	estadd scalar aic =  s[1,5]
	estadd scalar bic =  s[1,6]
end

eststo clear


mi estimate, ni(2) post: mixed sat prop_sub_samerace prop_sup_samerace $cov1 $cov2 $cov3 i.year i.race#i.agency_cd || agencyyear:
*postmlm
eststo mlm1

mi estimate, ni(2) post: mixed sat c.prop_sub_samerace#i.minor prop_sup_samerace $cov1 $cov2 $cov3 i.year i.race#i.agency_cd || agencyyear:
*postmlm
eststo mlm2

mi estimate, ni(2) post: mixed sat c.prop_sub_samerace#i.race prop_sup_samerace $cov1 $cov2 $cov3 i.year i.race#i.agency_cd || agencyyear:
*postmlm
eststo mlm3

mi estimate, ni(2) post: mixed sat c.prop_sub_samerace##c.prop_sup_samerace $cov1 $cov2 $cov3 i.year i.race#i.agency_cd || agencyyear:
*postmlm
eststo mlm4


esttab 	using "$wdata/TabA5_MI2.txt", replace ///
		se transform(ln*: exp(@)^2 2*exp(@)^2) ///
		eqlabels(""  "var(_cons)" "var(Residual)", none) ///
		varlabels(,elist(weight:_cons "{break}{hline @width}")) ///
		varwidth(13) b(%9.3f) se(%9.3f) ///
		stats(N icc2 aic bic, fmt(%15.0fc %9.3f %15.0fc %15.0fc))
		
esttab 	using "$wdata/TabA5_MI2.csv", replace ///
		se transform(ln*: exp(@)^2 2*exp(@)^2) ///
		eqlabels(""  "var(_cons)" "var(Residual)", none) ///
		varlabels(,elist(weight:_cons "{break}{hline @width}")) ///
		varwidth(13) b(%9.3f) se(%9.3f) ///
		stats(N icc2 aic bic, fmt(%15.0fc %9.3f %15.0fc %15.0fc))
