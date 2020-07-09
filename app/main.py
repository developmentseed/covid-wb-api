import json
import logging
import re
import sys

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.openapi.utils import get_openapi
from fastapi.responses import JSONResponse
from timvt.db.catalog import table_index
from timvt.db.events import close_db_connection, connect_to_db
from timvt.endpoints import tiles, demo, index
from .routers.titiler_router import router as cogrouter
from .routers.attribute_router import router as attribute_router


logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

app = FastAPI(docs_url="/")
app.add_middleware(CORSMiddleware, allow_origins=["*"])
app.add_middleware(GZipMiddleware, minimum_size=0)


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
    attribute_router, prefix="/vector", tags=['Tiles']
)
app.include_router(
    demo.router, prefix="/vector",
)
app.include_router(
    tiles.router, prefix="/vector",
)
app.include_router(
    index.router, prefix="/vector",
)

app.include_router(
    cogrouter, prefix="/cog", tags=['Raster Tiles (COG)']
)

# remove "/tiles/{identifier}/{table}/{z}/{x}/{y}.pbf" endpoint
for r in app.routes:
    if r.path == "/vector/":
        app.routes.remove(r)


# TODO: remove when https://github.com/developmentseed/titiler/pull/46 is merged
@app.middleware("http")
async def remove_memcached_middleware(request: Request, call_next):
    """
    Remove memcached layer from titiler (quick and dirty approach)
    Note: This could effect any other routes that happen to use state.cache,
    which could be bad. timvt does not reference a cache state.
    """
    request.state.cache = None
    return await call_next(request)


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
        get = path.get("get")
        if get is not None:
            summary = get.get("summary", None)
            tags = get.get("tags", None)
            parameters = get.get("parameters", None)
            if summary == "Demo":
                get["summary"] = "Vector Tile Simple Viewer"
                get["tags"] = ["Vector Tile API"]
            if summary == "Display Index":
                get["summary"] = "Available Layer Metadata"
                get["tags"] = ["Vector Tile API"]
            if "Tiles" in tags:
                get["tags"] = ["Vector Tile API"]
            if parameters is not None:
                for param in parameters:
                    if param.get("description") == "Table Name":
                        param["schema"] = tables_schema
    app.openapi_schema = o
    return app.openapi_schema


app.openapi = custom_openapi
