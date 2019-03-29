** Clean Caregiver Variable: Mexico **
/* This is a do file to produce clean caregiver codes for the Mexico child 1 
dataset. I use the roster and child dataset to decipher if a match exists between
the child and roster responses. 
For those that do not match with person_0 in the roster, I first use Miller's 
flag data set to determine who should be child2 and use person_0_aa11 for those.
For the rest, I loop through the roster and see if a member of the household
matches the relationship the child specified. If one exists, I use the relationship
of the match. For the 35 cases that have no matching adult response, I use the 
response from the child. I change two responses to match the roster because
evidence suggests the children were wrong. 

Variables which did not match person_0_aa4 or person_0_aa11 (depending on if
they were child 1 or 2) but matched another person in the roster are identified
by the flag variable (cleancg_fc1_f==1). 

At the end, there are 5 children that are left as missing (-99). After running
this do file, you will have child1 dataset open with the clean variable
(cleancg_fc1). 

Erick Axxe (axxe.1@osu.edu) --- FAMELO --- 03/15/2019 */

clear
clear matrix
set more off
capture log close

** Set working directory and establish the log file **
cd "C:\Users\axxe.1\Box Sync\FAMELO\Mexico\"
log using "Log Files\CleanCaregiver_MexChild1_EA_20190315", text replace
display "$S_TIME  $S_DATE"

**upload data**
set maxvar 10000
use "Data\CleanMexicoAdult.dta", clear


*****************************************************************
*****************************************************************
**********	 				Descriptives			*************
**********	 								        *************
**********	 								        *************
*****************************************************************
*****************************************************************

************ From Miller's Flag dataset ************
{ 
/*
Error flags in adult-child links

fc1rosterposition: where in the roster is focal child 1 (as designated by adult reports)
-5= Not in the roster, 1=Roster position 1 (where they should be), 
2= Roster position 2, etc., .=missing adult survey

fc2rosterposition; where in the roster is focal child 2 (as designated by adult reports)
-5= Not in the roster, -99=N/A because single focal child household, 
1=Roster position, 2= Roster position 2 (where they should be), etc. , .=missing adult survey

fc1childsurvey: which child survey should be matched to focal child 1 in adult survey
1= Child1 Survey, 2= Child2 survey, 
-10= No adult response but child response can be used by itself, 
-11= no child response but adult response can be used by itself, 
10=cannot match reports, but can use both the adult and child responses by themselves

fc2childsurvey: which child survey should be matched to focal child 2 in adult survey
-99=N/A because single focal child household, 1= Child1 Survey, 
2= Child2 survey, -10= No adult response but child response can be used by itself, 
-11= no child response but adult response can be used by itself, 
10=cannot match reports, but can use both the adult and child responses by themselves
Parent Identification Error Flags
*/
}

