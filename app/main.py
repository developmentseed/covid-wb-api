import logging
import os
import secrets
import sys

from fastapi import Depends, FastAPI, Request, Response, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.utils import get_openapi
from fastapi.responses import HTMLResponse
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from fastapi.staticfiles import StaticFiles

from .routers import pygeoapi_router
import pygeoapi


logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"])

http_basic_auth_scheme = HTTPBasic()


def basic_auth_flow(credentials: HTTPBasicCredentials = Depends(http_basic_auth_scheme)):
    """
    Dependency for basic http password. The username and password are defined in environment variables.
    :param credentials:
    :type credentials: HTTPBasicCredentials
    :return: username
    :rtype: str
    """
    correct_username = secrets.compare_digest(credentials.username, os.environ['BASIC_AUTH_USER'])
    correct_password = secrets.compare_digest(credentials.password, os.environ['BASIC_AUTH_PASS'])
    if not (correct_username and correct_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail='Incorrect username or password',
            headers={'WWW-Authenticate': 'Basic'},
        )
    return credentials.username


app.include_router(
    pygeoapi_router.router, prefix="/pygeoapi",
    dependencies=[Depends(basic_auth_flow)]
)

app.mount(
    "/pygeoapi/static", StaticFiles(directory=os.path.join(pygeoapi.__path__[0], "static")),
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


@app.get("/", response_class=HTMLResponse)
async def root(username=Depends(basic_auth_flow)) -> str:
    """
    HTTP root content of Covid WB. Intro page access point
    :returns: str
    """
    return f"""
    <html><body>
    <ul>
    <li><a href='pygeoapi/'>PyGeoAPI Entrypoint</a></li>
    <li><a href='docs'>OpenAPI Docs</a></li>

    <pre>current user: {username}</pre>
    </body></html>"""

