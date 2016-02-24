# Running Sensitivity Analysis

## Preparing SAlib

Prepare python module [salib](https://github.com/SALib).

If you are using Mac, you can prepare the environment as follows for example.

```
brew update
brew upgrade pyenv
pyenv install miniconda3-3.19.0
pyenv local miniconda3-3.19.0
conda create --name salib numpy scipy matplotlib
source ~/.pyenv/versions/miniconda3-3.19.0/envs/salib/bin/activate salib
conda install pip
pip install salib
```

## Generating sample points using SAlib

If your simulator has three input parameters, prepare "param.txt" file as follows.

```txt:param.txt
x0 0.0 1.0
x1 0.0 1.0
x2 0.0 1.0
```

Then run SAlib to generate smaple points as follows:

```
python -m SALib.sample.saltelli -n 1000 -p ./param.txt -o model_input.txt --delimiter=' ' --max-order=1
```

The number of generated points is $n(d+2)$, where "n" is the number you specified as an argument and "d" is the number of input parameters.
In this case, you'll find 5000 points in "model_input.txt".

## Building caravan

Build simulator as a static library:

```
cd SAIsing2d/caravan/simulator && make && cd -
```

"libising2d.a" is created in "build" directory.

Then, build x10 files and link it to the static library as follows:

```
x10c++ -sourcepath ./SAIsing2d:.. -d ./build SAIsing2d/SAIsing2d.x10 -VERBOSE_CHECKS -cxx-postarg libising2d.a
```

You will find "build/a.out" file.

## Running

After you copied "model_input.txt" to the current directory, run the command as follows:

```
X10_NPLACES=8 ../build/a.out 1234
```

You can change the number of process by setting "X10_NPLACES" environment variable. Please specify the value which is a multiple of 4.

The argument is the random number seed although changing it does not change the output in this case.

## Analyzing

After you run the simulations, you will find "ps_ids.txt" in addition to "runs.json" and "parameter_sets.json".
"ps_ids.txt" has the list of PS IDs for each sample point. Since an identical PS can be generated, we need to map the input sample points to the PS IDs using this file.

To analyzer the file, please run the following command:

```
ruby ../SAIsing2d/convert_format.rb ps_ids.txt runs.json > model_output.txt
python -m SALib.analyze.sobol -p ./param.txt -Y model_output.txt --max-order=1
```

The results are shown in the stdout like

```
arameter S1 S1_conf ST ST_conf
x0 -0.008666 0.028346 0.111069 0.011059
x1 0.887657 0.064879 0.992064 0.072618
x2 0.001290 0.002408 0.000437 0.000841
```

indicating the "x1" is the most effective parameter while "x3" is negligible.

