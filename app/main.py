import json
import re
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.openapi.utils import get_openapi
from timvt.endpoints import tiles, demo
from timvt.db.events import close_db_connection, connect_to_db
from timvt.db.catalog import table_index
from titiler.api.endpoints import cog

import logging
import sys

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

app = FastAPI(docs_url="/")
app.add_middleware(CORSMiddleware, allow_origins=["*"])
app.add_middleware(GZipMiddleware, minimum_size=0)

# Register Start/Stop application event
# handler to setup/stop the database connection
@app.on_event("startup")
async def startup_event():
    """
    Application startup:
    register the database connection and create table list.
    """
    await connect_to_db(app)
    # Fetch database table list
    app.state.Catalog = await table_index(app.state.pool)


@app.on_event("shutdown")
async def shutdown_event():
    """Application shutdown: de-register the database connection."""
    await close_db_connection(app)


app.include_router(
    demo.router, prefix="/vector",
)
app.include_router(
    tiles.router, prefix="/vector",
)
app.include_router(
    cog.router, prefix="/raster"
)

# remove "/tiles/{identifier}/{table}/{z}/{x}/{y}.pbf" endpoint
for r in app.routes:
    if re.search('TileMatrixSetId', r.path):
        app.routes.remove(r)
    if r.path == "/vector/":
        app.routes.remove(r)


@app.get("/RiskSchema.json", tags=["Risk Schema"], summary="Risk Schema")
async def root(request: Request) -> JSONResponse:
    with open("app/templates/RiskSchema.json", "r") as f:
        content = json.loads(f.read())

    response = JSONResponse(content=content, status_code=200)

    return response


def custom_openapi(openapi_prefix: str):
    if app.openapi_schema:
        return app.openapi_schema
    o = get_openapi(
        title="World Bank Covid API",
        version="0.1",
        description="API for World Bank Covid 19 Project",
        routes=app.routes,
        openapi_prefix=openapi_prefix,
    )

    cat = app.state.Catalog
    tables_schema = {"title": "Table", "enum": [r["table"] for r in cat]}
    # raise Exception(o['paths'].keys())
    for path in o["paths"].values():
        if path["get"]["summary"] == "Demo":
            path["get"]["summary"] = "Vector Tile Simple Viewer"
            path["get"]["tags"] = ["Vector Tile Simple Viewer"]
        parameters = path["get"].get("parameters")
        if parameters is not None:
            for param in parameters:
                if param.get("description") == "Table Name":
                    param["schema"] = tables_schema
    app.openapi_schema = o
    return app.openapi_schema


app.openapi = custom_openapi
