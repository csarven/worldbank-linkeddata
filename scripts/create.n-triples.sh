#!/bin/bash

rapper -g ../data/meta/meta.rdf >> ../data/import/graph.meta.nt ;

for file in ../data/indicators/en/*.rdf ; do rapper -g $file >> ../data/import/graph.meta.nt ; done ;

rapper -g ../data/regions-extra.rdf >> ../data/import/graph.meta.nt ;

rapper -g ../data/topics-extra.ttl >> ../data/import/graph.meta.nt ;

rapper -g ../data/currencies.rdf >> ../data/import/graph.meta.nt ;

cat ../data/worldbank-exactMatch-transparency_countries.nt >> ../data/import/graph.meta.nt ;
cat ../data/worldbank-exactMatch-fao_countries.nt >> ../data/import/graph.meta.nt ;
cat ../data/worldbank-exactMatch-ecb_countries.nt >> ../data/import/graph.meta.nt ;
cat ../data/worldbank-exactMatch-imf_countries.nt >> ../data/import/graph.meta.nt ;
cat ../data/worldbank-exactMatch-bfs_countries.nt >> ../data/import/graph.meta.nt ;
cat ../data/worldbank-exactMatch-qudt_countries.nt >> ../data/import/graph.meta.nt ;

cat ../data/worldbank-sameAs-dbpedia_countries.nt >> ../data/import/graph.meta.nt ;

cat ../data/worldbank-sameAs-eurostat_countries.nt >> ../data/import/graph.meta.nt ;

cat ../data/worldbank-sameAs-geonames_countries.nt >> ../data/import/graph.meta.nt ;

cat ../data/worldbank-sameAs-dbpedia_currencies.nt >> ../data/import/graph.meta.nt ;

cat ../data/worldbank.exactMatch.iati.nt >> ../data/import/graph.meta.nt ;
cat ../data/worldbank.exactMatch.hr.nt >> ../data/import/graph.meta.nt ;

rapper -g ../data/finances/views.rdf >> ../data/import/graph.meta.nt ;

rapper -g ../data/finances/finance/wc6g-9zmq.rdf >> ../data/import/graph.meta.nt ;

for file in ../data/finances/finance/*.loan-numbers.rdf ; do rapper -g "$file" >> ../data/import/graph.meta.nt ; done ;

rapper -g ../data/projects/projects-and-operations.loan-numbers.rdf >> ../data/import/graph.meta.nt ;

#cat ../data/finances/finances.datasets.txt | while read i ; do filename=$(basename $i); extension=${filename##*.}; graph=${filename%.*}; if [ "$graph" != "wc6g-9zmq" ] ; then rapper -g ../data/finances/finance/"$i".rdf >> ../data/import/graph.world-bank-finances.nt ; fi done ;

#rapper -g ../data/projects/projects-and-operations.rdf >> ../data/import/graph.world-bank-projects-and-operations.nt ;

#for file in ../data/indicators/en/indicator/*.rdf ; do rapper -g $file >> ../data/import/graph.world-development-indicators.nt ; done ;

#for file in ../data/climates/*/*/*.rdf ; do rapper -g $file >> ../data/import/graph.world-bank-climates.nt ; done ;

