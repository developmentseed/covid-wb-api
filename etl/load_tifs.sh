#!/usr/bin/env bash

# create merged COGs from per-country rasters

set -e

# note: first prepare BASEDIR by downloading from s3, and unzip the .tif archives:
#   aws s3 sync s3://covid-wb/data ./s3-data
#   cd s3-data
#   for f in $(ls *_tiffs.zip); do unzip $f; done
# Warning: there is lot of duplicated data in the s3 bucket, needs cleaning 2020-07-10.
BASEDIR=../../covid-wb/s3-data

# create a vrt from all input tifs.
function build_vrt() {
  # find all country tifs in the base directory matching the layer name
  country_tifs=$(find $BASEDIR -iname "${1}\.tif")
  # create virtual format for merged COG sourced from all country tifs
  gdalbuildvrt "${1}.vrt" $country_tifs
}
export -f build_vrt

function build_population_cog() {
  layer=$1
  build_vrt "$layer"
  rio cogeo create --web-optimized --overview-resampling nearest "${layer}.vrt" "${layer}.tif"
  rio cogeo validate "${layer}.tif"
}
export -f build_population_cog

# landcover layer is 1 band of Byte classification
build_vrt lc
gdal_translate -of GTiff lc.vrt lc_colormap.tif
python ./lc_colormap.py
rio cogeo create --web-optimized lc_colormap.tif lc.tif
rio cogeo validate lc.tif

# population layers: 1 band of Float64
build_population_cog wp_2020_1km
build_population_cog wp_2020_1km_urban_pop
build_population_cog wp2020_vulnerability_map

rm ./*_colormap.tif ./*.vrt
