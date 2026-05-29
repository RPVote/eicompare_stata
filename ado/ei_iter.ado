*! ei_iter v1.0.1 - Iterative EI (King's method) via eiCompare
*! Author: Loren Collingwood
*! Date: 2026-05-28

program define ei_iter, rclass
    version 14.0
    syntax varlist(min=2), Races(varlist) Totals(varname) ///
        [SEED(integer -1) ERho(real 10) CI(real 0.95) ///
         NAME(string) SAVE_BETAS]

    * -----------------------------------------------
    * Parse candidate and race variables
    * -----------------------------------------------
    local ncands : word count `varlist'
    local nraces : word count `races'

    * Build R vectors
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
    * Validate
    * -----------------------------------------------
    confirm variable `varlist'
    confirm variable `races'
    confirm variable `totals'

    if `ci' <= 0 | `ci' >= 1 {
        display as error "ci() must be between 0 and 1"
        exit 198
    }

    * -----------------------------------------------
    * Save data to temp CSV
    * -----------------------------------------------
    display as text ""
    display as text "{hline 60}"
    display as text "  Iterative EI - King's Method (via eiCompare)"
    display as text "{hline 60}"
    display as text ""

    tempfile datacsv resultscsv betascsv
    local datacsv = subinstr("`datacsv'", "\", "/", .)
    local resultscsv = subinstr("`resultscsv'", "\", "/", .)
    local betascsv = subinstr("`betascsv'", "\", "/", .)

    preserve
    keep `varlist' `races' `totals'
    quietly export delimited using "`datacsv'", replace
    restore

    * -----------------------------------------------
    * Set seed string for R
    * -----------------------------------------------
    local seed_cmd ""
    if `seed' != -1 {
        local seed_cmd "set.seed(`seed');"
    }

    * -----------------------------------------------
    * Run iterative EI in R
    * -----------------------------------------------
    display as text "  Running iterative EI (this may take a moment)..."

    rcall: library(eiCompare); ///
        `seed_cmd' ///
        dat <- read.csv("`datacsv'", stringsAsFactors=FALSE); ///
        cands <- c(`cand_vec'); ///
        races <- c(`race_vec'); ///
        total_col <- "`totals'"; ///
        results <- tryCatch({ ///
            ei_iter(data = dat, ///
                    cand_cols = cands, ///
                    race_cols = races, ///
                    total = total_col, ///
                    erho = `erho') ///
        }, error = function(e) { ///
            stop(paste("eiCompare ei_iter() error:", e$message)) ///
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
        capture rename v1 rowname
    }

    display as text ""
    display as result "  Iterative EI Results"
    display as text "  {hline 50}"
    list, separator(0) noobs
    display as text ""

    local nobs = _N
    return scalar N = `nobs'
    return scalar erho = `erho'
    return scalar ci = `ci'
    return local method "iterative"
    if "`name'" != "" {
        return local name "`name'"
    }
    if `seed' != -1 {
        return scalar seed = `seed'
    }

    restore

    display as text "  Iterative EI estimation complete."
    display as text ""
end
