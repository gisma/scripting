#!/bin/bash

# getting coordinates and directory
# example: cut_shp.sh -w -21543.0 -e 252606.0 -s -5846.0 -n 235465.0 -d ./
while getopts "n:s:w:e:d:" OPTION
do
     case $OPTION in
             \?)
              echo "example: cut_shp.sh -w -21543.0 -e 252606.0 -s -5846.0 -n 235465.0 -d ./"
              exit
            ;;	     
         n)
             n=$OPTARG
             ;;
             
         s)
             s=$OPTARG
             ;;
         w)
             w=$OPTARG
             ;;
         e)
             e=$OPTARG
             ;;
	     d)
	        dir=$OPTARG
	         ;;
     esac
done

for filename in  *shp
do
  outfilename=$filename'_cut.shp'
  echo "Processing $filename file..."
  ogr2ogr -f "ESRI Shapefile" -skipfailures -clipsrc $w $s $e $n $outfilename $dir/$filename 
done


