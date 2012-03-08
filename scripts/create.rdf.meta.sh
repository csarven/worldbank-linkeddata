#!/bin/bash

rapper -gq /var/www/lib/worldbank-linkeddata/data/meta.ttl -o rdfxml > /var/www/lib/worldbank-linkeddata/data/meta.rdf
echo "Created /var/www/lib/worldbank-linkeddata/data/meta.rdf"

saxonb-xslt -s /var/www/lib/worldbank-linkeddata/data/dl_iso_table_a1.xml -xsl /var/www/lib/worldbank-linkeddata/scripts/xsl/currencies.xsl wbapi_lang=en pathToCountries=/var/www/lib/worldbank-linkeddata/data/indicators/en/countries.rdf > /var/www/lib/worldbank-linkeddata/data/currencies.rdf
echo "Created /var/www/lib/worldbank-linkeddata/data/currencies.rdf"

