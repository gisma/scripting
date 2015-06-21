* the map file is missing the gribmap tool fix this
'!gribmap -verf -i gfs_sample.ctl'
'open /home/creu/progs/opengrads/data/grib2/gfs_sample.ctl'
say 'no'

'!/bin/rm -f ~/progs/opengrads/data/grib2/subset.ctl'
'!grep tdef ~/progs/opengrads/data/grib2/gfs_sample.ctl > ~/progs/opengrads/data/grib2/subset.ctl'
'!cat ~/progs/opengrads/data/grib2/subset.head >> ~/progs/opengrads/data/grib2/subset.ctl'
'!/bin/rm -f ~/progs/opengrads/data/grib2/subsetp.ctl'
'!grep tdef ~/progs/opengrads/data/grib2/gfs_sample.ctl > ~/progs/opengrads/data/grib2/subsetp.ctl'
'!cat ~/progs/opengrads/data/grib2/subsetp.head >> ~/progs/opengrads/data/grib2/subsetp.ctl'

'set gxout fwrite'
'set x 1 720'
'set y 1 361'


zmax=21
t = 1
f=0
while (t <= 61)
  say 't='t' f='f
  fmt='%03.0f'
  fhr=math_format(fmt,f)
  'set fwrite subset.fh'fhr'.dat'
  say fmt

  say result
  'set t 't
  z=1
  while (z<=zmax)
    'set z 'z
    'd z'
    z=z+1
  endwhile
  z=1
  while (z<=zmax)
    'set z 'z
    'd t'
    z=z+1
  endwhile
  z=1
  while (z<=zmax)
    'set z 'z
    'd u'
    z=z+1
  endwhile
  z=1
  while (z<=zmax)
    'set z 'z
    'd v'
    z=z+1
  endwhile
  z=1
  while (z<=zmax)
    'set z 'z
    'd rh'
    z=z+1
  endwhile
  'set z 1'
  'd slp' 
  'd ps'  
  'd u10m'
  'd v10m'
  'd t2m' 
  'd rh2m'
  'd runoff'
  'd soilw1'
  'd li'    
  'flush'
  'disable fwrite'
  t = t + 1
  f = f + 3

endwhile

'set gxout fwrite'
'set fwrite subsetp.dat'
'set t 1'
'set z 1'
'd p'
'd pc'
'd crain'
'd cfrzr'
'd cicep'
'd csnow'
index = 2
while (index <= 60)  ;* 60 is 1 timestep (or 3 hours) before the final time 
  'set t 'index
  'd p'
  'd pc'
  'd crain'
  'd cfrzr'
  'd cicep'
  'd csnow'
  'set t 'index+1
  'd p-p(t-1)  '
  'd pc-pc(t-1)'
  'd crain'
  'd cfrzr'
  'd cicep'
  'd csnow'
  'flush'
  index = index + 2
endwhile
'disable fwrite'
*'quit'
