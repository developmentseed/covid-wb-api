# covid-wb-api
COVID-19 Risk Schema API for the World Bank

## Running the API locally
The API requires a PostgreSQL/PostGIS Database as well which must be set up separately. An RDS instance can be used which can be populated using the tools in the etl directory.
* [Setup docker](https://www.docker.com/get-started)
* Clone this repo `git clone https://github.com/developmentseed/covid-wb-api.git`
* Build docker image `docker build -t covid-wb-api .`
* Create a new environment by copying `.env-sample` to `.env` and changing the variables to point to your PostgreSQL Instance.
* Run `docker run --env-file ./.env -p 8080:80 covid-wb-api`
* Now visit http://localhost:8080 to see the API

## CI
CircleCI builds a new image and tags it with `latest`, branch name and the unique circle build number. This is pushed to AWS ECR for this project. For deploying, see cloudformation/README.md.

## USAGE
This is using an instance that may not be currently running.

### OpenAPI documentation for all API endpoints is available at 
http://covid-publi-1onc9lx0j49x6-1338300620.us-east-1.elb.amazonaws.com/

### Available layers are:
adm0, adm0_full, adm1, adm1_full, adm2, adm2_full, hd_urban_fishnets, hd_urban_fishnets_full, urban_areas, urban_areas_full, urban_areas_hd, urban_areas_hd_full, urban_fishnets, urban_fishnets_full

The difference with the *_full is that those layers include all the attributes from the tables that you provided in addition to the attributes included in the original geojson files.
 
Basic usage to get just the attributes for a single feature using either the geohash or the ogc_fid
http://covid-publi-1onc9lx0j49x6-1338300620.us-east-1.elb.amazonaws.com/vector/info/{layer}/{geohash or ogc_fid}

So to get all the fields available for the ADM 1 feature with geohash=sh5rcxz20wjh you would use:

http://covid-publi-1onc9lx0j49x6-1338300620.us-east-1.elb.amazonaws.com/vector/info/adm1/sh5rcxz20wjh

You can limit the columns returned by selecting just a list of the columns with columns=wb_adm0_na,wb_adm1_na,geohash,ogc_fid

http://covid-publi-1onc9lx0j49x6-1338300620.us-east-1.elb.amazonaws.com/vector/info/adm1_full/sh5rcxz20wjh?columns=lc_20,lc_100,ogc_fid,geohash

You can select the id to query by with keycol={ogc_fid, geohash, wb_adm0_co, wb_adm1_co, wb_adm2_co, objectid (pick one)}. If it is not a primary column for the layer you selected it will return multiple results.

So the above could also be done using a get request with the admin code:

http://covid-publi-1onc9lx0j49x6-1338300620.us-east-1.elb.amazonaws.com/vector/info/adm1/381?keycol=wb_adm1_co&columns=lc_20,lc_100,ogc_fid,geohash,wb_adm1_co,wb_adm1_na

When multiple results are returned you can use reportkey= to specify the key that is used as the index for the returned json object.

OpenAPI docs -> http://covid-publi-1onc9lx0j49x6-1338300620.us-east-1.elb.amazonaws.com/#/Vector%20Tile%20API/feature_info_vector_info__table___id__get

Example to get all the adm1 attributes selected by the adm0 code:
http://covid-publi-1onc9lx0j49x6-1338300620.us-east-1.elb.amazonaws.com/vector/info/adm1/1?keycol=wb_adm0_co&reportkey=wb_adm1_co

The vector tile service is accessed by entering either the xyz pattern or tilejson endpoint for the layer into a client that can use vector tiles (latest QGIS, OpenLayers, MapboxGL,...).

Example to get the TileJson config for adm0:

http://covid-publi-1onc9lx0j49x6-1338300620.us-east-1.elb.amazonaws.com/vector/adm0.json

Using the "base" layer name (ie adm0) will only provide the attributes provided with the geojson. Using the *_full (ie adm0_full) layername will include all attributes with the vector tiles -- if using the _full layer, you should use a columns filter otherwise it will be a huge amount of data in the return.

There is a basic vector tile viewer endpoint as well that can be accessed at the /vector/demo/{table} endpoint.

To see all the adm0 features:

http://covid-publi-1onc9lx0j49x6-1338300620.us-east-1.elb.amazonaws.com/vector/demo/adm1/

You can click on the features to see the attributes that are included.

Metadata for the fields returned is simply a return of the json file that you provided. 

http://covid-publi-1onc9lx0j49x6-1338300620.us-east-1.elb.amazonaws.com/RiskSchema.json
