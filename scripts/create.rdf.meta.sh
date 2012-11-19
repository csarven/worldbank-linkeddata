#!/bin/bash

rapper -gq ../data/meta/meta.ttl -o rdfxml > ../data/meta/meta.rdf
echo "Created ../data/meta/meta.rdf"

saxonb-xslt -s ../data/dl_iso_table_a1.xml -xsl ../scripts/xsl/currencies.xsl wbapi_lang=en pathToCountries=../data/indicators/en/countries.rdf > ../data/currencies.rdf
echo "Created ../data/currencies.rdf"

