
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

describe 
// https://nhis.ipums.org/nhis/userNotes_links.shtml. adding new variables that I wanted to include this https://nhis.ipums.org/nhis/userNotes_links.shtml

merge 1:1 year nhispid using "HealthCon_additional.dta"
merge 1:1 year nhispid using "Medicaid_care_16_18.dta", generate(_merge_MC1618)
merge 1:1 year nhispid using "Auxilarydata_001_original.dta", generate(_merge_aux001)






**# Bookmark #7

//--------Now the data is fully merged------------//

use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/nhis_fully_merge.dta"
describe



// Drop all values recorded as niu for dvint and earnings, as these are
// unrecorded. 
// drop data NIU
//289,322  --> 94,587     58 varaible
drop if dvint == 0 | earnings == 0

tabulate dvint
tabulate earnings


//Drop a year value from 2019//
drop if year == 2019

misstable summarize 
describe 







//--------------------------Creating data table for original data----------------------------------//
//---- output summary static and data desrption for the unmerged data------//

ssc install estout
ssc describe descsave


//summary output

eststo clear
estpost summarize *
esttab using "original_data_summary.txt", cells(" count() mean()  sd()  min()  max()") label replace

// Desribe output
descsave, saving("original_data_description.dta") 


use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original dataset/original_data_description.dta"
//open and output the file
outsheet using "original_data_description.txt", replace





use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original dataset/nhis_first_merged"





descsave, saving("merged_data_description.dta") 




//---- output for merged data------//

use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original dataset/nhis_fully_merged_original.dta"



// summart
eststo clear
estpost summarize *
esttab using "merged_data_summary.txt", cells(" count() mean()  sd()  min()  max()") label replace



//describe

descsave, saving("merged_data_description.dta") 

use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Original dataset/merged_data_description.dta"

outsheet using "merged_data_description.txt", replace








//------------------------------Missing data----------------------------------//
//Learning about missing data for merged and unmerged//

mcartest copy_dvint copy_earnings copy_health sex age 


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



///----------------------------Dealing with data that are Unkown or marked as unobserved------------------------------------------------//





gen copy_dvint = dvint
gen copy_earnings = earnings
gen copy_health = health


count if age == 999

summarize dvint
summarize copy_dvint

summarize earnings
summarize copy_earnings

summarize health
summarize copy_health 


sum copy_earnings
sum copy_dvint

* Handle cases for missing or unrecognized categories
replace copy_dvint = .  if dvint == 997  
replace copy_dvint = .  if dvint == 998
replace copy_dvint = .  if  dvint == 999 



replace copy_earnings = . if earnings== 97 
replace copy_earnings = . if  earnings == 98 
replace copy_earnings = . if  earnings == 99



replace copy_health = . if  health == 7
replace copy_health  = . if  health == 8
replace copy_health  = . if  health == 9



//create missing data lable just in case
gen missing_dvint = missing(copy_dvint)
gen missing_earnings = missing(copy_earnings)
gen missing_health = missing(copy_health)



// analyse missing data



//----------------------Data imputation using KNN------------------------------//

// if the mcartest tell us we fail to reject null hypthesis that the data is MAC, we can say droping the variable would be ok since all missing data are purely random
mcartest copy_dvint copy_earnings copy_health sex age 





mi set mlong
mi register imputed copy_dvint earnings
mi impute mlogit copy_dvint = copy_earnings copy_health , add(5)
mi impute mlogit copy_earnings = copy_dvint copy_health, add(5)

mi impute mlogit copy_health = copy_earnings copy_dvint , add(5)

misstable patterns

sum copy_earnings
sum copy_dvint





//are there attrition bias//
//  -----------------Model Design--------------------//


global ylist copy_dvint
global xlist copy_earnings copy_health age 

describe

. ssc install estout, replace



//Ordered logit model
ologit $ylist $xlist, robust
eststo ologit_dvint
mlogit  $ylist $xlist, robust
eststo mlogit_dvint
lrtest mlogit_dvint ologit_dvint, force


//maginal effect

ologit $ylist $xlist, robust
eststo ologit_dvint






//
//mg all $xlist
margins, dydx(*) atmeans



mfx, predict(outcome(100))


// Fixed effect model ssc install feologit

encode nhispid, gen(nhispid_num)


xtset nhispid_num year
xtologit dvint earnings age health, fe robust


* Run the Fixed Effects Ordered Logit Model
feologit $ylist $xlist, i(nhispid_num) i(year) robust


//iv
xtivreg copy_dvint (copy_earnings = himedicaidyr) copy_health age, fe robust








//---------------------------------------Unrealated test




//A likelihood ratio test will therefore tell you whether simplification from multinomial logit to ordered logit is justified.

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

