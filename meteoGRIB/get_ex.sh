#!/bin/bash
# Chris Reudenbach
# Version: 0.1 Date: 2015-06-17
# simple script to download (selected) GFS 0.25 data for a forecast period
# from the NCEP NOAA archive
# Additionally it converts the single files to one datafile for use with IDV etc.
# and comfortable timeseries analysis
# generates netcdf, grib1 and grib2 all in one files


#set -x
# define variables FIXME argv
date=20150619
starthour=0
zstarthour=$(printf "%02d\n" $starthour)
echo "$zstarthour"
hour=$starthour
zhour=$(printf "%03d\n" $hour)
endhour=96
leftlon="-180"
rightlon="180"
toplat="90"
bottomlat="-90"

# make dirs
if [ ! -d $date ]; then
 mkdir ${date}
fi

while [ $hour -le $endhour ]
do

# here we put the filter URL of the noaa g2sub service (i.e. http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?dir=%2Fgfs.2015061700)
# we can also use the regular download from gribmaster  or similar scripts
#URL="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${zstarthour}z.pgrb2.0p25.f${zhour}&lev_0C_isotherm=on&lev_1000_mb=on&lev_100_m_above_ground=on&lev_10_m_above_ground=on&lev_200_mb=on&lev_2_m_above_ground=on&lev_3000-0_m_above_ground=on&lev_300_mb=on&lev_400_mb=on&lev_500_mb=on&lev_550_mb=on&lev_600_mb=on&lev_650_mb=on&lev_700_mb=on&lev_750_mb=on&lev_800_mb=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&lev_boundary_layer_cloud_layer=on&lev_convective_cloud_bottom_level=on&lev_convective_cloud_layer=on&lev_convective_cloud_top_level=on&lev_entire_atmosphere_%5C%28considered_as_a_single_layer%5C%29=on&lev_high_cloud_bottom_level=on&lev_high_cloud_layer=on&lev_high_cloud_top_level=on&lev_low_cloud_bottom_level=on&lev_low_cloud_layer=on&lev_low_cloud_top_level=on&lev_middle_cloud_bottom_level=on&lev_middle_cloud_layer=on&lev_middle_cloud_top_level=on&lev_planetary_boundary_layer=on&lev_surface=on&var_4LFTX=on&var_CAPE=on&var_CIN=on&var_CLWMR=on&var_CRAIN=on&var_CSNOW=on&var_CWAT=on&var_DPT=on&var_GUST=on&var_HGT=on&var_POT=on&var_PRATE=on&var_PRES=on&var_RH=on&var_SUNSD=on&var_TMAX=on&var_TMIN=on&var_TMP=on&var_UGRD=on&var_VGRD=on&var_VVEL=on&leftlon=${leftlon}&rightlon=${rightlon}&toplat=${toplat}&bottomlat=${bottomlat}&dir=%2Fgfs.${date}${zstarthour}" 

echo "URL='http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${zstarthour}z.pgrb2.0p25.f${zhour}&lev_1000_mb=on&lev_100_mb=on&lev_10_m_above_ground=on&lev_200_mb=on&lev_2_m_above_ground=on&lev_300_mb=on&lev_400_mb=on&lev_500_mb=on&lev_600_mb=on&lev_700_mb=on&lev_750_mb=on&lev_800_mb=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&var_4LFTX=on&var_ALBDO=on&var_CAPE=on&var_CIN=on&var_CLWMR=on&var_CPRAT=on&var_CRAIN=on&var_CSNOW=on&var_CWAT=on&var_CWORK=on&var_DPT=on&var_GUST=on&var_HGT=on&var_POT=on&var_PRATE=on&var_PRES=on&var_RH=on&var_SUNSD=on&var_TMAX=on&var_TMIN=on&var_TMP=on&var_UGRD=on&var_VGRD=on&var_VVEL=on&subregion=&leftlon=${leftlon}&rightlon=${rightlon}&toplat=${toplat}&bottomlat=${bottomlat}&dir=%2Fgfs.${date}${zstarthour}'"


