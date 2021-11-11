CPPFLAGS=-std=gnu++14 -g -O2 -fstack-protector-strong
run: cppbuild monobuild
	./rawrrRcpp	
cppbuild:
	g++ -Wall -o rawrrRcpp rawrrRcpp.cpp `pkg-config --cflags --libs mono-2` -lm -DMONO_EMBED_CPP_MAIN $(CPPFLAGS)
clean:
	$(RM) -vfr *.json sourceCpp-x86_64-pc-linux-gnu-1.0.7 *.blob
monobuild:
	msbuild && mono rawrrRcpp.exe 

Rcppbuild:
	R --no-save < Rawrr.R
