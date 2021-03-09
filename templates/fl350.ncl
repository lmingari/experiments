load "${RUNDIR}/POST/lib_fall3d.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

begin
  volcano                = "${volcano}"
  if(.not. isdefined("glon")) then
      glon = ${lon_vent}
  end if
  if(.not. isdefined("glat")) then
      glat = ${lat_vent}
  end if

  ;************************************************
  ; create points for box
  ;************************************************
   ypts1 = (/ 73., 61.,  61.,   61.,   63.5,  70.,   73.,  73. /)
   xpts1 = (/ 0.0, 0.0, -10.0, -30.0, -39.0, -20.0, -20.0, 0.0 /)

  varname                = "tephra_con_mean"

;---base path
  path                   = "${INPATH}/"
  outpath                = "${OUTPATH}/"
  fname                  = "${PRJNAME}.ens.nc"

;---Open WRF/FALL3D files
  a                      = addfile(path+fname,"r")

  wks_type               = "pdf"
  wks_type@wkPaperWidthF = 9
  wks_type@wkPaperHeightF= 8
  wks                    = gsn_open_wks(wks_type,outpath+varname)

  times  = a->time
  ntimes = dimsizes(times)
  format = "%d-%c-%Y %H:%M"
  stimes = cd_string(times,format)

  ik = 6
  fl = a->fl(ik)
  
;---Set common resources for all plots
  res                    = True
  res@gsnFrame           = False
  res@gsnDraw            = False
  res@gsnLeftString      = ""
  res@gsnRightString     = ""

  res@tiXAxisOn          = False
  res@tiYAxisOn          = False

  opts          = True
; Log requires: minimo, decadas
;  opts@scale    = "log"
;  opts@scale1   = -5
;  opts@decadas  = 4
;  opts@minimo   = 0.0
;  opts@maximo   = 1E9
; Linear requires: scale1, scale2, minimo, step, stride
  opts@scale    = "linear"
  opts@scale1   = 0
  opts@scale2   = 4
  opts@step     = 2
  opts@stride   = 1
  opts@minimo   = 0.2
  ;
  opts@lonmin   = a->lon@minimum
  opts@lonmax   = a->lon@maximum
  opts@latmin   = a->lat@minimum
  opts@latmax   = a->lat@maximum
  opts@volcano  = volcano
  opts@fontsize = 0.012
  opts@cmap     = (/(/0.,0.,0.,0./),(/0.25098,0.878431,0.815686,1./),(/0.7,0.7,0.7,1./),(/1.,0.,0.,1./)/)

  ypts2 = (/ opts@latmin, opts@latmin, opts@latmax, opts@latmax, opts@latmin /)
  xpts2 = (/ opts@lonmin, opts@lonmax, opts@lonmax, opts@lonmin, opts@lonmin /)

;---Map plot
  map_res = res
  set_map_resources(map_res,opts)
  map_res@gsnLeftString = "Concentration at FL"+fl+" in mg m~S~-3~N~"
  map_res@tiMainFont    = "helvetica"

  cres_base = res
  set_base_contour_resources(cres_base,opts)

  cres = res
  opts@fontsize = 0.016
  set_contour_resources(cres,opts)

;--- Polymarker   
  polyres                    = True
  polyres@gsMarkerIndex      = 14          ; polymarker style
  polyres@gsMarkerSizeF      = 14.         ; polymarker size
  polyres@gsMarkerColor      = "blue"
  polyres@gsMarkerThicknessF = 2
  polyres@gsMarkerOpacityF   = 0.9

  polyline1                  = True   
  polyline1@gsLineColor      = "red"  
  polyline1@gsLineThicknessF = 2.0    

  polyline2                  = True   
  polyline2@gsLineColor      = "blue"  
  polyline2@gsLineThicknessF = 2.0    

  resP                       = True
  resP@gsnMaximize           = True
  resP@gsnPaperOrientation   = "portrait"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  do it = 0,ntimes-1,1
    print("Working on hour: " + times(it) )
;---First get the variables we will need
    x = a->$varname$(it,ik,:,:)
    x = 1E3*x
    
    map_res@gsnRightString = stimes(it)
    map                    = gsn_csm_map(wks,map_res)
    contour1               = gsn_csm_contour(wks,x,cres)  
    ;contour2               = gsn_csm_contour(wks,x,cres_base)  

;---Overlay plots on map and draw.
    overlay(map,contour1)
    ;overlay(map,contour2)

    dum  = gsn_add_polymarker(wks,map,glon, glat, polyres)
    dum1 = gsn_add_polyline  (wks,map,xpts1,ypts1,polyline1)      
    dum2 = gsn_add_polyline  (wks,map,xpts2,ypts2,polyline2)      

;    draw(map)   ; This will draw all overlaid plots and the map
;    frame(wks)

    gsn_panel(wks,map,(/1,1/),resP)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  end do
end
