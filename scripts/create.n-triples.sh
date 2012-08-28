#!/bin/bash

rapper -g /var/www/lib/worldbank-linkeddata/data/meta/meta.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

for file in /var/www/lib/worldbank-linkeddata/data/indicators/en/*.rdf ; do rapper -g $file >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ; done ;

rapper -g /var/www/lib/worldbank-linkeddata/data/regions-extra.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/topics-extra.ttl >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/currencies.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

cat /var/www/lib/worldbank-linkeddata/data/worldbank-sameAs-dbpedia_countries.nt >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

cat /var/www/lib/worldbank-linkeddata/data/worldbank-sameAs-eurostat_countries.nt >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

cat /var/www/lib/worldbank-linkeddata/data/worldbank-sameAs-geonames_countries.nt >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

cat /var/www/lib/worldbank-linkeddata/data/worldbank-sameAs-dbpedia_currencies.nt >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/finances/views.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/finances/finance/wc6g-9zmq.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

for file in /var/www/lib/worldbank-linkeddata/data/finances/finance/*.loan-numbers.rdf ; do rapper -g "$file" >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ; done ;

rapper -g /var/www/lib/worldbank-linkeddata/data/projects/projects-and-operations.loan-numbers.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

#cat /var/www/lib/worldbank-linkeddata/data/finances/finances.datasets.txt | while read i ; do filename=$(basename $i); extension=${filename##*.}; graph=${filename%.*}; if [ "$graph" != "wc6g-9zmq" ] ; then rapper -g /var/www/lib/worldbank-linkeddata/data/finances/finance/"$i".rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.world-bank-finances.nt ; fi done ;

#rapper -g /var/www/lib/worldbank-linkeddata/data/projects/projects-and-operations.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.world-bank-projects-and-operations.nt ;

#for file in /var/www/lib/worldbank-linkeddata/data/indicators/en/indicator/*.rdf ; do rapper -g $file >> /var/www/lib/worldbank-linkeddata/data/import/graph.world-development-indicators.nt ; done ;

#for file in /var/www/lib/worldbank-linkeddata/data/climates/*/*/*.rdf ; do rapper -g $file >> /var/www/lib/worldbank-linkeddata/data/import/graph.world-bank-climates.nt ; done ;

