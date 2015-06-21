ncatted -a standard_name,QR,o,c,mass_fraction_of_rain_in_air            ente.nc 
ncatted -a standard_name,QS,o,c,mass_fraction_of_snow_in_air            ente.nc 
ncatted -a standard_name,QH,o,c,mass_fraction_of_graupel_in_air         ente.nc 
ncatted -a standard_name,UBAR,o,c,x_wind                                ente.nc 
ncatted -a standard_name,VBAR,o,c,y_wind                                ente.nc 
ncatted -a standard_name,QVBAR,o,c,specific_humidity_in_atmosphere      ente.nc 
ncatted -a standard_name,QVBAR,o,c,troposhere_specific_humidity         ente.nc 
ncatted -a standard_name,WBAR,o,c,upward_air_velocity                   ente.nc 
ncatted -a standard_name,QVBAR,o,c,surface_specific_humidity            ente.nc 
ncatted -a standard_name,PBAR,o,c,surface_air_pressure                  ente.nc 
ncks -x -v KMV,KMH,PTBAR ente.nc  out.nc
ncatted -a ,global,d,, -a ,global,d,, out.nc
