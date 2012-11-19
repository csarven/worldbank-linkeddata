#!/bin/bash

#PRWODI=$PWD
#BN=$BASENAME
pwdrelative=${PWD##*/}

for file in ../data/indicators/en/*.xml;
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};

        saxonb-xslt -s "$file" -xsl ../scripts/xsl/"$graph".xsl wbapi_lang=en pathToCountries=../data/indicators/en/countries.xml > ../data/indicators/en/"$graph".rdf
        echo "Created ../data/indicators/en/$graph.rdf"
    done;
