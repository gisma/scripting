#!/bin/bash

#INFILE='/home/creu/Daten/grib/20150618/gfs.t00z.pgrb2.0p25.20150618_00_96.grb'

if [[ "$1" == '-h' ]]; then
    echo "---------------------------------------------------------------------- "
    echo "<extractGribGFS.sh> extracts specified dataset from GFS 0.25 GRIB Data"
    echo "                    at the nearest model grid to a request."
    echo "                    Currently only meteogram datasets are supported"
    echo " "
    echo " Usage:  ./extractGribGFS.sh -i=<GribGFSFile> -lo=DD.DD -la=DD.DD -t=<extractype>"
    echo "         ./extractGribGFS.sh -h shows this brief help "    
    echo " "
    echo " <extractGrib.sh> extracts from the 0.25° GFS GRIB2 data"
    echo " at defined lat lon position the requested variables "
    echo " NOTE currently just a fix meteogram data set is derived"
    echo " "
    echo "Usage: ./extractGribGFS.sh -h gives this brief help "
    echo "       ./extractGribGFS.sh -i=INFILE -la=DDD.DD -lo=0  "
    echo""
    echo "  i=INFILE:    <Name>      of a valid grib2 file"
    echo " -lo=DD.DD:    <Longitude> of location that will be "
    echo "                           extracted in decimal degrees"
    echo " -la=DD.DD:    <Latitude>  of location that will be "
    echo "                           extracted in decimal degrees"
    echo " -t=type:      <keyword>   Type of data processing "
    echo "                           'meteogram'"
    echo "                           'wmaps'"
    echo "                           'maps'"
    
    echo " "
    echo " example: ./extractGribGFS.sh -i=gfs.t00z.pgrb2.0p25.20150618_00_96.grb -lo=10.5 -la=47.25 m=meteogram"
    exit 0
fi


for i in "$@"
do
case $i in
    -i=*|--GRIBINPUT=*)
    INFILE="${i#*=}"
    ;;
    -la=*|--latitude=*)
    LAT="${i#*=}"
    ;;
    -lo=*|--longitude=*)
    LON="${i#*=}"
    ;;
    -t=*|--type=*)
    type="${i#*=}"
    ;;    
    --default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
done

echo GRIB = ${INFILE}
echo LAT = ${LAT}
echo LON = ${LON}
if [[ "${INFILE}" == "" ]]; then echo "No data file available"; exit; fi
if [[ "${LAT}" == "" ]] ; then echo "No LAT provided - I take Marburg" ; LAT=50.8;LON=.8.7;  fi
if [[ "${LON}" == "" ]] ; then echo "No LON provided - I take Marburg" ; LAT=50.8;LON=.8.7;  fi
if [[ "${type}" == "" ]] ; then echo "No type take meteogram" ; type='meteogram';  fi

# list of all vars to be extracted
declare -a VARS=("HGT" "UGRD" "GUST" "PRES" "TMIN" "TMAX" "DPT" "RH" "PRMSL" "APCP" "ACPCP" "TCDC")

