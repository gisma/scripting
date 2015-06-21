* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* meteogram_gfs.gs
*
* This script draws a meteogram based on NCEP forecast data.
* The data is available through the GrADS-DODS Server at COLA.
* You MUST be using a DODS-enabled version of GrADS.
*
* Usage:   meteogram_gfs <name> <yyyymmddhh> <lon> <lat> <e>
* Example: meteogram_gfs Boston  2003031300   -71    42   e
*
* The GFS forecasts are global. Check the GDS URL
* http://monsoondata.org:9090/dods/gfs for a complete
* listing of all available forecast times.
*
* The 'e' argument is for British units. Default is metric.
*
* Note: This script must be run in a directory in which
* you have write permission because intermediate files
* are written out to disk in order to speed up the display
* and minimize the number of hits to the data server.
* 
* Originally written by Paul Dirmeyer
* Modification History:
* J.M. Adams   Oct 2001
* Jim Kinter   Oct 2001
* J.M. Adams   Dec 2001
* Joe Wielgosz Jan 2002
* J.M. Adams   Jul 2002
* J.M. Adams   Mar 2003
* J.M. Adams   Jul 2005
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
function main(args)

* Make sure GrADS is in portrait mode
'q gxinfo'
pagesize = sublin(result,2)
xsize = subwrd(pagesize,4)
ysize = subwrd(pagesize,6)
if (xsize != 8.5 & ysize != 11)
  say 'You must be in PORTRAIT MODE to draw a meteogram'
  return
endif

* Parse the arguments: name, date, longitude, latitude, units
if (args = '')
  name = 'Wasserkuppe'
  date = '2015050418'
  hilon = '13.778815'
  hilat = '46.18096'
  metric = 'm'
  
  metric = 'm'
  if (metric='m' | metric='M') ; units='e' ; endif
else
  name  = subwrd(args,1)
  date  = subwrd(args,2)
  hilon = subwrd(args,3)
  hilat = subwrd(args,4)
  units = subwrd(args,5)
endif

* Open the data file
*'reinit'
*'open /home/creu/progs/opengrads/data/stol_d1_ARP.gradscntl'
*'sdfopen /home/creu/Daten/ARPS/ente/ente_d1_E2A.nc'
*'reinit'
_baseurl = 'http://monsoondata.org:9090/dods/gfs0p25/'
_dataset = 'gfs.'date
'sdfopen '_baseurl%_dataset
say _baseurl%_dataset
if (rc) ; return ; endif
* Get info from the descriptor file
'q ctlinfo'
_ctl = result
_undef = getctl(undef)
_tdef = getctl(tdef)
_zdef = getctl(zdef)
say _zdef
* Get the Time axis info
tsize = subwrd(_tdef,2)
_t1 = 2
_t2 = tsize
'set t '_t1' '_t2
'q dims'
times  = sublin(result,5)
_time1 = subwrd(times,6) 
_time2 = subwrd(times,8)
_tdim = _time1' '_time2
say times
tincr = subwrd(_tdef,5)
_tdef = 'tdef 'tsize' linear '_time1' 'tincr
say _zdef
* Get Vertical grid info
'set lev 244.57 3179.39'



* Find the grid point closest to requsted location
'set lon 'hilon
hilon = subwrd(result,4)

'set lat 'hilat
hilat = subwrd(result,4)
_xdim = hilon' 'hilon
_ydim = hilat' 'hilat

say pt
return
*calculate airtemperature 
'define  t = pow(pt/(1000/p),0.287)'
*calculate water saturation pressure (E)
' define es = 6.107*pow(10,(7.5*t)/(235+t))'
*calculate water partial pressure (e)
'define e = (p*qv)/622'
*calculate rH
'define rh=(e/es)*1000'
  if lev = 733.7 ; z500 = z ; endif
* Determine pressure range for hovmoellers

getseries(p,pshov,244.570000)
'set lon 'hilon
'set lat 'hilat
'd ave(pshov,t='_t1',t='_t2')*0.01-15.0'





* Set up a few preliminary characteristics
setcols(1)
'set display color white'
'c'

* Determine the plot areas for each panel
* Panels: Xsect, thickness, stability, slp, u10, t2m, rh2m, precip
npanels = 8 
x1 =  1.20
x2 =  8.15
y1 =  7.50
y2 = 10.10
panel.npanels = x1' 'x2' 'y1' 'y2   ;* hovmoeller panel
ytop = 7.5  ;* y boundaries for rest of panels except precip
ybot = 1.7
int = (ytop-ybot)/(npanels-2)     ;* get height of middle panels
int = 0.001 * (math_nint(1000*int))
n=npanels-1
y2 = ytop
while (n >= 2)
  y2 = ytop - (npanels-n-1)*int
  y1 = ytop - (npanels-n)*int
  panel.n = x1' 'x2' 'y1' 'y2        ;* coords of middle panels
  n = n - 1
