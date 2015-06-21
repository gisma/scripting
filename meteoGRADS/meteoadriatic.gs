function main(args)

* Parse the arguments: name, date, longitude, latitude, units
if (args = '')
  location = 'Wasserkuppe'
  date = '2013082518'
  lon = '13.778815'
  lat = '46.18096'
  units = '10'
  maxtime = '26'
  run ='test'
  domain ='waku203_2700ARP'
  if (metric='n' | metric='N') ; units='e' ; endif
else
lat = subwrd(args,1)
lon = subwrd(args,2)
maxtime = subwrd(args,3)
location = subwrd(args,4)
product = subwrd(args,5)
resolution = subwrd(args,6)
date = subwrd(args,7)
run = subwrd(args,8)
domain = subwrd(args,9)
endif

'reinit'
'open /home/creu/progs/opengrads/data/stol_d1_ARP.gradscntl'

'set background 1'
'c'

* RELATIVE HUMIDITY, TEMPERATURE

'set vpage 0.63 8.5 4.4 11'
'set display color white'
'set lat 'lat
'set lon 'lon
'set t 1 'maxtime
'set clopts -1 -1 0.08'
'set clskip 1 3.5'
'set lev 244.57 3179.39'

*calculate airtemperature 
'define  t = pow(pt/(1000/p),0.287)'
*calculate water saturation pressure (E)
' define es = 6.107*pow(10,(7.5*t)/(235+t))'
*calculate water partial pressure (e)
'define e = (p*qv)/622'
*calculate rH
'define rh=(e/es)*1000'


 Set the Plot Area for the Upper Air Panel
p = npanels
'set parea 'panel.p
'set vpage off'
'set grads off'
'set grid on'

* Draw the Relative Humidity Shading
'set gxout shaded'
'set csmooth on'
'set clevs  30 50 70 90 100'
'set ccols 0 20 21 23 25 26'
'set xlopts 1 4 0.16'
'set xlpos 0 t'
'set ylab `1%g'
'set ylint 100'
if (units = 'e')
  'define t = (t-273.16)*1.8+32'
  'define u = u*2.2374'
  'define v = v*2.2374'

endif
*'set t '_t1-0.5' '_t2+0.5
*'set lev '_zbot+50' '_ztop-50
'd rh'
'set gxout contour'
'set grid off'
'set ccolor 15'
'set clab off'
'set clevs 10 30 50 70 90'
'd rh'
'set ccolor 0'
'set clab on'
'set cstyle 5'
'set clopts 15'
'set clevs 10 30 50 70 90'
'd rh'

* Draw the Temperature Contours
'set clopts -1'
'set cstyle 1'
'set ccolor rainbow'
'set rbcols 9 14 4 11 5 13 12 8 2 6'
if (units = 'e')
  'set cint 10'
  'd t'
  'set clevs 32'
  'set cthick 12'
  'set ccolor 1'
  'set clab off'
  'd t'
  'set background 1'
  'set ccolor 20'
  'set clevs 32'
  'set cthick 4'
  'set clab on'
  'set clab `4FR'
else
  'set cint 5'
  'd t'
  'set clevs 0'
  'set cthick 12'
  'set ccolor 1'
  'set clab off'
  'd t'
  'set background 1'
  'set ccolor 20'
  'set clevs 0'
  'set cthick 4'
  'set clab on'
endif
'd t'

* Draw the Wind Barbs
'set background 0'
'set gxout barb'
'set ccolor 1'
'set xlab off'
'set ylab off'
'd u;v'

* Draw a rectangle over the year to clear the area for a title
'set line 0'
'draw recf 0.5 10.52 1.95 11.0'





'draw title 'location ' 'product ' 'resolution

'set vpage 0 3.5 0 11'
'set string 1'
'set strsiz 0.10'
'draw string 0.3 8.2 Temperatura'
'draw string 0.6 8.0 (st.C)'
'set string 3'
'draw string 0.22 7.7 Relativna vlaga'
'draw string 0.7 7.5 (%)'
'set string 1'
'set strsiz 0.15'
'draw string 0.1 10.7 init: '
'draw string 0.1 10.5 'date' 'run'z'
'set strsiz 0.08'
'draw string 0.1 10.1 Forecast model by'
'draw string 0.1 10.0 www.meteoadriatic.net'
'set strsiz 0.10'




* MSLP, TEMPERATURE 2M

'set vpage 0 8.5 2.5 5.55'
'set grads off'
'set xlab off'
'set t 1 'maxtime+1
'set lev 1013'
'set gxout line'
'set ccolor 12'
'set cmark 0'
'set csmooth on'
'set ylint 3'
'd p/100'
'set ccolor 10'
'set cmark 0'
'set ylint 5'
'set ylpos 0 r'
'set ylopts 2'
'set grid horizontal 5 2'
'd t'

'set string 1'
'draw string 0.15 1.7 Atmosferski tlak'
'draw string 0.6 1.5 (hPa)'
'set string 2'
'draw string 0.12 1.2 Temperatura 2m'
'draw string 0.6 1.0 (st.C)'



* WIND SPEED, WIND BARBS

'set vpage 0 8.5 1.2 4.0'
'set grads off'
'set gxout line'
'set cmark 0'
'set ylopts 3'
'set ylevs 1 5 10 15 20 30 40 50'
'set ylpos 0 l'
'set ccolor 3'
'set cthick 6'
'set grid horizontal 5 3'
'd mag(u,v)'
'set parea 2 8.0 0.2 2.6'
lap1 = lat + 0.01
lam1 = lat - 0.01
'set lat 'lam1' 'lap1
'set frame off'
'set xyrev on'
'set ylab off'
'set cthick 1'
'set gxout barb'
'd skip(u*1.95,1,4);v*1.95'
'set parea off'
'set lat 'lat
'set frame on'
'set ylab on'
'set string 1'
'draw string 0.3 1.4 Brzina i smjer'
'draw string 0.6 1.2 vjetra'
'draw string 0.6 1.0 (m/s)'




* PRECITPITATION

'set vpage 0 8.5 0 2.7'
'set xlab on'
count = 2
'set gxout contour'
maxprec = 0.1
maxcount = maxtime+2
while ( count < maxcount )
'set t 'count
'd qc'
mprec = subwrd(result,10)
if ( mprec > maxprec )
'd qc'
maxprec = subwrd(result,10)
endif
count = count + 1
endwhile

'set grads off'
'set t 1 'maxtime+1
'set lev 1013'
'set gxout bar'
'set ccolor 4'
'set ylopts 4'
if ( maxprec < 1 )
'set ylevs 0.1 0.2 0.4 0.6 0.8 1'
endif
if ( maxprec >= 1 & maxprec < 10 )
'set ylevs 0.5 1 2 4 6 8 10'
endif
if ( maxprec >= 10 )
'set ylevs 1 5 10 20 30 50 70 100'
endif
'set vrange 0 'maxprec+maxprec/20
'set grid horizontal 5 4'
'd qc'
'set string 4'
'draw string 0.2 1.5 Ukupna oborina'
'draw string 0.5 1.3 (mm/1h)'

*'printim /tmp/wrf/nmm/'domain'/meteogrami/'location'.png x695 y900'
*'quit'

return
