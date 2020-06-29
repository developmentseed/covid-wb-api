DROP TABLE IF EXISTS adm0;
CREATE TABLE IF NOT EXISTS adm0 (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    objectid int,
    iso_a2 text,
    wb_adm0_co int,
    wb_adm0_na text,
    iso3 text,
    un_m49 int,
    region text,
    incomeg text,
    lendingc text,
    fid_100 int,
    geohash text
);
CREATE INDEX ON adm0 USING GIST (geom);

DROP TABLE IF EXISTS adm1;
CREATE TABLE IF NOT EXISTS adm1 (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    iso3 text,
    iso_a2 text,
    objectid int,
    wb_admo_co int,
    wb_adm0_na text,
    wb_adm1_co int,
    wb_adm1_na text,
    geohash text
);
CREATE INDEX ON adm1 USING GIST (geom);

DROP TABLE IF EXISTS adm2;
CREATE TABLE IF NOT EXISTS adm2 (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    iso3 text,
    iso_a2 text,
    objectid int,
    wb_adm0_co int,
    wb_adm0_na text,
    wb_adm1_co int,
    wb_adm1_na text,
    wb_adm2_co int,
    wb_adm2_na text,
    geohash text
);
CREATE INDEX ON adm2 USING GIST (geom);

DROP TABLE IF EXISTS urban_areas;
CREATE TABLE urban_areas (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    id int,
    pop float,
    geohash text
);
CREATE INDEX ON urban_areas USING GIST (geom);

DROP TABLE IF EXISTS urban_areas_hd;
CREATE TABLE urban_areas_hd (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    id int,
    pop float,
    geohash text
);
CREATE INDEX ON urban_areas_hd USING GIST (geom);

DROP TABLE IF EXISTS urban_fishnets;
CREATE TABLE urban_fishnets (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    fid int,
    geohash text
);
CREATE INDEX ON urban_fishnets USING GIST (geom);
CREATE INDEX ON urban_fishnets (geohash);

DROP TABLE IF EXISTS hd_urban_fishnets;
CREATE TABLE hd_urban_fishnets (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    fid int,
    geohash text
);
CREATE INDEX ON hd_urban_fishnets USING GIST (geom);
CREATE INDEX ON hd_urban_fishnets (geohash);