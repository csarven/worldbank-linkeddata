#!/bin/bash

. ./config.sh

#PRWODI=$PWD
#BN=$BASENAME
pwdrelative=${PWD##*/}

for file in ../data/indicators/en/indicator/*.xml;
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};

#        java "$JVM_ARGS" net.sf.saxon.Transform -s "$file" -xsl ../scripts/xsl/indicatorsObservations.xsl wbapi_lang=en > ../data/indicators/en/indicator/"$graph".rdf
        saxonb-xslt -t -tree:linked -ext:on -s "$file" -xsl ../scripts/xsl/indicatorsObservations.xsl wbapi_lang=en > ../data/indicators/en/indicator/"$graph".rdf

        echo "Created ../data/indicators/en/indicator/$graph.rdf"
    done;
