#!/bin/bash
# =================================================================
#
# Authors: Just van den Broecke <justb4@gmail.com>
#
# Copyright (c) 2019 Just van den Broecke
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

# pygeoapi entry script

echo "START /entrypoint.sh"

set +e

export PYGEOAPI_HOME=/pygeoapi
export PYGEOAPI_CONFIG="${PYGEOAPI_HOME}/local.config.yml"
export PYGEOAPI_OPENAPI="${PYGEOAPI_HOME}/local.openapi.yml"

# gunicorn env settings with defaults
SCRIPT_NAME=${SCRIPT_NAME:=pygeoapi}
CONTAINER_NAME=${CONTAINER_NAME:=pygeoapi}
CONTAINER_HOST=${CONTAINER_HOST:=0.0.0.0}
CONTAINER_PORT=${CONTAINER_PORT:=80}
WSGI_WORKERS=${WSGI_WORKERS:=4}

# What to invoke: default is to run gunicorn server
entry_cmd=${1:-run}

# Shorthand
function error() {
	echo "ERROR: $@"
	exit -1
}

# PyGeoAPI Workdir
cd ${PYGEOAPI_HOME}

echo "Trying to generate openapi.yml"
pygeoapi generate-openapi-document -c ${PYGEOAPI_CONFIG} > ${PYGEOAPI_OPENAPI}

[[ $? -ne 0 ]] && error "openapi.yml could not be generated ERROR"

echo "openapi.yml generated continue to pygeoapi"

cd /covidwb
# SCRIPT_NAME should not have value '/'
[[ "${SCRIPT_NAME}" = '/' ]] && export SCRIPT_NAME="" && echo "make SCRIPT_NAME empty from /"

echo "Start gunicorn name=${CONTAINER_NAME} on ${CONTAINER_HOST}:${CONTAINER_PORT} with ${WSGI_WORKERS} workers and SCRIPT_NAME=${SCRIPT_NAME}"
gunicorn --workers ${WSGI_WORKERS} \
        --name=${CONTAINER_NAME} \
        --bind ${CONTAINER_HOST}:${CONTAINER_PORT} \
        app.main:app \
        -k uvicorn.workers.UvicornWorker \
        --reload


echo "END /entrypoint.sh"