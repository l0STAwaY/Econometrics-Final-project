
cd "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original dataset" 
use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original dataset/nhis_first_original"



// This is one way to output but its not stata jornal latex format so I don't know how to compile the out put so I just typed everything in latex instead
// describe
// sjlog using "nhis_first_original.dta"
// misstable summarize
// sjlog close
// sjlog type nhis_first_original.dta.log.tex
//
//




**# Bookmark #6
//-------------------Merge data----------------------//


// we can do all this in the working data set now
cd "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset" 
use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/HealthCon_additional.dta"
use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/Medicaid_care_16_18"

drop missing_var
// https://nhis.ipums.org/nhis/userNotes_links.shtml. adding new variables that I wanted to include this https://nhis.ipums.org/nhis/userNotes_links.shtml


// merge for working data then I copy a sample to original merged data
merge 1:1 year nhispid using "HealthCon_additional.dta"
merge 1:1 year nhispid using "Medicaid_care_16_18.dta", generate(_merge_MC1618)
merge 1:1 year nhispid using "Auxilarydata_001_original.dta", generate(_merge_aux001)
merge 1:1 year nhispid using "Extra_medicaid_original.dta", generate(_merge_medicaid)






**# Bookmark #7

//--------Now the data is fully merged------------//

use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original datset/nhis_fully_merged_original.dta"
describe



// Drop all values recorded as niu for dvint and earnings, as these are
// unrecorded. 
// drop data NIU
//289,322  --> 94,587     58 varaible
drop if dvint == 0 | earnings == 0 | educ == 0 | poverty == 98 | himedicaidyr == 0 |   gotwelf == 0 | wormedbill  == 0 



drop if mcareprob == 0 & age >= 65



// Age sex and racenew   are in all data


// himcaid is useless  since cetagory is  NIU, Not mentioned, Mentioned, Unknown-refused, Unknown-not ascertained, Unknown-don't know

// no health bechase it dodesnt haven niu

tabulate dvint
tabulate earnings


//Drop a year value from 2019//
drop if year == 2019

misstable summarize 
describe 







**# Bookmark #2
//--------------------------Creating data table for original data----------------------------------//
//---- output summary static and data desrption for the unmerged data------//

ssc install estout
ssc install descsave


//summary output

eststo clear
estpost summarize *
esttab using "original_data_summary.txt", cells(" count() mean()  sd()  min()  max()") label replace

// Desribe output
descsave, saving("original_data_description.dta") 


use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original dataset/original_data_description.dta"
//open and output the file
outsheet using "original_data_description.txt", replace





use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original dataset/nhis_first_original_merged"





descsave, saving("merged_data_description.dta") 



**# Bookmark #3

//----------------------------------output for merged data--------------------------------------------//

use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original dataset/nhis_fully_merged_original.dta"



// summary
eststo clear
estpost summarize *
esttab using "merged_data_summary.txt", cells(" count() mean()  sd()  min()  max()") label replace



//describe

descsave, saving("merged_data_description.dta") 

use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original dataset/merged_data_description.dta"

outsheet using "merged_data_description.txt", replace









**# Bookmark #4

//------------------------------MISSING DATA Funciton---------------------------------//
//Learning about missing data for merged and unmerged//
use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/nhis_first_working.dta"   

misstable summarize

tabulate age

