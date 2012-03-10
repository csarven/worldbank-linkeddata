#!/bin/bash

rapper -g /var/www/lib/worldbank-linkeddata/data/meta/meta.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

for file in /var/www/lib/worldbank-linkeddata/data/indicators/en/*.rdf
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};

        rapper -g $file >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;
    done ;

rapper -g /var/www/lib/worldbank-linkeddata/data/regions-extra.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/topics-extra.ttl >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/income-levels-extra.ttl >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/currencies.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/worldbank-sameAs-dbpedia_countries.nt >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/worldbank-exactMatch-dbpedia_currencies.nt >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;



rapper -g /var/www/lib/worldbank-linkeddata/data/finances/views.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/finances/finance/wc6g-9zmq.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

for file in /var/www/lib/worldbank-linkeddata/data/finances/finance/*.rdf
    do
        filename=$(basename $file);
        extension=${filename##*.};
        graph=${filename%.*};

        if [ "$graph" != "wc6g-9zmq" ] ; then
            rapper -g $file >> /var/www/lib/worldbank-linkeddata/data/import/graph.world-bank-finances.nt ;
        fi
    done ;


#for file in /var/www/lib/worldbank-linkeddata/data/indicators/en/indicator/*.rdf ; do rapper -g $file >> /var/www/lib/worldbank-linkeddata/data/import/graph.world-development-indicators.nt ; done ;

#rapper -g /var/www/lib/worldbank-linkeddata/data/projects/projects-and-operations.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.projects-and-operations.nt ;


