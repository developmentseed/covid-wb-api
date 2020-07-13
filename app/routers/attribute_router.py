"""API for returning detailed attributes for gathered statistics."""
import re
from typing import Dict, Optional, Union, List
from enum import Enum
from fastapi import APIRouter, Depends, Path, Query, HTTPException
from fastapi.responses import JSONResponse
from starlette.requests import Request
from asyncpg.pool import Pool
from timvt.utils.dependencies import _get_db_pool

from pydantic import BaseModel, Field

import json
import logging

logger = logging.getLogger(__name__)

router = APIRouter()


class TableMetadata(BaseModel):
    """Table Metadata."""

    id: str
    dbschema: str = Field(..., alias="schema")
    table: str
    geometry_column: str
    srid: int
    geometry_type: str
    properties: Dict[str, str]
    link: Optional[str]
    column_list: Optional[List[str]]


async def TableParams(
    request: Request,
    table: str = Path(..., description="Table Name"),
    columns: Optional[str] = Query(None, description="List of Columns to Include"),
) -> TableMetadata:
    """Table."""
    logger.info(table)
    table_pattern = re.match(  # type: ignore
        r"^((?P<schema>.+)\.)?(?P<table>.+)$", table
    ).groupdict()

    schema = table_pattern["schema"]
    table_name = table_pattern["table"]

    if not re.search(r"_full$", table_name):
        table_name = f"{table_name}_full"
    logger.debug("Converted table name: ", table_name)

    table = None
    for r in request.app.state.Catalog:
        if r["table"] == table_name:
            if schema is None or r["schema"] == schema:
                table = TableMetadata(**r)
                break

    if table is None:
        raise HTTPException(status_code=404, detail=f"Table '{table}' not found.")

    geometry_column = table.geometry_column
    cols = table.properties
    if geometry_column in cols:
        del cols[geometry_column]

    if columns is not None:
        include_cols = [c.strip() for c in columns.split(",")]
        for c in cols.copy():
            if c not in include_cols:
                del cols[c]

    table.column_list = list(cols)

    return table


class KeyColumn(str, Enum):
    ogc_fid = "ogc_fid"
    geohash = "geohash"
    wb_adm0_co = "wb_adm0_co"
    wb_adm1_co = "wb_adm1_co"
    wb_adm2_co = "wb_adm2_co"
    objectid = "objectid"
    adm0 = "wb_adm0_co"
    adm1 = "wb_adm1_co"
    adm2 = "wb_adm2_co"


class KeyMetadata(BaseModel):
    """Key Metadata."""

    id: Union[str, int]
    column: KeyColumn
    reportkey: KeyColumn


async def KeyParams(
    request: Request,
    id: str = Path(..., description="Identifier Key"),
    keycol: Optional[KeyColumn] = Query(KeyColumn.ogc_fid, description="Alternate Key to Search"),
    reportkey: Optional[KeyColumn] = Query(KeyColumn.ogc_fid, description="Key used to index results"),
) -> KeyMetadata:
    if re.match(r"^[0-9]+$", id):
        key = KeyColumn[keycol]
        id = int(id)
    else:
        key = KeyColumn.geohash

    return KeyMetadata(id=id, column=key, reportkey=reportkey)


@router.get("/info/{table}/{id}",)
async def feature_info(
    request: Request,
    table: TableMetadata = Depends(TableParams),
    key: KeyMetadata = Depends(KeyParams),
    db_pool: Pool = Depends(_get_db_pool),
):
    """Return the all measurements for feature id."""
    id = key.id
    if key.column != 'geohash':
        id = int(key.id)
    column_list = table.column_list
    if key.column not in column_list:
        column_list.append(key.column)
    column_str = ", ".join(column_list)
    query = f"""
        WITH t AS (
            SELECT {column_str} FROM {table.id} WHERE {key.column}=$1 LIMIT 1000
        ) SELECT row_to_json(t) FROM t;
    """
    rows = {}
    count = 0
    async with db_pool.acquire() as conn:
        q = await conn.prepare(query)
        async with conn.transaction():
            async for record in q.cursor(id):
                logger.debug(record)
                rec = json.loads(record[0])
                k = rec[key.reportkey]
                rows[k] = rec
                count += 1
    if len(rows) == 1:
        content = rec
    else:
        content={
            "table": table.id,
            "searchKey": key.column,
            "searchValue": id,
            "reportKey": key.reportkey,
            "count": count,
            "records": rows
        }

    return JSONResponse(content=content)
