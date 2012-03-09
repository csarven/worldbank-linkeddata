#!/bin/bash

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/meta /var/www/lib/worldbank-linkeddata/data/meta/meta.rdf

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/regions /var/www/lib/worldbank-linkeddata/data/regions-extra.rdf

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/topics /var/www/lib/worldbank-linkeddata/data/topics-extra.ttl

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/incomeLevels /var/www/lib/worldbank-linkeddata/data/incomeLevels-extra.ttl

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/currencies /var/www/lib/worldbank-linkeddata/data/currencies.rdf

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-bank-finances /var/www/lib/worldbank-linkeddata/data/finances-views-extra.rdf

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/countries /var/www/lib/worldbank-linkeddata/data/worldbank-exactMatch-dbpedia_countries.nt

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/currencies /var/www/lib/worldbank-linkeddata/data/worldbank-exactMatch-dbpedia_currencies.nt

java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/currencies /var/www/lib/worldbank-linkeddata/data/worldbank-exactMatch-qudt_currencies.nt
