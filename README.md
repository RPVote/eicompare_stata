# eicompare_stata

Stata wrapper for the [eiCompare](https://github.com/RPVote/eiCompare) R package via [`rcall`](https://github.com/haghish/rcall). Provides Stata commands for ecological inference (EI) analysis commonly used in racially polarized voting (RPV) litigation and research.

## Overview

`eicompare_stata` brings the full power of the eiCompare R package to Stata users without requiring any R programming. It supports three standard EI methods:

- **Goodman's ecological regression** — fast, linear, can produce out-of-bounds estimates
- **Iterative EI (King's method)** — bounded 2×2 EI with uncertainty measures
- **RxC Bayesian EI** — joint multi-candidate, multi-group MCMC estimation

The package also provides commands for side-by-side method comparison and visualization.

## Requirements

| Requirement | Minimum Version |
|---|---|
| Stata | 14.0+ |
| R | 4.0+ |
| `rcall` (Stata) | latest |
| `eiCompare` (R) | 3.0.6+ |

## Installation

### Step 1: Install `rcall`

```stata
github install haghish/rcall
```

If you don't have the `github` command:

```stata
net install github, from("https://haghish.github.io/github/")
github install haghish/rcall
```

### Step 2: Install `eicompare_stata`

```stata
github install RPVote/eicompare_stata
```

Or from a local copy:

```stata
net install eicompare_stata, from("/path/to/eicompare_stata")
```

### Step 3: Verify setup and install R dependencies

```stata
ei_setup, install
```

This checks that R is accessible, verifies `rcall` works, and installs the `eiCompare`, `ei`, and `eiPack` R packages if they are missing.

## Commands

| Command | Description |
|---|---|
| `ei_setup` | Check and install dependencies |
| `ei_good` | Goodman's ecological regression |
| `ei_iter` | Iterative EI (King's method) |
| `ei_rxc` | RxC Bayesian EI (MCMC) |
| `ei_compare` | Compare results across methods |
| `ei_plot` | Visualize EI results |

## Quick Start

```stata
* Verify dependencies
ei_setup

* Load your election data (precinct-level with vote shares and demographic shares)
use my_election_data, clear

* Run Goodman's regression
ei_good cand_a cand_b, races(pct_white pct_black pct_hisp) totals(total_votes)

* Run iterative EI
ei_iter cand_a cand_b, races(pct_white pct_black pct_hisp) totals(total_votes) seed(12345)

* Run RxC Bayesian EI
ei_rxc cand_a cand_b, races(pct_white pct_black pct_hisp) totals(total_votes) seed(12345)

* Compare all three methods
ei_compare cand_a cand_b, races(pct_white pct_black pct_hisp) totals(total_votes) seed(12345)

* Generate a comparison plot
ei_plot cand_a cand_b, races(pct_white pct_black pct_hisp) totals(total_votes) ///
    saving(ei_results.pdf) seed(12345)
```

See the full **[vignette](vignettes/eicompare_stata_vignette.md)** for a detailed walkthrough with real-world guidance.

## Vignette

The package includes a comprehensive vignette covering:

- Data preparation and variable requirements
- Running each EI method with explanation of parameters
- Interpreting results
- Comparing methods for RPV analysis
- Visualization options
- Practical tips for Voting Rights Act Section 2 litigation

Read the full vignette: **[eicompare_stata_vignette.md](vignettes/eicompare_stata_vignette.md)**

## How It Works

Each Stata command:

1. Exports the current dataset to a temporary CSV
2. Calls the corresponding eiCompare R function via `rcall`
3. Imports the results back into Stata
4. Displays a formatted results table
5. Stores key values in `r()` for programmatic use

No R coding is required — the `.ado` files handle all R code generation internally.

## Data Requirements

Your dataset should contain precinct-level data with:

- **Candidate variables**: Vote shares as proportions (0 to 1) for each candidate. Must sum to 1 within each precinct.
- **Race variables**: Demographic group shares as proportions (0 to 1). Must sum to 1 within each precinct.
- **Totals variable**: Total number of votes (or voting-age population) per precinct.

## Citation

If you use this package, please cite both `eicompare_stata` and the underlying R package:

```
Collingwood, L. (2026). eicompare_stata: Stata wrapper for the eiCompare R package.
  https://github.com/RPVote/eicompare_stata

Collingwood, L., Oskooii, K., Garcia, S., & Barreto, M. (2020). eiCompare: Comparing
  ecological inference estimates across EI and EI:RC. R package.
  https://github.com/RPVote/eiCompare
```

## Author

Loren Collingwood, University of New Mexico
Email: lcollingwood@unm.edu

## License

MIT
