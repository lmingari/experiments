;---Define color palettes
  lcmap       = read_colormap_file("MPL_YlOrRd")
  ;lcmap       = read_colormap_file("MPL_viridis")
  lcmap(0,:)  = (/0.,0.,0.,0./)    ; Fully transparent

;--------------------------------------------------------------------------------
; Set Resources for base filled contour 
;--------------------------------------------------------------------------------
undef("set_base_contour_resources")
procedure set_base_contour_resources(con_res[1]:logical, \
                                     opts[1]:logical)
local minimo,fontsize
begin

  if(opts.and.isatt(opts,"minimo")) then
    minimo = opts@minimo
  else
    minimo = 0.
  end if

  if(opts.and.isatt(opts,"fontsize")) then
    fontsize = opts@fontsize
  else
    fontsize = 0.014
  end if

  if(con_res) then
      con_res@cnFillOn                   = True
      con_res@cnFillOn                   = False
      con_res@cnLinesOn                  = True
      con_res@cnInfoLabelOn              = False
      con_res@cnLineLabelsOn             = False
      con_res@cnLevelSelectionMode       = "ExplicitLevels"
      con_res@cnLevels                   = (/ minimo /)
      con_res@cnLineThicknessF           = 2.0
      con_res@cnLineColor                = "black" 
      con_res@lbLabelBarOn               = False
      con_res@tmXBLabelDeltaF            = -0.5

      con_res@gsnLeftStringFontHeightF     = fontsize
      con_res@gsnRightStringFontHeightF    = fontsize
      con_res@gsnRightStringOrthogonalPosF = 0.0
      con_res@gsnLeftStringOrthogonalPosF  = 0.0
  end if

end 
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Set Resources for filled contour 
;--------------------------------------------------------------------------------
undef("set_contour_resources")
procedure set_contour_resources(con_res[1]:logical, \
                                opts[1]:logical)
local minimo,maximo,scale1,scale2,step,stride, \
      nlev,nlevd,nlev_min,nlev_max,rlev,llev,  \
      levels,decadas,labels,fontsize,cmap
begin

  if(opts.and.isatt(opts,"cmap")) then
    cmap = opts@cmap
  else
    cmap = lcmap
  end if

  if(opts.and.isatt(opts,"minimo")) then
    minimo = opts@minimo
  else
    minimo = 1E-6
  end if

  if(opts.and.isatt(opts,"maximo")) then
    maximo = opts@maximo
  else
    maximo = 1E6
  end if

  if(opts.and.isatt(opts,"scale1")) then
    scale1 = opts@scale1
  else
    scale1 = 0.
  end if

  if(opts.and.isatt(opts,"scale2")) then
    scale2 = opts@scale2
  else
    scale2 = 10.
  end if

  if(opts.and.isatt(opts,"step")) then
    step = opts@step
  else
    step = 0.1
  end if

  if(opts.and.isatt(opts,"stride")) then
    stride = opts@stride
  else
    stride = 1.
  end if

  if(opts.and.isatt(opts,"decadas")) then
    decadas = opts@decadas
  else
    decadas = 3.
  end if

  if(opts.and.isatt(opts,"fontsize")) then
    fontsize = opts@fontsize
  else
    fontsize = 0.014
  end if

  if(con_res) then
      con_res@cnFillOn                   = True
      con_res@cnLinesOn                  = True
      con_res@cnInfoLabelOn              = False
      con_res@cnLineLabelsOn             = False
      con_res@cnLineThicknessF           = 2.0
      con_res@cnFillPalette              = cmap
      con_res@cnFillMode                 = "AreaFill"
      ;con_res@cnRasterSmoothingOn        = True
      con_res@cnSmoothingOn              = False

      con_res@lbLabelBarOn               = True    
      con_res@lbTitleFontHeightF         = fontsize
      con_res@lbLabelFontHeightF         = fontsize
      con_res@lbLabelAngleF              = 0.0
      con_res@lbLabelStride              = 1
      con_res@lbLabelAutoStride          = False
   ;   con_res@lbBoxLinesOn               = False
   ;   con_res@lbBoxEndCapStyle           = "TriangleBothEnds"
      
    ;---Vertical
      ;con_res@lbOrientation              = "vertical"
      ;con_res@lbTitlePosition            = "Left"
      ;con_res@lbTitleAngleF              = 90
      ;con_res@lbTitleDirection           = "Across"

    ;---Horizontal
      con_res@lbOrientation              = "horizontal"
      con_res@pmLabelBarOrthogonalPosF   = 0.025
      con_res@pmLabelBarHeightF          = 0.1  
  end if

  if(opts.and.isatt(opts,"scale")) then
    con_res@cnLevelSelectionMode = "ExplicitLevels"
    if( opts@scale.eq."log" ) then
      print("Using log scale")
      nlevd  = 1 ;levels per decade
      nlev   = decadas*nlevd + 1
      levels = fspan(scale1,scale1+decadas,nlev)
      labels = new(nlev,string,"")
      labels(::nlevd) = "10~S~" + ispan(scale1,scale1+decadas,1) + "~N~"
      levels = 10^levels
    else
      print("Using linear scale")
      nlev   = toint((scale2-scale1)/step+1.5)
      levels = fspan(scale1,scale2,nlev)
      labels = ""+levels
      labels = where(mod(levels,stride).eq.0,levels,"")
    end if
    ;
    ;---Redefine minimum/maximum
    nlev_min = 0
    nlev_max = nlev-1
    do i=0,nlev-2
        rlev = levels(i+1)
        llev = levels(i)
        if(minimo.ge.llev .and. minimo.lt.rlev) then
            print("redefined minimum: "+minimo)
            nlev_min = i
            levels(i) = minimo
            labels(i) = ""+minimo
        end if
        ;
        if(maximo.gt.llev .and. maximo.le.rlev) then
            print("redefined maximum: "+maximo)
            nlev_max = i
            levels(i) = maximo
            labels(i) = ""+maximo
        end if
    end do
    ;
    con_res@cnLevels       = levels(nlev_min:nlev_max)
    con_res@lbLabelStrings = labels(nlev_min:nlev_max)
  else
    print("Using automatic scale")
    con_res@cnLevelSelectionMode = "AutomaticLevels"
  end if

  if(opts.and.isatt(opts,"title")) then
    con_res@lbTitleString = opts@title
    con_res@lbTitleFontHeightF = fontsize
  end if

