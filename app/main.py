import os
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.openapi.utils import get_openapi
from .routers import pygeoapi_router
import pygeoapi
import logging
import sys

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"])

app.include_router(
    pygeoapi_router.router, prefix="/pygeoapi",
)

app.mount(
    "/pygeoapi/static", StaticFiles(directory=os.path.join(pygeoapi.__path__[0], "static"))
)


def merge(source, destination):
    for key, value in source.items():
        if isinstance(value, dict):
            # get node or create one
            node = destination.setdefault(key, {})
            merge(value, node)
        else:
            destination[key] = value

    return destination


def custom_openapi(openapi_prefix: str):
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        title="World Bank Covid API",
        version="0.1",
        description="API for World Bank Covid 19 Project",
        routes=app.routes,
        openapi_prefix=openapi_prefix,
    )
    p = pygeoapi_router.openapiobj().copy()
    p['paths'] = {f'/pygeoapi{k}': v for k, v in p['paths'].items()}
    del p['servers']
    merged = merge(openapi_schema, p)

    app.openapi_schema = merged
    return app.openapi_schema


app.openapi = custom_openapi


@app.route("/")
async def root(request: Request)->Response:
    """
    HTTP root content of Covid WB. Intro page access point
    :returns: Starlette HTTP Response
    """
    content = """
    <html><body>
    <ul>
    <li><a href='pygeoapi/'>PyGeoAPI Entrypoint</a></li>
    <li><a href='docs'>OpenAPI Docs</a></li>
    </body></html>"""

    response = Response(content=content, status_code=200)

    return response
