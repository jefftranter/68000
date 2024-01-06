#!/bin/sh

if [ "$1" = "clean" ]
then
    rm -rf */build
    exit 0
fi

for d in adventure1 adventure2 adventure3 nqueens yum rpncalc
do
    cd $d
    ./build.sh
    cd ..
done
