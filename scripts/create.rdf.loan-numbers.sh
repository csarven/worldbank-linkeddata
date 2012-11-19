#!/bin/bash

saxonb-xslt -s ../data/projects/projects-and-operations.xml -xsl ../scripts/xsl/loanNumbers.xsl wbapi_lang=en pathToCountries=../data/indicators/en/countries.xml pathToLendingTypes=../data/indicators/en/lendingTypes.rdf pathToRegionsExtra=../data/regions-extra.rdf pathToCurrencies=../data/currencies.rdf > ../data/projects/projects-and-operations.loan-numbers.rdf
echo "Created ../data/projects/projects-and-operations.loan-numbers.rdf"

cat ../data/finances/finances.datasets.txt | while read i ; do saxonb-xslt -s "../data/finances/finance/$i.xml" -xsl ../scripts/xsl/loanNumbers.xsl wbapi_lang=en pathToCountries=../data/indicators/en/countries.xml pathToLendingTypes=../data/indicators/en/lendingTypes.rdf pathToRegionsExtra=../data/regions-extra.rdf pathToMeta=../data/meta/meta.rdf pathToCurrencies=../data/currencies.rdf > "../data/finances/finance/$i.loan-numbers.rdf" ; echo "Created ../data/finances/finance/$i.loan-numbers.rdf" ; done
find ../data/finances/finance/*loan-numbers.rdf -size 1306c | xargs rm -f
