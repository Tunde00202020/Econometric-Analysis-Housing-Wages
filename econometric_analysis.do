
### 2. Improved Stata Do-File



```stata
// =============================================================================
// Econometric Analysis: Housing Markets & Wage Determinants
// Author: Babatunde Fati
// Date: [Current Date]
// 
// Project Description:
// This script performs econometric analysis on housing prices and wage determinants
// using multiple datasets and regression techniques.
// =============================================================================

// Setup
version 17.0
clear all
set more off
capture log close
log using "../outputs/analysis_log", text replace

// =============================================================================
// QUESTION 6.1: HOUSING PRICES AND INCINERATOR LOCATION
// =============================================================================

// Load and prepare data
bcuse kielmc, clear
keep if year == 1981
describe
summarize

// 6.1.i: Simple regression (potential omitted variable bias)
reg lprice ldist
// Interpretation: Initial naive model suggests distance from incinerator 
// positively affects prices (coef = 0.365, p < 0.001)

// 6.1.ii: Multiple regression with controls
reg lprice ldist lintst larea lland rooms baths age
// Key finding: After controlling for house characteristics, incinerator 
// distance effect becomes insignificant (coef = 0.055, p = 0.338)
// Demonstrates omitted variable bias in simple model

// 6.1.iii: Testing non-linearity in interstate distance
gen lintst_sq = lintst^2
reg lprice ldist lintst larea lland rooms baths age lintst_sq
// Interstate distance shows non-linear (inverted U) relationship with prices

// 6.1.iv: Testing non-linearity in incinerator distance  
gen ldist_sq = ldist^2
reg lprice ldist lintst larea lland rooms baths age lintst_sq ldist_sq
// No evidence of non-linear effects for incinerator distance (p = 0.741)

// =============================================================================
// QUESTION 6.2: WAGE DETERMINANTS AND EXPERIENCE
// =============================================================================

bcuse wage1, clear

// 6.2.i: Wage equation with experience quadratic
reg lwage educ exper expersq

// 6.2.ii: Statistical significance of quadratic term
// expersq is significant (p < 0.001), confirming diminishing returns

// 6.2.iii: Calculating marginal returns at different experience levels
// Return for 5th year of experience
display "Return for 5th year: " 100 * (_b[exper] + 2 * _b[expersq] * 4)
// Return for 20th year of experience  
display "Return for 20th year: " 100 * (_b[exper] + 2 * _b[expersq] * 19)

// 6.2.iv: Finding experience where marginal return becomes zero
display "Optimal experience level: " -_b[exper]/(2*_b[expersq])
sum exper if exper > 28.73, detail

// Visualization: Experience distribution
histogram exper, bin(20) title("Distribution of Work Experience") ///
xtitle("Years of Experience") saving("../outputs/figures/experience_distribution", replace)

// =============================================================================
// QUESTION 6.3: EDUCATION-EXPERIENCE INTERACTION
// =============================================================================

bcuse wage2, clear

// 6.3.i: Model with education-experience interaction
gen educ_exper = educ * exper
reg lwage educ exper educ_exper

// 6.3.ii & iii: Testing interaction significance
// Interaction term is positive (0.0032) and significant (p = 0.036)
// Evidence that returns to education increase with experience

// =============================================================================
// QUESTION 6.8: HOUSE PRICE PREDICTION
// =============================================================================

bcuse hprice1, clear

// Price prediction model
reg price lotsize sqrft bdrms

// Predict price for specific house characteristics
display "Predicted price: " _b[_cons] + _b[lotsize]*10000 + _b[sqrft]*2300 + _b[bdrms]*4

// =============================================================================
// Clean up
log close
clear all
