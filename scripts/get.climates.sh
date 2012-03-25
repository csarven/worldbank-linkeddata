#!/bin/bash
#    Author: Sarven Capadisli <info@csarven.ca>
#    Author URL: http://csarven.ca/#i

basePath="/var/www/lib/worldbank-linkeddata/data/climates/" ;

mkdir -p "$basePath"country/mavg
mkdir -p "$basePath"country/annualavg
mkdir -p "$basePath"country/manom
mkdir -p "$basePath"country/annualanom
mkdir -p "$basePath"country/month-average-historical
mkdir -p "$basePath"country/year-average-historical
mkdir -p "$basePath"country/decade-average-historical

mkdir -p "$basePath"basin/mavg
mkdir -p "$basePath"basin/annualavg
mkdir -p "$basePath"basin/manom
mkdir -p "$basePath"basin/annualanom
mkdir -p "$basePath"basin/month-average-historical
mkdir -p "$basePath"basin/year-average-historical
mkdir -p "$basePath"basin/decade-average-historical

dtstarts=(1920 1940 1960 1980 2020 2040 2060 2080) ;
dtends=(1939 1959 1979 1999 2039 2059 2079 2099) ;

statstypes=(mavg annualavg) ;
variables=(pr tas) ;

counter=0 ;

#mavg annualavg
while read country ;
    do
        for statstype in "${statstypes[@]}" ;
            do
                for variable in "${variables[@]}" ;
                    do
                        let "counter=0" ;

                        for dtstart in "${dtstarts[@]}" ;
                            do
                                dtend=`expr ${dtends[$counter]}` ;

                                wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/country/"$statstype"/"$variable"/"$dtstart"/"$dtend"/"$country".xml -O "$basePath"country/"$statstype"/"$country"."$dtstart"."$dtend"."$statstype"."$variable".xml

                                (( counter++ )) ;
                            done ;
                    done ;
            done ;
    done < /var/www/lib/worldbank-linkeddata/data/iso-3166_alpha-3.txt


#basinID
for basinID in `seq 1 468`;
    do
        for statstype in "${statstypes[@]}" ;
            do
                for variable in "${variables[@]}"
                    do
                        let "counter=0" ;

                        for dtstart in "${dtstarts[@]}"
                            do
                                dtend=`expr ${dtends[$counter]}` ;

                                wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/basin/"$statstype"/"$variable"/"$dtstart"/"$dtend"/"$basinID".xml -O "$basePath"basin/"$statstype"/"$basinID"."$dtstart"."$dtend"."$statstype"."$variable".xml

                                (( counter++ )) ;
                            done ;
                    done ;
            done ;

        (( basinID++ )) ;
    done ;



dtstarts=(2020 2040 2060 2080) ;
dtends=(2039 2059 2079 2099) ;

statstypes=(manom annualanom) ;
variables=(pr tas) ;

counter=0 ;

#manom annualanom
while read country ;
    do
        for statstype in "${statstypes[@]}" ;
            do
                for variable in "${variables[@]}" ;
                    do
                        let "counter=0" ;

                        for dtstart in "${dtstarts[@]}" ;
                            do
                                dtend=`expr ${dtends[$counter]}` ;

                                wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/country/"$statstype"/"$variable"/"$dtstart"/"$dtend"/"$country".xml -O "$basePath"country/"$statstype"/"$country"."$dtstart"."$dtend"."$statstype"."$variable".xml

                                (( counter++ )) ;
                            done ;
                    done ;
            done ;
    done < /var/www/lib/worldbank-linkeddata/data/iso-3166_alpha-3.txt




dtstarts=(2020 2040 2060 2080) ;
dtends=(2039 2059 2079 2099) ;

statstypes=(manom annualanom) ;
variables=(pr tas) ;

counter=0 ;

#basinID
for basinID in `seq 1 468`;
    do
        for statstype in "${statstypes[@]}" ;
            do
                for variable in "${variables[@]}"
                    do
                        let "counter=0" ;

                        for dtstart in "${dtstarts[@]}"
                            do
                                dtend=`expr ${dtends[$counter]}` ;

                                wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/basin/"$statstype"/"$variable"/"$dtstart"/"$dtend"/"$basinID".xml -O "$basePath"basin/"$statstype"/"$basinID"."$dtstart"."$dtend"."$statstype"."$variable".xml

                                (( counter++ )) ;
                            done ;
                    done ;
            done ;

        (( basinID++ )) ;
    done ;



#Historical Data
statstypes=(month year decade) ;
variables=(pr tas) ;

#Historical Data - month year decade
while read country ;
    do
        for statstype in "${statstypes[@]}" ;
            do
                for variable in "${variables[@]}" ;
                    do
                        wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/country/cru/"$variable"/"$statstype"/"$country".xml -O "$basePath"country/"$statstype"-average-historical/"$country"."$statstype"."$variable".xml

                        (( counter++ )) ;
                    done ;
            done ;
    done < /var/www/lib/worldbank-linkeddata/data/iso-3166_alpha-3.txt



statstypes=(month year decade) ;
variables=(pr tas) ;

#Historical Data - basinID
for basinID in `seq 1 468`;
    do
        for statstype in "${statstypes[@]}" ;
            do
                for variable in "${variables[@]}"
                    do
                        wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/basin/cru/"$variable"/"$statstype"/"$basinID".xml -O "$basePath"basin/"$statstype"-average-historical/"$basinID"."$statstype"."$variable".xml
                    done ;
            done ;

        (( basinID++ )) ;
    done ;

