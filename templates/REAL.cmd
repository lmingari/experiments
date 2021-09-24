#!/bin/bash 

#BSUB -n 1
#BSUB -cwd ${RUNDIR}
#BSUB -oo ${LOGDIR}/REAL_%J.out
#BSUB -eo ${LOGDIR}/REAL_%J.err
#BSUB -J REAL
#BSUB -w 'done(WPS)'
#BSUB -W 01:00
#BSUB -q xlarge

RUNDIR=${RUNDIR}
EXPDIR=${EXPDIR}
PRJDIR=${PRJDIR}
###ENDDEF

echo "$(date '+%d/%m/%Y %H:%M:%S'): Starting REAL" >> ${PRJDIR}/status.log

source ${EXPDIR}/set_environment.sh

DATE=$(date +"%Y-%m-%d")

start_year=$(date +"%Y")
start_month=$(date +"%m")
start_day=$(date +"%d")

end_year=$(date -u --date="${DATE} 00:00 Z +${total_hours} hour" +'%Y')
end_month=$(date -u --date="${DATE} 00:00 Z +${total_hours} hour" +'%m')
end_day=$(date -u --date="${DATE} 00:00 Z +${total_hours} hour" +'%d')
end_hour=$(date -u --date="${DATE} 00:00 Z +${total_hours} hour" +'%H')

sed -e "s/\${start_year}/${start_year}/g"   \
    -e "s/\${start_month}/${start_month}/g" \
    -e "s/\${start_day}/${start_day}/g"     \
    -e "s/\${end_year}/${end_year}/g"       \
    -e "s/\${end_month}/${end_month}/g"     \
    -e "s/\${end_day}/${end_day}/g"         \
    -e "s/\${end_hour}/${end_hour}/g"       \
    ${RUNDIR}/namelist.base.input > ${RUNDIR}/namelist.input
    
rm ${RUNDIR}/met_em.d01.*
ln -s ../WPS/met_em.d01.* .

rm ${RUNDIR}/met_em.d02.*
ln -s ../WPS/met_em.d02.* .

mpirun ${RUNDIR}/real.exe 

echo "$(date '+%d/%m/%Y %H:%M:%S'): REAL Done" >> ${PRJDIR}/status.log