#URL="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${zstarthour}z.pgrb2.0p25.f${zhour}&lev_1000_mb=on&lev_10_m_above_ground=on&lev_200_mb=on&lev_2_m_above_ground=on&lev_300_mb=on&lev_400_mb=on&lev_500_mb=on&lev_550_mb=on&lev_600_mb=on&lev_650_mb=on&lev_700_mb=on&lev_750_mb=on&lev_800_mb=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&var_4LFTX=on&var_CAPE=on&var_CIN=on&var_CLWMR=on&var_CRAIN=on&var_CSNOW=on&var_CWAT=on&var_DPT=on&var_GUST=on&var_HGT=on&var_POT=on&var_PRATE=on&var_PRES=on&var_RH=on&var_SUNSD=on&var_TMAX=on&var_TMIN=on&var_TMP=on&var_UGRD=on&var_VGRD=on&var_VVEL=on&subregion=&leftlon=${leftlon}&rightlon=${rightlon}&toplat=${toplat}&bottomlat=${bottomlat}&dir=%2Fgfs.${date}${zstarthour}" 
URL="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${zstarthour}z.pgrb2.0p25.f${zhour}&lev_1000_mb=on&lev_100_mb=on&lev_10_m_above_ground=on&lev_200_mb=on&lev_2_m_above_ground=on&lev_300_mb=on&lev_400_mb=on&lev_500_mb=on&lev_600_mb=on&lev_700_mb=on&lev_750_mb=on&lev_800_mb=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&var_4LFTX=on&var_ALBDO=on&var_CAPE=on&var_CIN=on&var_CLWMR=on&var_CPRAT=on&var_CRAIN=on&var_CSNOW=on&var_CWAT=on&var_CWORK=on&var_DPT=on&var_GUST=on&var_HGT=on&var_POT=on&var_PRATE=on&var_PRES=on&var_RH=on&var_SUNSD=on&var_TMAX=on&var_TMIN=on&var_TMP=on&var_UGRD=on&var_VGRD=on&var_VVEL=on&subregion=&leftlon=${leftlon}&rightlon=${rightlon}&toplat=${toplat}&bottomlat=${bottomlat}&dir=%2Fgfs.${date}${zstarthour}"
#URL="http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t00z.pgrb2.0p25.f000&lev_1000_mb=on&lev_100_mb=on&lev_10_m_above_ground=on&lev_200_mb=on&lev_2_m_above_ground=on&lev_300_mb=on&lev_400_mb=on&lev_500_mb=on&lev_600_mb=on&lev_700_mb=on&lev_750_mb=on&lev_800_mb=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&var_4LFTX=on&var_ALBDO=on&var_CAPE=on&var_CIN=on&var_CLWMR=on&var_CPRAT=on&var_CRAIN=on&var_CSNOW=on&var_CWAT=on&var_CWORK=on&var_DPT=on&var_GUST=on&var_HGT=on&var_POT=on&var_PRATE=on&var_PRES=on&var_RH=on&var_SUNSD=on&var_TMAX=on&var_TMIN=on&var_TMP=on&var_UGRD=on&var_VGRD=on&var_VVEL=on&subregion=&leftlon=-10&rightlon=40&toplat=70&bottomlat=30&dir=%2Fgfs.2015061700"

# then we get the data via cURL
curl "$URL" -o ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f${zhour}

#### converts grib2nc
###cdo -f nc copy ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f${zhour} ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f${zhour}.nc
#### compression via shuffeling and compressing (http://www.unidata.ucar.edu/blogs/developer/en/entry/netcdf_compression)
###nccopy -u -d9 ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f${zhour}.nc  ${date}/gfs.t${zstarthour}z.0p25.f${zhour}.nc
#### delete single nc files as not useful anymore
###rm ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f${zhour}.nc
#### convert grib2 to grib1 via cnvgrib as taken from the gribmaster bin directory
###cnvgrib -g21 ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f${zhour} ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f${zhour}.grb
#### delete single GRIB2 files as not useful anymore
###rm ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f${zhour}

# INCREMENT timeslot
hour=$(($hour + 3))

# format it correct for substitution 
zhour=$(printf "%03d\n" $hour)
done

# rename initial analysis data due to a different number of variables
#mv ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f000 ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f000.grb

#cdo mergetime $date/*.nc ${date}/gfs.t${zstarthour}z.pgrb2.0p25.$Date_${zstarthour}_${endhour}.nc

# merge all grib2 files to one 
#cdo mergetime ${date}/gfs.t${zstarthour}z.pgrb2.0p25.f??? ${date}/gfs.t${zstarthour}z.pgrb2.0p25.${date}_${zstarthour}_${endhour}.grb

# convert it to netcdf (it seems to work even if there some warnings)
#cdo -f nc copy ${date}/gfs.t${zstarthour}z.pgrb2.0p25.${date}_${zstarthour}_${endhour}.grb ${date}/gfs.t${zstarthour}z.pgrb2.0p25.${date}_${zstarthour}_${endhour}.nc

# and squeeze it via shuffeling and compressing (http://www.unidata.ucar.edu/blogs/developer/en/entry/netcdf_compression)
#nccopy -u -d5 ${date}/gfs.t${zstarthour}z.pgrb2.0p25.$Date_${zstarthour}_${endhour}.nc ${date}/gfs.t${zstarthour}z.0p25.${date}_${zstarthour}_${endhour}.nc

# convert the grib 2 to grib one for usage with zygrib
#cnvgrib -g21 ${date}/gfs.t${zstarthour}z.pgrb2.0p25.$Date_${zstarthour}_${endhour}.grb ${date}/gfs.t${zstarthour}z.pgrb1.0p25.$Date_${zstarthour}_${endhour}.grb
