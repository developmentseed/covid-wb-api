#!/usr/bin/env bash

# create merged COGs from per-country rasters

set -e

# note: first prepare BASEDIR by downloading from s3, and unzip the .tif archives:
#   aws s3 sync s3://covid-wb/data ./s3-data
#   cd s3-data
#   for f in $(ls *_tiffs.zip); do unzip $f; done
# Warning: there is lot of duplicated data in the s3 bucket, needs cleaning 2020-07-10.
BASEDIR=../../covid-wb/s3-data

# create a vrt from all input tifs. apply a workaround for bad nodata attributes on several of the layers.
function build_vrt() {
  layer=$1 # layer name
  nodata_value=$2 # what the actual nodata was discovered to be by manual inspection of data dump.
  # find all country tifs in the base directory matching the layer name
  # TODO: Dont forget FIJI.here we omit FJI because it wraps across international date line, causing problems with rasterio/titiler.
  country_tifs=$(find $BASEDIR -iname "${layer}\.tif" | grep --invert-match FJI)
  fixed_tifs=()
  # fix bad nodata attributes on the src tifs
  for src in $country_tifs; do
    tmp=$(mktemp /tmp/load_tifs_XXX)
    gdal_translate -a_nodata "$nodata_value" "$src" "$tmp"
    fixed_tifs+="${tmp} "
  done
  # create virtual format for merged COG sourced from all fixed country tifs
  gdalbuildvrt "${1}.vrt" ${fixed_tifs[@]}
}
export -f build_vrt

# build_population_cog requires .vrt alread exists
function build_population_cog() {
  layer=$1 # layer name
  rio cogeo create --web-optimized --overview-resampling nearest "${layer}.vrt" "${layer}.tif"
  rio cogeo validate "${layer}.tif"
}
export -f build_population_cog

# landcover layer is 1 band of Byte classification
build_vrt lc 0
gdal_translate -of GTiff lc.vrt lc_colormap.tif
python ./lc_colormap.py
rio cogeo create --web-optimized lc_colormap.tif lc.tif
rio cogeo validate lc.tif

# population layers: 1 band of Float32

# Workarounds for bad nodata attributes:
# WP_2020_1km_urban_pop.tif has values 0,-0.0 for actual nodata (found by sampling the 4 corners)
# WP2020_vulnerability_map.tif has nan for actual nodata (found by sampling the 4 corners)
# WP_2020_1km.tif has -3.4E+038 for actual nodata (found by sampling the 4 corners)
# TODO: ask WB to QA it in their analysis/export workflow

build_vrt wp_2020_1km "-3.4028235e+38"
build_population_cog wp_2020_1km

build_vrt wp_2020_1km_urban_pop 0
build_population_cog wp_2020_1km_urban_pop

build_vrt wp2020_vulnerability_map nan
build_population_cog wp2020_vulnerability_map

rm ./*_colormap.tif ./*.vrt ./*.aux.xml /tmp/load_tifs*
