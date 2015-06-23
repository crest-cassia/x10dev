CPP=g++-4.9
OPT=-O3 -Wall -DNDEBUG
INCLUDE=
LIBS=
BUILD_DIR=../../build

ising2d.o: *.cpp *.hpp Makefile
	$(CPP) $(OPT) $(INCLUDE) -c main.cpp $(LIBS) -o $(BUILD_DIR)/$@
	cp main.hpp ..

clean:
	rm -f *.out *~ *.bak *.o
