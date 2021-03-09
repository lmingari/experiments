#!/bin/bash 

#BSUB -n ${NTASKS}
#BSUB -cwd ${RUNDIR}
#BSUB -oo ${LOGDIR}/FALL3D-GFS_POS_%J.out
#BSUB -eo ${LOGDIR}/FALL3D-GFS_POS_%J.err
#BSUB -J FALL3D-GFS_POS
#BSUB -w 'done(FALL3D-GFS)'
#BSUB -W 01:00
#BSUB -q xlarge

RUNDIR=${RUNDIR}
EXPDIR=${EXPDIR}
PRJDIR=${PRJDIR}
F3DIR=${F3DIR}
PRJNAME=${PRJNAME}
NENS=${NENS}
TASK="posens"
###ENDDEF

echo "$(date '+%d/%m/%Y %H:%M:%S'): Starting FALL3D-GFS_POS" >> ${PRJDIR}/status.log

module load ANACONDA/3-2020.02
source activate ncl_stable
source ${EXPDIR}/set_environment.sh
source ${PRJDIR}/set_parameters.sh

mpirun ${F3DIR}/Fall3d.r8.x ${TASK} ${PRJNAME}.inp -nens ${NENS}

POSTDIR="${RUNDIR}/POST"
for POSTJOB in col-mass deposit fl200 fl350 fl450 cloud-top
do
    ncl ${POSTDIR}/${POSTJOB}.ncl      glon=${lon_vent} glat=${lat_vent} & 
    ncl ${POSTDIR}/prob-${POSTJOB}.ncl glon=${lon_vent} glat=${lat_vent}
done

###Store in ARCHIVE
DATE=$(date +"%Y%m%d")
IRUN=$(find ${RUNDIR}/ARCHIVE -name "${DATE}-???" | wc -l)
ARCHIVE="${RUNDIR}/ARCHIVE/${DATE}-$(printf %03d ${IRUN})"
mkdir "${ARCHIVE}"
cp -r ${POSTDIR}/deterministic        ${ARCHIVE}
cp -r ${POSTDIR}/probabilistic        ${ARCHIVE}
cp    ${RUNDIR}/${PRJNAME}.ens.nc     ${ARCHIVE}
cp    ${RUNDIR}/${PRJNAME}.inp        ${ARCHIVE}
cp    ${RUNDIR}/${PRJNAME}.SetEns.log ${ARCHIVE}

echo "$(date '+%d/%m/%Y %H:%M:%S'): FALL3D-GFS_POS Done" >> ${PRJDIR}/status.log
