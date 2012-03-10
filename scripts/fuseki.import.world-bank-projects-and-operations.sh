#!/bin/bash

#Graph http://worldbank.270a.info/graph/world-bank-finances
java tdb.tdbloader --desc=/usr/lib/fuseki/tdb2.worldbank.ttl --graph=http://worldbank.270a.info/graph/world-bank-projects-and-operations /var/www/lib/worldbank-linkeddata/data/projects/projects-and-operations.rdf

