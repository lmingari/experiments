#!/bin/bash 

#BSUB -n 1
#BSUB -cwd ${RUNDIR}
#BSUB -oo ${LOGDIR}/WPS_%J.out
#BSUB -eo ${LOGDIR}/WPS_%J.err
#BSUB -J WPS
#BSUB -W 02:00
#BSUB -q xlarge

RUNDIR=${RUNDIR}
EXPDIR=${EXPDIR}
PRJDIR=${PRJDIR}
###ENDDEF

echo "$(date '+%d/%m/%Y %H:%M:%S'): Starting WPS" >> ${PRJDIR}/status.log

source ${EXPDIR}/set_environment.sh

DATE=$(date +"%Y-%m-%d")

start_date=$(date -u --date="${DATE} 00:00 Z" +'%Y-%m-%d_%H:%M:%S')
end_date=$(date -u --date="${DATE} 00:00 Z +${total_hours} hour" +'%Y-%m-%d_%H:%M:%S')

sed -e "s/\${start_date}/${start_date}/" \
    -e "s/\${end_date}/${end_date}/"     \
    ${RUNDIR}/namelist.base.wps > ${RUNDIR}/namelist.wps

${RUNDIR}/link_grib.csh ${PRJDIR}/GFS/gfs.*
rm ${RUNDIR}/met_em.d01.*

${RUNDIR}/geogrid.exe
${RUNDIR}/ungrib.exe
${RUNDIR}/metgrid.exe

echo "$(date '+%d/%m/%Y %H:%M:%S'): WPS Done" >> ${PRJDIR}/status.log