endwhile
xincr = (8.15 - 1.2)/tsize           ;* size of one time step
xincr = 0.01 * math_nint(100*xincr)
panel.1 = x1+xincr' 'x2' 0.55 'y1     ;* coords of precip panel

* Set the Plot Area for the Upper Air Panel
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
*'set ylab `1%g'
'set ylab %g'
'set ylint 100'
if (units = 'e')
  'define t =  (t-273.16)*1.8+32'
  'define u =  u*2.2374'
  'define v =  v*2.2374'

endif
'set t '_t1-0.5' '_t2+0.5
'set lev 244.57+50 3179.39-50'
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

*Draw the Temperature Contours
'set clopts -1'
'set cstyle 1'
'set ccolor rainbow'
'set rbcols 9 14 4 11 5 13 12 8 2 6'
if (units = 'e')
  'set cint 10'
  'set cthick 6'
  'd t'
  'set clevs 32'
  'set cthick 12'
  'set ccolor 1'
  'set clab off'
  'd t'
  'set background 1'
  'set ccolor 20'
  'set clevs 32'
  'set cthick 3'
  'set clab on'
  'set clab `4FR'
else
  'set cint 5'
'set cthick 1'
  'd t'
'set clevs 0'
  'set cthick 1'
  'set ccolor 1'
  'set clab off'
  'd t'
  'set background 1'
  'set ccolor 1'
  'set clevs 0'
  'set cthick 1'
  'set clab on'
endif
'd t'

* Draw the Wind Barbs
'set background 0'
'set gxout vector'
'set arrlab off'
'set ccolor 15'
'set xlab off'
'set ylab off'
'd u;v'

* Draw a rectangle over the year to clear the area for a title
'set line 0'
'draw recf 0.5 10.6 2.5 11.0'

* Definisco Geopotentiale
'set lev 1000'
'set t '_t1' '_t2
*getseries('p',hgt,244.57)
getseries('p',z5,5135.93)
getseries('p',z10,244.57)
'define geop = z5'

* Next Panel: Geopotenziale 500
p = p - 1
'set parea 'panel.p
'set gxout line'
'set vpage off'
'set grads off'
'set grid on'
'set xlab on'
'set ylab on'
vrng(geop, geop)
'set ccolor 5'
'set cmark 0'
'set t '_t1-0.5' '_t2+0.5
'd geop'

* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)





* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02

* Next Panel: SLP

* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02

* Next Panel: Surface Wind Speed
p = p - 1

'define u10m=u*3.6'
'define v10m=v*3.6'

getseries(um,ubot,244.57)
getseries(v,vbot,244.57)
'set parea 'panel.p
'set vpage off'
'set grads off'
if (units = 'e')
'define ubot = 2.2374*ubot'
'define vbot = 2.2374*vbot'
else
'define ubot = 3.6*ubot'
'define vbot = 3.6*vbot'
endif
'define wind = mag(ubot,vbot)'
vrng(wind,wind)
'set ccolor 26'
'set cmark 0'
'set grid on'
'set t '_t1-0.5' '_t2+0.5
'set gxout contour'
'd wind'

* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02

* Next Panel: 2m Temperatures and Indices
getseries(tmp2m,tmp2m,1000)
getseries(rh2m,rh2m,1000)
p = p - 1
'set parea 'panel.p
'set vpage off'
'set frame on'
'set grads off'
'set ylab on'
'set gxout line'
'set grid on'
if (units = 'e')
  'define t2mc = const((tmp2m-273.16),0,-u)'
  'define tmp2m  = const((tmp2m-273.16)*9/5+32,0,-u)'
  'define dewpt = tmp2mc-((14.55+0.114*t2mc)*(1-0.01*rh2m)+pow((2.5+0.007*t2mc)*(1-0.01*rh2m),3)+(15.9+0.117*t2mc)*pow((1-0.01*rh2m),14))'
  'define dewpt = dewpt*9/5+32'
else
  'define t2mf = const((tmp2m-273.16)*1.8+32,0,-u)'
  'define tmp2m  = const((tmp2m-273.16),0,-u)'
  'define dewpt = tmp2m-((14.55+0.114*tmp2m)*(1-0.01*rh2m)+pow((2.5+0.007*tmp2m)*(1-0.01*rh2m),3)+(15.9+0.117*tmp2m)*pow((1-0.01*rh2m),14))'

