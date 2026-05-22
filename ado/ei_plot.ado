*! ei_plot v1.0.0 - Visualize EI results via eiCompare
*! Author: Loren Collingwood
*! Date: 2026-05-21

program define ei_plot
    version 14.0
    syntax varlist(min=2), Races(varlist) Totals(varname) ///
        SAVing(string) [TYPE(string) SEED(integer -1) ///
        ERho(real 10) SAMples(integer 10000) BURNin(integer 5000) ///
        THIN(integer 1) WIDTH(real 8) HEIGHT(real 6)]

    * -----------------------------------------------
    * Default plot type
    * -----------------------------------------------
    if "`type'" == "" {
        local type "comparison"
    }

    * Validate type
    if "`type'" != "density" & "`type'" != "comparison" & "`type'" != "tomography" {
        display as error "type() must be one of: density, comparison, tomography"
        exit 198
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
    * Determine file format from extension
    * -----------------------------------------------
    local ext = lower(substr("`saving'", -4, .))
    if "`ext'" == ".png" {
        local device "png"
    }
    else if "`ext'" == ".pdf" {
        local device "pdf"
    }
    else if "`ext'" == ".jpg" {
        local device "jpg"
    }
    else {
        * Default to PDF
        local saving "`saving'.pdf"
        local device "pdf"
    }

    * -----------------------------------------------
    * Save data to temp CSV
    * -----------------------------------------------
    display as text ""
    display as text "{hline 60}"
    display as text "  EI Visualization (via eiCompare)"
    display as text "{hline 60}"
    display as text ""

    tempfile datacsv
    local datacsv = subinstr("`datacsv'", "\", "/", .)
    local saving_r = subinstr("`saving'", "\", "/", .)

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
    * Generate plot in R
    * -----------------------------------------------
    display as text "  Generating `type' plot..."
    display as text "  (Running EI methods for plot data...)"

    if "`type'" == "comparison" {
        rcall: library(eiCompare); ///
            library(ggplot2); ///
            `seed_cmd' ///
            dat <- read.csv("`datacsv'", stringsAsFactors=FALSE); ///
            cands <- c(`cand_vec'); ///
            races <- c(`race_vec'); ///
            total_col <- "`totals'"; ///
            good_res <- tryCatch( ///
                ei_good(data=dat, cand_cols=cands, race_cols=races, total=total_col), ///
                error = function(e) NULL ///
            ); ///
            iter_res <- tryCatch( ///
                ei_iter(data=dat, cand_cols=cands, race_cols=races, total=total_col, erho=`erho'), ///
                error = function(e) NULL ///
            ); ///
            rxc_res <- tryCatch( ///
                ei_rxc(data=dat, cand_cols=cands, race_cols=races, total=total_col, ///
                       ntunes=`burnin', samples=`samples', thin=`thin'), ///
                error = function(e) NULL ///
            ); ///
            results <- list(); ///
            if (!is.null(good_res)) results[["Goodman"]] <- good_res; ///
            if (!is.null(iter_res)) results[["Iterative"]] <- iter_res; ///
            if (!is.null(rxc_res)) results[["RxC"]] <- rxc_res; ///
            if (length(results) == 0) stop("No methods succeeded for plotting."); ///
            p <- tryCatch( ///
                plot(results, cand_cols=cands, race_cols=races), ///
                error = function(e) { ///
                    comp <- do.call(rbind, lapply(names(results), function(nm) { ///
                        df <- as.data.frame(results[[nm]]); ///
                        df$method <- nm; ///
                        df ///
                    })); ///
                    ggplot(comp, aes(x=rownames(comp), y=as.numeric(comp[,1]))) + ///
                        geom_bar(stat="identity") + ///
                        theme_minimal() + ///
                        labs(title="EI Comparison") ///
                } ///
            ); ///
            ggsave("`saving_r'", plot=p, width=`width', height=`height'); ///
            cat("SUCCESS\n")
    }
    else if "`type'" == "density" {
        rcall: library(eiCompare); ///
            library(ggplot2); ///
            `seed_cmd' ///
            dat <- read.csv("`datacsv'", stringsAsFactors=FALSE); ///
            cands <- c(`cand_vec'); ///
            races <- c(`race_vec'); ///
            total_col <- "`totals'"; ///
            iter_res <- tryCatch( ///
                ei_iter(data=dat, cand_cols=cands, race_cols=races, total=total_col, erho=`erho'), ///
                error = function(e) stop(paste("EI iter failed:", e$message)) ///
            ); ///
            rxc_res <- tryCatch( ///
                ei_rxc(data=dat, cand_cols=cands, race_cols=races, total=total_col, ///
                       ntunes=`burnin', samples=`samples', thin=`thin'), ///
                error = function(e) NULL ///
            ); ///
            results <- list("Iterative" = iter_res); ///
            if (!is.null(rxc_res)) results[["RxC"]] <- rxc_res; ///
            p <- tryCatch( ///
                overlay_density_plot(results, cand_cols=cands, race_cols=races), ///
                error = function(e) { ///
                    plot(results, cand_cols=cands, race_cols=races) ///
                } ///
            ); ///
            ggsave("`saving_r'", plot=p, width=`width', height=`height'); ///
            cat("SUCCESS\n")
    }
    else if "`type'" == "tomography" {
        rcall: library(eiCompare); ///
            library(ggplot2); ///
            `seed_cmd' ///
            dat <- read.csv("`datacsv'", stringsAsFactors=FALSE); ///
            cands <- c(`cand_vec'); ///
            races <- c(`race_vec'); ///
            total_col <- "`totals'"; ///
            iter_res <- tryCatch( ///
                ei_iter(data=dat, cand_cols=cands, race_cols=races, total=total_col, erho=`erho'), ///
                error = function(e) stop(paste("EI iter failed:", e$message)) ///
            ); ///
            p <- tryCatch( ///
                plot(iter_res, cand_cols=cands, race_cols=races), ///
                error = function(e) { ///
                    ggplot() + labs(title="Tomography plot requires ei_iter results") + theme_minimal() ///
                } ///
            ); ///
            ggsave("`saving_r'", plot=p, width=`width', height=`height'); ///
            cat("SUCCESS\n")
    }

    display as text ""
    display as result "  Plot saved to: `saving'"
    display as text ""
end
