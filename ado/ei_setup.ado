*! ei_setup v1.0.0 - Check and install eiCompare dependencies
*! Author: Loren Collingwood
*! Date: 2026-05-21

program define ei_setup
    version 14.0
    syntax [, Install]

    display as text ""
    display as text "{hline 60}"
    display as text "  eicompare_stata: Setup and Dependency Check"
    display as text "{hline 60}"
    display as text ""

    * -----------------------------------------------
    * Step 1: Check that rcall is installed in Stata
    * -----------------------------------------------
    capture which rcall
    if _rc != 0 {
        display as error "rcall is not installed."
        display as error "Install it with: github install haghish/rcall"
        exit 198
    }
    display as result "  [OK] rcall is installed"

    * -----------------------------------------------
    * Step 2: Check that R is accessible via rcall
    * -----------------------------------------------
    capture rcall: cat(paste0("R version: ", R.version.string, "\n"))
    if _rc != 0 {
        display as error "R is not accessible via rcall."
        display as error "Make sure R is installed and rcall can find it."
        display as error "Try: rcall setpath /usr/local/bin/R"
        exit 198
    }
    display as result "  [OK] R is accessible"

    * -----------------------------------------------
    * Step 3: Check for eiCompare R package
    * -----------------------------------------------
    capture rcall: if (!requireNamespace("eiCompare", quietly=TRUE)) stop("not installed")
    if _rc != 0 {
        if "`install'" != "" {
            display as text "  Installing eiCompare from GitHub..."
            capture rcall: remotes::install_github("RPVote/eiCompare", quiet=TRUE)
            if _rc != 0 {
                display as error "Failed to install eiCompare."
                display as error "Try installing manually in R:"
                display as error "  remotes::install_github('RPVote/eiCompare')"
                exit 198
            }
            display as result "  [OK] eiCompare installed successfully"
        }
        else {
            display as error "eiCompare R package is not installed."
            display as error "Run: ei_setup, install"
            display as error "Or install manually in R:"
            display as error "  remotes::install_github('RPVote/eiCompare')"
            exit 198
        }
    }
    else {
        display as result "  [OK] eiCompare R package found"
    }

    * -----------------------------------------------
    * Step 4: Check eiCompare version
    * -----------------------------------------------
    rcall: cat(paste0("eiCompare version: ", ///
        packageVersion("eiCompare"), "\n"))

    * -----------------------------------------------
    * Step 5: Check for key dependencies
    * -----------------------------------------------
    local deps ei eiPack
    foreach pkg of local deps {
        capture rcall: if (!requireNamespace("`pkg'", quietly=TRUE)) stop("missing")
        if _rc != 0 {
            if "`install'" != "" {
                display as text "  Installing `pkg'..."
                capture rcall: install.packages("`pkg'", quiet=TRUE, ///
                    repos="https://cloud.r-project.org")
                if _rc != 0 {
                    display as error "  Failed to install `pkg'"
                }
                else {
                    display as result "  [OK] `pkg' installed"
                }
            }
            else {
                display as text "  [MISSING] `pkg' - run ei_setup, install"
            }
        }
        else {
            display as result "  [OK] `pkg' found"
        }
    }

    display as text ""
    display as text "{hline 60}"
    display as result "  eicompare_stata is ready to use."
    display as text "{hline 60}"
    display as text ""
    display as text "  Available commands:"
    display as text "    ei_good    - Goodman's ecological regression"
    display as text "    ei_iter    - Iterative EI (King's method)"
    display as text "    ei_rxc     - RxC Bayesian EI"
    display as text "    ei_compare - Compare all methods"
    display as text "    ei_plot    - Visualize EI results"
    display as text ""
end
