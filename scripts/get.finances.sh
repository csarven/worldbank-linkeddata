#!/bin/bash

#This gets everything from views.
#xmllint --format /var/www/lib/worldbank-linkeddata/data/finances/views.xml | grep "view id" | perl -pe 's/\s*<view id=\"([^\"]*)\".*/$1/' | sort | uniq | while read i ; do wget "https://finances.worldbank.org/api/views/$i/rows.xml" -O "/var/www/lib/worldbank-linkeddata/data/finances/finance/$i.xml" ; done

wget http://finances.worldbank.org/api/views.xml -O /var/www/lib/worldbank-linkeddata/data/finances/views.xml

wget https://finances.worldbank.org/api/views/wc6g-9zmq/rows.xml -O /var/www/lib/worldbank-linkeddata/data/finances/finance/wc6g-9zmq.xml

cat /var/www/lib/worldbank-linkeddata/data/finances/finances.datasets.txt | while read i ; do wget "https://finances.worldbank.org/api/views/$i/rows.xml" -O "/var/www/lib/worldbank-linkeddata/data/finances/finance/$i.xml" ; done
