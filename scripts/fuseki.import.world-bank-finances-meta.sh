#!/bin/bash

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-bank-finances ../data/finances/views.rdf

for i in ../data/finance.dsd*.rdf ;
    do
        java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-bank-finances ../data/finances/"$i".rdf ;
    done

