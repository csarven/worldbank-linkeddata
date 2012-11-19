#!/bin/bash

cat ../data/finances/finances.datasets.txt | while read i ; do saxonb-xslt -s "../data/finances/finance/$i.xml" -xsl ../scripts/xsl/financesObservations.xsl wbapi_lang=en pathToCountries=../data/indicators/en/countries.xml pathToLendingTypes=../data/indicators/en/lendingTypes.rdf pathToRegionsExtra=../data/regions-extra.rdf pathToMeta=../data/meta/meta.rdf pathToCurrencies=../data/currencies.rdf > ../data/finances/finance/$i.rdf ; echo "Created ../data/finances/finance/$i.rdf" ; done

