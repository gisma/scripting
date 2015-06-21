#!/bin/bash
for filename in  *ecw
do
  outfilename=$filename'_jpg.tif'
  outfilenamelzw=$filename'_cut_lzw.tif'
  outfilenamecomp=$filename'_com_jpg.tif'
  echo "Processing $filename file..."
  #gdal_translate -a_nodata 0 -projwin -21543.0 252606.0 -5846.0 235465.0 -of GTiff -co COMPRESS=JPEG -co JPEG_QUALITY=60 $filename $outfilenamecomp
  #gdal_translate -a_nodata 0 -projwin -21543.0 252606.0 -5846.0 235465.0 -of GTiff -co COMPRESS=JPEG  $filename $outfilename
  gdal_translate -a_nodata 0 -projwin -21543.0 252606.0 -5846.0 235465.0 -of GTiff -co  COMPRESS=LZW  -co BIGTIFF=YES $filename $outfilenamelzw
 
done


