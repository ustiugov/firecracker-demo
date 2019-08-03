#!/bin/bash

#Usage 
## sudo ./start.sh 0 100 # Will start VM#0 to VM#99. 

start="${1:-0}"
upperlim="${2:-1}"

declare -a cpus1
declare -a cpus2
#first socket 0 then socket 1, socket 0 siblings, socket 1 siblings
cpus1=(0 4 8 12 16 1 5 9 13 17 24 28 32 36 40 25 29 33 37 41)
cpus2=(2 6 10 14 18 3 7 11 15 19 26 30 34 38 42 27 31 35 39 43)
#cpus=(0 2 4 6 8 10 12 14 16 18 1 3 5 7 9 11 13 15 17 19 24 26 28 30 32 34 36 38 40 42 25 27 29 31 33 35 37 39 41 43)

for ((i=start; i<upperlim; i++)); do
  if [ ! -z "$FC_CPU_AFFIN" ]; then
    ind=$((i % 20))
    TASKSET="taskset -c ${cpus1[$ind]},${cpus2[$ind]} "
  else
    TASKSET=
  fi

  $TASKSET ./start-firecracker.sh "$i"
done
