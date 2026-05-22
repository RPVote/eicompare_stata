{smcl}
{* *! version 1.0.0  21may2026}{...}
{viewerjumpto "Syntax" "ei_compare##syntax"}{...}
{viewerjumpto "Description" "ei_compare##description"}{...}
{viewerjumpto "Options" "ei_compare##options"}{...}
{viewerjumpto "Examples" "ei_compare##examples"}{...}
{viewerjumpto "Stored results" "ei_compare##results"}{...}
{viewerjumpto "Author" "ei_compare##author"}{...}
{title:Title}

{phang}
{bf:ei_compare} {hline 2} Compare EI methods via eiCompare


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ei_compare}
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
{synopt:{opt methods(string)}}which methods to compare; default is {cmd:"all"}{p_end}
{synopt:{opt erho(#)}}erho for iterative EI; default is {cmd:10}{p_end}
{synopt:{opt sam:ples(#)}}MCMC samples for RxC; default is {cmd:10000}{p_end}
{synopt:{opt bur:nin(#)}}MCMC burn-in for RxC; default is {cmd:5000}{p_end}
{synopt:{opt thin(#)}}MCMC thinning for RxC; default is {cmd:1}{p_end}
{synopt:{opt name(string)}}label for this analysis{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ei_compare} runs multiple ecological inference methods and produces a
side-by-side comparison table. By default, it runs all three methods
(Goodman's regression, iterative EI, and RxC Bayesian EI) and uses
{cmd:eiCompare}'s {cmd:ei_rc_good_table()} function to create the comparison.

{pstd}
This is the recommended command for racially polarized voting (RPV) analysis,
as comparing across methods provides a more robust assessment than relying
on any single method.


{marker options}{...}
{title:Options}

{phang}
{opt races(varlist)} specifies the variables containing racial group proportions. Required.

{phang}
{opt totals(varname)} specifies the total votes/population variable. Required.

{phang}
{opt seed(#)} sets the random number seed for reproducibility.

{phang}
{opt methods(string)} specifies which methods to run. Options:{p_end}
{p 12 16 2}{cmd:"all"} - Goodman, iterative, and RxC (default){p_end}
{p 12 16 2}{cmd:"good iter"} - Goodman and iterative only{p_end}
{p 12 16 2}{cmd:"good rxc"} - Goodman and RxC only{p_end}
{p 12 16 2}{cmd:"iter rxc"} - iterative and RxC only{p_end}

{phang}
{opt erho(#)} sets the erho parameter for iterative EI. Default is 10.

{phang}
{opt samples(#)} number of MCMC samples for RxC. Default is 10000.

{phang}
{opt burnin(#)} MCMC burn-in for RxC. Default is 5000.

{phang}
{opt thin(#)} MCMC thinning for RxC. Default is 1.

{phang}
{opt name(string)} assigns a label to this analysis.


{marker examples}{...}
{title:Examples}

{pstd}Compare all three methods:{p_end}
{phang}{cmd:. ei_compare cand_a cand_b, races(pct_white pct_black pct_hisp) totals(totvotes) seed(42)}{p_end}

{pstd}Compare only Goodman and iterative (faster):{p_end}
{phang}{cmd:. ei_compare cand_a cand_b, races(pct_white pct_minority) totals(total) methods("good iter")}{p_end}

{pstd}All methods with tuned MCMC parameters:{p_end}
{phang}{cmd:. ei_compare cand_a cand_b, races(pct_w pct_b pct_h) totals(tot) samples(20000) burnin(10000) thin(2)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:ei_compare} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of rows in comparison table{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(methods)}}methods that were compared{p_end}
{synopt:{cmd:r(name)}}analysis label if specified{p_end}


{marker author}{...}
{title:Author}

{pstd}Loren Collingwood, University of New Mexico{p_end}
{pstd}Email: {browse "mailto:lcollingwood@unm.edu":lcollingwood@unm.edu}{p_end}

{title:Also see}

{psee}
{space 2}Help: {help ei_good}, {help ei_iter}, {help ei_rxc}, {help ei_plot}
{p_end}
