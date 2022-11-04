#!/bin/sh

if [ "$1" = "clean" ]
then
    rm -rf */build
    exit 0
fi

for d in adventure1 adventure2 nqueens yum
do
    cd $d
    ./build.sh
    cd ..
done
