#!/bin/bash
set -e
BASEDIR=/home/bitner/devseed/wb-covid/geojson-files
export PG_USE_COPY=YES
NJOBS=10

function cols {
    echo $(fio info "$1" | jq '.schema.properties | keys | join("|")')
}
export -f cols

function metadata {
    echo -e "$1\t$(cols $1)"
}
export -f metadata

function load {
    file=$1
    [ -z "$2" ] && base=$(basename $file .geojson) || base=$2
    #[[ $base =~ (.*)_[0-9]+$ ]] && base=${BASH_REMATCH[1]}

    echo $base
    ogr2ogr -f PGDump \
    -lco CREATE_TABLE=OFF \
    -lco DROP_TABLE=OFF \
    -lco GEOMETRY_NAME=geom \
    -nlt PROMOTE_TO_MULTI  \
    -nln $base \
    -t_srs EPSG:4326 \
    /vsistdout/ $file | psql
}
export -f load

function load_all {
    echo "****************** LOADING $1 ***************************"
    find $BASEDIR | \
    egrep -i "$1" | \
    parallel -j $NJOBS "load {} $2"
}
export -f load_all

psql -f db_schema.sql

load_all adm0.geojson
load_all adm1.geojson
load_all adm2.geojson
load_all urban_areas.geojson
load_all urban_areas_hd.geojson
load_all "urban_[0-9]+\.geojson" urban_fishnets
load_all "hd_urban_[0-9]+\.geojson" hd_urban_fishnets