//Reported hhweight, fmx, px, perweight, fweight, pooryn, earnings, and pclookhelyr.      px and fm are label for identificaltion. That is labelwithin a family and person they do not need tobe data, 
foreach var of varlist * {
    display "`var'"  // Display the variable name
    

    * Count missing values
    quietly count if missing(`var')  
    display "Missing: " r(N)  // Display the count of missing values
}



// drop if dvint ==  000



//     Record results looks good since the missing data are all those from 2019 mostly
//
//     Result                      Number of obs
//     -----------------------------------------
//     Not matched                        41,190
//         from master                    41,190  (_merge==1)
//         from using                          0  (_merge==2)
//
//     Matched                           248,132  (_merge==3)
//     -----------------------------------------


// around half the data is niu

//
// Generate new data for these two variables to transferin-
// terval to average.

tabulate hospnght  

tabulate dvint if year == 2016 | year ==2017 |year== 2018


//--------------------------------Check for missing data now that we dropped--------------------------------------------------//




misstable summarize

// there is no missing data left for both merged and original data since all missing are from 2019 but we still need to deal with NIU unkown cases where many could be treated as missing



///----------------------------Dealing with data that are Unkown or marked as unobserved------------------------------------------------//describe
use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/nhis_fully_merged.dta"     // The fully merged is the one that I am using
describe

gen impute_dvint = dvint
gen impute_earnings = earnings
gen impute_health = health
gen impute_educ = educ
gen impute_poverty = poverty
gen impute_himedicaidyr = himedicaidyr
gen impute_gotwelf = gotwelf
gen impute_wormedbill = wormedbill 
gen impute_mcareprob = mcareprob if age>=65








summarize dvint
summarize impute_dvint

summarize earnings

summarize impute_earnings

summarize health
summarize impute_health 



summarize educ
summarize impute_educ

summarize poverty
summarize impute_poverty


summarize himedicaidyr
summarize impute_himedicaidyr 

summarize gotwelf
summarize impute_gotwelf

summarize wormedbill 
summarize impute_wormedbill 

// we don't need to impute the remianing niu case since their age is less than 65

summarize mcareprob
summarize impute_mcareprob










* Handle cases for missing or unrecognized categories
replace impute_dvint = .  if dvint == 997  
replace impute_dvint = .  if dvint == 998
replace impute_dvint = .  if  dvint == 999 



replace impute_earnings = . if earnings== 97 
replace impute_earnings = . if  earnings == 98 
replace impute_earnings = . if  earnings == 99



replace impute_health = . if  health == 7
replace impute_health  = . if  health == 8
replace impute_health  = . if  health == 9


replace impute_educ = . if  educ == 997
replace impute_educ  = . if  educ == 998
replace impute_educ  = . if  health == 999



replace impute_poverty = . if  poverty == 99


replace impute_himedicaidyr =. if himedicaidyr == 7
replace impute_himedicaidyr =. if himedicaidyr == 9


replace impute_gotwelf =. if gotwelf == 70
replace impute_gotwelf =. if gotwelf == 80
replace impute_gotwelf =. if gotwelf == 90

replace impute_wormedbill =. if wormedbill == 7
replace impute_wormedbill =. if wormedbill == 8
replace impute_wormedbill =. if wormedbill == 9


replace impute_mcareprob =. if mcareprob == 7
replace impute_mcareprob =. if mcareprob == 8
replace impute_mcareprob =. if mcareprob == 9


misstable summarize

// Create missing data indicators
gen missing_dvint = missing(impute_dvint)
gen missing_earnings = missing(impute_earnings)
gen missing_health = missing(impute_health)
gen missing_educ = missing(impute_educ)
gen missing_poverty = missing(impute_poverty)
gen missing_himedicaidyr = missing(impute_himedicaidyr)
gen missing_gotwelf = missing(impute_gotwelf)
gen missing_wormedbill = missing(impute_wormedbill)
gen missing_mcareprob = missing(impute_mcareprob)

// Label variables for clarity
label variable missing_dvint "Missing indicator for dvint"
label variable missing_earnings "Missing indicator for earnings"
label variable missing_health "Missing indicator for health"
label variable missing_educ "Missing indicator for educ"
label variable missing_poverty "Missing indicator for poverty"
label variable missing_himedicaidyr "Missing indicator for himedicaidyr"
label variable missing_gotwelf "Missing indicator for gotwelf"
label variable missing_wormedbill "Missing indicator for wormedbill"
label variable missing_mcareprob "Missing indicator for mcareprob"

describe



// analyse missing data






//----------------------Data imputation using ologit------------------------------//

use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/nhis_fully_merged.dta"     // The fully merged is the one that I am using
// if the mcartest tell us we fail to reject null hypthesis that the data is MAC, we can say droping the variable would be ok since all missing data are purely random

mcartest impute_dvint impute_earnings impute_health impute_educ impute_poverty impute_himedicaidyr impute_gotwelf impute_wormedbill age sex racenew  


// determine order of imputation //
// I realize I can use misstable afterwards

misstable summarize
// Tabulate missing data for each variable 
tabulate missing_dvint
tabulate missing_earnings
tabulate missing_health
tabulate missing_educ
tabulate missing_poverty
tabulate missing_himedicaidyr
tabulate missing_gotwelf
tabulate missing_wormedbill
tabulate missing_mcareprob if age >= 65





tabulate missing_educ impute_earnings


// missing mechanic test






* Logistic regression for missing_earnings 
logistic missing_earnings impute_dvint impute_health impute_educ impute_poverty impute_himedicaidyr impute_gotwelf impute_wormedbill age sex racenew
estimates store reg_missing_earnings

* Logistic regression for missing_health 
logistic missing_health impute_dvint impute_earnings impute_educ impute_poverty impute_himedicaidyr impute_gotwelf impute_wormedbill  age sex racenew
estimates store reg_missing_health

* Logistic regression for missing_dvint 
logistic missing_dvint impute_health impute_earnings impute_educ impute_poverty impute_himedicaidyr impute_gotwelf impute_wormedbill age sex racenew
estimates store reg_missing_dvint


//

* Logistic regression for missing_educ 
logistic missing_educ impute_dvint impute_health impute_poverty impute_himedicaidyr impute_gotwelf impute_wormedbill  age sex racenew
estimates store reg_missing_educ

* Logistic regression for missing_poverty 
logistic missing_poverty impute_dvint impute_earnings impute_health impute_educ impute_himedicaidyr impute_gotwelf impute_wormedbill  age sex racenew
estimates store reg_missing_poverty

* Logistic regression for missing_himedicaidyr 
logistic missing_himedicaidyr impute_dvint impute_earnings impute_health impute_educ impute_poverty impute_gotwelf impute_wormedbill age sex racenew
estimates store reg_missing_himedicaidyr



* Logistic regression for missing_gotwelf 
logistic missing_gotwelf impute_dvint impute_health impute_educ impute_poverty impute_himedicaidyr impute_wormedbill age sex racenew
estimates store reg_missing_gotwelf

* Logistic regression for missing_wormedbill 
logistic missing_wormedbill impute_dvint impute_earnings impute_health impute_educ impute_poverty impute_himedicaidyr impute_gotwelf age sex racenew
estimates store reg_missing_wormedbill




* Missingness results to a text file including R-squared
esttab reg_missing_earnings reg_missing_health reg_missing_dvint reg_missing_poverty reg_missing_himedicaidyr reg_missing_wormedbill using missingness_test_finalllll.txt, replace eform stat(r2_p se p)




// chi idnependence test


local vars impute_dvint impute_earnings impute_health impute_educ impute_poverty impute_himedicaidyr impute_gotwelf impute_wormedbill impute_mcareprob


log using "chi2_results_final.txt", replace text

* Assuming 'vars' is a local macro that contains the list of variable names
foreach var1 of local vars {
    foreach var2 of local vars {
        * Avoid redundant pairs (e.g., impute_dvint vs impute_dvint)
        if "`var1'" < "`var2'" {
            * Perform the chi2 test
            display "Performing chi2 test on `var1' and `var2'"
            tabulate `var1' `var2', chi2

            * Log chi-squared statistic and p-value
            display "Chi-squared: " r(chi2) ", p-value: " r(p)
        }
    }
}