end 
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Set Resources for map 
;--------------------------------------------------------------------------------
undef("set_map_resources")
procedure set_map_resources(map_res[1]:logical, \
                            opts[1]:logical)
local fontsize,lonmin,lonmax,latmin,latmax
begin

  if(opts) then
    if(isatt(opts,"fontsize")) then
        fontsize = opts@fontsize
    else
        fontsize = 0.014
    end if

    if(isatt(opts,"lonmin")) then
        lonmin = opts@lonmin
    else
        lonmin = 0.0
    end if

    if(isatt(opts,"lonmax")) then
        lonmax = opts@lonmax
    else
        lonmin = 0.0
    end if

    if(isatt(opts,"latmin")) then
        latmin = opts@latmin
    else
        latmin = 0.0
    end if

    if(isatt(opts,"latmax")) then
        latmax = opts@latmax
    else
        latmax = 0.0
    end if

  end if

  if(map_res) then
      map_res@tfDoNDCOverlay        = False
      map_res@mpProjection          = "LambertConformal"
      map_res@mpLambertParallel1F   = 0.5*(latmin+latmax)
      map_res@mpLambertParallel2F   = 0.5*(latmin+latmax) 
      map_res@mpLambertMeridianF    = 0.5*(lonmin+lonmax)

      map_res@mpLimitMode                 = "LatLon"
      map_res@mpMinLonF                   = lonmin
      map_res@mpMaxLonF                   = lonmax
      map_res@mpMinLatF                   = latmin
      map_res@mpMaxLatF                   = latmax

      map_res@mpFillOn                    = True
      map_res@mpOutlineOn                 = True
      map_res@mpDataBaseVersion           = "MediumRes"
    ;  map_res@mpDataBaseVersion           = "HighRes"
      map_res@mpDataSetName               = "Earth..4"
      map_res@mpOutlineDrawOrder          = "PostDraw"
      map_res@mpOutlineBoundarySets       = "National"
      map_res@mpPerimLineColor            = "Black"
      map_res@mpNationalLineColor         = "Black"
      map_res@mpLimbLineColor             = "Black"
      map_res@mpGridLineColor             = "Black"
      map_res@mpGeophysicalLineColor      = "Black"
      map_res@mpNationalLineThicknessF    = 0.5
      map_res@mpGeophysicalLineThicknessF = 0.5
      map_res@mpGridAndLimbOn             = True
      map_res@mpGridLatSpacingF           = 5
      map_res@mpGridLonSpacingF           = 5
      map_res@mpGridLineDashPattern       = 2

      map_res@tmXBLabelFontHeightF        = fontsize*0.75
      map_res@tmXBLabelDeltaF             = -0.5

      map_res@tmXTLabelFontHeightF        = fontsize*0.75
      map_res@tmXTLabelDeltaF             = -0.5

      map_res@tmYLLabelFontHeightF        = fontsize*0.75
      map_res@tmYLLabelAngleF             = 90
      map_res@tmYLLabelJust               = "CenterCenter"

      map_res@tmYRLabelFontHeightF        = fontsize*0.75
      map_res@tmYRLabelAngleF             = -90
      map_res@tmYRLabelJust               = "CenterCenter"

      map_res@gsnLeftStringFontHeightF    = fontsize*1.2
      map_res@gsnRightStringFontHeightF   = fontsize*1.2
      map_res@gsnRightStringOrthogonalPosF= 0.02
      map_res@gsnLeftStringOrthogonalPosF = 0.02

      map_res@pmTickMarkDisplayMode       = "Always"

      map_res@mpPerimOn = True
  end if

end

;********************************************************************
; This function creates and draws a labelbar based on a given 
; contour plot.
;********************************************************************
function labelbar(wks,plot,labels)
local colors, levels, nboxes, title
begin

;---Retrieve the contour levels and their associated colors.
  getvalues plot
    "cnLevels"      : levels
    "cnFillColors"  : colors
    "lbTitleString" : title
  end getvalues

  nboxes = dimsizes(colors)

;---Set some labelbar resources.
  lbres                    = True
  lbres@vpXF               = 0.15         ; Position labelbar at         
  lbres@vpYF               = 0.1          ; bottom edge of plot
  lbres@vpWidthF           = 0.70
  lbres@vpHeightF          = 0.10

  lbres@lbPerimOn          = False            ; Turn off perimeter.
  lbres@lbOrientation      = "Horizontal"     ; Default is vertical.
  lbres@lbFillColors       = colors
  lbres@lbMonoFillPattern  = True             ; Fill them all solid.
  lbres@lbLabelAlignment   = "InteriorEdges"
  lbres@lbBoxLinesOn       = False
  lbres@lbLabelStride      = 1
  lbres@lbLabelAutoStride  = False
  lbres@lbTitleFontHeightF = 0.012
  lbres@lbLabelFontHeightF = 0.012
  lbres@lbTitleString      = title

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)

  return(lbid)   ; Return it so we can maximize later if desired.
end
