{smcl}
{* *! version 1.0.0  21may2026}{...}
{viewerjumpto "Syntax" "ei_setup##syntax"}{...}
{viewerjumpto "Description" "ei_setup##description"}{...}
{viewerjumpto "Options" "ei_setup##options"}{...}
{viewerjumpto "Examples" "ei_setup##examples"}{...}
{viewerjumpto "Author" "ei_setup##author"}{...}
{title:Title}

{phang}
{bf:ei_setup} {hline 2} Check and install eiCompare dependencies


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ei_setup}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt install}}install missing R packages automatically{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ei_setup} verifies that all dependencies required by the eicompare_stata
package are properly installed and configured. It checks for:

{p 8 12 2}1. The {cmd:rcall} Stata package (required for R integration){p_end}
{p 8 12 2}2. A working R installation accessible via {cmd:rcall}{p_end}
{p 8 12 2}3. The {cmd:eiCompare} R package{p_end}
{p 8 12 2}4. Supporting R packages ({cmd:ei}, {cmd:eiPack}){p_end}

{pstd}
Run this command before using any other eicompare_stata commands to ensure
your environment is properly configured.


{marker options}{...}
{title:Options}

{phang}
{opt install} attempts to install any missing R packages automatically.
Without this option, {cmd:ei_setup} only reports which packages are missing.
The {cmd:eiCompare} package is installed from GitHub
(RPVote/eiCompare); other packages are installed from CRAN.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. ei_setup}{p_end}
{pstd}Check all dependencies without installing anything.

{phang}{cmd:. ei_setup, install}{p_end}
{pstd}Check dependencies and install any missing R packages.


{marker author}{...}
{title:Author}

{pstd}Loren Collingwood, University of New Mexico{p_end}
{pstd}Email: {browse "mailto:lcollingwood@unm.edu":lcollingwood@unm.edu}{p_end}
{pstd}GitHub: {browse "https://github.com/RPVote/eiCompare"}{p_end}
