#!/bin/bash

state=".staging";
tdbAssembler="/usr/lib/fuseki/tdb.worldbank$state.ttl";
JVM_ARGS="-Xmx16000M";

#java "$JVM_ARGS" tdb.tdbloader --desc="$tdbAssembler" --graph=http://worldbank.270a.info/graph/world-bank-climates ../data/import/graph.world-bank-climates.nt

#java "$JVM_ARGS" tdb.tdbloader --desc="$tdbAssembler" --graph=http://worldbank.270a.info/graph/world-development-indicators /data/worldbank-linkeddata/data/import/graph.world-development-indicators.nt

#java "$JVM_ARGS" tdb.tdbloader --desc="$tdbAssembler" --graph=http://worldbank.270a.info/graph/world-bank-finances ../data/import/graph.world-bank-finances.nt

#java "$JVM_ARGS" tdb.tdbloader --desc="$tdbAssembler" --graph=http://worldbank.270a.info/graph/world-bank-projects-and-operations ../data/import/graph.world-bank-projects-and-operations.nt

#for i in ../data/meta/meta.finance*.rdf ; do java tdb.tdbloader --desc="$tdbAssembler" --graph=http://worldbank.270a.info/graph/meta "$i" ; done

#java "$JVM_ARGS" tdb.tdbloader --desc="$tdbAssembler" --graph=http://worldbank.270a.info/graph/meta ../data/import/graph.meta.nt

#java "$JVM_ARGS" tdb.tdbloader --desc="$tdbAssembler" --graph=http://worldbank.270a.info/graph/void /var/www/worldbank.270a.info/void.ttl
