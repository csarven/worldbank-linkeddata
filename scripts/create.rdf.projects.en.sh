#!/bin/bash

saxonb-xslt -s ../data/projects/projects-and-operations.xml -xsl ../scripts/xsl/projects-and-operations.xsl wbapi_lang=en pathToCountries=../data/indicators/en/countries.xml pathToLendingTypes=../data/indicators/en/lendingTypes.rdf pathToRegionsExtra=../data/regions-extra.rdf pathToCurrencies=../data/currencies.rdf > ../data/projects/projects-and-operations.rdf

echo "Created ../data/projects/projects-and-operations.rdf"
