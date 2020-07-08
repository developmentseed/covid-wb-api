#!/bin/bash
set -e
BASEDIR=/home/bitner/devseed/wb-covid/workspace/home/wb411133/data/Projects/CoVID/
export PG_USE_COPY=YES
NJOBS=10

export base_cols="geom_key,R10_SUM,P1_SUM,P2_SUM,LC_11,LC_14,LC_20,LC_30,LC_40,LC_50,LC_60,LC_70,LC_90,LC_100,LC_110,LC_120,LC_130,LC_140,LC_150,LC_160,LC_170,LC_180,LC_190,LC_200,LC_210,LC_220,LC_230"

export base_pgcols=$(echo "${base_cols}" | tr '[:upper:]' '[:lower:]')

function load_base {
    file="$1"
    base="$2"
    adm0="$3"

    # echo "**************  $file $base $adm0 ***************************" >/dev/stderr
    csvcut -c "$base_cols" -x $file | csvcut -K 1 | \
    psql -c "copy ${base}_base_stats (${base_pgcols}) FROM stdin WITH CSV;"
}
export -f load_base

function load {
    adm0=$(echo "$1" | sed -nr 's/^.*CoVID\/([A-Z]{3})\/.*$/\1/p')
    load_base "$1" "$2" "$adm0"
}
export -f load

function load_all {
    echo "****************** LOADING $1 ***************************"
    find $BASEDIR | \
    egrep -i "$1" | grep -i base | \
    parallel -j $NJOBS "load {} $2"
}
export -f load_all

# psql -f db_schema.sql

load_all adm0 adm0
load_all adm1 adm1
load_all adm2 adm2
load_all urban_areas urban_areas
load_all urban_areas_hd urban_areas_hd
load_all "urban_[0-9]+" urban_fishnets
load_all "hd_urban_[0-9]+" hd_urban_fishnets

# postprocess loaded data
psql <<EOSQL

EOSQL