{smcl}
{* *! version 1.0.0  21may2026}{...}
{viewerjumpto "Syntax" "ei_rxc##syntax"}{...}
{viewerjumpto "Description" "ei_rxc##description"}{...}
{viewerjumpto "Options" "ei_rxc##options"}{...}
{viewerjumpto "Examples" "ei_rxc##examples"}{...}
{viewerjumpto "Stored results" "ei_rxc##results"}{...}
{viewerjumpto "Author" "ei_rxc##author"}{...}
{title:Title}

{phang}
{bf:ei_rxc} {hline 2} RxC Bayesian ecological inference via eiCompare


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ei_rxc}
{it:candvars}
{cmd:,} {opt r:aces(varlist)} {opt t:otals(varname)}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt r:aces(varlist)}}variables containing racial group proportions{p_end}
{synopt:{opt t:otals(varname)}}variable containing total votes or population{p_end}
{syntab:Optional}
{synopt:{opt seed(#)}}random number seed{p_end}
{synopt:{opt sam:ples(#)}}number of MCMC samples; default is {cmd:10000}{p_end}
{synopt:{opt bur:nin(#)}}number of burn-in iterations; default is {cmd:5000}{p_end}
{synopt:{opt thin(#)}}thinning interval; default is {cmd:1}{p_end}
{synopt:{opt ci(#)}}confidence interval level; default is {cmd:0.95}{p_end}
{synopt:{opt nchains(#)}}number of MCMC chains; default is {cmd:1}{p_end}
{synopt:{opt name(string)}}label for this analysis{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ei_rxc} performs RxC Bayesian ecological inference using Markov Chain
Monte Carlo (MCMC) estimation via the {cmd:eiCompare} R package. Unlike
iterative EI, this method jointly estimates the full RxC table of vote
proportions by racial group, making it suitable for multi-candidate,
multi-racial-group elections.

{pstd}
{it:candvars} are variables containing vote shares (proportions) for each
candidate. {opt races()} specifies variables containing racial group proportions.
All proportions should be between 0 and 1 (shares of {opt totals()}).

{pstd}
RxC EI uses MCMC sampling and can be computationally intensive. The
{opt samples()}, {opt burnin()}, and {opt thin()} options control the
MCMC parameters. For quick exploratory analysis, reduce the number of
samples.


{marker options}{...}
{title:Options}

{phang}
{opt races(varlist)} specifies the variables containing racial group proportions. Required.

{phang}
{opt totals(varname)} specifies the total votes/population variable. Required.

{phang}
{opt seed(#)} sets the random number seed for reproducibility.

{phang}
{opt samples(#)} number of MCMC posterior samples to draw after burn-in.
Default is 10000.

{phang}
{opt burnin(#)} number of initial tuning/burn-in iterations discarded before
sampling. Default is 5000.

{phang}
{opt thin(#)} thinning interval for MCMC samples. Default is 1 (no thinning).

{phang}
{opt ci(#)} confidence interval level. Default is 0.95. Must be between 0 and 1.

{phang}
{opt nchains(#)} number of MCMC chains to run. Default is 1.

{phang}
{opt name(string)} assigns a label to this analysis.


{marker examples}{...}
{title:Examples}

{pstd}Basic RxC EI with defaults:{p_end}
{phang}{cmd:. ei_rxc cand_a cand_b, races(pct_white pct_black pct_hisp) totals(totvotes)}{p_end}

{pstd}Faster run with fewer samples:{p_end}
{phang}{cmd:. ei_rxc cand_a cand_b, races(pct_white pct_minority) totals(total) samples(5000) burnin(2000)}{p_end}

{pstd}With seed and thinning:{p_end}
{phang}{cmd:. ei_rxc cand_a cand_b cand_c, races(pct_white pct_black pct_hisp) totals(total) seed(42) thin(5)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:ei_rxc} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of rows in results{p_end}
{synopt:{cmd:r(samples)}}number of MCMC samples{p_end}
{synopt:{cmd:r(burnin)}}number of burn-in iterations{p_end}
{synopt:{cmd:r(thin)}}thinning interval{p_end}
{synopt:{cmd:r(ci)}}confidence interval level{p_end}
{synopt:{cmd:r(seed)}}seed if specified{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(method)}}"rxc"{p_end}
{synopt:{cmd:r(name)}}analysis label if specified{p_end}


{marker author}{...}
{title:Author}

{pstd}Loren Collingwood, University of New Mexico{p_end}
{pstd}Email: {browse "mailto:lcollingwood@unm.edu":lcollingwood@unm.edu}{p_end}

{title:References}

{pstd}Rosen, O., Jiang, W., King, G., & Tanner, M.A. (2001). Bayesian and
frequentist inference for ecological inference: The RxC case.
{it:Statistica Neerlandica}, 55(2), 134-156.{p_end}

{title:Also see}

{psee}
{space 2}Help: {help ei_good}, {help ei_iter}, {help ei_compare}, {help ei_plot}
{p_end}
