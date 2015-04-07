#!/bin/sh
#============ pjsub Options ============
#PJM --rsc-list "node=4"
#PJM --rsc-list "elapse=00:05:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --mpi "proc=32"
#PJM --stgin-dir "rank=* ./build %r:./"
#PJM --stgin  "rank=0 /data/ra000014/a03144/local/icedCopy.tar 0:../"
#PJM --stgin-dir  "rank=* /data/ra000014/a03144/local/x10.dist.stageIn %r:./x10"
#PJM --stgout-dir "rank=* %r:./ %j"
#PJM -s

#============ Shell Script ============

. /work/system/Env_base

tar xf ../icedCopy.tar -C ../

export X10_NPLACES=32
export X10_NTHREADS=1
export X10RT_MPI_ENABLE_COLLECTIVES=true

ICED_COPY=../icedCopy
X10D=./x10

export PATH=$PATH:$ICED_COPY/bin/
export JAVA_HOME=$ICED_COPY
export LD_LIBRARY_PATH=$ICED_COPY/jre/lib/s64fx/server:.:$X10D:$LD_LIBRARY_PATH
export _JAVA_OPTIONS="-Xmx2048m -Xss16m"

PROGRAM=Main
ARG=task_list.txt

ls

mpiexec $X10D/X10MPIJava -ea -Djava.library.path=$LD_LIBRARY_PATH -Djava.class.path=.:$X10D/x10.jar:$X10D/commons-math3-3.3.jar:$X10D/commons-logging-1.2.jar:$X10D/hazelcast-3.3.jar -Djava.util.logging.config.file=$X10D/logging.properties -DX10RT_IMPL=mpi $PROGRAM\$\$Main $ARG

