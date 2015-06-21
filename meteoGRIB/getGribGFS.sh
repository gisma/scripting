#!/bin/bash
# Chris Reudenbach
# Version: 0.1 Date: 2015-06-17
#          0.2 Date: 2015-06-20
#                    add commandline and nettiquette
#                    add default settings 
# simple script to download (selected) GFS 0.25 data for a forecast period
# from the NCEP NOAA archive
# Additionally it converts the single files to one datafile for use with IDV etc.
# and comfortable timeseries analysis
# generates netcdf, grib1 and grib2 all in one files


if [[ "$1" == '-h' ]]; then
    echo " "
    echo " <getGribGFS.sh> downloads the 0.25° GFS GRIB2 date"
    echo " By default you will get the whole world data set by 10 days "
    echo " It is strongly recommended to extract a ROI"
    echo " "
    echo "Usage: ./getGribGFS.sh -h gives this brief help "
    echo "       ./getGribGFS.sh -d=YYYYMMDD -wl=DDD.DD -el=DDD.DD -nl=DDD.DD -sl=DDD.DD -st=0 -et=96 "
    echo""
    echo "-d=YYYYMMDD:   Date ie 20150621"
    echo " -wl -el   :   western and eastern Longitude of the area"
    echo "               to extract in decimal degrees"
    echo " -sl -nl   :   southern and northern Latitude of the area"
    echo "               to extract in decimal degrees"
    echo " -st -et   :   Starting time (st)arting  and (e)nding (t)ime"
    echo "               of the forecast default is (0,96) = 10 days "
    echo " example   :  ./getGribGFS.sh -d=20150620 -wl=-10.5 -el=20.25 -nl=60.75 -sl=40.0 -st=0 -et=96"
    exit 0
fi

for i in "$@"
do
case $i in
    -d=*|--date=*)
    date="${i#*=}"
    ;;
    -wl=*|--westLongitude=*)
    leftlon="${i#*=}"
    ;;
    -el=*|--eastLongitude=*)
    rightlon="${i#*=}"
    ;;
    -nl=*|--northLatitude=*)
    toplat="${i#*=}"
    ;;
    -sl=*|--southLatitude=*)
    bottomlat="${i#*=}"
    ;;
    -st=*|--startTime=*)
    StartTime="${i#*=}"
    ;;
    -et=*|--EndTime=*)
    EndTime="${i#*=}"
    ;;        
    --default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
done

# define default variables 
if [[ "${date}" == "" ]]      ; then  param=FALSE; date=`date -u +%Y%m%d`; fi
if [[ "${StartTime}" == "" ]] ; then  param=FALSE; StartTime=0 ; fi
if [[ "${EndTime}" == ""   ]] ; then  param=FALSE; EndTime=96 ; fi
if [[ "${leftlon}" == ""   ]] ; then  param=FALSE; leftlon="0" ; fi
if [[ "${rightlon}" == ""  ]] ; then  param=FALSE; rightlon="360" ; fi
if [[ "${toplat}" == ""    ]] ; then  param=FALSE; toplat="90" ; fi 
if [[ "${bottomlat}" == "" ]] ; then  param=FALSE; bottomlat="-90" ; fi 

echo "extracting the data with the following parameters:"
echo date=${date}
echo StartTime=${StartTime}
echo EndTime=${EndTime}
echo leftlon=${leftlon}
echo rightlon=${rightlon}
echo toplat=${toplat}
echo bottomlat=${bottomlat}
if [[ "${param}" == "FALSE" ]]; then echo "Get help with ./extractGribGFS.sh -h"; echo "However proceeding with above DEFAULT values..." ;fi

######
# identify users home
USER=`whoami`
# PREDIFINED FOLDERS
DATADIR="data"
MODELDIR="GFS25"


# set datapath (currently GFS25)
filename=$(basename "$INFILE")
filename="${filename%.*}"
fndate=${filename:20:8}
INDATAPATH=$(dirname "$INFILE")
EXDATAPATH=/home/$USER/$DATADIR/$MODELDIR/$date
SCRIPTPATH=/home/$USER/dev/scripts/meteoGRIB
echo "~~~~~~~~~~~~~~~~~"
echo "output folder:"
echo "$EXDATAPATH"
echo "$SCRIPTPATH"
echo "~~~~~~~~~~~~~~~~~"
echo "Start Download...."

# create directories 
if [ ! -d $EXDATAPATH ]; then mkdir -p ${EXDATAPATH} ; fi
                 
# change directory to runtimedirectory   
cd $EXDATAPATH

# fix the substituion variables to fixed format 3 numbers
charStartTime=$(printf "%02d\n" $StartTime)
charNewHour=$(printf "%03d\n" $StartTime)
hour=$StartTime



