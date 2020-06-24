#!/bin/bash
set -e
BASEDIR=/home/bitner/devseed/wb-covid/data/V2ZIPFILES
export PG_USE_COPY=YES
export PGDATABASE=covidwb

cd $BASEDIR
function cols {
    echo $(fio info "$1" | jq '.schema.properties | keys | join("|")')
}
export -f cols

function metadata {
    echo -e "$1\t$(cols $1)"
}
export -f metadata

function load {
    ogr2ogr -f PGDump \
    -lco CREATE_TABLE=OFF \
    -lco DROP_TABLE=OFF \
    -nlt PROMOTE_TO_MULTI  \
    -nln $2 \
    -t_srs EPSG:4326 \
    /vsistdout/ $1 | psql
}
export -f load

# ADM 0
psql <<SQL
DROP TABLE IF EXISTS adm0;
CREATE TABLE IF NOT EXISTS adm0 (
    "ogc_fid" SERIAL PRIMARY KEY,
    wkb_geometry geometry(MULTIPOLYGON,4326),
    fid_100 int,
    iso3 text,
    iso_a2 text,
    objectid int,
    p1_sum float,
    p2_sum float,
    r10_sum float,
    region text,
    shape_area float,
    shape_leng float,
    un_m49 int,
    wb_adm0_co int,
    wb_adm0_na text,
    incomeg text,
    lendingc text
);
CREATE INDEX ON adm0 USING GIST (wkb_geometry);
SQL
for f in $(find . | egrep -i 'adm_?0\.shp')
do
    base=$(basename $f)
    dir=$(dirname $f)
    [ "$base" = "ADM_0.shp" -a -f "${dir}adm0.shp" ] && continue
    # metadata $f
    load $f adm0
done


# ADM 1
psql <<SQL
DROP TABLE IF EXISTS adm1;
CREATE TABLE IF NOT EXISTS adm1 (
    "ogc_fid" SERIAL PRIMARY KEY,
    wkb_geometry geometry(MULTIPOLYGON,4326),
    fid_100 int,
    iso3 text,
    iso_a2 text,
    objectid int,
    p1_sum float,
    p2_sum float,
    r10_sum float,
    shape_area float,
    shape_leng float,
    wb_admo_co int,
    wb_adm0_na text,
    wb_adm1_co int,
    wb_adm1_na text
);
CREATE INDEX ON adm1 USING GIST (wkb_geometry);
SQL
for f in $(find . | egrep -i 'adm_?1\.shp')
do
    base=$(basename $f)
    dir=$(dirname $f)
    [ "$base" = "ADM_1.shp" -a -f "${dir}/adm1.shp" ] && continue
    load $f adm1
done

# ADM 2
psql <<SQL
DROP TABLE IF EXISTS adm2;
CREATE TABLE IF NOT EXISTS adm2 (
    "ogc_fid" SERIAL PRIMARY KEY,
    wkb_geometry geometry(MULTIPOLYGON,4326),
    fid_100 int,
    iso3 text,
    iso_a2 text,
    objectid int,
    p1_sum float,
    p2_sum float,
    r10_sum float,
    shape_area float,
    shape_leng float,
    wb_adm0_co int,
    wb_adm0_na text,
    wb_adm1_co int,
    wb_adm1_na text,
    wb_adm2_co int,
    wb_adm2_na text
);
CREATE INDEX ON adm2 USING GIST (wkb_geometry);
SQL
for f in $(find . | egrep -i 'adm_?2\.shp')
do
    base=$(basename $f)
    dir=$(dirname $f)
    [ "$base" = "ADM_2.shp" -a -f "${dir}/adm2.shp" ] && continue
    load $f adm2
done

# Urban Areas
psql <<SQL
DROP TABLE IF EXISTS urban_areas;
CREATE TABLE urban_areas (
    "ogc_fid" SERIAL PRIMARY KEY,
    wkb_geometry geometry(MULTIPOLYGON,4326),
    id int,
    p1_sum float,
    p2_sum float,
    r10_sum float,
    pop float
);
CREATE INDEX ON urban_areas USING GIST (wkb_geometry);
SQL
echo "************** LOADING URBAN AREAS ********************"

find . | \
    egrep -i 'urban_areas\.shp' | \
    parallel -j 4 "load {} urban_areas"


# Urban Areas HD
psql <<SQL
DROP TABLE IF EXISTS urban_areas_hd;
CREATE TABLE urban_areas_hd (
    "ogc_fid" SERIAL PRIMARY KEY,
    wkb_geometry geometry(MULTIPOLYGON,4326),
    id int,
    p1_sum float,
    p2_sum float,
    r10_sum float,
    pop float
);
CREATE INDEX ON urban_areas_hd USING GIST (wkb_geometry);
SQL
echo "************** LOADING URBAN AREAS HD ********************"
find . | \
    egrep -i 'urban_areas_hd\.shp' | \
    parallel -j 4 "load {} urban_areas_hd"


# Urban Area Fishnets
psql <<SQL
DROP TABLE IF EXISTS urban_fishnets;
CREATE TABLE urban_fishnets (
    "ogc_fid" SERIAL PRIMARY KEY,
    wkb_geometry geometry(MULTIPOLYGON,4326),
    fid int,
    geohash text
);
CREATE INDEX ON urban_fishnets USING GIST (wkb_geometry);
CREATE INDEX ON urban_fishnets (geohash);
SQL
echo "************** LOADING URBAN FISHNETS ********************"

find . | \
    egrep -i '\/urban_[0-9]+\.shp' | \
    parallel -j 4 "load {} urban_fishnets"

# HD Urban Area Fishnets
psql <<SQL
DROP TABLE IF EXISTS hd_urban_fishnets;
CREATE TABLE hd_urban_fishnets (
    "ogc_fid" SERIAL PRIMARY KEY,
    wkb_geometry geometry(MULTIPOLYGON,4326),
    fid int,
    geohash text
);
CREATE INDEX ON hd_urban_fishnets USING GIST (wkb_geometry);
CREATE INDEX ON hd_urban_fishnets (geohash);
SQL
echo "************** LOADING URBAN FISHNETS HD ********************"

find . | \
    egrep -i 'hd_urban_[0-9]+\.shp' | \
    parallel -j 4 "load {} hd_urban_fishnets"
