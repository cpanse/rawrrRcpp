#R

Sys.setenv("MONO_LOG_LEVEL"="all")
Sys.setenv("MONO_LOG_MASK"="dll,cfg")
Sys.setenv("PKG_CONFIG_PATH"="/Library/Frameworks/Mono.framework/Versions/5.18.1/lib/pkgconfig")
Sys.setenv("PKG_CONFIG_PATH"="/Library/Frameworks/Mono.framework/Versions/6.12.0/lib/pkgconfig")
Sys.setenv("PKG_CPPFLAGS"="`pkg-config --cflags mono-2` -O3")
Sys.setenv("PKG_CXXFLAGS"="`pkg-config --cflags mono-2` -O3")
Sys.setenv("PKG_LIBS"="`pkg-config --libs mono-2`")


Rcpp::sourceCpp("rawrrRcpp.cpp", cacheDir = "RcppMonoEmbed", showOutput=TRUE, verbose=TRUE, rebuild = TRUE)

f<-"/home/cpanse/.cache/R/rawrr/20181113_010_autoQC01.raw"
EH4547 <- "/home/cpanse/.cache/R/ExperimentHub/18e7d5bfb4a3b_4590.raw"
EH4547 <- "/Users/cp/__checkouts/rawrrrcpp/src/18e7d5bfb4a3b_4590.raw"
EH4547 <- "/Users/cp/Library/Caches/ExperimentHub/237c4872c76b_4590.raw"

R <- new(Rawrr)
R$setDomainName("rawrrRcpp")
R$createObject()
R$setRawFile(EH4547)
R$openFile()
mZ <- R$get_values(9594, "CentroidScan.Masses"); intensity <- R$get_values(9594, "CentroidScan.Intensities")
head(mZ)
head(intensity)


rawfile <- "/Users/cp/Library/Caches/ExperimentHub/237c4872c76b_4590.raw"

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

  }, times = 2, unit = "nanosecond", rawfile = rawfile) |> Reduce(f='rbind')

bm
lattice::xyplot(time ~ n|mode, data=bm, scales=list(log=TRUE))
lattice::xyplot(time ~ n, groups=bm$mode, data=bm,
  type='p', scale=list(log=TRUE), ylab='time [in nanosecond]', xlab='number of spectra', auto.key=TRUE)
quit('yes')

set.seed(2)




lapply(1:10,function(y){
b <- lapply(2^(0:14), function(x){
  smp <- sample(2^14,x, replace=FALSE)
  start_time <- Sys.time()
S <- .readSpectrumRcpp(f, scan=smp) 
  end_time <- Sys.time()
  R$get_info()
  message(paste(x, td <- end_time - start_time))
  b1 <- data.frame(n=x, time=td, type='Rcpp')

  start_time <- Sys.time()
  S<- rawrr::readSpectrum(EH4547, smp)
  end_time <- Sys.time()
  message(paste(x, td <- end_time - start_time))
  b2 <- data.frame(n=x, time=td, type='system2')
  rbind(b1,b2)
})   |> Reduce(f=rbind)

write.table(b, file="../vignettes/benchmark2.txt", row.names = FALSE, append=TRUE)
})
quit("yes")

