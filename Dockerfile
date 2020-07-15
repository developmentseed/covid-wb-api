# =================================================================
#
# Authors: Tom Kralidis <tomkralidis@gmail.com>
#          Just van den Broecke <justb4@gmail.com>
#          Francesco Bartoli <xbartolone@gmail.com>
#
# Copyright (c) 2020 Tom Kralidis
# Copyright (c) 2019 Just van den Broecke
# Copyright (c) 2020 Francesco Bartoli
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

FROM debian:bullseye-slim

LABEL maintainer="Just van den Broecke <justb4@gmail.com>"

# Docker file for full geoapi server with libs/packages for all providers.
# Server runs with gunicorn. You can override ENV settings.
# Defaults:
# SCRIPT_NAME=/
# CONTAINER_NAME=pygeoapi
# CONTAINER_HOST=0.0.0.0
# CONTAINER_PORT=80
# WSGI_WORKERS=4
# WSGI_WORKER_TIMEOUT=6000
# WSGI_WORKER_CLASS=gevent

# Calls entrypoint.sh to run. Inspect it for options.
# Contains some test data. Also allows you to verify by running all unit tests.
# Simply run: docker run -it geopython/pygeoapi test
# Override the default config file /pygeoapi/local.config.yml
# via Docker Volume mapping or within a docker-compose.yml file. See example at
# https://github.com/geopython/demo.pygeoapi.io/tree/master/services/pygeoapi

# ARGS
ARG TIMEZONE="Europe/London"
ARG LOCALE="en_US.UTF-8"
ARG ADD_DEB_PACKAGES=""
ARG ADD_PIP_PACKAGES=""

ADD https://github.com/geopython/pygeoapi/archive/0.8.0.tar.gz /pygeoapi/pygeoapi.tar.gz
ADD https://github.com/developmentseed/timvt/archive/master.tar.gz /timvt/timvt.tar.gz
ADD https://github.com/developmentseed/titiler/archive/2.1.2.tar.gz /titiler/titiler.tar.gz

# ENV settings
ENV TZ=${TIMEZONE} \
    DEBIAN_FRONTEND="noninteractive" \
    DEB_BUILD_DEPS="tzdata build-essential python3-dev python3-setuptools python3-pip apt-utils curl git unzip" \
    DEB_PACKAGES="locales libgdal27 python3-gdal libsqlite3-mod-spatialite ${ADD_DEB_PACKAGES}" \
    PIP_PACKAGES="gunicorn==20.0.4 gevent==1.5a4 wheel==0.33.4 fastapi[all]==0.58.0 uvicorn==0.11.5 pyyaml ${ADD_PIP_PACKAGES}"

# Run all installs
RUN \
    # Install dependencies
    apt-get update \
    && apt-get --no-install-recommends install -y ${DEB_BUILD_DEPS} ${DEB_PACKAGES} \
    # Timezone
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime\
    && dpkg-reconfigure tzdata \
    # Locale
    && sed -i -e "s/# ${LOCALE} UTF-8/${LOCALE} UTF-8/" /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=${LOCALE} \
    && echo "For ${TZ} date=$(date)" && echo "Locale=$(locale)" \
    # Upgrade pip3 and install packages
    && python3 -m pip install --upgrade pip \
    && pip3 install ${PIP_PACKAGES} \
    # Install pygeoapi
    && cd /pygeoapi \
    && tar xvfz /pygeoapi/pygeoapi.tar.gz --strip-components 1 \
    && pip3 install -r requirements.txt \
    && pip3 install -r requirements-dev.txt \
    && pip3 install -r requirements-provider.txt \
    && pip3 install -e . \
    # Install timvt
    && cd /timvt \
    && tar xvfz /timvt/timvt.tar.gz --strip-components 1 \
    # TODO: probably do not need the timvt 'dev' reqs in container:
    && pip3 install -e .[dev] \
    # Install titiler
    && cd /titiler \
    && tar xvfz titiler.tar.gz --strip-components 1 \
    && pip install -e . \
    # OGC schemas local setup
    && mkdir /schemas.opengis.net \
    && curl -O http://schemas.opengis.net/SCHEMAS_OPENGIS_NET.zip \
    && unzip ./SCHEMAS_OPENGIS_NET.zip "ogcapi/*" -d /schemas.opengis.net \
    # Cleanup TODO: remove unused Locales and TZs
    && pip3 uninstall --yes wheel \
    && apt-get remove --purge ${DEB_BUILD_DEPS} -y \
    && apt autoremove -y  \
    && rm -rf /var/lib/apt/lists/*

# COPY ./local.config.yml /pygeoapi/local.config.yml
COPY ./entrypoint.sh /entrypoint.sh
COPY ./app /covidwb/app

WORKDIR /covidwb

CMD ["/entrypoint.sh"]