************ From the Adult questionnaire ************
{ 
/*
Variable: ADULTID
Question Text: [INTERVIEWER: ENTER NAME OF CAREGIVER BEING INTERVIEWED]
NAME OF CAREGIVER: __________

Variable: AA2
Question Text: { message=""; if (i>0) { message="So far, we have talked about 
"; for (j=0; j<=i-1; j++) { message=message+PERSON[j].AA2.value; if (j!=i-1) 
{ message=message+", "; } } } message;}{i==0 ? 
"Let's start with you, what is your name" : "What is the next person's name"}?
[INTERVIEWER- FIRST PERSON IN ROSTER SHOULD BE RESPONDENT, SECOND PERSON SHOULD
 BE FOCAL CHILD 1, THIRD PERSON SHOULD BE FOCAL CHILD 2 IF APPLICABLE, AND 
 THEN OTHER MEMBERS OF THE HOUSEHOLD]
[IF THE INTERVIEWER ALREADY KNOWS THE NAME, DON'T ASK, JUST ENTER]
Name: __________

Variable: AA4
Question Text: What is {i==0 ? "your" : PERSON[i].AA2.value + "'s"} relationship to {FC1Name.value}?
[INTERVIEWER: IF THE INTERVIEWER ALREADY KNOWS THE ANSWER ONLY CONFIRM THE 
RELATIONSHIP BEFORE ENTERING. WHEN THE PROGRAM ASKS WHAT IS THE RELATIONSHIP 
OF "FOCAL CHILD 1" TO "FOCAL CHILD 1", YOU SHOULD PICK THE ANSWER "THIS IS FOCAL CHILD 1".
[0 - This is focal child 1]
Choose: 1 - Mother/father, 2 - Stepmother/stepfather, 3 - Grandmother/grandfather, 
4 - Sister/brother, 5 - Sister in law/brother in law, 6 - Aunt/uncle, 7 - Cousin,
8 - Niece/nephew, 9 - Other relative, 11 - Non-relative
Choose: 1 - Mother/father, 2 - Stepmother/stepfather, 3 - Grandmother/grandfather, 
4 - Sister/brother, 5 - Sister in law/brother in law, 6 - Aunt/uncle, 7 - Cousin, 
8 - Niece/nephew, 9 - Other relative, 10 - Employer (FC is non-relative who works for household), 
11 - Non-relative
Choose: 1 - Mother/father, 2 - Father's wife/mother's husband, 
3 - Grandmother/grandfather, 4 - Sister/brother, 5 - Sister in law/brother in law, 
6 - Aunt/uncle, 7 - Cousin, 8 - Niece/nephew, 9 - Other relative, 
10 - Employer (FC is non-relative who works for household), 11 - Non-relative
[97 - [Don't know]]
[99 - [Refused]]

Variable: AA4Other, Show If: PERSON[i].AA4.value==9
Question Text: Please specify other relation:
Relationship: __________

Variable: AA4Nonrelative, Show If: PERSON[i].AA4.value==11
Question Text: Please specify relation to the child:
Relationship: __________

Variable: AA6, Show If: PERSON[i].AA5.value==997 || PERSON[i].AA5.value==999
Question Text: Is {PERSON[i].AA2.value} a child or an adult?
[0 - Child]
[1 - Adult]
[97 - [Don't know]]

Variable: AA11
Question Text: How {i==0 ? "are you" : "is " + PERSON[i].AA2.value} related to {FC2Name.value}?
[INTERVIEWER: IF THE INTERVIEWER ALREADY KNOWS THE ANSWER ONLY CONFIRM THE 
RELATIONSHIP BEFORE ENTERING. WHEN THE PROGRAM ASKS WHAT IS THE RELATIONSHIP 
OF "FOCAL 2" TO "FOCAL CHILD 2", YOU SHOULD PICK THE ANSWER "THIS IS FOCAL CHILD 2".
[0 - This is focal child 2.]
Choose: 1 - Mother/father, 2 - Stepmother/stepfather, 3 - Grandmother/grandfather, 
4 - Sister/brother, 5 - Sister in law/brother in law, 6 - Aunt/uncle, 7 - Cousin, 
8 - Niece/nephew, 9 - Other relative, 11 - Non-relative
Choose: 1 - Mother/father, 2 - Stepmother/stepfather, 3 - Grandmother/grandfather, 
4 - Sister/brother, 5 - Sister in law/brother in law, 6 - Aunt/uncle, 7 - Cousin, 
8 - Niece/nephew, 9 - Other relative, 
10 - Employer (FC is non-relative who works for household), 11 - Non-relative
Choose: 1 - Mother/father, 2 - Father's wife/mother's husband, 
3 - Grandmother/grandfather, 4 - Sister/brother, 5 - Sister in law/brother in law, 
6 - Aunt/uncle, 7 - Cousin, 8 - Niece/nephew, 9 - Other relative, 
10 - Employer (FC is non-relative who works for household), 11 - Non-relative
[97 - [Don't know]]
*/
}

*************** From Child Questionnaire ******************
{
/*
Variable: ADULTNAME
Question Text: [INTERVIEWER: ENTER NAME OF ADULT CAREGIVER]
ADULT CAREGIVER'S NAME: __________

Variable: CHILDCHECK4
Question Text: What is the relationship of the caregiver to the child?
The caregiver is the child's _______
Choose: 1 - Mother/father, 2 - Stepmother/stepfather, 3 - Grandmother/grandfather, 
4 - Sister/brother, 5 - Sister in law/brother in law, 6 - Aunt/uncle, 7 - Cousin, 
8 - Niece/nephew, 9 - Other relative, 11 - Non-relative
Choose: 1 - Mother/father, 2 - Stepmother/stepfather, 3 - Grandmother/grandfather, 
4 - Sister/brother, 5 - Sister in law/brother in law, 6 - Aunt/uncle, 7 - Cousin, 
8 - Niece/nephew, 9 - Other relative, 10 - Employer (FC is non-relative who works for household), 
11 - Non-relative
Choose: 1 - Mother/father, 2 - Father's wife/mother's husband, 
3 - Grandmother/grandfather, 4 - Sister/brother, 5 - Sister in law/brother in law,
6 - Aunt/uncle, 7 - Cousin, 8 - Niece/nephew, 9 - Other relative, 
10 - Employer (FC is non-relative who works for household), 11 - Non-relative
[97 - [Don't know]]
[99 - [Refused]]

Variable: DADALIVE
Question Text: Is the father alive?
[0 - No]
[1 - Yes]

Variable: MOMALIVE
Question Text: Is the mother alive?
[0 - No]
[1 - Yes]
*/
}