log close

// if it doesn't work then put it in the command line along with local, likly the for each loop is not seeing the local variable

local vars impute_dvint impute_earnings impute_health impute_educ impute_poverty impute_himedicaidyr impute_gotwelf impute_wormedbill impute_mcareprob

log using "chi2_V_results_final.txt", replace text



foreach var1 of local vars {
    foreach var2 of local vars {
        * Avoid redundant pairs (impute_dvint vs impute_dvint as string compare)
        if "`var1'" < "`var2'" {
            * Perform the chi2 test
            display "Performing chi2 V test on `var1' and `var2'"
            tabulate `var1' `var2', chi V         // as macro variable
            * Calculate and display Cramér's V
            local chi2 = r(chi2)
            local n = _N
            local k = min(r(r1), r(r2))
            local cramersv = sqrt(`chi2'/(`n' * (`k' - 1)))
            display "Cramér's V: " `cramersv'
        }
		
	
    }
}

log close




mi set mlong

mi register imputed impute_dvint impute_earnings impute_health impute_educ impute_poverty ///
    impute_himedicaidyr impute_gotwelf impute_wormedbill impute_mcareprob
	
// First we would imputate on health since it has the least missing data//


log using "missing_datapattern.txt.txt", replace text
mi misstable pattern
mi describe, detail
log close

tabulate impute_himedicaidyr 

tabulate impute_gotwelf
tabulate impute_mcareprob 



// we need to change some of the variable for logit regression do this first
replace impute_himedicaidyr = 0 if impute_himedicaidyr == 1
replace impute_himedicaidyr = 1 if impute_himedicaidyr == 2

replace impute_gotwelf = 0 if impute_gotwelf == 10
replace impute_gotwelf = 1 if impute_gotwelf == 21



describe


mi impute chained (ologit, augment)  impute_health impute_educ impute_poverty impute_dvint impute_earnings impute_wormedbill ///
    (logit, augment) impute_himedicaidyr impute_gotwelf = age sex racenew ///
    if age < 65, ///
    add(5) noisily
	




mi impute ologit impute_earnings = age sex racenew if age >= 65, replace noisily

* Impute 'impute_poverty' for age >= 65
mi impute ologit impute_poverty = age sex racenew if age >= 65, replace noisily

* Impute 'impute_himedicaidyr' for age >= 65
mi impute logit impute_himedicaidyr = age sex racenew if age >= 65, replace noisily augment

* Impute 'impute_mcareprob' for age >= 65
mi impute mlogit impute_mcareprob = age sex racenew if age >= 65, replace noisily


// We first padd all the data with non missing variable then we use more acurate imputation


// force is for prevention, in reality all data are imputed


* Impute 'impute_health' for age < 65 
mi impute ologit impute_health = impute_dvint impute_earnings impute_himedicaidyr impute_wormedbill impute_poverty impute_educ age sex racenew if age < 65, replace

* Impute 'impute_health' for age >= 65 
mi impute ologit impute_health = impute_dvint impute_earnings impute_himedicaidyr impute_wormedbill impute_mcareprob impute_poverty impute_educ age sex racenew if age >= 65, replace

* Impute 'impute_educ' for age < 65 
mi impute ologit impute_educ = impute_health impute_dvint impute_earnings impute_himedicaidyr impute_wormedbill impute_poverty age sex racenew if age < 65, replace

* Impute 'impute_educ' for age >= 65 
mi impute ologit impute_educ = impute_health impute_dvint impute_earnings impute_himedicaidyr impute_wormedbill impute_mcareprob impute_poverty age sex racenew if age >= 65, replace

* Impute 'impute_gotwelf' for age < 65 
mi impute logit impute_gotwelf = impute_health impute_dvint impute_earnings impute_himedicaidyr impute_wormedbill impute_poverty age sex racenew if age < 65, replace

* Impute 'impute_gotwelf' for age >= 65 
mi impute logit impute_gotwelf = impute_health impute_dvint impute_earnings impute_himedicaidyr impute_wormedbill impute_mcareprob impute_poverty age sex racenew if age >= 65, replace

* Impute 'impute_wormedbill' for age < 65 
mi impute ologit impute_wormedbill = impute_health impute_dvint impute_earnings impute_himedicaidyr impute_educ impute_poverty age sex racenew if age < 65, force replace

* Impute 'impute_wormedbill' for age >= 65 
mi impute ologit impute_wormedbill = impute_health impute_dvint impute_earnings impute_himedicaidyr impute_mcareprob impute_educ impute_poverty age sex racenew if age >= 65, replace

* Impute 'impute_dvint' for age < 65 
mi impute ologit impute_dvint = impute_health impute_earnings impute_himedicaidyr impute_wormedbill impute_educ impute_poverty age sex racenew if age < 65, replace

* Impute 'impute_dvint' for age >= 65 
mi impute ologit impute_dvint = impute_health impute_earnings impute_himedicaidyr impute_wormedbill impute_mcareprob impute_educ impute_poverty age sex racenew if age >= 65, replace

describe

* Impute 'impute_himedicaidyr'
* Here we don't have impute 'impute_himedicaidyr' for age >= 65 because there is only one case where age is greater than 65 and including all model variables to impute it has issues of perfect predictor(s) detected
mi impute logit impute_himedicaidyr = impute_health impute_dvint impute_earnings impute_wormedbill impute_educ impute_poverty impute_gotwelf age sex racenew, replace


mi impute mlogit impute_mcareprob = impute_health impute_dvint impute_earnings impute_himedicaidyr impute_wormedbill impute_educ age sex racenew if age >= 65, replace augment

* Impute 'impute_poverty' for age >= 65 
mi impute ologit impute_poverty = impute_health impute_dvint impute_earnings impute_himedicaidyr impute_wormedbill impute_mcareprob impute_educ impute_gotwelf age sex racenew if age >= 65, replace

* Impute 'impute_earnings' for age < 65 
mi impute ologit impute_earnings = impute_health impute_dvint impute_himedicaidyr impute_wormedbill impute_educ impute_poverty impute_educ impute_gotwelf age sex racenew if age < 65, replace

* Impute 'impute_earnings' for age >= 65 
mi impute ologit impute_earnings = impute_health impute_dvint impute_himedicaidyr impute_wormedbill impute_mcareprob impute_educ impute_poverty impute_gotwelf age sex racenew if age >= 65, replace



mi describe,detail
// also make sure we are working with imputated data this should be 0 we are good

count if impute_mcareprob == .& age >65
	
//------------------Summary of data after imputation---------------------//





mi describe,detail







//are there attrition bias//
//  -----------------Model Design--------------------//


use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/nhis_fully_impute.dta"   


global ylist_earn impute_dvint
global xlist_earn impute_dvint impute_earnings impute_health age sex racenew

describe

. ssc install estout, replace



//Ordered logit model.  ----> lr test does not work for mi estmate since its not based on maimum liklihood but we pick ologit for dvint anyways
// mi estimate: ologit impute_dvint impute_earnings, robust
// eststo ologit_dvint
// mi estimate:  mlogit  impute_dvint impute_earnings, robust
// eststo mlogit_dvint
// lrtest mlogit_dvint ologit_dvint, force

// create a special term for impute_mcareprob_dummy that only terms on when its above age 65 in other cases missing

gen impute_mcareprob_dummy = .
replace impute_mcareprob_dummy = 0 if age >=65 & impute_mcareprob == 1
replace impute_mcareprob_dummy = 1 if age >=65 & impute_mcareprob == 2




// slowly including more variable
mi estimate: ologit impute_dvint impute_earnings, robust
mi estimate: ologit impute_dvint impute_earnings impute_health, robust
mi estimate: ologit impute_dvint impute_earnings impute_health age, robust
mi estimate: ologit impute_dvint impute_earnings impute_health age sex, robust
mi estimate: ologit impute_dvint impute_earnings impute_health age sex racenew, robust
mi estimate: ologit impute_dvint impute_earnings impute_health age sex racenew impute_mcareprob_dummy, robust
mi estimate: ologit impute_dvint impute_earnings impute_health age sex racenew i.age_65_dummy2, robust 

misstable summarize

tabulate impute_mcareprob
tabulate impute_mcareprob_dummy
//maginal effect

tabulate impute_dvint
eststo ologit_dvint




ologit dvint earnings 



// compare impute and un impuute for reference


ssc install mimrgns

mimrgns, dydx(impute_earnings) atmeans
//
mimrgns, dydx(impute_earnings) atmeans predict(outcome(100))
mimrgns, dydx(impute_earnings) atmeans predict(outcome(203))
mimrgns, dydx(impute_earnings) atmeans predict(outcome(204))
mimrgns, dydx(impute_earnings) atmeans predict(outcome(302))
mimrgns, dydx(impute_earnings) atmeans predict(outcome(305))
mimrgns, dydx(impute_earnings) atmeans predict(outcome(400))

tabulate impute_earnings
tabulate sex

//https://stats.oarc.ucla.edu/stata/faq/how-can-i-get-margins-and-marginsplot-with-multiply-imputed-data/ citation for how I got this visualizeation to work


program myret, rclass
    return add
    return matrix b = b
    return matrix V= V
end

program drop emargins



program emargins, eclass properties(mi)
  version 15
  args outcome
  ologit impute_dvint impute_earnings impute_health age sex racenew
  margins, dydx(impute_earnings) at(sex=(1 2))atmeans asbalanced ///
    post predict(outcome(`outcome'))
end


* Loop over each unique value for impute_dvint
foreach outcome in 100 203 204 302 305 400 {
    * Estimate marginal effects using the 'emargins' program for each category of impute_dvint
    mi estimate, cmdok: emargins `outcome'  // emargins computes marginal effects
    
    mat b = e(b_mi)  // Save the point estimates from MI
    mat V = e(V_mi)  // Save the variance-covariance matrix from MI

    * Now, run the ologit model for _mi_m==0 (non-missing data) to compute margins
    quietly ologit impute_dvint impute_earnings impute_health age sex racenew if _mi_m == 0
    quietly margins,dydx(impute_earnings) at(sex=(1 2)) atmeans asbalanced predict(outcome(`outcome'))

    * Store the results for the margins command
    myret  // This would store the results if defined

    * Technically, we ran myret between margins and marginsplot.
    * Set the previous command to margins to make marginsplot work.
    mata: st_global("e(cmd)", "margins")

    * Now generate the plot
    marginsplot, x(sex) recast(line) noci name(ologit`outcome', replace)
}

marginsplot
 



//-------- For iv and fixed effect its easier to extract one imptated data set and use it since the mi_estimate: libarary did not offer fix effect for ologit or iv analysis tools-----------------//

use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/nhis_fully_imputated_extract.dta"   



mi extract 1

// make sure we are working with imputated data this should be 0 we are good

count if impute_mcareprob == .& age >65
misstable summarize


// check for fixed effect id
tabulate nhishid   
isid year nhispid_num 
isid year nhishid_num 
isid year poverty   

ssc install cmp


cmp setup


//fixed effect

ologit impute_dvint impute_earnings impute_health age sex racenew i.year 


//conditional mixed process (cmp)

cmp(impute_earnings = impute_himedicaidyr i.year impute_health age sex racenew)(impute_dvint  = impute_earnings impute_health age sex racenew i.year) ,ind ($cmp_mprobit $cmp_oprobit)

//////


//------------------model for impute_wormedbill--------------//


// You can use 2SLS in the following cases:
// 1) 𝑌𝑌𝑖𝑖𝑖𝑖 and 𝑃𝑃𝑖𝑖𝑖𝑖 are both continuous variables
// 2) 𝑌𝑌𝑖𝑖𝑖𝑖 is discrete, and 𝑃𝑃𝑖𝑖𝑖𝑖 is continuous
// 3) 𝑌𝑌𝑖𝑖𝑖𝑖 is continuous, and 𝑃𝑃𝑖𝑖𝑖𝑖 is discrete, but it is better to use maximum likelihood estimation
// (MLE) procedures. The Stata command treatreg can do that easily.
// If 𝑌𝑌𝑖𝑖𝑖𝑖 and 𝑃𝑃𝑖𝑖𝑖𝑖are both discrete, you should not use 2SLS, you should use a MLE method that
// estimates both equations simultaneously. You can use biprobit or mvprobit commands in
// Stata. the sfirst method is perfered

ologit impute_dvint impute_wormedbill impute_health age sex racenew i.year 

cmp(impute_wormedbill = impute_himedicaidyr i.year impute_health age sex racenew) ///
    (impute_dvint = impute_wormedbill impute_health age sex racenew i.year), ///
    ind($cmp_mprobit $cmp_oprobit)













//---------------------------------------Unrealated




//A likelihood ratio test will therefore tell you whether simplification from multinomial logit to ordered logit is justified, how ever mi is not based on 

// An LR test can compare a Logit (binary outcome) model and an Mlogit (multinomial outcome) model because both use maximum likelihood estimation. The test evaluates whether the increased complexity of the Mlogit model, with more categories, significantly improves the fit over the simpler Logit model, thereby assessing if the added complexity is justified by the data.
//https://www.statalist.org/forums/forum/general-stata-discussion/general/1653984-ordinal-or-multinomial-regression




*-----------------------------

*General remark 

* What we can do is to limit time from 2016-2018 pre covid

* Complication for missing data

* Attempt at data imputation/ there is a big issue the entirety of missing data exist in 2019, if imputated it, we are essentially using knn to predict the data and it won't give us much information, consider simply dropping them.

* hospnght has no missing data but should we count unknown case as missing data or somthing else, and should we treat the unknown refused, not certainor don't know differently
* The same issue apply to variables like eryrno, usualpl   essentually any variable that has this choice

*-----------------------------
*  For similar variable ,sum, average, first principal component of the two (or more) series. How do we justify a given choice
*  Interval since last doctor visit/  was in a hospital overnight in past 12 months/  received home care from health professional, past 12 months





* Medical care delayed due to cost, past 12 months/ needed but couldn't afford medical care, past 12 months /  needed but couldn't afford prescription medicines, past 12 months /  worried about paying medical bills/  delayed filling prescription to save money, past 12 months/  took less medication to save money, past 12 months/  skipped medication doses to save money, past 12 months/  problems paying or unable to pay medical bills, past 12 months/  unable to pay medical bills


* The concern is this If variables x1 and x2 represent two distinct methods for measuring the same attribute, merging them can offer a more precise representation of the attribute you're trying to measure. For example, to create a variable indicating body size, you could combine x1 = height and x2 = weight, either by adding them together (x1 + x2) or by performing a principal components analysis and selecting the first principal component.

*-----------------------------

* Having children may effect health care usage as well


*-----------------------------

* Other data we should include 	Health status/. why? we may be able to calculate short term QALY

* What about a cost utility example.  does cost/utility effect the utilization of health care?  We don't have life expectancy we could devide this by the years of obervation to get average health of a individua across year, then we might be able use a dummy varaible to simulate treatment or not or utilization or not.  Another question arise, is three years of observation enoough to make meaningful conclusion?

*-----------------------------


* Remember its invalid to simply to drop these varaibles as there may be missing data bias.  Drop? / Imputation?
* Perhaps we need to understand, are the missing data missing datas MAR/MCAR/MANR
*Should we use dummy variables as adjustments? The missing-indicator method is a popular and simple method to handle missing data in clinical research but has been criticized for introducing bias.   But we would know that the variability of x would be reduce since usually we replace missing x value with somthing like the mean or regression estimate







* Does affordability in healthcare and vist mean the same thing?  Can you visit but can't afford?  
* Define population regression function    :     interval since last doctor visit=







//    wormedbill 

