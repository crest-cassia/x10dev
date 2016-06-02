#!/bin/bash
die() { echo "$@"; exit 1; }

home=${0%oacis/run-long.sh} #'samples/ShockTransfer'

[ $# -ge 4 ] || die "$0: Need more than 4 arguments but [$@]
Usage: $ bash $home/oacis/run-long.sh ./a.out F C N [T] [SEED] >output.dat
  F  FCNAgent fundamentalWeight
  C  FCNAgent chartWeight
  N  FCNAgent noiseWeight
  T  Simulation steps [500]"

[ -x "$1" ] || die "$0: $1 is not executable"

F=$2
C=$3
N=$4
T=$5
SEED=$6    # may be empty
JSON=$(mktemp)
sed "s/%F%/$F/g; s/%C%/$C/g; s/%N%/$N/g; s/%T%/$T/g" "$home"/oacis/template-long.json >$JSON

"$1" $JSON $SEED

rm $JSON
