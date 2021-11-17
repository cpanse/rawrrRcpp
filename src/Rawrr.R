#R

Sys.setenv("PKG_CPPFLAGS"="`pkg-config --cflags mono-2` -O3")
Sys.setenv("PKG_CXXFLAGS"="`pkg-config --cflags mono-2` -O3")
Sys.setenv("PKG_LIBS"="`pkg-config --libs mono-2`")


Rcpp::sourceCpp("rawrrRcpp.cpp", cacheDir = "/tmp/cpanse/Rcpp3/", showOutput=TRUE, verbose=TRUE, rebuild = TRUE)

f<-"/home/cpanse/.cache/R/rawrr/20181113_010_autoQC01.raw"
EH4547 <- "/home/cpanse/.cache/R/ExperimentHub/18e7d5bfb4a3b_4590.raw"

R <- new(Rawrr)
R$setDomainName("rrr3")
R$createObject()
R$setRawFile(EH4547)
R$openFile()

set.seed(2)

.readSpectrumRcpp <- function(f, scan){
  rv <- lapply(scan, function(i){
     list(
     	trailer = R$get_trailer(i),
     	mZ = R$get_values(i, "CentroidScan.Masses"),
        intensity = R$get_values(i, "CentroidScan.Intensities")
	)
  })
 # R$dector()

rv
}



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

write.csv2(b, file="../vignettes/benchmark.txt", row.names = FALSE, append=TRUE)
})
quit("yes")

