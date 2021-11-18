#R
S <- read.table("benchmark.txt", sep=' ', header=TRUE);
m <- length(table(S$n))
boxplot(as.double(time) ~ n, data = S,
             boxwex = 0.25,
	     at = 1:m - 0.2,
             subset = type == "system2", col = "yellow",
             main = "Benchmark | AMD EPYC 7742 64-Core Processor | Debian 10",
             xlab = "number of random selected spectra log2 scale",
	     ylim=range(as.double(S$time)),
	     axes=FALSE,
	     log="y",
             ylab = "runtime in seconds and log10 scale")
abline(h=1, col='grey')

boxplot(as.double(time) ~ n, data = S, add = TRUE,
             boxwex = 0.25, at = 1:m + 0.2,
	     axes=FALSE,
             subset = type == "Rcpp", col = "orange")


axis(1,1:m, names(table(S$n)))
axis(2)
axis(4, c(1,30), c(1,30))

legend("bottomright", c(paste("rawrr", packageVersion('rawrr')), "Rcpp libmono-2.so"),
            fill = c("yellow", "orange"))