endif
vrng(tmp2m,dewpt)
'set t '_t1-0.5' '_t2+0.5
if (units = 'e')
  'set ylint 10'
  'set gxout linefill'
  expr = 'tmp2m;const(tmp2m'
  'set lfcols  9 0' ; 'd 'expr',-60,-a)'
  'set lfcols  9 0' ; 'd 'expr',-60,-a)'
  'set lfcols 14 0' ; 'd 'expr',-10,-a)'
  'set lfcols  4 0' ; 'd 'expr',0,-a)'
  'set lfcols 11 0' ; 'd 'expr',10,-a)'
  'set lfcols  5 0' ; 'd 'expr',20,-a)'
  'set lfcols 13 0' ; 'd 'expr',30,-a)'
  'set lfcols  3 0' ; 'd 'expr',40,-a)'
  'set lfcols 10 0' ; 'd 'expr',50,-a)'
  'set lfcols  7 0' ; 'd 'expr',60,-a)'
  'set lfcols 12 0' ; 'd 'expr',70,-a)'
  'set lfcols  8 0' ; 'd 'expr',80,-a)'
  'set lfcols  2 0' ; 'd 'expr',90,-a)'
  'set lfcols  6 0' ; 'd 'expr',100,-a)'
  'set gxout line'
  'set ccolor 15'
  'set cstyle 3'
  'set cmark 0'
  'd t'
else

  'set ylint 3'
  'set gxout linefill'
  expr = 'tmp2m;const(tmp2m'
  'set lfcols 50 0' ; 'd 'expr',-24,-a)'
  'set lfcols 51 0' ; 'd 'expr',-22,-a)'
  'set lfcols 52 0' ; 'd 'expr',-20,-a)'
  'set lfcols 53 0' ; 'd 'expr',-18,-a)'
  'set lfcols 54 0' ; 'd 'expr',-16,-a)'
  'set lfcols 55 0' ; 'd 'expr',-14,-a)'
  'set lfcols 56 0' ; 'd 'expr',-12,-a)'
  'set lfcols 57 0' ; 'd 'expr',-10,-a)'
  'set lfcols 58 0' ; 'd 'expr',-8,-a)'
  'set lfcols 59 0' ; 'd 'expr',-6,-a)'
  'set lfcols 60 0' ; 'd 'expr',-4,-a)'
  'set lfcols 61 0' ; 'd 'expr',-2,-a)'
  'set lfcols 62 0' ; 'd 'expr',0,-a)'
  'set lfcols 63 0' ; 'd 'expr',2,-a)'
  'set lfcols 64 0' ; 'd 'expr',4,-a)'
  'set lfcols 65 0' ; 'd 'expr',6,-a)'
  'set lfcols 66 0' ; 'd 'expr',8,-a)'
  'set lfcols 67 0' ; 'd 'expr',10,-a)'
  'set lfcols 68 0' ; 'd 'expr',12,-a)'
  'set lfcols 69 0' ; 'd 'expr',14,-a)'
  'set lfcols 70 0' ; 'd 'expr',16,-a)'
  'set lfcols 71 0' ; 'd 'expr',18,-a)'
  'set lfcols 72 0' ; 'd 'expr',20,-a)'
  'set lfcols 73 0' ; 'd 'expr',22,-a)'
  'set lfcols 74 0' ; 'd 'expr',24,-a)'
  'set lfcols 75 0' ; 'd 'expr',26,-a)'
  'set lfcols 76 0' ; 'd 'expr',28,-a)'
  'set lfcols 77 0' ; 'd 'expr',30,-a)'
  'set lfcols 78 0' ; 'd 'expr',32,-a)'
  'set lfcols 79 0' ; 'd 'expr',34,-a)'
  'set lfcols 80 0' ; 'd 'expr',36,-a)'
  'set lfcols 81 0' ; 'd 'expr',38,-a)'
  'set lfcols 82 0' ; 'd 'expr',40,-a)'
  'set lfcols 83 0' ; 'd 'expr',42,-a)'
  'set lfcols 84 0' ; 'd 'expr',44,-a)'
  'set lfcols 85 0' ; 'd 'expr',46,-a)'
  'set lfcols 86 0' ; 'd 'expr',48,-a)'
  'set gxout line'
  'set ccolor 15'
  'set cstyle 3'
  'set cmark 0'
  'd t'
endif
'set grid on'
'set cmark 8'
'set ccolor 2'
'd t'

*'set ccolor 97'
*'set cmark 0'
*'d t'

* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02

