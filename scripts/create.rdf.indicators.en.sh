#!/bin/bash

#PRWODI=$PWD
#BN=$BASENAME
pwdrelative=${PWD##*/}

for file in /var/www/lib/worldbank-linkeddata/data/indicators/en/*.xml;
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};

        saxonb-xslt -s $file -xsl /var/www/lib/worldbank-linkeddata/scripts/xsl/$graph.xsl wbapi_lang=en > /var/www/lib/worldbank-linkeddata/data/indicators/en/$graph.rdf
        echo "Created /var/www/lib/worldbank-linkeddata/data/indicators/en/$graph.rdf"
    done;
