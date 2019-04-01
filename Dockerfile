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

RUN ldconfig
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

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /usr/src/
COPY installAggdraw.sh .
RUN ./installAggdraw.sh
