FROM gcc AS gdal
WORKDIR /build
RUN apt-get update && apt-get -y install curl
RUN  curl -fsSLO http://download.osgeo.org/gdal/2.2.0/gdal-2.2.0.tar.gz 
RUN gzip -dc gdal-2.2.0.tar.gz | tar xf -
WORKDIR /build/gdal-2.2.0 
RUN ./configure
RUN make
RUN make install 


FROM gcc as gshhg
WORKDIR /app
WORKDIR /app/gshhg
RUN apt-get update && apt-get -y install curl
RUN curl -fsSLO http://www.soest.hawaii.edu/pwessel/gshhg/gshhg-shp-2.3.6.zip
RUN unzip gshhg-shp-2.3.6.zip 


FROM python:3.7
COPY --from=gdal /usr/local /usr/local
# do RUN ldconfig?
COPY --from=gshhg /app/gshgg /app/gshgg

RUN apt-get update && apt-get -y install libhdf5-serial-dev libnetcdf-dev unzip libfreetype6 libfreetype6-dev
RUN ln -s /usr/include/freetype2 /usr/include/freetype  

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /usr/src/
COPY installAggdraw.sh .
RUN ./installAggdraw.sh
