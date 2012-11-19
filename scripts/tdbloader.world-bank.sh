#!/bin/bash

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta ../data/import/graph.meta.nt

for i in ../data/meta/meta.finance*.rdf ;
    do
        java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta "$i" ;
    done

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-bank-finances ../data/import/graph.world-bank-finances.nt

#java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-development-indicators ../data/import/graph.world-development-indicators.nt

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-bank-projects-and-operations ../data/import/graph.world-bank-projects-and-operations.nt

