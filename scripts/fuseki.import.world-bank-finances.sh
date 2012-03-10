#!/bin/bash

for file in /var/www/lib/worldbank-linkeddata/data/finances/finance/*.rdf;
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};

        if [ "$graph" != "wc6g-9zmq" ] ; then
            java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-bank-finances "$file" ;
        fi
    done
