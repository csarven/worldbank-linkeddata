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

rapper -g /var/www/lib/worldbank-linkeddata/data/worldbank-sameAs-eurostat_countries.nt >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;

rapper -g /var/www/lib/worldbank-linkeddata/data/worldbank-sameAs-dbpedia_currencies.nt >> /var/www/lib/worldbank-linkeddata/data/import/graph.meta.nt ;


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

rapper -g /var/www/lib/worldbank-linkeddata/data/projects/projects-and-operations.rdf >> /var/www/lib/worldbank-linkeddata/data/import/graph.world-bank-projects-and-operations.nt ;

#The following two imports take a while i.e., 6-12 hours each. They are commented out in order to execute them manually when really needed.
#for file in /var/www/lib/worldbank-linkeddata/data/indicators/en/indicator/*.rdf ; do rapper -g $file >> /var/www/lib/worldbank-linkeddata/data/import/graph.world-development-indicators.nt ; done ;

#for file in /var/www/lib/worldbank-linkeddata/data/climates/*/*/*.rdf ; do rapper -g $file >> /var/www/lib/worldbank-linkeddata/data/import/graph.world-bank-climates.nt ; done ;