*****************************************************************
*****************************************************************
**********	 				Merging and 			*************
**********	 				cleaning 		        *************
**********	 				values			        *************
*****************************************************************
*****************************************************************
** Child 1 **
merge 1:1 nbhhh using "Data/CleanMexicoChild1.dta" 
rename _merge merge_1
keep if merge_1==3 | merge_1==2
tab childcheck4 person_0_aa4, m

//I create a clean variable which identifies those values where the child
//caregiver response does not match the roster response. 
gen cleancg_fc1=.
replace cleancg_fc1=childcheck4 if childcheck4==person_0_aa4
tab cleancg_fc1, m
//There are 49 problem cases. 35 of those are problems bc they didn't
//match when I merged the two datasets. 
keep if cleancg_fc1==.

**Flag dataset**
merge 1:1 nbhhh using "Data/MexErrorFlags.dta"
rename _merge merge_2
keep if merge_2==3

//create a flag variable which will indicate that the caregiver is not the
//person interviewed
gen cleancg_fc1_f=.
replace cleancg_fc1_f=1 if cleancg_fc1==.

//If a person exists in the household that matches the caregiver response the
//child gave, I use that response. I first do this if Miller says that they
//are actually the second child, then I run a loop for the rest.
foreach num of numlist 0/24 {
	replace cleancg_fc1=childcheck4 if childcheck4==person_`num'_aa11 & ///
	fc2childsurvey==2
	}

foreach num of numlist 0/24 {
	replace cleancg_fc1=childcheck4 if childcheck4==person_`num'_aa4 & cleancg_fc1==.
	}

//For those who do not merge and Sarah Miller's says we can use on their own,
//I replace the clean variable with the child response
replace cleancg_fc1=childcheck4 if fc1childsurvey==-10

//I will manually look at the responses children provided to try and decipher 
//what's going on
list nbhhh childcheck4 person_0_aa4 person_0_aa11 if cleancg_fc1==.

foreach num of numlist 0/24 {
	list nbhhh childcheck4 person_`num'_aa4 person_`num'_aa11 if ///
	cleancg_fc1==. & (person_`num'_aa4!=. | person_`num'_aa11!=.)
	}

foreach num of numlist 0/24 {
	list nbhhh childcheck4 person_`num'_aa4 person_`num'_aa11 dadalive momalive if ///
	cleancg_fc1==. & (person_`num'_aa4!=. | person_`num'_aa11!=.)
	}
//This respondent refused to answer, but the roster indicates the caregiver
//is their mother/father. I also change the flag bc the roster interviewee
//is the primary caregiver.
replace cleancg_fc1=1 if nbhhh=="1409600140164018-009"
replace cleancg_fc1_f=0 if nbhhh=="1409600140164018-009"

//Neither parent is alive for this individual, but they listed their caregiver
//as their parent. The roster indicates the caregiver is a grandparent,
//so I switch it to that. I also change the flag bc the roster interviewee
//is the primary caregiver.
replace cleancg_fc1=3 if nbhhh=="1411200010070007-018"
replace cleancg_fc1_f=0 if nbhhh=="1411200010070007-018"

//For the final 5, the roster suggests a mother/father lives in the house, 
//but the children say their primary caregiver is a relationship which
//doesn't exist in the roster.
foreach num of numlist 0/24 {
	list nbhhh childcheck4 person_`num'_aa4 person_`num'_aa11 if ///
	cleancg_fc1==. & (person_`num'_aa4!=. | person_`num'_aa11!=.)
	}

//So that these variables are unique when I merge the two, I will replace them
//with -99
replace cleancg_fc1=-99 if cleancg_fc1==.

//Remove the unnecessary variables so I can merge the child1 data set back on.
keep nbhhh cleancg_fc1 cleancg_fc1_f surveyid fc1childsurvey fc2childsurvey
merge 1:1 nbhhh using "data/CleanMexicoChild1.dta"

//All those who I didn't deal with (and were correct in the first place) 
//retain their original response
replace cleancg_fc1=childcheck4 if cleancg_fc1==.
replace cleancg_fc1_f=0 if cleancg_fc1_f==.

tab cleancg_fc1, m
tab cleancg_fc1_f, m

//produce a data set with the clean variable
keep cleancg_fc1 cleancg_fc1_f nbhhh
save "data/CleanCG_FC1_Mex_EA_20190315.dta", replace

log close
