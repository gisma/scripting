#!/bin/bash
# Script get the v4 srtm-tiles using the 5 deg indexes
# converts and tiles them to 1201**2 DEM Tiles that can be used by ARPS
# additionally it creates the corresponding control file for ARPS

# define dirnames etc.
dir='srtmtileseu'
demdir='demeu'
reg='EU'
indexfile='eu_index'

# make dirs
if [ ! -d $dir ]; then
 mkdir ${dir}
fi
if [ ! -d $demdir ]; then
 mkdir ${demdir}
fi

# delete existing indexfile and puts headerline
rm ${demdir}/${indexfile}
sh -c "echo in_alaska_or_not file_name lat_se\(deg N\) lon_se\(deg E\)  >> "${demdir}/${indexfile}

# if not existing go and get SRTM data using the CGIAR indexes numbers of the tiles
for x in {34..45}; do
 for y in {01..06}; do
  if [ ! -f srtm_${x}_${y}.zip ]; then
   # cgiar is to slow
   #wget ftp://xftp.jrc.it/pub/srtmV4/tiff/srtm_${x}_${y}.zip
   wget http://droppr.org/srtm/v4.1/6_5x5_TIFs/srtm_${x}_${y}.zip
  fi

  # generate mergestring for gdalmerge
  mergestring=${mergestring}' '${dir}'/srtm_'${x}'_'${y}'.tif'
done
done
 
# unzip all zip files to dir
unzip -o  '*.zip' -d ${dir}

# remove unused files
rm -f ${dir}/*.hdr
rm -f ${dir}/*.tfw
rm -f ${dir}/*.txt 

# merge all srtm tiles to the big one no data is set to zero and the file is prenitilized with zero
gdal_merge.py -of GTiff -ot Int16 -a_nodata 0 -init '0' -o  merge.tif  ${mergestring}

# reclass the negative an arbitrary Values to nodata
echo 'be patient gdal calculates...'
gdal_calc.py -A merge.tif --outfile=out.tif --calc='A*(A>=0)' 

# generate command line chunks for gdal -now degrees of the latter dem-tile are used
# for latitude naming
for lat in {60..40}; do
 lat1=`echo "scale=2 ; $lat*1.0" | bc`
 if [ $lat -le 0 ] ; then
  equat='s'
  lat2=`echo "scale=2 ; $lat+1.001" | bc`
  idxlat=`echo "scale=1 ; ($lat+1)" | bc`
  tmplat=`echo "scale=1 ; ($lat+1)*-1.0" | bc`
  lat3=${tmplat%.*}
 else
  equat='n'
  lat2=`echo "scale=2 ; $lat-1.001" | bc`
  idxlat=`echo "scale=1 ; ($lat-1)" | bc`
  tmplat=`echo "scale=1 ; ($lat-1)" | bc`
  lat3=${tmplat%.*}
 fi

# for longitude naming
  for lon in {35..-15}; do
   lon2=`echo "scale=2 ; $lon*1.0" | bc`
   if [ $lon -le 0 ]; then
    greenw='w'
    lon1=`echo "scale=2 ; $lon+0.001" | bc`
    idxlon=`echo "scale=1 ; ($lon)" | bc`
    tmplon=`echo "scale=0 ; $lon*-1.0" | bc`
    lon3=${tmplon%.*}
   else
    greenw='e'
    lon1=`echo "scale=2 ; $lon-1.001" | bc`
    lon3=${lon%.*}
    idxlon=$lon3
   fi

   # cut tiles and drop nodata values
   gdal_translate -projwin ${lon1} ${lat1}  ${lon2} ${lat2} -of GTiff out.tif ${lat3}${equat}${lon3}${greenw}.tif -a_nodata none

   # convert them to dem 
   gdal_translate -of USGSDEM ${lat3}${equat}${lon3}${greenw}.tif ${lat3}${equat}${lon3}${greenw}.dem

   # zip them
   gzip -f ${lat3}${equat}${lon3}${greenw}.dem

   # reorganise files
   mv -f ${lat3}${equat}${lon3}${greenw}.dem.gz ${demdir}
   rm ${lat3}${equat}${lon3}${greenw}.tif
   rm -f ${lat3}${equat}${lon3}${greenw}.dem.aux.xml

   #generate indexfile first value (latitude has to be at pos 40)   
   test=${lat3}${equat}${lon3}${greenw}.dem.gz
   len=${#test}
   len=$((39-$len))
   printf '%s %0s %'${len}'s %s\n' "${reg}" "${lat3}${equat}${lon3}${greenw}.dem.gz" "${idxlat}.0" "${idxlon}.0"  >>${demdir}/${indexfile}

  done
done

echo "ARPS DEM tiles generated ... you'll find them in " $demdir