* Back up to Previous Panel: 10m Wind Barbs
p = p + 1
'set parea 'panel.p
'set ccolor 1'
'set lat 'hilat
res=sublin(result,1)
latcross2=subwrd(res,4)
lap1 = latcross2 + 0.03
lam1 = latcross2 - 0.03
*'set lon 'hilon ;* ??
'set lon 'hilon
'set lat 'lam1' 'lap1
'set frame off'
'set grid off'
'set gxout vector'
'set arrlab off'
'set xyrev on'
'set xlab off'
'set ylab off'
if (units = 'e')
  'd skip(2.2374*u.1,2,1);2.2374*v.1'
else
  'd skip(u.1,2,1);v.1'
endif

* Reset dimension and graphics parameters
'set lat 'hilat
'set lon 'hilon
'set vpage off'
'set frame on'
'set grads off'
'set ylab on'
'set xlab on'
'set gxout line'
'set grid off'

* Skip to Next Panel: 2m Relative Humidity
p = p - 2
'set parea 'panel.p
*'set vpage off'
*'set grads off'
rh2vrng(rh2m)
'set gxout linefill'

'set lfcols 99 0' ; 'd rh2m;const(rh2m,16.01,-a)'
'set lfcols 98 0' ; 'd rh2m;const(rh2m,20.01,-a)'
'set lfcols 97 0' ; 'd rh2m;const(rh2m,24.01,-a)'
'set lfcols 96 0' ; 'd rh2m;const(rh2m,28.01,-a)'
'set lfcols 95 0' ; 'd rh2m;const(rh2m,32.01,-a)'
'set lfcols 94 0' ; 'd rh2m;const(rh2m,36.01,-a)'
'set lfcols 93 0' ; 'd rh2m;const(rh2m,40.01,-a)'
'set lfcols 92 0' ; 'd rh2m;const(rh2m,44.01,-a)'
'set lfcols 91 0' ; 'd rh2m;const(rh2m,48.01,-a)'
'set lfcols 90 0' ; 'd rh2m;const(rh2m,52.01,-a)'
'set lfcols 89 0' ; 'd rh2m;const(rh2m,56.01,-a)'
'set lfcols 88 0' ; 'd rh2m;const(rh2m,60.01,-a)'
'set lfcols 87 0' ; 'd rh2m;const(rh2m,64.01,-a)'
'set lfcols 86 0' ; 'd rh2m;const(rh2m,68.01,-a)'
'set lfcols 85 0' ; 'd rh2m;const(rh2m,72.01,-a)'
'set lfcols 84 0' ; 'd rh2m;const(rh2m,76.01,-a)'
'set lfcols 83 0' ; 'd rh2m;const(rh2m,80.01,-a)'
'set lfcols 82 0' ; 'd rh2m;const(rh2m,84.01,-a)'
'set lfcols 19 0' ; 'd rh2m;const(rh2m,88.01,-a)'
'set lfcols 18 0' ; 'd rh2m;const(rh2m,92.01,-a)'
'set lfcols 17 0' ; 'd rh2m;const(rh2m,96.01,-a)'

'set ccolor 28'
'set gxout line'
'set grid on'
'set cmark 2'
'd rh'





* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02




* Skip to Next Panel: Temperatura 850hPa
p = p - 1
'set lev 850'
'define temp=tmpprs-273.15'
'set parea 'panel.p
'set gxout line'
'set vpage off'
'set grads off'
'set grid on'
'set xlab on'
'set ylab on'
vrng(t,t)
'set ccolor 8'
'set cmark 0'
'set t '_t1-0.5' '_t2+0.5
'd t'
*'set string 26 c 4 90' ; 'draw string 0.65 'ymid' Umidita'


* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02


*
* Next Panel: Soil Moisture
*p = p -1
*'set parea 'panel.p
*getseries(runoff,runoff,1000)
*getseries(soilm2,sm,1000)
*
*'define sm = const(sm,0,-u)'
*'set t 1'
*'d sm(t=1)'
*sm1 = subwrd(result,4)
*'set t '_t1' '_t2
*'define ss = sm(t-1)/4 + sm/2 + sm(t+1)/4'
*if (units = 'e')
*  'define runoff  = const(runoff,0,-u)/25.4'
*  'define dsoilm = (ss-ss(t-1))*39.37*1.9'
*else
*  'define runoff  = const(runoff,0,-u)'
*  'define dsoilm = (ss-ss(t-1))*1000*1.9'
*endif
*'set vpage off'
*vrng(runoff,dsoilm)
*'set t '_t1+0.5' '_t2+0.5
*'set gxout bar'
*'set barbase 0'
*'set bargap 20'
*'set ccolor 5'
*'set grid on'
*'d runoff'
*'set grid on'
*'set ccolor 96'
*'set bargap 60'
*'d tsoil1'
*
* Draw a rectangle over the x-axis labels
*xlo = subwrd(panel.p,1)
*xhi = subwrd(panel.p,2)
*ylo = subwrd(panel.p,3)
*yhi = subwrd(panel.p,4)
*'set line 0'
*'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02
*




