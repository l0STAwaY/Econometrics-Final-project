cd "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset" 
use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/nhis_first_working.dta"


describe


// report missing data

// Reported hhweight, perweight, fweight, pooryn, earnings, and pclookhelyr.
misstable summarize 


tabulate age

//Reported hhweight, fmx, px, perweight, fweight, pooryn, earnings, and pclookhelyr.      px and fm are label for identificaltion. That is labelwithin a family and person they do not need tobe data, 
foreach var of varlist * {
    display "`var'"  // Display the variable name
    

    * Count missing values
    quietly count if missing(`var')  
    display "Missing: " r(N)  // Display the count of missing values
}



**# Bookmark #6
//-------------------Merge data----------------------//

// checj the data before merging
use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/HealthCon_additional.dta"
use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/Medicaid_care_16_18"

describe 
// https://nhis.ipums.org/nhis/userNotes_links.shtml. adding new variables that I wanted to include this https://nhis.ipums.org/nhis/userNotes_links.shtml

merge 1:1 year nhispid using "HealthCon_additional.dta"
merge 1:1 year nhispid using "Medicaid_care_16_18", generate(_merge_MC1618)






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


describe 



* Open the file to write the descriptions
file open myfile using "nhis_first_working_description.txt", write replace

* Write the header in the file
file write myfile "Variable Descriptions:\n\n"



//the reason w droped 2019 is becuase



* I could techncally use drop but I dont like changing the original data for saftly concern despite keeping a copy of the original data
* Loop through all variables in the dataset
foreach var of varlist * {
    * If the value in the current variable is missing, set missing_var to 1 for that row 
    replace missing_var = 1 if missing(`var')
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


* There is hald the data un recorded which imputating on those data would in fact reduce the variablility.
* Create a new variable with numeric values
*this is the average of dvint
gen dvint_average = 0

* Recode the categorical values in `dvint` into numeric values
replace dvint_average = 0 if dvint == 100 //"never"  
replace dvint_average = 0.25 if dvint == 203 //"under 6 months" 
replace dvint_average = 0.75 if dvint ==  204 //"6 months to less than 12 months" 
replace dvint_average = 1.5 if dvint == 302 //"1 year to less than 2 years" 
replace dvint_average = 3.5 if dvint == 305 //"2 years to less than 5 years" 
replace dvint_average = 5 if dvint == 400 //"5 years or more"  


* Handle cases for missing or unrecognized categories that are unknown and unrecorded
replace dvint_average = .  if dvint == 997  
replace dvint_average = .  if dvint == 998
replace dvint_average = .  if  dvint == 999 
							
tabulate dvint_average 			
tabulate dvint		
							
corr dvint_average earnings_average
							





//Medicare Part B of Original Medicare and Medicare Advantage (Part C) cover the costs of doctor visits

// Part A covers mostly hospital utilization 




							
							
							
gen earnings_average = 0


* Assign calculated midpoints for each income category
replace earnings_average = 2500 if earnings == 01  // $01 to $4999
replace earnings_average = 7500 if earnings == 02  // $5000 to $9999
replace earnings_average = 12500 if earnings == 03 // $10000 to $14999
replace earnings_average = 17500 if earnings == 04 // $15000 to $19999
replace earnings_average = 22500 if earnings == 05 // $20000 to $24999
replace earnings_average = 30000 if earnings == 06 // $25000 to $34999
replace earnings_average = 40000 if earnings == 07 // $35000 to $44999
replace earnings_average = 50000 if earnings == 08 // $45000 to $54999
replace earnings_average = 60000 if earnings  == 09 // $55000 to $64999
replace earnings_average = 70000 if earnings == 10 // $65000 to $74999
replace earnings_average = 75000 if earnings == 11 // $75000 and over (no upper bound)

* Handle cases for missing or unrecognized categories
replace earnings_average = . if earnings== 97 
replace earnings_average = . if  earnings == 98 
replace earnings_average = . if  earnings == 99

 
tabulate earnings
tabulate earnings_average	


// use "/Users/apple/Documents/GitHub/Econometrics-Final-project/3. Data Processing/Working datset/meps_00001.dta" 

gen copy_dvint_average = dvint_average
gen copy_earnings_average = earnings_average

histogram dvint_average
histogram earnings_average


/// -----------Imputation--------------//



gen copy_dvint = dvint_average
gen copy_earnings = earnings_average


mi set mlong
mi register imputed copy_dvint earnings
mi impute mlogit copy_dvint = copy_earnings , add(5)
mi impute mlogit copy_earnings = copy_dvint  , add(5)



//  -----------------Model Design--------------------//



regress dvint_average i.earnings_average health



twoway scatter dvint_average earnings_average
							
twoway scatter dvint_average earnings_average
reg dvint_average earnings_average, robust

describe

encode nhispid, gen(nhispid_num)


xtset nhispid_num year
xtologit dvint earnings, fe


. ssc install estout, replace




ologit dvint earnings, robust
eststo ologit_dvint
mlogit dvint earnings, robust
eststo mlogit_dvint
lrtest mlogit_dvint ologit_dvint, force



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


corr delaycost ybarcare ybarmeds wormedbill hiprobpayr hiunablepay ydelaymedyr yskimpmedyr yskipmedyr




* Remember its invalid to simply to drop these varaibles as there may be missing data bias.  Drop? / Imputation?
* Perhaps we need to understand, are the missing data missing datas MAR/MCAR/MANR
*Should we use dummy variables as adjustments? The missing-indicator method is a popular and simple method to handle missing data in clinical research but has been criticized for introducing bias.   But we would know that the variability of x would be reduce since usually we replace missing x value with somthing like the mean or regression estimate







* Does affordability in healthcare and vist mean the same thing?  Can you visit but can't afford?  
* Define population regression function    :     interval since last doctor visit=







//    wormedbill 

