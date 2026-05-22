*! ei_compare v1.0.0 - Compare EI methods via eiCompare
*! Author: Loren Collingwood
*! Date: 2026-05-21

program define ei_compare, rclass
    version 14.0
    syntax varlist(min=2), Races(varlist) Totals(varname) ///
        [SEED(integer -1) METHODS(string) ERho(real 10) ///
         SAMples(integer 10000) BURNin(integer 5000) ///
         THIN(integer 1) NAME(string)]

    * -----------------------------------------------
    * Default methods to all
    * -----------------------------------------------
    if "`methods'" == "" {
        local methods "all"
    }

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

    * -----------------------------------------------
    * Save data to temp CSV
    * -----------------------------------------------
    display as text ""
    display as text "{hline 60}"
    display as text "  EI Method Comparison (via eiCompare)"
    display as text "{hline 60}"
    display as text ""

    tempfile datacsv resultscsv
    local datacsv = subinstr("`datacsv'", "\", "/", .)
    local resultscsv = subinstr("`resultscsv'", "\", "/", .)

    preserve
    keep `varlist' `races' `totals'
    quietly export delimited using "`datacsv'", replace
    restore

    * -----------------------------------------------
    * Set seed
    * -----------------------------------------------
    local seed_cmd ""
    if `seed' != -1 {
        local seed_cmd "set.seed(`seed');"
    }

    * -----------------------------------------------
    * Determine which methods to run
    * -----------------------------------------------
    local run_good = 0
    local run_iter = 0
    local run_rxc = 0

    if "`methods'" == "all" {
        local run_good = 1
        local run_iter = 1
        local run_rxc = 1
    }
    else {
        if strpos("`methods'", "good") > 0 {
            local run_good = 1
        }
        if strpos("`methods'", "iter") > 0 {
            local run_iter = 1
        }
        if strpos("`methods'", "rxc") > 0 {
            local run_rxc = 1
        }
    }

    * -----------------------------------------------
    * Run comparison in R
    * -----------------------------------------------
    display as text "  Running EI comparison (methods: `methods')..."
    if `run_rxc' {
        display as text "  (RxC uses MCMC - this may take a while)"
    }

    rcall: library(eiCompare); ///
        `seed_cmd' ///
        dat <- read.csv("`datacsv'", stringsAsFactors=FALSE); ///
        cands <- c(`cand_vec'); ///
        races <- c(`race_vec'); ///
        total_col <- "`totals'"; ///
        run_good <- `run_good'; ///
        run_iter <- `run_iter'; ///
        run_rxc <- `run_rxc'; ///
        results_list <- list(); ///
        if (run_good) { ///
            cat("  Running Goodman's regression...\n"); ///
            good_res <- tryCatch( ///
                ei_good(data=dat, cand_cols=cands, race_cols=races, total=total_col), ///
                error = function(e) { cat("  Goodman error:", e$message, "\n"); NULL } ///
            ); ///
            if (!is.null(good_res)) results_list[["Goodman"]] <- good_res; ///
        }; ///
        if (run_iter) { ///
            cat("  Running Iterative EI...\n"); ///
            iter_res <- tryCatch( ///
                ei_iter(data=dat, cand_cols=cands, race_cols=races, total=total_col, erho=`erho'), ///
                error = function(e) { cat("  Iter EI error:", e$message, "\n"); NULL } ///
            ); ///
            if (!is.null(iter_res)) results_list[["Iterative"]] <- iter_res; ///
        }; ///
        if (run_rxc) { ///
            cat("  Running RxC Bayesian EI...\n"); ///
            rxc_res <- tryCatch( ///
                ei_rxc(data=dat, cand_cols=cands, race_cols=races, total=total_col, ///
                       ntunes=`burnin', samples=`samples', thin=`thin'), ///
                error = function(e) { cat("  RxC error:", e$message, "\n"); NULL } ///
            ); ///
            if (!is.null(rxc_res)) results_list[["RxC"]] <- rxc_res; ///
        }; ///
        if (length(results_list) > 1) { ///
            comp <- tryCatch( ///
                ei_rc_good_table(results_list, cand_cols=cands, race_cols=races), ///
                error = function(e) { ///
                    cat("  Comparison table error:", e$message, "\n"); ///
                    do.call(rbind, lapply(names(results_list), function(nm) { ///
                        df <- as.data.frame(results_list[[nm]]); ///
                        df$method <- nm; ///
                        df ///
                    })) ///
                } ///
            ); ///
        } else if (length(results_list) == 1) { ///
            comp <- as.data.frame(results_list[[1]]); ///
            comp$method <- names(results_list)[1]; ///
        } else { ///
            stop("No methods completed successfully.") ///
        }; ///
        comp_df <- as.data.frame(comp); ///
        write.csv(comp_df, "`resultscsv'", row.names=TRUE); ///
        cat("SUCCESS\n")

    * -----------------------------------------------
    * Load and display comparison
    * -----------------------------------------------
    preserve
    quietly {
        import delimited using "`resultscsv'", clear varnames(1)
        capture rename v1 rowname
    }

    display as text ""
    display as result "  EI Method Comparison Results"
    display as text "  {hline 50}"
    list, separator(0) noobs
    display as text ""

    local nobs = _N
    return scalar N = `nobs'
    return local methods "`methods'"
    if "`name'" != "" {
        return local name "`name'"
    }

    restore

    display as text "  Comparison complete."
    display as text ""
end
