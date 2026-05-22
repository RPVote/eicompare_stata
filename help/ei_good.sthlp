{smcl}
{* *! version 1.0.0  21may2026}{...}
{viewerjumpto "Syntax" "ei_good##syntax"}{...}
{viewerjumpto "Description" "ei_good##description"}{...}
{viewerjumpto "Options" "ei_good##options"}{...}
{viewerjumpto "Examples" "ei_good##examples"}{...}
{viewerjumpto "Stored results" "ei_good##results"}{...}
{viewerjumpto "Author" "ei_good##author"}{...}
{title:Title}

{phang}
{bf:ei_good} {hline 2} Goodman's ecological regression via eiCompare


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ei_good}
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
{synopt:{opt name(string)}}label for this analysis{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ei_good} performs Goodman's ecological regression using the {cmd:eiCompare}
R package. This method estimates vote choice by racial group using a simple
linear ecological regression. It is the fastest and simplest of the three
EI methods available in this package.

{pstd}
{it:candvars} are variables containing vote shares (proportions) for each
candidate. {opt races()} specifies variables containing racial group proportions.
All proportions should be between 0 and 1 (shares of {opt totals()}).

{pstd}
Goodman's regression can produce estimates outside the [0,1] bounds, which
is a known limitation. For bounded estimates, consider {help ei_iter} or
{help ei_rxc}.


{marker options}{...}
{title:Options}

{phang}
{opt races(varlist)} specifies the variables containing racial group proportions
(e.g., pct_white pct_black pct_hispanic). Required.

{phang}
{opt totals(varname)} specifies the variable containing total votes or total
population for each precinct/unit. Required.

{phang}
{opt name(string)} assigns a label to this analysis for reference.


{marker examples}{...}
{title:Examples}

{pstd}Basic Goodman's regression with two candidates and two racial groups:{p_end}
{phang}{cmd:. ei_good cand_a cand_b, races(pct_white pct_minority) totals(total_votes)}{p_end}

{pstd}Three candidates, three racial groups:{p_end}
{phang}{cmd:. ei_good pct_cand1 pct_cand2 pct_cand3, races(pct_white pct_black pct_hisp) totals(totvotes)}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:ei_good} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of rows in results{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(method)}}"goodman"{p_end}
{synopt:{cmd:r(name)}}analysis label if specified{p_end}


{marker author}{...}
{title:Author}

{pstd}Loren Collingwood, University of New Mexico{p_end}
{pstd}Email: {browse "mailto:lcollingwood@unm.edu":lcollingwood@unm.edu}{p_end}

{title:Also see}

{psee}
{space 2}Help: {help ei_iter}, {help ei_rxc}, {help ei_compare}, {help ei_plot}
{p_end}
