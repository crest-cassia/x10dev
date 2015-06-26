#!/bin/sh
#============ pjsub Options ============
#PJM --rsc-list "node=12"
#PJM --rsc-list "elapse=00:04:00"
#PJM --rsc-list "rscgrp=small"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin  "rank=* ./build/a.out %r:./"
#PJM --stgout-dir "rank=0 %r:./ %j"
#PJM -s

#============ Shell Script ============
#  ## #PJM --mpi "proc=12"
#  #PJM --stgin-dir "rank=* ./build %r:./"


. /work/system/Env_base

export GC_MARKERS=1
export X10_NTHREADS=8
# export X10_NPLACES=12
# export X10_STATIC_THREADS=$X10_NTHREADS
# export X10RT_MPI_ENABLE_COLLECTIVES=true
# export X10RT_MPI_FORCE_COLLECTIVES=false

mpiexec ./a.out 60 10.0 2.0 180

