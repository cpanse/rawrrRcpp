# rawrrRcpp

## links

* https://fgcz-intranet.uzh.ch/tiki-index.php?page=rawrrR.cpp

* https://www.denbi.de/news/1299-3rd-de-nbi-elixir-de-metarbolomics-hackathon



<table>

<tr style="border:2px solid black">
<td style="padding:15px">
R>
</td>
</tr>

<tr style="border:2px solid black">
<td style="padding:15px">
Rcpp module
</td>
</tr>

<tr style="background-color:yellow;color:black; border:2px solid black">
<td style="padding:15px">
C++ code
</td>
</tr>

<tr style="background-color:yellowgreen;color:black; border:2px solid black">
<td style="padding:15px">
Mono Runtime - linking `libmono-2`
</td>
</tr>

<tr style="background-color:orange;color:black; border:2px solid black">
<td style="padding:15px">
Managed Assembly
(CIL/.NET code)
</td>
</tr>

<tr style="background-color:orange;color:black; border:2px solid black">
<td style="padding:15px">
ThermoFisher.CommonCore.*.dll
</td>
</tr>

</table>

```{r prx, echo=FALSE, out.width="100%", error=TRUE, fig.align='center'}

```{r}
.readSpectrumRcpp <- function(rawfile, scan){
    R <- new(Rawrr)
    R.setAssembly(rawrr:::.rawrrAssembly())
    R.setFileName(rawfile)

    mZ <- R.getValues(scan, 'mZ')
    intensities <- R.getValues(scan, 'intensities')
    nois <- R.getValues(scan, 'noise')
    resolution <- R.getValues(scan, 'resollution')
    trailer <- R.getTrailer(scan)

    R$deconstructor

    rv <- mapply(mZ, intensities, trailer, fun = ...)
    rv
}


```
