##################
# retrieve gshhg #
##################
FROM busybox as gshhg
WORKDIR /gshhg
RUN wget http://www.soest.hawaii.edu/pwessel/gshhg/gshhg-shp-2.3.6.zip
RUN unzip gshhg-shp-2.3.6.zip 


###################
# build the image #
###################
FROM python:3.7

COPY --from=tparkerusgs/gdal /usr/local /usr/local
COPY --from=gshhg /gshhg /usr/local/gshhg

RUN apt-get update && apt-get install -y \
  gdal-bin \
  libfreetype6 \
  libfreetype6-dev \
  libhdf5-serial-dev \
  libnetcdf-dev \
  python-gdal \
  python-numpy \
  unzip 

RUN ln -s /usr/include/freetype2 /usr/include/freetype  

RUN useradd -u 2001 auto
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /usr/src/
COPY installAggdraw.sh .
RUN ./installAggdraw.sh && rm installAggdraw.sh

# install supercronic
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.8/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=be43e64c45acd6ec4fce5831e03759c89676a0ea

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic
