#!/bin/bash

for file in ../data/indicators/en/indicator/*.rdf;
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};
        java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-development-indicators $file;
    done;
