#!/bin/bash

#touch ../data/temp.finances-meta.nt

saxonb-xslt -s ../data/finances/views.xml -xsl ../scripts/xsl/financesViews.xsl wbapi_lang=en pathToMeta=../data/meta/meta.rdf > ../data/finances/views.rdf
echo "Created ../data/finances/views.rdf"

saxonb-xslt -s ../data/finances/finance/wc6g-9zmq.xml -xsl ../scripts/xsl/finances-meta.xsl wbapi_lang=en pathToCountries=../data/indicators/en/countries.xml pathToLendingTypes=../data/indicators/en/lendingTypes.rdf pathToRegionsExtra=../data/regions-extra.rdf pathToMeta=../data/meta/meta.rdf pathToCurrencies=../data/currencies.rdf pathToFinancesDictionary=../data/finances/finance/wc6g-9zmq.rdf financeDatasetID=wc6g-9zmq > ../data/finances/finance/wc6g-9zmq.rdf
echo "Created ../data/finances/finance/wc6g-9zmq.rdf"

cat ../data/finances/finances.datasets.txt | while read i ; do saxonb-xslt -s ../data/finances/finance/"$i".xml -xsl ../scripts/xsl/finances-meta.xsl wbapi_lang=en pathToCountries=../data/indicators/en/countries.xml pathToLendingTypes=../data/indicators/en/lendingTypes.rdf pathToRegionsExtra=../data/regions-extra.rdf pathToMeta=../data/meta/meta.rdf pathToCurrencies=../data/currencies.rdf pathToFinancesDictionary=../data/finances/finance/wc6g-9zmq.rdf financeDatasetID="$i" > ../data/meta/meta.finance."$i".rdf ; echo "Created ../data/meta/meta.finance.$i.rdf" ; done

#for i in ../data/meta/meta.finance.*rdf;
#    do rapper -g "$i" >> ../data/temp.finances-meta.nt ;
#rm "$i" ;
#done

#sort ../data/temp.finances-meta.nt | uniq > ../data/finances-meta.nt

#rm ../data/temp.finances-meta.nt
#rm ../data/temp*rdf

