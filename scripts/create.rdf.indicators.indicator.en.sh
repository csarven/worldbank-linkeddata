#!/bin/bash

#PRWODI=$PWD
#BN=$BASENAME
pwdrelative=${PWD##*/}

for file in /var/www/lib/worldbank-linkeddata/data/indicators/en/indicator/*.xml;
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};

        saxonb-xslt -s "$file" -xsl /var/www/lib/worldbank-linkeddata/scripts/xsl/indicatorsObservations.xsl wbapi_lang=en > /var/www/lib/worldbank-linkeddata/data/indicators/en/indicator/"$graph".rdf
        echo "Created /var/www/lib/worldbank-linkeddata/data/indicators/en/indicator/$graph.rdf"
    done;
