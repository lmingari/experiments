begin
  volcano                = "${volcano}"
  if(.not. isdefined("glon")) then
      glon = ${lon_vent}
  end if
  if(.not. isdefined("glat")) then
      glat = ${lat_vent}
  end if


  varname                = "tephra_cloud_top"

;---base path
  path                   = "${INPATH}/0001/"
  outpath                = "${OUTPATH}/"
  fname                  = "${PRJNAME}.res.nc"

  print("Cloud top not shown for ensemble runs")
end
