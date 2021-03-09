#!/bin/bash

BASEPATH="${PRJDIR}"

echo "GFS updated. Launching jobs..."
bsub < ${BASEPATH}/SCRIPTS/FALL3D-GFS.cmd
bsub < ${BASEPATH}/SCRIPTS/FALL3D-GFS_POS.cmd