for i in `seq 0 $((${#VARS[@]}-1))`;
	do
      if [ ${VARS[$i]} == 'UGRD' ] ; then
       # first calculate WIND DIR and SPEED
       wgrib2 $INFILE  -match "(UGRD|VGRD)" -wind_speed WIND.grb  -wind_dir WIND.grb > /dev/null 2>&1
              # extract the dmenaded levels
                            
       wgrib2 -match  ":WIND:10 m above ground:"               WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WS10
       wgrib2 -match  ":WDIR:10 m above ground:"               WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WD10
       wgrib2 -match  ":WIND:100 m above ground:"              WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WS100
       wgrib2 -match  ":WDIR:100 m above ground:"              WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WD100
       wgrib2 -match  ":WIND:1829 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WS1829
       wgrib2 -match  ":WDIR:1829 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WD1829
       wgrib2 -match  ":WIND:2743 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WS2743
       wgrib2 -match  ":WDIR:2743 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WD2743
       wgrib2 -match  ":WIND:3658 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WS3658
       wgrib2 -match  ":WDIR:3658 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WD3658             
      elif [ ${VARS[$i]} == 'GUST' ] ;  then
       wgrib2 -match  ":${VARS[$i]}:surface:"                  $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > GUST
      elif [ ${VARS[$i]} == 'PRES' ] ;  then 
       wgrib2 -match  ":${VARS[$i]}:surface:"                  $INFILE  -rpn "0.01:*"    -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > PRES
      elif [ ${VARS[$i]} == 'PRMSL' ] ;  then 
       wgrib2 -match  ":${VARS[$i]}:mean sea level:"                  $INFILE  -rpn "0.01:*"    -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > PRMSL
      elif [ ${VARS[$i]} == 'TMAX' ] ;	then
       wgrib2 -match  ":${VARS[$i]}:2 m above ground:"         $INFILE  -rpn "273.15:-" -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > TMAX
      elif [ ${VARS[$i]} == 'TMIN' ] ;	then
       wgrib2 -match  ":${VARS[$i]}:2 m above ground:"         $INFILE  -rpn "273.15:-" -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > TMIN
      
      elif [ ${VARS[$i]} == 'DPT' ] ;	then
       wgrib2 -match  ":${VARS[$i]}:2 m above ground:"         $INFILE  -rpn "273.15:-" -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > DPT
      elif [ ${VARS[$i]} == 'RH' ] ;	then
       wgrib2 -match  ":${VARS[$i]}:2 m above ground:"         $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > RH
      elif [ ${VARS[$i]} == 'HGT' ] ;	then
       wgrib2 -match  ":${VARS[$i]}:surface:"                  $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > HGT
      elif [ ${VARS[$i]} == 'ACPCP' ] ;	then
       wgrib2 -match  ":${VARS[$i]}:surface:"                  $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > ACPCP
      elif [ ${VARS[$i]} == 'APCP' ] ;	then
       wgrib2 -match  ":${VARS[$i]}:surface:"                  $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > APCP              
      elif [ ${VARS[$i]} == 'TCDC' ] ;	then
       wgrib2 -match  ":TCDC:low cloud layer:"                 $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > lTCDC
       wgrib2 -match  ":TCDC:middle cloud layer:"              $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > mTCDC
       wgrib2 -match  ":TCDC:high cloud layer:"                $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > hTCDC

	  fi	
		i=$((i+1))

# get the STARTTIME
	done

    
      # just for getting startime and valid data periods the use of the TCDC is arbitrary 
       wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=d=).*(?=,)' | awk '{print substr($0, 0, 10);}' > STIME
       wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=vt=).*(?=:DEL)' | awk '{ printf("%010d\n", $0 - 3) }' > CTIME1
       wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=vt=).*(?=:DEL)'  > CTIME2
	  
       while read line
       do
        STARTTIME=$line
        break
       done < 'STIME'   
       while read line
       do
        geoHGT=$line
        break
       done < 'HGT'

# calculate sunrise/set

Y=${STARTTIME:0:4}
M=${STARTTIME:4:2}
D=${STARTTIME:6:2}

SUNTIME=$(./suncalc.R "$M/$D/$Y" $LON $LAT)
    

Y=${STARTTIME:0:4}
M=${STARTTIME:4:2}
D=${STARTTIME:6:2}

tmp=${STARTTIME}_${LON}_${LAT}
mod=${tmp//./-}
OUTFILE=$mod.meteogram

# past the single col-files together (del=,)
paste -d',' CTIME1 CTIME2 PRES PRMSL TMAX TMIN DPT RH WS10 WD10 GUST WS100 WD100 WS1829 WD1829 WS2743 WD2743 WS3658 WD3658 APCP ACPCP lTCDC mTCDC hTCDC> $OUTFILE

# put header 
sed -i '1iStartzeit, Endzeit,Lokaler Luftdruck,Reduzierter Luftdruck,MaxTemp,MinTemp,TaupunktTemp,Relative Feuchte,Windgeschwindigkeit 10m, Windrichtung 10m, Windböen, Windgeschwindigkeit 100m, Windrichtung 100m, Windgeschwindigkeit 1829m, Windrichtung 1829m, Windgeschwindigkeit 2743m, Windrichtung 2743m, Windgeschwindigkeit 3658m, Windrichtung 3658m, Konvektiver Niederschlag, Stratiformer Niederschlag,Wolkenbedeckung (niedrig),Wolkenbedeckung (mittel),Wolkenbedeckung (hoch)) '  $OUTFILE
# write some metatags
# STARTTIME : the Starting Time of the Model i.e. the Analysis run
# SUNTIME   : Sunrise and Sunset at the given coordinate in decimal Time
# HGT the geopotential Height of the given coordinate

# concat the META string
META=$STARTTIME,$SUNTIME,$geoHGT

sed -i "1i${META}"  $OUTFILE 
set -- "HGT" "STIME" "WIND.grb" "CTIME1" "CTIME2" "PRES" "PRMSL" "TMAX" "TMIN" "DPT" "RH" "WS10" "WD10" "GUST" "WS100" "WD100" "WS1829" "WD1829" "WS2743" "WD2743" "WS3658" "WD3658" "APCP" "ACPCP" "lTCDC" "mTCDC" "hTCDC"
# cleanup
rm -f $@

