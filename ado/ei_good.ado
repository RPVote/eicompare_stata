*! ei_good v1.0.1 - Goodman's ecological regression via eiCompare
*! Author: Loren Collingwood
*! Date: 2026-05-28

program define ei_good, rclass
    version 14.0
    syntax varlist(min=2), Races(varlist) Totals(varname) ///
        [NAME(string)]

    * -----------------------------------------------
    * Parse candidate and race variables
    * -----------------------------------------------
    local ncands : word count `varlist'
    local nraces : word count `races'

    * Build R vectors for candidate and race column names
    local cand_vec ""
    local first = 1
    foreach v of local varlist {
        if `first' {
            local cand_vec `""`v'""'
            local first = 0
        }
        else {
            local cand_vec `"`cand_vec', "`v'""'
        }
    }

    local race_vec ""
    local first = 1
    foreach v of local races {
        if `first' {
            local race_vec `""`v'""'
            local first = 0
        }
        else {
            local race_vec `"`race_vec', "`v'""'
        }
    }

    * -----------------------------------------------
    * Validate variables exist in dataset
    * -----------------------------------------------
    confirm variable `varlist'
    confirm variable `races'
    confirm variable `totals'

    * -----------------------------------------------
    * Save current data to temp CSV for R
    * -----------------------------------------------
    display as text ""
    display as text "{hline 60}"
    display as text "  Goodman's Ecological Regression (via eiCompare)"
    display as text "{hline 60}"
    display as text ""

    tempfile datacsv resultscsv
    local datacsv = subinstr("`datacsv'", "\", "/", .)
    local resultscsv = subinstr("`resultscsv'", "\", "/", .)

    * Build varlist of all needed variables
    preserve
    keep `varlist' `races' `totals'
    quietly export delimited using "`datacsv'", replace
    restore

    * -----------------------------------------------
    * Run Goodman's regression in R via rcall
    * -----------------------------------------------
    display as text "  Running Goodman's ecological regression..."

    rcall: library(eiCompare); ///
        dat <- read.csv("`datacsv'", stringsAsFactors=FALSE); ///
        cands <- c(`cand_vec'); ///
        races <- c(`race_vec'); ///
        total_col <- "`totals'"; ///
        results <- tryCatch({ ///
            ei_good(data = dat, ///
                    cand_cols = cands, ///
                    race_cols = races, ///
                    total = total_col) ///
        }, error = function(e) { ///
            stop(paste("eiCompare ei_good() error:", e$message)) ///
        }); ///
        res_df <- results$estimates; ///
        write.csv(res_df, "`resultscsv'", row.names=TRUE); ///
        cat("SUCCESS\n")

    * -----------------------------------------------
    * Load and display results
    * -----------------------------------------------
    preserve
    quietly {
        import delimited using "`resultscsv'", clear varnames(1)

        * Rename V1 to rowname if needed
        capture rename v1 rowname
    }

    * Display results table
    display as text ""
    display as result "  Goodman's Ecological Regression Results"
    display as text "  {hline 50}"
    list, separator(0) noobs
    display as text ""

    * Store results in return
    local nobs = _N
    return scalar N = `nobs'
    return local method "goodman"
    if "`name'" != "" {
        return local name "`name'"
    }

    restore

    * Save results to a Stata dataset if user wants
    display as text "  Results displayed above."
    display as text "  To save: import delimited using the results CSV."
    display as text ""
end
