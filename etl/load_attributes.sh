#!/bin/bash
set -a
BASEDIR=/home/bitner/devseed/wb-covid/workspace/CoVID/
OUTPUTDIR=/home/bitner/devseed/wb-covid/workspace/output/
RELOAD=true
PG_USE_COPY=YES
NJOBS=1

TABLES="adm0 adm1 adm2 urban_areas urban_areas_hd urban_fishnets hd_urban_fishnets"

function table_pattern {
    if [ $1 = "urban_fishnets" ]
        then echo "[^_]urban_[0-9]+"
    elif [ $1 = "hd_urban_fishnets" ]
        then echo "hd_urban_[0-9]+"
    else echo $1
    fi
}

function table_geom_key {
    if [ $1 = "adm0" ]
        then echo "wb_adm0_co"
    elif [ $1 = "adm1" ]
        then echo "wb_adm1_co"
    elif [ $1 = "adm2" ]
        then echo "wb_adm2_co"
    else echo "geohash"
    fi
}

# Get List of Columns in a CSV from Header Line
function csv_columns {
    csvcut -n $1 | sed -E 's/^[ 0-9]+:[ ]+//'
}

# Gets list of expected columns for a table that are not present in csv
function check_columns {
    addcols=""
    declare -A map
    for key in $(csv_columns $1)
    do
        map[$key]=1
    done
    for col in $(echo $2 | tr -s "," " ")
    do
        [[ -z  "${map[$col]}" ]] && addcols="$addcols,$col"
    done
    echo $addcols
}

declare -A COLS
COLS["base"]="geom_key,R10_SUM,P1_SUM,P2_SUM,LC_11,LC_14,LC_20,LC_30,LC_40,LC_50,LC_60,LC_70,LC_90,LC_100,LC_110,LC_120,LC_130,LC_140,LC_150,LC_160,LC_170,LC_180,LC_190,LC_200,LC_210,LC_220,LC_230"

