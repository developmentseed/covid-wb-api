import os
import json
from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.openapi.utils import get_openapi
from timvt.endpoints import tiles, tms, index, demo
from timvt.events import create_start_app_handler, create_stop_app_handler
import logging
import sys

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

app = FastAPI(docs_url="/")
app.add_middleware(CORSMiddleware, allow_origins=["*"])
app.add_middleware(GZipMiddleware, minimum_size=0)

app.add_event_handler("startup", create_start_app_handler(app))
app.add_event_handler("shutdown", create_stop_app_handler(app))

app.include_router(
    demo.router, prefix="/vector",
)
app.include_router(
    tiles.router, prefix="/vector",
)
# remove "/tiles/{identifier}/{table}/{z}/{x}/{y}.pbf" endpoint
for r in app.routes:
    if r.path == '/vector/tiles/{identifier}/{table}/{z}/{x}/{y}.pbf':
        app.routes.remove(r)
    if r.path == '/vector/':
        app.routes.remove(r)



@app.get("/RiskSchema.json", tags=["Risk Schema"], summary="Risk Schema")
async def root(request: Request) -> JSONResponse:
    with open('app/templates/RiskSchema.json','r') as f:
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
    tables_schema = {
        'title' : 'Table',
        'enum' : [r["table"] for r in cat.index]
    }
    #raise Exception(o['paths'].keys())
    for path in o['paths'].values():
        if path['get']['summary'] == 'Demo':
            path['get']['summary'] = "Vector Tile Simple Viewer"
            path['get']['tags'] = ["Vector Tile Simple Viewer"]
        parameters = path['get'].get('parameters')
        if parameters is not None:
            for param in parameters:
                if param.get('description') == "Table Name":
                    param['schema'] = tables_schema
    app.openapi_schema = o
    return app.openapi_schema


app.openapi = custom_openapi
