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
R$get_info()
#R$get_info()
R$get_info()
rv <- sapply(1:100, function(x){R$get_Revision()})
table(rv)
