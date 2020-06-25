#!/bin/bash
set -e
BASEDIR=/home/bitner/devseed/wb-covid/data/V2ZIPFILES
export PGDATABASE=covidwb

function cog {
    gdalbuildvrt $1.vrt $(find $BASEDIR | grep -i "$1\.tif" )
    rio cogeo create --cog-profile lzw --web-optimized $1.vrt $1.tif
    rm $1.vrt
}
export -f cog

cog wp_2020_1km
cog wp2020_vulnerability_map
cog wp_2020_1km_urban_pop
cog lc
