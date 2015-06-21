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
  say 'Usage: meteogram_subset_GDS <yyyymmddhh> <lon> <lat>'
  return
else
  yyyymmddhh=subwrd(args,1)
  lon=subwrd(args,2)
  lat=subwrd(args,3)
endif

* Flags for downloading both groups of data
getsubset=1
getsubsetp=1

* Open the GDS data file
'sdfopen http://monsoondata.org:9090/dods/gfs0p25/gfs.'yyyymmddhh
if (rc!=0)
  say 'Error opening URL http://monsoondata.org:9090/dods/gfs0p25/gfs.'yyyymmddhh
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
  say 'Working on mysubset.dat'
  'set fwrite mysubset.dat'
  t=1
  f=0
  while (t<=tmax)
     say 'step 't' of 'tmax
    'set t 't
    fmod=math_fmod(t,2)
*   write out the z-varying variables
    z=1; while (z<=zmax); 'set z 'z; 'd t' ; z=z+1; endwhile
    z=1; while (z<=zmax); 'set z 'z; 'd rh'; z=z+1; endwhile
    if (fmod=0)
*     write out missing values for 3hr winds
      z=1; while (z<=zmax); 'd const(lat,-9.99e8,-a)' ; z=z+1; endwhile
      z=1; while (z<=zmax); 'd const(lat,-9.99e8,-a)' ; z=z+1; endwhile
    else
*     write out winds only for 6-hour increments
      z=1; while (z<=zmax); 'set z 'z; 'd u' ; z=z+1; endwhile
      z=1; while (z<=zmax); 'set z 'z; 'd v' ; z=z+1; endwhile
    endif
*   write out single-level variables
    'set z 1'
    'd z(lev=500)-z(lev=1000)'
    'd slp' 
    'd ps'  
    'd u10m'
    'd v10m'
    'd t2m' 
    'd td2m' 
    'd rh2m'
    if (fmod=0)
*     write out missing values for 3hr min/max
      'd const(lat,-9.99e8,-a)'
      'd const(lat,-9.99e8,-a)'
    else
*     these are 6hr min/max values
      'd t2min'
      'd t2max'
    endif
    'd li'    
    'd capes'
    'd lcc'
    'd mcc'
    'd hcc'
    t=t+1
    f=f+3
  endwhile
  'disable fwrite'

* Create the descriptor file
  ctl='mysubset.ctl'
  rc=write(ctl,'dset ^mysubset.dat')
  rc=write(ctl,'title GFS subset data for a meteogram',append)
  rc=write(ctl,'undef -9.99e8',append)
  xdef='xdef 1 levels 'glon ; rc=write(ctl,xdef,append)
  ydef='ydef 1 levels 'glat ; rc=write(ctl,ydef,append)
  rc=write(ctl,'zdef 23 levels ',append)
  rc=write(ctl,' 1000 975 950 925 900 875 850 825 800 775 750 725 ',append)
  rc=write(ctl,'  700 675 650 625 600 575 550 525 500 475 450',append)
  'set t 1'; 'q time'; inittime=subwrd(result,3)
  tdef='tdef 2 linear 'inittime' 3hr'
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
  say 'Working on mysubsetp.dat'
* Write out the precip variables in a separate file
  'set fwrite mysubsetp.dat'
  'set z 1'
  'set t 1'
  'd p'
  'd pc'
  'd crain'
  'd cfrzr'
  'd cicep'
  'd csnow'
  t=2
  while (t<=tmax-1)
*   these are 3-hourly accumulations
    'set t 't
    'd p'
    'd pc'
    'd crain'
    'd cfrzr'
    'd cicep'
    'd csnow'
*   these are 6-hourly accumulations
*   so we must subtract the previous 3hr totals
    'set t 't+1
    'd p-p(t-1)  '
    'd pc-pc(t-1)'
    'd crain'
    'd cfrzr'
    'd cicep'
    'd csnow'
    t=t+2
  endwhile
  'disable fwrite'

* Create the descriptor file
  ctl='mysubsetp.ctl'
  rc=write(ctl,'dset ^mysubsetp.dat')
  rc=write(ctl,'title GFS subset data for a meteogram',append)
  rc=write(ctl,'undef -9.99e8',append)
  xdef='xdef 1 levels 'glon ; rc=write(ctl,xdef,append)
  ydef='ydef 1 levels 'glat ; rc=write(ctl,ydef,append)
  rc=write(ctl,'zdef 1 levels 1',append)
  'set t 1'; 'q time'; inittime=subwrd(result,3)
  tdef='tdef 2 linear 'inittime' 3hr'
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




