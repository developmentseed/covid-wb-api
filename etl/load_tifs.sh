#!/usr/bin/env bash

# create merged COGs from per-country rasters

set -e

# note: first prepare BASEDIR by downloading from s3, and unzip the .tif archives:
#   aws s3 sync s3://covid-wb/data ./s3-data
#   cd s3-data
#   for f in $(ls *_tiffs.zip); do unzip $f; done
# Warning: there is lot of duplicated data in the s3 bucket, needs cleaning 2020-07-10.
BASEDIR=../../covid-wb/s3-data

# create a cog from all input tifs. Maintain original data format (e.g. single band of Byte, or single band of Float64)
function cog() {
  # find all country tifs in the base directory matching the layer name
  country_tifs=$(find $BASEDIR -iname "${1}\.tif")
  # create virtual format for merged COG sourced from all country tifs
  gdalbuildvrt "${1}.vrt" $country_tifs
  rio cogeo create --cog-profile lzw --web-optimized "${1}.vrt" "${1}.tif"
  rio cogeo validate "${1}.tif"
}
export -f cog

# Create an additional "visualization" tif with UInt16 format so PNG tile conversion by
# titiler/rasterio does not fail later on. Note: requires cog() be run first to generate the .vrt.
function cog_for_tiler() {
  gdal_translate -of VRT -ot UInt16 -a_nodata 0 "${1}.vrt" "${1}_uint16.vrt"
  rio cogeo create --cog-profile lzw --web-optimized "${1}_uint16.vrt" "${1}_for_tiler.tif"
  rio cogeo validate "${1}_for_tiler.tif"
}
export -f cog_for_tiler

cog lc
cog wp_2020_1km
cog wp2020_vulnerability_map
cog wp_2020_1km_urban_pop

cog_for_tiler wp_2020_1km
cog_for_tiler wp2020_vulnerability_map
cog_for_tiler wp_2020_1km_urban_pop

rm ./*.vrt