* Final Panel: Precipitation
getseries(qc,APCPsfc,1000)
getseries(qc,ACPCPsfc,1000)

getseries(qc,WEASDsfc,1000)
getseries(qc,cfrzrsfc,1000)
getseries(qc,cicepsfc,1000)

p = p - 1
'set parea 'panel.p
'set vpage off'
'set grid on'
'set grads off'
'define ptot  = APCPsfc'
'define pconv = ACPCPsfc'
'define psnow = WEASDsfc'
if (units = 'e')
  'define ptot  = const(ptot,0,-u)/25.4'
  'define pconv = const(pconv,0,-u)/25.4'
  'define psnow = const(psnow,0,-u)/25.4'
else
  'define ptot  = const(ptot,0,-u)'
  'define pconv = const(pconv,0,-u)'
  'define psnow = const(psnow,0,-u)'
endif

* Get Total Precipitation Range
'set gxout stat'
'd ptot'
data = sublin(result,8)
pmx = subwrd(data,5)
if (units = 'e')
  if (pmx < 0.05)
    pmx = 0.0499
  else
    pmx = pmx + (0.05*pmx)
  endif
else
  if (pmx < 1.0)
    pmx = 0.99
  else
    pmx = pmx + (0.05*pmx)
  endif
endif
'set vrange 0 'pmx
incr = 0.01 * (math_nint(100*pmx/5))
'set ylint 'incr
'set t '_t1+0.5' '_t2+0.5

* Rain (Total Precipitation)
'set gxout bar'
'set barbase 0'
'set bargap 20'
'set ccolor 42'
'd ptot'

* Snow
'set bargap 60'
'set ccolor 44'
'd psnow'

* Freezing rain
'set bargap 60'
'set ccolor 45'
'd ptot*cfrzrsfc'

* Convective Precipitation
'set gxout bar'
'set bargap 60'
'set ccolor 2'
'd pconv'

* Ice pellets
'set bargap 80'
'set ccolor 46'
'd ptot*cicepsfc'


* Draw all the Y-axis labels

* First panel
'set line 21' ; 'draw recf 0.4 7.65 0.62  8.18'
'set line 22' ; 'draw recf 0.4 7.65 0.58  8.18'
'set line 23' ; 'draw recf 0.4 7.65 0.535 8.18'
'set line 25' ; 'draw recf 0.4 7.65 0.49  8.18'
'set line 26' ; 'draw recf 0.4 7.65 0.445 8.18'
'set string 0 c 4 90' ; 'draw string 0.5 7.93 RH (%)'
if (units = 'e')
  'set string 2 l 4 90' ; 'draw string 0.5 8.79 (F)'
  'set string 1 c 4 90' ; 'draw string 0.5 9.40 Temp.(C) & Wind (nodi)'
else
  'set string 1 c 4 90' ; 'draw string 0.5 9.40 Temp.(C) & Wind (km/h)'
endif

* Next Panel
'set strsiz 0.08 0.12'
p = npanels - 1
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string  5 c 4 90' 
'draw string 0.3 'ymid' Geop. 500hPa'
'set string 1 c 4 90'
'draw string 0.5 'ymid' (hPa)'



* Next Panel
p = p - 1
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 11 c 4 90' ; 'draw string 0.3 'ymid' Press.SLM'
'set string  1 c 4 90' ; 'draw string 0.5 'ymid' (hPa)'

* Next Panel
p = p - 1
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 26 c 4 90' ; 'draw string 0.15 'ymid' Wind 10m'
'set string 26 c 4 90' ; 'draw string 0.35 'ymid' Speed & Direction.'
if (units = 'e')
  'set string 1 c 4 90'
  'draw string 0.75 'ymid' (mph)'
else
  'set string 1 c 4 90'
  'draw string 0.5 'ymid' (Km/h)'
endif

* Next Panel
p = p - 1
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string  2 c 4 90' ; 'draw string 0.3 'ymid' Temp. 2m '
*'set string 97 c 4 90' ; 'draw string 0.35 'ymid' 2m Dew Point '
*'set string 31 c 4 90' ; 'draw string 0.35 'ymid' Wind Chill'
*'set string 30 c 4 90' ; 'draw string 0.55 'ymid' Indice di Calore'
if (units = 'e')
  'set string 1 c 4 90'
  'draw string 0.6 'ymid' (F)'
else
  'set string 1 c 4 90'
  'draw string 0.5 'ymid' (C)'
endif

* Next Panel
p = p - 1
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 26 c 4 90' ; 'draw string 0.3 'ymid' Humidity'



