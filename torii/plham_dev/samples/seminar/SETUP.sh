#!/bin/bash

[ "${PWD##*/}" == "seminar" ] || { echo "Run in samples/seminar; exit now"; exit 1; }

# The root directory of plham
home=../..

mkdir -p answer
mkdir -p oacis
cp $home/plham/agent/FCNAgent.x10 .
cp $home/samples/CI2002/CI2002Main.x10 .
cp $home/samples/CI2002/*.R .
cp $home/samples/CI2002/oacis/run.sh oacis/run.sh
cp $home/samples/CI2002/oacis/template-long.json oacis/template.json

sed -i 's/package plham.agent/package samples.seminar/' FCNAgent.x10
sed -i 's/package samples.CI2002/package samples.seminar/' CI2002Main.x10
sed -i 's/import plham.agent.FCNAgent/import samples.seminar.FCNAgent/' CI2002Main.x10

cp $home/plham/agent/FCNAgent.x10 answer
cp $home/samples/CI2002/CI2002Main.x10 answer

F=1
C=1
N=1
sed "s/%F%/$F/g; s/%C%/$C/g; s/%N%/$N/g" oacis/template.json >config.json

cat <<EOH
Follow the below to complete this setup:
 1 Edit samples/seminar/FCNAgent.x10
     * Delete the content of both submitOrders()
 2 Edit samples/seminar/CI2002Main.x10
     * Delete the body of if (json("class")...) {} in createAgents()
     * Delete the body of if (json("class")...) {} in createMarkets()
EOH
  
