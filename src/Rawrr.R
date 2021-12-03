#R
stopifnot( packageVersion('rawrr') > '1.3.1')

Sys.setenv("MONO_LOG_LEVEL"="all")
Sys.setenv("MONO_LOG_MASK"="dll,cfg")
Sys.setenv("PKG_CPPFLAGS"="`pkg-config --cflags mono-2` -O3")
Sys.setenv("PKG_CXXFLAGS"="`pkg-config --cflags mono-2` -O3")
Sys.setenv("PKG_LIBS"="`pkg-config --libs mono-2`")


Rcpp::sourceCpp("rawrrRcpp.cpp", cacheDir = "RcppMonoEmbed", showOutput=TRUE, verbose=TRUE, rebuild = TRUE)

EH4547 <- "/home/cpanse/.cache/R/ExperimentHub/18e7d5bfb4a3b_4590.raw"

R <- new(Rawrr)
R$setDomainName("rawrrRcpp")
R$createObject()
R$setRawFile(EH4547)
R$openFile()
mZ <- R$get_values(9594, "CentroidScan.Masses"); intensity <- R$get_values(9594, "CentroidScan.Intensities")
head(mZ)
head(intensity)



.readSpectrumRcpp <- function(f, scan, mode){
  R$setRawFile(f)
  rv <- lapply(scan, function(i){
     list(
     	trailer = R$get_trailer(i),
     	mZ = R$get_values(i, "CentroidScan.Masses"),
        intensity = R$get_values(i, "CentroidScan.Intensities")
	)
  })
rv
}

bm <- lapply(2^(0:13), function(n, rawfile, ...){
	message(n)
         m0 <-  microbenchmark::microbenchmark({S0 <- rawrr::readSpectrum(rawfile, 1:n, mode='default')}, ...)
         m1 <-  microbenchmark::microbenchmark({S1 <- rawrr::readSpectrum(rawfile, 1:n, mode='barebone')}, ...)
         m2 <-  microbenchmark::microbenchmark({S2 <- .readSpectrumRcpp(rawfile, 1:n, mode='monoembed')}, ...)

	 testthat::expect_setequal(
         	 unlist( sapply(S0, function(x) x$mZ)),
         	 unlist( sapply(S1, function(x) x$mZ)))

	 testthat::expect_setequal(
         	 unlist( sapply(S1, function(x) x$mZ)),
         	 unlist( sapply(S2, function(x) x$mZ)))

	 testthat::expect_setequal(
         	 unlist( sapply(S0, function(x) x$intensity)),
         	 unlist( sapply(S1, function(x) x$intensity)))

	 testthat::expect_setequal(
         	 unlist( sapply(S1, function(x) x$intensity)),
         	 unlist( sapply(S2, function(x) x$intensity)))

	 rv <- list(
	 data.frame(time = m0$time, mode='default', n=n),
	 data.frame(time = m1$time, mode='barebone', n=n),
	 data.frame(time = m2$time, mode='monoembed', n=n))
	 rv |> Reduce(f='rbind')

  }, times = 2, unit = "nanosecond", rawfile = EH4547) |> Reduce(f='rbind')

bm
lattice::xyplot(time ~ n|mode, data=bm, scales=list(log=TRUE))
lattice::xyplot(time ~ n, groups=bm$mode, data=bm,
  type='p', scale=list(log=TRUE), ylab='time [in nanosecond]', xlab='number of spectra', auto.key=TRUE)
quit('yes')

