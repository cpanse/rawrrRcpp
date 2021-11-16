#R
S <- read.csv2("benchmark.txt");
m <- length(table(S$n))
boxplot(as.double(time) ~ n, data = S,
             boxwex = 0.25,
	     at = 1:m - 0.2,
             subset = type == "system2", col = "yellow",
             main = "Benchmark",
             xlab = "number of random selected spectra",
	     ylim=range(as.double(S$time)),
	     axes=FALSE,
	     log="y",
             ylab = "runtime in seconds in log scale")

boxplot(as.double(time) ~ n, data = S, add = TRUE,
             boxwex = 0.25, at = 1:m + 0.2,
	     axes=FALSE,
             subset = type == "Rcpp", col = "orange")

axis(1,1:m, names(table(S$n)))
axis(2)

legend("bottomright", c("system2", "Rcpp"),
            fill = c("yellow", "orange"))

