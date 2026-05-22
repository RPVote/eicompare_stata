{smcl}
{* *! version 1.0.0  21may2026}{...}
{viewerjumpto "Syntax" "ei_iter##syntax"}{...}
{viewerjumpto "Description" "ei_iter##description"}{...}
{viewerjumpto "Options" "ei_iter##options"}{...}
{viewerjumpto "Examples" "ei_iter##examples"}{...}
{viewerjumpto "Stored results" "ei_iter##results"}{...}
{viewerjumpto "Author" "ei_iter##author"}{...}
{title:Title}

{phang}
{bf:ei_iter} {hline 2} Iterative EI (King's method) via eiCompare


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ei_iter}
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
{synopt:{opt seed(#)}}random number seed for reproducibility{p_end}
{synopt:{opt erho(#)}}erho parameter; default is {cmd:10}{p_end}
{synopt:{opt ci(#)}}confidence interval level; default is {cmd:0.95}{p_end}
{synopt:{opt name(string)}}label for this analysis{p_end}
{synopt:{opt save_betas}}save precinct-level beta estimates{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ei_iter} performs iterative ecological inference using King's (1997) EI
method, implemented via the {cmd:eiCompare} R package. This method runs
separate 2x2 EI models for each race-candidate pair and aggregates the
results.

{pstd}
{it:candvars} are variables containing vote shares (proportions) for each
candidate. {opt races()} specifies variables containing racial group proportions.
All proportions should be between 0 and 1 (shares of {opt totals()}).

{pstd}
Unlike Goodman's regression, iterative EI produces bounded estimates within
[0,1] and provides measures of uncertainty. However, it assumes a 2x2 table
structure and runs separate models for each pair. For a fully joint model,
see {help ei_rxc}.


{marker options}{...}
{title:Options}

{phang}
{opt races(varlist)} specifies the variables containing racial group proportions. Required.

{phang}
{opt totals(varname)} specifies the total votes/population variable. Required.

{phang}
{opt seed(#)} sets the random number seed in R for reproducibility.

{phang}
{opt erho(#)} sets the erho parameter controlling the grid search density.
Default is 10. Higher values provide finer search but slower computation.

{phang}
{opt ci(#)} sets the confidence interval level. Default is 0.95. Must be
between 0 and 1.

{phang}
{opt name(string)} assigns a label to this analysis for reference.

{phang}
{opt save_betas} requests that precinct-level beta estimates be saved.


{marker examples}{...}
{title:Examples}

{pstd}Basic iterative EI:{p_end}
{phang}{cmd:. ei_iter cand_a cand_b, races(pct_white pct_minority) totals(total_votes)}{p_end}

{pstd}With seed for reproducibility:{p_end}
{phang}{cmd:. ei_iter cand_a cand_b, races(pct_white pct_black pct_hisp) totals(totvotes) seed(12345)}{p_end}

{pstd}Adjusting erho:{p_end}
{phang}{cmd:. ei_iter pct_cand1 pct_cand2, races(pct_white pct_nonwhite) totals(total) erho(20)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:ei_iter} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of rows in results{p_end}
{synopt:{cmd:r(erho)}}erho value used{p_end}
{synopt:{cmd:r(ci)}}confidence interval level{p_end}
{synopt:{cmd:r(seed)}}seed if specified{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(method)}}"iterative"{p_end}
{synopt:{cmd:r(name)}}analysis label if specified{p_end}


{marker author}{...}
{title:Author}

{pstd}Loren Collingwood, University of New Mexico{p_end}
{pstd}Email: {browse "mailto:lcollingwood@unm.edu":lcollingwood@unm.edu}{p_end}

{title:References}

{pstd}King, G. (1997). {it:A Solution to the Ecological Inference Problem.}
Princeton University Press.{p_end}

{title:Also see}

{psee}
{space 2}Help: {help ei_good}, {help ei_rxc}, {help ei_compare}, {help ei_plot}
{p_end}
