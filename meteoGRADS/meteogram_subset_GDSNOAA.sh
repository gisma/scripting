#!/home/creu/progs/opengrads/Contents/Resources/Scripts/grads2
* * * * * * * * * * * * *
* meteogram_subset_GDS.gs
* 
* This script will write out two small data files along with matching descriptor files.
* The files will be written to the same directory where the script is executed; any existing 
* files will be overwritten. These files contain all the variables needed to draw a meteogram,
* a multi-panel plot showing time series of forecasts for selected variables at a given location. 
* The data are downloaded from the GrADS Data Server at http://monsoondata.org:9090/dods/gfs0p25. 
* This script must be executed before running the meteogram script, meteogram_GDS.gs
* 
* The script requires three arguments: 
*    yyyymmddhh -- the initialization date of the desired forecast data
*    lon        -- the longitude of the desired location
*    lat        -- the latitude of the desired location
* 
* Written by Jennifer M. Adams (jma@iges.org)
* 
* Both scripts are available to download at: 
*   ftp://cola.gmu.edu/grads/scripts/meteogram_subset_GDS.gs
*   ftp://cola.gmu.edu/grads/scripts/meteogram_GDS.gs
* * * * * * * * * * * * * 
 
function main(args)
if (args='')

  return
else
  yyyymmdd=subwrd(args,1)
  hh=subwrd(args,2)
  lon=subwrd(args,3)
  lat=subwrd(args,4)
  fn=subwrd(args,5)
endif

* Flags for downloading both groups of data
getsubset=1
getsubsetp=1

* Open the GDS data file
*'sdfopen http://monsoondata.org:9090/dods/gfs0p25/gfs.yyyymmddhh'

'sdfopen http://nomads.ncep.noaa.gov:9090/dods/gfs_0p25/gfs'yyyymmdd'/gfs_0p25_'hh'z'
say  'sdfopen http://nomads.ncep.noaa.gov:9090/dods/gfs_0p25/gfs'yyyymmdd'/gfs_0p25_'hh'z'  
*'open /home/creu/Daten/ARPS/ente/grib/15050500.gfs.t00z.pgbf00.gdf'

if (rc!=0)
  say 'http://nomads.ncep.noaa.gov:9090/dods/gfs_0p25/gfs'yyyymmdd'/gfs_0p25_'hh'z'
  return
endif

'set lon 'lon
glon=subwrd(result,4)
'set lat 'lat
glat=subwrd(result,4)

zmax=23
tmax=49
'set gxout fwrite'

if (getsubset=1)
* Write out the variables needed for the meteogram
  '!date'
  say 'extracting atmos data to  'fn'.dat'
  'set fwrite 'fn'.dat'
  t=1
  f=0
 
  while (t<=tmax)
     say 'step 't' of 'tmax
    'set t 't
    fmod=math_fmod(t,2)
*   write out the z-varying variables
    z=1; while (z<=zmax); 'set z 'z; 'd tmpprs';  z=z+1; endwhile
    z=1; while (z<=zmax); 'set z 'z; 'd rhprs'; z=z+1; endwhile
    if (fmod=0)
*     write out missing values for 3hr winds
      z=1; while (z<=zmax); 'd const(lat,-9.99e8,-a)' ; z=z+1; endwhile
      z=1; while (z<=zmax); 'd const(lat,-9.99e8,-a)' ; z=z+1; endwhile
    else
*     write out winds only for 6-hour increments
      z=1; while (z<=zmax); 'set z 'z; 'd ugrdprs' ; z=z+1; endwhile
      z=1; while (z<=zmax); 'set z 'z; 'd vgrdprs' ; z=z+1; endwhile
    endif
*   write out single-level variables
    'set z 1'
    'd hgtprs(lev=500)-hgtprs(lev=1000)'
    'd prmslmsl' 
    'd pressfc'
    'd ugrd10m'
    'd vgrd10m'
    'd tmp2m' 
    'd dpt2m' 
    'd rh2m'
    if (fmod=0)
*     write out missing values for 3hr min/max
      'd const(lat,-9.99e8,-a)'
      'd const(lat,-9.99e8,-a)'
    else
*     these are 6hr min/max values
      'd tmin2m'
      'd tmax2m'
    endif
    'd lftxsfc'    
    'd capesfc'
    'd tcdclcll'
    'd tcdcmcll'
    'd tcdchcll'
    t=t+1
    f=f+3
  endwhile
  'disable fwrite'
   
    
