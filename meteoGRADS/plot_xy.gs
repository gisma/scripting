*********************************************************************
* The following lines will display an arbitrary X section
* from one specified point to another.
*
* lon1 is the westernmost longitude point
* lon2 is the easternmost longitude point
* lat1 is the latitude that corresponds to lon1
* lat2 is the latitude that corresponds to lon2
*
********************************************************************


'reinit'


'set parea 1 9.25 1 7.75'
timestep=1
height=1000



'set t 'timestep
* 'open /home/creu/progs/opengrads/data/stol_d1_ARP.trndata.ctl'
'open /home/creu/Daten/ARPS/ente/kilid1_E2A.trndata.ctl'
*'set lon  13.1 14.1'
*'set lat  46.0 46.5'

 
'set lev 1 '    
'set gxout shaded'
*'set clevs 0 100 200 300 400 500 600 700 800 900 1000 1500 2000 2500 3000'
*'set ccols 0 39 37 35 33 31 71 72 73 74 75 76 77 78 79 80'

'set mpdset mres'
'set mpdraw on'
*'color -gxout shaded   0 1500 100  -kind blue->white->red 1' 
    'd trn'      
    'cbarn 0.8 1'  
'close 1'

'open /home/creu/progs/opengrads/data/stol_d1_ARP.gradscntl'

'set lon  13.1 14.1'
'set lat  46.0 46.5'
'set line 0'
'draw rec 0 0 11 8.5'
'enable print tmp1.out'
'set grads off'
*'set x 1'
*'set y 10'


************************************************************************
*                                                                      *
* Set up the user's environment and draw an initial picture of pt      *
*                                                                      *
************************************************************************

    'set lev 1'

    'set csmooth on'
    'set clab forced'
    'set cterp off'
    'set gxout contour'
*   'set gxout shaded'
    'set csmooth on'
    'set grads off'
    'd (mag(u, v))'

'set gxout stream'
'set arrlab on'
'set ccolor 0'
'set cthick 1'
'd coll2gr(2);coll2gr(4)'

*   dummy = colorbars()
    'draw title Initial WHINDSPEED KM/ at z='height
function arrow(x,y,len,scale)
'set line 0 1 4'
'draw line 'x-len/2.' 'y' 'x+len/2.' 'y
'draw line 'x+len/2.-0.05' 'y+0.025' 'x+len/2.' 'y
'draw line 'x+len/2.-0.05' 'y-0.025' 'x+len/2.' 'y
'set string 0 c'
'set strsiz 0.1'
'draw string 'x' 'y-0.1' 'scale'  m/s'

return
