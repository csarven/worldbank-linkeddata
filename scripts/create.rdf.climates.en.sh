#!/bin/bash
#    Author: Sarven Capadisli <info@csarven.ca>
#    Author URL: http://csarven.ca/#i

basePath="/var/www/lib/worldbank-linkeddata/data/climates/" ;
pathToCountries="/var/www/lib/worldbank-linkeddata/data/indicators/en/countries.xml" ;

areas=(country basin) ;
statstypes=(mavg annualavg manom annualanom month-average-historical year-average-historical decade-average-historical mavg-ensemble annualavg-ensemble manom-ensemble annualanom-ensemble mavg-ensemble-derived annualavg-ensemble-derived manom-ensemble-derived annualanom-ensemble-derived) ;
variables=(pr tas tmin_means tmax_means tmax_days90th tmin_days90th tmax_days10th tmin_days10th tmin_days0 ppt_days ppt_days2 ppt_days10 ppt_days90th ppt_dryspell ppt_means) ;

for area in "${areas[@]}" ;
    do
        for statstype in "${statstypes[@]}" ;
            do
                for variable in "${variables[@]}" ;
                    do
                        ls -1 "$basePath""$area"/"$statstype"/*."$variable".xml | while read file ;
                            do
                                filename=$(basename $file);
                                extension=${filename##*.};
                                graph=${filename%.*};

                                areaCode=`echo "$graph" | perl -pe 's/([^\.]+).*/$1/'`

                                if [[ "$area" = "country" ]]
                                then
                                    code="countryCode=$areaCode" ;
                                else
                                    code="basinCode=$areaCode" ;
                                fi

                                saxonb-xslt -s "$file" /var/www/lib/worldbank-linkeddata/scripts/xsl/climates.xsl wbapi_lang=en pathToCountries=$pathToCountries $code statstypeCode="$statstype" variableCode="$variable" > "$basePath""$area"/"$statstype"/"$graph".rdf

                                echo "Created $basePath$area/$statstype/$graph.rdf"
                            done
                    done
            done
    done

