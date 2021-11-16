#R

#Sys.setenv("PKG_CONFIG_PATH"="/Library/Frameworks/Mono.framework/Versions/6.12.0/lib/pkgconfig/")
Sys.setenv("PKG_CPPFLAGS"="`pkg-config --cflags mono-2` -O3")
Sys.setenv("PKG_CXXFLAGS"="`pkg-config --cflags mono-2` -O3")
Sys.setenv("PKG_LIBS"="`pkg-config --libs mono-2`")
#Sys.setenv("MONO_PATH"="/home/cp//project/2021/rawrrR.cpp/Rcpp")
#Sys.setenv("MONO_EXTERNAL_ENCODINGS"="utf8:latin1")


Rcpp::sourceCpp("rawrrRcpp.cpp", cacheDir = "/tmp/cpanse/Rcpp/", showOutput=TRUE, verbose=TRUE, rebuild = TRUE)
#Rcpp::sourceCpp("rawrrRcpp.cpp", cacheDir = "/home/cp/project/2021/rawrrR.cpp/Rcpa")
R <- new(Rawrr)
R
R$createObject()
R$get_Revision()

R$get_trailer(1)
R$get_values(1, "CentroidScan.Masses")
R$get_values(1, "CentroidScan.Intensities")

quit("yes")

rv <- lapply(c(1, 1, 10, 100), function(n){
  start_time <- Sys.time()
  mZ <- lapply(1:n, function(scanId){list(peaks=R$get_mZvalues(scanId), dump=R$get_mZvalues(scanId),tailer=R$get_trailer(scanId))})
  end_time <- Sys.time()

  rawrr_start_time <- Sys.time()
  mZ <- rawrr::readSpectrum("/tmp/sample.raw", 1:n)
  rawrr_end_time <- Sys.time()

  td <- end_time - start_time
  rawrr_td <- rawrr_end_time - rawrr_start_time
 rv<-       data.frame(n=n, timediff=td, rawrr_timediff=rawrr_td)
 print(rv)
 rv
}) |> Reduce(f=rbind)

rv$scanspersecond <- rv$n / as.double(rv$timediff)  
rv$rawrr_scanspersecond <- rv$n / as.double(rv$rawrr_timediff)  
rv$gain <- round(rv$scanspersecond / rv$rawrr_scanspersecond)
options(width=120)
rv