*
* Next Panel
*p = p - 1
*ylo = subwrd(panel.p,3)
*yhi = subwrd(panel.p,4)
*ymid = ylo + (yhi-ylo)/2
*'set string  5 c 4 90' ; 'draw string 0.35 'ymid' Runoff'
*'set string 96 c 4 90' ; 'draw string 0.55 'ymid' `3d`0[ Moist]'
*
if (units = 'e')
  'set string 1 c 4 90' ; 'draw string 0.6 'ymid' (pollici)'
else
  'set string 1 c 4 90' ; 'draw string 0.5 'ymid' (%)'
endif


* Next Panel
p = p - 1
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string  8 c 4 90' ; 'draw string 0.3 'ymid' Temp.850hPa '

if (units = 'e')
  'set string 1 c 4 90'
  'draw string 0.75 'ymid' (F)'
else
  'set string 1 c 4 90'
  'draw string 0.5 'ymid' (C)'
endif


* Next Panel
*p = p - 1
*ylo = subwrd(panel.p,3)
*yhi = subwrd(panel.p,4)
*ymid = ylo + (yhi-ylo)/2
*'set string  4 c 4 90' ; 'draw string  0.15 'ymid' Rain '
*'set string  2 c 4 90' ; 'draw string  0.35 'ymid' Snow.'

*if (units = 'e')
*  'set string 1 c 4 90'
*  'draw string 0.75 'ymid' (pollici/6hr)'
*else
*  'set string 1 c 4 90'
*  'draw string 0.6 'ymid' (mm/hr)'
*  'draw string 0.8 'ymid' (cm/hr)'
*endif


* Bottom Panel

'set string  1 c 4 90'; 'draw string .85 1.10 (mm/hr)'
'set string 42 r 4 0' ; 'draw string 0.7 1.5 Total Rain'

'set string  2 r 4 0' ; 'draw string 0.7 1.3 Convective'

'set string 45 r 4 0' ; 'draw string 0.7 1.1 Frzg. Rain'

'set string 44 r 4 0' ; 'draw string 0.7 0.9 Snow (cm)'

'set string 46 r 4 0' ; 'draw string 0.7 0.7 Ice Pellets'





* Draw Labels at the top of the page
'set gxout stat'
'set lat 'hilat
'set lon 'hilon
*'set lev 1000'
'd HGTsfc'
hgtline=sublin(result,9)
hnn=subwrd(hgtline,4)
hnn=round(hnn)

'set string 1 r 1 0'
'set strsiz 0.14 .17'
hilat= round(100.0*hilat)/100.0
hilon= round(100.0*hilon)/100.0

label = '(c)G.Ihninger - WRF Meteogram for ('
if (hilon < 0)  ; label = label%hilon*(-1.0)'W, ' ; endif
if (hilon >= 0) ; label = label%hilon'E, ' ; endif
if (hilat < 0)  ; label = label%hilat*(-1.0)'S)'; endif
if (hilat >= 0) ; label = label%hilat'N)' ; endif
'draw string 8.15 10.89 'label
'draw string 8.15 10.68 H='hnn' m'

* Draw the station label
'set strsiz 0.13 0.17'
'set string 21 l 12 0' ; 'draw string 0.12 10.79 `1'name
'set string  1 l  8 0' ; 'draw string 0.10 10.81 `1'name



* Remove the dummy files
'!rm -f dummy.ctl'
'!rm -f dummy.dat'
'printim /wrfems/gmaps/Austria4/meteo.png x1000 y1000 png'

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* END OF MAIN SCRIPT
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* Assegna colori ausiliari

function setcols(args)
'set rgb 20 234 245 234'
'set rgb 21 200 215 200'
'set rgb 22 160 205 160'
'set rgb 23 120 215 120'
'set rgb 24  80 235  80'
'set rgb 25   0 255   0'
'set rgb 26   0 195   0'
'set rgb 27   0 160   0'
'set rgb 28   0 125   0'

'set rgb 30 255 160 120'
'set rgb 31 160 120 255'
'set rgb 32 160 180 205'

'set rgb 42  32 208  32'
'set rgb 43 208  32 208'
'set rgb 44  64  64 255'
'set rgb 45 255 120  32'
'set rgb 46  32 208 208'
'set rgb 47 240 240   0'

