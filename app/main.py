import os
from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from .routers import pygeoapi_router
import pygeoapi

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"])

app.include_router(
    pygeoapi_router.router, prefix="/pygeoapi",
)

app.mount(
    "/pygeoapi/static", StaticFiles(directory=os.path.join(pygeoapi.__path__[0], "static"))
)


@app.route("/")
async def root(request: Request):
    """
    HTTP root content of Covid WB. Intro page access point
    :returns: Starlette HTTP Response
    """
    content = "<html><body><a href='pygeoapi/'>PyGeoAPI</a></body></html>"

    response = Response(content=content, status_code=200)

    return response
