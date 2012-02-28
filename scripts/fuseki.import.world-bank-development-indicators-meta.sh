#!/bin/bash

for file in ../data/indicators/en/*.rdf;
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};
        echo "$graph";
        java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/$graph $file;
    done;