'set rgb 50 250 18  250'
'set rgb 51 230 24  230'
'set rgb 52 210 30  220'
'set rgb 53 190 30  210'
'set rgb 54 170 30  200'
'set rgb 55 131 27  190'
'set rgb 56 90  27  180'
'set rgb 57 0   0   255'
'set rgb 58 80  80  255'
'set rgb 59 120 120 255'
'set rgb 60 160 160 255'
'set rgb 61 200 200 255'
'set rgb 62 255 255 255'
'set rgb 63 255 250 200'
'set rgb 64 255 240 100'
'set rgb 65 255 230 0'
'set rgb 66 255 220 0'
'set rgb 67 255 210 0'
'set rgb 68 255 200 0'
'set rgb 69 255 190 0'
'set rgb 70 255 170 0'
'set rgb 71 255 150 0'
'set rgb 72 255 130 0'
'set rgb 73 255 110 0'
'set rgb 74 245 90  0'
'set rgb 75 220 70  0'
'set rgb 76 200 40  0'
'set rgb 77 180 0   0'
'set rgb 78 150 40  0'
'set rgb 79 120 0   0'
'set rgb 80  90 40  0'
'set rgb 81  60 0   0'



'set rgb 17    0  0 255'
'set rgb 18   30  30 255'
'set rgb 19   60  60 255'
'set rgb 82   80  80 255'
'set rgb 83  100 100 255'
'set rgb 84  120 120 255'
'set rgb 85  130 130 255'
'set rgb 86  140 140 255'
'set rgb 87  150 150 255'
'set rgb 88  160 160 255'
'set rgb 89  170 170 255'
'set rgb 90  180 180 255'
'set rgb 91  190 190 255'
'set rgb 92  200 200 255'
'set rgb 93  210 210 255'
'set rgb 94  220 220 255'
'set rgb 95  230 230 255'
'set rgb 96  235 235 255'
'set rgb 97  240 240 255'
'set rgb 98  245 245 255'
'set rgb 99  250 250 255'







return

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
function vrng(f1,f2)
'set gxout stat'
'd 'f1
data = sublin(result,8)
ymx = subwrd(data,5)
ymn = subwrd(data,4)
'd 'f2
data = sublin(result,8)
zmx = subwrd(data,5)
zmn = subwrd(data,4)
if (zmx > ymx) ; ymx = zmx ; endif
if (zmn < ymn) ; ymn = zmn ; endif
dy = ymx-ymn
ymx = ymx + 0.08 * dy
ymn = ymn - 0.08 * dy
if ((ymx-ymn)/2.2 < 1)
  incr = (ymx-ymn)/4
  incr = 0.01 * (math_nint(100*incr))
else
  incr = math_nint((ymx-ymn)/4)
endif
'set vrange 'ymn' 'ymx
'set ylint 'incr
*say 'vrng: 'ymn' 'ymx' 'incr
if (ymn=0 & ymx=0 & incr=0)
*  say 'vrng: resetting zeros to -.9 .9 1'
  'set vrange -.9 .9'
  'set ylint 1'
endif
'set gxout line'
return

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
function rh2vrng(f1)
'set gxout stat'
'd 'f1
data = sublin(result,8)
ymn = subwrd(data,4)
ymx = subwrd(data,5)
if (ymn < 20)
  miny = 0
  'set ylevs 20 40 60 80 100'
endif
if (ymn >= 20 & ymn < 30)
  miny = 20
  'set ylevs  40 60 80 100'
endif
if (ymn >= 30 & ymn < 40)
  miny = 30
  'set ylevs 40 50 60 70 80 90 100'
endif
if (ymn >= 40 & ymn < 50)
  miny = 40
  'set ylevs 40 50 60 70 80 90 100'
endif
if (ymn >= 50 & ymn < 60)
  miny = 50
  'set ylevs 50 60 70 80 90 100'
endif
if (ymn >= 60)
  miny = 60
  'set ylevs 70 80 90 100'
endif
'set vrange 'miny' 'ymx+3
return

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
function getctl(handle)
line = 1
found = 0
while (!found)
  info = sublin(_ctl,line)
  if (subwrd(info,1)=handle)
    _handle = info
    found = 1
  endif
  line = line + 1
endwhile
return _handle

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
function getgrid(dodsvar,myvar)

'set lon '_xdim
'set lat '_ydim
'set lev '_zgrd
'set time '_tdim

* Write the variable to a file
'set gxout fwrite'
'set fwrite dummy.dat'
'd 'dodsvar
'disable fwrite'

* Write a descriptor file
rc = write(dummy.ctl,'dset ^dummy.dat')
rc = write(dummy.ctl,_undef,append)
rc = write(dummy.ctl,'xdef 1 linear 1 1',append)
rc = write(dummy.ctl,'ydef 1 linear 1 1',append)
rc = write(dummy.ctl,_zdef,append)
rc = write(dummy.ctl,_tdef,append)
rc = write(dummy.ctl,'vars 1',append)
rc = write(dummy.ctl,'dummy '_newzsize' -999 dummy',append)
rc = write(dummy.ctl,'endvars',append)
rc = close (dummy.ctl)

