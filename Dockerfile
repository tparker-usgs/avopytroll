FROM python:3.7


RUN apt-get update && apt-get -y install libhdf5-serial-dev libnetcdf-dev unzip libfreetype6 libfreetype6-dev

RUN ln -s /usr/include/freetype2 /usr/include/freetype  

RUN wget http://download.osgeo.org/gdal/2.2.0/gdal-2.2.0.tar.gz \
    && (gzip -dc gdal-2.2.0.tar.gz | tar xf -) \
    && cd gdal-2.2.0 \
    && ./configure; make; make install \
    && ldconfig \
    && cd .. && rm -rf gdal-2.2.0 gdal-2.2.0.tar.gz

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /app/gshhg
RUN wget http://www.soest.hawaii.edu/pwessel/gshhg/gshhg-shp-2.3.6.zip \
    && unzip gshhg-shp-2.3.6.zip && rm gshhg-shp-2.3.6.zip

WORKDIR /usr/src/
COPY installAggdraw.sh .
RUN ./installAggdraw.sh
