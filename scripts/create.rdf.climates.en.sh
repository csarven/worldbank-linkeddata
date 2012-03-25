#!/bin/bash
#    Author: Sarven Capadisli <info@csarven.ca>
#    Author URL: http://csarven.ca/#i

basePath="/var/www/lib/worldbank-linkeddata/data/climates/" ;
pathToCountries="/var/www/lib/worldbank-linkeddata/data/indicators/en/countries.xml" ;

areas=(country basin) ;
statstypes=(mavg annualavg manom annualanom month-average-historical year-average-historical decade-average-historical) ;
variables=(pr tas) ;

for area in "${areas[@]}" ;
    do
        for statstype in "${statstypes[@]}" ;
            do
                for variable in "${variables[@]}" ;
                    do
                        for file in "$basePath""$area"/"$statstype"/*."$variable".xml
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