* Open the dummy file, define variable, close dummy file
'open dummy.ctl'
line = sublin(result,2)
dummyfile = subwrd(line,8)
'set dfile 'dummyfile
'set lon 1'
'set lat 1'
'set lev '_zbot' '_ztop
'set time '_time1' '_time2
'define 'myvar' = dummy.'dummyfile
'close 'dummyfile
'set dfile 1'
return

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
function getetarh(dodsvar,myvar)

* swap out original pressure vars
tmpzgrd = _zgrd
tmpzdef = _zdef
tmpzbot = _zbot
tmpztop = _ztop
tmpzsize = _newzsize

* retrieve rh data over the rh pressure range
_zgrd = _rhzgrd
_zdef = _trhzdef
_ztop = _rhztop
_zbot = _rhzbot
_newzsize = _trhzsize
getgrid(dodsvar,tmprh)

* swap in original pressure vars
_zgrd = tmpzgrd
_zdef = tmpzdef
_zbot = tmpzbot
_ztop = tmpztop
_newzsize = tmpzsize

'set lon '_xdim
'set lat '_ydim
'set lev '_rhzgrd
'set time '_tdim

* Write the variable to a file
'set gxout fwrite'
'set fwrite dummy.dat'
t = _t1
while (t <= _t2)
  'set t 't
  z = 1
  while (z <= _newrhzsize)
    level = subwrd(_rhlevs,z)
    'set lev 'level
    'd tmprh'
    z = z + 1
  endwhile
  t = t + 1
endwhile
'disable fwrite'

* Write a descriptor file
rc = write(dummy.ctl,'dset ^dummy.dat')
rc = write(dummy.ctl,_undef,append)
rc = write(dummy.ctl,'xdef 1 linear 1 1',append)
rc = write(dummy.ctl,'ydef 1 linear 1 1',append)
rc = write(dummy.ctl,_rhzdef,append)
rc = write(dummy.ctl,_tdef,append)
rc = write(dummy.ctl,'vars 1',append)
rc = write(dummy.ctl,'dummy '_newrhzsize' -999 dummy',append)
rc = write(dummy.ctl,'endvars',append)
rc = close (dummy.ctl)

* Open the dummy file, define variable, close dummy file
'open dummy.ctl'
line = sublin(result,2)
dummyfile = subwrd(line,8)
'set dfile 'dummyfile
'set lon 1'
'set lat 1'
'set lev '_rhzbot' '_rhztop
'set time '_time1' '_time2
'q dims'
'define 'myvar' = dummy.'dummyfile
'close 'dummyfile
'set dfile 1'

return

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
function getseries(dodsvar,myvar,level)

'set lon '_xdim
'set lat '_ydim
'set lev 244.57 244.57'
'set time '_tdim
'set z 2 2'
'q dim'
say result
say _xdim
say _ydim
say _tdim
say level
say dodsvar
' q ctlinfo'
* Write the variable to a file
'set fwrite dummy.dat'
'set gxout fwrite'
'd 'dodsvar
say dodsvar
'disable fwrite'

* Write a descriptor file
rc = write(dummy.ctl,'dset ^dummy.dat')
rc = write(dummy.ctl,_undef,append)
rc = write(dummy.ctl,'xdef 1 linear 1 1',append)
rc = write(dummy.ctl,'ydef 1 linear 1 1',append)
rc = write(dummy.ctl,'zdef 1 linear 1 1',append)
rc = write(dummy.ctl,_tdef,append)
rc = write(dummy.ctl,'vars 1',append)
rc = write(dummy.ctl,'dummy 0 -999 dummy',append)
rc = write(dummy.ctl,'endvars',append)
rc = close(dummy.ctl)

* Open the dummy file, define variable, close dummy file
'open dummy.ctl'
line = sublin(result,2)
dummyfile = subwrd(line,8)
'set dfile 'dummyfile
'set lon 1'
'set lat 1'
'set lev 'level
'set time '_time1' '_time2
'define 'myvar' = dummy.'dummyfile
'close 'dummyfile
'set dfile 1'
'set gxout contour'

return


***********************************************************************
function round(i)

rr=abs(1.0*i)
rr=int(rr+0.5)
if (i < 0)
   rr=-1*rr     
endif
return(rr)


**************************************************************************


function int(i0)

*--------------------------
* Return integer of i0
*--------------------------
  i=0
  while(i<12)
    i=i+1
    if(substr(i0,i,1)='.')
      i0=substr(i0,1,i-1)
      break
    endif
  endwhile
return(i0)

*************************************************************************

function abs(i)

*----------------------------
* return absolute value of i
*----------------------------

  if (i < 0)
     absval=-i
  else
     absval=i
  endif

return(absval)
