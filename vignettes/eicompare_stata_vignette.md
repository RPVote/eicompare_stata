# eicompare_stata: A Stata Interface for Ecological Inference

## Introduction

Ecological inference (EI) is a statistical method for estimating individual-level behavior from aggregate data. In voting rights analysis, EI is used to estimate how different racial groups voted when individual-level vote-by-race data is unavailable — which is nearly always the case, since ballots are secret.

`eicompare_stata` provides a Stata interface to the [eiCompare](https://github.com/RPVote/eiCompare) R package, allowing researchers and practitioners to run three standard EI methods directly from Stata without writing any R code.

### The Three Methods

| Method | Function | Strengths | Limitations |
|---|---|---|---|
| **Goodman's regression** | `ei_good` | Fast, simple, easy to interpret | Can produce estimates outside [0, 1] |
| **Iterative EI** (King 1997) | `ei_iter` | Bounded estimates, uncertainty measures | Assumes 2×2 structure; runs pairwise |
| **RxC Bayesian EI** (Rosen et al. 2001) | `ei_rxc` | Joint estimation, handles full R×C table | Computationally intensive (MCMC) |

In practice, analysts run all three and compare. Convergence across methods strengthens conclusions about racially polarized voting (RPV).

---

## 1. Setup and Installation

### Prerequisites

You need:

1. **Stata 14 or later**
2. **R 4.0 or later** — download from [r-project.org](https://www.r-project.org/)
3. **rcall** — a Stata package that calls R from within Stata

### Install `rcall`

```stata
* Install the github package manager (if you don't have it)
net install github, from("https://haghish.github.io/github/")

* Install rcall
github install haghish/rcall
```

If `rcall` cannot find R, point it to your R installation:

```stata
rcall setpath "/usr/local/bin/R"          // macOS/Linux
rcall setpath "C:\Program Files\R\R-4.3.0\bin\R.exe"  // Windows
```

### Install `eicompare_stata`

```stata
github install RPVote/eicompare_stata
```

### Verify everything works

```stata
ei_setup, install
```

You should see:

```
------------------------------------------------------------
  eicompare_stata: Setup and Dependency Check
------------------------------------------------------------

  [OK] rcall is installed
  [OK] R is accessible
  [OK] eiCompare R package found
  eiCompare version: 3.0.5
  [OK] ei found
  [OK] eiPack found

------------------------------------------------------------
  eicompare_stata is ready to use.
------------------------------------------------------------
```

If any package is missing, the `install` option will attempt to install it automatically.

---

## 2. Data Preparation

EI requires precinct-level data with three types of variables:

### Candidate vote share variables

Each candidate needs a variable containing their **proportion** of the total vote in each precinct. These must sum to 1 across candidates within each precinct.

```
cand_a = (votes for candidate A) / total_votes
cand_b = (votes for candidate B) / total_votes
```

### Racial group proportion variables

Each racial group needs a variable containing its **proportion** of the total population (or voting-age population) in each precinct. These must sum to 1 across groups within each precinct.

```
pct_white = (white pop) / total_pop
pct_black = (black pop) / total_pop
pct_hisp  = (hispanic pop) / total_pop
```

### Total variable

A variable containing the total number of votes cast (or total population) per precinct.

### Example data creation

```stata
clear all
set seed 54321
set obs 100

* Racial composition (proportions summing to 1)
generate pct_white = runiform(0.1, 0.7)
generate pct_black = runiform(0.05, 0.35)
generate pct_hisp  = runiform(0.05, 0.25)

* Normalize so they sum to 1
generate race_total = pct_white + pct_black + pct_hisp
replace pct_white = pct_white / race_total
replace pct_black = pct_black / race_total
replace pct_hisp  = pct_hisp  / race_total
drop race_total

* Total voters per precinct
generate total_votes = round(runiform(300, 3000))

* Candidate vote shares (proportions summing to 1)
* Simulate racially polarized voting: candidate A preferred by white voters
generate cand_a = 0.3 * pct_white + 0.7 * pct_black + 0.5 * pct_hisp ///
    + rnormal(0, 0.03)
replace cand_a = max(0.01, min(0.99, cand_a))
generate cand_b = 1 - cand_a

summarize pct_white pct_black pct_hisp cand_a cand_b total_votes
```

### Common data issues

| Problem | Symptom | Fix |
|---|---|---|
| Proportions don't sum to 1 | R error or biased estimates | Normalize: `replace x = x / (x + y + z)` |
| Missing values | Command fails | `drop if missing(cand_a)` |
| Proportions > 1 or < 0 | Nonsensical results | Verify data construction |
| Too few precincts | Unstable estimates | EI works best with 30+ precincts |

---

## 3. Goodman's Ecological Regression

Goodman's regression is the simplest and fastest method. It fits a linear regression of candidate vote share on racial group proportions.

### Syntax

```stata
ei_good candvars, races(varlist) totals(varname) [name(string)]
```

### Example

```stata
ei_good cand_a cand_b, races(pct_white pct_black pct_hisp) totals(total_votes)
```

### Output

The results table shows estimated vote shares for each candidate within each racial group. For example:

| | cand_a | cand_b |
|---|---|---|
| pct_white | 0.32 | 0.68 |
| pct_black | 0.71 | 0.29 |
| pct_hisp | 0.48 | 0.52 |

### Interpretation

Each cell is the estimated proportion of a racial group's voters who voted for a given candidate. In this example, an estimated 71% of Black voters chose candidate A, while only 32% of white voters did — suggestive of racially polarized voting.

### Caveats

Goodman's regression can produce estimates below 0 or above 1, which are substantively impossible. This is a well-known limitation of the linear approach. When this happens, the estimates should be interpreted cautiously and compared against bounded methods (iterative EI or RxC).

---

## 4. Iterative EI (King's Method)

King's (1997) iterative EI method runs a series of 2×2 EI models — one for each combination of candidate and racial group — and aggregates the results. Unlike Goodman's method, estimates are bounded within [0, 1].

### Syntax

```stata
ei_iter candvars, races(varlist) totals(varname) ///
    [seed(#) erho(#) ci(#) name(string) save_betas]
```

### Key options

- **seed(#)** — Set a random number seed for reproducibility. Recommended.
- **erho(#)** — Controls the density of the grid search over the prior. Default is 10. Higher values are more thorough but slower.
- **ci(#)** — Confidence interval level. Default is 0.95.

### Example

```stata
ei_iter cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) seed(12345)
```

### Interpretation

The output table shows point estimates (posterior means) for each race-candidate cell. Because iterative EI runs 2×2 models, it handles each racial group separately. This means it does not enforce the constraint that vote shares across racial groups must aggregate to the observed precinct total — a limitation addressed by RxC EI.

---

## 5. RxC Bayesian EI

RxC Bayesian EI (Rosen et al. 2001) estimates the full R×C table jointly using Markov Chain Monte Carlo (MCMC) sampling. This is the most principled method but also the most computationally demanding.

### Syntax

```stata
ei_rxc candvars, races(varlist) totals(varname) ///
    [seed(#) samples(#) burnin(#) thin(#) ci(#) nchains(#) name(string)]
```

### Key options

- **samples(#)** — Number of posterior samples to draw after burn-in. Default: 10,000.
- **burnin(#)** — Number of initial iterations to discard. Default: 5,000.
- **thin(#)** — Keep every nth sample to reduce autocorrelation. Default: 1 (no thinning).
- **nchains(#)** — Number of MCMC chains. Default: 1.

### Example

```stata
ei_rxc cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) seed(12345) samples(10000) burnin(5000)
```

### Tuning advice

| Scenario | Recommendation |
|---|---|
| Exploratory analysis | `samples(5000) burnin(2000)` |
| Publication/litigation | `samples(20000) burnin(10000) thin(2)` |
| Convergence concerns | Increase `burnin`, add `thin(5)`, try `nchains(2)` |

### When to prefer RxC over iterative EI

- When you have more than 2 candidates or more than 2 racial groups and want joint estimation
- When you need the full posterior distribution for credible intervals
- When the 2×2 pairwise approach of iterative EI produces inconsistent results

---

## 6. Comparing Methods

The `ei_compare` command runs multiple methods and presents results side by side. This is the standard approach for RPV analysis.

### Syntax

```stata
ei_compare candvars, races(varlist) totals(varname) ///
    [seed(#) methods(string) erho(#) samples(#) burnin(#) thin(#) name(string)]
```

### Example: all three methods

```stata
ei_compare cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) seed(12345)
```

### Example: Goodman and iterative only (faster)

```stata
ei_compare cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) methods("good iter")
```

### Interpreting the comparison

When all three methods produce similar estimates, you can be more confident in the conclusions. Large discrepancies — especially between Goodman's and the Bayesian methods — may indicate violations of the ecological regression assumptions (e.g., nonlinear relationships between race and vote choice).

For RPV analysis under Section 2 of the Voting Rights Act, courts generally look for evidence that:

1. **The minority-preferred candidate is identifiable** — one candidate receives a clear majority of minority votes.
2. **Voting is racially polarized** — white voters and minority voters prefer different candidates.
3. **Results are consistent across methods** — convergence strengthens the finding.

---

## 7. Visualization

The `ei_plot` command generates plots of EI results saved to PDF, PNG, or JPG.

### Syntax

```stata
ei_plot candvars, races(varlist) totals(varname) saving(filename) ///
    [type(string) seed(#) erho(#) samples(#) burnin(#) thin(#) ///
     width(#) height(#)]
```

### Plot types

| Type | Description | Methods used |
|---|---|---|
| `comparison` | Bar chart comparing estimates across all methods | Goodman + Iter + RxC |
| `density` | Overlay density plots of posterior distributions | Iter + RxC |
| `tomography` | Tomography plot showing bounds and point estimates | Iter only |

### Examples

```stata
* Comparison bar chart (default)
ei_plot cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) saving(comparison.pdf) seed(12345)

* Density plot showing posteriors
ei_plot cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) saving(density.png) type(density) seed(12345)

* Tomography plot
ei_plot cand_a cand_b, races(pct_white pct_black pct_hisp) ///
    totals(total_votes) saving(tomography.pdf) type(tomography) seed(12345)

* Custom dimensions for a wide figure
ei_plot cand_a cand_b, races(pct_white pct_black) ///
    totals(total_votes) saving(wide_plot.pdf) width(12) height(5) seed(12345)
```

---

## 8. Practical Workflow for RPV Analysis

A typical RPV analysis follows this workflow:

```stata
* =========================================================
* RPV Analysis Workflow
* =========================================================

* 1. Load precinct-level election data
use election_data, clear

* 2. Verify the data
summarize cand_* pct_* total_votes
assert abs(cand_a + cand_b - 1) < 0.001        // candidates sum to 1
assert abs(pct_white + pct_black + pct_hisp - 1) < 0.001  // races sum to 1

* 3. Run all three EI methods with comparison
ei_compare cand_a cand_b, ///
    races(pct_white pct_black pct_hisp) ///
    totals(total_votes) ///
    seed(12345) ///
    samples(20000) burnin(10000)

* 4. Generate comparison plot for the report
ei_plot cand_a cand_b, ///
    races(pct_white pct_black pct_hisp) ///
    totals(total_votes) ///
    saving(rpv_comparison.pdf) ///
    seed(12345) ///
    samples(20000) burnin(10000)

* 5. Generate density plot showing uncertainty
ei_plot cand_a cand_b, ///
    races(pct_white pct_black pct_hisp) ///
    totals(total_votes) ///
    type(density) ///
    saving(rpv_density.pdf) ///
    seed(12345) ///
    samples(20000) burnin(10000)
```

### Reporting checklist

When presenting EI results in a report or expert declaration:

- [ ] State which methods were used and why
- [ ] Report point estimates from all methods
- [ ] Note consistency or inconsistency across methods
- [ ] Report confidence/credible intervals where available
- [ ] Specify the random seed used for reproducibility
- [ ] Describe the data source and any preprocessing (e.g., merging ACS demographics with election returns)
- [ ] Note the number of precincts analyzed
- [ ] Include comparison plots

---

## 9. Troubleshooting

### `rcall is not installed`

Install rcall:

```stata
github install haghish/rcall
```

### `R is not accessible via rcall`

R may not be on your system PATH. Set the path explicitly:

```stata
rcall setpath "/usr/local/bin/R"                           // macOS (Homebrew)
rcall setpath "/Library/Frameworks/R.framework/Resources/R" // macOS (CRAN installer)
rcall setpath "C:\Program Files\R\R-4.3.0\bin\R.exe"       // Windows
```

### `eiCompare R package is not installed`

```stata
ei_setup, install
```

Or install manually in R:

```r
install.packages("remotes")
remotes::install_github("RPVote/eiCompare")
```

### `ei_good() error` or `ei_iter() error`

Common causes:

1. **Proportions don't sum to 1**: Check your candidate and race variables.
2. **Missing values**: Drop observations with missing data before running EI.
3. **Zero totals**: Remove precincts with zero votes.
4. **Too few observations**: EI needs a reasonable number of precincts (30+).

### MCMC is very slow

For RxC EI, reduce computational burden:

```stata
* Faster (exploratory)
ei_rxc cand_a cand_b, races(pct_white pct_black) totals(total) ///
    samples(5000) burnin(2000) thin(1) seed(42)
```

---

## 10. References

- King, G. (1997). *A Solution to the Ecological Inference Problem: Reconstructing Individual Behavior from Aggregate Data*. Princeton University Press.

- Rosen, O., Jiang, W., King, G., & Tanner, M.A. (2001). Bayesian and frequentist inference for ecological inference: The R×C case. *Statistica Neerlandica*, 55(2), 134–156.

- Goodman, L.A. (1953). Ecological regressions and behavior of individuals. *American Sociological Review*, 18(6), 663–664.

- Collingwood, L., Oskooii, K., Garcia, S., & Barreto, M. (2020). eiCompare: Comparing ecological inference estimates across EI and EI:RC. R package. https://github.com/RPVote/eiCompare

- Barreto, M., Collingwood, L., Garcia-Rios, S., & Oskooii, K. (2022). Estimating candidate support in voting rights cases: Comparing iterative EI and EI-RxC methods. *Sociological Methods & Research*, 51(4), 1512–1541.

---

*eicompare_stata v1.0.0 — Loren Collingwood, University of New Mexico*
