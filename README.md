# rawrrRcpp

## links

* https://fgcz-intranet.uzh.ch/tiki-index.php?page=rawrrR.cpp

* https://www.denbi.de/news/1299-3rd-de-nbi-elixir-de-metarbolomics-hackathon


|               |                   |
| :------------ | :---------------- |
| R             |                  |
|            |    Rcpp              |
|  C++-code       |                 |
|            |    libmono-2.0  |
|  C#        |                 |
|            |                 |
|            |                 |


```{r}
.readSpectrumRcpp <- function(rawfile, scan){
    R <- new(Rawrr)
    R.setAssembly(rawfile)
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
