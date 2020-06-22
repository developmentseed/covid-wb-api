# =================================================================
#
# Authors: Francesco Bartoli <xbartolone@gmail.com>
#
#
# Copyright (c) 2019 Francesco Bartoli
# Copyright (c) 2020 Tom Kralidis
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# =================================================================
""" FastAPI module providing the route paths to the api"""

import os
from fastapi import APIRouter, Request, Response
from pygeoapi.api import API
from pygeoapi.util import yaml_load

router = APIRouter()

with open(
    os.environ.get('PYGEOAPI_CONFIG'),
    encoding="utf8"
) as fh:
    CONFIG = yaml_load(fh)

api_ = API(CONFIG)


@router.route("/")
async def root(request: Request):
    """
    HTTP root content of pygeoapi. Intro page access point
    :returns: Starlette HTTP Response
    """
    headers, status_code, content = api_.root(request.headers, request.query_params)

    response = Response(content=content, status_code=status_code)
    if headers:
        response.headers.update(headers)

    return response


@router.route("/openapi")
@router.route("/openapi/")
async def openapi(request: Request):
    """
    OpenAPI access point
    :returns: Starlette HTTP Response
    """
    with open(os.environ.get("PYGEOAPI_OPENAPI"), encoding="utf8") as ff:
        openapi = yaml_load(ff)

    headers, status_code, content = api_.openapi(
        request.headers, request.query_params, openapi
    )

    response = Response(content=content, status_code=status_code)
    if headers:
        response.headers.update(headers)

    return response


@router.route("/conformance")
@router.route("/conformance/")
async def conformance(request: Request):
    """
    OGC open api conformance access point
    :returns: Starlette HTTP Response
    """

    headers, status_code, content = api_.conformance(
        request.headers, request.query_params
    )

    response = Response(content=content, status_code=status_code)
    if headers:
        response.headers.update(headers)

    return response


@router.route("/collections")
@router.route("/collections/")
@router.route("/collections/{name}")
@router.route("/collections/{name}/")
async def describe_collections(request: Request, name=None):
    """
    OGC open api collections  access point
    :param name: identifier of collection name
    :returns: Starlette HTTP Response
    """

    if "name" in request.path_params:
        name = request.path_params["name"]
    headers, status_code, content = api_.describe_collections(
        request.headers, request.query_params, name
    )

    response = Response(content=content, status_code=status_code)
    if headers:
        response.headers.update(headers)

    return response


@router.route("/collections/{name}/queryables")
@router.route("/collections/{name}/queryables/")
async def get_collection_queryables(request: Request, name=None):
    """
    OGC open api collections queryables access point
    :param name: identifier of collection name
    :returns: Starlette HTTP Response
    """

    if "name" in request.path_params:
        name = request.path_params["name"]
    headers, status_code, content = api_.get_collection_queryables(
        request.headers, request.query_params, name
    )

    response = Response(content=content, status_code=status_code)
    if headers:
        response.headers.update(headers)

    return response


@router.route("/collections/{collection_id}/items")
@router.route("/collections/{collection_id}/items/")
@router.route("/collections/{collection_id}/items/{item_id}")
@router.route("/collections/{collection_id}/items/{item_id}/")
async def dataset(request: Request, collection_id=None, item_id=None):
    """
    OGC open api collections/{dataset}/items/{item_id}  access point
    :returns: Starlette HTTP Response
    """

    if "collection_id" in request.path_params:
        collection_id = request.path_params["collection_id"]
    if "item_id" in request.path_params:
        item_id = request.path_params["item_id"]
    if item_id is None:
        headers, status_code, content = api_.get_collection_items(
            request.headers,
            request.query_params,
            collection_id,
            pathinfo=request.scope["path"],
        )
    else:
        headers, status_code, content = api_.get_collection_item(
            request.headers, request.query_params, collection_id, item_id
        )

    response = Response(content=content, status_code=status_code)

    if headers:
        response.headers.update(headers)

    return response


@router.route("/stac")
async def stac_catalog_root(request: Request):
    """
    STAC access point
    :returns: Starlette HTTP response
    """

    headers, status_code, content = api_.get_stac_root(
        request.headers, request.query_params
    )

    response = Response(content=content, status_code=status_code)

    if headers:
        response.headers.update(headers)

    return response


@router.route("/stac/{path:path}")
async def stac_catalog_path(request: Request):
    """
    STAC access point
    :returns: Starlette HTTP response
    """

    path = request.path_params["path"]

    headers, status_code, content = api_.get_stac_path(
        request.headers, request.query_params, path
    )

    response = Response(content=content, status_code=status_code)

    if headers:
        response.headers.update(headers)

    return response


@router.route("/processes")
@router.route("/processes/")
@router.route("/processes/{name}")
@router.route("/processes/{name}/")
async def describe_processes(request: Request, name=None):
    """
    OGC open api processes access point (experimental)
    :param name: identifier of process to describe
    :returns: Starlette HTTP Response
    """
    headers, status_code, content = api_.describe_processes(
        request.headers, request.query_params, name
    )

    response = Response(content=content, status_code=status_code)

    if headers:
        response.headers.update(headers)

    return response


@router.route("/processes/{name}/jobs", methods=["GET", "POST"])
@router.route("/processes/{name}/jobs/", methods=["GET", "POST"])
async def execute_process(request: Request, name=None):
    """
    OGC open api jobs from processes access point (experimental)
    :param name: identifier of process to execute
    :returns: Starlette HTTP Response
    """

    if request.method == "GET":
        headers, status_code, content = ({}, 200, "[]")
    elif request.method == "POST":
        headers, status_code, content = api_.execute_process(
            request.headers, request.query_params, request.data, name
        )

    response = Response(content=content, status_code=status_code)

    if headers:
        response.headers.update(headers)

    return response
