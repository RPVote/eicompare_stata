*! ei_example.do - Example usage of eicompare_stata package
*! Author: Loren Collingwood
*! Date: 2026-05-21

* =========================================================
* eicompare_stata: Example Do-File
* =========================================================
* This do-file demonstrates how to use the eicompare_stata
* package for ecological inference analysis.
*
* Prerequisites:
*   1. Install rcall: github install haghish/rcall
*   2. Install eicompare_stata:
*      net install eicompare_stata, from("path/to/eicompare_stata")
*   3. Run: ei_setup, install
* =========================================================

clear all
set more off

* ---------------------------------------------------------
* Step 0: Verify setup
* ---------------------------------------------------------
ei_setup

* ---------------------------------------------------------
* Step 1: Create example election dataset
* ---------------------------------------------------------
* Simulating a simple election dataset with:
*   - 50 precincts
*   - 2 candidates (cand_a, cand_b)
*   - 3 racial groups (pct_white, pct_black, pct_hisp)
*   - Total voters per precinct

set seed 12345
set obs 50

* Generate racial composition (proportions summing to 1)
generate pct_white = runiform(0.2, 0.8)
generate pct_black = runiform(0.05, 0.4)
generate pct_hisp  = 1 - pct_white - pct_black

* Fix any negatives from random generation
replace pct_hisp = 0.05 if pct_hisp < 0
replace pct_black = 1 - pct_white - pct_hisp if pct_white + pct_black + pct_hisp > 1

* Generate total voters
generate total_votes = round(runiform(200, 2000))

* Generate candidate vote shares (proportions summing to 1)
* Candidate A does better in whiter precincts (for illustration)
generate cand_a = 0.3 + 0.4 * pct_white + rnormal(0, 0.05)
replace cand_a = max(0.01, min(0.99, cand_a))
generate cand_b = 1 - cand_a

* Verify proportions
summarize pct_white pct_black pct_hisp cand_a cand_b

display ""
display "Data created with `=_N' precincts"
display ""

* ---------------------------------------------------------
* Step 2: Goodman's Ecological Regression
* ---------------------------------------------------------
display as text ""
display as result "=== GOODMAN'S ECOLOGICAL REGRESSION ==="
display as text ""

ei_good cand_a cand_b, races(pct_white pct_black pct_hisp) totals(total_votes)

* ---------------------------------------------------------
* Step 3: Iterative EI (King's Method)
* ---------------------------------------------------------
display as text ""
display as result "=== ITERATIVE EI (KING'S METHOD) ==="
display as text ""

ei_iter cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) seed(12345)

* ---------------------------------------------------------
* Step 4: RxC Bayesian EI
* ---------------------------------------------------------
display as text ""
display as result "=== RxC BAYESIAN EI ==="
display as text ""

* Using fewer samples for speed in this example
ei_rxc cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) seed(12345) samples(5000) burnin(2000)

* ---------------------------------------------------------
* Step 5: Compare All Methods
* ---------------------------------------------------------
display as text ""
display as result "=== EI METHOD COMPARISON ==="
display as text ""

ei_compare cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) seed(12345) samples(5000) burnin(2000)

* ---------------------------------------------------------
* Step 6: Visualization
* ---------------------------------------------------------
display as text ""
display as result "=== VISUALIZATION ==="
display as text ""

* Comparison plot
ei_plot cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) saving(ei_comparison.pdf) seed(12345) ///
    samples(5000) burnin(2000)

* ---------------------------------------------------------
* Done
* ---------------------------------------------------------
display as text ""
display as result "{hline 60}"
display as result "  Example complete!"
display as result "{hline 60}"
display as text ""
display as text "  Check ei_comparison.pdf for the comparison plot."
display as text ""
