#!/bin/bash

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt

for i in /var/www/lib/worldbank-linkeddata/data/meta/meta.finance*.rdf ;
    do
        java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta "$i" ;
    done

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-bank-finances /var/www/lib/worldbank-linkeddata/data/import/graph.world-bank-finances.nt

#TODO
#java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-development-indicators /var/www/lib/worldbank-linkeddata/data/import/graph.world-development-indicators.nt

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-bank-projects-and-operations /var/www/lib/worldbank-linkeddata/data/import/graph.world-bank-projects-and-operations.nt

