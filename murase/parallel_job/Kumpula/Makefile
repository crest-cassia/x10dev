UNAME = ${shell uname}
CPP=g++
OPT=-O3 -Wall -DNDEBUG
INCLUDE=
LIBS=
BUILD=../build

ifeq ($(UNAME), Linux)

endif
ifeq ($(UNAME), Darwin)
	CPP=g++-4.9
endif
ifeq ($(XSUB_TYPE), k)
	CPP=FCCpx
	OPT=-Kfast -Xg
	INCLUDE=-I$(HOME)/program/libs/boost_1_54_0
endif

libkumpula.a: main.cpp kumpula_2d_mobile_nd_ld_aging.cpp node_2d.cpp random.cpp main.hpp kumpula_2d_mobile_nd_ld_aging.hpp node_2d.hpp random.hpp Makefile
	$(CPP) $(OPT) $(INCLUDE) -c main.cpp kumpula_2d_mobile_nd_ld_aging.cpp node_2d.cpp random.cpp && ar rcs $(BUILD)/libkumpula.a main.o kumpula_2d_mobile_nd_ld_aging.o node_2d.o random.o

clean:
	rm -f *.o $(BUILD)/libkumpula.a
