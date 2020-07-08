BEGIN;
/*
--DROP TABLE IF EXISTS adm0;
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

--DROP TABLE IF EXISTS adm1;
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

--DROP TABLE IF EXISTS adm2;
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

--DROP TABLE IF EXISTS urban_areas;
CREATE TABLE IF NOT EXISTS urban_areas (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    id int,
    pop float,
    geohash text
);

--DROP TABLE IF EXISTS urban_areas_hd;
CREATE TABLE IF NOT EXISTS  urban_areas_hd (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    id int,
    pop float,
    geohash text
);

--DROP TABLE IF EXISTS urban_fishnets;
CREATE TABLE IF NOT EXISTS urban_fishnets (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    fid int,
    geohash text
);


--DROP TABLE IF EXISTS hd_urban_fishnets;
CREATE TABLE IF NOT EXISTS hd_urban_fishnets (
    "ogc_fid" SERIAL PRIMARY KEY,
    geom geometry(MULTIPOLYGON,4326),
    fid int,
    geohash text
);
*/

DROP TABLE IF EXISTS adm0_base_stats;
DROP TABLE IF EXISTS adm1_base_stats;
DROP TABLE IF EXISTS adm2_base_stats;
DROP TABLE IF EXISTS urban_areas_base_stats;
DROP TABLE IF EXISTS urban_areas_hd_base_stats;
DROP TABLE IF EXISTS urban_fishnets_base_stats;
DROP TABLE IF EXISTS hd_urban_fishnets_base_stats;

CREATE TABLE IF NOT EXISTS adm0_base_stats (
    ogc_fid int,
    geom_key text primary key,
    r10_sum float,
    p1_sum float,
    p2_sum float,
    lc_11 int,
    lc_14 int,
    lc_20 int,
    lc_30 int,
    lc_40 int,
    lc_50 int,
    lc_60 int,
    lc_70 int,
    lc_90 int,
    lc_100 int,
    lc_110 int,
    lc_120 int,
    lc_130 int,
    lc_140 int,
    lc_150 int,
    lc_160 int,
    lc_170 int,
    lc_180 int,
    lc_190 int,
    lc_200 int,
    lc_210 int,
    lc_220 int,
    lc_230 int
);

CREATE TABLE IF NOT EXISTS adm1_base_stats (LIKE adm0_base_stats);
CREATE TABLE IF NOT EXISTS adm2_base_stats (LIKE adm0_base_stats);
CREATE TABLE IF NOT EXISTS urban_areas_base_stats (LIKE adm0_base_stats);
CREATE TABLE IF NOT EXISTS urban_areas_hd_base_stats (LIKE adm0_base_stats);
CREATE TABLE IF NOT EXISTS urban_fishnets_base_stats (LIKE adm0_base_stats);
CREATE TABLE IF NOT EXISTS hd_urban_fishnets_base_stats (LIKE adm0_base_stats);

/*INDEXES
CREATE INDEX ON adm0 USING GIST (geom);
CREATE INDEX ON adm1 USING GIST (geom);
CREATE INDEX ON adm2 USING GIST (geom);
CREATE INDEX ON urban_areas USING GIST (geom);
CREATE INDEX ON urban_areas_hd USING GIST (geom);
CREATE INDEX ON urban_fishnets USING GIST (geom);
CREATE INDEX ON urban_fishnets (geohash);
CREATE INDEX ON hd_urban_fishnets USING GIST (geom);
CREATE INDEX ON hd_urban_fishnets (geohash);
--*/

COMMIT;