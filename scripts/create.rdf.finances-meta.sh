#!/bin/bash

saxonb-xslt -s /var/www/lib/worldbank-linkeddata/data/finances/finance/wc6g-9zmq.xml -xsl /var/www/lib/worldbank-linkeddata/scripts/xsl/finances-meta.xsl wbapi_lang=en pathToCountries=/var/www/lib/worldbank-linkeddata/data/indicators/en/countries.xml pathToLendingTypes=/var/www/lib/worldbank-linkeddata/data/indicators/en/lendingTypes.rdf pathToRegionsExtra=/var/www/lib/worldbank-linkeddata/data/regions-extra.rdf pathToMeta=/var/www/lib/worldbank-linkeddata/data/meta.rdf pathToCurrencies=/var/www/lib/worldbank-linkeddata/data/currencies.rdf pathToFinancesDictionary=/var/www/lib/worldbank-linkeddata/data/finances/finance/wc6g-9zmq.rdf financeDatasetID=wc6g-9zmq > /var/www/lib/worldbank-linkeddata/data/finances/finance/wc6g-9zmq.rdf
echo "Created /var/www/lib/worldbank-linkeddata/data/finances/finance/wc6g-9zmq.rdf"

cat /var/www/lib/worldbank-linkeddata/data/finances/finances.datasets.txt | while read i ; do saxonb-xslt -s "/var/www/lib/worldbank-linkeddata/data/finances/finance/"$i".xml" -xsl /var/www/lib/worldbank-linkeddata/scripts/xsl/finances-meta.xsl wbapi_lang=en pathToCountries=/var/www/lib/worldbank-linkeddata/data/indicators/en/countries.xml pathToLendingTypes=/var/www/lib/worldbank-linkeddata/data/indicators/en/lendingTypes.rdf pathToRegionsExtra=/var/www/lib/worldbank-linkeddata/data/regions-extra.rdf pathToMeta=/var/www/lib/worldbank-linkeddata/data/meta.rdf pathToCurrencies=/var/www/lib/worldbank-linkeddata/data/currencies.rdf pathToFinancesDictionary=/var/www/lib/worldbank-linkeddata/data/finances/finance/wc6g-9zmq.rdf financeDatasetID="$i" > /var/www/lib/worldbank-linkeddata/data/temp."$i".rdf ; echo "Created /var/www/lib/worldbank-linkeddata/data/temp."$i".rdf" ; done

touch /var/www/lib/worldbank-linkeddata/data/temp.finances-meta.nt
for i in /var/www/lib/worldbank-linkeddata/data/temp*rdf;
    do rapper -g "$i" >> /var/www/lib/worldbank-linkeddata/data/temp.finances-meta.nt ;
#rm "$i" ;
done

sort /var/www/lib/worldbank-linkeddata/data/temp.finances-meta.nt | uniq > /var/www/lib/worldbank-linkeddata/data/finances-meta.nt

#rm /var/www/lib/worldbank-linkeddata/data/temp.finances-meta.nt
