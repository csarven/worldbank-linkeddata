#!/bin/bash

#PRWODI=$PWD
#BN=$BASENAME
pwdrelative=${PWD##*/}

for file in /var/www/lib/worldbank-linkeddata/data/finances/views.xml;
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};

        saxonb-xslt -s $file -xsl /var/www/lib/worldbank-linkeddata/scripts/xsl/financesViews.xsl wbapi_lang=en pathToMeta=/var/www/lib/worldbank-linkeddata/data/meta.rdf > /var/www/lib/worldbank-linkeddata/data/finances/views.rdf
        echo "Created /var/www/lib/worldbank-linkeddata/data/finances/views.rdf"
    done;
