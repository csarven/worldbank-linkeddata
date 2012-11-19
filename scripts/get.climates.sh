#!/bin/bash
#    Author: Sarven Capadisli <info@csarven.ca>
#    Author URL: http://csarven.ca/#i

basePath="../data/climates/" ;

mkdir -p "$basePath"country/mavg
mkdir -p "$basePath"country/annualavg
mkdir -p "$basePath"country/manom
mkdir -p "$basePath"country/annualanom
mkdir -p "$basePath"country/month-average-historical
mkdir -p "$basePath"country/year-average-historical
mkdir -p "$basePath"country/decade-average-historical
mkdir -p "$basePath"country/mavg-ensemble
mkdir -p "$basePath"country/annualavg-ensemble
mkdir -p "$basePath"country/manom-ensemble
mkdir -p "$basePath"country/annualanom-ensemble
mkdir -p "$basePath"country/mavg-ensemble-derived
mkdir -p "$basePath"country/annualavg-ensemble-derived
mkdir -p "$basePath"country/manom-ensemble-derived
mkdir -p "$basePath"country/annualanom-ensemble-derived

mkdir -p "$basePath"basin/mavg
mkdir -p "$basePath"basin/annualavg
mkdir -p "$basePath"basin/manom
mkdir -p "$basePath"basin/annualanom
mkdir -p "$basePath"basin/month-average-historical
mkdir -p "$basePath"basin/year-average-historical
mkdir -p "$basePath"basin/decade-average-historical
mkdir -p "$basePath"basin/mavg-ensemble
mkdir -p "$basePath"basin/annualavg-ensemble
mkdir -p "$basePath"basin/manom-ensemble
mkdir -p "$basePath"basin/annualanom-ensemble
mkdir -p "$basePath"basin/mavg-ensemble-derived
mkdir -p "$basePath"basin/annualavg-ensemble-derived
mkdir -p "$basePath"basin/manom-ensemble-derived
mkdir -p "$basePath"basin/annualanom-ensemble-derived



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
    done < ../data/iso-3166_alpha-3.txt


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
    done < ../data/iso-3166_alpha-3.txt


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

#Historical Data - country
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
    done < ../data/iso-3166_alpha-3.txt


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


#Ensembles
dtstarts=(1920 1940 1960 1980 2020 2040 2060 2080) ;
dtends=(1939 1959 1979 1999 2039 2059 2079 2099) ;

statstypes=(mavg annualavg) ;
variables=(pr tas) ;

counter=0 ;

#Ensembles - mavg annualavg
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

                                wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/country/"$statstype"/ensemble/"$variable"/"$dtstart"/"$dtend"/"$country".xml -O "$basePath"country/"$statstype"-ensemble/"$country"."$dtstart"."$dtend".ensemble."$statstype"."$variable".xml

                                (( counter++ )) ;
                            done ;
                    done ;
            done ;
    done < ../data/iso-3166_alpha-3.txt


#Ensembles - mavg annualavg
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

                                wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/basin/"$statstype"/ensemble/"$variable"/"$dtstart"/"$dtend"/"$basinID".xml -O "$basePath"country/"$statstype"-ensemble/"$basinID"."$dtstart"."$dtend".ensemble."$statstype"."$variable".xml

                                (( counter++ )) ;
                            done ;
                    done ;
            done ;

        (( basinID++ )) ;
    done ;



#Ensemble
dtstarts=(2020 2040 2060 2080) ;
dtends=(2039 2059 2079 2099) ;

statstypes=(manom annualanom) ;
variables=(pr tas) ;

counter=0 ;

#Ensemble - manom annualanom
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

                                wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/country/"$statstype"/ensemble/"$variable"/"$dtstart"/"$dtend"/"$country".xml -O "$basePath"country/"$statstype"-ensemble/"$country"."$dtstart"."$dtend".ensemble."$statstype"."$variable".xml

                                (( counter++ )) ;
                            done ;
                    done ;
            done ;
    done < ../data/iso-3166_alpha-3.txt


#Ensemble - manom annualanom
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

                                wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/basin/"$statstype"/ensemble/"$variable"/"$dtstart"/"$dtend"/"$basinID".xml -O "$basePath"basin/"$statstype"-ensemble/"$basinID"."$dtstart"."$dtend".ensemble."$statstype"."$variable".xml

                                (( counter++ )) ;
                            done ;
                    done ;
            done ;

        (( basinID++ )) ;
    done ;





#Ensemble - Derived statistics
dtstarts=(2046 2081)
dtends=(2065 2100)

statstypes=(mavg annualavg manom annualanom)
derivedstatstypes=(tmin_means tmax_means tmax_days90th tmin_days90th tmax_days10th tmin_days10th tmin_days0 ppt_days ppt_days2 ppt_days10 ppt_days90th ppt_dryspell ppt_means)

#Ensemble derived statistics - country
while read country ;
    do
        for statstype in "${statstypes[@]}" ;
            do
                for derivedstatstype in "${derivedstatstypes[@]}" ;
                    do
                        let "counter=0" ;

                        for dtstart in "${dtstarts[@]}" ;
                            do
                                dtend=`expr ${dtends[$counter]}` ;

                                wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/country/"$statstype"/ensemble/"$derivedstatstype"/"$dtstart"/"$dtend"/"$country".xml -O "$basePath"country/"$statstype"-ensemble-derived/"$country"."$dtstart"."$dtend"."$statstype"."$derivedstatstype".xml

                                (( counter++ )) ;
                            done ;
                    done ;
            done ;
    done < ../data/iso-3166_alpha-3.txt

#Ensemble derived statistics - basinid
for basinID in `seq 1 468`;
    do
        for statstype in "${statstypes[@]}" ;
            do
                for derivedstatstype in "${derivedstatstypes[@]}"
                    do
                        let "counter=0" ;

                        for dtstart in "${dtstarts[@]}"
                            do
                                dtend=`expr ${dtends[$counter]}` ;

                                wget -nv http://climatedataapi.worldbank.org/climateweb/rest/v1/basin/"$statstype"/ensemble/"$derivedstatstype"/"$dtstart"/"$dtend"/"$basinID".xml -O "$basePath"basin/"$statstype"-ensemble-derived/"$basinID"."$dtstart"."$dtend"."$statstype"."$derivedstatstype".xml

                                (( counter++ )) ;
                            done ;
                    done ;
            done ;

        (( basinID++ )) ;
    done ;

