
# CARAVAN

A framework for large scale parameter-space exploration.

## Prerequisites

- x10
    - tested against native x10 2.5.0 with MPI backend

## Compiling

You have to specify the simulator to use when compiling.


### on local environment

#### Compiling mock project

```
x10c++ -sourcepath ./mock:.. -d ./build ./mock/Mock.x10 -VERBOSE_CHECKS
```

Include `mock/` directory to `sourcepath` option, and specify `./mock/Mock.x10` as the main x10 file to compile.
Also include the parent directory `..` since the codes are imported via `caravan.` prefix which is the name of the current directory.

`VERBOSE_CHECKS` warns us when a code has a potential bug in communication.

The `-d` option specifies the directory where the output binary is made.
In this directory, intermediate C++ codes are also generated.

---

#### Compiling a project with an actual simulator

A simulator program must be called as a function written in C++.

First you need to create a static library. Hereafter, we use `Ising2dSimulator` as a sample.

To compile the Ising project,

```
cd Ising2DSimulator/caravan/simulator && make
```

This command compiles C++ simulator and make `libising.a` file in the `build` directory.

Then return to the top directory and compile x10 sources as follows.

```
x10c++ -sourcepath ./Ising2DSimulator:.. -d ./build Ising2DSimulator/IsingSearch.x10 -VERBOSE_CHECKS -cxx-postarg libising2d.a
```

The build target is `Ising2dSimulator/IsingSearch.x10`. Source paths are included in a similar way as the mock project.
Since Ising project calls a function written in C++, it is also needs the option to link against `libising2d.a`.
The output binary is created in `build` directory.

### Executing

To execute caravan without MPI, run the following command

```
X10_NPLACES=8 ../build/a.out 192 0.2 0.1 30 4
```

The environment variable `X10_NPLACES` specifies the number of processes.

`runs.json` and `parameter_sets.json` are created.