* Create the descriptor file
  ctl=fn'.ctl'
  rc=write(ctl,'dset ^'fn'.dat')
  rc=write(ctl,'title GFS subset data for a meteogram',append)
  rc=write(ctl,'undef -9.99e8',append)
  xdef='xdef 1 levels 'glon ; rc=write(ctl,xdef,append)
  ydef='ydef 1 levels 'glat ; rc=write(ctl,ydef,append)
  rc=write(ctl,'zdef 'zmax' levels ',append)
  rc=write(ctl,' 1000 975 950 925 900 875 850 825 800 775 750 725 ',append)
  rc=write(ctl,'  700 675 650 625 600 575 550 525 500 475 450',append)
  'set t 1'; 'q time'; inittime=subwrd(result,3)
  tdef='tdef 'tmax' linear 'inittime' 3hr'
  rc=write(ctl,tdef,append)
  rc=write(ctl,'vars 19',append)
  rc=write(ctl,'t      23  99  temperature',append)
  rc=write(ctl,'rh     23  99  relative humidity',append)
  rc=write(ctl,'u      23  99  u',append)
  rc=write(ctl,'v      23  99  v',append)
  rc=write(ctl,'thk     0  99  500-1000mb thickness',append)
  rc=write(ctl,'slp     0  99  sea level pressure',append)
  rc=write(ctl,'ps      0  99  surface pressure',append)
  rc=write(ctl,'u10m    0  99  u at 10m',append)
  rc=write(ctl,'v10m    0  99  v at 10m',append)
  rc=write(ctl,'t2m     0  99  temperature at 2m',append)
  rc=write(ctl,'td2m    0  99  dew point temperature at 2m',append)
  rc=write(ctl,'rh2m    0  99  relative humidity at 2m',append)
  rc=write(ctl,'t2min   0  99  min temperature at 2m',append)
  rc=write(ctl,'t2max   0  99  max temperature at 2m',append)
  rc=write(ctl,'li      0  99  lifted index',append)
  rc=write(ctl,'capes   0  99  CAPE at surface',append)
  rc=write(ctl,'lcc     0  99  low cloud cover',append)
  rc=write(ctl,'mcc     0  99  middle cloud cover',append)
  rc=write(ctl,'hcc     0  99  high cloud cover',append)
  rc=write(ctl,'endvars',append)
  rc=close(ctl)
endif

if (getsubsetp=1)
  '!date'
  say 'extracting precip data to  'fn'p.dat'
* Write out the precip variables in a separate file
  'set fwrite 'fn'p.dat'
  'set z 1'
  'set t 1'
    'd apcpsfc'
    'd acpcpsfc'
    'd crainsfc'
    'd cfrzrsfc'
    'd cicepsfc'
    'd csnowsfc'
  t=2
  while (t<=tmax-1)
*   these are 3-hourly accumulations
    'set t 't
    'd apcpsfc'
    'd acpcpsfc'
    'd crainsfc'
    'd cfrzrsfc'
    'd cicepsfc'
    'd csnowsfc'
*   these are 6-hourly accumulations
*   so we must subtract the previous 3hr totals
    'set t 't+1
    'd apcpsfc-apcpsfc(t-1)  '
    'd acpcpsfc-acpcpsfc(t-1)'
    'd crainsfc'
    'd cfrzrsfc'
    'd cicepsfc'
    'd csnowsfc'
    t=t+2
  endwhile
  'disable fwrite'
  
* Create the descriptor file
  ctl=fn'p.ctl'
  rc=write(ctl,'dset ^'fn'p.dat')
  rc=write(ctl,'title GFS subset data for a meteogram',append)
  rc=write(ctl,'undef -9.99e8',append)
  xdef='xdef 1 levels 'glon ; rc=write(ctl,xdef,append)
  ydef='ydef 1 levels 'glat ; rc=write(ctl,ydef,append)
  rc=write(ctl,'zdef 1 levels 1',append)
  'set t 1'; 'q time'; inittime=subwrd(result,3)
  tdef='tdef 'tmax' linear 'inittime' 3hr'
  rc=write(ctl,tdef,append)
  rc=write(ctl,'vars 6',append)
  rc=write(ctl,'p     0 99 total precip',append)
  rc=write(ctl,'pc    0 99 convective precip',append)
  rc=write(ctl,'crain 0 99 categorical rain',append)
  rc=write(ctl,'cfrzr 0 99 categorical freezing rain',append)
  rc=write(ctl,'cicep 0 99 categorical ice pellets',append)
  rc=write(ctl,'csnow 0 99 categorical snow',append)
  rc=write(ctl,'endvars',append)
  rc=close(ctl)
endif

'quit'





