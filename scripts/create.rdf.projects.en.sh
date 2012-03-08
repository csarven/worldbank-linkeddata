#!/bin/bash

saxonb-xslt -s /var/www/lib/worldbank-linkeddata/data/projects/projects-and-operations.xml -xsl /var/www/lib/worldbank-linkeddata/scripts/xsl/projects-and-operations.xsl wbapi_lang=en pathToCountries=/var/www/lib/worldbank-linkeddata/data/indicators/en/countries.xml pathToLendingTypes=/var/www/lib/worldbank-linkeddata/data/indicators/en/lendingTypes.rdf pathToRegionsExtra=/var/www/lib/worldbank-linkeddata/data/regions-extra.rdf pathToCurrencies=/var/www/lib/worldbank-linkeddata/data/currencies.rdf > /var/www/lib/worldbank-linkeddata/data/projects/projects-and-operations.rdf

echo "Created /var/www/lib/worldbank-linkeddata/data/projects.rdf"
