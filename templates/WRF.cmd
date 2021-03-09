#!/bin/bash 

#BSUB -n ${NTASKS}
#BSUB -cwd ${RUNDIR}
#BSUB -oo ${LOGDIR}/WRF_%J.out
#BSUB -eo ${LOGDIR}/WRF_%J.err
#BSUB -J WRF
#BSUB -w 'done(REAL)'
#BSUB -W 02:30
#BSUB -q xlarge
#BSUB -R "span[ptile=8]"
#BSUB -x

RUNDIR=${RUNDIR}
EXPDIR=${EXPDIR}
PRJDIR=${PRJDIR}
###ENDDEF

echo "$(date '+%d/%m/%Y %H:%M:%S'): Starting WRF" >> ${PRJDIR}/status.log

source ${EXPDIR}/set_environment.sh
export OMP_NUM_THREADS=2

mpirun ${RUNDIR}/wrf.exe 

echo "$(date '+%d/%m/%Y %H:%M:%S'): WRF Done" >> ${PRJDIR}/status.log