COLS["dhs"]="geom_key,DHS_1_SUM,DHS_1_MEAN,DHS_2_SUM,DHS_2_MEAN,DHS_3_SUM,DHS_3_MEAN,DHS_4_SUM,DHS_4_MEAN,DHS_5_SUM,DHS_5_MEAN,DHS_6_SUM,DHS_6_MEAN,DHS_7_SUM,DHS_7_MEAN,DHS_8_SUM,DHS_8_MEAN,DHS_9_SUM,DHS_9_MEAN,DHS_10_SUM,DHS_10_MEAN,DHS_11_SUM,DHS_11_MEAN,DHS_12_SUM,DHS_12_MEAN,DHS_13_SUM,DHS_13_MEAN,DHS_14_SUM,DHS_14_MEAN,DHS_15_SUM,DHS_15_MEAN,DHS_16_SUM,DHS_16_MEAN,DHS_17_SUM,DHS_17_MEAN,DHS_18_SUM,DHS_18_MEAN,DHS_19_SUM,DHS_19_MEAN,DHS_20_SUM,DHS_20_MEAN,DHS_21_SUM,DHS_21_MEAN,DHS_22_SUM,DHS_22_MEAN,DHS_23_SUM,DHS_23_MEAN,DHS_24_SUM,DHS_24_MEAN,DHS_25_SUM,DHS_25_MEAN,DHS_26_SUM,DHS_26_MEAN,DHS_27_SUM,DHS_27_MEAN,DHS_28_SUM,DHS_28_MEAN,DHS_29_SUM,DHS_29_MEAN,DHS_30_SUM,DHS_30_MEAN,DHS_31_SUM,DHS_31_MEAN,DHS_32_SUM,DHS_32_MEAN,DHS_33_SUM,DHS_33_MEAN,DHS_34_SUM,DHS_34_MEAN,DHS_35_SUM,DHS_35_MEAN,DHS_36_SUM,DHS_36_MEAN,DHS_37_SUM,DHS_37_MEAN,DHS_38_SUM,DHS_38_MEAN,DHS_39_SUM,DHS_39_MEAN,DHS_40_SUM,DHS_40_MEAN,DHS_41_SUM,DHS_41_MEAN,DHS_42_SUM,DHS_42_MEAN,DHS_43_SUM,DHS_43_MEAN,DHS_44_SUM,DHS_44_MEAN,DHS_48_SUM,DHS_48_MEAN,DHS_49_SUM,DHS_49_MEAN,DHS_50_SUM,DHS_50_MEAN,DHS_51_SUM,DHS_51_MEAN,DHS_52_SUM,DHS_52_MEAN,DHS_53_SUM,DHS_53_MEAN,DHS_54_SUM,DHS_54_MEAN,DHS_55_SUM,DHS_55_MEAN,DHS_56_SUM,DHS_56_MEAN,DHS_57_SUM,DHS_57_MEAN,DHS_58_SUM,DHS_58_MEAN,DHS_59_SUM,DHS_59_MEAN,DHS_60_SUM,DHS_60_MEAN,DHS_61_SUM,DHS_61_MEAN,DHS_62_SUM,DHS_62_MEAN,DHS_63_SUM,DHS_63_MEAN,DHS_64_SUM,DHS_64_MEAN,DHS_65_SUM,DHS_65_MEAN,DHS_66_SUM,DHS_66_MEAN,DHS_67_SUM,DHS_67_MEAN,DHS_68_SUM,DHS_68_MEAN,DHS_69_SUM,DHS_69_MEAN,DHS_70_SUM,DHS_70_MEAN,DHS_71_SUM,DHS_71_MEAN,DHS_72_SUM,DHS_72_MEAN,DHS_73_SUM,DHS_73_MEAN,DHS_74_SUM,DHS_74_MEAN,DHS_75_SUM,DHS_75_MEAN,DHS_76_SUM,DHS_76_MEAN,DHS_77_SUM,DHS_77_MEAN,DHS_78_SUM,DHS_78_MEAN,DHS_79_SUM,DHS_79_MEAN,DHS_80_SUM,DHS_80_MEAN,DHS_81_SUM,DHS_81_MEAN,DHS_82_SUM,DHS_82_MEAN,DHS_83_SUM,DHS_83_MEAN,DHS_84_SUM,DHS_84_MEAN,DHS_85_SUM,DHS_85_MEAN,DHS_86_SUM,DHS_86_MEAN,DHS_87_SUM,DHS_87_MEAN,DHS_88_SUM,DHS_88_MEAN,DHS_89_SUM,DHS_89_MEAN,DHS_90_SUM,DHS_90_MEAN,DHS_91_SUM,DHS_91_MEAN,DHS_92_SUM,DHS_92_MEAN,DHS_93_SUM,DHS_93_MEAN,DHS_94_SUM,DHS_94_MEAN,DHS_95_SUM,DHS_95_MEAN,DHS_96_SUM,DHS_96_MEAN,DHS_97_SUM,DHS_97_MEAN,DHS_98_SUM,DHS_98_MEAN,DHS_99_SUM,DHS_99_MEAN,DHS_100_SUM,DHS_100_MEAN,DHS_101_SUM,DHS_101_MEAN,DHS_102_SUM,DHS_102_MEAN,DHS_103_SUM,DHS_103_MEAN,DHS_104_SUM,DHS_104_MEAN"


# standardizes csv file so it has all columns and appends to
# global csv. for columns that are expected in the final table
# but are not present in the csv, it pads them at the end
function process_csv {
    file="$1"
    table="$2"
    grp="$3"
    cols="$4"
    echo "**************  $file $table $adm0 ***************************"
    add_columns=$(check_columns $file $cols)
    add_commas=$(echo $add_columns | sed 's/[a-z_0-9]//gi')
    echo $add_columns
    echo $add_commas
    sed -e "1 s/$/${add_columns}/" -e "2,$ s/$/${add_commas}/" $file | \
        csvcut -c "$cols" -x | \
        csvcut -K 1 >> ${OUTPUTDIR}/${table}_${grp}_stats.csv
}