# start loop over all time slots NOTE GFS 0.25 has a 3 hours cycle
while [ $hour -le $EndTime ] ; do
 # here we put the filter URL of the noaa g2sub service (i.e. http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?dir=%2Fgfs.2015061700) 
 # we can also use the regular download from gribmaster  or similar scripts
 # next line you will find a filter call currently we are loading all levels and all vars in a small subregion.
 # be careful each full earth all variables&levels file is about 550 MB and GRIB is a really good compression!
  #URL="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${charStartTime}z.pgrb2.0p25.f${charNewHour}&lev_1000_mb=on&lev_100_mb=on&lev_10_m_above_ground=on&lev_200_mb=on&lev_2_m_above_ground=on&lev_300_mb=on&lev_400_mb=on&lev_500_mb=on&lev_600_mb=on&lev_700_mb=on&lev_750_mb=on&lev_800_mb=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&var_4LFTX=on&var_ALBDO=on&var_CAPE=on&var_CIN=on&var_CLWMR=on&var_CPRAT=on&var_CRAIN=on&var_CSNOW=on&var_CWAT=on&var_CWORK=on&var_DPT=on&var_GUST=on&var_HGT=on&var_POT=on&var_PRATE=on&var_PRES=on&var_RH=on&var_SUNSD=on&var_TMAX=on&var_TMIN=on&var_TMP=on&var_UGRD=on&var_VGRD=on&var_VVEL=on&subregion=&leftlon=${leftlon}&rightlon=${rightlon}&toplat=${toplat}&bottomlat=${bottomlat}&dir=%2Fgfs.${date}${charStartTime}"
  # allvars and all levels in a subregion

  # setup the url
  URL="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${charStartTime}z.pgrb2.0p25.f${charNewHour}&all_lev=on&all_var=on&subregion=&leftlon=${leftlon}&rightlon=${rightlon}&toplat=${toplat}&bottomlat=${bottomlat}&dir=%2Fgfs.${date}${charStartTime}"
  #echo `wget -S --spider $URL  2>&1`
  # first we check if the file exist
  if [[ `wget -S --spider $URL  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then 

  # then we get the data via cURL
  curl "$URL" -o gfs.t${charStartTime}z.pgrb2.0p25.f${charNewHour}

  # INCREMENT timeslot
  hour=$(($hour + 3))
  # to avoid server overload
  wait 1
  # correct time format for substitution 
  charNewHour=$(printf "%03d\n" $hour)
 else
  echo "-----------------------------------------------"
  echo "Currently the requested Data is NOT available."
  echo "Please check the date of the request. "
  echo "Note: GFS 0.25 files have about a 7 hours delay."
  exit
 fi 
done


# rename initial analysis data due to a different number of variables
mv gfs.t${charStartTime}z.pgrb2.0p25.f000 gfs.t${charStartTime}z.pgrb2.0p25.f000.grb

#cdo mergetime $date/*.nc gfs.t${charStartTime}z.pgrb2.0p25.$Date_${charStartTime}_${EndTime}.nc

# merge all grib2 files to one 
cdo mergetime gfs.t${charStartTime}z.pgrb2.0p25.f??? gfs.t${charStartTime}z.pgrb2.0p25.${date}_${charStartTime}_${EndTime}.grb

# convert it to netcdf (it seems to work even if there some warnings)
# cdo -f nc copy gfs.t${charStartTime}z.pgrb2.0p25.${date}_${charStartTime}_${EndTime}.grb gfs.t${charStartTime}z.pgrb2.0p25.${date}_${charStartTime}_${EndTime}.nc

# and squeeze it via shuffeling and compressing (http://www.unidata.ucar.edu/blogs/developer/en/entry/netcdf_compression)
#nccopy -u -d5 gfs.t${charStartTime}z.pgrb2.0p25.${date}_${charStartTime}_${EndTime}.nc gfs.t${charStartTime}z.0p25.${date}_${charStartTime}_${EndTime}.nc

# convert the grib 2 to grib one for usage with zygrib
#cnvgrib -g21 ${date}/gfs.t${charStartTime}z.pgrb2.0p25.${date}_${charStartTime}_${EndTime}.grb ${date}/gfs.t${charStartTime}z.pgrb1.0p25.$Date_${charStartTime}_${EndTime}.grb

# remove uncompressed files
if [ ! -f gfs.t${charStartTime}z.pgrb2.0p25.${date}_${charStartTime}_${EndTime}.nc ]; then rm -r gfs.t${charStartTime}z.pgrb2.0p25.${date}_${charStartTime}_${EndTime}.nc ; fi
if [ ! -f rm gfs.t${charStartTime}z.pgrb2.0p25.f??? ]; then rm -r rm gfs.t${charStartTime}z.pgrb2.0p25.f??? ; fi


