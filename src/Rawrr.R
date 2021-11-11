#R

Sys.setenv("PKG_CPPFLAGS"="`pkg-config --cflags mono-2`")
Sys.setenv("PKG_CXXFLAGS"="`pkg-config --cflags mono-2`")
Sys.setenv("PKG_LIBS"="`pkg-config --libs mono-2`")
#Sys.setenv("MONO_PATH"="/home/cp//project/2021/rawrrR.cpp/Rcpp")
#Sys.setenv("MONO_EXTERNAL_ENCODINGS"="utf8:latin1")


Rcpp::sourceCpp("rawrrRcpp.cpp", cacheDir = "/scratch/cpanse/Rcpp/", showOutput=TRUE, verbose=TRUE, rebuild = TRUE)
#Rcpp::sourceCpp("rawrrRcpp.cpp", cacheDir = "/home/cp/project/2021/rawrrR.cpp/Rcpa")
R <- new(Rawrr)
R
R$createObject()
R$get_Revision()

R$get_mZvalues(1)

rv <- lapply(c(1,1,10,100,1000, 2000, 4000 ), function(n){
start_time <- Sys.time()
mZ <- lapply(1:n, function(scanId){R$get_mZvalues(scanId)})
end_time <- Sys.time()

td <- end_time - start_time
	data.frame(n=n, timediff=td)
}) |> Reduce(f=rbind)
rv$scanspersecond <- rv$n / as.double(rv$timediff)  
rv
#mZ[1]
