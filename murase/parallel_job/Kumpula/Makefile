UNAME = ${shell uname}
ifeq ($(UNAME), Linux)
CPP=g++
endif
ifeq ($(UNAME), Darwin)
CPP=g++-4.9
endif
OPT=-O3 -Wall -DNDEBUG -fopenmp
INCLUDE=
LIB=
BUILD=../build

kumpula.a: main.cpp kumpula_2d_mobile_nd_ld_aging.cpp node_2d.cpp random.cpp main.hpp kumpula_2d_mobile_nd_ld_aging.hpp node_2d.hpp random.hpp Makefile
	$(CPP) $(OPT) $(INCLUDE) -c main.cpp kumpula_2d_mobile_nd_ld_aging.cpp node_2d.cpp random.cpp && ar rcs $(BUILD)/kumpula.a main.o kumpula_2d_mobile_nd_ld_aging.o node_2d.o random.o

clean:
	rm -f *.o ../build/kumpula.a
