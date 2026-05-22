{smcl}
{* *! version 1.0.0  21may2026}{...}
{viewerjumpto "Syntax" "ei_plot##syntax"}{...}
{viewerjumpto "Description" "ei_plot##description"}{...}
{viewerjumpto "Options" "ei_plot##options"}{...}
{viewerjumpto "Examples" "ei_plot##examples"}{...}
{viewerjumpto "Author" "ei_plot##author"}{...}
{title:Title}

{phang}
{bf:ei_plot} {hline 2} Visualize EI results via eiCompare


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ei_plot}
{it:candvars}
{cmd:,} {opt r:aces(varlist)} {opt t:otals(varname)} {opt sav:ing(filename)}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt r:aces(varlist)}}variables containing racial group proportions{p_end}
{synopt:{opt t:otals(varname)}}variable containing total votes or population{p_end}
{synopt:{opt sav:ing(filename)}}output file path (PDF, PNG, or JPG){p_end}
{syntab:Optional}
{synopt:{opt type(string)}}plot type: {cmd:comparison}, {cmd:density}, or {cmd:tomography}; default is {cmd:comparison}{p_end}
{synopt:{opt seed(#)}}random number seed{p_end}
{synopt:{opt erho(#)}}erho for iterative EI; default is {cmd:10}{p_end}
{synopt:{opt sam:ples(#)}}MCMC samples for RxC; default is {cmd:10000}{p_end}
{synopt:{opt bur:nin(#)}}MCMC burn-in for RxC; default is {cmd:5000}{p_end}
{synopt:{opt thin(#)}}MCMC thinning for RxC; default is {cmd:1}{p_end}
{synopt:{opt width(#)}}plot width in inches; default is {cmd:8}{p_end}
{synopt:{opt height(#)}}plot height in inches; default is {cmd:6}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ei_plot} generates visualizations of ecological inference results using
the {cmd:eiCompare} R package's plotting functions. The command runs the
necessary EI methods and produces publication-quality plots saved to a file.

{pstd}
Three plot types are available:

{p 8 12 2}{cmd:comparison} - bar chart comparing estimates across methods
(runs all three EI methods){p_end}
{p 8 12 2}{cmd:density} - overlay density plots of posterior distributions
from iterative and RxC EI{p_end}
{p 8 12 2}{cmd:tomography} - tomography plot from iterative EI showing
the bounds and estimates{p_end}

{pstd}
The output format is determined by the file extension of {opt saving()}.
Supported formats: PDF (.pdf), PNG (.png), JPG (.jpg). If no extension is
provided, PDF is used.


{marker options}{...}
{title:Options}

{phang}
{opt races(varlist)} specifies the variables containing racial group proportions. Required.

{phang}
{opt totals(varname)} specifies the total votes/population variable. Required.

{phang}
{opt saving(filename)} file path for the output plot. Include extension
(.pdf, .png, .jpg) to specify format. Required.

{phang}
{opt type(string)} plot type. Default is {cmd:comparison}.

{phang}
{opt seed(#)} random number seed for reproducibility.

{phang}
{opt erho(#)} erho parameter for iterative EI. Default is 10.

{phang}
{opt samples(#)} MCMC samples for RxC. Default is 10000.

{phang}
{opt burnin(#)} MCMC burn-in for RxC. Default is 5000.

{phang}
{opt thin(#)} MCMC thinning for RxC. Default is 1.

{phang}
{opt width(#)} plot width in inches. Default is 8.

{phang}
{opt height(#)} plot height in inches. Default is 6.


{marker examples}{...}
{title:Examples}

{pstd}Comparison plot saved to PDF:{p_end}
{phang}{cmd:. ei_plot cand_a cand_b, races(pct_white pct_black) totals(total) saving(ei_comparison.pdf)}{p_end}

{pstd}Density plot saved to PNG:{p_end}
{phang}{cmd:. ei_plot cand_a cand_b, races(pct_white pct_minority) totals(total) type(density) saving(density.png) seed(42)}{p_end}

{pstd}Tomography plot:{p_end}
{phang}{cmd:. ei_plot cand_a cand_b, races(pct_white pct_black) totals(total) type(tomography) saving(tomo.pdf)}{p_end}

{pstd}Custom dimensions:{p_end}
{phang}{cmd:. ei_plot cand_a cand_b, races(pct_w pct_b) totals(tot) saving(wide.pdf) width(12) height(4)}{p_end}


{marker author}{...}
{title:Author}

{pstd}Loren Collingwood, University of New Mexico{p_end}
{pstd}Email: {browse "mailto:lcollingwood@unm.edu":lcollingwood@unm.edu}{p_end}

{title:Also see}

{psee}
{space 2}Help: {help ei_good}, {help ei_iter}, {help ei_rxc}, {help ei_compare}
{p_end}
