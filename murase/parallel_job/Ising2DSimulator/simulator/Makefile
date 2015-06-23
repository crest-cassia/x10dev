UNAME = ${shell uname}
ifeq ($(UNAME), Linux)
	CPP=g++
endif
ifeq ($(UNAME), Darwin)
	CPP=g++-4.9
endif
OPT=-O3 -Wall -DNDEBUG
INCLUDE=
LIBS=
BUILD=../../build

ising2d.a: *.cpp *.hpp Makefile
	$(CPP) $(OPT) $(INCLUDE) -c main.cpp $(LIBS) -o main.o
	ar rcs $(BUILD)/ising2d.a main.o
	cp main.hpp ..

clean:
	rm -f *.out *~ *.bak *.o
