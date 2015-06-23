UNAME = ${shell uname}
CPP=g++
OPT=-O3 -Wall -DNDEBUG
INCLUDE=
LIBS=
BUILD=../../build
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

ising2d.a: *.cpp *.hpp Makefile
	$(CPP) $(OPT) $(INCLUDE) -c main.cpp $(LIBS) -o main.o
	ar rcs $(BUILD)/libising2d.a main.o
	cp main.hpp ..

clean:
	rm -f *.out *~ *.bak *.o
