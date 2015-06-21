function acss_terrain(args)
 
* DRAWING ARBITRARY CROSS SECTION AND THE UNDERLYING TERRAIN 
* Usage: 
*        Uses the collect command to collect the 3D field values in the vertical 
*        at each lat-lon point needed to plot the vertical cross section
*        than at the same lat-lon points reads in the value of the terrain
*        and plots it as a filled polygon
 
step=subwrd(args,1)
 'open  file.ctl'
 step2=step-1
 'set t 'step
'q time'
rec=subwrd(result,3)
rec1=substr(rec,1,2)
dat1=substr(rec,4,9)
 
*gray shades
'set rgb 16 230 230 230'
'set rgb 17 210 210 210'
'set rgb 18 204 204 204'
'set rgb 19 195 195 195'
'set rgb 20 179 179 179'
'set rgb 21 160 160 160'
'set rgb 22 150 150 150'
'set rgb 23 139 139 139'
'set rgb 24 128 128 128'
'set rgb 25 115 115 115'
'set rgb 26 100 100 100'
'set rgb 27  85  85  85'
'set rgb 28  70  70  70'
'set rgb 29  55  55  55'
'set rgb 30  40  40  40'
'set rgb 31  25  25  25'
 
height=4000
hgt=height/1000
 
'c'
'set background 0'
'set line 0'
'draw rec 0 0 11 8.5'
'enable print tmp1.out'
'set grads off'
'set x 1'
'set y 10'
'set lev  10 'height
* ARBITRARY CROSS-SECTION defined by lon1-lat1 lon2-lat2 
lon1=15.579
lon2=15.826
lat1=43.93425
lat2=44.3
lon=lon1
lat=lat1
'collect 1 free'
'collect 2 free'
'collect 3 free'
while (lon<=lon2)
     'collect 1 gr2stn(pott,'lon','lat')'
     'collect 2 gr2stn(uuuu,'lon','lat')'
     'collect 3 gr2stn(vvvv,'lon','lat')'
     say lon
     say lat
     lon=lon+0.013
     lat=lat1 + (lat2-lat1)*(lon-lon1) / (lon2-lon1)
endwhile
 
* Horizotal windspeed and potential temparature
'set lon 'lon1' 'lon2
'set xaxis 'lon1' 'lon2' 0.05'
'set parea 1 9.25 1 7.75'
'set vrange 10 'height
'set yaxis 0 'hgt' 0.5'
'set clab off'
'set gxout shaded'
'set xlopts 1 7 0.18'
'set ylopts 1 7 0.18'
'set clevs 5 10 15 20 25 30 35 '
'set ccols 0 19 22 24 26 28 29 30'
' d mag(coll2gr(2),coll2gr(3))'
'set gxout contour'
'set clab off'
'set clevs 5 10 15 20 25 30 35 '
'set ccols 26'
' d mag(coll2gr(2),coll2gr(3))'
'set vrange 10 'height
'set yaxis 0 'hgt' 0.5'
'set gxout contour'
'set clab on'
'set cint 1'
'set ccolor 1'
'set clskip 5'
'set cthick 1'
'd coll2gr(1)'
'set gxout vector'
len = 0.4
scale = 20
'set arrscl ' len' 'scale
'set arrlab on'
'set ccolor 1'
'set cthick 1'
'set vrange 10 'height
'set yaxis 0 'hgt' 0.5'
'd coll2gr(2);coll2gr(3)'
'set strsiz 0.18'
'draw xlab lon(deg E)'
'draw ylab z(km MSL)'
* TERRAIN
'set lev  10 '
'set parea 1 9.25 1 7.75'
ln=lon1
lt1=lat1
ln1=lon1
'set lon 'lon1' 'lon2
rc=terrain(height,ln,ln1,lt1,lon1,lon2,lat1,lat2)
 
'set strsiz 0.17'
'set string 1 c 5'
'draw string 5.1 8 Pot.Temp.(K), H. Windspeed(m/s) at 'step2' UTC 'dat1''
'print'
'disable print'
'!gxgif -r -x 740 -y 582 -i tmp1.out -o cross_HWind_'step2'.gif'
 
 
**********************************************
'quit'
 
 
 
**************************************************************
 
   function terrain(height,ln,ln1,lt1,lon1,lon2,lat1,lat2)
 
* this terrain adjustment is specified for the parea used here
* when scaling the terrain height if parea is different
* use ymax-ymin in parea(eg. 7.75-1=6.75)
 
while (ln<lon2)
      ln=ln+0.013
      lt=lat1 + (lat2-lat1)*(ln-lon1) / (lon2-lon1)
* calculates the lat/lon for which 2D terrain is extracted
  'q w2xy 'ln1' 'lt1
  x1=subwrd(result,3)
  'set lon 'ln1
  'set lat 'lt1
  'd topo'
  res =sublin(result,2)
  mt=subwrd(res,4)
*check if the actual terrain height is higher than the domain height and 
*if it is set it to that height so that terrain doesn't go outside the cross-section
  if (mt>height); mt=height;endif
  t1=mt*6.75/height+1
  'q w2xy 'ln' 'lt
  x2=subwrd(result,3)
  'set lon 'ln
  'set lat 'lt
  'd topo'
  res =sublin(result,2)
  mt=subwrd(res,4)
  if (mt>height); mt=height;endif
  t2=mt*6.75/height+1
  'set line 1 1 5'
  'draw polyf 'x1' 1 'x1' 't1' 'x2' 't2' 'x2' 1'
     lt1=lt
     ln1=ln
endwhile
 
**************************************
return
