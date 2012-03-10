#!/bin/bash

#Graph http://worldbank.270a.info/graph/meta

# Metadata that's used widely
java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/meta/meta.rdf

for file in /var/www/lib/worldbank-linkeddata/data/indicators/en/*.rdf;
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};
        java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta $file;
    done;

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/regions-extra.rdf

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/topics-extra.ttl

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/income-levels-extra.ttl

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/currencies.rdf

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/worldbank-sameAs-dbpedia_countries.nt

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/worldbank-exactMatch-dbpedia_currencies.nt


#World Bank Finances metadata
java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/finances/views.rdf

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/finances/finance/wc6g-9zmq.rdf

for i in /var/www/lib/worldbank-linkeddata/data/meta/meta.finance*.rdf ;
    do
        java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta "$i" ;
    done

