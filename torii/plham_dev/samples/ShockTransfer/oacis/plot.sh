#!/bin/bash
die() { echo "$@"; exit 1; }

home=${0%oacis/plot.sh} #'samples/ShockTransfer'

[ $# -ge 2 ] || die "$0: Need more than 2 arguments but [$@]
Usage: $ bash $home/oacis/plot.sh plot.R output.png"

[ -f "$1" ] || die "$0: $1 must be R script file"

Rscript "$1" $(find _input -name '_stdout.txt') $2