# uses the passed in pattern and the BASEDIR path to search for files
# matching the pattern to send to the data loader
function aggregate_csv {
    echo "****************** LOADING $1 $2 ***************************"
    table=$1
    grp=$2
    pattern=$(table_pattern $1)
    cols=${COLS[$grp]}
    pgcols=$(echo "${cols}" | tr '[:upper:]' '[:lower:]')
    csv=${OUTPUTDIR}${table}_${grp}_stats.csv
    rm -f ${csv}
    find $BASEDIR | \
        egrep -i "$pattern" | grep -i "$grp" | \
        parallel -j $NJOBS "process_csv {} $table $grp $cols"
}

#loads global csv into postgresql
function load_csv {
    echo "load_csv $1 $2"
    base=$1
    grp=$2
    cols=${COLS[$grp]}
    pgcols=$(echo "${cols}" | tr '[:upper:]' '[:lower:]')
    csv=${OUTPUTDIR}${base}_${grp}_stats.csv

    cat ${csv} | \
        psql -c "copy ${base}_${grp}_stats (${pgcols}) FROM stdin WITH CSV;"
}

# converts list of columns adding types suitable for a postgresql
# create table call
function tablecols {
    echo "$1" | \
    tr '[:upper:]' '[:lower:]' | \
    sed -E \
        -e 's/geom_key/geom_key text/g' \
        -e 's/([a-z]+_?[0-9]+_sum)/\1 float/g' \
        -e 's/([a-z]+_?[0-9]+_mean)/\1 float/g' \
        -e 's/([a-z]+_[0-9]+),/\1 int,/g' \
        -e 's/([a-z]+_[0-9]+)$/\1 int/g'
}

function recreate_table {
table=$1
grp=$2
pgcols=$(tablecols ${COLS[$grp]})
psql <<EOSQL
    BEGIN;
    DROP TABLE IF EXISTS ${table}_${grp}_stats;
    CREATE TABLE IF NOT EXISTS ${table}_${grp}_stats (
        ogc_fid int,
        ${pgcols}
    );
EOSQL
}

function recreate_tables_grp {
    grp=$1
    for table in $TABLES
    do
        recreate_table $table $grp
    done
}

# postprocess loaded data
function postprocess_table {
    table=$1
    grp=$2
    keycol=$(table_geom_key $table)
psql <<EOSQL
UPDATE ${table}_${grp}_stats set ogc_fid=t.ogc_fid
    FROM ${table} t
    WHERE geom_key=$keycol::text;
CREATE UNIQUE INDEX IF NOT EXISTS ${table}_${grp}_ogc_fid_idx
        ON ${table}_${grp}_stats (ogc_fid);
EOSQL
}

function create_view_table {
    table=$1
    basecols=$(echo ${COLS['base']} | sed 's/geom_key,//')
    dhscols=$(echo ${COLS['dhs']} | sed 's/geom_key,//')
psql <<EOSQL
    DROP VIEW IF EXISTS ${table}_full;
    CREATE VIEW ${table}_full AS
        SELECT
            t.*,
            ${basecols},
            ${dhscols}
        FROM
            ${table} t
            LEFT JOIN ${table}_base_stats base USING (ogc_fid)
            LEFT JOIN ${table}_dhs_stats dhs USING (ogc_fid)
    ;
EOSQL
}

function create_views {
    for table in $TABLES
    do
        create_view_table $table
    done
}

function postprocess_tables_grp {
    grp=$1
    for table in $TABLES
    do
        postprocess_table $table $grp
    done
}

function aggregate_grp {
    grp=$1
    for table in $TABLES
    do
    aggregate_csv $TABLE $grp
    done
}

function load_grp {
    grp=$1
    for table in $TABLES
    do
    load_csv $table $grp
    done
}
set +a